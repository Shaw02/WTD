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
;****************************************************************
;								*
;			メモリ関連				*
;								*
;****************************************************************
;---------------------------------------------------------------|
;		メモリ確保					|
;---------------------------------------------------------------|
;	●引数							|
;		ax	割り当てたいパラグラム			|
;	●返り値						|
;		ax	割り当てたメモリのセグメント		|
;---------------------------------------------------------------|
Memory_Open:				;
	push	bx			;

	MOV	bx,ax			;データ領域の確保

	MOV	AH,48H			;
	INT	21H			;

	JNC	Memory_Open_Err		;割り当て失敗時に飛ぶ。
	call	File_Err		;
Memory_Open_Err:			;

	pop	bx
	RET				;
;---------------------------------------------------------------|
;		メモリ開放					|
;---------------------------------------------------------------|
;	●引数							|
;		ax	開放するメモリのセグメント		|
;	●返り値						|
;		無し						|
;---------------------------------------------------------------|
Memory_Close:				;
	push	ax			;
	push	es			;

	mov	es,ax			;

	MOV	AH,49H			;
	INT	21H			;データ領域の開放

	JNC	Memory_Close_Err	;
	call	File_Err		;
Memory_Close_Err:			;

	pop	es			;
	pop	ax			;
	RET				;
;****************************************************************
;								*
;			ファイル関連				*
;								*
;****************************************************************
;---------------------------------------------------------------|
;		ファイルの作成					|
;---------------------------------------------------------------|
;	●引数							|
;		ds:dx	ファイルネームのポインタ		|
;			0 ･･･ Read				|
;			1 ･･･ Write				|
;			2 ･･･ Randam				|
;	●返り値						|
;		ax	ハンドル				|
;---------------------------------------------------------------|
File_Create	proc	near		;

		mov	ah,3ch		;
		int	21h		;

		jnc	File_Create_Ok	;
		call	File_Err	;
File_Create_Ok:				;
		ret			;
File_Create	endp			;
;---------------------------------------------------------------|
;		ファイルのオープン				|
;---------------------------------------------------------------|
;	●引数							|
;		ds:dx	ファイルネームのポインタ		|
;		al	0 ･･･ Read				|
;			1 ･･･ Write				|
;			2 ･･･ Randam				|
;	●返り値						|
;		ax	ハンドル				|
;---------------------------------------------------------------|
File_Open	proc	near		;

		mov	ah,3dh		;
		int	21h		;

		jnc	File_Open_Ok	;
		call	File_Err	;
File_Open_Ok:				;
		ret			;
File_Open	endp			;
;---------------------------------------------------------------|
;		ファイルのクローズ				|
;---------------------------------------------------------------|
;	●引数							|
;		ax	ハンドル				|
;	●返り値						|
;---------------------------------------------------------------|
File_Close	proc	near		;
		push	ax		;
		push	bx		;

		mov	bx,ax		;bx←ハンドル

		mov	ah,3eh		;
		int	21h		;

		jnc	File_Close_Ok	;
		call	File_Err	;
File_Close_Ok:				;
		pop	bx		;
		pop	ax		;
		ret			;
File_Close	endp			;
;---------------------------------------------------------------|
;		ファイルのロード				|
;---------------------------------------------------------------|
;	●引数							|
;		ax	ハンドル				|
;		ds:dx	バッファのアドレス			|
;	●返り値						|
;		ax	読み込めたバイト数			|
;---------------------------------------------------------------|
File_Load	proc	near		;
		push	bx		;
		push	cx		;

		mov	bx,ax		;bx←ハンドル
		mov	cx,0ffffh	;全部読むよ？
		mov	ah,3fh		;
		int	21h		;

		jnc	File_Load_Ok	;
		call	File_Err	;
File_Load_Ok:				;
		pop	cx		;
		pop	bx		;
		ret			;
File_Load	endp			;
;---------------------------------------------------------------|
;		ファイルのライト				|
;---------------------------------------------------------------|
;	●引数							|
;		ax	ハンドル				|
;		cx	書き込みバイト数			|
;		ds:dx	バッファのアドレス			|
;	●返り値						|
;---------------------------------------------------------------|
File_Write	proc	near		;
		push	bx		;
		push	cx		;

		mov	bx,ax		;bx←ハンドル
		mov	ah,040h		;
		int	21h		;

		jnc	File_Write_Ok	;
		call	File_Err	;
File_Write_Ok:				;
		pop	cx		;
		pop	bx		;
		ret			;
File_Write	endp			;
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
	MOV	BX,OFFSET Dat2Asm_End+BSTACK
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
;		エラー終了					|
;---------------------------------------------------------------|
;	●引数							|
;		ax Error Code					|
;---------------------------------------------------------------|
Error_MsgOffset:
	dw	offset	Err_M00
	dw	offset	Err_M01
	dw	offset	Err_M02
	dw	offset	Err_M03
	dw	offset	Err_M04
	dw	offset	Err_M05
	dw	offset	Err_M06
	dw	offset	Err_M07
	dw	offset	Err_M08
	dw	offset	Err_M09
	dw	offset	Err_M0A
	dw	offset	Err_M0B
	dw	offset	Err_M0C
	dw	offset	Err_M0D
	dw	offset	Err_M0E
	dw	offset	Err_M0F

Err_M00	db	'正常',0dh,0ah,24h
Err_M01	db	'無効な機能コードです。',0dh,0ah,24h
Err_M02	db	'ファイルが存在しません。',0dh,0ah,24h
Err_M03	db	'指定されたパスが無効です',0dh,0ah,24h
Err_M04	db	'オープンされているファイルが多いです。',0dh,0ah,24h
Err_M05	db	'アクセスが拒否されました。',0dh,0ah,24h
Err_M06	db	'指定されたファイルは、現在オープンされていません。',0dh,0ah,24h
Err_M07	db	'Memory Control Blockが破壊されています。',0dh,0ah,24h
Err_M08	db	'十分な大きさのメモリがありません。',0dh,0ah,24h
Err_M09	db	'指定されたメモリーは、割り当てられていません。',0dh,0ah,24h
Err_M0A	db	'環境変数が32kByte以上あります。',0dh,0ah,24h
Err_M0B	db	'指定されたファイルのexeヘッダーが正しくありません。',0dh,0ah,24h
Err_M0C	db	'ファイルアクセスコードが0～2の範囲外です',0dh,0ah,24h
Err_M0D	db	'指定されたデバイスは無効です。',0dh,0ah,24h
Err_M0E	db	'？',0dh,0ah,24h
Err_M0F	db	'指定されたドライブ番号は無効です。',0dh,0ah,24h
File_Err	proc	near

		mov	bx,offset Error_MsgOffset
		shl	ax,1			;
		add	bx,ax			;
		mov	dx,cs:[bx]		;
		push	cs			;
		pop	ds			;

		mov	AH,09H			;
		int	21H			;
		jmp	COMEND			;

		ret
File_Err	endp
