;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Interrupt device accsess program	|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				デバイス出力			*
;*								*
;****************************************************************
;===============================================================|
;		デバイスによるルーチンの分岐			|
;===============================================================|
;	●レジスタ使用						|
;		ax	汎用（主に計算用）			|
;		ds:bx	共有構造体アドレス		引数	|
;		cx	汎用					|
;		dx	ジャンプテーブルのアドレス	引数	|
;		ds:di	個別構造体			引数	|
;		ds:bp	ワークベースアドレス		引数	|
;		es;si	演奏アドレス			引数	|
;								|
;	ルーチンに渡す引数					|
;		cl	汎用（主にカウンタ用）			|
;		ch	現在のチャンネル			|
;		dx						|
;		ss:[bp + 04h]	呼び出し元のCXレジスタ。	|
;		ss:[bp + 06h]	呼び出し元のDXレジスタ。	|
;		　DXレジスタを使う場合、ルーチンで以下の処理が必要。
;		push	bp					|
;		mov	bp,sp					|
;		（中略）					|
;		pop	bp					|
;		ret						|
;								|
;	デバイスアクセス部で、bpレジスタを使用しているので、	|
;	注意する。						|
;								|
;===============================================================|
	even				;偶数アドレス配置
I_Table_Jump:				;
	push	dx			;
	push	cx			;
	push	bx			;
	push	ax			;レジスタ保存

;---------------------------------------------------------------

;ジャンプテーブルアドレスの設定
	mov	bx,dx			;bx←dx(Jump table address)
;チャンネル・音源情報の取得
	xor	ax,ax			;
	mov	al,ds:[di].WTD_Channel	;ax←Channel

;チャンネルと音源情報の個別化
;ch←チャンネル情報
	mov	ch,al			;
	and	ch,0fh			;ch←チャンネル(音源情報無し)
;ax←音源情報×２
	shr	ax,6			;ax←音源タイプ(負論理)
	not	ax			;ax←正論理にする。
	and	ax,02h			;ax←音源タイプ以外を消す。
;ジャンプアドレス格納アドレスの取得
	add	bx,ax			;bx←音源タイプを加算

;ジャンプアドレスの取得
	mov	dx,word ptr cs:[bx]	;

;---------------------------------------------------------------

;不必要なレジスタの復帰
	pop	ax			;レジスタ復帰
	pop	bx			;
;ルーチン呼び出し
	call	dx			;呼び出し
;残ったレジスタの復帰
	pop	cx			;
	pop	dx			;残りのレジスタ復帰

;終了
	ret				;
;===============================================================|
;			KeyOn					|
;===============================================================|
;	引数							|
;		al	キー・コード				|
;	返値							|
;		無し						|
;	処理							|
;		デバイスをKeyOnする。				|
;		休符の場合は、このルーチンを呼ばない。		|
;===============================================================|
	even				;偶数アドレス配置
;-------------[	  Table   ]-------------
I_Table_KeyOn:				
	dw	I_SP_KeyOn		
	dw	I_SM_KeyOn		
;-------------[	WS内蔵PCM ]-------------
	even				;偶数アドレス配置
I_SP_KeyOn:				;
	push	cx			;
	push	bx			;
	push	ax			;レジスタ保存

	mov	ds:[di].WTD_KeySet,al	;今回のデータを書き込み

;キーコードの分解（キー，オクターブ）
	xor	ah,ah				;ax←KeyCode
	mov	cl,12				;
	idiv	cl				;ah←Key(余) / al←Octave(商)
;オクターブの書き込み
	dec	al				;オクターブ補正(Drv値)
	mov	ds:[di].WTD_OctaveSet,al	;オクターブ書き込み
;テーブル読み込み（ベンド変換）
	mov	al,ah				;
	mov	ah,0				;ax←Key
	shl	ax,1				;
	mov	bx,offset I_Frection_Table	;
	add	bx,ax				;
	mov	ax,cs:[bx]			;ax←Pitch Bend
;ベンドの書き込み
	mov	ds:[di].WTD_Frection,ax		;Bendとして処理
;（ハードウェアにKeyOnは無い。）

	pop	ax			;レジスタ復帰
	pop	bx			;
	pop	cx			;
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_KeyOn:				;
	push	bx			;
	push	ax			;レジスタ保存

;実際に出力したオクターブ。
;（MIDI制御では要らないけど、ビュアー用に計算しておく。）
;レジスタ保存
	push	ax				;
	push	cx				;
;キーコードの分解（キー，オクターブ）
	xor	ah,ah				;ax←KeyCode
	mov	cl,12				;
	idiv	cl				;ah←Key(余) / al←Octave(商)
;オクターブの書き込み
	dec	al				;
	mov	ds:[di].WTD_OctaveSet,al	;オクターブ書き込み
;レジスタ復帰
	pop	cx				;
	pop	ax				;

;バッファ書き込み
	xor	bx,bx				;
	mov	bl,ds:[di].WTD_KeySetPointer	;ポインタ読み込み
	mov	al,ds:[di+bx].WTD_KeySet	;バッファ読み込み
	cmp	al,0ffh				;内容は空？
	jz	I_SM_KeyOn_ChkEnd		;空でなかったら
	call	SM_KeyOff			;空ということにする。
I_SM_KeyOn_ChkEnd:				;
	pop	ax				;
	push	ax				;ax←引数を復帰
	mov	ds:[di+bx].WTD_KeySet,al	;今回のデータを書き込み
	inc	bx				;ポインタインクリメント
	and	bx,07h				;
	mov	ds:[di].WTD_KeySetPointer,bl	;ポインタ保存

;送信
I_SM_KeyOn_Out:
	mov	ah,ds:[di].WTD_Velocity	;ah←ベロシティー
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Acsent
	jz	I_SM_KeyOn_DeviceOut	;もしアクセントだったら、それ用。
	mov	ah,ds:[di].WTD_AcsentVelocity
	and	ds:[di].WTD_FlagControl,WTD_Ctrl_AcsentR
I_SM_KeyOn_DeviceOut:			;
	call	SM_KeyOn		;デバイス出力。

	pop	ax			;レジスタ復帰
	pop	bx			;
	ret				;
;===============================================================|
;			KeyOff					|
;===============================================================|
;	引数							|
;		無し						|
;	返値							|
;		無し						|
;	処理							|
;		デバイスをKeyOffする。				|
;===============================================================|
	even				;偶数アドレス配置
;-------------[	  Table   ]-------------
I_Table_KeyOff:				
	dw	I_SP_KeyOff		
	dw	I_SM_KeyOff		
;-------------[	WS内蔵PCM ]-------------
	even				;偶数アドレス配置
I_SP_KeyOff:				;
	mov	ds:[di].WTD_KeySet,0ffh	;空データの書き込み
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_KeyOff:				;
	push	bx			;
	push	ax			;レジスタ保存

;バッファに書かれている内容を全てkeyOffし、空にする。
	mov	cl,8				;８回ループ
	xor	bx,bx				;
I_SM_KeyOff_Loop:				;
	mov	al,ds:[di+bx].WTD_KeySet	;バッファ読み込み
	mov	ds:[di+bx].WTD_KeySet,0ffh	;空データの書き込み
	inc	bx				;
	call	SM_KeyOff			;KeyOffの送信
	dec	cl				;カウンタディクリメント
	jnz	I_SM_KeyOff_Loop		;
;
;	　ポインタは面倒だから戻さない。
;	どうせ、クルクル回っているから、処理時間が無駄。
;
	pop	ax			;レジスタ復帰
	pop	bx			;
	ret				;
;===============================================================|
;			Volume					|
;===============================================================|
;	引数							|
;		al←ボリューム					|
;	返値							|
;		無し						|
;	処理							|
;		音量を出力する。				|
;===============================================================|
	even				;偶数アドレス配置
;-------------[	  Table   ]-------------
I_Table_Volume:				
	dw	I_SP_Volume		
	dw	I_SM_Volume		
;-------------[	WS内蔵PCM ]-------------
	even				;偶数アドレス配置
I_SP_Volume:				;
;音量保存。
	mov	ds:[di].WTD_ExprSet,al	;
;パンポットと合成するので、合成した値をチェックする。

;レジスタ保存
	push	dx			;
	push	bx			;
	push	cx			;
	push	si				;

;音量の次元を[dB]に変換
;	shl	al,1			;(Range:0～255)
;	and	ax,00ffh			;
;	mov	bx,offset I_Volume_Table	;
;	mov	si,ax				;
;	mov	al,cs:[bx + si]		;cl←int(256*(log(al+1)/log(257)))
	mov	cl,al			;

;パンポット読み込み
	mov	al,ds:[di].WTD_Pan		;
	shl	al,1				;
	mov	ah,0ffh				;al←左のレベル
	sub	ah,al				;ah←右のレベル
;パンポットの次元を[dB]に変換
	mov	bx,offset I_Volume_Table	;
	mov	si,ax				;
	and	si,00ffh			;
	mov	al,cs:[bx + si]			;
	xchg	al,ah				;ch←左のレベル
	mov	bx,offset I_Volume_Table	;
	mov	si,ax				;
	and	si,00ffh			;
	mov	al,cs:[bx + si]			;cl←右のレベル
	xchg	ax,cx				;al←音量

;パンポットの合成
;左演算
	push	ax			;
	xor	ah,ah			;
	inc	ax			;ax←音量+1
	push	cx			;
	mov	cl,ch			;
	xor	ch,ch			;
	inc	cx			;cx←左のレベル+1
	mul	cx			;
	dec	ax			;
	pop	cx			;
	mov	ch,ah			;ch←左の音量
	pop	ax			;
;右演算
	xor	ah,ah			;
	inc	ax			;ax←音量+1
	push	cx			;
	xor	ch,ch			;
	inc	cx			;cx←右のレベル+1
	mul	cx			;
	dec	ax			;
	pop	cx			;
	mov	cl,ah			;cl←右の音量
;合成
	and	ch,0f0h			;上位4bitのみ
	and	cl,0f0h			;上位4bitのみ
	shr	cl,4			;
	or	ch,cl			;
	mov	al,ch			;al←左右の音量

	pop	si			;
	pop	cx			;チャンネル情報を戻す。

	cmp	ds:[di].WTD_ExprPanSet,al	;
	jz	I_SP_Volume_End			;前回と同じだったらいらない。

	mov	ds:[di].WTD_ExprPanSet,al	;
	call	SP_Set_Volume			;

I_SP_Volume_End:
	pop	bx			;
	pop	dx			;
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_Volume:				;
	shr	al,1			;al÷2 (Range:0～127)
	cmp	ds:[di].WTD_ExprSet,al	;
	jz	I_SM_Volume_End		;前回と同じだったらいらない。

	push	cx			;レジスタ保存
	mov	ds:[di].WTD_ExprSet,al	;
	mov	cl,MIDI_Ctrl_Expression	;
	call	SM_ControlByte		;
	pop	cx			;レジスタ復帰

I_SM_Volume_End:			;
	ret				;
;===============================================================|
;			Frection(Pitch　Bend)			|
;===============================================================|
;	引数							|
;		ax←Bend(Frection)				|
;	返値							|
;		無し						|
;	処理							|
;		周波数／ピッチベンドを出力する。		|
;===============================================================|
	even				;偶数アドレス配置
;-------------[	  Table   ]-------------
I_Table_Frection:			
	dw	I_SP_Frection		
	dw	I_SM_Frection		
;-------------[	WS内蔵PCM ]-------------
	even				;偶数アドレス配置
;DeviceOut = 2048 - (Table / 2^(3 + Octave))
I_SP_Frection:				;
	push	cx			;
	push	ax			;レジスタ保存

;オクターブ処理
	mov	cl,ds:[di].WTD_OctaveSet
	add	cl,3			;
	shr	ax,cl			;
	mov	bx,ax			;
	mov	ax,2048			;
	sub	ax,bx			;
	jnc	I_SP_Frection_Step	;
	xor	ax,ax			;オーバーフローしたら、０にする。
I_SP_Frection_Step:			;

	cmp	ds:[di].WTD_FrectionSet,ax	;前回と同じだったらいらない。
	jz	I_SP_Frection_End		;

	mov	ds:[di].WTD_FrectionSet,ax	;
	call	SP_Set_Frection			;周波数の設定

I_SP_Frection_End:			;
	pop	ax			;レジスタ復帰
	pop	cx			;
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_Frection:				;
	cmp	ds:[di].WTD_BendSet,ax	;前回と同じだったらいらない。
	jz	I_SM_Frection_End	;

	mov	ds:[di].WTD_BendSet,ax	;
	call	SM_PitchBend		;
I_SM_Frection_End:			;
	ret				;
;===============================================================|
;			Voice & Program				|
;===============================================================|
;	引数							|
;		al←音色番号					|
;	返値							|
;		無し						|
;	処理							|
;		音色を転送する。				|
;===============================================================|
	even				;偶数アドレス配置
;-------------[	  Table   ]-------------
I_Table_Voice:				
	dw	I_SP_Voice		
	dw	I_SM_Voice		
;-------------[	WS内蔵PCM ]-------------
	even				;偶数アドレス配置
I_SP_Voice:				;
	cmp	ds:[di].WTD_Voice,al	;前回と同じだったらいらない。
	jz	I_SP_Voice_End		;

	push	ax			;
	push	si			;レジスタ保存

	mov	ds:[di].WTD_Voice,al	;音色番号保存
	xor	ah,ah			;
	shl	ax,4			;ax←al×16
	mov	si,bp			;
	add	si,WTD_WorkAdd_Wave	;
	add	si,ax			;ds:si←音色のあるアドレス

	call	SP_Set_Voice		;音色セット

	pop	si			;レジスタ復帰
	pop	ax			;
I_SP_Voice_End:				;
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_Voice:				;
	cmp	ds:[di].WTD_Program,al	;前回と同じだったらいらない。
	jz	I_SM_Voice_End		;

	mov	ds:[di].WTD_Program,al	;
	call	SM_Program		;
I_SM_Voice_End:				;
	ret				;
;===============================================================|
;			Poly Key Pressior			|
;===============================================================|
;	引数							|
;		al←Key						|
;		ah←pressior					|
;	返値							|
;		無し						|
;	処理							|
;		ポリフォニック　キー　プレッシャーの送信	|
;===============================================================|
	even				;偶数アドレス配置
;-------------[	  Table   ]-------------
I_Table_PolyKeyPress:			
	dw	I_SP_PolyKeyPress	
	dw	I_SM_PolyKeyPress	
;-------------[	WS内蔵PCM ]-------------
	even				;偶数アドレス配置
I_SP_PolyKeyPress:			;
;	処理無し			;
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_PolyKeyPress:			;
	call	SM_KeyPress		;
	ret				;
;===============================================================|
;			Poly Channel Pressior			|
;===============================================================|
;	引数							|
;		al←pressior					|
;	返値							|
;		無し						|
;	処理							|
;		ポリフォニック　キー　プレッシャーの送信	|
;===============================================================|
	even				;偶数アドレス配置
;-------------[	  Table   ]-------------
I_Table_PolyChPress:			
	dw	I_SP_PolyChPress	
	dw	I_SM_PolyChPress	
;-------------[	WS内蔵PCM ]-------------
	even				;偶数アドレス配置
I_SP_PolyChPress:			;
;	処理無し			;
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_PolyChPress:			;
	call	SM_ChPress		;
	ret				;
;===============================================================|
;			Control Change Byte			|
;===============================================================|
;	引数							|
;		al←データ					|
;		cl←機能番号					|
;	返値							|
;		無し						|
;	処理							|
;		コントロールチェンジの送信			|
;===============================================================|
	even				;偶数アドレス配置
;-------------[	  Table   ]-------------
I_Table_CtrlChgB:			
	dw	I_SP_CtrlChgB		
	dw	I_SM_CtrlChgB		
;-------------[	WS内蔵PCM ]-------------
	even				;偶数アドレス配置
I_SP_CtrlChgB:				;
;	処理無し			;
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_CtrlChgB:				;
	push	bp			;
	mov	bp,sp			;
	push	cx			;レジスタ保存

	mov	cl,[bp+04h]		;
	call	SM_ControlByte		;

	pop	cx			;レジスタ復帰
	pop	bp			;
	ret				;
;===============================================================|
;			Control Change Word			|
;===============================================================|
;	引数							|
;		ax←データ					|
;		cl←機能番号					|
;	返値							|
;		無し						|
;	処理							|
;		コントロールチェンジの送信			|
;===============================================================|
	even				;偶数アドレス配置
;-------------[	  Table   ]-------------
I_Table_CtrlChgW:			
	dw	I_SP_CtrlChgW		
	dw	I_SM_CtrlChgW		
;-------------[	WS内蔵PCM ]-------------
	even				;偶数アドレス配置
I_SP_CtrlChgW:				;
;	処理無し			;
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_CtrlChgW:				;
	push	bp			;
	mov	bp,sp			;
	push	cx			;レジスタ保存

	mov	cl,[bp+04h]		;
	call	SM_ControlWord		;

	pop	cx			;レジスタ復帰
	pop	bp			;
	ret				;
;===============================================================|
;	WS内蔵PCM Channelモード	/ MIDI Dumper Switch		|
;===============================================================|
;	引数							|
;		al←モードスイッチ				|
;	返値							|
;		無し						|
;	処理							|
;		モード						|
;===============================================================|
	even				;偶数アドレス配置
;-------------[	  Table   ]-------------
I_Table_Mode:				
	dw	I_SP_Mode		
	dw	I_SM_Mode		
;-------------[	WS内蔵PCM ]-------------
	even				;偶数アドレス配置
I_SP_Mode:				;
	push	cx			;
	push	ax			;レジスタ保存

	and	ax,0001h		;and	al,01h
	or	ax,0100h		;set	0,ah
	mov	cl,ch			;
	add	cl,4			;
	shl	ax,cl			;

	call	SP_Set_Channel		;

	pop	ax			;レジスタ復帰
	pop	cx			;
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_Mode:				;
	push	cx			;レジスタ保存

	shl	al,6			;数値を64倍する。
	and	al,40h			;0か64だけ。
	mov	cl,MIDI_Ctrl_Hold	;
	call	SM_ControlWord		;ダンパースイッチの送信

	pop	cx			;レジスタ復帰
	ret				;
