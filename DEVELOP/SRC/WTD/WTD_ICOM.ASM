;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;			Interrupt main program				|
;				Serial Control				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
ifndef	hyoka
;****************************************************************
;*								*
;*			割り込みメインルーチン			*
;*								*
;****************************************************************
;===============================================================|
;		Interrupt Main					|
;===============================================================|
;								|
;	●処理							|
;		シリアル通信の制御を行うルーチン。		|
;								|
;	●使用レジスタ						|
;		ds:bp	ワーク領域先頭アドレス			|
;		ds:bx	パート共通構造体			|
;								|
;===============================================================|
	Public	IC_Start
	even					;偶数アドレス配置
IC_Start:
	push	ax				;
	push	bx				;
	push	bp				;
	push	ds				;レジスタ保存

;---------------------------------------------------------------

	in	al,Int_Enable		;
	and	al,INT_CommSendReset	;シリアル送信エンプティー
	out	Int_Enable,al		;割り込み禁止

;---------------------------------------------------------------
;EOIの発行

;End Of Interrupt
	mov	al,INT_CommSendSet		;
	out	Int_Eoi,al			;出力

;---------------------------------------------------------------
;バンクの設定
ifndef	IRAM		;DGROUP=IRAMの場合、不要
	in	al,BankSram			;現在のSRAM Bankを得る
	cmp	al,BANK_USERDS0			;ユーザ領域を示していたら、
	jz	IC_Start_Step1			;この処理は行わない。
	cmp	al,BANK_USERDS1			;
	jz	IC_Start_Step1			;'/ram0'アクセス中は、
	jmp	IC_Start_End			;処理をしない。
endif

IC_Start_Step1:
;	push	ax				;

;---------------------------------------------------------------
;ワークエリアアドレスの取得

	WTD_WorkGet	ds,bp			;ワークエリアアドレスの取得

;---------------------------------------------------------------
;通信
IC_Start_Step2:					;
	call	IC_Send				;送信
;---------------------------------------------------------------
;バンクの復帰
ifndef	IRAM		;DGROUP=IRAMの場合、不要
;
;	pop	ax				;復帰
;	out	BankSram,al			;設定する。
;
endif
;---------------------------------------------------------------
;割り込みの終了

IC_Start_End:

	pop	ds				;レジスタ復帰
	pop	bp				;
	pop	bx				;
	pop	ax				;
	iret					;
;===============================================================|
endif
