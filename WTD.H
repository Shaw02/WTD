/****************************************************************/
/*																*/
/*				Wander Swan Total Sound Driver					*/
/*								define file						*/
/*										for C Language			*/
/*																*/
/*								Programmed by					*/
/*										A.Watanabe				*/
/*																*/
/****************************************************************/
/*
 *	IL構造体の定義以外は、'wtd_def.asm'と同等の定義となっています。
 */

#include	<sys/indirect.h>

/********************************************/
/*											*/
/*				IL構造体の定義				*/
/*											*/
/********************************************/
/* 構造体定義 */
typedef struct {
	IL		super;
	int			(far *Stay)();
	int			(far *StayOut)();
	void		(far *Init)();
	char		(far *MusicPlay)(char far *Music);
	void		(far *MusicStop)();
	char		(far *EffectPlay)(char far *Effect);
	void		(far *EffectStop)();
	char		(far *PcmPlay)(char far *Pcm);
	void		(far *PcmStop)();
	char		(far *PcmVoiceSet)(char no,char far *wave);
	char		(far *SoftEmbSet)(char no,char far *emb);
	void	far	*(far *ChangeFar)(void far *add);
	void		(far *SoundSetChannel)(int mode);
	int			(far *SoundGetChannel)();
	void		(far *SoundSetOutput)(int mode);
	int			(far *SoundGetOutput)();
	int			(far *SoundGetRandom)();
	void		(far *SetMusicVolume)(char volume);
	char		(far *GetMusicVoluem)();
	void		(far *SetEffectVolume)(char volume);
	char		(far *GetEffectVolume)();
	void		(far *SetPcmVolume)(char volume);
	char		(far *GetPcmVolume)();
} WtdIL;

/********************************************/
/*											*/
/*					定数					*/
/*											*/
/********************************************/
/* Wander Swan far address */
#define	IRAM_Segment		0x00000000L			/* 本体RAM */
#define	SRAM_Segment		(BANK_SRAM_ADDRESS)
#define	FROM_Segment		(BANK_ROM0_ADDRESS)

/* HBLANK Interrupt vector address*/
#define	Hblank_interrupt	0x00bc	/*  0x2F * 4  */

/* 構造体定義 RIFF Header */
typedef struct {
	char	Head[4];		/* 'RIFF' */
	long	Size;			/* File Size(全体-8) */
	char	Type[4];		/* 'WAVE' */
	char	Data;			/* データ */
} Riff;

/* 構造体定義	RIFF struct */
typedef struct {
	char	Head[4];		/* ヘッダ */
	long	Size;			/* ヘッダのデータのサイズ */
	char	Data;			/* ヘッダのデータ */
} RiffHed;

/* 構造体定義	WAVE fmt */
typedef struct {
	char	Head[4];		/* 'fmt ' */
	long	Size;			/* 16	[byte] */
	int		Type;			/* 1	(wave) */
	int		Channel;		/* 1	(mono) */
	long	SamplingRate;	/* 11025	[Hz] */
	long	SamplingSec;	/* 11025	[Byte] */
	int		DataSize;		/* 1	[Byte] */
	int		ChannelSize;	/* 8	[bit] */
} WaveFmt;

/* 構造体定義	WAVE Data */
typedef struct {
	char	Head[4];		/* 'data' */
	long	Size;			/* Data Size */
	char	Data;			/* wave data */
} WaveData;

/********************************************/
/*											*/
/*			ワーク領域アドレス				*/
/*											*/
/********************************************/
#define	WTD_WorkAdd_User	0x0000	/* ユーザ用ワーク */
#define	WTD_WorkAdd_Wave	0x0100	/* 音色 */
#define	WTD_WorkAdd_Emb		0x0200	/* エンベロープ */
#define	WTD_WorkAdd_System	0x0380	/* パート共通構造体 */

#define	WTD_WorkAdd_ECh0	0x0400	/* Effect ch0 */
#define	WTD_WorkAdd_ECh1	0x0480	/* Effect ch1 */
#define	WTD_WorkAdd_ECh2	0x0500	/* Effect ch2 */
#define	WTD_WorkAdd_PCM		0x0580	/* PCM Voice */

#define	WTD_WorkAdd_Ch0		0x0600	/* パート個別構造体 */
#define	WTD_WorkAdd_Ch1		0x0680	
#define	WTD_WorkAdd_Ch2		0x0700	
#define	WTD_WorkAdd_Ch3		0x0780	
#define	WTD_WorkAdd_Ch4		0x0800	
#define	WTD_WorkAdd_Ch5		0x0880	
#define	WTD_WorkAdd_Ch6		0x0900	
#define	WTD_WorkAdd_Ch7		0x0980	
#define	WTD_WorkAdd_Ch8		0x0a00	
#define	WTD_WorkAdd_Ch9		0x0a80	
#define	WTD_WorkAdd_Ch10	0x0b00	
#define	WTD_WorkAdd_Ch11	0x0b80	
#define	WTD_WorkAdd_Ch12	0x0c00	
#define	WTD_WorkAdd_Ch13	0x0c80	
#define	WTD_WorkAdd_Ch14	0x0d00	
#define	WTD_WorkAdd_Ch15	0x0d80	
#define	WTD_WorkAdd_Ch16	0x0e00	
#define	WTD_WorkAdd_Ch17	0x0e80	
#define	WTD_WorkAdd_Ch18	0x0f00	
#define	WTD_WorkAdd_Ch19	0x0f80	

#define	WTD_WorkChSize		0x0080	/* パート個別構造体のサイズ */
#define	WTD_WorkSize		0x1000	/* ワーク全体のサイズ */

#define	WTD_WorkAdd_End		WTD_WorkSize

/********************************************/
/*											*/
/*			パート個別ワーク構造体			*/
/*											*/
/********************************************/
/*
 *	構造体の詳細は、Developer's Manualを参照。
 */

/* 構造体定義 */
typedef struct {
	int		FlagControl;			/* 00-01	フラグ */
	char	FlagTai;				/* 02		タイフラグ */
	char	FlagSharp;				/* 03		#フラグ */
	char	FlagFlat;				/* 04		bフラグ */
	char	Channel;				/* 05		ﾁｬﾝﾈﾙ/ﾄﾗｯｸ */
	int		Address;				/* 06-07	演奏中のｱﾄﾞﾚｽ */
	char	LoopCount[8];			/* 08-0F	ループ回数/PCM Address */
	char	LoopCountPointer;		/* 10		上記ﾎﾟｲﾝﾀ */
	char	Program;				/* 11		音色 */
	char	SweepLevel;				/* 12		ｽｳｨｰﾌﾟ値/ﾉｲｽﾞﾓｰﾄﾞ */
	char	SweepTime;				/* 13		ｽｳｨｰﾌﾟ時間 */
	int		Leng;					/* 14-15	音長 */
	int		LengCounter;			/* 16-17	音長カウンター */
	int		LengDefault;			/* 18-19	ﾃﾞﾌｫﾙﾄの音長 */
	int		KeyOffTime;				/* 1A-1B	ｹﾞｰﾄﾀｲﾑ制御値 */
	int		KeyOnDelay;				/* 1C-1D	ｷｰｵﾝﾃﾞｨﾚｲ */
	char	KeyShift;				/* 1E		移調値 */
	char	Key;					/* 1F		音程 */
	char	KeySet[8];				/* 20-27	出力した音程 */
	char	KeySetPointer;			/* 28		上記ﾎﾟｲﾝﾀ */
	char	AcsentVelocity;			/* 29		アクセント値 */
	int		BendSet;				/* 2A-2B	出力した周波数 */
	int		Bend;					/* 2C-2D	指定周波数 */
	int		BendDetune;				/* 2E-2F	ディチューン */
	char	BendLfoDecayRate;		/* 30		LFOディケイレイト */
	char	BendLfoSpeedRate;		/* 31		LFOスピード */
	int		BendLfoLevel;			/* 32-33	LFO変位ﾚﾍﾞﾙ */
	char	BendLfoCount;			/* 34		LFO変化回数 */
	char	BendLfoRateCounter;		/* 35		LFOレイト用カウンタ */
	int		BendLfoLevelSet;		/* 36-37	LFO現在の変位ﾚﾍﾞﾙ */
	char	BendLfoCountCounter;	/* 38		LFO回数用カウンタ */
	char	BendEmbAddress;			/* 39		EMB番号（ｱﾄﾞﾚｽ） */
	char	BendEmbRate;			/* 3A		EMBレイト */
	char	BendEmbCounter;			/* 3B		EMBカウンター */
	char	BendEmbMaxMin;			/* 3C		EMB最大／最小値 */
	char	BendEmbLevelSet;		/* 3D		EMB変位ﾚﾍﾞﾙ */
	char	Pan;					/* 3E		パンポット */
	char	ExprPanSet;				/* 3F		出力/ｳﾞｪﾛｼﾃｨｰ */
	char	ExprSet;				/* 40		出力音量/ｴｸｽﾌﾟﾚｯｼｮﾝ */
	char	Expr;					/* 41		音量/ｴｸｽﾌﾟﾚｯｼｮﾝ */
	int		ExprDetune;				/* 42-43	音量増減値 */
	char	ExprLfoDecayRate;		/* 44		LFOディケイレイト */
	char	ExprLfoSpeedRate;		/* 45		LFOスピード */
	int		ExprLfoLevel;			/* 46-47	LFO変位ﾚﾍﾞﾙ */
	char	ExprLfoCount;			/* 48		LFO変化回数 */
	char	ExprLfoRateCounter;		/* 49		LFOレイト用カウンタ */
	int		ExprLfoLevelSet;		/* 4A-4B	LFO現在の変位ﾚﾍﾞﾙ */
	char	ExprLfoCountCounter;	/* 4C		LFO回数用カウンタ */
	char	ExprEmbAddress;			/* 4D		EMB番号（ｱﾄﾞﾚｽ） */
	char	ExprEmbRate;			/* 4E		EMBレイト */
	char	ExprEmbCounter;			/* 4F		EMBカウンター */
	char	ExprEmbMaxMin;			/* 50		EMB最大／最小値 */
	char	ExprEmbLevelSet;		/* 51		EMB変位ﾚﾍﾞﾙ */
	char	WorkAddress;			/* 52		ワークｱﾄﾞﾚｽ上位8BIT */
	char	OctaveSet;				/* 53		出力したオクターブ */
	char	Octave;					/* 54		指定オクターブ */
	char	GateTime8;				/* 55		ｹﾞｰﾄﾀｲﾑ（Q,U) */
	int		GateTimeStepLast;		/* 56-57	ｹﾞｰﾄﾀｲﾑ(q) */
	int		GateTimeStepFirst;		/* 58-59	ｹﾞｰﾄﾀｲﾑ(u) */
	char	VolumeUpDown;			/* 5A		相対ボリュームの増減値 */
} Wtd;

/* 構造体位置 */
#define	WTD_BendLFO		Wtd 0.BendLFO
#define	WTD_ExprLFO		Wtd 0.ExprLFO
#define	WTD_BendEmb		Wtd 0.BendEmb
#define	WTD_ExprEmb		Wtd 0.ExprEmb

/* ChLFO構造体 */
typedef struct{
	char	DecayRate;		/* LFOディケイレイト */
	char	SpeedRate;		/* LFOスピード */
	int		Level;			/* LFO変位ﾚﾍﾞﾙ */
	char	Count;			/* LFO変化回数 */
	char	RateCounter;	/* LFOレイト用カウンタ */
	int		LevelSet;		/* LFO現在の変位ﾚﾍﾞﾙ */
	char	CountCounter;	/* LFO回数用カウンタ */
} WTD_ChLfo;

/* ChEmb構造体 */
typedef struct{
	char	Address;		/* EMB番号（ｱﾄﾞﾚｽ） */
	char	Rate;			/* EMBレイト */
	char	Counter;		/* EMBカウンター */
	char	MaxMin;			/* EMB最大／最小値 */
	char	LevelSet;		/* EMB変位ﾚﾍﾞﾙ */
} WTD_ChEmb;

/* Flag bit */
/* Set */
#define	WTD_Ctrl_BendLfo		00001h	/* 音程ＬＦＯスイッチ */
#define	WTD_Ctrl_BendEmb		00002h	/* 音程エンベロープスイッチ */
#define	WTD_Ctrl_ExprLfo		00004h	/* 音量ＬＦＯスイッチ */
#define	WTD_Ctrl_ExprEmb		00008h	/* 音量エンベロープスイッチ */
#define	WTD_Ctrl_PanLfo			00010h	/* パンＬＦＯスイッチ */
#define	WTD_Ctrl_PanEmb			00020h	/* パンエンベロープスイッチ */
#define	WTD_Ctrl_Acsent			00040h	/* 次の音階はアクセント */
#define	WTD_Ctrl_EmbFreq		00080h	/* 音程エンベロープ 上位bit */
#define	WTD_Ctrl_EmbVol			00100h	/* 音量エンベロープ 上位bit */
#define	WTD_Ctrl_EmbPan			00200h	/* パンエンベロープ 上位bit */
#define	WTD_Ctrl_Vol0			00400h	/* 音量＝０ */
#define	WTD_Ctrl_WorkSw			00800h	/* 次のコマンドは、ワーク参照 */
#define	WTD_Ctrl_WorkCy			01000h	/* ワーク演算結果、オーバーフロー */
#define	WTD_Ctrl_WorkZe			02000h	/* ワーク演算結果、０になった。 */
#define	WTD_Ctrl_Effect			04000h	/* このパートは効果音か？ */
#define	WTD_Ctrl_PlayEnd		08000h	/* 演奏終了 */
/* Reset */
#define	WTD_Ctrl_BendLfoR		0fffeh	/*	;音程ＬＦＯスイッチ */
#define	WTD_Ctrl_BendEmbR		0fffdh	/*	;音程エンベロープスイッチ */
#define	WTD_Ctrl_ExprLfoR		0fffbh	/*	;音量ＬＦＯスイッチ */
#define	WTD_Ctrl_ExprEmbR		0fff7h	/*	;音量エンベロープスイッチ */
#define	WTD_Ctrl_PanLfoR		0ffefh	/*	;パンＬＦＯスイッチ */
#define	WTD_Ctrl_PamEmbR		0ffdfh	/*	;パンエンベロープスイッチ */
#define	WTD_Ctrl_AcsentR		0ffbfh	/*	;次の音階はアクセント */
#define	WTD_Ctrl_EmbFreqR		0ff7fh	/*	;音程エンベロープ 上位bit */
#define	WTD_Ctrl_EmbVolR		0feffh	/*	;音量エンベロープ 上位bit */
#define	WTD_Ctrl_EmbPanR		0fdffh	/*	;パンエンベロープ 上位bit */
#define	WTD_Ctrl_Vol0R			0fbffh	/*	;音量＝０ */
#define	WTD_Ctrl_WorkSwR		0f7ffh	/*	;次のコマンドは、ワーク参照 */
#define	WTD_Ctrl_WorkCyR		0efffh	/*	;ワーク演算結果、オーバーフロー */
#define	WTD_Ctrl_WorkZeR		0dfffh	/*	;ワーク演算結果、０になった。 */
#define	WTD_Ctrl_EffectR		0bfffh	/*	;このパートは効果音か？ */
#define	WTD_Ctrl_PlayEndR		07fffh	/*	;演奏終了 */

/********************************************/
/*											*/
/*			パート共通ワーク構造体			*/
/*											*/
/********************************************/
/*
 *	構造体の詳細は、Developer's Manualを参照。
 */
typedef struct {
	int		Flag;				/* Flag */
	int		ProgramOffset;		/* Program Offset Address */
	int		ProgramSegment;		/* Program Segment Address */
	int		MusicOffset;		/* Music Offset Address*/
	int		MusicSegment;		/* Music Segment Address */
	int		EffectOffset;		/* Effect Offset Address */
	int		EffectSegment;		/* Effect Segment Address */
	int		PcmOffset;			/* Pcm Offset Address */
	int		PcmSegment;			/* Pcm Segment Address */
	int		StayOutMask;		/* 常駐解除禁止 */
	int		OldIntvector[2];	/* 前の割り込みベクタ */
	int		OldCommBaudrate;	/* 元のボーレート */
	int		OldCommCansel;		/* 元のキャンセルパターン */
	char	OldSoundMode;		/* 元のサウンドモード設定 */
	char	OldSoundOut;		/* 元のサウンド出力設定 */
	int		OldSoundSweep;		/* 元のサウンド・sweep */
	char	OldSoundNoise;		/* 元のサウンド・noise */
	char	VolumeMusic;		/* ソフトウェア音量 演奏 */
	char	VolumeEffect;		/* ソフトウェア音量 効果音 */
	char	VolumePCM;			/* ソフトウェア音量 PCM */
	int		Tempo;				/* テンポ */
	int		TempoCounter;		/* テンポカウンタ */
	char	MusicPart;			/* 演奏のパート数(最大20) */
	char	EffectPart;			/* 効果音のパート数(最大3) */
} Wtd_Sys;

/* Flag bit */
/* Set */
#define	WTD_Sys_Music			0x0001	/* 演奏中 */
#define	WTD_Sys_Effect			0x0002	/* 効果音発声中 */
#define	WTD_Sys_Pcm				0x0004	/* PCMボイス発生中 */
#define	WTD_Sys_PcmEnd			0x0008	/* PCMボイス発生終了 */
#define	WTD_Sys_Midi			0x0010	/* MIDIモード(システムでは未使用) */
#define	WTD_Sys_5				0x0020	/* NULL */
#define	WTD_Sys_6				0x0040	/* NULL */
#define	WTD_Sys_7				0x0080	/* NULL */
#define	WTD_Sys_ChannelMode1	0x0100	/* チャンネルモード ch1 */
#define	WTD_Sys_ChannelMode2	0x0200	/* チャンネルモード ch2 */
#define	WTD_Sys_ChannelMode3	0x0400	/* チャンネルモード ch3 */
#define	WTD_Sys_ChannelMode4	0x0800	/* チャンネルモード ch4 */
#define	WTD_Sys_EffectMask1		0x1000	/* 効果音パートマスク ch1 */
#define	WTD_Sys_EffectMask2		0x2000	/* 効果音パートマスク ch2 */
#define	WTD_Sys_EffectMask3		0x4000	/* 効果音パートマスク ch3 */
#define	WTD_Sys_EffectMask4		0x8000	/* 効果音パートマスク ch4 */
/* Reset */
#define	WTD_Sys_MusicR			0xFFFE	/* 演奏中 */
#define	WTD_Sys_EffectR			0xFFFD	/* 効果音発声中 */
#define	WTD_Sys_PcmR			0xFFFB	/* PCMボイス発生中 */
#define	WTD_Sys_PcmEndR			0xFFF7	/* PCMボイス発生終了 */
#define	WTD_Sys_MidiR			0xFFEF	/* MIDIモード(システムでは未使用) */
#define	WTD_Sys_5R				0xFFDF	/* NULL */
#define	WTD_Sys_6R				0xFFBF	/* NULL */
#define	WTD_Sys_7R				0xFF7F	/* NULL */
#define	WTD_Sys_ChannelMode1R	0xFEFF	/* チャンネルモード ch1 */
#define	WTD_Sys_ChannelMode2R	0xFDFF	/* チャンネルモード ch2 */
#define	WTD_Sys_ChannelMode3R	0xFBFF	/* チャンネルモード ch3 */
#define	WTD_Sys_ChannelMode4R	0xF7FF	/* チャンネルモード ch4 */
#define	WTD_Sys_EffectMask1R	0xEFFF	/* 効果音パートマスク ch1 */
#define	WTD_Sys_EffectMask2R	0xDFFF	/* 効果音パートマスク ch2 */
#define	WTD_Sys_EffectMask3R	0xBFFF	/* 効果音パートマスク ch3 */
#define	WTD_Sys_EffectMask4R	0x7FFF	/* 効果音パートマスク ch4 */

/********************************************/
/*											*/
/*		ソフトウェアエンベロープ構造体		*/
/*											*/
/********************************************/
typedef struct {
	char	AR;				/* Attack Rate */
	char	AS;				/* Attack Speed */
	char	AL;				/* Attack Level */
	char	FL;				/* First Level */
	char	DR;				/* Decay Rate */
	char	DS;				/* Decay Speed */
	char	DL;				/* Decay Level */
	char	Null1;			/* 未使用 */
	char	SR;				/* Sustain Rate */
	char	SS;				/* Sustain Speed */
	char	SL;				/* Sustain Level */
	char	Null2;			/* 未使用 */
	char	RR;				/* Relase Rate */
	char	RS;				/* Relase Speed */
	char	RL;				/* Relase Level */
	char	Null3;			/* 未使用 */
} Wtd_Emb;
/********************************************/
/*											*/
/*		曲データ構造体						*/
/*											*/
/********************************************/
/* ヘッダ構造体 */
typedef struct{
	char	Name[4];		/* 00-03h	:選別子 "'WTD',0" */
	char	VersionN;		/* 04h		:Version 整数部 */
	char	VersionS;		/* 05h		:Version 小数部 */
	int		Extr;			/* 06-07h	:拡張ヘッダサイズ */
	char	Emb;			/* 08h		:エンベロープ数量 */
	char	Voice;			/* 09h		:波形データ数量 */
	char	Part;			/* 0Ah		:パート数 */
	char	TimeBase;		/* 0Bh		:４部音符の分割数 */
	void	*ExtrAdr;		/* 0C-0Dh	:拡張ヘッダのアドレス */
	char	*DataAdr;		/* 0E-0Fh	:データのアドレス */
	void	*(*PartAdr);	/* 10-11h	:曲データ先頭アドレスのアドレス */
} WTD_Mus;

/* 拡張ヘッダ構造体 */
typedef struct{
	char	Null;			/* この構造体は、未使用 */
} WTD_MusEx;
