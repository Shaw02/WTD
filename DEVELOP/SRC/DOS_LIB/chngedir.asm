
	.186
	.model	tiny,stdcall


;****************************************************************
;*		外部宣言					*
;****************************************************************
include	lib_dos.inc


;****************************************************************
;*		コード						*
;****************************************************************
;---------------------------------------------------------------|
;		カレントディレクトリの変更			|
;---------------------------------------------------------------|
;	●引数							|
;		cDirname	ディレクトリ名			|
;---------------------------------------------------------------|
.const
Current_Directory_Mess1	DB	'カレントディレクトリを',24h
Current_Directory_Mess2	DB	'に変更しました。',0dh,0ah,24h
.code
Change_Current_Directory	proc	near	uses ds es,
		cDirname:dword
	local	Current_Directory[128]:byte

	pusha

	;-------------------------------
	;カレントディレクトリあるか？
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
		mov	bx,cx	;一番最後の'\'をbxに記憶する。
	   .endif
	   inc	cx
	.until	(al<21h)
	pop	si

	;-------------------------------
	;カレントディレクトリ名を設定
	.if	(bx>0)
		mov	cx,bx
		cld
		rep	movsb
		mov	al,00H
		stosb
		mov	al,24H
		stosb

		;-------------------------------
		;カレントディレクトリを変更する。
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
	;終了

	popa
	ret				;
Change_Current_Directory	endp
;****************************************************************
	end
