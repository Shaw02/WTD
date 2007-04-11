/****************************************************************/
/*																*/
/*					Music Viewer								*/
/*						for Wonder Swan Emulator				*/
/*																*/
/*								Programmed by.					*/
/*									Fun-X						*/
/*									S.W.						*/
/*																*/
/****************************************************************/
/*--------------------------------------*/
/*	定数定義							*/
/*--------------------------------------*/
#define DISPLAY_MODE_swCOLOR			/* S.W. 設計のBIOS設定に*/

#include <stdio.h>
#include <wtd.h>
#include "ws.h"		/* IO Device定義ファイル */
#include "grp.h"

/*	サブルーチン群	*/
#include "rom_disp.c"
#include "rom_key.c"
#include "rom_time.c"
#include "debug.c"

/*--------------------------------------*/
/*	グローバル変数定義					*/
/*--------------------------------------*/
static	WtdIL	wtdIL;			/*実体をつくって、wtdILにその先頭アドレス。*/
static	char near *wtdBUFF;		/*アドレスを変数として持つ。*/
static	char near *wtdBUFF_Sys;
static	char near *wtdBUFF_Pcm;
static	char near *wtdBUFF_Ch0;
static	char near *wtdBUFF_Emb;
static	Wtd *WtdState[4];
static	Wtd_Sys *WtdSys;

/*--------------------------------------*/
/*	外部宣言							*/
/*--------------------------------------*/
//	外部.objファイルにあるグローバル変数
extern	char	WTD_Work[4096];

//	外部.objファイルにある関数
extern	void	WTD_FunctionLoad(WtdIL	near	*Wtd_Function);

/*--------------------------------------*/
/*	プロトタイプ宣言					*/
/*--------------------------------------*/
/*	画面表示	*/
void	LCDcls(int cChr);
void	LCDinit();
int		print(int x,int y,char *str);

/*	キー入力	*/
int		Inkey0();
int		KeyWait();

/*	ＷＴＤ関連	*/
void	WTD_FunctionLoad(WtdIL	near	*Wtd_Function);

/*--------------------------------------------------------------*/
/*	メインルーチン												*/
/*--------------------------------------------------------------*/
/*●引数	無し												*/
/*●返値	無し												*/
/*●処理	ビュアー等を絵画するルーチン						*/
/*			必ず、無限ループとすること。						*/
/*●開発	Fun-X												*/
/*			S.W.												*/
/*--------------------------------------------------------------*/
void main(){
	int		count;
	int		i,j,l;
	char szBuf[16];
	const char szNote[12][3]={"c","c+","d","d+","e","f","f+","g","g+","a","a+","b"};
	int nGage[8]={0,0,0,0,0,0,0,0};

/*制御用ワークアドレスの取得 */
	wtdBUFF 	= WTD_Work;		/*配列変数では、先頭のアドレス*/
	wtdBUFF_Sys	= wtdBUFF + WTD_WorkAdd_System;
	wtdBUFF_Pcm	= wtdBUFF + WTD_WorkAdd_PCM;
	wtdBUFF_Ch0	= wtdBUFF + WTD_WorkAdd_Ch0;
	wtdBUFF_Emb	= wtdBUFF + WTD_WorkAdd_Emb;

	WtdSys = (Wtd_Sys*)wtdBUFF_Sys;

/*画面表示*/
	LCDinit();
	LCDcls(0x0020);

	DrawKeyboard();

/* IL関数のロード	*/
	WTD_FunctionLoad(&wtdIL);

/* WTD設定	*/
	wtdIL.Stay();


	// キーボード表示
	DrawKeyboard();

	// ステータスアドレス取得とCH表示
    for(i=0;i<4;i++){
		WtdState[i]=(Wtd*)(wtdBUFF + WTD_WorkAdd_Ch0 + i * WTD_WorkChSize);
    }

/*演奏開始*/
	count = wtdIL.MusicPlay(0xE0000000L);

	while(1){

		/*	無限ループ♪	*/
//		KeyWait();

	    // ステータス表示
	    for(i=0;i<4;i++){

			if(Inkey0()==KEY_START){debug_main();};


//---------- 以下音階----------

		    j=WtdState[i]->Key;
			if(j==255)
				sprintf(szBuf,"r    ");
			else
				sprintf(szBuf,"o%d%-2s",j/12-1,szNote[j%12]);
	        print(15,i*4+2,szBuf);

//---------- 以下Lengthゲージ----------

			if(WtdState[i]->LengCounter>127)
				l=127;
			else
				l=WtdState[i]->LengCounter;

			for(j=0;j<(l>>4);j++)
				nGage[j]=4;
			nGage[j]=((l>>2)&3)+1;
			j++;
			for(j;j<8;j++)
				nGage[j]=0;
			BGDraw(0,6,i*4+2,8,1,nGage,FONT_LENGTH,KEYBOARD_PAL_NO);

//---------- 以下Volゲージ----------

			l=(WtdState[i]->ExprSet)/10;
			for(j=0;j<(l>>2);j++)
				nGage[2-j]=4;
			nGage[2-j]=(l&3);
			j++;
			for(j;j<3;j++)
				nGage[2-j]=0;
			BGDraw(0,14,i*4+3,1,3,nGage,FONT_VOL,KEYBOARD_PAL_NO);

//---------- 以下パン --------------

			sprintf(szBuf,"p%03d",WtdState[i]->Pan);
	        print(15,i*4+3+2,szBuf);
			l=WtdState[i]->Pan;

			if(l<32)
				l=0;
			else if(l>=32 && l<56)
				l=1;
			else if(l>=56 && l<72)
				l=2;
			else if(l>72 && l<=96)
				l=3;
			else if(l>96)
				l=4;

			BGDraw(0,5,i*4+2,1,1,&l,FONT_PANPOT,KEYBOARD_PAL_NO);


//---------- 以下その他 ----------

			sprintf(szBuf,"@%03d",WtdState[i]->Program);
	        print(15,i*4+3,szBuf);
			sprintf(szBuf,"v%03d",WtdState[i]->Expr);
	        print(15,i*4+3+1,szBuf);


		}

		sprintf(szBuf,"%03d",WtdSys->Tempo);
		print(25,0,szBuf);

	};

};
