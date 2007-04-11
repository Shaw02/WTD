/****************************************************************/
/*																*/
/*				IL_TEST �w�b�_�[�t�@�C��						*/
/*																*/
/****************************************************************/
#define DISPLAY_MODE_swCOLOR			/* S.W. �݌v��BIOS�ݒ��*/

#include	<wtd.h>
#include	"ws.h"		/* IO Device��`�t�@�C�� */

/*--------------------------------------*/
/*	�萔��`							*/
/*--------------------------------------*/

/*��Text�\���p */
#define LCDclsChr			0x00		/* LCD�N���A�p�̃L�����N�^ */
#define	TextPalette			0			/* Text�\���Ɏg���p���b�g */
#define	TextAscii			0x7f		/* Ascii�R�[�h�̍ő�l */
	int	TextPaletteData[] = {			/* Text�\���p�̃p���b�g�f�[�^ */
		0x0000,0x0700,0x0070,0x0007, 0x0077,0x0707,0x0770,0x777,
		0x0000,0x000F,0x00F0,0x00FF, 0x000F,0x0F0F,0x000F,0xFFF};

/*��VRAM Address*/
	VRAM_Sprite		far	*VramSprite  = VramAdrSprite;
	VRAM_Screen		far	*VramScreen1 = VramAdrScreen1;
	VRAM_Screen		far	*VramScreen2 = VramAdrScreen2;
	VRAM_FontColor	far	*VramFont    = VramAdrFontColor;
	VRAM_Palatte	far *VramPalette = VramAdrPalette;

/* �ϐ���`(DGROUP�ɔz�u�����B) */
static	WtdIL	wtdIL;			/*���̂������āAwtdIL�ɂ��̐擪�A�h���X�B*/
static	char near *wtdBUFF;		/*�A�h���X��ϐ��Ƃ��Ď��B*/
static	char near *wtdBUFF_Sys;
static	char near *wtdBUFF_Pcm;
static	char near *wtdBUFF_Ch0;
static	char near *wtdBUFF_Emb;

/*========================================================================
	Program
=========================================================================*/
/*�O���錾*/
extern	void	main();
extern	void	WTD_FunctionLoad(WtdIL	near	*Wtd_Function);
extern	char	WTD_Work[4096];

/* ���v���g�^�C�v�錾 */

/*	��ʕ\��	*/
void	LCDcls(int cChr);
void	LCDinit();
int		print(int x,int y,char *str);

/*	�L�[����	*/
int		Inkey0();
int		KeyWait();

/*	�v�s�c�֘A	*/
void	WTD_FunctionLoad(WtdIL	near	*Wtd_Function);

/****************************************************************/
/*		��ʊ֌W		*****************************************/
/****************************************************************/
/*--------------------------------------------------------------*/
/*	��ʂ̃N���A												*/
/*--------------------------------------------------------------*/
/*������	cChr	���ߐs�����L�����N�^�[ (�p���b�g�͂O)		*/
/*���Ԓl	����												*/
/*������	��ʑS�̂�cChr�Ŗ��ߐs�����B						*/
/*--------------------------------------------------------------*/
void LCDcls(int cChr){
	int	x;								/* ��ʃN���A�p */
	int	y;								/* ��ʃN���A�p */

	for(x=0;x<LCD_ScrWidth;x++){
		for(y=0;y<LCD_ScrHight;y++){
			VramScreen1->Atr[y][x] = cChr;
			VramScreen2->Atr[y][x] = cChr;
		};
	};
};
/*--------------------------------------------------------------*/
/*	������														*/
/*--------------------------------------------------------------*/
/*������	����												*/
/*���Ԓl	����												*/
/*������	Palette0���e�L�X�g�p�ɐݒ肷��B					*/
/*			16�F�J���[���[�h�ɂ���B							*/
/*--------------------------------------------------------------*/
void LCDinit(){
	int	i;								/* �p���b�g��`�p */

	outb(LCD_ColorMode,					/* �J���[���[�h�̐ݒ� */
		 COLOR_MODE_16PACKED | (LCD_ColorModeMask & inb(LCD_ColorMode)) );

	for(i=0;i<LCD_Color;i++){			/* �e�L�X�g�p�̃p���b�g�ݒ� */
		VramPalette->Color[TextPalette][i] = TextPaletteData[i];};

										/* �L�����N�^�[0�𓧖��F�ɂ���B */
	for(i=0;i<LCD_FontSize;i++){VramFont->PCG[LCDclsChr][i] = 0;};

	LCDcls(LCDclsChr);					/* ��ʂ̃N���A */


};
/*--------------------------------------------------------------*/
/*	������\��													*/
/*--------------------------------------------------------------*/
/*������	int	x		�\�������� x ���W						*/
/*			int	y		�\�������� y ���W						*/
/*			char *str	�\��������������B						*/
/*���Ԓl	int			�Ō�Ɏg�p�����L�����N�^�[ + 1			*/
/*������	�������Screen2�̎w�肵�����W�ɕ\������B			*/
/*--------------------------------------------------------------*/
int	print(int x,int y,char *str){
	int		lstr = 0;					/* ������p�̃|�C���^ */
	int		cChr;						/* �L�����N�^�[�R�[�h�p */

	while(cChr = str[lstr++]){			/* �����͍Ō�ł��邩�`�F�b�N */
		VramScreen1->Atr[y][x++] = cChr;};
	return	cChr;						/* �ݒ��̃t�H���g�ԍ� */
};
/****************************************************************/
/*		�L�[�֌W		*****************************************/
/****************************************************************/
/*--------------------------------------------------------------*/
/*	�L�[�ǂݍ���												*/
/*--------------------------------------------------------------*/
/*������	����												*/
/*���Ԓl	�L�[												*/
/*������	������Ă���L�[��ǂݍ���							*/
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
/*	�L�[�E�F�C�g												*/
/*--------------------------------------------------------------*/
/*������	����												*/
/*���Ԓl	�L�[												*/
/*������	������Ă���L�[��ǂݍ���							*/
/*--------------------------------------------------------------*/
int	KeyWait(){
	int	key=0;

	while(key==0){key=Inkey0();};

	return	key;
};
/****************************************************************/
/*	���C�����[�`��		*****************************************/
/****************************************************************/
void main(){
	int		count;
	int		i;

/*����p���[�N�A�h���X�̎擾 */
	wtdBUFF 	= WTD_Work;		/*�z��ϐ��ł́A�擪�̃A�h���X*/
	wtdBUFF_Sys	= wtdBUFF + WTD_WorkAdd_System;
	wtdBUFF_Pcm	= wtdBUFF + WTD_WorkAdd_PCM;
	wtdBUFF_Ch0	= wtdBUFF + WTD_WorkAdd_Ch0;
	wtdBUFF_Emb	= wtdBUFF + WTD_WorkAdd_Emb;


/*��ʕ\��*/
	LCDinit();
	LCDcls(0x0020);

	print( 3,1,"Wonder Swan");
	print( 1,2,"Total Sound Driver");
	print( 5,3,"for WS Emulator");

	print( 8,5,"Programmed by.");
	print(11,6,"S.W.");
	print(11,7,"Fun-X");

/* IL�֐��̃��[�h	*/
	WTD_FunctionLoad(&wtdIL);

/* WTD�ݒ�	*/
	wtdIL.Stay();

/*���t�J�n*/
	count = wtdIL.MusicPlay(0xE0000000L);

	while(count==0){

		/*	�������[�v��	*/
		KeyWait();

	};

};