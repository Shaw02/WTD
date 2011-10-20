
	.186
	.model	tiny,stdcall


;****************************************************************
;*		外部宣言					*
;****************************************************************
include	lib_dos.inc


;****************************************************************
;*		コード						*
;****************************************************************
;---------------------------------------------------------------|
;		エラー終了					|
;---------------------------------------------------------------|
;	●引数							|
;		ax Error Code					|
;---------------------------------------------------------------|
.const
Error_MsgOffset	dw	offset	Err_M00
		dw	offset	Err_M01
		dw	offset	Err_M02
		dw	offset	Err_M03
		dw	offset	Err_M04
		dw	offset	Err_M05
		dw	offset	Err_M06
		dw	offset	Err_M07
		dw	offset	Err_M08
		dw	offset	Err_M09
		dw	offset	Err_M0A
		dw	offset	Err_M0B
		dw	offset	Err_M0C
		dw	offset	Err_M0D
		dw	offset	Err_M0E
		dw	offset	Err_M0F

Err_M00	db	'Err=0x00:正常',0dh,0ah,24h
Err_M01	db	'Err=0x01:無効な機能コードです。',0dh,0ah,24h
Err_M02	db	'Err=0x02:ファイルが存在しません。',0dh,0ah,24h
Err_M03	db	'Err=0x03:指定されたパスが無効です',0dh,0ah,24h
Err_M04	db	'Err=0x04:オープンされているファイルが多いです。',0dh,0ah,24h
Err_M05	db	'Err=0x05:アクセスが拒否されました。',0dh,0ah,24h
Err_M06	db	'Err=0x06:指定されたファイルは、現在オープンされていません。',0dh,0ah,24h
Err_M07	db	'Err=0x07:Memory Control Blockが破壊されています。',0dh,0ah,24h
Err_M08	db	'Err=0x08:十分な大きさのメモリがありません。',0dh,0ah,24h
Err_M09	db	'Err=0x09:指定されたメモリーは、割り当てられていません。',0dh,0ah,24h
Err_M0A	db	'Err=0x0A:環境変数が32kByte以上あります。',0dh,0ah,24h
Err_M0B	db	'Err=0x0B:指定されたファイルのexeヘッダーが正しくありません。',0dh,0ah,24h
Err_M0C	db	'Err=0x0C:ファイルアクセスコードが0～2の範囲外です',0dh,0ah,24h
Err_M0D	db	'Err=0x0D:指定されたデバイスは無効です。',0dh,0ah,24h
Err_M0E	db	'Err=0x0E:？',0dh,0ah,24h
Err_M0F	db	'Err=0x0F:指定されたドライブ番号は無効です。',0dh,0ah,24h
.code
File_Err	proc	near

		push	ds
		push	dx
		push	ax
		mov	bx,offset Error_MsgOffset
		shl	ax,1			;
		add	bx,ax			;
		mov	dx,cs:[bx]		;
		push	cs			;
		pop	ds			;

		mov	AH,09H			;
		int	21H			;
		pop	ax
		pop	dx
		pop	ds

	.if	((ax==02h)||(ax==03h)||(ax==0Bh)||(ax==0Ch))
		mov	AH,09H			;
		int	21H			;
	.endif

		.exit	255
File_Err	endp
;****************************************************************
	end
