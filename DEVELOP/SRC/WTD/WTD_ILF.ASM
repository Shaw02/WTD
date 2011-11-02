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
IL:							;IL構造体先頭
IL_Link_Pos	dw	0				;未使用
		dw	0				;
IL_N_Methods	dw	((offset IL_F_End)-(offset IL_GetInfo))/4	;ファンクション数
IL_GetInfo	dw	offset CGROUP:_GetInfo		;ILinfo構造体を得る
		dw	0				;far *TEST_GetInfo();
IL_F00		dw	offset CGROUP:_Stay		;
		dw	0				;
IL_F01		dw	offset CGROUP:_StayOut		;
		dw	0				;
IL_F02		dw	offset CGROUP:_Init		;
		dw	0				;
IL_F03		dw	offset CGROUP:_MusicPlay	;
		dw	0				;
IL_F04		dw	offset CGROUP:_MusicStop	;
		dw	0				;
IL_F05		dw	offset CGROUP:_EffectPlay	;
		dw	0				;
IL_F06		dw	offset CGROUP:_EffectStop	;
		dw	0				;
IL_F07		dw	offset CGROUP:_PcmPlay		;
		dw	0				;
IL_F08		dw	offset CGROUP:_PcmStop		;
		dw	0				;
IL_F09		dw	offset CGROUP:_PcmVoiceSet	;
		dw	0				;
IL_F10		dw	offset CGROUP:_SoftEmbSet	;
		dw	0				;
IL_F11		dw	offset CGROUP:_ChangeFar	;
		dw	0				;
IL_F12		dw	offset CGROUP:_SoundSetChannel	;
		dw	0				;
IL_F13		dw	offset CGROUP:_SoundGetChannel	;
		dw	0				;
IL_F14		dw	offset CGROUP:_SoundSetOutput	;
		dw	0				;
IL_F15		dw	offset CGROUP:_SoundGetOutput	;
		dw	0				;
IL_F16		dw	offset CGROUP:_SoundGetRandom	;
		dw	0				;
IL_F17		dw	offset CGROUP:_SetMusicVolume	;
		dw	0				;
IL_F18		dw	offset CGROUP:_GetMusicVolume	;
		dw	0				;
IL_F19		dw	offset CGROUP:_SetEffectVolume	;
		dw	0				;
IL_F20		dw	offset CGROUP:_GetEffectVolume	;
		dw	0				;
IL_F21		dw	offset CGROUP:_SetPcmVolume	;
		dw	0				;
IL_F22		dw	offset CGROUP:_GetPcmVolume	;
		dw	0				;
IL_F23		dw	offset CGROUP:_SetFIFO		;
		dw	0				;
IL_F_End:
;===============================================================|
;		ILinfo構造体定義（全てポインタ）		|
;===============================================================|
ILinfo:							;ILinfo構造体先頭
ILinfo_ClassName	dw	offset CGROUP:ILinfoD_ClassName	;未使用
			dw	0				;
ILinfo_Name		dw	offset CGROUP:ILinfoD_Name	;名前
			dw	0				;
ILinfo_Version		dw	offset CGROUP:ILinfoD_Version	;バージョン
			dw	0				;
ILinfo_Description	dw	offset CGROUP:ILinfoD_Description
			dw	0				;
ILinfo_Depends		dw	offset CGROUP:ILinfoD_Depends	;未使用
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
;*		IL構造体の設定					*
;*								*
;****************************************************************
;===============================================================|
;		void	WTD_FucntionLoad()			|
;===============================================================|
;	引き数							|
;		WtdIL	Wtd_Function	/*構造体のポインタを*/	|
;	返り値							|
;		無し						|
;	処理							|
;		・WtdIL構造体の設定				|
;		　WtdIL構造体は、ライブラリを呼ぶ側が用意する。	|
;===============================================================|
ifdef	library				;※　ライブラリ版のみ必要

	public	WTD_FunctionLoad	;外部宣言

WTD_FunctionLoad	proc	near c	uses ax cx si di ds es,
	Wtd_Function:word

	push	ds			;
	pop	es			;es←DGROUP
	mov	di,Wtd_Function		;di←Wtd_Functionのポインタ

	push	cs			;
	pop	ds			;ds←CGROUP
	mov	si,offset CGROUP:IL	;di←IL構造体用のデータ

	cld				;インクリメントモード
	mov	cx,3			;
	rep	movsw			;IL_Link_Pos, IL_Link_Methodの転送

	mov	cx,word ptr CS:[IL_N_Methods]	;構造体のサイズ計算
	mov	ax,cs			;
	.repeat
		movsw			;
		stosw			;
		add	si,2		;
	.untilcxz

	ret				;
WTD_FunctionLoad	endp		;
endif
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
;		dx,ax←ILinfo構造体のポインタ			|
;	処理							|
;		ILinfoポインタの取得				|
;===============================================================|
_GetInfo	proc far c		;
	push	cs			;
	pop	dx			;LSI-C86
	mov	ax,offset CGROUP:ILinfo	;dx:ax←far pointer
	ret				;
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
_Stay		proc far c	uses bx cx dx si di ds es	;

	pushf				;レジスタ保存

	cli				;割り込み禁止

;---------------------------------------------------------------
;ワークエリアアドレスの取得

;ワークエリアの取得
	WTD_WorkGet	ds,bx		;ワークエリアアドレス

;エラーチェック
	cmp	bx,0f000h		;/* S-RAMは4096byte以上ある？ */
	jc	_Stay_00		;if (bx>0xF000) then ax=1:Retuen
	mov	ax,0001h		;/* 本体RAM容量が足りない。 */
	jmp	_Stay_End		;
_Stay_00:


;ワーク全体の初期化(00hで埋める)
;メモリ書き込み
	cld				;インクリメントモード
	push	ds
	pop	es
	lea	di,[bx]			;es:di←ワークファーアドレス
	mov	cx,WTD_WorkSize		;ワークのサイズ分(1000h)
	xor	ax,ax			;ax←0
	rep	stosb			;書き込み

;構造体アドレスの設定
	lea	si,[bx + WTD_WorkAdd_System]	;ds:si←System

;---------------------------------------------------------------
;共通ワークの初期化

;レジスタの設定　構造体のベースポインタの設定。
	push	IRAM_Segment		;
	pop	es			;es←本体RAMセグメント

;IntVectorの設定
	push	bx					;

	mov	ax,0					;
	call	IntVector_Get				;al←割り込みベクタ
	mov	ds:[si].WTD_Sys_InterruptBase,al	;保存
	shl	ax,2			;読み込んだ値を4倍
	mov	bx,ax			;割り込みベクタのアドレス

	mov	ax,es:[bx+SYS_INT_HBLANK_COUNTUP*4+0]	;タイマー
	mov	ds:[si].WTD_Sys_OldIntvector+0,ax	;割り込み
	mov	ax,es:[bx+SYS_INT_HBLANK_COUNTUP*4+2]	;
	mov	ds:[si].WTD_Sys_OldIntvector+2,ax	;復帰用に保存

	mov	es:[bx+SYS_INT_HBLANK_COUNTUP*4+0],offset CGROUP:I_Start
	mov	es:[bx+SYS_INT_HBLANK_COUNTUP*4+2],cs	;アドレスの設定

ifndef	hyoka	;------------------------廉価版は無し
	mov	ax,es:[bx+SYS_INT_SENDREADY*4+0]	;シリアルエンプティー
	mov	ds:[si].WTD_Sys_OldIntvectorCom+0,ax	;割り込み
	mov	ax,es:[bx+SYS_INT_SENDREADY*4+2]	;
	mov	ds:[si].WTD_Sys_OldIntvectorCom+2,ax	;復帰用に保存

	mov	es:[bx+SYS_INT_SENDREADY*4+0],offset CGROUP:IC_Start
	mov	es:[bx+SYS_INT_SENDREADY*4+2],cs	;アドレスの設定
endif	;--------------------------------
	pop	bx					;

;タイマー
	mov	ax,Timer_Tempo120			;
	mov	ds:[si].WTD_Sys_Tempo,ax		;
	xor	ax,ax					;
	mov	ds:[si].WTD_Sys_TempoCounter,ax		;

;音色テーブル
	mov	ax,IRAM_SoundVoiceTable			;
	mov	ds:[si].WTD_Sys_VoiceTableOffset,ax	;

;ソフト音量
	mov	ax,0ffffh				;音量設定
	mov	ds:[si].WTD_Sys_VolumeMusic,al		;
	mov	ds:[si].WTD_Sys_VolumeEffect,al		;
	mov	al,0fh					;
	mov	ds:[si].WTD_Sys_VolumePcm,al		;

;	mov	ax,bx					;
;	add	ax,WTD_WorkSize				;
	lea	ax,[bx + WTD_WorkSize]			;FIFOバッファの設定
	push	ds					;ワークエリアの次
	push	ax					;
	push	4096					;4096[Byte]確保
	push	cs					;
	call	near ptr _SetFIFO			;
	add	sp,+6					;

;
;	その他、ワーク内容の初期化をする。
;

;---------------------------------------------------------------
;デバイスの初期化

ifndef	hyoka	;------------------------廉価版は無し
	call	C_open			;通信回線の初期化
endif	;--------------------------------

	push	cs			;
	call	near ptr _Init		;ドライバーの初期化
	call	T_open			;タイマーの初期化

;---------------------------------------------------------------

;正常終了
	xor	ax,ax			;正常終了(ax=0000h)

_Stay_End:

	popf				;レジスタ復帰

	ret				;終了
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
_StayOut	proc far c	uses bx di si ds es
	pushf				;

	cli				;割り込み禁止

;---------------------------------------------------------------
;デバイスの初期化

	call	T_close			;タイマー割り込みの停止、復帰
	push	cs			;
	call	near ptr _Init		;ドライバーの初期化

ifndef	hyoka	;------------------------廉価版は無し
	call	C_close			;通信回線の遮断
endif	;--------------------------------

;---------------------------------------------------------------
;ワークエリアの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得

	;構造体アドレスの設定
	lea	si,[bx + WTD_WorkAdd_System]

;---------------------------------------------------------------
;割り込み設定の復帰

;レジスタの設定　構造体のベースポインタの設定。
	push	IRAM_Segment		;
	pop	es			;es←本体RAMセグメント

;IntVectorの復帰
	push	bx					;

	xor	bx,bx					;
	mov	bl,ds:[si].WTD_Sys_InterruptBase	;bx←割り込みベクタ
	shl	bx,2					;読み込んだ値を4倍(割り込みベクタのアドレス)
;	mov	bx,ax					;

	mov	ax,ds:[si].WTD_Sys_OldIntvector+0	;
	mov	es:[bx+SYS_INT_HBLANK_COUNTUP*4+0],ax	;
	mov	ax,ds:[si].WTD_Sys_OldIntvector+2	;
	mov	es:[bx+SYS_INT_HBLANK_COUNTUP*4+2],ax	;

ifndef	hyoka	;------------------------廉価版は無し
	mov	ax,ds:[si].WTD_Sys_OldIntvectorCom+0	;
	mov	es:[bx+SYS_INT_SENDREADY*4+0],ax	;
	mov	ax,ds:[si].WTD_Sys_OldIntvectorCom+2	;
	mov	es:[bx+SYS_INT_SENDREADY*4+2],ax	;
endif	;--------------------------------
	pop	bx					;

;
;	その他、設定の復帰を行う。
;
;---------------------------------------------------------------
;正常終了

	xor	ax,ax			;正常終了(ax=0000h)
;	jmp	_StayOut_End		;

;---------------------------------------------------------------
_StayOut_End:

	popf				;
	ret				;終了
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
_Init	proc far c	uses bp ax si ds

;---------------------------------------------------------------
;ワークエリアの取得

	WTD_WorkGet	ds,bp			;ワークエリアアドレスの取得

	;構造体アドレスの設定
	lea	si,[bp + WTD_WorkAdd_System]


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

ifndef	hyoka	;------------------------廉価版は無し
	call	SM_init			;GM Resetの送信

	;FIFO送信まで待つ。		;
	.repeat
		call	IC_Send			;送信
		mov	ax,ds:[si].WTD_Sys_ComFIFO_Cnt
	.until	(ax==ds:[si].WTD_Sys_ComFIFO_Adr)
endif	;--------------------------------

;---------------------------------------------------------------
	ret				;終了
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
_MusicPlay	proc far c	uses bx cx dx di si ds es,
	fptMusic:far ptr byte

;---------------------------------------------------------------
;演奏の停止

	push	cs			;
	call	near ptr _MusicStop	;演奏停止・割込周期の初期化

;---------------------------------------------------------------
;割り込み禁止

	in	al,Int_Enable		;
	and	al,Int_HblankReset	;
	out	Int_Enable,al		;

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得

;構造体アドレスの設定
	lea	di,[bx + WTD_WorkAdd_Ch0]
	lea	si,[bx + WTD_WorkAdd_System]

;---------------------------------------------------------------
;演奏アドレスの設定

	les	ax,fptMusic
	push	es
	push	ax
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
	.if	(word ptr es:[bx].WTD_Mus_Name!='TW')	;'WTD',0
		mov	ax,1				;
		jmp	_MusicPlay_End			;
	.endif

	;バージョンチェック
	mov	ax,es:[bx].WTD_Mus_Version	;
	xchg	ah,al				;ax←Music Data Version
	.if	(ax>WTdIL_Version_N)
		mov	ax,2			;
		jmp	_MusicPlay_End		;
	.endif
_MusicPlay_Chk2:


;---------------------------------------------------------------
;データ登録

	;初期設定
	mov	ch,es:[bx].WTD_Mus_Voice	;数の取得 Voice
	mov	cl,es:[bx].WTD_Mus_Emb		;数の取得 Emb
	push	bx				;
	mov	bx,es:[bx].WTD_Mus_DataAdr	;

	;WS内蔵PCM波形データの登録
	.while	(ch!=0)
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
	.endw

	;エンベロープデータの登録
	.while	(cl!=0)
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
	.endw

	pop	bx				;レジスタ復帰

;---------------------------------------------------------------
;個別ワークの設定

;チャンネル数の取得
	mov	ch,es:[bx].WTD_Mus_Part	;チャンネル数の取得
	.if	(ch>MusicMaxPart)	;パート数チェック
		mov	ch,MusicMaxPart		;最大値を越えてたら最大値に。
	.endif

;演奏パート数保存
	push	cx			;レジスタ保存
	mov	cl,0			;トラック番号用カウンタ
	add	bx,WTD_Mus_PartAdr	;演奏アドレス

;ワーク全体の初期化(00hで埋める)
;メモリ書き込み
	cld				;インクリメントモード
	push	di			;es:di←ワークファーアドレス
	push	cx			;
	push	es			;
;	mov	ax,ds			;
;	mov	es,ax			;
	push	ds
	pop	es
	mov	al,WTD_WorkChSize / 2	;Wordなので、2で割る。
	mul	ch			;
	mov	cx,ax			;パート個別構造体(080h * 20 / 2)
	xor	ax,ax			;ax←0
	rep	stosw			;書き込み
	pop	es			;
	pop	cx			;
	pop	di			;

	.repeat
;	xor	ax,ax				;Stosbによる初期化
;	mov	ds:[di].WTD_FlagControl,ax	;
;	mov	ds:[di].WTD_FlagTai,al		;
;	mov	ds:[di].WTD_FlagSharp,al	;
;	mov	ds:[di].WTD_FlagFlat,al		;
;	mov	ds:[di].WTD_Channel,cl		;
;	mov	ds:[di].WTD_KeyOffTime,ax	;
;	mov	ds:[di].WTD_KeyOnDelay,ax	;
;	mov	ds:[di].WTD_KeyShift,al		;
;	mov	ds:[di].WTD_KeySetPointer,al	;
;	mov	ds:[di].WTD_ModDecay,ax		;
;	mov	ds:[di].WTD_ModLevel,al		;
;	mov	ds:[di].WTD_BendDetune,ax	;
;	mov	ds:[di].WTD_BendEmbRate,al	;
;	mov	ds:[di].WTD_BendEmbMaxMin,al	;
;	mov	ds:[di].WTD_BendEmbLevelSet,al	;
;	mov	ds:[di].WTD_ExprDetune,ax	;
;	mov	ds:[di].WTD_ExprEmbRate,al	;
;	mov	ds:[di].WTD_ExprEmbMaxMin,al	;
;	mov	ds:[di].WTD_ExprEmbLevelSet,al	;
;	mov	ds:[di].WTD_PanDetune,ax	;
;	mov	ds:[di].WTD_PanEmbRate,al	;
;	mov	ds:[di].WTD_PanEmbMaxMin,al	;
;	mov	ds:[di].WTD_PanEmbLevelSet,al	;
;	mov	ds:[di].WTD_GateTimeStepLast,ax	;
;	mov	ds:[di].WTD_GateTimeStepFirst,ax
;	mov	ds:[di].WTD_Expr,al		;
;	mov	ds:[di].WTD_ExprSet,al		;初期値0にしておくこと。
	mov	ax,1				;
	mov	ds:[di].WTD_BendEmbCounter,al	;
	mov	ds:[di].WTD_ExprEmbCounter,al	;
	mov	ds:[di].WTD_PanEmbCounter,al	;
	mov	ds:[di].WTD_Leng,ax		;
	mov	ds:[di].WTD_LengCounter,ax	;
	mov	ds:[di].WTD_VolumeUpDown,al	;
	mov	ax,04h				;
	mov	ds:[di].WTD_Octave,al		;
	mov	ax,08h				;
	mov	ds:[di].WTD_GateTime8,al	;
	mov	ax,0ch				;
	mov	ds:[di].WTD_BendEmbAddress,al	;
	mov	ds:[di].WTD_ExprEmbAddress,al	;
	mov	ds:[di].WTD_PanEmbAddress,al	;
	mov	ax,48				;
	mov	ds:[di].WTD_LengDefault,ax	;
	mov	ax,64				;
	mov	ds:[di].WTD_Pan,al		;
	mov	ax,100				;
	mov	ds:[di].WTD_Velocity,al		;ExprPanと同一
	mov	ax,127				;
	mov	ds:[di].WTD_AcsentVelocity,al	;
	mov	ax,8192				;
	mov	ds:[di].WTD_Bend,ax		;
	mov	ax,0ffffh			;
	mov	ds:[di].WTD_Program,al		;
	mov	ds:[di].WTD_Program2nd,al	;
	mov	ds:[di].WTD_Program3rd,al	;
	mov	ds:[di].WTD_LoopCountPointer,al	;
	mov	ds:[di].WTD_Key,al		;
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

;	その他の設定
	add	di,WTD_WorkChSize	;構造体分、加算
	add	bx,2			;アドレスインクリメント
	inc	cl			;
	dec	ch			;
	.until	(zero?)

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

	in	al,Int_Enable		;
	or	al,Int_HblankSet	;
	out	Int_Enable,al		;

	ret				;終了
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
_MusicStop	proc far c	uses bp ax cx dx di si ds

	in	al,Int_Enable		;
	and	al,Int_HblankReset	;
	out	Int_Enable,al		;

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bp			;ワークエリアアドレスの取得

;構造体アドレスの設定
	lea	di,[bp + WTD_WorkAdd_Ch0]
	lea	si,[bp + WTD_WorkAdd_System]

;---------------------------------------------------------------
;個別構造体設定

;チャンネル数
	xor	cx,cx					;
	mov	ch,ds:[si].WTD_Sys_MusicPart		;使用トラック数
	.while	(ch!=0)
		mov	cl,ds:[di].WTD_Channel		;

		;初期化すべき事項
		mov	ax,003Fh		;演奏終了
		or	ds:[di].WTD_FlagControl,ax

		mov	dx,offset CGROUP:I_Table_KeyOff
		call	I_Table_Jump		;キーオフ

		mov	ax,0			;エクスプレッション = 0
		mov	dx,offset CGROUP:I_Table_Volume
		call	I_Table_Jump		;(エンベロープ音量。)

		mov	ax,8192			;ベンド = 8192
		mov	dx,offset CGROUP:I_Table_Frection
		call	I_Table_Jump		;

		mov	ax,0			;音色 = 0
		mov	dx,offset CGROUP:I_Table_Voice
		call	I_Table_Jump		;

ifndef	hyoka	;------------------------廉価版は無し
		mov	ax,64			;パンポット = 64
		mov	cl,MIDI_Ctrl_Pan	;
		mov	dx,offset CGROUP:I_Table_CtrlChgB
		call	I_Table_Jump		;
endif	;--------------------------------

ifndef	hyoka	;------------------------廉価版は無し
		mov	ax,100			;音量 = 100
		mov	cl,MIDI_Ctrl_Volume	;
		mov	dx,offset CGROUP:I_Table_CtrlChgB
		call	I_Table_Jump		;
endif	;--------------------------------

		mov	ax,0			;モード　初期化
		mov	dx,offset CGROUP:I_Table_Mode
		call	I_Table_Jump		;

		mov	ax,8000h		;演奏終了
		or	ds:[di].WTD_FlagControl,ax

;		その他
;		to do	あれば

		add	di,WTD_WorkChSize	;構造体分、加算
		dec	ch			;
	.endw

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

	in	al,Int_Enable		;
	or	al,Int_HblankSet	;
	out	Int_Enable,al		;

	ret				;終了
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
_EffectPlay	proc far c	uses bx cx dx di si ds es,
	fptEffect:far ptr byte

;---------------------------------------------------------------
;演奏の停止

	push	cs			;
	call	near ptr _EffectStop	;演奏停止・割込周期の初期化

;---------------------------------------------------------------
;割り込み禁止

	in	al,Int_Enable		;
	and	al,Int_HblankReset	;
	out	Int_Enable,al		;

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得

;構造体アドレスの設定
	lea	di,[bx + WTD_WorkAdd_ECh0]
	lea	si,[bx + WTD_WorkAdd_System]

;---------------------------------------------------------------
;演奏アドレスの設定

	les	ax,fptEffect
	push	es
	push	ax
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

	;ヘッダー文字列チェック
	.if	(word ptr es:[bx].WTD_Mus_Name!='TW')	;'WTD',0
		mov	ax,1					;
		jmp	_EffectPlay_End				;
	.endif

	;バージョンチェック
	mov	ax,es:[bx].WTD_Mus_Version	;
	xchg	ah,al				;ax←Effect Data Version
	.if	(ax>WTdIL_Version_N)
		mov	ax,2			;
		jmp	_EffectPlay_End		;
	.endif


;---------------------------------------------------------------
;データ登録

	;初期設定
	mov	ch,es:[bx].WTD_Mus_Voice	;数の取得 Voice
	mov	cl,es:[bx].WTD_Mus_Emb		;数の取得 Emb
	push	bx				;
	mov	bx,es:[bx].WTD_Mus_DataAdr	;

	;WS内蔵PCM波形データの登録
	.while	(ch!=0)
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
	.endw

	;エンベロープデータの登録
	.while	(cl!=0)
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
	.endw

	pop	bx				;レジスタ復帰

;---------------------------------------------------------------
;個別ワークの設定

;チャンネル数の取得
	mov	ch,es:[bx].WTD_Mus_Part	;チャンネル数の取得
	cmp	ch,EffectMaxPart	;パート数チェック
	jc	_EffectPlay_Step2	;
	mov	ch,EffectMaxPart	;最大値を越えてたら最大値に。
_EffectPlay_Step2:			;

;演奏パート数保存
	push	cx			;レジスタ保存
	mov	cl,0			;トラック番号用カウンタ
	add	bx,WTD_Mus_PartAdr	;演奏アドレス

;ワーク全体の初期化(00hで埋める)
;メモリ書き込み
	cld				;インクリメントモード
	push	di			;es:di←ワークファーアドレス
	push	cx			;
	push	es			;
;	mov	ax,ds			;
;	mov	es,ax			;
	push	ds
	pop	es
	mov	al,WTD_WorkChSize / 2	;Wordなので、2で割る。
	mul	ch			;
	mov	cx,ax			;パート個別構造体(080h * 20 / 2)
	xor	ax,ax			;ax←0
	rep	stosw			;書き込み
	pop	es			;
	pop	cx			;
	pop	di			;

	.repeat
	mov	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
;	xor	ax,ax				;Stosbによる初期化
;	mov	ds:[di].WTD_FlagControl,ax	;
;	mov	ds:[di].WTD_FlagTai,al		;
;	mov	ds:[di].WTD_FlagSharp,al	;
;	mov	ds:[di].WTD_FlagFlat,al		;
;	mov	ds:[di].WTD_Channel,cl		;
;	mov	ds:[di].WTD_KeyOffTime,ax	;
;	mov	ds:[di].WTD_KeyOnDelay,ax	;
;	mov	ds:[di].WTD_KeyShift,al		;
;	mov	ds:[di].WTD_KeySetPointer,al	;
;	mov	ds:[di].WTD_ModDecay,ax		;
;	mov	ds:[di].WTD_ModLevel,al		;
;	mov	ds:[di].WTD_BendDetune,ax	;
;	mov	ds:[di].WTD_BendEmbRate,al	;
;	mov	ds:[di].WTD_BendEmbMaxMin,al	;
;	mov	ds:[di].WTD_BendEmbLevelSet,al	;
;	mov	ds:[di].WTD_ExprDetune,ax	;
;	mov	ds:[di].WTD_ExprEmbRate,al	;
;	mov	ds:[di].WTD_ExprEmbMaxMin,al	;
;	mov	ds:[di].WTD_ExprEmbLevelSet,al	;
;	mov	ds:[di].WTD_PanDetune,ax	;
;	mov	ds:[di].WTD_PanEmbRate,al	;
;	mov	ds:[di].WTD_PanEmbMaxMin,al	;
;	mov	ds:[di].WTD_PanEmbLevelSet,al	;
;	mov	ds:[di].WTD_GateTimeStepLast,ax	;
;	mov	ds:[di].WTD_GateTimeStepFirst,ax
;	mov	ds:[di].WTD_Expr,al		;
;	mov	ds:[di].WTD_ExprSet,al		;初期値0にしておくこと。
	mov	ax,1				;
	mov	ds:[di].WTD_BendEmbCounter,al	;
	mov	ds:[di].WTD_ExprEmbCounter,al	;
	mov	ds:[di].WTD_PanEmbCounter,al	;
	mov	ds:[di].WTD_Leng,ax		;
	mov	ds:[di].WTD_LengCounter,ax	;
	mov	ds:[di].WTD_VolumeUpDown,al	;
	mov	ax,04h				;
	mov	ds:[di].WTD_Octave,al		;
	mov	ax,08h				;
	mov	ds:[di].WTD_GateTime8,al	;
	mov	ax,0ch				;
	mov	ds:[di].WTD_BendEmbAddress,al	;
	mov	ds:[di].WTD_ExprEmbAddress,al	;
	mov	ds:[di].WTD_PanEmbAddress,al	;
	mov	ax,48				;
	mov	ds:[di].WTD_LengDefault,ax	;
	mov	ax,64				;
	mov	ds:[di].WTD_Pan,al		;
	mov	ax,100				;
	mov	ds:[di].WTD_Velocity,al		;ExprPanと同一
	mov	ax,127				;
	mov	ds:[di].WTD_AcsentVelocity,al	;
	mov	ax,8192				;
	mov	ds:[di].WTD_Bend,ax		;
	mov	ax,0ffffh			;
	mov	ds:[di].WTD_Program,al		;
	mov	ds:[di].WTD_Program2nd,al	;
	mov	ds:[di].WTD_Program3rd,al	;
	mov	ds:[di].WTD_LoopCountPointer,al	;
	mov	ds:[di].WTD_Key,al		;
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

;	その他の設定
	add	di,WTD_WorkChSize	;構造体分、加算
	add	bx,2			;アドレスインクリメント
	inc	cl			;
	dec	ch			;
	.until	(zero?)

	pop	cx			;レジスタ復帰
;---------------------------------------------------------------
;共通ワークの設定

;演奏フラグのセット
	mov	ax,ds:[si].WTD_Sys_Flag			;
	or	ax,WTD_Sys_Effect			;演奏イネーブル
	mov	ds:[si].WTD_Sys_Flag,ax			;終了リセット

	mov	ds:[si].WTD_Sys_EffectPart,ch		;パート数
;
;	その他の設定
;

;	現在は、特に無し

;---------------------------------------------------------------

;エラー無し
	xor	ax,ax			;ax←0

_EffectPlay_End:

	in	al,Int_Enable		;
	or	al,Int_HblankSet	;
	out	Int_Enable,al		;

	ret				;終了
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
_EffectStop	proc far c	uses bp ax bx cx dx di ds es

	in	al,Int_Enable		;
	and	al,Int_HblankReset	;
	out	Int_Enable,al		;

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bp			;ワークエリアアドレスの取得

;構造体アドレスの設定
	lea	bx,[bp + WTD_WorkAdd_System]

	lea	di,[bp + WTD_WorkAdd_Ech0]
;	mov	es,ds:[bx].WTD_Sys_MusicSegment	;es←効果音データセグメント

;---------------------------------------------------------------
;個別構造体設定

;チャンネル数
	xor	cx,cx					;
	mov	ch,ds:[bx].WTD_Sys_EffectPart		;使用トラック数
	.while	(ch!=0)
		mov	cl,ds:[di].WTD_Channel			;

		;初期化すべき事項
		mov	ax,003Fh			;
		or	ds:[di].WTD_FlagControl,ax	;演奏終了

		mov	dx,offset CGROUP:I_Table_KeyOff	;
		call	I_Table_Jump			;キーオフ

		mov	ax,0			;エクスプレッション = 0
		mov	dx,offset CGROUP:I_Table_Volume
		call	I_Table_Jump		;(エンベロープ音量。)

		push	cx				;
		mov	ch, cl				;
		call	I_Effect_Return			;効果音復帰処理
		pop	cx				;

		or	ds:[di].WTD_FlagControl,WTD_Ctrl_PlayEnd
	;	mov	ax,8000h			;
	;	or	ds:[di].WTD_FlagControl,ax	;演奏終了

;		その他
;		to do	あれば

		add	di,WTD_WorkChSize		;構造体分、加算
		dec	ch				;
	.endw

;---------------------------------------------------------------
;共通構造体設定

	mov	ax,ds:[bx].WTD_Sys_Flag		;
	and	ax,WTD_Sys_EffectR		;演奏ディセーブル
	mov	ds:[bx].WTD_Sys_Flag,ax		;終了リセット
;
;	その他
;

;	現在は、処理無し。

;---------------------------------------------------------------

	in	al,Int_Enable		;
	or	al,Int_HblankSet	;
	out	Int_Enable,al		;

	ret				;終了
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
_PcmPlay	proc far c	uses bx cx dx di si ds es,
	fptPCM:far ptr byte

;---------------------------------------------------------------
;演奏の停止

	push	cs			;
	call	near ptr _PcmStop	;演奏停止・割込周期の初期化

;---------------------------------------------------------------
;割り込み禁止

	in	al,Int_Enable		;
	and	al,Int_HblankReset	;
	out	Int_Enable,al		;

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得

;構造体アドレスの設定
	lea	di,[bx + WTD_WorkAdd_PCM]
	lea	si,[bx + WTD_WorkAdd_System]

;---------------------------------------------------------------
;演奏アドレスの設定

	les	ax,fptPCM
	push	es
	push	ax
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
;	mov	ax,WaveData_Data			;
;	add	ax,bx					;
	lea	ax,[bx + WaveData_Data]			;
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
	;PCMVoice効果音On, Musicch2Mask, Timer Emulate on
	or	ax,WTD_Sys_Pcm + WTD_Sys_EffectMask2 + WTD_Sys_TimerEmulate
;	and	ax,WTD_Sys_PcmEndR			;このフラグは廃止
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
	in	al,Int_Enable		;
	or	al,Int_HblankSet	;
	out	Int_Enable,al		;

	ret				;終了
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
_PcmStop	proc far c	uses bp ax bx cx dx di si ds

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得

;構造体アドレスの設定
	lea	di,[bx + WTD_WorkAdd_PCM]
	lea	si,[bx + WTD_WorkAdd_System]

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
	and	ax,WTD_Sys_PcmR				;終了
	mov	ds:[si].WTD_Sys_Flag,ax			;終了リセット

;	タイマーは、割り込みルーチンでいじる。


;
;	その他の設定
;

;---------------------------------------------------------------

	ret				;終了
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
_PcmVoiceSet	proc far c	uses bx cx dx di si ds es,
	cNumber:byte,
	fptWave:far ptr byte

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得
	push	ds
	pop	es

;構造体アドレスの設定
	lea	di,[bx + WTD_WorkAdd_Wave]

;---------------------------------------------------------------
;設定

	;音色番号取得
	xor	ax,ax			;
	mov	al,cNumber		;ax←音色番号

	;音色番号チェック
	.if	(al>15)			;16以下？
		mov	ax,11		;でなかったら、エラー
		jmp	_PCMVoiceSet_End
	.endif

	;音色転送
	shl	ax,4			;
	add	di,ax			;di＝di＋ax×16
	lds	si,fptWave		;ds:si←送り元
	mov	cx,8			;16Byte転送
	rep	movsw			;ブロック転送

;---------------------------------------------------------------

	;エラー無し
	xor	ax,ax			;ax←0

_PCMVoiceSet_End:

	ret				;終了
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
_SoftEmbSet	proc far c	uses bx cx dx di si ds es,
	cNumber:byte,
	fptWave:far ptr byte

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得
	push	ds
	pop	es

;構造体アドレスの設定
	lea	di,[bx + WTD_WorkAdd_Emb]

;---------------------------------------------------------------
;設定

	;音色番号取得
	xor	ax,ax			;
	mov	al,cNumber		;ax←音色番号

	;音色番号チェック
	.if	(al>23)			;24以下？
		mov	ax,11		;でなかったら、エラー
		jmp	_SoftEmbSet_End	
	.endif

	;転送
	shl	ax,4			;
	add	di,ax			;di＝di＋ax×16
	lds	si,fptWave		;ds:si←送り元
	mov	cx,8			;16Byte転送
	rep	movsw			;ブロック転送

;---------------------------------------------------------------

;エラー無し
	xor	ax,ax			;ax←0

_SoftEmbSet_End:
	ret				;終了
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
_ChangeFar	proc far c,
	fptData:far ptr byte

;---------------------------------------------------------------
;ファーポインタ変換

;	mov	ax,word ptr [bp + 06h]	;ax←far pointer offset
	mov	ax,word ptr fptData	;ax←far pointer offset
	mov	dx,ax			;
	and	ax,000Fh		;ax←残りの16byte分
	shr	dx,4			;
;	add	dx,word ptr [bp + 08h]	;dx←ax / 16 + far pointer segment
	add	dx,word ptr fptData+2	;dx←ax / 16 + far pointer segment

;---------------------------------------------------------------

	ret				;終了
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
_SoundSetChannel	proc far c	uses ax,
	iMode:word

	mov	ax,iMode		;ax←mode
	call	SP_Set_Channel		;Chennel modeの設定

	ret				;終了
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
_SoundGetChannel	proc far c	;
	call	SP_Get_Channel		;Channel mode の取得
	ret				;終了
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
_SoundSetOutput	proc far c	uses ax,
	iMode:word

	mov	ax,iMode		;ax←mode
	call	SP_Set_Output		;Output modeの設定

	ret				;終了
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
_SoundGetOutput	proc far c		;
	call	SP_Get_Output		;Output modeの取得
	ret				;終了
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
_SoundGetRandom	proc far c		;
	call	SP_Get_Random		;乱数の取得
	ret				;終了
_SoundGetRandom	endp			;
;===============================================================|
;	void	(far *SetMusicVolume)(char volume);		|
;===============================================================|
;	引き数							|
;		cVolume						|
;	返り値							|
;		無し						|
;	処理							|
;		マスターボリュームの設定			|
;===============================================================|
_SetMusicVolume	proc far c	uses ax bx si ds,
	cVolume:byte

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得

;構造体アドレスの設定
	lea	si,[bx + WTD_WorkAdd_System]

;---------------------------------------------------------------
;設定
	mov	al,cVolume			;
	mov	ds:[si].WTD_Sys_VolumeMusic,al	;

;---------------------------------------------------------------

	ret				;終了
_SetMusicVolume	endp			;
;===============================================================|
;	char	(far *GetMusicVoluem)();			|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		ax	Volume					|
;	処理							|
;		マスターボリュームの取得			|
;===============================================================|
_GetMusicVolume	proc far c	uses bx si ds

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得

;構造体アドレスの設定
	lea	si,[bx + WTD_WorkAdd_System]

;---------------------------------------------------------------
;取得
	xor	ax,ax				;ax←0
	mov	al,ds:[si].WTD_Sys_VolumeMusic	;

;---------------------------------------------------------------

	ret				;終了
_GetMusicVolume	endp			;
;===============================================================|
;	void	(far *SetEffectVolume)(char volume);		|
;===============================================================|
;	引き数							|
;		iVolume	音量					|
;	返り値							|
;		無し						|
;	処理							|
;		効果音のマスターボリュームの設定		|
;===============================================================|
_SetEffectVolume	proc far c	uses ax bx si ds,
	cVolume:byte

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得

;構造体アドレスの設定
	lea	si,[bx + WTD_WorkAdd_System]

;---------------------------------------------------------------
;設定
	mov	al,cVolume			;
	mov	ds:[si].WTD_Sys_VolumeEffect,al	;

;---------------------------------------------------------------

	ret				;終了
_SetEffectVolume	endp		;
;===============================================================|
;	char	(far *GetEffectVolume)();			|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		ボリューム					|
;	処理							|
;		効果音のマスターボリュームの取得		|
;===============================================================|
_GetEffectVolume	proc far c	uses bx si ds

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得

;構造体アドレスの設定
	lea	si,[bx + WTD_WorkAdd_System]

;---------------------------------------------------------------
;取得
	xor	ax,ax				;ax←0
	mov	al,ds:[si].WTD_Sys_VolumeEffect	;

;---------------------------------------------------------------

	ret				;終了
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
_SetPcmVolume	proc far c	uses ax bx si ds,
	cVolume:byte

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得

;構造体アドレスの設定
	lea	si,[bx + WTD_WorkAdd_System]

;---------------------------------------------------------------
;設定
	mov	al,cVolume			;
	mov	ds:[si].WTD_Sys_VolumePcm,al	;al←Set Data
	mov	ah,0fh				;ah←Set Bit
	call	SP_Set_VolumePCM		;

;---------------------------------------------------------------

	ret				;終了
_SetPcmVolume	endp			;
;===============================================================|
;	char	(far *GetPcmVolume)();				|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		音量						|
;	処理							|
;		PCM Voice の音量を取得する。			|
;===============================================================|
_GetPcmVolume	proc far c	uses bx si ds

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得

;構造体アドレスの設定
	lea	si,[bx + WTD_WorkAdd_System]

;---------------------------------------------------------------
;取得
	xor	ax,ax				;ax←0
	mov	al,ds:[si].WTD_Sys_VolumePcm	;

;---------------------------------------------------------------

	ret				;終了
_GetPcmVolume	endp			;
;===============================================================|
;	void	(far *SetFIFO)(int size,char far *FIFO);	|
;===============================================================|
;	引き数							|
;		int	size	FIFOバッファのサイズ		|
;		char far *FIFO	FIFOバッファのアドレス		|
;	返り値							|
;		無し						|
;	処理							|
;		FIFOバッファを設定する。			|
;===============================================================|
_SetFIFO	proc far c	uses ax bx di si ds es,
	szFIFO:word,
	fptFIFO:far ptr byte

ifndef	hyoka;-------------------------------
	pushf				;フラグ保存

;---------------------------------------------------------------
;ワークアドレスの取得

	WTD_WorkGet	ds,bx			;ワークエリアアドレスの取得

;構造体アドレスの設定
	lea	si,[bx + WTD_WorkAdd_System]

;---------------------------------------------------------------

	cli
	.repeat				;FIFOバッファが空になるまで待つ。
	mov	ax,ds:[si].WTD_Sys_ComFIFO_Cnt	
	.until	(ax==ds:[si].WTD_Sys_ComFIFO_Adr)
	sti

	mov	ax,szFIFO			;
	mov	ds:[si].WTD_Sys_ComFIFO_Size,ax	;

	les	ax,fptFIFO			;
	push	es				;引数の取得	Segment
	push	ax				;		Offset
	push	cs				;データ変換
	call	near ptr _ChangeFar		;dxax = wtdIL.ChangeFar(*FIFO);
	add	sp,+4				;
	mov	ds:[si].WTD_Sys_ComFIFO_Offset,ax
	mov	ds:[si].WTD_Sys_ComFIFO_Segment,dx

;---------------------------------------------------------------

	popf				;レジスタ復帰
endif;----------------------------------------

	ret				;
_SetFIFO	endp			;
