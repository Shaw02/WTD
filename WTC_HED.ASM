;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				Heder Compile Routine			|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;---------------------------------------------------------------|
;		ヘッダーコンパイル	初期			|
;---------------------------------------------------------------|
;	引数							|
;		無し						|
;	返り値							|
;		無し						|
;	使用レジスタ						|
;		cx	コマンド数カウンタ			|
;		di	c_Head_Com_Adrsポインタ			|
;		si	c_Hear_Com_Dataポインタ			|
;---------------------------------------------------------------|
c_Head_first:				;
	pusha				;レジスタ保存

;ヘッダー初期設定
	call	c_Head_first_Start	;

;コマンド検索
;コマンド数量の読み込み
c_Head_first_Loop1:			;cx←コマンドの数量
	xor	di,di			;di←変換定義アドレスのポインタ
	mov	cx,cs:[offset c_Head_Com_Adrs + di]
					;文字列チェックのカウンタ
;ポインタ読み込み
c_Head_first_Loop2:			;
	push	cs:[pMML_File]		;ポインタ保存
	add	di,2			;ポインタインクリメント(Word)
	mov	si,cs:[offset c_Head_Com_Adrs + di]	;si←変換定義アドレス
;１文字読み込み
c_Head_first_Loop3:			;
	call	cread			;MMLファイルから１文字読み込み
c_Head_first_Step1:			;
;１文字チェック（24h含む）
	mov	al,cs:[si]		;
	inc	si			;
	cmp	al,24h			;文字終了？
	jz	c_Head_first_Step2	;ならば、文字列一致で処理実行。
	cmp	ah,al			;文字一致？
	jz	c_Head_first_Loop3	;ならば、次もチェック。
;文字チェックで一致しなかった場合。
	pop	cs:[pMML_File]		;ポインタ復帰
	sub	cx,1			;カウンター・ディクリメント
	jnz	c_Head_first_Loop2	;次のコマンドで比較
	inc	CS:[pMML_File]		;ポインタ・インクリメント
	mov	ax,CS:[szMML_File]	;
	cmp	ax,CS:[pMML_File]	;MMLファイルの終了チェック
	jnc	c_Head_first_Loop1	;文字列比較開始。
	jmp	c_Head_first_End	;MMLファイルが[EOF]ならば終了
;-----------------------------------------------------------------------
;コマンド処理。
c_Head_first_Step2:			;
	pop	ax			;ポインタの復帰(値は戻さず。)
	push	ds			;セグメントの保存

;ポインタを元に戻す。
	dec	cs:[pMML_File]		;ポインタ・ディクリメント

;セグメントの設定
c_Head_first_Loop4:			;
	mov	al,cs:[si]		;
	inc	si			;
	cmp	al,00h			;終了
	jnz	c_Head_first_Step9	;
	jmp	c_Head_first_Step99	;
c_Head_first_Step9:			;
	cmp	al,010h			;CS (Program Segment)
	jnz	c_Head_first_Step3	;
	mov	ds,cx			;
c_Head_first_Step3:			;
	cmp	al,011h			;DS (WTD Segment)
	jnz	c_Head_first_Step4	;
	mov	ds,cs:[segWTD_File]	;
c_Head_first_Step4:			;
	cmp	al,012h			;ES (MML Segment)
	jnz	c_Head_first_Step5	;
	mov	ds,cs:[segMML_File]	;
c_Head_first_Step5:			;
	cmp	al,0F0h			;Call (Other Program)
	jnz	c_Head_first_Step11	;
	mov	dx,cs:[si]		;
	add	si,2			;
	call	dx			;
c_Head_first_Step11:			;

;オフセットの設定
	mov	bx,cs:[si]		;bx←Offset Address
	add	si,2			;

;データの書き込み
	mov	al,cs:[si]		;
	inc	si			;
	cmp	al,000h			;Byte Write
	jnz	c_Head_first_Step6	;
	call	A2H8R			;
	mov	ds:[bx],ah		;
c_Head_first_Step6:			;
	cmp	al,001h			;Word Write
	jnz	c_Head_first_Step7	;
	call	A2H16R			;
	mov	ds:[bx],ah		;
c_Head_first_Step7:			;
	cmp	al,020h			;Strings Write
	jnz	c_Head_first_Step8	;End of '$'(24h)
;
;	文字列一括転送(未対応)
;
c_Head_first_Step8:			;

;コンパイル処理ループ
	jmp	c_Head_first_Loop4	;

;命令コンパイル処理終了
c_Head_first_Step99:			;
	pop	ds			;セグメントの復帰
	jmp	c_Head_first_Loop1	;文字列比較開始。
;-----------------------------------------------------------------------
;終了
c_Head_first_End:			;
	popa				;レジスタ復帰
	ret				;
;---------------------------------------------------------------|
;		初期設定					|
;---------------------------------------------------------------|
;	引数							|
;		無し						|
;	返り値							|
;		無し						|
;---------------------------------------------------------------|
c_Head_first_Start:
	pusha				;レジスタ保存

;ポインターを先頭にする。
	xor	ax,ax			;
	mov	cs:[pMML_File],ax	;
	mov	cs:[pWTD_File],ax	;ポインターを先頭にする。

;WTDファイルのアドレス取得
	mov	ds,cs:[segWTD_File]	;
	xor	bx,bx			;ds:bx←WTD File Segment Address

;ヘッダー初期値の設定
	mov	word ptr ds:[bx].WTD_Mus_Name + 0	,5457h	;
	mov	word ptr ds:[bx].WTD_Mus_Name + 2	,0044h	;'WTD',00h
	mov	word ptr ds:[bx].WTD_Mus_Version	,0100h	;Version
	mov	word ptr ds:[bx].WTD_Mus_Extr		,0000h	;
	mov	byte ptr ds:[bx].WTD_Mus_Emb		,0	;
	mov	byte ptr ds:[bx].WTD_Mus_Voice		,0	;
	mov	byte ptr ds:[bx].WTD_Mus_Part		,0	;
	mov	byte ptr ds:[bx].WTD_Mus_TimeBase	,48	;
	mov	word ptr ds:[bx].WTD_Mus_ExtrAdr	,0000h	;
	mov	word ptr ds:[bx].WTD_Mus_DataAdr	,0000h	;

;終了
	popa				;レジスタ復帰
	ret				;Return
;===============================================================|
;			命令	初期				|
;===============================================================|
c_Head_Com_Adrs:
	dw	5			;数量
	dw	offset cHCD_0		;TB
	dw	offset cHCD_1		;PA
	dw	offset cHCD_2		;#timebase
	dw	offset cHCD_3		;#part
	dw	offset cHCD_4		;#version
;---------------------------------------------------------------|
;	①コマンド文字列					|
;		最後は24hで終わる				|
;	②出力する場所						|
;	    00h	終わり						|
;	    1xh	CS	プログラム				|
;		x	Segment		0:CS / 1:DS(WTD) / 2:ES(MML)
;		word	Offset		Offset Address		|
;		byte	Output Type	00h:Byte / 01:Word	|
;					20h:文字列+24h		|
;	    F0h	プログラム					|
;		nnnn	Offset Address				|
;---------------------------------------------------------------
c_Hear_Com_Data:
cHCD_0	db	0dh,0ah,'TB',24h, 11h	;Seg = WTD
	dw	WTD_Mus_TimeBase	;Time base
	db	00h,00h			;Byte , End
cHCD_1	db	0dh,0ah,'PA',24h, 11h	;Seg = WTD
	dw	WTD_Mus_Part		;Music Part count
	db	00h,00h			;Byte , End
cHCD_2	db	'#timebase',24h, 11h	;Seg = WTD
	dw	WTD_Mus_TimeBase	;Time base
	db	00h,00h			;Byte , End
cHCD_3	db	'#part',24h, 11h	;Seg = WTD
	dw	WTD_Mus_Part		;Music Part count
	db	00h,00h			;Byte , End
cHCD_4	db	'#version',24h, 11h	;Seg = WTD
	dw	WTD_Mus_Version + 0	;Music Version
	db	00h,11h			;Seg = WTD
	dw	WTD_Mus_Version + 1	;Music Version
	db	00h,00h			;Byte , End
;---------------------------------------------------------------
cHCD_Flag	dw	0000h		;フラグ
cHCD_voice	db	00h		;音色・エンベロープ数量
;---------------------------------------------------------------|
;		ヘッダーコンパイル	後期			|
;---------------------------------------------------------------|
;	引数							|
;		無し						|
;	返り値							|
;		無し						|
;	使用レジスタ						|
;		cx	コマンド数カウンタ			|
;		di	c_Head_Com_Adrsポインタ			|
;		si	c_Hear_Com_Dataポインタ			|
;---------------------------------------------------------------|
c_Head_end:				;
	pusha				;レジスタ保存






;終了
	popa				;レジスタ復帰
	ret				;Return
