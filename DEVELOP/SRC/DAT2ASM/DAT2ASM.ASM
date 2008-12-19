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
include	wtd_ver.inc	;WTD Version infomation
include	wtd_def.inc	;WTD Define infomation
include	WSMAKE.INC	;
include	D2A_SUB.ASM	;sub routine
include	D2A_CNV.ASM	;convert routine
;****************************************************************
;*		�I�v�V��������					*
;****************************************************************
OP_FLAG_LEN	DB	4			;�I�v�V�����t���O�|�������w��
OP_FLAG_HELP	DB	0			;�I�v�V�����t���O�|�w���v�\��
OP_FLAG_FILE	DB	081H	DUP(00H)	;�t�@�C�����i�P�Q�W�������j
OP_HELP	DB	0DH,0AH
	DB	"	Converter from a binary to a DB command",0DH,0AH
	DB	"			Programmed by  A.Watanabe",0DH,0AH
	DB	0DH,0AH
	DB	"	 [32;4m Filename[32;0m [m"
	DB	"�t�@�C���̓ǂݍ���",0DH,0AH
	DB	"	>[32;4m Filename[32;0m [m"
	DB	"�t�@�C���֏�������",0DH,0AH
	DB	"	/B : DB���ߏo�́iByte�j",0DH,0AH
	DB	"	/W : DW���ߏo�́iWord�j",0DH,0AH
	DB	"	/D : DD���ߏo�́iDouble Word�j",0DH,0AH
	DB	"	/? :�w���v�̕\��",0DH,0AH
	DB	024H
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
OP_S03:	

	MOV	DX,OFFSET OP_FLAG_LEN	;DB���ߎw��
	mov	ah,1			;
	CMP	AL,"b"			;
	JNZ	OP_S04			;
	JMP	OP_FLAG_SET		;
OP_S04:	CMP	AL,"B"			;
	JNZ	OP_S05			;
	JMP	OP_FLAG_SET		;
OP_S05:	

	mov	ah,2			;DW���ߎw��
	CMP	AL,"w"			;
	JNZ	OP_S06			;
	JMP	OP_FLAG_SET		;
OP_S06:	CMP	AL,"W"			;
	JNZ	OP_S07			;
	JMP	OP_FLAG_SET		;
OP_S07:	

	mov	ah,4			;DD���ߎw��
	CMP	AL,"d"			;
	JNZ	OP_S08			;
	JMP	OP_FLAG_SET		;
OP_S08:	CMP	AL,"D"			;
	JNZ	OP_S09			;
	JMP	OP_FLAG_SET		;
OP_S09:	

OP_SEE:	JMP	OPTION_ERROR		;����������G���[
;****************************************************************
OP_FLAG_SET:
	XCHG	BX,DX			;
	MOV	CS:[BX],AH		;�t���O�Z�b�g
	XCHG	BX,DX			;
	JMP	OP_LOOP			;���[�v�ɖ߂�
;****************************************************************
OP_FILE_SET:
	MOV	DX,OFFSET OP_FLAG_FILE	;�t�@�C�����ׁB
	XCHG	BX,DX			;
	MOV	AH,CS:[BX]		;
	XCHG	BX,DX			;
	CMP	AH,0			;�t���O���O�ȊO�H
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
	DEC	CX			;�P�Q�W�����������H
	JNZ	OP_FILE_SET_2		;
OP_FILE_SET_3:
	MOV	AL,0			;
	XCHG	BX,DX			;
	MOV	CS:[BX],AL		;'0' ���Z�b�g
	XCHG	BX,DX			;
	POP	CX			;���W�X�^���A
	JMP	OP_LOOP			;���[�v�ɖ߂�
;=======================================================================|
;		�^�ݒ�							|
;=======================================================================|
OPTION_LEN:				;
;	PUSH	AX			;
;	MOV	AL,CS:[OP_FLAG_LEN]	;
;	MOV	CS:[D_ZEN],AL		;�ݒ�
;	POP	AX			;
	RET				;RETURN
;=======================================================================|
;		�w���v							|
;=======================================================================|
OPTION_HELP:				;
	MOV	DX,OFFSET OP_HELP	;�\��
	MOV	AH,09H			;
	INT	21H			;
	JMP	COMEND			;�v���O�����I��
;=======================================================================|
;		�t�@�C�����ݒ�						|
;=======================================================================|
OPTION_FILE:				;
	pusha				;

	;hWtd_File = file_open(0,OP_FLAG_FILE);
	push	cs			;
	pop	ds			;
	mov	dx,offset OP_FLAG_FILE	;DS:DX���t�@�C�����A�h���X
	mov	ax,0			;AX��Read����
	call	File_Open		;
	mov	word ptr cs:[hWtd_File],ax

;���t�@�C���̃��[�h
	;szWtd_File = file_close(hWtd_File,segWtd_File);
	push	ds			;
	mov	ax,word ptr cs:[segWtd_File]
	mov	ds,ax			;
	mov	dx,0			;ds:dx���o�b�t�@
	mov	ax,word ptr cs:[hWtd_File]
	call	File_Load		;
	mov	word ptr cs:[szWtd_File],ax
	pop	ds			;

;���t�@�C���̃N���[�Y
	;file_close(hWtd_File);
	mov	ax,word ptr cs:[hWtd_File]
	call	File_Close		;

	popa				;
	RET				;RETURN
;=======================================================================|
;		�I�v�V��������						|
;=======================================================================|
operr_msg	db	'�I�v�V�������s���ł��B',0ah,0dh,24h
OPTION_ERROR:
	push	cs			;�G���[��
	pop	ds			;
	mov	dx,offset operr_msg	;
	mov	ah,09h			;
	int	21h			;
	jmp	COMEND			;
;=======================================================================|
;		�I�v�V��������						|
;=======================================================================|
Op_:
	CALL	OPTION_FLAG		;�t���O����
	MOV	AL,0			;�`�F�b�N�p
OP_L00:	CMP	CS:[OP_FLAG_LEN],AL	;�o�͏���
	JZ	OP_L01			;
	CALL	OPTION_LEN		;
OP_L01:	CMP	CS:[OP_FLAG_HELP],AL	;�w���v�\��
	JZ	OP_L02			;
	CALL	OPTION_HELP		;
OP_L02:	CMP	CS:[OP_FLAG_FILE],AL	;�t�@�C���ǂݍ���
	JZ	OP_L03			;
	CALL	OPTION_FILE		;
	jmp	OP_LEE			;
OP_L03:	jmp	COMEND			;�t�@�C�����̎w�肪������΁A
OP_LEE:	RET				;RETURN
;=======================================================================|
;				main					|
;=======================================================================|
_main:
	MOV	AX,OFFSET Dat2Asm_End + BSTACK	;
	MOV	SP,AX			;

	MOV	AX,CS			;
	MOV	DS,AX			;
	MOV	ES,AX			;�Z�O�����g�����ււցB
	MOV	SS,AX			;

	call	ComSmole		;�������̍ŏ���

	mov	ax,01000h		;
	call	Memory_Open		;
	mov	word ptr cs:[segWtd_File],ax

	call	Op_			;�I�v�V��������

	call	convert			;�t�l�l�k�R���p�C����

	mov	ax,word ptr cs:[segWtd_File]
	call	Memory_Close		;�������̉��

_main_End:
COMEND:
	STI				;���荞�݋���
	MOV	AX,04C00H		;
	INT	21H			;MS-DOS RET
;=======================================================================|
;				End					|
;=======================================================================|
Dat2Asm_End:
CODE	ENDS
	END	Dat2Asm_End_