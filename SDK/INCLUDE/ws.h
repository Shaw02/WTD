/************************************************************************/
/*				Wonder Witch program for C Magazine						*/
/*						Device Define file								*/
/*								Programed by A.Watanabe (S.W.)			*/
/************************************************************************/
/*========================================================================
	�ėp��`
=========================================================================*/
/*���C���N���[�h��`*/
#include	<sys/bios.h>
#include	<sys/libwwc.h>

/*���C�����C���A�Z���u����`*/
	char	_asm_cc(char *);
	char	_asm_ccc(char *, char);
	int		_asm_ic(char *);
	int		_asm_icc(char *, int);
	char	_asm_ci();
	char	_asm_cci();
	int		_asm_ii();
	int		_asm_ici();

#define	_qq_(s)		# s
#define	_q_(s)		_qq_(s)

#define	inb(p)		_asm_cc( "\n\tIN\tAL," _q_(__eval__(p)))
#define	outb(p, c)	_asm_ccc("\n\tOUT\t"   _q_(__eval__(p)) ",AL", (c))
#define	inw(p)		_asm_ic( "\n\tIN\tAX," _q_(__eval__(p)))
#define	outw(p, c)	_asm_icc("\n\tOUT\t"   _q_(__eval__(p)) ",AX", (c))
#define	inpb(p)		_asm_ci( "\n\tIN\tAL,DX"     ,_asm_ci,_asm_ci,_asm_ci,(p))
#define	outpb(p, c)	_asm_cci("\n\tOUT\tDX,AL",(c),_asm_ci,_asm_ci        ,(p))
#define	inpw(p)		_asm_ii( "\n\tIN\tAX,DX"     ,_asm_ci,_asm_ci,_asm_ci,(p))
#define	outpw(p, c)	_asm_ici("\n\tOUT\tDX,AX",(c),_asm_ci,_asm_ci        ,(p))

/*========================================================================
	�V�X�e��
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*��I/O Address*/
#define	Hardware				0xA0	/* �@�픻�ʗp */

/*--------------------------------------*/
/*	�萔��`							*/
/*--------------------------------------*/
/*��Status bit*/
#define	HardwareMask			0x02	/* �@�픻�ʗp */

/*========================================================================
	���
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*��I/O Address*/
#define	LCD_DisplayControl		0x00	/* ��� */
#define	LCD_Line				0x02	/* �G��f�[�^�������̃��C�� */
#define	LCD_Interrupt			0x03	/* ���荞�݂������郉�C�� */
#define	LCD_SpriteArea			0x04	/* Sprite��VRAM */
#define	LCD_SpriteStart			0x05	/* �\������X�v���C�g�̍ŏ��̔ԍ� */
#define	LCD_SpriteCount			0x06	/* �\������X�v���C�g�̐� */
#define	LCD_ScreenArea			0x07	/* Screen��VRAM */
#define	LCD_Scr2WindowsStart	0x08	/* Screen2 Window�̍���̍��W[dot] */
#define	LCD_Scr2WindowsEnd		0x0A	/* Screen2 Window�̉E���̍��W[dot] */
#define	LCD_SprWindowsStart		0x0C	/* Sprite  Window�̍���̍��W[dot] */
#define	LCD_SprWindowsEnd		0x0E	/* Sprite  Window�̉E���̍��W[dot] */
#define	LCD_Scr1Scroll			0x10	/* Screen1�̃X�N���[���� */
#define	LCD_Scr2Scroll			0x12	/* Screen2�̃X�N���[���� */
#define	LCD_IF_Ctrl				0x14	/* IF�R���g���[�� */
#define	LCD_Segment				0x15	/* �Z�O�����g�E�}�[�N */
#define	LCD_Gray0123			0x1C	/* ���m�N��8�K�� 0�`3 */
#define	LCD_Gray4567			0x1E	/* ���m�N��8�K�� 4�`7 */
#define	LCD_ScrPalette			0x20	/* ���m�N���p���b�g */
#define	LCD_ScrPalette0			LCD_ScrPalette + 0x00
#define	LCD_ScrPalette1			LCD_ScrPalette + 0x02
#define	LCD_ScrPalette2			LCD_ScrPalette + 0x04
#define	LCD_ScrPalette3			LCD_ScrPalette + 0x06
#define	LCD_ScrPalette4			LCD_ScrPalette + 0x08
#define	LCD_ScrPalette5			LCD_ScrPalette + 0x0A
#define	LCD_ScrPalette6			LCD_ScrPalette + 0x0B
#define	LCD_ScrPalette7			LCD_ScrPalette + 0x0C
#define	LCD_ScrPalette8			LCD_ScrPalette + 0x10
#define	LCD_ScrPalette9			LCD_ScrPalette + 0x12
#define	LCD_ScrPaletteA			LCD_ScrPalette + 0x14
#define	LCD_ScrPaletteB			LCD_ScrPalette + 0x16
#define	LCD_ScrPaletteC			LCD_ScrPalette + 0x18
#define	LCD_ScrPaletteD			LCD_ScrPalette + 0x1A
#define	LCD_ScrPaletteE			LCD_ScrPalette + 0x1C
#define	LCD_ScrPaletteF			LCD_ScrPalette + 0x1E
#define	LCD_ColorMode			0x60	/* �J���[���[�h */

/*��Memory Address*/			/* �X�^�[�g�E�A�b�v���[�`���ł̐ݒ�l */
#define	VramAdrFontMono		0x00002000L	/* Mono  Font��VRAM�A�h���X */
#define	VramAdrFontColor	0x00004000L	/* Color Font��VRAM�A�h���X */
#define	VramAdrPalette		0x0000fe00L	/* Palettte  ��VRAM�A�h���X */

/* AscII�P ���[�h */
#define	VramAdrSprite_a1	0x00002e00L	/* Sprite    ��VRAM�A�h���X */
#define	VramAdrScreen1_a1	0x00003000L	/* Screen    ��VRAM�A�h���X */
#define	VramAdrScreen2_a1	0x00003000L	/* Screen    ��VRAM�A�h���X */
/* AscII�Q ���[�h */
#define	VramAdrSprite_a2	0x00002600L	/* Sprite    ��VRAM�A�h���X */
#define	VramAdrScreen1_a2	0x00003000L	/* Screen    ��VRAM�A�h���X */
#define	VramAdrScreen2_a2	0x00002800L	/* Screen    ��VRAM�A�h���X */
/* ���{��P ���[�h */
#define	VramAdrSprite_j1	0x00001600L	/* Sprite    ��VRAM�A�h���X */
#define	VramAdrScreen1_j1	0x00001800L	/* Screen    ��VRAM�A�h���X */
#define	VramAdrScreen2_j1	0x00001800L	/* Screen    ��VRAM�A�h���X */
/* ���{��Q ���[�h */
#define	VramAdrSprite_j2	0x00000e00L	/* Sprite    ��VRAM�A�h���X */
#define	VramAdrScreen1_j2	0x00001000L	/* Screen    ��VRAM�A�h���X */
#define	VramAdrScreen2_j2	0x00001800L	/* Screen    ��VRAM�A�h���X */
/* �I���W�i�� ���[�h */
#define	VramAdrSprite_sc	0x00002e00L	/* Sprite    ��VRAM�A�h���X */
#define	VramAdrScreen1_sc	0x00003000L	/* Screen    ��VRAM�A�h���X */
#define	VramAdrScreen2_sc	0x00003800L	/* Screen    ��VRAM�A�h���X */

#ifdef DISPLAY_MODE_ASCII1		/* AscII�P ���[�h */
#define	VramAdrSprite	VramAdrSprite_a1	/* Sprite��VRAM�A�h���X */
#define	VramAdrScreen1	VramAdrScreen1_a1	/* Screen��VRAM�A�h���X */
#define	VramAdrScreen2	VramAdrScreen2_a1	/* Screen��VRAM�A�h���X */
#endif
#ifdef DISPLAY_MODE_ASCII2		/* AscII�Q ���[�h */
#define	VramAdrSprite	VramAdrSprite_a2	/* Sprite��VRAM�A�h���X */
#define	VramAdrScreen1	VramAdrScreen1_a2	/* Screen��VRAM�A�h���X */
#define	VramAdrScreen2	VramAdrScreen2_a2	/* Screen��VRAM�A�h���X */
#endif
#ifdef DISPLAY_MODE_JAPANESE1	/* ���{��P ���[�h */
#define	VramAdrSprite	VramAdrSprite_j1	/* Sprite��VRAM�A�h���X */
#define	VramAdrScreen1	VramAdrScreen1_j1	/* Screen��VRAM�A�h���X */
#define	VramAdrScreen2	VramAdrScreen2_j1	/* Screen��VRAM�A�h���X */
#endif
#ifdef DISPLAY_MODE_JAPANESE2	/* ���{��Q ���[�h */
#define	VramAdrSprite	VramAdrSprite_j2	/* Sprite��VRAM�A�h���X */
#define	VramAdrScreen1	VramAdrScreen1_j2	/* Screen��VRAM�A�h���X */
#define	VramAdrScreen2	VramAdrScreen2_j2	/* Screen��VRAM�A�h���X */
#endif
#ifdef DISPLAY_MODE_swCOLOR		/* �I���W�i�� ���[�h */
#define	VramAdrSprite	VramAdrSprite_sc	/* Sprite��VRAM�A�h���X */
#define	VramAdrScreen1	VramAdrScreen1_sc	/* Screen��VRAM�A�h���X */
#define	VramAdrScreen2	VramAdrScreen2_sc	/* Screen��VRAM�A�h���X */
#endif

/*--------------------------------------*/
/*	�萔��`							*/
/*--------------------------------------*/
/*���A�g���r���[�g�p*/
#define	Atr_Character		0x01FF	/* �L�����N�^�[�ԍ�(0�`511) */
#define	Atr_Palette			0X1E00	/* �p���b�g */
#define	Atr_CharacterH		0x2000	/* �L�����N�^�[�ԍ�( + 512) */
#define	Atr_Vm				0x4000	/* �����] */
#define	Atr_Hm				0x8000	/* �c���] */

/*��I/O Display Control�p*/
#define	LCD_DispCtrl_Scr1	0x0001	/* Screen1 Enable */
#define	LCD_DispCtrl_Scr2	0x0002	/* Screen2 Enable */
#define	LCD_DispCtrl_Spr	0x0004	/* Sprite  Enable */
#define	LCD_DispCtrl_SprWin	0x0008	/* Sprite  Windows Enable */
#define	LCD_DispCtrl_ScrWin	0x0030	/* Screen2 Windows Mode */
#define	LCD_DispCtrl_BCol	0x0F00	/* �{�[�_�[ Color */
#define	LCD_DispCtrl_BPal	0xF000	/* �{�[�_�[ Palette */

/*��I/O LCD Segment�p*/
#define	LCD_Segment_Sleep	0x01	/* Sleep�_�� */
#define	LCD_Segment_Hor		0x02	/* �c�_�� */
#define	LCD_Segment_Ver		0x04	/* ���_�� */

/*��I/O Color mode�p*/
#define	LCD_ColorModeMask	0x1f		/* �J���[���[�h�ׂ̈̃}�X�N�l */

/*��LCD�֘A */
#define	LCD_Sprite			128			/* �X�v���C�g�� */
#define	LCD_ScrHight		32			/* VRAM�̏c�T�C�Y */
#define	LCD_ScrWidth		32			/* VRAM�̉��T�C�Y */
#define	LCD_Font			1024		/* �t�H���g�� */
#define	LCD_FontSizeMono	16			/* �t�H���g�̃T�C�Y */
#define	LCD_FontSize		32			/* �t�H���g�̃T�C�Y */
#define	LCD_Palette			16			/* �p���b�g�� */
#define	LCD_Color			16			/* �P�p���b�g�ł̐F�� */
#define	LCD_FontMono		512			/* �F��(2^2= 4) */
#define	LCD_FontColor		1024		/* �F��(2^4=16) */
#define	LCD_FontHight		8			/* �t�H���g�̏c�T�C�Y */
#define	LCD_FontWidth		8			/* �t�H���g�̉��T�C�Y */

/*--------------------------------------*/
/*	�\���̒�`							*/
/*--------------------------------------*/
/*��Sprite Attr */
typedef struct {						/* �E�X�v���C�g�\�� */
	unsigned int	Atr;				/* �A�g���r���[�g */
	unsigned char	y;					/* y ���W */
	unsigned char	x;					/* x ���W */
} AttrSprite;

/*��Sprite VRAM */
typedef struct {						/* �E�X�v���C�gVRAM */
	AttrSprite		Atr[LCD_Sprite];	/* �X�v���C�g�\�� */
} VRAM_Sprite;

/*��Screen VRAM */
typedef struct {										/* �E�X�N���[��VRAM */
	unsigned int	Atr[LCD_ScrHight][LCD_ScrWidth];	/* �A�g���r���[�g */
} VRAM_Screen;

/*��Mono Font VRAM*/
typedef struct {									/* �E�t�H���g */
	unsigned char	PCG[LCD_FontMono][LCD_FontSizeMono];
} VRAM_FontMono;

/*��Color Font VRAM*/
typedef struct {									/* �E�t�H���g */
	unsigned char	PCG[LCD_FontColor][LCD_FontSize];
} VRAM_FontColor;

/*��Palette VRAM*/
typedef struct {									/* �E�p���b�g */
	unsigned int	Color[LCD_Palette][LCD_Color];	/* �F */
} VRAM_Palatte;

/*========================================================================
	�T�E���h
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*��I/O Address*/
#define	SOUND_Frequency			0x80	/* ���g�� */
#define	SOUND_FrequencyCh1		SOUND_Frequency + 0
#define	SOUND_FrequencyCh2		SOUND_Frequency + 2
#define	SOUND_FrequencyCh3		SOUND_Frequency + 4
#define	SOUND_FrequencyCh4		SOUND_Frequency + 6
#define	SOUND_Volume			0x88	/* ���� */
#define	SOUND_VolumeCh1			SOUND_Volume + 0	
#define	SOUND_VolumeCh2			SOUND_Volume + 1	
#define	SOUND_VolumeCh3			SOUND_Volume + 2	
#define	SOUND_VolumeCh4			SOUND_Volume + 3	
#define	SOUND_PCMVoice			SOUND_VolumeCh2	/*	PCM Voice */
#define	SOUND_Sweep				0x8C	/* Sweep */
#define	SOUND_SweepLevel		SOUND_Sweep + 0	/* Sweep Level */
#define	SOUND_SweepTime			SOUND_Sweep + 1	/* Sweep time */
#define	SOUND_Noise				0x8E	/* Noise mode */
#define	SOUND_VoiceAddress		0x8F	/* ���FWave address */
#define	SOUND_Channel			0x90	/* Channel mode */
#define	SOUND_Output			0x91	/* Output mode */
#define	SOUND_Random			0x92	/* Random get */
#define	SOUND_VolumePCM			0x94	/* PCM Voice Volume */

/*��Memory Address*/
#define	SOUND_VoiceAdr		0x00000180L	/* FreyaBIOS Work Area */

/*--------------------------------------*/
/*	�萔��`							*/
/*--------------------------------------*/
/*���m�C�Y���[�h*/
#define	SOUND_NoiseMode			0x07	/* �m�C�Y�E���[�h */
#define	SOUND_NoiseReset		0x08	/* �����J�E���^�[�E���Z�b�g */
#define	SOUND_NoiseEnable		0x10	/* �C�l�[�u���E�X�C�b�` */

/*���`�����l�����[�h*/
#define	SOUND_ChannelCh1		0x01	/* Ch1 Enable */
#define	SOUND_ChannelCh2		0x02	/* Ch2 Enable */
#define	SOUND_ChannelCh3		0x04	/* Ch3 Enable */
#define	SOUND_ChannelCh4		0x08	/* Ch4 Enable */
#define	SOUND_ChannelPcmVoice	0x20	/* PCM Voice Enable */
#define	SOUND_ChannelSweep		0x40	/* Sweep Enable */
#define	SOUND_ChannelNoise		0x80	/* Noise Enable */

/*���o�̓��[�h*/
#define	SOUND_OutputSpkEn		0x01	/* �����X�s�[�JEnable */
#define	SOUND_OutputRange		0x06	/* �����X�s�[�J�o�̓����W */
#define	SOUND_OutputPhoneEn		0x08	/* �O���X�s�[�JEnable */
#define	SOUND_OutputPhoneSw		0x80	/* �O���X�s�[�J�ڑ��`�F�b�N */

/*��Channel*/
#define	SOUND_ChannelMax		4		/* �`�����l���� */

/*���e��}�X�N*/
#define	SOUND_FrequencyMask		0x07FF	/* ����Range */
#define	SOUND_VolumeMask		0x0F	/* ����Range */

/*�����F�p*/
#define	SOUND_VoiceSize			16		/* ���F�p�����[�^�̃T�C�Y */

/*--------------------------------------*/
/*	�\���̒�`							*/
/*--------------------------------------*/
/*�����F*/
typedef struct {						/* ���F�e�[�u�� */
	unsigned char	Voice[SOUND_Channel][SOUND_VoiceSize];
} SOUND_Voice;

/*========================================================================
	�^�C�}�[
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*��I/O Address*/
#define	TIMER_Status			0xA2	/* Timer Status */
#define	TIMER_MaxCountH			0xA4	/* Hblank Load Count */
#define	TIMER_MaxCountV			0xA6	/* Vblank Load Count */
#define	TIMER_CounterH			0xA8	/* Hblank Down Counter */
#define	TIMER_CounterV			0xAA	/* Vblank Down Counter */

/*--------------------------------------*/
/*	�萔��`							*/
/*--------------------------------------*/
/*��Status bit*/
/* Set */
#define	Timer_H_Enable			0x01	/* Hblank Int. Enable	(or) */
#define	Timer_H_auto			0x02	/* Vblank auto preset mode(or) */
#define	Timer_V_Enable			0x04	/* Vblank Int. Enable 	(or) */
#define	Timer_V_auto			0x08	/* Vblank auto preset mode(or) */
/* Reset*/
#define	Timer_H_Disable			0xFE	/* Hblank Int. Disable	(and) */
#define	Timer_H_shot			0xFD	/* Vblank 1 shot mode	(and) */
#define	Timer_V_Disable			0xFB	/* Vblank Int. Disable	(and) */
#define	Timer_V_shot			0xF7	/* Vblank 1 shot mode	(and) */

/*========================================================================
	���荞��
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*��I/O Address*/
#define	Int_Vector				0xB0	/* ���荞�݃x�N�^ (����֎~) */
#define	Int_Enable				0xB2	/* ���荞�݉ۃt���O */
#define	Int_Type				0xB4	/* �v������Ă��銄�荞�� */
#define	Int_Eoi					0xB6	/* End of Interrupt�̔��s */

/*--------------------------------------*/
/*	�萔��`							*/
/*--------------------------------------*/
/*�����荞��bit*/
/* Set */
#define	INT_CommSendSet			0x01	/* ���M�f�[�^��			(or) */
#define	INT_KeySet				0x02	/* �L�[���荞��			(or) */
#define	INT_CasetteSet			0x04	/* �J�Z�b�g���荞��		(or) */
#define	INT_CommReciSet			0x08	/* ��M�f�[�^���f�B�[	(or) */
#define	INT_LCDlineSet			0x10	/* LCD�G�惉�C�����m	(or) */
#define	INT_VblankSet			0x20	/* Vblank 				(or) */
#define	INT_VblankStartSet		0x40	/* Vblank���ԊJ�n		(or) */
#define	INT_HblankSet			0x80	/* Hblank				(or) */
/* Reset*/
#define	INT_CommSendRes			0xFE	/* ���M�f�[�^��			(and) */
#define	INT_KeyRes				0xFD	/* �L�[���荞��			(and) */
#define	INT_Casette	Res			0xFB	/* �J�Z�b�g���荞��		(and) */
#define	INT_CommReciRes			0xF7	/* ��M�f�[�^���f�B�[	(and) */
#define	INT_LCDlineRes			0xFF	/* LCD�G�惉�C�����m	(and) */
#define	INT_VblankRes			0xDF	/* Vblank 				(and) */
#define	INT_VblankStartRes		0xBF	/* Vblank���ԊJ�n		(and) */
#define	INT_HblankRes			0x7F	/* Hblank				(and) */

/*========================================================================
	�V���A���ʐM
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*��I/O Address*/
#define	COMM_DATA				0xB1	/* Send & Receive data */
#define	COMM_STATUS				0xB3	/* Serial Status */

/*--------------------------------------*/
/*	�萔��`							*/
/*--------------------------------------*/
/*��Status bit*/
/* Set */
#define	COMM_Receive			0x01	/* ��M�f�[�^�L��i��M�j	 */
#define	COMM_OverRun			0x02	/* �I�[�o�[�����E�G���[		 */
#define	COMM_SendEmpty			0x04	/* ���M�o�b�t�@��i���M�j	 */
#define	COMM_OrReset			0x20	/* �I�[�o�[�����E�G���[�̃��Z�b�g */
#define	COMM_Baudrate38k		0x40	/* �{�[���[�g�i38400 [bps])	(or) */
#define	COMM_Enable				0x80	/* �ʐM�C�l�[�u��			(or) */
/* Reset */
#define	COMM_Baudrate9K			0xBF	/* �{�[���[�g�i 9600 [bps])	(and) */
#define	COMM_Disable			0x7F	/* �ʐM�f�B�Z�[�u��			(and) */

/*========================================================================
	�L�[
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*��I/O Address*/
#define	KEY						0xB5	/* COMON & Key Data */

/*--------------------------------------*/
/*	�萔��`							*/
/*--------------------------------------*/
/*��Comon bit*/
#define	KEY_GroupY				0x10	/* Y1,Y2,Y3,Y4 */
#define	KEY_GroupX				0x20	/* X1,X2,X3,X4 */
#define	KEY_GroupABS			0x40	/* A,B,Start */

/*========================================================================
	�o���N
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*��I/O Address*/
#define	Bank_Sram				0xC1	/* SRAM Bank */
#define	Bank_Rom1				0xC2	/* ROM1 Bank */
#define	Bank_Rom2				0xC3	/* ROM2 Bank */
