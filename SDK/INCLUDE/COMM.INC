;=======================================================================|
;									|
;			ＷａｎｄｅｒＳｗａｎ				|
;				汎用定義ファイル			|
;				ＢＩＯＳ編　－シリアル制御		|
;									|
;						A.Watanabe (S.W.)	|
;									|
;=======================================================================|
;===============機能番号定義	（AHレジスタに代入し、割り込みをかける。）
COMM_OPEN			equ	00h	;通信開始
COMM_CLOSE			equ	01h	;通信終了
COMM_SEND_CHAR			equ	02h	;１バイト送信
COMM_RECEIVE_CHAR		equ	03h	;１バイト受信
COMM_RECEIVE_WITH_TIMEOUT	equ	04h	;ﾀｲﾑｱｳﾄ指定１バイト受信
COMM_SEND_STRING		equ	05h	;文字列送信
COMM_SEND_BLOCK			equ	06h	;ブロック送信
COMM_RECEIVE_BLOCK		equ	07h	;ブロック受信
COMM_SET_TIMEOUT		equ	08h	;タイムアウト設定
COMM_SET_BAUDRATE		equ	09h	;通信ボーレート設定
COMM_GET_BAUDRATE		equ	0ah	;通信ボーレート所得
COMM_SET_CANCEL_KEY		equ	0bh	;通信キャンセルキーパターン設定
COMM_GET_CANCEL_KEY		equ	0ch	;通信キャンセルキーパターン所得
COMM_XMODEM			equ	0dh	;X-modem送受信
;===============ボーレート
COMM_SPEED_9600			equ	0	; 9600[bps]
COMM_SPEED_38400		equ	1	;38400[bps]
;===============XMODEM structure
xmodeminfo			struc
xmodeminfo_state		dw	?	;メーカ未公開
xmodeminfo_mode			db	?	;
xmodeminfo_retry_c		db	?	;
xmodeminfo_block_c		dw	?	;
xmodeminfo_block_max		dw	?	;
xmodeminfo_block_sixa		dw	?	;
xmodeminfo_bank			dw	?	;
xmodeminfo_offset		dw	?	;
xmodeminfo_timeout_c		dw	?	;
xmodeminfo			ends
;===============XMODEM state codes
XM_START			equ	1	;メーカ未公開
XM_NEGO				equ	2	;
XM_BLOCK			equ	3	;
XM_BLOCK_RETRY			equ	4	;
XM_CLOSE			equ	5	;
XM_ABORT			equ	6	;
XM_DONE				equ	7	;
XM_ERASE_BANK			equ	8	;
;===============XMODEM transfer modes
XMODE_SEND			equ	0	;送信　メーカ未公開
XMODE_RECEIVE			equ	1	;受信
XMODE_SEND_ENCRYPTED		equ	2	;
XMODE_RECEIVE_ENCRYPTED		equ	3	;
XMODE_AUTO_ERASE		equ	4	;
;===============SIO error codes
ERR_SIO_OK			equ	0000h	;エラー無し
ERR_SIO_BUSY			equ	8100h	;ビジー
ERR_SIO_TIMEOUT			equ	8101h	;タイムアウト
ERR_SIO_OVERRUN			equ	8102h	;オーバーラン
ERR_SIO_CANCEL			equ	8103h	;キャンセル
;===============XMODEM error codes
ERR_XM_STATECODE		equ	8104h	;ステータスコード
ERR_XM_CANCELED			equ	8105h	;キャンセルされた。
ERR_XM_BLOCK_LOST		equ	8106h	;ブロックが消えた。
ERR_XM_TOO_LARGE		equ	8107h	;大きすぎ。
