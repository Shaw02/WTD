;=======================================================================|
;									|
;	変換サブルーチン						|
;		10進（ASCII）	─　16進(BIN)				|
;		16進（BIN）	－　10進（ASCII）			|
;		16進（BIN）	－　16進（ASCII）			|
;									|
;					Programmed by			|
;						────		|
;									|
;=======================================================================|
;---------------------------------------------------------------|
;		ASCII CODE→１６進コード(-128～256)		|
;			数値データがあるまでずっと		|
;---------------------------------------------------------------|
;	引数							|
;		CS:[pMML_File] ←変換したい文字列先頭アドレス	|
;		ES←MML Dataのあるセグメント			|
;	返り値							|
;		AH←データ					|
;		CS:[pMML_File] ←次のアドレス			|
;---------------------------------------------------------------|
.code
A2H8R	proc	near
	PUSH	BX			;
	PUSH	CX			;
	PUSH	DX			;
	PUSH	DS			;
	MOV	CL,AL			;ALの保存
	PUSH	AX			;
	MOV	AX,ES			;
	MOV	DS,AX			;
	POP	AX			;
	MOV	DX,CS:[pMML_File]	;
A2H8R1:	CALL	COMMENT_CHK		;コメントチェック
	CALL	ASC2HEX8		;ASC Code →16進Code変換
	MOV	DX,BX			;
	JNC	A2H8RR			;変換不可能？だったら
	JMP	A2H8R1			;やり直し。
A2H8RR:	MOV	CS:[pMML_File],DX	;
	MOV	AL,CL			;ALの復帰
	POP	DS			;
	POP	DX			;
	POP	CX			;
	POP	BX			;
	RET				;RETURN
A2H8R	endp
;---------------------------------------------------------------|
;		ASCII CODE→１６進コード(-32767～65535)		|
;			数値データがあるまでずっと		|
;---------------------------------------------------------------|
;	引数							|
;		CS:[pMML_File] ←変換したい文字列先頭アドレス	|
;		ES←MML Dataのあるセグメント			|
;	返り値							|
;		AX←データ					|
;		CS:[pMML_File] ←次のアドレス			|
;---------------------------------------------------------------|
A2H16R	proc	near
	CALL	COMMENT_CHK		;コメントチェック

	PUSH	BX			;
	PUSH	DX			;
	PUSH	DS			;
	PUSH	AX			;
	MOV	AX,ES			;
	MOV	DS,AX			;
	POP	AX			;
	MOV	DX,CS:[pMML_File]	;
A2H16R1:CALL	ASC2HEX16		;ASC Code →16進Code変換
	MOV	DX,BX			;
	JNC	A2H16RR			;変換不可能？だったら
	JMP	A2H16R1			;やり直し。
A2H16RR:MOV	CS:[pMML_File],DX	;
	POP	DS			;
	POP	DX			;
	POP	BX			;
	RET				;RETURN
A2H16R	endp
;---------------------------------------------------------------|
;		コンパイルデータ読み込み			|
;---------------------------------------------------------------|
;	引数							|
;		CS:[pMML_File]：コンパイルアドレス		|
;		ES←MML Dataのあるセグメント			|
;	返り値							|
;		AH	 　：データ				|
;		CS:[pMML_File]：次のアドレス			|
;---------------------------------------------------------------|
CREAD	proc	near	uses	si

	call	COMMENT_CHK		;
	MOV	si,CS:[pMML_File]	;BX←コンパイルするアドレス
	mov	ah,es:[si]		;AH←そこのデータ
	inc	si			;BX（ポインタ）を増加
	mov	cs:[pMML_File],si	;
	cmp	cs:[szMml_File],si	;ポインタがサイズを越えていたらCy←'H'

	RET				;
CREAD	endp
;---------------------------------------------------------------|
CREAD_L	proc	near	uses	si

	call	COMMENT_CHK		;
	MOV	si,CS:[pMML_File]	;si←コンパイルするアドレス
	lodsb	es:[si]			;AL←そこのデータ
	mov	cs:[pMML_File],si	;
	cmp	cs:[szMml_File],si	;ポインタがサイズを越えていたらCy←'H'

	RET				;
CREAD_L	endp
;---------------------------------------------------------------|
;		コンパイルデータ書き込み			|
;---------------------------------------------------------------|
;	引数							|
;		AH	 　：データ				|
;		CS:[pWTD_File]：コンパイルアドレス		|
;		DS←FSP データを書くセグメント			|
;	返り値							|
;		CS:[pWTD_File]：次のアドレス			|
;---------------------------------------------------------------|
CSET	proc	near	uses	di
	MOV	di,CS:[pWTD_File]	;di←コンパイルしたアドレス
	MOV	DS:[di],AH		;書き込み
	inc	CS:[pWTD_File]		;（ポインタ）増加
	RET				;
CSET	endp
;---------------------------------------------------------------
CSET_L	proc	near	uses	di
	MOV	di,CS:[pWTD_File]	;di←コンパイルしたアドレス
	MOV	DS:[di],al		;書き込み
	inc	CS:[pWTD_File]		;（ポインタ）増加
	RET				;
CSET_L	endp
;---------------------------------------------------------------
CSET16	proc	near	uses	di
	MOV	di,CS:[pWTD_File]	;di←コンパイルしたアドレス
	MOV	DS:[di],ax		;書き込み
	add	CS:[pWTD_File],2	;（ポインタ）増加
	RET				;
CSET16	endp
;---------------------------------------------------------------|
;		コメントチェック				|
;---------------------------------------------------------------|
COMMENT_CHK	proc	near	uses ax si
	MOV	si,CS:[pMML_File]	;BX←コンパイル中アドレス
	MOV	al,ES:[si]		;AH←そこのデータ
	CMP	al,';'			;もしコメントがあったら改行までジャンプ
	JNZ	REMCHK			;
	CALL	CRJUMP			;
REMCHK:	
	RET				;
COMMENT_CHK	endp
;---------------------------------------------------------------|
;		改行まで飛ばす					|
;---------------------------------------------------------------|
CRJUMP	proc	near	uses	ax si

	mov	si,CS:[pMML_File]	;BX←コンパイルするアドレス
	.repeat
	lodsb	es:[si]			;AH←そこのデータ
	.until	(al == 0dh)		;改行？

	dec	si
	mov	CS:[pMML_File],si	;ポインタを増加

	RET				;
CRJUMP	endp
