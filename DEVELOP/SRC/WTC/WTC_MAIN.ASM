;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				Main Routine				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
_main:
	MOV	AX,OFFSET WTD_MML_Compiler_End + BSTACK	;
	MOV	SP,AX			;

	MOV	AX,CS			;
	MOV	DS,AX			;
	MOV	ES,AX			;セグメントの設定。
	MOV	SS,AX			;
	
	CALL	TPRINT			;タイトルの表示
	CALL	ComSmole		;メモリの最小化

	CLI				;割り込み禁止

	CALL	FOPEN			;ファイルオープン
	;FOPENの次に呼ぶこと。
	CALL	Change_Current_Directory

	CALL	MOPEN			;ＭＭＬファイル用メモリオープン
	CALL	WOPEN			;ＷＴＤファイル用メモリオープン
	CALL	VOPEN			;音色ファイル用メモリオープン

	CALL	MREAD			;ファイル→メモリ転送

	CALL	CHK_INCLUDE		;インクルードファイル
	CALL	COMPAIL			;コンパイル（セーブ処理含む）

;	CALL	TSOPEN			;
;	CALL	TMSAVE			;デバック用セーブ
;	CALL	TSCLOSE			;

	CALL	VCLOSE			;音色ファイル用メモリクローズ
	CALL	WCLOSE			;ＷＴＤファイル用メモリの開放
	CALL	MCLOSE			;ＭＭＬファイル用メモリの開放

	CALL	FCLOSE			;ファイルのクローズ

_main_End:
COMEND:
	STI				;割り込み許可
	MOV	AX,04C00H		;
	INT	21H			;MS-DOS RET
