;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Serial Control				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
ifndef	hyoka
;===============================================================|
;			I/O Address				|
;===============================================================|
COMM_DATA		equ	0b1h	;Send / Receive data
COMM_STATUS		equ	0b3h	;Serial Status
;===============================================================|
;			COMM Status bit flag			|
;===============================================================|
COMM_Receive		equ	001h	;受信データ有り（受信可）
COMM_OverRun		equ	002h	;オーバーラン・エラー
COMM_SendEmpty		equ	004h	;送信バッファ空（送信可）
COMM_OrReset		equ	020h	;オーバーラン・エラーのリセット
COMM_Baudrate9K		equ	000h	;ボーレート（ 9600 [bps])(+)
COMM_Baudrate38k	equ	040h	;ボーレート（38400 [bps])(+)
COMM_Enable		equ	080h	;通信イネーブル(or)
COMM_Disable		equ	07fh	;通信ディセーブル(and)
;===============================================================|
;			定数					|
;===============================================================|
COMM_TimeOut		equ	0ffffh	;タイムアウトの時間
;===============================================================|
;			通信回線を開く				|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		無し						|
;	処理							|
;		回線を38400bpsに設定、通信回線を開く。		|
;===============================================================|
	even				;偶数アドレス配置
C_Open	proc near			;
	push	ax			;
	push	bx			;
	
	mov	al,COMM_OrReset + COMM_Baudrate38k + COMM_Enable
	out	COMM_Status,al		;

	pop	bx			;
	pop	ax			;
	ret				;
C_Open	endp				;
;===============================================================|
;			通信回線を閉じる			|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		無し						|
;	処理							|
;		通信回線を閉じる。				|
;===============================================================|
	even				;偶数アドレス配置
C_Close	proc near			;
	push	ax			;

C_Close_2:				;
	in	al,COMM_Status		;ステータス読み込み
	test	al,COMM_Enable		;通信機能はイネーブル？
	jz	C_Close_1		;
	test	al,COMM_SendEmpty	;送信データ空？
	jz	C_Close_2		;空でなければ、空になるまで待つ。
C_Close_1:				;
	and	al,COMM_Disable		;通信ディセーブル設定。
	out	COMM_Status,al		;出力

	pop	ax			;
	ret				;
C_Close	endp				;
;===============================================================|
;			1 byte送信				|
;===============================================================|
;	引き数							|
;		al	send data				|
;	返り値							|
;		無し						|
;	処理							|
;		回線にデータを出力する。			|
;===============================================================|
	even				;偶数アドレス配置
C_Send	proc near			;
	push	cx			;
	push	ax			;レジスタ保存

	mov	cx,COMM_TimeOut		;count
	xchg	al,ah			;
C_send_1:				
	dec	cx			;time count
	jz	C_send_e		;無限ループ対策
	in	al,COMM_Status		;ステータス読み込み
	test	al,COMM_SendEmpty	;送信バッファ空？
	jz	C_send_1		;
	xchg	al,ah			;
	out	COMM_DATA,al		;送信
	or	ax,ax			;Cy flag reset

C_Send_e:
	pop	ax			;レジスタ復帰
	pop	cx			;
	ret				;
C_Send	endp				;
;===============================================================|
;			2 byte送信				|
;===============================================================|
;	引き数							|
;		ax	send data(al:LSB,ah:MSB)		|
;	返り値							|
;		無し						|
;	処理							|
;		回線にデータを出力する。			|
;===============================================================|
	even				;偶数アドレス配置
C_Send_Word	proc near		;
	call	C_Send			;
	xchg	al,ah			;
	call	C_Send			;
	xchg	al,ah			;
	ret				;
C_Send_Word	endp			;
;===============================================================|
;			ブロック送信				|
;===============================================================|
;	引き数							|
;		CX	Size					|
;		DS:SI	Data Address				|
;	返り値							|
;		無し						|
;	処理							|
;		回線にデータを出力する。			|
;===============================================================|
	even				;偶数アドレス配置
C_Send_Block	proc near		;
	push	si			;
	push	cx			;
	push	ax			;レジスタ保存

C_Send_Block_1:
	lods	byte ptr ds:[si]	;
	call	C_Send			;送信
	loop	C_Send_Block_1		;
	
	pop	ax			;レジスタ復帰
	pop	cx			;
	pop	si			;
	ret				;
C_Send_Block	endp			;
;===============================================================|
endif
