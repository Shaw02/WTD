/****************************************************************/
/*																*/
/*				IL_TEST ヘッダーファイル						*/
/*																*/
/****************************************************************/

#include	<stdio.h>
#include	<stdlib.h>
#include	<fcntl.h>
#include	<sys/bios.h>
#include	<..\..\..\wtd.h>

/* heap変数を作る。 */
/* #define	_pc	BANK_SRAM_ADDRESS */
/* _heapは、構造体定義されている。*/
/* 'sys/process.h'を参照。*/
#define	heap	(_pc->_heap)

/* 変数定義(DGROUPに配置される。) */
	WtdIL	wtdIL;
	char	voice[]={0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0,0,0,0,0,0,0,0};
	char near *wtdBUFF;
	char near *wtdBUFF_System;
	char near *wtdBUFF_Pcm;
	char near *wtdBUFF_Ch0;
	char near *wtdBUFF_Wave;
	char far  *IRAMV;

void wtd_print();

/* メインルーチン */
void main(){

/* グローバル変数確保 */
	int	result;
	int	count;

/*制御用ワークアドレスの取得 */
	wtdBUFF = heap;
	wtdBUFF_System = wtdBUFF + WTD_WorkAdd_System;
	wtdBUFF_Pcm    = wtdBUFF + WTD_WorkAdd_PCM;
	wtdBUFF_Ch0    = wtdBUFF + WTD_WorkAdd_Ch0;
	wtdBUFF_Wave   = wtdBUFF + WTD_WorkAdd_Wave;
	IRAMV          = IRAM_Segment;

/*	テキスト画面初期化	*/
	text_screen_init();

	text_put_string(0, 0, "WanderSwan");
	text_put_string(0, 1, "TotalSoundDriver");
	text_put_string(0, 2, "TEST Program");
	text_put_string(4, 4, "Push any key");
	key_wait();

/*	ILファイルをマッピングする	*/
	result = ilibIL->_open("@wtdIL", (IL far *)&wtdIL);
	
/*	正常終了？	*/
	if (result == E_FS_SUCCESS){

	text_screen_init();
	text_put_string(0,0,"stay success");
	text_put_string(0,1,"WS 4bit PCM Test");

	text_put_string(4,2,"wtdIL init");
	wtdIL.Stay();
	key_wait();

	text_put_string(4,3,"wave test play");
	count = wtdIL.PcmPlay(mmap("/rom0/testwav"));
	text_put_numeric(4,4,5,1,count);
	key_wait();


	text_put_string(4,3,"music test play");
	count = wtdIL.MusicPlay(mmap("/rom0/testmus"));
	text_put_numeric(4,4,5,1,count);

	text_screen_init();

	wtd_print();						/* パラメータの表示 */

	text_screen_init();

	text_put_string(4,6,"wave stop");
	wtdIL.PcmStop();
	key_wait();

	text_put_string(4,7,"stay out");
	wtdIL.StayOut();
	key_wait();

	count = wtdBUFF_System[0x14] + wtdBUFF_System[0x15] * 256;
	text_put_numeric(6,8,5,1,count);
	key_wait();

	count = wtdBUFF_System[0x0E] + wtdBUFF_System[0x0F] * 256;
	text_put_numeric( 6,9,5,1,count);
	count = wtdBUFF_System[0x10] + wtdBUFF_System[0x11] * 256;
	text_put_numeric(12,9,5,1,count);
	key_wait();
	count = wtdBUFF_Pcm[0x08] + wtdBUFF_Pcm[0x09] * 256;
	text_put_numeric( 6,10,5,1,count);
	count = wtdBUFF_Pcm[0x0A] + wtdBUFF_Pcm[0x0B] * 256;
	text_put_numeric(12,10,5,1,count);
	count = wtdBUFF_Pcm[0x0C] + wtdBUFF_Pcm[0x0D] * 256;
	text_put_numeric(18,10,5,1,count);
	key_wait();
	count = wtdBUFF_System[0x26] + wtdBUFF_System[0x27] * 256;
	text_put_numeric( 6,11,5,1,count);
	key_wait();

	};
};



void wtd_print(){

	int	count;
	int	i;

	text_put_string(0, 0,"Address:");
	text_put_string(0, 1,"FlagCtr:");
	text_put_string(0, 2,"Key    :");
	text_put_string(0, 3,"KeySet :");
	text_put_string(0, 4,"Bend   :");
	text_put_string(0, 5,"BendSet:");
	text_put_string(0, 6,"Expr   :");
	text_put_string(0, 7,"ExprSet:");
	text_put_string(0, 8,"BendLFO:");
	text_put_string(0, 9,"BendEmb:");
	text_put_string(0,10,"ExprLFO:");
	text_put_string(0,11,"ExprEmb:");
	text_put_string(0,12,"ExprPan:");
	text_put_string(0,13,"WTDWTbl:");
	text_put_string(0,15,"WaveTbl:");

	text_put_string(14, 0,"Flag & :");
	text_put_string(14, 1,"Flag # :");
	text_put_string(14, 2,"Flag b :");
	text_put_string(14, 3,"Program:");
	text_put_string(14, 4,"Channel:");
	text_put_string(14, 5,"Loop   :");
	text_put_string(14, 6,"LoopPnt:");
	text_put_string(14, 7,"Leng   :");
	text_put_string(14, 8,"LengCnt:");
	text_put_string(14, 9,"LengDef:");

	while(key_press_check() == 0){
		count = wtdBUFF_Ch0[0x06] + wtdBUFF_Ch0[0x07] * 256;
			text_put_numeric( 8, 0,5,1,count);
		count = wtdBUFF_Ch0[0x00] + wtdBUFF_Ch0[0x01] * 256;
			text_put_numeric( 8, 1,5,1,count);
		count = wtdBUFF_Ch0[0x1f];
			text_put_numeric( 8, 2,5,1,count);
		count = wtdBUFF_Ch0[0x20];
			text_put_numeric( 8, 3,5,1,count);
		count = wtdBUFF_Ch0[0x2c] + wtdBUFF_Ch0[0x2d] * 256;
			text_put_numeric( 8, 4,5,1,count);
		count = wtdBUFF_Ch0[0x2a] + wtdBUFF_Ch0[0x2b] * 256;
			text_put_numeric( 8, 5,5,1,count);
		count = wtdBUFF_Ch0[0x41];
			text_put_numeric( 8, 6,5,1,count);
		count = wtdBUFF_Ch0[0x40];
			text_put_numeric( 8, 7,5,1,count);
		count = wtdBUFF_Ch0[0x36] + wtdBUFF_Ch0[0x37] * 256;
			text_put_numeric( 8, 8,5,1,count);
		count = wtdBUFF_Ch0[0x3D];
			text_put_numeric( 8, 9,5,1,count);
		count = wtdBUFF_Ch0[0x4a] + wtdBUFF_Ch0[0x4b] * 256;
			text_put_numeric( 8,10,5,1,count);
		count = wtdBUFF_Ch0[0x51];
			text_put_numeric( 8,11,5,1,count);
		count = wtdBUFF_Ch0[0x3f];
			text_put_numeric( 8,12,5,1,count);
		for(i=0;i<8;i++){
			text_put_numeric( 8+i*2,13,2,1,wtdBUFF_Wave[i+0+wtdBUFF_Ch0[0x11]*16]);
			text_put_numeric( 8+i*2,14,2,1,wtdBUFF_Wave[i+8+wtdBUFF_Ch0[0x11]*16]);
			text_put_numeric( 8+i*2,15,2,1,IRAMV[0x0180+i+(wtdBUFF_Ch0[0x05] & 0x7f)*16]);
			text_put_numeric( 8+i*2,16,2,1,IRAMV[0x0188+i+(wtdBUFF_Ch0[0x05] & 0x7f)*16]);
		};

		count = wtdBUFF_Ch0[0x01];
			text_put_numeric(22, 0,5,1,count);
		count = wtdBUFF_Ch0[0x02];
			text_put_numeric(22, 1,5,1,count);
		count = wtdBUFF_Ch0[0x03];
			text_put_numeric(22, 2,5,1,count);
		count = wtdBUFF_Ch0[0x11];
			text_put_numeric(22, 3,5,1,count);
		count = wtdBUFF_Ch0[0x05];
			text_put_numeric(22, 4,5,1,count);
		count = wtdBUFF_Ch0[0x08 + wtdBUFF_Ch0[0x10]];
			text_put_numeric(22, 5,5,1,count);
		count = wtdBUFF_Ch0[0x10];
			text_put_numeric(22, 6,5,1,count);
		count = wtdBUFF_Ch0[0x14] + wtdBUFF_Ch0[0x15] * 256;
			text_put_numeric(22, 7,5,1,count);
		count = wtdBUFF_Ch0[0x16] + wtdBUFF_Ch0[0x17] * 256;
			text_put_numeric(22, 8,5,1,count);
		count = wtdBUFF_Ch0[0x18] + wtdBUFF_Ch0[0x19] * 256;
			text_put_numeric(22, 9,5,1,count);
	};
};


