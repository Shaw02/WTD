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
 *	IL�\���̂̒�`�ȊO�́A'wtd_def.asm'�Ɠ����̒�`�ƂȂ��Ă��܂��B
 *	�ڍׂ́ADeveloper's Manual���Q�Ƃ̂��ƁB
 */

#ifndef _IL_WTD_H_
#define _IL_WTD_H_

#include	<sys/types.h>
#include	<sys/indirect.h>
#include	<sys/process.h>

/********************************************/
/*											*/
/*				IL�\���̂̒�`				*/
/*											*/
/********************************************/
/* �\���̒�` */
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
	void		(far *SetFIFO)(int size,char far *FIFO);
} WtdIL;

/********************************************/
/*											*/
/*					�萔					*/
/*											*/
/********************************************/
/*==========================================*/
/* Wander Swan far address					*/
/*==========================================*/
#define	IRAM_Segment		0x00000000L			/* �{��RAM */
#define	SRAM_Segment		(BANK_SRAM_ADDRESS)
#define	FROM_Segment		(BANK_ROM0_ADDRESS)

/*==========================================*/
/* HBLANK Interrupt vector address			*/
/*==========================================*/
#define	CommEnpty_intvector	0x00a0	/*  0x28 * 4  */
#define	Hblank_interrupt	0x00bc	/*  0x2F * 4  */

/*==========================================*/
/* ���[�N�̈�A�h���X						*/
/*==========================================*/
#define	WTD_WorkAdd_User	0x0000	/* ���[�U�p���[�N */
#define	WTD_WorkAdd_Wave	0x0100	/* ���F */
#define	WTD_WorkAdd_Emb		0x0200	/* �G���x���[�v */
#define	WTD_WorkAdd_System	0x0380	/* �p�[�g���ʍ\���� */

#define	WTD_WorkAdd_ECh0	0x0400	/* Effect ch0 */
#define	WTD_WorkAdd_ECh1	0x0480	/* Effect ch1 */
#define	WTD_WorkAdd_ECh2	0x0500	/* Effect ch2 */
#define	WTD_WorkAdd_PCM		0x0580	/* PCM Voice */

#define	WTD_WorkAdd_Ch0		0x0600	/* �p�[�g�ʍ\���� */
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

#define	WTD_WorkChSize		0x0080	/* �p�[�g�ʍ\���̂̃T�C�Y */
#define	WTD_WorkSize		0x1000	/* ���[�N�S�̂̃T�C�Y */

#define	WTD_WorkAdd_End		WTD_WorkSize

/********************************************/
/*											*/
/*			�p�[�g�ʃ��[�N�\����			*/
/*											*/
/********************************************/
/*==========================================*/
/* Micro Soft  RIFF and Wave data formats	*/
/*==========================================*/
/* �\���̒�` RIFF Header */
typedef struct {
	char	Head[4];		/* 'RIFF' */
	long	Size;			/* File Size(�S��-8) */
	char	Type[4];		/* 'WAVE' */
	char	Data;			/* �f�[�^ */
} Riff;

/* �\���̒�`	RIFF struct */
typedef struct {
	char	Head[4];		/* �w�b�_ */
	long	Size;			/* �w�b�_�̃f�[�^�̃T�C�Y */
	char	Data;			/* �w�b�_�̃f�[�^ */
} RiffHed;

/* �\���̒�`	WAVE fmt */
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

/* �\���̒�`	WAVE Data */
typedef struct {
	char	Head[4];		/* 'data' */
	long	Size;			/* Data Size */
	char	Data;			/* wave data */
} WaveData;

/*==========================================*/
/* �p�[�g�ʃ��[�N�\����					*/
/*==========================================*/
/* �\���̒�` */
typedef struct {
	int		FlagControl;			/* 00-01	�t���O */
	char	FlagTai;				/* 02		�^�C�t���O */
	char	FlagSharp;				/* 03		#�t���O */
	char	FlagFlat;				/* 04		b�t���O */
	char	Channel;				/* 05		�����/�ׯ� */
	int		Address;				/* 06-07	���t���̱��ڽ */
	char	LoopCount[8];			/* 08-0F	���[�v��/PCM Address */
	char	LoopCountPointer;		/* 10		��L�߲�� */
	char	Program;				/* 11		���F */
	char	SweepLevel;				/* 12		�����ߒl/ɲ��Ӱ�� */
	char	SweepTime;				/* 13		�����ߎ��� */
	int		Leng;					/* 14-15	���� */
	int		LengCounter;			/* 16-17	�����J�E���^�[ */
	int		LengDefault;			/* 18-19	��̫�Ẳ��� */
	int		KeyOffTime;				/* 1A-1B	�ް���ѐ���l */
	int		KeyOnDelay;				/* 1C-1D	�����ިڲ */
	char	KeyShift;				/* 1E		�ڒ��l */
	char	Key;					/* 1F		���� */
	char	KeySet[8];				/* 20-27	�o�͂������� */
	char	KeySetPointer;			/* 28		��L�߲�� */
	char	AcsentVelocity;			/* 29		�A�N�Z���g�l */
	int		BendSet;				/* 2A-2B	�o�͂������g�� */
	int		Bend;					/* 2C-2D	�w����g�� */
	int		BendDetune;				/* 2E-2F	�f�B�`���[�� */
	char	BendLfoDecayRate;		/* 30		LFO�f�B�P�C���C�g */
	char	BendLfoSpeedRate;		/* 31		LFO�X�s�[�h */
	int		BendLfoLevel;			/* 32-33	LFO�ψ����� */
	char	BendLfoCount;			/* 34		LFO�ω��� */
	char	BendLfoRateCounter;		/* 35		LFO���C�g�p�J�E���^ */
	int		BendLfoLevelSet;		/* 36-37	LFO���݂̕ψ����� */
	char	BendLfoCountCounter;	/* 38		LFO�񐔗p�J�E���^ */
	char	BendEmbAddress;			/* 39		EMB�ԍ��i���ڽ�j */
	char	BendEmbRate;			/* 3A		EMB���C�g */
	char	BendEmbCounter;			/* 3B		EMB�J�E���^�[ */
	char	BendEmbMaxMin;			/* 3C		EMB�ő�^�ŏ��l */
	char	BendEmbLevelSet;		/* 3D		EMB�ψ����� */
	char	Null_3E;				/* 3E		���g�p */
	char	ExprPanSet;				/* 3F		�o��/�ުۼè� */
	char	ExprSet;				/* 40		�o�͉���/�����گ��� */
	char	Expr;					/* 41		����/�����گ��� */
	int		ExprDetune;				/* 42-43	���ʑ����l */
	char	ExprLfoDecayRate;		/* 44		LFO�f�B�P�C���C�g */
	char	ExprLfoSpeedRate;		/* 45		LFO�X�s�[�h */
	int		ExprLfoLevel;			/* 46-47	LFO�ψ����� */
	char	ExprLfoCount;			/* 48		LFO�ω��� */
	char	ExprLfoRateCounter;		/* 49		LFO���C�g�p�J�E���^ */
	int		ExprLfoLevelSet;		/* 4A-4B	LFO���݂̕ψ����� */
	char	ExprLfoCountCounter;	/* 4C		LFO�񐔗p�J�E���^ */
	char	ExprEmbAddress;			/* 4D		EMB�ԍ��i���ڽ�j */
	char	ExprEmbRate;			/* 4E		EMB���C�g */
	char	ExprEmbCounter;			/* 4F		EMB�J�E���^�[ */
	char	ExprEmbMaxMin;			/* 50		EMB�ő�^�ŏ��l */
	char	ExprEmbLevelSet;		/* 51		EMB�ψ����� */
	char	WorkAddress;			/* 52		���[�N���ڽ���8BIT */
	char	OctaveSet;				/* 53		�o�͂����I�N�^�[�u */
	char	Octave;					/* 54		�w��I�N�^�[�u */
	char	GateTime8;				/* 55		�ް���сiQ,U) */
	int		GateTimeStepLast;		/* 56-57	�ް����(q) */
	int		GateTimeStepFirst;		/* 58-59	�ް����(u) */
	char	VolumeUpDown;			/* 5A		���΃{�����[���̑����l */
	int		ModDecay;				/* 5B-5C	Ӽޭڰ��� �ި��ڲ� */
	char	ModLevel;				/* 5D		Ӽޭڰ��� ���� */
	char	ModLevelSet;			/* 5E		���݂�Ӽޭڰ��� ���� */
	char	Null_5F;				/* 5F		���g�p */
	char	PanSet;					/* 60		�o�̓p���|�b�g */
	char	Pan;					/* 61		�p���|�b�g */
	int		PanDetune;				/* 62-63	���ʑ����l */
	char	PanLfoDecayRate;		/* 64		LFO�f�B�P�C���C�g */
	char	PanLfoSpeedRate;		/* 65		LFO�X�s�[�h */
	int		PanLfoLevel;			/* 66-67	LFO�ψ����� */
	char	PanLfoCount;			/* 68		LFO�ω��� */
	char	PanLfoRateCounter;		/* 69		LFO���C�g�p�J�E���^ */
	int		PanLfoLevelSet;			/* 6A-6B	LFO���݂̕ψ����� */
	char	PanLfoCountCounter;		/* 6C		LFO�񐔗p�J�E���^ */
	char	PanEmbAddress;			/* 6D		EMB�ԍ��i���ڽ�j */
	char	PanEmbRate;				/* 6E		EMB���C�g */
	char	PanEmbCounter;			/* 6F		EMB�J�E���^�[ */
	char	PanEmbMaxMin;			/* 60		EMB�ő�^�ŏ��l */
	char	PanEmbLevelSet;			/* 61		EMB�ψ����� */
	int		ProgramRate;			/* 62-63	���F��ς���B */
	char	Program1st;				/* 64		���F�̏����l */
	char	Program2nd;				/* 65		�o���ω� */
	char	Program3rd;				/* 66		KeyOff�㉹�F */
} Wtd;

/* �\���̈ʒu */
#define	WTD_BendLFO		Wtd.BendLfoDecayRate
#define	WTD_ExprLFO		Wtd.ExprLfoDecayRate
#define	WTD_PanLFO		Wtd.PanLfoDecayRate
#define	WTD_BendEmb		Wtd.BendEmbAddress
#define	WTD_ExprEmb		Wtd.ExprEmbAddress
#define	WTD_PanEmb		Wtd.PanEmbAddress

/* ChLFO�\���� */
typedef struct{
	char	DecayRate;		/* LFO�f�B�P�C���C�g */
	char	SpeedRate;		/* LFO�X�s�[�h */
	int		Level;			/* LFO�ψ����� */
	char	Count;			/* LFO�ω��� */
	char	RateCounter;	/* LFO���C�g�p�J�E���^ */
	int		LevelSet;		/* LFO���݂̕ψ����� */
	char	CountCounter;	/* LFO�񐔗p�J�E���^ */
} WTD_ChLfo;

/* ChEmb�\���� */
typedef struct{
	char	Address;		/* EMB�ԍ��i���ڽ�j */
	char	Rate;			/* EMB���C�g */
	char	Counter;		/* EMB�J�E���^�[ */
	char	MaxMin;			/* EMB�ő�^�ŏ��l */
	char	LevelSet;		/* EMB�ψ����� */
} WTD_ChEmb;

/* Flag bit */
/* Set */
#define	WTD_Ctrl_BendLfo		00001h	/* �����k�e�n�X�C�b�` */
#define	WTD_Ctrl_BendEmb		00002h	/* �����G���x���[�v�X�C�b�` */
#define	WTD_Ctrl_ExprLfo		00004h	/* ���ʂk�e�n�X�C�b�` */
#define	WTD_Ctrl_ExprEmb		00008h	/* ���ʃG���x���[�v�X�C�b�` */
#define	WTD_Ctrl_PanLfo			00010h	/* �p���k�e�n�X�C�b�` */
#define	WTD_Ctrl_PanEmb			00020h	/* �p���G���x���[�v�X�C�b�` */
#define	WTD_Ctrl_Acsent			00040h	/* ���̉��K�̓A�N�Z���g */
#define	WTD_Ctrl_EmbFreq		00080h	/* �����G���x���[�v ���bit */
#define	WTD_Ctrl_EmbVol			00100h	/* ���ʃG���x���[�v ���bit */
#define	WTD_Ctrl_EmbPan			00200h	/* �p���G���x���[�v ���bit */
#define	WTD_Ctrl_Vol0			00400h	/* ���ʁ��O */
#define	WTD_Ctrl_WorkSw			00800h	/* ���̃R�}���h�́A���[�N�Q�� */
#define	WTD_Ctrl_WorkCy			01000h	/* ���[�N���Z���ʁA�I�[�o�[�t���[ */
#define	WTD_Ctrl_WorkZe			02000h	/* ���[�N���Z���ʁA�O�ɂȂ����B */
#define	WTD_Ctrl_Effect			04000h	/* ���̃p�[�g�͌��ʉ����H */
#define	WTD_Ctrl_PlayEnd		08000h	/* ���t�I�� */
/* Reset */
#define	WTD_Ctrl_BendLfoR		0fffeh	/*	;�����k�e�n�X�C�b�` */
#define	WTD_Ctrl_BendEmbR		0fffdh	/*	;�����G���x���[�v�X�C�b�` */
#define	WTD_Ctrl_ExprLfoR		0fffbh	/*	;���ʂk�e�n�X�C�b�` */
#define	WTD_Ctrl_ExprEmbR		0fff7h	/*	;���ʃG���x���[�v�X�C�b�` */
#define	WTD_Ctrl_PanLfoR		0ffefh	/*	;�p���k�e�n�X�C�b�` */
#define	WTD_Ctrl_PamEmbR		0ffdfh	/*	;�p���G���x���[�v�X�C�b�` */
#define	WTD_Ctrl_AcsentR		0ffbfh	/*	;���̉��K�̓A�N�Z���g */
#define	WTD_Ctrl_EmbFreqR		0ff7fh	/*	;�����G���x���[�v ���bit */
#define	WTD_Ctrl_EmbVolR		0feffh	/*	;���ʃG���x���[�v ���bit */
#define	WTD_Ctrl_EmbPanR		0fdffh	/*	;�p���G���x���[�v ���bit */
#define	WTD_Ctrl_Vol0R			0fbffh	/*	;���ʁ��O */
#define	WTD_Ctrl_WorkSwR		0f7ffh	/*	;���̃R�}���h�́A���[�N�Q�� */
#define	WTD_Ctrl_WorkCyR		0efffh	/*	;���[�N���Z���ʁA�I�[�o�[�t���[ */
#define	WTD_Ctrl_WorkZeR		0dfffh	/*	;���[�N���Z���ʁA�O�ɂȂ����B */
#define	WTD_Ctrl_EffectR		0bfffh	/*	;���̃p�[�g�͌��ʉ����H */
#define	WTD_Ctrl_PlayEndR		07fffh	/*	;���t�I�� */

/*==========================================*/
/* �p�[�g���ʃ��[�N�\����					*/
/*==========================================*/
/* �\���̒�` */
typedef struct {
	int		Flag;				/* 00	Flag */
	int		ProgramOffset;		/* 02	Program Offset Address */
	int		ProgramSegment;		/* 04	Program Segment Address */
	int		MusicOffset;		/* 06	Music Offset Address*/
	int		MusicSegment;		/* 08	Music Segment Address */
	int		EffectOffset;		/* 0A	Effect Offset Address */
	int		EffectSegment;		/* 0C	Effect Segment Address */
	int		PcmOffset;			/* 0E	Pcm Offset Address */
	int		PcmSegment;			/* 10	Pcm Segment Address */
	int		StayOutMask;		/* 12	�풓�����֎~ */
	int		OldIntvector[2];	/* 14	�O�̊��荞�݃x�N�^ */
	int		OldIntvectorCom[2];	/* 18	�O�̊��荞�݃x�N�^ */
	int		ComFIFO_Offset;		/* 1C	FIFO Offset Address */
	int		ComFIFO_Segment;	/* 1E	FIFO Segment Address */
	char	Null_20;			/* 20	���g�p */
	char	VolumeMusic;		/* 21	�\�t�g�E�F�A���� ���t */
	char	VolumeEffect;		/* 22	�\�t�g�E�F�A���� ���ʉ� */
	char	VolumePCM;			/* 23	�\�t�g�E�F�A���� PCM */
	int		Tempo;				/* 24	�e���| */
	int		TempoCounter;		/* 26	�e���|�J�E���^ */
	char	MusicPart;			/* 28	���t�̃p�[�g��(�ő�20) */
	char	EffectPart;			/* 29	���ʉ��̃p�[�g��(�ő�3) */
	int		ComFIFO_Cnt;		/* 2A	FIFO Counter */
	int		ComFIFO_Adr;		/* 2C	FIFO Address */
	int		ComFIFO_Size;		/* 2E	FIFO Size */
	char	RunningStatus;		/* 30	MIDI Running Status */
} Wtd_Sys;

/* Flag bit */
/* Set */
#define	WTD_Sys_Music			0x0001	/* ���t�� */
#define	WTD_Sys_Effect			0x0002	/* ���ʉ������� */
#define	WTD_Sys_Pcm				0x0004	/* PCM�{�C�X������ */
#define	WTD_Sys_PcmEnd			0x0008	/* PCM�{�C�X�����I�� */
#define	WTD_Sys_Midi			0x0010	/* MIDI���[�h(�V�X�e���ł͖��g�p) */
#define	WTD_Sys_5				0x0020	/* NULL */
#define	WTD_Sys_6				0x0040	/* NULL */
#define	WTD_Sys_7				0x0080	/* NULL */
#define	WTD_Sys_ChannelMode1	0x0100	/* �`�����l�����[�h ch1 */
#define	WTD_Sys_ChannelMode2	0x0200	/* �`�����l�����[�h ch2 */
#define	WTD_Sys_ChannelMode3	0x0400	/* �`�����l�����[�h ch3 */
#define	WTD_Sys_ChannelMode4	0x0800	/* �`�����l�����[�h ch4 */
#define	WTD_Sys_EffectMask1		0x1000	/* ���ʉ��p�[�g�}�X�N ch1 */
#define	WTD_Sys_EffectMask2		0x2000	/* ���ʉ��p�[�g�}�X�N ch2 */
#define	WTD_Sys_EffectMask3		0x4000	/* ���ʉ��p�[�g�}�X�N ch3 */
#define	WTD_Sys_EffectMask4		0x8000	/* ���ʉ��p�[�g�}�X�N ch4 */
/* Reset */
#define	WTD_Sys_MusicR			0xFFFE	/* ���t�� */
#define	WTD_Sys_EffectR			0xFFFD	/* ���ʉ������� */
#define	WTD_Sys_PcmR			0xFFFB	/* PCM�{�C�X������ */
#define	WTD_Sys_PcmEndR			0xFFF7	/* PCM�{�C�X�����I�� */
#define	WTD_Sys_MidiR			0xFFEF	/* MIDI���[�h(�V�X�e���ł͖��g�p) */
#define	WTD_Sys_5R				0xFFDF	/* NULL */
#define	WTD_Sys_6R				0xFFBF	/* NULL */
#define	WTD_Sys_7R				0xFF7F	/* NULL */
#define	WTD_Sys_ChannelMode1R	0xFEFF	/* �`�����l�����[�h ch1 */
#define	WTD_Sys_ChannelMode2R	0xFDFF	/* �`�����l�����[�h ch2 */
#define	WTD_Sys_ChannelMode3R	0xFBFF	/* �`�����l�����[�h ch3 */
#define	WTD_Sys_ChannelMode4R	0xF7FF	/* �`�����l�����[�h ch4 */
#define	WTD_Sys_EffectMask1R	0xEFFF	/* ���ʉ��p�[�g�}�X�N ch1 */
#define	WTD_Sys_EffectMask2R	0xDFFF	/* ���ʉ��p�[�g�}�X�N ch2 */
#define	WTD_Sys_EffectMask3R	0xBFFF	/* ���ʉ��p�[�g�}�X�N ch3 */
#define	WTD_Sys_EffectMask4R	0x7FFF	/* ���ʉ��p�[�g�}�X�N ch4 */

/*==========================================*/
/* �\�t�g�E�F�A�G���x���[�v�\����			*/
/*==========================================*/
/* �\���̒�` */
typedef struct {
	char	AR;				/* Attack Rate */
	char	AS;				/* Attack Speed */
	char	AL;				/* Attack Level */
	char	FL;				/* First Level */
	char	DR;				/* Decay Rate */
	char	DS;				/* Decay Speed */
	char	DL;				/* Decay Level */
	char	Null1;			/* ���g�p */
	char	SR;				/* Sustain Rate */
	char	SS;				/* Sustain Speed */
	char	SL;				/* Sustain Level */
	char	Null2;			/* ���g�p */
	char	RR;				/* Relase Rate */
	char	RS;				/* Relase Speed */
	char	RL;				/* Relase Level */
	char	Null3;			/* ���g�p */
} Wtd_Emb;

/*==========================================*/
/* �ȃf�[�^�\����							*/
/*==========================================*/
/* �w�b�_�\���� */
typedef struct{
	char	Name[4];		/* 00-03h	:�I�ʎq "'WTD',0" */
	char	VersionN;		/* 04h		:Version ������ */
	char	VersionS;		/* 05h		:Version ������ */
	int		Extr;			/* 06-07h	:�g���w�b�_�T�C�Y */
	char	Emb;			/* 08h		:�G���x���[�v���� */
	char	Voice;			/* 09h		:�g�`�f�[�^���� */
	char	Part;			/* 0Ah		:�p�[�g�� */
	char	TimeBase;		/* 0Bh		:�S�������̕����� */
	void	*ExtrAdr;		/* 0C-0Dh	:�g���w�b�_�̃A�h���X */
	char	*DataAdr;		/* 0E-0Fh	:�f�[�^�̃A�h���X */
	void	*(*PartAdr);	/* 10-11h	:�ȃf�[�^�擪�A�h���X�̃A�h���X */
} WTD_Mus;

/* �g���w�b�_�\���� */
typedef struct{
	char	Null;			/* ���̍\���̂́A���g�p */
} WTD_MusEx;

/*==========================================*/

#endif _IL_WTD_H_