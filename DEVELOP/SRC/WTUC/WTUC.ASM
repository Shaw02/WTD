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

WTD_UnMML_Compiler_:
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
include bank.inc	;ƒoƒ“ƒN
include wtd_ver.inc	;WTD Version infomation
include wtd_def.inc	;WTD Define infomation
include wtc_def.inc	;Define
include wtuc_sub.asm	;Sub
include wtuc_cmd.asm	;Command
;===============================================================|
;								|
;		ƒIƒvƒVƒ‡ƒ“ˆ—					|
;								|
;===============================================================|
OP_FLAG_ZEMLEN	DB	0			;ƒIƒvƒVƒ‡ƒ“ƒtƒ‰ƒO|•ªŠ„”Žw’è
OP_FLAG_HELP	DB	0			;ƒIƒvƒVƒ‡ƒ“ƒtƒ‰ƒO|ƒwƒ‹ƒv•\Ž¦
OP_FLAG_FILE	DB	081H	DUP(00H)	;ƒtƒ@ƒCƒ‹–¼i‚P‚Q‚W•¶Žš•ªj
OP_HELP	DB	0DH,0AH
	DB	"	Wonder Swan Total Sound Driver Un MML Compiler",0DH,0AH
	DB	"			Programmed by  A.Watanabe",0DH,0AH
	DB	0DH,0AH
	DB	"	 [32;4m Filename[32;0m [m"
	DB	"ƒtƒ@ƒCƒ‹‚Ì“Ç‚Ýž‚Ý",0DH,0AH
	DB	"	>[32;4m Filename[32;0m [m"
	DB	"ƒtƒ@ƒCƒ‹‚Ö‘‚«ž‚Ý",0DH,0AH
	DB	"	/Z :‚P•ª‰¹•„‚Ì•ªŠ„”i1`255j",0DH,0AH
	DB	"	/? :ƒwƒ‹ƒv‚Ì•\Ž¦",0DH,0AH
	DB	024H
;****************************************************************
;*		ƒIƒvƒVƒ‡ƒ“ˆ—					*
;****************************************************************
Op_:
	CALL	OPTION_FLAG		;ƒtƒ‰ƒO—§‚Ä
	MOV	AL,0			;ƒ`ƒFƒbƒN—p
OP_L00:	CMP	CS:[OP_FLAG_ZEMLEN],AL	;ˆê•ª‰¹•„•ªŠ„”
	JZ	OP_L01			;
	CALL	OPTION_ZEMLEN		;
OP_L01:	CMP	CS:[OP_FLAG_HELP],AL	;ƒwƒ‹ƒv•\Ž¦
	JZ	OP_L02			;
	CALL	OPTION_HELP		;
OP_L02:	CMP	CS:[OP_FLAG_FILE],AL	;ƒtƒ@ƒCƒ‹“Ç‚Ýž‚Ý
	JZ	OP_L03			;
	CALL	OPTION_FILE		;
	jmp	OP_LEE			;
OP_L03:	jmp	COMEND			;ƒtƒ@ƒCƒ‹–¼‚ÌŽw’è‚ª–³‚¯‚ê‚ÎA
OP_LEE:	RET				;RETURN
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
OP_S03:	MOV	DX,OFFSET OP_FLAG_ZEMLEN
	CMP	AL,"z"			;ˆê•ª‰¹•„•ªŠ„”
	JNZ	OP_S04			;
	JMP	OP_ZEMLEN_SET		;
OP_S04:	CMP	AL,"Z"			;
	JNZ	OP_S05			;
	JMP	OP_ZEMLEN_SET		;
OP_S05:	
OP_SEE:	JMP	OPTION_ERROR		;–³‚©‚Á‚½‚çƒGƒ‰[
;****************************************************************
OP_ZEMLEN_SET:
	INC	BX			;
	PUSH	DX			;
OP_ZEMLEN_SET_1:			;
	MOV	DX,BX			;DX©ƒIƒvƒVƒ‡ƒ“ƒAƒhƒŒƒX
	CALL	ASC2HEX8		;AH©•¶Žš—ñi”’lj
	JC	OP_ZEMLEN_SET_1		;
	DEC	BX			;
	MOV	AL,AH			;AL©”’l
	POP	DX			;
;****************************************************************
OP_FLAG_SET:
	XCHG	BX,DX			;
	MOV	CS:[BX],AL		;ƒtƒ‰ƒOƒZƒbƒg
	XCHG	BX,DX			;
	JMP	OP_LOOP			;ƒ‹[ƒv‚É–ß‚é
;****************************************************************
OP_FILE_SET:
	MOV	DX,OFFSET OP_FLAG_FILE	;ƒtƒ@ƒCƒ‹‚¾‚×B
	XCHG	BX,DX			;
	MOV	AH,CS:[BX]		;
	XCHG	BX,DX			;
	CMP	AH,0			;
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
	DEC	CX			;‚P‚Q•¶Žš’´‚¦‚½H
	JNZ	OP_FILE_SET_2		;
OP_FILE_SET_3:
	MOV	AL,0			;
	XCHG	BX,DX			;
	MOV	CS:[BX],AL		;'0' ‚ðƒZƒbƒg
	XCHG	BX,DX			;
	POP	CX			;ƒŒƒWƒXƒ^•œ‹A
	JMP	OP_LOOP			;ƒ‹[ƒv‚É–ß‚é
;****************************************************************
OPTION_ZEMLEN:				;
	PUSH	AX			;
	MOV	AL,CS:[OP_FLAG_ZEMLEN]	;
	MOV	CS:[D_ZEN],AL		;Ý’è
	POP	AX			;
	RET				;RETURN
;****************************************************************
OPTION_HELP:				;
	MOV	DX,OFFSET OP_HELP	;•\Ž¦
	MOV	AH,09H			;
	INT	21H			;
	JMP	COMEND			;ƒvƒƒOƒ‰ƒ€I—¹
;****************************************************************
OPTION_FILE:				;
	pusha				;

;œƒtƒ@ƒCƒ‹‚ÌƒI[ƒvƒ“
	MOV	AX,3D00H		;ƒtƒ@ƒCƒ‹‚ÌƒI[ƒvƒ“
	MOV	DX,OFFSET OP_FLAG_FILE	;DX©ƒtƒ@ƒCƒ‹–¼ƒAƒhƒŒƒX
	MOV	CX,00H			;•’Ê
	INT	21H			;ax©ƒtƒ@ƒCƒ‹ƒnƒ“ƒhƒ‹
	jnc	Option_File_ErrOp	;
	jmp	SOPEN_ERROR		;
Option_File_ErrOp:			;
	mov	word ptr cs:[hWtd_File],ax

;œƒtƒ@ƒCƒ‹‚Ìƒ[ƒh
	PUSH	DS			;
	MOV	AX,word ptr CS:[segWtd_File]
	MOV	DS,AX			;
	MOV	DX,0000H		;
	MOV	CX,0FFFFH		;
	MOV	BX,word ptr CS:[hWtd_File]
	MOV	AH,3FH			;
	INT	21H			;
	POP	DS			;
	JNC	Option_File_ErrLd	;
	JMP	READ_ERROR		;
Option_File_ErrLd:			;

;œƒtƒ@ƒCƒ‹‚ÌƒNƒ[ƒY
	MOV	BX,WORD PTR CS:[hWtd_File]
	MOV	AH,3EH			;
	INT	21H			;
	JNC	Option_File_ErrCl	;
	JMP	CLOSE_ERROR		;
Option_File_ErrCl:			;

	popa				;
	RET				;RETURN
;=======================================================================|
;				main					|
;=======================================================================|
_main:
	MOV	AX,OFFSET WTD_UnMML_Compiler_End + BSTACK	;
	MOV	SP,AX			;

	MOV	AX,CS			;
	MOV	DS,AX			;
	MOV	ES,AX			;ƒZƒOƒƒ“ƒg‚ª‚¦‚Ö‚Ö‚ÖB
	MOV	SS,AX			;

	call	ComSmole		;ƒƒ‚ƒŠ‚ÌÅ¬‰»

	call	Memory_Open		;ƒƒ‚ƒŠ‚ÌŠm•Û
	call	Op_			;ƒIƒvƒVƒ‡ƒ“ˆ—
	call	UnMML_COMPAILE		;‹t‚l‚l‚kƒRƒ“ƒpƒCƒ‹•”
	call	Memory_Close		;ƒƒ‚ƒŠ‚Ì‰ð•ú

_main_End:
COMEND:
	STI				;Š„‚èž‚Ý‹–‰Â
	MOV	AX,04C00H		;
	INT	21H			;MS-DOS RET
;=======================================================================|
;				End					|
;=======================================================================|
WTD_UnMML_Compiler_End:
CODE	ENDS
	END	WTD_UnMML_Compiler_
