
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
;		AH���ϊ����������l				|
;	�Ԃ�l							|
;		DX���ϊ�����������̐擪�A�h���X		|
;---------------------------------------------------------------|
;.data
;ASC_8	DB	'$$$$$'			;
.code
H2A8		proc	near	uses	ax

	mov	al,ah
	and	ax,00FFh
	invoke	H2A_F,	ax,3
	ret

;	PUSH	AX			
;	PUSH	BX			
;	PUSH	CX			
;	MOV	BX,OFFSET ASC_8		
;	MOV	CH,' '			
;	MOV	CS:[BX],CH		
;	INC	BX			
;	
;	MOV	AL,' '			
;	CMP	AH,100			
;	JC	H2A8L03			
;	
;	MOV	AL,AH			
;	XOR	AH,AH			
;	MOV	CH,100			
;	DIV	CH			
;	ADD	AL,30H			
;H2A8L03:MOV	CS:[BX],AL		
;	INC	BX			
;	
;	CMP	AL,' '			
;	JNZ	H2A8E02			
;	CMP	AH,10			
;	JC	H2A8L02			
;	
;H2A8E02:MOV	AL,AH			
;	XOR	AH,AH			
;	MOV	CH,10			
;	DIV	CH			
;	ADD	AL,30H			
;H2A8L02:MOV	CS:[BX],AL		
;
;	INC	BX			
;	
;	ADD	AH,30H			
;	MOV	CS:[BX],AH		
;	
;	MOV	DX,OFFSET ASC_8		
;	POP	CX			
;	POP	BX			
;	POP	AX			
;	RET				
H2A8		endp
;****************************************************************
	end
