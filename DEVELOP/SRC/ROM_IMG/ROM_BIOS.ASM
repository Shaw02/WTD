;=======================================================================|
;									|
;		ROM image (0xF0000～0xFFFFF)				|
;			for Wander Swan Total Sound Driver		|
;									|
;					Programmed by			|
;						S.W.			|
;									|
;=======================================================================|
;	！！注意！！							|
;									|
;	0xFFF0:0x0000の領域に、						|
;	far jump、WonderSwan制御用のデータを書かないので		|
;	.WS(ROMイメージ)ファイルの作成時に書くこと！！			|
;									|
;	また"ROM_IMG.BIN"作成時は、このオブジェクトを先頭に配置する事	|
;	ラベル"_Start"が、メモリ0xF000:0000に配置されるように！		|
;=======================================================================|

	.186

;=======================================================================|
;				define					|
;=======================================================================|
DISPLAY_MODE_swCOLOR	equ	1	;SW定義のカラーに！

include	ws.inc				;定義ファイル　WonderSwan I/O
include	service.inc			;定義ファイル　割り込み
include	bank.inc			;定義ファイル　バンク
include	wtd_def.inc			;定義ファイル　ドライバー
include	wtd_ver.inc			;定義ファイル　バージョン情報

;=======================================================================|
;				Segment define				|
;=======================================================================|
;●CODE領域--------------------------------------------------------------
TEXT		segment byte public 'CODE'	; for LSI-C
TEXT		ends

_TEXT		segment byte public 'CODE'	; for TurboC
_TEXT		ends

_GHOST_DATA	segment para public 'CODE'	;LSI-C86では必要。
_GHOST_DATA	ends				;

;●DATA領域　初期化データ領域--------------------------------------------
	public	dseg_start
DATA		segment para public 'DATA'	; for LSI-C
dseg_start:
DATA		ends


_DATA		segment para public 'DATA'	; for TurboC0
_DATA		ends

;●BSS領域　未初期化データ領域-------------------------------------------
	public	bss_start
BSS		segment word public 'DATA'	; for LSI-C
bss_start:
BSS		ends

_BSS		segment word public 'BSS'	; for TurboC
_BSS		ends

;●HEAP領域　空き領域----------------------------------------------------
	public	heap_start
_HEAP		segment para public 'BSS'
heap_start:
_HEAP		ends

;●セグメント・グループ定義
CGROUP		group	_TEXT, TEXT
DGROUP		group	_DATA, DATA, BSS, _BSS, _HEAP

		assume	cs:CGROUP, ds:DGROUP, es:DGROUP

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
	extrn	_WTD_FunctionLoad	:near	;ファンクションのロード
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
		cli			;割り込み全般禁止
		cld			;インクリメントモード

		;-------------------------------
		;セグメントの設定
		mov	ax,IRAM_Segment	;
		mov	es,ax		;
		mov	ss,ax		;SS,ESにIRAMの位置を代入

		mov	ax, cs		;
		sub	ax, TEXT	;
		add	ax,_GHOST_DATA	;
		mov	ds, ax		;DSにDGROUPの位置を代入

		;-------------------------------
		;スタックエリアの設定
		mov	sp,VramAdrFontColor	;Color Fontを最後尾に

		;-------------------------------
		;初期化済みデータの転送
		mov	di, offset DGROUP:dseg_start
		mov	si, di		;
		mov	cx, offset DGROUP:bss_start
		shr	cx, 1		; word alignmented
	rep	movsw			;一括転送

		;-------------------------------
		;未初期化データの０クリア
		xor	ax, ax		;
		mov	di, offset DGROUP:bss_start
		mov	cx, offset DGROUP:heap_start
		sub	cx, di		;
		shr	cx, 1		;
	rep	stosw			;一括フィル

		;-------------------------------
		;割り込みベクトルの設定
		mov	ax,cs		;
		mov	bx,offset CGROUP:_InterruptVector_Default
		mov	di,offset DGROUP:_InteruptVector
		mov	cx,128		;ループ回数
_Start_SetIntVector_Loop1:		;
		mov	es:[di],bx	;
		mov	es:[di+2],ax	;
		add	di,4		;
		loop	_Start_SetIntVector_Loop1

		;-------------------------------
		;割り込みの設定
		mov	ax,0		;
		out	Int_Enable,al	;ハードウェア割り込み禁止

		mov	al,INT_HARDWARE_VECTOR_BASE
		out	Int_Vector,al	;ベースベクトル設定

;デバイスの初期化-------------------------------------------------------
		push	cs			;
		pop	ds			;ds←cs

		;カラーチェック
		in	al,HARDWARE		;ハードウェア・チェック
		and	al,HardwareMask		;
		jnz	_run0_color		;

_run0_mono:	;=======[ Normal WonderSwan ]=======
		;-------------------------------
		;Mono Mode
		in	al,LCD_ColorMode	;Mono Mode
		and	al,01Fh			;
		or	al,000h			;
		out	LCD_ColorMode,al	;

		jmp	_run0_common		;

_run0_color:	;=======[ WonderSwan Color ]=======
		;-------------------------------
		;Color Mode
		in	al,LCD_ColorMode	;Packed Mode
		and	al,01Fh			;
		or	al,0E0h			;
		out	LCD_ColorMode,al	;

		;-------------------------------
		;Color Palette
;		mov	si,offset CGROUP:_ColorPalette
		mov	si,offset CGROUP:_ColorFontData
		add	si,0010h		;Color PaletteのAddr.
		mov	di,offset DGROUP:VramAdrPalette
		mov	cx,16			;16色
	rep	movsw				;一括転送

		;-------------------------------
		;Color Font
;		mov	si,offset CGROUP:_bmp_ASCII_C
		mov	si,offset CGROUP:_ColorFontData
		add	si,0030h		;Color FontのAddr.
		mov	di,offset DGROUP:VramAdrFontColor
		mov	cx,128 *8 *2		;n × line × dd
	rep	movsw				;一括転送

		jmp	_run0_common

_run0_common:	;=======[ 全機種 共通設定 ]=======

		mov	ax,06420h		;
		out	LCD_Gray0123,ax		;
		mov	ax,0fca8h		;
		out	LCD_Gray4567,ax		;

		;-------------------------------
		;Mono Palette
;		mov	bx,offset CGROUP:_MonoPalette	;
		mov	bx,offset CGROUP:_MonoPalette	;
		mov	ax,cs:[bx]		;
		out	LCD_ScrPalette0,ax	;

		;-------------------------------
		;Mono Font
;		mov	si,offset CGROUP:_MonoPalette	;
		mov	si,offset CGROUP:_MonoFontData	;
		add	si,0010h		;Mono FontのAddr.
		mov	di,offset DGROUP:VramAdrFontMono
		mov	cx,128 *8 *1		;n × line × dw
	rep	movsw				;一括転送

		;-------------------------------
		;V-RAM	fill space
		mov	ax,00020h		;スペース
		mov	di,offset DGROUP:VramAdrScreen1
		mov	cx,32*32		;32×32キャラクタ
	rep	stosw				;一括フィル

	;V-RAMアドレス設定
	mov	al,(VramAdrSprite/512)
	out	LCD_SpriteArea,al
	mov	al,(VramAdrScreen1 / 2048) + ((VramAdrScreen2 / 2048) * 16)
	out	LCD_ScreenArea,al

	mov	ax,LCD_DispCtrl_Scr1 + LCD_DispCtrl_Spr
	out	LCD_DisplayControl,ax	;display_control(0005h);

	xor	ax,ax			;ax ← 0x0000
	out	LCD_SpriteStart,al	;sprite_set_range(0,0);
	out	LCD_SpriteCount,al	;
	out	LCD_Scr1Scroll,ax	;screen_set_scroll(SCREEN1, 0, 0);
	out	LCD_Scr2Scroll,ax	;screen_set_scrol2(SCREEN2, 0, 0);
	out	LCD_Scr2WindowsStart,ax	;
	out	LCD_SprWindowsStart,ax	;
	mov	ax,0FFFFh		;ax ← 0xFFFF
	out	LCD_Scr2WindowsEnd,ax	;screen2_set_window(0, 0, 255, 255);
	out	LCD_SprWindowsEnd,ax	;sprite_set_window(0, 0, 255, 255);

		;-------------------------------
		;DS＝DGROUP
		mov	ax,IRAM_Segment
		mov	ds,ax
		mov	es,ax

		;-------------------------------
		;割り込み許可
		sti

		;-------------------------------
		;Ｃ言語のmain関数呼び出し
		call	_main
_Exit:

		;-------------------------------
		;プログラム終了
_Loop:		cli			;割り込み禁止
		hlt			;CPU停止
		jmp	_Loop		;ループ

;===============================================================|
;			割り込み先の初期設定値			|
;===============================================================|
_InterruptVector_Default:
	iret
;===============================================================|
;			０除算割り込み				|
;===============================================================|
_InterruptVector_DivZero:
	iret

;****************************************************************
;*								*
;*			ROMにおくデータ群			*
;*								*
;****************************************************************
;===============================================================|
;			文字フォント				|
;===============================================================|
_ColorFontData:
include		ASCII_C.ASM		;カラーフォント

_MonoFontData:
include		ASCII_M.ASM		;モノクロフォント

_MonoPalette:
	dw	07503h		;Black	Black2	White	BG

;===============================================================|
TEXT	ends
;****************************************************************
;*								*
;*			データ群				*
;*								*
;****************************************************************
DATA	segment para public 'DATA'

	public	_InteruptVector		;割り込みベクタ
_InteruptVector:			;割り込みベクタ＆デバイス用
	dd	128	dup	(0)	;0x0180は、音色テーブル
					;0x0000～0x01FF


DATA	ends

;===============================================================|
;●BSS領域　未初期化データ領域-------------------------------------------
BSS		segment word public 'DATA'
INITSIZE:
BEGINBSS:
BSS		ends

_BSS		segment word public 'BSS'
_BSS		ends

;●HEAP領域　空き領域----------------------------------------------------
_HEAP		segment para public 'BSS'
ENDBSS:
BEGINHEAP:
_HEAP		ends

;****************************************************************
	end	_Start
