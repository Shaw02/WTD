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
C_Open	proc near	uses ax		;
	
	mov	al,COMM_OrReset + COMM_Baudrate38k + COMM_Enable
	out	COMM_Status,al		;

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
C_Close	proc near	uses ax		;

	.repeat
	  in	al,COMM_Status			;ステータス読み込み
	  .break  .if	!(al&COMM_Enable)	;通信機能はイネーブル？
	.until		 (al&COMM_SendEmpty)	;送信データ空？
	and	al,COMM_Disable		;通信ディセーブル設定。
	out	COMM_Status,al		;出力

	in	al,Int_Enable		;
	and	al,INT_CommSendReset	;シリアル送信エンプティー
	out	Int_Enable,al		;割り込み禁止

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
;		送信中だったら、FIFOへ書き込み			|
;===============================================================|
	even				;偶数アドレス配置
C_Send	proc near	uses ax bx cx di si es

	pushf				;
	cli

	mov	cx,ax

	in	al,Int_Enable		;
	and	al,INT_CommSendReset	;シリアル送信エンプティー
	out	Int_Enable,al		;割り込み禁止

	;ハードウェア送信バッファ ＆ ソフトウェアFIFOバッファ が両方とも空であるかチェック。
	mov	bx,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	lea	si,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	in	al,COMM_Status		;ステータス読み込み
	.if	((!(al & COMM_SendEmpty))||(bx != word ptr ds:[si]))
		;空ではなかった。（まだ送信中）
		mov	di,bx			;di ← 現在の書き込みポインタ
		inc	bx			
		.if	(bx >= word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Size)
			xor	bx,bx		;
		.endif				;bx ← 次の書き込みポインタ
		.while	(bx == word ptr ds:[si])
			call	IC_Send		;FIFOの送信を試みる。
		.endw				;FIFOに空きが出来るまで繰り返す。
		mov	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt,bx

		les	bx,dword ptr ds:[bp].(WTD_WorkAdd_System+WTD_Sys_ComFIFO_Offset)
		mov	ax,cx			;al←送信データ
		mov	byte ptr es:[di+bx],al	;FIFOバッファに書き込み

		in	al,Int_Enable		;バッファにデータが来たので、
		or	al,INT_CommSendSet	;シリアル送信エンプティー
		out	Int_Enable,al		;割り込み許可

	.else
		;どっちも空だったら、FIFO割り込み使わないで直接出力する。
		mov	ax,cx			;al←送信データ
		out	COMM_DATA,al		;送信
	.endif

	popf				;
	ret				;
;----------------------------------------------------------------
;C_Send_0:
;	mov	di,ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
;;	mov	di,ax			;ax←FIFOポインタCnt
;
;	mov	bx,ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
;
;	inc	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
;	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
;	cmp	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Size
;	jnz	C_Send_1		;
;	mov	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt,0
;C_Send_1:				;
;	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
;	cmp	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
;	jnz	C_Send_3		;FIFOバッファはいっぱい？
;	mov	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt,bx
;	call	IC_Send			;FIFOの送信を試みて、
;	jmp	C_Send_1		;やり直し。
;
;C_Send_3:				;
;;	mov	bx,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Offset
;;	mov	es,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Segment
;	les	bx,dword ptr ds:[bp].(WTD_WorkAdd_System+WTD_Sys_ComFIFO_Offset)
;	pop	ax			;FIFOバッファに書き込み
;	push	ax			;
;	mov	byte ptr es:[di+bx],al	;
;
;C_Send_e:
;	in	al,Int_Enable		;バッファにデータが来たので、
;	or	al,INT_CommSendSet	;シリアル送信エンプティー
;	out	Int_Enable,al		;割り込み許可
;
;	pop	ax			;
;	pop	bx			;
;	pop	di			;レジスタ復帰
;	pop	es			;
;	popf				;
;	ret				;
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
C_Send_Block	proc near	uses ax cx si

	.repeat
		lodsb			;
		call	C_Send		;送信
	.untilcxz

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
;		FIFOから回線にデータを出力する。		|
;===============================================================|
	even				;偶数アドレス配置
IC_Send	proc	near	uses ax bx dx di es
	pushf				;
	cli				;

;---------------------------------------------------------------
	in	al,Int_Enable		;
	and	al,INT_CommSendReset	;シリアル送信エンプティー
	out	Int_Enable,al		;割り込み禁止

	mov	dx,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	mov	bx,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	.if	(dx != bx)			;空だったら処理しない。

	   ;まだハードウェアで送信中だったら、FIFO送信はしない。
	   in	al,COMM_Status			;ステータス読み込み
	   .if	(al & COMM_SendEmpty)		;送信バッファ空？
		mov	di,bx			;di ← 現在の読み込みポインタ
		inc	bx			;
		.if	(bx >= word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Size)
			xor	bx,bx		;
		.endif				;bx ← 次の読み込みポインタ
		mov	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr,bx
		push	bx			;
		les	bx,dword ptr ds:[bp].(WTD_WorkAdd_System+WTD_Sys_ComFIFO_Offset)
		mov	al,byte ptr es:[di+bx]	;
		out	COMM_DATA,al		;送信
		pop	bx			;
	   .endif				;
	   .if	(dx != bx)			;空だったら処理しない。（送信後の再check）
		in	al,Int_Enable		;
		or	al,INT_CommSendSet	;シリアル送信エンプティー
		out	Int_Enable,al		;割り込み許可
	   .endif
	.endif

	popf				;
	ret				;
IC_Send	endp
;===============================================================|
endif
