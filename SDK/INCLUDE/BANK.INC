;=======================================================================|
;									|
;			ＷａｎｄｅｒＳｗａｎ				|
;				汎用定義ファイル			|
;				ＢＩＯＳ編　－バンク制御		|
;									|
;						A.Watanabe (S.W.)	|
;									|
;=======================================================================|
;===============機能番号定義	（AHレジスタに代入し、割り込みをかける。）
BANK_SET_MAP			equ	00h	;バンクマッピング設定
BANK_GET_MAP			equ	01h	;バンクマッピング取得
BANK_READ_BYTE			equ	02h	;バンク指定１バイト読みこみ
BANK_WRITE_BYTE			equ	03h	;バンク指定１バイト書きこみ
BANK_READ_WORD			equ	04h	;バンク指定１ワード読みこみ
BANK_WRITE_WORD			equ	05h	;バンク指定１ワード書きこみ
BANK_READ_BLOCK			equ	06h	;バンク指定ブロック読みこみ
BANK_WRITE_BLOCK		equ	07h	;バンク指定ブロック書きこみ
BANK_FILL_BLOCK			equ	08h	;バンク指定ブロックフィル
BANK_ERASE_FLASH		equ	09h	;ﾌﾗｯｼｭﾛﾑのﾌﾗｯｼｭ（メーカ未公開）
;===============bank identifiers
BANK_SRAM			equ	0	;バンク SRAM
BANK_ROM0			equ	1	;バンク ROM0
BANK_ROM1			equ	2	;バンク ROM1

BANK_SRAM_ADDRESS		equ	01000h	;SRAM　のセグメントアドレス
BANK_ROM0_ADDRESS		equ	02000h	;ROM0　のセグメントアドレス
BANK_ROM1_ADDRESS		equ	03000h	;ROM1　のセグメントアドレス

BANK_MAX_BANKS			equ	7Fh	;バンクの最大

BANK_SOFTFS			equ	00h	;SRAM FreyaOS Filesys
BANK_USERDS1			equ	01h	;SRAM FreyaOS Process 2
BANK_USERDS0			equ	02h	;SRAM FreyaOS Peocess 1
BANK_OSWORK			equ	03h	;SRAM FreyaOS Work

;#define sram_get_map()		bank_get_map(BANK_SRAM)
SRAM_GET_MAP	macro
		mov	ah,BANK_GET_MAP		;ファンクション番号
		mov	bl,BANK_SRAM		;バンクの種類　SRAM
		int	INT_BANK		;ファンクション呼び出し
		endm

;#define sram_set_map(bank)	bank_set_map(BANK_SRAM, bank)
SRAM_SET_MAP	macro	bank
		mov	ah,BANK_SET_MAP		;ファンクション番号
		mov	bl,BANK_SRAM		;バンクの種類　SRAM
		mov	cx,bank			;バンク番号
		int	INT_BANK		;ファンクション呼び出し
		endm

;#define rom0_get_map()		bank_get_map(BANK_ROM0)
ROM0_GET_MAP	macro
		mov	ah,BANK_GET_MAP		;ファンクション番号
		mov	bl,BANK_ROM0		;バンクの種類　ROM0
		int	INT_BANK		;ファンクション呼び出し
		endm

;#define rom0_set_map(bank)	bank_set_map(BANK_ROM0, bank)
ROM0_SET_MAP	macro	bank
		mov	ah,BANK_SET_MAP		;ファンクション番号
		mov	bl,BANK_ROM0		;バンクの種類　ROM0
		mov	cx,bank			;バンク番号
		int	INT_BANK		;ファンクション呼び出し
		endm

;#define rom1_get_map()		bank_get_map(BANK_ROM1)
ROM1_GET_MAP	macro
		mov	ah,BANK_GET_MAP		;ファンクション番号
		mov	bl,BANK_ROM1		;バンクの種類　ROM1
		int	INT_BANK		;ファンクション呼び出し
		endm

;#define rom1_set_map(bank)	bank_set_map(BANK_ROM1, bank)
ROM1_SET_MAP	macro	bank
		mov	ah,BANK_SET_MAP		;ファンクション番号
		mov	bl,BANK_ROM1		;バンクの種類　ROM1
		mov	cx,bank			;バンク番号
		int	INT_BANK		;ファンクション呼び出し
		endm
