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

.data?

pWSC_File	dw	?	;アドレス管理(p)

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
;include	WSMAKE.INC	;
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
	DB	"	WonderSwan ROM image maker",0DH,0AH
	DB	"			Programmed by  A.Watanabe",0DH,0AH
	DB	0DH,0AH
	DB	"	 [32;4m Filename[32;0m [m"
	DB	"ファイルの読み込み",0DH,0AH
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

	local	cHelp:BYTE		;ヘルプ表示の有無
	local	dotFlag:BYTE		;ファイル名の拡張子の有無

	pusha

	;-----------------------
	;フラグ立て
	xor	ax,ax			;ax ← 0
	les	di,ptFilename		;
	stosb				;先頭にだけ、0を入れておく。
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
		mov	ds,word ptr CS:[pWSC_File]
		invoke	File_Load,	ax,addr ds:0

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
.const
BIOS_FILE	db	'ROM_IMG.BIN',0,0ah,0dh,24h
MUS_ERR		db	'WTD形式のデータではありません。'

WSR_HEAD	db	"WSRF"
		dw	0100h
		db	10	dup(0)
WSC_HEAD	db	0EAh
		dw	00000h
		dw	0F000h
		db	11	dup(0)
.code
_main	proc	near

	local	Ext[3]:BYTE		;拡張子　変更用
	local	cFilename[134]:BYTE	;ファイル名

		;-------------------------------
		;■メモリオープン
		invoke	Memory_Open,	02000h	;
		mov	word ptr cs:[pWSC_File],ax
		mov	es,ax			;ES←MML SEGMENT
		mov	di,0			;es:di← 確保したセグメント
		mov	cx,08000h		;
		mov	ax,0			;
	rep	stosw				;０初期化
		mov	ax,es			;
		add	ax,01000h		;
		mov	es,ax			;
		mov	di,0			;es:di← 確保したセグメント
		mov	cx,08000h		;
		mov	ax,0			;
	rep	stosw				;０初期化

		;-----------------------
		;■独自BIOSの読み込み

		;file_open(ROM_IMG.BIN)
		invoke	File_Open,	addr cs:[BIOS_FILE],	0
		push	ax

		invoke	File_Load,	ax, addr es:0

		;クローズ
		pop	ax
		invoke	File_Close,	ax


		;-------------------------------
		;■オプション処理 ＆ ファイル読み込み
		invoke	Op_,	addr ss:cFilename	;オプションに記述されたファイル名を取得する。


		;-----------------------
		;■Wonder Swan ROM 設定
		push	cs
		pop	ds
		lea	si, WSR_HEAD
		mov	di, 0FFE0h
		mov	cx, 00010h
	rep	movsw

		;-----------------------
		;■ROMイメージの作成

		;WTD形式かチェック		;
		push	cs:[pWSC_File]		;
		pop	ds			;
		xor	dx, dx			;ds:dx← 確保したセグメント
		xor	bx, bx
		.if	(word ptr ds:[bx] != 'TW')
		   mov	dx, 80h
		   mov	bx, dx
		   .if	(word ptr ds:[bx] != 'TW')
			lea	dx, MUS_ERR
			jmp	PRINT_ERR
		   .endif
		.endif

		;file_open("*.WSC")
		mov	Ext[0],'W'		;
		mov	Ext[1],'S'		;拡張子は"WTD"
		mov	Ext[2],'C'		;
		invoke	ChangeExt,	addr ss:cFilename,addr ss:Ext

		invoke	File_Create,	addr ss:cFilename,0

		;※※※　File_Write() は、 ax を壊さない

		mov	cx, 8000h
		invoke	File_Write,	ax, cx, ds::dx
		add	dx, cx
		invoke	File_Write,	ax, cx, ds::dx
		xor	dx, dx
		invoke	File_Write,	ax, cx, es::dx
		invoke	File_Write,	ax, cx, es::cx

		invoke	File_Close,	ax

		ret
_main	endp
;=======================================================================|
;				End					|
;=======================================================================|
	END
