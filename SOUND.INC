;=======================================================================|
;									|
;			ＷａｎｄｅｒＳｗａｎ				|
;				汎用定義ファイル			|
;				ＢＩＯＳ編　－サウンド制御		|
;									|
;						A.Watanabe (S.W.)	|
;									|
;=======================================================================|
;===============機能番号定義	（AHレジスタに代入し、割り込みをかける。）
SOUND_INIT			equ	00h		;サウンド初期化
SOUND_SET_CHANNEL		equ	01h		;出力・モード設定
SOUND_GET_CHANNEL		equ	02h		;出力・モード取得
SOUND_SET_OUTPUT		equ	03h		;サウンド出力設定
SOUND_GET_OUTPUT		equ	04h		;サウンド出力取得
SOUND_SET_WAVE			equ	05h		;波形設定
SOUND_SET_PITCH			equ	06h		;サウンド周波数設定
SOUND_GET_PITCH			equ	07h		;サウンド周波数所得
SOUND_SET_VOLUME		equ	08h		;サウンド音量設定
SOUND_GET_VOLUME		equ	09h		;サウンド音量所得
SOUND_SET_SWEEP			equ	0Ah		;ﾁｬﾝﾈﾙ3ｽｳｨｰﾌﾟ設定
SOUND_GET_SWEEP			equ	0Bh		;ﾁｬﾝﾈﾙ3ｽｳｨｰﾌﾟ所得
SOUND_SET_NOISE			equ	0Ch		;ﾁｬﾝﾈﾙ4ﾉｲｽﾞ設定
SOUND_GET_NOISE			equ	0Dh		;ﾁｬﾝﾈﾙ4ﾉｲｽﾞ所得
SOUND_GET_RANDOM		equ	0Eh		;ﾁｬﾝﾈﾙ4疑似乱数ﾃﾞｰﾀ所得
