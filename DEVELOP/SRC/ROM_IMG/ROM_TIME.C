/****************************************************************/
/*																*/
/*					Music Viewer	Timer sub routine			*/
/*						for Wonder Swan Emulator				*/
/*																*/
/*								Programmed by.					*/
/*									S.W.						*/
/*																*/
/****************************************************************/
/*--------------------------------------*/
/*	定数定義							*/
/*--------------------------------------*/
/* タイマー割り込み関連 */

/* タイマー設定用 */
#define	TimerCountMax		75			/* V-blankで約１秒 */



/* カウンターの最大値 */
#define	MaxSec				59
#define	MaxMin				59
#define	MaxHr				23

/*--------------------------------------*/
/*	構造体定義							*/
/*--------------------------------------*/
typedef struct{
	char	cSec;				/*秒*/
	char	cMin;				/*分*/
	char	cHr;				/*時間 (ここまで放置する人いたらスゴヒネ♪) */
	char	cDay;				/*日数 (ここがインクリメントされたら神！！)*/
} TimeCounter;


/*--------------------------------------*/
/*	グローバル変数定義					*/
/*--------------------------------------*/

volatile	TimeCounter	TimeCount;		/* 時間カウント用 */
			IntVector	old_vector_vblabk;


/*--------------------------------------------------------------*/
/*	タイマー割り込みメインルーチン								*/
/*--------------------------------------------------------------*/
/*●引数	無し												*/
/*●返値	無し												*/
/*●処理	メモリのダンプ表示									*/
/*●開発	S.W.												*/
/*--------------------------------------------------------------*/
void	time_int_main(){

	int	i;						/* ダミー */

	pusha();					/* レジスタ保存 */
	get_iram();					/* DSレジスタ ← DGROUP */

	/* タイマー割り込みの禁止 */
	outb(Int_Enable,(INT_VblankRes & inb(Int_Enable)) );
	/* End Of Interrupt(EOI)の発行 */
	outb(Int_Eoi,INT_VblankSet);

	/* 時間のカウント */
	if(TimeCount.cSec++>=MaxSec){
		if(TimeCount.cMin++>=MaxMin){
			if(TimeCount.cHr++>=MaxHr){
				TimeCount.cDay++;
				TimeCount.cHr=0;
			}
			TimeCount.cMin=0;
		}
		TimeCount.cSec=0;
	}

	/* タイマー割り込みの許可 */
	outb(Int_Enable,(INT_VblankSet | inb(Int_Enable)) );

	i=0;						/*	Dummy	*/

	popa();						/* レジスタ復帰 */
	iret();						/* 割り込み処理完了 */
};
/*--------------------------------------------------------------*/
/*	タイマー初期化												*/
/*--------------------------------------------------------------*/
/*●引数	無し												*/
/*●返値	無し												*/
/*●処理	時間のカウント開始									*/
/*●開発	S.W.												*/
/*--------------------------------------------------------------*/
void	Time_Init(){
	IntVector	far	*VblCountup_Int;	/* 割り込みベクタ */

	/* カウンター初期化 */
	TimeCount.cSec	= 0;
	TimeCount.cMin	= 0;
	TimeCount.cHr	= 0;
	TimeCount.cDay	= 0;

	/* 割り込みベクタのポインタ設定 */
	VblCountup_Int = 4L * (long)(INT_VBLANK_COUNTUP);

	/* タイマー割り込みの許可 */
	outb(Int_Enable,(INT_VblankRes & inb(Int_Enable)) );

	/* 割り込みベクタの設定 */
	old_vector_vblabk = *VblCountup_Int;
	VblCountup_Int->callback = time_int_main;
	VblCountup_Int->cs = get_cs();

	/* タイマーの設定 */
	outb(TIMER_Status,((Timer_V_Enable | Timer_V_auto) | inb(TIMER_Status)));
	outw(TIMER_MaxCountV,TimerCountMax);

	/* タイマー割り込みの許可 */
	outb(Int_Enable,(INT_VblankSet | inb(Int_Enable)) );


};
