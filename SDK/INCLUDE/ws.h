/************************************************************************/
/*				Wonder Witch program for C Magazine						*/
/*						Device Define file								*/
/*								Programed by A.Watanabe (S.W.)			*/
/************************************************************************/
/*========================================================================
	汎用定義
=========================================================================*/
/*●インクルード定義*/
#include	<sys/bios.h>
#include	<sys/libwwc.h>

/*●インラインアセンブラ定義*/
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
	システム
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*●I/O Address*/
#define	Hardware				0xA0	/* 機種判別用 */

/*--------------------------------------*/
/*	定数定義							*/
/*--------------------------------------*/
/*●Status bit*/
#define	HardwareMask			0x02	/* 機種判別用 */

/*========================================================================
	画面
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*●I/O Address*/
#define	LCD_DisplayControl		0x00	/* 画面 */
#define	LCD_Line				0x02	/* 絵画データ生成中のライン */
#define	LCD_Interrupt			0x03	/* 割り込みをかけるライン */
#define	LCD_SpriteArea			0x04	/* SpriteのVRAM */
#define	LCD_SpriteStart			0x05	/* 表示するスプライトの最初の番号 */
#define	LCD_SpriteCount			0x06	/* 表示するスプライトの数 */
#define	LCD_ScreenArea			0x07	/* ScreenのVRAM */
#define	LCD_Scr2WindowsStart	0x08	/* Screen2 Windowの左上の座標[dot] */
#define	LCD_Scr2WindowsEnd		0x0A	/* Screen2 Windowの右下の座標[dot] */
#define	LCD_SprWindowsStart		0x0C	/* Sprite  Windowの左上の座標[dot] */
#define	LCD_SprWindowsEnd		0x0E	/* Sprite  Windowの右下の座標[dot] */
#define	LCD_Scr1Scroll			0x10	/* Screen1のスクロール量 */
#define	LCD_Scr2Scroll			0x12	/* Screen2のスクロール量 */
#define	LCD_IF_Ctrl				0x14	/* IFコントロール */
#define	LCD_Segment				0x15	/* セグメント・マーク */
#define	LCD_Gray0123			0x1C	/* モノクロ8階調 0～3 */
#define	LCD_Gray4567			0x1E	/* モノクロ8階調 4～7 */
#define	LCD_ScrPalette			0x20	/* モノクロパレット */
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
#define	LCD_ColorMode			0x60	/* カラーモード */

/*●Memory Address*/			/* スタート・アップルーチンでの設定値 */
#define	VramAdrFontMono		0x00002000L	/* Mono  FontのVRAMアドレス */
#define	VramAdrFontColor	0x00004000L	/* Color FontのVRAMアドレス */
#define	VramAdrPalette		0x0000fe00L	/* Palettte  のVRAMアドレス */

/* AscII１ モード */
#define	VramAdrSprite_a1	0x00002e00L	/* Sprite    のVRAMアドレス */
#define	VramAdrScreen1_a1	0x00003000L	/* Screen    のVRAMアドレス */
#define	VramAdrScreen2_a1	0x00003000L	/* Screen    のVRAMアドレス */
/* AscII２ モード */
#define	VramAdrSprite_a2	0x00002600L	/* Sprite    のVRAMアドレス */
#define	VramAdrScreen1_a2	0x00003000L	/* Screen    のVRAMアドレス */
#define	VramAdrScreen2_a2	0x00002800L	/* Screen    のVRAMアドレス */
/* 日本語１ モード */
#define	VramAdrSprite_j1	0x00001600L	/* Sprite    のVRAMアドレス */
#define	VramAdrScreen1_j1	0x00001800L	/* Screen    のVRAMアドレス */
#define	VramAdrScreen2_j1	0x00001800L	/* Screen    のVRAMアドレス */
/* 日本語２ モード */
#define	VramAdrSprite_j2	0x00000e00L	/* Sprite    のVRAMアドレス */
#define	VramAdrScreen1_j2	0x00001000L	/* Screen    のVRAMアドレス */
#define	VramAdrScreen2_j2	0x00001800L	/* Screen    のVRAMアドレス */
/* オリジナル モード */
#define	VramAdrSprite_sc	0x00002e00L	/* Sprite    のVRAMアドレス */
#define	VramAdrScreen1_sc	0x00003000L	/* Screen    のVRAMアドレス */
#define	VramAdrScreen2_sc	0x00003800L	/* Screen    のVRAMアドレス */

#ifdef DISPLAY_MODE_ASCII1		/* AscII１ モード */
#define	VramAdrSprite	VramAdrSprite_a1	/* SpriteのVRAMアドレス */
#define	VramAdrScreen1	VramAdrScreen1_a1	/* ScreenのVRAMアドレス */
#define	VramAdrScreen2	VramAdrScreen2_a1	/* ScreenのVRAMアドレス */
#endif
#ifdef DISPLAY_MODE_ASCII2		/* AscII２ モード */
#define	VramAdrSprite	VramAdrSprite_a2	/* SpriteのVRAMアドレス */
#define	VramAdrScreen1	VramAdrScreen1_a2	/* ScreenのVRAMアドレス */
#define	VramAdrScreen2	VramAdrScreen2_a2	/* ScreenのVRAMアドレス */
#endif
#ifdef DISPLAY_MODE_JAPANESE1	/* 日本語１ モード */
#define	VramAdrSprite	VramAdrSprite_j1	/* SpriteのVRAMアドレス */
#define	VramAdrScreen1	VramAdrScreen1_j1	/* ScreenのVRAMアドレス */
#define	VramAdrScreen2	VramAdrScreen2_j1	/* ScreenのVRAMアドレス */
#endif
#ifdef DISPLAY_MODE_JAPANESE2	/* 日本語２ モード */
#define	VramAdrSprite	VramAdrSprite_j2	/* SpriteのVRAMアドレス */
#define	VramAdrScreen1	VramAdrScreen1_j2	/* ScreenのVRAMアドレス */
#define	VramAdrScreen2	VramAdrScreen2_j2	/* ScreenのVRAMアドレス */
#endif
#ifdef DISPLAY_MODE_swCOLOR		/* オリジナル モード */
#define	VramAdrSprite	VramAdrSprite_sc	/* SpriteのVRAMアドレス */
#define	VramAdrScreen1	VramAdrScreen1_sc	/* ScreenのVRAMアドレス */
#define	VramAdrScreen2	VramAdrScreen2_sc	/* ScreenのVRAMアドレス */
#endif

/*--------------------------------------*/
/*	定数定義							*/
/*--------------------------------------*/
/*●アトリビュート用*/
#define	Atr_Character		0x01FF	/* キャラクター番号(0～511) */
#define	Atr_Palette			0X1E00	/* パレット */
#define	Atr_CharacterH		0x2000	/* キャラクター番号( + 512) */
#define	Atr_Vm				0x4000	/* 横反転 */
#define	Atr_Hm				0x8000	/* 縦反転 */

/*●I/O Display Control用*/
#define	LCD_DispCtrl_Scr1	0x0001	/* Screen1 Enable */
#define	LCD_DispCtrl_Scr2	0x0002	/* Screen2 Enable */
#define	LCD_DispCtrl_Spr	0x0004	/* Sprite  Enable */
#define	LCD_DispCtrl_SprWin	0x0008	/* Sprite  Windows Enable */
#define	LCD_DispCtrl_ScrWin	0x0030	/* Screen2 Windows Mode */
#define	LCD_DispCtrl_BCol	0x0F00	/* ボーダー Color */
#define	LCD_DispCtrl_BPal	0xF000	/* ボーダー Palette */

/*●I/O LCD Segment用*/
#define	LCD_Segment_Sleep	0x01	/* Sleep点灯 */
#define	LCD_Segment_Hor		0x02	/* 縦点灯 */
#define	LCD_Segment_Ver		0x04	/* 横点灯 */

/*●I/O Color mode用*/
#define	LCD_ColorModeMask	0x1f		/* カラーモードの為のマスク値 */

/*●LCD関連 */
#define	LCD_Sprite			128			/* スプライト数 */
#define	LCD_ScrHight		32			/* VRAMの縦サイズ */
#define	LCD_ScrWidth		32			/* VRAMの横サイズ */
#define	LCD_Font			1024		/* フォント数 */
#define	LCD_FontSizeMono	16			/* フォントのサイズ */
#define	LCD_FontSize		32			/* フォントのサイズ */
#define	LCD_Palette			16			/* パレット数 */
#define	LCD_Color			16			/* １パレットでの色数 */
#define	LCD_FontMono		512			/* 色数(2^2= 4) */
#define	LCD_FontColor		1024		/* 色数(2^4=16) */
#define	LCD_FontHight		8			/* フォントの縦サイズ */
#define	LCD_FontWidth		8			/* フォントの横サイズ */

/*--------------------------------------*/
/*	構造体定義							*/
/*--------------------------------------*/
/*●Sprite Attr */
typedef struct {						/* ・スプライト構造 */
	unsigned int	Atr;				/* アトリビュート */
	unsigned char	y;					/* y 座標 */
	unsigned char	x;					/* x 座標 */
} AttrSprite;

/*●Sprite VRAM */
typedef struct {						/* ・スプライトVRAM */
	AttrSprite		Atr[LCD_Sprite];	/* スプライト構造 */
} VRAM_Sprite;

/*●Screen VRAM */
typedef struct {										/* ・スクリーンVRAM */
	unsigned int	Atr[LCD_ScrHight][LCD_ScrWidth];	/* アトリビュート */
} VRAM_Screen;

/*●Mono Font VRAM*/
typedef struct {									/* ・フォント */
	unsigned char	PCG[LCD_FontMono][LCD_FontSizeMono];
} VRAM_FontMono;

/*●Color Font VRAM*/
typedef struct {									/* ・フォント */
	unsigned char	PCG[LCD_FontColor][LCD_FontSize];
} VRAM_FontColor;

/*●Palette VRAM*/
typedef struct {									/* ・パレット */
	unsigned int	Color[LCD_Palette][LCD_Color];	/* 色 */
} VRAM_Palatte;

/*========================================================================
	サウンド
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*●I/O Address*/
#define	SOUND_Frequency			0x80	/* 周波数 */
#define	SOUND_FrequencyCh1		SOUND_Frequency + 0
#define	SOUND_FrequencyCh2		SOUND_Frequency + 2
#define	SOUND_FrequencyCh3		SOUND_Frequency + 4
#define	SOUND_FrequencyCh4		SOUND_Frequency + 6
#define	SOUND_Volume			0x88	/* 音量 */
#define	SOUND_VolumeCh1			SOUND_Volume + 0	
#define	SOUND_VolumeCh2			SOUND_Volume + 1	
#define	SOUND_VolumeCh3			SOUND_Volume + 2	
#define	SOUND_VolumeCh4			SOUND_Volume + 3	
#define	SOUND_PCMVoice			SOUND_VolumeCh2	/*	PCM Voice */
#define	SOUND_Sweep				0x8C	/* Sweep */
#define	SOUND_SweepLevel		SOUND_Sweep + 0	/* Sweep Level */
#define	SOUND_SweepTime			SOUND_Sweep + 1	/* Sweep time */
#define	SOUND_Noise				0x8E	/* Noise mode */
#define	SOUND_VoiceAddress		0x8F	/* 音色Wave address */
#define	SOUND_Channel			0x90	/* Channel mode */
#define	SOUND_Output			0x91	/* Output mode */
#define	SOUND_Random			0x92	/* Random get */
#define	SOUND_VolumePCM			0x94	/* PCM Voice Volume */

/*●Memory Address*/
#define	SOUND_VoiceAdr		0x00000180L	/* FreyaBIOS Work Area */

/*--------------------------------------*/
/*	定数定義							*/
/*--------------------------------------*/
/*●ノイズモード*/
#define	SOUND_NoiseMode			0x07	/* ノイズ・モード */
#define	SOUND_NoiseReset		0x08	/* 生成カウンター・リセット */
#define	SOUND_NoiseEnable		0x10	/* イネーブル・スイッチ */

/*●チャンネルモード*/
#define	SOUND_ChannelCh1		0x01	/* Ch1 Enable */
#define	SOUND_ChannelCh2		0x02	/* Ch2 Enable */
#define	SOUND_ChannelCh3		0x04	/* Ch3 Enable */
#define	SOUND_ChannelCh4		0x08	/* Ch4 Enable */
#define	SOUND_ChannelPcmVoice	0x20	/* PCM Voice Enable */
#define	SOUND_ChannelSweep		0x40	/* Sweep Enable */
#define	SOUND_ChannelNoise		0x80	/* Noise Enable */

/*●出力モード*/
#define	SOUND_OutputSpkEn		0x01	/* 内蔵スピーカEnable */
#define	SOUND_OutputRange		0x06	/* 内蔵スピーカ出力レンジ */
#define	SOUND_OutputPhoneEn		0x08	/* 外部スピーカEnable */
#define	SOUND_OutputPhoneSw		0x80	/* 外部スピーカ接続チェック */

/*●Channel*/
#define	SOUND_ChannelMax		4		/* チャンネル数 */

/*●各種マスク*/
#define	SOUND_FrequencyMask		0x07FF	/* 音程Range */
#define	SOUND_VolumeMask		0x0F	/* 音量Range */

/*●音色用*/
#define	SOUND_VoiceSize			16		/* 音色パラメータのサイズ */

/*--------------------------------------*/
/*	構造体定義							*/
/*--------------------------------------*/
/*●音色*/
typedef struct {						/* 音色テーブル */
	unsigned char	Voice[SOUND_Channel][SOUND_VoiceSize];
} SOUND_Voice;

/*========================================================================
	タイマー
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*●I/O Address*/
#define	TIMER_Status			0xA2	/* Timer Status */
#define	TIMER_MaxCountH			0xA4	/* Hblank Load Count */
#define	TIMER_MaxCountV			0xA6	/* Vblank Load Count */
#define	TIMER_CounterH			0xA8	/* Hblank Down Counter */
#define	TIMER_CounterV			0xAA	/* Vblank Down Counter */

/*--------------------------------------*/
/*	定数定義							*/
/*--------------------------------------*/
/*●Status bit*/
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
	割り込み
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*●I/O Address*/
#define	Int_Vector				0xB0	/* 割り込みベクタ (操作禁止) */
#define	Int_Enable				0xB2	/* 割り込み可否フラグ */
#define	Int_Type				0xB4	/* 要求されている割り込み */
#define	Int_Eoi					0xB6	/* End of Interruptの発行 */

/*--------------------------------------*/
/*	定数定義							*/
/*--------------------------------------*/
/*●割り込みbit*/
/* Set */
#define	INT_CommSendSet			0x01	/* 送信データ空			(or) */
#define	INT_KeySet				0x02	/* キー割り込み			(or) */
#define	INT_CasetteSet			0x04	/* カセット割り込み		(or) */
#define	INT_CommReciSet			0x08	/* 受信データレディー	(or) */
#define	INT_LCDlineSet			0x10	/* LCD絵画ライン検知	(or) */
#define	INT_VblankSet			0x20	/* Vblank 				(or) */
#define	INT_VblankStartSet		0x40	/* Vblank期間開始		(or) */
#define	INT_HblankSet			0x80	/* Hblank				(or) */
/* Reset*/
#define	INT_CommSendRes			0xFE	/* 送信データ空			(and) */
#define	INT_KeyRes				0xFD	/* キー割り込み			(and) */
#define	INT_Casette	Res			0xFB	/* カセット割り込み		(and) */
#define	INT_CommReciRes			0xF7	/* 受信データレディー	(and) */
#define	INT_LCDlineRes			0xFF	/* LCD絵画ライン検知	(and) */
#define	INT_VblankRes			0xDF	/* Vblank 				(and) */
#define	INT_VblankStartRes		0xBF	/* Vblank期間開始		(and) */
#define	INT_HblankRes			0x7F	/* Hblank				(and) */

/*========================================================================
	シリアル通信
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*●I/O Address*/
#define	COMM_DATA				0xB1	/* Send & Receive data */
#define	COMM_STATUS				0xB3	/* Serial Status */

/*--------------------------------------*/
/*	定数定義							*/
/*--------------------------------------*/
/*●Status bit*/
/* Set */
#define	COMM_Receive			0x01	/* 受信データ有り（受信可）	 */
#define	COMM_OverRun			0x02	/* オーバーラン・エラー		 */
#define	COMM_SendEmpty			0x04	/* 送信バッファ空（送信可）	 */
#define	COMM_OrReset			0x20	/* オーバーラン・エラーのリセット */
#define	COMM_Baudrate38k		0x40	/* ボーレート（38400 [bps])	(or) */
#define	COMM_Enable				0x80	/* 通信イネーブル			(or) */
/* Reset */
#define	COMM_Baudrate9K			0xBF	/* ボーレート（ 9600 [bps])	(and) */
#define	COMM_Disable			0x7F	/* 通信ディセーブル			(and) */

/*========================================================================
	キー
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*●I/O Address*/
#define	KEY						0xB5	/* COMON & Key Data */

/*--------------------------------------*/
/*	定数定義							*/
/*--------------------------------------*/
/*●Comon bit*/
#define	KEY_GroupY				0x10	/* Y1,Y2,Y3,Y4 */
#define	KEY_GroupX				0x20	/* X1,X2,X3,X4 */
#define	KEY_GroupABS			0x40	/* A,B,Start */

/*========================================================================
	バンク
=========================================================================*/
/*--------------------------------------*/
/*	I/O Device							*/
/*--------------------------------------*/
/*●I/O Address*/
#define	Bank_Sram				0xC1	/* SRAM Bank */
#define	Bank_Rom1				0xC2	/* ROM1 Bank */
#define	Bank_Rom2				0xC3	/* ROM2 Bank */
