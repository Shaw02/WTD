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
;WtdIL_Name		equ	'WTD',0
WtdIL_Name		equ	'WTD_h',0
;MusicMaxPart		equ	20	;製品版は20パート
MusicMaxPart		equ	4	;廉価版は4 パート
EffectMaxPart		equ	3	;効果音は3 パート
;=======================================================================|
;				Start					|
;=======================================================================|
include wtd_ver.asm	;バージョン情報
include	wtd_def.asm	;定義ファイル
include	wtd_ilf.asm	;IL構造体,ILinfo構造体,ILファンクション
include	wtd_int.asm	;割り込みメインルーチン
include	wtd_tim.asm	;タイマー制御用サブルーチン
include	wtd_snd.asm	;サウンド制御用サブルーチン
include	wtd_com.asm	;シリアル制御用サブルーチン
;=======================================================================|
;				End					|
;=======================================================================|
CODE	ENDS
	END	WanderSwanTotalSoundDriver_
