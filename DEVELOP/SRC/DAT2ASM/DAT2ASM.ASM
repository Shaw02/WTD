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

OP_FLAG_LEN	DB	4			;ƒIƒvƒVƒ‡ƒ“ƒtƒ‰ƒO|•ªŠ„”Žw’è

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
;include	DAT2ASM.INC	;
include	D2A_CNV.ASM	;convert routine
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
	DB	"	Converter from a binary to a DB command",0DH,0AH
	DB	"			Programmed by  A.Watanabe",0DH,0AH
	DB	0DH,0AH
	DB	"	 [32;4m Filename[32;0m [m"
	DB	"ƒtƒ@ƒCƒ‹‚Ì“Ç‚Ýž‚Ý",0DH,0AH
	DB	"	>[32;4m Filename[32;0m [m"
	DB	"ƒtƒ@ƒCƒ‹‚Ö‘‚«ž‚Ý",0DH,0AH
	DB	"	/B : DB–½—ßo—ÍiBytej",0DH,0AH
	DB	"	/W : DW–½—ßo—ÍiWordj",0DH,0AH
	DB	"	/D : DD–½—ßo—ÍiDouble Wordj",0DH,0AH
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

	local	cDebug:BYTE		;ƒfƒoƒbƒO‚ÌÝ’è—L–³
	local	cHelp:BYTE		;ƒwƒ‹ƒv•\Ž¦‚Ì—L–³
	local	dotFlag:BYTE		;ƒtƒ@ƒCƒ‹–¼‚ÌŠg’£Žq‚Ì—L–³

	pusha

	;-----------------------
	;ƒtƒ‰ƒO—§‚Ä
	xor	ax,ax			;ax © 0
	les	di,ptFilename		;
	stosb				;æ“ª‚É‚¾‚¯A0‚ð“ü‚ê‚Ä‚¨‚­B
	mov	cDebug,al		;
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
		.elseif	((al=='b')||(al=='B'))
			mov	OP_FLAG_LEN, 1
		.elseif	((al=='w')||(al=='W'))
			mov	OP_FLAG_LEN, 2
		.elseif	((al=='d')||(al=='D'))
			mov	OP_FLAG_LEN, 4
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
		mov	ds,word ptr CS:[segWtd_File]
		invoke	File_Load,	ax,addr ds:0
		mov	word ptr CS:[szWtd_File],ax

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
;				main					|
;=======================================================================|
_main	proc	near

	local	cFilename[134]:BYTE		;ƒtƒ@ƒCƒ‹–¼

	;-------------------------------
	;¡ƒƒ‚ƒŠƒI[ƒvƒ“
	invoke	Memory_Open,	01000h	;
	mov	word ptr cs:[segWtd_File],ax
	mov	es,ax				;DS©WTD SEGMENT

	;-------------------------------
	;¡ƒIƒvƒVƒ‡ƒ“ˆ—
	invoke	Op_,	addr ss:cFilename	;ƒIƒvƒVƒ‡ƒ“‚É‹Lq‚³‚ê‚½ƒtƒ@ƒCƒ‹–¼‚ðŽæ“¾‚·‚éB

	;-------------------------------
	;¡ƒRƒ“ƒpƒCƒ‹
	invoke	convert				;

	;-------------------------------
	;¡ƒƒ‚ƒŠ‚Ì‰ð•ú
	invoke	Memory_Close,	es

	ret
_main	endp
;=======================================================================|
;				End					|
;=======================================================================|
	END
