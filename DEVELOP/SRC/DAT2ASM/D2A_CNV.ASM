;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				Convert Routine				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;---------------------------------------------------------------|
;		�R���o�[�g�@���C�����[�`��			|
;---------------------------------------------------------------|
;	������							|
;		al	�f�[�^					|
;	���Ԃ�l						|
;		ds:dx	������̃A�h���X			|
;---------------------------------------------------------------|
dat2hex8_Print:	db	'00$'
dat2hex8	proc	near		;
		push	ax		;
		push	bx		;���W�X�^�[�ۑ�

		mov	ah,al		;
		shr	al,4		;ah������4bit
		and	ax,0f0fh	;al�����4bit

		cmp	al,0ah		;
		jc	dat2hex8_Low	;����4bit��0x0A�ȉ��H
		add	al,7		;
dat2hex8_Low:				;
		cmp	ah,0ah		;
		jc	dat2hex8_Hi	;���4bit��0x0A�ȉ��H
		add	ah,7		;
dat2hex8_Hi:				;
		add	ax,3030h	;

		push	cs		;
		pop	ds		;ds:dx��far &(dat2hex8_Print)
		mov	dx,offset dat2hex8_Print

		mov	bx,dx		;�����񏑍���
		mov	word ptr cs:[bx],ax

		pop	bx		;���W�X�^�[���A
		pop	ax		;
		ret			;
dat2hex8	endp			;
;---------------------------------------------------------------|
;		�R���o�[�g�@���C�����[�`��			|
;---------------------------------------------------------------|
;	������							|
;			����					|
;	���Ԃ�l						|
;			����					|
;	�����W�X�^						|
;		es:bx	�ϊ����̃|�C���^			|
;		cx	�T�C�Y�p�J�E���^			|
;		ds:dx	������\���p				|
;---------------------------------------------------------------|
convert_ptStr	dw	offset convert_strDB
		dw	offset convert_strDW
		dw	offset convert_strDW	;Dummy
		dw	offset convert_strDD
convert_strDB	db	'	DB	0$'
convert_strDW	db	'	DW	0$'
convert_strDD	db	'	DD	0$'
convert_strh	db	'h',0dh,0ah,24h
convert_strCR	db	0dh,0ah,24h
convert		proc	near		;
		pusha			;
		push	si		;
		push	ds		;
		push	es		;���W�X�^�ۑ�

		mov	ax,word ptr cs:[segWtd_File]
		mov	es,ax		;es���������̃A�h���X
		mov	bx,0		;es:bx

		push	cs		;
		pop	ds		;ds��cs

		;���[�v��
		mov	cx,word ptr cs:[szWtd_File]
convert_loop:
		;printf("	DB	0")
		push	bx		;
		mov	bx,offset convert_ptStr
		mov	ax,word ptr cs:[OP_FLAG_LEN]
		dec	ax		;
		shl	ax,1		;
		add	bx,ax		;
		mov	dx,word ptr cs:[bx]
		mov	ah,9		;
		int	21h		;
		pop	bx		;

		push	cx		;�f�[�^�������A���[�v
		mov	cx,word ptr cs:[OP_FLAG_LEN]
convert_loop_l:
		;printf("%02x",[bx])
		mov	si,cx		;
		mov	al,byte ptr es:[bx+si-1]
		call	dat2hex8	;������ϊ�
		mov	ah,9		;
		int	21h		;�ϊ����ʕ\��
		loop	convert_loop_l	;

		;printf("h\n")
		mov	dx,offset convert_strh
		mov	ah,9		;
		int	21h		;

		pop	cx		;�T�C�Y���A

		mov	ax,word ptr cs:[OP_FLAG_LEN]
		add	bx,ax		;bx+=OP_FLAG_LEN
		sub	cx,ax		;cx-=OP_FLAG_LEN

		pushf			;
		mov	ax,0008h	;
		mul	word ptr cs:[OP_FLAG_LEN]
		dec	ax		;
		test	bx,ax		;
		jnz	convert_ChkOct	;if(0==(cx&0x0007)){
		mov	dx,offset convert_strCR
		mov	ah,9		;	printf("\n");
		int	21h		;};
convert_ChkOct:
		popf			;
		jz	convert_ChkSz	;
		jc	convert_ChkSz	;
		jmp	convert_loop	;
convert_ChkSz:				;

convert_end:				;
		pop	es		;���W�X�^���A
		pop	ds		;
		pop	si		;
		popa			;
		ret			;
convert		endp			;