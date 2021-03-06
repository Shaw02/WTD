;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Un MML Compiler Program			|
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

OP_FLAG_LEN	DB	4			;オプションフラグ−分割数指定

.data?

segWtd_File	dw	?
szWtd_File	dw	?

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
include	wtd_ver.inc	;WTD Version infomation
include	wtd_def.inc	;WTD Define infomation
;include	DAT2ASM.INC	;
include	D2A_CNV.ASM	;convert routine
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
OP_HELP	DB	0DH,0AH
	DB	"	Converter from a binary to a DB command",0DH,0AH
	DB	"			Programmed by  A.Watanabe",0DH,0AH
	DB	0DH,0AH
	DB	"	 [32;4m Filename[32;0m [m"
	DB	"ファイルの読み込み",0DH,0AH
	DB	"	>[32;4m Filename[32;0m [m"
	DB	"ファイルへ書き込み",0DH,0AH
	DB	"	/B : DB命令出力（Byte）",0DH,0AH
	DB	"	/W : DW命令出力（Word）",0DH,0AH
	DB	"	/D : DD命令出力（Double Word）",0DH,0AH
	DB	"	/? :ヘルプの表示",0DH,0AH
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
	MOV	si,0080H		;BX←オプション文字列先頭アドレス−１
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
		.elseif	((al=='b')||(al=='B'))
			mov	OP_FLAG_LEN, 1
		.elseif	((al=='w')||(al=='W'))
			mov	OP_FLAG_LEN, 2
		.elseif	((al=='d')||(al=='D'))
			mov	OP_FLAG_LEN, 4
		.else
			JMP	OPTION_ERROR	;無かったらエラー
		.endif

	.else
		les	di,ptFilename		;ファイル名を入れるポインタ
		.if	(byte ptr es:[di] != 0)
			JMP	OPTION_ERROR	;ファイル名が２つ書いてあるよぉ〜
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
			mov	al,'W'		;".WTD"にする。一応、大文字で。
			stosb
			mov	al,'T'
			stosb
			mov	al,'D'
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
		push	ax

		;ロード
		mov	ds,word ptr CS:[segWtd_File]
		invoke	File_Load,	ax,addr ds:0
		mov	word ptr CS:[szWtd_File],ax

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
;				main					|
;=======================================================================|
_main	proc	near

	local	cFilename[134]:BYTE		;ファイル名

	;-------------------------------
	;■メモリオープン
	invoke	Memory_Open,	01000h	;
	mov	word ptr cs:[segWtd_File],ax
	mov	es,ax				;DS←WTD SEGMENT

	;-------------------------------
	;■オプション処理
	invoke	Op_,	addr ss:cFilename	;オプションに記述されたファイル名を取得する。

	;-------------------------------
	;■コンパイル
	invoke	convert				;

	;-------------------------------
	;■メモリの解放
	invoke	Memory_Close,	es

	ret
_main	endp
;=======================================================================|
;				End					|
;=======================================================================|
	END
