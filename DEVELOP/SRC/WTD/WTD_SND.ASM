;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Sound Control				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;****************************************************************
;*								*
;*		Ｗａｎｄｅｒ　Ｓｗａｎ　内蔵ＰＣＭ		*
;*								*
;****************************************************************
;===============================================================|
;			I/O Address				|
;===============================================================|
PCM_Com_Frection	equ	080h			;周波数
PCM_Com_FrectionCh1	equ	PCM_Com_Frection + 0	;周波数
PCM_Com_FrectionCh2	equ	PCM_Com_Frection + 2	;周波数
PCM_Com_FrectionCh3	equ	PCM_Com_Frection + 4	;周波数
PCM_Com_FrectionCh4	equ	PCM_Com_Frection + 6	;周波数
PCM_Com_Volume		equ	088h			;音量
PCM_Com_VolumeCh1	equ	PCM_Com_Volume + 0	;音量
PCM_Com_VolumeCh2	equ	PCM_Com_Volume + 1	;音量
PCM_Com_VolumeCh3	equ	PCM_Com_Volume + 2	;音量
PCM_Com_VolumeCh4	equ	PCM_Com_Volume + 3	;音量
PCM_Com_PCMVoice	equ	Pcm_Com_VolumeCh2	;PCM Voice
PCM_Com_Sweep		equ	08Ch			;Sweep
PCM_Com_SweepLevel	equ	PCM_Com_Sweep + 0	;Sweep Level
PCM_Com_SweepTime	equ	PCM_Com_Sweep + 1	;Sweep time
PCM_Com_Noise		equ	08Eh			;Noise mode
PCM_Com_VoiceAddress	equ	08Fh			;音色Wave table address
PCM_Com_Channel		equ	090h			;Channel mode
PCM_Com_Output		equ	091h			;Output mode
PCM_Com_Random		equ	092h			;Random get
PCM_Com_VolumePCM	equ	094h			;PCM Voice Volume
;===============================================================|
;			Work Address				|
;===============================================================|
PCM_Wrok_Segment	equ	0000h	;FreyaBIOS Work Area
PCM_Wrok_VoiceTable	equ	0180h	;FreyaBIOS Work Area
;===============================================================|
;			定数					|
;===============================================================|
PCM_Channel_mask	equ	0300h	;マスク
PcmVoiceMode_Set	equ	2020h	;Channel Mode  PCM Voice Mode Set
PcmVoiceMode_Reset	equ	2000h	;Channel Mode  PCM Voice Mode Reset
;===============================================================|
;		サウンドの初期化				|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		無し						|
;	処理							|
;		deviceの初期化					|
;===============================================================|
	even				;偶数アドレス配置
SP_init	proc near			;
	push	ax			;
	push	cx			;
	push	di			;
	push	es			;レジスタ保存

	mov	ax,PCM_Wrok_VoiceTable	;
	call	SP_Set_VoiceAdd		;音色テーブルの設定

	push	PCM_Wrok_Segment	;
	pop	es			;
	mov	di,ax			;es:di←0000h:0180h

	xor	ax,ax			;各デバイスの初期化
	mov	cx,0020h		;64byte転送
	rep	stosw			;音色の初期化
	xor	ax,ax			;
	out	PCM_Com_FrectionCh1,ax	;
	out	PCM_Com_FrectionCh2,ax	;
	out	PCM_Com_FrectionCh3,ax	;
	out	PCM_Com_FrectionCh4,ax	;
	out	PCM_Com_VolumeCh1,al	;
	out	PCM_Com_VolumeCh2,al	;
	out	PCM_Com_VolumeCh3,al	;
	out	PCM_Com_VolumeCh4,al	;
	out	PCM_Com_SweepLevel,al	;
	out	PCM_Com_SweepTime,al	;
	out	PCM_Com_Noise,al	;
	mov	al,00fh			;
	out	PCM_Com_Channel,al	;
	mov	al,00fh			;
	out	PCM_Com_Output,al	;
	out	PCM_Com_VolumePCM,al	;

	pop	es			;レジスタ復帰
	pop	di			;
	pop	cx			;
	pop	ax			;
	ret				;
SP_init	endp				;
;===============================================================|
;			周波数のセット				|
;===============================================================|
;	引き数							|
;		CH	Channel					|
;		AX	Frection				|
;	返り値							|
;		無し						|
;	処理							|
;		周波数のセット					|
;===============================================================|
	even				;偶数アドレス配置
SP_Set_Frection	proc near		;
	push	cx			;
	push	dx			;レジスタ保存

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Frection_Step	;効果音パート？
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Frection_End	;効果音鳴っているか？

SP_Set_Frection_Step:			;
	mov	dx,PCM_Com_Frection	;dx←I/O Address base
	and	cx,PCM_Channel_mask	;
	shr	cx,7			;cx = ch * 2
	add	dx,cx			;dx←I/O Address
	out	dx,ax			;out(dx),ax

SP_Set_Frection_End:			;
	pop	dx			;レジスタ復帰
	pop	cx			;
	ret				;
SP_Set_Frection	endp			;
;===============================================================|
;			音量のセット				|
;===============================================================|
;	引き数							|
;		CH	Channel					|
;		AL	Volume					|
;	返り値							|
;		無し						|
;	処理							|
;		音量のセット					|
;===============================================================|
	even				;偶数アドレス配置
SP_Set_Volume	proc near		;
	push	cx			;
	push	dx			;レジスタ保存

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Volume_Step	;効果音パート？
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Volume_End	;効果音鳴っているか？

SP_Set_Volume_Step:			;
	mov	dx,PCM_Com_Volume	;dx←I/O Address base
	and	cx,PCM_Channel_mask	;
	shr	cx,8			;cx = cl
	add	dx,cx			;dx←I/O Address
	out	dx,al			;out(dx),ax

SP_Set_Volume_End:			;
	pop	dx			;レジスタ復帰
	pop	cx			;
	ret				;
SP_Set_Volume	endp			;
;===============================================================|
;			スウィープのセット			|
;===============================================================|
;	引き数							|
;		AL	Sweep Level				|
;		AH	Sweep Time				|
;	返り値							|
;		無し						|
;	処理							|
;		スウィープの設定				|
;===============================================================|
	even				;偶数アドレス配置
SP_Set_Sweep	proc near		;
	push	dx

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Sweep_Step	;効果音パート？
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Sweep_End	;効果音鳴っているか？

SP_Set_Sweep_Step:			;
	out	PCM_Com_SweepLevel,al	;出力
	xchg	al,ah			;
	out	PCM_Com_SweepTime,al	;出力
	xchg	al,ah			;

SP_Set_Sweep_End:			;
	pop	dx			;
	ret				;
SP_Set_Sweep	endp			;
;===============================================================|
;			ノイズモードのセット			|
;===============================================================|
;	引き数							|
;		AL	Set Data				|
;		AH	Set bit					|
;	返り値							|
;		無し						|
;	処理							|
;		ノイズモードの設定				|
;===============================================================|
	even				;偶数アドレス配置
SP_Set_Noise	proc near		;
	push	dx			;レジスタの保存

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Noise_Step	;効果音パート？
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Noise_End	;効果音鳴っているか？

SP_Set_Noise_Step:			;
	mov	dx,PCM_Com_Noise	;dx←I/O Address
	call	SP_Set_with_mask	;

SP_Set_Noise_End:			;
	pop	dx			;
	ret				;レジスタの復帰
SP_Set_Noise	endp			;
;===============================================================|
;			音色テーブルのアドレス			|
;===============================================================|
;	引き数							|
;		AX	Address					|
;	返り値							|
;		無し						|
;	処理							|
;		音色テーブルのアドレス設定			|
;===============================================================|
	even				;偶数アドレス配置
SP_Set_VoiceAdd	proc near		;
	push	ax			;レジスタの保存
	push	dx			;

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_VoiceAdd_Step	;効果音パート？
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_VoiceAdd_End	;効果音鳴っているか？

SP_Set_VoiceAdd_Step:			;
	shr	ax,6			;64Byte単位。64で割る。
	out	PCM_Com_VoiceAddress,al	;出力

SP_Set_VoiceAdd_End:			;
	pop	dx			;
	pop	ax			;レジスタの復帰
	ret				;
SP_Set_VoiceAdd	endp			;
;===============================================================|
;			Channel modeの設定			|
;===============================================================|
;	引き数							|
;		AL	Channel mode				|
;		AH	Set bit					|
;	返り値							|
;		無し						|
;	処理							|
;		チャンネルモードの設定				|
;===============================================================|
	even				;偶数アドレス配置
SP_Set_Channel	proc near		;
	push	dx			;レジスタの保存

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Channel_Step	;効果音パート？
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Channel_End	;効果音鳴っているか？

SP_Set_Channel_Step:			;
	mov	dx,PCM_Com_Channel	;dx←I/O Address
	call	SP_Set_with_mask	;

SP_Set_Channel_End:			;
	pop	dx			;
	ret				;レジスタの復帰
SP_Set_Channel	endp			;
;===============================================================|
;			Channel modeの取得			|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		AX	Channel mode(ah = 00h)			|
;	処理							|
;		チャンネルモードの取得				|
;===============================================================|
	even				;偶数アドレス配置
SP_Get_Channel	proc near		;
	xor	ax,ax			;
	in	al,PCM_Com_Channel	;入力
	ret				;
SP_Get_Channel	endp			;
;===============================================================|
;			Output modeの設定			|
;===============================================================|
;	引き数							|
;		AL	Output mode				|
;		AH	Set bit					|
;	返り値							|
;		無し						|
;	処理							|
;		出力モードの設定				|
;===============================================================|
	even				;偶数アドレス配置
SP_Set_Output	proc near		;
	push	dx			;レジスタの保存

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Output_Step	;効果音パート？
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Output_End	;効果音鳴っているか？

SP_Set_Output_Step:			;
	mov	dx,PCM_Com_Output	;dx←I/O Address
	call	SP_Set_with_mask	;

SP_Set_Output_End:			;
	pop	dx			;
	ret				;レジスタの復帰
SP_Set_Output	endp			;
;===============================================================|
;			Output modeの取得			|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		AX	Output mode (AH = 0)			|
;	処理							|
;		出力モードの取得				|
;===============================================================|
	even				;偶数アドレス配置
SP_Get_Output	proc near		;
	xor	ax,ax			;
	in	al,PCM_Com_Output	;入力
	ret				;
SP_Get_Output	endp			;
;===============================================================|
;			疑似乱数の取得				|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		AX	疑似乱数				|
;	処理							|
;		疑似乱数の取得					|
;===============================================================|
	even				;偶数アドレス配置
SP_Get_Random	proc near		;
	in	ax,PCM_Com_Random	;入力
	ret				;
SP_Get_Random	endp			;
;===============================================================|
;			PCM Volume Volumeの設定			|
;===============================================================|
;	引き数							|
;		AL	PCM Voice Volume			|
;		AH	Set bit					|
;	返り値							|
;		無し						|
;	処理							|
;		出力モードの設定				|
;===============================================================|
	even				;偶数アドレス配置
SP_Set_VolumePCM	proc near	;
	push	dx			;レジスタの保存

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_VolumePCM_Step	;効果音パート？
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_VolumePCM_End	;効果音鳴っているか？

SP_Set_VolumePCM_Step:			;
	mov	dx,PCM_Com_VolumePCM	;dx←I/O Address
	call	SP_Set_with_mask	;

SP_Set_VolumePCM_End:			;
	pop	dx			;
	ret				;レジスタの復帰
SP_Set_VolumePCM	endp		;
;===============================================================|
;			PCM Volume Volumeの設定			|
;===============================================================|
;	引き数							|
;		AL	PCM Voice Volume			|
;		AH	Set bit					|
;	返り値							|
;		無し						|
;	処理							|
;		出力モードの設定				|
;===============================================================|
	even				;偶数アドレス配置
SP_Get_VolumePCM	proc near	;
	in	al,PCM_Com_VolumePCM	;入力
	ret				;
SP_Get_VolumePCM	endp		;
;===============================================================|
;			音色の設定				|
;===============================================================|
;	引き数							|
;		CH	チャンネル				|
;		DS:SI	音色データのアドレス			|
;	返り値							|
;		無し						|
;	処理							|
;		音色を設定する					|
;===============================================================|
	even				;偶数アドレス配置
SP_Set_Voice	proc	near		;
	push	cx			;
	push	dx			;
	push	di			;
	push	si			;
	push	es			;レジスタ保存

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Voice_Step	;効果音パート？
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Voice_End	;効果音鳴っているか？

SP_Set_Voice_Step:			;

	cld				;インクリメントモード

	push	PCM_Wrok_Segment	;es←0000h
	pop	es			;
	mov	di,PCM_Wrok_VoiceTable	;0180h(音色テーブルアドレス)
	and	cx,PCM_Channel_mask	;
	shr	cx,4			;
	add	di,cx			;es:di←0000h:0180h + ch × 16
	mov	cx,8			;16byte転送する。
	rep	movsw			;転送

SP_Set_Voice_End:			;
	pop	es			;レジスタ復帰
	pop	si			;
	pop	di			;
	pop	dx
	pop	cx			;
	ret				;
SP_Set_Voice	endp			;
;---------------------------------------------------------------|
;		マスクを利用して一部出力			|
;---------------------------------------------------------------|
;	dx		i/o address				|
;	al		set data				|
;	ah		set bit					|
;---------------------------------------------------------------|
	even				;偶数アドレス配置
SP_Set_with_mask:			;
	push	ax			;
	push	cx			;レジスタ保存

	and	al,ah			;マスク
	mov	cl,al			;ch←Set Data
	not	ah			;マスクデータの反転
	in	al,dx			;入力
	and	al,ah			;マスク
	or	al,cl			;論理和
	out	dx,al			;出力

	pop	cx			;レジスタ復帰
	pop	ax			;
	ret				;
;****************************************************************
;*								*
;*			ＭＩＤＩ制御				*
;*				JIS X 6054-1			*
;*				JIS X 6054-2 参照		*
;*								*
;****************************************************************
ifndef	hyoka
;===============================================================|
;			コマンド				|
;===============================================================|
MIDI_Com_KeyOff		equ	080h	;
MIDI_Com_KeyOn		equ	090h	;
MIDI_Com_KeyPress	equ	0A0h	;
MIDI_Com_Control	equ	0B0h	;
MIDI_Com_Program	equ	0C0h	;
MIDI_Com_ChPress	equ	0D0h	;
MIDI_Com_PitchBend	equ	0E0h	;
MIDI_Com_Exclucive	equ	0F0h	;
;===============================================================|
;			コントロールコード			|
;===============================================================|
MIDI_Ctrl_MSB		equ	20h	;
MIDI_Ctrl_Bank		equ	00h	;
MIDI_Ctrl_Mod		equ	01h	;
MIDI_Ctrl_Bress		equ	02h	;
MIDI_Ctrl_Foot		equ	04h	;
MIDI_Ctrl_PolTime	equ	05h	;
MIDI_Ctrl_DataEntly	equ	06h	;
MIDI_Ctrl_Volume	equ	07h	;
MIDI_Ctrl_Blance	equ	08h	;
MIDI_Ctrl_Pan		equ	0Ah	;
MIDI_Ctrl_Expression	equ	0Bh	;
MIDI_Ctrl_Effect1	equ	0Ch	;
MIDI_Ctrl_Effect2	equ	0Dh	;
MIDI_Ctrl_Hold		equ	40h	;
MIDI_Ctrl_PolSW		equ	41h	;ポルタメントスイッチ
MIDI_Ctrl_S		equ	42h	;ソヌーテート
MIDI_Ctrl_Soft		equ	43h	;ソフトペダル
MIDI_Ctrl_Legert	equ	44h	;レガートスイッチ
MIDI_Ctrl_Hold2		equ	45h	;ホールド
MIDI_Ctrl_PolControl	equ	54h	;ポルタメントコントロール
MIDI_Ctrl_Reverv	equ	5Bh	;リバーブ
MIDI_Ctrl_Tremono	equ	5Ch	;トレモノ
MIDI_Ctrl_Chorus	equ	5Dh	;コーラス
MIDI_Ctrl_Delay		equ	5Eh	;ディレイ
MIDI_Ctrl_F		equ	5Fh	;フェザー
MIDI_Ctrl_DataInc	equ	60h	;
MIDI_Ctrl_DaraDec	equ	61h	;
MIDI_Ctrl_NonRegLSB	equ	62h	;ディレイ
MIDI_Ctrl_NonRegMSB	equ	63h	;フェザー
MIDI_Ctrl_RegLSB	equ	64h	;
MIDI_Ctrl_RegMSB	equ	65h	;
;===============================================================|
;			レジスタードパラメータ			|
;===============================================================|
;				LSB-MSB
MIDI_Reg_PitchBend	equ	0000h	;ピッチベンドセンシティビティ
MIDI_Reg_Fain		equ	0001h	;ファインチューン
MIDI_Reg_Cose		equ	0002h	;コースチューン
MIDI_Reg_CProgram	equ	0003h	;チューニングプログラムセレクト
MIDI_Reg_CBank		equ	0004h	;チューニングバンクセレクト
MIDI_Reg_NULL		equ	7F7Fh	;ヌル
;===============================================================|
;			定数					|
;===============================================================|
MIDI_Channel_mask	equ	0Fh	;マスク
;===============================================================|
;			エクスクルーシブ			|
;===============================================================|
	even				;偶数アドレス配置
MIDI_Ex_GmReset		db	6,0f0h,7eh,7fh,09h,01h,0f7h
MIDI_Ex_GsReset		db	0
MIDI_Ex_XgReset		db	0
;===============================================================|
;			MIDI Running Status			|
;===============================================================|
;	引き数							|
;		al	MIDI Command				|
;	返り値							|
;		無し						|
;	処理							|
;		ランニング・ステータスを考慮したコマンド送信	|
;===============================================================|
SM_Send_With_Running_Status:		;
	cmp	ds:[bp].WTD_WorkAdd_System+WTD_Sys_RunningStatus,al
	jz	SM_Send_With_Running_Status_e
	call	C_Send			;コマンドの送信
	mov	ds:[bp].WTD_WorkAdd_System+WTD_Sys_RunningStatus,al
SM_Send_With_Running_Status_e:		;
	ret				;
;===============================================================|
;			MIDIの初期化				|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		無し						|
;	処理							|
;			GM Resetの送信				|
;===============================================================|
	even				;偶数アドレス配置
SM_init	proc near			;
	push	cx			;
	push	si			;
	push	es			;レジスタ保存

	push	cs			;
	pop	es			;ds←cs
	xor	cx,cx			;cx←MIDI_Ex_GmReset
	mov	cl,byte ptr es:[MIDI_Ex_GmReset]
	mov	si,offset MIDI_Ex_GmReset + 1
	call	C_Send_Block		;ブロック送信

	pop	es			;レジスタ復帰
	pop	si			;
	pop	cx			;
	ret				;
SM_init	endp				;
;===============================================================|
;			KeyOff					|
;===============================================================|
;	引き数							|
;		CH	Track					|
;		AL	Key					|
;	返り値							|
;		AH	00h					|
;	処理							|
;		KeyOff						|
;===============================================================|
	even				;偶数アドレス配置
SM_KeyOff:				;
	xor	ah,ah			;発音停止(KeyOff)
;===============================================================|
;			KeyOn					|
;===============================================================|
;	引き数							|
;		CH	Track					|
;		AH	Velocity (0:KeyOff)			|
;		AL	Key					|
;	返り値							|
;		無し						|
;	処理							|
;		KeyOn						|
;===============================================================|
	even				;偶数アドレス配置
SM_KeyOn	proc near		;
	push	cx			;レジスタ保存

	push	ax			;レジスタ保存
	mov	al,MIDI_Com_KeyOn	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;コマンドの送信
	pop	ax			;レジスタ復帰
	call	C_Send_Word		;データの送信

	pop	cx			;レジスタ復帰
	ret				;
SM_KeyOn	endp			;
;===============================================================|
;			Poly Key Press				|
;===============================================================|
;	引き数							|
;		CH	Track					|
;		AH	Pressior				|
;		AL	Key					|
;	返り値							|
;		無し						|
;	処理							|
;		キープレッシャー（アフタータッチ）の送信	|
;===============================================================|
	even				;偶数アドレス配置
SM_KeyPress	proc near		;
	push	cx			;レジスタ保存

	push	ax			;レジスタ保存
	mov	al,MIDI_Com_KeyPress	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;コマンドの送信
	pop	ax			;レジスタ復帰
	call	C_Send_Word		;データの送信

	pop	cx			;レジスタ復帰
	ret				;
SM_KeyPress	endp			;
;===============================================================|
;			Control Change Byte			|
;===============================================================|
;	引き数							|
;		CH	Track					|
;		CL	Reg.					|
;		AL	Data					|
;	返り値							|
;		無し						|
;	処理							|
;		Control Change					|
;===============================================================|
	even				;偶数アドレス配置
SM_ControlByte	proc near		;
	push	ax			;
	push	cx			;レジスタ保存

	push	ax			;保存
	mov	al,MIDI_Com_Control	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;コマンドの送信
	pop	ax			;復帰
	mov	ah,cl			;
	call	C_Send_Word		;データの送信

	pop	cx			;レジスタ復帰
	pop	ax			;
	ret				;
SM_ControlByte	endp			;
;===============================================================|
;			Control Change Word			|
;===============================================================|
;	引き数							|
;		CH	Track					|
;		CL	Reg.					|
;		AX	Data					|
;	返り値							|
;		無し						|
;	処理							|
;		Control Change					|
;===============================================================|
	even				;偶数アドレス配置
SM_ControlWord	proc near		;
	push	ax			;
	push	cx			;レジスタ保存

	shl	ax,1			;
	shr	al,1			;
	and	ax,07f7fh		;データの分離

	push	ax			;保存
	mov	al,MIDI_Com_Control	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;コマンドの送信
	pop	ax			;復帰
	push	ax			;
	mov	al,ah			;
	mov	ah,cl			;
	call	C_Send_Word		;レジスタ(ah)，データの送信(al(LSB))
	pop	ax			;復帰
	mov	ah,cl			;
	add	ah,MIDI_Ctrl_MSB	;
	call	C_Send_Word		;レジスタ(ah)，データの送信(al(MSB))

	pop	cx			;レジスタ復帰
	pop	ax			;
	ret				;
SM_ControlWord	endp			;
;===============================================================|
;			Program Change				|
;===============================================================|
;	引き数							|
;		CH	Track					|
;		AL	Program					|
;	返り値							|
;		無し						|
;	処理							|
;		Program Change					|
;===============================================================|
	even				;偶数アドレス配置
SM_Program	proc near		;
	push	ax			;
	push	cx			;レジスタ保存

	mov	ah,al			;
	mov	al,MIDI_Com_Program	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;コマンドの送信
	mov	al,ah			;
	call	C_Send			;データの送信

	pop	cx			;レジスタ復帰
	pop	ax			;
	ret				;
SM_Program	endp			;
;===============================================================|
;			Program Change with Bank		|
;===============================================================|
;	引き数							|
;		CH	Track					|
;		AL	Program					|
;		BX	Bank(AH:Msb,AL:Lsb)			|
;	返り値							|
;		無し						|
;	処理							|
;		Program ChangeとBank Selectの送信		|
;===============================================================|
	even				;偶数アドレス配置
SM_BankProgram	proc near		;
	push	cx			;レジスタの保存

	push	ax			;
	mov	cl,MIDI_Ctrl_Bank	;バンクセレクト
	mov	ax,bx			;バンク
	shl	al,1			;
	shr	ax,1			;
	and	ax,03fffh		;データ合成
	call	SM_ControlWord		;
	pop	ax			;
	call	SM_Program		;プログラムチェンジ
	
	pop	cx			;レジスタの復帰
	ret				;
SM_BankProgram	endp			;
;===============================================================|
;			Poly Ch Press				|
;===============================================================|
;	引き数							|
;		CH	Track					|
;		AL	Pressior				|
;	返り値							|
;		無し						|
;	処理							|
;		キープレッシャー（アフタータッチ）の送信	|
;===============================================================|
	even				;偶数アドレス配置
SM_ChPress	proc near		;
	push	cx			;
	push	ax			;レジスタ保存

	mov	ah,al			;
	mov	al,MIDI_Com_KeyPress	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;コマンドの送信
	mov	al,ah			;
	call	C_Send			;データの送信

	pop	ax			;レジスタ復帰
	pop	cx			;
	ret				;
SM_ChPress	endp			;
;===============================================================|
;			Pitch Bend				|
;===============================================================|
;	引き数							|
;		CH	Track					|
;		AX	Pitch Bend				|
;	返り値							|
;		無し						|
;	処理							|
;		Pitch Bendの送信				|
;===============================================================|
	even				;偶数アドレス配置
SM_PitchBend	proc near		;
	push	cx			;レジスタ保存

	push	ax			;レジスタ保存
	mov	al,MIDI_Com_PitchBend	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;コマンドの送信
	pop	ax			;レジスタ復帰
	push	ax			;レジスタ保存
	shl	ax,1			;
	shr	al,1			;
	and	ax,07f7fh		;データの分離
	call	C_Send_Word		;データの送信
	pop	ax			;レジスタ復帰

	pop	cx			;レジスタ復帰
	ret				;
SM_PitchBend	endp			;
;===============================================================|
endif
