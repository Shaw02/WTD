
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
;	����							|
;		AH���ϊ����������l				|
;	�Ԃ�l							|
;		DX���ϊ�����������̐擪�A�h���X		|
;---------------------------------------------------------------|
;.data
;	DB	'-'			;����
;ASC_8	DB	'$$$$$'			;
.code
HEX2ASC8	proc	near	uses ax

	mov	al,ah
	and	ax,00FFh
	invoke	HEX2ASC16
	ret

;	MOV	BX,OFFSET ASC_8		
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
;
;	MOV	BX,OFFSET ASC_8		
;	MOV	AL,' '			;
;	CMP	AH,100			;
;	JC	H2A8L3			;�P�O�O�̈ʂ���H
;	
;	MOV	AL,AH			
;	XOR	AH,AH			
;	MOV	CH,100			
;	DIV	CH			
;	ADD	AL,30H			
;	MOV	CS:[BX],AL		
;	INC	BX			
;H2A8L3:	
;	CMP	AL,' '			;AL=" "��������P�O�O�̈ʂ͖�������
;	JNZ	H2A8E2			
;	CMP	AH,10			;�P�O�̈ʂ���H
;	JC	H2A8L2			
;	
;H2A8E2:	MOV	AL,AH			
;	XOR	AH,AH			
;	MOV	CH,10			
;	DIV	CH			
;	ADD	AL,30H			
;	MOV	CS:[BX],AL		
;	INC	BX			
;H2A8L2:	
;	ADD	AH,30H			;��̈ʂ͕K������
;	MOV	CS:[BX],AH		;
;	
;	MOV	DX,OFFSET ASC_8		;�A�h���X
;
;	RET				
HEX2ASC8	endp
;****************************************************************
	end
