;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Interrupt command program		|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				データ読み込み			*
;*								*
;****************************************************************
;===============================================================|
;		Command Read					|
;===============================================================|
;	●処理							|
;		　データの読み込み				|
;		　ワークフラグが立っていた場合は、ワークから	|
;	●引数							|
;		es:si	演奏中のアドレス			|
;	●返値							|
;		es:si	次の引数又はコマンドのアドレス		|
;		al(ax)	引数					|
;								|
;===============================================================|
;●8bit版========================================================
I_Read8:				;
	mov	al,es:[si]		;データ読み込み
	inc	si			;ポインタ・インクリメント
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkSw
	jz	I_Read8_End		;ワークからであるか？

	push	bx			;	{ワーク読み込み}
	mov	bh,ds:[di].WTD_WorkAddress
	mov	bl,al			;bx←ワークオフセットアドレス
	mov	al,ds:[bx]		;
	pop	bx			;

I_Read8_End:				;
	ret				;終了
;●16bit版=======================================================
I_Read16:				;
	mov	ax,es:[si]		;データ読み込み
	inc	si			;ポインタ・インクリメント
	inc	si			;
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkSw
	jz	I_Read16_End		;ワークからであるか？

	push	bx			;	{ワーク読み込み}
	mov	bh,ds:[di].WTD_WorkAddress
	mov	bl,al			;bx←ワークオフセットアドレス
	mov	ax,ds:[bx]		;
	pop	bx			;

I_Read16_End:				;
	ret				;終了
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				音階コマンド(80h～FFh)		*
;*								*
;****************************************************************
;音階コード
	even				;偶数アドレス配置
I_PlayKey_Code:
	db	0			;c
	db	2			;d
	db	4			;e
	db	5			;f
	db	7			;g
	db	9			;a
	db	11			;b
;---------------------------------------------------------------
	even				;偶数アドレス配置
I_PlayKey_Auto:				;オートの半音処理(未解決)
	push	cx			;レジスタ保存

	and	cl,07h			;cl←音程(0～7)

;＃処理
	mov	ch,ds:[di].WTD_FlagSharp	;
	shr	ch,cl				;
	jnc	I_PlayKey_Auto_Step1		;チェック
	inc	al				;KeyCode ++
I_PlayKey_Auto_Step1:				;

;ｂ処理
	mov	ch,ds:[di].WTD_FlagFlat		;
	shr	ch,cl				;
	jnc	I_PlayKey_Auto_Step2		;チェック
	dec	al				;KeyCode --
I_PlayKey_Auto_Step2:				;

	pop	cx			;
	ret				;
;---------------------------------------------------------------
	even				;偶数アドレス配置
I_PlayKey:				;
	push	ax			;レジスタ保存
	push	bx			;
	push	cx			;
	push	dx			;

;音程演算処理
	mov	cl,al				;cl←コマンド
	and	ax,07h				;al←音階情報(0～7)
	sub	ax,1				;
	jnc	I_PlayKey_Step1			;休符？
	mov	ds:[di].WTD_Key,al		;音程保存
	jmp	I_PlayKey_Step2R		;
I_PlayKey_Step1:				;
	mov	bx,offset I_PlayKey_Code	;
	push	si				;
	mov	si,ax				;
	mov	al,cs:[bx + si]			;
	pop	si				;
	mov	ch,al				;ch←音階情報
	mov	al,ds:[di].WTD_Octave		;
	mov	ah,12				;
	imul	ah				;
	add	al,ch				;al←Key Code

;半音演算処理
	test	cl,008h				;Sharp Flag Check
	jnz	I_PlayKey_Step3			;
;'#' Flag = '0'
	test	cl,010h				;Flat Flag Check
	jnz	I_PlayKey_Step4			;
;'#b' Flag = '00'
	call	I_PlayKey_Auto			;自動半音処理
	jmp	I_PlayKey_Step2			;
I_PlayKey_Step4:				;
;'#b' Flag = '01'
	dec	al				;音程－１
	call	I_PlayKey_Auto			;自動半音処理
	jmp	I_PlayKey_Step2			;
;'#' Flag = '1'
I_PlayKey_Step3:				;
	test	cl,010h				;Flat Flag Check
	jnz	I_PlayKey_Step5			;
;'#b' Flag = '10'
	inc	al				;音程＋１
	call	I_PlayKey_Auto			;自動半音処理
	jmp	I_PlayKey_Step2			;
I_PlayKey_Step5:				;
;'#b' Flag = '11'	Nothing
;	jmp	I_PlayKey_Step2			;自動半音　無し

I_PlayKey_Step2:				;
	add	al,12				;KeyCode補正(MIDI単位)
	mov	ds:[di].WTD_Key,al		;音程保存
;ハードウェアをKeyOn
	add	al,ds:[di].WTD_KeyShift		;
	mov	dx,offset I_Table_KeyOn		;
	call	I_Table_Jump			;KeyOn

I_PlayKey_Step2R:				;
;タイフラグチェック
	test	cl,020h				;タイフラグチェック
	jz	I_PlayKey_Step6			;cy←0
	stc					;cy←1
I_PlayKey_Step6:				;
	rcl	ds:[di].WTD_FlagTai,1		;シフト

;音長フラグのチェック
	test	cl,040h				;音長フラグチェック
	jnz	I_PlayKey_Step7			;
;音長指定無しの場合
	mov	ax,ds:[di].WTD_LengDefault	;
	jmp	I_PlayKey_Step8			;
;音長指定有りの場合
I_PlayKey_Step7:				;
	xor	ax,ax				;
	mov	al,es:[si]			;ax←音長
	inc	si				;
	cmp	al,0ffh				;if (ax = 255)
	jnz	I_PlayKey_Step8			;then{
	mov	ax,es:[si]			;	ax = es:[si];
	inc	si				;	si = si + 2;
	inc	si				;};
I_PlayKey_Step8:				;
	mov	ds:[di].WTD_Leng,ax		;
	mov	ds:[di].WTD_LengCounter,ax	;

I_PlayKey_StepE:			;
	pop	dx			;
	pop	cx			;
	pop	bx			;
	pop	ax			;
	ret				;レジスタ復帰
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				補助コマンド(00h～7Fh)		*
;*								*
;****************************************************************
;===============================================================|
;			ジャンプテーブル			|
;===============================================================|
;コマンド処理のあるアドレス
	even				;偶数アドレス配置
I_PlayCommand_JumpTable:
	dw	offset I_Com00		;00 	
	dw	offset I_Com01		;01 	
	dw	offset I_Com02		;02 	
	dw	offset I_Com03		;03 	
	dw	offset I_Com04		;04 	
	dw	offset I_Com05		;05 	
	dw	offset I_Com06		;06 	
	dw	offset I_Com07		;07 	
	dw	offset I_Com08		;08 	
	dw	offset I_Com09		;09 	
	dw	offset I_Com0a		;0a 	
	dw	offset I_Com0b		;0b 	
	dw	offset I_Com0c		;0c 	
	dw	offset I_Com0d		;0d 	
	dw	offset I_Com0e		;0e 	
	dw	offset I_Com0f		;0f 	
	dw	offset I_Com10		;10 	
	dw	offset I_Com11		;11 	
	dw	offset I_Com12		;12 	
	dw	offset I_Com13		;13 	
	dw	offset I_Com14		;14 	
	dw	offset I_Com15		;15 	
	dw	offset I_Com16		;16 	
	dw	offset I_Com17		;17 	
	dw	offset I_Com18		;18 	
	dw	offset I_Com19		;19 	
	dw	offset I_Com1a		;1a 	
	dw	offset I_Com1b		;1b 	
	dw	offset I_Com1c		;1c 	
	dw	offset I_Com1d		;1d 	
	dw	offset I_Com1e		;1e 	
	dw	offset I_Com1f		;1f 	
	dw	offset I_Com20		;20  	
	dw	offset I_Com21		;21 !	Work Switch
	dw	offset I_Com22		;22 "	Work Base Address
	dw	offset I_Com23		;23 #		(MML:Sharp)
	dw	offset I_Com24		;24 $		(MML:Macro)
	dw	offset I_Com25		;25 %		(MML:Step)
	dw	offset I_Com26		;26 &		(MML:Tai)
	dw	offset I_Com27		;27 '	Acsent
	dw	offset I_Com28		;28 (	Volume down
	dw	offset I_Com29		;29 )	Volume up
	dw	offset I_Com2a		;2a *	LFO Switch
	dw	offset I_Com2b		;2b +		(MML:Sharp)
	dw	offset I_Com2c		;2c ,		(MML:Channel)
	dw	offset I_Com2d		;2d -		(MML:Flat)
	dw	offset I_Com2e		;2e .		(MML:Leng*1.5)
	dw	offset I_Com2f		;2f /	Emb. Switch
	dw	offset I_Com30		;30 0	Work mov
	dw	offset I_Com31		;31 1	Work add
	dw	offset I_Com32		;32 2	Work sub
	dw	offset I_Com33		;33 3	Work and
	dw	offset I_Com34		;34 4	Work or
	dw	offset I_Com35		;35 5	Work xor
	dw	offset I_Com36		;36 6	Work set
	dw	offset I_Com37		;37 7	Work res
	dw	offset I_Com38		;38 8	Work cmp
	dw	offset I_Com39		;39 9	Work test
	dw	offset I_Com3a		;3a :	Loop Jump
	dw	offset I_Com3b		;3b ;	Loop Jump Flag
	dw	offset I_Com3c		;3c <	Octave down
	dw	offset I_Com3d		;3d =		(MML:Natural)
	dw	offset I_Com3e		;3e >	Octave up
	dw	offset I_Com3f		;3f ?	
	dw	offset I_Com40		;40 @	Voice
	dw	offset I_Com41		;41 A	
	dw	offset I_Com42		;42 B	Bend , Bend Range(MIDI PRN)
	dw	offset I_Com43		;43 C	Track / Channel , Sound Type
	dw	offset I_Com44		;44 D	Drection Detune
	dw	offset I_Com45		;45 E	Emb.
	dw	offset I_Com46		;46 F	Volume(MIDI ctrl:00x7)
	dw	offset I_Com47		;47 G	Channel Pressior(MIDI:0xD0)
	dw	offset I_Com48		;48 H	Bank(MIDI ctrl:0x00)
	dw	offset I_Com49		;49 I	
	dw	offset I_Com4a		;4a J	
	dw	offset I_Com4b		;4b K	Key On Delay
	dw	offset I_Com4c		;4c L	Loop
	dw	offset I_Com4d		;4d M	Mod(MIDI Ctrl:0x01)
	dw	offset I_Com4e		;4e N	NPRN(MIDI Ctrl:0x62)
	dw	offset I_Com4f		;4f O	
	dw	offset I_Com50		;50 P	Mode Sw(WS) / Damper(MIDI)
	dw	offset I_Com51		;51 Q	Gate time
	dw	offset I_Com52		;52 R	
	dw	offset I_Com53		;53 S	
	dw	offset I_Com54		;54 T	Filter(MIDI ctrl:)
	dw	offset I_Com55		;55 U	Gate time
	dw	offset I_Com56		;56 V	Expression Detune
	dw	offset I_Com57		;57 W	
	dw	offset I_Com58		;58 X	Excluesiv Send(MIDI:0xF0)
	dw	offset I_Com59		;59 Y	
	dw	offset I_Com5a		;5a Z	Send Data(MIDI)
	dw	offset I_Com5b		;5b [	Loop
	dw	offset I_Com5c		;5c \	
	dw	offset I_Com5d		;5d ]	Loop End
	dw	offset I_Com5e		;5e ^	Lengs add
	dw	offset I_Com5f		;5f _	Key Trance
	dw	offset I_Com60		;60 `	
	dw	offset I_Com61		;61 a	(MML:La)
	dw	offset I_Com62		;62 b	(MML:Si)
	dw	offset I_Com63		;63 c	(MML:Do)
	dw	offset I_Com64		;64 d	(MML:Re)
	dw	offset I_Com65		;65 e	(MML:Mi)
	dw	offset I_Com66		;66 f	(MML:Fa)
	dw	offset I_Com67		;67 g	(MML:So)
	dw	offset I_Com68		;68 h	
	dw	offset I_Com69		;69 i	
	dw	offset I_Com6a		;6a j	
	dw	offset I_Com6b		;6b k	velocity(MIDI)
	dw	offset I_Com6c		;6c l	lengs
	dw	offset I_Com6d		;6d m	LFO
	dw	offset I_Com6e		;6e n	Noise mode
	dw	offset I_Com6f		;6f o	Octave
	dw	offset I_Com70		;70 p	Pan.
	dw	offset I_Com71		;71 q	Gate time
	dw	offset I_Com72		;72 r	hol.
	dw	offset I_Com73		;73 s	Sweep
	dw	offset I_Com74		;74 t	tempo(HBLANK)
	dw	offset I_Com75		;75 u	Gate time
	dw	offset I_Com76		;76 v	Volume (WS/MIDI)
	dw	offset I_Com77		;77 w	
	dw	offset I_Com78		;78 x		(MML:Hex)
	dw	offset I_Com79		;79 y	
	dw	offset I_Com7a		;7a z	
	dw	offset I_Com7b		;7b {	Auto trance
	dw	offset I_Com7c		;7c |	
	dw	offset I_Com7d		;7d }	
	dw	offset I_Com7e		;7e ~	
	dw	offset I_Com7f		;7f 	
;===============================================================|
;		コマンドによる分岐				|
;			いわゆる、Ｃ言語でいう'switch'文と同等	|
;===============================================================|
;	●レジスタ使用						|
;		ax						|
;		bx						|
;		cx	汎用(主にカウンタ)			|
;		dx	汎用(主に計算)				|
;		ds:di	個別構造体		引数		|
;		ds:bp	ワークベースアドレス	引数		|
;		es	演奏セグメントアドレス	引数		|
;		si	演奏オフセットアドレス			|
;===============================================================|
	even				;偶数アドレス配置
I_PlayCommand:				;
	push	dx			;レジスタ保存

	push	bx			;
	mov	bx,ax			
	and	bx,007fh		;
	shl	bx,1			;
	mov	dx,word ptr cs:[I_PlayCommand_JumpTable + bx]
	pop	bx			;
	
	call	dx			;サブルーチンの呼び出し
	
	pop	dx			;レジスタ復帰
	and	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkSwR
	ret				;ワーク・スイッチのリセット
;===============================================================|
;		NULL						|
;===============================================================|
	even				;偶数アドレス配置
I_Com00:				;
I_Com01:				;
I_Com02:				;
I_Com03:				;
I_Com04:				;
I_Com05:				;
I_Com06:				;
I_Com07:				;
I_Com08:				;
I_Com09:				;
I_Com0a:				;
I_Com0b:				;
I_Com0c:				;
I_Com0d:				;
I_Com0e:				;
I_Com0f:				;
I_Com10:				;
I_Com11:				;
I_Com12:				;
I_Com13:				;
I_Com14:				;
I_Com15:				;
I_Com16:				;
I_Com17:				;
I_Com18:				;
I_Com19:				;
I_Com1a:				;
I_Com1b:				;
I_Com1c:				;
I_Com1d:				;
I_Com1e:				;
I_Com1f:				;
I_Com20:				;
	ret				;
;===============================================================|
;		Work Switch					|
;===============================================================|
	even				;偶数アドレス配置
I_Com21:				;
	or	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkSw
	ret				;
;===============================================================|
;		Work Base Address Set				|
;===============================================================|
	even				;偶数アドレス配置
I_Com22:				;
	call	I_Read8			;
	mov	ds:[di].WTD_WorkAddress,al
	ret				;
;===============================================================|
;		MML:Sharp					|
;===============================================================|
	even				;偶数アドレス配置
I_Com23:				;
	ret				;
;===============================================================|
;		MML:Macro					|
;===============================================================|
	even				;偶数アドレス配置
I_Com24:				;
	ret				;
;===============================================================|
;		MML:Step					|
;===============================================================|
	even				;偶数アドレス配置
I_Com25:				;
	ret				;
;===============================================================|
;		MML:Tai						|
;===============================================================|
	even				;偶数アドレス配置
I_Com26:				;
	ret				;
;===============================================================|
;		Acsent						|
;===============================================================|
	even				;偶数アドレス配置
I_Com27:				;
	call	I_Read8			;
	mov	ds:[di].WTD_AcsentVelocity,al
	or	ds:[di].WTD_FlagControl,WTD_Ctrl_Acsent
	ret				;
;===============================================================|
;		Volume down					|
;===============================================================|
	even				;偶数アドレス配置
I_Com28:				;
	mov	al,ds:[di].WTD_VolumeUpDown
	sub	ds:[di].WTD_Expr,al	;
	jnc	I_Com28_End		;
	mov	ds:[di].WTD_Expr,0	;
I_Com28_End:				;
	ret				;
;===============================================================|
;		Volume up					|
;===============================================================|
	even				;偶数アドレス配置
I_Com29:				;
	mov	al,ds:[di].WTD_VolumeUpDown
	add	ds:[di].WTD_Expr,al	;
	jnc	I_Com29_End		;
	mov	ds:[di].WTD_Expr,127	;
I_Com29_End:				;
	ret				;
;===============================================================|
;		LFO Switch					|
;===============================================================|
	even				;偶数アドレス配置
I_Com2a:				;
	push	bx			;
	push	cx			;

	mov	cl,es:[si]		;cl = 0,1,2
	inc	si			;
	shl	cl,1			;cl = 0,2,4 (bit)
	xor	ax,ax			;
	call	I_Read8			;
	and	ax,00001h		;Bit Mask
	mov	bx,0FFFEh		;Bit Mask
	test	cl,cl			;
	jz	I_Com2a_Step1		;
	shl	ax,cl			;al = 1,4,16
	rol	bx,cl			;
I_Com2a_Step1:				;
	and	ax,015h			;Bit Mask
	mov	cx,ds:[di].WTD_FlagControl
	and	cx,bx			;
	or	ax,cx			;
	mov	ds:[di].WTD_FlagControl,ax

	pop	cx			;
	pop	bx			;
	ret				;
;===============================================================|
;		MML:Sharp					|
;===============================================================|
	even				;偶数アドレス配置
I_Com2b:				;
	ret				;
;===============================================================|
;		MML:Channel					|
;===============================================================|
	even				;偶数アドレス配置
I_Com2c:				;
	ret				;
;===============================================================|
;		MML:Flat					|
;===============================================================|
	even				;偶数アドレス配置
I_Com2d:				;
	ret				;
;===============================================================|
;		MML:Lengs×1.5					|
;===============================================================|
	even				;偶数アドレス配置
I_Com2e:				;
	ret				;
;===============================================================|
;		Emb. Switch					|
;===============================================================|
	even				;偶数アドレス配置
I_Com2f:				;
	push	bx			;
	push	cx			;

	mov	cl,es:[si]		;cl = 0,1,2
	inc	si			;
	shl	cl,1			;cl = 0,2,4 (bit)
	inc	cl			;cl = 1,3,5 (bit)
	xor	ax,ax			;
	call	I_Read8			;
	and	ax,00001h		;Bit Mask
	mov	bx,0FFFEh		;Bit Mask
	test	cl,cl			;
	jz	I_Com2f_Step1		;
	shl	ax,cl			;al = 2,8,32
	shl	bx,cl			;
I_Com2f_Step1:				;
	and	ax,02Ah			;Bit Mask
	mov	cx,ds:[di].WTD_FlagControl
	and	cx,bx			;
	or	ax,cx			;
	mov	ds:[di].WTD_FlagControl,ax

	pop	cx			;
	pop	bx			;
	ret				;
;===============================================================|
;		Work	フラグ変化				|
;===============================================================|
	even				;偶数アドレス配置
I_Com3x_Flag:

;キャリーフラグ
	pushf				;レジスタ保存
	jnc	I_Com3x_Flag_CyL	;
I_Com3x_Flag_CyH:			;Cy="H"
	or	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkCy
	jmp	I_Com3x_Flag_Step0	;
I_Com3x_Flag_CyL:			;Cy="L"
	and	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkCyR
;	jmp	I_Com3x_Flag_Step0	;
I_Com3x_Flag_Step0:			;
	popf				;レジスタ復帰

;ゼローフラグ
	pushf				;レジスタ保存
	jnc	I_Com3x_Flag_ZeL	;
I_Com3x_Flag_ZeH:			;Ze="H"
	or	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkZe
	jmp	I_Com3x_Flag_Step1	;
I_Com3x_Flag_ZeL:			;Ze="L"
	and	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkZeR
;	jmp	I_Com3x_Flag_Step1	;
I_Com3x_Flag_Step1:			;
	popf				;レジスタ復帰

	ret
;===============================================================|
;		Work	mov	LD				|
;===============================================================|
	even				;偶数アドレス配置
I_Com30:				;
	push	bx			;
;アドレスの取得
	mov	ah,ds:[di].WTD_WorkAddress
	call	I_Read8			;
	mov	bx,ax			;bx←アドレス
	call	I_Read8			;al←数値

	mov	ds:[bx],al		;代入

	pop	bx			;
	ret				;
;===============================================================|
;		Work	add	ADD				|
;===============================================================|
	even				;偶数アドレス配置
I_Com31:				;
	push	bx			;
;アドレスの取得
	mov	ah,ds:[di].WTD_WorkAddress
	call	I_Read8			;
	mov	bx,ax			;bx←アドレス
	call	I_Read8			;al←数値

	add	ds:[bx],al		;加算
	call	I_Com3x_Flag		;フラグ変化

	pop	bx			;
	ret				;
;===============================================================|
;		Work	sub	SUB				|
;===============================================================|
	even				;偶数アドレス配置
I_Com32:				;
	push	bx			;
;アドレスの取得
	mov	ah,ds:[di].WTD_WorkAddress
	call	I_Read8			;
	mov	bx,ax			;bx←アドレス
	call	I_Read8			;al←数値

	sub	ds:[bx],al		;加算
	call	I_Com3x_Flag		;フラグ変化

	pop	bx			;
	ret				;
;===============================================================|
;		Work	and	AND				|
;===============================================================|
	even				;偶数アドレス配置
I_Com33:				;
	push	bx			;
;アドレスの取得
	mov	ah,ds:[di].WTD_WorkAddress
	call	I_Read8			;
	mov	bx,ax			;bx←アドレス
	call	I_Read8			;al←数値

	and	ds:[bx],al		;加算
	call	I_Com3x_Flag		;フラグ変化

	pop	bx			;
	ret				;
;===============================================================|
;		Work	or	OR				|
;===============================================================|
	even				;偶数アドレス配置
I_Com34:				;
	push	bx			;
;アドレスの取得
	mov	ah,ds:[di].WTD_WorkAddress
	call	I_Read8			;
	mov	bx,ax			;bx←アドレス
	call	I_Read8			;al←数値

	or	ds:[bx],al		;加算
	call	I_Com3x_Flag		;フラグ変化

	pop	bx			;
	ret				;
;===============================================================|
;		Work	xor	XOR				|
;===============================================================|
	even				;偶数アドレス配置
I_Com35:				;
	push	bx			;
;アドレスの取得
	mov	ah,ds:[di].WTD_WorkAddress
	call	I_Read8			;
	mov	bx,ax			;bx←アドレス
	call	I_Read8			;al←数値

	xor	ds:[bx],al		;加算
	call	I_Com3x_Flag		;フラグ変化

	pop	bx			;
	ret				;
;===============================================================|
;		Work		SET				|
;===============================================================|
	even				;偶数アドレス配置
I_Com36:				;
	push	bx			;
	push	cx
;アドレスの取得
	mov	ah,ds:[di].WTD_WorkAddress
	call	I_Read8			;
	mov	bx,ax			;bx←アドレス
	call	I_Read8			;al←数値

	mov	cl,al			;
	mov	al,001h			;
	shl	al,cl			;
	or	ds:[bx],al		;ビットセット
	call	I_Com3x_Flag		;フラグ変化

	pop	cx			;
	pop	bx			;
	ret				;
;===============================================================|
;		Work		RES				|
;===============================================================|
	even				;偶数アドレス配置
I_Com37:				;
	push	bx			;
;アドレスの取得
	mov	ah,ds:[di].WTD_WorkAddress
	call	I_Read8			;
	mov	bx,ax			;bx←アドレス
	call	I_Read8			;al←数値

	mov	cl,al			;
	mov	al,0FEh			;
	shl	al,cl			;
	and	ds:[bx],al		;ビットリセット
	call	I_Com3x_Flag		;フラグ変化

	pop	bx			;
	ret				;
;===============================================================|
;		Work	cmp	CP				|
;===============================================================|
	even				;偶数アドレス配置
I_Com38:				;
	push	bx			;
;アドレスの取得
	mov	ah,ds:[di].WTD_WorkAddress
	call	I_Read8			;
	mov	bx,ax			;bx←アドレス
	call	I_Read8			;al←数値

	cmp	ds:[bx],al		;加算
	call	I_Com3x_Flag		;フラグ変化

	pop	bx			;
	ret				;
;===============================================================|
;		work	test					|
;===============================================================|
	even				;偶数アドレス配置
I_Com39:				;
	push	bx			;
;アドレスの取得
	mov	ah,ds:[di].WTD_WorkAddress
	call	I_Read8			;
	mov	bx,ax			;bx←アドレス
	call	I_Read8			;al←数値

	test	ds:[bx],al		;加算
	call	I_Com3x_Flag		;フラグ変化

	pop	bx			;
	ret				;
;===============================================================|
;		Loop Jump					|
;===============================================================|
	even				;偶数アドレス配置
I_Com3a:				;
;読み込み
	mov	dx,es:[si]		;
	inc	si			;
	inc	si			;

;カウンタ・読み込み
	push	bx			;
	xor	bx,bx			;
	mov	bl,ds:[di].WTD_LoopCountPointer
	mov	al,ds:[di + bx].WTD_LoopCount
	pop	bx			;

;カウンタ・ディクリメント
	cmp	al,1			;
	jz	I_Com3d_Step		;

	ret				;終了
;---------------------------------------------------------------
	even				;偶数アドレス配置
I_Com3d_Step:				;カウンター = 1 の場合。
	dec	ds:[di].WTD_LoopCountPointer
	mov	si,dx			;

	ret				;
;===============================================================|
;		Loop Jump Flags					|
;===============================================================|
	even				;偶数アドレス配置
I_Com3b:				;
	mov	ax,ds:[di].WTD_FlagControl
	and	ax,WTD_Ctrl_WorkCy + WTD_Ctrl_WorkZe
	shr	ax,4			;ah←WTD内部のフラグ
	call	I_Read8			;al←曲データ中のフラグ
	mov	dx,es:[si]		;
	inc	si			;
	inc	si			;dx←ループ先
	cmp	al,ah			;比較
	jnz	I_Com3b_End		;

	dec	ds:[di].WTD_LoopCountPointer
	mov	si,dx			;ループ抜け

I_Com3b_End:				;
	ret				;
;===============================================================|
;		Octave down					|
;===============================================================|
	even				;偶数アドレス配置
I_Com3c:				;
	dec	ds:[di].WTD_Octave	;
	ret				;
;===============================================================|
;		MML:Natural					|
;===============================================================|
	even				;偶数アドレス配置
I_Com3d:				;
	ret				;
;===============================================================|
;		Octave up					|
;===============================================================|
	even				;偶数アドレス配置
I_Com3e:				;
	inc	ds:[di].WTD_Octave	;
	ret				;
;===============================================================|
;		NULL '?'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com3f:				;
	ret				;
;===============================================================|
;		Voice / Program					|
;===============================================================|
	even				;偶数アドレス配置
I_Com40:				;
	call	I_Read8			;音色拡張子はあるか？
	rol	al,1			;
	shr	al,1			;Bit 7 Reset & Bit 7 -> Cy Flag
	jnc	I_Com40_1st		;

	mov	ah,al			;
	call	I_Read8			;
	cmp	ah,00h			;@F = Switch 80h
	jz	I_Com40_1st		;
	cmp	ah,01h			;@S = Switch 81h
	jz	I_Com40_2nd		;
	cmp	ah,02h			;@R = Switch 82h
	jz	I_Com40_3rd		;
	jmp	I_Com40_End		;

I_Com40_1st:				;
	mov	ds:[di].WTD_Program1st,al
	mov	dx,offset I_Table_Voice	;
	jmp	I_Table_Jump		;call with return
I_Com40_2nd:				;
	mov	ds:[di].WTD_Program2nd,al
	call	I_Read16		;
	mov	ds:[di].WTD_ProgramRate,ax
	jmp	I_Com40_End		;
I_Com40_3rd:				;
	mov	ds:[di].WTD_Program3rd,al
I_Com40_End:				;
	ret				;
;===============================================================|
;		NULL 'A'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com41:				;
	ret				;
;===============================================================|
;		Bend & Bend Range(MIDI)				|
;===============================================================|
	even				;偶数アドレス配置
I_Com42:				;
	call	I_Read16		;
	rol	ax,1			;
	shr	ax,1			;Bit 7 Reset & Bit 7 -> Cy Flag
	mov	ds:[di].WTD_Bend,ax	;
	jnc	I_Com42_End		;

ifndef	hyoka	;------------------------廉価版は無し
	mov	al,00h			;
	mov	cl,MIDI_Ctrl_RegLSB	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;

	mov	al,00h			;
	mov	cl,MIDI_Ctrl_RegMSB	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

	call	I_Read8			;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_DataEntly	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

I_Com42_End:				;
	ret				;
;===============================================================|
;		Track / Sound Type				|
;===============================================================|
	even				;偶数アドレス配置
I_Com43:				;
	call	I_Read8			;
	mov	ds:[di].WTD_Channel,al	;
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jz	I_Com43_End		;効果音か？
	and	al,07h			;
	mov	cl,al			;
	inc	cl			;
	mov	ax,0800h		;
	shl	ax,cl			;
	or	ds:[bx].WTD_Sys_Flag,ax	;
I_Com43_End:				;
	ret				;
;===============================================================|
;		Frection Detune					|
;===============================================================|
	even				;偶数アドレス配置
I_Com44:				;
	call	I_Read16		;
	mov	ds:[di].WTD_BendDetune,ax
	ret				;
;===============================================================|
;		Emblop						|
;===============================================================|
	even				;偶数アドレス配置
I_Com45:				;
	push	bx			;

	mov	al,es:[si]		;ax←タイプ
	inc	si			;
	push	ax			;保存
	xor	ax,ax			;
	call	I_Read8			;ax←エンベロープ番号
	and	ax,001fh		;
	shl	ax,4			;ax←ax×16
	pop	bx			;復帰
	mov	bh,ah			;
	cmp	bl,1			;
	jz	I_Com45_Expr		;
	cmp	bl,2			;
	jz	I_Com45_Pan		;

I_Com45_Bend:					;音程 bl=0
	and	ds:[di].WTD_BendEmbAddress,00fh	;
	or	ds:[di].WTD_BendEmbAddress,al	;
	mov	ax,ds:[di].WTD_FlagControl	;
	shr	bx,1				;bx bit 7  =  No. bit 5
	and	bx,WTD_Ctrl_EmbFreq		;
	and	ax,WTD_Ctrl_EmbFreqR		;
	or	ax,bx				;
	mov	ds:[di].WTD_FlagControl,ax
	jmp	I_Com45_End			;

I_Com45_Expr:					;音量 bl=1
	and	ds:[di].WTD_ExprEmbAddress,00fh	;
	or	ds:[di].WTD_ExprEmbAddress,al	;
	mov	ax,ds:[di].WTD_FlagControl	;bx bit 8  =  No. bit 5
	and	bx,WTD_Ctrl_EmbVol		;
	and	ax,WTD_Ctrl_EmbVolR		;
	or	ax,bx				;
	mov	ds:[di].WTD_FlagControl,ax
	jmp	I_Com45_End			;

I_Com45_Pan:					;音程 bl=2
	and	ds:[di].WTD_PanEmbAddress,00fh	;
	or	ds:[di].WTD_PanEmbAddress,al	;
	mov	ax,ds:[di].WTD_FlagControl	;
	shl	bx,1				;bx bit 9  =  No. bit 5
	and	bx,WTD_Ctrl_EmbPan		;
	and	ax,WTD_Ctrl_EmbPanR		;
	or	ax,bx				;
	mov	ds:[di].WTD_FlagControl,ax
;	jmp	I_Com45_End			;

I_Com45_End:				;
	pop	bx			;
	ret				;
;===============================================================|
;		Volume(MIDI ctrl:0x07)				|
;===============================================================|
	even				;偶数アドレス配置
I_Com46:				;
	call	I_Read8			;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_Volume	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

	ret				;
;===============================================================|
;		Channel Pressior(MIDI)				|
;===============================================================|
	even				;偶数アドレス配置
I_Com47:				;
	call	I_Read8			;
	mov	dx,offset I_Table_PolyChPress
	call	I_Table_Jump		;
	ret				;
;===============================================================|
;		Program Bank Select(MIDI)			|
;===============================================================|
	even				;偶数アドレス配置
I_Com48:				;
	call	I_Read16		;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_Bank	;
	mov	dx,offset I_Table_CtrlChgW
	call	I_Table_Jump		;
endif	;--------------------------------

	ret				;
;===============================================================|
;		NULL 'I'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com49:				;
	ret				;
;===============================================================|
;		NULL 'J'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com4a:				;
	ret				;
;===============================================================|
;		Key on  Delay					|
;===============================================================|
	even				;偶数アドレス配置
I_Com4b:				;
	call	I_Read16		;
	mov	ds:[di].WTD_KeyOnDelay,ax
	ret				;
;===============================================================|
;		Loop	'L'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com4c:				;
	mov	ax,es:[si]		;
	inc	si			;
	inc	si			;
	or	ax,ax			;演奏終了か？
	jz	I_Com4c_Step1		;
	mov	si,ax			;ループ
	ret				;

I_Com4c_Step1:				;
	or	ds:[di].WTD_FlagControl,WTD_Ctrl_PlayEnd
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jz	I_Com4c_Step2		;効果音か？
	mov	ch,ds:[di].WTD_Channel	;ch←チャンネル番号
	cmp	ch,80h			;
	jc	I_Com4c_Step2		;ＷＳ音源？
	call	I_Effect_Return		;効果音からの復帰
I_Com4c_Step2:				;
	ret				;
;===============================================================|
;		Modration(MIDI ctrl:0x??)			|
;===============================================================|
	even				;偶数アドレス配置
I_Com4d:				;
	call	I_Read16		;
	mov	ds:[di].WTD_ModDecay,ax	;
	call	I_Read8			;
	mov	ds:[di].WTD_ModLevel,al	;

;ifndef	hyoka	;------------------------廉価版は無し
;	mov	cl,MIDI_Ctrl_Mod	;
;	mov	dx,offset I_Table_CtrlChgB
;	call	I_Table_Jump		;
;endif	;--------------------------------

	ret				;
;===============================================================|
;		NPRN(MIDI)					|
;===============================================================|
	even				;偶数アドレス配置
I_Com4e:				;
	call	I_Read8			;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_NonRegLSB	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

	call	I_Read8			;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_NonRegMSB	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

	call	I_Read8			;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_DataEntly	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

	ret				;
;===============================================================|
;		ソヌーテート					|
;===============================================================|
	even				;偶数アドレス配置
I_Com4f:				;
	call	I_Read8			;
	shl	al,6			;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_S		;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

	ret				;
;===============================================================|
;		PCM Mode / MIDI Damper				|
;===============================================================|
	even				;偶数アドレス配置
I_Com50:				;
	call	I_Read8			;
	mov	dx,offset I_Table_Mode	;
	call	I_Table_Jump		;設定
	ret				;終了
;===============================================================|
;		Gate time 'Q'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com51:				;
	call	I_Read8			;
	mov	ds:[di].WTD_GateTime8,al
	ret				;
;===============================================================|
;		Bress						|
;===============================================================|
	even				;偶数アドレス配置
I_Com52:				;
	call	I_Read8			;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_Bress	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

	ret				;
;===============================================================|
;		Soft						|
;===============================================================|
	even				;偶数アドレス配置
I_Com53:				;
	call	I_Read8			;
	shl	al,6			;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_Soft	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

	ret				;
;===============================================================|
;		Foot						|
;===============================================================|
	even				;偶数アドレス配置
I_Com54:				;
	call	I_Read8			;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_Foot	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

	ret				;
;===============================================================|
;		Gate Time(U)					|
;===============================================================|
	even				;偶数アドレス配置
I_Com55:				;
	call	I_Read8			;
	or	al,080h			;
	mov	ds:[di].WTD_GateTime8,al
	ret				;
;===============================================================|
;		Expression Detune				|
;===============================================================|
	even				;偶数アドレス配置
I_Com56:				;
	call	I_Read16		;
	mov	ds:[di].WTD_ExprDetune,ax
	ret				;
;===============================================================|
;		Balance						|
;===============================================================|
	even				;偶数アドレス配置
I_Com57:				;
	call	I_Read8			;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_Blance	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

	ret				;
;===============================================================|
;		Excluesiv Send(MIDI)				|
;===============================================================|
	even				;偶数アドレス配置
I_Com58:				;
	push	ds			;
	push	cx			;

I_Com58_Step1:				;
	mov	al,byte ptr es:[si]	;
	inc	si			;

ifndef	hyoka
	call	C_Send			;送信
endif

	cmp	al,0f7h			;0xF7だったら終わり。
	jnz	I_Com58_Step1		;

	pop	cx			;
	pop	ds			;
	ret				;
;===============================================================|
;		NULL 'Y'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com59:				;
	ret				;
;===============================================================|
;		MIDI Send Data(MIDI)				|
;===============================================================|
	even				;偶数アドレス配置
I_Com5a:				;
	push	cx			;

	xor	cx,cx
	mov	cl,es:[si]		;
	inc	si			;

I_Com5a_Step1:				;
	mov	al,byte ptr es:[si]	;
	inc	si			;

ifndef	hyoka
	call	C_Send			;送信
endif

	loop	I_Com5a_Step1		;

	pop	cx			;
	ret				;
;===============================================================|
;		Loop Start					|
;===============================================================|
	even				;偶数アドレス配置
I_Com5b:				;

;読み込み
	mov	al,es:[si]		;
	inc	si			;

;設定
	inc	ds:[di].WTD_LoopCountPointer

;カウンタ書き込み
	push	bx			;
	xor	bx,bx			;
	mov	bl,ds:[di].WTD_LoopCountPointer
	mov	ds:[di + bx].WTD_LoopCount,al
	pop	bx			;

;終了
	ret				;
;===============================================================|
;		NULL '\'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com5c:				;
	ret				;
;===============================================================|
;		Loop End					|
;===============================================================|
	even				;偶数アドレス配置
I_Com5d:				;

;読み込み
	mov	dx,es:[si]		;
	inc	si			;
	inc	si			;

;カウンタ・ディクリメント
	push	bx			;
	xor	bx,bx			;
	mov	bl,ds:[di].WTD_LoopCountPointer
	sub	ds:[di + bx].WTD_LoopCount,1
	pop	bx			;
	jnz	I_Com5d_Step		;

	dec	ds:[di].WTD_LoopCountPointer

	ret				;終了
;---------------------------------------------------------------
	even				;偶数アドレス配置
I_Com5d_Step:				;カウンター <> 0 の場合。
	mov	si,dx			;

	ret				;
;===============================================================|
;		Tai (add lengs)					|
;===============================================================|
	even				;偶数アドレス配置
I_Com5e:				;
	ret				;
;===============================================================|
;		Key Trance					|
;===============================================================|
	even				;偶数アドレス配置
I_Com5f:				;
	call	I_Read8			;
	mov	ds:[di].WTD_KeyShift,al	;
	ret				;
;===============================================================|
;		NULL '`'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com60:				;
	ret				;
;===============================================================|
;		MML:a						|
;===============================================================|
	even				;偶数アドレス配置
I_Com61:				;
	ret				;
;===============================================================|
;		MML:b						|
;===============================================================|
	even				;偶数アドレス配置
I_Com62:				;
	ret				;
;===============================================================|
;		MML:c						|
;===============================================================|
	even				;偶数アドレス配置
I_Com63:				;
	ret				;
;===============================================================|
;		MML:d						|
;===============================================================|
	even				;偶数アドレス配置
I_Com64:				;
	ret				;
;===============================================================|
;		MML:e						|
;===============================================================|
	even				;偶数アドレス配置
I_Com65:				;
	ret				;
;===============================================================|
;		MML:f						|
;===============================================================|
	even				;偶数アドレス配置
I_Com66:				;
	ret				;
;===============================================================|
;		MML:g						|
;===============================================================|
	even				;偶数アドレス配置
I_Com67:				;
	ret				;
;===============================================================|
;		NULL 'h'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com68:				;
	ret				;
;===============================================================|
;		NULL 'i'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com69:				;
	ret				;
;===============================================================|
;		NULL 'j'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com6a:				;
	ret				;
;===============================================================|
;		Velocity(MIDI)					|
;===============================================================|
	even				;偶数アドレス配置
I_Com6b:				;
	call	I_Read8			;
	mov	ds:[di].WTD_Velocity,al	;
	ret				;
;===============================================================|
;		lengs						|
;===============================================================|
	even				;偶数アドレス配置
I_Com6c:				;
	xor	ax,ax			;
	mov	al,es:[si]		;
	inc	si			;
	cmp	al,0ffh			;
	jnz	I_Com6c_Step1		;

	mov	ax,es:[si]		;
	inc	si			;
	inc	si			;
I_Com6c_Step1:				;
	mov	ds:[di].WTD_LengDefault,ax
	ret				;
;===============================================================|
;		LFO						|
;===============================================================|
	even				;偶数アドレス配置
I_Com6d:				;
	push	bp			;

	mov	al,es:[si]		;
	inc	si			;
	mov	bp,WTD_BendLFO		;
	cmp	al,0			;
	jz	I_Com6d_Step		;
	mov	bp,WTD_ExprLFO		;
	cmp	al,1			;
	jz	I_Com6d_Step		;
	mov	bp,WTD_PanLFO		;
	cmp	al,2			;
	jz	I_Com6d_Step		;
I_Com6d_Step:				;

	call	I_Read8			;DR
	mov	ds:[di+bp].WTD_ChLfo_DecayRate,al

	call	I_Read8			;SR
	mov	ds:[di+bp].WTD_ChLfo_SpeedRate,al

	call	I_Read16		;Lv
	mov	ds:[di+bp].WTD_ChLfo_Level,ax

	call	I_Read8			;Cnt
	mov	ds:[di+bp].WTD_ChLfo_Count,al

	pop	bp			;
	ret				;
;===============================================================|
;		Noise mode					|
;===============================================================|
	even				;偶数アドレス配置
I_Com6e:				;
	call	I_Read8			;
	mov	ds:[di].WTD_NoiseMode,al

	or	al,18h			;
	mov	ah,1fh			;
	call	SP_Set_Noise		;

	ret				;
;===============================================================|
;		Octave						|
;===============================================================|
	even				;偶数アドレス配置
I_Com6f:				;
	call	I_Read8			;
	mov	ds:[di].WTD_Octave,al	;
	ret				;
;===============================================================|
;		Panpot						|
;===============================================================|
	even				;偶数アドレス配置
I_Com70:				;
	push	cx			;

	call	I_Read8			;
	mov	ds:[di].WTD_Pan,al	;

	pop	cx			;
	ret				;
;===============================================================|
;		Gate time 'q'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com71:				;
	call	I_Read16		;
	mov	ds:[di].WTD_GateTimeStepLast,ax
	ret				;
;===============================================================|
;		mml:r						|
;===============================================================|
	even				;偶数アドレス配置
I_Com72:				;
	ret				;
;===============================================================|
;		Sweep 						|
;===============================================================|
	even				;偶数アドレス配置
I_Com73:				;
	call	I_Read8			;
	mov	ah,al			;
	call	I_Read8			;
	xchg	al,ah			;

	cmp	ds:[di].WTD_Channel,82h	;PCM Ch2であるか？
	jnz	I_Com73_End		;

	mov	ds:[di].WTD_SweepLevel,al
	mov	ds:[di].WTD_SweepTime,ah
	call	SP_Set_Sweep		;Sweep Modeの設定

I_Com73_End:				;
	ret				;
;===============================================================|
;		tempo						|
;===============================================================|
	even				;偶数アドレス配置
I_Com74:				;
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	I_Com74_E		;効果音の場合、処理無し。

	call	I_Read16		;
	mov	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Tempo,ax
	call	T_Set_Frection		;タイマーセット

I_Com74_E:				;
	ret				;
;===============================================================|
;		Gate time 'u'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com75:				;
	call	I_Read16		;
	mov	ds:[di].WTD_GateTimeStepFirst,ax
	ret				;
;===============================================================|
;		Volume						|
;===============================================================|
	even				;偶数アドレス配置
I_Com76:				;
	call	I_Read8			;
	mov	ds:[di].WTD_Expr,al	;
	ret				;
;===============================================================|
;		NULL 'w'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com77:				;
	ret				;
;===============================================================|
;		x						|
;===============================================================|
	even				;偶数アドレス配置
I_Com78:				;
	call	I_Read8			;
	mov	ds:[di].WTD_VolumeUpDown,al
	ret				;
;===============================================================|
;		Control Change(MIDI)				|
;===============================================================|
	even				;偶数アドレス配置
I_Com79:				;
	push	cx

	call	I_Read8			;
	mov	cl,al			;
	call	I_Read8			;

	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;

	pop	cx			;
	ret				;
;===============================================================|
;		NULL 'z'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com7a:				;
	ret				;
;===============================================================|
;		Key Trance (major / minor)			|
;===============================================================|
	even				;偶数アドレス配置
I_Com7b:				;
	mov	al,es:[si]		;
	inc	si			;
	cmp	al,0			;
	jz	I_Com7b_Step0		;
	rol	al,1			;
	shr	al,1			;Bit 7 Reset & Bit 7 -> Cy Flag
	jc	I_Com7b_Step2		;
	jmp	I_Com7b_Step1		;
I_Com7b_Step0:				;
	mov	ds:[di].WTD_FlagSharp,al
	mov	ds:[di].WTD_FlagFlat,al	;
	jmp	I_Com7b_End		;
I_Com7b_Step1:				;
	mov	ds:[di].WTD_FlagSharp,al
	jmp	I_Com7b_End		;
I_Com7b_Step2:				;
	mov	ds:[di].WTD_FlagFlat,al	;
;	jmp	I_Com7b_End		;
I_Com7b_End:				;
	ret				;
;===============================================================|
;		NULL '|'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com7c:				;
	ret				;
;===============================================================|
;		NULL '}'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com7d:				;
	ret				;
;===============================================================|
;		NULL '~'					|
;===============================================================|
	even				;偶数アドレス配置
I_Com7e:				;
	ret				;
;===============================================================|
;		NULL ?						|
;===============================================================|
	even				;偶数アドレス配置
I_Com7f:				;
	ret				;
