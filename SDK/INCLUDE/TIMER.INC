;=======================================================================|
;									|
;			ＷａｎｄｅｒＳｗａｎ				|
;				汎用定義ファイル			|
;				ＢＩＯＳ編　－カレンダ／タイマー制御	|
;									|
;						A.Watanabe (S.W.)	|
;									|
;=======================================================================|
;===============機能番号定義	（AHレジスタに代入し、割り込みをかける。）
RTC_RESET			equ	00h	;RTCリセット
RTC_GET_DATETIME		equ	01h	;RTC日付時間取得
RTC_SET_DATETIME		equ	02h	;RTC日付時間設定
RTC_SET_DATETIME_STRUCT		equ	03h	;RTC日付時間一括設定
RTC_GET_DATETIME_STRUCT		equ	04h	;RTC日付時間一括取得
RTC_ENABLE_ALARM		equ	05h	;RTCアラーム割り込み設定
RTC_DISABLE_ALARM		equ	06h	;RTC割り込み解除
TIMER_ENABLE			equ	07h	;タイマー割り込み設定
TIMER_DISABLE			equ	08h	;タイマー割り込み禁止
TIMER_GET_COUNT			equ	09h	;タイマーカウント値取得
;===============カレンダ・時計
RTC_YEAR			equ	00h	;年
RTC_MONTH			equ	01h	;月
RTC_DATE			equ	02h	;日
RTC_DAY_OF_WEEK			equ	03h	;曜日
RTC_HOUR			equ	04h	;時間
RTC_MIN				equ	05h	;分
RTC_SEC				equ	06h	;秒
;===============timer_type
TIMER_HBLANK			equ	00h	;HBLANK_CoundUp
TIMER_VBLANK			equ	01h	;VBLANK_CountUp
;===============timer_preset_type
TIMER_ONESHOT			equ	00h	;OneShotType
TIMER_AUTOPRESET		equ	01h	;AutoPresetType
