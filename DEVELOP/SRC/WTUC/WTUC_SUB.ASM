;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				UnMML Compiler Program			|
;				SUB Routine				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;****************************************************************
;								*
;			�R���p�C����				*
;								*
;****************************************************************
;---------------------------------------------------------------|
;		�R���p�C�����[�`��				|
;---------------------------------------------------------------|
UnMML_COMPAILE:				;�R���p�C��
	MOV	AX,CS:[segWTD_File]	;
	MOV	ES,AX			;ES��WTD SEGMENT

;	CALL	c_Head_first		;�w�b�_�[�ݒ�
;	CALL	c_voice			;���F�]��
;	CALL	c_emb			;�G���x���[�v
;	CALL	c_Command		;�p�[�g�R���p�C��

UnMML_COMPAILE_End:			;
	ret				;RETURN
;---------------------------------------------------------------|
;		�f�[�^�ǂݍ���					|
;---------------------------------------------------------------|
;	����							|
;		ES:BX���A�h���X					|
;	�Ԃ�l							|
;		AL���f�[�^					|
;		BX�����̃A�h���X				|
;---------------------------------------------------------------|
D_READ:					;
	MOV	AL,ES:[BX]		;�ǂݍ���
	INC	BX			;�|�C���^�@�C���N�������g
	RET				;RETURN
D_READ_H:				;
	MOV	AH,ES:[BX]		;�ǂݍ���
	INC	BX			;�|�C���^�@�C���N�������g
	RET				;RETURN
D_READ16:
	MOV	AX,ES:[BX]		;�ǂݍ���
	INC	BX			;�|�C���^�@�C���N�������g
	INC	BX			;
	RET				;RETURN
;****************************************************************
;*								*
;*		�P�O�i������P�U�i�R�[�h�ϊ����[�`��		*
;*								*
;****************************************************************
;---------------------------------------------------------------|
;		ASCII CODE���P�U�i�R�[�h(-127�`255)		|
;---------------------------------------------------------------|
;	����							|
;		DS:DX���ϊ�������������擪�A�h���X		|
;	�Ԃ�l							|
;		AH���ϊ���					|
;		AL���j��					|
;		DS:BX�����̃A�h���X				|
;---------------------------------------------------------------|
HEX_8	DB	00H,00H,00H		;
DHEX8	DB	00H			;
F8FLAG	DB	00H			;
ASC2HEX8:				;
	PUSH	CX			;
	PUSH	DX			;
	XOR	CX,CX			;CX��0
	MOV	BX,DX			;BX��DX�i������擪�A�h���X�j
	MOV	DX,OFFSET HEX_8		;DX���ϊ��p�f�[�^�o�b�t�@
	XOR	AX,AX			;
	MOV	CS:[F8FLAG],AH		;�����t���O�̃��Z�b�g
	MOV	AH,DS:[BX]		;
	CMP	AH,'-'			;
	JNZ	A2H8L0			;
	INC	BX			;
	MOV	AH,0F8H			;Flag
	MOV	CS:[F8FLAG],AH		;Set
A2H8L0:	MOV	AH,DS:[BX]		;
	INC	BX			;
	SUB	AH,30H			;CHR CODE��HEX CODE
	JNC	A2H8L1			;AH<0�@��������ꎞ�ϊ��I��
	JMP	A2H8E1			;
A2H8L1:	CMP	AH,10			;
	JC	A2H8L2			;AH>10 ��������ꎞ�ϊ��I��
	JMP	A2H8E1			;
A2H8L2:	XCHG	BX,DX			;
	MOV	CS:[BX],AH		;�ۑ�
	INC	BX			;
	XCHG	BX,DX			
	INC	CL			;
	CMP	CL,3			;�R��ϊ�������ꎞ�ϊ��I��
	JZ	A2H8E0			;�i�ő�R��( 0~255)�j
	JMP	A2H8L0			;
A2H8E1:
	DEC	BX			;
A2H8E0:
	CMP	CL,0			;���l�����i-, 0~9�j���������ꍇ
	JNZ	A2H8L3			;�W�����v
	STC				;����ȊO�A
	INC	BX			;�G���[�Ŗ߂�
	JMP	A2H8EE			;
A2H8L3:					;
	MOV	CH,0			;
	MOV	CS:[DHEX8],CH		;
	MOV	CH,CL			;CH���ꎞ�ϊ��ŕϊ�����������
	MOV	CL,3			;CL�����v�Z�p
	XCHG	BX,DX			;	3�10^0	2�10^1	1�10^2
A2H8L4:	
	DEC	BX			;
	MOV	AH,CS:[BX]		;
	CALL	A2H8AA			;���v�Z
	DEC	CL			;
	DEC	CH			;
	JNZ	A2H8L4			;��������
	XCHG	BX,DX			;
	MOV	AH,CS:[DHEX8]		;
	CMP	CS:[F8FLAG],00H		;
	JZ	A2H8L5			;
	NEG	AH			;
A2H8L5:	CLC				;
A2H8EE:	POP	DX			;
	POP	CX			;
	RET				;

;	*	*	*	*	*	*	*	*

A2H8AA:					;
	CMP	CL,1			;CL��	�P�̏ꍇ
	JNZ	A2H8C1			;AX��AH*100
	MOV	AL,100			;
	JMP	A2H8C3			;
A2H8C1:	CMP	CL,2			;	�Q�̏ꍇ
	JNZ	A2H8C2			;AX��AH*10
	MOV	AL,10			;
	JMP	A2H8C3			;
A2H8C2:	CMP	CL,3			;	�R�̏ꍇ
	JNZ	A2H8C4			;AX��AH*1
	MOV	AL,1			;
;	JMP	A2H8C3			;
A2H8C3:	CALL	KAKE8			;
	ADD	CS:[DHEX8],AL		;[DHEX8]��[DHEX8]*AX
	RET				;
A2H8C4:	MOV	CL,0			;�b�k������ȊO�̏ꍇ
	XCHG	BX,DX			;�G���[
	POP	DX			;
	MOV	DX,OFFSET A2H8EE	;
	PUSH	DX			;
	STC				;
	RET				;
;---------------------------------------------------------------|
;		�����Z���[�`��					|
;---------------------------------------------------------------|
;	����							|
;		AH���������鐔				|
;		AL�������鐔					|
;	�Ԃ�l							|
;		AX����						|
;---------------------------------------------------------------|
KAKE8:					;
	PUSH	CX			;
	PUSH	DX			;���W�X�^�ۑ�
	XOR	DX,DX			;DX��0000<h>
	MOV	CH,0			;CH��0
	MOV	CL,1			;CL��00000001<h>
KLOOP0:	TEST	AH,CL			;Bit check
	JZ	KLOOP1			;if 'L' then *KLOOP1
	CALL	KADD			;���Z����(DX+AL*2^CL)
KLOOP1:	INC	CH			;CH��CH+1
	SHL	CL,1			;CL Bit shift ��
	JNC	KLOOP0			;CL>128�ŏI��
	MOV	AX,DX			;
	POP	DX			;
	POP	CX			;���W�X�^���A
	RET				;RETURN
;		*************************
;		*	���Z����	*
;		*************************
KADD:					;
	PUSH	AX			;
	XOR	AH,AH			;AH��00h
	CMP	CH,1			;CH=1�Ȃ�Ή��Z�̂�
	JC	KADD1			;
	PUSH	CX			;
	MOV	CL,CH			;
	SHL	AX,CL			;AX��AX*2^CH
	POP	CX			;
KADD1:	ADD	DX,AX			;DX��DX+AX
	POP	AX			;
	RET				;
;****************************************************************
;*								*
;*		�P�U�i�R�[�h�P�O�i������ϊ����[�`��		*
;*								*
;****************************************************************
;---------------------------------------------------------------|
;		�P�U�i���R�[�h�`ASCII CODE(255)			|
;---------------------------------------------------------------|
;	����							|
;		�P�U�i�R�[�h���P�O�i�̃A�X�L�[�R�[�h�ɕϊ�	|
;	����							|
;		AH���ϊ����������l				|
;	�Ԃ�l							|
;		DX���ϊ�����������̐擪�A�h���X		|
;---------------------------------------------------------------|
	DB	'-'			;����
ASC_8	DB	'$$$$$'			;
HEX2ASC8:
	PUSH	AX			
	PUSH	BX			
	PUSH	CX			;���W�X�^�ۑ�
	MOV	BX,OFFSET ASC_8		
	MOV	AL,'$'			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		

	MOV	BX,OFFSET ASC_8		
	MOV	AL,' '			;
	CMP	AH,100			;
	JC	H2A8L3			;�P�O�O�̈ʂ���H
	
	MOV	AL,AH			
	XOR	AH,AH			
	MOV	CH,100			
	DIV	CH			
	ADD	AL,30H			
	MOV	CS:[BX],AL		
	INC	BX			
H2A8L3:	
	CMP	AL,' '			;AL=" "��������P�O�O�̈ʂ͖�������
	JNZ	H2A8E2			
	CMP	AH,10			;�P�O�̈ʂ���H
	JC	H2A8L2			
	
H2A8E2:	MOV	AL,AH			
	XOR	AH,AH			
	MOV	CH,10			
	DIV	CH			
	ADD	AL,30H			
	MOV	CS:[BX],AL		
	INC	BX			
H2A8L2:	
	ADD	AH,30H			;��̈ʂ͕K������
	MOV	CS:[BX],AH		;
	
	MOV	DX,OFFSET ASC_8		;�A�h���X
	POP	CX			
	POP	BX			
	POP	AX			
	RET				
;---------------------------------------------------------------|
;		�P�U�i���R�[�h�`ASCII CODE(65535)		|
;---------------------------------------------------------------|
;	����							|
;		�P�U�i�R�[�h���P�O�i�̃A�X�L�[�R�[�h�ɕϊ�	|
;	����							|
;		AX���ϊ����������l				|
;	�Ԃ�l							|
;		DX���ϊ�����������̐擪�A�h���X		|
;---------------------------------------------------------------|
	DB	'-'			;����
ASC_16	DB	'$$$$$$$'
HEX2ASC16:
	PUSH	AX			
	PUSH	BX			
	PUSH	CX			

	PUSH	AX			
	MOV	BX,OFFSET ASC_16	
	MOV	AL,'$'			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	POP	AX			

	MOV	BX,OFFSET ASC_16	
	MOV	CL,' '			
	MOV	DX,AX			
	CMP	DX,10000		;�P�O�O�O�O�̈ʂ͂���H
	JC	H2A6L5			
	
	XOR	DX,DX			
	MOV	CX,10000		
	DIV	CX			
	ADD	AL,30H			
	MOV	CL,AL			
	MOV	CS:[BX],CL		
	INC	BX			
H2A6L5:	
	CMP	CL,' '			
	JNZ	H2A6E4			
	CMP	DX,1000			;�P�O�O�O�̈ʂ́H
	JC	H2A6L4			
	
H2A6E4:	MOV	AX,DX			
	XOR	DX,DX			
	MOV	CX,1000			
	DIV	CX			
	ADD	AL,30H			
	MOV	CL,AL			
	MOV	CS:[BX],CL		
	INC	BX			
H2A6L4:	
	CMP	CL,' '			
	JNZ	H2A6E3			
	CMP	DX,100			;�P�O�O�̈�
	JC	H2A6L3			
	
H2A6E3:	MOV	AX,DX			
	XOR	DX,DX			
	MOV	CX,100			
	DIV	CX			
	ADD	AL,30H			
	MOV	CL,AL			
	MOV	CS:[BX],CL		
	INC	BX			
H2A6L3:	
	CMP	CL,' '			
	JNZ	H2A6E2			
	CMP	DX,10			;�P�O�̈ʂ́H
	JC	H2A6L2			

H2A6E2:	MOV	AX,DX			
	XOR	DX,DX			
	MOV	CX,10			
	DIV	CX			
	ADD	AL,30H			
	MOV	CL,AL			
	MOV	CS:[BX],CL		
	INC	BX			
H2A6L2:	
	MOV	AX,DX			
	ADD	AL,30H			
	MOV	CS:[BX],AL		;�P�̈ʂ͕K������
	
	MOV	DX,OFFSET ASC_16	
	POP	CX			
	POP	BX			
	POP	AX			
	RET				
;---------------------------------------------------------------|
;		�P�U�i���R�[�h�`ASCII CODE(255)	�i�����t���j	|
;---------------------------------------------------------------|
;	����							|
;		�P�U�i�R�[�h���P�O�i�̃A�X�L�[�R�[�h�ɕϊ�	|
;	����							|
;		AH���ϊ����������l				|
;	�Ԃ�l							|
;		DX���ϊ�����������̐擪�A�h���X		|
;---------------------------------------------------------------|
FH2A8:
	PUSH	AX			
	PUSH	BX			
	PUSH	CX			
	
	TEST	AH,80H			
	JZ	F2A8L0			
	NEG	AH			
	CALL	HEX2ASC8		
	DEC	DX			
	JMP	F2A8L2			
F2A8L0:	CALL	HEX2ASC8		
F2A8L2:	
	POP	CX			
	POP	BX			
	POP	AX			
	RET				
;---------------------------------------------------------------|
;		�P�U�i���R�[�h�`ASCII CODE(65535)�i�����t���j	|
;---------------------------------------------------------------|
;	����							|
;		�P�U�i�R�[�h���P�O�i�̃A�X�L�[�R�[�h�ɕϊ�	|
;	����							|
;		AH���ϊ����������l				|
;	�Ԃ�l							|
;		DX���ϊ�����������̐擪�A�h���X		|
;---------------------------------------------------------------|
FH2A16:
	PUSH	AX			
	PUSH	BX			
	PUSH	CX			
	
	TEST	AH,80H			
	JZ	F2A6L0			
	NEG	AX			
	CALL	HEX2ASC16		
	DEC	DX			
	JMP	F2A6L2			
F2A6L0:	CALL	HEX2ASC16		
F2A6L2:	
	POP	CX			
	POP	BX			
	POP	AX			
	RET				
;---------------------------------------------------------------|
;		�P�U�i���R�[�h�`ASCII CODE(255)			|
;---------------------------------------------------------------|
;	����							|
;		�P�U�i�R�[�h���P�O�i�̃A�X�L�[�R�[�h�ɕϊ�	|
;		�S���Ńt�H�[�}�b�g����B			|
;	����							|
;		AH���ϊ����������l				|
;	�Ԃ�l							|
;		DX���ϊ�����������̐擪�A�h���X		|
;---------------------------------------------------------------|
H2A8:
	PUSH	AX			
	PUSH	BX			
	PUSH	CX			
	MOV	BX,OFFSET ASC_8		
	MOV	CH,' '			
	MOV	CS:[BX],CH		
	INC	BX			
	
	MOV	AL,' '			
	CMP	AH,100			
	JC	H2A8L03			
	
	MOV	AL,AH			
	XOR	AH,AH			
	MOV	CH,100			
	DIV	CH			
	ADD	AL,30H			
H2A8L03:MOV	CS:[BX],AL		
	INC	BX			
	
	CMP	AL,' '			
	JNZ	H2A8E02			
	CMP	AH,10			
	JC	H2A8L02			
	
H2A8E02:MOV	AL,AH			
	XOR	AH,AH			
	MOV	CH,10			
	DIV	CH			
	ADD	AL,30H			
H2A8L02:MOV	CS:[BX],AL		

	INC	BX			
	
	ADD	AH,30H			
	MOV	CS:[BX],AH		
	
	MOV	DX,OFFSET ASC_8		
	POP	CX			
	POP	BX			
	POP	AX			
	RET				
;****************************************************************
;								*
;			�������֘A				*
;								*
;****************************************************************
;---------------------------------------------------------------|
;		�������m�ہiWTD Data�j				|
;---------------------------------------------------------------|
Memory_Open:				;
	MOV	AH,48H			;
	MOV	BX,1000H		;64KByte �̃f�[�^�̈�̊m��
	INT	21H			;
	JNC	Memory_Open_Err		;���蓖�Ď��s���ɔ�ԁB
	JMP	MOPEN_ERROR		;
Memory_Open_Err:			;
	MOV	CS:[segWtd_File],AX	;���蓖�Ă��Z�O�����g�A�h���X�̕ۑ��B
	MOV	DS,AX			;DS��Segment�̐ݒ�
	RET				;
;---------------------------------------------------------------|
;		�������J���iWTD Data�j				|
;---------------------------------------------------------------|
Memory_Close:				;
	MOV	AX,CS:[segWtd_File]	;
	MOV	ES,AX			;�Z�O�����g��ǂށB
	MOV	AH,49H			;
	INT	21H			;�f�[�^�̈�̊J��
	JNC	Memory_Close_Err	;
	JMP	CLOSE_ERROR		;
Memory_Close_Err:			;
	RET				;
;---------------------------------------------------------------|
;								|
;		�b�n�l�t�@�C���̃������[�ŏ���			|
;---------------------------------------------------------------|
;	����							|
;		�b�n�l�v���O�������s���Ƀ������[��		|
;		�ŏ����ɂ���					|
;	����							|
;		����						|
;	�Ԃ�l							|
;		DS��CS						|
;	��	Cy��'L' �̂Ƃ��B�i����I���j			|
;		BX���ύX�����������[�̑傫���B			|
;	��	Cy��'H' �̂Ƃ��B�i�G���[�j			|
;		BX���ύX�ł���ő�̑傫��			|
;		AX��INT21H ̧ݸ���4AH�Q��			|
;---------------------------------------------------------------|
ComSmoleMessage7	DB	"�v���O�����ɂ�郁�����[���̃f�[�^�[�̔j��B",0DH,0AH,"$"
ComSmoleMessage8	DB	"�\���ȋ󂫃������[�������B",0DH,0AH,"$"
ComSmoleMessage9	DB	"�s���ȃ������[�u���b�N�̎g�p�B",0DH,0AH,"$"
ComSmole:			;�������[�̍ŏ���
	PUSH	DX		;
	PUSH	CX		;���W�X�^�̕ۑ�
	
	MOV	ES,CS:[002CH]	;���Z�O�����g�̊J��
	MOV	AH,49H		;
	INT	21H		;
	
	MOV	AX,CS		;
	MOV	DS,AX		;DS��CS
	MOV	ES,AX		;ES��CS
	MOV	BX,OFFSET WTD_UnMML_Compiler_End+BSTACK
	MOV	CL,4		;
	SHR	BX,CL		;
	INC	BX		;BX���v���O�����̑傫���i�p���O���t�P�ʁj
	MOV	AH,04AH		;
	INT	21H		;�ŏ���
	PUSH	BX		;
	PUSH	AX		;�Ԃ�l�̕ۑ�
	JC	ComSmoleERR	;�G���[���ɔ��
	CLC			;Cy��'L'
	JMP	ComSmoleRET	;RETURN
;===============================================================|
ComSmoleERR:			;�t�@���N�V����4AH �̂d�q�q�n�q
	CMP	AX,07H		;
	JNZ	ComSmoleER8	;ERROR CODE=07H
	MOV	AH,09H		;
	MOV	DX,OFFSET ComSmoleMessage7
	INT	21H		;���b�Z�[�W�̕\��
	STC			;Cy��'H'
	JMP	ComSmoleRET	;RETURN
ComSmoleER8:
	CMP	AX,08H		;
	JNZ	ComSmoleER9	;ERROR CODE=08H
	MOV	AH,09H		;
	MOV	DX,OFFSET ComSmoleMessage8
	INT	21H		;���b�Z�[�W�̕\��
	STC			;Cy��'L'
	JMP	ComSmoleRET	;RETURN
ComSmoleER9:
	MOV	AH,09H		;ERROR CODE=09H
	MOV	DX,OFFSET ComSmoleMessage9
	INT	21H		;���b�Z�[�W�̕\��
	STC			;Cy��'H'
	JMP	ComSmoleRET	;RETURN
;===============================================================|
ComSmoleRET:			;�q�d�s�t�q�m
	POP	AX		;
	POP	BX		;
	POP	CX		;���W�X�^�[�̕��A
	POP	DX		;
	RET			;RETURN
;---------------------------------------------------------------|
;		�G���[����					|
;---------------------------------------------------------------|
P_TAB	DB	"	$"
P	DB	0DH,0AH,'$'
ERROR	DB	'�t�@�C����������܂���B',0DH,0AH,'$'
RERROR	DB	'�t�@�C����ǂ߂܂���B',0AH,0DH,24H
MEMERR	DB	'������������܂���B',0AH,0DH,24H
OERROR	DB	'�I�[�v���Ɏ��s���܂���',0DH,0AH,'$'
CERROR	DB	'�N���[�Y�Ɏ��s���܂���',0DH,0AH,'$'
OPERROR	DB	"����s�\�ł��B",0DH,0AH,24H

D_SEG:	MOV	AX,ES			;
	MOV	DS,AX			;DS��Data
	ADD	DX,1000H		;
	RET				;
C_SEG:	MOV	AX,CS			;
	MOV	DS,AX			;DS��Program
	RET				;
LPRINT:	MOV	AH,09H			;
	INT	21H			;PRINT
	RET				;
LOAD_ERROR:
	MOV	DX,OFFSET ERROR		;
PRINT:	MOV	AX,CS			;
	MOV	DS,AX			;
	MOV	AH,09H			;
	INT	21H			;
	JMP	COMEND			;
;FILE_ERROR:
;	MOV	DX,OFFSET FERROR	;
;	JMP	PRINT			;
MOPEN_ERROR:
	MOV	DX,OFFSET MEMERR	;
	JMP	PRINT			;
OPEN_ERROR:
	MOV	DX,OFFSET OERROR	;
	JMP	PRINT			;
CLOSE_ERROR:
	MOV	DX,OFFSET CERROR	;
	JMP	PRINT			;
READ_ERROR:
	MOV	DX,OFFSET RERROR	;
	JMP	PRINT			;
SOPEN_ERROR:
	CMP	AX,3
	MOV	DX,OFFSET FSERR3
	JMP	PRINT
	CMP	AX,4
	MOV	DX,OFFSET FSERR4
	JMP	PRINT
	CMP	AX,5
	MOV	DX,OFFSET FSERR5
	JMP	PRINT
FSERR3	DB	'�w�肳�ꂽ�p�X�E�t�@�C������������܂���B',0AH,0DH,24H
FSERR4	DB	'�����ɃI�[�v������Ă���t�@�C�������������܂��B',0AH,0DH,24H
FSERR5	DB	'�A�N�Z�X�����ۂ���܂����B',0AH,0DH,24H
OPTION_ERROR:
	MOV	DX,OFFSET OPERROR	;
	JMP	LPRINT			;

