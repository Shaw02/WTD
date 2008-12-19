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
;		命令定義　（コンパイル情報）			|
;===============================================================|
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
;---------------------------------------------------------------
c_Command_Data:
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
;===============================================================
c_Command_Adrs:				;コマンド・データのアドレス。
	dw	84			;数量
	dw	offset cMCD_0		;<CR+LF>+"C"
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
	dw	offset cMCD_83		;{	
;===============================================================
;現在コンパイル中のチャンネル。
cMCD_ChannelWTD	db	?		;コンパイル中の。
cMCD_ChannelMML	db	?		;ＭＭＬ中の。
cMCD_MacroCount	dw	-2		;マクロのスタックポインタ
cMCD_MacroAdr	dw	8	dup(0)	;マクロのスタックエリア
;無限ループアドレス
cMCD_LoopL	dw	0000h		;
;音長'l'
dMCD_lengs	dw	48		;
;ループ
cMCD_LoopCount	dw	-2		;
cMCD_LoopEnd	dw	8	dup(0)	;
cMCD_LoopJump	dw	8	dup(0)	;

;===============================================================

;---------------------------------------------------------------
;改行の直前までポインタを進める
;---------------------------------------------------------------
cMCD_CRS:				;Serach
	pusha				;改行検査から実行する。
	jmp	cMCD_CR_Loop		;

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
cMCD_CR:
	call	cMCD_MacroEndChk	;マクロ中かチェック＆マクロ終了。
	jc	cMCD_CR_EndM		;マクロ中だったら、cy='H'

	;-------
	;マクロ中じゃなかった場合	;スペース or 制御文字であるかチェックし、
	pusha				;そうでなかったら、改行検査を行う。
	call	CREAD			;
	cmp	ah,21h			;制御文字であるか？
	jc	cMCD_CR_Step		;それ以外だったら、改行検査から。

cMCD_CR_Loop:				;改行検査
	call	CREAD			;
	jc	cMCD_CR_End		;ファイル終了だったら、終わり。
	cmp	ah,0dh			;（このとき、ポインタは改行の次。）
	jnz	cMCD_CR_Loop		;改行があった。

;ポインタを改行直前に戻す。
cMCD_CR_Step:				;
	dec	cs:[pMML_File]		;
;終了
cMCD_CR_End:				;
	popa				;レジスタ復帰

cMCD_CR_EndM:				;
	ret				;
;---------------------------------------------------------------
;
;---------------------------------------------------------------
cMCD_CH:				;チャンネル設定
	call	cMCD_MacroEndChk	;マクロの終了かどうかをチェック
	jc	cMCD_CH_EndM		;
	pusha				;

	mov	ah,0ffh			;ダミーの設定
	mov	cs:[cMCD_ChannelMML],ah	;保存
cMCD_CH_Loop:				;
	call	A2H8R			;読み込み

	cmp	ah,cs:[cMCD_ChannelWTD]	;比較
	jnz	cMCD_CH_Step		;
	call	cMCD_CH_Set		;同じだったら設定。
cMCD_CH_Step:				;

	call	CREAD			;カンマがあったら、
	cmp	ah,','			;トラックの複数指定。
	jz	cMCD_CH_Loop		;

;終了
cMCD_CH_End:
	popa				;レジスタ復帰
cMCD_CH_EndM:				;
	ret				;
cMCD_CH_Set:
	mov	cs:[cMCD_ChannelMML],ah	;保存
	ret

;---------------------------------------------------------------
;	マクロ呼び出し
;---------------------------------------------------------------
cMCD_Macro	proc	near		;マクロ

	local	ptMacroSearch:word	;ポインタ

;	call	cMCD_MacroEndChk	;マクロの終了かどうかをチェック
;	jc	cMCD_Macro_EndM		;

;●レジスタの保存
	pusha				;

;●マクロ名の取得
	xor	bx,bx			;
	call	CREAD			;
	mov	bl,ah			;bl←マクロ文字
	push	cs:[pMML_File]		;
	call	CREAD			;
	pop	cs:[pMML_File]		;ah←引数先頭文字
	cmp	ah,30h			;
	jc	cMCD_Macro_Step0	;
	cmp	ah,3Ah			;
	jnc	cMCD_Macro_Step0	;数字じゃなかったら、0固定！
	call	A2H8R			;
	mov	bh,ah			;bh←マクロ引数
					;bxで、マクロ番号（文字と番号）

;●マクロの検索
cMCD_Macro_Step0:			;
	mov	dx,cs:[pMML_File]	;dx←MMLのポインタ（保存）
	mov	ptMacroSearch,0		;ポインタを先頭に
cMCD_Macro_Loop0:			;
	mov	ax,ptMacroSearch	;今のポインタ
	mov	cs:[pMML_File],ax	;
	call	cread			;
	jnc	cMCD_Macro_Step1	;EOFになったら、
	jmp	MACRO_ERROR		;存在しないマクロの呼び出し

cMCD_Macro_Step1:			;
	inc	ptMacroSearch		;サーチポインタをインクリメント

	cmp	ah,0dh			;
	jnz	cMCD_Macro_Loop0	;

	call	cread			;
	cmp	ah,0ah			;
	jnz	cMCD_Macro_Loop0	;

	call	cread			;
	cmp	ah,'$'			;CR+LF+'$'があるかを、先ずチェック
	jnz	cMCD_Macro_Loop0	;

	call	CREAD			;
	mov	cl,ah			;cl←マクロ文字
	push	cs:[pMML_File]		;ポインタ復帰
	mov	ch,0			;
	call	CREAD			;
	pop	cs:[pMML_File]		;ポインタ復帰
	cmp	ah,30h			;
	jc	cMCD_Macro_Step2	;
	cmp	ah,3Ah			;
	jnc	cMCD_Macro_Step2	;
	call	A2H8R			;
	mov	ch,ah			;ch←番号
cMCD_Macro_Step2:			;
	cmp	bx,cx			;
	jnz	cMCD_Macro_Loop0	;

;●マクロ
	add	cs:[cMCD_MacroCount],2	;
	mov	bx,cs:[cMCD_MacroCount]	;マクロのポインタ
	cmp	bx,16			;
	jc	cMCD_Macro_Step3	;マクロを呼びすぎ。
	jmp	MACRO_ERROR2		;
cMCD_Macro_Step3:			;
	mov	cs:[cMCD_MacroAdr + bx],dx	;復帰時のポインタ

;●レジスタの復帰
	popa				;レジスタ復帰
cMCD_Macro_EndM:			;
	ret				;
cMCD_Macro	endp
;---------------------------------------------------------------
;	マクロ中かチェック＆マクロの終了
;---------------------------------------------------------------
;	◆返値
;		cy='L'	マクロ中じゃない。そのままリターン
;		cy='H'	マクロを終了した。
;			cs:[pMML_File]	元のポインタ
;---------------------------------------------------------------
cMCD_MacroEndChk	proc	near
	pusha				;

	cmp	cs:[cMCD_MacroCount],-2	;マクロのスタックは空？
	jz	cMCD_MacroEndChk_End	;空だったら、終了

	mov	bx,cs:[cMCD_MacroCount]	;マクロのポインタ
	sub	cs:[cMCD_MacroCount],2	;
	mov	ax,cs:[cMCD_MacroAdr + bx]
	mov	cs:[pMML_File],ax	;

	stc				;Cy←'h'
cMCD_MacroEndChk_End:			;
	popa				;レジスタ復帰
	ret				;

cMCD_MacroEndChk	endp
;---------------------------------------------------------------
;	パンポット
;---------------------------------------------------------------
cMCD_sp:				;
	pusha				;

	push	cs:[pMML_File]		;
	call	CREAD			;%があったら、
	pop	cs:[pMML_File]		;
	cmp	ah,'%'			;
	jz	cMCD_sp_2		;

cMCD_sp_1:				;------------------
	call	A2H8R			;%が無かった場合
	call	CSET			;
	jmp	cMCD_sp_3		;

cMCD_sp_2:				;------------------
	call	A2H8R			;%があった場合
	cmp	ah,32			;
	jc	cMCD_sp_21		;
	mov	ah,127			;もし32以上だったら127
	jmp	cMCD_sp_22		;
cMCD_sp_21:				;
	mov	al,ah			;
	mov	ah,4			;
	mul	ah			;それ以外は４倍にする。
	mov	ah,al			;
cMCD_sp_22:				;
	call	CSET			;
;	jmp	cMCD_sp_3		;

cMCD_sp_3:				;------------------
	push	cs:[pMML_File]		;
	call	CREAD			;カンマがあったら、
	pop	cs:[pMML_File]		;
	cmp	ah,','			;
	jnz	cMCD_sp_end		;

	call	A2H8R			;引数を読む
	cmp	ah,1			;
	jc	cMCD_sp_end		;

	push	bx			;ビットセット
	mov	bx,CS:[pWTD_File]	;
	dec	bx			;
	or	byte ptr ds:[bx],80h	;
	pop	bx			;

cMCD_sp_end:				;------------------
	popa				;終了
	ret				;

;---------------------------------------------------------------
;	音量
;---------------------------------------------------------------
cMCD_sv:				;
	pusha				;

	push	cs:[pMML_File]		;
	call	CREAD			;%があったら、
	pop	cs:[pMML_File]		;
	cmp	ah,'%'			;
	jz	cMCD_sv_2		;

cMCD_sv_1:				;------------------
	call	A2H8R			;%が無かった場合
	call	CSET			;
	jmp	cMCD_sv_3		;

cMCD_sv_2:				;------------------
	call	A2H8R			;%があった場合
	cmp	ah,16			;
	jc	cMCD_sv_21		;
	mov	ah,127			;もし16以上だったら127
	jmp	cMCD_sv_22		;
cMCD_sv_21:				;
	mov	al,ah			;
	mov	ah,8			;
	mul	ah			;それ以外は8倍にする。
	mov	ah,al			;
cMCD_sv_22:				;
	call	CSET			;
;	jmp	cMCD_sv_3		;

cMCD_sv_3:				;------------------
	popa				;
	ret				;

;---------------------------------------------------------------
;	テンポ
;---------------------------------------------------------------
cMCD_st:
	pusha				;

	push	cs:[pMML_File]		;
	call	CREAD			;%があったら、
	pop	cs:[pMML_File]		;
	cmp	ah,'%'			;
	jnz	cMCD_st_2		;

cMCD_st_1:				;------------------
	call	A2H16R			;cx←Tempo
	jmp	cMCD_st_3		;

cMCD_st_2:				;------------------
;数値読み込み				;■従来
	call	A2H16R			;cx←Tempo
	mov	cx,ax			;
	xor	bx,bx			;bx←TimeBase
	mov	bl,ds:[0].WTD_Mus_TimeBase

;演算
	mov	dx,0000ah		;
	mov	ax,0fc80h		;
	div	bx			;
	xor	dx,dx			;
	div	cx			;ax←12000 * 60 / (Tempo * TimeBase)
;	jmp	cMCD_st_3		;

cMCD_st_3:				;------------------
;書き込み
	call	CSET16			;

;終了
	popa				;
	ret				;

;---------------------------------------------------------------
;	ピッチベンド
;---------------------------------------------------------------
cMCD_lB:				;'B'コマンド
	push	ax			;
	
	call	A2H16R			;
	call	CSET16			;

	push	cs:[pMML_File]		;
	call	CREAD			;カンマがあったら、
	pop	cs:[pMML_File]		;
	cmp	ah,','			;ベンドレンジ
	jnz	cMCD_lB_End		;

	push	bx			;ビットセット
	mov	bx,CS:[pWTD_File]	;
	dec	bx			;
	dec	bx			;
	or	word ptr ds:[bx],8000h	;
	pop	bx			;

	call	A2H8R			;
	call	CSET			;


cMCD_lB_End:				;
	pop	ax			;
	ret				;

;---------------------------------------------------------------
;	無限ループのポインタセット
;---------------------------------------------------------------
cMCD_lL:				;'L'コマンド
	push	ax			;
	
	mov	ax,cs:[pWTD_File]	;
	mov	cs:[cMCD_LoopL],ax	;
	
	pop	ax			;アドレスの保存
	ret				;

;---------------------------------------------------------------
;	エクスクルーシブ
;---------------------------------------------------------------
cMCD_lX_CRC	db	?		;
cMCD_lX_Flag	db	?		;
cMCD_lX:				;'X'コマンド
	pusha				;

	mov	cs:[cMCD_lX_CRC],0	;CRCを0x00にする。
	mov	cs:[cMCD_lX_Flag],0	;Flagを0x00にする。

	mov	ah,0f0h			;エクスクルーシブ開始
	call	cset			;

cMCD_lX_Loop:				;
	push	cs:[pMML_File]		;
	call	CREAD			;
	pop	cs:[pMML_File]		;
	cmp	ah,'}'			;
	jz	cMCD_lX_StepEnd		;
	cmp	ah,'('			;
	jnz	cMCD_lX_Step0		;
	mov	cs:[cMCD_lX_Flag],1	;Flagを0x01にする。
cMCD_lX_Step0:				;
	cmp	ah,')'			;
	jnz	cMCD_lX_Step1		;
	mov	cs:[cMCD_lX_Flag],0	;Flagを0x00にする。
	push	ax			;
	mov	cl,cs:[cMCD_lX_CRC]	;
	and	cl,07fh			;
	mov	al,128			;
	sub	al,cl			;
	mov	ah,al			;
	call	CSET			;CRCの出力
	pop	ax			;
cMCD_lX_Step1:				;
	cmp	ah,030h			;
	jc	cMCD_lX_Step9		;
	cmp	ah,03ah			;
	jnc	cMCD_lX_Step9		;
	call	A2H8R			;読み込み
	call	CSET			;
	cmp	cs:[cMCD_lX_Flag],1	;
	jnz	cMCD_lX_Step2		;
	add	cs:[cMCD_lX_CRC],ah	;
cMCD_lX_Step2:				;
	jmp	cMCD_lX_Loop		;
cMCD_lX_Step9:				;
	inc	cs:[pMML_File]		;
	jmp	cMCD_lX_Loop		;

cMCD_lX_StepEnd:			;
	mov	ah,0f7h			;エクスクルーシブ終了
	call	cset			;

	popa				;
	ret				;

;---------------------------------------------------------------
;	MIDIイベント直書き込み
;---------------------------------------------------------------
cMCD_lZ:				;'Z'コマンド
	pusha				;

	mov	dx,cs:[pWTD_File]	;
	xor	cx,cx			;
	call	CSET			;ポインタ移動

cMCD_lZ_Loop:				;
	inc	cx			;
	call	A2H8R			;読み込み
	call	CSET			;

	push	cs:[pMML_File]		;
	call	CREAD			;
	pop	cs:[pMML_File]		;
	cmp	ah,'}'			;
	jnz	cMCD_lZ_Loop		;

	push	cs:[pWTD_File]		;
	mov	cs:[pWTD_File],dx	;
	mov	ah,cl			;
	call	CSET			;
	pop	cs:[pWTD_File]		;

	popa				;
	ret				;

;---------------------------------------------------------------
;	ループ開始点
;---------------------------------------------------------------
cMCD_Loop_Start:			;
	push	ax			;
	push	bx			;

	add	cs:[cMCD_LoopCount],2	;ポインタ・インクリメント

	cmp	cs:[cMCD_LoopCount],18	;ネスト８回超えた？
	jc	cMCD_Loop_Start_Step1	;
	jmp	LOOP_ERROR		;そしたら、エラー。
cMCD_Loop_Start_Step1:			;
	mov	ax,cs:[pWTD_File]	;ポインタ読み込み。
	mov	bx,cs:[cMCD_LoopCount]	;

	mov	cs:[cMCD_LoopEnd + bx],ax

	mov	ah,2			;とりあえず、２を書き込み。
	call	cset			;

	pop	bx			;
	pop	ax			;
	ret				;

;---------------------------------------------------------------
;	ループ終了点
;---------------------------------------------------------------
cMCD_Loop_End:				;
	push	ax			;
	push	bx			;

	mov	bx,cs:[cMCD_LoopCount]	;ポインタ読み込み。

	mov	ax,cs:[cMCD_LoopEnd + bx]
	inc	ax			;1つ進んだ場所を書き込み。
	call	cset16			;戻りアドレスの書き込み。
	dec	ax			;

	push	cs:[pWTD_File]		;
	mov	cs:[pWTD_File],ax	;
	call	A2H8R			;
	call	CSET			;ループ回数
	pop	cs:[pWTD_File]		;

	mov	ax,cs:[cMCD_LoopJump + bx]
	cmp	ax,0			;ループアドレス
	jz	cMCD_Loop_End_End	;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	mov	cx,cs:[pWTD_File]	;Loop Jump

	push	cs:[pWTD_File]		;
	mov	cs:[pWTD_File],ax	;
	mov	ax,cx			;
	call	cset16			;
	pop	cs:[pWTD_File]		;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
cMCD_Loop_End_End:			;
	xor	ax,ax			;ax←0
	mov	cs:[cMCD_LoopJump + bx],ax
	mov	cs:[cMCD_LoopEnd + bx],ax
	sub	bx,2			;
	mov	cs:[cMCD_LoopCount],bx	;ポインタ書き込み

	pop	bx			;
	pop	ax			;
	ret				;

;---------------------------------------------------------------
;	ループ抜け点
;---------------------------------------------------------------
cMCD_Loop_Jump:				;
	push	ax			;
	push	bx			;

	mov	ax,cs:[pWTD_File]	;ポインタ読み込み。
	mov	bx,cs:[cMCD_LoopCount]	;

	mov	cs:[cMCD_LoopJump + bx],ax

	call	cset16			;

	pop	bx			;
	pop	ax			;
	ret				;

;---------------------------------------------------------------
;	転調
;---------------------------------------------------------------
cMCD_tranceFlag	db	00h
cMCD_trance:
	pusha				;レジスタ保存

	mov	bx,offset cMCD_tranceFlag
	call	CREAD			;読み込み
	cmp	ah,'='			;
	jz	cMCD_tranceNatu		;
	cmp	ah,'+'			;
	jz	cMCD_tranceSharp	;
	cmp	ah,'#'			;
	jz	cMCD_tranceSharp	;
	cmp	ah,'-'			;
	jz	cMCD_tranceFlat		;
	cmp	ah,'b'			;
	jz	cMCD_tranceFlat		;
cMCD_tranceLoop:
	call	CREAD			;
	cmp	ah,'}'			;
	jz	cMCD_tranceEnd		;
	sub	ah,'c'			;
	jnc	cMCD_tranceStep0	;
	add	ah,7			;
cMCD_tranceStep0:			;
	mov	cl,ah			;
	mov	al,01h			;
	cmp	cl,0			;
	jz	cMCD_tranceStep1	;
	shl	al,cl			;
cMCD_tranceStep1:			;
	or	cs:[cMCD_tranceFlag],al	;
	jmp	cMCD_tranceLoop		;

cMCD_tranceSharp:				;
	mov	cs:[cMCD_tranceFlag],000h	;初期化
	jmp	cMCD_tranceLoop			;

cMCD_tranceFlat:				;
	mov	cs:[cMCD_tranceFlag],080h	;初期化
	jmp	cMCD_tranceLoop			;

cMCD_tranceNatu:				;
	mov	cs:[cMCD_tranceFlag],000h	;初期化
cMCD_tranceNatuLoop:
	call	CREAD			;
	cmp	ah,'}'			;}まで進む。
	jnz	cMCD_tranceNatuLoop	;
;	jmp	cMCD_tranceEnd		;

cMCD_tranceEnd:
	mov	ah,cs:[cMCD_tranceFlag]	;
	call	CSET			;

	popa				;レジスタ復帰
	ret

;===============================================================|
;			コマンド・コンパイル			|
;===============================================================|
c_Command:				;パートコンパイル
	pusha				;レジスタ保存

;パート数読み込み
	xor	cx,cx			;
	mov	cl,byte ptr ds:[0].WTD_Mus_Part

;-----------------------------------------------------------------------
;トラックコンパイル開始
c_Command_Loop0:

	push	cx			;レジスタ保存

;初期設定
;コンパイル中のチャンネル関連
	mov	byte ptr cs:[cMCD_ChannelMML],0ffh
	mov	byte ptr cs:[cMCD_ChannelWTD],ch
;無限ループアドレス
	mov	word ptr cs:[cMCD_LoopL],0000h
;音長
	mov	word ptr cs:[dMCD_lengs],48
;ループ
	mov	word ptr cs:[cMCD_LoopCount],0
	mov	bx,14			;
c_Command_Loop6:
	mov	word ptr cs:[cMCD_LoopEnd+bx],0
	mov	word ptr cs:[cMCD_LoopJump+bx],0
	sub	bx,2			;
	jnc	c_Command_Loop6		;

;MMLファイルの先頭にいく。
	xor	bx,bx			;
	mov	cs:[pMML_File],bx	;bx
;トラック先頭アドレス保存
	mov	ax,cs:[pWTD_File]	;
	mov	bl,byte ptr cs:[cMCD_ChannelWTD]
	shl	bx,1			;
	add	bx,WTD_Mus_PartAdr	;
	mov	ds:[bx],ax		;

;コマンド検索
;コマンド数量の読み込み
c_Command_Loop1:			;

;チャンネルが一致しなかったら、改行を探す。
	mov	ah,cs:[cMCD_ChannelMML]	;
	mov	al,cs:[cMCD_ChannelWTD]	;
	cmp	al,ah			;比較
	jz	c_Command_Step0		;チャンネルが一致しなかったら、
	call	cMCD_CRS		;改行を探す。
c_Command_Step0:			;

	xor	di,di			;di←変換定義アドレスのポインタ
	mov	cx,cs:[offset c_Command_Adrs + di]
					;文字列チェックのカウンタ
;ポインタ読み込み
c_Command_Loop2:			;
	push	cs:[pMML_File]		;ポインタ保存
	add	di,2			;ポインタインクリメント(Word)
	mov	si,cs:[offset c_Command_Adrs + di]	;si←変換定義アドレス
;１文字読み込み
c_Command_Loop3:			;
	call	cread			;MMLファイルから１文字読み込み
	jnc	c_Command_Step1		;
	pop	cs:[pMML_File]		;ポインタ復帰
	jmp	c_Command_End		;MMLファイルが[EOF]ならば終了
c_Command_Step1:			;
;１文字チェック（00h含む）
	mov	al,cs:[si]		;
	inc	si			;
	cmp	al,00h			;文字終了？
	jz	c_Command_Step2		;ならば、文字列一致で処理実行。
	cmp	ah,al			;文字一致？
	jz	c_Command_Loop3		;ならば、次もチェック。
;文字チェックで一致しなかった場合。
	pop	cs:[pMML_File]		;ポインタ復帰
	sub	cx,1			;カウンター・ディクリメント
	jnz	c_Command_Loop2		;次のコマンドで比較
	inc	CS:[pMML_File]		;ポインタ・インクリメント
	mov	ax,CS:[szMML_File]	;
	cmp	ax,CS:[pMML_File]	;MMLファイルの終了チェック
	jnc	c_Command_Loop1		;文字列比較開始。
	jmp	c_Command_End		;MMLファイルが[EOF]ならば終了
;-----------------------------------------------------------------------
;コマンド処理。
c_Command_Step2:			;
	pop	ax			;'pMML_File'ポインタの復帰(値は戻さず)
	push	ds			;セグメントの保存

;バージョン比較
	mov	ax,cs:[si]		;
	add	si,2			;バージョン読み込み
	mov	cx,ds:[0].WTD_Mus_Version
	xchg	ah,al			;逆に入っている。
	xchg	ch,cl			;(80形式ではないWord)
	cmp	cx,ax			;比較。
	jnc	c_Command_Step10	;
	xchg	ah,al			;このコマンドのバージョンの方が
	mov	ds:[0].WTD_Mus_Version,ax
c_Command_Step10:			;高ければ、数値セット。

;コマンド出力
c_Command_Loop5:			;
	mov	ah,cs:[si]		;al←コマンド
	inc	si			;
	cmp	ah,0			;０ならば終了。
	jz	c_Command_Step11	;
	call	CSET			;
	jmp	c_Command_Loop5		;
c_Command_Step11:

;ポインタを元に戻す。
	dec	cs:[pMML_File]		;ポインタ・ディクリメント

;コマンド処理
c_Command_Loop4:			;
	mov	al,cs:[si]		;al←コマンド
	inc	si			;
	cmp	al,00h			;終了
	jnz	c_Command_Step3		;
	jmp	c_Command_Step99	;
c_Command_Step3:			;
	cmp	al,010h			;4bit × 2
	jnz	c_Command_Step4		;
	call	A2H8R			;
	and	ah,0fh			;
	mov	al,ah			;
	call	A2H8R			;
	and	ah,0fh			;
	shl	ah,4			;
	or	ah,al			;
	call	cset			;
	jmp	c_Command_Loop4		;
c_Command_Step4:			;
	cmp	al,011h			;Byte
	jnz	c_Command_Step5		;
	call	A2H8R			;
	call	CSET			;
	jmp	c_Command_Loop4		;
c_Command_Step5:			;
	cmp	al,012h			;Word
	jnz	c_Command_Step6		;
	call	A2H16R			;
	call	CSET16			;
	jmp	c_Command_Loop4		;
c_Command_Step6:			;
	cmp	al,020h			;Step
	jnz	c_Command_Step7		;
	call	cread			;1文字読み込み。
	dec	cs:[pMML_File]		;(ポインタは、ずらさない。)
	xchg	ax,cx			;
	call	A2H16R			;cx←音長
	xchg	ax,cx			;
	cmp	ah,'%'			;数値の前に'%'が書いてある？
	mov	ax,cx			;ax←数値を保存。
	jz	c_Command_Step6_Step1	;
	xor	ax,ax			;
	mov	al,ds:[0].WTD_Mus_TimeBase
	shl	ax,2			;dx:ax←４部音符の分割数。
	xor	dx,dx			;
	div	cx			;ax←Step数。
c_Command_Step6_Step1:			;
	mov	cl,cs:[si]		;al←コマンド
	inc	si			;
	cmp	cl,01h			;
	jnz	c_Command_Step6_Step3	;
	mov	cs:[dMCD_lengs],ax	;
c_Command_Step6_Step3:			;
	cmp	ax,00FFh		;
	jnc	c_Command_Step6_Step2	;
	mov	ah,al			;
	call	cset			;
	jmp	c_Command_Loop4		;
c_Command_Step6_Step2:			;
	push	ax			;
	mov	ah,0ffh			;
	call	cset			;
	pop	ax			;
	call	cset16			;
	jmp	c_Command_Loop4		;
c_Command_Step7:			;
	cmp	al,080h			;Key
	jc	c_Command_Step8		;
	cmp	al,088h			;al←Command
	jnc	c_Command_Step8		;
	call	c_Command_KeyCode	;
	jmp	c_Command_Loop4		;
c_Command_Step8:			;
	cmp	al,0F0h			;Call (Other Program)
	jnz	c_Command_Step9		;
	mov	dx,cs:[si]		;
	add	si,2			;
	call	dx			;
	jmp	c_Command_Loop4		;
c_Command_Step9:			;

;コンパイル処理ループ
	jmp	c_Command_Loop4		;

;命令コンパイル処理終了
c_Command_Step99:			;
	pop	ds			;セグメントの復帰
	jmp	c_Command_Loop1		;文字列比較開始。
;-----------------------------------------------------------------------
;トラック終了
c_Command_End:

;トラック終了の書き込み
	mov	ah,'L'			;
	call	cset			;
	mov	ax,word ptr cs:[cMCD_LoopL]
	call	cset16			;

	pop	cx			;

	inc	ch			;
	sub	cl,1			;
	jz	c_Command_End99		;
	jmp	c_Command_Loop0		;

;-----------------------------------------------------------------------
;終了
c_Command_End99:			;
	popa				;レジスタ復帰
	ret				;
;=======================================================================
;音階
;	al←Command Code
;	dx←
cCKD_Key	db	?		;Key
cCKD_lengs	dw	?		;lengs
c_Command_KeyCode:
	pusha				;

	mov	dx,cs:[dMCD_lengs]	;dx←初期の音階。
	mov	cs:[cCKD_lengs],dx	;
	mov	byte ptr cs:[cCKD_Key],al	;コマンドの保存。
	call	CREAD			;読み込み。
	dec	cs:[pMML_File]		;(ポインタはずらさず。)

	cmp	ah,'#'			;
	jnz	c_Command_KeyCode_Step1	;
	or	byte ptr cs:[cCKD_Key],008h	;
	inc	cs:[pMML_File]		;
	call	CREAD			;読み込み。
	dec	cs:[pMML_File]		;(ポインタはずらさず。)
	jmp	c_Command_KeyCode_Step7	;
c_Command_KeyCode_Step1:		;
	cmp	ah,'+'			;
	jnz	c_Command_KeyCode_Step2	;
	or	byte ptr cs:[cCKD_Key],008h	;
	inc	cs:[pMML_File]		;
	call	CREAD			;読み込み。
	dec	cs:[pMML_File]		;(ポインタはずらさず。)
	jmp	c_Command_KeyCode_Step7	;
c_Command_KeyCode_Step2:		;
	cmp	ah,'-'			;
	jnz	c_Command_KeyCode_Step3	;
	or	byte ptr cs:[cCKD_Key],010h	;
	inc	cs:[pMML_File]		;
	call	CREAD			;読み込み。
	dec	cs:[pMML_File]		;(ポインタはずらさず。)
	jmp	c_Command_KeyCode_Step7	;
c_Command_KeyCode_Step3:
	cmp	ah,'='			;
	jnz	c_Command_KeyCode_Step7	;
	or	byte ptr cs:[cCKD_Key],018h	;
	inc	cs:[pMML_File]		;
	call	CREAD			;読み込み。
	dec	cs:[pMML_File]		;(ポインタはずらさず。)
;	jmp	c_Command_KeyCode_Step7	;
c_Command_KeyCode_Step7:		;
	cmp	ah,'%'			;
	jz	c_Command_KeyCode_Step7_Step1
	cmp	ah,30h			;
	jc	c_Command_KeyCode_Step4	;
	cmp	ah,3Ah			;
	jnc	c_Command_KeyCode_Step4	;
c_Command_KeyCode_Step7_Step1:		;
	call	cread			;1文字読み込み。
	dec	cs:[pMML_File]		;(ポインタは、ずらさない。)
	xchg	ax,cx			;
	call	A2H16R			;cx←音長
	dec	cs:[pMML_File]		;(ポインタは、ずらさない。)
	or	ax,ax			;音長が0だったら、演算なし。
	jz	c_Command_KeyCode_Step7_Step2
	xchg	ax,cx			;
	cmp	ah,'%'			;数値の前に'%'が書いてある？
	mov	ax,cx			;ax←数値を保存。
	jz	c_Command_KeyCode_Step7_Step2
	xor	ax,ax			;
	mov	al,ds:[0].WTD_Mus_TimeBase
	shl	ax,2			;dx:ax←４部音符の分割数。
	xor	dx,dx			;
	div	cx			;ax←Step数。
c_Command_KeyCode_Step7_Step2:		;
	mov	dx,ax			;
	mov	cs:[cCKD_lengs],dx	;
	inc	cs:[pMML_File]		;
	call	CREAD			;読み込み。
	dec	cs:[pMML_File]		;
c_Command_KeyCode_Step4:		;
	cmp	ah,'.'			;
	jnz	c_Command_KeyCode_Step5	;
	shr	word ptr cs:[cCKD_lengs],1
	add	dx,word ptr cs:[cCKD_lengs]
	inc	cs:[pMML_File]		;
	call	CREAD			;読み込み。
	dec	cs:[pMML_File]		;(ポインタはずらさず。)
	jmp	c_Command_KeyCode_Step4	;
c_Command_KeyCode_Step5:		;
	cmp	ah,'&'			;
	jnz	c_Command_KeyCode_Step6	;
	or	byte ptr cs:[cCKD_Key],020h	;
c_Command_KeyCode_Step6:		;
	cmp	dx,cs:[dMCD_lengs]	;
	jz	c_Command_KeyCode_Step8	;
	or	byte ptr cs:[cCKD_Key],040h	;
c_Command_KeyCode_Step8:		;
	mov	ah,cs:[cCKD_Key]	;
	call	CSET			;書き込み。
	test	byte ptr cs:[cCKD_Key],040h	;
	jz	c_Command_KeyCode_End	;

	mov	ax,dx			;

	cmp	ax,00FFh		;
	jnc	c_Command_KeyCode_Step9	;
	mov	ah,al			;
	call	cset			;
	jmp	c_Command_KeyCode_End	;
c_Command_KeyCode_Step9:
	push	ax			;
	mov	ah,0ffh			;
	call	cset			;
	pop	ax			;
	call	cset16			;

c_Command_KeyCode_End:			;
	popa				;
	ret				;
