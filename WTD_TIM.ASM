;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Timer Control				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;===============================================================|
;			I/O Address				|
;===============================================================|
Int_Enable		equ	0b2h	;
Int_Eoi			equ	0b6h	;
BankSram		equ	0c1h	;
TIMER_Status		equ	0a2h	;Timer Status
TIMER_MaxCountH		equ	0a4h	;Hblank Load Count
TIMER_MaxCountV		equ	0a6h	;Vblank Load Count
TIMER_CounterH		equ	0a8h	;Hblank Down Counter
TIMER_CounterV		equ	0aah	;Vblank Down Counter
;===============================================================|
;			INT Status bit flag			|
;===============================================================|
INT_HblankSet		equ	080h	;Hblank値セット　(or)
INT_HblankReset		equ	07fh	;Hblank値リセット(and)
;===============================================================|
;			COMM Status bit flag			|
;===============================================================|
Timer_H_Enable		equ	001h	;Hblank Int. Enable	(or)
Timer_H_Disable		equ	0feh	;Hblank Int. Disable	(and)
Timer_H_auto		equ	002h	;Vblank auto preset mode(or)
Timer_H_shot		equ	0fdh	;Vblank 1 shot mode	(and)
Timer_V_Enable		equ	004h	;Vblank Int. Enable 	(or)
Timer_V_Disable		equ	0fbh	;Vblank Int. Disable	(and)
Timer_V_auto		equ	008h	;Vblank auto preset mode(or)
Timer_V_shot		equ	0f7h	;Vblank 1 shot mode	(and)
;===============================================================|
;			定数					|
;===============================================================|
Timer_Open		equ	0303h	;Hblank Enable / Auto mode
Timer_Close		equ	0100h	;Hblank Disable
;
;	Frection = 12000 / ( timebase × tempo / 60 )
;	Frection = 0AFC80h / (timebase × tempo )
;
Timer_Tempo120		equ	125	;timebase 48 / Tempo 120
;===============================================================|
;		タイマーの動作開始				|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		無し						|
;	処理							|
;		deviceの初期設定				|
;===============================================================|
	even				;偶数アドレス配置
T_open	proc near			;
	push	ax			;レジスタ保存

	mov	ax,Timer_Open		;Set
	call	T_Set_Status		;

	call	T_init			;割り込み周期の設定

	in	al,Int_Enable		;
	or	al,Int_HblankSet	;
	out	Int_Enable,al		;

	pop	ax			;レジスタ復帰
	ret				;
T_open	endp				;
;===============================================================|
;		タイマーの動作終了				|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		無し						|
;	処理							|
;		deviceの初期化					|
;===============================================================|
	even				;偶数アドレス配置
T_close	proc near			;
	push	ax			;レジスタ保存

	mov	ax,Timer_Close		;Reset
	call	T_Set_Status		;

	in	al,Int_Enable		;
	and	al,Int_HblankReset	;
	out	Int_Enable,al		;

	pop	ax			;レジスタ復帰
	ret				;
T_close	endp				;
;===============================================================|
;		タイマーの初期設定				|
;===============================================================|
;	引き数							|
;		無し						|
;	返り値							|
;		無し						|
;	処理							|
;		タイマー周期をTempo120にする。			|
;===============================================================|
	even				;偶数アドレス配置
T_init	proc near			;
	push	ax			;レジスタ保存

	mov	ax,Timer_Tempo120	;
	call	T_Set_Frection		;

	pop	ax			;レジスタ復帰
	ret				;
T_init	endp				;
;===============================================================|
;		タイマーモードの設定				|
;===============================================================|
;	引き数							|
;		AL	Output mode				|
;		AH	Set bit					|
;	返り値							|
;		無し						|
;	処理							|
;		モードの設定					|
;===============================================================|
	even				;偶数アドレス配置
T_Set_Status	proc near		;
	push	dx			;レジスタ保存
	mov	dx,TIMER_Status		;dx←I/O Address
	call	SP_Set_with_mask	;
	pop	dx			;レジスタ復帰
	ret				;
T_Set_Status	endp			;
;===============================================================|
;		タイマー周期の設定				|
;===============================================================|
;	引き数							|
;		AX	割り込み周期				|
;	返り値							|
;		無し						|
;	処理							|
;		モードの設定					|
;===============================================================|
	even				;偶数アドレス配置
T_Set_Frection	proc near		;
	out	Timer_MaxCountH,ax	;出力
	ret				;
T_Set_Frection	endp			;
