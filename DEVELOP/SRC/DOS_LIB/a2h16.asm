
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
;		ASCII CODE���P�U�i�R�[�h(-32768�`65535)		|
;---------------------------------------------------------------|
;	����							|
;		DS:DX���ϊ�������������擪�A�h���X		|
;	�Ԃ�l							|
;		AX���ϊ���					|
;		DS:BX�����̃A�h���X				|
;---------------------------------------------------------------|
.data
A2H_MUL	dw	1,10,100,1000,10000
.code
ASC2HEX16	proc	near	uses cx dx di si es

	local	dhex8	:WORD
	local	hex_8[5]:BYTE
	local	f8flag	:BYTE

	push	ss			;��������
	pop	es
	lea	di, hex_8		;es:di �ۑ���
	mov	si, dx			;ds:si �Ǎ���
	xor	cx, cx
	mov	dhex8,	cx		
	mov	f8flag,	cl		;flag reset

	.if	(byte ptr ds:[si] == '-')	;�������`�F�b�N
		inc	si
		mov	f8flag, 0F8h
	.endif
	.repeat				;���ǂݍ��݁��ꎟ�ۑ�
	   lodsb
	   sub	al,30h
	   .break .if	( (carry?) || (al>=10) )
	   stosb
	   inc	cx
	.until		(cx >= 5)
	.if		(cx > 0)	;���ϊ�
	   dec	si	;�|�C���^�[��߂�
	   xor	bx, bx
	   .repeat
		dec	di
		xor	ax, ax
		mov	al, es:[di]
		mul	cs:[A2H_MUL + bx]
		add	DHEX8, ax
		add	bx, 2
		dec	cx
	   .until	(zero?)
	   mov	ax, DHEX8
	   .if	(f8flag != 0)
		neg	ax
	   .endif
	   clc		;Not Error
	.else
Error:	   stc		;Error
	.endif
	mov	bx, si

	RET				;
ASC2HEX16	endp			;
;;****************************************************************
	end
