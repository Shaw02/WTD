;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Interrupt main program			|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;****************************************************************
;*								*
;*			定数					*
;*								*
;****************************************************************
;
;	現状は無し
;
;****************************************************************
;*								*
;*			データテーブル				*
;*								*
;****************************************************************
;===============================================================|
;			Volume					|
;===============================================================|
;								|
;	Table = 256 * log(volume +1) / log(257)			|
;								|
;===============================================================|
	even
I_Volume_Table:
;		00h,01h,02h,03h,04h,05h,06h,07h,08h,09h,0Ah,0Bh,0Ch,0Dh,0Eh,0Fh
	db	  0, 31, 50, 63, 74, 82, 89, 95,101,106,110,114,118,121,124,127
	db	130,133,135,138,140,142,144,146,148,150,152,153,155,156,158,159
	db	161,162,164,165,166,167,169,170,171,172,173,174,175,176,177,178
	db	179,180,181,182,183,184,184,185,186,187,188,188,189,190,191,191
	db	192,193,193,194,195,195,196,197,197,198,199,199,200,200,201,202
	db	202,203,203,204,204,205,206,206,207,207,208,208,209,209,210,210
	db	211,211,211,212,212,213,213,214,214,215,215,216,216,216,217,217
	db	218,218,218,219,219,220,220,220,221,221,222,222,222,223,223,223
	db	224,224,224,225,225,225,226,226,226,227,227,227,228,228,228,229
	db	229,229,230,230,230,231,231,231,232,232,232,232,233,233,233,234
	db	234,234,234,235,235,235,236,236,236,236,237,237,237,238,238,238
	db	238,239,239,239,239,240,240,240,240,241,241,241,241,242,242,242
	db	242,243,243,243,243,243,244,244,244,244,245,245,245,245,246,246
	db	246,246,246,247,247,247,247,247,248,248,248,248,249,249,249,249
	db	249,250,250,250,250,250,251,251,251,251,251,252,252,252,252,252
	db	253,253,253,253,253,253,254,254,254,254,254,255,255,255,255,255
;===============================================================|
;			Frection(Key)				|
;===============================================================|
;								|
;	Table = (3.072[MHz] / (32 * frection)) * 2^7		|
;								|
;		Frection : a = 440[Hz]				|
;								|
;								|
;	DeviceOut = 2048 - (Table / 2^(3 + Octave))		|
;								|
;===============================================================|
	even				;偶数アドレス配置
I_Frection_Table:
	dw	46978			;c	Bend Range ≒ 4
	dw	44332			;c#		( 3～ 6)
	dw	41843			;d	
	dw	39495			;d#	
	dw	37278			;e	
	dw	35186			;f	
	dw	33211			;f#	
	dw	31347			;g	
	dw	29687			;g#	
	dw	27922			;a	
	dw	26360			;a#	
	dw	24880			;b	
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音・ＰＣＭ制御	*
;*								*
;****************************************************************
;*								*
;*	　演奏処理						*
;*								*
;*	●引数・返値（この値は保つ必要がある。）		*
;*		ds:bx	共有構造体アドレス			*
;*		ds:bp	ワークベースアドレス			*
;*								*
;*	●レジスタ割り振り					*
;*		ax	汎用(主に計算)				*
;*		ds:bx	共有構造体アドレス			*
;*		cx	汎用(主にカウンタ)			*
;*		dx	汎用(主に計算)				*
;*		ds:di	個別構造体				*
;*		es:si	演奏アドレス				*
;*		ds:bp	ワークベースアドレス			*
;*								*
;****************************************************************
;===============================================================|
;		Interrupt Main					|
;===============================================================|
;								|
;	●処理							|
;		　演奏ルーチンの呼び出し、			|
;		タイマーの制御を行うルーチン。			|
;								|
;	●使用レジスタ						|
;		ds:bp	ワーク領域先頭アドレス			|
;		ds:bx	パート共通構造体			|
;								|
;===============================================================|
	Public	I_Start
	even					;偶数アドレス配置
I_Start:
	push	bp				;
	push	ax				;
	push	bx				;
	push	cx				;
	push	si				;
	push	di				;
	push	ds				;レジスタ保存

;---------------------------------------------------------------
;EOIの発行
	cli					;割り込み不可
	mov	al,Int_HblankSet		;
	out	Int_Eoi,al			;出力

;	in	al,Int_Enable			;
;	and	al,INT_HblankReset		;シリアル送信エンプティー
;	out	Int_Enable,al			;割り込み禁止

;---------------------------------------------------------------
;バンクの設定

ifndef	IRAM		;DGROUP=IRAMの場合、不要
	;'/ram0'アクセス中は、処理をしない。
	in	al,BankSram			;現在のSRAM Bankを得る
	.if	(al==BANK_USERDS0)||(al==BANK_USERDS1)
endif

;---------------------------------------------------------------
;ワークエリアアドレスの取得

	WTD_WorkGet	ds,bp			;ワークエリアアドレスの取得
	lea	bx,[bp + WTD_WorkAdd_System]	;ds;bx←共通構造体

;===============================================================|
;	PCM Voice の処理（ with CPU Power）			|
;===============================================================|
;	●レジスタ使用						|
;		di	PCM Voice制御用構造体 のポインタ	|
;		si	*.wav のポインタ			|
;	※	cx	使用不可				|
;	※	dx	使用不可				|
;	※	es	使用不可				|
;===============================================================|

	;-----------------------------------------------
	;タイマーをエミュレートするか？
	.if	(ds:[bx].WTD_Sys_Flag & WTD_Sys_TimerEmulate)

	    ;------------------------------------------------
	    ;タイマーをエミュレートする時に追加される処理。	;
	    ;CALL命令と、ret命令の6clockが勿体ない		;
	    ;------------------------------------------------
	    ;PCM Voice をCPUパワーで鳴らす？
	    .if	(ds:[bx].WTD_Sys_Flag & WTD_Sys_Pcm)
	;
	;	to do	Sound-DMA を使わないモードかチェック
	;

		;レジスタ設定
	;	mov	di,bp					;
	;	add	di,WTD_WorkAdd_PCM			;di←パート個別構造体
		lea	di,[bp + WTD_WorkAdd_PCM]

		;アドレス取得
		push	ds					;レジスタ保存
		lds	si,dword ptr ds:[di].WTD_PcmAddress	;es:si←Play Address
		;データ取得
	;	mov	al,ds:[si]				;(注意：PipeLine)
	;	inc	si					;フラグも変化させる
		lodsb
		pop	ds					;レジスタ復帰
		;データ出力
		out	PCM_Com_VolumeCh2,al			;出力

		;アドレス保存
		mov	word ptr ds:[di].WTD_PcmAddress+0,si	;アドレス保存
		;ポインタチェック（セグメント境界？）
		.if	(si==0)
			add	word ptr ds:[di].WTD_PcmAddress+2,1000h
		.endif

		;終了？
		sub	word ptr ds:[di].WTD_PcmSize+0,1	;PcmSize ディクリメント
		sbb	word ptr ds:[di].WTD_PcmSize+2,0	;
		mov	ax,word ptr ds:[di].WTD_PcmSize+0	;
		or	ax,word ptr ds:[di].WTD_PcmSize+2	;
		.if	(zero?)					;
			;PCM Voice 発音終了
			and	ds:[bx].WTD_Sys_Flag,WTD_Sys_PcmR
			and	ds:[bx].WTD_Sys_Flag,WTD_Sys_EffectMask2R
			mov	ch,81h				;設定復帰ch2
			call	I_Effect_Return			;
		.endif
	    .endif

	    ;---------------				;
	    ;テンポ用カウンター　ディクリメント		;
	    dec	ds:[bx].WTD_Sys_TempoCounter		;
	    jnz	I_MusicEffectStep			;演奏を飛ばす。

	.endif

	;-----------------------------------------------
	;PCM Voice を Sound DMA で鳴らしている。
	.if	(ds:[bx].WTD_Sys_Flag & WTD_Sys_Pcm)
	;
	;	to do	Sound-DMA を使うモードかチェック
	;
	;   in	al, サウンドDMA
	   .if	!(al & 80h)				;
		and	ds:[bx].WTD_Sys_Flag,WTD_Sys_PcmR
		and	ds:[bx].WTD_Sys_Flag,WTD_Sys_EffectMask2R
		mov	ch,81h				;設定復帰ch2
		call	I_Effect_Return			;
	   .endif
	.endif

;===============================================================|
;	演奏 ＆ 効果音処理					|
;===============================================================|
;	●レジスタ使用						|
;		ds:di	個別構造体		破壊ok		|
;	（	es:si	演奏アドレス		破壊ok	）	|
;		ax	汎用(主に計算)		破壊ok		|
;		cx	汎用(主にカウンタ)	破壊ok		|
;		dx	汎用(主に計算)		破壊ok		|
;===============================================================|
;演奏ルーチン
	push	dx				;
	push	es

	;演奏あるか？
	.if	(ds:[bx].WTD_Sys_Flag & WTD_Sys_Music)

		;レジスタ設定
		lea	di,[bp + WTD_WorkAdd_Ch0]
		mov	es,ds:[bx].WTD_Sys_MusicSegment	;es←演奏データセグメント

		;演奏処理ルーチンの呼び出し
		xor	cx,cx				;製品版は最大'20'。
		mov	cl,ds:[bx].WTD_Sys_MusicPart	;廉価版は最大' 4'。
		.while	(cx!=0)
			call	I_Play			;
			add	di,WTD_WorkChSize	;構造体のサイズは80h(0x80)
			dec	cx			;
		.endw

	.endif

;---------------------------------------------------------------
;効果音ルーチン

	;効果音あるか？
	.if	(ds:[bx].WTD_Sys_Flag & WTD_Sys_Effect)

		;レジスタ設定
		lea	di,[bp + WTD_WorkAdd_Ech0]
		mov	es,ds:[bx].WTD_Sys_EffectSegment	;es←効果音データセグメント

		;演奏処理ルーチンの呼び出し
		xor	cx,cx				;
		mov	cl,ds:[bx].WTD_Sys_EffectPart	;最大'3'。
		.while	(cx!=0)
			call	I_Play			;
			add	di,WTD_WorkChSize	;構造体のサイズは80h(0x80)
			dec	cx			;
		.endw

	.endif

;---------------------------------------------------------------
;PCM Vioce効果音が発生しており、尚かつ終了であるならば、
;タイマーを戻す。

	;タイマーエミュレート中であるか？
	.if	(ds:[bx].WTD_Sys_Flag & WTD_Sys_TimerEmulate)

	    ;PcmVioce処理終了？
	    .if	(ds:[bx].WTD_Sys_Flag & WTD_Sys_Pcm)

		;●PcmVioce処理継続の場合
		;タイマー設定
		mov	ax,1				;割り込み周期は最速
		call	T_Set_Frection			;(12KHz)
		;タイマーカウンタ設定
		mov	ax,ds:[bx].WTD_Sys_Tempo	;
		mov	ds:[bx].WTD_Sys_TempoCounter,ax	;TempoCounter

	    .else

		;●PcmVioce処理終了の場合。
		;タイマー設定
		mov	ax,ds:[bx].WTD_Sys_Tempo	;タイマーの設定
		call	T_Set_Frection			;
		;タイマーカウンタ設定
	;	xor	ax,ax				;ax←0
		mov	ds:[bx].WTD_Sys_TempoCounter,0	;TempoCounter = 0
		;フラグ初期化
	;	and	ds:[bx].WTD_Sys_Flag,WTD_Sys_PcmR		;PCM効果音ディセーブル
	;	and	ds:[bx].WTD_Sys_Flag,WTD_Sys_PcmEndR		;このフラグは廃止
	;	and	ds:[bx].WTD_Sys_Flag,WTD_Sys_EffectMask2R	;ch2 効果音マスクRes
		and	ds:[bx].WTD_Sys_Flag,WTD_Sys_TimerEmulateR	;タイマーエミュレートRes
	;	mov	ch,81h				;設定復帰ch2
	;	call	I_Effect_Return			;

	    .endif
	.endif

	pop	es
	pop	dx				;

;===============================================================|
I_MusicEffectStep:					;

;
;---------------------------------------------------------------
;バンクの復帰
ifndef	IRAM		;DGROUP=IRAMの場合、不要
;
	.endif

endif
;---------------------------------------------------------------
;割り込みの終了

;	cli				;割り込み禁止
;	in	al,Int_Enable		;
;	or	al,INT_HblankSet	;タイマー
;	out	Int_Enable,al		;割り込み許可

	pop	ds				;レジスタ復帰
	pop	di				;
	pop	si				;
	pop	cx				;
	pop	bx				;
	pop	ax				;
	pop	bp				;
	iret					;
;===============================================================|
;		Music Control Main				|
;===============================================================|
;	●引数							|
;		ds:bp	ワークベースアドレス	引数		|
;		ds:bx	共有構造体アドレス	引数		|
;		ds:di	個別構造体		引数		|
;	●レジスタ使用						|
;		es:si	演奏アドレス		引数		|
;		cx	何パート目？		破壊NG		|
;		ax	ゲートタイム計算用	破壊ok		|
;		dx	汎用(主に計算)		破壊ok		|
;===============================================================|
	even				;偶数アドレス配置
I_Play	proc	near	uses	cx	;

	;演奏チェック
	.if	!(ds:[di].WTD_FlagControl&WTD_Ctrl_PlayEnd)

		;音長カウンター・ディクリメント
		dec	ds:[di].WTD_LengCounter
		mov	ax,ds:[di].WTD_Leng			;
		sub	ax,ds:[di].WTD_LengCounter		;ax←経過時間


		;音長による、キーオンディレイ
		.if	(ax==ds:[di].WTD_KeyOnDelay)		;'k'コマンドの判定
			call	I_Play_KeyOn			;
		.endif


		;音長による、音色制御
		.if	( !(ds:[di].WTD_Program2nd&80h) && (ds:[di].WTD_Key!=0ffh) && (ax==ds:[di].WTD_ProgramRate) )
			push	ax				;
			mov	al,ds:[di].WTD_Program2nd	;
			and	al,07fh				;上位bitのマスク
			mov	dx,offset CGROUP:I_Table_Voice	;
			call	I_Table_Jump			;
			pop	ax				;
		.endif


		;音長による、ゲートタイム制御
		.if	(ax!=ds:[di].WTD_GateTimeStepFirst)	;'u'コマンドでkeyoffするか？

			mov	ax,ds:[di].WTD_Leng		;'Q','U','q'コマンドの判定
			mov	ch,ds:[di].WTD_GateTime8	;ch←GateTime8
			rol	ch,1				;
			shr	ch,1				;Bit 7 Reset & Bit 7 -> Cy Flag
			.if	(!Carry?)
				mov	dx,8			;'Q'コマンド
				sub	dl,ch			;dx = 8 － ch
				mul	dx			;dx:ax = ax × dx
				shr	dx,1			;
				shr	ax,1			;
				shr	dx,1			;
				shr	ax,1			;
				shr	dx,1			;
				shr	ax,1			;ax = dx:ax ÷ cl
			.else
				mov	cl,100			;cl = 100
				mov	dx,100			;dx = 100
				sub	dl,ch			;dx = dx － ch
				mul	dx			;dx:ax = ax × dx
				xor	ch,ch			;
				div	cx			;ax = dx:ax ÷ cl
			.endif


			add	ax,ds:[di].WTD_GateTimeStepLast	;ax = ax + WTD_GateTimeStepLast
			.if	(Carry?)			;オーバーフローしたら、
				mov	ax,0ffffh		;最大値に修正。
			.endif					;
			.if	(ax==ds:[di].WTD_LengCounter)	;
				call	I_Play_KeyOff		;
			.endif

		.else
			call	I_Play_KeyOff			;

		.endif


		;音長カウンタ０ならば、コマンド処理
		.if	(ds:[di].WTD_LengCounter==0)		;音長カウンタ＝０？

			mov	si,ds:[di].WTD_Address		;es:si←Play Address
			call	I_Play_Loop			;制御ルーチンへ。
			mov	ds:[di].WTD_Address,si		;

	;		;演奏終了？　＆　KeyOnDelayは０？
			.if	(!(ds:[di].WTD_FlagControl&WTD_Ctrl_PlayEnd) && (ds:[di].WTD_KeyOnDelay==0))
				call	I_Play_KeyOn		;であれば、KeyOn
			.endif
		.endif


	.endif

	mov	ax, ds:[di].WTD_FlagControl
	.if	!( (ds:[bx] & WTD_Sys_Music) && (ax & WTD_Ctrl_PlayEnd) && (ax & WTD_Ctrl_Effect) )
		;制御ルーチンへ
		call	I_Play_Pan			;パン制御
		call	I_Play_Volume			;音量制御
		.if	(ds:[di].WTD_ExprSet!=0)	;　音量０でなかったら
			call	I_Play_Frection		;音程制御
		.endif
	.endif

	ret				;
I_Play	endp
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				ループ				*
;*								*
;****************************************************************
;===============================================================|
;	●引数							|
;		ds:bp	ワークベースアドレス	引数		|
;		ds:bx	共有構造体アドレス	引数		|
;		ds:di	個別構造体		引数		|
;		es:si	演奏アドレス		引数		|
;	●レジスタ使用						|
;		cx	何パート目？		破壊ok		|
;		ax	ゲートタイム計算用	破壊ok		|
;		dx	汎用(主に計算)		破壊ok		|
;===============================================================|
	even				;偶数アドレス配置
I_Play_Loop	proc	near		;

	.while	( !(ds:[di].WTD_FlagControl&WTD_Ctrl_PlayEnd) && (ds:[di].WTD_LengCounter==0) )

		;演奏データ読み込み
		lodsb	es:[si]

		;コマンドタイプチェック
		rol	al,1			;
		shr	al,1			;cy←Command Type

		;それぞれへ条件コール
		.if	(Carry?)
			call	I_PlayKey		;
		.else
			call	I_PlayCommand		;
		.endif

	.endw

	ret				;
I_Play_Loop	endp
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				KeyOn,KeyOff制御		*
;*								*
;****************************************************************
;*	●引数							*
;*		ds:bp	ワークベースアドレス	引数		*
;*		ds:bx	共有構造体アドレス	引数		*
;*		ds:di	個別構造体		引数		*
;*		es:si	演奏アドレス		引数		*
;*	●レジスタ使用						*
;*		ax	汎用(主に計算)		破壊NG		*
;*		cx	制御Flag		破壊NG		*
;*		dx	LFO/EMB制御構造体	破壊ok		*
;****************************************************************
;===============================================================|
;			KeyOn (Hardware,Software)		|
;===============================================================|
	even				;偶数アドレス配置
I_Play_KeyOn	proc	near	uses	ax cx

	;休符ではない ＆＆ 前回タイではない
	.if	((ds:[di].WTD_Key!=0ffh) && !(ds:[di].WTD_FlagTai & 02h))

		;音色制御
		mov	al,ds:[di].WTD_Program2nd	;'@'コマンド必要性の確認
		and	al,ds:[di].WTD_Program3rd	;第2,3パラメータの指定が無かったら、処理は無し。
		.if	!(al&080h)
			mov	al,ds:[di].WTD_Program1st	;
			and	al,07fh				;上位bitのマスク
			mov	dx,offset CGROUP:I_Table_Voice	;
			call	I_Table_Jump			;
		.endif

		;音量Embは処理必要。
		.if	(ds:[di].WTD_FlagControl&WTD_Ctrl_ExprEmb)
			mov	cx,WTD_Ctrl_EmbVol		;
			mov	dx,WTD_ExprEmb			;
			call	I_Play_KeyOn_Emb		;
		.else
			mov	ds:[di].WTD_ExprEmbLevelSet,0ffh
		.endif

	;	.if	(ds:[di].WTD_FlagControl&0037h)	;音量Emb以外の確認。ソフトウェア処理がなかったら飛ばす。

		;音程Emb
		.if	(ds:[di].WTD_FlagControl&WTD_Ctrl_BendEmb)
			mov	cx,WTD_Ctrl_EmbFreq		;
			mov	dx,WTD_BendEmb			;
			call	I_Play_KeyOn_Emb		;
		.endif

		;パンEmb
		.if	(ds:[di].WTD_FlagControl&WTD_Ctrl_PanEmb)
			mov	cx,WTD_Ctrl_EmbPan		;
			mov	dx,WTD_PanEmb			;
			call	I_Play_KeyOn_Emb		;
		.endif

		;音量LFO
		.if	(ds:[di].WTD_FlagControl&WTD_Ctrl_ExprLFO)
			mov	dx,WTD_ExprLFO			;
			call	I_Play_KeyOn_LFO		;
		.endif

		;音程LFO
		.if	(ds:[di].WTD_FlagControl&WTD_Ctrl_BendLfo)
			mov	dx,WTD_BendLFO			;
			call	I_Play_KeyOn_LFO		;
		.endif

		;パンLFO
		.if	(ds:[di].WTD_FlagControl&WTD_Ctrl_PanLFO)
			mov	dx,WTD_PanLFO			;
			call	I_Play_KeyOn_LFO		;
		.endif

;		.endif

ifndef	hyoka	;--------------------------------廉価版は無し
		;モジュレーション
		xor	ax,ax					;
		.if	(ds:[di].WTD_ModLevelSet!=al)		;
			mov	ds:[di].WTD_ModLevelSet,al	;
			mov	cl,MIDI_Ctrl_Mod		;
			mov	dx,offset CGROUP:I_Table_CtrlChgB
			call	I_Table_Jump			;モジュレーションを０にする。
		.endif
endif	;----------------------------------------

	.endif
	ret				;
I_Play_KeyOn	endp
;===============================================================|
;			KeyOff (Hardware,Software)		|
;===============================================================|
	even				;偶数アドレス配置
I_Play_KeyOff	proc	near	uses	ax cx

	.if	!(ds:[di].WTD_FlagTai & 01h)

		;ハードウェアをKeyOff
		mov	dx,offset CGROUP:I_Table_KeyOff	;
		call	I_Table_Jump			;KeyOff

		;音色制御
		.if	!(ds:[di].WTD_Program3rd&80h)	;'@'コマンド	必要性の確認
			mov	al,ds:[di].WTD_Program3rd	;
			and	al,07fh				;上位bitのマスク
			mov	dx,offset CGROUP:I_Table_Voice	;
			call	I_Table_Jump			;
		.endif

		;音量Emb
		.if	(ds:[di].WTD_FlagControl&WTD_Ctrl_ExprEmb)
			mov	cx,WTD_Ctrl_EmbVol		;
			mov	dx,WTD_ExprEmb			;
			call	I_Play_KeyOff_Emb		;
		.else
			.if	(ds:[di].WTD_Channel&80h)	;MIDIパートの場合は操作しない。
				mov	ds:[di].WTD_ExprEmbLevelSet,000h
			.endif
		.endif

		;音程Emb
		.if	(ds:[di].WTD_FlagControl&WTD_Ctrl_BendEmb)
			mov	cx,WTD_Ctrl_EmbFreq		;
			mov	dx,WTD_BendEmb			;
			call	I_Play_KeyOff_Emb		;
		.endif

		;パンEmb
		.if	(ds:[di].WTD_FlagControl&WTD_Ctrl_PanEmb)
			mov	cx,WTD_Ctrl_EmbPan		;
			mov	dx,WTD_PanEmb			;
			call	I_Play_KeyOff_Emb		;
		.endif

	.endif
	ret				;
I_Play_KeyOff	endp
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				音程・音量制御			*
;****************************************************************
;*	●引数							*
;*		ds:bp	ワークベースアドレス	引数		*
;*		ds:bx	共有構造体アドレス	引数		*
;*		ds:di	個別構造体		引数		*
;*		es:si	演奏アドレス		引数		*
;*	●レジスタ使用						*
;*		ax	汎用(主に計算)		破壊ok		*
;*		cx	汎用			破壊ok		*
;*		dx	汎用			破壊ok		*
;****************************************************************
;===============================================================|
;			音程制御 (Detune,LFO,Emb合成)		|
;===============================================================|
	even				;偶数アドレス配置
I_Play_Frection	proc	near		;

ifndef	hyoka	;--------------------------------廉価版は無し
	;モジュレーション制御(MIDI)
	mov	ax,ds:[di].WTD_Leng		;モジュレーション
	sub	ax,ds:[di].WTD_LengCounter	;
	.if	(ax==ds:[di].WTD_ModDecay)
	  mov	al,ds:[di].WTD_ModLevel		;
	  mov	ds:[di].WTD_ModLevelSet,al	;
	  mov	cl,MIDI_Ctrl_Mod		;
	  mov	dx,offset CGROUP:I_Table_CtrlChgB
	  call	I_Table_Jump			;モジュレーションをかける。
	.endif
endif	;----------------------------------------


	;音程読み込み
	mov	ax,ds:[di].WTD_Bend	;

	;ディチューンの加算
	add	ax,ds:[di].WTD_BendDetune

	;音程LFO処理
	.if	(ds:[di].WTD_FlagControl & WTD_Ctrl_BendLFO)
		mov	dx,WTD_BendLFO		;
		call	I_Play_LFO		;
		add	ax,dx			;
	.endif

	;音量Emb処理
	.if	(ds:[di].WTD_FlagControl & WTD_Ctrl_BendEmb)
		mov	cx,WTD_Ctrl_EmbFreq	;
		mov	dx,WTD_BendEmb		;
		call	I_Play_Emb		;
		sub	dl,80h			
		.if	(carry?)
		  mov	dh,0ffh			;dx←dl(符号付)
		.endif
		shl	dx,6			;×2^6
		add	ax,dx			;加算
	.endif

	;音程の出力
	mov	dx,offset CGROUP:I_Table_Frection
	call	I_Table_Jump		;音程セット

	ret				;
I_Play_Frection	endp
;===============================================================|
;			音量制御 (Detune,LFO,Emb合成)		|
;===============================================================|
	even				;偶数アドレス配置
I_Play_Volume	proc	near		;

	;音量読み込み＆14bitに変換
	xor	ax,ax			;
	mov	al,ds:[di].WTD_Expr	;
	inc	ax			;
	shl	ax,7			;128倍にする。
	dec	ax			;（Range:0～16383）

	;ディチューンの加算
	add	ax,ds:[di].WTD_ExprDetune

	;音量LFO処理
	.if	(ds:[di].WTD_FlagControl & WTD_Ctrl_ExprLFO)
		mov	dx,WTD_ExprLFO		;
		call	I_Play_LFO		;
		add	ax,dx			;
	.endif

	;音量Emb処理
	.if	(ds:[di].WTD_FlagControl & WTD_Ctrl_ExprEmb)
		mov	cx,WTD_Ctrl_EmbVol	;
		mov	dx,WTD_ExprEmb		;
		call	I_Play_Emb		;
;		mov	ds:[di].WTD_ExprEmbLevelSet,dl	;エンベロープ値
	.endif

	;音量を、7bitに補正
	inc	ax			;
	shr	ax,7			;ax←{(ax+1)÷128}-1
	dec	ax			;（Range:0～127）
	.if	(ah==0)
		.if	(al>=80h)
		  mov	ax,07fh		;if (128=>ax>255){ax = 0x7F;};
		.endif
	.else
		xor	ax,ax		;ax = 0x00;
	.endif

	;エンベロープ音量の合成
	xor	cx,cx			;
	mov	cl,al			;
	inc	cx				;cx←音量+1
	xor	ax,ax				;ax←0
	mov	al,ds:[di].WTD_ExprEmbLevelSet	;ax←音量
	inc	ax				;ax←ソフト音量+1
	mul	cx			;
	dec	ax			;
	shl	ax,1			;al←((Vol.+1)×(SoftVol.+1)-1)／128
	mov	al,ah			;(Range:0～255)

	;ソフトウェア音量の合成
	xor	cx,cx			;
	mov	cl,al			;
	inc	cx			;cx←音量+1
	xor	ax,ax			;ax←0
	.if	(ds:[di].WTD_FlagControl & WTD_Ctrl_Effect)
	  mov	al,ds:[bx].WTD_Sys_VolumeEffect	;ax←効果音音量
	.else
	  mov	al,ds:[bx].WTD_Sys_VolumeMusic	;ax←音楽音量
	.endif


;	mov	bx,offset CGROUP:I_Volume_Table	;log演算
;	xlat
;	xor	ah,ah
	mov	si,ax			;
	and	si,00ffh		;
	mov	al,byte ptr cs:[CGROUP:I_Volume_Table + si]

	inc	ax			;ax←ソフト音量+1
	mul	cx			;
	dec	ax			;al←((2*Vol.+1)×(SoftVol.+1)／256)-1
	mov	al,ah			;(Range:0～255)
	shr	al,1			;al÷2 (Range:0～127)

	;音量の出力
	mov	dx,offset CGROUP:I_Table_Volume
	call	I_Table_Jump		;音量セット

	ret				;
I_Play_Volume	endp
;===============================================================|
;			パンポット制御 (LFO,Emb合成)		|
;===============================================================|
	even				;偶数アドレス配置
I_Play_Pan	proc	near		;

	;パンポット読み込み
	mov	al,ds:[di].WTD_Pan	;
	and	ax,0007fh		;

	;ソフトウェア処理がなかったら飛ばす。
      .if	(ds:[di].WTD_FlagControl & (WTD_Ctrl_PanLFO + WTD_Ctrl_PanEmb))

	;128倍にする。
	inc	ax			;
	shl	ax,7			;
	dec	ax			;（Range:0～16383）

	;パンポットLFO処理
	.if	(ds:[di].WTD_FlagControl & WTD_Ctrl_PanLFO)
		mov	dx,WTD_PanLFO		;
		call	I_Play_LFO		;
		add	ax,dx			;
	.endif

	;パンポットEmb処理
	.if	(ds:[di].WTD_FlagControl & WTD_Ctrl_PanEmb)
		mov	cx,WTD_Ctrl_EmbPan	;
		mov	dx,WTD_PanEmb		;
		call	I_Play_Emb		;
		sub	dl,80h			;
		.if	(carry?)
		  mov	dh,0ffh			;dx←dl(符号付)
		.endif
		shl	dx,6			;×2^6
		add	ax,dx			;加算
	.endif

	;パンポットを、7bitに補正
	inc	ax			;
	shr	ax,7			;ax←{(ax+1)÷128}-1
	dec	ax			;（Range:0～127）

	.if	(ah==0)
		.if	(al>=80h)
		  mov	ax,07fh		;if (128=>ax>255){ax = 0x7F;};
		.endif
	.else
		xor	ax,ax		;ax = 0x00;
	.endif

      .endif

	;パンポットの出力
	.if	(ds:[di].WTD_PanSet!=al)
	  mov	ds:[di].WTD_PanSet,al	;書き込み
ifndef	hyoka	;------------------------廉価版は無し
	  mov	cl,MIDI_Ctrl_Pan	;
	  mov	dx,offset CGROUP:I_Table_CtrlChgB
	  call	I_Table_Jump		;パンポットセット
endif	;--------------------------------
	.endif

	ret				;
I_Play_Pan	endp
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				音程・音量LFO,Emb制御		*
;*				音程、音量で同一のルーチン	*
;*								*
;****************************************************************
;*	●引数							*
;*		ds:bp	ワークベースアドレス	引数		*
;*		ds:bx	共有構造体アドレス	引数		*
;*		ds:di	個別構造体		引数		*
;*		es:si	演奏アドレス		引数		*
;*		dx	ワークアドレス先頭	返り値になる	*
;*		cx	制御Flag		破壊ok		*
;*	●レジスタ使用						*
;*		ax	汎用(主に計算)		破壊NG		*
;*	●返り値						*
;*		dx	変位(レベル)				*
;****************************************************************
;===============================================================|
;			LFO処理	KeyOn				|
;===============================================================|
	even				;偶数アドレス配置
I_Play_KeyOn_LFO	proc	near	uses	ax di

;	mov	bp,dx					;
	add	di,dx

	;カウンター(Rate)の初期化
	mov	ah,ds:[di].WTD_ChLfo_DecayRate		;DR
	add	ah,ds:[di].WTD_ChLfo_SpeedRate		;SR
	mov	ds:[di].WTD_ChLfo_RateCounter,ah	;

	;カウンター(Count)の初期化
	mov	ah,ds:[di].WTD_ChLfo_Count		;
	shr	ah,1					;ah = ah / 2	←ミスだけど
;	.if	(ah==1)
;	  xor	ah,ah					;互換性の為、これを入れる。
;	.endif
	mov	ds:[di].WTD_ChLfo_CountCounter,ah	;

	;レベルの初期化
	xor	ax,ax					;
	mov	ds:[di].WTD_ChLfo_LevelSet,ax		;

	ret						;
I_Play_KeyOn_LFO	endp
;===============================================================|
;			Emb処理	KeyOn				|
;===============================================================|
	even				;偶数アドレス配置
I_Play_KeyOn_Emb	proc	near	uses	ax di si

	lea	si,[di]
	add	di,dx

	xor	ax,ax
	mov	al,ds:[di].WTD_ChEmb_Address	;
	and	al,0f0h				;
	mov	ds:[di].WTD_ChEmb_Address,al	;位置初期化
	.if	(ds:[si].WTD_FlagControl & cx)
	  mov	ah,01h				;
	.endif

	lea	si,[bp + WTD_WorkAdd_Emb]	;エンベロープアドレス
	add	si,ax				;データアドレス
	lodsw					;
	mov	dx,ds:[si]			;

	mov	ds:[di].WTD_ChEmb_Rate,al	;
	.if	(ah&80h)
	  neg	ah				;
	.endif
	mov	ds:[di].WTD_ChEmb_Counter,ah	;
	mov	ds:[di].WTD_ChEmb_MaxMin,dl	;
	mov	ds:[di].WTD_ChEmb_LevelSet,dh	;

	ret					;
I_Play_KeyOn_Emb	endp
;===============================================================|
;			Emb処理	KeyOff				|
;===============================================================|
	even				;偶数アドレス配置
I_Play_KeyOff_Emb	proc	near	uses ax di si

	lea	si,[di]
	add	di,dx

	xor	ax,ax
	mov	al,ds:[di].WTD_ChEmb_Address	;
	and	al,0f0h				;
	or	al,00cH				;
	mov	ds:[di].WTD_ChEmb_Address,al	;位置初期化
	.if	(ds:[si].WTD_FlagControl & cx)
	  mov	ah,01h				;
	.endif

	lea	si,[bp + WTD_WorkAdd_Emb]	;エンベロープアドレス
	add	si,ax				;データアドレス
	lodsw					;
	mov	dx,ds:[si]			;

	mov	ds:[di].WTD_ChEmb_Rate,al	;
	.if	(ah&80h)
	  neg	ah				;
	.endif
	mov	ds:[di].WTD_ChEmb_Counter,ah	;
	mov	ds:[di].WTD_ChEmb_MaxMin,dl	;

	ret					;
I_Play_KeyOff_Emb	endp
;===============================================================|
;			Emb処理	メイン				|
;===============================================================|
	even				;偶数アドレス配置
I_Play_Emb	proc	near	uses	ax di si

	lea	si,[di]
	add	di,dx

	;●Speed処理
	dec	ds:[di].WTD_ChEmb_Counter
	.if	(zero?)

		;●アドレスの設定
		xor	ax,ax
		mov	al,ds:[di].WTD_ChEmb_Address
		.if	(ds:[si].WTD_FlagControl & cx)
			mov	ah,01h			;ax←Address
		.endif
		lea	si,[bp + WTD_WorkAdd_Emb]	;エンベロープアドレス
		add	si,ax				;si←データアドレス

		;●Count再設定
		mov	ah,ds:[si].WTD_Emb_AS		;
		.if	(ah & 80h)
			neg	ah			;
		.endif
		mov	ds:[di].WTD_ChEmb_Counter,ah	;

		;●Rate ＆ Level処理
		mov	al,ds:[di].WTD_ChEmb_LevelSet
		.if	(ds:[si].WTD_Emb_AS & 80h)	;比較(正 or 負)
		  sub	al,ds:[si].WTD_Emb_AR		;負
		  jc	I_Play_Emb_Step3		;
		  cmp	al,ds:[si].WTD_Emb_AL		;最小値チェック
		  jnc	I_Play_Emb_StepEnd		;
		.else
		  add	al,ds:[si].WTD_Emb_AR		;正
		  jc	I_Play_Emb_Step3		;
		  cmp	al,ds:[si].WTD_Emb_AL		;最大値チェック
		  jc	I_Play_Emb_StepEnd		;
		.endif

		;●最大値を超えた場合
I_Play_Emb_Step3:					;
		mov	al,ds:[si].WTD_Emb_AL		;
		mov	ah,ds:[di].WTD_ChEmb_Address	;
		and	ah,0fh				;

		.if	(ah<08h)
		  push	ax				;
		  add	ds:[di].WTD_ChEmb_Address,04h	;
		  add	si,4				;アドレスの設定
		  lodsw					;
		  mov	dx,ds:[si]			;
		  mov	ds:[di].WTD_ChEmb_Rate,al	;
		  .if	(ah&80h)
			neg	ah			;
		  .endif
		  mov	ds:[di].WTD_ChEmb_Counter,ah	;
		  mov	ds:[di].WTD_ChEmb_MaxMin,dl	;
		  pop	ax				;
		.endif
I_Play_Emb_StepEnd:					;

		mov	ds:[di].WTD_ChEmb_LevelSet,al	

	.endif

	xor	dx,dx				;
	mov	dl,ds:[di].WTD_ChEmb_LevelSet	;

	ret					;
I_Play_Emb	endp
;===============================================================|
;			LFO処理	メイン				|
;===============================================================|
	even				;偶数アドレス配置
I_Play_LFO	proc	near	uses	ax di

	add	di,dx

	;Rate処理
	dec	ds:[di].WTD_ChLfo_RateCounter		;
	.if	(zero?)
		mov	al,ds:[di].WTD_ChLfo_SpeedRate		;
		mov	ds:[di].WTD_ChLfo_RateCounter,al	;

		;Level処理(dx←Level)
		mov	dx,ds:[di].WTD_ChLfo_LevelSet		;dx←Level
		mov	al,ds:[di].WTD_ChLfo_CountCounter	;
	;	shr	al,1	;※
		.if	(al>ds:[di].WTD_ChLfo_Count)		;加減算の分岐
		  sub	dx,ds:[di].WTD_ChLfo_Level		;減算
		.else
		  add	dx,ds:[di].WTD_ChLfo_Level		;加算
		.endif
		mov	ds:[di].WTD_ChLfo_LevelSet,dx		;保存

		;Count処理
		dec	ds:[di].WTD_ChLfo_CountCounter		;
		.if	(zero?)
		  mov	al,ds:[di].WTD_ChLfo_Count		;カウンター初期化
		  shl	al,1					;al = al × 2	（何故？）
		  mov	ds:[di].WTD_ChLfo_CountCounter,al	;
		.endif
	.endif

	mov	dx,DS:[di].WTD_ChLfo_LevelSet		;dx←LFOのレベル

	ret					;
I_Play_LFO	endp
;****************************************************************
;*								*
;*			効果音終了時の設定復帰			*
;*								*
;****************************************************************
;*	●引数							*
;*		ch	チャンネル				*
;*		ds:bx	System Sturuc				*
;*		ds:di	Part Sturuc				*
;****************************************************************
	even				;偶数アドレス配置
I_Effect_Return	proc	near			;
	pusha					;レジスタ保存

;---------------------------------------------------------------
;フラグのリセット
	mov	cl,ch				;
	and	cl,07h				;
	inc	cl				;
	mov	ax,0f7ffh			;
	rol	ax,cl				;
	and	ds:[bx].WTD_Sys_Flag,ax		;
;---------------------------------------------------------------
;Channel Modeの復帰
	mov	ax,ds:[bx].WTD_Sys_Flag		;ah←Channel Mode Flag
	and	ah,0fh				;ah←その他のFlagをMask
	shl	ah,4				;
	xchg	ah,al				;
	mov	ah,08h				;ah←08h
	mov	cl,ch				;
	and	cl,07h				;上位5bitマスク
	inc	cl				;
	shl	ah,cl				;ah = ah*2^cl (SetBit)
	call	SP_Set_Channel			;

;---------------------------------------------------------------
;パート個別

	;パート検索
	mov	cl,MusicMaxPart			;20回ループ
	lea	di,[bp + WTD_WorkAdd_Ch0]	;
	.repeat
	  .if	(ds:[di].WTD_Channel == ch)

	    push	es
	    mov	es, ds:[bx].WTD_Sys_MusicSegment
	    .if	!(ds:[di].WTD_FlagControl & WTD_Ctrl_PlayEnd)


		;復帰
		and	ch,03h				;チャンネル情報だけにする。

		;周波数
		mov	ax,ds:[di].WTD_FrectionSet	;周波数の復帰
		call	SP_Set_Frection			;

		;音量
		mov	al,ds:[di].WTD_ExprPanSet	;音量の復帰
		call	SP_Set_Volume			;

		;音色
		mov	al, ds:[di].WTD_Voice
		inc	ds:[di].WTD_Voice
		call	I_SP_Voice

		.if	(ch == 2)
			;スウィープ値(ch=02h)
			mov	al,ds:[di].WTD_SweepLevel	;
			mov	ah,ds:[di].WTD_SweepTime	;
			call	SP_Set_Sweep			;
		.elseif	(ch == 3)
			;ノイズモード(ch=03h)
			mov	ah,01fh				;
			mov	al,ds:[di].WTD_NoiseMode	;
			or	al,018h				;
			and	al,ah				;
			call	SP_Set_Noise			;
		.endif

	    .else
		.if	(ds:[bx].WTD_Sys_Flag & WTD_Sys_Music)
			mov	ax,0			;エクスプレッション = 0
			call	SP_Set_Volume			;
			mov	ax,0			;音色 = 0
			call	SP_Set_Voice
		.endif
	    .endif
	    pop		es
	    .break
	  .endif
	  add	di,WTD_WorkChSize		;構造体のサイズは80h(0x80)
	  dec	cl
	.until	(zero?)

;---------------------------------------------------------------
I_Effect_Return_End:
	popa					;レジスタ復帰
	ret					;
I_Effect_Return	endp
