
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
;		ASCII CODE���P�U�i�R�[�h(-127�`255)		|
;---------------------------------------------------------------|
;	����							|
;		DS:DX���ϊ�������������擪�A�h���X		|
;	�Ԃ�l							|
;		AH���ϊ���					|
;		DS:BX�����̃A�h���X				|
;---------------------------------------------------------------|
.code
ASC2HEX8	proc	near	uses cx
	push	ax
	invoke	ASC2HEX16
	mov	cl, al
	pop	ax
	mov	ah, cl
	RET				;
ASC2HEX8	endp			;
;****************************************************************
	end