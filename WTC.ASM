;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|

assume	cs:code,ds:code,es:code,ss:code

code	segment

.186

	org	0100h

WTD_MML_Compiler_:

;=======================================================================|
;				define					|
;=======================================================================|
WtdIL_Name		equ	'WTD',0
MusicMaxPart		equ	20	;製品版は20パート
EffectMaxPart		equ	3	;効果音は3 パート
;=======================================================================|
;				Start Up				|
;=======================================================================|
	jmp	_main			;メインルーチンへ
;=======================================================================|
;				Start					|
;=======================================================================|
include bank.inc	;バンク
include wtd_ver.inc	;WTD Version infomation
include wtd_def.inc	;WTD Define infomation
include wtc_def.inc	;Define
include wtc_main.asm	;Main
include wtc_sub.asm	;Sub
include wtc_hed.asm	;Header
include wtc_voi.asm	;Voice & Emb
include wtc_com.asm	;Command
;=======================================================================|
;				End					|
;=======================================================================|
WTD_MML_Compiler_End:
CODE	ENDS
	END	WTD_MML_Compiler_

