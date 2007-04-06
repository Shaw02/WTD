;=======================================================================|
;									|
;		ROM image (0xF0000～0xFFFFF)				|
;			for Wander Swan Total Sound Driver		|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;	！！注意！！							|
;									|
;	0xFFF0:0x0000の領域に、						|
;	far jump、WonderSwan制御用のデータを書かないので		|
;	.WS(ROMイメージ)ファイルの作成時に書くこと！！			|
;=======================================================================|

	.186

;=======================================================================|
;				define					|
;=======================================================================|
include	service.inc			;定義ファイル　割り込み
include	bank.inc			;定義ファイル　バンク
include	wtd_def.inc			;定義ファイル　ドライバー
include	wtd_ver.inc			;定義ファイル　バージョン情報

;=======================================================================|
;			I/O   ---[ I-RAM Define ]---			|
;=======================================================================|

IRAM_Stack		equ	02e00h

VRAM_Sprite		equ	02e00h	;23
VRAM_Screen1		equ	03000h	;6
VRAM_Screen2		equ	03800h	;7
VRAM_Font		equ	04000h	;
VRAM_Palette		equ	0FE00h	;

;=======================================================================|
;			I/O   ---[ Interrupt Define ]---		|
;=======================================================================|
;I/Oアドレス
Int_Base		equ	0b0h	;ベースベクトル
Int_Enable		equ	0b2h	;マスク
Int_Case		equ	0b4h	;ケース
Int_Eoi			equ	0b6h	;End of Interruptの発行

;割り込みベクトル
INT_HARDWARE_VECTOR_BASE	equ	028h
;===============割り込み番号定義
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

;=======================================================================|
;				Segment define				|
;=======================================================================|
_TEXT		segment byte public 'CODE'	; for TurboC
_TEXT		ends

TEXT		segment byte public 'CODE'	; for LSI-C
TEXT		ends

_DATA		segment para public 'DATA'	; for TurboC
dseg_start:
_DATA		ends

DATA		segment para public 'DATA'	; for LSI-C
DATA		ends

BSS		segment word public 'DATA'	; for LSI-C
bss_start:
BSS		ends

_BSS		segment word public 'BSS'	; for TurboC
_BSS		ends

_HEAP		segment para public 'BSS'
heap_start:
_HEAP		ends

CGROUP		group	_TEXT, TEXT
DGROUP		group	_DATA, DATA, BSS, _BSS, _HEAP

		assume	cs:CGROUP, ds:DGROUP, es:DGROUP

;****************************************************************
;*								*
;*			データ群				*
;*								*
;****************************************************************
DATA	segment para public 'DATA'

;===============================================================|
;			外部宣言				|
;===============================================================|
	public	_InteruptVector		;割り込みベクタ

;===============================================================|
;			データ実体				|
;===============================================================|
_InteruptVector:			;割り込みベクタ＆デバイス用
	dd	256	dup	(0)	;0x0180は、音色テーブル
					;0x0000～0x03FF


DATA	ends
;****************************************************************
;*								*
;*			プログラム・コード			*
;*								*
;****************************************************************
TEXT	segment byte public 'CODE'

;===============================================================|
;			外部宣言				|
;===============================================================|

	;Ｃ言語のmain関数
	extrn	_main			:near	;Ｃ言語のmain関数

	;ＷＴＤの関数
	extrn	_WTD_FucntionLoad	:near	;ファンクションのロード
	extrn	_WTD_Work		:near	;制御用ワーク

	;この内部
	public	_Start				;CPUリセット時に呼ばれる
	public	_Exit				;main関数を抜けた先
	public	_InterruptVector_Default	;割り込みベクタ初期値(reti)
	public	_InterruptVector_DivZero	;０除算割り込みルーチン

;===============================================================|
;			Start Up				|
;===============================================================|
_Start:	
		;-------------------------------
		;割り込みの設定
		mov	al,0		;
		out	Int_Enable,al	;割り込み禁止

		mov	al,INT_HARDWARE_VECTOR_BASE
		out	Int_Base,al	;ベースベクトル設定

		;-------------------------------
		;スタックエリアの設定
		mox	ax,IRAM_Segment	;
		mov	es,ax		;
		mov	ss,ax		;
		mov	sp,IRAM_Stack	;

		;-------------------------------
		;初期化済みデータの転送
		mov	cx, offset DGROUP:bss_start
		shr	cx, 1		; word alignmented

		mov	ax, cs		;
		sub	ax, CGROUP	;
		add	ax, DGROUP	;
		mov	ds, ax		;DSにDGROUPの位置を代入
		mov	si, offset DGROUP:dseg_start
		mov	di, si		;
	rep	movsw			;一括転送

		;-------------------------------
		;未初期化データの０クリア
		mov	cx, offset DGROUP:heap_start
		push	cx
		mov	di, offset DGROUP:bss_start
		sub	cx, di
		shr	cx, 1
		xor	ax, ax
	rep	stosw

		;-------------------------------
		;DS＝DGROUP
		push	es		;
		pop	ds		;

		;-------------------------------
		;割り込みベクトルの設定
		mov	cx,128
		mov	di,offset DGROUP:_InteruptVector
		mov	ax,cs
		mov	bx,offset _InterruptVector_Default
_Start_SetIntVector_Loop:
		mov	ds:[di],ax
		mov	ds:[di+2],bx
		add	di,4
		dec	cs
		jnz	_Start_SetIntVector_Loop

		;-------------------------------
		;V-RAMの設定







		;-------------------------------
		;Font







		;-------------------------------
		;Ｃ言語のmain関数呼び出し
		call	_main
_Exit:

		;-------------------------------
		;プログラム終了
_Loop:
		jmp	_Loop

;===============================================================|
;			割り込み先の初期設定値			|
;===============================================================|
_InterruptVector_Default:
	reti
;===============================================================|
;			０除算割り込み				|
;===============================================================|
_InterruptVector_DivZero:
	reti
;****************************************************************
;*								*
;*			データ群				*
;*								*
;****************************************************************
_FontAscii:
	

;===============================================================|
_TEXT	ends

	end
