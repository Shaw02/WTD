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
	jmp	_main			;���C�����[�`����
;=======================================================================|
;				define					|
;=======================================================================|
WtdIL_Name		equ	'WTD',0
MusicMaxPart		equ	20	;���i�ł�20�p�[�g
EffectMaxPart		equ	3	;���ʉ���3 �p�[�g
;
;		�R���p�C�����
;
D_ZEN	DB	128		;�P������������	�����l
;=======================================================================|
;				Start					|
;=======================================================================|
include bank.inc	;�o���N
include wtd_ver.inc	;WTD Version infomation
include wtd_def.inc	;WTD Define infomation
include wtc_def.inc	;Define
include wtuc_sub.asm	;Sub
include wtuc_cmd.asm	;Command
;===============================================================|
;								|
;		�I�v�V��������					|
;								|
;===============================================================|
OP_FLAG_ZEMLEN	DB	0			;�I�v�V�����t���O�|�������w��
OP_FLAG_HELP	DB	0			;�I�v�V�����t���O�|�w���v�\��
OP_FLAG_FILE	DB	081H	DUP(00H)	;�t�@�C�����i�P�Q�W�������j
OP_HELP	DB	0DH,0AH
	DB	"	Wonder Swan Total Sound Driver Un MML Compiler",0DH,0AH
	DB	"			Programmed by  A.Watanabe",0DH,0AH
	DB	0DH,0AH
	DB	"	 [32;4m Filename[32;0m [m"
	DB	"�t�@�C���̓ǂݍ���",0DH,0AH
	DB	"	>[32;4m Filename[32;0m [m"
	DB	"�t�@�C���֏�������",0DH,0AH
	DB	"	/Z :�P�������̕������i1�`255�j",0DH,0AH
	DB	"	/? :�w���v�̕\��",0DH,0AH
	DB	024H
;****************************************************************
;*		�I�v�V��������					*
;****************************************************************
Op_:
	CALL	OPTION_FLAG		;�t���O����
	MOV	AL,0			;�`�F�b�N�p
OP_L00:	CMP	CS:[OP_FLAG_ZEMLEN],AL	;�ꕪ����������
	JZ	OP_L01			;
	CALL	OPTION_ZEMLEN		;
OP_L01:	CMP	CS:[OP_FLAG_HELP],AL	;�w���v�\��
	JZ	OP_L02			;
	CALL	OPTION_HELP		;
OP_L02:	CMP	CS:[OP_FLAG_FILE],AL	;�t�@�C���ǂݍ���
	JZ	OP_L03			;
	CALL	OPTION_FILE		;
	jmp	OP_LEE			;
OP_L03:	jmp	COMEND			;�t�@�C�����̎w�肪������΁A
OP_LEE:	RET				;RETURN
;****************************************************************
;*		�I�v�V�����t���O����				*
;****************************************************************
;	�g�p���W�X�^						*
;	BX	�I�v�V����������A�h���X			*
;	CX	�I�v�V����������ŏI�A�h���X�{�P		*
;****************************************************************
OPTION_FLAG:				;
	MOV	AX,CS			;
	MOV	DS,AX			;DS��CS

	MOV	AX,0000H		;
	MOV	BX,0080H		;BX���I�v�V����������擪�A�h���X�|�P
	MOV	AL,CS:[BX]		;AL���I�v�V����������
	ADD	AX,BX			;
	MOV	CX,AX			;CX���I�[�v�V����������ŏI�Ԓn
OP_LOOP:
	INC	BX			;
	CMP	CX,BX			;�I�v�V�����I��
	JNC	OP_LP0			;��������t���O���ď�������I��
	RET				;
OP_LP0:
	MOV	AL,CS:[BX]		;������ǂݍ���
	CMP	AL,21H			;
	JC	OP_LOOP			;
	CMP	AL,"/"			;'/'or'-'�ł�������A�I�v�V����
	JZ	OP_SW			;
	CMP	AL,"-"			;
	JZ	OP_SW			;
	JMP	OP_FILE_SET		;����ȊO�̓t�@�C���w��
OP_SW:
	INC	BX			;�A�h���X�C���N�������g
	CMP	CX,BX			;�I�v�V�����I���H
	JNC	OP_S00			;
	JMP	OPTION_ERROR		;��������G���[
OP_S00:	
	MOV	AH,0FFH			;�t���O���ėp�B
	MOV	DX,OFFSET OP_FLAG_HELP	;�t���O�A�h���X
	MOV	AL,CS:[BX]		;
	CMP	AL,"?"			;Help�\��
	JNZ	OP_S01			;
	JMP	OP_FLAG_SET		;
OP_S01:	CMP	AL,"h"			;
	JNZ	OP_S02			;
	JMP	OP_FLAG_SET		;
OP_S02:	CMP	AL,"H"			;
	JNZ	OP_S03			;
	JMP	OP_FLAG_SET		;
OP_S03:	MOV	DX,OFFSET OP_FLAG_ZEMLEN
	CMP	AL,"z"			;�ꕪ����������
	JNZ	OP_S04			;
	JMP	OP_ZEMLEN_SET		;
OP_S04:	CMP	AL,"Z"			;
	JNZ	OP_S05			;
	JMP	OP_ZEMLEN_SET		;
OP_S05:	
OP_SEE:	JMP	OPTION_ERROR		;����������G���[
;****************************************************************
OP_ZEMLEN_SET:
	INC	BX			;
	PUSH	DX			;
OP_ZEMLEN_SET_1:			;
	MOV	DX,BX			;DX���I�v�V�����A�h���X
	CALL	ASC2HEX8		;AH��������i���l�j
	JC	OP_ZEMLEN_SET_1		;
	DEC	BX			;
	MOV	AL,AH			;AL�����l
	POP	DX			;
;****************************************************************
OP_FLAG_SET:
	XCHG	BX,DX			;
	MOV	CS:[BX],AL		;�t���O�Z�b�g
	XCHG	BX,DX			;
	JMP	OP_LOOP			;���[�v�ɖ߂�
;****************************************************************
OP_FILE_SET:
	MOV	DX,OFFSET OP_FLAG_FILE	;�t�@�C�����ׁB
	XCHG	BX,DX			;
	MOV	AH,CS:[BX]		;
	XCHG	BX,DX			;
	CMP	AH,0			;
	JZ	OP_FILE_SET_1		;
	JMP	OPTION_ERROR		;�t�@�C�������Q�����Ă���悧�`
OP_FILE_SET_1:
	DEC	BX			;�I�v�V�����|�C���^��߂�
	PUSH	CX			;���W�X�^�ۑ�
	MOV	CX,080H			;�t�@�C�����i�g���q�܁j�ő�T�C�Y
OP_FILE_SET_2:
	INC	BX			;
	MOV	AL,CS:[BX]		;AL��������ǂݍ���
	CMP	AL,21H			;�Ō�H
	JC	OP_FILE_SET_3		;
	XCHG	BX,DX			;
	MOV	CS:[BX],AL		;������Z�b�g
	XCHG	BX,DX			;
	INC	DX			;�C���N�������g
	DEC	CX			;�P�Q�����������H
	JNZ	OP_FILE_SET_2		;
OP_FILE_SET_3:
	MOV	AL,0			;
	XCHG	BX,DX			;
	MOV	CS:[BX],AL		;'0' ���Z�b�g
	XCHG	BX,DX			;
	POP	CX			;���W�X�^���A
	JMP	OP_LOOP			;���[�v�ɖ߂�
;****************************************************************
OPTION_ZEMLEN:				;
	PUSH	AX			;
	MOV	AL,CS:[OP_FLAG_ZEMLEN]	;
	MOV	CS:[D_ZEN],AL		;�ݒ�
	POP	AX			;
	RET				;RETURN
;****************************************************************
OPTION_HELP:				;
	MOV	DX,OFFSET OP_HELP	;�\��
	MOV	AH,09H			;
	INT	21H			;
	JMP	COMEND			;�v���O�����I��
;****************************************************************
OPTION_FILE:				;
	pusha				;

;���t�@�C���̃I�[�v��
	MOV	AX,3D00H		;�t�@�C���̃I�[�v��
	MOV	DX,OFFSET OP_FLAG_FILE	;DX���t�@�C�����A�h���X
	MOV	CX,00H			;����
	INT	21H			;ax���t�@�C���n���h��
	jnc	Option_File_ErrOp	;
	jmp	SOPEN_ERROR		;
Option_File_ErrOp:			;
	mov	word ptr cs:[hWtd_File],ax

;���t�@�C���̃��[�h
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

;���t�@�C���̃N���[�Y
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
	MOV	ES,AX			;�Z�O�����g�����ււցB
	MOV	SS,AX			;

	call	ComSmole		;�������̍ŏ���

	call	Memory_Open		;�������̊m��
	call	Op_			;�I�v�V��������
	call	UnMML_COMPAILE		;�t�l�l�k�R���p�C����
	call	Memory_Close		;�������̉��

_main_End:
COMEND:
	STI				;���荞�݋���
	MOV	AX,04C00H		;
	INT	21H			;MS-DOS RET
;=======================================================================|
;				End					|
;=======================================================================|
WTD_UnMML_Compiler_End:
CODE	ENDS
	END	WTD_UnMML_Compiler_