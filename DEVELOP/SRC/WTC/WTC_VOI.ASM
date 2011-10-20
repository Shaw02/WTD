;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				Voice Compile Routine			|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
c_Voice	proc	near

	;コンパイル作業
	call	c_Voice_Pcm_first	;
	call	c_Voice_Emb_first	;

	ret				;終了
c_Voice	endp
;---------------------------------------------------------------|
;		音色コンパイル					|
;---------------------------------------------------------------|
;	引数							|
;		無し						|
;	返り値							|
;		無し						|
;	使用レジスタ						|
;		cx	コマンド数カウンタ			|
;		di	c_Voice_Pcm_Adrsポインタ		|
;		si	c_Voice_Pcm_Dataポインタ		|
;---------------------------------------------------------------|
c_Voice_Pcm_first	proc	near		;
	pusha				;レジスタ保存

;ヘッダー初期設定
	;ポインターの設定及び、トラックアドレスの初期化をする。
	xor	bx,bx				;
	mov	cs:[pMML_File],bx		;MMLファイルのポインタを先頭にする。
	mov	cl,ds:[bx].WTD_Mus_Part		;パート数を読み込み。
	.if	(cl > MusicMaxPart)		;パート数チェック
		mov	cl,MusicMaxPart		;
		mov	ds:[bx].WTD_Mus_Part,cl	;パート数を書き込み。
	.endif					;
	mov	bx,0010h			;
	.repeat					;
		sub	cl,1			;カウンタ・ディクリメント
		.break	.if	(carry?)	;
		mov	word ptr ds:[bx],0000h	;トラックのアドレスの初期化
		add	bx,2			;ポインタ・インクリメント
	.until	0				;
	mov	cs:[pWTD_File],bx		;WTDファイルのポインタを設定する。

	;アドレス設定
	mov	word ptr ds:[0].WTD_Mus_DataAdr,bx

;コマンド検索
;コマンド数量の読み込み
c_Voice_Pcm_first_Loop1:		;cx←コマンドの数量
	xor	di,di			;di←変換定義アドレスのポインタ
	mov	cx,cs:[offset c_Voice_Pcm_Adrs + di]
					;文字列チェックのカウンタ
;ポインタ読み込み
c_Voice_Pcm_first_Loop2:		;
	push	cs:[pMML_File]		;ポインタ保存
	add	di,2			;ポインタインクリメント(Word)
	mov	si,cs:[offset c_Voice_Pcm_Adrs + di]	;si←変換定義アドレス
;１文字読み込み
c_Voice_Pcm_first_Loop3:		;
	call	cread			;MMLファイルから１文字読み込み
c_Voice_Pcm_first_Step1:		;
;１文字チェック（24h含む）
	mov	al,cs:[si]		;
	inc	si			;
	cmp	al,24h			;文字終了？
	jz	c_Voice_Pcm_first_Step2	;ならば、文字列一致で処理実行。
	cmp	ah,al			;文字一致？
	jz	c_Voice_Pcm_first_Loop3	;ならば、次もチェック。
;文字チェックで一致しなかった場合。
	pop	cs:[pMML_File]		;ポインタ復帰
	sub	cx,1			;カウンター・ディクリメント
	jnz	c_Voice_Pcm_first_Loop2	;次のコマンドで比較
	inc	CS:[pMML_File]		;ポインタ・インクリメント
	mov	ax,CS:[szMML_File]	;
	cmp	ax,CS:[pMML_File]	;MMLファイルの終了チェック
	jnc	c_Voice_Pcm_first_Loop1	;文字列比較開始。
	jmp	c_Voice_Pcm_first_End	;MMLファイルが[EOF]ならば終了
;-----------------------------------------------------------------------
;コマンド処理。
c_Voice_Pcm_first_Step2:			;
	pop	ax			;ポインタの復帰(値は戻さず。)
	push	ds			;セグメントの保存

;ポインタを元に戻す。
	dec	cs:[pMML_File]		;ポインタ・ディクリメント

;コマンド処理
c_Voice_Pcm_first_Loop4:		;
	mov	al,cs:[si]		;al←コマンド
	inc	si			;
	mov	cl,cs:[si]		;
	inc	si			;
	cmp	al,00h			;終了
	jnz	c_Voice_Pcm_first_Step3	;
	jmp	c_Voice_Pcm_first_Step99
c_Voice_Pcm_first_Step3:		;
	cmp	al,010h			;4bit × 2
	jnz	c_Voice_Pcm_first_Step4	;
c_Voice_Pcm_first_Step3_Loop:		;
	call	A2H8R			;
	and	ah,0fh			;
	mov	al,ah			;
	call	A2H8R			;
	and	ah,0fh			;
	shl	ah,4			;
	or	ah,al			;
	call	cset			;
	sub	cl,1			;
	jnz	c_Voice_Pcm_first_Step3_Loop
	jmp	c_Voice_Pcm_first_Loop4	;
c_Voice_Pcm_first_Step4:		;
	cmp	al,011h			;Byte
	jnz	c_Voice_Pcm_first_Step5	;
c_Voice_Pcm_first_Step4_Loop:		;
	call	A2H8R			;
	call	CSET			;
	sub	cl,1			;
	jnz	c_Voice_Pcm_first_Step4_Loop
	jmp	c_Voice_Pcm_first_Loop4	;
c_Voice_Pcm_first_Step5:		;
	cmp	al,012h			;Word
	jnz	c_Voice_Pcm_first_Step6	;
c_Voice_Pcm_first_Step5_Loop:		;
	call	A2H16R			;
	call	CSET16			;
	sub	cl,1			;
	jnz	c_Voice_Pcm_first_Step5_Loop
	jmp	c_Voice_Pcm_first_Loop4	;
c_Voice_Pcm_first_Step6:		;
	cmp	al,0F0h			;Call (Other Program)
	jnz	c_Voice_Pcm_first_Step7	;

	dec	si			;Countは無いので、siを戻す。
	mov	dx,cs:[si]		;
	add	si,2			;
	call	dx			;
;	jmp	c_Voice_Pcm_first_Loop4	;
c_Voice_Pcm_first_Step7:		;

;コンパイル処理ループ
	jmp	c_Voice_Pcm_first_Loop4	;

;命令コンパイル処理終了
c_Voice_Pcm_first_Step99:		;

;カウンタインクリメント
	inc	byte ptr ds:[0].WTD_Mus_Voice

;戻る
	pop	ds			;セグメントの復帰
	jmp	c_Voice_Pcm_first_Loop1	;文字列比較開始。
;-----------------------------------------------------------------------
;終了
c_Voice_Pcm_first_End:			;
	popa				;レジスタ復帰
	ret				;
c_Voice_Pcm_first	endp
;===============================================================|
;			命令					|
;===============================================================|
.const
c_Voice_Pcm_Adrs	dw	((offset c_Voice_Pcm_Adrs_E)-(offset c_Voice_Pcm_Adrs_S))/2 + 1
c_Voice_Pcm_Adrs_S	dw	offset cVPD_0		;#Voice
			dw	offset cVPD_1		;@F
c_Voice_Pcm_Adrs_E	dw	offset cVPD_2		;@
;---------------------------------------------------------------|
;	①コマンド文字列					|
;		最後は24hで終わる				|
;	②出力する場所						|
;	    00h	終わり						|
;	    1xh		データ書き込み				|
;		x	0:4bit×2 / 1:Byte / 2:Word		|
;		byte	Count					|
;	    F0h	プログラム					|
;		nnnn	Offset Address				|
;---------------------------------------------------------------
cVPD_0	db	'#voice'    ,24h, 011h,1, 010h,16, 00h
cVPD_1	db	0dh,0ah,'@F',24h, 011h,1, 0F0h	;@の前にある事！！
	dw	offset c_Voice_Pcm_File
	db	00h
cVPD_2	db	0dh,0ah,'@' ,24h, 011h,1, 010h,16, 00h
.code
;---------------------------------------------------------------|
;●ファイルからの読み込み		;
c_Voice_Pcm_File	proc	near

	local	cFilename[128]:BYTE	;[BP+80h]

	pusha				;レジスタ保存

	call	A2H8R			;音色番号読み込み
	push	ax			;番号保存

	;ファイル名文字列先頭の検索
	.repeat
	    CALL	CREAD_L		;
	.until	(al>20h)		;２０未満のコードは飛ばす

	;ファイル名文字列をピックアップ
	dec	cs:[pMML_File]		;ポインタを一つ戻す。
	xor	di,di			;
	mov	cx,128			;cl←ファイル名の最大文字数
	.repeat				;
	   CALL	CREAD_L			;
	   .break   .if	(al == 00dh)	;改行だったら格納終了
	   mov	cFilename[di],al	;mov [BP + DI + 80h],ah
	   inc	di			;
	.untilcxz			;
	mov	cFilename[di],0		;
	inc	di			;
	mov	cFilename[di],0dh	;
	inc	di			;
	mov	cFilename[di],0ah	;
	inc	di			;
	mov	cFilename[di],24h	;

	;音色の転送
	pop	bx			;音色番号の復帰
	mov	bl,bh			;
	xor	bh,bh			;
	shl	bx,4			;bx ← 音色ファイルのオフセット

	;ファイルの読み込み
	;音色ファイル用メモリオープン
	push	es			;
	invoke	Memory_Open,	0800h	;
	mov	es,ax			;es ← 音色ファイル
	invoke	File_Open,	addr ss:cFilename,0
	push	ax			;ハンドル保存
	invoke	File_Load,	ax,addr es:0
	pop	ax			;ハンドル復帰
	invoke	File_Close,	ax	;ファイルクローズ

	mov	cx,16			;cx ← 転送数
	.repeat
		mov	ah,es:[bx]	;
		inc	bx		;
		call	CSET		;
	.untilcxz

	invoke	Memory_Close,	es	;メモリの解放
	pop	es			;

	dec	cs:[pMML_File]		;ポインタ１つ戻す。

	popa				;レジスタ復帰
	ret				;
c_Voice_Pcm_File	endp
;---------------------------------------------------------------|
;		音色コンパイル					|
;---------------------------------------------------------------|
;	引数							|
;		無し						|
;	返り値							|
;		無し						|
;	使用レジスタ						|
;		cx	コマンド数カウンタ			|
;		di	c_Voice_Emb_Adrsポインタ		|
;		si	c_Voice_Emb_Dataポインタ		|
;---------------------------------------------------------------|
c_Voice_Emb_first	proc	near		;
	pusha				;レジスタ保存

;ヘッダー初期設定
	;ポインターの設定。
	mov	cs:[pMML_File],0	;MMLファイルのポインタを先頭にする。

;コマンド検索
;コマンド数量の読み込み
c_Voice_Emb_first_Loop1:		;cx←コマンドの数量
	xor	di,di			;di←変換定義アドレスのポインタ
	mov	cx,cs:[offset c_Voice_Emb_Adrs + di]
					;文字列チェックのカウンタ
;ポインタ読み込み
c_Voice_Emb_first_Loop2:		;
	push	cs:[pMML_File]		;ポインタ保存
	add	di,2			;ポインタインクリメント(Word)
	mov	si,cs:[offset c_Voice_Emb_Adrs + di]	;si←変換定義アドレス
;１文字読み込み
c_Voice_Emb_first_Loop3:		;
	call	cread			;MMLファイルから１文字読み込み
c_Voice_Emb_first_Step1:		;
;１文字チェック（24h含む）
	mov	al,cs:[si]		;
	inc	si			;
	cmp	al,24h			;文字終了？
	jz	c_Voice_Emb_first_Step2	;ならば、文字列一致で処理実行。
	cmp	ah,al			;文字一致？
	jz	c_Voice_Emb_first_Loop3	;ならば、次もチェック。
;文字チェックで一致しなかった場合。
	pop	cs:[pMML_File]		;ポインタ復帰
	sub	cx,1			;カウンター・ディクリメント
	jnz	c_Voice_Emb_first_Loop2	;次のコマンドで比較
	inc	CS:[pMML_File]		;ポインタ・インクリメント
	mov	ax,CS:[szMML_File]	;
	cmp	ax,CS:[pMML_File]	;MMLファイルの終了チェック
	jnc	c_Voice_Emb_first_Loop1	;文字列比較開始。
	jmp	c_Voice_Emb_first_End	;MMLファイルが[EOF]ならば終了
;-----------------------------------------------------------------------
;コマンド処理。
c_Voice_Emb_first_Step2:			;
	pop	ax			;ポインタの復帰(値は戻さず。)
	push	ds			;セグメントの保存

;ポインタを元に戻す。
	dec	cs:[pMML_File]		;ポインタ・ディクリメント

;コマンド処理
c_Voice_Emb_first_Loop4:		;
	mov	al,cs:[si]		;al←コマンド
	inc	si			;
	cmp	al,0FFh			;終了
	jnz	c_Voice_Emb_first_Step3	;
	jmp	c_Voice_Emb_first_Step99
c_Voice_Emb_first_Step3:		;
	cmp	al,0F0h			;Call (Other Program)
	jnz	c_Voice_Emb_first_Step7	;
	mov	dx,cs:[si]		;
	add	si,2			;
	call	dx			;
	jmp	c_Voice_Emb_first_Loop4	;
c_Voice_Emb_first_Step7:		;
	cmp	al,010h			;
	jnz	c_Voice_Emb_first_Step4	;
	call	A2H8R			;
	call	CSET			;
	jmp	c_Voice_Emb_first_Loop4	;
c_Voice_Emb_first_Step4:		;
	xor	bx,bx			;
	mov	bl,al			;
	rol	bl,1			;
	shr	bl,1			;Bit 7 Reset & Bit 7 -> Cy Flag
	jc	c_Voice_Emb_first_Step5	;
	call	A2H8R			;al←データ(MML File)
	jmp	c_Voice_Emb_first_Step6	;
c_Voice_Emb_first_Step5:		;
	mov	ah,cs:[si]		;al←データ(設定値)
	inc	si			;
c_Voice_Emb_first_Step6:		;
	add	bx,cs:[pWTD_File]	;
	mov	byte ptr ds:[bx],ah	;データ書き込み

;コンパイル処理ループ
	jmp	c_Voice_Emb_first_Loop4	;

;命令コンパイル処理終了
c_Voice_Emb_first_Step99:		;

;カウンタインクリメント
	inc	byte ptr ds:[0].WTD_Mus_Emb
;ポインタ増加
	add	cs:[pWTD_File],16	;16Byte分増加(直書きしている為)

;戻る
	pop	ds			;セグメントの復帰
	jmp	c_Voice_Emb_first_Loop1	;文字列比較開始。
;-----------------------------------------------------------------------
;終了
c_Voice_Emb_first_End:			;
	popa				;レジスタ復帰
	ret				;
c_Voice_Emb_first	endp
;===============================================================|
;			命令					|
;===============================================================|
.const
c_Voice_Emb_Adrs	dw	((offset c_Voice_Emb_Adrs_E)-(offset c_Voice_Emb_Adrs_S))/2 + 1
c_Voice_Emb_Adrs_S	dw	offset cVED_0		;E
c_Voice_Emb_Adrs_E	dw	offset cVED_1		;Ex
;---------------------------------------------------------------|
;	①コマンド文字列					|
;		最後は24hで終わる				|
;	②出力する場所						|
;	    0xh		Address (Emb.Sturc)			|
;	    8xh		Address (Emb.Sturc)			|
;		byte	Data					|
;	    F0h	プログラム					|
;		nnnn	Offset Address				|
;	    FFh	終わり						|
;---------------------------------------------------------------
cVED_0	db	0dh,0ah,'Ex',24h,10h
	db	WTD_Emb_FL
	db	WTD_Emb_AR
	db	WTD_Emb_AS
	db	WTD_Emb_AL
	db	WTD_Emb_DR
	db	WTD_Emb_DS
	db	WTD_Emb_DL
	db	WTD_Emb_SR
	db	WTD_Emb_SS
	db	WTD_Emb_SL
	db	WTD_Emb_RR
	db	WTD_Emb_RS
	db	WTD_Emb_RL
	db	0FFh
cVED_1	db	0dh,0ah,'E', 24h,10h
	db	WTD_Emb_FL
	db	WTD_Emb_AR
	db	WTD_Emb_AS + 80h,001h
	db	WTD_Emb_AL + 80h,0ffh
	db	WTD_Emb_DR
	db	WTD_Emb_DS + 80h,0ffh
	db	WTD_Emb_DL
	db	WTD_Emb_SR
	db	WTD_Emb_SS + 80h,0ffh
	db	WTD_Emb_SL + 80h,000h
	db	WTD_Emb_RR
	db	WTD_Emb_RS + 80h,0ffh
	db	WTD_Emb_RL + 80h,000h
	db	0FFh
.code
