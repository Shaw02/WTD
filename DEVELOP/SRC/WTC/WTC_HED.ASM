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
					;ポインタはコマンドの次にある。

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
	push	cs			;
	pop	ds			;
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
	jmp	c_Head_first_Loop4	;
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
	mov	ds:[bx],ax		;
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
	dw	11			;数量
	dw	offset cHCD_0		;TB
	dw	offset cHCD_1		;PA
	dw	offset cHCD_2		;FX
	dw	offset cHCD_3		;TI
	dw	offset cHCD_4		;FI
	dw	offset cHCD_5		;#timebase
	dw	offset cHCD_6		;#part
	dw	offset cHCD_7		;#version
	dw	offset cHCD_8		;#Switch
	dw	offset cHCD_9		;#title
	dw	offset cHCD_10		;#filename
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
cHCD_0	db	0dh,0ah,'TB',24h, 011h	;Seg = WTD
	dw	WTD_Mus_TimeBase	;Time base
	db	00h,00h			;Byte , End
cHCD_1	db	0dh,0ah,'PA',24h, 011h	;Seg = WTD
	dw	WTD_Mus_Part		;Music Part count
	db	00h,00h			;Byte , End
cHCD_2	db	0dh,0ah,'FX',24h, 010h	;Seg = CS
	dw	offset cHCD_FlagFx	;FX File Make
	db	00h,00h			;Byte , End
cHCD_3	db	0dh,0ah,'TI',24h, 0f0h	;
	dw	offset cHCD_Set_title	;
	db	00h			;
cHCD_4	db	0dh,0ah,'FI',24h, 0f0h	;
	dw	offset cHCD_Set_filename
	db	00h			;
cHCD_5	db	'#timebase',24h, 11h	;Seg = WTD
	dw	WTD_Mus_TimeBase	;Time base
	db	00h,00h			;Byte , End
cHCD_6	db	'#part',24h, 11h	;Seg = WTD
	dw	WTD_Mus_Part		;Music Part count
	db	00h,00h			;Byte , End
cHCD_7	db	'#version',24h, 11h	;Seg = WTD
	dw	WTD_Mus_Version + 0	;Music Version
	db	00h,11h			;Seg = WTD
	dw	WTD_Mus_Version + 1	;Music Version
	db	00h,00h			;Byte , End
cHCD_8	db	'#switch',24h, 10h	;Seg = CS
	dw	cHCD_FlagFx		;FX File Make
	db	00h,00h			;Byte , End
cHCD_9	db	'#title',24h, 0f0h	;
	dw	offset cHCD_Set_title	;
	db	00h			;
cHCD_10	db	'#filename',24h, 0f0h	;
	dw	offset cHCD_Set_filename
	db	00h			;
;---------------------------------------------------------------
cHCD_Flag	dw	0000h		;フラグ
cHCD_FlagFx	db	00h		;フラグ FXファイル生成
cHCD_voice	db	00h		;音色・エンベロープ数量
;---------------------------------------------------------------
FX:		db	23h,21h,77h,73h	;#!ws
		db	60	Dup(0FFh)
FX_filename	db	16	dup(0)	;ファイル名
FX_title	db	24	dup(0)	;タイトル
FX_fileadr	dd	0FFFFFFFFh	;ファイルのアドレス。
FX_filesize	dd	?		;ファイルサイズ
FX_block	dw	?		;ブロック数
FX_mode		dw	0006h		;モード
FX_data		dd	?		;年・時間
FX_type		dd	000000000h	;ファイルの種類
FX_resouce	dd	0FFFFFFFFh	;リソースの位置。
;---------------------------------------------------------------
cHCD_Set_title:				;
	push	ax			;
	push	bx			;
	push	cx			;レジスタ保存

	mov	bx,offset FX_title	;
	mov	cx,24			;

	jmp	cHCD_Set_Loop		;
;---------------------------------------------------------------
cHCD_Set_filename:			;
	push	ax			;
	push	bx			;
	push	cx			;レジスタ保存

	mov	bx,offset FX_filename	;
	mov	cx,16			;

cHCD_Set_Loop:				;
	call	cread			;空白のチェック
	cmp	ah,21h			;
	jc	cHCD_Set_Loop		;
	dec	cs:[pMML_File]		;ポインタ・ディクリメント

cHCD_Set_Str:				;
;改行チェック
	call	cread			;ah←データ
	dec	cs:[pMML_File]		;ポインタ・ディクリメント
	cmp	ah,0dh			;
	jz	cHCD_Set_Str_End	;

;転送
	mov	cs:[bx],ah		;文字の転送
	inc	bx			;

;文字数チェック
	inc	cs:[pMML_File]		;ポインタ・インクリメント
	dec	cx			;
	cmp	cx,0			;
	jnz	cHCD_Set_Str		;

cHCD_Set_Str_End:			;
	pop	cx			;レジスタ復帰
	pop	bx			;
	pop	ax			;
	ret				;
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
;●文字列
c_Head_Version	db	'This Music Data is version $'
c_Head_Point	db	'.$'
c_Head_CR	db	0dh,0ah,24h
c_Head_Size	db	'Filesize = '     ,24h
c_Head_Byte	db	' [Byte]   ( $'
c_Head_Block	db	' [Block] )',0dh,0ah,24h
;---------------------------------------------------------------
c_Head_end:				;
	pusha				;レジスタ保存
	push	ds
	push	es

	push	ds			;
	pop	es			;es←ds
	push	cs			;
	pop	ds			;ds←cs
;---------------------------------------------------------------
;バージョン情報の表示

	xor	bx,bx			;ds:bx←WTD File Segment Address

	mov	dx,offset c_Head_Version
	mov	ah,09h			;
	int	21h			;"This Music Data is Version "

	mov	ax,word ptr es:[bx].WTD_Mus_Version

	push	ax			;
	xchg	ah,al			;
	call	HEX2ASC8		;
	mov	ah,09h			;
	int	21h			;数値の表示
	mov	dx,offset c_Head_Point	;
	mov	ah,09h			;
	int	21h			;「点」の表示
	pop	ax			;
	call	HEX2ASC8		;
	mov	ah,09h			;
	int	21h			;数値の表示
	mov	dx,offset c_Head_CR	;
	mov	ah,09h			;
	int	21h			;改行の表示

;---------------------------------------------------------------
;FX形式ヘッダーの作成
;※filename,titleは作成済み。

;●ファイルサイズ・ブロック数
	mov	dx,offset c_Head_Size	;
	mov	ah,09h			;
	int	21h			;"Filesize = "の表示

	xor	dx,dx			;
	mov	ax,cs:[pWTD_File]	;
	dec	ax			;dx:ax←ファイルサイズ。
	mov	word ptr cs:[FX_filesize + 0],ax
	mov	word ptr cs:[FX_filesize + 2],dx

	push	ax			;
	push	dx			;
	call	HEX2ASC16		;
	mov	ah,09h			;
	int	21h			;数値の表示
	mov	dx,offset c_Head_Byte	;
	mov	ah,09h			;
	int	21h			;" [Byte]"の表示
	pop	dx			;
	pop	ax			;

	mov	cx,128			;
	div	cx			;128で割る。
	cmp	dx,0			;
	jz	c_Head_end_Step0	;余りがあったら、
	inc	ax			;解に１を足す。
c_Head_end_Step0:			;
	mov	word ptr cs:[FX_block],ax

	call	HEX2ASC16		;数値の表示
	mov	ah,09h			;
	int	21h			;
	mov	dx,offset c_Head_Block	;
	mov	ah,09h			;
	int	21h			;" [Byte]"の表示

;---------------------------------------------------------------
;●年・時間の作成
;	bit 25-31	年-2000	(7)
;	bit 21-24	月	(4)
;	bit 16-20	日	(5)
;	bit 11-15	時	(5)
;	bit  5-10	分	(6)
;	bit  0- 4	秒/2	(5)

	mov	ah,02ah			;
	int	21h			;日付の取得
	xor	ax,ax			;

	sub	cx,2000			;年-2000
	and	cx,007Fh		;
	or	ax,cx			;

	shl	ax,4			;月
	mov	bx,dx			;
	xchg	bh,bl			;
	and	bx,000fh		;
	or	ax,bx			;

	shl	ax,5			;日
	and	dx,001fh		;
	or	ax,dx			;

	push	ax			;日付の保存

	mov	ah,02ch			;
	int	21h			;時間の取得
	xor	ax,ax			;

	mov	bx,cx			;時
	xchg	bh,bl			;
	and	bx,001fh		;
	or	ax,bx			;

	shl	ax,6			;分
	and	cx,003fh		;
	or	ax,cx			;

	shl	ax,5			;秒/2
	xchg	dh,dl			;
	shr	dx,1			;
	and	dx,001fh		;
	or	ax,dx			;

	pop	dx			;日付の復帰

	mov	word ptr cs:[FX_data + 0],ax
	mov	word ptr cs:[FX_data + 2],dx

;---------------------------------------------------------------
;終了
	pop	es			;レジスタ復帰
	pop	ds			;
	popa				;
	ret				;Return
