
	.186
	.model	tiny,stdcall


;****************************************************************
;*		�O���錾					*
;****************************************************************
include	lib_dos.inc


;****************************************************************
;*		�R�[�h						*
;****************************************************************
;---------------------------------------------------------------|
;		�d�w�d�t�@�C���̃������[�ŏ���			|
;---------------------------------------------------------------|
;	����							|
;		�d�w�d�v���O�������s���Ƀ������[��		|
;		�ŏ����ɂ���					|
;	����							|
;		szDGROUP	DGROUP�̃T�C�Y�i�X�^�b�N�܂ށj	|
;		ES		Segment address of PSP		|
;		DS		Segment address of DGROUP	|
;	�Ԃ�l							|
;		����						|
;---------------------------------------------------------------|
.code
ExeSmole	proc	near	uses ax bx es,	;�������[�̍ŏ���
		szDGROUP:WORD

;	EXE�������̍ŏ���
;	size = (DS - ES) + (stack/16)

	mov	bx, ds
	mov	ax, es
	sub	bx, ax
	mov	ax, szDGROUP
	shr	ax,4
	add	bx,ax
	MOV	AH,04AH		;
	INT	21H		;�ŏ���
	.if	(carry?)
	invoke	File_Err
	.endif

	push	es:[002CH]	;���Z�O�����g�̊J��
	pop	es		;
	MOV	AH,49H		;
	INT	21H		;
	.if	(carry?)
	invoke	File_Err
	.endif

	ret			;RETURN
ExeSmole	endp		;
;****************************************************************
	end
