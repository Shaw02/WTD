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

static int nStatus=2;  /* 演奏状態・例外的に上に置く*/

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
static	WTD_Mus *WtdMus;

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

// VBLANK待ちもどき
/*
void VSyncWait(void)
{
	int i;
	i = inw(TIMER_CounterV);

	while(i==inw(TIMER_CounterV)){
	}

}
*/
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
	int		j,k,l,key;
	static int i=0;
	// 表示用バッファ
	char szBuf[16];

    // 音階テーブル
	const char szNote[12][3]={"c","c#","d","d#","e","f","f#","g","g#","a","a#","b"};
	// 音階スプライトの表示テーブル
	const int nKeyOn[]={0,2,4,6,8,12,14,16,18,20,22,24};
    // ゲージテーブル作成用
	int nGage[8]={0,0,0,0,0,0,0,0};
	// デバッグモード
	static char nDebug=0;
	// タイムカウント保存用
	static char cLastSec=0,cLastMin=0;

/*制御用ワークアドレスの取得 */
	wtdBUFF 	= WTD_Work;		/*配列変数では、先頭のアドレス*/
	wtdBUFF_Sys	= wtdBUFF + WTD_WorkAdd_System;
	wtdBUFF_Pcm	= wtdBUFF + WTD_WorkAdd_PCM;
	wtdBUFF_Ch0	= wtdBUFF + WTD_WorkAdd_Ch0;
	wtdBUFF_Emb	= wtdBUFF + WTD_WorkAdd_Emb;

	WtdSys = (Wtd_Sys*)wtdBUFF_Sys;
	WtdMus = (WTD_Mus*)0xE0000000L;

/*画面表示*/
	LCDinit();
	LCDcls(0x0020);

/* IL関数のロード	*/
	WTD_FunctionLoad(&wtdIL);

/* WTD設定	*/
	wtdIL.Stay();


	// キーボード表示
	DrawInit();

	// ステータスアドレス取得とCH表示
    for(i=0;i<4;i++){
		WtdState[i]=(Wtd*)(wtdBUFF + WTD_WorkAdd_Ch0 + i * WTD_WorkChSize);
    }

/*演奏開始*/
	count = wtdIL.MusicPlay(0xE0000000L);

	Time_Init();

	while(1){

		/*	無限ループ♪	*/
        key=KeyHit();


		// START押したらデバッグモードオン
		if(key==KEY_START)
			nDebug=1;

        // デバッグモード
        if(nDebug){
			nDebug=debug_main(); //終わったら0を返す
		}
		// ビューアー本体
		else{
			// 停止
			if(key&KEY_B){
				wtdIL.MusicStop();
				// ボタン変更
				VramSprite->Atr[10].Atr=FONT_PATTERN+2|PAL(4);
				VramSprite->Atr[8].Atr=FONT_PATTERN+3|PAL(4);
				// ステータス変更
				nStatus=0;
			}
			// 再生
			if(key&KEY_A){
				wtdIL.MusicPlay(0xE0000000L);
				// ボタン変更
				VramSprite->Atr[8].Atr=FONT_PATTERN|PAL(4);
				VramSprite->Atr[9].Atr=FONT_PATTERN+4|PAL(4);
				VramSprite->Atr[10].Atr=FONT_PATTERN+5|PAL(4);
				// タイマーも初期化
				Time_Init();
				// ステータス変更
				nStatus=2;
			}

		    // ステータス表示
		    for(i=0;i<4;i++){
//---------- 以下音階----------
				k=i*2;

			    j=WtdState[i]->Key;
				
			
				// 休符
				if(j==255){
					sprintf(szBuf,"o-r  ");
					// スプライトは画面の外に
					VramSprite->Atr[k].x = VramSprite->Atr[k+1].x = 240;
					VramSprite->Atr[k].x = VramSprite->Atr[k+1].y = 240;
				}
				else{
					// オクターブを代入
					l=WtdState[i]->Octave;
					// c～bを判別
					count=WtdState[i]->KeySet[0];
					j%=12;
					// オクターブ1～8かつ発音してる時のみ扱う
					if(l>0 && l<9){
						// オクターブと音階
						sprintf(szBuf,"o%d%-2s",l,szNote[j]);
	                	l--;
						// 発音中ならスプライト表示
						if(count!=255){
							// 鍵盤表示のスプライト座標設定
							VramSprite->Atr[k].Atr = mapKeyOn[j][0] | PAL(4);
							VramSprite->Atr[k].x = (nKeyOn[j]+(l*28))%112;
							VramSprite->Atr[k].y = (k<<4)+36-((l>>2)*12);
						
							VramSprite->Atr[k+1].Atr = mapKeyOn[j][1]|PAL(4);
							VramSprite->Atr[k+1].x = VramSprite->Atr[k].x;
							VramSprite->Atr[k+1].y = VramSprite->Atr[k].y+8;
						}
						else{
							// スプライトは画面の外に
							VramSprite->Atr[k].x = VramSprite->Atr[k+1].x = 240;
							VramSprite->Atr[k].x = VramSprite->Atr[k+1].y = 240;
						}

	                }
					// 表示対象外
					else{
						sprintf(szBuf,"----");
						// スプライトは画面の外に
						VramSprite->Atr[k].x = VramSprite->Atr[k+1].x = 240;
						VramSprite->Atr[k].x = VramSprite->Atr[k+1].y = 240;
					}
				}
				k=i*4;
	            // 描画
		        print(2,k+2,szBuf);
//---------- 以下Lengthゲージ----------
				l=WtdState[i]->LengCounter;
				// 128以上は127扱い
				if(l>127) l=127;
				for(j=0;j<(l>>4);j++)
					nGage[j]=4;
				nGage[j]=((l>>2)&3)+1;
				j++;
				for(j;j<8;j++)
					nGage[j]=0;
				BGDraw(0,7,k+2,8,1,nGage,FONT_LENGTH,KEYBOARD_PAL_NO);
//---------- 以下Volゲージ----------
				// とりあえず10分の1の値で表示(範囲0～12)
				l=WtdState[i]->ExprSet/10;
				for(j=0;j<(l>>2);j++)
					nGage[2-j]=4;
				nGage[2-j]=(l&3);
				j++;
				for(j;j<3;j++)
					nGage[2-j]=0;
				BGDraw(0,14,k+3,1,3,nGage,FONT_VOL,KEYBOARD_PAL_NO);
//---------- 以下パンとボリューム --------------
				l=WtdState[i]->Pan;

				sprintf(szBuf,"v%03d p%03d",WtdState[i]->Expr,l);
		        print(16,k+4,szBuf);

				// 0～31 左
				if(l<32)
					l=0;
				// 32～55 左上
				else if(l>=32 && l<56)
					l=1;
				// 56～71 上
				else if(l>=56 && l<72)
					l=2;
				// 72～96 右上
				else if(l>=72 && l<=96)
					l=3;
				// 97～127 右
				else if(l>96)
					l=4;

				BGDraw(0,6,k+2,1,1,&l,FONT_PANPOT,KEYBOARD_PAL_NO);

//---------- 以下その他 ----------

	            // 音色とディチューン
				sprintf(szBuf,"@%03d D%-5d",WtdState[i]->Program,WtdState[i]->BendDetune);
		        print(16,k+3,szBuf);
				// ゲートタイム
				sprintf(szBuf,"Q%03d q%-5d",WtdState[i]->GateTime8,WtdState[i]->GateTimeStepLast);
		        print(16,k+5,szBuf);
			}

//			VsyncWait();
			// VBLANKもどき
			// 外に関数作るとなぜか動かない
			i=inw(TIMER_CounterV);
			while(i==inw(TIMER_CounterV)){};

		}
		// 演奏時間
		if(nStatus){
			sprintf(szBuf,"%02d:%02d",TimeCount.cMin,TimeCount.cSec);
			// とまった時間保存
			cLastSec=TimeCount.cSec;
			cLastMin=TimeCount.cMin;
		}
		else{
			sprintf(szBuf,"%02d:%02d",cLastMin,cLastSec);
		}
		print(23,1,szBuf);

	};

};
