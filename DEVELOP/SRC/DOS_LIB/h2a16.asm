
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
;		�P�U�i���R�[�h�`ASCII CODE(65535)		|
;---------------------------------------------------------------|
;	����							|
;		�P�U�i�R�[�h���P�O�i�̃A�X�L�[�R�[�h�ɕϊ�	|
;	����							|
;		AX���ϊ����������l				|
;	�Ԃ�l							|
;		DX���ϊ�����������̐擪�A�h���X		|
;---------------------------------------------------------------|
.data
	DB	'-'			;����
ASC_16	DB	'$$$$$$$'
H2A_Div	dw	10000,1000,100,10,1
.code
HEX2ASC16	proc	near	uses ax bx cx di es

	local	flag:byte

	push	cs
	pop	es
	lea	di, [ASC_16]		;es:di �� �ϊ���A�h���X
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
	lea	dx, [ASC_16]		;es:di �� �ϊ���A�h���X

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
;	CMP	DX,10000		;�P�O�O�O�O�̈ʂ͂���H
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
;	CMP	DX,1000			;�P�O�O�O�̈ʂ́H
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
;	CMP	DX,100			;�P�O�O�̈�
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
;	CMP	DX,10			;�P�O�̈ʂ́H
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
;	MOV	CS:[BX],AL		;�P�̈ʂ͕K������
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
