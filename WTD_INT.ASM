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
;	今のところ無し
;
;
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
;*			割り込みメインルーチン			*
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
I_Start:
	pusha					;
	push	bp				;
	push	ds				;レジスタ保存

;---------------------------------------------------------------
;EOIの発行

;End Of Interrupt
	mov	al,Int_HblankSet		;
	out	Int_Eoi,al			;出力

;---------------------------------------------------------------
;ワークエリアアドレスの取得

	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bp,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス
	mov	bx,bp				;
	add	bx,WTD_WorkAdd_System		;ds;bx←共通構造体

;---------------------------------------------------------------
;演奏・効果音・PcmVoiceルーチンの呼び出し

;PCM Voice
	call	I_Pcm				;PCM Voice

;Music & Effect
	cmp	ds:[bx].WTD_Sys_TempoCounter,0	;if(TempoCounter == 0){
	jnz	I_MusicEffectStep		;	I_MusicEffect();
	call	I_MusicEffect			;};
I_MusicEffectStep:				;

;---------------------------------------------------------------
;割り込みの終了

	pop	ds				;レジスタ復帰
	pop	bp				;
	popa					;
	iret					;
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
;*		ds:bx	共有構造体アドレス	引数		*
;*		cx	汎用(主にカウンタ)			*
;*		dx	汎用(主に計算)				*
;*		ds:di	個別構造体				*
;*		es:si	演奏アドレス				*
;*		ds:bp	ワークベースアドレス	引数		*
;*								*
;****************************************************************
;===============================================================|
;		PCM Main					|
;===============================================================|
I_Pcm:						;
;---------------------------------------------------------------
;PcmVioceルーチン

;PcmVioceあるか？
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_Pcm	;
	jz	I_Pcm_PcmStep				;
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_PcmEnd	;
	jnz	I_Pcm_PcmStep1				;

;レジスタ設定
	mov	di,bp				;
	add	di,WTD_WorkAdd_PCM		;di←パート個別構造体

;PcmVioce発生					;
	call	I_PcmVoice			;発生ルーチン呼び出し

;---------------------------------------------------------------
;カウント

;テンポ用カウンター　ディクリメント
I_Pcm_PcmStep1:					;
	dec	ds:[bx].WTD_Sys_TempoCounter	;

;---------------------------------------------------------------
;終わり

I_Pcm_PcmStep:					;
	ret					;
;===============================================================|
;		Music Main					|
;===============================================================|
I_MusicEffect:					;
	push	es				;レジスタ保存

;---------------------------------------------------------------
;演奏ルーチン

;演奏あるか？
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_Music	;
	jz	I_MusicEffect_MusicStep			;

;レジスタ設定
	mov	di,bp				;
	add	di,WTD_WorkAdd_Ch0		;di←パート個別構造体
	mov	ax,ds:[bx].WTD_Sys_MusicSegment	;
	mov	es,ax				;es←演奏データセグメント

;演奏処理ルーチンの呼び出し
	xor	cx,cx				;製品版は最大'20'。
	mov	cl,ds:[bx].WTD_Sys_MusicPart	;廉価版は最大' 4'。
	or	cx,cx				;
	jz	I_MusicEffect_MusicStep		;
I_MusicEffect_MusicLoop:			;
	call	I_Play				;
	add	di,WTD_WorkChSize		;構造体のサイズは80h(0x80)
	dec	cx				;
	jnz	I_MusicEffect_MusicLoop		;

I_MusicEffect_MusicStep:

;---------------------------------------------------------------
;効果音ルーチン

;効果音あるか？
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_Effect	;
	jz	I_MusicEffect_EffectStep		;

;レジスタ設定
	mov	di,bp				;
	add	di,WTD_WorkAdd_Ech0		;di←パート個別構造体
	mov	ax,ds:[bx].WTD_Sys_MusicSegment	;
	mov	es,ax				;es←演奏データセグメント

;演奏処理ルーチンの呼び出し
	xor	cx,cx				;
	mov	cl,ds:[bx].WTD_Sys_EffectPart	;最大'3'。
	or	cx,cx				;
	jz	I_MusicEffect_EffectStep	;
I_MusicEffect_EffectLoop:			;
	call	I_Play				;
	add	di,WTD_WorkChSize		;構造体のサイズは80h(0x80)
	dec	cx				;
	jnz	I_MusicEffect_EffectLoop	;

I_MusicEffect_EffectStep:			;

;---------------------------------------------------------------
;PCM Vioce効果音が発生しており、尚かつ終了であるならば、
;タイマーを戻す。

;PCM Vioce 発生中であるか？
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_Pcm	;
	jz	I_MusicEffect_PcmCheck_End		;

;PcmVioce処理終了？
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_PcmEnd	;
	jz	I_MusicEffect_PcmCheck_Step1		;

;●PcmVioce処理終了の場合。
;フラグ初期化
	mov	ax,ds:[bx].WTD_Sys_Flag		;
	and	ax,WTD_Sys_PcmR			;演奏ディセーブル
	and	ax,WTD_Sys_PcmEndR		;終了リセット
	and	ax,WTD_Sys_EffectMask2R		;ch2 効果音マスクRes
	mov	ds:[bx].WTD_Sys_Flag,ax		;
;タイマー設定
	mov	ax,ds:[bx].WTD_Sys_Tempo	;タイマーの設定
	call	T_Set_Frection			;
;タイマーカウンタ設定
	xor	ax,ax				;ax←0
	mov	ds:[bx].WTD_Sys_TempoCounter,ax	;TempoCounter = 0
;channel 2  設定復帰
	mov	ch,1				;設定復帰ch2
	call	I_Effect_Return			;
;終了
	jmp	I_MusicEffect_PcmCheck_End	;

;●PcmVioce処理継続の場合
I_MusicEffect_PcmCheck_Step1:			;
;タイマー設定
	mov	ax,1				;割り込み周期は最速
	call	T_Set_Frection			;(12KHz)
;タイマーカウンタ設定
	mov	ax,ds:[bx].WTD_Sys_Tempo	;
	mov	ds:[bx].WTD_Sys_TempoCounter,ax	;TempoCounter
;終了
;	jmp	I_MusicEffect_PcmCheck_End	;

;処理終わり
I_MusicEffect_PcmCheck_End:			;

;---------------------------------------------------------------
;終わり

	pop	es				;レジスタ復帰
	ret					;
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				ＰＣＭ制御部			*
;*								*
;****************************************************************
;===============================================================|
;		PCM Control Main				|
;===============================================================|
;	●レジスタ使用						|
;		ax	汎用(主に計算)				|
;		ds:bx	共有構造体アドレス	引数		|
;		cx	汎用(主にカウンタ)			|
;		dx	汎用(主に計算)				|
;		ds:di	個別構造体		引数		|
;		ds:bp	ワークベースアドレス	引数		|
;		es	演奏セグメントアドレス	引数		|
;		si	演奏オフセットアドレス			|
;===============================================================|
I_PcmVoice:
	push	es				;レジスタ保存
;---------------------------------------------------------------
;発生処理

;アドレス取得
	les	si,dword ptr ds:[di].WTD_PcmAddress	;es:si←Play Address

;データ入力
	mov	ch,1				;ch = 2
	mov	al,es:[si]			;
	inc	si				;
;データ出力
	call	SP_Set_Volume			;Volume Set

;アドレス取得
	mov	dx,es				;dx:si←Play Address
;ポインタチェック（セグメント境界？）
	cmp	si,0				;
	jnz	I_PcmVoice_Step1		;
	add	dx,1000h			;セグメント増やす
I_PcmVoice_Step1:				;

;アドレス保存
	mov	word ptr ds:[di].WTD_PcmAddress+0,si	;アドレス保存
	mov	word ptr ds:[di].WTD_PcmAddress+2,dx	;

;終了？
	sub	word ptr ds:[di].WTD_PcmSize+0,1
	jnc	I_PcmVoice_Step2		;PcmSize ディクリメント
	dec	word ptr ds:[di].WTD_PcmSize+2	;
I_PcmVoice_Step2:				;
	mov	ax,word ptr ds:[di].WTD_PcmSize+0
	or	ax,word ptr ds:[di].WTD_PcmSize+2
	jnz	I_PcmVoice_End			;

;終了処理
	mov	ax,ds:[bx].WTD_Sys_Flag		;終了フラグ='h'
	or	ax,WTD_Sys_PcmEnd		;
	mov	ds:[bx].WTD_Sys_Flag,ax		;

;---------------------------------------------------------------
I_PcmVoice_End:
;終わり
	pop	es				;レジスタ復帰
	ret					;
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*								*
;****************************************************************
;===============================================================|
;		Music Control Main				|
;===============================================================|
;	●レジスタ使用						|
;		ax	汎用(主に計算)				|
;		ds:bx	共有構造体アドレス	引数		|
;		cx	汎用(主にカウンタ)			|
;		dx	汎用(主に計算)				|
;		ds:di	個別構造体		引数		|
;		ds:bp	ワークベースアドレス	引数		|
;		es	演奏セグメントアドレス	引数		|
;		si	演奏オフセットアドレス			|
;===============================================================|
I_Play:					;
	pusha				;
	push	es			;レジスタ保存
;---------------------------------------------------------------

;演奏チェック
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PlayEnd
	jz	I_Play_Step1			;
	jmp	I_Play_StepE			;
I_Play_Step1:					;

;音長カウンター・ディクリメント
	dec	ds:[di].WTD_LengCounter		;

;音長による、キーオンディレイ
	mov	ax,ds:[di].WTD_Leng		;'k'コマンドの判定
	sub	ax,ds:[di].WTD_LengCounter	;
	cmp	ax,ds:[di].WTD_KeyOnDelay	;
	jnz	I_Play_Step2			;
	call	I_Play_KeyOn			;
I_Play_Step2:					;

;音長による、ゲートタイム制御

	mov	ax,ds:[di].WTD_Leng		;'u'コマンドの判定
	sub	ax,ds:[di].WTD_LengCounter	;
	cmp	ax,ds:[di].WTD_GateTimeStepFirst
	jz	I_Play_Step3			;

	mov	ax,ds:[di].WTD_Leng		;'Q','U','q'コマンドの判定
	mov	ch,ds:[di].WTD_GateTime8	;ch←GateTime8
	rol	ch,1				;
	shr	ch,1				;Bit 7 Reset & Bit 7 -> Cy Flag
	jc	I_Play_Step5			;'Q'コマンド
	mov	cl,8				;cl = 8
	jmp	short I_Play_Step6		;
I_Play_Step5:					;'U'コマンド
	mov	cl,100				;cl = 100
I_Play_Step6:					;
	xor	dx,dx				;
	mov	dl,cl				;dx = cl
	sub	dl,ch				;dx = dx － ch
	mul	dx				;dx:ax = ax × dx
	xor	ch,ch				;
	div	cx				;ax = dx:ax ÷ cl
	add	ax,ds:[di].WTD_GateTimeStepLast	;ax = ax + WTD_GateTimeStepLast
	jnc	I_Play_Step7			;オーバーフローしたら、
	mov	ax,0ffffh			;最大値に修正。
I_Play_Step7:					;
	cmp	ax,ds:[di].WTD_LengCounter	;
	jnz	I_Play_Step4			;
I_Play_Step3:					;
	call	I_Play_KeyOff			;
I_Play_Step4:					;

;音長カウンタ０ならば、コマンド処理
	cmp	ds:[di].WTD_LengCounter,0		;音長カウンタ＝０？
	jnz	I_Play_StepE				;
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect	;
	jnz	I_Play_Step8				;
	mov	es,ds:[bx].WTD_Sys_MusicSegment		;演奏処理
	jmp	I_Play_Step9				;
I_Play_Step8:						;
	mov	es,ds:[bx].WTD_Sys_EffectSegment	;効果音
I_Play_Step9:						;
	mov	si,ds:[di].WTD_Address			;es:si←Play Address
	call	I_Play_Loop				;制御ルーチンへ。
	mov	ds:[di].WTD_Address,si			;
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PlayEnd
	jnz	I_Play_StepE				;演奏終了？
	cmp	ds:[di].WTD_KeyOnDelay,0		;KeyOnDelayは０？
	jnz	I_Play_StepE				;
	call	I_Play_KeyOn				;であれば、KeyOn

;制御ルーチンへ
I_Play_StepE:					;
	call	I_Play_Frection			;音量制御
	call	I_Play_Volume			;音程制御

;---------------------------------------------------------------
	pop	es			;レジスタ復帰
	popa				;
	ret				;
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				ループ				*
;*								*
;****************************************************************
I_Play_Loop:				;
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PlayEnd
	jnz	I_Loop_StepE		;演奏チェック
	cmp	ds:[di].WTD_LengCounter,0
	jnz	I_Loop_StepE		;音長チェック
	jmp	I_Loop_Step1		;
I_Loop_StepE:				;
	ret				;
I_Loop_Step1:				;

;演奏データ読み込み
	mov	al,es:[si]		;
	inc	si			;

;コマンドタイプチェック
	rol	al,1			;
	shr	al,1			;cy←Command Type

;それぞれへ条件コール・その後、ループする。
	jc	I_Loop_Step2		;
	call	I_PlayCommand		;
	jmp	I_Play_Loop		;Loop
I_Loop_Step2:				;
	call	I_PlayKey		;
	jmp	I_Play_Loop		;Loop
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				KeyOn,KeyOff制御		*
;*								*
;****************************************************************
;*	●レジスタ使用						*
;*		ax	汎用(主に計算)				*
;*		ds:bx	共有構造体アドレス	引数		*
;*		cx	汎用(主にカウンタ)			*
;*		dx	汎用(主に計算)				*
;*		ds:di	個別構造体		引数		*
;*		ds:bp	ワークベースアドレス	引数		*
;*		es:si	演奏アドレス		引数		*
;****************************************************************
;===============================================================|
;			KeyOn (Hardware,Software)		|
;===============================================================|
I_Play_KeyOn:				;
	cmp	ds:[di].WTD_Key,0ffh	;休符？
	jnz	I_Play_KeyOn_Start	;
	jmp	I_Play_KeyOn_End	;

I_Play_KeyOn_Start:			;
	pusha				;レジスタ保存

;前回の音符は、タイ？
	test	ds:[di].WTD_FlagTai,02h	;前回タイあったか？
	jnz	I_Play_KeyOn_StepEnd	;

;音程LFO
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_BendLfo
	jz	I_Play_KeyOn_Step1		;
	mov	dx,WTD_BendLFO			;
	call	I_Play_KeyOn_LFO		;
I_Play_KeyOn_Step1:				;

;音程Emb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_BendEmb
	jz	I_Play_KeyOn_Step2		;
	mov	dx,WTD_BendEmb			;
	call	I_Play_KeyOn_Emb		;
I_Play_KeyOn_Step2:				;

;音量LFO
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_ExprLFO
	jz	I_Play_KeyOn_Step3		;
	mov	dx,WTD_ExprLFO			;
	call	I_Play_KeyOn_LFO		;
I_Play_KeyOn_Step3:				;

;音量Emb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_ExprEmb
	jz	I_Play_KeyOn_Step4		;
	mov	dx,WTD_ExprEmb			;
	call	I_Play_KeyOn_Emb		;
	jmp	I_Play_KeyOn_StepEnd		;
I_Play_KeyOn_Step4:				;
	mov	ds:[di].WTD_ExprEmbLevelSet,0ffh

I_Play_KeyOn_StepEnd:			;
	popa				;レジスタ復帰

I_Play_KeyOn_End:			;
	ret				;
;===============================================================|
;			KeyOff (Hardware,Software)		|
;===============================================================|
I_Play_KeyOff:
	test	ds:[di].WTD_FlagTai,01h	;タイ？
	jnz	I_Play_KeyOff_End	;

I_Play_KeyOff_Start:			;
	pusha				;レジスタ保存

;ハードウェアをKeyOff
	mov	dx,offset I_Table_KeyOff	;
	call	I_Table_Jump			;KeyOff

;音程Emb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_BendEmb
	jz	I_Play_KeyOff_Step1		;
	mov	dx,WTD_BendEmb			;
	call	I_Play_KeyOff_Emb		;
I_Play_KeyOff_Step1:				;

;音量Emb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_ExprEmb
	jz	I_Play_KeyOff_Step2		;
	mov	dx,WTD_ExprEmb			;
	call	I_Play_KeyOff_Emb		;
	jmp	I_Play_KeyOff_StepEnd		;
I_Play_KeyOff_Step2:				;
	test	ds:[di].WTD_Channel,80h		;MIDIパートの場合は操作しない。
	jz	I_Play_KeyOff_Step3		;
	mov	ds:[di].WTD_ExprEmbLevelSet,000h
I_Play_KeyOff_Step3:				;

I_Play_KeyOff_StepEnd:				;
	popa					;レジスタ復帰

I_Play_KeyOff_End:			;
	ret				;
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				音程・音量制御			*
;****************************************************************
;*	●レジスタ使用						*
;*		ax	汎用(主に計算)				*
;*		ds:bx	共有構造体アドレス	引数		*
;*		cx	汎用					*
;*		dx	ワークアドレス先頭(個別構造体)		*
;*		ds:di	個別構造体		引数		*
;*		ds:bp	ワークベースアドレス	引数		*
;*		es:si	演奏アドレス		引数		*
;****************************************************************
;===============================================================|
;			音程制御 (Detune,LFO,Emb合成)		|
;===============================================================|
I_Play_Frection:			;
	pusha				;

;音程読み込み
	mov	ax,ds:[di].WTD_Bend	;

;ディチューンの加算
	add	ax,ds:[di].WTD_BendDetune

;音量LFO処理
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_BendLFO
	jz	I_Play_Frection_Step1	;
	mov	dx,WTD_BendLFO		;
	call	I_Play_LFO		;
	add	ax,dx			;
I_Play_Frection_Step1:			;

;音量Emb処理
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_BendEmb
	jz	I_Play_Frection_Step2	;
	mov	dx,WTD_BendEmb		;
	call	I_Play_Emb		;
	test	dl,80h			;dx←dl(符号付)
	jz	I_Play_Frection_Step3	;
	mov	dh,0ffh			;
I_Play_Frection_Step3:			;
	shl	dx,6			;×2^6
	add	ax,dx			;加算
I_Play_Frection_Step2:			;

;音程の出力
	mov	dx,offset I_Table_Frection	;音程セット
	call	I_Table_Jump			;

	popa				;
	ret				;
;===============================================================|
;			音量制御 (Detune,LFO,Emb合成)		|
;===============================================================|
I_Play_Volume:				;
	pusha				;

;音量読み込み＆14bitに変換
	xor	ax,ax			;
	mov	al,ds:[di].WTD_Expr	;
	inc	ax			;
	shl	ax,7			;128倍にする。
	dec	ax			;（Range:0～16383）

;ディチューンの加算
	add	ax,ds:[di].WTD_ExprDetune

;音量LFO処理
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_ExprLFO
	jz	I_Play_Volume_Step1	;
	mov	dx,WTD_ExprLFO		;
	call	I_Play_LFO		;
	add	ax,dx			;
I_Play_Volume_Step1:			;

;音量Emb処理
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_ExprEmb
	jz	I_Play_Volume_Step2	;
	mov	dx,WTD_ExprEmb		;
	call	I_Play_Emb		;
	mov	ds:[di].WTD_ExprEmbLevelSet,dl	;エンベロープ値
I_Play_Volume_Step2:			;

;音量を、7bitに補正
	inc	ax			;
	shr	ax,7			;ax←{(ax+1)÷128}-1
	dec	ax			;（Range:0～127）
	test	ah,ah			;
	jnz	I_Play_Volume_Step4	;
	test	al,080h			;
	jz	I_Play_Volume_Step5	;
I_Play_Volume_Step3:			;if (128=>ax>255){
	mov	al,07fh			;	al = 0x7F;
	jmp	I_Play_Volume_Step5	;}
I_Play_Volume_Step4:			;if (ax>255){
	mov	al,000h			;	al = 0x00;
I_Play_Volume_Step5:			;}

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
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	I_Volume_SoftEffect		;効果音？
	mov	al,ds:[bx].WTD_Sys_VolumeMusic	;ax←音楽音量
	jmp	I_Volume_SoftEnd		;
I_Volume_SoftEffect:				;
	mov	al,ds:[bx].WTD_Sys_VolumeEffect	;ax←効果音音量
I_Volume_SoftEnd:				;
	mov	bx,offset I_Volume_Table	;log演算
	mov	si,ax			;
	and	si,00ffh		;
	mov	al,cs:[bx + si]		;
	inc	ax			;ax←ソフト音量+1
	mul	cx			;
	dec	ax			;al←((2*Vol.+1)×(SoftVol.+1)／256)-1
	mov	al,ah			;(Range:0～255)

;音量の出力
	mov	dx,offset I_Table_Volume	;音量セット
	call	I_Table_Jump			;

	popa				;
	ret				;
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				音程・音量LFO,Emb制御		*
;*				音程、音量で同一のルーチン	*
;*								*
;****************************************************************
;*	●レジスタ使用						*
;*		ax	汎用(主に計算)				*
;*		ds:bx	共有構造体アドレス	引数		*
;*		cx	汎用(主にカウンタ)			*
;*		dx	ワークアドレス先頭(個別構造体)		*
;*		ds:di	個別構造体		引数		*
;*		ds:bp	ワークベースアドレス	引数		*
;*		es:si	演奏アドレス		引数		*
;*	●返り値						*
;*		dx	変位(レベル)				*
;****************************************************************
;===============================================================|
;			LFO処理	KeyOn				|
;===============================================================|
I_Play_KeyOn_LFO:			;



	ret				;
;===============================================================|
;			Emb処理	KeyOn				|
;===============================================================|
I_Play_KeyOn_Emb:			;



	ret				;
;===============================================================|
;			Emb処理	KeyOff				|
;===============================================================|
I_Play_KeyOff_Emb:			;



	ret				;
;===============================================================|
;			Emb処理	メイン				|
;===============================================================|
I_Play_Emb:				;

	xor	dx,dx			;暫定処理

	ret				;
;===============================================================|
;			LFO処理	メイン				|
;===============================================================|
I_Play_LFO:				;

	xor	dx,dx			;暫定処理

	ret				;
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				音階コマンド(80h～FFh)		*
;*								*
;****************************************************************
;音階コード
I_PlayKey_Code:
	db	0			;c
	db	2			;d
	db	4			;e
	db	5			;f
	db	7			;g
	db	9			;a
	db	11			;b
;---------------------------------------------------------------
I_PlayKey_Auto:				;オートの半音処理(未解決)
	push	cx			;レジスタ保存

	dec	cl			;
	and	cl,07h			;cl←音程(0～7)

;＃処理
	mov	ch,ds:[di].WTD_FlagSharp	;
	shl	ch,cl				;
	jnc	I_PlayKey_Auto_Step1		;チェック
	inc	al				;KeyCode ++
I_PlayKey_Auto_Step1:				;

;ｂ処理
	mov	ch,ds:[di].WTD_FlagFlat		;
	shl	ch,cl				;
	jnc	I_PlayKey_Auto_Step2		;チェック
	dec	al				;KeyCode --
I_PlayKey_Auto_Step2:				;

	pop	cx			;
	ret				;
;---------------------------------------------------------------
I_PlayKey:				;
	push	ax			;レジスタ保存
	push	bx			;
	push	cx			;
	push	dx			;

;音程演算処理
	mov	cl,al				;cl←コマンド
	and	ax,07h				;al←音階情報(0～7)
	sub	ax,1				;
	jnc	I_PlayKey_Step1			;休符？
	jmp	I_PlayKey_Step2R		;
I_PlayKey_Step1:				;
	mov	bx,offset I_PlayKey_Code	;
	push	si				;
	mov	si,ax				;
	mov	al,cs:[bx + si]			;
	pop	si				;
	mov	ch,al				;ch←音階情報
	mov	al,ds:[di].WTD_Octave		;
	mov	ah,12				;
	imul	ah				;
	add	al,ch				;al←Key Code

;半音演算処理
	test	cl,008h				;Sharp Flag Check
	jnz	I_PlayKey_Step3			;
;'#' Flag = '0'
	test	cl,010h				;Flat Flag Check
	jnz	I_PlayKey_Step4			;
;'#b' Flag = '00'
	call	I_PlayKey_Auto			;自動半音処理
	jmp	I_PlayKey_Step2			;
I_PlayKey_Step4:				;
;'#b' Flag = '01'
	dec	al				;音程－１
	call	I_PlayKey_Auto			;自動半音処理
	jmp	I_PlayKey_Step2			;
;'#' Flag = '1'
I_PlayKey_Step3:				;
	test	cl,010h				;Flat Flag Check
	jnz	I_PlayKey_Step5			;
;'#b' Flag = '10'
	inc	al				;音程＋１
	call	I_PlayKey_Auto			;自動半音処理
	jmp	I_PlayKey_Step2			;
I_PlayKey_Step5:				;
;'#b' Flag = '11'	Nothing
;	jmp	I_PlayKey_Step2			;自動半音　無し

I_PlayKey_Step2:				;
	add	al,12				;KeyCode補正(MIDI単位)
I_PlayKey_Step2R:				;
	mov	ds:[di].WTD_Key,al		;音程保存
;ハードウェアをKeyOn
	add	al,ds:[di].WTD_KeyShift		;
	mov	dx,offset I_Table_KeyOn		;
	call	I_Table_Jump			;KeyOn

;タイフラグチェック
	test	cl,020h				;タイフラグチェック
	jz	I_PlayKey_Step6			;cy←0
	stc					;cy←1
I_PlayKey_Step6:				;
	rcl	ds:[di].WTD_FlagTai,1		;シフト

;音長フラグのチェック
	test	cl,040h				;音長フラグチェック
	jnz	I_PlayKey_Step7			;
;音長指定無しの場合
	mov	ax,ds:[di].WTD_LengDefault	;
	jmp	I_PlayKey_Step8			;
;音長指定有りの場合
I_PlayKey_Step7:				;
	xor	ax,ax				;
	mov	al,es:[si]			;ax←音長
	inc	si				;
	cmp	al,0ffh				;if (ax = 255)
	jnz	I_PlayKey_Step8			;then{
	mov	ax,es:[si]			;	ax = es:[si];
	inc	si				;	si = si + 2;
	inc	si				;};
I_PlayKey_Step8:				;
	mov	ds:[di].WTD_Leng,ax		;
	mov	ds:[di].WTD_LengCounter,ax	;

I_PlayKey_StepE:			;
	pop	dx			;
	pop	cx			;
	pop	bx			;
	pop	ax			;
	ret				;レジスタ復帰
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				補助コマンド(00h～7Fh)		*
;*								*
;****************************************************************
;===============================================================|
;			ジャンプテーブル			|
;===============================================================|
;コマンド処理のあるアドレス
I_PlayCommand_JumpTable:
	dw	offset I_Com00		;00 	
	dw	offset I_Com01		;01 	
	dw	offset I_Com02		;02 	
	dw	offset I_Com03		;03 	
	dw	offset I_Com04		;04 	
	dw	offset I_Com05		;05 	
	dw	offset I_Com06		;06 	
	dw	offset I_Com07		;07 	
	dw	offset I_Com08		;08 	
	dw	offset I_Com09		;09 	
	dw	offset I_Com0a		;0a 	
	dw	offset I_Com0b		;0b 	
	dw	offset I_Com0c		;0c 	
	dw	offset I_Com0d		;0d 	
	dw	offset I_Com0e		;0e 	
	dw	offset I_Com0f		;0f 	
	dw	offset I_Com10		;10 	
	dw	offset I_Com11		;11 	
	dw	offset I_Com12		;12 	
	dw	offset I_Com13		;13 	
	dw	offset I_Com14		;14 	
	dw	offset I_Com15		;15 	
	dw	offset I_Com16		;16 	
	dw	offset I_Com17		;17 	
	dw	offset I_Com18		;18 	
	dw	offset I_Com19		;19 	
	dw	offset I_Com1a		;1a 	
	dw	offset I_Com1b		;1b 	
	dw	offset I_Com1c		;1c 	
	dw	offset I_Com1d		;1d 	
	dw	offset I_Com1e		;1e 	
	dw	offset I_Com1f		;1f 	
	dw	offset I_Com20		;20  	
	dw	offset I_Com21		;21 !	Work Switch
	dw	offset I_Com22		;22 "	Work Base Address
	dw	offset I_Com23		;23 #		(MML:Sharp)
	dw	offset I_Com24		;24 $		(MML:Macro)
	dw	offset I_Com25		;25 %		(MML:Step)
	dw	offset I_Com26		;26 &		(MML:Tai)
	dw	offset I_Com27		;27 '	Acsent
	dw	offset I_Com28		;28 (	Volume down
	dw	offset I_Com29		;29 )	Volume up
	dw	offset I_Com2a		;2a *	LFO Switch
	dw	offset I_Com2b		;2b +		(MML:Sharp)
	dw	offset I_Com2c		;2c ,		(MML:Channel)
	dw	offset I_Com2d		;2d -		(MML:Flat)
	dw	offset I_Com2e		;2e .		(MML:Leng*1.5)
	dw	offset I_Com2f		;2f /	Emb. Switch
	dw	offset I_Com30		;30 0	Work mov
	dw	offset I_Com31		;31 1	Work add
	dw	offset I_Com32		;32 2	Work sub
	dw	offset I_Com33		;33 3	Work and
	dw	offset I_Com34		;34 4	Work or
	dw	offset I_Com35		;35 5	Work xor
	dw	offset I_Com36		;36 6	Work set
	dw	offset I_Com37		;37 7	Work res
	dw	offset I_Com38		;38 8	Work cmp
	dw	offset I_Com39		;39 9	Work test
	dw	offset I_Com3a		;3a :	Loop Jump
	dw	offset I_Com3b		;3b ;	Loop Jump Flag
	dw	offset I_Com3c		;3c <	Octave down
	dw	offset I_Com3d		;3d =		(MML:Natural)
	dw	offset I_Com3e		;3e >	Octave up
	dw	offset I_Com3f		;3f ?	
	dw	offset I_Com40		;40 @	Voice
	dw	offset I_Com41		;41 A	
	dw	offset I_Com42		;42 B	Bend , Bend Range(MIDI PRN)
	dw	offset I_Com43		;43 C	Track / Channel , Sound Type
	dw	offset I_Com44		;44 D	Drection Detune
	dw	offset I_Com45		;45 E	Emb.
	dw	offset I_Com46		;46 F	Volume(MIDI ctrl:00x7)
	dw	offset I_Com47		;47 G	Channel Pressior(MIDI:0xD0)
	dw	offset I_Com48		;48 H	Bank(MIDI ctrl:0x00)
	dw	offset I_Com49		;49 I	
	dw	offset I_Com4a		;4a J	
	dw	offset I_Com4b		;4b K	Key On Delay
	dw	offset I_Com4c		;4c L	Loop
	dw	offset I_Com4d		;4d M	Mod(MIDI Ctrl:0x01)
	dw	offset I_Com4e		;4e N	NPRN(MIDI Ctrl:0x62)
	dw	offset I_Com4f		;4f O	
	dw	offset I_Com50		;50 P	Mode Sw(WS) / Damper(MIDI)
	dw	offset I_Com51		;51 Q	Gate time
	dw	offset I_Com52		;52 R	
	dw	offset I_Com53		;53 S	
	dw	offset I_Com54		;54 T	Filter(MIDI ctrl:)
	dw	offset I_Com55		;55 U	Gate time
	dw	offset I_Com56		;56 V	Expression Detune
	dw	offset I_Com57		;57 W	
	dw	offset I_Com58		;58 X	Excluesiv Send(MIDI:0xF0)
	dw	offset I_Com59		;59 Y	
	dw	offset I_Com5a		;5a Z	Send Data(MIDI)
	dw	offset I_Com5b		;5b [	Loop
	dw	offset I_Com5c		;5c \	
	dw	offset I_Com5d		;5d ]	Loop End
	dw	offset I_Com5e		;5e ^	Lengs add
	dw	offset I_Com5f		;5f _	Key Trance
	dw	offset I_Com60		;60 `	
	dw	offset I_Com61		;61 a	(MML:La)
	dw	offset I_Com62		;62 b	(MML:Si)
	dw	offset I_Com63		;63 c	(MML:Do)
	dw	offset I_Com64		;64 d	(MML:Re)
	dw	offset I_Com65		;65 e	(MML:Mi)
	dw	offset I_Com66		;66 f	(MML:Fa)
	dw	offset I_Com67		;67 g	(MML:So)
	dw	offset I_Com68		;68 h	
	dw	offset I_Com69		;69 i	
	dw	offset I_Com6a		;6a j	
	dw	offset I_Com6b		;6b k	velocity(MIDI)
	dw	offset I_Com6c		;6c l	lengs
	dw	offset I_Com6d		;6d m	LFO
	dw	offset I_Com6e		;6e n	Noise mode
	dw	offset I_Com6f		;6f o	Octave
	dw	offset I_Com70		;70 p	Pan.
	dw	offset I_Com71		;71 q	Gate time
	dw	offset I_Com72		;72 r	hol.
	dw	offset I_Com73		;73 s	Sweep
	dw	offset I_Com74		;74 t	tempo(HBLANK)
	dw	offset I_Com75		;75 u	Gate time
	dw	offset I_Com76		;76 v	Volume (WS/MIDI)
	dw	offset I_Com77		;77 w	
	dw	offset I_Com78		;78 x		(MML:Hex)
	dw	offset I_Com79		;79 y	
	dw	offset I_Com7a		;7a z	
	dw	offset I_Com7b		;7b {	Auto trance
	dw	offset I_Com7c		;7c |	
	dw	offset I_Com7d		;7d }	
	dw	offset I_Com7e		;7e ~	
	dw	offset I_Com7f		;7f 	
;===============================================================|
;		コマンドによる分岐				|
;			いわゆる、Ｃ言語でいう'switch'文と同等	|
;===============================================================|
;	●レジスタ使用						|
;		ax						|
;		bx						|
;		cx	汎用(主にカウンタ)			|
;		dx	汎用(主に計算)				|
;		ds:di	個別構造体		引数		|
;		ds:bp	ワークベースアドレス	引数		|
;		es	演奏セグメントアドレス	引数		|
;		si	演奏オフセットアドレス			|
;===============================================================|
I_PlayCommand:				;
	push	ax			;
	push	bx			;レジスタ保存

	mov	bx,offset I_PlayCommand_JumpTable
	and	ax,007fh		;
	shl	ax,1			;
	add	bx,ax			;
	
	call	word ptr cs:[bx]	;サブルーチンの呼び出し
	
	pop	bx			;レジスタ復帰
	pop	ax			;
I_ComNull:				;
	ret				;
;===============================================================|
;		NULL						|
;===============================================================|
I_Com00:				;
I_Com01:				;
I_Com02:				;
I_Com03:				;
I_Com04:				;
I_Com05:				;
I_Com06:				;
I_Com07:				;
I_Com08:				;
I_Com09:				;
I_Com0a:				;
I_Com0b:				;
I_Com0c:				;
I_Com0d:				;
I_Com0e:				;
I_Com0f:				;
I_Com10:				;
I_Com11:				;
I_Com12:				;
I_Com13:				;
I_Com14:				;
I_Com15:				;
I_Com16:				;
I_Com17:				;
I_Com18:				;
I_Com19:				;
I_Com1a:				;
I_Com1b:				;
I_Com1c:				;
I_Com1d:				;
I_Com1e:				;
I_Com1f:				;
I_Com20:				;
	ret				;
;===============================================================|
;		Work Switch					|
;===============================================================|
I_Com21:				;
	or	ds:[di].WTD_FlagControl,WTD_Ctrl_WorkSw
	ret				;
;===============================================================|
;		Work Base Address Set				|
;===============================================================|
I_Com22:				;
	mov	al,es:[si]		;
	inc	si			;
	mov	ds:[di].WTD_WorkAddress,al
	ret				;
;===============================================================|
;		MML:Sharp					|
;===============================================================|
I_Com23:				;
	ret				;
;===============================================================|
;		MML:Macro					|
;===============================================================|
I_Com24:				;
	ret				;
;===============================================================|
;		MML:Step					|
;===============================================================|
I_Com25:				;
	ret				;
;===============================================================|
;		MML:Tai						|
;===============================================================|
I_Com26:				;
	ret				;
;===============================================================|
;		Acsent						|
;===============================================================|
I_Com27:				;
	mov	al,es:[si]		;
	inc	si			;
	mov	ds:[di].WTD_AcsentVelocity,al
	or	ds:[di].WTD_FlagControl,WTD_Ctrl_Acsent
	ret				;
;===============================================================|
;		Volume down					|
;===============================================================|
I_Com28:				;
	dec	ds:[di].WTD_Expr	;
	ret				;
;===============================================================|
;		Volume up					|
;===============================================================|
I_Com29:				;
	inc	ds:[di].WTD_Expr	;
	ret				;
;===============================================================|
;		LFO Switch					|
;===============================================================|
I_Com2a:				;
	ret				;
;===============================================================|
;		MML:Sharp					|
;===============================================================|
I_Com2b:				;
	ret				;
;===============================================================|
;		MML:Channel					|
;===============================================================|
I_Com2c:				;
	ret				;
;===============================================================|
;		MML:Flat					|
;===============================================================|
I_Com2d:				;
	ret				;
;===============================================================|
;		MML:Lengs×1.5					|
;===============================================================|
I_Com2e:				;
	ret				;
;===============================================================|
;		Emb. Switch					|
;===============================================================|
I_Com2f:				;
	ret				;
;===============================================================|
;		Work	mov	LD				|
;===============================================================|
I_Com30:				;
	ret				;
;===============================================================|
;		Work	add	ADD				|
;===============================================================|
I_Com31:				;
	ret				;
;===============================================================|
;		Work	sub	SUB				|
;===============================================================|
I_Com32:				;
	ret				;
;===============================================================|
;		Work	and	AND				|
;===============================================================|
I_Com33:				;
	ret				;
;===============================================================|
;		Work	or	OR				|
;===============================================================|
I_Com34:				;
	ret				;
;===============================================================|
;		Work	xor	XOR				|
;===============================================================|
I_Com35:				;
	ret				;
;===============================================================|
;		Work		SET				|
;===============================================================|
I_Com36:				;
	ret				;
;===============================================================|
;		Work		RES				|
;===============================================================|
I_Com37:				;
	ret				;
;===============================================================|
;		Work	cmp	CP				|
;===============================================================|
I_Com38:				;
	ret				;
;===============================================================|
;		work	test					|
;===============================================================|
I_Com39:				;
	ret				;
;===============================================================|
;		Loop Jump					|
;===============================================================|
I_Com3a:				;
;読み込み
	mov	dx,es:[si]		;
	inc	si			;
	inc	si			;

;カウンタ・読み込み
	push	bx			;
	xor	bx,bx			;
	mov	bl,ds:[di].WTD_LoopCountPointer
	mov	al,ds:[di + bx].WTD_LoopCount
	pop	bx			;

;カウンタ・ディクリメント
	cmp	al,1			;
	jz	I_Com3d_Step		;

	ret				;終了
;---------------------------------------------------------------
I_Com3d_Step:				;カウンター = 1 の場合。
	dec	ds:[di].WTD_LoopCountPointer
	mov	si,dx			;

	ret				;
;===============================================================|
;		Loop Jump Flags					|
;===============================================================|
I_Com3b:				;
	ret				;
;===============================================================|
;		Octave down					|
;===============================================================|
I_Com3c:				;
	dec	ds:[di].WTD_Octave	;
	ret				;
;===============================================================|
;		MML:Natural					|
;===============================================================|
I_Com3d:				;
	ret				;
;===============================================================|
;		Octave up					|
;===============================================================|
I_Com3e:				;
	inc	ds:[di].WTD_Octave	;
	ret				;
;===============================================================|
;		NULL '?'					|
;===============================================================|
I_Com3f:				;
	ret				;
;===============================================================|
;		Voice / Program					|
;===============================================================|
I_Com40:				;
	mov	al,es:[si]		;
	inc	si			;
	mov	dx,offset I_Table_Voice	;
	call	I_Table_Jump		;
	ret				;
;===============================================================|
;		NULL 'A'					|
;===============================================================|
I_Com41:				;
	ret				;
;===============================================================|
;		Bend & Bend Range(MIDI)				|
;===============================================================|
I_Com42:				;
	ret				;
;===============================================================|
;		Track / Sound Type				|
;===============================================================|
I_Com43:				;
	mov	al,es:[si]		;
	inc	si			;
	mov	ds:[di].WTD_Channel,al	;
	ret				;
;===============================================================|
;		Frection Detune					|
;===============================================================|
I_Com44:				;
	mov	ax,es:[si]		;
	inc	si			;
	inc	si			;
	mov	ds:[di].WTD_BendDetune,ax
	ret				;
;===============================================================|
;		Emblop						|
;===============================================================|
I_Com45:				;
	mov	al,es:[si]		;ax←エンベロープ番号
	inc	si			;
	push	ax			;保存
	xor	ax,ax			;
	mov	al,es:[si]		;ax←エンベロープ番号
	inc	si			;
	and	ax,001fh		;
	shl	ax,4			;
	pop	bx			;復帰
	mov	bh,ah			;
	cmp	bl,1			;
	jnz	I_Com45_Expr		;
	cmp	bl,2			;
	jnz	I_Com45_Pan		;

I_Com45_Bend:					;音程
	mov	ds:[di].WTD_BendEmbAddress,al	;
	mov	ax,ds:[si].WTD_FlagControl	;
	shr	bx,1				;bx bit 7  =  No. bit 5
	and	bx,WTD_Ctrl_EmbFreq		;
	and	ax,WTD_Ctrl_EmbFreqR		;
	or	ax,bx				;
	mov	ds:[si].WTD_FlagControl,ax	;
	jmp	I_Com45_End			;

I_Com45_Expr:					;音量
	mov	ds:[di].WTD_ExprEmbAddress,al	;
	mov	ax,ds:[si].WTD_FlagControl	;bx bit 8  =  No. bit 5
	and	bx,WTD_Ctrl_EmbVol		;
	and	ax,WTD_Ctrl_EmbVolR		;
	or	ax,bx				;
	mov	ds:[si].WTD_FlagControl,ax	;
	jmp	I_Com45_End			;

I_Com45_Pan:					;音程
	mov	ds:[di].WTD_BendEmbAddress,al	;
	mov	ax,ds:[si].WTD_FlagControl	;
	shl	bx,1				;bx bit 9  =  No. bit 5
	and	bx,WTD_Ctrl_EmbPan		;
	and	ax,WTD_Ctrl_EmbPanR		;
	or	ax,bx				;
	mov	ds:[si].WTD_FlagControl,ax	;
;	jmp	I_Com45_End			;

I_Com45_End:				;
	ret				;
;===============================================================|
;		Volume(MIDI ctrl:0x07)				|
;===============================================================|
I_Com46:				;
	ret				;
;===============================================================|
;		Channel Pressior(MIDI)				|
;===============================================================|
I_Com47:				;
	ret				;
;===============================================================|
;		Program Bank Select(MIDI)			|
;===============================================================|
I_Com48:				;
	ret				;
;===============================================================|
;		NULL 'I'					|
;===============================================================|
I_Com49:				;
	ret				;
;===============================================================|
;		NULL 'J'					|
;===============================================================|
I_Com4a:				;
	ret				;
;===============================================================|
;		Key on  Delay					|
;===============================================================|
I_Com4b:				;
	mov	ax,es:[si]		;
	inc	si			;
	inc	si			;
	mov	ds:[di].WTD_KeyOnDelay,ax
	ret				;
;===============================================================|
;		Loop						|
;===============================================================|
I_Com4c:				;
	mov	ax,es:[si]		;
	inc	si			;
	inc	si			;
	or	ax,ax			;演奏終了か？
	jz	I_Com4c_Step1		;
	mov	si,ax			;ループ
	ret				;

I_Com4c_Step1:				;
	or	ds:[di].WTD_FlagControl,WTD_Ctrl_PlayEnd
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jz	I_Com4c_Step2		;効果音か？
	mov	ch,ds:[di].WTD_Channel	;ch←チャンネル番号
	cmp	ch,80h			;
	jz	I_Com4c_Step2		;ＷＳ音源？
	and	ch,03h			;
	call	I_Effect_Return		;効果音からの復帰
I_Com4c_Step2:				;
	ret				;
;===============================================================|
;		Modration(MIDI ctrl:0x??)			|
;===============================================================|
I_Com4d:				;
	ret				;
;===============================================================|
;		NPRN(MIDI)					|
;===============================================================|
I_Com4e:				;
	ret				;
;===============================================================|
;		NULL 'O'					|
;===============================================================|
I_Com4f:				;
	ret				;
;===============================================================|
;		PCM Mode / MIDI Damper				|
;===============================================================|
I_Com50:				;
	mov	al,es:[si]		;
	inc	si			;読み込み
	mov	dx,offset I_Table_Mode	;
	call	I_Table_Jump		;設定
	ret				;終了
;===============================================================|
;		Gate time 'Q'					|
;===============================================================|
I_Com51:				;
	mov	al,es:[si]		;
	inc	si			;
	mov	ds:[di].WTD_GateTime8,al
	ret				;
;===============================================================|
;		NULL 'R'					|
;===============================================================|
I_Com52:				;
	ret				;
;===============================================================|
;		NULL 'S'					|
;===============================================================|
I_Com53:				;
	ret				;
;===============================================================|
;		Cut off fillter(MIDI)				|
;===============================================================|
I_Com54:				;
	ret				;
;===============================================================|
;		Gate Time(U)					|
;===============================================================|
I_Com55:				;
	mov	al,es:[si]		;
	inc	si			;
	or	al,080h			;
	mov	ds:[di].WTD_GateTime8,al
	ret				;
;===============================================================|
;		Expression Detune				|
;===============================================================|
I_Com56:				;
	mov	ax,es:[si]		;
	inc	si			;
	inc	si			;
	mov	ds:[di].WTD_ExprDetune,ax
	ret				;
;===============================================================|
;		NULL 'W'					|
;===============================================================|
I_Com57:				;
	ret				;
;===============================================================|
;		Excluesiv Send(MIDI)				|
;===============================================================|
I_Com58:				;
	ret				;
;===============================================================|
;		NULL 'Y'					|
;===============================================================|
I_Com59:				;
	ret				;
;===============================================================|
;		MIDI Send Data(MIDI)				|
;===============================================================|
I_Com5a:				;
	ret				;
;===============================================================|
;		Loop Start					|
;===============================================================|
I_Com5b:				;

;読み込み
	mov	al,es:[si]		;
	inc	si			;

;設定
	inc	ds:[di].WTD_LoopCountPointer

;カウンタ書き込み
	push	bx			;
	xor	bx,bx			;
	mov	bl,ds:[di].WTD_LoopCountPointer
	mov	ds:[di + bx].WTD_LoopCount,al
	pop	bx			;

;終了
	ret				;
;===============================================================|
;		NULL '\'					|
;===============================================================|
I_Com5c:				;
	ret				;
;===============================================================|
;		Loop End					|
;===============================================================|
I_Com5d:				;

;読み込み
	mov	dx,es:[si]		;
	inc	si			;
	inc	si			;

;カウンタ・ディクリメント
	push	bx			;
	xor	bx,bx			;
	mov	bl,ds:[di].WTD_LoopCountPointer
	sub	ds:[di + bx].WTD_LoopCount,1
	pop	bx			;
	jnz	I_Com5d_Step		;

	dec	ds:[di].WTD_LoopCountPointer

	ret				;終了
;---------------------------------------------------------------
I_Com5d_Step:				;カウンター <> 0 の場合。
	mov	si,dx			;

	ret				;
;===============================================================|
;		Tai (add lengs)					|
;===============================================================|
I_Com5e:				;
	ret				;
;===============================================================|
;		Key Trance					|
;===============================================================|
I_Com5f:				;
	mov	al,es:[si]		;
	inc	si			;
	mov	ds:[di].WTD_KeyShift,al	;
	ret				;
;===============================================================|
;		NULL '`'					|
;===============================================================|
I_Com60:				;
	ret				;
;===============================================================|
;		MML:a						|
;===============================================================|
I_Com61:				;
	ret				;
;===============================================================|
;		MML:b						|
;===============================================================|
I_Com62:				;
	ret				;
;===============================================================|
;		MML:c						|
;===============================================================|
I_Com63:				;
	ret				;
;===============================================================|
;		MML:d						|
;===============================================================|
I_Com64:				;
	ret				;
;===============================================================|
;		MML:e						|
;===============================================================|
I_Com65:				;
	ret				;
;===============================================================|
;		MML:f						|
;===============================================================|
I_Com66:				;
	ret				;
;===============================================================|
;		MML:g						|
;===============================================================|
I_Com67:				;
	ret				;
;===============================================================|
;		NULL 'h'					|
;===============================================================|
I_Com68:				;
	ret				;
;===============================================================|
;		NULL 'i'					|
;===============================================================|
I_Com69:				;
	ret				;
;===============================================================|
;		NULL 'j'					|
;===============================================================|
I_Com6a:				;
	ret				;
;===============================================================|
;		Velocity(MIDI)					|
;===============================================================|
I_Com6b:				;
	mov	al,es:[si]		;
	inc	si			;
	mov	ds:[di].WTD_Velocity,al	;
	ret				;
;===============================================================|
;		lengs						|
;===============================================================|
I_Com6c:				;
	xor	ax,ax			;
	mov	al,es:[si]		;
	inc	si			;
	cmp	al,0ffh			;
	jnz	I_Com6c_Step1		;

	mov	ax,es:[si]		;
	inc	si			;
	inc	si			;
I_Com6c_Step1:				;
	mov	ds:[di].WTD_LengDefault,ax
	ret				;
;===============================================================|
;		LFO						|
;===============================================================|
I_Com6d:				;
	ret				;
;===============================================================|
;		Noise mode					|
;===============================================================|
I_Com6e:				;
	mov	al,es:[si]		;
	inc	si			;
	mov	ds:[di].WTD_NoiseMode,al
	ret				;
;===============================================================|
;		Octave						|
;===============================================================|
I_Com6f:				;
	mov	al,es:[si]		;
	inc	si			;
	mov	ds:[di].WTD_Octave,al	;
	ret				;
;===============================================================|
;		Panpot						|
;===============================================================|
I_Com70:				;
	mov	al,es:[si]		;
	inc	si			;
	mov	ds:[di].WTD_Pan,al	;

	mov	cl,MIDI_Ctrl_Pan	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;

	ret				;
;===============================================================|
;		Gate time 'q'					|
;===============================================================|
I_Com71:				;
	mov	ax,es:[si]		;
	inc	si			;
	inc	si			;
	mov	ds:[di].WTD_GateTimeStepLast,ax
	ret				;
;===============================================================|
;		mml:r						|
;===============================================================|
I_Com72:				;
	ret				;
;===============================================================|
;		Sweep 						|
;===============================================================|
I_Com73:				;
	ret				;
;===============================================================|
;		tempo						|
;===============================================================|
I_Com74:				;
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	I_Com74_E		;効果音の場合、処理無し。

	mov	ax,es:[si]		;
	inc	si			;
	inc	si			;
	mov	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Tempo,ax
	call	T_Set_Frection		;タイマーセット

I_Com74_E:				;
	ret				;
;===============================================================|
;		Gate time 'u'					|
;===============================================================|
I_Com75:				;
	mov	ax,es:[si]		;
	inc	si			;
	inc	si			;
	mov	ds:[di].WTD_GateTimeStepFirst,ax
	ret				;
;===============================================================|
;		Volume						|
;===============================================================|
I_Com76:				;
	mov	al,es:[si]		;
	inc	si			;
	mov	ds:[di].WTD_Expr,al	;
	ret				;
;===============================================================|
;		NULL 'w'					|
;===============================================================|
I_Com77:				;
	ret				;
;===============================================================|
;		MML:Hexca					|
;===============================================================|
I_Com78:				;
	ret				;
;===============================================================|
;		Control Change(MIDI)				|
;===============================================================|
I_Com79:				;
	ret				;
;===============================================================|
;		NULL 'z'					|
;===============================================================|
I_Com7a:				;
	ret				;
;===============================================================|
;		Key Trance (major / minor)			|
;===============================================================|
I_Com7b:				;
	ret				;
;===============================================================|
;		NULL '|'					|
;===============================================================|
I_Com7c:				;
	ret				;
;===============================================================|
;		NULL '}'					|
;===============================================================|
I_Com7d:				;
	ret				;
;===============================================================|
;		NULL '~'					|
;===============================================================|
I_Com7e:				;
	ret				;
;===============================================================|
;		NULL ?						|
;===============================================================|
I_Com7f:				;
	ret				;
;****************************************************************
;*								*
;*			効果音終了時の設定復帰			*
;*								*
;****************************************************************
;*	●引数							*
;*		ch	チャンネル				*
;****************************************************************
I_Effect_Return:				;
	pusha					;レジスタ保存
;---------------------------------------------------------------
;Channel Modeの復帰
	mov	ax,ds:[bx].WTD_Sys_Flag		;ah←Channel Mode Flag
	and	ah,0fh				;al←その他のFlagをMask
	shl	ah,4				;al←ah * 2^4
	xchg	ah,al				;
	mov	ah,08h				;ah←08h
	inc	ch				;
	mov	cl,ch				;
	shr	ah,cl				;ah = ah*2^cl (SetBit)
	call	SP_Set_Channel			;

;---------------------------------------------------------------
;パート個別

;パート検索
	or	ch,80h				;Channel Code
	mov	cl,20				;20回ループ
	mov	di,bp				;
	add	di,WTD_WorkAdd_Ch0		;di←構造体アドレス
I_Effect_Return_Loop0:				;
	cmp	byte ptr ds:[di].WTD_Channel,ch	;
	jz	I_Effect_Return_Step0		;
	add	di,WTD_WorkChSize		;構造体のサイズは80h(0x80)
	dec	cl				;
	jnz	I_Effect_Return_Loop0		;
	jmp	I_Effect_Return_End		;音源は使われていない。
I_Effect_Return_Step0:

;復帰
	and	ch,03h				;チャンネル情報だけにする。
;周波数
	mov	ax,ds:[di].WTD_FrectionSet	;周波数の復帰
	call	SP_Set_Frection			;
;音量
	mov	al,ds:[di].WTD_ExprPanSet	;音量の復帰
	call	SP_Set_Volume			;
;音色
	push	si				;音量の復帰
	mov	si,bp				;
	add	si,WTD_WorkAdd_Wave		;
	xor	ax,ax				;
	mov	al,ds:[di].WTD_Voice		;
	shl	ax,16				;
	add	si,ax				;ds:si←音色のあるアドレス
	call	SP_Set_Voice			;
	pop	si				;
;スウィープ値(ch=02h)
	cmp	ch,2				;スウィープ値の復帰
	jnz	I_Effect_Return_Step2		;
	mov	al,ds:[di].WTD_SweepLevel	;
	mov	ah,ds:[di].WTD_SweepTime	;
	call	SP_Set_Sweep			;
I_Effect_Return_Step2:				;
;ノイズモード(ch=03h)
	cmp	ch,3				;ノイズモードの復帰
	jnz	I_Effect_Return_Step3		;
	mov	ah,01fh				;
	mov	al,ds:[di].WTD_NoiseMode	;
	or	al,018h				;
	and	al,ah				;
	call	SP_Set_Noise			;
I_Effect_Return_Step3:				;

;---------------------------------------------------------------
I_Effect_Return_End:
	popa					;レジスタ復帰
	ret					;

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
;-------------[	  Table   ]-------------
I_Table_KeyOn:				
	dw	I_SP_KeyOn		
	dw	I_SM_KeyOn		
;-------------[	WS内蔵PCM ]-------------
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
;-------------[	  Table   ]-------------
I_Table_KeyOff:				
	dw	I_SP_KeyOff		
	dw	I_SM_KeyOff		
;-------------[	WS内蔵PCM ]-------------
I_SP_KeyOff:				;
	mov	ds:[di].WTD_KeySet,0ffh	;空データの書き込み
	ret				;
;-------------[	外部MIDI  ]-------------
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
;-------------[	  Table   ]-------------
I_Table_Volume:				
	dw	I_SP_Volume		
	dw	I_SM_Volume		
;-------------[	WS内蔵PCM ]-------------
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
	and	ax,00ffh			;
	mov	bx,offset I_Volume_Table	;
	mov	si,ax				;
	mov	al,cs:[bx + si]		;cl←int(256*(log(al+1)/log(257)))
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
;-------------[	  Table   ]-------------
I_Table_Frection:			
	dw	I_SP_Frection		
	dw	I_SM_Frection		
;-------------[	WS内蔵PCM ]-------------
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
;-------------[	  Table   ]-------------
I_Table_Voice:				
	dw	I_SP_Voice		
	dw	I_SM_Voice		
;-------------[	WS内蔵PCM ]-------------
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
;-------------[	  Table   ]-------------
I_Table_PolyKeyPress:			
	dw	I_SP_PolyKeyPress	
	dw	I_SM_PolyKeyPress	
;-------------[	WS内蔵PCM ]-------------
I_SP_PolyKeyPress:			;
;	処理無し			;
	ret				;
;-------------[	外部MIDI  ]-------------
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
;-------------[	  Table   ]-------------
I_Table_PolyChPress:			
	dw	I_SP_PolyChPress	
	dw	I_SM_PolyChPress	
;-------------[	WS内蔵PCM ]-------------
I_SP_PolyChPress:			;
;	処理無し			;
	ret				;
;-------------[	外部MIDI  ]-------------
I_SM_PolyChPress:			;
	call	SM_ChPress		;
	ret				;
;===============================================================|
;			Control Change Byte			|
;===============================================================|
;	引数							|
;		ax←データ					|
;		cl←機能番号					|
;	返値							|
;		無し						|
;	処理							|
;		コントロールチェンジの送信			|
;===============================================================|
;-------------[	  Table   ]-------------
I_Table_CtrlChgB:			
	dw	I_SP_CtrlChgB		
	dw	I_SM_CtrlChgB		
;-------------[	WS内蔵PCM ]-------------
I_SP_CtrlChgB:				;
;	処理無し			;
	ret				;
;-------------[	外部MIDI  ]-------------
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
;-------------[	  Table   ]-------------
I_Table_CtrlChgW:			
	dw	I_SP_CtrlChgW		
	dw	I_SM_CtrlChgW		
;-------------[	WS内蔵PCM ]-------------
I_SP_CtrlChgW:				;
;	処理無し			;
	ret				;
;-------------[	外部MIDI  ]-------------
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
;-------------[	  Table   ]-------------
I_Table_Mode:				
	dw	I_SP_Mode		
	dw	I_SM_Mode		
;-------------[	WS内蔵PCM ]-------------
I_SP_Mode:				;
	push	cx			;
	push	ax			;レジスタ保存

	and	ax,0001h		;and	al,01h
	or	ax,0100h		;set	0,ah
	mov	cl,ch			;
	shl	ax,cl			;
	shr	ax,1			;

	call	SP_Set_Channel		;

	pop	ax			;レジスタ復帰
	pop	cx			;
	ret				;
;-------------[	外部MIDI  ]-------------
I_SM_Mode:				;
	push	cx			;レジスタ保存

	shl	al,6			;数値を64倍する。
	and	al,40h			;0か64だけ。
	mov	cl,MIDI_Ctrl_Hold	;
	call	SM_ControlWord		;ダンパースイッチの送信

	pop	cx			;レジスタ復帰
	ret				;
