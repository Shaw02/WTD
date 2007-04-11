/****************************************************************/
/*																*/
/*					Music Viewer	Display Sub Routine			*/
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

/*●Text表示用 */
#define LCDclsChr			0x00		// LCDクリア用のキャラクタ
#define	PalText				0			// テキスト表示用パレット番号
#define	PalBG				1			// キーボード用パレット番号
#define	PalSprite			12			// スプライト用パレット番号
#define	TextAscii			0x7f		// Asciiコードの最大値
#define PAL(x)				(x<<9)		// パレット指定マクロ

/*--------------------------------------*/
/*	グローバル変数定義					*/
/*--------------------------------------*/
// Text表示用のパレットデータ
/*	ROM_BIOS.ASMで定義します。(S.W.注)
int	TextPaletteData[] = {
	0x0000,0x0700,0x0070,0x0007, 0x0077,0x0707,0x0770,0x777,
	0x0000,0x000F,0x00F0,0x00FF, 0x000F,0x0F0F,0x000F,0xFFF
};
*/

/*●VRAM Address*/
	VRAM_Sprite		far	*VramSprite  = VramAdrSprite;
	VRAM_Screen		far	*VramScreen1 = VramAdrScreen1;
	VRAM_Screen		far	*VramScreen2 = VramAdrScreen2;
	VRAM_FontColor	far	*VramFont    = VramAdrFontColor;
	VRAM_Palatte	far *VramPalette = VramAdrPalette;

/*--------------------------------------------------------------*/
/*	文字列表示													*/
/*--------------------------------------------------------------*/
/*●引数	int	x		表示したい x 座標						*/
/*			int	y		表示したい y 座標						*/
/*			char *str	表示したい文字列。						*/
/*●返値	int			最後に使用したキャラクター + 1			*/
/*●処理	文字列をScreen1の指定した座標に表示する。			*/
/*●開発	S.W.												*/
/*--------------------------------------------------------------*/
int	print(int x,int y,char *str){
	int		lstr = 0;					/* 文字列用のポインタ */
	int		cChr;						/* キャラクターコード用 */

	while(cChr = str[lstr++]){			/* 文字は最後であるかチェック */
		VramScreen1->Atr[y][x++] = cChr;};
	return	cChr;						/* 設定後のフォント番号 */
};
/*--------------------------------------------------------------*/
/*	画面のクリア												*/
/*--------------------------------------------------------------*/
/*●引数	cChr	埋め尽くすキャラクター (パレットは０)		*/
/*●返値	無し												*/
/*●処理	画面全体をcChrで埋め尽くす。						*/
/*●開発	S.W.												*/
/*--------------------------------------------------------------*/
void LCDcls(int cChr)
{

	int	x,y;							/* 画面クリア用 */

	for(x=0;x<LCD_ScrWidth;x++){
		for(y=0;y<LCD_ScrHight;y++){
			VramScreen1->Atr[y][x] = cChr;
/*			スクリーン１しか使わないので、コメントアウトします。(S.W.注)	*/
/*			VramScreen2->Atr[y][x] = cChr;		*/
		};
	};
};


/*--------------------------------------------------------------*/
/*	フォントデータ登録											*/
/*--------------------------------------------------------------*/
/*●引数	int nStartNo	登録するフォントの開始番号			*/
/*			int nNum		登録する個数						*/
/*			char *cData		データポインタ						*/
/*●返値	無し												*/
/*●処理	nStartNoからnNum個フォントデータを登録する			*/
/*●開発	Fun-X												*/
/*--------------------------------------------------------------*/
void SetFontData(int nStartNo,int nNum,const char *cData)
{
	int i,j;

    for(j=0;j<nNum;j++)
	    for(i=0;i<LCD_FontSize;i++)
			VramFont->PCG[nStartNo+j][i] = cData[j*LCD_FontSize+i];

}
/*--------------------------------------------------------------*/
/*	描画
/*--------------------------------------------------------------*/
/*●引数	int nScreen		描画するスクリーン(0or1)			*/
/*			int x			描画開始をするX座標					*/
/*			int y			描画開始をするY座標					*/
/*			int w			描画幅始							*/
/*			int h			描画高さ							*/
/*			int nFontNo		描画を開始するフォント番号			*/
/*			int nPalNo		パレット番号						*/
/*●返値	無し												*/
/*●処理	Dataを元に描画                                      */
/*●開発	Fun-X												*/
/*--------------------------------------------------------------*/
void BGDraw(int nScreen,int x,int y,int w,int h,int *Data,int nFontNo,int nPalNo)
{

	int i,j;

	for(j=0;j<h;j++){	
		for(i=0;i<w;i++){	
			VramScreen1->Atr[j+y][i+x] = nFontNo+Data[j*w+i]|PAL(nPalNo);
		}
	}
	

}

/*--------------------------------------------------------------*/
/*	鍵盤表示													*/
/*--------------------------------------------------------------*/
/*●引数	無し												*/
/*●返値	無し												*/
/*●処理	鍵盤を表示する										*/
/*●開発	Fun-X												*/
/*--------------------------------------------------------------*/
void DrawKeyboard(void)
{
	int i,j,k;
	char szBuf[8];

    // ロゴ
	BGDraw(0,0,0,LOGO_X,LOGO_Y,mapLogo,FONT_LOGO,KEYBOARD_PAL_NO);

	// 鍵盤
	for(j=0;j<4;j++){
		for(i=0;i<2;i++){
			BGDraw(0,i*7,j*4+3,KEYBOARD_X,KEYBOARD_Y,mapKeyboard,FONT_KEYBOARD,KEYBOARD_PAL_NO);
		}
	}
	

	// パン
	k=2;
	for(i=0;i<4;i++)
		BGDraw(0,5,i*4+2,1,1,&k,FONT_PANPOT,KEYBOARD_PAL_NO);

	for(i=0;i<4;i++){
		sprintf(szBuf,"CH%02d",i+1);
		print(0,i*4+2,szBuf);
	}

	print(19,0,"TEMPO 000");
	print(18,1,"TIME 00:00");

}
/*--------------------------------------------------------------*/
/*	初期化														*/
/*--------------------------------------------------------------*/
/*●引数	無し												*/
/*●返値	無し												*/
/*●処理	Palette0をテキスト用に設定する。					*/
/*			16色カラーモードにする。							*/
/*●開発	S.W.												*/
/*			Fun-X												*/
/*--------------------------------------------------------------*/
void LCDinit()
{

	// 汎用変数
	int	i;

//	// カラーモードの設定
//	"ROM_BIOS.ASM"で、機種を判別してそれに合わせた設定をします。(S.W.注)
//	outb(LCD_ColorMode,
//		 COLOR_MODE_16PACKED | (LCD_ColorModeMask & inb(LCD_ColorMode)) );


//	// キャラクター0を透明色にする
//		"ROM_BIOS.ASM"で、元々、真っ黒なフォントを定義しています。(S.W.注)
//	for(i=0;i<LCD_FontSize;i++){
//		VramFont->PCG[LCDclsChr][i] = 0;
//	}

	// フォントパレット設定
	for(i=0;i<LCD_Color;i++){
//		"ROM_BIOS.ASM"で、同一内容のパレットを設定します。(S.W.注)
//		VramPalette->Color[0][i] = TextPaletteData[i]; */ // テキスト用
		VramPalette->Color[PalBG][i] = sPal4[i];              // キーボード用
		VramPalette->Color[PalSprite][i] = sPal4[i];             // スプライト用
	}                           

	//---以下フォント登録系--------------------

	// キーボード
	SetFontData(FONT_KEYBOARD,FONT_USE_KEYBOARD,grpKeyboard);
	// ロゴ
	SetFontData(FONT_LOGO,FONT_USE_LOGO,grpLogo);
	// パン
	SetFontData(FONT_PANPOT,FONT_USE_PANPOT,grpPan);
	// 音長ゲージ
	SetFontData(FONT_LENGTH,FONT_USE_LENGTH,grpLength);
	// ボリュームゲージ
	SetFontData(FONT_VOL,FONT_USE_VOL,grpVol);

	// スプライト
	SetFontData(FONT_SPR,FONT_USE_SPR,grpSpr);
/*
	// スプライト0～3を表示
	outb(LCD_SpriteStart,0);
	outb(LCD_SpriteCount,4);
	VramSprite->Atr[0].Atr=FONT_SPR|PAL(4);
	VramSprite->Atr[0].x=8*20;
	VramSprite->Atr[0].y=64;
*/
	// 画面のクリア
	LCDcls(LCDclsChr);



};

