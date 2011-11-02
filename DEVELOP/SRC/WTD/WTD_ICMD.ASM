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
I_Read8	proc	near			;
	lodsb	es:[si]			;
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkSw
	jz	I_Read8_End		;ワークからであるか？

	push	bx			;	{ワーク読み込み}
	mov	bh,ds:[di].WTD_WorkAddress
	mov	bl,al			;bx←ワークオフセットアドレス
	mov	al,ds:[bx]		;
	pop	bx			;

I_Read8_End:				;
	ret				;終了
I_Read8	endp
;●16bit版=======================================================
I_Read16	proc	near		;
	lodsw	es:[si]
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkSw
	jz	I_Read16_End		;ワークからであるか？

	push	bx			;	{ワーク読み込み}
	mov	bh,ds:[di].WTD_WorkAddress
	mov	bl,al			;bx←ワークオフセットアドレス
	mov	ax,ds:[bx]		;
	pop	bx			;

I_Read16_End:				;
	ret				;終了
I_Read16	endp
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				音階コマンド(80h～FFh)		*
;*								*
;****************************************************************
;===============================================================|
;		オートの臨時記号処理(未解決？)			|
;===============================================================|
;	●引数							|
;		al	Note Number				|
;		cl	音程（0～7）				|
;		ds:[di]	パート個別構造体			|
;	●返値							|
;		al	Noto Number (自動臨時記号追加後)	|
;===============================================================|
	even					;偶数アドレス配置
I_PlayKey_Auto	proc	near	uses cx		;

	and	cl,07h				;cl←音程(0～7)

;＃処理
	mov	ch,ds:[di].WTD_FlagSharp	;
	shr	ch,cl				;
	.if	(carry?)			;チェック
		inc	al			;KeyCode ++
	.endif

;ｂ処理
	mov	ch,ds:[di].WTD_FlagFlat		;
	shr	ch,cl				;
	.if	(carry?)			;チェック
		dec	al			;KeyCode --
	.endif

	ret				;
I_PlayKey_Auto	endp
;===============================================================|
;		音符コマンドの処理				|
;===============================================================|
;	●引数							|
;		ds:bp	ワークベースアドレス	引数		|
;		ds:bx	共有構造体アドレス	引数		|
;		ds:di	個別構造体		引数		|
;		es:si	演奏アドレス		引数		|
;		al	音符コマンド（00h～7Fh）破壊ok		|
;	●レジスタ使用						|
;		cx	汎用			破壊ok		|
;		dx	汎用			破壊ok		|
;===============================================================|
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
I_PlayKey	proc	near	uses bx

	mov	cl,al				;cl←コマンド
	and	ax,07h				;al←音階情報(0～7)
	sub	ax,1				;

	;音符だった場合	（こっちの方が高頻度）
	.if	(!carry?)
		mov	bx,ax			;

		mov	al,12			;
		imul	byte ptr ds:[di].WTD_Octave	;パイプラインの為、これを先に。
		mov	ch,byte ptr cs:[bx + CGROUP:I_PlayKey_Code]
		add	al,ch			;al←Key Code

		;半音演算処理
		mov	ch,cl
		and	ch,018h			;臨時記号にマスク

		;臨時記号
		.if	(ch==08h)		;♭？
			inc	al
		.elseif	(ch==10h)		;＃？
			dec	al
		.endif

		;自動臨時記号
		.if	(ch!=18h)		;ナチュラル以外？
			call	I_PlayKey_Auto	;自動半音処理
		.endif

		add	al,12			;KeyCode補正(MIDI単位)
		mov	ds:[di].WTD_Key,al	;音程保存

		;ハードウェアをKeyOn
		add	al,ds:[di].WTD_KeyShift	
		mov	dx,offset CGROUP:I_Table_KeyOn
		call	I_Table_Jump		;KeyOn

	;休符だった場合
	.else
		mov	ds:[di].WTD_Key,al	;音程保存（休符:0FFh）

	.endif



	;タイフラグチェック
	test	cl,020h				;タイフラグチェック（cy←0）
	.if	!(zero?)
		stc				;cy←1
	.endif
	rcl	ds:[di].WTD_FlagTai,1		;シフト



	;音長フラグのチェック
	;音長指定無しの場合
	.if	!(cl&40h)
		mov	ax,ds:[di].WTD_LengDefault
	;音長指定有りの場合
	.else
		xor	ax,ax			;
		lodsb	es:[si]			;ax←音長
		.if	(al==0ffh)
			lodsw	es:[si]		;
		.endif
	.endif

	mov	ds:[di].WTD_Leng,ax		;
	mov	ds:[di].WTD_LengCounter,ax	;



I_PlayKey_StepE:			;
	ret				;レジスタ復帰
I_PlayKey	endp
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
	dw	offset CGROUP:I_Com00	;00 	
	dw	offset CGROUP:I_Com01	;01 	
	dw	offset CGROUP:I_Com02	;02 	
	dw	offset CGROUP:I_Com03	;03 	
	dw	offset CGROUP:I_Com04	;04 	
	dw	offset CGROUP:I_Com05	;05 	
	dw	offset CGROUP:I_Com06	;06 	
	dw	offset CGROUP:I_Com07	;07 	
	dw	offset CGROUP:I_Com08	;08 	
	dw	offset CGROUP:I_Com09	;09 	
	dw	offset CGROUP:I_Com0a	;0a 	
	dw	offset CGROUP:I_Com0b	;0b 	
	dw	offset CGROUP:I_Com0c	;0c 	
	dw	offset CGROUP:I_Com0d	;0d 	
	dw	offset CGROUP:I_Com0e	;0e 	
	dw	offset CGROUP:I_Com0f	;0f 	
	dw	offset CGROUP:I_Com10	;10 	
	dw	offset CGROUP:I_Com11	;11 	
	dw	offset CGROUP:I_Com12	;12 	
	dw	offset CGROUP:I_Com13	;13 	
	dw	offset CGROUP:I_Com14	;14 	
	dw	offset CGROUP:I_Com15	;15 	
	dw	offset CGROUP:I_Com16	;16 	
	dw	offset CGROUP:I_Com17	;17 	
	dw	offset CGROUP:I_Com18	;18 	
	dw	offset CGROUP:I_Com19	;19 	
	dw	offset CGROUP:I_Com1a	;1a 	
	dw	offset CGROUP:I_Com1b	;1b 	
	dw	offset CGROUP:I_Com1c	;1c 	
	dw	offset CGROUP:I_Com1d	;1d 	
	dw	offset CGROUP:I_Com1e	;1e 	
	dw	offset CGROUP:I_Com1f	;1f 	
	dw	offset CGROUP:I_Com20	;20  	
	dw	offset CGROUP:I_Com21	;21 !	Work Switch
	dw	offset CGROUP:I_Com22	;22 "	Work Base Address
	dw	offset CGROUP:I_Com23	;23 #		(MML:Sharp)
	dw	offset CGROUP:I_Com24	;24 $		(MML:Macro)
	dw	offset CGROUP:I_Com25	;25 %		(MML:Step)
	dw	offset CGROUP:I_Com26	;26 &		(MML:Tai)
	dw	offset CGROUP:I_Com27	;27 '	Acsent
	dw	offset CGROUP:I_Com28	;28 (	Volume down
	dw	offset CGROUP:I_Com29	;29 )	Volume up
	dw	offset CGROUP:I_Com2a	;2a *	LFO Switch
	dw	offset CGROUP:I_Com2b	;2b +		(MML:Sharp)
	dw	offset CGROUP:I_Com2c	;2c ,		(MML:Channel)
	dw	offset CGROUP:I_Com2d	;2d -		(MML:Flat)
	dw	offset CGROUP:I_Com2e	;2e .		(MML:Leng*1.5)
	dw	offset CGROUP:I_Com2f	;2f /	Emb. Switch
	dw	offset CGROUP:I_Com30	;30 0	Work mov
	dw	offset CGROUP:I_Com31	;31 1	Work add
	dw	offset CGROUP:I_Com32	;32 2	Work sub
	dw	offset CGROUP:I_Com33	;33 3	Work and
	dw	offset CGROUP:I_Com34	;34 4	Work or
	dw	offset CGROUP:I_Com35	;35 5	Work xor
	dw	offset CGROUP:I_Com36	;36 6	Work set
	dw	offset CGROUP:I_Com37	;37 7	Work res
	dw	offset CGROUP:I_Com38	;38 8	Work cmp
	dw	offset CGROUP:I_Com39	;39 9	Work test
	dw	offset CGROUP:I_Com3a	;3a :	Loop Jump
	dw	offset CGROUP:I_Com3b	;3b ;	Loop Jump Flag
	dw	offset CGROUP:I_Com3c	;3c <	Octave down
	dw	offset CGROUP:I_Com3d	;3d =		(MML:Natural)
	dw	offset CGROUP:I_Com3e	;3e >	Octave up
	dw	offset CGROUP:I_Com3f	;3f ?	
	dw	offset CGROUP:I_Com40	;40 @	Voice
	dw	offset CGROUP:I_Com41	;41 A	
	dw	offset CGROUP:I_Com42	;42 B	Bend , Bend Range(MIDI PRN)
	dw	offset CGROUP:I_Com43	;43 C	Track / Channel , Sound Type
	dw	offset CGROUP:I_Com44	;44 D	Drection Detune
	dw	offset CGROUP:I_Com45	;45 E	Emb.
	dw	offset CGROUP:I_Com46	;46 F	Volume(MIDI ctrl:00x7)
	dw	offset CGROUP:I_Com47	;47 G	Channel Pressior(MIDI:0xD0)
	dw	offset CGROUP:I_Com48	;48 H	Bank(MIDI ctrl:0x00)
	dw	offset CGROUP:I_Com49	;49 I	
	dw	offset CGROUP:I_Com4a	;4a J	
	dw	offset CGROUP:I_Com4b	;4b K	Key On Delay
	dw	offset CGROUP:I_Com4c	;4c L	Loop
	dw	offset CGROUP:I_Com4d	;4d M	Mod(MIDI Ctrl:0x01)
	dw	offset CGROUP:I_Com4e	;4e N	NPRN(MIDI Ctrl:0x62)
	dw	offset CGROUP:I_Com4f	;4f O	
	dw	offset CGROUP:I_Com50	;50 P	Mode Sw(WS) / Damper(MIDI)
	dw	offset CGROUP:I_Com51	;51 Q	Gate time
	dw	offset CGROUP:I_Com52	;52 R	
	dw	offset CGROUP:I_Com53	;53 S	
	dw	offset CGROUP:I_Com54	;54 T	Filter(MIDI ctrl:)
	dw	offset CGROUP:I_Com55	;55 U	Gate time
	dw	offset CGROUP:I_Com56	;56 V	Expression Detune
	dw	offset CGROUP:I_Com57	;57 W	
	dw	offset CGROUP:I_Com58	;58 X	Excluesiv Send(MIDI:0xF0)
	dw	offset CGROUP:I_Com59	;59 Y	
	dw	offset CGROUP:I_Com5a	;5a Z	Send Data(MIDI)
	dw	offset CGROUP:I_Com5b	;5b [	Loop
	dw	offset CGROUP:I_Com5c	;5c \	
	dw	offset CGROUP:I_Com5d	;5d ]	Loop End
	dw	offset CGROUP:I_Com5e	;5e ^	Lengs add
	dw	offset CGROUP:I_Com5f	;5f _	Key Trance
	dw	offset CGROUP:I_Com60	;60 `	
	dw	offset CGROUP:I_Com61	;61 a	(MML:La)
	dw	offset CGROUP:I_Com62	;62 b	(MML:Si)
	dw	offset CGROUP:I_Com63	;63 c	(MML:Do)
	dw	offset CGROUP:I_Com64	;64 d	(MML:Re)
	dw	offset CGROUP:I_Com65	;65 e	(MML:Mi)
	dw	offset CGROUP:I_Com66	;66 f	(MML:Fa)
	dw	offset CGROUP:I_Com67	;67 g	(MML:So)
	dw	offset CGROUP:I_Com68	;68 h	
	dw	offset CGROUP:I_Com69	;69 i	
	dw	offset CGROUP:I_Com6a	;6a j	
	dw	offset CGROUP:I_Com6b	;6b k	velocity(MIDI)
	dw	offset CGROUP:I_Com6c	;6c l	lengs
	dw	offset CGROUP:I_Com6d	;6d m	LFO
	dw	offset CGROUP:I_Com6e	;6e n	Noise mode
	dw	offset CGROUP:I_Com6f	;6f o	Octave
	dw	offset CGROUP:I_Com70	;70 p	Pan.
	dw	offset CGROUP:I_Com71	;71 q	Gate time
	dw	offset CGROUP:I_Com72	;72 r	hol.
	dw	offset CGROUP:I_Com73	;73 s	Sweep
	dw	offset CGROUP:I_Com74	;74 t	tempo(HBLANK)
	dw	offset CGROUP:I_Com75	;75 u	Gate time
	dw	offset CGROUP:I_Com76	;76 v	Volume (WS/MIDI)
	dw	offset CGROUP:I_Com77	;77 w	
	dw	offset CGROUP:I_Com78	;78 x		(MML:Hex)
	dw	offset CGROUP:I_Com79	;79 y	
	dw	offset CGROUP:I_Com7a	;7a z	
	dw	offset CGROUP:I_Com7b	;7b {	Auto trance
	dw	offset CGROUP:I_Com7c	;7c |	
	dw	offset CGROUP:I_Com7d	;7d }	
	dw	offset CGROUP:I_Com7e	;7e ~	
	dw	offset CGROUP:I_Com7f	;7f 	
;===============================================================|
;		コマンドによる分岐				|
;			いわゆる、Ｃ言語でいう'switch'文と同等	|
;===============================================================|
;	●引数							|
;		ds:bp	ワークベースアドレス	引数		|
;		ds:bx	共有構造体アドレス	引数		|
;		ds:di	個別構造体		引数		|
;		es:si	演奏アドレス		引数		|
;		al	音符コマンド（00h～7Fh）破壊ok		|
;	●レジスタ使用						|
;		cx	汎用			破壊ok		|
;		dx	汎用			破壊ok		|
;===============================================================|
	even				;偶数アドレス配置
I_PlayCommand	proc	near

	push	bx			;
	mov	bx,ax			
	and	bx,007fh		;
	shl	bx,1			;
	mov	dx,word ptr cs:[I_PlayCommand_JumpTable + bx]
	pop	bx			;

	call	dx			;サブルーチンの呼び出し

	and	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkSwR

	ret				;ワーク・スイッチのリセット
I_PlayCommand	endp			;
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
	.if	(carry?)		;
		mov	ds:[di].WTD_Expr,0
	.endif				;
	ret				;
;===============================================================|
;		Volume up					|
;===============================================================|
	even				;偶数アドレス配置
I_Com29:				;
	mov	al,ds:[di].WTD_VolumeUpDown
	add	ds:[di].WTD_Expr,al	;
	.if	(carry?)		;
		mov	ds:[di].WTD_Expr,127
	.endif				;
	ret				;
;===============================================================|
;		LFO Switch					|
;===============================================================|
	even				;偶数アドレス配置
I_Com2a:				;
	push	bx			;

;	mov	cl,es:[si]		;cl = 0,1,2
;	inc	si			;
	lodsb	es:[si]
	mov	cl,al
	shl	cl,1			;cl = 0,2,4 (bit)

	xor	ax,ax			;
	call	I_Read8			;
	and	ax,00001h		;Bit Mask
	mov	bx,0FFFEh		;Bit Mask
	.if	(cl!=0)
		shl	ax,cl		;ax = 01h,04h,10h
		rol	bx,cl		;
	.endif

	and	ax,015h			;Bit Mask
	and	word ptr ds:[di].WTD_FlagControl,bx
	or	word ptr ds:[di].WTD_FlagControl,ax

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

;	mov	cl,es:[si]		;cl = 0,1,2
;	inc	si			;
	lodsb	es:[si]
	mov	cl,al
	shl	cl,1			;cl = 0,2,4 (bit)
	inc	cl			;cl = 1,3,5 (bit)

	xor	ax,ax			;
	call	I_Read8			;
	and	ax,00001h		;Bit Mask
	mov	bx,0FFFEh		;Bit Mask

	.if	(cl!=0)
		shl	ax,cl		;al = 02h,08h,20h
		rol	bx,cl		;
	.endif

	and	ax,02Ah			;Bit Mask
	and	ds:[di].WTD_FlagControl,bx
	or	ds:[di].WTD_FlagControl,ax

	pop	bx			;
	ret				;
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
	pop	bx			;

	jmp	I_Com3x_Flag		;フラグ変化
;	ret				;
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
	pop	bx			;

	jmp	I_Com3x_Flag		;フラグ変化
;	ret				;
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
	pop	bx			;

	jmp	I_Com3x_Flag		;フラグ変化
;	ret				;
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
	pop	bx			;

	jmp	I_Com3x_Flag		;フラグ変化
;	ret				;
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
	pop	bx			;

	jmp	I_Com3x_Flag		;フラグ変化
;	ret				;
;===============================================================|
;		Work		SET				|
;===============================================================|
	even				;偶数アドレス配置
I_Com36:				;
	push	bx			;

	;アドレスの取得
	mov	ah,ds:[di].WTD_WorkAddress
	call	I_Read8			;
	mov	bx,ax			;bx←アドレス
	call	I_Read8			;al←数値

	mov	cl,al			;
	mov	al,001h			;
	shl	al,cl			;

	or	ds:[bx],al		;ビットセット

	pop	bx			;
	jmp	I_Com3x_Flag		;フラグ変化
;	ret				;
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
	rol	al,cl			;

	and	ds:[bx],al		;ビットリセット

	pop	bx			;
	jmp	I_Com3x_Flag		;フラグ変化
;	ret				;
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
	pop	bx			;

	jmp	I_Com3x_Flag		;フラグ変化
;	ret				;
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
	pop	bx			;

;	jmp	I_Com3x_Flag		;フラグ変化
;	ret				;
;===============================================================|
;		Work	フラグ変化				|
;===============================================================|
	even				;偶数アドレス配置
I_Com3x_Flag:

	;キャリーフラグ
	pushf				;レジスタ保存
	.if	(carry?)
		or	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkCy
	.else
		and	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkCyR
	.endif
	popf				;レジスタ復帰

	;ゼローフラグ
	pushf				;レジスタ保存
	.if	(zero?)
		or	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkZe
	.else
		and	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkZeR
	.endif
	popf				;レジスタ復帰

	ret
;===============================================================|
;		Loop Jump					|
;===============================================================|
	even				;偶数アドレス配置
I_Com3a:				;
	push	bx			;

	;読み込み
	lodsw	es:[si]

	;カウンタ・読み込み
	xor	bx,bx			;
	mov	bl,ds:[di].WTD_LoopCountPointer

	;チェック
	.if	(ds:[di + bx].WTD_LoopCount==1)
		dec	ds:[di].WTD_LoopCountPointer
		mov	si,ax		;
	.endif

	pop	bx			;
	ret				;終了
;===============================================================|
;		Loop Jump Flags					|
;===============================================================|
	even				;偶数アドレス配置
I_Com3b:				;
	mov	ax,ds:[di].WTD_FlagControl
	and	ax,WTD_Ctrl_WorkCy + WTD_Ctrl_WorkZe
	shr	ax,4			;
	call	I_Read8			;dh←WTD内部のフラグ
	mov	dx,ax			;dl←曲データ中のフラグ

	lodsw	es:[si]			;ax←ループ先

	;チェック
	.if	(dl==dh)
		dec	ds:[di].WTD_LoopCountPointer
		mov	si,ax		;ループ抜け
	.endif

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

;	jc	I_Com40_1st
	.if	(!carry?)
I_Com40_1st:
		mov	ds:[di].WTD_Program1st,al
		mov	dx,offset CGROUP:I_Table_Voice
		jmp	I_Table_Jump
	.else
		mov	ah,al		;
		call	I_Read8		;
;		.if	(ah==01h)
		cmp	ah,01h
		jnz	I_Com40_2nd
			mov	ds:[di].WTD_Program2nd,al
			call	I_Read16
			mov	ds:[di].WTD_ProgramRate,ax
			ret		;※else の jmp 命令の代理
	even
I_Com40_2nd:
;		.elseif	(ah==02h)
		cmp	ah,02h
			jnz	I_Com40_1st
			mov	ds:[di].WTD_Program3rd,al
;		.else	;(ah==00h)	デフォルト
;			jmp	I_Com40_1st
;		.endif
	.endif

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
	.if	(carry?)

ifndef	hyoka	;------------------------廉価版は無し
	mov	al,00h			;
	mov	cl,MIDI_Ctrl_RegLSB	;
	mov	dx,offset CGROUP:I_Table_CtrlChgB
	call	I_Table_Jump		;

	mov	al,00h			;
	mov	cl,MIDI_Ctrl_RegMSB	;
	mov	dx,offset CGROUP:I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

	call	I_Read8			;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_DataEntly	;
	mov	dx,offset CGROUP:I_Table_CtrlChgB
	jmp	I_Table_Jump		;※call → jmp
endif	;--------------------------------

	.endif
	ret				;
;===============================================================|
;		Track / Sound Type				|
;===============================================================|
	even				;偶数アドレス配置
I_Com43:				;
	call	I_Read8			;
	mov	ds:[di].WTD_Channel,al	;

	;効果音？
	.if	(ds:[di].WTD_FlagControl&WTD_Ctrl_Effect)
		and	al,07h		;
		mov	cl,al		;
		inc	cl		;
		mov	ax,0800h	;
		shl	ax,cl		;
		or	ds:[bx].WTD_Sys_Flag,ax
	.endif
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

	lodsb	es:[si]


	push	ax			;保存
	xor	ax,ax			;
	call	I_Read8			;ax←エンベロープ番号
	and	ax,001fh		;
	shl	ax,4			;ax←ax×16
	pop	bx			;復帰

	mov	bh,ah			;bh←上位ビット

	.if	(bl==0)		;音程
		and	ds:[di].WTD_BendEmbAddress,00fh	;
		or	ds:[di].WTD_BendEmbAddress,al	;

;		mov	ax,ds:[di].WTD_FlagControl	;
		shr	bx,1				;bx bit 7  =  No. bit 5
		and	bx,WTD_Ctrl_EmbFreq		;
		mov	ax,WTD_Ctrl_EmbFreqR		;
;		or	ax,bx				;
;		mov	ds:[di].WTD_FlagControl,ax

	.elseif	(bl==1)		;音量
		and	ds:[di].WTD_ExprEmbAddress,00fh	;
		or	ds:[di].WTD_ExprEmbAddress,al	;

;		mov	ax,ds:[di].WTD_FlagControl	;bx bit 8  =  No. bit 5
		and	bx,WTD_Ctrl_EmbVol		;
		mov	ax,WTD_Ctrl_EmbVolR		;
;		or	ax,bx				;
;		mov	ds:[di].WTD_FlagControl,ax

	.elseif	(bl==2)		;パン
		and	ds:[di].WTD_PanEmbAddress,00fh	;
		or	ds:[di].WTD_PanEmbAddress,al	;

;		mov	ax,ds:[di].WTD_FlagControl	;
		shl	bx,1				;bx bit 9  =  No. bit 5
		and	bx,WTD_Ctrl_EmbPan		;
		mov	ax,WTD_Ctrl_EmbPanR		;
;		or	ax,bx				;
;		mov	ds:[di].WTD_FlagControl,ax
	.endif

	and	ds:[di].WTD_FlagControl,ax
	or	ds:[di].WTD_FlagControl,bx

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
	mov	dx,offset CGROUP:I_Table_CtrlChgB
	jmp	I_Table_Jump		;※call → jmp
endif	;--------------------------------

	ret				;
;===============================================================|
;		Channel Pressior(MIDI)				|
;===============================================================|
	even				;偶数アドレス配置
I_Com47:				;
	call	I_Read8			;
	mov	dx,offset CGROUP:I_Table_PolyChPress
	jmp	I_Table_Jump		;
;	ret				;
;===============================================================|
;		Program Bank Select(MIDI)			|
;===============================================================|
	even				;偶数アドレス配置
I_Com48:				;
	call	I_Read16		;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_Bank	;
	mov	dx,offset CGROUP:I_Table_CtrlChgW
	jmp	I_Table_Jump		;※call → jmp
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
	lodsw	es:[si]

	;無限ループ	（こっちの方が、高頻度）
	.if	(ax==0)
		or	ds:[di].WTD_FlagControl,WTD_Ctrl_PlayEnd
		mov	ch,byte ptr ds:[di].WTD_Channel

		.if	((ds:[di].WTD_FlagControl&WTD_Ctrl_Effect) && (ch>=80h))
			jmp	I_Effect_Return	;効果音からの復帰	※call → jmp
		.endif
	;演奏終了
	.else
		mov	si,ax		;ループ
	.endif
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
;	mov	dx,offset CGROUP:I_Table_CtrlChgB
;	jmp	I_Table_Jump		;※call → jmp
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
	mov	dx,offset CGROUP:I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

	call	I_Read8			;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_NonRegMSB	;
	mov	dx,offset CGROUP:I_Table_CtrlChgB
	call	I_Table_Jump		;
endif	;--------------------------------

	call	I_Read8			;

ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_DataEntly	;
	mov	dx,offset CGROUP:I_Table_CtrlChgB
	jmp	I_Table_Jump		;※call → jmp
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
	mov	dx,offset CGROUP:I_Table_CtrlChgB
	jmp	I_Table_Jump		;※call → jmp
endif	;--------------------------------

	ret				;
;===============================================================|
;		PCM Mode / MIDI Damper				|
;===============================================================|
	even				;偶数アドレス配置
I_Com50:				;
	call	I_Read8			;
	mov	dx,offset CGROUP:I_Table_Mode
	jmp	I_Table_Jump		;設定
;	ret				;終了
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
	mov	dx,offset CGROUP:I_Table_CtrlChgB
	jmp	I_Table_Jump		;※call → jmp
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
	mov	dx,offset CGROUP:I_Table_CtrlChgB
	jmp	I_Table_Jump		;※call → jmp
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
	mov	dx,offset CGROUP:I_Table_CtrlChgB
	jmp	I_Table_Jump		;※call → jmp
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
	mov	dx,offset CGROUP:I_Table_CtrlChgB
	jmp	I_Table_Jump		;※call → jmp
endif	;--------------------------------

	ret				;
;===============================================================|
;		Excluesiv Send(MIDI)				|
;===============================================================|
	even				;偶数アドレス配置
I_Com58:				;
	push	ds			;

I_Com58_Step1:				;
	lodsb	es:[si]

ifndef	hyoka
	call	C_Send			;送信
endif

	cmp	al,0f7h			;0xF7だったら終わり。
	jnz	I_Com58_Step1		;

	;ランニングステータスの初期化
	mov	ds:[bp].WTD_WorkAdd_System+WTD_Sys_RunningStatus,0

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

;	xor	cx,cx
;	mov	cl,es:[si]		;
;	inc	si			;
	xor	ax,ax
	lodsb	es:[si]
	mov	cx,ax

	.repeat
		lodsb	es:[si]
ifndef	hyoka
		call	C_Send		;送信
endif
	.untilcxz

	;ランニングステータスの初期化
	mov	ds:[bp].WTD_WorkAdd_System+WTD_Sys_RunningStatus,0

	ret				;
;===============================================================|
;		Loop Start					|
;===============================================================|
	even				;偶数アドレス配置
I_Com5b:				;

	;読み込み
	lodsb	es:[si]

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
;	mov	dx,es:[si]		;
;	inc	si			;
;	inc	si			;
	lodsw	es:[si]

	;カウンタ・ディクリメント
	push	bx			;
	xor	bx,bx			;
	mov	bl,ds:[di].WTD_LoopCountPointer
	dec	ds:[di + bx].WTD_LoopCount	;Zeは立つ Cy変化無し
	pop	bx			;
	.if	(zero?)
		dec	ds:[di].WTD_LoopCountPointer
	.else
		mov	si,ax		;
	.endif

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
	lodsb	es:[si]
	.if	(al==0FFh)
		lodsw	es:[si]
	.endif
	mov	ds:[di].WTD_LengDefault,ax
	ret				;
;===============================================================|
;		LFO						|
;===============================================================|
	even				;偶数アドレス配置
I_Com6d:				;
	push	bx			;

	lodsb	es:[si]

	.if	(al==0)
		lea	bx,[di + WTD_BendLFO]
	.elseif	(al==2)
		lea	bx,[di + WTD_PanLFO]
	.else	;(al==1)	デフォルトはEPにしておく
		lea	bx,[di + WTD_ExprLFO]
	.endif

	call	I_Read8			;DR
	mov	ds:[bx].WTD_ChLfo_DecayRate,al

	call	I_Read8			;SR
	mov	ds:[bx].WTD_ChLfo_SpeedRate,al

	call	I_Read16		;Lv
	mov	ds:[bx].WTD_ChLfo_Level,ax

	call	I_Read8			;Cnt
	mov	ds:[bx].WTD_ChLfo_Count,al

	pop	bx			;
	ret				;
;===============================================================|
;		Noise mode					|
;---------------------------------------------------------------|
;	0x00～0x07	Set the noise mode 			|
;	(0～7)		bit 0-2 : Noise mode (0～7)		|
;===============================================================|
	even				;偶数アドレス配置
I_Com6e:				;
	call	I_Read8			;al ← 引数

	mov	ds:[di].WTD_NoiseMode,al
	or	al,18h			;
	mov	ah,1fh			;
	mov	ch, 3			;
	jmp	SP_Set_Noise		;※call → jmp

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
	call	I_Read8			;
	mov	ds:[di].WTD_Pan,al	;
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

	;PCM Ch2であるか？
	.if	(ds:[di].WTD_Channel==82h)
		mov	ds:[di].WTD_SweepLevel,al
		mov	ds:[di].WTD_SweepTime,ah
		mov	ch, 2		;
		jmp	SP_Set_Sweep	;Sweep Modeの設定	※call → jmp
	.endif
	ret				;
;===============================================================|
;		tempo						|
;===============================================================|
	even				;偶数アドレス配置
I_Com74:				;
	call	I_Read16		;データは読む。

	;効果音の場合、処理無し。
	.if	!(ds:[di].WTD_FlagControl&WTD_Ctrl_Effect)
		mov	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Tempo,ax
		.if	!((ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag)&WTD_Sys_TimerEmulate)
			jmp	T_Set_Frection	;タイマーセット	※call → jmp
		.endif
	.endif

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

	call	I_Read8			;
	mov	cl,al			;
	call	I_Read8			;

	mov	dx,offset CGROUP:I_Table_CtrlChgB
	call	I_Table_Jump		;

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
	lodsb	es:[si]

	.if	(al!=0)
		rol	al,1		;
		shr	al,1		;Bit 7 Reset & Bit 7 -> Cy Flag
		.if	(!carry?)
			mov	ds:[di].WTD_FlagSharp,al
		.else
			mov	ds:[di].WTD_FlagFlat,al	;
		.endif
	.else
		mov	ds:[di].WTD_FlagSharp,al
		mov	ds:[di].WTD_FlagFlat,al
	.endif

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
