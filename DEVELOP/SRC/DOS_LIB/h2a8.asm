
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
;	引数							|
;		AH←変換したい数値				|
;	返り値							|
;		DX←変換した文字列の先頭アドレス		|
;---------------------------------------------------------------|
;.data
;	DB	'-'			;符号
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
;	JC	H2A8L3			;１００の位ある？
;	
;	MOV	AL,AH			
;	XOR	AH,AH			
;	MOV	CH,100			
;	DIV	CH			
;	ADD	AL,30H			
;	MOV	CS:[BX],AL		
;	INC	BX			
;H2A8L3:	
;	CMP	AL,' '			;AL=" "だったら１００の位は無かった
;	JNZ	H2A8E2			
;	CMP	AH,10			;１０の位ある？
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
;	ADD	AH,30H			;一の位は必ず書く
;	MOV	CS:[BX],AH		;
;	
;	MOV	DX,OFFSET ASC_8		;アドレス
;
;	RET				
HEX2ASC8	endp
;****************************************************************
	end
