/****************************************************************/
/*																*/
/*					Music Viewer	Debug Routine				*/
/*						for Wonder Swan Emulator				*/
/*																*/
/*								Programmed by.					*/
/*									S.W.						*/
/*																*/
/****************************************************************/
/*--------------------------------------*/
/*	構造体定義							*/
/*--------------------------------------*/
typedef struct{
	char	cIRAM_Data[0x4000];

} IRAM;

/*--------------------------------------------------------------*/
/*	I-RAM ダンプ表示											*/
/*--------------------------------------------------------------*/
/*●引数	無し												*/
/*●返値	0													*/
/*●処理	メモリのダンプ表示									*/
/*●開発	S.W.												*/
/*--------------------------------------------------------------*/
int	IRAM_Dump(){

	IRAM	far	*pIRAM;				/* I-RAM アクセス用 */
	char		strPrint[8];		/* 表示用 */
	int			iKey;				/* キー入力 */

	int			y		= 0;		/* y座標 */
	int			x		= 0;		/* x座標 */
	int			pAddr	= 0x0000;	/* 表示アドレス */

	pIRAM = 0x00000000L;

	print(0,0,"Addr +0 +1 +2 +3 +4 +5 +6 +7");

	while(KeyHit()!=KEY_B){

		if(Inkey0()==KEY_UP1){pAddr=pAddr-0x08;};
		if(Inkey0()==KEY_DOWN1){pAddr=pAddr+0x08;};
		if(Inkey0()==KEY_LEFT1){pAddr=pAddr-0x80;};
		if(Inkey0()==KEY_RIGHT1){pAddr=pAddr+0x80;};

		for(y=0;y<(LCD_ScrHight-1);y++){

			/* Address表示 */
			sprintf(strPrint,"%04x:",pAddr+y*8);
			print(0,y+1,strPrint);

			/* Data表示 */
			for(x=0;x<8;x++){
				sprintf(strPrint,"%02x",pIRAM->cIRAM_Data[pAddr+x+y*8]);
				print((5+x*3),y+1,strPrint);
			};

		};

	};
	return 0;

};
/*--------------------------------------------------------------*/
/*	デバックメインルーチン										*/
/*--------------------------------------------------------------*/
/*●引数	無し												*/
/*●返値	0													*/
/*●処理	メモリのダンプ表示									*/
/*●開発	S.W.												*/
/*--------------------------------------------------------------*/
int	debug_main(){

	LCDinit();
	LCDcls(0x0020);

	IRAM_Dump();

	LCDcls(0x0020);

	// キーボード表示
	DrawInit();
	return 0;

};

