
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
;		１６進数コード〜ASCII CODE(65535)		|
;---------------------------------------------------------------|
;	処理							|
;		１６進コードを１０進のアスキーコードに変換	|
;	引数							|
;		AX←変換したい数値				|
;	返り値							|
;		DX←変換した文字列の先頭アドレス		|
;---------------------------------------------------------------|
.data
	DB	'-'			;符号
ASC_16	DB	'$$$$$$$'
H2A_Div	dw	10000,1000,100,10,1
.code
HEX2ASC16	proc	near	uses ax bx cx di es

	local	flag:byte

	push	cs
	pop	es
	lea	di, [ASC_16]		;es:di ← 変換先アドレス
	xor	bx, bx
	mov	flag, bl		;flag reset
	mov	cx, 5
	mov	dx, ax
	.repeat
	   .if	( (ax >= word ptr cs:[H2A_Div + bx]) || (flag != 0)  || (cx==1))
		mov	flag, 1
		mov	ax, dx
		xor	dx, dx
		div	word ptr cs:[H2A_Div + bx]
		add	al,30h
		stosb
	   .endif
	   add	bx,2
	   dec	cx
	.until	(zero?)
	mov	word ptr es:[di], '$'
	lea	dx, [ASC_16]		;es:di ← 変換先アドレス

	ret


;	PUSH	AX			
;	PUSH	BX			
;	PUSH	CX			
;
;	PUSH	AX			
;	MOV	BX,OFFSET ASC_16	
;	MOV	AL,'$'			
;	MOV	CS:[BX],AL		
;	INC	BX			
;	MOV	CS:[BX],AL		
;	INC	BX			
;	MOV	CS:[BX],AL		
;	INC	BX			
;	MOV	CS:[BX],AL		
;	INC	BX			
;	MOV	CS:[BX],AL		
;	INC	BX			
;	MOV	CS:[BX],AL		
;	INC	BX			
;	MOV	CS:[BX],AL		
;;	INC	BX			
;;	MOV	CS:[BX],AL		
;	POP	AX			
;
;	MOV	BX,OFFSET ASC_16	
;	MOV	CL,' '			
;	MOV	DX,AX			
;	CMP	DX,10000		;１００００の位はある？
;	JC	H2A6L5			
;	
;	XOR	DX,DX			
;	MOV	CX,10000		
;	DIV	CX			
;	ADD	AL,30H			
;	MOV	CL,AL			
;	MOV	CS:[BX],CL		
;	INC	BX			
;H2A6L5:	
;	CMP	CL,' '			
;	JNZ	H2A6E4			
;	CMP	DX,1000			;１０００の位は？
;	JC	H2A6L4			
;	
;H2A6E4:	MOV	AX,DX			
;	XOR	DX,DX			
;	MOV	CX,1000			
;	DIV	CX			
;	ADD	AL,30H			
;	MOV	CL,AL			
;	MOV	CS:[BX],CL		
;	INC	BX			
;H2A6L4:	
;	CMP	CL,' '			
;	JNZ	H2A6E3			
;	CMP	DX,100			;１００の位
;	JC	H2A6L3			
;	
;H2A6E3:	MOV	AX,DX			
;	XOR	DX,DX			
;	MOV	CX,100			
;	DIV	CX			
;	ADD	AL,30H			
;	MOV	CL,AL			
;	MOV	CS:[BX],CL		
;	INC	BX			
;H2A6L3:	
;	CMP	CL,' '			
;	JNZ	H2A6E2			
;	CMP	DX,10			;１０の位は？
;	JC	H2A6L2			
;
;H2A6E2:	MOV	AX,DX			
;	XOR	DX,DX			
;	MOV	CX,10			
;	DIV	CX			
;	ADD	AL,30H			
;	MOV	CL,AL			
;	MOV	CS:[BX],CL		
;	INC	BX			
;H2A6L2:	
;	MOV	AX,DX			
;	ADD	AL,30H			
;	MOV	CS:[BX],AL		;１の位は必ず書く
;	
;	MOV	DX,OFFSET ASC_16	
;	POP	CX			
;	POP	BX			
;	POP	AX			
;
;	RET				
HEX2ASC16	endp
;****************************************************************
	end
