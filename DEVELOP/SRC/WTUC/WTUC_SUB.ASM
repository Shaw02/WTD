;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				UnMML Compiler Program			|
;				SUB Routine				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;****************************************************************
;								*
;			コンパイル部				*
;								*
;****************************************************************
;---------------------------------------------------------------|
;		コンパイルルーチン				|
;---------------------------------------------------------------|
UnMML_COMPAILE:				;コンパイル
	MOV	AX,CS:[segWTD_File]	;
	MOV	ES,AX			;ES←WTD SEGMENT

;	CALL	c_Head_first		;ヘッダー設定
;	CALL	c_voice			;音色転送
;	CALL	c_emb			;エンベロープ
;	CALL	c_Command		;パートコンパイル

UnMML_COMPAILE_End:			;
	ret				;RETURN
;---------------------------------------------------------------|
;		データ読み込み					|
;---------------------------------------------------------------|
;	引数							|
;		ES:BX←アドレス					|
;	返り値							|
;		AL←データ					|
;		BX←次のアドレス				|
;---------------------------------------------------------------|
D_READ:					;
	MOV	AL,ES:[BX]		;読み込み
	INC	BX			;ポインタ　インクリメント
	RET				;RETURN
D_READ_H:				;
	MOV	AH,ES:[BX]		;読み込み
	INC	BX			;ポインタ　インクリメント
	RET				;RETURN
D_READ16:
	MOV	AX,ES:[BX]		;読み込み
	INC	BX			;ポインタ　インクリメント
	INC	BX			;
	RET				;RETURN
;****************************************************************
;*								*
;*		１０進文字列１６進コード変換ルーチン		*
;*								*
;****************************************************************
;---------------------------------------------------------------|
;		ASCII CODE→１６進コード(-127～255)		|
;---------------------------------------------------------------|
;	引数							|
;		DS:DX←変換したい文字列先頭アドレス		|
;	返り値							|
;		AH←変換後					|
;		AL←破壊					|
;		DS:BX←次のアドレス				|
;---------------------------------------------------------------|
HEX_8	DB	00H,00H,00H		;
DHEX8	DB	00H			;
F8FLAG	DB	00H			;
ASC2HEX8:				;
	PUSH	CX			;
	PUSH	DX			;
	XOR	CX,CX			;CX←0
	MOV	BX,DX			;BX←DX（文字列先頭アドレス）
	MOV	DX,OFFSET HEX_8		;DX←変換用データバッファ
	XOR	AX,AX			;
	MOV	CS:[F8FLAG],AH		;符号フラグのリセット
	MOV	AH,DS:[BX]		;
	CMP	AH,'-'			;
	JNZ	A2H8L0			;
	INC	BX			;
	MOV	AH,0F8H			;Flag
	MOV	CS:[F8FLAG],AH		;Set
A2H8L0:	MOV	AH,DS:[BX]		;
	INC	BX			;
	SUB	AH,30H			;CHR CODE→HEX CODE
	JNC	A2H8L1			;AH<0　だったら一時変換終了
	JMP	A2H8E1			;
A2H8L1:	CMP	AH,10			;
	JC	A2H8L2			;AH>10 だったら一時変換終了
	JMP	A2H8E1			;
A2H8L2:	XCHG	BX,DX			;
	MOV	CS:[BX],AH		;保存
	INC	BX			;
	XCHG	BX,DX			
	INC	CL			;
	CMP	CL,3			;３回変換したら一時変換終了
	JZ	A2H8E0			;（最大３桁( 0~255)）
	JMP	A2H8L0			;
A2H8E1:
	DEC	BX			;
A2H8E0:
	CMP	CL,0			;数値文字（-, 0~9）があった場合
	JNZ	A2H8L3			;ジャンプ
	STC				;それ以外、
	INC	BX			;エラーで戻る
	JMP	A2H8EE			;
A2H8L3:					;
	MOV	CH,0			;
	MOV	CS:[DHEX8],CH		;
	MOV	CH,CL			;CH←一時変換で変換した文字数
	MOV	CL,3			;CL←桁計算用
	XCHG	BX,DX			;	3･10^0	2･10^1	1･10^2
A2H8L4:	
	DEC	BX			;
	MOV	AH,CS:[BX]		;
	CALL	A2H8AA			;桁計算
	DEC	CL			;
	DEC	CH			;
	JNZ	A2H8L4			;文字数分
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
	CMP	CL,1			;CLが	１の場合
	JNZ	A2H8C1			;AX←AH*100
	MOV	AL,100			;
	JMP	A2H8C3			;
A2H8C1:	CMP	CL,2			;	２の場合
	JNZ	A2H8C2			;AX←AH*10
	MOV	AL,10			;
	JMP	A2H8C3			;
A2H8C2:	CMP	CL,3			;	３の場合
	JNZ	A2H8C4			;AX←AH*1
	MOV	AL,1			;
;	JMP	A2H8C3			;
A2H8C3:	CALL	KAKE8			;
	ADD	CS:[DHEX8],AL		;[DHEX8]←[DHEX8]*AX
	RET				;
A2H8C4:	MOV	CL,0			;ＣＬがそれ以外の場合
	XCHG	BX,DX			;エラー
	POP	DX			;
	MOV	DX,OFFSET A2H8EE	;
	PUSH	DX			;
	STC				;
	RET				;
;---------------------------------------------------------------|
;		かけ算ルーチン					|
;---------------------------------------------------------------|
;	引数							|
;		AH←かけられる数				|
;		AL←かける数					|
;	返り値							|
;		AX←答						|
;---------------------------------------------------------------|
KAKE8:					;
	PUSH	CX			;
	PUSH	DX			;レジスタ保存
	XOR	DX,DX			;DX←0000<h>
	MOV	CH,0			;CH←0
	MOV	CL,1			;CL←00000001<h>
KLOOP0:	TEST	AH,CL			;Bit check
	JZ	KLOOP1			;if 'L' then *KLOOP1
	CALL	KADD			;加算処理(DX+AL*2^CL)
KLOOP1:	INC	CH			;CH←CH+1
	SHL	CL,1			;CL Bit shift ←
	JNC	KLOOP0			;CL>128で終了
	MOV	AX,DX			;
	POP	DX			;
	POP	CX			;レジスタ復帰
	RET				;RETURN
;		*************************
;		*	加算処理	*
;		*************************
KADD:					;
	PUSH	AX			;
	XOR	AH,AH			;AH←00h
	CMP	CH,1			;CH=1ならば加算のみ
	JC	KADD1			;
	PUSH	CX			;
	MOV	CL,CH			;
	SHL	AX,CL			;AX←AX*2^CH
	POP	CX			;
KADD1:	ADD	DX,AX			;DX←DX+AX
	POP	AX			;
	RET				;
;****************************************************************
;*								*
;*		１６進コード１０進文字列変換ルーチン		*
;*								*
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
	DB	'-'			;符号
ASC_8	DB	'$$$$$'			;
HEX2ASC8:
	PUSH	AX			
	PUSH	BX			
	PUSH	CX			;レジスタ保存
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
	JC	H2A8L3			;１００の位ある？
	
	MOV	AL,AH			
	XOR	AH,AH			
	MOV	CH,100			
	DIV	CH			
	ADD	AL,30H			
	MOV	CS:[BX],AL		
	INC	BX			
H2A8L3:	
	CMP	AL,' '			;AL=" "だったら１００の位は無かった
	JNZ	H2A8E2			
	CMP	AH,10			;１０の位ある？
	JC	H2A8L2			
	
H2A8E2:	MOV	AL,AH			
	XOR	AH,AH			
	MOV	CH,10			
	DIV	CH			
	ADD	AL,30H			
	MOV	CS:[BX],AL		
	INC	BX			
H2A8L2:	
	ADD	AH,30H			;一の位は必ず書く
	MOV	CS:[BX],AH		;
	
	MOV	DX,OFFSET ASC_8		;アドレス
	POP	CX			
	POP	BX			
	POP	AX			
	RET				
;---------------------------------------------------------------|
;		１６進数コード～ASCII CODE(65535)		|
;---------------------------------------------------------------|
;	処理							|
;		１６進コードを１０進のアスキーコードに変換	|
;	引数							|
;		AX←変換したい数値				|
;	返り値							|
;		DX←変換した文字列の先頭アドレス		|
;---------------------------------------------------------------|
	DB	'-'			;符号
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
	POP	AX			

	MOV	BX,OFFSET ASC_16	
	MOV	CL,' '			
	MOV	DX,AX			
	CMP	DX,10000		;１００００の位はある？
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
	CMP	DX,1000			;１０００の位は？
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
	CMP	DX,100			;１００の位
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
	CMP	DX,10			;１０の位は？
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
	MOV	CS:[BX],AL		;１の位は必ず書く
	
	MOV	DX,OFFSET ASC_16	
	POP	CX			
	POP	BX			
	POP	AX			
	RET				
;---------------------------------------------------------------|
;		１６進数コード～ASCII CODE(255)	（符号付き）	|
;---------------------------------------------------------------|
;	処理							|
;		１６進コードを１０進のアスキーコードに変換	|
;	引数							|
;		AH←変換したい数値				|
;	返り値							|
;		DX←変換した文字列の先頭アドレス		|
;---------------------------------------------------------------|
FH2A8:
	PUSH	AX			
	PUSH	BX			
	PUSH	CX			
	
	TEST	AH,80H			
	JZ	F2A8L0			
	NEG	AH			
	CALL	HEX2ASC8		
	DEC	DX			
	JMP	F2A8L2			
F2A8L0:	CALL	HEX2ASC8		
F2A8L2:	
	POP	CX			
	POP	BX			
	POP	AX			
	RET				
;---------------------------------------------------------------|
;		１６進数コード～ASCII CODE(65535)（符号付き）	|
;---------------------------------------------------------------|
;	処理							|
;		１６進コードを１０進のアスキーコードに変換	|
;	引数							|
;		AH←変換したい数値				|
;	返り値							|
;		DX←変換した文字列の先頭アドレス		|
;---------------------------------------------------------------|
FH2A16:
	PUSH	AX			
	PUSH	BX			
	PUSH	CX			
	
	TEST	AH,80H			
	JZ	F2A6L0			
	NEG	AX			
	CALL	HEX2ASC16		
	DEC	DX			
	JMP	F2A6L2			
F2A6L0:	CALL	HEX2ASC16		
F2A6L2:	
	POP	CX			
	POP	BX			
	POP	AX			
	RET				
;---------------------------------------------------------------|
;		１６進数コード～ASCII CODE(255)			|
;---------------------------------------------------------------|
;	処理							|
;		１６進コードを１０進のアスキーコードに変換	|
;		４桁でフォーマットする。			|
;	引数							|
;		AH←変換したい数値				|
;	返り値							|
;		DX←変換した文字列の先頭アドレス		|
;---------------------------------------------------------------|
H2A8:
	PUSH	AX			
	PUSH	BX			
	PUSH	CX			
	MOV	BX,OFFSET ASC_8		
	MOV	CH,' '			
	MOV	CS:[BX],CH		
	INC	BX			
	
	MOV	AL,' '			
	CMP	AH,100			
	JC	H2A8L03			
	
	MOV	AL,AH			
	XOR	AH,AH			
	MOV	CH,100			
	DIV	CH			
	ADD	AL,30H			
H2A8L03:MOV	CS:[BX],AL		
	INC	BX			
	
	CMP	AL,' '			
	JNZ	H2A8E02			
	CMP	AH,10			
	JC	H2A8L02			
	
H2A8E02:MOV	AL,AH			
	XOR	AH,AH			
	MOV	CH,10			
	DIV	CH			
	ADD	AL,30H			
H2A8L02:MOV	CS:[BX],AL		

	INC	BX			
	
	ADD	AH,30H			
	MOV	CS:[BX],AH		
	
	MOV	DX,OFFSET ASC_8		
	POP	CX			
	POP	BX			
	POP	AX			
	RET				
;****************************************************************
;								*
;			メモリ関連				*
;								*
;****************************************************************
;---------------------------------------------------------------|
;		メモリ確保（WTD Data）				|
;---------------------------------------------------------------|
Memory_Open:				;
	MOV	AH,48H			;
	MOV	BX,1000H		;64KByte のデータ領域の確保
	INT	21H			;
	JNC	Memory_Open_Err		;割り当て失敗時に飛ぶ。
	JMP	MOPEN_ERROR		;
Memory_Open_Err:			;
	MOV	CS:[segWtd_File],AX	;割り当てたセグメントアドレスの保存。
	MOV	DS,AX			;DS←Segmentの設定
	RET				;
;---------------------------------------------------------------|
;		メモリ開放（WTD Data）				|
;---------------------------------------------------------------|
Memory_Close:				;
	MOV	AX,CS:[segWtd_File]	;
	MOV	ES,AX			;セグメントを読む。
	MOV	AH,49H			;
	INT	21H			;データ領域の開放
	JNC	Memory_Close_Err	;
	JMP	CLOSE_ERROR		;
Memory_Close_Err:			;
	RET				;
;---------------------------------------------------------------|
;								|
;		ＣＯＭファイルのメモリー最小化			|
;---------------------------------------------------------------|
;	処理							|
;		ＣＯＭプログラム実行時にメモリーを		|
;		最小限にする					|
;	引数							|
;		無し						|
;	返り値							|
;		DS←CS						|
;	◎	Cy←'L' のとき。（正常終了）			|
;		BX←変更したメモリーの大きさ。			|
;	◎	Cy←'H' のとき。（エラー）			|
;		BX←変更できる最大の大きさ			|
;		AX←INT21H ﾌｧﾝｸｼｮﾝ4AH参照			|
;---------------------------------------------------------------|
ComSmoleMessage7	DB	"プログラムによるメモリー中のデーターの破壊。",0DH,0AH,"$"
ComSmoleMessage8	DB	"十分な空きメモリーが無い。",0DH,0AH,"$"
ComSmoleMessage9	DB	"不正なメモリーブロックの使用。",0DH,0AH,"$"
ComSmole:			;メモリーの最小化
	PUSH	DX		;
	PUSH	CX		;レジスタの保存
	
	MOV	ES,CS:[002CH]	;環境セグメントの開放
	MOV	AH,49H		;
	INT	21H		;
	
	MOV	AX,CS		;
	MOV	DS,AX		;DS←CS
	MOV	ES,AX		;ES←CS
	MOV	BX,OFFSET WTD_UnMML_Compiler_End+BSTACK
	MOV	CL,4		;
	SHR	BX,CL		;
	INC	BX		;BX←プログラムの大きさ（パラグラフ単位）
	MOV	AH,04AH		;
	INT	21H		;最小化
	PUSH	BX		;
	PUSH	AX		;返り値の保存
	JC	ComSmoleERR	;エラー時に飛ぶ
	CLC			;Cy←'L'
	JMP	ComSmoleRET	;RETURN
;===============================================================|
ComSmoleERR:			;ファンクション4AH のＥＲＲＯＲ
	CMP	AX,07H		;
	JNZ	ComSmoleER8	;ERROR CODE=07H
	MOV	AH,09H		;
	MOV	DX,OFFSET ComSmoleMessage7
	INT	21H		;メッセージの表示
	STC			;Cy←'H'
	JMP	ComSmoleRET	;RETURN
ComSmoleER8:
	CMP	AX,08H		;
	JNZ	ComSmoleER9	;ERROR CODE=08H
	MOV	AH,09H		;
	MOV	DX,OFFSET ComSmoleMessage8
	INT	21H		;メッセージの表示
	STC			;Cy←'L'
	JMP	ComSmoleRET	;RETURN
ComSmoleER9:
	MOV	AH,09H		;ERROR CODE=09H
	MOV	DX,OFFSET ComSmoleMessage9
	INT	21H		;メッセージの表示
	STC			;Cy←'H'
	JMP	ComSmoleRET	;RETURN
;===============================================================|
ComSmoleRET:			;ＲＥＴＵＲＮ
	POP	AX		;
	POP	BX		;
	POP	CX		;レジスターの復帰
	POP	DX		;
	RET			;RETURN
;---------------------------------------------------------------|
;		エラー処理					|
;---------------------------------------------------------------|
P_TAB	DB	"	$"
P	DB	0DH,0AH,'$'
ERROR	DB	'ファイルが見つかりません。',0DH,0AH,'$'
RERROR	DB	'ファイルを読めません。',0AH,0DH,24H
MEMERR	DB	'メモリが足りません。',0AH,0DH,24H
OERROR	DB	'オープンに失敗しました',0DH,0AH,'$'
CERROR	DB	'クローズに失敗しました',0DH,0AH,'$'
OPERROR	DB	"理解不能です。",0DH,0AH,24H

D_SEG:	MOV	AX,ES			;
	MOV	DS,AX			;DS←Data
	ADD	DX,1000H		;
	RET				;
C_SEG:	MOV	AX,CS			;
	MOV	DS,AX			;DS←Program
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
;FILE_ERROR:
;	MOV	DX,OFFSET FERROR	;
;	JMP	PRINT			;
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
SOPEN_ERROR:
	CMP	AX,3
	MOV	DX,OFFSET FSERR3
	JMP	PRINT
	CMP	AX,4
	MOV	DX,OFFSET FSERR4
	JMP	PRINT
	CMP	AX,5
	MOV	DX,OFFSET FSERR5
	JMP	PRINT
FSERR3	DB	'指定されたパス・ファイル名が見つかりません。',0AH,0DH,24H
FSERR4	DB	'同時にオープンされているファイルが多いすぎます。',0AH,0DH,24H
FSERR5	DB	'アクセスが拒否されました。',0AH,0DH,24H
OPTION_ERROR:
	MOV	DX,OFFSET OPERROR	;
	JMP	LPRINT			;


