;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				Define file				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;****************************************************************
;*								*
;*			変数					*
;*								*
;****************************************************************
;===============================================================|
;		MS-DOS	Fileハンドル & ファイル制御用		|
;===============================================================|
.data?
;●コンパイル前ファイル
hMml_File	dw	?		;ハンドル(h)
szMml_File	dw	?		;ファイルサイズ(sz)
pMml_File	dw	?		;アドレス管理(p)
segMml_File	dw	?		;アドレス管理(Segment)

;●コンパイル後ファイル
hWtd_File	dw	?		;
szWtd_File	dw	?		;
pWtd_File	dw	?		;
segWtd_File	dw	?		;

;●音色ファイル用（全て、local変数にした。）
;hVoice_File	dw	?		;
;szVoice_File	dw	?		;
;pVoice_File	dw	?		;
;segVoice_File	dw	?		;

;●インクルードファイル用（全て、local変数にした。）
;hInclude_File		dw	?		;
;szInclude_File		dw	?		;
;pInclude_File		dw	?		;
;segInclude_File	dw	?		;

;●デバッグ用（全て、local変数にした。）
;hTest_File	dw	?		;
;szTest_File	dw	?		;
;pTest_File	dw	?		;
;segTest_File	dw	?		;

