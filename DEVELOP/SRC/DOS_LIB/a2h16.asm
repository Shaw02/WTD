
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
;		ASCII CODE→１６進コード(-32768～65535)		|
;---------------------------------------------------------------|
;	引数							|
;		DS:DX←変換したい文字列先頭アドレス		|
;	返り値							|
;		AX←変換後					|
;		DS:BX←次のアドレス				|
;---------------------------------------------------------------|
.data
A2H_MUL	dw	1,10,100,1000,10000
.code
ASC2HEX16	proc	near	uses cx dx di si es

	local	dhex8	:WORD
	local	hex_8[5]:BYTE
	local	f8flag	:BYTE

	push	ss			;◆初期化
	pop	es
	lea	di, hex_8		;es:di 保存先
	mov	si, dx			;ds:si 読込元
	xor	cx, cx
	mov	dhex8,	cx		
	mov	f8flag,	cl		;flag reset

	.if	(byte ptr ds:[si] == '-')	;◆符号チェック
		inc	si
		mov	f8flag, 0F8h
	.endif
	.repeat				;◆読み込み＆一次保存
	   lodsb
	   sub	al,30h
	   .break .if	( (carry?) || (al>=10) )
	   stosb
	   inc	cx
	.until		(cx >= 5)
	.if		(cx > 0)	;◆変換
	   dec	si	;ポインターを戻す
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
