;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Timer Control				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;===============================================================|
;			I/O Address				|
;===============================================================|
Int_Enable		equ	0b2h	;
Int_Eoi			equ	0b6h	;
BankSram		equ	0c1h	;
TIMER_Status		equ	0a2h	;Timer Status
TIMER_MaxCountH		equ	0a4h	;Hblank Load Count
TIMER_MaxCountV		equ	0a6h	;Vblank Load Count
TIMER_CounterH		equ	0a8h	;Hblank Down Counter
TIMER_CounterV		equ	0aah	;Vblank Down Counter
;===============================================================|
;			INT Status bit flag			|
;===============================================================|
INT_HblankSet		equ	080h	;Hblank�l�Z�b�g�@(or)
INT_HblankReset		equ	07fh	;Hblank�l���Z�b�g(and)
;===============================================================|
;			COMM Status bit flag			|
;===============================================================|
Timer_H_Enable		equ	001h	;Hblank Int. Enable	(or)
Timer_H_Disable		equ	0feh	;Hblank Int. Disable	(and)
Timer_H_auto		equ	002h	;Vblank auto preset mode(or)
Timer_H_shot		equ	0fdh	;Vblank 1 shot mode	(and)
Timer_V_Enable		equ	004h	;Vblank Int. Enable 	(or)
Timer_V_Disable		equ	0fbh	;Vblank Int. Disable	(and)
Timer_V_auto		equ	008h	;Vblank auto preset mode(or)
Timer_V_shot		equ	0f7h	;Vblank 1 shot mode	(and)
;===============================================================|
;			�萔					|
;===============================================================|
Timer_Open		equ	0303h	;Hblank Enable / Auto mode
Timer_Close		equ	0100h	;Hblank Disable
;
;	Frection = 12000 / ( timebase �~ tempo / 60 )
;	Frection = 0AFC80h / (timebase �~ tempo )
;
Timer_Tempo120		equ	125	;timebase 48 / Tempo 120
;===============================================================|
;		�^�C�}�[�̓���J�n				|
;===============================================================|
;	������							|
;		����						|
;	�Ԃ�l							|
;		����						|
;	����							|
;		device�̏����ݒ�				|
;===============================================================|
	even				;�����A�h���X�z�u
T_open	proc near			;
	push	ax			;���W�X�^�ۑ�

	mov	ax,Timer_Open		;Set
	call	T_Set_Status		;

	call	T_init			;���荞�ݎ����̐ݒ�

	in	al,Int_Enable		;
	or	al,Int_HblankSet	;
	out	Int_Enable,al		;

	pop	ax			;���W�X�^���A
	ret				;
T_open	endp				;
;===============================================================|
;		�^�C�}�[�̓���I��				|
;===============================================================|
;	������							|
;		����						|
;	�Ԃ�l							|
;		����						|
;	����							|
;		device�̏�����					|
;===============================================================|
	even				;�����A�h���X�z�u
T_close	proc near			;
	push	ax			;���W�X�^�ۑ�

	mov	ax,Timer_Close		;Reset
	call	T_Set_Status		;

	in	al,Int_Enable		;
	and	al,Int_HblankReset	;
	out	Int_Enable,al		;
	mov	al,Int_HblankReset	;
	out	Int_Eoi,al		;�o��

	pop	ax			;���W�X�^���A
	ret				;
T_close	endp				;
;===============================================================|
;		�^�C�}�[�̏����ݒ�				|
;===============================================================|
;	������							|
;		����						|
;	�Ԃ�l							|
;		����						|
;	����							|
;		�^�C�}�[������Tempo120�ɂ���B			|
;===============================================================|
	even				;�����A�h���X�z�u
T_init	proc near			;
	push	ax			;���W�X�^�ۑ�

	mov	ax,Timer_Tempo120	;
	call	T_Set_Frection		;

	pop	ax			;���W�X�^���A
	ret				;
T_init	endp				;
;===============================================================|
;		�^�C�}�[���[�h�̐ݒ�				|
;===============================================================|
;	������							|
;		AL	Output mode				|
;		AH	Set bit					|
;	�Ԃ�l							|
;		����						|
;	����							|
;		���[�h�̐ݒ�					|
;===============================================================|
	even				;�����A�h���X�z�u
T_Set_Status	proc near		;
	push	dx			;���W�X�^�ۑ�
	mov	dx,TIMER_Status		;dx��I/O Address
	call	SP_Set_with_mask	;
	pop	dx			;���W�X�^���A
	ret				;
T_Set_Status	endp			;
;===============================================================|
;		�^�C�}�[�����̐ݒ�				|
;===============================================================|
;	������							|
;		AX	���荞�ݎ���				|
;	�Ԃ�l							|
;		����						|
;	����							|
;		���[�h�̐ݒ�					|
;===============================================================|
	even				;�����A�h���X�z�u
T_Set_Frection	proc near		;
	out	Timer_MaxCountH,ax	;�o��
	ret				;
T_Set_Frection	endp			;