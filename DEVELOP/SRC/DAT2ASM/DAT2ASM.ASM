;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Un MML Compiler Program			|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|

assume	cs:code,ds:code,es:code,ss:code

code	segment

.186

	org	0100h

Dat2Asm_End_:
;=======================================================================|
;				Start Up				|
;=======================================================================|
	jmp	_main			;ƒƒCƒ“ƒ‹[ƒ`ƒ“‚Ö
;=======================================================================|
;				define					|
;=======================================================================|
WtdIL_Name		equ	'WTD',0
MusicMaxPart		equ	20	;»•i”Å‚Í20ƒp[ƒg
EffectMaxPart		equ	3	;Œø‰Ê‰¹‚Í3 ƒp[ƒg
;
;		ƒRƒ“ƒpƒCƒ‹î•ñ
;
D_ZEN	DB	128		;‚P•ª‰¹•„•ªŠ„”	‰Šú’l
;=======================================================================|
;				Start					|
;=======================================================================|
include	wtd_ver.inc	;WTD Version infomation
include	wtd_def.inc	;WTD Define infomation
include	WSMAKE.INC	;
include	D2A_SUB.ASM	;sub routine
include	D2A_CNV.ASM	;convert routine
;****************************************************************
;*		ƒIƒvƒVƒ‡ƒ“ˆ—					*
;****************************************************************
OP_FLAG_LEN	DB	4			;ƒIƒvƒVƒ‡ƒ“ƒtƒ‰ƒO|•ªŠ„”Žw’è
OP_FLAG_HELP	DB	0			;ƒIƒvƒVƒ‡ƒ“ƒtƒ‰ƒO|ƒwƒ‹ƒv•\Ž¦
OP_FLAG_FILE	DB	081H	DUP(00H)	;ƒtƒ@ƒCƒ‹–¼i‚P‚Q‚W•¶Žš•ªj
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
;****************************************************************
;*		ƒIƒvƒVƒ‡ƒ“ƒtƒ‰ƒO—§‚Ä				*
;****************************************************************
;	Žg—pƒŒƒWƒXƒ^						*
;	BX	ƒIƒvƒVƒ‡ƒ“•¶Žš—ñƒAƒhƒŒƒX			*
;	CX	ƒIƒvƒVƒ‡ƒ“•¶Žš—ñÅIƒAƒhƒŒƒX{‚P		*
;****************************************************************
OPTION_FLAG:				;
	MOV	AX,CS			;
	MOV	DS,AX			;DS©CS

	MOV	AX,0000H		;
	MOV	BX,0080H		;BX©ƒIƒvƒVƒ‡ƒ“•¶Žš—ñæ“ªƒAƒhƒŒƒX|‚P
	MOV	AL,CS:[BX]		;AL©ƒIƒvƒVƒ‡ƒ“•¶Žš”
	ADD	AX,BX			;
	MOV	CX,AX			;CX©ƒI[ƒvƒVƒ‡ƒ“•¶Žš—ñÅI”Ô’n
OP_LOOP:
	INC	BX			;
	CMP	CX,BX			;ƒIƒvƒVƒ‡ƒ“I—¹
	JNC	OP_LP0			;‚¾‚Á‚½‚çƒtƒ‰ƒO—§‚Äˆ—³íI—¹
	RET				;
OP_LP0:
	MOV	AL,CS:[BX]		;•¶Žš—ñ“Ç‚Ýž‚Ý
	CMP	AL,21H			;
	JC	OP_LOOP			;
	CMP	AL,"/"			;'/'or'-'‚Å‚ ‚Á‚½‚çAƒIƒvƒVƒ‡ƒ“
	JZ	OP_SW			;
	CMP	AL,"-"			;
	JZ	OP_SW			;
	JMP	OP_FILE_SET		;‚»‚êˆÈŠO‚Íƒtƒ@ƒCƒ‹Žw’è
OP_SW:
	INC	BX			;ƒAƒhƒŒƒXƒCƒ“ƒNƒŠƒƒ“ƒg
	CMP	CX,BX			;ƒIƒvƒVƒ‡ƒ“I—¹H
	JNC	OP_S00			;
	JMP	OPTION_ERROR		;‚¾‚Á‚½‚çƒGƒ‰[
OP_S00:	
	MOV	AH,0FFH			;ƒtƒ‰ƒO—§‚Ä—pB
	MOV	DX,OFFSET OP_FLAG_HELP	;ƒtƒ‰ƒOƒAƒhƒŒƒX
	MOV	AL,CS:[BX]		;
	CMP	AL,"?"			;Help•\Ž¦
	JNZ	OP_S01			;
	JMP	OP_FLAG_SET		;
OP_S01:	CMP	AL,"h"			;
	JNZ	OP_S02			;
	JMP	OP_FLAG_SET		;
OP_S02:	CMP	AL,"H"			;
	JNZ	OP_S03			;
	JMP	OP_FLAG_SET		;
OP_S03:	

	MOV	DX,OFFSET OP_FLAG_LEN	;DB–½—ßŽw’è
	mov	ah,1			;
	CMP	AL,"b"			;
	JNZ	OP_S04			;
	JMP	OP_FLAG_SET		;
OP_S04:	CMP	AL,"B"			;
	JNZ	OP_S05			;
	JMP	OP_FLAG_SET		;
OP_S05:	

	mov	ah,2			;DW–½—ßŽw’è
	CMP	AL,"w"			;
	JNZ	OP_S06			;
	JMP	OP_FLAG_SET		;
OP_S06:	CMP	AL,"W"			;
	JNZ	OP_S07			;
	JMP	OP_FLAG_SET		;
OP_S07:	

	mov	ah,4			;DD–½—ßŽw’è
	CMP	AL,"d"			;
	JNZ	OP_S08			;
	JMP	OP_FLAG_SET		;
OP_S08:	CMP	AL,"D"			;
	JNZ	OP_S09			;
	JMP	OP_FLAG_SET		;
OP_S09:	

OP_SEE:	JMP	OPTION_ERROR		;–³‚©‚Á‚½‚çƒGƒ‰[
;****************************************************************
OP_FLAG_SET:
	XCHG	BX,DX			;
	MOV	CS:[BX],AH		;ƒtƒ‰ƒOƒZƒbƒg
	XCHG	BX,DX			;
	JMP	OP_LOOP			;ƒ‹[ƒv‚É–ß‚é
;****************************************************************
OP_FILE_SET:
	MOV	DX,OFFSET OP_FLAG_FILE	;ƒtƒ@ƒCƒ‹‚¾‚×B
	XCHG	BX,DX			;
	MOV	AH,CS:[BX]		;
	XCHG	BX,DX			;
	CMP	AH,0			;ƒtƒ‰ƒO‚ª‚OˆÈŠOH
	JZ	OP_FILE_SET_1		;
	JMP	OPTION_ERROR		;ƒtƒ@ƒCƒ‹–¼‚ª‚Q‚Â‘‚¢‚Ä‚ ‚é‚æ‚§`
OP_FILE_SET_1:
	DEC	BX			;ƒIƒvƒVƒ‡ƒ“ƒ|ƒCƒ“ƒ^ˆê‚Â–ß‚·
	PUSH	CX			;ƒŒƒWƒXƒ^•Û‘¶
	MOV	CX,080H			;ƒtƒ@ƒCƒ‹–¼iŠg’£ŽqŠÜjÅ‘åƒTƒCƒY
OP_FILE_SET_2:
	INC	BX			;
	MOV	AL,CS:[BX]		;AL©•¶Žš—ñ“Ç‚Ýž‚Ý
	CMP	AL,21H			;ÅŒãH
	JC	OP_FILE_SET_3		;
	XCHG	BX,DX			;
	MOV	CS:[BX],AL		;•¶Žš—ñƒZƒbƒg
	XCHG	BX,DX			;
	INC	DX			;ƒCƒ“ƒNƒŠƒƒ“ƒg
	DEC	CX			;‚P‚Q‚W•¶Žš’´‚¦‚½H
	JNZ	OP_FILE_SET_2		;
OP_FILE_SET_3:
	MOV	AL,0			;
	XCHG	BX,DX			;
	MOV	CS:[BX],AL		;'0' ‚ðƒZƒbƒg
	XCHG	BX,DX			;
	POP	CX			;ƒŒƒWƒXƒ^•œ‹A
	JMP	OP_LOOP			;ƒ‹[ƒv‚É–ß‚é
;=======================================================================|
;		Œ^Ý’è							|
;=======================================================================|
OPTION_LEN:				;
;	PUSH	AX			;
;	MOV	AL,CS:[OP_FLAG_LEN]	;
;	MOV	CS:[D_ZEN],AL		;Ý’è
;	POP	AX			;
	RET				;RETURN
;=======================================================================|
;		ƒwƒ‹ƒv							|
;=======================================================================|
OPTION_HELP:				;
	MOV	DX,OFFSET OP_HELP	;•\Ž¦
	MOV	AH,09H			;
	INT	21H			;
	JMP	COMEND			;ƒvƒƒOƒ‰ƒ€I—¹
;=======================================================================|
;		ƒtƒ@ƒCƒ‹–¼Ý’è						|
;=======================================================================|
OPTION_FILE:				;
	pusha				;

	;hWtd_File = file_open(0,OP_FLAG_FILE);
	push	cs			;
	pop	ds			;
	mov	dx,offset OP_FLAG_FILE	;DS:DX©ƒtƒ@ƒCƒ‹–¼ƒAƒhƒŒƒX
	mov	ax,0			;AX©Read‘®«
	call	File_Open		;
	mov	word ptr cs:[hWtd_File],ax

;œƒtƒ@ƒCƒ‹‚Ìƒ[ƒh
	;szWtd_File = file_close(hWtd_File,segWtd_File);
	push	ds			;
	mov	ax,word ptr cs:[segWtd_File]
	mov	ds,ax			;
	mov	dx,0			;ds:dx©ƒoƒbƒtƒ@
	mov	ax,word ptr cs:[hWtd_File]
	call	File_Load		;
	mov	word ptr cs:[szWtd_File],ax
	pop	ds			;

;œƒtƒ@ƒCƒ‹‚ÌƒNƒ[ƒY
	;file_close(hWtd_File);
	mov	ax,word ptr cs:[hWtd_File]
	call	File_Close		;

	popa				;
	RET				;RETURN
;=======================================================================|
;		ƒIƒvƒVƒ‡ƒ“ˆ—						|
;=======================================================================|
operr_msg	db	'ƒIƒvƒVƒ‡ƒ“‚ª•s³‚Å‚·B',0ah,0dh,24h
OPTION_ERROR:
	push	cs			;ƒGƒ‰[Žž
	pop	ds			;
	mov	dx,offset operr_msg	;
	mov	ah,09h			;
	int	21h			;
	jmp	COMEND			;
;=======================================================================|
;		ƒIƒvƒVƒ‡ƒ“ˆ—						|
;=======================================================================|
Op_:
	CALL	OPTION_FLAG		;ƒtƒ‰ƒO—§‚Ä
	MOV	AL,0			;ƒ`ƒFƒbƒN—p
OP_L00:	CMP	CS:[OP_FLAG_LEN],AL	;o—Í‘Ž®
	JZ	OP_L01			;
	CALL	OPTION_LEN		;
OP_L01:	CMP	CS:[OP_FLAG_HELP],AL	;ƒwƒ‹ƒv•\Ž¦
	JZ	OP_L02			;
	CALL	OPTION_HELP		;
OP_L02:	CMP	CS:[OP_FLAG_FILE],AL	;ƒtƒ@ƒCƒ‹“Ç‚Ýž‚Ý
	JZ	OP_L03			;
	CALL	OPTION_FILE		;
	jmp	OP_LEE			;
OP_L03:	jmp	COMEND			;ƒtƒ@ƒCƒ‹–¼‚ÌŽw’è‚ª–³‚¯‚ê‚ÎA
OP_LEE:	RET				;RETURN
;=======================================================================|
;				main					|
;=======================================================================|
_main:
	MOV	AX,OFFSET Dat2Asm_End + BSTACK	;
	MOV	SP,AX			;

	MOV	AX,CS			;
	MOV	DS,AX			;
	MOV	ES,AX			;ƒZƒOƒƒ“ƒg‚ª‚¦‚Ö‚Ö‚ÖB
	MOV	SS,AX			;

	call	ComSmole		;ƒƒ‚ƒŠ‚ÌÅ¬‰»

	mov	ax,01000h		;
	call	Memory_Open		;
	mov	word ptr cs:[segWtd_File],ax

	call	Op_			;ƒIƒvƒVƒ‡ƒ“ˆ—

	call	convert			;‹t‚l‚l‚kƒRƒ“ƒpƒCƒ‹•”

	mov	ax,word ptr cs:[segWtd_File]
	call	Memory_Close		;ƒƒ‚ƒŠ‚Ì‰ð•ú

_main_End:
COMEND:
	STI				;Š„‚èž‚Ý‹–‰Â
	MOV	AX,04C00H		;
	INT	21H			;MS-DOS RET
;=======================================================================|
;				End					|
;=======================================================================|
Dat2Asm_End:
CODE	ENDS
	END	Dat2Asm_End_
