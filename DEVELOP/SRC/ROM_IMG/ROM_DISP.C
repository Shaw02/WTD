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
/*	�萔��`							*/
/*--------------------------------------*/

/*��Text�\���p */
#define LCDclsChr			0x00		// LCD�N���A�p�̃L�����N�^
#define	PalText				0			// �e�L�X�g�\���p�p���b�g�ԍ�
#define	PalBG				1			// �L�[�{�[�h�p�p���b�g�ԍ�
#define	PalSprite			12			// �X�v���C�g�p�p���b�g�ԍ�
#define	TextAscii			0x7f		// Ascii�R�[�h�̍ő�l
#define PAL(x)				(x<<9)		// �p���b�g�w��}�N��

/*--------------------------------------*/
/*	�O���[�o���ϐ���`					*/
/*--------------------------------------*/
// Text�\���p�̃p���b�g�f�[�^
/*	ROM_BIOS.ASM�Œ�`���܂��B(S.W.��)
int	TextPaletteData[] = {
	0x0000,0x0700,0x0070,0x0007, 0x0077,0x0707,0x0770,0x777,
	0x0000,0x000F,0x00F0,0x00FF, 0x000F,0x0F0F,0x000F,0xFFF
};
*/

/*��VRAM Address*/
	VRAM_Sprite		far	*VramSprite  = VramAdrSprite;
	VRAM_Screen		far	*VramScreen1 = VramAdrScreen1;
	VRAM_Screen		far	*VramScreen2 = VramAdrScreen2;
	VRAM_FontColor	far	*VramFont    = VramAdrFontColor;
	VRAM_Palatte	far *VramPalette = VramAdrPalette;

/*--------------------------------------------------------------*/
/*	������\��													*/
/*--------------------------------------------------------------*/
/*������	int	x		�\�������� x ���W						*/
/*			int	y		�\�������� y ���W						*/
/*			char *str	�\��������������B						*/
/*���Ԓl	int			�Ō�Ɏg�p�����L�����N�^�[ + 1			*/
/*������	�������Screen1�̎w�肵�����W�ɕ\������B			*/
/*���J��	S.W.												*/
/*--------------------------------------------------------------*/
int	print(int x,int y,char *str){
	int		lstr = 0;					/* ������p�̃|�C���^ */
	int		cChr;						/* �L�����N�^�[�R�[�h�p */

	while(cChr = str[lstr++]){			/* �����͍Ō�ł��邩�`�F�b�N */
		VramScreen1->Atr[y][x++] = cChr;};
	return	cChr;						/* �ݒ��̃t�H���g�ԍ� */
};
/*--------------------------------------------------------------*/
/*	��ʂ̃N���A												*/
/*--------------------------------------------------------------*/
/*������	cChr	���ߐs�����L�����N�^�[ (�p���b�g�͂O)		*/
/*���Ԓl	����												*/
/*������	��ʑS�̂�cChr�Ŗ��ߐs�����B						*/
/*���J��	S.W.												*/
/*--------------------------------------------------------------*/
void LCDcls(int cChr)
{

	int	x,y;							/* ��ʃN���A�p */

	for(x=0;x<LCD_ScrWidth;x++){
		for(y=0;y<LCD_ScrHight;y++){
			VramScreen1->Atr[y][x] = cChr;
/*			�X�N���[���P�����g��Ȃ��̂ŁA�R�����g�A�E�g���܂��B(S.W.��)	*/
/*			VramScreen2->Atr[y][x] = cChr;		*/
		};
	};
};


/*--------------------------------------------------------------*/
/*	�t�H���g�f�[�^�o�^											*/
/*--------------------------------------------------------------*/
/*������	int nStartNo	�o�^����t�H���g�̊J�n�ԍ�			*/
/*			int nNum		�o�^�����						*/
/*			char *cData		�f�[�^�|�C���^						*/
/*���Ԓl	����												*/
/*������	nStartNo����nNum�t�H���g�f�[�^��o�^����			*/
/*���J��	Fun-X												*/
/*--------------------------------------------------------------*/
void SetFontData(int nStartNo,int nNum,const char *cData)
{
	int i,j;

    for(j=0;j<nNum;j++)
	    for(i=0;i<LCD_FontSize;i++)
			VramFont->PCG[nStartNo+j][i] = cData[j*LCD_FontSize+i];

}
/*--------------------------------------------------------------*/
/*	�`��
/*--------------------------------------------------------------*/
/*������	int nScreen		�`�悷��X�N���[��(0or1)			*/
/*			int x			�`��J�n������X���W					*/
/*			int y			�`��J�n������Y���W					*/
/*			int w			�`�敝�n							*/
/*			int h			�`�捂��							*/
/*			int nFontNo		�`����J�n����t�H���g�ԍ�			*/
/*			int nPalNo		�p���b�g�ԍ�						*/
/*���Ԓl	����												*/
/*������	Data�����ɕ`��                                      */
/*���J��	Fun-X												*/
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
/*	���Օ\��													*/
/*--------------------------------------------------------------*/
/*������	����												*/
/*���Ԓl	����												*/
/*������	���Ղ�\������										*/
/*���J��	Fun-X												*/
/*--------------------------------------------------------------*/
void DrawKeyboard(void)
{
	int i,j,k;
	char szBuf[8];

    // ���S
	BGDraw(0,0,0,LOGO_X,LOGO_Y,mapLogo,FONT_LOGO,KEYBOARD_PAL_NO);

	// ����
	for(j=0;j<4;j++){
		for(i=0;i<2;i++){
			BGDraw(0,i*7,j*4+3,KEYBOARD_X,KEYBOARD_Y,mapKeyboard,FONT_KEYBOARD,KEYBOARD_PAL_NO);
		}
	}
	

	// �p��
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
/*	������														*/
/*--------------------------------------------------------------*/
/*������	����												*/
/*���Ԓl	����												*/
/*������	Palette0���e�L�X�g�p�ɐݒ肷��B					*/
/*			16�F�J���[���[�h�ɂ���B							*/
/*���J��	S.W.												*/
/*			Fun-X												*/
/*--------------------------------------------------------------*/
void LCDinit()
{

	// �ėp�ϐ�
	int	i;

//	// �J���[���[�h�̐ݒ�
//	"ROM_BIOS.ASM"�ŁA�@��𔻕ʂ��Ă���ɍ��킹���ݒ�����܂��B(S.W.��)
//	outb(LCD_ColorMode,
//		 COLOR_MODE_16PACKED | (LCD_ColorModeMask & inb(LCD_ColorMode)) );


//	// �L�����N�^�[0�𓧖��F�ɂ���
//		"ROM_BIOS.ASM"�ŁA���X�A�^�����ȃt�H���g���`���Ă��܂��B(S.W.��)
//	for(i=0;i<LCD_FontSize;i++){
//		VramFont->PCG[LCDclsChr][i] = 0;
//	}

	// �t�H���g�p���b�g�ݒ�
	for(i=0;i<LCD_Color;i++){
//		"ROM_BIOS.ASM"�ŁA������e�̃p���b�g��ݒ肵�܂��B(S.W.��)
//		VramPalette->Color[0][i] = TextPaletteData[i]; */ // �e�L�X�g�p
		VramPalette->Color[PalBG][i] = sPal4[i];              // �L�[�{�[�h�p
		VramPalette->Color[PalSprite][i] = sPal4[i];             // �X�v���C�g�p
	}                           

	//---�ȉ��t�H���g�o�^�n--------------------

	// �L�[�{�[�h
	SetFontData(FONT_KEYBOARD,FONT_USE_KEYBOARD,grpKeyboard);
	// ���S
	SetFontData(FONT_LOGO,FONT_USE_LOGO,grpLogo);
	// �p��
	SetFontData(FONT_PANPOT,FONT_USE_PANPOT,grpPan);
	// �����Q�[�W
	SetFontData(FONT_LENGTH,FONT_USE_LENGTH,grpLength);
	// �{�����[���Q�[�W
	SetFontData(FONT_VOL,FONT_USE_VOL,grpVol);

	// �X�v���C�g
	SetFontData(FONT_SPR,FONT_USE_SPR,grpSpr);
/*
	// �X�v���C�g0�`3��\��
	outb(LCD_SpriteStart,0);
	outb(LCD_SpriteCount,4);
	VramSprite->Atr[0].Atr=FONT_SPR|PAL(4);
	VramSprite->Atr[0].x=8*20;
	VramSprite->Atr[0].y=64;
*/
	// ��ʂ̃N���A
	LCDcls(LCDclsChr);



};
