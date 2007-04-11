;=======================================================================|
;									|
;		ROM image (0xF0000�`0xFFFFF)				|
;			for Wander Swan Total Sound Driver		|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;	�I�I���ӁI�I							|
;									|
;	0xFFF0:0x0000�̗̈�ɁA						|
;	far jump�AWonderSwan����p�̃f�[�^�������Ȃ��̂�		|
;	.WS(ROM�C���[�W)�t�@�C���̍쐬���ɏ������ƁI�I			|
;=======================================================================|

	.186

;=======================================================================|
;				define					|
;=======================================================================|
include	service.inc			;��`�t�@�C���@���荞��
include	bank.inc			;��`�t�@�C���@�o���N
include	wtd_def.inc			;��`�t�@�C���@�h���C�o�[
include	wtd_ver.inc			;��`�t�@�C���@�o�[�W�������

;=======================================================================|
;			I/O   ---[ I-RAM Define ]---			|
;=======================================================================|

IRAM_Stack		equ	02e00h

VRAM_Sprite		equ	02e00h	;23
VRAM_Screen1		equ	03000h	;6
VRAM_Screen2		equ	03800h	;7
VRAM_Font		equ	04000h	;
VRAM_Palette		equ	0FE00h	;

;���̃X�^�[�g�A�b�v
IRAM_Stack		equ	2e00h	;0x02??-0x2dff	Stack        Area
IRAM_Sprite		equ	23	;0x2e00-0x2FFF	Sprite  VRAM Area
IRAM_Screen1		equ	6	;0x3000-0x37FF	Screen1 VRAM Area
IRAM_Screen2		equ	7	;0x3800-0x3FFF	Screen2 VRAM Area

;=======================================================================|
;			I/O   ---[ Display Define ]---			|
;=======================================================================|
;I/O
LCD_Display_Control	equ	000h	;Display Control
LCD_Sprite_Area		equ	004h	;Sprite Start Number
LCD_Sprite_Start	equ	005h	;Sprite Start Number
LCD_Sprite_Range	equ	006h	;Sprite Range
LCD_Screen_Area		equ	007h	;Sprite Start Number
LCD_Screen2_WinStart	equ	008h	;Screen2 Window Start Locate
LCD_Screen2_WinEnd	equ	00ah	;Screen2 Window End Locate
LCD_Sprite_WinStart	equ	00ch	;Sprite Window Start Locate
LCD_Sprite_WinEnd	equ	00eh	;Sprite Window End Locate
LCD_Screen1_Scroll	equ	010h	;Screen1 Scroll Locate
LCD_Screen2_Scroll	equ	012h	;Screen2 Scroll Locate
LCD_Color_Mode		equ	060h	;Wonder Swan Color
HARDWARE		equ	0a0h	;Hardware Type
;=======================================================================|
;			I/O   ---[ Interrupt Define ]---		|
;=======================================================================|
;I/O�A�h���X
Int_Base		equ	0b0h	;�x�[�X�x�N�g��
Int_Enable		equ	0b2h	;�}�X�N
Int_Case		equ	0b4h	;�P�[�X
Int_Eoi			equ	0b6h	;End of Interrupt�̔��s

;���荞�݃x�N�g��
INT_HARDWARE_VECTOR_BASE	equ	028h
;===============���荞�ݔԍ���`
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

;=======================================================================|
;				Segment define				|
;=======================================================================|
;��CODE�̈�--------------------------------------------------------------
TEXT		segment byte public 'CODE'	; for LSI-C
TEXT		ends

_TEXT		segment byte public 'CODE'	; for TurboC
_TEXT		ends

_GHOST_DATA	segment para public 'CODE'	;LSI-C86�ł͕K�v�B
_GHOST_DATA	ends				;

;��DATA�̈�@�������f�[�^�̈�--------------------------------------------
	public	dseg_start
DATA		segment para public 'DATA'	; for LSI-C
dseg_start:
DATA		ends


_DATA		segment para public 'DATA'	; for TurboC0
_DATA		ends

;��BSS�̈�@���������f�[�^�̈�-------------------------------------------
	public	bss_start
BSS		segment word public 'DATA'	; for LSI-C
bss_start:
BSS		ends

_BSS		segment word public 'BSS'	; for TurboC
_BSS		ends

;��HEAP�̈�@�󂫗̈�----------------------------------------------------
	public	heap_start
_HEAP		segment para public 'BSS'
heap_start:
_HEAP		ends

;���Z�O�����g�E�O���[�v��`
CGROUP		group	_TEXT, TEXT
DGROUP		group	_DATA, DATA, BSS, _BSS, _HEAP

		assume	cs:CGROUP, ds:DGROUP, es:DGROUP

;****************************************************************
;*								*
;*			�v���O�����E�R�[�h			*
;*								*
;****************************************************************
TEXT	segment byte public 'CODE'

;===============================================================|
;			�O���錾				|
;===============================================================|

	;�b�����main�֐�
	extrn	_main			:near	;�b�����main�֐�

	;�v�s�c�̊֐�
	extrn	_WTD_FunctionLoad	:near	;�t�@���N�V�����̃��[�h
	extrn	_WTD_Work		:near	;����p���[�N

	;���̓���
	public	_Start				;CPU���Z�b�g���ɌĂ΂��
	public	_Exit				;main�֐��𔲂�����
	public	_InterruptVector_Default	;���荞�݃x�N�^�����l(reti)
	public	_InterruptVector_DivZero	;�O���Z���荞�݃��[�`��

;===============================================================|
;			Start Up				|
;===============================================================|
_Start:	
		cli			;
		cld			;

		;-------------------------------
		;���荞�݂̐ݒ�
		mov	al,0		;
		out	Int_Enable,al	;���荞�݋֎~

		mov	al,INT_HARDWARE_VECTOR_BASE
		out	Int_Base,al	;�x�[�X�x�N�g���ݒ�

		;-------------------------------
		;�X�^�b�N�G���A�̐ݒ�
		mov	ax,IRAM_Segment	;
		mov	es,ax		;
		mov	ss,ax		;
		mov	sp,IRAM_Stack	;

		;-------------------------------
		;�������ς݃f�[�^�̓]��
		mov	cx, offset DGROUP:bss_start
		shr	cx, 1		; word alignmented

		mov	ax, cs		;

		sub	ax, TEXT	;
		add	ax,_GHOST_DATA	;

		mov	ds, ax		;DS��DGROUP�̈ʒu����
		mov	si, offset DGROUP:dseg_start
		mov	di, si		;
	rep	movsw			;�ꊇ�]��

		;-------------------------------
		;���������f�[�^�̂O�N���A
		mov	cx, offset DGROUP:heap_start
		push	cx
		mov	di, offset DGROUP:bss_start
		sub	cx, di
		shr	cx, 1
		xor	ax, ax
	rep	stosw

		;-------------------------------
		;���荞�݃x�N�g���̐ݒ�
		mov	cx,256
		mov	di,offset DGROUP:_InteruptVector
		mov	ax,cs
		mov	bx,offset CGROUP:_InterruptVector_Default
_Start_SetIntVector_Loop1:
		mov	es:[di],ax
		mov	es:[di+2],bx
		add	di,4
		dec	cx
		jnz	_Start_SetIntVector_Loop1

;�J���[�`�F�b�N----------------------------------------------------------
		in	al,HARDWARE		;�n�[�h�E�F�A�E�`�F�b�N
		and	al,02h			;
		jnz	_run0_color		;

;�f�o�C�X�̏�����-------------------------------------------------------
_run0_color:

	;V-RAM�A�h���X�ݒ�
	mov	al,IRAM_Sprite
	out	LCD_Sprite_Area,al
	mov	al,IRAM_Screen1 + IRAM_Screen2 * 16
	out	LCD_Screen_Area,al

	mov	ax,1			;Screen 1,2 Sprite �L��
	out	LCD_Display_Control,ax	;display_control(0001h);

	xor	ax,ax
	out	LCD_Sprite_Start,al	;sprite_set_range(0,0);
	out	LCD_Sprite_Range,al	;
	out	LCD_Screen1_Scroll,ax	;screen_set_scroll(SCREEN1, 0, 0);
	out	LCD_Screen2_Scroll,ax	;screen_set_scrol2(SCREEN2, 0, 0);
	out	LCD_Screen2_WinStart,ax	;
	out	LCD_Sprite_WinStart,ax	;
	mov	ax,0FFFFh
	out	LCD_Screen2_WinEnd,ax	;screen2_set_window(0, 0, 255, 255);
	out	LCD_Sprite_WinEnd,ax	;sprite_set_window(0, 0, 255, 255);

		;-------------------------------
		;Color Mode
		in	al,LCD_Color_Mode	;Packed Mode
		or	al,0E0h			;
		out	LCD_Color_Mode,al	;

		push	cs			;
		pop	ds			;ds��cs

		;-------------------------------
		;Font
		mov	cx,2048			;128 *8 *2
		mov	si,offset CGROUP:_FontAscii
		mov	di,offset DGROUP:VRAM_Font
	rep	movsw

		;-------------------------------
		;Palette
		mov	cx,16			;
		mov	si,offset CGROUP:_FontPalette
		mov	di,offset DGROUP:VRAM_Palette
	rep	movsw

		;-------------------------------
		;V-RAM	fill space

		mov	cx,32*32*2	;32�~32 �~ 2 �L�����N�^
		mov	ax,00020h
		mov	di,offset DGROUP:VRAM_Screen1
	rep	stosw	

		;-------------------------------
		;���荞�݋���

		sti

		;-------------------------------
		;DS��DGROUP

		mov	ax,IRAM_Segment
		mov	ds,ax
		mov	es,ax

		;-------------------------------
		;�b�����main�֐��Ăяo��
		call	_main
_Exit:

		;-------------------------------
		;�v���O�����I��
_Loop:
		jmp	_Loop

;===============================================================|
;			���荞�ݐ�̏����ݒ�l			|
;===============================================================|
_InterruptVector_Default:
	iret
;===============================================================|
;			�O���Z���荞��				|
;===============================================================|
_InterruptVector_DivZero:
	iret

;===============================================================|
;			�����t�H���g				|
;===============================================================|
_FontPalette:
	dw	0000h
	dw	0007h
	dw	0070h
	dw	0077h
	dw	0700h
	dw	0707h
	dw	0770h
	dw	0777h
	dw	0000h
	dw	000Fh
	dw	00F0h
	dw	00FFh
	dw	0F00h
	dw	0F0Fh
	dw	0FF0h
	dw	0FFFh
;===============================================================|
;			�����t�H���g				|
;===============================================================|
_FontAscii:
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0
	
	dd	0CCCCCCCCh
	dd	0CCCCCCCCh
	dd	0CCCCCCCCh
	dd	0CCCCCCCCh
	dd	0CCCCCCCCh
	dd	0CCCCCCCCh
	dd	0CCCCCCCCh
	dd	0CCCCCCCCh
	
	dd	000000000h
	dd	000000000h
	dd	000000000h
	dd	000000000h
	dd	000000000h
	dd	000000000h
	dd	000000000h
	dd	000000000h
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	

	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	

	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CEF4CFCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	0CEF0C4CCh
	dd	0CE40CCCCh
	dd	0CEF4CFCCh
	dd	0CEF0CFCCh
	dd	0EE00E4EEh
	
	dd	0CEF44FFFh
	dd	0CEF00FFFh
	dd	0CEF0044Fh
	dd	0CE400FF4h
	dd	0CE0CC440h
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	04EFFF4CFh
	dd	00EFFF04Fh
	dd	0F4FFFFFFh
	dd	000FFF04Fh
	dd	0F4FFFFFFh
	dd	000FFF04Fh
	dd	00E4FF0C4h
	dd	00EE440EEh
	
	dd	0CE4CFFC4h
	dd	04EFFFF4Fh
	dd	00E00FFF4h
	dd	0CEF4FF4Fh
	dd	04E4FFFC4h
	dd	00EF4FFFFh
	dd	0CE004F40h
	dd	0EE0E40EEh
	
	dd	0FEC44C4Fh
	dd	0404FF0F4h
	dd	00EF4044Fh
	dd	0CE404FCCh
	dd	04E0FF4C4h
	dd	0FEF4404Fh
	dd	0404F0CF4h
	dd	00EEEEEE0h
	
	dd	0CE4CFFC4h
	dd	0CEF4F0CFh
	dd	0CEF0F0CFh
	dd	0F440FF4Fh
	dd	0400F0FFFh
	dd	00EFF04FFh
	dd	0F44FFF4Fh
	dd	0000400E4h
	
	dd	0CECCF4CFh
	dd	0CECCF0CFh
	dd	0CECCF0C4h
	dd	0CECC40CFh
	dd	0CECC0CC4h
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CEF4CFCCh
	dd	0CEF04FCCh
	dd	0CE00FFCCh
	dd	0CE0CFFCCh
	dd	0CE0CFFCCh
	dd	0CEF44FCCh
	dd	0CEF0CFCCh
	dd	0EE00E4EEh
	
	dd	0CE4CFFCCh
	dd	0CE0CFFCCh
	dd	0CEF44FCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	0CE00FFCCh
	dd	0CE0CFFCCh
	dd	0EE0E40EEh
	
	dd	0CE4CCFCCh
	dd	04E0F4FCFh
	dd	00EF4FFC4h
	dd	0CE004FCCh
	dd	0CEF4FFC4h
	dd	04E0F4FCFh
	dd	00E040FC4h
	dd	0EE0EE4EEh
	
	dd	0CECCCCCCh
	dd	0CE4CCFCCh
	dd	0CE0CCFCCh
	dd	04EFFFFCFh
	dd	00E000FC4h
	dd	0CE0CCFCCh
	dd	0CE0CC4CCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CE4CFFCCh
	dd	0CE0C4FCCh
	dd	0CE0CF4CCh
	dd	0EEEE40EEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	04EFFFFCFh
	dd	00E0000C4h
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CE4CFFCCh
	dd	0CE0CFFCCh
	dd	0CE0C40CCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CE4FCCCCh
	dd	00EF4C4CCh
	dd	0CE404FCCh
	dd	0CE0CF4C4h
	dd	0CECC40CFh
	dd	0CECC0CC4h
	dd	0EEEEEEEEh
	

	dd	04EFFFF4Fh
	dd	0F40F00FFh
	dd	0F0FF04FFh
	dd	0F04F0FFFh
	dd	0F00FF4FFh
	dd	0F04F00FFh
	dd	000FFFF4Fh
	dd	00E0000E4h
	
	dd	0CEF44FCCh
	dd	0CEF0FFCCh
	dd	0CEF04FCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	04EFFFFCCh
	dd	00E0040EEh
	
	dd	04EFFFF4Fh
	dd	0F40F00FFh
	dd	0F0CF0C40h
	dd	000FFFFCCh
	dd	00E00F0CFh
	dd	0F4CC00FFh
	dd	0F0FFFFFFh
	dd	000000040h
	
	dd	04EFFFF4Fh
	dd	0F40F00FFh
	dd	0F04F0C40h
	dd	000FFFFCCh
	dd	0F40F40CCh
	dd	0F04FCCFFh
	dd	000FFFF4Fh
	dd	00E0000E4h
	
	dd	0CEF44FCCh
	dd	0CEF0FFC4h
	dd	0CEF0FF4Fh
	dd	0CEF00FFFh
	dd	0F4FFFFFFh
	dd	000F00F40h
	dd	04EFFFFCCh
	dd	00E0040EEh
	
	dd	0F4FFFFCFh
	dd	00000004Fh
	dd	04EFFFFFFh
	dd	0F40F00FFh
	dd	0F0CF0C40h
	dd	0F04F4C88h
	dd	000FFFF4Fh
	dd	00E0000E4h
	
	dd	04EFFFFC4h
	dd	0F40FF0CFh
	dd	000C4F04Fh
	dd	04EFFFFFFh
	dd	0F40F00FFh
	dd	0F04F0CFFh
	dd	000FFFF4Fh
	dd	00E0000E4h
	
	dd	04EFFFFCFh
	dd	00EFFFFCFh
	dd	00E0F00C4h
	dd	00EF4CCCCh
	dd	0CEF0CCCCh
	dd	0CE40CFCCh
	dd	0CE0CCFCCh
	dd	0EE0EE4EEh
	
	dd	04EFFFF4Fh
	dd	0F40F00FFh
	dd	0F04F0CFFh
	dd	000FFFF4Fh
	dd	0F40F00FFh
	dd	0F04F0CFFh
	dd	000FFFF4Fh
	dd	00E0000E4h
	
	dd	04EFFFF4Fh
	dd	0F40F00FFh
	dd	0F0CF0CFFh
	dd	0F0FFFF4Fh
	dd	0F00F00C4h
	dd	000FFC4CCh
	dd	00EF0FFCCh
	dd	0EE0040EEh
	
	dd	0CECCCCCCh
	dd	0CEF4CFCCh
	dd	0CEF0CFCCh
	dd	0CE00C4CCh
	dd	0CEF4CFCCh
	dd	0CEF0CFCCh
	dd	0CE00C4CCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CEF4CFCCh
	dd	0CEF0CFCCh
	dd	0CE00C4CCh
	dd	0CEF4CFCCh
	dd	0CEF0C4CCh
	dd	0CE40CFCCh
	dd	0EE0EE4EEh
	
	dd	04EFFC4CCh
	dd	00EF04FCCh
	dd	0CE00FFC4h
	dd	0CE0CF0CFh
	dd	0CE4CFFC4h
	dd	0CEF44FCCh
	dd	04EFFC4CCh
	dd	00E40EEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	04EFFFFCFh
	dd	00E0000C4h
	dd	04EFFFFCFh
	dd	00E0000C4h
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCF4CFh
	dd	0CE4CFFC4h
	dd	0CEF44FCCh
	dd	04EFFC4CCh
	dd	00EF04FCCh
	dd	0CE00FFC4h
	dd	0CE0CF0CFh
	dd	0EEEE00E4h
	
	dd	04EFFFF4Fh
	dd	0F40F00FFh
	dd	0F04F0C40h
	dd	000FFC4CCh
	dd	00EF0CFCCh
	dd	0CE00C4CCh
	dd	0CEF4CFCCh
	dd	0EE00E4EEh
	

	dd	0CEF4FFC4h
	dd	04E0F404Fh
	dd	00ECF0FF4h
	dd	00EFFF4F0h
	dd	00EF04FF0h
	dd	0F400444Fh
	dd	040FFFFC4h
	dd	00E0040EEh
	
	dd	0CEF44FCCh
	dd	04EFFF4CCh
	dd	00EFFF0CCh
	dd	00EFFFFC4h
	dd	0F40F404Fh
	dd	0F0CF0CFFh
	dd	000C40C40h
	dd	0EEEEEEEEh
	
	dd	04EFFFFFFh
	dd	0F40FF04Fh
	dd	040FFFFCFh
	dd	0F40FF0CFh
	dd	0F04FF04Fh
	dd	040FFFFFFh
	dd	00C000040h
	dd	0EEEEEEEEh
	
	dd	0F4F4FF4Fh
	dd	0F00F00FFh
	dd	0F0C40CFFh
	dd	040CC0CFFh
	dd	0F4CF0CFFh
	dd	000FFFF4Fh
	dd	00E0000C4h
	dd	0EEEEEEEEh
	
	dd	04EFFFFFFh
	dd	0F40FF04Fh
	dd	0F0CFF0CFh
	dd	0F0CFF0CFh
	dd	0F04FF04Fh
	dd	040FFFFFFh
	dd	00E000040h
	dd	0EEEEEEEEh
	
	dd	0F4FFFFFFh
	dd	0F000F04Fh
	dd	040F4FFCFh
	dd	0CEF0F0CFh
	dd	0F440F04Fh
	dd	0F0FFFFFFh
	dd	000000040h
	dd	0EEEEEEEEh
	
	dd	0F4FFFFFFh
	dd	0F000F04Fh
	dd	040F4FFCFh
	dd	0CEF0F0CFh
	dd	0CE40F04Fh
	dd	0CE4CFFFFh
	dd	0CE0C0040h
	dd	0EEEEEEEEh
	
	dd	0F4F4FF4Fh
	dd	0F00F00FFh
	dd	000C40CFFh
	dd	0F0FF0FFFh
	dd	000FF04FFh
	dd	00EFFFF4Fh
	dd	00E0000C4h
	dd	0EEEEEEEEh
	
	dd	0F48FF4FFh
	dd	0004FF04Fh
	dd	00EFFFFCFh
	dd	00E0FF0CFh
	dd	00E4FF04Fh
	dd	0F48FF0FFh
	dd	000400040h
	dd	0EEEEEEEEh
	
	dd	04EFFFFCCh
	dd	00EF04FCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	0CEF04FCCh
	dd	04EFFFFCCh
	dd	00E0040CCh
	dd	0EEEEEEEEh
	
	dd	04EFFFFCCh
	dd	00EF04FCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	0CEF04FFFh
	dd	0CE00FF4Fh
	dd	0CE0C00C4h
	dd	0EEEEEEEEh
	
	dd	0F44FFFFFh
	dd	0000FF04Fh
	dd	00EF4FFCFh
	dd	0CEF0FFCFh
	dd	04EFFF04Fh
	dd	0F44FFFFFh
	dd	000040040h
	dd	0EEEEEEEEh
	
	dd	0CE4CFFFFh
	dd	0CE0CF04Fh
	dd	0CECCF0CFh
	dd	0CECCF0CFh
	dd	0F4C4F04Fh
	dd	0F0FFFFFFh
	dd	000000040h
	dd	0EEEEEEEEh
	
	dd	0F44F4CFFh
	dd	0F0FFF44Fh
	dd	0F0FFF0CFh
	dd	0F04F0FCFh
	dd	0F00F0F4Fh
	dd	0F0FFF4FFh
	dd	000400040h
	dd	0EEEEEEEEh
	
	dd	0F4FFF4FFh
	dd	0004FF04Fh
	dd	00E4FFFCFh
	dd	00EFF0FCFh
	dd	00EFF044Fh
	dd	0F4FFF4FFh
	dd	000400040h
	dd	0EEEEEEEEh
	
	dd	04EFFFF4Fh
	dd	0F40F00FFh
	dd	0F0CF0CFFh
	dd	0F0CF0CFFh
	dd	0F04F0CFFh
	dd	000FFFF4Fh
	dd	00E0000C4h
	dd	0EEEEEEEEh
	

	dd	04EFFFFFFh
	dd	0F40FF04Fh
	dd	0F04FF0CFh
	dd	040FFFFCFh
	dd	00E00F04Fh
	dd	0CE4CFFFFh
	dd	0CE0C0040h
	dd	0EEEEEEEEh
	
	dd	04EFFFF4Fh
	dd	0F40F00FFh
	dd	0F0CF0CFFh
	dd	0F04FFFFFh
	dd	0F00F0FFFh
	dd	040FFFF4Fh
	dd	00EF000C4h
	dd	0EE40EEEEh
	
	dd	04EFFFFFFh
	dd	0F40FF04Fh
	dd	0F04FF0CFh
	dd	000FFFFCFh
	dd	0F40FF0CFh
	dd	0F0CFF0FFh
	dd	000C40040h
	dd	0EEEEEEEEh
	
	dd	04EFFFF4Fh
	dd	0F40F00FFh
	dd	000C4FF4Fh
	dd	04EFF0FC4h
	dd	0F40FC4FFh
	dd	040FFFF4Fh
	dd	00E0000C4h
	dd	0EEEEEEEEh
	
	dd	04EFFFFFFh
	dd	00E0FFFF0h
	dd	00E04FF40h
	dd	0CE0CFFCCh
	dd	0CE0CFFC4h
	dd	0CEF4FFCFh
	dd	0CE0000C4h
	dd	0EEEEEEEEh
	
	dd	0F4FFF4FFh
	dd	000CFF04Fh
	dd	00ECFF0CFh
	dd	00ECFF0CFh
	dd	00E4FF0CFh
	dd	00EF4FFC4h
	dd	0CE0040CCh
	dd	0EEEEEEEEh
	
	dd	0F4FFF4FFh
	dd	0004F0CFFh
	dd	00EF4F44Fh
	dd	0CEF0F0CFh
	dd	0CE40FFC4h
	dd	0CE0CFFCCh
	dd	0CE0C40CCh
	dd	0EEEEEEEEh
	
	dd	0F4CCCCFFh
	dd	0F0F40FFFh
	dd	0F0F00FFFh
	dd	0F0F00FFFh
	dd	040FFF44Fh
	dd	00EFFF0CFh
	dd	00E4000C4h
	dd	0EEEEEEEEh
	
	dd	0F4FFF4FFh
	dd	000F0F04Fh
	dd	0CE40FFC4h
	dd	0CEF44FCCh
	dd	04EFFF4C4h
	dd	0F4FFF0FFh
	dd	000400040h
	dd	0EEEEEEEEh
	
	dd	0F4FFF4FFh
	dd	0004F004Fh
	dd	00EF4F4C4h
	dd	0CE404FCCh
	dd	0CE0C4FCCh
	dd	0CEF4FFCCh
	dd	0CE0040CCh
	dd	0EEEEEEEEh
	
	dd	0F4FFFFFFh
	dd	0F00F00F0h
	dd	000F44F40h
	dd	04C00FFC4h
	dd	0F40440FFh
	dd	0F0FFFFFFh
	dd	000000040h
	dd	0EEEEEEEEh
	
	dd	0CEF4FFCCh
	dd	0CE00FFCCh
	dd	0CE0CFFCCh
	dd	0CE0CFFCCh
	dd	0CE0CFFCCh
	dd	0CE0CFFCCh
	dd	0CEF4FFCCh
	dd	0EE0040EEh
	
	dd	04E4FCCF4h
	dd	00EF4CC4Fh
	dd	04EFFFFFFh
	dd	00E00FF40h
	dd	04EFFFFFFh
	dd	00E00FF40h
	dd	0CE0CFFCCh
	dd	0EE0E40EEh
	
	dd	0CEF4FFCCh
	dd	0CEF04FCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	0CEF04FCCh
	dd	0CEF0FFCCh
	dd	0EE0040EEh
	
	dd	0CE4C4FCCh
	dd	0CEF4F4C4h
	dd	04E4F40CFh
	dd	00EC40CC4h
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0F4FFFFFFh
	dd	000000040h
	

	dd	0CECCF4CFh
	dd	0CECC00CFh
	dd	0CECCF4C4h
	dd	0CECC40CCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CEF4FFCFh
	dd	04EFF00C4h
	dd	00EFFFF4Fh
	dd	00EFF00FFh
	dd	0FE4FFF4Fh
	dd	0000400C4h
	dd	0EEEEEEEEh
	
	dd	0CECCF4FFh
	dd	0CECCF04Fh
	dd	04EFFFFCFh
	dd	0FE0FF0CFh
	dd	0F04FF04Fh
	dd	040FFFFFFh
	dd	00E000040h
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CEF4FF4Fh
	dd	0CE0040FFh
	dd	04E4F0CFFh
	dd	00EF4FF4Fh
	dd	0CE0000C4h
	dd	0EEEEEEEEh
	
	dd	04EFFCFCCh
	dd	00EFFC4CCh
	dd	00EFFFF4Fh
	dd	00EFF00FFh
	dd	00EFF04FFh
	dd	0F4FFFF4Fh
	dd	0000000C4h
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CEF4FF4Fh
	dd	04EFF00FFh
	dd	00EF0FFFFh
	dd	04E0F00FFh
	dd	00EF4FF4Fh
	dd	0CE0000C4h
	dd	0EEEEEEEEh
	
	dd	0CEF4FFCCh
	dd	04E0FF0CFh
	dd	00EC4F04Fh
	dd	0CEF4FFFFh
	dd	0CE00F04Fh
	dd	0CE4CFFFFh
	dd	0CE0C0040h
	dd	0EEEEEEEEh
	
	dd	0F44FCCCCh
	dd	000FFFF4Fh
	dd	00EFF00FFh
	dd	00EFF04FFh
	dd	00EFFFF4Fh
	dd	00EFF00C4h
	dd	00EF0FFFFh
	dd	0EE000040h
	
	dd	0CECCF4FFh
	dd	0CE4CF04Fh
	dd	0CEF4FFCFh
	dd	04E0FF0CFh
	dd	00E4FF04Fh
	dd	0F4FFF0FFh
	dd	000400000h
	dd	0EEEEEEEEh
	
	dd	0CEF4CFCCh
	dd	0CE00C4CCh
	dd	0CEF4FFCCh
	dd	0CEF04FCCh
	dd	0CEF04FCCh
	dd	04EFFFFCCh
	dd	00E0040CCh
	dd	0EEEEEEEEh
	
	dd	0CEF4CFCCh
	dd	0CE00C4CCh
	dd	0CEF4FFCCh
	dd	0CEF04FCCh
	dd	0CEF0CFCCh
	dd	0CEF04FCCh
	dd	0CE40FFCCh
	dd	0EE0E40EEh
	
	dd	0CECCF4FFh
	dd	0CECCF04Fh
	dd	0F44FF0CFh
	dd	000FFF0CFh
	dd	00EF0FF4Fh
	dd	0F40FF0FFh
	dd	000C40040h
	dd	0EEEEEEEEh
	
	dd	0CEF4FFCCh
	dd	0CEF04FCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	0CEF04FCCh
	dd	04EFFFFCCh
	dd	00E0040CCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	04E4F4FFFh
	dd	0F4F4F44Fh
	dd	0F0F0F0CFh
	dd	0F0F0F0CFh
	dd	0F0F0F0CFh
	dd	0404000C4h
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CEF44FFFh
	dd	04E0FF04Fh
	dd	00ECFF0CFh
	dd	00E4FF04Fh
	dd	0F4FFF0FFh
	dd	000400040h
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0CEF4FF4Fh
	dd	04EFF00FFh
	dd	00EFF0CFFh
	dd	00EFF04FFh
	dd	00EF0FF4Fh
	dd	0CE0000C4h
	dd	0EEEEEEEEh
	

	dd	0CECCCCCCh
	dd	04EFF4FFFh
	dd	0F40FF44Fh
	dd	0F04FF0CFh
	dd	040FFFFCFh
	dd	00E00F04Fh
	dd	0CE4CFFFFh
	dd	0EE0E0040h
	
	dd	0CECCCCCCh
	dd	0F44FFF4Fh
	dd	000FF00FFh
	dd	00EFF04FFh
	dd	00EFFFF4Fh
	dd	00EFF00C4h
	dd	0F4FFCFCCh
	dd	00000E4EEh
	
	dd	0CECCCCCCh
	dd	0CEF44FFFh
	dd	04E0FF44Fh
	dd	00EC4F0CFh
	dd	0CECCF04Fh
	dd	0CE4CFFFFh
	dd	0CE0C0040h
	dd	0EEEEEEEEh
	
	dd	0F4C4CCCCh
	dd	0F0FF4FCCh
	dd	00000FFCCh
	dd	04EFF4FCCh
	dd	0F40F4CCFh
	dd	040FFFF4Fh
	dd	00E0000F4h
	dd	0EEEEEE40h
	
	dd	0CECCCCCCh
	dd	0CE4CFFC4h
	dd	04EFFFFFFh
	dd	00E00FF40h
	dd	0CE0CFFCCh
	dd	04EFF4FCCh
	dd	00E00C4CCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	04EFFF4FFh
	dd	00EFFF04Fh
	dd	00EFFF0CFh
	dd	00EFFF0CFh
	dd	0F44FFFC4h
	dd	0000440CCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0F4CFF4FFh
	dd	000CF00FFh
	dd	00EF4F44Fh
	dd	0CEF0F0CFh
	dd	0CE40FFC4h
	dd	0CE0C40CCh
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0F4CC4CFFh
	dd	0F0F40FFFh
	dd	0F0F00FFFh
	dd	0F0F00FFFh
	dd	040FFF44Fh
	dd	00E4000C4h
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	04EFFF4CFh
	dd	00EF0F0C4h
	dd	0CE404FCCh
	dd	0CEF4FCC4h
	dd	04EFFF0CFh
	dd	00E4000C4h
	dd	0EEEEEEEEh
	
	dd	0CECCCCCCh
	dd	0F4FFF4FFh
	dd	000FF004Fh
	dd	00EFF04CFh
	dd	00EFFFFC4h
	dd	00EFF40CCh
	dd	00EF4FFCCh
	dd	0EE0040EEh
	
	dd	0CECCCCCCh
	dd	04EFFFFFFh
	dd	00EF000F0h
	dd	0CE40FF40h
	dd	04E0F404Fh
	dd	00EFFFFFFh
	dd	00E000040h
	dd	0EEEEEEEEh
	
	dd	0CEF44FCCh
	dd	0CE00FFCCh
	dd	0CE0CFFC4h
	dd	0CE0CF0CFh
	dd	0CE4CFFC4h
	dd	0CE0CFFCCh
	dd	0CEF44FCCh
	dd	0EE00E4EEh
	
	dd	0CEF4CFCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	0CEF0CFCCh
	dd	0EE00E4EEh
	
	dd	0CE4CFFCCh
	dd	0CEF44FCCh
	dd	0CEF0CFCCh
	dd	04EFFC4CCh
	dd	00EF0CFCCh
	dd	0CEF04FCCh
	dd	0CE00FFCCh
	dd	0EE0E40EEh
	
	dd	0F44FFF4Fh
	dd	0F00F0FFFh
	dd	000FF04FFh
	dd	00E400C40h
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0CECCCCCCh
	dd	0EEEEEEEEh
	
	dd	0F4FFFFFFh
	dd	0F0FFFFFFh
	dd	0F0FFFFFFh
	dd	0F0FFFFFFh
	dd	0F0FFFFFFh
	dd	0F0FFFFFFh
	dd	0F0FFFFFFh
	dd	000000040h

;===============================================================|
TEXT	ends

;****************************************************************
;*								*
;*			�f�[�^�Q				*
;*								*
;****************************************************************
DATA	segment para public 'DATA'

;===============================================================|
;			�O���錾				|
;===============================================================|
	public	_InteruptVector		;���荞�݃x�N�^

;===============================================================|
;			�f�[�^����				|
;===============================================================|
_InteruptVector:			;���荞�݃x�N�^���f�o�C�X�p
	dd	256	dup	(0)	;0x0180�́A���F�e�[�u��
					;0x0000�`0x03FF


DATA	ends

;��BSS�̈�@���������f�[�^�̈�-------------------------------------------
BSS		segment word public 'DATA'
INITSIZE:
BEGINBSS:
BSS		ends

_BSS		segment word public 'BSS'
_BSS		ends

;��HEAP�̈�@�󂫗̈�----------------------------------------------------
_HEAP		segment para public 'BSS'
ENDBSS:
BEGINHEAP:
_HEAP		ends

;****************************************************************
	end	_Start