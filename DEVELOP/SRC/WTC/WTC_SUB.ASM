;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				SUB Routine				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;---------------------------------------------------------------|
;		ƒ^ƒCƒgƒ‹Aƒo[ƒWƒ‡ƒ“‚Ì•\Ž¦			|
;---------------------------------------------------------------|
WTD_TITLE	DB	'Wonder Swan Total Souund Driver',0Dh,0Ah,24h
VER_P		DB	'Version '
		DB	WtdIL_Version
		DB	0Dh,0Ah,24h
TPRINT:					;
	MOV	AX,CS			;
	MOV	DS,AX			;
	MOV	AH,09H			;
	MOV	DX,OFFSET WTD_TITLE	;
	INT	21H			;
	MOV	DX,OFFSET P_TAB		;
	INT	21H			;
	MOV	DX,OFFSET VER_P		;
	INT	21H			;
	MOV	DX,OFFSET P		;
	MOV	AH,09H			;
	INT	21H			;
	RET
;---------------------------------------------------------------|
;		ƒRƒ“ƒpƒCƒ‹ƒ‹[ƒ`ƒ“				|
;---------------------------------------------------------------|
COMPAIL:				;ƒRƒ“ƒpƒCƒ‹
	MOV	AX,CS:[segWTD_File]	;
	MOV	DS,AX			;DS©WTD SEGMENT
	MOV	AX,CS:[segMML_File]	;
	MOV	ES,AX			;ES©MML SEGMENT

	CALL	c_Head_first		;ƒwƒbƒ_[Ý’è
	CALL	c_voice			;‰¹F“]‘—
	CALL	c_Command		;ƒp[ƒgƒRƒ“ƒpƒCƒ‹
	CALL	c_Head_end		;ƒwƒbƒ_[Ý’è(ˆê”ÔÅŒã‚ÉŒÄ‚ÔB)

	cmp	cs:[cHCD_FlagFx],00h	;FXŒ`Ž®ƒtƒ‰ƒO‚ª—§‚Á‚Ä‚é‚©H
	jnz	COMPAIL_Step0		;—§‚Á‚Ä‚È‚©‚Á‚½‚çAI‚í‚èB
	call	WTD_SAVE		;‚v‚s‚cŒ`Ž®‚ÅƒZ[ƒu‚·‚é
COMPAIL_Step0:				;

	cmp	cs:[cHCD_FlagFx],01h	;FXŒ`Ž®ƒtƒ‰ƒO‚ª—§‚Á‚Ä‚é‚©H
	jnz	COMPAIL_Step1		;—§‚Á‚Ä‚È‚©‚Á‚½‚çAI‚í‚èB
	call	FX_SAVE			;‚e‚wŒ`Ž®‚ÅƒZ[ƒu‚·‚éB
COMPAIL_Step1:				;

COMPAIL_End:				;
	ret				;RETURN
;---------------------------------------------------------------|
;		ƒRƒ“ƒpƒCƒ‹ƒf[ƒ^‚Ì‚e‚r‚oŒ`Ž®ƒZ[ƒu		|
;---------------------------------------------------------------|
WTD_SAVE:
	call	SOPEN			;
	mov	dx,cs:[pWTD_File]	;
	call	MSAVE			;
	call	SCLOSE			;
	ret				;
FX_SAVE:
	call	FXopen			;
	mov	dx,07Fh			;
	call	FXsave			;
	mov	dx,cs:[pWTD_File]	;
	call	MSAVE			;
	call	SCLOSE			;
	ret
;---------------------------------------------------------------|
;		‚P‚Ui”ƒR[ƒh`ASCII CODE(255)			|
;---------------------------------------------------------------|
;	ˆ—							|
;		‚P‚UiƒR[ƒh‚ð‚P‚Oi‚ÌƒAƒXƒL[ƒR[ƒh‚É•ÏŠ·	|
;	ˆø”							|
;		AH©•ÏŠ·‚µ‚½‚¢”’l				|
;	•Ô‚è’l							|
;		DX©•ÏŠ·‚µ‚½•¶Žš—ñ‚Ìæ“ªƒAƒhƒŒƒX		|
;---------------------------------------------------------------|
	DB	'-'			;•„†
ASC_8	DB	'$$$$$'			;
HEX2ASC8:
	PUSH	AX			
	PUSH	BX			
	PUSH	CX			;ƒŒƒWƒXƒ^•Û‘¶
	MOV	BX,OFFSET ASC_8		
	MOV	AL,'$'			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		

	MOV	BX,OFFSET ASC_8		
	MOV	AL,' '			;
	CMP	AH,100			;
	JC	H2A8L3			;‚P‚O‚O‚ÌˆÊ‚ ‚éH
	
	MOV	AL,AH			
	XOR	AH,AH			
	MOV	CH,100			
	DIV	CH			
	ADD	AL,30H			
	MOV	CS:[BX],AL		
	INC	BX			
H2A8L3:	
	CMP	AL,' '			;AL=" "‚¾‚Á‚½‚ç‚P‚O‚O‚ÌˆÊ‚Í–³‚©‚Á‚½
	JNZ	H2A8E2			
	CMP	AH,10			;‚P‚O‚ÌˆÊ‚ ‚éH
	JC	H2A8L2			
	
H2A8E2:	MOV	AL,AH			
	XOR	AH,AH			
	MOV	CH,10			
	DIV	CH			
	ADD	AL,30H			
	MOV	CS:[BX],AL		
	INC	BX			
H2A8L2:	
	ADD	AH,30H			;ˆê‚ÌˆÊ‚Í•K‚¸‘‚­
	MOV	CS:[BX],AH		;
	
	MOV	DX,OFFSET ASC_8		;ƒAƒhƒŒƒX
	POP	CX			
	POP	BX			
	POP	AX			
	RET				
;---------------------------------------------------------------|
;		‚P‚Ui”ƒR[ƒh`ASCII CODE(65535)		|
;---------------------------------------------------------------|
;	ˆ—							|
;		‚P‚UiƒR[ƒh‚ð‚P‚Oi‚ÌƒAƒXƒL[ƒR[ƒh‚É•ÏŠ·	|
;	ˆø”							|
;		AX©•ÏŠ·‚µ‚½‚¢”’l				|
;	•Ô‚è’l							|
;		DX©•ÏŠ·‚µ‚½•¶Žš—ñ‚Ìæ“ªƒAƒhƒŒƒX		|
;---------------------------------------------------------------|
	DB	'-'			;•„†
ASC_16	DB	'$$$$$$$'
HEX2ASC16:
	PUSH	AX			
	PUSH	BX			
	PUSH	CX			

	PUSH	AX			
	MOV	BX,OFFSET ASC_16	
	MOV	AL,'$'			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
	INC	BX			
	MOV	CS:[BX],AL		
;	INC	BX			
;	MOV	CS:[BX],AL		
	POP	AX			

	MOV	BX,OFFSET ASC_16	
	MOV	CL,' '			
	MOV	DX,AX			
	CMP	DX,10000		;‚P‚O‚O‚O‚O‚ÌˆÊ‚Í‚ ‚éH
	JC	H2A6L5			
	
	XOR	DX,DX			
	MOV	CX,10000		
	DIV	CX			
	ADD	AL,30H			
	MOV	CL,AL			
	MOV	CS:[BX],CL		
	INC	BX			
H2A6L5:	
	CMP	CL,' '			
	JNZ	H2A6E4			
	CMP	DX,1000			;‚P‚O‚O‚O‚ÌˆÊ‚ÍH
	JC	H2A6L4			
	
H2A6E4:	MOV	AX,DX			
	XOR	DX,DX			
	MOV	CX,1000			
	DIV	CX			
	ADD	AL,30H			
	MOV	CL,AL			
	MOV	CS:[BX],CL		
	INC	BX			
H2A6L4:	
	CMP	CL,' '			
	JNZ	H2A6E3			
	CMP	DX,100			;‚P‚O‚O‚ÌˆÊ
	JC	H2A6L3			
	
H2A6E3:	MOV	AX,DX			
	XOR	DX,DX			
	MOV	CX,100			
	DIV	CX			
	ADD	AL,30H			
	MOV	CL,AL			
	MOV	CS:[BX],CL		
	INC	BX			
H2A6L3:	
	CMP	CL,' '			
	JNZ	H2A6E2			
	CMP	DX,10			;‚P‚O‚ÌˆÊ‚ÍH
	JC	H2A6L2			

H2A6E2:	MOV	AX,DX			
	XOR	DX,DX			
	MOV	CX,10			
	DIV	CX			
	ADD	AL,30H			
	MOV	CL,AL			
	MOV	CS:[BX],CL		
	INC	BX			
H2A6L2:	
	MOV	AX,DX			
	ADD	AL,30H			
	MOV	CS:[BX],AL		;‚P‚ÌˆÊ‚Í•K‚¸‘‚­
	
	MOV	DX,OFFSET ASC_16	
	POP	CX			
	POP	BX			
	POP	AX			
	RET				
;---------------------------------------------------------------|
;		ASCII CODE¨‚P‚UiƒR[ƒh(-127`255)		|
;			”’lƒf[ƒ^‚ª‚ ‚é‚Ü‚Å‚¸‚Á‚Æ		|
;---------------------------------------------------------------|
;	ˆø”							|
;		CS:[pMML_File] ©•ÏŠ·‚µ‚½‚¢•¶Žš—ñæ“ªƒAƒhƒŒƒX	|
;		ES©MML Data‚Ì‚ ‚éƒZƒOƒƒ“ƒg			|
;	•Ô‚è’l							|
;		AH©ƒf[ƒ^					|
;		CS:[pMML_File] ©ŽŸ‚ÌƒAƒhƒŒƒX			|
;---------------------------------------------------------------|
A2H8R:
	PUSH	BX			;
	PUSH	CX			;
	PUSH	DX			;
	PUSH	DS			;
	MOV	CL,AL			;AL‚Ì•Û‘¶
	PUSH	AX			;
	MOV	AX,ES			;
	MOV	DS,AX			;
	POP	AX			;
	MOV	DX,CS:[pMML_File]	;
A2H8R1:	CALL	COMMENT_CHK		;ƒRƒƒ“ƒgƒ`ƒFƒbƒN
	CALL	ASC2HEX8		;ASC Code ¨16iCode•ÏŠ·
	MOV	DX,BX			;
	JNC	A2H8RR			;•ÏŠ·•s‰Â”\H‚¾‚Á‚½‚ç
	JMP	A2H8R1			;‚â‚è’¼‚µB
A2H8RR:	MOV	CS:[pMML_File],DX	;
	MOV	AL,CL			;AL‚Ì•œ‹A
	POP	DS			;
	POP	DX			;
	POP	CX			;
	POP	BX			;
	RET				;RETURN
;---------------------------------------------------------------|
;		ASCII CODE¨‚P‚UiƒR[ƒh(-32767`65535)		|
;			”’lƒf[ƒ^‚ª‚ ‚é‚Ü‚Å‚¸‚Á‚Æ		|
;---------------------------------------------------------------|
;	ˆø”							|
;		CS:[pMML_File] ©•ÏŠ·‚µ‚½‚¢•¶Žš—ñæ“ªƒAƒhƒŒƒX	|
;		ES©MML Data‚Ì‚ ‚éƒZƒOƒƒ“ƒg			|
;	•Ô‚è’l							|
;		AX©ƒf[ƒ^					|
;		CS:[pMML_File] ©ŽŸ‚ÌƒAƒhƒŒƒX			|
;---------------------------------------------------------------|
A2H16R:
	CALL	COMMENT_CHK		;ƒRƒƒ“ƒgƒ`ƒFƒbƒN

	PUSH	BX			;
	PUSH	DX			;
	PUSH	DS			;
	PUSH	AX			;
	MOV	AX,ES			;
	MOV	DS,AX			;
	POP	AX			;
	MOV	DX,CS:[pMML_File]	;
A2H16R1:CALL	ASC2HEX16		;ASC Code ¨16iCode•ÏŠ·
	MOV	DX,BX			;
	JNC	A2H16RR			;•ÏŠ·•s‰Â”\H‚¾‚Á‚½‚ç
	JMP	A2H16R1			;‚â‚è’¼‚µB
A2H16RR:MOV	CS:[pMML_File],DX	;
	POP	DS			;
	POP	DX			;
	POP	BX			;
	RET				;RETURN
;---------------------------------------------------------------|
;		ASCII CODE¨‚P‚UiƒR[ƒh(-127`255)		|
;---------------------------------------------------------------|
;	ˆø”							|
;		DS:DX©•ÏŠ·‚µ‚½‚¢•¶Žš—ñæ“ªƒAƒhƒŒƒX		|
;	•Ô‚è’l							|
;		AH©•ÏŠ·Œã					|
;		DS:BX©ŽŸ‚ÌƒAƒhƒŒƒX				|
;---------------------------------------------------------------|
HEX_8	DB	00H,00H,00H		;
DHEX8	DB	00H			;
F8FLAG	DB	00H			;
ASC2HEX8:				;
	PUSH	CX			;
	PUSH	DX			;
	XOR	CX,CX			;CX©0
	MOV	BX,DX			;BX©DXi•¶Žš—ñæ“ªƒAƒhƒŒƒXj
	MOV	DX,OFFSET HEX_8		;DX©•ÏŠ·—pƒf[ƒ^ƒoƒbƒtƒ@
	XOR	AX,AX			;
	MOV	CS:[F8FLAG],AH		;•„†ƒtƒ‰ƒO‚ÌƒŠƒZƒbƒg
	MOV	AH,DS:[BX]		;
	CMP	AH,'-'			;
	JNZ	A2H8L0			;
	INC	BX			;
	MOV	AH,0F8H			;Flag
	MOV	CS:[F8FLAG],AH		;Set
A2H8L0:	MOV	AH,DS:[BX]		;
	INC	BX			;
	SUB	AH,30H			;CHR CODE¨HEX CODE
	JNC	A2H8L1			;AH<0@‚¾‚Á‚½‚çˆêŽž•ÏŠ·I—¹
	JMP	A2H8E1			;
A2H8L1:	CMP	AH,10			;
	JC	A2H8L2			;AH>10 ‚¾‚Á‚½‚çˆêŽž•ÏŠ·I—¹
	JMP	A2H8E1			;
A2H8L2:	XCHG	BX,DX			;
	MOV	CS:[BX],AH		;•Û‘¶
	INC	BX			;
	XCHG	BX,DX			
	INC	CL			;
	CMP	CL,3			;‚R‰ñ•ÏŠ·‚µ‚½‚çˆêŽž•ÏŠ·I—¹
	JZ	A2H8E0			;iÅ‘å‚RŒ…( 0~255)j
	JMP	A2H8L0			;
A2H8E1:
	DEC	BX			;
A2H8E0:
	CMP	CL,0			;”’l•¶Žši-, 0~9j‚ª‚ ‚Á‚½ê‡
	JNZ	A2H8L3			;ƒWƒƒƒ“ƒv
	STC				;‚»‚êˆÈŠOA
	INC	BX			;ƒGƒ‰[‚Å–ß‚é
	JMP	A2H8EE			;
A2H8L3:					;
	MOV	CH,0			;
	MOV	CS:[DHEX8],CH		;
	MOV	CH,CL			;CH©ˆêŽž•ÏŠ·‚Å•ÏŠ·‚µ‚½•¶Žš”
	MOV	CL,3			;CL©Œ…ŒvŽZ—p
	XCHG	BX,DX			;	3¥10^0	2¥10^1	1¥10^2
A2H8L4:	
	DEC	BX			;
	MOV	AH,CS:[BX]		;
	CALL	A2H8AA			;Œ…ŒvŽZ
	DEC	CL			;
	DEC	CH			;
	JNZ	A2H8L4			;•¶Žš”•ª
	XCHG	BX,DX			;
	MOV	AH,CS:[DHEX8]		;
	CMP	CS:[F8FLAG],00H		;
	JZ	A2H8L5			;
	NEG	AH			;
A2H8L5:	CLC				;
A2H8EE:	POP	DX			;
	POP	CX			;
	RET				;

;	*	*	*	*	*	*	*	*

A2H8AA:					;
	CMP	CL,1			;CL‚ª	‚P‚Ìê‡
	JNZ	A2H8C1			;AX©AH*100
	MOV	AL,100			;
	JMP	A2H8C3			;
A2H8C1:	CMP	CL,2			;	‚Q‚Ìê‡
	JNZ	A2H8C2			;AX©AH*10
	MOV	AL,10			;
	JMP	A2H8C3			;
A2H8C2:	CMP	CL,3			;	‚R‚Ìê‡
	JNZ	A2H8C4			;AX©AH*1
	MOV	AL,1			;
;	JMP	A2H8C3			;
A2H8C3:	CALL	KAKE8			;
	ADD	CS:[DHEX8],AL		;[DHEX8]©[DHEX8]*AX
	RET				;
A2H8C4:	MOV	CL,0			;‚b‚k‚ª‚»‚êˆÈŠO‚Ìê‡
	XCHG	BX,DX			;ƒGƒ‰[
	POP	DX			;
	MOV	DX,OFFSET A2H8EE	;
	PUSH	DX			;
	STC				;
	RET				;
;---------------------------------------------------------------|
;		‚©‚¯ŽZƒ‹[ƒ`ƒ“					|
;---------------------------------------------------------------|
;	ˆø”							|
;		AH©‚©‚¯‚ç‚ê‚é”				|
;		AL©‚©‚¯‚é”					|
;	•Ô‚è’l							|
;		AX©“š						|
;---------------------------------------------------------------|
KAKE8:					;
	PUSH	CX			;
	PUSH	DX			;ƒŒƒWƒXƒ^•Û‘¶
	XOR	DX,DX			;DX©0000<h>
	MOV	CH,0			;CH©0
	MOV	CL,1			;CL©00000001<h>
KLOOP0:	TEST	AH,CL			;Bit check
	JZ	KLOOP1			;if 'L' then *KLOOP1
	CALL	KADD			;‰ÁŽZˆ—(DX+AL*2^CL)
KLOOP1:	INC	CH			;CH©CH+1
	SHL	CL,1			;CL Bit shift ©
	JNC	KLOOP0			;CL>128‚ÅI—¹
	MOV	AX,DX			;
	POP	DX			;
	POP	CX			;ƒŒƒWƒXƒ^•œ‹A
	RET				;RETURN
;		*************************
;		*	‰ÁŽZˆ—	*
;		*************************
KADD:					;
	PUSH	AX			;
	XOR	AH,AH			;AH©00h
	CMP	CH,1			;CH=1‚È‚ç‚Î‰ÁŽZ‚Ì‚Ý
	JC	KADD1			;
	PUSH	CX			;
	MOV	CL,CH			;
	SHL	AX,CL			;AX©AX*2^CH
	POP	CX			;
KADD1:	ADD	DX,AX			;DX©DX+AX
	POP	AX			;
	RET				;
;---------------------------------------------------------------|
;		ASCII CODE¨‚P‚UiƒR[ƒh(-32767`65535)		|
;---------------------------------------------------------------|
;	ˆø”							|
;		DS:DX©•ÏŠ·‚µ‚½‚¢•¶Žš—ñæ“ªƒAƒhƒŒƒX		|
;	•Ô‚è’l							|
;		AX©•ÏŠ·Œã					|
;		DS:BX©ŽŸ‚ÌƒAƒhƒŒƒX				|
;---------------------------------------------------------------|
HEX_16	DB	00H,00H,00H,00H,00H	;
DHEX16	DW	0000H			;
F6FLAG	DB	00H			;
ASC2HEX16:				;
	PUSH	CX			;
	PUSH	DX			;
	XOR	CX,CX			;CX©0
	MOV	BX,DX			;BX©DXi•¶Žš—ñæ“ªƒAƒhƒŒƒXj
	MOV	DX,OFFSET HEX_16	;DX©•ÏŠ·—pƒf[ƒ^ƒoƒbƒtƒ@
	XOR	AX,AX
	MOV	CS:[F6FLAG],AH
	MOV	AH,DS:[BX]
	CMP	AH,'-'
	JNZ	A2H6L0
	INC	BX
	MOV	AH,0F6H
	MOV	CS:[F6FLAG],AH
A2H6L0:	MOV	AH,DS:[BX]		;
	INC	BX			;
	SUB	AH,30H			;CHR CODE¨HEX CODE
	JNC	A2H6L1			;AH<0@‚¾‚Á‚½‚çˆêŽž•ÏŠ·I—¹
	JMP	A2H6E1			;
A2H6L1:	CMP	AH,10			;
	JC	A2H6L2			;AH>10 ‚¾‚Á‚½‚çˆêŽž•ÏŠ·I—¹
	JMP	A2H6E1			;
A2H6L2:	XCHG	BX,DX			
	MOV	CS:[BX],AH		;•Û‘¶
	INC	BX			;
	XCHG	BX,DX			
	INC	CL			;
	CMP	CL,5			;‚T‰ñ•ÏŠ·‚µ‚½‚çˆêŽž•ÏŠ·I—¹
	JZ	A2H6E0			;
	JMP	A2H6L0			;
A2H6E1:
	DEC	BX			
A2H6E0:
	CMP	CL,0			
	JNZ	A2H6L3			
	STC				
	INC	BX			
	JMP	A2H6EE			
A2H6L3:					
	XOR	AX,AX			
	MOV	CS:[DHEX16],AX		
	MOV	CH,CL			
	MOV	CL,5			
	XCHG	BX,DX			
A2H6L4:	
	DEC	BX			
	XOR	AH,AH			
	MOV	AL,CS:[BX]		
	CALL	A2H6AA			
	DEC	CL			
	DEC	CH			
	JNZ	A2H6L4			
	XCHG	BX,DX			
	MOV	AX,CS:[DHEX16]		
	CMP	CS:[F6FLAG],00H		
	JZ	A2H6L5			
	NEG	AX			
A2H6L5:	CLC				
A2H6EE:	POP	DX			
	POP	CX			
	RET				

;	*	*	*	*	*	*	*	*

A2H6AA:					
	PUSH	DX			
	CMP	CL,1			
	JNZ	A2H6C1			
	MOV	DX,10000		
	JMP	A2H6C5			
A2H6C1:	CMP	CL,2			
	JNZ	A2H6C2			
	MOV	DX,1000			
	JMP	A2H6C5			
A2H6C2:	CMP	CL,3			
	JNZ	A2H6C3			
	MOV	DX,100			
	JMP	A2H6C5			
A2H6C3:	CMP	CL,4			
	JNZ	A2H6C4			
	MOV	DX,10			
	JMP	A2H6C5			
A2H6C4:	CMP	CL,5			
	JNZ	A2H6C6			
	MOV	DX,1			
;	JMP	A2H6C5			
A2H6C5:	MUL	DX			
	POP	DX			
	ADD	CS:[DHEX16],AX		
	RET				
A2H6C6:	MOV	CL,0			
	POP	DX			
	XCHG	BX,DX			
	POP	DX			
	MOV	DX,OFFSET A2H6EE	
	PUSH	DX			
	STC				
	RET				
;---------------------------------------------------------------|
;		ƒRƒ“ƒpƒCƒ‹ƒf[ƒ^“Ç‚Ýž‚Ý			|
;---------------------------------------------------------------|
;	ˆø”							|
;		CS:[pMML_File]FƒRƒ“ƒpƒCƒ‹ƒAƒhƒŒƒX		|
;		ES©MML Data‚Ì‚ ‚éƒZƒOƒƒ“ƒg			|
;	•Ô‚è’l							|
;		AH	 @Fƒf[ƒ^				|
;		CS:[pMML_File]FŽŸ‚ÌƒAƒhƒŒƒX			|
;---------------------------------------------------------------|
CREAD:	
	call	COMMENT_CHK		;

	PUSH	BX			;
	MOV	BX,CS:[pMML_File]	;BX©ƒRƒ“ƒpƒCƒ‹‚·‚éƒAƒhƒŒƒX
	MOV	AH,ES:[BX]		;AH©‚»‚±‚Ìƒf[ƒ^
	INC	BX			;BXiƒ|ƒCƒ“ƒ^j‚ð‘‰Á
	PUSH	AX			;
	MOV	AX,CS:[szMml_File]	;AX© *.MML‚ÌƒTƒCƒY
	CMP	AX,BX			;ƒ|ƒCƒ“ƒ^‚ªƒTƒCƒY‚ð‰z‚¦‚Ä‚¢‚½‚ç
	MOV	CS:[pMML_File],BX	;Cy©'H'
	POP	AX			;
	POP	BX			;
	RET				;
;---------------------------------------------------------------|
;		ƒRƒ“ƒpƒCƒ‹ƒf[ƒ^‘‚«ž‚Ý			|
;---------------------------------------------------------------|
;	ˆø”							|
;		AH	 @Fƒf[ƒ^				|
;		CS:[pWTD_File]FƒRƒ“ƒpƒCƒ‹ƒAƒhƒŒƒX		|
;		DS©FSP ƒf[ƒ^‚ð‘‚­ƒZƒOƒƒ“ƒg			|
;	•Ô‚è’l							|
;		CS:[pWTD_File]FŽŸ‚ÌƒAƒhƒŒƒX			|
;---------------------------------------------------------------|
CSET:	PUSH	BX			;
	MOV	BX,CS:[pWTD_File]	;BX©ƒRƒ“ƒpƒCƒ‹‚µ‚½ƒAƒhƒŒƒX
	MOV	DS:[BX],AH		;‘‚«ž‚Ý
	INC	BX			;BXiƒ|ƒCƒ“ƒ^j‘‰Á
	MOV	CS:[pWTD_File],BX	;
	POP	BX			;
	RET				;
;---------------------------------------------------------------
CSET16:	PUSH	BX			;
	MOV	BX,CS:[pWTD_File]	;BX©ƒRƒ“ƒpƒCƒ‹‚µ‚½ƒAƒhƒŒƒX
	MOV	DS:[BX],ax		;‘‚«ž‚Ý
	add	bx,2			;BXiƒ|ƒCƒ“ƒ^j‘‰Á
	MOV	CS:[pWTD_File],BX	;
	POP	BX			;
	RET				;
;---------------------------------------------------------------|
;		ƒRƒƒ“ƒgƒ`ƒFƒbƒN				|
;---------------------------------------------------------------|
COMMENT_CHK:				;
	PUSH	AX			;
	PUSH	BX			;
	MOV	BX,CS:[pMML_File]	;BX©ƒRƒ“ƒpƒCƒ‹’†ƒAƒhƒŒƒX
	MOV	AH,ES:[BX]		;AH©‚»‚±‚Ìƒf[ƒ^
	CMP	AH,';'			;‚à‚µƒRƒƒ“ƒg‚ª‚ ‚Á‚½‚ç‰üs‚Ü‚ÅƒWƒƒƒ“ƒv
	JNZ	REMCHK			;
	CALL	CRJUMP			;
REMCHK:	POP	BX			;
	POP	AX			;
	RET				;
;---------------------------------------------------------------|
;		‰üs‚Ü‚Å”ò‚Î‚·					|
;---------------------------------------------------------------|
CRJUMP:	PUSH	AX			;
	push	bx			;

CR_JMP:	
	MOV	BX,CS:[pMML_File]	;BX©ƒRƒ“ƒpƒCƒ‹‚·‚éƒAƒhƒŒƒX
	MOV	AH,ES:[BX]		;AH©‚»‚±‚Ìƒf[ƒ^
	inc	CS:[pMML_File]		;ƒ|ƒCƒ“ƒ^‚ð‘‰Á

	CMP	AH,0DH			;‰üsH
	JNZ	CR_JMP			;‚Å‚È‚©‚Á‚½‚çª

	dec	CS:[pMML_File]		;ƒ|ƒCƒ“ƒ^‚ð‘‰Á

	pop	bx			;
	POP	AX			;
	RET				;
;****************************************************************
;								*
;			ƒtƒ@ƒCƒ‹ŠÖ˜A				*
;								*
;****************************************************************
;---------------------------------------------------------------|
;		ƒCƒ“ƒNƒ‹[ƒhƒtƒ@ƒCƒ‹ƒ`ƒFƒbƒN			|
;---------------------------------------------------------------|
INCFILE	DB	'            ',000,00DH,00AH,024H
CHK_INCLUDE:				;ƒCƒ“ƒNƒ‹[ƒh’è‹`‚Ìˆ—
	CALL	IOPEN			;ƒtƒ@ƒCƒ‹“Ç‚Ýž‚Ý—p‚Ìƒƒ‚ƒŠŠ„“–
	xor	bx,bx			;
	MOV	CS:[pMML_File],BX	;‚l‚l‚kƒf[ƒ^æ“ªƒAƒhƒŒƒX
	MOV	AX,CS:[segMml_File]	;
	MOV	ES,AX			;
	JMP	INCL01			;
INCLOOP:				;
	CALL	CREAD			;
	JNC	INCL00			;ƒTƒCƒYƒI[ƒo
	JMP	INCEOF			;
INCL00:	CMP	AH,00AH			;‰üsH
	JNZ	INCLOOP			;
INCL01:	CALL	CREAD			;
	CMP	AH,'I'			;I
	JNZ	INCLOOP			;
INCL02:	CALL	CREAD			;
	CMP	AH,'N'			;N
	JNZ	INCLOOP			;s‚Ìæ“ª‚É'IN'‚Ì•¶Žš‚ª‚ ‚é‚©H
INCL03:	CALL	CREAD			;
	CMP	AH,21H			;
	JC	INCL03			;‚Q‚O–¢–ž‚ÌƒR[ƒh‚Í”ò‚Î‚·
INCL04:	MOV	BX,OFFSET INCFILE	;BX©ƒtƒ@ƒCƒ‹–¼‚ðŠi”[‚·‚éƒAƒhƒŒƒX
	MOV	CL,13			;
	MOV	AX,CS:[pMML_File]	;
	DEC	AX			;
	MOV	CS:[pMML_File],AX	;
INCL05:	CALL	CREAD			;
	CMP	AH,0DH			;‰üs‚¾‚Á‚½‚ç
	JZ	INCL06			;Ši”[I—¹
	MOV	CS:[BX],AH		;
	INC	BX			;
	DEC	CL			;
	JNZ	INCL05			;•¶Žš—ñƒI[ƒo
	JMP	INC_ERROR		;‘¶Ý‚µ‚È‚¢ƒtƒ@ƒCƒ‹
INCL06:	MOV	AH,00H			;
	MOV	CS:[BX],AH		;
	CALL	CREAD			;ƒ|ƒCƒ“ƒ^‚ði‚Ü‚¹‚é
	CALL	INC_FILE_OPEN		;ƒCƒ“ƒNƒ‹[ƒhƒtƒ@ƒCƒ‹ƒI[ƒvƒ“
	CALL	INC_MREAD		;ƒƒ‚ƒŠ“Ç‚Ýž‚Ý
	CALL	INC_FILE_CLOSE		;ƒCƒ“ƒNƒ‹[ƒhƒtƒ@ƒCƒ‹ƒNƒ[ƒY
	CALL	INC_SCROOL		;ƒCƒ“ƒNƒ‹[ƒh‚Ì‘}“ü
	JMP	INCLOOP			;
INCEOF:	
	CALL	ICLOSE			;Š„‚è“–‚Ä‚½ƒƒ‚ƒŠ‚Ì‰ð•ú
	RET				;
;---------------------------------------------------------------|
;		ƒCƒ“ƒNƒ‹[ƒhƒtƒ@ƒCƒ‹‘}“ü			|
;---------------------------------------------------------------|
INC_SCROOL:
	STD				;ƒuƒƒbƒN“]‘—ŽžƒfƒBƒNƒŠƒƒ“ƒg
	MOV	SI,0FFFFH		;
	SUB	SI,CS:[szInclude_File]	;
	MOV	DI,0FFFFH		;
	MOV	AX,CS:[segMml_File]	;
	MOV	DS,AX			;
	MOV	ES,AX			;
INC_SCROOL_L0:				;
	MOVSB				;
	CMP	SI,CS:[pMML_File]	;
	JNC	INC_SCROOL_L0		;ƒTƒCƒY•ª‚µ‚½‚É‚¸‚ç‚·B

	MOV	CX,CS:[szInclude_File]	;CX ©“]‘—ƒTƒCƒY
	MOV	SI,0000H		;DS:SI ©“]‘—Œ³
	MOV	DI,CS:[pMML_File]	;ES:DI ©‘—‚èæ
	MOV	AX,CS:[segInclude_File]	;
	MOV	DS,AX			;
	MOV	AX,CS:[segMml_File]	;
	MOV	ES,AX			;
	
	CLD				;ƒuƒƒbƒN“]‘—ŽžƒCƒ“ƒNƒŠƒƒ“ƒg
	REP	MOVSB			;ƒuƒƒbƒN“]‘—
	
	DEC	DI			;
	MOV	AH,ES:[DI]		;ƒCƒ“ƒNƒ‹[ƒhƒtƒ@ƒCƒ‹‚ÌÅŒã‚ÉEOF‚ª
	CMP	AH,1AH			;‚Â‚¢‚Ä‚¢‚½‚çA20h ‚ð“ü‚ê‚é
	JNZ	INC_SCROOL_L1		;
	MOV	AH,20H			;
	MOV	ES:[DI],AH		;
INC_SCROOL_L1:				;
	MOV	AX,CS:[szMml_File]	;‚l‚l‚kƒTƒCƒY‚ðƒCƒ“ƒNƒ‹[ƒhƒtƒ@ƒCƒ‹‚Ì
	ADD	AX,CS:[szInclude_File]	;ƒTƒCƒY•ª‚¾‚¯‘å‚«‚­‚·‚éB
	MOV	CS:[szMml_File],AX	;
	RET				;
;---------------------------------------------------------------|
;		ƒZ[ƒu—pƒtƒ@ƒCƒ‹‚ÌƒI[ƒvƒ“			|
;---------------------------------------------------------------|
SOPEN:
	PUSH	DS			;
	PUSH	AX			;
	PUSH	BX			;
	PUSH	CX			;
	PUSH	DX			;

	MOV	AX,CS			;
	MOV	DS,AX			;DS©CS

	MOV	AX,CS:[F_ADD]		;
	MOV	SI,AX			;SI©ƒtƒ@ƒCƒ‹ƒAƒhƒŒƒX
	MOV	BX,AX			;
SFLP1:					;Šg’£Žq‚ð'.WTD'‚Æ‚·‚éB
	INC	BX			;
	CMP	BYTE PTR CS:[BX],'.'	;
	JNZ	SFLP1			;
SFLP2:	INC	BX			;
	MOV	AH,'W'			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,'T'			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,'D'			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,00H			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,0AH			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,0DH			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,24H			;
	MOV	CS:[BX],AH		;

SFL20:	MOV	AX,3C00H		;ƒtƒ@ƒCƒ‹‚ÌƒI[ƒvƒ“
	MOV	DX,SI			;DX©ƒtƒ@ƒCƒ‹–¼ƒAƒhƒŒƒX
	MOV	CX,00H			;•’Ê
	INT	21H			;
	JNC	SFL02			;
	JMP	SOPEN_ERROR		;
SFL02:	MOV	WORD PTR CS:[hWtd_File],AX	;

	POP	DX			;
	POP	CX			;
	POP	BX			;
	POP	AX			;
	POP	DS			;
	RET				;
;---------------------------------------------------------------|
;		ƒZ[ƒu—pƒtƒ@ƒCƒ‹‚ÌƒI[ƒvƒ“	FX		|
;---------------------------------------------------------------|
FXOPEN:
	PUSH	DS			;
	PUSH	AX			;
	PUSH	BX			;
	PUSH	CX			;
	PUSH	DX			;

	MOV	AX,CS			;
	MOV	DS,AX			;DS©CS

	MOV	AX,CS:[F_ADD]		;
	MOV	SI,AX			;SI©ƒtƒ@ƒCƒ‹ƒAƒhƒŒƒX
	MOV	BX,AX			;
FXFLP1:					;Šg’£Žq‚ð'.FX'‚Æ‚·‚éB
	INC	BX			;
	CMP	BYTE PTR CS:[BX],'.'	;
	JNZ	FXFLP1			;
FXFLP2:	INC	BX			;
	MOV	AH,'F'			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,'X'			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,00H			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,0AH			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,0DH			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,24H			;
	MOV	CS:[BX],AH		;

FXFL20:	MOV	AX,3C00H		;ƒtƒ@ƒCƒ‹‚ÌƒI[ƒvƒ“
	MOV	DX,SI			;DX©ƒtƒ@ƒCƒ‹–¼ƒAƒhƒŒƒX
	MOV	CX,00H			;•’Ê
	INT	21H			;
	JNC	FXFL02			;
	JMP	SOPEN_ERROR		;
FXFL02:	MOV	WORD PTR CS:[hWtd_File],AX	;

	POP	DX			;
	POP	CX			;
	POP	BX			;
	POP	AX			;
	POP	DS			;
	RET				;
;---------------------------------------------------------------|
;		ƒZ[ƒu—pƒtƒ@ƒCƒ‹‚ÌƒI[ƒvƒ“iƒeƒXƒgj		|
;---------------------------------------------------------------|
TSOPEN:
	PUSH	DS			;
	PUSH	AX			;
	PUSH	BX			;
	PUSH	CX			;
	PUSH	DX			;

	MOV	AX,CS			;
	MOV	DS,AX			;DS©CS

	MOV	AX,CS:[F_ADD]		;
	MOV	SI,AX			;SI©ƒtƒ@ƒCƒ‹ƒAƒhƒŒƒX
	MOV	BX,AX			;
TSFLP1:					;Šg’£Žq‚ð'.TCM'‚Æ‚·‚éB
	INC	BX			;
	CMP	BYTE PTR CS:[BX],'.'	;
	JNZ	TSFLP1			;
TSFLP2:	INC	BX			;
	MOV	AH,'T'			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,'C'			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,'M'			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,00H			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,0AH			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,0DH			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,24H			;
	MOV	CS:[BX],AH		;

TSFL20:	MOV	AX,3C00H		;ƒtƒ@ƒCƒ‹‚ÌƒI[ƒvƒ“
	MOV	DX,SI			;DX©ƒtƒ@ƒCƒ‹–¼ƒAƒhƒŒƒX
	MOV	CX,00H			;•’Ê
	INT	21H			;
	JNC	TSFL02			;
	JMP	SOPEN_ERROR		;
TSFL02:	MOV	WORD PTR CS:[hTest_File],AX

	POP	DX			;
	POP	CX			;
	POP	BX			;
	POP	AX			;
	POP	DS			;
	RET				;
;---------------------------------------------------------------|
;		ƒtƒ@ƒCƒ‹‚ÌƒI[ƒvƒ“				|
;---------------------------------------------------------------|
FOPEN:					;
	MOV	BX,0081H		;
	MOV	CH,CS:[BX - 1]		;
	ADD	BL,CH			;
	MOV	CS:[BX],BH		;
	MOV	BX,0081H		;
FLOOP:	CMP	CH,0			;
	JNZ	FL001			;
	JMP	FILE_ERROR		;
FL001:	DEC	CH			;
	INC	BX			;
	CMP	BYTE PTR CS:[BX],21H	;
	JC	FLOOP			;
	MOV	DX,BX			;
	MOV	CS:[F_ADD],BX		;ƒtƒ@ƒCƒ‹–¼æ“ªƒAƒhƒŒƒX‚Ì•Û‘¶

FLOP1:	CMP	CH,0			;Šg’£ŽqŽw’è‚Ì‚È‚¢ê‡
	JNZ	FL012			;'.MML'‚Æ‚·‚éB
	MOV	AH,'.'			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,'M'			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,'M'			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,'L'			;
	MOV	CS:[BX],AH		;
	INC	BX			;
	MOV	AH,00			;
	MOV	CS:[BX],AH		;
	
	JMP	FL020			;
FL012:	DEC	CH			;
	INC	BX			;
	CMP	BYTE PTR CS:[BX],'.'	;
	JNZ	FLOP1			;

FL020:	MOV	AX,3D00H		;ƒtƒ@ƒCƒ‹‚ÌƒI[ƒvƒ“
	INT	21H			;
	JNC	FL002			;
	JMP	LOAD_ERROR		;
FL002:	MOV	WORD PTR CS:[hMml_File],AX
	RET				;
;---------------------------------------------------------------|
;		ƒCƒ“ƒNƒ‹[ƒhƒtƒ@ƒCƒ‹‚ÌƒI[ƒvƒ“			|
;---------------------------------------------------------------|
INC_FILE_OPEN:				;ƒCƒ“ƒNƒ‹[ƒhƒtƒ@ƒCƒ‹
	PUSH	DS			;
	PUSH	CS			;
	POP	DS			;
	MOV	DX,OFFSET INCFILE	;DS:DX©ƒtƒ@ƒCƒ‹–¼ƒ|ƒCƒ“ƒ^
	MOV	AX,3D00H		;
	INT	21H			;
	JNC	INC_FILE_OPEN_L0	;
	JMP	INC_ERROR		;–³‚©‚Á‚½‚æ‚§`
INC_FILE_OPEN_L0:			;
	MOV	WORD PTR CS:[hInclude_File],AX	;ƒnƒ“ƒhƒ‹‚ð•Û‘¶‚µ‚Æ‚±B
	POP	DS			;
	RET				;
;---------------------------------------------------------------|
;		‰¹Fƒtƒ@ƒCƒ‹‚ÌƒI[ƒvƒ“				|
;---------------------------------------------------------------|
VOI_FILE_OPEN:				;‰¹Fƒtƒ@ƒCƒ‹
	PUSH	DS			;
	PUSH	CS			;
	POP	DS			;
	MOV	DX,OFFSET c_Voice_File	;DS:DX©ƒtƒ@ƒCƒ‹–¼ƒ|ƒCƒ“ƒ^
	MOV	AX,3D00H		;
	INT	21H			;
	JNC	VOI_FILE_OPEN_L0	;
	JMP	VOI_ERROR		;–³‚©‚Á‚½‚æ‚§`
VOI_FILE_OPEN_L0:			;
	MOV	WORD PTR CS:[hVoice_File],AX	;ƒnƒ“ƒhƒ‹‚ð•Û‘¶‚µ‚Æ‚±B
	POP	DS			;
	RET				;
;---------------------------------------------------------------|
;		ƒƒ‚ƒŠŠm•ÛiOPN Dataj				|
;---------------------------------------------------------------|
MOPEN:					;
	MOV	AH,48H			;
	MOV	BX,1000H		;64KByte ‚Ìƒf[ƒ^—Ìˆæ‚ÌŠm•Û
	INT	21H			;
	JNC	NOPERR			;Š„‚è“–‚ÄŽ¸”sŽž‚É”ò‚ÔB
	JMP	MOPEN_ERROR		;
NOPERR:	MOV	CS:[segMml_File],AX	;Š„‚è“–‚Ä‚½ƒZƒOƒƒ“ƒgƒAƒhƒŒƒX‚Ì•Û‘¶B
	MOV	DS,AX			;DS©Segment‚ÌÝ’è
	RET				;
;---------------------------------------------------------------|
;		ƒƒ‚ƒŠŠm•ÛiWTD Dataj				|
;---------------------------------------------------------------|
WOPEN:					;
	MOV	AH,48H			;
	MOV	BX,1000H		;64KByte ‚Ìƒf[ƒ^—Ìˆæ‚ÌŠm•Û
	INT	21H			;
	JNC	WOPERR			;Š„‚è“–‚ÄŽ¸”sŽž‚É”ò‚ÔB
	JMP	MOPEN_ERROR		;
WOPERR:	MOV	CS:[segWtd_File],AX	;Š„‚è“–‚Ä‚½ƒZƒOƒƒ“ƒgƒAƒhƒŒƒX‚Ì•Û‘¶B
	MOV	DS,AX			;DS©Segment‚ÌÝ’è
	RET				;
;---------------------------------------------------------------|
;		ƒƒ‚ƒŠŠm•ÛiINC Dataj				|
;---------------------------------------------------------------|
IOPEN:					;
	MOV	AH,48H			;
	MOV	BX,0800H		;32KByte ‚Ìƒf[ƒ^—Ìˆæ‚ÌŠm•Û
	INT	21H			;
	JNC	IOPERR			;Š„‚è“–‚ÄŽ¸”sŽž‚É”ò‚ÔB
	JMP	MOPEN_ERROR		;
IOPERR:	MOV	CS:[segInclude_File],AX	;Š„‚è“–‚Ä‚½ƒZƒOƒƒ“ƒgƒAƒhƒŒƒX‚Ì•Û‘¶B
	MOV	DS,AX			;DS©Segment‚ÌÝ’è
	RET				;
;---------------------------------------------------------------|
;		ƒƒ‚ƒŠŠm•ÛiVOI Dataj				|
;---------------------------------------------------------------|
VOPEN:					;
	MOV	AH,48H			;
	MOV	BX,0200H		;8KByte ‚Ìƒf[ƒ^—Ìˆæ‚ÌŠm•Û
	INT	21H			;
	JNC	VOPERR			;Š„‚è“–‚ÄŽ¸”sŽž‚É”ò‚ÔB
	JMP	MOPEN_ERROR		;
VOPERR:	MOV	CS:[segVoice_File],AX	;Š„‚è“–‚Ä‚½ƒZƒOƒƒ“ƒgƒAƒhƒŒƒX‚Ì•Û‘¶B
	RET				;
;---------------------------------------------------------------|
;		ƒƒ‚ƒŠŠJ•úiOPN Dataj				|
;---------------------------------------------------------------|
MCLOSE:					;
	MOV	AX,CS:[segMml_File]	;
	MOV	ES,AX			;ƒZƒOƒƒ“ƒg‚ð“Ç‚ÞB
	MOV	AH,49H			;
	INT	21H			;ƒf[ƒ^—Ìˆæ‚ÌŠJ•ú
	JNC	MCLRET			;
	JMP	CLOSE_ERROR		;
MCLRET:	RET				;
;---------------------------------------------------------------|
;		ƒƒ‚ƒŠŠJ•úiOPN Dataj				|
;---------------------------------------------------------------|
WCLOSE:					;
	MOV	AX,CS:[segWtd_File]	;
	MOV	ES,AX			;ƒZƒOƒƒ“ƒg‚ð“Ç‚ÞB
	MOV	AH,49H			;
	INT	21H			;ƒf[ƒ^—Ìˆæ‚ÌŠJ•ú
	JNC	WCLRET			;
	JMP	CLOSE_ERROR		;
WCLRET:	RET				;
;---------------------------------------------------------------|
;		ƒƒ‚ƒŠŠJ•úiINC Dataj				|
;---------------------------------------------------------------|
ICLOSE:					;
	push	es			;
	MOV	AX,CS:[segInclude_File]	;
	MOV	ES,AX			;ƒZƒOƒƒ“ƒg‚ð“Ç‚ÞB
	MOV	AH,49H			;
	INT	21H			;ƒf[ƒ^—Ìˆæ‚ÌŠJ•ú
	JNC	ICLRET			;
	JMP	CLOSE_ERROR		;
ICLRET:	pop	es			;
	RET				;
;---------------------------------------------------------------|
;		ƒƒ‚ƒŠŠJ•úiVOI Dataj				|
;---------------------------------------------------------------|
VCLOSE:					;
	push	es
	MOV	AX,CS:[segVoice_File]	;
	MOV	ES,AX			;ƒZƒOƒƒ“ƒg‚ð“Ç‚ÞB
	MOV	AH,49H			;
	INT	21H			;ƒf[ƒ^—Ìˆæ‚ÌŠJ•ú
	JNC	VCLRET			;
	JMP	CLOSE_ERROR		;
VCLRET:	pop	es
	RET				;
;---------------------------------------------------------------|
;		ƒtƒ@ƒCƒ‹¨ƒƒ‚ƒŠ“]‘—iOPN Dataj		|
;---------------------------------------------------------------|
MREAD:					;
	MOV	AX,CS:[segMml_File]	;
	MOV	DS,AX			;
	mov	dx,00002h		;
	MOV	CX,0FFFFH		;
	MOV	BX,WORD PTR CS:[hMml_File]
	MOV	AH,3FH			;
	INT	21H			;
	JNC	FL003			;
	JMP	READ_ERROR		;
FL003:	add	ax,2			;
	MOV	CS:[szMml_File],AX	;
	mov	bx,0000h		;
	mov	ds:[bx],0a0dh		;
	RET				;
;---------------------------------------------------------------|
;		ƒtƒ@ƒCƒ‹¨ƒƒ‚ƒŠ“]‘—iINC Dataj		|
;---------------------------------------------------------------|
INC_MREAD:				;
	MOV	AX,CS:[segInclude_File]	;
	MOV	DS,AX			;
	xor	dx,dx			;
	MOV	CX,07FFFH		;
	MOV	BX,WORD PTR CS:[hInclude_File]	;
	MOV	AH,3FH			;
	INT	21H			;
	JNC	INC_MREAD_L0		;
	JMP	READ_ERROR		;
INC_MREAD_L0:				;
	MOV	BX,AX			;
	DEC	BX			;
	CMP	DS:[BX],BYTE PTR 01AH	;[EOF] ‚ªÅŒã‚É‚­‚Á‚Â‚¢‚Ä‚¢‚éH
	JNZ	INC_MREAD_L1		;
	DEC	AX			;‚È‚ç‚ÎAƒtƒ@ƒCƒ‹ƒTƒCƒY‚ð‚P‚a‚™‚”‚…
INC_MREAD_L1:				;¬‚³‚­‚·‚éB
	MOV	CS:[szInclude_File],AX	;
	RET				;
;---------------------------------------------------------------|
;		ƒtƒ@ƒCƒ‹¨ƒƒ‚ƒŠ“]‘—iOPN Dataj		|
;---------------------------------------------------------------|
VOI_MREAD:				;
	PUSH	DS			;
	MOV	AX,CS:[segVoice_File]	;
	MOV	DS,AX			;DS©‰¹Fƒtƒ@ƒCƒ‹—pƒZƒOƒƒ“ƒgƒAƒhƒŒƒX
	MOV	DX,0000H		;DS:0000‚©‚ç
	MOV	CX,01FFFH		;1FFFh“]‘—‚·‚éB
	MOV	BX,WORD PTR CS:[hVoice_File]	;
	MOV	AH,3FH			;
	INT	21H			;
	JNC	VOI_MREAD_L1		;
	JMP	READ_ERROR		;
VOI_MREAD_L1:				;
	POP	DS			;
	RET				;
;---------------------------------------------------------------|
;		ƒƒ‚ƒŠ¨ƒtƒ@ƒCƒ‹“]‘—				|
;---------------------------------------------------------------|
MSAVE:					;
	PUSH	AX			;
	PUSH	BX			;
	PUSH	CX			;
	PUSH	DX			;
	PUSH	DS			;

	MOV	CX,DX			;
	xor	dx,dx
	MOV	BX,CS:[hWtd_File]	;
	MOV	AH,40H			;
	INT	21H			;
	JNC	SFL03			;
	JMP	READ_ERROR		;

SFL03:	POP	DS			;
	POP	DX			;
	POP	CX			;
	POP	BX			;
	POP	AX			;
	RET				;
;---------------------------------------------------------------|
;		ƒƒ‚ƒŠ¨ƒtƒ@ƒCƒ‹“]‘—	FX			|
;---------------------------------------------------------------|
FXSAVE:					;
	PUSH	AX			;
	PUSH	BX			;
	PUSH	CX			;
	PUSH	DX			;
	PUSH	DS			;

	push	cs			;
	pop	ds			;
	mov	dx,offset FX		;ds:dx©ƒtƒ@ƒCƒ‹ƒAƒhƒŒƒX
	mov	cx,128			;cx©ƒtƒ@ƒCƒ‹ƒTƒCƒY
	mov	bx,cs:[hWtd_File]	;bx©ƒtƒ@ƒCƒ‹ƒnƒ“ƒhƒ‹
	mov	ah,40h			;ax©ƒƒ‚ƒŠ“à—e‚ÌƒZ[ƒu
	INT	21H			;
	JNC	FXFL03			;
	JMP	READ_ERROR		;

FXFL03:	POP	DS			;
	POP	DX			;
	POP	CX			;
	POP	BX			;
	POP	AX			;
	RET				;
;---------------------------------------------------------------|
;		ƒƒ‚ƒŠ¨ƒtƒ@ƒCƒ‹“]‘—				|
;---------------------------------------------------------------|
TMSAVE:					;
	PUSH	AX			;
	PUSH	BX			;
	PUSH	CX			;
	PUSH	DX			;
	PUSH	DS			;

	MOV	AX,CS:[segMml_File]	;
	MOV	DS,AX			;
	MOV	CX,CS:[szMml_File]	;
	xor	dx,dx			;
	MOV	BX,CS:[hTest_File]	;
	MOV	AH,40H			;
	INT	21H			;
	JNC	TSFL03			;
	JMP	READ_ERROR		;

TSFL03:	POP	DS			;
	POP	DX			;
	POP	CX			;
	POP	BX			;
	POP	AX			;
	RET				;
;---------------------------------------------------------------|
;		ƒtƒ@ƒCƒ‹‚ÌƒNƒ[ƒY				|
;---------------------------------------------------------------|
FCLOSE:
	MOV	BX,WORD PTR CS:[hMml_File]	;
	MOV	AH,3EH			;
	INT	21H			;
	JNC	FL004			;
	JMP	CLOSE_ERROR		;
FL004:	RET				;
;---------------------------------------------------------------|
;		ƒZ[ƒu—pƒtƒ@ƒCƒ‹‚ÌƒNƒ[ƒY			|
;---------------------------------------------------------------|
SCLOSE:	
	PUSH	AX			;
	PUSH	BX			;
	
	MOV	BX,WORD PTR CS:[hWtd_File]	;
	MOV	AH,3EH			;
	INT	21H			;
	JNC	SFL04			;
	JMP	CLOSE_ERROR		;

SFL04:	POP	BX			;
	POP	AX			;
	RET				;
;---------------------------------------------------------------|
;		ƒZ[ƒu—pƒtƒ@ƒCƒ‹‚ÌƒNƒ[ƒY			|
;---------------------------------------------------------------|
TSCLOSE:
	PUSH	AX			;
	PUSH	BX			;
	
	MOV	BX,WORD PTR CS:[hTest_File]	;
	MOV	AH,3EH			;
	INT	21H			;
	JNC	TSFL04			;
	JMP	CLOSE_ERROR		;

TSFL04:	POP	BX			;
	POP	AX			;
	RET				;
;---------------------------------------------------------------|
;		ƒCƒ“ƒNƒ‹[ƒhƒtƒ@ƒCƒ‹‚ÌƒNƒ[ƒY			|
;---------------------------------------------------------------|
INC_FILE_CLOSE:				;
	PUSH	AX			;
	PUSH	BX			;
	
	MOV	BX,WORD PTR CS:[hInclude_File]	;
	MOV	AH,3EH			;
	INT	21H			;
	JNC	INC_FILE_CLOSE_L0	;
	JMP	CLOSE_ERROR		;
INC_FILE_CLOSE_L0:			;

	POP	BX			;
	POP	AX			;
	RET				;
;---------------------------------------------------------------|
;		‰¹Fƒtƒ@ƒCƒ‹‚ÌƒNƒ[ƒY				|
;---------------------------------------------------------------|
VOI_FILE_CLOSE:				;
	PUSH	AX			;
	PUSH	BX			;
	
	MOV	BX,WORD PTR CS:[hVoice_File]	;
	MOV	AH,3EH			;
	INT	21H			;
	JNC	VOI_FILE_CLOSE_L0	;
	JMP	CLOSE_ERROR		;
VOI_FILE_CLOSE_L0:			;

	POP	BX			;
	POP	AX			;
	RET				;
;---------------------------------------------------------------|
;		ƒJƒŒƒ“ƒgƒfƒBƒŒƒNƒgƒŠ‚Ì•ÏX			|
;---------------------------------------------------------------|
Current_Directory_Mess1	DB	'ƒJƒŒƒ“ƒgƒfƒBƒŒƒNƒgƒŠ‚ð'
Current_Directory	DB	132	DUP(00h)
Current_Directory_Mess2	DB	'‚É•ÏX‚µ‚Ü‚µ‚½B',0dh,0ah,24h
Change_Current_Directory:
	pusha				;
	push	ds			;
	push	es			;

	;-------------------------------
	;ƒZƒOƒƒ“ƒg‚ÌÝ’è
	mov	ax,cs			;
	mov	ds,ax			;
	mov	es,ax			;

	;-------------------------------
	;ƒJƒŒƒ“ƒgƒfƒBƒŒƒNƒgƒŠ‚ðŒŸõ
	MOV	BX,0081H		;
	MOV	CH,CS:[BX - 1]		;
	ADD	BL,CH			;BX©ƒtƒ@ƒCƒ‹–¼‚ª‘‚©‚ê‚Ä‚¢‚éÅŒãB

Change_Current_Directory_Loop:		;
	cmp	bx,0081h		;
	jc	Change_Current_Directory_End
	mov	al,cs:[bx]		;
	dec	bx			;
	cmp	al,'\'			;
	jnz	Change_Current_Directory_Loop

	;-------------------------------
	;ƒJƒŒƒ“ƒgƒfƒBƒŒƒNƒgƒŠ–¼‚ðÝ’è
	mov	cx,bx			;
	sub	cx,0081h		;
	mov	si,CS:[F_ADD]		;“]‘—Œ³
	mov	di,offset Current_Directory
	cld				;
	rep	movsb			;
	MOV	AH,00H			;
	MOV	CS:[di],AH		;
	INC	di			;
	MOV	AH,24H			;
	MOV	CS:[di],AH		;

	;-------------------------------
	;ƒJƒŒƒ“ƒgƒfƒBƒŒƒNƒgƒŠ‚ð•ÏX‚·‚éB
	mov	dx,offset Current_Directory
	mov	ah,3BH			;
	int	21h			;

	mov	dx,offset Current_Directory_Mess1
	mov	ah,09H			;
	int	21h			;

	mov	dx,offset Current_Directory_Mess2
	mov	ah,09H			;
	int	21h			;

	;-------------------------------
	;I—¹
Change_Current_Directory_End:
	pop	es			;
	pop	ds			;
	popa				;
	ret				;
;---------------------------------------------------------------|
;								|
;		‚b‚n‚lƒtƒ@ƒCƒ‹‚Ìƒƒ‚ƒŠ[Å¬‰»			|
;---------------------------------------------------------------|
;	ˆ—							|
;		‚b‚n‚lƒvƒƒOƒ‰ƒ€ŽÀsŽž‚Éƒƒ‚ƒŠ[‚ð		|
;		Å¬ŒÀ‚É‚·‚é					|
;	ˆø”							|
;		–³‚µ						|
;	•Ô‚è’l							|
;		DS©CS						|
;		Cy©'L' ‚Ì‚Æ‚«Bi³íI—¹j			|
;		BX©•ÏX‚µ‚½ƒƒ‚ƒŠ[‚Ì‘å‚«‚³B			|
;		Cy©'H' ‚Ì‚Æ‚«BiƒGƒ‰[j			|
;		BX©•ÏX‚Å‚«‚éÅ‘å‚Ì‘å‚«‚³			|
;		AX©INT21H Ì§Ý¸¼®Ý4AHŽQÆ			|
;---------------------------------------------------------------|
ComSmoleMessage7	DB	"ƒvƒƒOƒ‰ƒ€‚É‚æ‚éƒƒ‚ƒŠ[’†‚Ìƒf[ƒ^[‚Ì”j‰óB",0DH,0AH,"$"
ComSmoleMessage8	DB	"\•ª‚È‹ó‚«ƒƒ‚ƒŠ[‚ª–³‚¢B",0DH,0AH,"$"
ComSmoleMessage9	DB	"•s³‚Èƒƒ‚ƒŠ[ƒuƒƒbƒN‚ÌŽg—pB",0DH,0AH,"$"
ComSmole:			;ƒƒ‚ƒŠ[‚ÌÅ¬‰»
	PUSH	DX		;
	PUSH	CX		;ƒŒƒWƒXƒ^‚Ì•Û‘¶
	
	MOV	ES,CS:[002CH]	;ŠÂ‹«ƒZƒOƒƒ“ƒg‚ÌŠJ•ú
	MOV	AH,49H		;
	INT	21H		;
	
	MOV	AX,CS		;
	MOV	DS,AX		;DS©CS
	MOV	ES,AX		;ES©CS
	MOV	BX,OFFSET WTD_MML_Compiler_End+BSTACK
	MOV	CL,4		;
	SHR	BX,CL		;
	INC	BX		;BX©ƒvƒƒOƒ‰ƒ€‚Ì‘å‚«‚³iƒpƒ‰ƒOƒ‰ƒt’PˆÊj
	MOV	AH,04AH		;
	INT	21H		;Å¬‰»
	PUSH	BX		;
	PUSH	AX		;•Ô‚è’l‚Ì•Û‘¶
	JC	ComSmoleERR	;ƒGƒ‰[Žž‚É”ò‚Ô
	CLC			;Cy©'L'
	JMP	ComSmoleRET	;RETURN
;===============================================================|
ComSmoleERR:			;ƒtƒ@ƒ“ƒNƒVƒ‡ƒ“4AH ‚Ì‚d‚q‚q‚n‚q
	CMP	AX,07H		;
	JNZ	ComSmoleER8	;ERROR CODE=07H
	MOV	AH,09H		;
	MOV	DX,OFFSET ComSmoleMessage7
	INT	21H		;ƒƒbƒZ[ƒW‚Ì•\Ž¦
	STC			;Cy©'H'
	JMP	ComSmoleRET	;RETURN
ComSmoleER8:
	CMP	AX,08H		;
	JNZ	ComSmoleER9	;ERROR CODE=08H
	MOV	AH,09H		;
	MOV	DX,OFFSET ComSmoleMessage8
	INT	21H		;ƒƒbƒZ[ƒW‚Ì•\Ž¦
	STC			;Cy©'L'
	JMP	ComSmoleRET	;RETURN
ComSmoleER9:
	MOV	AH,09H		;ERROR CODE=09H
	MOV	DX,OFFSET ComSmoleMessage9
	INT	21H		;ƒƒbƒZ[ƒW‚Ì•\Ž¦
	STC			;Cy©'H'
	JMP	ComSmoleRET	;RETURN
;===============================================================|
ComSmoleRET:			;‚q‚d‚s‚t‚q‚m
	POP	AX		;
	POP	BX		;
	POP	CX		;ƒŒƒWƒXƒ^[‚Ì•œ‹A
	POP	DX		;
	RET			;RETURN
;---------------------------------------------------------------|
;		ƒGƒ‰[ˆ—					|
;---------------------------------------------------------------|
P_TAB	DB	"	$"
P	DB	0DH,0AH,'$'
ERROR	DB	'ƒtƒ@ƒCƒ‹‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñB',0DH,0AH,'$'
FERROR	DB	'WTC[32;4m ƒtƒ@ƒCƒ‹–¼[.mml][32;0m [m',0DH,0AH,'$'
RERROR	DB	'ƒtƒ@ƒCƒ‹‚ð“Ç‚ß‚Ü‚¹‚ñB',0AH,0DH,24H
MEMERR	DB	'ƒƒ‚ƒŠ‚ª‘«‚è‚Ü‚¹‚ñB',0AH,0DH,24H
ZERROR	DB	'‚e‚r‚o‚ªí’“‚µ‚Ä‚¢‚Ü‚¹‚ñB',0AH,0DH,'$'
OERROR	DB	'ƒI[ƒvƒ“‚ÉŽ¸”s‚µ‚Ü‚µ‚½',0DH,0AH,'$'
CERROR	DB	'ƒNƒ[ƒY‚ÉŽ¸”s‚µ‚Ü‚µ‚½',0DH,0AH,'$'
LERROR	DB	'ƒ‹[ƒvŠÖŒW‚ª‚¨‚©‚µ‚¢‚Å‚·B',0DH,0AH,'$'
MACERR	DB	'ƒ}ƒNƒ‚Åƒ}ƒNƒ‚ðŒÄ‚Ño‚µ‰ß‚¬‚Å‚·B',0DH,0AH,'$'
MACERR2	DB	'’è‹`‚³‚ê‚Ä‚¢‚È‚¢ƒ}ƒNƒ‚ðŽg—p‚µ‚Ä‚¢‚Ü‚·B',0DH,0AH,'$'
INCERR	DB	'‘¶Ý‚µ‚È‚¢ƒCƒ“ƒNƒ‹[ƒhƒtƒ@ƒCƒ‹‚ðŽw’è‚µ‚Ä‚¢‚Ü‚·B',0DH,0AH,'$'
VOIERR	DB	'‘¶Ý‚µ‚È‚¢‰¹Fƒtƒ@ƒCƒ‹‚ðŽw’è‚µ‚Ä‚¢‚Ü‚·B',0DH,0AH,'$'

D_SEG:	MOV	AX,ES			;
	MOV	DS,AX			;DS©Data
	ADD	DX,1000H		;
	RET				;
C_SEG:	MOV	AX,CS			;
	MOV	DS,AX			;DS©Program
	RET				;
LPRINT:	MOV	AH,09H			;
	INT	21H			;PRINT
	RET				;
LOAD_ERROR:
	MOV	DX,OFFSET ERROR		;
PRINT:	MOV	AX,CS			;
	MOV	DS,AX			;
	MOV	AH,09H			;
	INT	21H			;
	JMP	COMEND			;
FILE_ERROR:
	MOV	DX,OFFSET FERROR	;
	JMP	PRINT			;
MOPEN_ERROR:
	MOV	DX,OFFSET MEMERR	;
	JMP	PRINT			;
OPEN_ERROR:
	MOV	DX,OFFSET OERROR	;
	JMP	PRINT			;
CLOSE_ERROR:
	MOV	DX,OFFSET CERROR	;
	JMP	PRINT			;
READ_ERROR:
	MOV	DX,OFFSET RERROR	;
	JMP	PRINT			;
ZYO_ERROR:
	MOV	DX,OFFSET ZERROR	;
	JMP	PRINT			;
LOOP_ERROR:
	MOV	DX,OFFSET LERROR	;ƒ‹[ƒvŽü‚è‚ª‚¨‚©‚µ‚¢
	JMP	PRINT			;
MACRO_ERROR:
	MOV	DX,OFFSET MACERR	;‘¶Ý‚µ‚È‚¢ƒ}ƒNƒ‚ÌŒÄo
	JMP	PRINT			;
MACRO_ERROR2:
	MOV	DX,OFFSET MACERR2	;ƒ}ƒNƒ‚Åƒ}ƒNƒ‚ðŒÄ‚Ñ‚·‚¬
	JMP	PRINT			;
INC_ERROR:
	MOV	DX,OFFSET INCERR	;‘¶Ý‚µ‚È‚¢ƒCƒ“ƒNƒ‹[ƒhƒtƒ@ƒCƒ‹
	MOV	AX,CS			;
	MOV	DS,AX			;
	MOV	AH,09H			;
	INT	21H			;
	MOV	DX,OFFSET INCFILE	;
	JMP	PRINT			;
VOI_ERROR:
	MOV	DX,OFFSET VOIERR	;‘¶Ý‚µ‚È‚¢‰¹Fƒtƒ@ƒCƒ‹
	MOV	AX,CS			;
	MOV	DS,AX			;
	MOV	AH,09H			;
	INT	21H			;
	MOV	DX,OFFSET c_Voice_File	;
	JMP	PRINT			;
SOPEN_ERROR:
	PUSH	AX
	MOV	AH,09H
	MOV	DX,SI
	INT	21H
	POP	AX
	CMP	AX,3
	MOV	DX,OFFSET FSERR3
	JMP	PRINT
	CMP	AX,4
	MOV	DX,OFFSET FSERR4
	JMP	PRINT
	CMP	AX,5
	MOV	DX,OFFSET FSERR5
	JMP	PRINT
	JMP	OPEN_ERROR
FSERR3	DB	'–³Œø‚ÈƒpƒXEƒtƒ@ƒCƒ‹–¼',0AH,0DH,24H
FSERR4	DB	'“¯Žž‚ÉƒI[ƒvƒ“‚³‚ê‚Ä‚¢‚éƒtƒ@ƒCƒ‹‚ª‘½‚¢‚·‚¬‚é',0AH,0DH,24H
FSERR5	DB	'ƒAƒNƒZƒX‚Ì”Û’è',0AH,0DH,24H


