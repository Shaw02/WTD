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
	void		(far *SoundSetChannel)(int mode);	/* test */
	int			(far *SoundGetChannel)();			/* test */
	void		(far *SoundSetOutput)(int mode);	/* test */
	int			(far *SoundGetOutput)();			/* test */
	int			(far *SoundGetRandom)();			/* test */
	void		(far *SetMusicVolume)(char volume);
	char		(far *GetMusicVoluem)();
	void		(far *SetEffectVolume)(char volume);
	char		(far *GetEffectVolume)();
	void		(far *SetPcmVolume)(char volume);
	char		(far *GetPcmVolume)();
/* Device control test program */
	void		(far *Test_S_Frec)(char ch,int pitch);
	void		(far *Test_S_Volume)(char ch,char volume);
	void		(far *Test_S_Sweep)(char lv,char time);
	void		(far *Test_S_Noise)(char data,char mask);
	void		(far *Test_S_Voice)(char ch,char far *address);
	void		(far *Test_M_KeyOff)(char ch,char key);
	void		(far *Test_M_KeyOn)(char ch,char key,char press);
	void		(far *Test_M_KeyPress)(char ch,char key,char press);
	void		(far *Test_M_ControlB)(char ch,char reg,char data);
	void		(far *Test_M_ControlW)(char ch,char reg,char data);
	void		(far *Test_M_Program)(char ch,char prog);
	void		(far *Test_M_BProgram)(char ch,char bank,char prog);
	void		(far *Test_M_ChPress)(char ch,char press);
	void		(far *Test_M_Pitch)(char ch,char pitch);
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
	char	Head[4];
	long	Size;
	char	Type[4];
	char	Data;
} Riff;

/* 構造体定義	RIFF struct */
typedef struct {
	char	Head[4];
	long	Size;
	char	Data;
} RiffHed;

/* 構造体定義	WAVE fmt */
typedef struct {
	char	Head[4];
	long	Size;
	int		Type;
	int		Channel;
	long	SamplingRate;
	long	SamplingSec;
	int		DataSize;
	int		ChannelSize;
} WaveFmt;

/* 構造体定義	WAVE Data */
typedef struct {
	char	Head[4];
	long	Size;
	char	Data;
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
 *	構造体の詳細は、「取説.PDF」か「wtd_def.asm」を参照。
 */

/* 構造体定義 */
typedef struct {
	int		FlagControl;
	char	FlagTai;
	char	FlagSharp;
	char	FlagFlat;
	char	Channel;
	int		Address;
	char	LoopCount;
	char	LoopCountPointer;
	char	Program;
	char	SweepLevel;
	char	SweepTime;
	int		Leng;
	int		LengCounter;
	int		LengDefault;
	int		KeyOffTime;
	int		KeyOnDelay;
	char	KeyShift;
	char	Key;
	char	KeySet;
	char	KeySetPointer;
	char	AcsentVelocity;
	int		BendSet;
	int		Bend;
	int		BendDetune;
	char	BendLfoDecayRate;
	char	BendLfoSpeedRate;
	int		BendLfoLevel;
	char	BendLfoCount;
	char	BendLfoRateCounter;
	int		BendLfoLevelSet;
	char	BendLfoCountCounter;
	char	BendEmbAddress;
	char	BendEmbRate;
	char	BendEmbCounter;
	char	BendEmbMaxMin;
	char	BendEmbLevelSet;
	char	Pan;
	char	ExprPanSet;
	char	ExprSet;
	char	Expr;
	int		ExprDetune;
	char	ExprLfoDecayRate;
	char	ExprLfoSpeedRate;
	int		ExprLfoLevel;
	char	ExprLfoCount;
	char	ExprLfoRateCounter;
	int		ExprLfoLevelSet;
	char	ExprLfoCountCounter;
	char	ExprEmbAddress;
	char	ExprEmbRate;
	char	ExprEmbCounter;
	char	ExprEmbMaxMin;
	char	ExprEmbLevelSet;
	char	WorkAddress;
	char	OctaveSet;
	char	Octave;
	char	GateTime8;
	int		GateTimeStepLast;
	int		GateTimeStepFirst;
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
#define	WTD_Ctrl_BendLfo		0x0001
#define	WTD_Ctrl_BendEmb		0x0002
#define	WTD_Ctrl_ExprLfo		0x0004
#define	WTD_Ctrl_ExprEmb		0x0008
#define	WTD_Ctrl_WorkSw			0x0010
#define	WTD_Ctrl_WorkCy			0x0020
#define	WTD_Ctrl_WorkZe			0x0040
#define	WTD_Ctrl_WorkSi			0x0080
#define	WTD_Ctrl_EmbVol			0x0100
#define	WTD_Ctrl_EmbFreq		0x0200
#define	WTD_Ctrl_Vol0			0x0400
#define	WTD_Ctrl_Acsent			0x0800
#define	WTD_Ctrl_Null_2			0x1000
#define	WTD_Ctrl_Null_3			0x2000
#define	WTD_Ctrl_Effect			0x4000
#define	WTD_Ctrl_PlayEnd		0x8000
/* Reset */
#define	WTD_Ctrl_BendLfoR		0xFFFE
#define	WTD_Ctrl_BendEmbR		0xFFFD
#define	WTD_Ctrl_ExprLfoR		0xFFFB
#define	WTD_Ctrl_ExprEmbR		0xFFF7
#define	WTD_Ctrl_WorkSwR		0xFFEF
#define	WTD_Ctrl_WorkCyR		0xFFDF
#define	WTD_Ctrl_WorkZeR		0xFFBF
#define	WTD_Ctrl_WorkSiR		0xFF7F
#define	WTD_Ctrl_EmbVolR		0xFEFF
#define	WTD_Ctrl_EmbFreqR		0xFDFF
#define	WTD_Ctrl_Vol0R			0xFBFF
#define	WTD_Ctrl_AcsentR		0xF7FF
#define	WTD_Ctrl_Null_2R		0xEFFF
#define	WTD_Ctrl_Null_3R		0xDFFF
#define	WTD_Ctrl_EffectR		0xBFFF
#define	WTD_Ctrl_PlayEndR		0x7FFF

/********************************************/
/*											*/
/*			パート共通ワーク構造体			*/
/*											*/
/********************************************/
/*
 *	構造体の詳細は、「取説.PDF」か「wtd_def.asm」を参照。
 */
typedef struct {
	int		Flag;
	int		ProgramOffset;
	int		ProgramSegment;
	int		MusicOffset;
	int		MusicSegment;
	int		EffectOffset;
	int		EffectSegment;
	int		PcmOffset;
	int		PcmSegment;
	int		StayOutMask;
	int		OldIntvector[2];
	int		OldCommBaudrate;
	int		OldCommCansel;
	char	OldSoundMode;
	char	OldSoundOut;
	int		OldSoundSweep;	
	char	OldSoundNoise;
	char	VolumeMusic;
	char	VolumeEffect;
	char	VolumePCM;
	int		Tempo;
	int		TempoCounter;
	char	MusicPart;
	char	EffectPart;
} Wtd_Sys;

/* Flag bit */
/* Set */
#define	WTD_Sys_Music			0x0001
#define	WTD_Sys_Effect			0x0002
#define	WTD_Sys_Pcm				0x0004
#define	WTD_Sys_PcmEnd			0x0008
#define	WTD_Sys_Midi			0x0010
#define	WTD_Sys_5				0x0020
#define	WTD_Sys_6				0x0040
#define	WTD_Sys_7				0x0080
#define	WTD_Sys_ChannelMode1	0x0100
#define	WTD_Sys_ChannelMode2	0x0200
#define	WTD_Sys_ChannelMode3	0x0400
#define	WTD_Sys_ChannelMode4	0x0800
#define	WTD_Sys_EffectMask1		0x1000
#define	WTD_Sys_EffectMask2		0x2000
#define	WTD_Sys_EffectMask3		0x4000
#define	WTD_Sys_EffectMask4		0x8000
/* Reset */
#define	WTD_Sys_MusicR			0xFFFE
#define	WTD_Sys_EffectR			0xFFFD
#define	WTD_Sys_PcmR			0xFFFB
#define	WTD_Sys_PcmEndR			0xFFF7
#define	WTD_Sys_MidiR			0xFFEF
#define	WTD_Sys_5R				0xFFDF
#define	WTD_Sys_6R				0xFFBF
#define	WTD_Sys_7R				0xFF7F
#define	WTD_Sys_ChannelMode1R	0xFEFF
#define	WTD_Sys_ChannelMode2R	0xFDFF
#define	WTD_Sys_ChannelMode3R	0xFBFF
#define	WTD_Sys_ChannelMode4R	0xF7FF
#define	WTD_Sys_EffectMask1R	0xEFFF
#define	WTD_Sys_EffectMask2R	0xDFFF
#define	WTD_Sys_EffectMask3R	0xBFFF
#define	WTD_Sys_EffectMask4R	0x7FFF

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
