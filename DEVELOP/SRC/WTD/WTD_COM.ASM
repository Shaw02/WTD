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
;			INT Status bit flag			|
;===============================================================|
INT_CommSendSet		equ	001h	;CommSend値セット　(or)
INT_CommSendReset	equ	0feh	;CommSend値リセット(and)
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

	in	al,Int_Enable		;
	and	al,INT_CommSendReset	;シリアル送信エンプティー
	out	Int_Enable,al		;割り込み禁止

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
	pushf				;
	push	es			;
	push	di			;
	push	bx			;
	push	ax			;レジスタ保存
	cli

	in	al,Int_Enable		;
	and	al,INT_CommSendReset	;シリアル送信エンプティー
	out	Int_Enable,al		;割り込み禁止

	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	cmp	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	jnz	C_Send_0		;FIFOバッファある？

	in	al,COMM_Status		;ステータス読み込み
	test	al,COMM_SendEmpty	;送信バッファ空？
	jz	C_send_0		;

	pop	ax			;
	out	COMM_DATA,al		;送信
	pop	bx			;
	pop	di			;
	pop	es			;
	popf				;
	ret				;
;----------------------------------------------------------------
C_Send_0:
	mov	ax,ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	mov	di,ax			;ax←FIFOポインタCnt

	mov	bx,ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt

	inc	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	cmp	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Size
	jnz	C_Send_1		;
	mov	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt,0
C_Send_1:				;
	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	cmp	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	jnz	C_Send_3		;FIFOバッファはいっぱい？
	mov	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt,bx
	call	IC_Send			;FIFOの送信を試みて、
	jmp	C_Send_1		;やり直し。

C_Send_3:				;
	mov	bx,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Offset
	mov	es,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Segment
	pop	ax			;FIFOバッファに書き込み
	push	ax			;
	mov	byte ptr es:[di+bx],al	;

C_Send_e:
	in	al,Int_Enable		;バッファにデータが来たので、
	or	al,INT_CommSendSet	;シリアル送信エンプティー
	out	Int_Enable,al		;割り込み許可

	pop	ax			;
	pop	bx			;
	pop	di			;レジスタ復帰
	pop	es			;
	popf				;
	ret				;
C_Send	endp				;
;===============================================================|
;	even				;偶数アドレス配置
;C_Send	proc near			;
;	push	cx			;
;	push	ax			;レジスタ保存
;
;	mov	cx,COMM_TimeOut		;count
;	xchg	al,ah			;
;C_send_1:				
;	dec	cx			;time count
;	jz	C_send_e		;無限ループ対策
;	in	al,COMM_Status		;ステータス読み込み
;	test	al,COMM_SendEmpty	;送信バッファ空？
;	jz	C_send_1		;
;	xchg	al,ah			;
;	out	COMM_DATA,al		;送信
;	or	ax,ax			;Cy flag reset
;
;C_Send_e:
;	pop	ax			;レジスタ復帰
;	pop	cx			;
;	ret				;
;C_Send	endp				;
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
	lods	byte ptr es:[si]	;
	call	C_Send			;送信
	loop	C_Send_Block_1		;
	
	pop	ax			;レジスタ復帰
	pop	cx			;
	pop	si			;
	ret				;
C_Send_Block	endp			;
;===============================================================|
;			1 byte送信				|
;===============================================================|
;	引き数							|
;		FIFO	send data				|
;	返り値							|
;		無し						|
;	処理							|
;		回線にデータを出力する。			|
;===============================================================|
	even				;偶数アドレス配置
IC_Send:
	push	es			;
	push	di			;
	push	bx			;
	push	ax			;
	pushf				;
	cli				;

;---------------------------------------------------------------
	in	al,Int_Enable		;
	and	al,INT_CommSendReset	;シリアル送信エンプティー
	out	Int_Enable,al		;割り込み禁止

	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	cmp	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	jz	IC_Send_e		;FIFOバッファある？

	in	al,COMM_Status		;ステータス読み込み
	test	al,COMM_SendEmpty	;送信バッファ空？
	jz	IC_send_e0		;Ze←'H'

	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	mov	di,ax			;FIFOポインタの取得

	inc	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	cmp	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Size
	jnz	IC_Send_1		;
	mov	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr,0
IC_Send_1:				;
	mov	bx,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Offset
	mov	es,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Segment
	mov	al,byte ptr es:[di+bx]	;
	out	COMM_DATA,al		;送信

IC_Send_e0:
	in	al,Int_Enable		;
	or	al,INT_CommSendSet	;シリアル送信エンプティー
	out	Int_Enable,al		;割り込み許可

IC_Send_e:
	popf				;
	pop	ax			;
	pop	bx			;
	pop	di			;
	pop	es			;
	ret				;
;===============================================================|
endif
