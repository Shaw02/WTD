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
;	●引数							|
;		ds:bp	ワークベースアドレス		引数	|
;		ds:bx	共有構造体アドレス		引数	|
;		ds:di	個別構造体			引数	|
;		es;si	演奏アドレス			引数	|
;		dx	ジャンプテーブルのアドレス	引数	|
;		cx	汎用				(引数)	|
;	●レジスタ使用						|
;		ax	汎用（主に計算用）			|
;								|
;	ルーチンに渡す引数					|
;		cl	汎用（主にカウンタ用）			|
;		ch	現在のチャンネル			|
;		dx						|
;		ss:[bp + 04h]	呼び出し元のCXレジスタ。	|
;		ss:[bp + 06h]	呼び出し元のDXレジスタ。	|
;		ss:[bp + 08h]	呼び出し元のBPレジスタ。	|
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
	push	bp			;
	push	dx			;
	push	cx			;
	push	bx			;
	push	ax			;レジスタ保存

;---------------------------------------------------------------

	;ジャンプテーブルアドレスの設定
	mov	bx,dx			;bx←dx(Jump table address)
	;チャンネル・音源情報の取得
;	xor	ax,ax			;後でandでbit resetしてる。
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
	pop	bp			;

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
;	mov	al,ah				;
;	mov	ah,0				;ax←Key
;	shl	ax,1				;
;	mov	bx,offset CGROUP:I_Frection_Table
;	add	bx,ax				;
;	mov	ax,cs:[bx]			;ax←Pitch Bend

	xor	bx,bx
	mov	bl,ah
	shl	bx,1
	mov	ax,cs:[bx + CGROUP:I_Frection_Table]

	;ベンドの書き込み
	mov	ds:[di].WTD_Frection,ax		;Bendとして処理
	;（ハードウェアにKeyOnは無い。）

	pop	ax			;レジスタ復帰
	pop	bx			;
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_KeyOn:				;
ifndef	hyoka	;------------------------廉価版は無し
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
	.if	(al!=0ffh)			;内容は空？
		call	SM_KeyOff		;空ということにする。
	.endif
	pop	ax				;
	push	ax				;ax←引数を復帰
	mov	ds:[di+bx].WTD_KeySet,al	;今回のデータを書き込み
	inc	bx				;ポインタインクリメント
	and	bx,07h				;
	mov	ds:[di].WTD_KeySetPointer,bl	;ポインタ保存

	;送信
	mov	ah,ds:[di].WTD_Velocity	;ah←ベロシティー
	.if	(ds:[di].WTD_FlagControl&WTD_Ctrl_Acsent)
		mov	ah,ds:[di].WTD_AcsentVelocity	;もしアクセントだったら、それ用。
		and	ds:[di].WTD_FlagControl,WTD_Ctrl_AcsentR
	.endif
	call	SM_KeyOn		;デバイス出力。

	pop	ax			;レジスタ復帰
	pop	bx			;
endif	;--------------------------------
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
ifndef	hyoka	;------------------------廉価版は無し
	push	bx			;
	push	ax			;レジスタ保存

	;バッファに書かれている内容を全てkeyOffし、空にする。
	mov	cl,8				;８回ループ
	xor	bx,bx				;
	.repeat
		mov	al,ds:[di+bx].WTD_KeySet	;バッファ読み込み
		mov	ds:[di+bx].WTD_KeySet,0ffh	;空データの書き込み
		inc	bx				;
		.if	(al!=0ffh)			;
			call	SM_KeyOff		;KeyOffの送信
		.endif
		dec	cl
	.until	(cl == 0)
;
;	　ポインタは面倒だから戻さない。
;	どうせ、クルクル回っているから、処理時間が無駄。
;
	pop	ax			;レジスタ復帰
	pop	bx			;
endif	;--------------------------------
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
I_SP_Volume	proc	near	uses	ax bx

	push	cx			;chを保存

	;音量保存。
	mov	ds:[di].WTD_ExprSet,al	;
	cbw				;ax←al
	shl	ax,1			;(Range:0～255)
	mov	cx,ax			;cx←音量

	;パンポット読み込み
	mov	al,ds:[di].WTD_PanSet		;
	.if	!(ds:[di].WTD_Pan&080h)		;

		;パンポットは、リニアに変化。
		mov	dx,007fh			;
		and	ax,dx				;
		sub	dx,ax				;
		shl	ax,2				;ax←右の音量
		shl	dx,2				;dx←左の音量

		.if	(ah!=0)				;
			mov	ax,00ffh		;右のLimit処理
		.endif					;

		.if	(dh!=0)				;
			mov	dx,00ffh		;左のLimit処理
		.endif					;

		mov	ah,dl				;al←右のレベル
	.else

		;パンポットの次元を[dB]に変換
		shl	al,1				;
		mov	ah,0ffh				;al←右のレベル
		sub	ah,al				;ah←左のレベル

		push	ds				;
		push	cs				;
		pop	ds				;
		mov	bx,offset CGROUP:I_Volume_Table	;
		xchg	al,ah				;
		xlat					;
		xchg	al,ah				;ah←左のレベル
		xlat					;al←右のレベル
		pop	ds				;

	.endif



	;パンポットの合成
	xchg	cx,ax		;cx←左右の音量
	push	ax		;ax←音量

	;左演算
	inc	ax			;ax←音量+1
	push	cx			;
	mov	cl,ch			;
	xor	ch,ch			;
	inc	cx			;cx←左のレベル+1
	mul	cx			;
	dec	ax			;
	pop	cx			;
	mov	ch,ah			;ch←左の音量

	pop	ax

	;右演算
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

	pop	cx			;チャンネル情報を戻す。

	.if	(ds:[di].WTD_ExprPanSet!=al)	;前回と同じだったらいらない。
		mov	ds:[di].WTD_ExprPanSet,al
		call	SP_Set_Volume
	.endif

	ret				;
I_SP_Volume	endp
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_Volume:				;
ifndef	hyoka	;------------------------廉価版は無し
	.if	(ds:[di].WTD_ExprSet!=al)	;前回と同じだったらいらない。
		push	cx			;レジスタ保存
		mov	ds:[di].WTD_ExprSet,al	;
		mov	cl,MIDI_Ctrl_Expression	;
		call	SM_ControlByte		;
		pop	cx			;レジスタ復帰
	.endif
endif	;--------------------------------
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
	push	ax			;レジスタ保存
	push	bx			;

	;オクターブ処理
	mov	cl,ds:[di].WTD_OctaveSet
	add	cl,3			;
	sub	cl,ds:[di].WTD_BendRange
	shr	ax,cl			;
	mov	bx,ax			;
	mov	ax,2048			;
	sub	ax,bx			;
	.if	(Carry?)		;
		xor	ax,ax		;オーバーフローしたら、０にする。
	.endif

	;出力
	.if	(ds:[di].WTD_FrectionSet!=ax)	;前回と同じだったらいらない。
		mov	ds:[di].WTD_FrectionSet,ax
		call	SP_Set_Frection		;周波数の設定
	.endif

	pop	bx			;
	pop	ax			;レジスタ復帰
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_Frection:				;
ifndef	hyoka	;------------------------廉価版は無し
	.if	(ds:[di].WTD_BendSet!=ax)	;前回と同じだったらいらない。
		mov	ds:[di].WTD_BendSet,ax	;
		call	SM_PitchBend		;
	.endif
endif	;--------------------------------
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
	.if	(ds:[di].WTD_Voice!=al)	;前回と同じだったらいらない。

		push	ax			;
		push	si			;レジスタ保存

		mov	ds:[di].WTD_Voice,al	;音色番号保存
		xor	ah,ah			;ax ← 音色番号

		.if	(al < 16)
			shl	ax,4			;ax←al×16
			lea	si,[bp + WTD_WorkAdd_Wave]
			add	si,ax			;ds:si←音色のあるアドレス

			call	SP_Set_Voice		;音色セット
		.else
			push	cx
			push	dx

			mov	cl,ch
			inc	cl
			mov	dx,00800h
			shl	dx,cl

			.if	((ds:[di].WTD_FlagControl & WTD_Ctrl_Effect) || !(ds:[bx].WTD_Sys_Flag & dx))

				mov	si, ds:[bx].WTD_Sys_MusicOffset	;アドレスの設定
				mov	cl, es:[si].WTD_Mus_Voice
				mov	si, es:[si].WTD_Mus_DataAdr
				.while	(cl > 0)
				   .if	(al == es:[si])

					push	cx
					push	di
					push	ds
					push	es

					and	cx, PCM_Channel_mask	;
					mov	di, ds:[bx].WTD_Sys_VoiceTableOffset
					shr	cx, 4			;
					inc	si
					add	di, cx			;es:di←0000h:0180h + ch × 16

					push	es
					pop	ds
					push	IRAM_Segment		;es←0000h
					pop	es			;

					mov	cx, 8			;16byte転送する。
					rep	movsw			;転送

					pop	es
					pop	ds
					pop	di
					pop	cx
					.break
				   .endif
				   add	si, 17
				   dec	cl
				.endw
			.endif
			pop	dx
			pop	cx
		.endif

		pop	si			;レジスタ復帰
		pop	ax			;

	.endif
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_Voice:				;
ifndef	hyoka	;------------------------廉価版は無し
	.if	(ds:[di].WTD_Program!=al)	;前回と同じだったらいらない。
		mov	ds:[di].WTD_Program,al	;
		call	SM_Program		;
	.endif
endif	;-------------------------------
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
ifndef	hyoka	;------------------------廉価版は無し
	call	SM_KeyPress		;
endif	;--------------------------------
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
ifndef	hyoka	;------------------------廉価版は無し
	call	SM_ChPress		;
endif	;--------------------------------
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
ifndef	hyoka	;------------------------廉価版は無し
	push	bp			;
	mov	bp,sp			;
	push	cx			;レジスタ保存

	mov	cl,[bp + 04h]		;
	mov	bp,[bp + 08h]		;bpレジスタの復帰
	call	SM_ControlByte		;

	pop	cx			;レジスタ復帰
	pop	bp			;
endif	;--------------------------------
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
ifndef	hyoka	;------------------------廉価版は無し
	push	bp			;
	mov	bp,sp			;
	push	cx			;レジスタ保存

	mov	cl,[bp + 04h]		;
	mov	bp,[bp + 08h]		;bpレジスタの復帰
	call	SM_ControlWord		;

	pop	cx			;レジスタ復帰
	pop	bp			;
endif	;--------------------------------
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

	and	ax, 0001h		;and	al,01h
	or	ax, 0100h		;set	0,ah
	mov	cl, ch			;
	shl	ax, cl

	.if	!(ds:[di].WTD_FlagControl & WTD_Ctrl_Effect)
		push	dx

		mov	dx, WTD_Sys_ChannelMode1R
		rol	dx, cl
		and	dx, ds:[bx].WTD_Sys_Flag
		or	dh, al
		mov	ds:[bx].WTD_Sys_Flag, dx

		pop	dx
	.endif

	shl	ax,4			;
	call	SP_Set_Channel		;

	pop	ax			;レジスタ復帰
	pop	cx			;
	ret				;
;-------------[	外部MIDI  ]-------------
	even				;偶数アドレス配置
I_SM_Mode:				;
ifndef	hyoka	;------------------------廉価版は無し
	push	cx			;レジスタ保存

	shl	al,6			;数値を64倍する。
	and	al,40h			;0か64だけ。
	mov	cl,MIDI_Ctrl_Hold	;
	call	SM_ControlWord		;ダンパースイッチの送信

	pop	cx			;レジスタ復帰
endif	;--------------------------------
	ret				;
