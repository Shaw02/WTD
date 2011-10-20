;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				Command Compile Routine			|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;===============================================================|
;		構造体定義　（コンパイル制御用）		|
;===============================================================|
cMCD		struc
cMCD_ChannelWTD	db	?		;現在コンパイル中のチャンネル。
cMCD_ChannelMML	db	?		;現在コンパイル中のチャンネル。
cMCD_DefLength	dw	?		;デフォルト音長記憶
cMCD_LoopL	dw	?		;無限ループアドレス
cMCD_LoopCount	dw	?		;リピート(スタック)
cMCD_LoopEnd	dw	8	dup(?)	;リピート(終了点記憶用)
cMCD_LoopJump	dw	8	dup(?)	;リピート()
cMCD_MacroCount	dw	?		;マクロのスタックポインタ
cMCD_MacroAdr	dw	8	dup(?)	;マクロのスタックエリア
cMCD		ends

;===============================================================|
;		命令定義　（コンパイル情報）			|
;===============================================================|
;コマンド・データのアドレス。
.const
c_Command_Adrs		dw	((offset c_Command_Adrs_E)-(offset c_Command_Adrs_S))/2 + 1
c_Command_Adrs_S	dw	offset cMCD_0		;<CR+LF>+"C"
			dw	offset cMCD_1		;<CR+LF>+"!"
			dw	offset cMCD_2		;<CR+LF>
			dw	offset cMCD_3		;a	ラ
			dw	offset cMCD_4		;b	シ
			dw	offset cMCD_5		;c	ド
			dw	offset cMCD_6		;d	レ
			dw	offset cMCD_7		;e	ミ
			dw	offset cMCD_8		;f	ファ
			dw	offset cMCD_9		;g	ソ
			dw	offset cMCD_10		;h	
			dw	offset cMCD_11		;i	
			dw	offset cMCD_12		;j	
			dw	offset cMCD_13		;k	
			dw	offset cMCD_14		;l	
			dw	offset cMCD_15		;n	
			dw	offset cMCD_16		;m	
			dw	offset cMCD_17		;o	
			dw	offset cMCD_18		;p	
			dw	offset cMCD_19		;q	
			dw	offset cMCD_20		;r	
			dw	offset cMCD_21		;s	
			dw	offset cMCD_22		;t	
			dw	offset cMCD_23		;u	
			dw	offset cMCD_24		;v	
			dw	offset cMCD_25		;w	
			dw	offset cMCD_26		;x	
			dw	offset cMCD_27		;y	
			dw	offset cMCD_28		;z	
			dw	offset cMCD_29		;A	
			dw	offset cMCD_30		;B	
			dw	offset cMCD_31		;C	
			dw	offset cMCD_32		;D	
			dw	offset cMCD_33		;E	
			dw	offset cMCD_34		;F	
			dw	offset cMCD_35		;G	
			dw	offset cMCD_36		;H	
			dw	offset cMCD_37		;I	
			dw	offset cMCD_38		;J	
			dw	offset cMCD_39		;K	
			dw	offset cMCD_40		;L	
			dw	offset cMCD_41		;N	
			dw	offset cMCD_42		;M	
			dw	offset cMCD_43		;O	
			dw	offset cMCD_44		;P	
			dw	offset cMCD_45		;Q	
			dw	offset cMCD_46		;R	
			dw	offset cMCD_47		;S	
			dw	offset cMCD_48		;T	
			dw	offset cMCD_49		;U	
			dw	offset cMCD_50		;V	
			dw	offset cMCD_51		;W	
			dw	offset cMCD_52		;X	
			dw	offset cMCD_53		;Y	
			dw	offset cMCD_54		;Z	
			dw	offset cMCD_55		;!	
			dw	offset cMCD_56		;"	
			dw	offset cMCD_57		;'	
			dw	offset cMCD_58		;(	
			dw	offset cMCD_59		;)	
			dw	offset cMCD_60		;0	
			dw	offset cMCD_61		;1	
			dw	offset cMCD_62		;2	
			dw	offset cMCD_63		;3	
			dw	offset cMCD_64		;4	
			dw	offset cMCD_65		;5	
			dw	offset cMCD_66		;6	
			dw	offset cMCD_67		;7	
			dw	offset cMCD_68		;8	
			dw	offset cMCD_69		;9	
			dw	offset cMCD_70		;*	
			dw	offset cMCD_71		;/	
			dw	offset cMCD_72		;:	
			dw	offset cMCD_73		;	
			dw	offset cMCD_74		;[	
			dw	offset cMCD_75		;]	
			dw	offset cMCD_76		;<	
			dw	offset cMCD_77		;>	
			dw	offset cMCD_78		;@F	
			dw	offset cMCD_79		;@S	
			dw	offset cMCD_80		;@R	
			dw	offset cMCD_81		;@	
			dw	offset cMCD_82		;_	
c_Command_Adrs_E	dw	offset cMCD_83		;{	
;c_Command_Adrs_E:
;---------------------------------------------------------------|
;	①コマンド文字列					|
;		最後は00hで終わる				|
;	②バージョン						|
;		byte	整数部	／	byte	少数部		|
;	③出力文字列。						|
;		最後は00hで終わる				|
;	④出力する場所						|
;	    00h	終わり						|
;	    1xh データ読み込み＆書き込み			|
;		x	0:4bit×2 / 1:Byte / 2:Word		|
;	    20h 音長用数値書き込み。				|(変更未)
;		「Zenlen÷(読み込み)」を書き込む。		|
;		（'%'指定だったら、そのままの数値。）		|
;		（付点もチェックする。）			|
;		01	lコマンドの場合指定する。		|
;		01以外	lコマンド以外。				|
;	    8xh	音階書き込み					|(変更未)
;		x	0・・・休符				|
;			1・・・ド　／　7・・・シ		|
;		('#','+','-','&'のチェック。)			|
;		(次に、数値があるかチェック。→'20h'と同じ処理)	|
;	    F0h	プログラム					|
;		nnnn	Offset Address				|
;---------------------------------------------------------------|
;		MML		WTD	Output	param
;		Strings		Version	Strings	Command
cMCD_0	db	0dh,0ah,'C',0,	0,1,	0,	0f0h	;<CR+LF>+'C'
	dw		offset cMCD_CH			;
	db		0				;
cMCD_1	db	0dh,0ah,0,	0,1,	0,	0f0h	;<CR+LF>改行
	dw		offset cMCD_CR			;
	db		0				;－最初に改行チェック
cMCD_2	db	'$',0,		0,1,	0,	0f0h	;<CR+LF>+'$'
	dw		offset cMCD_Macro		;
	db		0				;
cMCD_3	db	'a',0,		0,1,	0,	86h,0	;a	ラ
cMCD_4	db	'b',0,		0,1,	0,	87h,0	;b	シ
cMCD_5	db	'c',0,		0,1,	0,	81h,0	;c	ド
cMCD_6	db	'd',0,		0,1,	0,	82h,0	;d	レ
cMCD_7	db	'e',0,		0,1,	0,	83h,0	;e	ミ
cMCD_8	db	'f',0,		0,1,	0,	84h,0	;f	ファ
cMCD_9	db	'g',0,		0,1,	0,	85h,0	;g	ソ
cMCD_10	db	'h',0,		0,0,	0,	0	;h
cMCD_11	db	'i',0,		0,0,	0,	0	;i
cMCD_12	db	'j',0,		0,0,	0,	0	;j
cMCD_13	db	'k',0,		0,1,	'k',0,	11h,0	;k	Velocity
cMCD_14	db	'l',0,		0,1,	'l',0,	20h,1,0	;l	Lengs
cMCD_15	db	'n',0,		0,1,	'n',0,	11h,0	;n	Noise mode
cMCD_16	db	'm',0,		0,4,	'm',0,	11h,11h,11h,12h,11h,0	;m
cMCD_17	db	'o',0,		0,1,	'o',0,	11h,0	;o	Octave
cMCD_18	db	'p',0,		1,7,	'p',0,	0f0h	;p	Pan
	dw		offset cMCD_sp
	db		0
cMCD_19	db	'q',0,		0,1,	'q',0,	12h,0	;q	Gate Step
cMCD_20	db	'r',0,		0,1,	0,	80h,0	;r	休符
cMCD_21	db	's',0,		0,5,	's',0,	11h,11h,0   ;s	Sweep
cMCD_22	db	't',0,		0,2,	't',0,	0f0h	;t	Tempo
	dw		offset cMCD_st
	db		0
cMCD_23	db	'u',0,		0,1,	'u',0,	12h,0	;u	Gate Step
cMCD_24	db	'v',0,		0,1,	'v',0,	0f0h	;v	Volume
	dw		offset cMCD_sv
	db		0
cMCD_25	db	'w',0,		0,0,	0,	0	;w
cMCD_26	db	'x',0,		0,5,	'x',0,	11h,0	;x	Volume UpDown
cMCD_27	db	'y',0,		0,5,	'y',0,	11h,11h,0   ;y	Conroll Change
cMCD_28	db	'z',0,		0,0,	0,	0	;z
cMCD_29	db	'A',0,		0,0,	0,	0	;A
cMCD_30	db	'B',0,		0,8,	'B',0,	0f0h	;B	Bend
	dw		offset cMCD_lb
	db		0
cMCD_31	db	'C',0,		0,1,	'C',0,	11h,0	;C	Channel
cMCD_32	db	'D',0,		0,1,	'D',0,	12h,0	;D	Detune
cMCD_33	db	'E',0,		0,5,	'E',0,	11h,11h,0   ;E	Emb
cMCD_34	db	'F',0,		0,8,	'F',0,	11h,0	;F	Volume
cMCD_35	db	'G',0,		0,8,	'G',0,	11h,0	;G	Plessior
cMCD_36	db	'H',0,		0,8,	'H',0,	11h,11h,0   ;H	Bank
cMCD_37	db	'I',0,		0,0,	0,	0	;I
cMCD_38	db	'J',0,		0,0,	0,	0	;J
cMCD_39	db	'K',0,		0,1,	'K',0,	12h,0	;K	KeyDelay
cMCD_40	db	'L',0,		0,3,	0,	0f0h	;L	Loop
	dw		offset cMCD_lL			;
	db		0				;
cMCD_41	db	'N',0,		0,8,	'N',0,	11h,0	;N	NPR
cMCD_42	db	'M',0,		0,0ah,	'M',0,	12h,11h,0   ;M	Mod
cMCD_43	db	'O',0,		0,8,	'O',0,	11h,0	;O	Son
cMCD_44	db	'P',0,		0,3,	'P',0,	11h,0	;P	Switch
cMCD_45	db	'Q',0,		0,1,	'Q',0,	11h,0	;Q	Gate time
cMCD_46	db	'R',0,		0,8,	'R',0,	11h,0	;R	Bless
cMCD_47	db	'S',0,		0,8,	'S',0,	11h,0	;S	Soft
cMCD_48	db	'T',0,		0,8,	'T',0,	11h,0	;T	Foot
cMCD_49	db	'U',0,		0,1,	'U',0,	11h,0	;U	Gate time
cMCD_50	db	'V',0,		0,1,	'V',0,	12h,0	;V	V dev
cMCD_51	db	'W',0,		0,8,	'W',0,	11h,0	;W	Blance
cMCD_52	db	'X',0,		0,5,	'X',0,	0f0h	;X
	dw		offset cMCD_lX			;
	db		0				;
cMCD_53	db	'Y',0,		0,0,	0,	0	;Y
cMCD_54	db	'Z',0,		0,5,	'Z',0,	0f0h	;Z
	dw		offset cMCD_lZ			;
	db		0				;
cMCD_55	db	'!',0,		0,1,	'!',0,	0	;!	Work Sw
cMCD_56	db	'"',0,		0,1,	'"',0,	11h,0	;"	Work Add
cMCD_57	db	27h,0,		0,1,	27h,0,	11h,0	;'	Acsent
cMCD_58	db	'(',0,		0,1,	'(',0,	0	;(	Volume Down
cMCD_59	db	')',0,		0,1,	')',0,	0	;)	Volume Up
cMCD_60	db	'0',0,		1,0,	'0',0,	11h,11h,0   ;0	ld
cMCD_61	db	'1',0,		1,0,	'1',0,	11h,11h,0   ;1	add
cMCD_62	db	'2',0,		1,0,	'2',0,	11h,11h,0   ;2	sub
cMCD_63	db	'3',0,		1,0,	'3',0,	11h,11h,0   ;3	and
cMCD_64	db	'4',0,		1,0,	'4',0,	11h,11h,0   ;4	or
cMCD_65	db	'5',0,		1,0,	'5',0,	11h,11h,0   ;5	xor
cMCD_66	db	'6',0,		1,0,	'6',0,	11h,11h,0   ;6	set
cMCD_67	db	'7',0,		1,0,	'7',0,	11h,11h,0   ;7	reset
cMCD_68	db	'8',0,		1,0,	'8',0,	11h,11h,0   ;8	cmp
cMCD_69	db	'9',0,		1,0,	'9',0,	11h,11h,0   ;9	test
cMCD_70	db	'*',0,		0,4,	'*',0,	11h,11h,0   ;*	LFO Switch
cMCD_71	db	'/',0,		0,5,	'/',0,	11h,11h,0   ;/	Emb Switch
cMCD_72	db	':',0,		0,3,	':',0,	0f0h	;:	Loop Jump
	dw		offset cMCD_Loop_Jump		;
	db		0				;
cMCD_73	db	3bh,0,		1,0,	3bh,0,	11h,0f0h    ;;	Loop Flag
	dw		offset cMCD_Loop_Jump		;
	db		0				;
cMCD_74	db	'[',0,		0,3,	'[',0,	0f0h	;[	Loop Start
	dw		offset cMCD_Loop_Start		;
	db		0				;
cMCD_75	db	']',0,		0,3,	']',0,	0f0h	;]	Loop End
	dw		offset cMCD_Loop_End		;
	db		0				;
cMCD_76	db	'<',0,		0,1,	'<',0,	0	;<
cMCD_77	db	'>',0,		0,1,	'>',0,	0	;>
cMCD_78	db	'@F',0,		1,5,	'@',80h,0,    11h,0	;@F
cMCD_79	db	'@S',0,		1,5,	'@',81h,0,    11h,12h,0	;@S
cMCD_80	db	'@R',0,		1,5,	'@',82h,0,    11h,0	;@R
cMCD_81	db	'@',0,		0,1,	'@',0,	11h,0	;@
cMCD_82	db	'_',0,		0,1,	'_',0,	11h,0	;_
cMCD_83	db	'{',0,		0,8,	'{',0,	0f0h	;{
	dw		offset cMCD_trance		;
	db		0				;
.code

;---------------------------------------------------------------
;	改行の直前までポインタを進める
;---------------------------------------------------------------
cMCD_CRS	proc	near	uses ax	;Serach

	.repeat
	   call	CREAD_L			;ファイル終了だったら、終わり。
	   jc	cMCD_CRS_END		;（このとき、ポインタは改行の次。）
	.until	(al == 0dh)		;改行があった。

	;ポインタを改行直前に戻す。
	dec	cs:[pMML_File]		;

cMCD_CRS_END:
	ret				;
cMCD_CRS	endp
;---------------------------------------------------------------
;	改行があった場合の処理
;---------------------------------------------------------------
;	処理１：マクロ中の場合
;		マクロを終了する。
;
;	処理２：マクロ中でない場合
;		行先頭がスペース or 制御コードかチェックし、
;		それ以外であれば、改行の直前までポインタを進める。
;---------------------------------------------------------------
cMCD_CR		proc	near	uses ax
	call	cMCD_MacroEndChk	;マクロ中かチェック＆マクロ終了。
	.if	(!carry?)
	   ;-------
	   ;マクロ中じゃなかった場合	;スペース or 制御文字であるかチェックし、
	   call	CREAD_L			;そうでなかったら、改行検査を行う。
	   .if	(al >= 21h)		;制御文字以外だったら、改行検査から。
		call	cMCD_CRS	;次の改行まで進める。
	   .else
		dec	cs:[pMML_File]	;
	   .endif
	.endif
	ret				;
cMCD_CR		endp
;---------------------------------------------------------------
;	改行＋"C"があった場合の処理	チャンネル設定
;---------------------------------------------------------------
cMCD_CH		proc	near	uses ax
	call	cMCD_MacroEndChk	;マクロの終了かどうかをチェック
	.if	(!carry?)
		mov	ss:[di].cMCD_ChannelMML,0ffh	;ダミーの設定

		.repeat
		   call	A2H8R		;読み込み
		   .if	(ah == ss:[di].cMCD_ChannelWTD)
			mov	ss:[di].cMCD_ChannelMML,ah
		   .endif
		   call	CREAD_L		;カンマがあったら、
		.until	(al != ',')	;トラックの複数指定。
	.endif
	ret				;
cMCD_CH		endp
;---------------------------------------------------------------
;	マクロ呼び出し
;---------------------------------------------------------------
.const
cMCD_Macro_Err	db	'マクロが定義されていません。',0DH,0AH,'$'
cMCD_Macro_Err2	db	'マクロのネストが８回を超えました。',0DH,0AH,'$'
.code
cMCD_Macro	proc	near	uses ax bx cx dx	;マクロ

	local	ptMacroSearch:word		;ポインタ

	;●マクロ名の取得
	xor	bx,bx				;
	call	CREAD_L				;
	mov	bl,al				;bl ← マクロ文字
	push	cs:[pMML_File]			;
	call	CREAD_L				;
	pop	cs:[pMML_File]			;ah ← 引数先頭文字
	.if	((al >= 30h) && (al < 3Ah))
		call	A2H8R			;
		mov	bh,ah			;bh ← マクロ引数
	.endif					;bx ← マクロ番号（文字と番号）

	;●マクロの検索
	mov	dx,cs:[pMML_File]		;dx←MMLのポインタ（保存）
	mov	ptMacroSearch,0			;ポインタを先頭に
	.repeat
		xor	cx,cx			;cx←マクロ番号

		mov	ax,ptMacroSearch	;今のポインタ
		mov	cs:[pMML_File],ax	;
		inc	ptMacroSearch		;サーチポインタをインクリメント

		;CR+LF+'$'があるかを、先ずチェック
		call	cread_l			;
		.if	(carry?)		;EOFになったら、
			mov	dx,offset cMCD_Macro_Err
			jmp	PRINT_ERR
		.endif
		.continue	.if	(al != 0dh)
		call	cread_l			;
		.continue	.if	(al != 0ah)
		call	cread_l			;
		.continue	.if	(al != '$')

		;同一名のマクロかチェック
		call	CREAD_L			;
		mov	cl,al			;cl←マクロ文字
		push	cs:[pMML_File]		;ポインタ復帰
		call	CREAD_L			;
		pop	cs:[pMML_File]		;ポインタ復帰
		.if	((al >= 30h) && (al < 3Ah))
			call	A2H8R		;
			mov	ch,ah		;ch←番号
		.endif
	.until	(cx == bx)

	;●マクロ
	add	ss:[di].cMCD_MacroCount,2	;
	mov	bx,ss:[di].cMCD_MacroCount	;マクロのポインタ
	.if	(bx >= 16)
		mov	dx,offset cMCD_Macro_Err2
		jmp	PRINT_ERR
	.endif
	mov	ss:[di].cMCD_MacroAdr[bx],dx	;復帰時のポインタ

	ret					;
cMCD_Macro	endp
;---------------------------------------------------------------
;	マクロ中かチェック＆マクロの終了
;---------------------------------------------------------------
;	◆返値
;		cy='L'	マクロ中じゃない。そのままリターン
;		cy='H'	マクロを終了した。
;			cs:[pMML_File]	元のポインタ
;---------------------------------------------------------------
cMCD_MacroEndChk	proc	near	uses ax bx

	mov	bx,ss:[di].cMCD_MacroCount		;マクロのポインタ
	.if	(bx != -2)
		sub	ss:[di].cMCD_MacroCount,2	;
		mov	ax,ss:[di].cMCD_MacroAdr[bx]	;
		mov	cs:[pMML_File],ax		;
		stc					;Cy←'h'
	.endif

	ret				;
cMCD_MacroEndChk	endp
;---------------------------------------------------------------
;	パンポット
;---------------------------------------------------------------
cMCD_sp		proc	near	uses ax	bx

	push	cs:[pMML_File]		;
	call	CREAD_L			;%があったら、
	pop	cs:[pMML_File]		;
	call	A2H8R	
	.if	(al == '%')
	   .if	(ah < 32)		;%があった場合
		shl	ah,2		;それ以外は４倍にする。
	   .else
		mov	ah,127		;もし32以上だったら127
	   .endif
	.endif
	call	CSET			;

	push	cs:[pMML_File]		;
	call	CREAD_L			;カンマがあったら、
	pop	cs:[pMML_File]		;
	.if	(al == ',')
	call	A2H8R			;引数を読む
	   .if	(ah >= 1)
		mov	bx,CS:[pWTD_File]	;
		dec	bx			;
		or	byte ptr ds:[bx],80h	;
	   .endif
	.endif

	ret				;
cMCD_sp		endp
;---------------------------------------------------------------
;	音量
;---------------------------------------------------------------
cMCD_sv		proc	near	uses ax	;

	push	cs:[pMML_File]		;
	call	CREAD_L			;%があったら、
	pop	cs:[pMML_File]		;
	call	A2H8R	
	.if	(al == '%')
	   .if	(ah < 16)		;%があった場合
		shl	ah,3		;それ以外は8倍にする。
	   .else
		mov	ah,127		;もし16以上だったら127
	   .endif
	.endif
	call	CSET			;

	ret				;
cMCD_sv		endp
;---------------------------------------------------------------
;	テンポ
;---------------------------------------------------------------
cMCD_st		proc	near	uses ax bx cx dx
	push	cs:[pMML_File]		;
	call	CREAD_L			;
	pop	cs:[pMML_File]		;
	mov	cl,al			;
	call	A2H16R			;
	.if	(cl != '%')		;%が無かったら
		;数値読み込み		;
		mov	cx,ax		;cx ← 読み込んだ値
		xor	bx,bx		;bx ← TimeBase
		mov	bl,ds:[0].WTD_Mus_TimeBase
		;演算
		mov	dx,0000ah	;
		mov	ax,0fc80h	;
		div	bx		;
		xor	dx,dx		;
		div	cx		;ax←12000 * 60 / (Tempo * TimeBase)
	.endif
	call	CSET16			;書き込み

	;終了
	ret				;
cMCD_st		endp
;---------------------------------------------------------------
;	ピッチベンド
;---------------------------------------------------------------
cMCD_lB		proc	near	uses ax bx	;'B'コマンド
	
	call	A2H16R				;
	call	CSET16				;

	push	cs:[pMML_File]			;
	call	CREAD_L				;
	pop	cs:[pMML_File]			;
	.if	(al == ',')			;カンマがあったら、ベンドレンジ
		push	bx			;ビットセット
		mov	bx,CS:[pWTD_File]	;
		dec	bx			;
		dec	bx			;
		or	word ptr ds:[bx],8000h	;
		pop	bx			;
		call	A2H8R			;
		call	CSET			;
	.endif

	ret				;
cMCD_lB		endp
;---------------------------------------------------------------
;	無限ループのポインタセット
;---------------------------------------------------------------
cMCD_lL		proc	near	uses ax	;'L'コマンド
	
	mov	ax,cs:[pWTD_File]	;
	mov	ss:[di].cMCD_LoopL,ax	;
	
	ret				;
cMCD_lL		endp
;---------------------------------------------------------------
;	エクスクルーシブ
;---------------------------------------------------------------
cMCD_lX		proc	near	uses ax	;'X'コマンド

	local	cCRC:BYTE		;Roland GS音源のチェックサム計算用
	local	cFlag:BYTE		;チェックサム計算中か？

	mov	cCRC,0			;CRCを0x00にする。
	mov	cFlag,0			;Flagを0x00にする。

	mov	ah,0f0h			;エクスクルーシブ開始
	call	cset			;
	.repeat
		push	cs:[pMML_File]		;
		call	CREAD_L			;
		pop	cs:[pMML_File]		;
		.break	.if	(al == '}')	;
		.if		(al == '(')	;
			mov	cFlag,1		;Flagを0x01にする。
		.elseif		(al == ')')	;
			mov	cFlag,0		;Flagを0x00にする。
			mov	al,cCRC		;
			and	al,07fh		;
			mov	ah,128		;
			sub	ah,al		;
			call	CSET		;CRCの出力
		.elseif	((al >= 30h) && (al < 3Ah))
			call	A2H8R		;読み込み
			call	CSET		;
			.if	(cFlag == 1)	;
			   add	cCRC,ah		;
			.endif
			.continue
		.endif
		inc	cs:[pMML_File]		;
	.until	0

	mov	al,0f7h			;エクスクルーシブ終了
	call	cset_l			;

	ret				;
cMCD_lX		endp
;---------------------------------------------------------------
;	MIDIイベント直書き込み
;---------------------------------------------------------------
cMCD_lZ		proc	near	uses ax bx cx	;'Z'コマンド

	mov	bx,cs:[pWTD_File]	;一時保存
	xor	cx,cx			;
	call	CSET			;ポインタ移動

	.repeat
		inc	cx		;
		call	A2H8R		;読み込み
		call	CSET		;

		push	cs:[pMML_File]	;
		call	CREAD_L		;
		pop	cs:[pMML_File]	;
	.until	(al == '}')

	push	cs:[pWTD_File]		;
	mov	cs:[pWTD_File],bx	;
	mov	al,cl			;
	call	CSET_L			;
	pop	cs:[pWTD_File]		;

	ret				;
cMCD_lZ		endp
;---------------------------------------------------------------
;	ループ開始点
;---------------------------------------------------------------
.const
cMCD_Loop_Err1	db	"リピート[]のネストが８回を超えました。",0DH,0AH,24h
cMCD_Loop_Err2	db	"リピート開始'['がありません。",0DH,0AH,24h
cMCD_Loop_Err3	db	"リピート終了']'がありません。",0DH,0AH,24h

cMCD_Err_00	db	0DH,0AH,24h
cMCD_Err_01	db	"チャンネル＝",24h
cMCD_Err_02	db	"ポインタ　＝",24h
.code
cMCD_Loop_Start	proc	near	uses ax bx	;

	add	ss:[di].cMCD_LoopCount,2	;ポインタ・インクリメント
	mov	bx,ss:[di].cMCD_LoopCount	
	.if	(bx >= 16)			;ネスト８回超えた？
		mov	dx,offset cMCD_Loop_Err1
		jmp	PRINT_ERR
	.endif
	mov	ax,cs:[pWTD_File]		;ポインタ読み込み。
	mov	ss:[di].cMCD_LoopEnd[bx],ax
	mov	ah,2				;とりあえず、２を書き込み。
	call	cset				;

	ret					;
cMCD_Loop_Start	endp
;---------------------------------------------------------------
;	ループ終了点
;---------------------------------------------------------------
cMCD_Loop_End	proc	near	uses ax bx

	mov	bx,ss:[di].cMCD_LoopCount	;bx ← ポインタ読み込み。
	.if	(bx == -2)
		mov	dx,offset cMCD_Loop_Err2
		jmp	PRINT_ERR
	.endif
	mov	ax,ss:[di].cMCD_LoopEnd[bx]	;ax ← 戻り先アドレス
	inc	ax				;1つ進んだ場所を書き込み。
	call	cset16				;戻りアドレスの書き込み。
	dec	ax				;

	push	cs:[pWTD_File]			;
	mov	cs:[pWTD_File],ax		;
	call	A2H8R				;
	call	CSET				;ループ回数
	pop	cs:[pWTD_File]			;

	mov	ax,ss:[di].cMCD_LoopJump[bx]
	.if	(ax != 0)			;ループアドレス
		push	cs:[pWTD_File]		;
		xchg	ax,cs:[pWTD_File]	;ax ← Loop Break先のアドレス
		call	cset16			;
		pop	cs:[pWTD_File]		;
	.endif
	xor	ax,ax				;ax←0
	mov	ss:[di].cMCD_LoopJump[bx],ax	;
	mov	ss:[di].cMCD_LoopEnd[bx],ax	;
	sub	bx,2				;
	mov	ss:[di].cMCD_LoopCount,bx	;ポインタ書き込み

	ret				;
cMCD_Loop_End	endp
;---------------------------------------------------------------
;	ループ抜け点
;---------------------------------------------------------------
cMCD_Loop_Jump	proc	near	uses ax bx	;

	mov	bx,ss:[di].cMCD_LoopCount	;
	.if	(bx == -2)
		mov	dx,offset cMCD_Loop_Err2
		jmp	PRINT_ERR
	.endif
	mov	ax,cs:[pWTD_File]		;ポインタ読み込み。
	mov	ss:[di].cMCD_LoopJump[bx],ax	;
	call	cset16				;

	ret				;
cMCD_Loop_Jump	endp
;---------------------------------------------------------------
;	転調
;---------------------------------------------------------------
.const
cMCD_trance_Err		db	'{コマンドにて不正な半音記号が指定されました。',0dh,0ah,24h
.code
cMCD_trance	proc	near	uses ax cx

	local	cPara:BYTE

	mov	cPara,000h			;初期化

	call	CREAD_L				;読み込み
	.if	(al == '=')			;■ハ長調 or イ短調 の場合
	   .repeat				;
		call	CREAD_L			;
	   .until	(al == '}')		;}まで進む。

	.else					;■ハ長調 and イ短調 以外の場合
	   .if		((al == '-')||(al == 'b'))
		mov	cPara,080h		;
	   .elseif	((al == '+')||(al == '#'))
	   .else				;
		mov	dx,offset cMCD_trance_Err
		jmp	PRINT_ERR		;
	   .endif				;
	   .repeat				;
		call	CREAD_L			;
		.break	.if	(al == '}')	;
		sub	al,'c'			;
		.if	(carry?)		;
		   add	al,7			;
		.endif				;
		mov	cl,al			;
		mov	al,01h			;
		.if	(cl != 0)		;
		   shl	al,cl			;
		.endif				;
		or	cPara,al		;
	   .until	0			;
	.endif					;

	mov	al,cPara		;
	call	CSET_L			;

	ret
cMCD_trance	endp
;===============================================================|
;			コマンド・コンパイル			|
;===============================================================|
.code
c_Command	proc	near		;パートコンパイル

	local	cMCDinfo:cMCD		;コンパイル情報

	local	iLength:WORD		;音長計算用
	local	cOpcode:BYTE		;Op-Code計算用

	pusha				;レジスタ保存

;パート数読み込み
	xor	cx,cx			;
	mov	cl,byte ptr ds:[0].WTD_Mus_Part

;-----------------------------------------------------------------------
;トラックコンパイル開始

    .repeat				;トラック数繰り返す。

	push	cx			;レジスタ保存

	;---------------
	;メンバー変数・初期設定
	;コンパイル中のチャンネル関連
	xor	ax,ax

	;MMLファイルのポインタを先頭に設定。
	mov	cs:[pMML_File],ax	;
	;チャンネル情報
	mov	cMCDinfo.cMCD_ChannelWTD,ch
	mov	cMCDinfo.cMCD_ChannelMML,0ffh
	;デフォルト音長
	mov	cMCDinfo.cMCD_DefLength,48
	;無限ループアドレス
	mov	cMCDinfo.cMCD_LoopL,ax
	;ループ・マクロ
	mov	cMCDinfo.cMCD_LoopCount,-2
	mov	cMCDinfo.cMCD_MacroCount,-2
	xor	di,di			;
	mov	cx,8
	.repeat
	   mov	cMCDinfo.cMCD_LoopEnd[di],ax
	   mov	cMCDinfo.cMCD_LoopJump[di],ax
	   mov	cMCDinfo.cMCD_MacroAdr[di],ax
	   add	di,2		;
	.untilcxz

	;---------------
	;トラック先頭アドレス保存
	mov	ax,cs:[pWTD_File]	;
	xor	bx,bx			;
	mov	bl,cMCDinfo.cMCD_ChannelWTD
	shl	bx,1			;
	add	bx,WTD_Mus_PartAdr	;
	mov	ds:[bx],ax		;

	;---------------
	;コマンド検索
	;コマンド数量の読み込み
	;EOFまで繰り返す。
	.repeat

		mov	ah,cMCDinfo.cMCD_ChannelMML
		mov	al,cMCDinfo.cMCD_ChannelWTD
		.if	(al != ah)		;チャンネルが一致しなかったら、
		  call	cMCD_CRS		;改行を探す。
		.endif

		xor	di,di			;di←変換定義アドレスのポインタ
		mov	cx,cs:[offset c_Command_Adrs + di]

		;コマンドの数だけ繰り返す。
		.repeat
		   push	cs:[pMML_File]			;ポインタ保存
		   add	di,2				;ポインタインクリメント(Word)
		   mov	si,cs:[offset c_Command_Adrs + di]	;si←変換定義アドレス
		   ;１文字読み込み
		   .repeat
			call	cread			;MMLファイルから１文字読み込み
			lodsb	cs:[si]			;１文字チェック（00h含む）
		   .until	(al != ah)		;文字一致ならば、次もチェック。
		   .if		(al == 00h)		;文字終了？
			;コマンド処理。
			pop	ax			;'pMML_File'ポインタの復帰(値は戻さず)
			dec	cs:[pMML_File]		;ポインタを元に戻す。

			;バージョン比較
			lodsw	cs:[si]			;
			mov	cx,ds:[0].WTD_Mus_Version
			xchg	ah,al			;逆に入っている。
			xchg	ch,cl			;(80形式ではないWord)
			.if	(cx < ax)		;比較。
			  xchg	ah,al			;このコマンドのバージョンの方が
			  mov	ds:[0].WTD_Mus_Version,ax
			.endif				;高ければ、数値セット。

			;コマンド出力
			.repeat
			  lodsb	cs:[si]			;al←コマンド
			  .break  .if	(al == 0)	;０ならば終了。
			  mov	ah,al			;
			  call	CSET			;
			.until	0			;

			;コマンド処理
			.repeat
			    lodsb	cs:[si]			;al←コマンド
			   ;------------------------------------
			   .break .if	(al == 000h)		;０ならば終了。
			   ;------------------------------------
			   .if		(al == 010h)		;4bit × 2
				call	A2H8R			;
				and	ah,0fh			;
				mov	al,ah			;
				call	A2H8R			;
				and	ah,0fh			;
				shl	ah,4			;
				or	ah,al			;
				call	cset			;
			   ;------------------------------------
			   .elseif	(al == 011h)		;Byte
				call	A2H8R			;
				call	CSET			;
			   ;------------------------------------
			   .elseif	(al == 012h)		;Word
				call	A2H16R			;
				call	CSET16			;
			   ;------------------------------------
			   .elseif	(al == 020h)		;Step 書き込み
				call	cread			;
				mov	cl,ah			;cl ← 1文字読み込み。
				dec	cs:[pMML_File]		;(ポインタは、ずらさない。)
				call	A2H16R			;
				xchg	ax,cx			;cx←音長を保存。
				.if	(al != '%')		;数値の前に'%'が書いてある？
				  xor	dx,dx			;
				  xor	ax,ax			;
				  mov	al,ds:[0].WTD_Mus_TimeBase
				  shl	ax,2			;dx:ax←４部音符の分割数。
				  div	cx			;
				  mov	cx,ax			;cx←Step数。
				.endif				;
				lodsb	cs:[si]			;al←コマンド
				.if	(al == 01h)		;
				  mov	cMCDinfo.cMCD_DefLength,cx
				.endif				;
				.if	(cx < 0FFh)		;
				  mov	ah,cl			;
				  call	cset			;
				.else				;
				  mov	ah,0ffh			;
				  call	cset			;
				  mov	ax,cx			;
				  call	cset16			;
				.endif				;
			   ;------------------------------------
			   .elseif	((al >= 080h) && (al < 88h))
				mov	cOpcode,al		;コマンドの保存。
				mov	dx,cMCDinfo.cMCD_DefLength
				mov	iLength,dx		;iLength←デフォルト音長。
				;-------
				;臨時記号の処理
				call	CREAD_L			;読み込み。
				.if	((al == '#')||(al == '+'))
					or	cOpcode,008h	;
					call	CREAD_L		;読み込み。
				.elseif	(al == '-')
					or	cOpcode,010h	;
					call	CREAD_L		;読み込み。
				.elseif	(al == '=')
					or	cOpcode,018h	;
					call	CREAD_L		;読み込み。
				.endif

				;-------
				;音長（数字）の処理
				.if	((al == '%') || ((al >= '0')&&(al <= '9')))
				  mov	cx,ax			;cl ← 文字読み込み結果
				  dec	cs:[pMML_File]		;(ポインタを戻す)
				  call	A2H16R			;ax ← 音長
				  .if	((ax != 0) && (cl != '%'))
					mov	cx,ax		;cx ← 音長
					xor	dx,dx		;
					xor	ax,ax		;dx:ax = WTD_Mus_TimeBase
					mov	al,ds:[0].WTD_Mus_TimeBase
					shl	ax,2		;dx:ax←４部音符の分割数。
					div	cx		;ax←Step数。
				  .endif
				  mov	iLength,ax		;
				  mov	dx,ax			;dx←音長
				  call	CREAD_L			;読み込み。
				.endif

				;-------
				;音長（付点）の処理
				.while	(al == '.')
					shr	iLength,1	;
					add	dx,iLength	;
					call	CREAD_L		;読み込み。
				.endw
				dec	cs:[pMML_File]		;(ポインタは、ずらさない。)

				;-------
				;タイ・スラーの処理
				.if	(al == '&')
					or	cOpcode,020h	;
				.endif

				;-------
				;音長は、lコマンドの指定値と同じ？
				.if	(dx != cMCDinfo.cMCD_DefLength)
					or	cOpcode,040h	;
				.endif

				;-------
				;コマンドを書き込み
				mov	al,cOpcode		;
				call	CSET_L			;書き込み。
				.if	(cOpcode & 040h)
				   .if	(dx < 00FFh)
					mov	al,dl		;
					call	cset_L		;
				   .else
					mov	al,0ffh		;
					call	cset_l		;
					mov	ax,dx		;
					call	cset16		;
				   .endif
				.endif
			   ;------------------------------------
			   .elseif	(al == 0F0h)		;Call (Other Program)
				push	di			;引数（レジスタ渡し）として、
				lea	di,cMCDinfo		;ss:di ← "cMCDinfo"のポインタ
				lodsw	cs:[si]			;
				call	ax			;関数呼び出し
				pop	di			;
			   .endif
			   ;------------------------------------
			.until	0			;コンパイル処理ループ
			dec	cs:[pMML_File]		;命令コンパイル処理終了
			.break				;命令デコード終了
		   .else
			;文字チェックで一致しなかった場合。
			pop	cs:[pMML_File]	;ポインタ復帰
		   .endif
		   dec	cx
		.until	(zero?)			;次のコマンドで比較
		inc	CS:[pMML_File]		;ポインタ・インクリメント
		mov	ax,CS:[szMML_File]	;
	.until	(ax < CS:[pMML_File])		;MMLファイルが[EOF]ならば終了
;-----------------------------------------------------------------------
;トラック終了

	;エラーチェック
	.if	(cMCDinfo.cMCD_LoopCount != -2)		;
		mov	dx,offset cMCD_Loop_Err3	;
		jmp	PRINT_ERR			;リピート命令 '[' を ']' で閉じてるか？
	.endif

	;トラック終了の書き込み
	mov	ah,'L'			;
	call	cset			;
	mov	ax,cMCDinfo.cMCD_LoopL	;
	call	cset16			;

	pop	cx			;
	inc	ch			;
	dec	cl			;
    .until	(zero?)

;-----------------------------------------------------------------------
;終了
	popa				;レジスタ復帰
	ret				;
c_Command	endp
