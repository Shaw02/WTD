;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				IL Struct define			|
;				IL Function Routine			|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;****************************************************************
;*								*
;*		ＩＬの定義／データ群				*
;*								*
;****************************************************************
;===============================================================|
;		IL構造体定義					|
;===============================================================|
IL:						;IL構造体先頭
IL_Link_Pos	dw	0			;未使用
		dw	0			;
IL_N_Methods	dw	24			;ファンクション数
IL_GetInfo	dw	offset _GetInfo		;ILinfo構造体を得る
		dw	0			;far *TEST_GetInfo();
IL_F00		dw	offset _Stay		;
		dw	0			;
IL_F01		dw	offset _StayOut		;
		dw	0			;
IL_F02		dw	offset _Init		;
		dw	0			;
IL_F03		dw	offset _MusicPlay	;
		dw	0			;
IL_F04		dw	offset _MusicStop	;
		dw	0			;
IL_F05		dw	offset _EffectPlay	;
		dw	0			;
IL_F06		dw	offset _EffectStop	;
		dw	0			;
IL_F07		dw	offset _PcmPlay		;
		dw	0			;
IL_F08		dw	offset _PcmStop		;
		dw	0			;
IL_F09		dw	offset _PcmVoiceSet	;
		dw	0			;
IL_F10		dw	offset _SoftEmbSet	;
		dw	0			;
IL_F11		dw	offset _ChangeFar	;
		dw	0			;
IL_F12		dw	offset _SoundSetChannel	;
		dw	0			;
IL_F13		dw	offset _SoundGetChannel	;
		dw	0			;
IL_F14		dw	offset _SoundSetOutput	;
		dw	0			;
IL_F15		dw	offset _SoundGetOutput	;
		dw	0			;
IL_F16		dw	offset _SoundGetRandom	;
		dw	0			;
IL_F17		dw	offset _SetMusicVolume	;
		dw	0			;
IL_F18		dw	offset _GetMusicVolume	;
		dw	0			;
IL_F19		dw	offset _SetEffectVolume	;
		dw	0			;
IL_F20		dw	offset _GetEffectVolume	;
		dw	0			;
IL_F21		dw	offset _SetPcmVolume	;
		dw	0			;
IL_F22		dw	offset _GetPcmVolume	;
		dw	0			;
;===============================================================|
;		ILinfo構造体定義（全てポインタ）		|
;===============================================================|
ILinfo:							;ILinfo構造体先頭
ILinfo_ClassName	dw	offset ILinfoD_ClassName	;未使用
			dw	0				;
ILinfo_Name		dw	offset ILinfoD_Name		;名前
			dw	0				;
ILinfo_Version		dw	offset ILinfoD_Version		;バージョン
			dw	0				;
ILinfo_Description	dw	offset ILinfoD_Description	;未使用
			dw	0				;
ILinfo_Depends		dw	offset ILinfoD_Depends		;未使用
			dw	0				;
;===============================================================|
;		ILinfo構造体の内容				|
;===============================================================|
ILinfoD_WTD:					;内容
ILinfoD_ClassName	db	'WTD_IL',0	;未使用
ILinfoD_Name		db	wtdIL_Name	;名前
ILinfoD_Version		db	wtdIL_Version	;バージョン
ILinfoD_Description	db	0		;未使用
ILinfoD_Depends		dw	0		;未使用（ポインタ）
			dw	0		;
;****************************************************************
;*								*
;*		ＩＬのファンクション				*
;*								*
;****************************************************************
;===============================================================|
;		far *TEST_GetInfo()				|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		bx,ax←ILinfo構造体のポインタ			|
;	処理							|
;		ILinfoポインタの取得				|
;===============================================================|
_GetInfo	proc far		;
	push	cs			;
	pop	dx			;LSI-C86
	mov	ax,offset ILinfo	;dx:ax←far pointer
	retf				;
_GetInfo	endp			;
;===============================================================|
;	int	(far *Stay)();					|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		ax	00h	正常終了			|
;		ax	01h	heap領域が足りない		|
;	処理							|
;		WTD本体の常駐					|
;===============================================================|
_Stay		proc far		;
	push	bp			;bpレジスタの保存
	mov	bp,sp			;bp←sp
	push	bx			;
	push	cx			;
	push	dx			;
	push	di			;
	push	ds			;
	push	es			;
	pushf				;レジスタ保存

	cli				;割り込み禁止

;---------------------------------------------------------------
;ワークエリアアドレスの取得

;ワークエリアの取得
	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bx,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;エラーチェック
	cmp	bx,0f000h		;/* S-RAMは4096byte以上ある？ */
	jc	_Stay_00		;if (bx>0xF000) then ax=1:Retuen
	mov	ax,0001h		;/* 本体RAM容量が足りない。 */
	jmp	_Stay_End		;
_Stay_00:

;ワーク全体の初期化(00hで埋める)
;メモリ書き込み
	cld				;インクリメントモード
	mov	di,bx			;es:di←ワークファーアドレス
	mov	cx,WTD_WorkSize		;ワークのサイズ分(1000h)
	xor	ax,ax			;ax←0
	rep	stosb			;書き込み

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_Ch0		;ds:di←channel
	mov	si,bx				;
	add	si,WTD_WorkAdd_System		;ds:si←System

;---------------------------------------------------------------
;共通ワークの初期化

;レジスタの設定　構造体のベースポインタの設定。
	push	IRAM_Segment		;
	pop	es			;es←本体RAMセグメント

;IntVectorの設定
	mov	ax,es:[Hblank_intvector].0		;
	mov	ds:[si].WTD_Sys_OldIntvector+0,ax	;
	mov	ax,es:[Hblank_intvector].2		;
	mov	ds:[si].WTD_Sys_OldIntvector+2,ax	;
							;復帰用に保存
	mov	es:[Hblank_intvector].0,offset I_Start	;割り込みアドレスの
	mov	es:[Hblank_intvector].2,cs		;設定

;タイマー
	mov	ax,Timer_Tempo120			;
	mov	ds:[si].WTD_Sys_Tempo,ax		;
	xor	ax,ax					;
	mov	ds:[si].WTD_Sys_TempoCounter,ax		;

;ソフト音量
	mov	ax,0ffffh				;音量設定
	mov	ds:[si].WTD_Sys_VolumeMusic,al		;
	mov	ds:[si].WTD_Sys_VolumeEffect,al		;
	mov	al,0fh					;
	mov	ds:[si].WTD_Sys_VolumePcm,al		;


;
;	その他、ワーク内容の初期化をする。
;

;---------------------------------------------------------------
;デバイスの初期化

	call	C_open			;通信回線の初期化
	push	cs			;
	call	near ptr _Init		;ドライバーの初期化
	call	T_open			;タイマーの初期化

;---------------------------------------------------------------

;正常終了
	xor	ax,ax			;正常終了(ax=0000h)

_Stay_End:
	popf				;レジスタ復帰
	pop	es			;割り込みの許可は不要。
	pop	ds			;(popfがあるため。)
	pop	di			;
	pop	dx			;
	pop	cx			;
	pop	bx			;
	pop	bp			;bpレジスタの復帰
	retf				;終了
_Stay		endp			;
;===============================================================|
;	int	(far *StayOut)();				|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		ax	00h	正常終了			|
;		ax	01h	常駐していない。		|
;	処理							|
;		WTD本体の常駐解除				|
;===============================================================|
_StayOut	proc far		;
	push	bx			;
	push	di			;
	push	si			;
	push	ds			;
	push	es			;レジスタ保存

	cli				;割り込み禁止

;---------------------------------------------------------------
;デバイスの初期化

	call	T_close			;タイマー割り込みの停止、復帰
	push	cs			;
	call	near ptr _Init		;ドライバーの初期化
	call	C_close			;通信回線の遮断

;---------------------------------------------------------------
;ワークエリアの取得

	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bx,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_Ch0		;ds:di←channel
	mov	si,bx				;
	add	si,WTD_WorkAdd_System		;ds:si←System

;---------------------------------------------------------------
;割り込み設定の復帰

;レジスタの設定　構造体のベースポインタの設定。
	push	IRAM_Segment		;
	pop	es			;es←本体RAMセグメント

;IntVectorの復帰
	mov	ax,ds:[si].WTD_Sys_OldIntvector+0	;
	mov	es:[Hblank_intvector].0,ax		;
	mov	ax,ds:[si].WTD_Sys_OldIntvector+2	;
	mov	es:[Hblank_intvector].2,ax		;

;
;	その他、設定の復帰を行う。
;
;---------------------------------------------------------------
;正常終了

	xor	ax,ax			;正常終了(ax=0000h)
;	jmp	_StayOut_End		;

;---------------------------------------------------------------
_StayOut_End:

	sti				;割り込み許可

	pop	es			;レジスタ復帰
	pop	ds			;
	pop	si			;
	pop	di			;
	pop	bx			;
	retf				;終了
_StayOut	endp			;
;===============================================================|
;	void	(far *Init)();					|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		無し						|
;	処理							|
;		デバイスの初期化				|
;===============================================================|
_Init	proc far			;

;---------------------------------------------------------------
;演奏・効果音・PCMの停止。個別ワークの初期化

	push	cs			;
	call	near ptr _MusicStop	;演奏停止・割込周期の初期化
	push	cs			;
	call	near ptr _EffectStop	;効果音発生停止
	push	cs			;
	call	near ptr _PcmStop	;PcmVoice発生停止

;---------------------------------------------------------------
;デバイスの初期化

	call	SP_init			;デバイスの初期化
	call	SM_init			;GM Resetの送信
;	割り込み周期のリセット		;タイマー割り込み周期の初期設定

;---------------------------------------------------------------

	retf				;終了
_Init	endp				;
;===============================================================|
;	char	(far *MusicPlay)(char far *Music);		|
;===============================================================|
;	引き数							|
;		char far *Music		曲データのアドレス	|
;	返り値							|
;		ax		Error Code			|
;				00h	正常終了		|
;				01h	曲データじゃ無い。	|
;				02h	ヴァージョンが違う。	|
;	処理							|
;		演奏を開始する					|
;===============================================================|
_MusicPlay	proc far		;
	push	bp			;bpレジスタの保存
	mov	bp,sp			;bp←sp
	push	bx			;
	push	dx			;
	push	di			;
	push	si			;
	push	ds			;レジスタ保存
	pushf				;

	cli				;割り込み禁止

;---------------------------------------------------------------
;演奏の停止

	push	cs			;
	call	near ptr _MusicStop	;演奏停止・割込周期の初期化

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bx,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_Ch0		;ds:di←channel
	mov	si,bx				;
	add	si,WTD_WorkAdd_System		;ds:si←System

;---------------------------------------------------------------
;演奏アドレスの設定
	push	word ptr [bp + 08h]	;引数の取得	Segment
	push	word ptr [bp + 06h]	;		Offset
	push	cs			;データ変換
	call	near ptr _ChangeFar	;dxax = wtdIL.ChangeFar(*Music);
	add	sp,+4			;
	mov	ds:[si].WTD_Sys_MusicOffset,ax	;アドレスの設定
	mov	ds:[si].WTD_Sys_MusicSegment,dx	;

;ポインタの設定
	mov	es,dx			;
	mov	bx,ax			;es:bx←曲データ先頭アドレス

;---------------------------------------------------------------
;データ形式チェック

;ヘッダー文字列チェック
	cmp	word ptr es:[bx].WTD_Mus_Name,'TW'	;'WTD',0
	jz	_MusicPlay_Chk1			;
	mov	ax,1				;
	jmp	_MusicPlay_End			;
_MusicPlay_Chk1:

;バージョンチェック
	mov	ax,es:[bx].WTD_Mus_Version	;
	xchg	ah,al				;ax←Music Data Version
	push	bx				;
	mov	bx,WTdIL_Version_N		;
	cmp	bx,ax				;if (Ver - ax >= 0) then NG
	pop	bx				;
	jnc	_MusicPlay_Chk2			;
	mov	ax,2				;
	jmp	_MusicPlay_End			;
_MusicPlay_Chk2:


;---------------------------------------------------------------
;データ登録

;初期設定
	mov	ch,es:[bx].WTD_Mus_Voice	;数の取得 Voice
	mov	cl,es:[bx].WTD_Mus_Emb		;数の取得 Emb
	push	bx				;
	mov	bx,es:[bx].WTD_Mus_DataAdr	;

;WS内蔵PCM波形データの登録
_MusicPlay_Loop2:				;
	cmp	ch,0				;
	jz	_MusicPlay_Loop2_End		;
	xor	ax,ax				;
	mov	al,es:[bx]			;音色番号
	inc	bx				;
	push	es				;
	push	bx				;波形データ
	push	ax				;
	push	cs				;
	call	near ptr _PcmVoiceSet		;登録
	add	sp,+6				;
	add	bx,16				;
	dec	ch				;
	jnz	_MusicPlay_Loop2		;
_MusicPlay_Loop2_End:				;

;エンベロープデータの登録
_MusicPlay_Loop3:				;
	cmp	cl,0				;
	jz	_MusicPlay_Loop3_End		;
	xor	ax,ax				;
	mov	al,es:[bx]			;音色番号
	inc	bx				;
	push	es				;
	push	bx				;エンベロープデータ
	push	ax				;
	push	cs				;
	call	near ptr _SoftEmbSet		;登録
	add	sp,+6				;
	add	bx,16				;
	dec	cl				;
	jnz	_MusicPlay_Loop3		;
_MusicPlay_Loop3_End:				;

;レジスタ復帰
	pop	bx				;

;---------------------------------------------------------------
;個別ワークの設定

;チャンネル数の取得
	mov	ch,es:[bx].WTD_Mus_Part	;チャンネル数の取得
	cmp	ch,MusicMaxPart		;パート数チェック
	jc	_MusicPlay_Step2	;
	mov	ch,MusicMaxPart		;最大値を越えてたら最大値に。
_MusicPlay_Step2:			;

;演奏パート数保存
	push	cx			;レジスタ保存
	mov	cl,0			;トラック番号用カウンタ
	add	bx,WTD_Mus_PartAdr	;演奏アドレス

_MusicPlay_Loop1:				;
	xor	ax,ax				;
	mov	ds:[di].WTD_FlagControl,ax	;
	mov	ds:[di].WTD_FlagTai,al		;
	mov	ds:[di].WTD_FlagSharp,al	;
	mov	ds:[di].WTD_FlagFlat,al		;
	mov	ds:[di].WTD_Channel,cl		;
	mov	ds:[di].WTD_KeyOffTime,ax	;
	mov	ds:[di].WTD_KeyOnDelay,ax	;
	mov	ds:[di].WTD_KeyShift,al		;
	mov	ds:[di].WTD_KeySetPointer,al	;
	mov	ds:[di].WTD_BendDetune,ax	;
	mov	ds:[di].WTD_BendEmbAddress,al	;
	mov	ds:[di].WTD_ExprDetune,ax	;
	mov	ds:[di].WTD_ExprEmbAddress,al	;
	mov	ds:[di].WTD_GateTimeStepLast,ax	;
	mov	ds:[di].WTD_GateTimeStepFirst,ax
	mov	ax,1				;
	mov	ds:[di].WTD_Leng,ax		;
	mov	ds:[di].WTD_LengCounter,ax	;
	mov	ax,4				;
	mov	ds:[di].WTD_Octave,al		;
	mov	ax,8				;
	mov	ds:[di].WTD_GateTime8,al	;
	mov	ax,48				;
	mov	ds:[di].WTD_LengDefault,ax	;
	mov	ax,64				;
	mov	ds:[di].WTD_Pan,al		;
	mov	ax,100				;
	mov	ds:[di].WTD_Expr,al		;
	mov	ds:[di].WTD_Velocity,al		;
	mov	ax,127				;
	mov	ds:[di].WTD_AcsentVelocity,al	;
	mov	ax,8192				;
	mov	ds:[di].WTD_Bend,ax		;
	mov	ax,0ffffh			;
	mov	ds:[di].WTD_Voice,al		;
	mov	ds:[di].WTD_LoopCountPointer,al	;
	mov	ds:[di].WTD_KeySet + 0,al	;
	mov	ds:[di].WTD_KeySet + 1,al	;
	mov	ds:[di].WTD_KeySet + 2,al	;
	mov	ds:[di].WTD_KeySet + 3,al	;
	mov	ds:[di].WTD_KeySet + 4,al	;
	mov	ds:[di].WTD_KeySet + 5,al	;
	mov	ds:[di].WTD_KeySet + 6,al	;
	mov	ds:[di].WTD_KeySet + 7,al	;
	mov	ax,es:[bx]			;
	mov	ds:[di].WTD_Address,ax		;

;
;	その他の設定
;
	add	di,WTD_WorkChSize	;構造体分、加算
	add	bx,2			;アドレスインクリメント
	inc	cl			;
	dec	ch			;
	jz	_MusicPlay_Step1	;
	jmp	_MusicPlay_Loop1	;

_MusicPlay_Step1:			;

	pop	cx			;レジスタ復帰
;---------------------------------------------------------------
;共通ワークの設定

;演奏フラグのセット
	mov	ax,ds:[si].WTD_Sys_Flag			;
	or	ax,WTD_Sys_Music			;演奏イネーブル
	mov	ds:[si].WTD_Sys_Flag,ax			;終了リセット

	mov	ds:[si].WTD_Sys_MusicPart,ch		;パート数
;
;	その他の設定
;

;タイマー（効果音、PCMは必要無し）
	mov	ax,Timer_Tempo120			;
	mov	ds:[si].WTD_Sys_Tempo,ax		;
	xor	ax,ax					;
	mov	ds:[si].WTD_Sys_TempoCounter,ax		;

;---------------------------------------------------------------

;エラー無し
	xor	ax,ax			;ax←0

_MusicPlay_End:

	popf				;
	pop	ds			;レジスタの復帰
	pop	si			;
	pop	di			;
	pop	dx			;
	pop	bx			;
	pop	bp			;bpレジスタの復帰
	retf				;終了
_MusicPlay	endp			;
;===============================================================|
;	void	(far *MusicStop)();				|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		無し						|
;	処理							|
;		演奏の終了					|
;===============================================================|
_MusicStop	proc far		;
	pusha				;
	push	ds			;
	pushf				;

	cli				;割り込み禁止

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bp,ds:[ProcContext_heap]	;ds:bp←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bp				;
	add	di,WTD_WorkAdd_Ch0		;ds:di←channel
	mov	bx,bp				;
	add	bx,WTD_WorkAdd_System		;ds:bx←System
	mov	si,bx				;ds:si←ds:bx

;---------------------------------------------------------------
;個別構造体設定

;チャンネル数
	xor	cx,cx					;
	mov	ch,MusicMaxPart				;全トラック

_MusicStop_Loop1:			;

;初期化すべき事項
	mov	dx,offset I_Table_KeyOff
	call	I_Table_Jump		;キーオフ

	mov	ax,0			;エクスプレッション = 0
	mov	dx,offset I_Table_Volume
	call	I_Table_Jump		;(エンベロープ音量。)

	mov	ax,8192			;ベンド = 8192
	mov	dx,offset I_Table_Frection
	call	I_Table_Jump		;

	mov	ax,0			;音色 = 0
	mov	dx,offset I_Table_Voice	;
	call	I_Table_Jump		;

	mov	ax,64			;パンポット = 64
	mov	cl,MIDI_Ctrl_Pan	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;

	mov	ax,100			;音量 = 100
	mov	cl,MIDI_Ctrl_Volume	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;

	mov	ax,8000h			;
	mov	ds:[di].WTD_FlagControl,ax	;演奏終了
;
;	その他
;
	add	di,WTD_WorkChSize	;構造体分、加算
	add	bx,2			;アドレスインクリメント
	inc	cl			;
	dec	ch			;
	jz	_MusicStop_Step1	;
	jmp	_MusicStop_Loop1	;

_MusicStop_Step1:			;
;---------------------------------------------------------------
;共通構造体設定

	mov	ax,ds:[si].WTD_Sys_Flag			;
	and	ax,WTD_Sys_MusicR			;演奏ディセーブル
	mov	ds:[si].WTD_Sys_Flag,ax			;終了リセット
;
;	その他
;

;タイマー（効果音、PCMは必要無し）
	mov	ax,Timer_Tempo120			;
	mov	ds:[si].WTD_Sys_Tempo,ax		;
	xor	ax,ax					;
	mov	ds:[si].WTD_Sys_TempoCounter,ax		;

;---------------------------------------------------------------

	popf				;
	pop	ds			;
	popa				;
	retf				;終了
_MusicStop	endp			;
;===============================================================|
;	char	(far *EffectPlay)(char far *Effect);		|
;===============================================================|
;	引き数							|
;		char far *Effect	効果音データのアドレス	|
;	返り値							|
;		ax			Error Code		|
;				00h	正常終了		|
;				01h	曲データじゃ無い。	|
;				02h	ヴァージョンが違う。	|
;	処理							|
;		効果音の発生					|
;===============================================================|
_EffectPlay	proc far		;
	push	bp			;bpレジスタの保存
	mov	bp,sp			;bp←sp
	push	bx			;
	push	dx			;
	push	di			;
	push	si			;
	push	ds			;レジスタ保存
	pushf				;

	cli				;割り込み禁止

;---------------------------------------------------------------
;演奏の停止

	push	cs			;
	call	near ptr _EffectStop	;演奏停止・割込周期の初期化

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bx,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_ECh0		;ds:di←channel
	mov	si,bx				;
	add	si,WTD_WorkAdd_System		;ds:si←System

;---------------------------------------------------------------
;演奏アドレスの設定
	push	word ptr [bp + 08h]	;
	push	word ptr [bp + 06h]	;引数の取得
	push	cs			;データ変換
	call	near ptr _ChangeFar	;dxax = wtdIL.ChangeFar(*Effect);
	add	sp,+4			;
	mov	ds:[si].WTD_Sys_EffectOffset,ax		;アドレスの設定
	mov	ds:[si].WTD_Sys_EffectSegment,dx	;

;ポインタの設定
	mov	es,dx			;
	mov	bx,ax			;es:bx←曲データ先頭アドレス

;---------------------------------------------------------------
;データ形式チェック

;
;	ＷＴＤの曲・効果音形式データであるかチェックする。
;

;---------------------------------------------------------------
;個別ワークの設定

;
;	その他の設定
;

;---------------------------------------------------------------
;共通ワークの設定

;演奏フラグのセット
	mov	ax,ds:[si].WTD_Sys_Flag			;
	or	ax,WTD_Sys_Effect			;演奏イネーブル
	mov	ds:[si].WTD_Sys_Flag,ax			;終了リセット

;
;	その他の設定
;

;---------------------------------------------------------------

;エラー無し
	xor	ax,ax			;ax←0

_EffectPlay_End:

	popf				;
	pop	ds			;レジスタの復帰
	pop	si			;
	pop	di			;
	pop	dx			;
	pop	bx			;
	pop	bp			;bpレジスタの復帰
	retf				;終了
_EffectPlay	endp			;
;===============================================================|
;	void	(far *EffectStop)();				|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		無し						|
;	処理							|
;		効果音の発生終了				|
;===============================================================|
_EffectStop	proc far		;
	pusha				;
	push	ds			;

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bx,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_Ch0		;ds:di←channel
	mov	si,bx				;
	add	si,WTD_WorkAdd_System		;ds:si←System

;---------------------------------------------------------------
;個別構造体設定

;
;	その他
;

;---------------------------------------------------------------
;共通構造体設定

;
;	その他
;

;---------------------------------------------------------------

	pop	ds			;
	popa				;
	retf				;終了
_EffectStop	endp			;
;===============================================================|
;	char	(far *PcmPlay)(char far *Pcm);			|
;===============================================================|
;	引き数							|
;		char far*Pcm	ファイルのあるアドレス		|
;	返り値							|
;		ax	0	正常				|
;			1	Waveデータじゃない。		|
;			   or	データ形式が違う。		|
;			2	'fmt 'が見つからない。		|
;			3	'data'が見つからない。		|
;	処理							|
;		Waveファイルの解析と、発生準備			|
;===============================================================|
_PcmPlay	proc far		;
	push	bp			;bpレジスタの保存
	mov	bp,sp			;bp←sp
	push	bx			;
	push	dx			;
	push	di			;
	push	si			;
	push	ds			;レジスタ保存
	pushf				;

	cli				;割り込み禁止

;---------------------------------------------------------------
;演奏の停止

	push	cs			;
	call	near ptr _PcmStop	;演奏停止・割込周期の初期化

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bx,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_PCM		;ds:di←channel
	mov	si,bx				;
	add	si,WTD_WorkAdd_System		;ds:si←System

;---------------------------------------------------------------
;演奏アドレスの設定
	push	word ptr [bp + 08h]	;
	push	word ptr [bp + 06h]	;引数の取得
	push	cs			;データ変換
	call	near ptr _ChangeFar	;dxax = wtdIL.ChangeFar(*Pcm);
	add	sp,+4			;
	mov	ds:[si].WTD_Sys_PcmOffset,ax	;アドレスの設定
	mov	ds:[si].WTD_Sys_PcmSegment,dx	;

;ポインタの設定
	mov	es,dx			;
	mov	bx,ax			;es:bx←RIFF構造体

;---------------------------------------------------------------
;'Wave'ファイルの解析	データ形式のチェック
;※下位16bitのみのチェック・解析・演算である。
;　上位16bitは無視している。

;FileCheck
;・RIFF形式、且つ、WAVEデータであか？
	cmp	word ptr es:[bx].RIFF_Head,'IR'		;RIFF ?
	jnz	_PcmPlay_EndJmp				;
	cmp	word ptr es:[bx].RIFF_Type,'AW'		;WAVE ?
	jnz	_PcmPlay_EndJmp				;
;次アドレス設定
	add	bx,RIFF_Data				;bx←RIFFのData部。

;Wavefmt構造体の検索
;文字列チェック
_PcmPlay_FileChkLoop:					;
	cmp	word ptr es:[bx].RiffHed_Head,'mf'	;fmt  ?
	jz	_PcmPlay_FileChkEnd			;
	mov	ax,word ptr es:[bx].RiffHed_Size	;ヘッド、サイズ分を加算
	add	bx,RiffHed_Data				;64KByte越えたら、
	jc	_PcmPlay_FileChkStep1			;エラーにする。
	add	bx,ax					;
	jnc	_PcmPlay_FileChkLoop			;
_PcmPlay_FileChkStep1:					;
	mov	ax,2					;'fmt 'が無い。
	jmp	_PcmPlay_End				;
_PcmPlay_FileChkEnd:					;

;ファイル形式チェック
;・モノラルか？
;・量子化数＝8bitか？
;サンプリングレイトは面倒だから確認しない。（遊べるし。）
	cmp	word ptr es:[bx].WaveFmt_Type,1		;Wave type ?
	jnz	_PcmPlay_EndJmp				;
	cmp	word ptr es:[bx].WaveFmt_Channel,1	;mono(1ch) ?
	jnz	_PcmPlay_EndJmp				;
	cmp	word ptr es:[bx].WaveFmt_DataSize,1	;1byte ?
	jnz	_PcmPlay_EndJmp				;
	cmp	word ptr es:[bx].WaveFmt_ChannelSize,8	;8bit ?
	jnz	_PcmPlay_EndJmp				;
	jmp	short _PcmPlay_EndJmpStep
_PcmPlay_EndJmp:
	mov	ax,1					;Error 
	jmp	_PcmPlay_End				;
_PcmPlay_EndJmpStep:
;次アドレス設定
	mov	ax,word ptr es:[bx].WaveFmt_Size	;ヘッド、サイズ分を加算
	add	bx,WaveFmt_Type				;64KByte越えたら、
	jc	_PcmPlay_EndJmp				;エラーにする。
	add	bx,ax					;
	jc	_PcmPlay_EndJmp				;

;WaveData構造体の検索
;文字列チェック
_PcmPlay_FileChkLoop2:					;
	cmp	word ptr es:[bx].RiffHed_Head,'ad'	;data ?
	jz	_PcmPlay_FileChkEnd2			;
	mov	ax,word ptr es:[bx].RiffHed_Size	;ヘッド、サイズ分を加算
	add	bx,RiffHed_Data				;64KByte越えたら、
	jc	_PcmPlay_FileChkStep2			;エラーにする。
	add	bx,ax					;
	jnc	_PcmPlay_FileChkLoop2			;
_PcmPlay_FileChkStep2:					;
	mov	ax,3					;
	jmp	_PcmPlay_End				;
_PcmPlay_FileChkEnd2:					;

;---------------------------------------------------------------
;個別ワークの設定

;構造体設定
;データサイズ
	mov	ax,word ptr es:[bx].WaveData_Size+0	;
	mov	word ptr ds:[di].WTD_PcmSize+0,ax	;
	mov	ax,word ptr es:[bx].WaveData_Size+2	;
	mov	word ptr ds:[di].WTD_PcmSize+2,ax	;
;発生アドレス
	mov	ax,WaveData_Data			;
	add	ax,bx					;
	mov	dx,es					;dx:ax←Data Address
	mov	word ptr ds:[di].WTD_PcmAddress+0,ax	;
	mov	word ptr ds:[di].WTD_PcmAddress+2,dx	;
;フラグ設定
	mov	ax,word ptr ds:[di].WTD_FlagControl	;
	or	ax,WTD_Ctrl_Effect			;
	and	ax,WTD_Ctrl_PlayEndR			;
	mov	word ptr ds:[di].WTD_FlagControl,ax	;

;
;	その他の設定
;

;---------------------------------------------------------------
;共通ワークの設定

;テンポカウンター
	mov	ax,1					;
	mov	ds:[si].WTD_Sys_TempoCounter,ax		;TempoCounter = 1

;演奏フラグのセット
	mov	ax,ds:[si].WTD_Sys_Flag			;
	or	ax,WTD_Sys_Pcm + WTD_Sys_EffectMask2	;演奏イネーブル
	and	ax,WTD_Sys_PcmEndR			;ch2 効果音マスク
	mov	ds:[si].WTD_Sys_Flag,ax			;終了リセット

;
;	その他の設定
;

;---------------------------------------------------------------
;デバイスの設定

;PCM Voice mode
	mov	ax,PcmVoiceMode_Set	;
	call	SP_Set_Channel		;PcmVoice Modeにする。

;---------------------------------------------------------------

;エラー無し
	xor	ax,ax			;ax←0

_PcmPlay_End:
	popf				;レジスタの復帰
	pop	ds			;
	pop	si			;
	pop	di			;
	pop	dx			;
	pop	bx			;
	pop	bp			;bpレジスタの復帰
	retf				;終了
_PcmPlay	endp			;
;===============================================================|
;	void	(far *PcmStop)();				|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		無し						|
;	処理							|
;		PCM Voice の発生終了準備			|
;===============================================================|
_PcmStop	proc far		;
	pusha				;
	push	ds			;

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bx,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_PCM		;ds:di←channel
	mov	si,bx				;
	add	si,WTD_WorkAdd_System		;ds:si←System

;---------------------------------------------------------------
;構造体設定

;
;	　タイマー割り込みアルゴリズムの都合上、
;	割り込み処理内で復帰処理を行う。
;

;---------------------------------------------------------------
;共通ワークの設定

;演奏フラグのセット
	mov	ax,ds:[si].WTD_Sys_Flag			;
	or	ax,WTD_Sys_PcmEnd			;ch2 効果音マスク
	mov	ds:[si].WTD_Sys_Flag,ax			;終了リセット

;
;	その他の設定
;

;---------------------------------------------------------------

	pop	ds			;
	popa				;
	retf				;終了
_PcmStop	endp			;
;===============================================================|
;	char	(far *PcmVoiceSet)(char no,char far *wave);	|
;===============================================================|
;	引き数							|
;		char	no	音色番号			|
;		char far *wave	波形データ			|
;	返り値							|
;		Error Code					|
;	処理							|
;		WS内蔵PCM波形データをドライバーに登録する。	|
;===============================================================|
_PcmVoiceSet	proc far		;
	push	bp			;bpレジスタの保存
	mov	bp,sp			;bp←sp
	push	bx			;
	push	cx			;
	push	dx			;
	push	di			;
	push	si			;
	push	ds			;
	push	es			;レジスタ保存

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	es				;ds←SRAMセグメント
	mov	bx,es:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_Wave		;es:di←Wave

;---------------------------------------------------------------
;設定

;音色番号取得
	xor	ax,ax			;
	mov	al,[bp + 06h]		;ax←音色番号
;音色番号チェック
	cmp	al,16			;16以下？
	jc	_PCMVoiceSet_Step1	;
	mov	ax,11			;でなかったら、エラー
	jmp	_PCMVoiceSet_End	;
_PCMVoiceSet_Step1:			;
;音色転送先アドレス設定
	shl	ax,4			;
	add	di,ax			;di＝di＋ax×16

;波形データアドレス取得
	lds	si,[bp + 08h]		;ds:si←送り元

;転送
	mov	cx,8			;16Byte転送
	rep	movsw			;ブロック転送

;---------------------------------------------------------------

;エラー無し
	xor	ax,ax			;ax←0

_PCMVoiceSet_End:
	pop	es			;レジスタ復帰
	pop	ds			;
	pop	si			;
	pop	di			;
	pop	dx			;
	pop	cx			;
	pop	bx			;
	pop	bp			;bpレジスタの復帰
	retf				;終了
_PcmVoiceSet	endp			;
;===============================================================|
;	char	(far *SoftEmbSet)(char no,char far *emb);	|
;===============================================================|
;	引き数							|
;		char	no	音色番号			|
;		char far *wave	エンベロープデータ		|
;	返り値							|
;		Error Code					|
;	処理							|
;		エンベロープデータをドライバーに登録する。	|
;===============================================================|
_SoftEmbSet	proc far		;
	push	bp			;bpレジスタの保存
	mov	bp,sp			;bp←sp
	push	bx			;
	push	cx			;
	push	dx			;
	push	di			;
	push	si			;
	push	ds			;
	push	es			;レジスタ保存

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	es				;ds←SRAMセグメント
	mov	bx,es:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_Emb		;ds:si←Wave

;---------------------------------------------------------------
;設定

;音色番号取得
	xor	ax,ax			;
	mov	al,[bp + 06h]		;ax←音色番号
;音色番号チェック
	cmp	al,24			;24以下？
	jc	_SoftEmbSet_Step1	;
	mov	ax,11			;でなかったら、エラー
	jmp	_SoftEmbSet_End		;
_SoftEmbSet_Step1:			;
;音色転送先アドレス設定
	shl	ax,4			;
	add	di,ax			;di＝di＋ax×16

;波形データアドレス取得
	lds	si,[bp + 08h]		;ds:si←送り元

;転送
	mov	cx,8			;16Byte転送
	rep	movsw			;ブロック転送

;---------------------------------------------------------------

;エラー無し
	xor	ax,ax			;ax←0

_SoftEmbSet_End:
	pop	es			;レジスタ復帰
	pop	ds			;
	pop	si			;
	pop	di			;
	pop	dx			;
	pop	cx			;
	pop	bx			;
	pop	bp			;bpレジスタの復帰
	retf				;終了
_SoftEmbSet	endp			;
;===============================================================|
;	void far *(far *ChangeFar)(void far *add);		|
;===============================================================|
;	引き数							|
;		void far *add	far pointer			|
;	返り値							|
;		dxax		far pointer			|
;	処理							|
;		far pointerの変換。offset=0x000?にする。	|
;===============================================================|
_ChangeFar	proc far		;
	push	bp			;bpレジスタの保存
	mov	bp,sp			;bp←sp

;---------------------------------------------------------------
;ファーポインタ変換

	mov	ax,word ptr [bp + 06h]	;ax←far pointer offset
	mov	dx,ax			;
	and	ax,000Fh		;ax←残りの16byte分
	shr	dx,4			;
	add	dx,word ptr [bp + 08h]	;dx←ax / 16 + far pointer segment

;---------------------------------------------------------------

	pop	bp			;bpレジスタの復帰
	retf				;終了
_ChangeFar	endp			;
;===============================================================|
;	void	(far *SoundSetChannel)(int mode);		|
;===============================================================|
;	引き数							|
;		mode bit 0- 7	Set Data			|
;		mode bit 8-15	Set Data bit			|
;	返り値							|
;		無し						|
;	処理							|
;		Channel modeの設定				|
;===============================================================|
_SoundSetChannel	proc far	;
	push	bp			;bpレジスタの保存
	mov	bp,sp			;bp←sp
	push	ax			;

;---------------------------------------------------------------
;設定ルーチンへ

	mov	ax,word ptr [bp + 06h]	;ax←mode
	call	SP_Set_Channel		;Chennel modeの設定

;---------------------------------------------------------------

	pop	ax			;
	pop	bp			;bpレジスタの復帰
	retf				;終了
_SoundSetChannel	endp		;
;===============================================================|
;	int	(far *SoundGetChannel)();			|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		ax		Channel mode			|
;	処理							|
;		Channel modeの取得				|
;===============================================================|
_SoundGetChannel	proc far	;
	call	SP_Get_Channel		;Channel mode の取得
	retf				;終了
_SoundGetChannel	endp		;
;===============================================================|
;	void	(far *SoundSetOutput)(int mode);		|
;===============================================================|
;	引き数							|
;		mode bit 0- 7	Set Data			|
;		mode bit 8-15	Set Data bit			|
;	返り値							|
;		無し						|
;	処理							|
;		Output modeの設定				|
;===============================================================|
_SoundSetOutput	proc far		;
	push	bp			;bpレジスタの保存
	mov	bp,sp			;bp←sp
	push	ax			;

;---------------------------------------------------------------
;設定ルーチンへ

	mov	ax,word ptr [bp + 06h]	;ax←mode
	call	SP_Set_Output		;Output modeの設定

;---------------------------------------------------------------

	pop	ax			;
	pop	bp			;bpレジスタの復帰
	retf				;終了
_SoundSetOutput	endp			;
;===============================================================|
;	int	(far *SoundGetOutput)();			|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		ax		Output mode			|
;	処理							|
;		Output modeの取得				|
;===============================================================|
_SoundGetOutput	proc far		;
	call	SP_Get_Output		;Output modeの取得
	retf				;終了
_SoundGetOutput	endp			;
;===============================================================|
;	int	(far *SoundGetRandom)();			|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		AX		疑似乱数(0～32767)		|
;	処理							|
;		疑似乱数を得る					|
;===============================================================|
_SoundGetRandom	proc far		;
	call	SP_Get_Random		;乱数の取得
	retf				;終了
_SoundGetRandom	endp			;
;===============================================================|
;	void	(far *SetMusicVolume)(char volume);		|
;===============================================================|
;	引き数							|
;		
;	返り値							|
;		
;	処理							|
;		
;===============================================================|
_SetMusicVolume	proc far		;
	push	bp			;bpレジスタの保存
	mov	bp,sp			;bp←sp
	pusha				;
	push	ds			;

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bx,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_Ch0		;ds:di←channel
	mov	si,bx				;
	add	si,WTD_WorkAdd_System		;ds:si←System

;---------------------------------------------------------------
;設定
	mov	al,byte ptr [bp + 06h]		;
	mov	ds:[si].WTD_Sys_VolumeMusic,al	;

;---------------------------------------------------------------

	pop	ds			;
	popa				;
	pop	bp			;bpレジスタの復帰
	retf				;終了
_SetMusicVolume	endp			;
;===============================================================|
;	char	(far *GetMusicVoluem)();			|
;===============================================================|
;	引き数							|
;		
;	返り値							|
;		
;	処理							|
;		
;===============================================================|
_GetMusicVolume	proc far		;
	push	bx			;
	push	di			;
	push	si			;
	push	ds			;

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bx,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_Ch0		;ds:di←channel
	mov	si,bx				;
	add	si,WTD_WorkAdd_System		;ds:si←System

;---------------------------------------------------------------
;取得
	xor	ax,ax				;ax←0
	mov	al,ds:[si].WTD_Sys_VolumeMusic	;

;---------------------------------------------------------------

	pop	ds			;
	pop	si			;
	pop	di			;
	pop	bx			;
	retf				;終了
_GetMusicVolume	endp			;
;===============================================================|
;	void	(far *SetEffectVolume)(char volume);		|
;===============================================================|
;	引き数							|
;		
;	返り値							|
;		
;	処理							|
;		
;===============================================================|
_SetEffectVolume	proc far	;
	push	bp			;bpレジスタの保存
	mov	bp,sp			;bp←sp
	pusha				;
	push	ds			;

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bx,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_Ch0		;ds:di←channel
	mov	si,bx				;
	add	si,WTD_WorkAdd_System		;ds:si←System

;---------------------------------------------------------------
;設定
	mov	al,byte ptr [bp + 06h]		;
	mov	ds:[si].WTD_Sys_VolumeEffect,al	;

;---------------------------------------------------------------

	pop	ds			;
	popa				;
	pop	bp			;bpレジスタの復帰
	retf				;終了
_SetEffectVolume	endp		;
;===============================================================|
;	char	(far *GetEffectVolume)();			|
;===============================================================|
;	引き数							|
;		
;	返り値							|
;		
;	処理							|
;		
;===============================================================|
_GetEffectVolume	proc far	;
	push	bx			;
	push	di			;
	push	si			;
	push	ds			;

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bx,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_Ch0		;ds:di←channel
	mov	si,bx				;
	add	si,WTD_WorkAdd_System		;ds:si←System

;---------------------------------------------------------------
;取得
	xor	ax,ax				;ax←0
	mov	al,ds:[si].WTD_Sys_VolumeEffect	;

;---------------------------------------------------------------

	pop	ds			;
	pop	si			;
	pop	di			;
	pop	bx			;
	retf				;終了
_GetEffectVolume	endp		;
;===============================================================|
;	void	(far *SetPcmVolume)(char volume);		|
;===============================================================|
;	引き数							|
;		bit0,1	右の音量	bit2,3	左の音量	|
;	返り値							|
;		無し						|
;	処理							|
;		PCM Voice の音量を設定する。			|
;===============================================================|
_SetPcmVolume	proc far		;
	push	bp			;bpレジスタの保存
	mov	bp,sp			;bp←sp
	pusha				;
	push	ds			;

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bx,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_Ch0		;ds:di←channel
	mov	si,bx				;
	add	si,WTD_WorkAdd_System		;ds:si←System

;---------------------------------------------------------------
;設定
	mov	al,byte ptr [bp + 06h]		;
	mov	ds:[si].WTD_Sys_VolumePcm,al	;al←Set Data
	mov	ah,0fh				;ah←Set Bit
	call	SP_Set_VolumePCM		;

;---------------------------------------------------------------

	pop	ds			;
	popa				;
	pop	bp			;bpレジスタの復帰
	retf				;終了
_SetPcmVolume	endp			;
;===============================================================|
;	char	(far *GetPcmVolume)();				|
;===============================================================|
;	引き数							|
;		
;	返り値							|
;		
;	処理							|
;		
;===============================================================|
_GetPcmVolume	proc far		;
	push	bx			;
	push	di			;
	push	si			;
	push	ds			;

;---------------------------------------------------------------
;ワークアドレスの取得

;ワークアドレスの取得
	push	SRAM_Segment			;
	pop	ds				;ds←SRAMセグメント
	mov	bx,ds:[ProcContext_heap]	;ds:bx←ワークエリアアドレス

;構造体アドレスの設定
	mov	di,bx				;
	add	di,WTD_WorkAdd_Ch0		;ds:di←channel
	mov	si,bx				;
	add	si,WTD_WorkAdd_System		;ds:si←System

;---------------------------------------------------------------
;取得
	xor	ax,ax				;ax←0
	mov	al,ds:[si].WTD_Sys_VolumePcm	;

;---------------------------------------------------------------

	pop	ds			;
	pop	si			;
	pop	di			;
	pop	bx			;
	retf				;終了
_GetPcmVolume	endp			;
