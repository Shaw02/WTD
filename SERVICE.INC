;=======================================================================|
;									|
;			ＷａｎｄｅｒＳｗａｎ				|
;				汎用定義ファイル			|
;				割り込み編				|
;									|
;						A.Watanabe (S.W.)	|
;									|
;=======================================================================|
;************************************************************************
;*									*
;*			ＢＩＯＳファンクション定義			*
;*									*
;************************************************************************
INT_BIOS_VECTOR_BASE		equ	010h
;===============割り込み番号定義
INT_EXIT	equ	INT_BIOS_VECTOR_BASE + 0	;プログラムの終了
INT_KEY		equ	INT_BIOS_VECTOR_BASE + 1	;キー制御
INT_DISP	equ	INT_BIOS_VECTOR_BASE + 2	;画面制御
INT_TEXT	equ	INT_BIOS_VECTOR_BASE + 3	;テキスト制御
INT_COMM	equ	INT_BIOS_VECTOR_BASE + 4	;シリアル通信制御
INT_SOUND	equ	INT_BIOS_VECTOR_BASE + 5	;サウンド制御
INT_TIMER	equ	INT_BIOS_VECTOR_BASE + 6	;カレンダ／タイマ制御
INT_SYSTEM	equ	INT_BIOS_VECTOR_BASE + 7	;システム制御
INT_BANK	equ	INT_BIOS_VECTOR_BASE + 8	;バンク制御


;************************************************************************
;*									*
;*			ハードウェア割り込み定義			*
;*									*
;************************************************************************
INT_HARDHAEW_VECTOR_BASE	equ	028h
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


;************************************************************************
;*									*
;*			システム割り込み定義				*
;*									*
;************************************************************************
INT_SYSCALL_VECTOR_BASE		equ	030h
;===============割り込み番号定義
INT_PROCESS	equ	INT_SYSCALL_VECTOR_BASE + 0	;不明
INT_FILESYS	equ	INT_SYSCALL_VECTOR_BASE + 1	;不明
INT_ILIB	equ	INT_SYSCALL_VECTOR_BASE + 2	;不明


