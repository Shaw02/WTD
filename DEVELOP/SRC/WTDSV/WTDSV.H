/*
    WonderWitch Music Selector & Viewer for WTD
           (c)2001 FUN-X / Digitalis

    FILENAME        : wtdsv.h
    LAST MODIFIED   : 2001/09/24
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/bios.h>
#include <sys/libwwc.h>
#include "wtd.h"
#include "graphics.h"

#define WMSV_EXP

#define TEXT_VIEW_FILENAME   128
#define TEXT_VIEW_FILEINFO   141
#define TEXT_VIEW_FRAME      178
#define TEXT_VIEW_PLAY       208
#define TEXT_VIEW_PLAYFILE   213
#define TEXT_VIEW_TIME       225     /* ���t���� */

#define TEXT_VIEW_CHANNEL    256
#define TEXT_VIEW_PROGRAM    272
#define TEXT_VIEW_VOL        288
#define TEXT_VIEW_PAN        304
#define TEXT_VIEW_PART       320     /* ���t�p�[�g��*/


#define TEXT_STATE_CHANNEL   256
#define TEXT_STATE_NOTE      276
#define TEXT_STATE_PROGRAM   284
#define TEXT_STATE_VOL       292
#define TEXT_STATE_PAN       300
#define TEXT_STATE_KEYSHIFT  308
#define TEXT_STATE_DETUNE    316
#define TEXT_STATE_ADD       332
#define TEXT_STATE_FLAG      348
#define TEXT_STATE_TRACK     364
#define TEXT_STATE_NAME      372

#define BG_CLEAR    0   /* �^���� */
#define BG_TILE     1   /* �w�i */
#define BG_KEYBOARD 8   /* ���� */
#define SP_KEY      50  /* �L�[ */

#define PAL(a)  (a)<<9

#define heap (_pc->_heap)

void main(void);
BOOL Init(void);
BOOL InitWtd(void);
void InitFontMono(void);
void InitFontColor(void);
BOOL CheckWtdData(void);
void wwprintf(short nX, short nY,int nFontNo,unsigned char far *szStrings,...);
void draw_keyboard(void);
void draw_frame(void);
void draw_files(void);
void draw_playfile(void);
void draw_viewer(void);
void key_out(void);
void KeyCheck(void);

#ifdef WMSV_EXP
void draw_state(void);
#endif

typedef struct{
    char Key_A;
    char Key_B;
    char Key_X1;
    char Key_X2;
    char Key_X3;
    char Key_X4;
    char Key_Y1;
    char Key_Y2;
    char Key_Y3;
    char Key_Y4;
    char Key_Start;
}KEY_STATE;

static KEY_STATE KeyState;

static WtdIL       WtdIl;
static WTD_Mus far *WtdMus;
static Wtd         *WtdState[20];
static Wtd_Sys far *WtdSys;

static char             szFileName[128][21];/* �t�@�C���� */
static unsigned short   nFiles;             /* ���t�ł���t�@�C���� */
static short            nNum;               /* �w�肵�Ă���t�@�C���ԍ� */
static short            nBGMPlay=0;         /* ���t�� */

static unsigned long    nPlayTime;          /* ���t�J�n���Ԃ̎擾*/
static char             second,minute;      /* ���t���� */