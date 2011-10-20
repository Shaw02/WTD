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
;===============================================================|
;		FX構造体（実体）				|
;===============================================================|
.data
FX		db	23h,21h,77h,73h	;#!ws
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

;===============================================================|
;		フラグ						|
;===============================================================|
cHCD_FlagFx	db	00h		;フラグ FXファイル生成

;===============================================================|
;			命令	初期				|
;===============================================================|
.const
c_Head_Com_Adrs		dw	((offset c_Head_Com_Adr_E)-(offset c_Head_Com_Adr_S))/2 + 1
c_Head_Com_Adr_S	dw	offset cHCD_0		;TB
			dw	offset cHCD_1		;PA
			dw	offset cHCD_2		;FX
			dw	offset cHCD_3		;TI
			dw	offset cHCD_4		;FI
			dw	offset cHCD_5		;IN
			dw	offset cHCD_6		;#timebase
			dw	offset cHCD_7		;#part
			dw	offset cHCD_8		;#version
			dw	offset cHCD_9		;#Switch
			dw	offset cHCD_10		;#title
			dw	offset cHCD_11		;#filename
c_Head_Com_Adr_E	dw	offset cHCD_12		;#include
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
cHCD_5	db	0dh,0ah,'IN',24h, 0f0h	;
	dw	offset cHCD_include	;
	db	00h			;
cHCD_6	db	'#timebase',24h, 11h	;Seg = WTD
	dw	WTD_Mus_TimeBase	;Time base
	db	00h,00h			;Byte , End
cHCD_7	db	'#part',24h, 11h	;Seg = WTD
	dw	WTD_Mus_Part		;Music Part count
	db	00h,00h			;Byte , End
cHCD_8	db	'#version',24h, 11h	;Seg = WTD
	dw	WTD_Mus_Version + 0	;Music Version
	db	00h,11h			;Seg = WTD
	dw	WTD_Mus_Version + 1	;Music Version
	db	00h,00h			;Byte , End
cHCD_9	db	'#switch',24h, 10h	;Seg = CS
	dw	cHCD_FlagFx		;FX File Make
	db	00h,00h			;Byte , End
cHCD_10	db	'#title',24h, 0f0h	;
	dw	offset cHCD_Set_title	;
	db	00h			;
cHCD_11	db	'#filename',24h, 0f0h	;
	dw	offset cHCD_Set_filename;
	db	00h			;
cHCD_12	db	'#include',24h, 0f0h	;
	dw	offset cHCD_include	;
	db	0			;
.code
;---------------------------------------------------------------
;	
;---------------------------------------------------------------
cHCD_Set_Loop	proc	near	uses ax cx di,
		szBuff:word,
		ptBuff:word

	.repeat
	  call	cread_l			;空白のチェック
	.until	(al>=21h)
	dec	cs:[pMML_File]		;ポインタ・ディクリメント

	;改行チェック
	mov	cx,szBuff
	mov	di,ptBuff
	.repeat
		call	cread_l			;ah←データ
		dec	cs:[pMML_File]		;ポインタ・ディクリメント
		.break	.if	(al == 0dh)

		;転送
		mov	cs:[di],al		;文字の転送
		inc	di			;
	;	stosb

		;文字数チェック
		inc	cs:[pMML_File]		;ポインタ・インクリメント
	.untilcxz

	ret				;
cHCD_Set_Loop	endp
;---------------------------------------------------------------
;	
;---------------------------------------------------------------
cHCD_Set_title		proc	near

	invoke	cHCD_Set_Loop,	24,	addr FX_title

	ret
cHCD_Set_title	endp		;
;---------------------------------------------------------------
;	
;---------------------------------------------------------------
cHCD_Set_filename	proc	near

	invoke	cHCD_Set_Loop,	16,	addr FX_filename

	ret
cHCD_Set_filename	endp		;
;---------------------------------------------------------------|
;		インクルードファイルの挿入			|
;---------------------------------------------------------------|
cHCD_include	proc	near	uses	ds es

	local	cFilename[128]:BYTE	;

	pusha

	;-----------------------
	;ファイル名までポインタを進ませる。
	.repeat
	    CALL	CREAD_L		;
	.until	(al>20h)		;２０未満のコードは飛ばす

	;-----------------------
	;ファイル名の取得
	dec	CS:[pMML_File]		;
	xor	di,di			
	mov	cx,128			;
	.repeat				;
	   CALL	CREAD_L			;
	   .break  .if	(al==00dh)	;改行だったら格納終了
	   mov	cFilename[di],al	;
	   inc	di			;
	.untilcxz			;
	mov	cFilename[di],0		;
	inc	di			;
	mov	cFilename[di],0dh	;
	inc	di			;
	mov	cFilename[di],0ah	;
	inc	di			;
	mov	cFilename[di],24h	;
	CALL	CREAD_L			;ポインタを進ませる

	;-----------------------
	;ファイル・オープン
	invoke	Memory_Open,0800h	;メモリ確保
	mov	ds,ax			;
	invoke	File_Open,	addr ss:cFilename,0	;インクルードファイル・オープン
	push	ax			;ハンドル保存
	invoke	File_Load,	ax,addr ds:0		;インクルードファイル・ロード
	mov	cx,ax			;cx←インクルードファイルサイズ
	pop	ax			;ax←ハンドル
	invoke	File_Close,	ax	;インクルードファイル・クローズ


	;-----------------------
	;現MMLファイルを、インクルードファイル分ずらす
	push	cx			;
	push	ds			;
	STD				;ブロック転送時ディクリメント
	mov	ax, cs:[segMml_File]	;
	mov	bx, cs:[szMml_File]	;現MML最後尾
	mov	ds, ax			;
	lea	si, [bx - 1]		;ds:si = 転送元
	mov	es, ax			;
	lea	di, [bx - 1]		;es:di = 転送先
	add	di, cx			;
	mov	cx, bx			;
	sub	cx, CS:[pMML_File]	;cx = 転送量
	rep	MOVSB			;
	pop	ds			;
	pop	cx			;

	;-----------------------
	;インクルードファイルの挿入
	push	cx			;
	CLD				;ブロック転送時インクリメント
	xor	si,si			;DS:SI ←転送元
	MOV	es,CS:[segMml_File]	;
	MOV	di,CS:[pMML_File]	;ES:DI ←送り先
	REP	MOVSB			;ブロック転送
	pop	cx			;

	;-----------------------
	;EOFを消す
	DEC	DI			;
	.if	(byte ptr es:[di]==01ah)
		MOV	byte ptr es:[di],020h	;
	.endif

	;-----------------------
	;サイズ分だけ大きくする。
	add	CS:[szMml_File],cx	;

	;-----------------------
	;割り当てたメモリの解放
	invoke	Memory_Close,	ds

	popa
	RET				;
cHCD_include	endp
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
c_Head_first	proc	near	uses	ds

	pusha

	;ポインターを先頭にする。
	xor	ax,ax			;
	mov	cs:[pMML_File],ax	;
	mov	cs:[pWTD_File],ax	;ポインターを先頭にする。

	;ヘッダー初期値の設定
	mov	word ptr ds:[0].WTD_Mus_Name + 0	,5457h	;
	mov	word ptr ds:[0].WTD_Mus_Name + 2	,0044h	;'WTD',00h
	mov	word ptr ds:[0].WTD_Mus_Version		,0100h	;Version
	mov	word ptr ds:[0].WTD_Mus_Extr		,ax	;0
	mov	byte ptr ds:[0].WTD_Mus_Emb		,al	;0
	mov	byte ptr ds:[0].WTD_Mus_Voice		,al	;0
	mov	byte ptr ds:[0].WTD_Mus_Part		,al	;0
	mov	byte ptr ds:[0].WTD_Mus_TimeBase	,48	;
	mov	word ptr ds:[0].WTD_Mus_ExtrAdr		,ax	;0
	mov	word ptr ds:[0].WTD_Mus_DataAdr		,ax	;0

	push	cs			;
	pop	ds			;ds ← cs

	.repeat

	   ;コマンド検索
	   ;コマンド数量の読み込み
	   xor	di,di				;di←変換定義アドレスのポインタ
	   ;cx←コマンドの数量
	   mov	cx,cs:[offset c_Head_Com_Adrs + di]
	   .repeat
		;ポインタ読み込み
		push	cs:[pMML_File]		;ポインタ保存
		add	di,2			;ポインタインクリメント(Word)
		mov	si,cs:[offset c_Head_Com_Adrs + di]	;si←変換定義アドレス
		;命令一致チェック
		.repeat
		   call	cread			;MMLファイルから１文字読み込み
		   lodsb
		.until	(al != ah)		;文字一致ならば、次もチェック。
		.if	(al == 24h)		;文字終了？
		   pop	ax			;ポインタの復帰(値は戻さず。)
		   dec	cs:[pMML_File]		;ポインタ・ディクリメント
						;ポインタはコマンドの次にある。
		   ;コマンド処理。
		   .repeat
			;セグメントの設定
			lodsb
			.if	(al==00h)		
				.break			;終了
			.elseif	(al==010h)
				mov	ax,cs		;
			.elseif	(al==011h)
				mov	ax,cs:[segWTD_File]
			.elseif	(al==012h)
				mov	ax,cs:[segMML_File]
			.elseif	(al==0f0h)
				lodsw			;
				call	ax		;
				.continue
			.endif

			push	ds			;DS保存
			;オフセットの設定
			push	ax			;
			lodsw				;
			mov	bx,ax			;bx ← Offset Address
			lodsb				;al ← 制御コード
			pop	ds			;DS ← 保存先
			;データの書き込み
			.if	(al==000h)
				call	A2H8R		;
				mov	ds:[bx],ah	;
			.elseif	(al==001h)
				call	A2H16R		;
				mov	ds:[bx],ax	;
			.elseif	(al==020h)
				;
				;	文字列一括転送(未対応)
				;
			.endif
			pop	ds			;DS復帰
		   .until	0
		   dec	cs:[pMML_File]		;
		   .break			;命令デコード終了
		.else
		   ;文字チェックで一致しなかった場合。
		   pop	cs:[pMML_File]		;ポインタ復帰
		.endif
		dec	cx
	   .until	(zero?)			;次のコマンドで比較
	   inc	CS:[pMML_File]			;ポインタ・インクリメント
	   mov	ax,CS:[szMML_File]		;MMLファイルの終了チェック
	.until	(ax < CS:[pMML_File])		;MMLファイルが[EOF]ならば終了

	popa
	ret				;
c_Head_first	endp
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
.const
c_Head_Version	db	'This Music Data is version $'
c_Head_CR	db	0dh,0ah,24h
c_Head_Size	db	'Filesize = '     ,24h
c_Head_Byte	db	' [Byte]   ( $'
c_Head_Block	db	' [Block] )',0dh,0ah,24h
;---------------------------------------------------------------
.code
c_Head_end	proc	near	uses ds es
	pusha				;レジスタ保存

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
	mov	dl,'.'
	mov	ah,02h
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
	popa				;
	ret				;Return
c_Head_end	endp
