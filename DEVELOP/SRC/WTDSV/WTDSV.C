/*
    WonderWitch Music Selector & Viewer for WTD
           (c)2001 FUN-X / Digitalis

    FILENAME        : wtdsv.c
    LAST MODIFIED   : 2001/12/02
*/

#include "wtdsv.h"

/*=================================================================================================

                                        ���C������

=================================================================================================*/
/*--------------------------------------------------------------
  [���C������]
--------------------------------------------------------------*/
void main(void)
{
    int i;
    unsigned long nTimeCount;
    static int nDrawMode=0,nOldDrawMode=0;

    /* ������ */
    if(!Init())
        return;

    screen_fill_char(SCREEN2, 0, 0, 32, 32, PAL(4));
    screen_fill_char(SCREEN1, 0, 0, 32, 32, BG_TILE | PAL(4));

    draw_keyboard();
    draw_files();
    draw_frame();
    wwprintf( 0,13,TEXT_VIEW_PLAY,"PLAY:");

    /* ���[�v START����������I�� */
    while(!KeyState.Key_Start){

        KeyCheck();

        switch(nDrawMode){
            /* ���Օ\�� */
            case 0:
                if(nOldDrawMode!=0){
                    screen_fill_char(SCREEN2, 0, 0, 28, 12, PAL(4));
                    draw_keyboard();
                    nOldDrawMode=0;
                }
                draw_viewer();
                break;
            /* ���t�X�e�[�^�X�\�� */
#ifdef WMSV_EXP
            case 1:
                if(nOldDrawMode!=1){
                    screen_fill_char(SCREEN1, 0, 0, 28, 12, BG_TILE | PAL(4));
                    screen_fill_char(SCREEN2, 0, 0, 28, 12, PAL(4));
                    key_out();
                    nOldDrawMode=1;
                }
                draw_state();
                break;
#endif
            default:
                break;
        }

        /* ���t���Ȃ�^�C�����J�E���g */
        for(i=0;i<WtdSys->MusicPart;i++){
            if(WtdState[i]->FlagControl>>15==0)
                break;
        }
        if(i<WtdSys->MusicPart){
            nTimeCount=sys_get_tick_count();
            second=(short)((nTimeCount-nPlayTime)/75);
            if(second/60>=1){
                nPlayTime=nTimeCount;
                second=0;
                minute++;
            }
        }
        /* ���t���ԕ\�� */
        wwprintf(21,13,TEXT_VIEW_TIME,"%02d:%02d",minute,second);


        if(KeyState.Key_X4){
            if(nNum>0){
                nNum--;
                draw_files();
                sys_wait(8);
            }
        }
        if(KeyState.Key_X2){
            if(nNum<nFiles-1){
                nNum++;
                draw_files();
                sys_wait(8);
            }
        }
        if(KeyState.Key_X3){
            if((nNum+=10)>nFiles-1)
                nNum=nFiles-1;
            draw_files();
            sys_wait(8);
        }
        if(KeyState.Key_X1){
            if((nNum-=10)<0)
                nNum=0;
            draw_files();
            sys_wait(8);
        }
#ifdef WMSV_EXP
        if(KeyState.Key_Y2){
           if(nDrawMode<1){
               nOldDrawMode=nDrawMode;
               nDrawMode++;
           }
        }
        if(KeyState.Key_Y4){
           if(nDrawMode>0){
               nOldDrawMode=nDrawMode;
               nDrawMode--;
           }
        }
#endif
        /* ���t�J�n */
        if(KeyState.Key_A){
            sys_wait(10);
            /* �w��t�@�C�����̃A�h���X�擾 */
            WtdMus = (WTD_Mus far *)mmap(szFileName[nNum]);
            /* �Đ� */
            WtdIl.MusicPlay((void far *)WtdMus);
            draw_playfile();
            nBGMPlay=1;
            /* �^�C���J�E���g������ */
            nPlayTime = sys_get_tick_count();
            second=minute=0;
        }
        /* ���t��~ */
        if(KeyState.Key_B){
            WtdIl.MusicStop();
            key_out();
            nBGMPlay=0;
        }
        
    }

    WtdIl.StayOut();
    text_set_palette(0);
    wwc_set_color_mode(COLOR_MODE_GRAYSCALE);
    text_screen_init();
    
}


/*=================================================================================================

                                        ����������

=================================================================================================*/
/*--------------------------------------------------------------
  [������]
  �Ԃ�l�FTRUE ����/FALSE ���s
--------------------------------------------------------------*/
BOOL Init(void)
{
    int i;

    /* �X�N���[���������� */
    screen_set_scroll(SCREEN1, 0, 0);
    screen_set_scroll(SCREEN2, 0, 0);
    text_screen_init();

    /* �e�L�X�g�\���X�N���[���w�� */
    text_set_screen(SCREEN2);

    /* �f�B�X�v���C���[�h�ݒ� */
    display_control(DCM_SCR1|DCM_SCR2|DCM_SPR);

    /* WTD�풓 */
    if(!InitWtd())
        return FALSE;

    /* �t�H���g�Z�b�g */
    font_set_colordata(BG_CLEAR,1, gp_clear);                           /* �^���� */
    font_set_colordata(BG_TILE,1, gp_tile);                             /* �w�i */
    font_set_colordata(BG_KEYBOARD,keyboard_w*keyboard_h,gp_keyboard);  /* ���� */
    font_set_colordata(SP_KEY,1, sp_key );                              /* �L�[ */

    /* �X�v���C�g�Z�b�g */
    for(i=0;i<32;i++){
        sprite_set_char(i, SP_KEY | 4<<9); /* 12�Ԃ̃p���b�g���g�p */
        sprite_set_location(i,0,18*8);      /* �\����ʊO�ֈړ� */
    }
    /* �X�v���C�g�\�� */
    sprite_set_range( 0, 32 );
    /* �e�L�X�g�\���p�p���b�g��ύX */
    text_set_palette(5);

    /* �n�[�h�ʃt�H���g�Z�b�g */
    if(wwc_get_hardarch() != HARDARCH_WSC) /* ���m�N�����̏��� */
        InitFontMono();
    else                                   /* �J���[���̏��� */
        InitFontColor();


    return TRUE;
}

/*--------------------------------------------------------------
  [WTD�̃`�F�b�N�E�풓]
  �Ԃ�l�FTRUE ����/FALSE ���s
--------------------------------------------------------------*/
BOOL InitWtd(void)
{

    int i;
    char *wtdBUFF,*wtdBUFF2;

    /* WTD�`�F�b�N */
    if( (ilibIL->_open("@wtd.IL", (IL far *)&WtdIl)) !=  E_FS_SUCCESS){
        text_put_string(0,0,"WTD���]������Ă��Ȃ��E�܂��̓��[�h�ł��܂���B");
        text_put_string(0,1,"�I�����܂��B");
        key_wait();
        return FALSE;
    }
    /* WTD�풓 */
    if(WtdIl.Stay() != 0){
        text_put_string(0,0,"WTD���풓�ł��܂���ł����B");
        text_put_string(0,1,"�I�����܂��B");
        key_wait();
        return FALSE;
    }
  
    /* /rom0/�f�B���N�g���ɂ���WTD�f�[�^���`�F�b�N */
    if(!CheckWtdData())
        return FALSE;

    /* �e�A�h���X�ʒu�擾 */
    wtdBUFF = heap;

    for(i=0;i<20;i++){
        wtdBUFF2 = wtdBUFF + WTD_WorkAdd_Ch0 + i*0x80;
        WtdState[i]=(Wtd*)wtdBUFF2;
    }
    wtdBUFF2 = wtdBUFF + WTD_WorkAdd_System;
    WtdSys = (Wtd_Sys*)wtdBUFF2;


    return TRUE;
}

/*--------------------------------------------------------------
  [WTD�f�[�^�̃`�F�b�N]
  �Ԃ�l�FTRUE ����/FALSE �t�@�C�������݂��Ȃ�
--------------------------------------------------------------*/
BOOL CheckWtdData(void)
{

    int i,j;
    struct stat status;

    nFiles=0;
    
    /* ���� */
    text_put_string(0,0,"WMSV-WTD ver0.05 by FUN-X");
    text_put_string(0,1,"WTD by S.W.");
    text_put_string(4,7,"Data searching...");

    /* /rom0/�ɂ���t�@�C���G���g�������擾 */
    j=nument("/rom0/");
    if(j!=E_FS_FILE_NOT_FOUND){
        for(i=0;i<j;i++){
            /* �{���Ƀt�@�C�������݂��Ă��邩 */
            if( (getent("/rom0/",i,&status)==E_FS_SUCCESS) && (status.count!=-1) ){
                WtdMus = (WTD_Mus far *)mmap(status.name);
                /* WTD�f�[�^�t�@�C���� */
                if(strncmp(WtdMus->Name,"WTD\0",4)==0){
                    strcpy(szFileName[nFiles],status.name);
                    nFiles++;
                }
            }
        }
    }
    /* WTD�t�@�C��������������I�� */    
    if(nFiles==0){
        text_put_string(4,8,"���t�\�ȃt�@�C���������̂ŏI�����܂�");
        key_wait();
        return FALSE;
    }

    return TRUE;
}

/*--------------------------------------------------------------
  [���m�N���̃t�H���g�f�[�^���Z�b�g]
--------------------------------------------------------------*/
void InitFontMono(void)
{

    /*
    wwc_set_color_mode(COLOR_MODE_GRAYSCALE);
    */

    /* �p���b�g�Z�b�g */
    palette_set_color( 4, 15<<12 | 2<<8 | 0<<4 | 0);  /* ���՗p */
    palette_set_color( 5, 15<<12 | 0<<8 | 15<<4 | 0);   /* �t�H���g�p */
    palette_set_color(12, 4<<12 | 4<<8 | 4<<4 | 0);  /* �X�v���C�g�p */
}
/*--------------------------------------------------------------
  [�J���[�̃t�H���g�f�[�^���Z�b�g]
--------------------------------------------------------------*/
void InitFontColor(void)
{
    int i;

    /* 4�F���[�h�ɐݒ� */
    wwc_set_color_mode(COLOR_MODE_4COLOR);
    /* �p���b�g�Z�b�g */
    for ( i=0; i<4; i++ ){
        wwc_palette_set_color( 4, i, pal_c_keyboard[i]);    /* ���՗p */
        wwc_palette_set_color( 5, i, pal_c_font[i]);        /* �t�H���g�p */
        wwc_palette_set_color(12, i, pal_c_key[i]);         /* �X�v���C�g�p */
    }
}



/*=================================================================================================

                                        �e�L�X�g����

=================================================================================================*/
/*--------------------------------------------------------------
  [�����\��](�O���C�X�P�[���E�S�F�J���[���[�h�̂ݎg�p�\)
  �����Fshort              nX         �\��X���W
        short              nY         �\��Y���W
        int               nFontNo    �g�p�J�n�t�H���g�ԍ�
        unsigned char far *szStrings �\�����镶����
--------------------------------------------------------------*/
void wwprintf(short nX, short nY,int nFontNo,unsigned char far *szStrings,...)
{

    int nFontCode;
    char szBuf[64];
    char cMonoData[8];
    char nCount=0;
    
    vsprintf(szBuf,szStrings,(char *)(&szStrings+1));

    /* �����񂪏I������܂Ń��[�v */
    while ((nFontCode = szBuf[nCount++]) != 0x00){
        /* 2byte�����̏���(�蔲��) */
        if(nFontCode >= 0x0081)
            nFontCode = (nFontCode<<8) | szBuf[nCount++];
            
        /* �����R�[�h����t�H���g�f�[�^���쐬 */
        text_get_fontdata(nFontCode,cMonoData);
        font_set_monodata(nFontNo,1,cMonoData);
        screen_fill_char(SCREEN2,nX,nY,1,1,nFontNo|PAL(5));
        nFontNo++;
        nX++;
    }

/*  �t�H���g�ԍ���512�ȏ�ɂȂ��ĂȂ����`�F�b�N(debug�p)
    if(nFontNo>511)
        lcd_set_segments(1<<3);
*/

}
/*=================================================================================================

                                        �`�揈��

=================================================================================================*/
/*---------------------------------------------------------------
   [�Z���N�^�[���t�@�C�����\��]
---------------------------------------------------------------*/
void draw_files(void)
{

    screen_fill_char(SCREEN2, 0,16, 26, 1, PAL(4));
    
    wwprintf( 2,16,TEXT_VIEW_FILENAME,"%s",szFileName[nNum]);
    wwprintf(18,17,TEXT_VIEW_FILEINFO,"(%03d/%03d)",nNum+1,nFiles);

}
/*---------------------------------------------------------------
   [���t���̃t�@�C�����\��]
---------------------------------------------------------------*/
void draw_playfile(void)
{

    screen_fill_char(SCREEN2, 5, 13, 12, 1, PAL(4));
    wwprintf( 5,13,TEXT_VIEW_PLAYFILE,"%s",szFileName[nNum]);

}

/*---------------------------------------------------------------
   [�t���[���\��]
---------------------------------------------------------------*/
void draw_frame(void)
{
    int i,j;

    for(i=0;i<2;i++)
        for(j=0;j<28;j++)
            wwprintf( j,12+i*2,TEXT_VIEW_FRAME,"��");

}

/*---------------------------------------------------------------
   [���Օ\��]
---------------------------------------------------------------*/
void draw_keyboard(void)
{
    int dw,dx,dy,dz,count;

    /* ���Օ\�� */
    for(dz=0;dz<4;dz++){
        for(dw=0;dw<4;dw++){
            count=0;
            for(dy=0;dy<2;dy++){
                for(dx=0;dx<7;dx++){
                    screen_fill_char(SCREEN1, dx+dw*7, dy+dz*3+1, 1, 1, BG_KEYBOARD+count | PAL(4) );
                    count++;
                }
            }
        }
    }
}
/*---------------------------------------------------------------
   [���t�X�e�[�^�X�\��]
---------------------------------------------------------------*/
#ifdef WMSV_EXP
void draw_state(void)
{
    int i;
    static int nViewPoint=0;
    static BOOL bFirstDraw=TRUE;
    static char szStateName[9][8]={"NOTE","PROGRAM","EXPRESS","PAN","SHIFT","DETUNE","ADDRESS","FLAG","CHANNEL"};
    static int nNameFontNo[9]={TEXT_STATE_NAME,TEXT_STATE_NAME+4,TEXT_STATE_NAME+11,TEXT_STATE_NAME+18,
                               TEXT_STATE_NAME+21,TEXT_STATE_NAME+26,TEXT_STATE_NAME+32,TEXT_STATE_NAME+39,TEXT_STATE_NAME+43};

    /* �p�[�g�̃X�N���[�� */
    if((KeyState.Key_Y1) && nViewPoint>0){
        bFirstDraw=TRUE;
        nViewPoint--;
        sys_wait(5);
    }
    else if((KeyState.Key_Y3) && nViewPoint<16){
        bFirstDraw=TRUE;
        nViewPoint++;
        sys_wait(5);
    }

    if((KeyState.Key_Y2) || (KeyState.Key_Y4))
        bFirstDraw=TRUE;

    if(bFirstDraw){
        wwprintf( 8,0,TEXT_STATE_CHANNEL,"CH%02d CH%02d CH%02d CH%02d",nViewPoint+1,nViewPoint+2,nViewPoint+3,nViewPoint+4);
        for(i=0;i<9;i++)
            wwprintf( 0,i+1,nNameFontNo[i],szStateName[i]);
        bFirstDraw=FALSE;
    }

    /* �e��X�e�[�^�X��\�� */
    for(i=0;i<4;i++){
        wwprintf(8+i*5,1,TEXT_STATE_NOTE+i*2    ,"%02x",WtdState[i+nViewPoint]->Key);
        wwprintf(8+i*5,2,TEXT_STATE_PROGRAM+i*2 ,"%02x",WtdState[i+nViewPoint]->Program);
        wwprintf(8+i*5,3,TEXT_STATE_VOL+i*2     ,"%02x",WtdState[i+nViewPoint]->Expr);
        wwprintf(8+i*5,4,TEXT_STATE_PAN+i*2     ,"%02x",WtdState[i+nViewPoint]->Pan);
        wwprintf(8+i*5,5,TEXT_STATE_KEYSHIFT+i*2,"%02x",WtdState[i+nViewPoint]->KeyShift);
        wwprintf(8+i*5,6,TEXT_STATE_DETUNE+i*4  ,"%04x",WtdState[i+nViewPoint]->BendDetune);
        wwprintf(8+i*5,7,TEXT_STATE_ADD+i*4     ,"%04x",WtdState[i+nViewPoint]->Address);
        wwprintf(8+i*5,8,TEXT_STATE_FLAG+i*4    ,"%04x",WtdState[i+nViewPoint]->FlagControl);
        wwprintf(8+i*5,9,TEXT_STATE_TRACK+i*2   ,"%02x",WtdState[i+nViewPoint]->Channel);
    }
}
#endif
/*---------------------------------------------------------------
   [���ՃX�e�[�^�X�\��]
---------------------------------------------------------------*/
void draw_viewer(void)
{

    int i,j;
    static int nViewPoint=0;
    static char key_pos[12][2] = {{ 1,17},{ 3,12},{ 5,17},{ 7,12},{ 9,17},{13,17},
                                  {15,12},{17,17},{19,12},{21,17},{23,12},{25,17}};

    /* �p�[�g�̃X�N���[�� */
    if((KeyState.Key_Y1) && nViewPoint>0){
        nViewPoint--;
        sys_wait(5);
    }
    else if((KeyState.Key_Y3) && nViewPoint<16){
        nViewPoint++;
        sys_wait(5);
    }
    
    /* �X�e�[�^�X�\�� */    
    for(i=0;i<4;i++){
        wwprintf( 0,i*3,TEXT_VIEW_CHANNEL+i*4,"CH%02d",i+1+nViewPoint);                 /* CH */
        wwprintf( 5,i*3,TEXT_VIEW_PROGRAM+i*4,"@%03d",WtdState[i+nViewPoint]->Program); /* @ */
        wwprintf(10,i*3,TEXT_VIEW_VOL+i*4,"v%03d",WtdState[i+nViewPoint]->Expr);        /* v */
        wwprintf(15,i*3,TEXT_VIEW_PAN+i*4,"p%03d",WtdState[i+nViewPoint]->Pan);         /* p */
    }

    /* ���t���ĂȂ��ꍇ�����Ŗ߂�(�X�v���C�g��\�������Ȃ�����) */
    if(nBGMPlay==0)
        return;

    /* ���K(����) */
    for(i=0;i<4;i++){
        for(j=0;j<8;j++){
            if(i+nViewPoint>=WtdSys->MusicPart)
                sprite_set_location(i*8+j,0,18*8);
            else{
                if(WtdState[i+nViewPoint]->KeySet[j]!=0xFF)
                    sprite_set_location(i*8+j,
                        key_pos[WtdState[i+nViewPoint]->KeySet[j]%12][0]+(WtdState[i+nViewPoint]->KeySet[j]-24)/12*28-4,
                        key_pos[WtdState[i+nViewPoint]->KeySet[j]%12][1]+i*24-1);
                else
                    sprite_set_location(i*8+j,0,18*8);
            }
        }
    }


}
/*---------------------------------------------------------------
   [�X�v���C�g����ʊO��]
---------------------------------------------------------------*/
void key_out(void)
{
    int i;
    
    for(i=0;i<32;i++)
        sprite_set_location(i,0,18*8);

}

/*=================================================================================================

                                        �L�[����

=================================================================================================*/
/*---------------------------------------------------------------
   [�������L�[�̕ۑ�]
---------------------------------------------------------------*/
void KeyCheck(void)
{

    int nKeyState;        /* �L�[�̏�� */

    nKeyState=key_press_check();

    if(nKeyState&KEY_A)  KeyState.Key_A  = TRUE; else KeyState.Key_A  = FALSE;
    if(nKeyState&KEY_B)  KeyState.Key_B  = TRUE; else KeyState.Key_B  = FALSE;
    if(nKeyState&KEY_X1) KeyState.Key_X1 = TRUE; else KeyState.Key_X1 = FALSE;
    if(nKeyState&KEY_X2) KeyState.Key_X2 = TRUE; else KeyState.Key_X2 = FALSE;
    if(nKeyState&KEY_X3) KeyState.Key_X3 = TRUE; else KeyState.Key_X3 = FALSE;
    if(nKeyState&KEY_X4) KeyState.Key_X4 = TRUE; else KeyState.Key_X4 = FALSE;
    if(nKeyState&KEY_Y1) KeyState.Key_Y1 = TRUE; else KeyState.Key_Y1 = FALSE;
    if(nKeyState&KEY_Y2) KeyState.Key_Y2 = TRUE; else KeyState.Key_Y2 = FALSE;
    if(nKeyState&KEY_Y3) KeyState.Key_Y3 = TRUE; else KeyState.Key_Y3 = FALSE;
    if(nKeyState&KEY_Y4) KeyState.Key_Y4 = TRUE; else KeyState.Key_Y4 = FALSE;
    if(nKeyState&KEY_START) KeyState.Key_Start = TRUE; else KeyState.Key_Start = FALSE;

}