
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
;		�J�����g�f�B���N�g���̕ύX			|
;---------------------------------------------------------------|
;	������							|
;		cDirname	�f�B���N�g����			|
;---------------------------------------------------------------|
.const
Current_Directory_Mess1	DB	'�J�����g�f�B���N�g����',24h
Current_Directory_Mess2	DB	'�ɕύX���܂����B',0dh,0ah,24h
.code
Change_Current_Directory	proc	near	uses ds es,
		cDirname:dword
	local	Current_Directory[128]:byte

	pusha

	;-------------------------------
	;�J�����g�f�B���N�g�����邩�H
	lds	si,cDirname
	push	ss
	pop	es
	lea	di,[Current_Directory]
	xor	cx,cx
	xor	bx,bx
	push	si
	.repeat
	   lodsb
	   .if		(al=='\')
		mov	bx,cx	;��ԍŌ��'\'��bx�ɋL������B
	   .endif
	   inc	cx
	.until	(al<21h)
	pop	si

	;-------------------------------
	;�J�����g�f�B���N�g������ݒ�
	.if	(bx>0)
		mov	cx,bx
		cld
		rep	movsb
		mov	al,00H
		stosb
		mov	al,24H
		stosb

		;-------------------------------
		;�J�����g�f�B���N�g����ύX����B
		push	ss
		pop	ds
		lea	dx,[Current_Directory]
		mov	ah,3BH			;
		int	21h			;
		.if	(carry?)
		jmp	File_Err
		.endif
		push	cs
		pop	ds
		lea	dx,[Current_Directory_Mess1]
		mov	ah,09H			;
		int	21h			;

		push	ss			;
		pop	ds			;
		lea	dx,[Current_Directory]	;
		mov	ah,09H			;
		int	21h			;

		push	cs			;
		pop	ds			;
		lea	dx,[Current_Directory_Mess2]
		mov	ah,09H			;
		int	21h			;
	.endif
	;-------------------------------
	;�I��

	popa
	ret				;
Change_Current_Directory	endp
;****************************************************************
	end
