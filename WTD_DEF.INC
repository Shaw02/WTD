;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				define file				|
;					for Assemble Language		|
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
;===============================================================|
;		Wander Swan Segment Address			|
;===============================================================|
;'sys/bank.h'に同等の定義がある。
BANK_SRAM_ADDRESS	equ	01000h	;SRAM　のセグメントアドレス
BANK_ROM0_ADDRESS	equ	02000h	;ROM0　のセグメントアドレス
BANK_ROM1_ADDRESS	equ	03000h	;ROM1　のセグメントアドレス
;セグメントアドレス定義
IRAM_Segment		equ	0000h	;本体RAM
SRAM_Segment		equ	BANK_SRAM_ADDRESS
FROM_Segment		equ	BANK_ROM0_ADDRESS
;===============================================================|
;		本体RAM Work Address				|
;===============================================================|
Hblank_intvector	equ	000bch		;割り込みベクタ(02fh×4)
;===============================================================|
;		FreyaOS process control block			|
;===============================================================|
;	'sys/process.h'に同等の定義がある。			|
;---------------------------------------------------------------|
;構造体定義
ProcContext		struc			;
ProcContext_id		db	4	dup(?)	; mark: "LCC"/"TCC"
ProcContext_pid		dw	?		; pid of process
ProcContext_ppid	dw	?		; pid of parent process
ProcContext_pcbid	dw	?		; pcbid of process
ProcContext_ppcbib	dw	?		; parent's pcbid
ProcContext_ilib	dd	?		; IlibIL for this process
ProcContext_proc	dd	?		; ProcIL for this process
ProcContext_cwfs	dd	?		; current working filesystem
ProcContext_currentdir	db	64	dup(?)	; current working directory
ProcContext_argv	dw 	?		; execution arguments
ProcContext_resource	dd	?		; poiter to resource
ProcContext_heap	dw	?		; poiter to free heap area
ProcContext		ends			;
;===============================================================|
;		Micro Soft  RIFF and Wave data formats		|
;===============================================================|
;構造体定義 RIFF Header
Riff			struc			;
Riff_Head		db	4	dup(?)	;'RIFF'
Riff_Size		dd	?		;File Size(全体-8)
Riff_Type		db	4	dup(?)	;'WAVE'
Riff_Data		db	?		;データ
Riff			ends

;構造体定義	RIFF struct
RiffHed			struc			;
RiffHed_Head		db	4	dup(?)	;ヘッダ
RiffHed_Size		dd	?		;ヘッダのデータのサイズ
RiffHed_Data		db	?		;ヘッダのデータ
RiffHed			ends			;

;構造体定義	WAVE fmt
WaveFmt			struc			;
WaveFmt_Head		db	4	dup(?)	;'fmt '
WaveFmt_Size		dd	?		;16	[byte]
WaveFmt_Type		dw	?		;1	(wave)
WaveFmt_Channel		dw	?		;1	(mono)
WaveFmt_SamplingRate	dd	?		;11025	[Hz]
WaveFmt_SamplingSec	dd	?		;11025	[Byte]
WaveFmt_DataSize	dw	?		;1	[Byte]
WaveFmt_ChannelSize	dw	?		;8	[bit]
WaveFmt			ends			;

;構造体定義	WAVE Data
WaveData		struc			;
WaveData_Head		db	4	dup(?)	;'data'
WaveData_Size		dd	?		;Data Size
WaveData_Data		db	?		;wave data
WaveData		ends			;
;****************************************************************
;*								*
;*		ワーク領域アドレス				*
;*								*
;****************************************************************
;構造体位置
WTD_WorkAdd_User	equ	0000h		;ユーザ用ワーク
WTD_WorkAdd_Wave	equ	0100h		;音色
WTD_WorkAdd_Emb		equ	0200h		;エンベロープ
WTD_WorkAdd_System	equ	0380h		;パート共通構造体

WTD_WorkAdd_Ech0	equ	0400h		;Effect ch1
WTD_WorkAdd_Ech1	equ	0480h		;Effect ch2
WTD_WorkAdd_Ech2	equ	0500h		;Effect ch3
WTD_WorkAdd_PCM		equ	0580h		;Effect PCM Voice

WTD_WorkAdd_Ch0		equ	0600h		;ch0
WTD_WorkAdd_Ch1		equ	0680h		;ch1
WTD_WorkAdd_Ch2		equ	0700h		;ch2
WTD_WorkAdd_Ch3		equ	0780h		;ch3
WTD_WorkAdd_Ch4		equ	0800h		;ch4
WTD_WorkAdd_Ch5		equ	0880h		;ch5
WTD_WorkAdd_Ch6		equ	0900h		;ch6
WTD_WorkAdd_Ch7		equ	0980h		;ch7
WTD_WorkAdd_Ch8		equ	0a00h		;ch8
WTD_WorkAdd_Ch9		equ	0a80h		;ch9
WTD_WorkAdd_Ch10	equ	0b00h		;ch10
WTD_WorkAdd_Ch11	equ	0b80h		;ch11
WTD_WorkAdd_Ch12	equ	0c00h		;ch12
WTD_WorkAdd_Ch13	equ	0c80h		;ch13
WTD_WorkAdd_Ch14	equ	0d00h		;ch14
WTD_WorkAdd_Ch15	equ	0d80h		;ch15
WTR_WorkAdd_Ch16	equ	0e00h		;ch16
WTD_WorkAdd_Ch17	equ	0e80h		;ch17
WTD_WorkAdd_Ch18	equ	0f00h		;ch18
WTD_WorkAdd_Ch19	equ	0f80h		;ch19

WTD_WorkChSize		equ	080h		;ワークのサイズ
WTD_WorkSize		equ	1000h		;ワークのサイズ

WTD_WorkAdd_End		equ	WTD_WorkSize	;ワークの最後＋１
;****************************************************************
;*								*
;*		パート個別ワーク構造体				*
;*								*
;****************************************************************
;===============================================================|
;			構造体定義				|
;===============================================================|
;構造体定数定義
WTD_NoiseMode		equ	WTD_SweepLevel	;
WTD_Voice		equ	WTD_Program	;
WTD_Frection		equ	WTD_Bend	;
WTD_FrectionSet		equ	WTD_BendSet	;
WTD_Velocity		equ	WTD_ExprPanSet	;
WTD_PcmAddress		equ	WTD_LoopCount	;発生中アドレス
WTD_PcmSize		equ	WTD_LoopCount+4	;発生終了アドレス
;---------------------------------------------------------------
;パート個別構造体定義
WTD			struc			;各パート個別用	
WTD_FlagControl		dw	?		;00-01	フラグ
WTD_FlagTai		db	?		;02	タイフラグ
WTD_FlagSharp		db	?		;03	#フラグ
WTD_FlagFlat		db	?		;04	bフラグ
WTD_Channel		db	?		;05	ﾁｬﾝﾈﾙ/ﾄﾗｯｸ
WTD_Address		dw	?		;06-07	演奏中のｱﾄﾞﾚｽ
WTD_LoopCount		db	8	dup(?)	;08-0F	ループ回数/PCM Address
WTD_LoopCountPointer	db	?		;10	上記ﾎﾟｲﾝﾀ
WTD_Program		db	?		;11	音色
WTD_SweepLevel		db	?		;12	ｽｳｨｰﾌﾟ値/ﾉｲｽﾞﾓｰﾄﾞ
WTD_SweepTime		db	?		;13	ｽｳｨｰﾌﾟ時間
WTD_Leng		dw	?		;14-15	音長
WTD_LengCounter		dw	?		;16-17	音長カウンター
WTD_LengDefault		dw	?		;18-19	ﾃﾞﾌｫﾙﾄの音長
WTD_KeyOffTime		dw	?		;1A-1B	ｹﾞｰﾄﾀｲﾑ制御値
WTD_KeyOnDelay		dw	?		;1C-1D	ｷｰｵﾝﾃﾞｨﾚｲ
WTD_KeyShift		db	?		;1E	移調値
WTD_Key			db	?		;1F	音程
WTD_KeySet		db	8	dup(?)	;20-27	出力した音程
WTD_KeySetPointer	db	?		;28	上記ﾎﾟｲﾝﾀ
WTD_AcsentVelocity	db	?		;29	アクセント値
WTD_BendSet		dw	?		;2A-2B	出力した周波数
WTD_Bend		dw	?		;2C-2D	指定周波数
WTD_BendDetune		dw	?		;2E-2F	ディチューン
WTD_BendLfoDecayRate	db	?		;30	LFOディケイレイト
WTD_BendLfoSpeedRate	db	?		;31	LFOスピード
WTD_BendLfoLevel	dw	?		;32-33	LFO変位ﾚﾍﾞﾙ
WTD_BendLfoCount	db	?		;34	LFO変化回数
WTD_BendLfoRateCounter	db	?		;35	LFOレイト用カウンタ
WTD_BendLfoLevelSet	dw	?		;36-37	LFO現在の変位ﾚﾍﾞﾙ
WTD_BendLfoCountCounter	db	?		;38	LFO回数用カウンタ
WTD_BendEmbAddress	db	?		;39	EMB番号（ｱﾄﾞﾚｽ）
WTD_BendEmbRate		db	?		;3A	EMBレイト
WTD_BendEmbCounter	db	?		;3B	EMBカウンター
WTD_BendEmbMaxMin	db	?		;3C	EMB最大／最小値
WTD_BendEmbLevelSet	db	?		;3D	EMB変位ﾚﾍﾞﾙ
WTD_Pan			db	?		;3E	パンポット
WTD_ExprPanSet		db	?		;3F	出力/ｳﾞｪﾛｼﾃｨｰ
WTD_ExprSet		db	?		;40	出力音量/ｴｸｽﾌﾟﾚｯｼｮﾝ
WTD_Expr		db	?		;41	音量/ｴｸｽﾌﾟﾚｯｼｮﾝ
WTD_ExprDetune		dw	?		;42-43	音量増減値
WTD_ExprLfoDecayRate	db	?		;44	LFOディケイレイト
WTD_ExprLfoSpeedRate	db	?		;45	LFOスピード
WTD_ExprLfoLevel	dw	?		;46-47	LFO変位ﾚﾍﾞﾙ
WTD_ExprLfoCount	db	?		;48	LFO変化回数
WTD_ExprLfoRateCounter	db	?		;49	LFOレイト用カウンタ
WTD_ExprLfoLevelSet	dw	?		;4A-4B	LFO現在の変位ﾚﾍﾞﾙ
WTD_ExprLfoCountCounter	db	?		;4C	LFO回数用カウンタ
WTD_ExprEmbAddress	db	?		;4D	EMB番号（ｱﾄﾞﾚｽ）
WTD_ExprEmbRate		db	?		;4E	EMBレイト
WTD_ExprEmbCounter	db	?		;4F	EMBカウンター
WTD_ExprEmbMaxMin	db	?		;50	EMB最大／最小値
WTD_ExprEmbLevelSet	db	?		;51	EMB変位ﾚﾍﾞﾙ
WTD_WorkAddress		db	?		;52	ワークｱﾄﾞﾚｽ上位8BIT
WTD_OctaveSet		db	?		;53	出力したオクターブ
WTD_Octave		db	?		;54	指定オクターブ
WTD_GateTime8		db	?		;55	ｹﾞｰﾄﾀｲﾑ（Q,U)
WTD_GateTimeStepLast	dw	?		;56-57	ｹﾞｰﾄﾀｲﾑ(q)
WTD_GateTimeStepFirst	dw	?		;58-59	ｹﾞｰﾄﾀｲﾑ(u)
WTD_VolumeUpDown	db	?		;5A	相対ボリュームの増減値
WTD			ends
;---------------------------------------------------------------
;構造体位置
WTD_BendLFO		equ	WTD_BendLfoDecayRate	;ChLFO構造体先頭
WTD_ExprLFO		equ	WTD_ExprLfoDecayRate	;ChLFO構造体先頭
WTD_BendEmb		equ	WTD_BendEmbAddress	;ChEmb構造体先頭
WTD_ExprEmb		equ	WTD_ExprEmbAddress	;ChEmb構造体先頭

;ChLFO構造体
WTD_ChLfo		struc
WTD_ChLfo_DecayRate	db	?		;	LFOディケイレイト
WTD_ChLfo_SpeedRate	db	?		;	LFOスピード
WTD_ChLfo_Level		dw	?		;	LFO変位ﾚﾍﾞﾙ
WTD_ChLfo_Count		db	?		;	LFO変化回数
WTD_ChLfo_RateCounter	db	?		;	LFOレイト用カウンタ
WTD_ChLfo_LevelSet	dw	?		;	LFO現在の変位ﾚﾍﾞﾙ
WTD_ChLfo_CountCounter	db	?		;	LFO回数用カウンタ
WTD_ChLfo		ends
;ChEmb構造体
WTD_ChEmb		struc
WTD_ChEmb_Address	db	?		;	EMB番号（ｱﾄﾞﾚｽ）
WTD_ChEmb_Rate		db	?		;	EMBレイト
WTD_ChEmb_Counter	db	?		;	EMBカウンター
WTD_ChEmb_MaxMin	db	?		;	EMB最大／最小値
WTD_ChEmb_LevelSet	db	?		;	EMB変位ﾚﾍﾞﾙ
WTD_ChEmb		ends
;===============================================================|
;			フラグビット				|
;===============================================================|
;セット
WTD_Ctrl_BendLfo	equ	00001h		;音程ＬＦＯスイッチ
WTD_Ctrl_BendEmb	equ	00002h		;音程エンベロープスイッチ
WTD_Ctrl_ExprLfo	equ	00004h		;音量ＬＦＯスイッチ
WTD_Ctrl_ExprEmb	equ	00008h		;音量エンベロープスイッチ
WTD_Ctrl_PanLfo		equ	00010h		;パンＬＦＯスイッチ
WTD_Ctrl_PanEmb		equ	00020h		;パンエンベロープスイッチ
WTD_Ctrl_Acsent		equ	00040h		;次の音階はアクセント
WTD_Ctrl_EmbFreq	equ	00080h		;音程エンベロープ 上位bit
WTD_Ctrl_EmbVol		equ	00100h		;音量エンベロープ 上位bit
WTD_Ctrl_EmbPan		equ	00200h		;パンエンベロープ 上位bit
WTD_Ctrl_Vol0		equ	00400h		;音量＝０
WTD_Ctrl_WorkSw		equ	00800h		;次のコマンドは、ワーク参照
WTD_Ctrl_WorkCy		equ	01000h		;ワーク演算結果、オーバーフロー
WTD_Ctrl_WorkZe		equ	02000h		;ワーク演算結果、０になった。
WTD_Ctrl_Effect		equ	04000h		;このパートは効果音か？
WTD_Ctrl_PlayEnd	equ	08000h		;演奏終了
;---------------------------------------------------------------
;リセット
WTD_Ctrl_BendLfoR	equ	0fffeh		;音程ＬＦＯスイッチ
WTD_Ctrl_BendEmbR	equ	0fffdh		;音程エンベロープスイッチ
WTD_Ctrl_ExprLfoR	equ	0fffbh		;音量ＬＦＯスイッチ
WTD_Ctrl_ExprEmbR	equ	0fff7h		;音量エンベロープスイッチ
WTD_Ctrl_PanLfoR	equ	0ffefh		;パンＬＦＯスイッチ
WTD_Ctrl_PamEmbR	equ	0ffdfh		;パンエンベロープスイッチ
WTD_Ctrl_AcsentR	equ	0ffbfh		;次の音階はアクセント
WTD_Ctrl_EmbFreqR	equ	0ff7fh		;音程エンベロープ 上位bit
WTD_Ctrl_EmbVolR	equ	0feffh		;音量エンベロープ 上位bit
WTD_Ctrl_EmbPanR	equ	0fdffh		;パンエンベロープ 上位bit
WTD_Ctrl_Vol0R		equ	0fbffh		;音量＝０
WTD_Ctrl_WorkSwR	equ	0f7ffh		;次のコマンドは、ワーク参照
WTD_Ctrl_WorkCyR	equ	0efffh		;ワーク演算結果、オーバーフロー
WTD_Ctrl_WorkZeR	equ	0dfffh		;ワーク演算結果、０になった。
WTD_Ctrl_EffectR	equ	0bfffh		;このパートは効果音か？
WTD_Ctrl_PlayEndR	equ	07fffh		;演奏終了

;****************************************************************
;*								*
;*		パート共通ワーク構造体				*
;*								*
;****************************************************************
;===============================================================|
;			構造体定義				|
;===============================================================|
WTD_Sys			struc			;システム全体	
WTD_Sys_Flag		dw	?		;00	Flag
WTD_Sys_ProgramOffset	dw	?		;02	Program Offset Address
WTD_Sys_ProgramSegment	dw	?		;04	Program Segment Address
WTD_Sys_MusicOffset	dw	?		;06	Music Offset Address
WTD_Sys_MusicSegment	dw	?		;08	Music Segment Address
WTD_Sys_EffectOffset	dw	?		;0a	Effect Offset Address
WTD_Sys_EffectSegment	dw	?		;0c	Effect Segment Address
WTD_Sys_PcmOffset	dw	?		;0e	Pcm Offset Address
WTD_Sys_PcmSegment	dw	?		;10	Pcm Segment Address
WTD_Sys_StayOutMask	dw	?		;12	常駐解除禁止
WTD_Sys_OldIntvector	dw	2	dup(?)	;14-17	前の割り込みベクタ
WTD_Sys_OldCommBaudrate	dw	?		;18	元のボーレート
WTD_Sys_OldCommCansel	dw	?		;1a	元のキャンセルパターン
WTD_Sys_OldSoundMode	db	?		;1c	元のサウンドモード設定
WTD_Sys_OldSoundOut	db	?		;1d	元のサウンド出力設定
WTD_Sys_OldSoundSweep	dw	?		;1e	元のサウンド・sweep
WTD_Sys_OldSoundNoise	db	?		;20	元のサウンド・noise
WTD_Sys_VolumeMusic	db	?		;21	ソフトウェア音量 演奏
WTD_Sys_VolumeEffect	db	?		;22	ソフトウェア音量 効果音
WTD_Sys_VolumePCM	db	?		;23	ソフトウェア音量 PCM
WTD_Sys_Tempo		dw	?		;24	テンポ
WTD_Sys_TempoCounter	dw	?		;26	テンポカウンタ
WTD_Sys_MusicPart	db	?		;28	演奏のパート数(最大20)
WTD_Sys_EffectPart	db	?		;29	効果音のパート数(最大3)
WTD_Sys			ends			
;===============================================================|
;			フラグビット				|
;===============================================================|
;セット
WTD_Sys_Music		equ	00001h		;演奏中
WTD_Sys_Effect		equ	00002h		;効果音発声中
WTD_Sys_Pcm		equ	00004h		;PCMボイス発生中
WTD_Sys_PcmEnd		equ	00008h		;PCMボイス発生終了
WTD_Sys_Midi		equ	00010h		;MIDIモード(システムでは未使用)
WTD_Sys_5		equ	00020h		;
WTD_Sys_6		equ	00040h		;
WTD_Sys_7		equ	00080h		;
WTD_Sys_ChannelMode1	equ	00100h		;チャンネルモード ch1
WTD_Sys_ChannelMode2	equ	00200h		;チャンネルモード ch2
WTD_Sys_ChannelMode3	equ	00400h		;チャンネルモード ch3
WTD_Sys_ChannelMode4	equ	00800h		;チャンネルモード ch4
WTD_Sys_EffectMask1	equ	01000h		;効果音パートマスク ch1
WTD_Sys_EffectMask2	equ	02000h		;効果音パートマスク ch2
WTD_Sys_EffectMask3	equ	04000h		;効果音パートマスク ch3
WTD_Sys_EffectMask4	equ	08000h		;効果音パートマスク ch4
;---------------------------------------------------------------
;リセット
WTD_Sys_MusicR		equ	0fffeh		;演奏中
WTD_Sys_EffectR		equ	0fffdh		;効果音発声中
WTD_Sys_PcmR		equ	0fffbh		;PCMボイス発生中
WTD_Sys_PcmEndR		equ	0fff7h		;PCMボイス発生終了
WTD_Sys_MidiR		equ	0ffefh		;MIDIモード(システムでは未使用)
WTD_Sys_5R		equ	0ffdfh		;
WTD_Sys_6R		equ	0ffbfh		;
WTD_Sys_7R		equ	0ff7fh		;
WTD_Sys_ChannelMode1R	equ	0feffh		;チャンネルモード ch1
WTD_Sys_ChannelMode2R	equ	0fdffh		;チャンネルモード ch2
WTD_Sys_ChannelMode3R	equ	0fbffh		;チャンネルモード ch3
WTD_Sys_ChannelMode4R	equ	0f7ffh		;チャンネルモード ch4
WTD_Sys_EffectMask1R	equ	0efffh		;効果音パートマスク ch1
WTD_Sys_EffectMask2R	equ	0dfffh		;効果音パートマスク ch2
WTD_Sys_EffectMask3R	equ	0bfffh		;効果音パートマスク ch3
WTD_Sys_EffectMask4R	equ	07fffh		;効果音パートマスク ch4

;****************************************************************
;*								*
;*		ソフトウェアエンベロープ構造体			*
;*								*
;****************************************************************
;===============================================================|
;			構造体定義				|
;===============================================================|
WTD_Emb			struc
WTD_Emb_AR		db	?		;00h	:Attack Rate
WTD_Emb_AS		db	?		;01h	:Attack Speed (001h)
WTD_Emb_AL		db	?		;02h	:Attack Level (0FFh)
WTD_Emb_FL		db	?		;03h	:First Level
WTD_Emb_DR		db	?		;04h	:Decay Rate
WTD_Emb_DS		db	?		;05h	:Decay Speed (081h)
WTD_Emb_DL		db	?		;06h	:Decay Level
WTD_Emb_Null1		db	?		;07h	:未使用
WTD_Emb_SR		db	?		;08h	:Sustain Rate
WTD_Emb_SS		db	?		;09h	:Sustain Speed (081h)
WTD_Emb_SL		db	?		;0Ah	:Sustain Level (000h)
WTD_Emb_Null2		db	?		;0Bh	:未使用
WTD_Emb_RR		db	?		;0Ch	:Relase Rate
WTD_Emb_RS		db	?		;0Dh	:Relase Speed (081h)
WTD_Emb_RL		db	?		;0Eh	:Relase Level (000h)
WTD_Emb_Null3		db	?		;0Fh	:未使用
WTD_Emb			ends				
;****************************************************************
;*								*
;*		曲データ構造体					*
;*								*
;****************************************************************
;===============================================================|
;			ヘッダー構造体定義			|
;===============================================================|
WTD_Mus			struc
WTD_Mus_Name		db	4	dup(?)	;00-03h	:選別子
WTD_Mus_Version		dw	?		;04-05h	:Version
WTD_Mus_Extr		dw	?		;06-07h	:拡張ヘッダサイズ
WTD_Mus_Emb		db	?		;08h	:エンベロープ数量
WTD_Mus_Voice		db	?		;09h	:波形データ数量
WTD_Mus_Part		db	?		;0Ah	:パート数
WTD_Mus_TimeBase	db	?		;0Bh	:４部音符の分割数
WTD_Mus_ExtrAdr		dw	?		;0Ch	:拡張ヘッダのアドレス
WTD_Mus_DataAdr		dw	?		;0Eh	:データのアドレス
WTD_Mus_PartAdr		dw	?		;10h	:曲データアドレス
WTD_Mus			ends
;===============================================================|
;			拡張ヘッダー構造体定義			|
;===============================================================|
WTD_MusEx		struc
;
;			現在、未使用
;
WTD_MusEx		ends

