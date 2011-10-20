;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|

.186
.model	tiny,stdcall

;=======================================================================|
;				define					|
;=======================================================================|

include	lib_dos.inc

.dosseg

.stack	1000h

.data
WtdIL_Name		equ	'WTD',0
MusicMaxPart		equ	20	;製品版は20パート
EffectMaxPart		equ	3	;効果音は3 パート

D_Debug			DB	00h		;デバッグフラグ

;=======================================================================|
;				Start Up				|
;=======================================================================|
.code
	.startup
	mov	ax,cs
	mov	ss,ax
	mov	sp,offset DGROUP:STACK
	invoke	ComSmole,	sp	;メモリの最小化

	cld

	call	_main

	.exit	0

;---------------------------------------------------------------|
;		エラー処理					|
;---------------------------------------------------------------|
;引数								|
;	dx	表示文字列（エラー内容）			|
;---------------------------------------------------------------|
PRINT_ERR:
	push	cs			;
	pop	ds			;
	MOV	AH,09H			;
	INT	21H			;
	.exit	255			;

;=======================================================================|
;				Start					|
;=======================================================================|
.code
include bank.inc	;バンク
include wtd_ver.inc	;WTD Version infomation
include wtd_def.inc	;WTD Define infomation
include wtc_def.inc	;Define

include sub_cnv.asm	;10進 16進 変換
include wtc_hed.asm	;Header
include wtc_voi.asm	;Voice & Emb
include wtc_com.asm	;Command

;===============================================================|
;								|
;		オプション処理					|
;								|
;===============================================================|
;****************************************************************
;*		オプションフラグ立て				*
;****************************************************************
.const
OPTION_ERROR_MSG	db	'オプションが不正です。',0dh,0ah,24h
.code
OPTION_ERROR	proc	near
	lea	dx,[OPTION_ERROR_MSG]
	jmp	PRINT_ERR
OPTION_ERROR	endp
;****************************************************************
;*		オプションフラグ立て				*
;****************************************************************
.const
OP_HELP		DB	0DH,0AH
		DB	'Wonder Swan Total Souund Driver',0Dh,0Ah
		DB	'Version ', WtdIL_Version
		DB	0DH,0AH
		DB	0DH,0AH
		DB	"WTC [/?] [filename]",0DH,0AH
		DB	0DH,0AH
		DB	"   filename	Source MML filename",0DH,0AH
;		DB	"  /D		Set the debug mode (0 to 255)",0DH,0AH
;		db	"  mode		 bit0(+  1) : reserve",0DH,0AH
;		db	"		 bit2(+  4) : reserve",0DH,0AH
;		db	"		 bit3(+  8) : reserve",0DH,0AH
;		db	"		 bit4(+ 16) : reserve",0DH,0AH
;		db	"		 bit5(+ 32) : reserve",0DH,0AH
;		db	"		 bit6(+ 64) : reserve",0DH,0AH
;		db	"		 bit7(+128) : インクルード展開後のMMLを出力する。",0DH,0AH
;		db	"		 default = 0",0dh,0ah
		DB	"  /?		Display help",0DH,0AH
		DB	024H
.code
OPTION_HELP	proc	near
	push	cs
	pop	ds
	lea	DX,[OP_HELP]		;表示
	MOV	AH,09H			;
	INT	21H			;
	.exit	0
OPTION_HELP	endp			;
;****************************************************************
;*		オプション処理					*
;****************************************************************
;●引数								*
;	ptFilename	ファイル名を入れるポインタ		*
;●返り値							*
;	ptFilename[]	オプション文字列で指定されたファイル名	*
;●使用レジスタ							*
;	ds:si		オプション文字列アドレス		*
;	es:di		ptFilename				*
;	ax		汎用					*
;	cx		オプション文字列最終アドレス＋１	*
;****************************************************************
.code
Op_	proc	near	uses ds es,
		ptFilename:DWORD	;ファイル名を入れるポインタ

	local	cDebug:BYTE		;デバッグの設定有無
	local	cHelp:BYTE		;ヘルプ表示の有無
	local	dotFlag:BYTE		;ファイル名の拡張子の有無

	pusha

	;-----------------------
	;フラグ立て
	xor	ax,ax			;ax ← 0
	les	di,ptFilename		;
	stosb				;先頭にだけ、0を入れておく。
	mov	cDebug,al		;
	mov	cHelp,al		;
	mov	dotFlag,al		;

	push	cs			;
	pop	ds			;DS←CS
	MOV	si,0080H		;BX←オプション文字列先頭アドレス－１
	lodsb				;AL←オプション文字数
	ADD	ax,si			;
	MOV	cx,ax			;CX←オープション文字列最終番地

    .while	(cx>=si)

	lodsb

	.if	(al<21h)
		.continue

	.elseif	((al=='/')||(al=='-'))
		.if	(cx<si)
			JMP	OPTION_ERROR	;だったらエラー
		.endif

		lodsb
		.if	((al=='h')||(al=='H')||(al=='?'))
			mov	cHelp,0FFh
		.elseif	((al=='d')||(al=='D'))
		   .repeat
			mov	dx,si		;DX←オプションアドレス
			.if	(cx<dx)		;無かったらエラー
				JMP	OPTION_ERROR
			.endif
			CALL	ASC2HEX8	;AH←文字列（数値）
			mov	si,bx
		   .until	(!(Carry?))
		   mov	cDebug,ah
		.else
			JMP	OPTION_ERROR	;無かったらエラー
		.endif

	.else
		les	di,ptFilename		;ファイル名を入れるポインタ
		.if	(byte ptr es:[di] != 0)
			JMP	OPTION_ERROR	;ファイル名が２つ書いてあるよぉ～
		.endif

		dec	si			;ポインタ一つ戻す
		mov	dotFlag,0
		.while	(cx>=si)
			lodsb
			.if	(al == '.')
				mov	dotFlag,1
			.elseif	(al < 21h)
				dec	si
				.break		;21h未満だったら終わり。
			.endif
			stosb			;ファイル名セット
		.endw

		.if	(dotFlag==0)		;拡張子が定義されなかったら定義
			mov	al,'.'
			stosb
			mov	al,'M'		;".MML"にする。一応、大文字で。
			stosb
			mov	al,'M'
			stosb
			mov	al,'L'
			stosb
		.endif

		mov	al,0			;
		stosb
		mov	al,24h			;
		stosb
	.endif

    .endw

	;-----------------------
	;フラグに応じた処理
	;●デバッグ
	.if	(cDebug != 0)
		mov	al,cDebug
		mov	CS:[D_Debug],AL		;設定
	.endif

	;●ヘルプ
	.if	(cHelp != 0)
		jmp	OPTION_HELP		;
	.endif

	;●ファイル処理
	les	di,ptFilename			;ファイル名があるポインタ
	.if	(byte ptr es:[di] != 0)
		invoke	Change_Current_Directory,	addr es:[di]

		;オープン
		invoke	File_Open,			addr es:[di],	0
		mov	word ptr cs:[hMml_File],ax
		push	ax

		;ロード
		mov	ds,word ptr CS:[segMml_File]
		xor	bx,bx			;
		mov	ds:[bx],0a0dh		;ファイル先頭に改行を挿入
		invoke	File_Load,	ax,addr ds:2
		add	ax,2			;
		mov	word ptr CS:[szMml_File],ax

		;クローズ
		pop	ax
		invoke	File_Close,	ax
	.else
		jmp	OPTION_HELP	;ファイル名の指定が無ければ、
	.endif

	popa
	RET				;RETURN
Op_	endp
;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				Main Routine				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;●レジスタ使用								|
;	ds	WTDファイルを処理する為に確保したメモリ・セグメント	|
;	es	MMLファイルを処理する為に確保したメモリ・セグメント	|
;	ax	セーブ用のファイルハンドル				|
;=======================================================================|
.code
_main	proc	near

	local	Ext[3]:BYTE		;拡張子　変更用
	local	cFilename[134]:BYTE	;ファイル名

	;-------------------------------
	;■メモリオープン
	invoke	Memory_Open,	01000h	;
	mov	word ptr cs:[segMml_File],ax
	mov	es,ax			;ES←MML SEGMENT
	invoke	Memory_Open,	01000h	;
	mov	word ptr cs:[segWtd_File],ax
	mov	ds,ax			;DS←WTD SEGMENT

	;-------------------------------
	;■オプション処理
	invoke	Op_,	addr ss:cFilename	;オプションに記述されたファイル名を取得する。

	;-------------------------------
	;■コンパイル
	invoke	c_Head_first		;ヘッダー ＆ インクルードファイルの挿入処理
	invoke	c_voice			;音色転送
	invoke	c_Command		;パートコンパイル
	invoke	c_Head_end		;ヘッダー設定(一番最後に呼ぶ。)

	;-------------------------------
	;■WTD or FX ファイルのセーブ
	;セーブするファイルの作成
	.if	(cs:[cHCD_FlagFx]==00h)
		mov	Ext[0],'W'		;
		mov	Ext[1],'T'		;拡張子は"WTD"
		mov	Ext[2],'D'		;
	.else
		mov	Ext[0],'F'		;
		mov	Ext[1],'X'		;拡張子は"FX"
		mov	Ext[2],0		;
	.endif
	invoke	ChangeExt,	addr ss:cFilename,addr ss:Ext
	invoke	File_Create,	addr ss:cFilename,0
	mov	word ptr cs:[hWtd_File],ax

	;セーブ・ファイルへ書き込み
	.if	(cs:[cHCD_FlagFx]!=00h)
	   invoke  File_Write,	ax,128,addr cs:FX
	.endif
	invoke	File_Write,	ax,word ptr cs:[pWTD_File],addr ds:0
	invoke	File_Close,	ax

	;-------------------------------
	;■デバック用セーブ
	.if	(CS:[D_Debug] & 80h)
		mov	Ext[0],'T'		;
		mov	Ext[1],'C'		;拡張子は"TCM"
		mov	Ext[2],'M'		;
		invoke	ChangeExt,	addr ss:cFilename,addr ss:Ext
		invoke	File_Create,	addr ss:cFilename,0
		invoke	File_Write,	ax,word ptr cs:[szMml_File],addr es:0
		invoke	File_Close,	ax
	.endif

	;-------------------------------
	;■メモリの解放
	invoke	Memory_Close,	ds
	invoke	Memory_Close,	es

	ret
_main	endp
;************************************************************************
;*		終わり							*
;************************************************************************
	END

