;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Main program				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|

	.186

;=======================================================================|
;				define					|
;=======================================================================|
include process.inc			;定義ファイル　プロセス
include	service.inc			;定義ファイル　割り込み
include	timer.inc			;定義ファイル　タイマー
include	comm.inc			;定義ファイル　通信
include	sound.inc			;定義ファイル　サウンド
include	bank.inc			;定義ファイル　バンク
include	wtd_def.inc			;定義ファイル　ドライバー
include	wtd_ver.inc			;定義ファイル　バージョン情報
;
;	　演奏開始ファンクションのところで、チェックする。
;	パート数を追加する場合は、その分だけワークを確保する事。
;
ifdef	hyoka	;------------------------
WtdIL_Name		equ	'WTD_h',0
MusicMaxPart		equ	4	;廉価版は4 パート
else	;--------------------------------
WtdIL_Name		equ	'WTD',0
MusicMaxPart		equ	20	;製品版は20パート
endif	;--------------------------------
EffectMaxPart		equ	3	;効果音は3 パート

;=======================================================================|
;				Segment define				|
;=======================================================================|
ifdef	library	;---------------------	※　ライブラリ版

_TEXT	segment	word public 'CODE'
_TEXT	ends

DATA	segment	word public 'DATA'
DATA	ends

_BSS	segment	word public 'BSS'
_BSS	ends

CGROUP	group	_TEXT
DGROUP	group	DATA,_BSS

	assume	cs:CGROUP, ds:DGROUP, es:DGROUP

else		;---------------------	※　IL版

_TEXT	segment word public 'CODE'
_TEXT	ends

CGROUP	group	_TEXT
	assume	cs:CGROUP

endif		;---------------------

;=======================================================================|
;				プログラム・コード			|
;=======================================================================|
_TEXT	segment word public 'CODE'

;	org	0000h			;明示の必要性？

	public	WanderSwanTotalSoundDriver_
WanderSwanTotalSoundDriver_:

include	wtd_ilf.asm			;IL構造体,ILinfo構造体,ILファンクション
include	wtd_int.asm			;割り込み　メインルーチン
include	wtd_icmd.asm			;割り込み　コマンド解釈部
include	wtd_idev.asm			;割り込み　デバイス制御部
include	wtd_icom.asm			;割り込み　シリアル通信制御
include	wtd_tim.asm			;タイマー制御用サブルーチン
include	wtd_snd.asm			;サウンド制御用サブルーチン
include	wtd_com.asm			;シリアル制御用サブルーチン

_TEXT	ends

;=======================================================================|
;				グローバル変数				|
;=======================================================================|
ifdef	library				;※　ライブラリ版のみ必要
_BSS	segment word public 'BSS'

include wtd_lib.asm			;ライブラリ版　データ領域

_BSS	ends
endif
;=======================================================================|

	end
