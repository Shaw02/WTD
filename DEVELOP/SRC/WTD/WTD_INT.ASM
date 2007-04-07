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
	push	ax				;
	push	bx				;
	push	cx				;
	push	dx				;
	push	si				;
	push	di				;
	push	bp				;
	push	ds				;レジスタ保存

;---------------------------------------------------------------
;EOIの発行

	cli					;割り込み不可

;End Of Interrupt
	mov	al,Int_HblankSet		;
	out	Int_Eoi,al			;出力

;	in	al,Int_Enable			;
;	and	al,INT_HblankReset		;シリアル送信エンプティー
;	out	Int_Enable,al			;割り込み禁止
;---------------------------------------------------------------
;バンクの設定
ifndef	IRAM		;DGROUP=IRAMの場合、不要
	in	al,BankSram			;現在のSRAM Bankを得る
	cmp	al,BANK_USERDS0			;ユーザ領域を示していたら、
	jz	I_Start_Step1			;この処理は行わない。
	cmp	al,BANK_USERDS1			;
	jz	I_Start_Step1			;'/ram0'アクセス中は、
	jmp	I_Start_End			;処理をしない。
endif

I_Start_Step1:

;---------------------------------------------------------------
;ワークエリアアドレスの取得

;	push	SRAM_Segment			;
;	pop	ds				;ds←SRAMセグメント
;	mov	bp,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス
	WTD_WorkGet	ds,bp			;ワークエリアアドレスの取得
	mov	bx,bp				;
	add	bx,WTD_WorkAdd_System		;ds;bx←共通構造体

;---------------------------------------------------------------
;演奏・効果音・PcmVoiceルーチンの呼び出し

	;タイマーをエミュレートするか？
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_TimerEmulate
	jz	I_Start_Step2				;

	;------------------------------------------------
	;タイマーをエミュレートする時に追加される処理。	;
	;CALL命令と、ret命令の6clockが勿体ない		;
	;------------------------------------------------
	;PCM Voice					;
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_Pcm	;PCM Voice鳴らす？
	jz	I_PcmStep				;

	;レジスタ設定
	mov	di,bp					;
	add	di,WTD_WorkAdd_PCM			;di←パート個別構造体
	push	es					;レジスタ保存

	;アドレス取得
	les	si,dword ptr ds:[di].WTD_PcmAddress	;es:si←Play Address
	mov	dx,es					;dx:si←Play Address
	;データ取得
	mov	al,es:[si]				;(注意：PipeLine)
	inc	si					;
	;データ出力
	out	PCM_Com_VolumeCh2,al			;出力

	;ポインタチェック（セグメント境界？）
	jnz	I_PcmVoice_Step1			;
	add	dx,1000h				;セグメント増やす
I_PcmVoice_Step1:					;
	;アドレス保存
	mov	word ptr ds:[di].WTD_PcmAddress+0,si	;アドレス保存
	mov	word ptr ds:[di].WTD_PcmAddress+2,dx	;(注意：PipeLine)

	;終了？
	sub	word ptr ds:[di].WTD_PcmSize+0,1	;PcmSize ディクリメント
	sbb	word ptr ds:[di].WTD_PcmSize+2,0	;
	mov	ax,word ptr ds:[di].WTD_PcmSize+0	;
	or	ax,word ptr ds:[di].WTD_PcmSize+2	;
	jnz	I_PcmVoice_End				;

	;終了処理
	and	ds:[bx].WTD_Sys_Flag,WTD_Sys_PcmR	;処理終了

I_PcmVoice_End:						;
	pop	es					;レジスタ復帰
I_PcmStep:						;
	;PCM Voice終わり				;
	;---------------				;
	;テンポ用カウンター　ディクリメント		;
	dec	ds:[bx].WTD_Sys_TempoCounter		;
	jnz	I_MusicEffectStep			;演奏を飛ばす。
	;------------------------------------------------
	;タイマーエミュレート時の処理ここまで。		;
	;------------------------------------------------

I_Start_Step2:						;Music & Effect	
	call	I_MusicEffect				;
I_MusicEffectStep:					;

;	in	ax,TIMER_CounterH		;
;	test	ax,ax				;たいまーカウンターが０
;	jz	I_Start_Step1			;だったら、もう一回。
;
;---------------------------------------------------------------
;バンクの復帰
ifndef	IRAM		;DGROUP=IRAMの場合、不要
;
;	pop	ax				;復帰
;	out	BankSram,al			;設定する。
;
endif
;---------------------------------------------------------------
;割り込みの終了
;
I_Start_End:
;	cli				;割り込み禁止
;
;	in	al,Int_Enable		;
;	or	al,INT_HblankSet	;タイマー
;	out	Int_Enable,al		;割り込み許可

	pop	ds				;レジスタ復帰
	pop	bp				;
	pop	di				;
	pop	si				;
	pop	dx				;
	pop	cx				;
	pop	bx				;
	pop	ax				;
	iret					;
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*								*
;****************************************************************
;===============================================================|
;		Music Main					|
;===============================================================|
;	●レジスタ使用						|
;		ax	汎用(主に計算)				|
;		ds:bx	共有構造体アドレス	引数		|
;		cx	汎用(主にカウンタ)			|
;		dx	汎用(主に計算)				|
;		ds:di	個別構造体				|
;		ds:bp	ワークベースアドレス	引数		|
;		es:si	演奏アドレス				|
;===============================================================|
	even					;偶数アドレス配置
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
	even					;偶数アドレス配置
I_MusicEffect_MusicLoop:			;
	call	I_Play				;
	add	di,WTD_WorkChSize		;構造体のサイズは80h(0x80)
	sub	cx,1				;
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
	mov	ax,ds:[bx].WTD_Sys_EffectSegment
	mov	es,ax				;es←効果音データセグメント

;演奏処理ルーチンの呼び出し
	xor	cx,cx				;
	mov	cl,ds:[bx].WTD_Sys_EffectPart	;最大'3'。
	or	cx,cx				;
	jz	I_MusicEffect_EffectStep	;
	even					;偶数アドレス配置
I_MusicEffect_EffectLoop:			;
	call	I_Play				;
	add	di,WTD_WorkChSize		;構造体のサイズは80h(0x80)
	sub	cx,1				;
	jnz	I_MusicEffect_EffectLoop	;

I_MusicEffect_EffectStep:			;

;---------------------------------------------------------------
;PCM Vioce効果音が発生しており、尚かつ終了であるならば、
;タイマーを戻す。

;タイマーエミュレート中であるか？
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_TimerEmulate
	jz	I_MusicEffect_PcmCheck_End		;

;PcmVioce処理終了？
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_Pcm	;
	jnz	I_MusicEffect_PcmCheck_Step1		;

;●PcmVioce処理終了の場合。
;フラグ初期化
	mov	ax,ds:[bx].WTD_Sys_Flag		;
;	and	ax,WTD_Sys_PcmR			;PCM効果音ディセーブル
;	and	ax,WTD_Sys_PcmEndR		;このフラグは廃止
	and	ax,WTD_Sys_EffectMask2R		;ch2 効果音マスクRes
	and	ax,WTD_Sys_TimerEmulateR	;タイマーエミュレートRes
	mov	ds:[bx].WTD_Sys_Flag,ax		;
;タイマー設定
	mov	ax,ds:[bx].WTD_Sys_Tempo	;タイマーの設定
	call	T_Set_Frection			;
;タイマーカウンタ設定
	xor	ax,ax				;ax←0
	mov	ds:[bx].WTD_Sys_TempoCounter,ax	;TempoCounter = 0
;channel 2  設定復帰
	mov	ch,81h				;設定復帰ch2
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
;		es:si	演奏アドレス		引数		|
;===============================================================|
	even				;偶数アドレス配置
I_Play:					;
	pusha				;
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

;音長による、音色制御
	mov	ax,ds:[di].WTD_Leng		;'@'コマンド
	sub	ax,ds:[di].WTD_LengCounter	;
	cmp	ax,ds:[di].WTD_ProgramRate	;
	jnz	I_Play_Step8			;
	test	ds:[di].WTD_Program2nd,80h	;必要性の確認
	jnz	I_Play_Step8			;
	push	ax				;
	mov	al,ds:[di].WTD_Program2nd	;
	and	al,07fh				;上位bitのマスク
	mov	dx,offset CGROUP:I_Table_Voice		;
	call	I_Table_Jump			;
	pop	ax				;
I_Play_Step8:					;

;音長による、ゲートタイム制御
	cmp	ax,ds:[di].WTD_GateTimeStepFirst
	jz	I_Play_Step3			;'u'コマンドの判定
	mov	ax,ds:[di].WTD_Leng		;'Q','U','q'コマンドの判定
	mov	ch,ds:[di].WTD_GateTime8	;ch←GateTime8
	rol	ch,1				;
	shr	ch,1				;Bit 7 Reset & Bit 7 -> Cy Flag
	jc	I_Play_Step5			;

	mov	dx,8				;'Q'コマンド
	sub	dl,ch				;dx = 8 － ch
	mul	dx				;dx:ax = ax × dx
	shr	dx,1				;
	shr	ax,1				;
	shr	dx,1				;
	shr	ax,1				;
	shr	dx,1				;
	shr	ax,1				;ax = dx:ax ÷ cl
	jmp	short I_Play_Step6		;

	even					;偶数アドレス配置
I_Play_Step5:					;'U'コマンド
	mov	cl,100				;cl = 100
	mov	dx,100				;dx = 100
	sub	dl,ch				;dx = dx － ch
	mul	dx				;dx:ax = ax × dx
	xor	ch,ch				;
	div	cx				;ax = dx:ax ÷ cl
I_Play_Step6:					;
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
	call	I_Play_Pan			;パン制御
	call	I_Play_Volume			;音量制御
	cmp	ds:[di].WTD_ExprSet,0		;　音量０だったら、
	jz	I_Play_StepEnd			;　以下の処理は無し。
	call	I_Play_Frection			;音程制御

;---------------------------------------------------------------
I_Play_StepEnd:				;
	popa				;
	ret				;
;****************************************************************
;*								*
;*			割り込みルーチン			*
;*				演奏・効果音制御部		*
;*				ループ				*
;*								*
;****************************************************************
	even				;偶数アドレス配置
I_Play_Loop:				;
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PlayEnd
	jnz	I_Loop_StepE		;演奏チェック
	cmp	ds:[di].WTD_LengCounter,0
	jnz	I_Loop_StepE		;音長チェック
	jmp	I_Loop_Step1		;
I_Loop_StepE:				;
	ret				;
	even				;偶数アドレス配置
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
	even				;偶数アドレス配置
I_Play_KeyOn:				;
	cmp	ds:[di].WTD_Key,0ffh	;休符？
	jnz	I_Play_KeyOn_Start	;
	jmp	I_Play_KeyOn_End	;

	even				;偶数アドレス配置
I_Play_KeyOn_Start:			;
	pusha				;レジスタ保存

;前回の音符は、タイ？
	test	ds:[di].WTD_FlagTai,02h	;前回タイあったか？
	jnz	I_Play_KeyOn_StepEnd	;

;音色制御
	mov	al,ds:[di].WTD_Program2nd	;'@'コマンド
	and	al,ds:[di].WTD_Program3rd	;必要性の確認
	and	al,080h				;第2,3パラメータの指定が
	jnz	I_Play_KeyOn_Step8		;無かったら、処理は無し。
	mov	al,ds:[di].WTD_Program1st	;
	and	al,07fh				;上位bitのマスク
	mov	dx,offset CGROUP:I_Table_Voice		;
	call	I_Table_Jump			;
I_Play_KeyOn_Step8:				;

;音量Embは処理必要。
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_ExprEmb
	jz	I_Play_KeyOn_Step4		;
	mov	cx,WTD_Ctrl_EmbVol		;
	mov	dx,WTD_ExprEmb			;
	call	I_Play_KeyOn_Emb		;
	jmp	I_Play_KeyOn_Step4End		;
I_Play_KeyOn_Step4:				;
	mov	ds:[di].WTD_ExprEmbLevelSet,0ffh
I_Play_KeyOn_Step4End:				;

	test	ds:[di].WTD_FlagControl,0037h	;音量Embは処理必要。
	jz	I_Play_KeyOn_Step7	;ソフトウェア処理がなかったら飛ばす。

;音程LFO
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_BendLfo
	jz	I_Play_KeyOn_Step1		;
	mov	dx,WTD_BendLFO			;
	call	I_Play_KeyOn_LFO		;
I_Play_KeyOn_Step1:				;

;音程Emb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_BendEmb
	jz	I_Play_KeyOn_Step2		;
	mov	cx,WTD_Ctrl_EmbFreq		;
	mov	dx,WTD_BendEmb			;
	call	I_Play_KeyOn_Emb		;
I_Play_KeyOn_Step2:				;

;音量LFO
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_ExprLFO
	jz	I_Play_KeyOn_Step3		;
	mov	dx,WTD_ExprLFO			;
	call	I_Play_KeyOn_LFO		;
I_Play_KeyOn_Step3:				;

;パンLFO
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PanLFO
	jz	I_Play_KeyOn_Step5		;
	mov	dx,WTD_PanLFO			;
	call	I_Play_KeyOn_LFO		;
I_Play_KeyOn_Step5:				;

;パンEmb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PanEmb
	jz	I_Play_KeyOn_Step6		;
	mov	cx,WTD_Ctrl_EmbPan		;
	mov	dx,WTD_PanEmb			;
	call	I_Play_KeyOn_Emb		;
I_Play_KeyOn_Step6:				;

;モジュレーション
I_Play_KeyOn_Step7:
ifndef	hyoka	;--------------------------------廉価版は無し
	xor	ax,ax				;
	cmp	ds:[di].WTD_ModLevelSet,al	;
	jz	I_Play_KeyOn_StepEnd		;前回とおなじ？
	mov	ds:[di].WTD_ModLevelSet,al	;
	mov	cl,MIDI_Ctrl_Mod		;
	mov	dx,offset CGROUP:I_Table_CtrlChgB	;モジュレーションを
	call	I_Table_Jump			;０する。
endif	;----------------------------------------

I_Play_KeyOn_StepEnd:			;
	popa				;レジスタ復帰

I_Play_KeyOn_End:			;
	ret				;
;===============================================================|
;			KeyOff (Hardware,Software)		|
;===============================================================|
	even				;偶数アドレス配置
I_Play_KeyOff:
	test	ds:[di].WTD_FlagTai,01h	;タイ？
	jnz	I_Play_KeyOff_End	;

I_Play_KeyOff_Start:			;
	pusha				;レジスタ保存

;ハードウェアをKeyOff
	mov	dx,offset CGROUP:I_Table_KeyOff	;
	call	I_Table_Jump			;KeyOff

;音色制御
	test	ds:[di].WTD_Program3rd,80h	;'@'コマンド
	jnz	I_Play_KeyOff_Step5		;必要性の確認
	mov	al,ds:[di].WTD_Program3rd	;
	and	al,07fh				;上位bitのマスク
	mov	dx,offset CGROUP:I_Table_Voice		;
	call	I_Table_Jump			;
I_Play_KeyOff_Step5:				;

;音程Emb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_BendEmb
	jz	I_Play_KeyOff_Step1		;
	mov	cx,WTD_Ctrl_EmbFreq		;
	mov	dx,WTD_BendEmb			;
	call	I_Play_KeyOff_Emb		;
I_Play_KeyOff_Step1:				;

;音量Emb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_ExprEmb
	jz	I_Play_KeyOff_Step2		;
	mov	cx,WTD_Ctrl_EmbVol		;
	mov	dx,WTD_ExprEmb			;
	call	I_Play_KeyOff_Emb		;
	jmp	I_Play_KeyOff_StepEnd		;
I_Play_KeyOff_Step2:				;
	test	ds:[di].WTD_Channel,80h		;MIDIパートの場合は操作しない。
	jz	I_Play_KeyOff_Step3		;
	mov	ds:[di].WTD_ExprEmbLevelSet,000h
I_Play_KeyOff_Step3:				;

;パンEmb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PanEmb
	jz	I_Play_KeyOff_Step4		;
	mov	cx,WTD_Ctrl_EmbPan		;
	mov	dx,WTD_PanEmb			;
	call	I_Play_KeyOff_Emb		;
I_Play_KeyOff_Step4:				;

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
	even				;偶数アドレス配置
I_Play_Frection:			;
	pusha				;

;モジュレーション制御(MIDI)
ifndef	hyoka	;--------------------------------廉価版は無し
	mov	ax,ds:[di].WTD_Leng		;モジュレーション
	sub	ax,ds:[di].WTD_LengCounter	;
	cmp	ax,ds:[di].WTD_ModDecay		;
	jnz	I_Play_Frection_Step4		;
	mov	al,ds:[di].WTD_ModLevel		;
;	cmp	ds:[di].WTD_ModLevelSet,al	;
;	jz	I_Play_Frection_Step4		;同じではないでしょう。
	mov	ds:[di].WTD_ModLevelSet,al	;
	mov	cl,MIDI_Ctrl_Mod		;
	mov	dx,offset CGROUP:I_Table_CtrlChgB	;モジュレーションを
	call	I_Table_Jump			;かける。
endif	;----------------------------------------
I_Play_Frection_Step4:				;


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
	mov	cx,WTD_Ctrl_EmbFreq	;
	mov	dx,WTD_BendEmb		;
	call	I_Play_Emb		;
	sub	dl,80h			
	jnc	I_Play_Frection_Step3	;
	mov	dh,0ffh			;dx←dl(符号付)
I_Play_Frection_Step3:			;
	shl	dx,6			;×2^6
	add	ax,dx			;加算
I_Play_Frection_Step2:			;

;音程の出力
	mov	dx,offset CGROUP:I_Table_Frection	;音程セット
	call	I_Table_Jump			;

	popa				;
	ret				;
;===============================================================|
;			音量制御 (Detune,LFO,Emb合成)		|
;===============================================================|
	even				;偶数アドレス配置
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
	mov	cx,WTD_Ctrl_EmbVol	;
	mov	dx,WTD_ExprEmb		;
	call	I_Play_Emb		;
;	mov	ds:[di].WTD_ExprEmbLevelSet,dl	;エンベロープ値
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
	mov	bx,offset CGROUP:I_Volume_Table	;log演算
	mov	si,ax			;
	and	si,00ffh		;
	mov	al,cs:[bx + si]		;
	inc	ax			;ax←ソフト音量+1
	mul	cx			;
	dec	ax			;al←((2*Vol.+1)×(SoftVol.+1)／256)-1
	mov	al,ah			;(Range:0～255)

;音量の出力
	mov	dx,offset CGROUP:I_Table_Volume	;音量セット
	call	I_Table_Jump			;

	popa				;
	ret				;
;===============================================================|
;			パンポット制御 (LFO,Emb合成)		|
;===============================================================|
	even				;偶数アドレス配置
I_Play_Pan:				;
	pusha				;

;パンポット読み込み
	mov	al,ds:[di].WTD_Pan	;
	and	ax,0007fh		;

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PanLFO + WTD_Ctrl_PanEmb
	jz	I_Play_Pan_Output	;ソフトウェア処理がなかったら飛ばす。

;128倍にする。
	inc	ax			;
	shl	ax,7			;
	dec	ax			;（Range:0～16383）

;パンポットLFO処理
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PanLFO
	jz	I_Play_Pan_Step1	;
	mov	dx,WTD_PanLFO		;
	call	I_Play_LFO		;
	add	ax,dx			;
I_Play_Pan_Step1:			;

;パンポットEmb処理
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PanEmb
	jz	I_Play_Pan_Step2	;
	mov	cx,WTD_Ctrl_EmbPan	;
	mov	dx,WTD_PanEmb		;
	call	I_Play_Emb		;
	sub	dl,80h			;
	jnc	I_Play_Pan_Step3	;
	mov	dh,0ffh			;dx←dl(符号付)
I_Play_Pan_Step3:			;
	shl	dx,6			;×2^6
	add	ax,dx			;加算
I_Play_Pan_Step2:			;

;パンポットを、7bitに補正
	inc	ax			;
	shr	ax,7			;ax←{(ax+1)÷128}-1
	dec	ax			;（Range:0～127）
	test	ah,ah			;
	jnz	I_Play_Pan_Step5	;
	test	al,080h			;
	jz	I_Play_Pan_Step6	;
I_Play_Pan_Step4:			;if (128=>ax>255){
	mov	al,07fh			;	al = 0x7F;
	jmp	I_Play_Pan_Step6	;}
I_Play_Pan_Step5:			;if (ax>255){
	mov	al,000h			;	al = 0x00;
I_Play_Pan_Step6:			;}

;パンポットの出力
I_Play_Pan_Output:
	cmp	ds:[di].WTD_PanSet,al	;同じならば、要らない。
	jz	I_Play_Pan_End		;
	mov	ds:[di].WTD_PanSet,al	;書き込み
ifndef	hyoka	;------------------------廉価版は無し
	mov	cl,MIDI_Ctrl_Pan	;
	mov	dx,offset CGROUP:I_Table_CtrlChgB
	call	I_Table_Jump		;パンポットセット
endif	;--------------------------------

I_Play_Pan_End:
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
	even				;偶数アドレス配置
I_Play_KeyOn_LFO:				;
	push	ax				;
	push	bp				;レジスタ保存

	mov	bp,dx					;

;カウンター(Rate)の初期化
	mov	ah,ds:[di + bp].WTD_ChLfo_DecayRate	;DR
	add	ah,ds:[di + bp].WTD_ChLfo_SpeedRate	;SR
	mov	ds:[di + bp].WTD_ChLfo_RateCounter,ah	;

;カウンター(Count)の初期化
	mov	ah,ds:[di + bp].WTD_ChLfo_Count		;
	shr	ah,1					;ah = ah / 2
	mov	ds:[di + bp].WTD_ChLfo_CountCounter,ah	;

;レベルの初期化
	xor	ax,ax					;
	mov	ds:[di + bp].WTD_ChLfo_LevelSet,ax	;

	pop	bp					;レジスタ復帰
	pop	ax					;
	ret						;
;===============================================================|
;			Emb処理	KeyOn				|
;===============================================================|
	even				;偶数アドレス配置
I_Play_KeyOn_Emb:				;
	pusha					;

	xchg	bp,dx				;

	mov	al,ds:[di + bp].WTD_ChEmb_Address	;
	and	al,0f0h					;
	mov	ds:[di + bp].WTD_ChEmb_Address,al	;位置初期化

	mov	ah,00h				;上位アドレスの設定
	test	ds:[di].WTD_FlagControl,cx	;
	jz	I_Play_KeyOn_Emb_Step1		;
	mov	ah,01h				;
I_Play_KeyOn_Emb_Step1:				;

	mov	bx,dx				;bx←ベースアドレス
	add	bx,WTD_WorkAdd_Emb		;エンベロープアドレス
	add	bx,ax				;データアドレス
	mov	ax,ds:[bx]			;読み込み。
	add	bx,2				;
	mov	dx,ds:[bx]			;

	mov	ds:[di + bp].WTD_ChEmb_Rate,al		;
	cmp	ah,80h					;ahは、絶対値をとる。
	jc	I_Play_KeyOn_Emb_Step9			;
	neg	ah					;
I_Play_KeyOn_Emb_Step9:					;
	mov	ds:[di + bp].WTD_ChEmb_Counter,ah	;
	mov	ds:[di + bp].WTD_ChEmb_MaxMin,dl	;
	mov	ds:[di + bp].WTD_ChEmb_LevelSet,dh	;

	popa					;
	ret					;
;===============================================================|
;			Emb処理	KeyOff				|
;===============================================================|
	even				;偶数アドレス配置
I_Play_KeyOff_Emb:				;
	pusha					;

	xchg	bp,dx				;

	mov	al,ds:[di + bp].WTD_ChEmb_Address	;
	and	al,0f0h					;
	or	al,00cH					;
	mov	ds:[di + bp].WTD_ChEmb_Address,al	;位置初期化

I_Play_KeyOnOff_Emb:					;

	mov	ah,00h				;上位アドレスの設定
	test	ds:[di].WTD_FlagControl,cx	;
	jz	I_Play_KeyOff_Emb_Step1		;
	mov	ah,01h				;
I_Play_KeyOff_Emb_Step1:			;

	mov	bx,dx				;bx←ベースアドレス
	add	bx,WTD_WorkAdd_Emb		;エンベロープアドレス
	add	bx,ax				;データアドレス
	mov	ax,ds:[bx]			;読み込み。
	add	bx,2				;
	mov	dx,ds:[bx]			;

	mov	ds:[di + bp].WTD_ChEmb_Rate,al		;
	cmp	ah,80h					;ahは、絶対値をとる。
	jc	I_Play_KeyOff_Emb_Step9			;
	neg	ah					;
I_Play_KeyOff_Emb_Step9:				;
	mov	ds:[di + bp].WTD_ChEmb_Counter,ah	;
	mov	ds:[di + bp].WTD_ChEmb_MaxMin,dl	;

	popa					;
	ret					;
;===============================================================|
;			Emb処理	メイン				|
;===============================================================|
	even				;偶数アドレス配置
I_Play_Emb:					;
	push	bp				;
	push	bx				;レジスタ保存
	push	ax				;

	xchg	bp,dx				;

;●Speed処理
	sub	ds:[di + bp].WTD_ChEmb_Counter,1
	jz	I_Play_Emb_Step1		;
	jmp	I_Play_Emb_End			;
I_Play_Emb_Step1:				;

;●アドレスの設定
	mov	ah,00h				;上位アドレスの設定
	test	ds:[di].WTD_FlagControl,cx	;
	jz	I_Play_Emb_Step2		;
	mov	ah,01h				;
I_Play_Emb_Step2:				;ax←Address
	mov	al,ds:[di + bp].WTD_ChEmb_Address
	mov	bx,dx				;bx←ベースアドレス
	add	bx,WTD_WorkAdd_Emb		;エンベロープアドレス
	add	bx,ax				;bx←データアドレス

;●Count再設定
	mov	ah,ds:[bx].WTD_Emb_AS		;
	cmp	ah,80h				;ahは、絶対値をとる。
	jc	I_Play_Emb_Step5		;
	neg	ah				;
I_Play_Emb_Step5:				;
	mov	ds:[di + bp].WTD_ChEmb_Counter,ah

;●Rate処理
	mov	al,ds:[di + bp].WTD_ChEmb_LevelSet
	cmp	ds:[bx].WTD_Emb_AS,80h		;比較(正 or 負)
	jc	I_Play_Emb_Step7		;分岐
	sub	al,ds:[bx].WTD_Emb_AR		;負
	jmp	I_Play_Emb_Step8		;
I_Play_Emb_Step7:				;
	add	al,ds:[bx].WTD_Emb_AR		;正
I_Play_Emb_Step8:				;
	jc	I_Play_Emb_Step3		;

;●Level処理
	cmp	ds:[bx].WTD_Emb_AS,80h		;比較(正 or 負)
	jc	I_Play_Emb_Step4		;分岐
	cmp	al,ds:[bx].WTD_Emb_AL		;負 最小値チェック
	jc	I_Play_Emb_Step3		;
	jmp	I_Play_Emb_StepEnd		;
I_Play_Emb_Step4:				;正 最大値チェック
	cmp	al,ds:[bx].WTD_Emb_AL		;
	jnc	I_Play_Emb_Step3		;
	jmp	I_Play_Emb_StepEnd		;

;●最大値を超えた場合
I_Play_Emb_Step3:					;
	mov	al,ds:[bx].WTD_Emb_AL			;
	mov	ah,ds:[di + bp].WTD_ChEmb_Address	;
	and	ah,0fh					;
	cmp	ah,08h					;
	jnc	I_Play_Emb_StepEnd			;

	push	ax					;
	add	ds:[di + bp].WTD_ChEmb_Address,04h	;
	add	bx,4					;アドレスの設定
	mov	ax,ds:[bx]				;読み込み。
	add	bx,2					;
	mov	dx,ds:[bx]				;
	mov	ds:[di + bp].WTD_ChEmb_Rate,al		;
	cmp	ah,80h					;ahは、絶対値をとる。
	jc	I_Play_Emb_Step6			;
	neg	ah					;
I_Play_Emb_Step6:					;
	mov	ds:[di + bp].WTD_ChEmb_Counter,ah	;
	mov	ds:[di + bp].WTD_ChEmb_MaxMin,dl	;
	pop	ax					;

I_Play_Emb_StepEnd:				;
	mov	ds:[di + bp].WTD_ChEmb_LevelSet,al

I_Play_Emb_End:					;
	xor	dx,dx				;
	mov	dl,ds:[di + bp].WTD_ChEmb_LevelSet

	pop	ax				;
	pop	bx				;
	pop	bp				;
	ret					;
;===============================================================|
;			LFO処理	メイン				|
;===============================================================|
	even				;偶数アドレス配置
I_Play_LFO:					;
	push	ax				;
	push	bp				;レジスタ保存

	mov	bp,dx				;

;Rate処理
	sub	ds:[di + bp].WTD_ChLfo_RateCounter,1	;
	jnz	I_Play_LFO_End				;
	mov	al,ds:[di + bp].WTD_ChLfo_SpeedRate	;
	mov	ds:[di + bp].WTD_ChLfo_RateCounter,al	;

;Level処理(dx←Level)
	mov	dx,ds:[di + bp].WTD_ChLfo_LevelSet	;dx←Level
	mov	al,ds:[di + bp].WTD_ChLfo_CountCounter	;
	mov	ah,ds:[di + bp].WTD_ChLfo_Count		;加減算の分岐
	cmp	al,ah					;
	jz	I_Play_LFO_Add				;
	jc	I_Play_LFO_Add				;
I_Play_LFO_Sub:						;
	sub	dx,ds:[di + bp].WTD_ChLfo_Level		;減算
	jmp	I_Play_LFO_Step				;
I_Play_LFO_Add:						;
	add	dx,ds:[di + bp].WTD_ChLfo_Level		;加算
I_Play_LFO_Step:					;
	mov	ds:[di + bp].WTD_ChLfo_LevelSet,dx	;保存

;Count処理
	sub	ds:[di + bp].WTD_ChLfo_CountCounter,1	;
	jnz	I_Play_LFO_End				;
	mov	al,ds:[di + bp].WTD_ChLfo_Count		;カウンター初期化
	shl	al,1					;al = al × 2
	mov	ds:[di + bp].WTD_ChLfo_CountCounter,al	;

I_Play_LFO_End:
	mov	dx,DS:[di + bp].WTD_ChLfo_LevelSet	;dx←LFOのレベル

	pop	bp				;レジスタ復帰
	pop	ax				;
	ret					;
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
I_Effect_Return:				;
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
	push	si				;音色の復帰
	mov	si,bp				;
	add	si,WTD_WorkAdd_Wave		;
	xor	ax,ax				;
	mov	al,ds:[di].WTD_Voice		;
	shl	ax,4				;
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
