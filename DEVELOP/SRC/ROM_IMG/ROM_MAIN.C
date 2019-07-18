/****************************************************************/
/*																*/
/*				IL_TEST ヘッダーファイル						*/
/*																*/
/****************************************************************/
#define DISPLAY_MODE_swCOLOR			/* S.W. 設計のBIOS設定に*/

#include	<wtd.h>
#include	"ws.h"		/* IO Device定義ファイル */

/*--------------------------------------*/
/*	定数定義							*/
/*--------------------------------------*/

/*●Text表示用 */
#define LCDclsChr			0x00		/* LCDクリア用のキャラクタ */
#define	TextPalette			0			/* Text表示に使うパレット */
#define	TextAscii			0x7f		/* Asciiコードの最大値 */
	int	TextPaletteData[] = {			/* Text表示用のパレットデータ */
		0x0000,0x0700,0x0070,0x0007, 0x0077,0x0707,0x0770,0x777,
		0x0000,0x000F,0x00F0,0x00FF, 0x000F,0x0F0F,0x000F,0xFFF};

/*●VRAM Address*/
	VRAM_Sprite		far	*VramSprite  = VramAdrSprite;
	VRAM_Screen		far	*VramScreen1 = VramAdrScreen1;
	VRAM_Screen		far	*VramScreen2 = VramAdrScreen2;
	VRAM_FontColor	far	*VramFont    = VramAdrFontColor;
	VRAM_Palatte	far *VramPalette = VramAdrPalette;

/* 変数定義(DGROUPに配置される。) */
static	WtdIL	wtdIL;			/*実体をつくって、wtdILにその先頭アドレス。*/
static	char near *wtdBUFF;		/*アドレスを変数として持つ。*/
static	char near *wtdBUFF_Sys;
static	char near *wtdBUFF_Pcm;
static	char near *wtdBUFF_Ch0;
static	char near *wtdBUFF_Emb;

/*========================================================================
	Program
=========================================================================*/
/*外部宣言*/
extern	void	main();
extern	void	WTD_FunctionLoad(WtdIL	near	*Wtd_Function);
extern	char	WTD_Work[4096];

/* ●プロトタイプ宣言 */

/*	画面表示	*/
void	LCDcls(int cChr);
void	LCDinit();
int		print(int x,int y,char *str);

/*	キー入力	*/
int		Inkey0();
int		KeyWait();

/*	ＷＴＤ関連	*/
void	WTD_FunctionLoad(WtdIL	near	*Wtd_Function);

/****************************************************************/
/*		画面関係		*****************************************/
/****************************************************************/
/*--------------------------------------------------------------*/
/*	画面のクリア												*/
/*--------------------------------------------------------------*/
/*●引数	cChr	埋め尽くすキャラクター (パレットは０)		*/
/*●返値	無し												*/
/*●処理	画面全体をcChrで埋め尽くす。						*/
/*--------------------------------------------------------------*/
void LCDcls(int cChr){
	int	x;								/* 画面クリア用 */
	int	y;								/* 画面クリア用 */

	for(x=0;x<LCD_ScrWidth;x++){
		for(y=0;y<LCD_ScrHight;y++){
			VramScreen1->Atr[y][x] = cChr;
			VramScreen2->Atr[y][x] = cChr;
		};
	};
};
/*--------------------------------------------------------------*/
/*	初期化														*/
/*--------------------------------------------------------------*/
/*●引数	無し												*/
/*●返値	無し												*/
/*●処理	Palette0をテキスト用に設定する。					*/
/*			16色カラーモードにする。							*/
/*--------------------------------------------------------------*/
void LCDinit(){
	int	i;								/* パレット定義用 */

	outb(LCD_ColorMode,					/* カラーモードの設定 */
		 COLOR_MODE_16PACKED | (LCD_ColorModeMask & inb(LCD_ColorMode)) );

	for(i=0;i<LCD_Color;i++){			/* テキスト用のパレット設定 */
		VramPalette->Color[TextPalette][i] = TextPaletteData[i];};

										/* キャラクター0を透明色にする。 */
	for(i=0;i<LCD_FontSize;i++){VramFont->PCG[LCDclsChr][i] = 0;};

	LCDcls(LCDclsChr);					/* 画面のクリア */


};
/*--------------------------------------------------------------*/
/*	文字列表示													*/
/*--------------------------------------------------------------*/
/*●引数	int	x		表示したい x 座標						*/
/*			int	y		表示したい y 座標						*/
/*			char *str	表示したい文字列。						*/
/*●返値	int			最後に使用したキャラクター + 1			*/
/*●処理	文字列をScreen2の指定した座標に表示する。			*/
/*--------------------------------------------------------------*/
int	print(int x,int y,char *str){
	int		lstr = 0;					/* 文字列用のポインタ */
	int		cChr;						/* キャラクターコード用 */

	while(cChr = str[lstr++]){			/* 文字は最後であるかチェック */
		VramScreen1->Atr[y][x++] = cChr;};
	return	cChr;						/* 設定後のフォント番号 */
};
/****************************************************************/
/*		キー関係		*****************************************/
/****************************************************************/
/*--------------------------------------------------------------*/
/*	キー読み込み												*/
/*--------------------------------------------------------------*/
/*●引数	無し												*/
/*●返値	キー												*/
/*●処理	押されているキーを読み込む							*/
/*--------------------------------------------------------------*/
int	Inkey0(){
	int	key;

	outb(KEY,KEY_GroupABS);
	key=(inb(KEY)        & 0x000F);
	outb(KEY,KEY_GroupX);
	key|=(inb(KEY) * 16  & 0x00F0);
	outb(KEY,KEY_GroupY);
	key|=(inb(KEY) * 256 & 0x0F00);

	return	key;
};
/*--------------------------------------------------------------*/
/*	キーウェイト												*/
/*--------------------------------------------------------------*/
/*●引数	無し												*/
/*●返値	キー												*/
/*●処理	押されているキーを読み込む							*/
/*--------------------------------------------------------------*/
int	KeyWait(){
	int	key=0;

	while(key==0){key=Inkey0();};

	return	key;
};
/****************************************************************/
/*	メインルーチン		*****************************************/
/****************************************************************/
void main(){
	int		count;
	int		i;

/*制御用ワークアドレスの取得 */
	wtdBUFF 	= WTD_Work;		/*配列変数では、先頭のアドレス*/
	wtdBUFF_Sys	= wtdBUFF + WTD_WorkAdd_System;
	wtdBUFF_Pcm	= wtdBUFF + WTD_WorkAdd_PCM;
	wtdBUFF_Ch0	= wtdBUFF + WTD_WorkAdd_Ch0;
	wtdBUFF_Emb	= wtdBUFF + WTD_WorkAdd_Emb;


/*画面表示*/
	LCDinit();
	LCDcls(0x0020);

	print( 3,1,"Wonder Swan");
	print( 1,2,"Total Sound Driver");
	print( 5,3,"for WS Emulator");

	print( 8,5,"Programmed by.");
	print(11,6,"S.W.");
	print(11,7,"Fun-X");

/* IL関数のロード	*/
	WTD_FunctionLoad(&wtdIL);

/* WTD設定	*/
	wtdIL.Stay();

/*演奏開始*/
	count = wtdIL.MusicPlay(0xE0000000L);

	while(count==0){

		/*	無限ループ♪	*/
		KeyWait();

	};

};
