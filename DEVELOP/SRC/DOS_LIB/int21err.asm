
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
;		�G���[�I��					|
;---------------------------------------------------------------|
;	������							|
;		ax Error Code					|
;---------------------------------------------------------------|
.const
Error_MsgOffset	dw	offset	Err_M00
		dw	offset	Err_M01
		dw	offset	Err_M02
		dw	offset	Err_M03
		dw	offset	Err_M04
		dw	offset	Err_M05
		dw	offset	Err_M06
		dw	offset	Err_M07
		dw	offset	Err_M08
		dw	offset	Err_M09
		dw	offset	Err_M0A
		dw	offset	Err_M0B
		dw	offset	Err_M0C
		dw	offset	Err_M0D
		dw	offset	Err_M0E
		dw	offset	Err_M0F

Err_M00	db	'Err=0x00:����',0dh,0ah,24h
Err_M01	db	'Err=0x01:�����ȋ@�\�R�[�h�ł��B',0dh,0ah,24h
Err_M02	db	'Err=0x02:�t�@�C�������݂��܂���B',0dh,0ah,24h
Err_M03	db	'Err=0x03:�w�肳�ꂽ�p�X�������ł�',0dh,0ah,24h
Err_M04	db	'Err=0x04:�I�[�v������Ă���t�@�C���������ł��B',0dh,0ah,24h
Err_M05	db	'Err=0x05:�A�N�Z�X�����ۂ���܂����B',0dh,0ah,24h
Err_M06	db	'Err=0x06:�w�肳�ꂽ�t�@�C���́A���݃I�[�v������Ă��܂���B',0dh,0ah,24h
Err_M07	db	'Err=0x07:Memory Control Block���j�󂳂�Ă��܂��B',0dh,0ah,24h
Err_M08	db	'Err=0x08:�\���ȑ傫���̃�����������܂���B',0dh,0ah,24h
Err_M09	db	'Err=0x09:�w�肳�ꂽ�������[�́A���蓖�Ă��Ă��܂���B',0dh,0ah,24h
Err_M0A	db	'Err=0x0A:���ϐ���32kByte�ȏ゠��܂��B',0dh,0ah,24h
Err_M0B	db	'Err=0x0B:�w�肳�ꂽ�t�@�C����exe�w�b�_�[������������܂���B',0dh,0ah,24h
Err_M0C	db	'Err=0x0C:�t�@�C���A�N�Z�X�R�[�h��0�`2�͈̔͊O�ł�',0dh,0ah,24h
Err_M0D	db	'Err=0x0D:�w�肳�ꂽ�f�o�C�X�͖����ł��B',0dh,0ah,24h
Err_M0E	db	'Err=0x0E:�H',0dh,0ah,24h
Err_M0F	db	'Err=0x0F:�w�肳�ꂽ�h���C�u�ԍ��͖����ł��B',0dh,0ah,24h
.code
File_Err	proc	near

		push	ds
		push	dx
		push	ax
		mov	bx,offset Error_MsgOffset
		shl	ax,1			;
		add	bx,ax			;
		mov	dx,cs:[bx]		;
		push	cs			;
		pop	ds			;

		mov	AH,09H			;
		int	21H			;
		pop	ax
		pop	dx
		pop	ds

	.if	((ax==02h)||(ax==03h)||(ax==0Bh)||(ax==0Ch))
		mov	AH,09H			;
		int	21H			;
	.endif

		.exit	255
File_Err	endp
;****************************************************************
	end
