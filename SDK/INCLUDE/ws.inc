;***********************************************************************
;*		Wonder Witch program for C Magazine			
;*			Device Define file				
;*				Programed by A.Watanabe (S.W.)		
;***********************************************************************
;=========================================================================
;	�V�X�e��
;=========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;��I/O Address
Hardware		equ	0A0h	; �@�픻�ʗp 

;--------------------------------------
;	�萔��`
;--------------------------------------
;��Status bit
HardwareMask		equ	002h	; �@�픻�ʗp 

;========================================================================
;	���
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;��I/O Address
LCD_DisplayControl	equ	000h	; ��� 
LCD_Line		equ	002h	; �G��f�[�^�������̃��C�� 
LCD_Interrupt		equ	003h	; ���荞�݂������郉�C�� 
LCD_SpriteArea		equ	004h	; Sprite��VRAM 
LCD_SpriteStart		equ	005h	; �\������X�v���C�g�̍ŏ��̔ԍ� 
LCD_SpriteCount		equ	006h	; �\������X�v���C�g�̐� 
LCD_ScreenArea		equ	007h	; Screen��VRAM 
LCD_Scr2WindowsStart	equ	008h	; Screen2 Window�̍���̍��W[dot] 
LCD_Scr2WindowsEnd	equ	00Ah	; Screen2 Window�̉E���̍��W[dot] 
LCD_SprWindowsStart	equ	00Ch	; Sprite  Window�̍���̍��W[dot] 
LCD_SprWindowsEnd	equ	00Eh	; Sprite  Window�̉E���̍��W[dot] 
LCD_Scr1Scroll		equ	010h	; Screen1�̃X�N���[���� 
LCD_Scr2Scroll		equ	012h	; Screen2�̃X�N���[���� 
LCD_IF_Ctrl		equ	014h	; IF�R���g���[�� 
LCD_Segment		equ	015h	; �Z�O�����g�E�}�[�N 
LCD_Gray0123		equ	01Ch	; ���m�N��8�K�� 0�`3 
LCD_Gray4567		equ	01Eh	; ���m�N��8�K�� 4�`7 
LCD_ScrPalette		equ	020h	; ���m�N���p���b�g 
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
LCD_ColorMode		equ	060h	; �J���[���[�h 

;��Memory Address			; �X�^�[�g�E�A�b�v���[�`���ł̐ݒ�l 
VramAdrFontMono		equ	02000h		; Mono  Font��VRAM�A�h���X 
VramAdrFontColor	equ	04000h		; Color Font��VRAM�A�h���X 
VramAdrPalette		equ	0fe00h		; Palettte  ��VRAM�A�h���X 

; AscII�P ���[�h 
VramAdrSprite_a1	equ	02e00h		; Sprite    ��VRAM�A�h���X 
VramAdrScreen1_a1	equ	03000h		; Screen    ��VRAM�A�h���X 
VramAdrScreen2_a1	equ	03000h		; Screen    ��VRAM�A�h���X 
; AscII�Q ���[�h 
VramAdrSprite_a2	equ	02600h		; Sprite    ��VRAM�A�h���X 
VramAdrScreen1_a2	equ	03000h		; Screen    ��VRAM�A�h���X 
VramAdrScreen2_a2	equ	02800h		; Screen    ��VRAM�A�h���X 
; ���{��P ���[�h 
VramAdrSprite_j1	equ	01600h		; Sprite    ��VRAM�A�h���X 
VramAdrScreen1_j1	equ	01800h		; Screen    ��VRAM�A�h���X 
VramAdrScreen2_j1	equ	01800h		; Screen    ��VRAM�A�h���X 
; ���{��Q ���[�h 
VramAdrSprite_j2	equ	00e00h		; Sprite    ��VRAM�A�h���X 
VramAdrScreen1_j2	equ	01000h		; Screen    ��VRAM�A�h���X 
VramAdrScreen2_j2	equ	01800h		; Screen    ��VRAM�A�h���X 
; �I���W�i�� ���[�h 
VramAdrSprite_sc	equ	02e00h		; Sprite    ��VRAM�A�h���X 
VramAdrScreen1_sc	equ	03000h		; Screen    ��VRAM�A�h���X 
VramAdrScreen2_sc	equ	03800h		; Screen    ��VRAM�A�h���X 

ifdef DISPLAY_MODE_ASCII1		; AscII�P ���[�h 
VramAdrSprite		equ	VramAdrSprite_a1	; Sprite��VRAM�A�h���X 
VramAdrScreen1		equ	VramAdrScreen1_a1	; Screen��VRAM�A�h���X 
VramAdrScreen2		equ	VramAdrScreen2_a1	; Screen��VRAM�A�h���X 
endif
ifdef DISPLAY_MODE_ASCII2		; AscII�Q ���[�h 
VramAdrSprite		equ	VramAdrSprite_a2	; Sprite��VRAM�A�h���X 
VramAdrScreen1		equ	VramAdrScreen1_a2	; Screen��VRAM�A�h���X 
VramAdrScreen2		equ	VramAdrScreen2_a2	; Screen��VRAM�A�h���X 
endif
ifdef DISPLAY_MODE_JAPANESE1	; ���{��P ���[�h 
VramAdrSprite		equ	VramAdrSprite_j1	; Sprite��VRAM�A�h���X 
VramAdrScreen1		equ	VramAdrScreen1_j1	; Screen��VRAM�A�h���X 
VramAdrScreen2		equ	VramAdrScreen2_j1	; Screen��VRAM�A�h���X 
endif
ifdef DISPLAY_MODE_JAPANESE2	; ���{��Q ���[�h 
VramAdrSprite		equ	VramAdrSprite_j2	; Sprite��VRAM�A�h���X 
VramAdrScreen1		equ	VramAdrScreen1_j2	; Screen��VRAM�A�h���X 
VramAdrScreen2		equ	VramAdrScreen2_j2	; Screen��VRAM�A�h���X 
endif
ifdef DISPLAY_MODE_swCOLOR		; �I���W�i�� ���[�h 
VramAdrSprite		equ	VramAdrSprite_sc	; Sprite��VRAM�A�h���X 
VramAdrScreen1		equ	VramAdrScreen1_sc	; Screen��VRAM�A�h���X 
VramAdrScreen2		equ	VramAdrScreen2_sc	; Screen��VRAM�A�h���X 
endif

;--------------------------------------
;	�萔��`
;--------------------------------------
;���A�g���r���[�g�p
Atr_Character		equ	001FFh		; �L�����N�^�[�ԍ�(0�`511) 
Atr_Palette		equ	01E00h		; �p���b�g 
Atr_CharacterH		equ	02000h		; �L�����N�^�[�ԍ�( + 512) 
Atr_Vm			equ	04000h		; �����] 
Atr_Hm			equ	08000h		; �c���] 

;��I/O Display Control�p
LCD_DispCtrl_Scr1	equ	00001h		; Screen1 Enable 
LCD_DispCtrl_Scr2	equ	00002h		; Screen2 Enable 
LCD_DispCtrl_Spr	equ	00004h		; Sprite  Enable 
LCD_DispCtrl_SprWin	equ	00008h		; Sprite  Windows Enable 
LCD_DispCtrl_ScrWin	equ	00030h		; Screen2 Windows Mode 
LCD_DispCtrl_BCol	equ	00F00h		; �{�[�_�[ Color 
LCD_DispCtrl_BPal	equ	0F000h		; �{�[�_�[ Palette 

;��I/O LCD Segment�p
LCD_Segment_Sleep	equ	001h		; Sleep�_�� 
LCD_Segment_Hor		equ	002h		; �c�_�� 
LCD_Segment_Ver		equ	004h		; ���_�� 

;��I/O Color mode�p
LCD_ColorModeMask	equ	01fh		; �J���[���[�h�ׂ̈̃}�X�N�l 

;��LCD�֘A 
LCD_Sprite		equ	128		; �X�v���C�g�� 
LCD_ScrHight		equ	32		; VRAM�̏c�T�C�Y 
LCD_ScrWidth		equ	32		; VRAM�̉��T�C�Y 
LCD_Font		equ	1024		; �t�H���g�� 
LCD_FontSizeMono	equ	16		; �t�H���g�̃T�C�Y 
LCD_FontSize		equ	32		; �t�H���g�̃T�C�Y 
LCD_Palette		equ	16		; �p���b�g�� 
LCD_Color		equ	16		; �P�p���b�g�ł̐F�� 
LCD_FontMono		equ	512		; �F��(2^2= 4) 
LCD_FontColor		equ	1024		; �F��(2^4=16) 
LCD_FontHight		equ	8		; �t�H���g�̏c�T�C�Y 
LCD_FontWidth		equ	8		; �t�H���g�̉��T�C�Y 

;========================================================================
;	�T�E���h
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;��I/O Address
SOUND_Frequency		equ	080h		; ���g�� 
SOUND_FrequencyCh1	equ	SOUND_Frequency + 0
SOUND_FrequencyCh2	equ	SOUND_Frequency + 2
SOUND_FrequencyCh3	equ	SOUND_Frequency + 4
SOUND_FrequencyCh4	equ	SOUND_Frequency + 6
SOUND_Volume		equ	088h		; ���� 
SOUND_VolumeCh1		equ	SOUND_Volume + 0
SOUND_VolumeCh2		equ	SOUND_Volume + 1
SOUND_VolumeCh3		equ	SOUND_Volume + 2
SOUND_VolumeCh4		equ	SOUND_Volume + 3
SOUND_PCMVoice		equ	SOUND_VolumeCh2	; PCM Voice 
SOUND_Sweep		equ	08Ch		; Sweep 
SOUND_SweepLevel	equ	SOUND_Sweep + 0	; Sweep Level 
SOUND_SweepTime		equ	SOUND_Sweep + 1	; Sweep time 
SOUND_Noise		equ	08Eh		; Noise mode 
SOUND_VoiceAddress	equ	08Fh		; ���FWave address 
SOUND_Channel		equ	090h		; Channel mode 
SOUND_Output		equ	091h		; Output mode 
SOUND_Random		equ	092h		; Random get 
SOUND_VolumePCM		equ	094h		; PCM Voice Volume 

;��Memory Address
SOUND_VoiceAdr		equ	00180h		; FreyaBIOS Work Area 

;--------------------------------------
;	�萔��`
;--------------------------------------
;���m�C�Y���[�h
SOUND_NoiseMode		equ	007h		; �m�C�Y�E���[�h 
SOUND_NoiseReset	equ	008h		; �����J�E���^�[�E���Z�b�g 
SOUND_NoiseEnable	equ	010h		; �C�l�[�u���E�X�C�b�` 

;���`�����l�����[�h
SOUND_ChannelCh1	equ	001h		; Ch1 Enable 
SOUND_ChannelCh2	equ	002h		; Ch2 Enable 
SOUND_ChannelCh3	equ	004h		; Ch3 Enable 
SOUND_ChannelCh4	equ	008h		; Ch4 Enable 
SOUND_ChannelPcmVoice	equ	020h		; PCM Voice Enable 
SOUND_ChannelSweep	equ	040h		; Sweep Enable 
SOUND_ChannelNoise	equ	080h		; Noise Enable 

;���o�̓��[�h
SOUND_OutputSpkEn	equ	001h		; �����X�s�[�JEnable 
SOUND_OutputRange	equ	006h		; �����X�s�[�J�o�̓����W 
SOUND_OutputPhoneEn	equ	008h		; �O���X�s�[�JEnable 
SOUND_OutputPhoneSw	equ	080h		; �O���X�s�[�J�ڑ��`�F�b�N 

;��Channel
SOUND_ChannelMax	equ	4		; �`�����l���� 

;���e��}�X�N
SOUND_FrequencyMask	equ	007FFh		; ����Range 
SOUND_VolumeMask	equ	00Fh		; ����Range 

;�����F�p
SOUND_VoiceSize		equ	16		; ���F�p�����[�^�̃T�C�Y 

;========================================================================
;	�^�C�}�[
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;��I/O Address
TIMER_Status		equ	0A2h	; Timer Status 
TIMER_MaxCountH		equ	0A4h	; Hblank Load Count 
TIMER_MaxCountV		equ	0A6h	; Vblank Load Count 
TIMER_CounterH		equ	0A8h	; Hblank Down Counter 
TIMER_CounterV		equ	0AAh	; Vblank Down Counter 

;--------------------------------------
;	�萔��`
;--------------------------------------
;��Status bit
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
;	���荞��
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;��I/O Address
Int_Vector		equ	0B0h	; ���荞�݃x�N�^ (����֎~) 
Int_Enable		equ	0B2h	; ���荞�݉ۃt���O 
Int_Type		equ	0B4h	; �v������Ă��銄�荞�� 
Int_Eoi			equ	0B6h	; End of Interrupt�̔��s 

;--------------------------------------
;	�萔��`
;--------------------------------------
;�����荞�݃x�N�g��
INT_HARDWARE_VECTOR_BASE	equ	028h

;�����荞�ݔԍ���`
SYS_INT_SENDREADY		equ	0	;�V���A�����M�f�[�^�G���v�e�B�[
SYS_INT_KEY			equ	1	;�L�[���荞��
SYS_INT_CASETTE			equ	2	;�J�Z�b�g���荞��
SYS_INT_RECEIVEREADY		equ	3	;�V���A����M�f�[�^���f�B�[
SYS_INT_DISPLINE		equ	4	;�`�惉�C���ԍ����m���荞��
SYS_INT_VBLANK_COUNTUP		equ	5	;���������^�C�}�[���荞��
SYS_INT_VBLANK			equ	6	;�����������ԊJ�n
SYS_INT_HBLANK_COUNTUP		equ	7	;���������^�C�}�[���荞��

INT_SENDREADY		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_SENDREADY
INT_KEY_PUSH		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_KEY
INT_CASETTE		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_CASETTE
INT_RECEIVEREADY	equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_RECEIVEREADY
INT_DISPLINE		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_DISPLINE
INT_VBLANK_COUNTUP	equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_VBLANK_COUNTUP
INT_VBLANK		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_VBLANK
INT_HBLANK_COUNTUP	equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_HBLANK_COUNTUP

;�����荞��bit
; Set 
INT_CommSendSet		equ	001h	; ���M�f�[�^��		(or) 
INT_KeySet		equ	002h	; �L�[���荞��		(or) 
INT_CasetteSet		equ	004h	; �J�Z�b�g���荞��	(or) 
INT_CommReciSet		equ	008h	; ��M�f�[�^���f�B�[	(or) 
INT_LCDlineSet		equ	010h	; LCD�G�惉�C�����m	(or) 
INT_VblankSet		equ	020h	; Vblank 		(or) 
INT_VblankStartSet	equ	040h	; Vblank���ԊJ�n	(or) 
INT_HblankSet		equ	080h	; Hblank		(or) 
; Reset
INT_CommSendRes		equ	0FEh	; ���M�f�[�^��		(and) 
INT_KeyRes		equ	0FDh	; �L�[���荞��		(and) 
INT_CasetteRes		equ	0FBh	; �J�Z�b�g���荞��	(and) 
INT_CommReciRes		equ	0F7h	; ��M�f�[�^���f�B�[	(and) 
INT_LCDlineRes		equ	0FFh	; LCD�G�惉�C�����m	(and) 
INT_VblankRes		equ	0DFh	; Vblank 		(and) 
INT_VblankStartRes	equ	0BFh	; Vblank���ԊJ�n	(and) 
INT_HblankRes		equ	07Fh	; Hblank		(and) 

;========================================================================
;	�V���A���ʐM
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;��I/O Address
COMM_DATA		equ	0B1h	; Send & Receive data 
COMM_STATUS		equ	0B3h	; Serial Status 

;--------------------------------------
;	�萔��`
;--------------------------------------
;��Status bit
; Set 
COMM_Receive		equ	001h	; ��M�f�[�^�L��i��M�j	 
COMM_OverRun		equ	002h	; �I�[�o�[�����E�G���[		 
COMM_SendEmpty		equ	004h	; ���M�o�b�t�@��i���M�j	 
COMM_OrReset		equ	020h	; �I�[�o�[�����E�G���[�̃��Z�b�g 
COMM_Baudrate38k	equ	040h	; �{�[���[�g�i38400 [bps])	(or) 
COMM_Enable		equ	080h	; �ʐM�C�l�[�u��		(or) 
; Reset 
COMM_Baudrate9K		equ	0BFh	; �{�[���[�g�i 9600 [bps])	(and) 
COMM_Disable		equ	07Fh	; �ʐM�f�B�Z�[�u��		(and) 

;========================================================================
;	�L�[
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;��I/O Address
KEY			equ	0B5h	; COMON & Key Data 

;--------------------------------------
;	�萔��`
;--------------------------------------
;��Comon bit
KEY_GroupY		equ	010h	; Y1,Y2,Y3,Y4 
KEY_GroupX		equ	020h	; X1,X2,X3,X4 
KEY_GroupABS		equ	040h	; A,B,Start 

;========================================================================
;	�o���N
;========================================================================
;--------------------------------------
;	I/O Device
;--------------------------------------
;��I/O Address
Bank_SramSelect		equ	0C1h	; SRAM Bank 
Bank_Rom1Select		equ	0C2h	; ROM1 Bank 
Bank_Rom2Select		equ	0C3h	; ROM2 Bank 