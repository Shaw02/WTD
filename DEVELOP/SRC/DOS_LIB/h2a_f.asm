
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
;		１６進数コード～ASCII CODE(255)			|
;---------------------------------------------------------------|
;	処理							|
;		１６進コードを１０進のアスキーコードに変換	|
;		スペースで、右揃え				|
;	引数							|
;		iValue	変換したい数値				|
;		iForm	整形文字数 (5～1)			|
;	返り値							|
;		DX←変換した文字列の先頭アドレス		|
;---------------------------------------------------------------|
.data
	DB	'-'			;符号
ASC	DB	'$$$$$$$'
H2A_Div	dw	10000,1000,100,10,1
.code
H2A_F	proc	near	uses ax bx cx di es,
	iValue	:WORD,
	iForm	:WORD

	local	flag:byte

	push	cs
	pop	es
	lea	di, [ASC]		;es:di ← 変換先アドレス
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
	lea	dx, [ASC]		;es:di ← 変換先アドレス

	ret
H2A_F	endp
;****************************************************************
	end
