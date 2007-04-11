;***********************************************************************
;*		Wonder Witch program for C Magazine			
;*			Device Define file				
;*				Programed by A.Watanabe (S.W.)		
;***********************************************************************
;=========================================================================
;	システム
;=========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;●I/O Address
Hardware		equ	0A0h	; 機種判別用 

;--------------------------------------
;	定数定義
;--------------------------------------
;●Status bit
HardwareMask		equ	002h	; 機種判別用 

;========================================================================
;	画面
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;●I/O Address
LCD_DisplayControl	equ	000h	; 画面 
LCD_Line		equ	002h	; 絵画データ生成中のライン 
LCD_Interrupt		equ	003h	; 割り込みをかけるライン 
LCD_SpriteArea		equ	004h	; SpriteのVRAM 
LCD_SpriteStart		equ	005h	; 表示するスプライトの最初の番号 
LCD_SpriteCount		equ	006h	; 表示するスプライトの数 
LCD_ScreenArea		equ	007h	; ScreenのVRAM 
LCD_Scr2WindowsStart	equ	008h	; Screen2 Windowの左上の座標[dot] 
LCD_Scr2WindowsEnd	equ	00Ah	; Screen2 Windowの右下の座標[dot] 
LCD_SprWindowsStart	equ	00Ch	; Sprite  Windowの左上の座標[dot] 
LCD_SprWindowsEnd	equ	00Eh	; Sprite  Windowの右下の座標[dot] 
LCD_Scr1Scroll		equ	010h	; Screen1のスクロール量 
LCD_Scr2Scroll		equ	012h	; Screen2のスクロール量 
LCD_IF_Ctrl		equ	014h	; IFコントロール 
LCD_Segment		equ	015h	; セグメント・マーク 
LCD_Gray0123		equ	01Ch	; モノクロ8階調 0～3 
LCD_Gray4567		equ	01Eh	; モノクロ8階調 4～7 
LCD_ScrPalette		equ	020h	; モノクロパレット 
LCD_ScrPalette0		equ	LCD_ScrPalette + 000h
LCD_ScrPalette1		equ	LCD_ScrPalette + 002h
LCD_ScrPalette2		equ	LCD_ScrPalette + 004h
LCD_ScrPalette3		equ	LCD_ScrPalette + 006h
LCD_ScrPalette4		equ	LCD_ScrPalette + 008h
LCD_ScrPalette5		equ	LCD_ScrPalette + 00Ah
LCD_ScrPalette6		equ	LCD_ScrPalette + 00Bh
LCD_ScrPalette7		equ	LCD_ScrPalette + 00Ch
LCD_ScrPalette8		equ	LCD_ScrPalette + 010h
LCD_ScrPalette9		equ	LCD_ScrPalette + 012h
LCD_ScrPaletteA		equ	LCD_ScrPalette + 014h
LCD_ScrPaletteB		equ	LCD_ScrPalette + 016h
LCD_ScrPaletteC		equ	LCD_ScrPalette + 018h
LCD_ScrPaletteD		equ	LCD_ScrPalette + 01Ah
LCD_ScrPaletteE		equ	LCD_ScrPalette + 01Ch
LCD_ScrPaletteF		equ	LCD_ScrPalette + 01Eh
LCD_ColorMode		equ	060h	; カラーモード 

;●Memory Address			; スタート・アップルーチンでの設定値 
VramAdrFontMono		equ	02000h		; Mono  FontのVRAMアドレス 
VramAdrFontColor	equ	04000h		; Color FontのVRAMアドレス 
VramAdrPalette		equ	0fe00h		; Palettte  のVRAMアドレス 

; AscII１ モード 
VramAdrSprite_a1	equ	02e00h		; Sprite    のVRAMアドレス 
VramAdrScreen1_a1	equ	03000h		; Screen    のVRAMアドレス 
VramAdrScreen2_a1	equ	03000h		; Screen    のVRAMアドレス 
; AscII２ モード 
VramAdrSprite_a2	equ	02600h		; Sprite    のVRAMアドレス 
VramAdrScreen1_a2	equ	03000h		; Screen    のVRAMアドレス 
VramAdrScreen2_a2	equ	02800h		; Screen    のVRAMアドレス 
; 日本語１ モード 
VramAdrSprite_j1	equ	01600h		; Sprite    のVRAMアドレス 
VramAdrScreen1_j1	equ	01800h		; Screen    のVRAMアドレス 
VramAdrScreen2_j1	equ	01800h		; Screen    のVRAMアドレス 
; 日本語２ モード 
VramAdrSprite_j2	equ	00e00h		; Sprite    のVRAMアドレス 
VramAdrScreen1_j2	equ	01000h		; Screen    のVRAMアドレス 
VramAdrScreen2_j2	equ	01800h		; Screen    のVRAMアドレス 
; オリジナル モード 
VramAdrSprite_sc	equ	02e00h		; Sprite    のVRAMアドレス 
VramAdrScreen1_sc	equ	03000h		; Screen    のVRAMアドレス 
VramAdrScreen2_sc	equ	03800h		; Screen    のVRAMアドレス 

ifdef DISPLAY_MODE_ASCII1		; AscII１ モード 
VramAdrSprite		equ	VramAdrSprite_a1	; SpriteのVRAMアドレス 
VramAdrScreen1		equ	VramAdrScreen1_a1	; ScreenのVRAMアドレス 
VramAdrScreen2		equ	VramAdrScreen2_a1	; ScreenのVRAMアドレス 
endif
ifdef DISPLAY_MODE_ASCII2		; AscII２ モード 
VramAdrSprite		equ	VramAdrSprite_a2	; SpriteのVRAMアドレス 
VramAdrScreen1		equ	VramAdrScreen1_a2	; ScreenのVRAMアドレス 
VramAdrScreen2		equ	VramAdrScreen2_a2	; ScreenのVRAMアドレス 
endif
ifdef DISPLAY_MODE_JAPANESE1	; 日本語１ モード 
VramAdrSprite		equ	VramAdrSprite_j1	; SpriteのVRAMアドレス 
VramAdrScreen1		equ	VramAdrScreen1_j1	; ScreenのVRAMアドレス 
VramAdrScreen2		equ	VramAdrScreen2_j1	; ScreenのVRAMアドレス 
endif
ifdef DISPLAY_MODE_JAPANESE2	; 日本語２ モード 
VramAdrSprite		equ	VramAdrSprite_j2	; SpriteのVRAMアドレス 
VramAdrScreen1		equ	VramAdrScreen1_j2	; ScreenのVRAMアドレス 
VramAdrScreen2		equ	VramAdrScreen2_j2	; ScreenのVRAMアドレス 
endif
ifdef DISPLAY_MODE_swCOLOR		; オリジナル モード 
VramAdrSprite		equ	VramAdrSprite_sc	; SpriteのVRAMアドレス 
VramAdrScreen1		equ	VramAdrScreen1_sc	; ScreenのVRAMアドレス 
VramAdrScreen2		equ	VramAdrScreen2_sc	; ScreenのVRAMアドレス 
endif

;--------------------------------------
;	定数定義
;--------------------------------------
;●アトリビュート用
Atr_Character		equ	001FFh		; キャラクター番号(0～511) 
Atr_Palette		equ	01E00h		; パレット 
Atr_CharacterH		equ	02000h		; キャラクター番号( + 512) 
Atr_Vm			equ	04000h		; 横反転 
Atr_Hm			equ	08000h		; 縦反転 

;●I/O Display Control用
LCD_DispCtrl_Scr1	equ	00001h		; Screen1 Enable 
LCD_DispCtrl_Scr2	equ	00002h		; Screen2 Enable 
LCD_DispCtrl_Spr	equ	00004h		; Sprite  Enable 
LCD_DispCtrl_SprWin	equ	00008h		; Sprite  Windows Enable 
LCD_DispCtrl_ScrWin	equ	00030h		; Screen2 Windows Mode 
LCD_DispCtrl_BCol	equ	00F00h		; ボーダー Color 
LCD_DispCtrl_BPal	equ	0F000h		; ボーダー Palette 

;●I/O LCD Segment用
LCD_Segment_Sleep	equ	001h		; Sleep点灯 
LCD_Segment_Hor		equ	002h		; 縦点灯 
LCD_Segment_Ver		equ	004h		; 横点灯 

;●I/O Color mode用
LCD_ColorModeMask	equ	01fh		; カラーモードの為のマスク値 

;●LCD関連 
LCD_Sprite		equ	128		; スプライト数 
LCD_ScrHight		equ	32		; VRAMの縦サイズ 
LCD_ScrWidth		equ	32		; VRAMの横サイズ 
LCD_Font		equ	1024		; フォント数 
LCD_FontSizeMono	equ	16		; フォントのサイズ 
LCD_FontSize		equ	32		; フォントのサイズ 
LCD_Palette		equ	16		; パレット数 
LCD_Color		equ	16		; １パレットでの色数 
LCD_FontMono		equ	512		; 色数(2^2= 4) 
LCD_FontColor		equ	1024		; 色数(2^4=16) 
LCD_FontHight		equ	8		; フォントの縦サイズ 
LCD_FontWidth		equ	8		; フォントの横サイズ 

;========================================================================
;	サウンド
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;●I/O Address
SOUND_Frequency		equ	080h		; 周波数 
SOUND_FrequencyCh1	equ	SOUND_Frequency + 0
SOUND_FrequencyCh2	equ	SOUND_Frequency + 2
SOUND_FrequencyCh3	equ	SOUND_Frequency + 4
SOUND_FrequencyCh4	equ	SOUND_Frequency + 6
SOUND_Volume		equ	088h		; 音量 
SOUND_VolumeCh1		equ	SOUND_Volume + 0
SOUND_VolumeCh2		equ	SOUND_Volume + 1
SOUND_VolumeCh3		equ	SOUND_Volume + 2
SOUND_VolumeCh4		equ	SOUND_Volume + 3
SOUND_PCMVoice		equ	SOUND_VolumeCh2	; PCM Voice 
SOUND_Sweep		equ	08Ch		; Sweep 
SOUND_SweepLevel	equ	SOUND_Sweep + 0	; Sweep Level 
SOUND_SweepTime		equ	SOUND_Sweep + 1	; Sweep time 
SOUND_Noise		equ	08Eh		; Noise mode 
SOUND_VoiceAddress	equ	08Fh		; 音色Wave address 
SOUND_Channel		equ	090h		; Channel mode 
SOUND_Output		equ	091h		; Output mode 
SOUND_Random		equ	092h		; Random get 
SOUND_VolumePCM		equ	094h		; PCM Voice Volume 

;●Memory Address
SOUND_VoiceAdr		equ	00180h		; FreyaBIOS Work Area 

;--------------------------------------
;	定数定義
;--------------------------------------
;●ノイズモード
SOUND_NoiseMode		equ	007h		; ノイズ・モード 
SOUND_NoiseReset	equ	008h		; 生成カウンター・リセット 
SOUND_NoiseEnable	equ	010h		; イネーブル・スイッチ 

;●チャンネルモード
SOUND_ChannelCh1	equ	001h		; Ch1 Enable 
SOUND_ChannelCh2	equ	002h		; Ch2 Enable 
SOUND_ChannelCh3	equ	004h		; Ch3 Enable 
SOUND_ChannelCh4	equ	008h		; Ch4 Enable 
SOUND_ChannelPcmVoice	equ	020h		; PCM Voice Enable 
SOUND_ChannelSweep	equ	040h		; Sweep Enable 
SOUND_ChannelNoise	equ	080h		; Noise Enable 

;●出力モード
SOUND_OutputSpkEn	equ	001h		; 内蔵スピーカEnable 
SOUND_OutputRange	equ	006h		; 内蔵スピーカ出力レンジ 
SOUND_OutputPhoneEn	equ	008h		; 外部スピーカEnable 
SOUND_OutputPhoneSw	equ	080h		; 外部スピーカ接続チェック 

;●Channel
SOUND_ChannelMax	equ	4		; チャンネル数 

;●各種マスク
SOUND_FrequencyMask	equ	007FFh		; 音程Range 
SOUND_VolumeMask	equ	00Fh		; 音量Range 

;●音色用
SOUND_VoiceSize		equ	16		; 音色パラメータのサイズ 

;========================================================================
;	タイマー
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;●I/O Address
TIMER_Status		equ	0A2h	; Timer Status 
TIMER_MaxCountH		equ	0A4h	; Hblank Load Count 
TIMER_MaxCountV		equ	0A6h	; Vblank Load Count 
TIMER_CounterH		equ	0A8h	; Hblank Down Counter 
TIMER_CounterV		equ	0AAh	; Vblank Down Counter 

;--------------------------------------
;	定数定義
;--------------------------------------
;●Status bit
; Set 
Timer_H_Enable		equ	001h	; Hblank Int. Enable	(or) 
Timer_H_auto		equ	002h	; Vblank auto preset mode(or) 
Timer_V_Enable		equ	004h	; Vblank Int. Enable 	(or) 
Timer_V_auto		equ	008h	; Vblank auto preset mode(or) 
; Reset
Timer_H_Disable		equ	0FEh	; Hblank Int. Disable	(and) 
Timer_H_shot		equ	0FDh	; Vblank 1 shot mode	(and) 
Timer_V_Disable		equ	0FBh	; Vblank Int. Disable	(and) 
Timer_V_shot		equ	0F7h	; Vblank 1 shot mode	(and) 

;========================================================================
;	割り込み
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;●I/O Address
Int_Vector		equ	0B0h	; 割り込みベクタ (操作禁止) 
Int_Enable		equ	0B2h	; 割り込み可否フラグ 
Int_Type		equ	0B4h	; 要求されている割り込み 
Int_Eoi			equ	0B6h	; End of Interruptの発行 

;--------------------------------------
;	定数定義
;--------------------------------------
;●割り込みベクトル
INT_HARDWARE_VECTOR_BASE	equ	028h

;●割り込み番号定義
SYS_INT_SENDREADY		equ	0	;シリアル送信データエンプティー
SYS_INT_KEY			equ	1	;キー割り込み
SYS_INT_CASETTE			equ	2	;カセット割り込み
SYS_INT_RECEIVEREADY		equ	3	;シリアル受信データレディー
SYS_INT_DISPLINE		equ	4	;描画ライン番号検知割り込み
SYS_INT_VBLANK_COUNTUP		equ	5	;垂直同期タイマー割り込み
SYS_INT_VBLANK			equ	6	;垂直同期期間開始
SYS_INT_HBLANK_COUNTUP		equ	7	;水平同期タイマー割り込み

INT_SENDREADY		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_SENDREADY
INT_KEY_PUSH		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_KEY
INT_CASETTE		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_CASETTE
INT_RECEIVEREADY	equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_RECEIVEREADY
INT_DISPLINE		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_DISPLINE
INT_VBLANK_COUNTUP	equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_VBLANK_COUNTUP
INT_VBLANK		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_VBLANK
INT_HBLANK_COUNTUP	equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_HBLANK_COUNTUP

;●割り込みbit
; Set 
INT_CommSendSet		equ	001h	; 送信データ空		(or) 
INT_KeySet		equ	002h	; キー割り込み		(or) 
INT_CasetteSet		equ	004h	; カセット割り込み	(or) 
INT_CommReciSet		equ	008h	; 受信データレディー	(or) 
INT_LCDlineSet		equ	010h	; LCD絵画ライン検知	(or) 
INT_VblankSet		equ	020h	; Vblank 		(or) 
INT_VblankStartSet	equ	040h	; Vblank期間開始	(or) 
INT_HblankSet		equ	080h	; Hblank		(or) 
; Reset
INT_CommSendRes		equ	0FEh	; 送信データ空		(and) 
INT_KeyRes		equ	0FDh	; キー割り込み		(and) 
INT_CasetteRes		equ	0FBh	; カセット割り込み	(and) 
INT_CommReciRes		equ	0F7h	; 受信データレディー	(and) 
INT_LCDlineRes		equ	0FFh	; LCD絵画ライン検知	(and) 
INT_VblankRes		equ	0DFh	; Vblank 		(and) 
INT_VblankStartRes	equ	0BFh	; Vblank期間開始	(and) 
INT_HblankRes		equ	07Fh	; Hblank		(and) 

;========================================================================
;	シリアル通信
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;●I/O Address
COMM_DATA		equ	0B1h	; Send & Receive data 
COMM_STATUS		equ	0B3h	; Serial Status 

;--------------------------------------
;	定数定義
;--------------------------------------
;●Status bit
; Set 
COMM_Receive		equ	001h	; 受信データ有り（受信可）	 
COMM_OverRun		equ	002h	; オーバーラン・エラー		 
COMM_SendEmpty		equ	004h	; 送信バッファ空（送信可）	 
COMM_OrReset		equ	020h	; オーバーラン・エラーのリセット 
COMM_Baudrate38k	equ	040h	; ボーレート（38400 [bps])	(or) 
COMM_Enable		equ	080h	; 通信イネーブル		(or) 
; Reset 
COMM_Baudrate9K		equ	0BFh	; ボーレート（ 9600 [bps])	(and) 
COMM_Disable		equ	07Fh	; 通信ディセーブル		(and) 

;========================================================================
;	キー
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;●I/O Address
KEY			equ	0B5h	; COMON & Key Data 

;--------------------------------------
;	定数定義
;--------------------------------------
;●Comon bit
KEY_GroupY		equ	010h	; Y1,Y2,Y3,Y4 
KEY_GroupX		equ	020h	; X1,X2,X3,X4 
KEY_GroupABS		equ	040h	; A,B,Start 

;========================================================================
;	バンク
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;●I/O Address
Bank_SramSelect		equ	0C1h	; SRAM Bank 
Bank_Rom1Select		equ	0C2h	; ROM1 Bank 
Bank_Rom2Select		equ	0C3h	; ROM2 Bank 
