
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
;		�P�U�i���R�[�h�`ASCII CODE(255)			|
;---------------------------------------------------------------|
;	����							|
;		�P�U�i�R�[�h���P�O�i�̃A�X�L�[�R�[�h�ɕϊ�	|
;		�X�y�[�X�ŁA�E����				|
;	����							|
;		iValue	�ϊ����������l				|
;		iForm	���`������ (5�`1)			|
;	�Ԃ�l							|
;		DX���ϊ�����������̐擪�A�h���X		|
;---------------------------------------------------------------|
.data
	DB	'-'			;����
ASC	DB	'$$$$$$$'
H2A_Div	dw	10000,1000,100,10,1
.code
H2A_F	proc	near	uses ax bx cx di es,
	iValue	:WORD,
	iForm	:WORD

	local	flag:byte

	push	cs
	pop	es
	lea	di, [ASC]		;es:di �� �ϊ���A�h���X
	mov	flag, bl		;flag reset
	mov	cx, iForm
	mov	dx, iValue
	mov	bx, 5
	sub	bx, cx
	shl	bx, 1
	.repeat
	   .if	( (ax >= word ptr cs:[H2A_Div + bx]) || (flag != 0) || (cx==1))
		mov	flag, 1
		mov	ax, dx
		xor	dx, dx
		div	word ptr cs:[H2A_Div + bx]
		add	al,30h
	   .elseif
		mov	al,' '
	   .endif
	   stosb
	   add	bx,2
	   dec	cx
	.until	(zero?)
	mov	word ptr es:[di], '$'
	lea	dx, [ASC]		;es:di �� �ϊ���A�h���X

	ret
H2A_F	endp
;****************************************************************
	end
