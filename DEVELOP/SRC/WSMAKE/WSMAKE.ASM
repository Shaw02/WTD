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

pWSC_File	dw	?	;ƒAƒhƒŒƒXŠÇ—(p)

;=======================================================================|
;				Start Up				|
;=======================================================================|
.code
	.startup
	mov	ax,cs
	mov	ss,ax
	mov	sp,offset DGROUP:STACK
	invoke	ComSmole,	sp	;ƒƒ‚ƒŠ‚ÌÅ¬‰»

	cld

	call	_main

	.exit	0

;---------------------------------------------------------------|
;		ƒGƒ‰[ˆ—					|
;---------------------------------------------------------------|
;ˆø”								|
;	dx	•\Ž¦•¶Žš—ñiƒGƒ‰[“à—ej			|
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
;		ƒIƒvƒVƒ‡ƒ“ˆ—					|
;								|
;===============================================================|
;****************************************************************
;*		ƒIƒvƒVƒ‡ƒ“ƒtƒ‰ƒO—§‚Ä				*
;****************************************************************
.const
OPTION_ERROR_MSG	db	'ƒIƒvƒVƒ‡ƒ“‚ª•s³‚Å‚·B',0dh,0ah,24h
.code
OPTION_ERROR	proc	near
	lea	dx,[OPTION_ERROR_MSG]
	jmp	PRINT_ERR
OPTION_ERROR	endp
;****************************************************************
;*		ƒIƒvƒVƒ‡ƒ“ƒtƒ‰ƒO—§‚Ä				*
;****************************************************************
.const
OP_HELP	DB	0DH,0AH
	DB	"	WonderSwan ROM image maker",0DH,0AH
	DB	"			Programmed by  A.Watanabe",0DH,0AH
	DB	0DH,0AH
	DB	"	 [32;4m Filename[32;0m [m"
	DB	"ƒtƒ@ƒCƒ‹‚Ì“Ç‚Ýž‚Ý",0DH,0AH
	DB	"	/? :ƒwƒ‹ƒv‚Ì•\Ž¦",0DH,0AH
	DB	024H
.code
OPTION_HELP	proc	near
	push	cs
	pop	ds
	lea	DX,[OP_HELP]		;•\Ž¦
	MOV	AH,09H			;
	INT	21H			;
	.exit	0
OPTION_HELP	endp			;
;****************************************************************
;*		ƒIƒvƒVƒ‡ƒ“ˆ—					*
;****************************************************************
;œˆø”								*
;	ptFilename	ƒtƒ@ƒCƒ‹–¼‚ð“ü‚ê‚éƒ|ƒCƒ“ƒ^		*
;œ•Ô‚è’l							*
;	ptFilename[]	ƒIƒvƒVƒ‡ƒ“•¶Žš—ñ‚ÅŽw’è‚³‚ê‚½ƒtƒ@ƒCƒ‹–¼	*
;œŽg—pƒŒƒWƒXƒ^							*
;	ds:si		ƒIƒvƒVƒ‡ƒ“•¶Žš—ñƒAƒhƒŒƒX		*
;	es:di		ptFilename				*
;	ax		”Ä—p					*
;	cx		ƒIƒvƒVƒ‡ƒ“•¶Žš—ñÅIƒAƒhƒŒƒX{‚P	*
;****************************************************************
.code
Op_	proc	near	uses ds es,
		ptFilename:DWORD	;ƒtƒ@ƒCƒ‹–¼‚ð“ü‚ê‚éƒ|ƒCƒ“ƒ^

	local	cHelp:BYTE		;ƒwƒ‹ƒv•\Ž¦‚Ì—L–³
	local	dotFlag:BYTE		;ƒtƒ@ƒCƒ‹–¼‚ÌŠg’£Žq‚Ì—L–³

	pusha

	;-----------------------
	;ƒtƒ‰ƒO—§‚Ä
	xor	ax,ax			;ax © 0
	les	di,ptFilename		;
	stosb				;æ“ª‚É‚¾‚¯A0‚ð“ü‚ê‚Ä‚¨‚­B
	mov	cHelp,al		;
	mov	dotFlag,al		;

	push	cs			;
	pop	ds			;DS©CS
	MOV	si,0080H		;BX©ƒIƒvƒVƒ‡ƒ“•¶Žš—ñæ“ªƒAƒhƒŒƒX|‚P
	lodsb				;AL©ƒIƒvƒVƒ‡ƒ“•¶Žš”
	ADD	ax,si			;
	MOV	cx,ax			;CX©ƒI[ƒvƒVƒ‡ƒ“•¶Žš—ñÅI”Ô’n

    .while	(cx>=si)

	lodsb

	.if	(al<21h)
		.continue

	.elseif	((al=='/')||(al=='-'))
		.if	(cx<si)
			JMP	OPTION_ERROR	;‚¾‚Á‚½‚çƒGƒ‰[
		.endif

		lodsb
		.if	((al=='h')||(al=='H')||(al=='?'))
			mov	cHelp,0FFh
		.else
			JMP	OPTION_ERROR	;–³‚©‚Á‚½‚çƒGƒ‰[
		.endif

	.else
		les	di,ptFilename		;ƒtƒ@ƒCƒ‹–¼‚ð“ü‚ê‚éƒ|ƒCƒ“ƒ^
		.if	(byte ptr es:[di] != 0)
			JMP	OPTION_ERROR	;ƒtƒ@ƒCƒ‹–¼‚ª‚Q‚Â‘‚¢‚Ä‚ ‚é‚æ‚§`
		.endif

		dec	si			;ƒ|ƒCƒ“ƒ^ˆê‚Â–ß‚·
		mov	dotFlag,0
		.while	(cx>=si)
			lodsb
			.if	(al == '.')
				mov	dotFlag,1
			.elseif	(al < 21h)
				dec	si
				.break		;21h–¢–ž‚¾‚Á‚½‚çI‚í‚èB
			.endif
			stosb			;ƒtƒ@ƒCƒ‹–¼ƒZƒbƒg
		.endw

		.if	(dotFlag==0)		;Šg’£Žq‚ª’è‹`‚³‚ê‚È‚©‚Á‚½‚ç’è‹`
			mov	al,'.'
			stosb
			mov	al,'W'		;".WTD"‚É‚·‚éBˆê‰žA‘å•¶Žš‚ÅB
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
	;ƒtƒ‰ƒO‚É‰ž‚¶‚½ˆ—
	;œƒwƒ‹ƒv
	.if	(cHelp != 0)
		jmp	OPTION_HELP		;
	.endif

	;œƒtƒ@ƒCƒ‹ˆ—
	les	di,ptFilename			;ƒtƒ@ƒCƒ‹–¼‚ª‚ ‚éƒ|ƒCƒ“ƒ^
	.if	(byte ptr es:[di] != 0)
		invoke	Change_Current_Directory,	addr es:[di]

		;ƒI[ƒvƒ“
		invoke	File_Open,			addr es:[di],	0
		push	ax

		;ƒ[ƒh
		mov	ds,word ptr CS:[pWSC_File]
		invoke	File_Load,	ax,addr ds:0

		;ƒNƒ[ƒY
		pop	ax
		invoke	File_Close,	ax
	.else
		jmp	OPTION_HELP	;ƒtƒ@ƒCƒ‹–¼‚ÌŽw’è‚ª–³‚¯‚ê‚ÎA
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
MUS_ERR		db	'WTDŒ`Ž®‚Ìƒf[ƒ^‚Å‚Í‚ ‚è‚Ü‚¹‚ñB'

WSR_HEAD	db	"WSRF"
		dw	0100h
		db	10	dup(0)
WSC_HEAD	db	0EAh
		dw	00000h
		dw	0F000h
		db	11	dup(0)
.code
_main	proc	near

	local	Ext[3]:BYTE		;Šg’£Žq@•ÏX—p
	local	cFilename[134]:BYTE	;ƒtƒ@ƒCƒ‹–¼

		;-------------------------------
		;¡ƒƒ‚ƒŠƒI[ƒvƒ“
		invoke	Memory_Open,	02000h	;
		mov	word ptr cs:[pWSC_File],ax
		mov	es,ax			;ES©MML SEGMENT
		mov	di,0			;es:di© Šm•Û‚µ‚½ƒZƒOƒƒ“ƒg
		mov	cx,08000h		;
		mov	ax,0			;
	rep	stosw				;‚O‰Šú‰»
		mov	ax,es			;
		add	ax,01000h		;
		mov	es,ax			;
		mov	di,0			;es:di© Šm•Û‚µ‚½ƒZƒOƒƒ“ƒg
		mov	cx,08000h		;
		mov	ax,0			;
	rep	stosw				;‚O‰Šú‰»

		;-----------------------
		;¡“ÆŽ©BIOS‚Ì“Ç‚Ýž‚Ý

		;file_open(ROM_IMG.BIN)
		invoke	File_Open,	addr cs:[BIOS_FILE],	0
		push	ax

		invoke	File_Load,	ax, addr es:0

		;ƒNƒ[ƒY
		pop	ax
		invoke	File_Close,	ax


		;-------------------------------
		;¡ƒIƒvƒVƒ‡ƒ“ˆ— • ƒtƒ@ƒCƒ‹“Ç‚Ýž‚Ý
		invoke	Op_,	addr ss:cFilename	;ƒIƒvƒVƒ‡ƒ“‚É‹Lq‚³‚ê‚½ƒtƒ@ƒCƒ‹–¼‚ðŽæ“¾‚·‚éB


		;-----------------------
		;¡Wonder Swan ROM Ý’è
		push	cs
		pop	ds
		lea	si, WSR_HEAD
		mov	di, 0FFE0h
		mov	cx, 00010h
	rep	movsw

		;-----------------------
		;¡ROMƒCƒ[ƒW‚Ìì¬

		;WTDŒ`Ž®‚©ƒ`ƒFƒbƒN		;
		push	cs:[pWSC_File]		;
		pop	ds			;
		xor	dx, dx			;ds:dx© Šm•Û‚µ‚½ƒZƒOƒƒ“ƒg
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
		mov	Ext[1],'S'		;Šg’£Žq‚Í"WTD"
		mov	Ext[2],'C'		;
		invoke	ChangeExt,	addr ss:cFilename,addr ss:Ext

		invoke	File_Create,	addr ss:cFilename,0

		;¦¦¦@File_Write() ‚ÍA ax ‚ð‰ó‚³‚È‚¢

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
