;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Main program				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|

	ASSUME	CS:CODE

CODE	SEGMENT

.186

	org	0000h
WanderSwanTotalSoundDriver_:
;=======================================================================|
;				define					|
;=======================================================================|
;
;	　演奏開始ファンクションのところで、チェックする。
;	パート数を追加する場合は、その分だけワークを確保する事。
;
hyoka			equ	0
if	hyoka
WtdIL_Name		equ	'WTD_h',0
MusicMaxPart		equ	4	;廉価版は4 パート
else
WtdIL_Name		equ	'WTD',0
MusicMaxPart		equ	20	;製品版は20パート
endif
EffectMaxPart		equ	3	;効果音は3 パート
;=======================================================================|
;				Start					|
;=======================================================================|
include	service.inc	;定義ファイル　割り込み
include	timer.inc	;定義ファイル　タイマー
include	comm.inc	;定義ファイル　通信
include	sound.inc	;定義ファイル　サウンド
include	wtd_def.inc	;定義ファイル　ドライバー
include wtd_ver.inc	;バージョン情報
include	wtd_ilf.asm	;IL構造体,ILinfo構造体,ILファンクション
include	wtd_int.asm	;割り込み　メインルーチン
include	wtd_icom.asm	;割り込み　コマンド解釈部
include	wtd_idev.asm	;割り込み　デバイス制御部
include	wtd_tim.asm	;タイマー制御用サブルーチン
include	wtd_snd.asm	;サウンド制御用サブルーチン
include	wtd_com.asm	;シリアル制御用サブルーチン
;=======================================================================|
;				End					|
;=======================================================================|
CODE	ENDS
	END	WanderSwanTotalSoundDriver_
