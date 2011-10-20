
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
;		�P�U�i���R�[�h�`ASCII CODE(FF)			|
;---------------------------------------------------------------|
;	����							|
;		�P�U�i�R�[�h���P�U�i�̃A�X�L�[�R�[�h�ɕϊ�	|
;	����							|
;		ax���ϊ����������l				|
;	�Ԃ�l							|
;		CS:DX���ϊ�����������̐擪�A�h���X		|
;	�R�����g						|
;		���̏������́A�������̋ߍ����B			|
;---------------------------------------------------------------|
.data
dat2hex16_Print	db	'0000$'
.code
dat2hex16	proc	near	uses ax

		mov	dx,ax		;
		shr	ax,4		; ax <- ---- FEDC BA98 7654
		and	dx,0f0fh	; dx <- ---- BA98 ---- 3210
		and	ax,0f0fh	; ax <- ---- FEDC ---- 7654

		.if	(dl>9)
			add	dl,7
		.endif

		.if	(dh>9)
			add	dh,7
		.endif

		.if	(al>9)
			add	al,7
		.endif

		.if	(ah>9)
			add	ah,7
		.endif

		add	dx,3030h
		add	ax,3030h

		xchg	dl,ah

		mov	word ptr cs:[dat2hex16_Print + 2],ax
		mov	ax,dx
		mov	word ptr cs:[dat2hex16_Print + 0],ax

		push	cs		;
		pop	ds		;ds:dx��far &(dat2hex8_Print)
		mov	dx,offset dat2hex16_Print

		ret			;
dat2hex16	endp			;
;****************************************************************
	end
