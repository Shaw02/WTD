;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Interrupt main program			|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;****************************************************************
;*								*
;*			�萔					*
;*								*
;****************************************************************
;
;	����͖���
;
;****************************************************************
;*								*
;*			�f�[�^�e�[�u��				*
;*								*
;****************************************************************
;===============================================================|
;			Volume					|
;===============================================================|
;								|
;	Table = 256 * log(volume +1) / log(257)			|
;								|
;===============================================================|
	even
I_Volume_Table:
;		00h,01h,02h,03h,04h,05h,06h,07h,08h,09h,0Ah,0Bh,0Ch,0Dh,0Eh,0Fh
	db	  0, 31, 50, 63, 74, 82, 89, 95,101,106,110,114,118,121,124,127
	db	130,133,135,138,140,142,144,146,148,150,152,153,155,156,158,159
	db	161,162,164,165,166,167,169,170,171,172,173,174,175,176,177,178
	db	179,180,181,182,183,184,184,185,186,187,188,188,189,190,191,191
	db	192,193,193,194,195,195,196,197,197,198,199,199,200,200,201,202
	db	202,203,203,204,204,205,206,206,207,207,208,208,209,209,210,210
	db	211,211,211,212,212,213,213,214,214,215,215,216,216,216,217,217
	db	218,218,218,219,219,220,220,220,221,221,222,222,222,223,223,223
	db	224,224,224,225,225,225,226,226,226,227,227,227,228,228,228,229
	db	229,229,230,230,230,231,231,231,232,232,232,232,233,233,233,234
	db	234,234,234,235,235,235,236,236,236,236,237,237,237,238,238,238
	db	238,239,239,239,239,240,240,240,240,241,241,241,241,242,242,242
	db	242,243,243,243,243,243,244,244,244,244,245,245,245,245,246,246
	db	246,246,246,247,247,247,247,247,248,248,248,248,249,249,249,249
	db	249,250,250,250,250,250,251,251,251,251,251,252,252,252,252,252
	db	253,253,253,253,253,253,254,254,254,254,254,255,255,255,255,255
;===============================================================|
;			Frection(Key)				|
;===============================================================|
;								|
;	Table = (3.072[MHz] / (32 * frection)) * 2^7		|
;								|
;		Frection : a = 440[Hz]				|
;								|
;								|
;	DeviceOut = 2048 - (Table / 2^(3 + Octave))		|
;								|
;===============================================================|
	even				;�����A�h���X�z�u
I_Frection_Table:
	dw	46978			;c	Bend Range �� 4
	dw	44332			;c#		( 3�` 6)
	dw	41843			;d	
	dw	39495			;d#	
	dw	37278			;e	
	dw	35186			;f	
	dw	33211			;f#	
	dw	31347			;g	
	dw	29687			;g#	
	dw	27922			;a	
	dw	26360			;a#	
	dw	24880			;b	
;****************************************************************
;*								*
;*			���荞�݃��C�����[�`��			*
;*								*
;****************************************************************
;===============================================================|
;		Interrupt Main					|
;===============================================================|
;								|
;	������							|
;		�@���t���[�`���̌Ăяo���A			|
;		�^�C�}�[�̐�����s�����[�`���B			|
;								|
;	���g�p���W�X�^						|
;		ds:bp	���[�N�̈�擪�A�h���X			|
;		ds:bx	�p�[�g���ʍ\����			|
;								|
;===============================================================|
	even					;�����A�h���X�z�u
I_Start:
	push	ax				;
	push	bx				;
	push	cx				;
	push	dx				;
	push	si				;
	push	di				;
	push	bp				;
	push	ds				;���W�X�^�ۑ�

	in	al,Int_Enable			;
	and	al,INT_HblankReset		;�V���A�����M�G���v�e�B�[
	out	Int_Enable,al			;���荞�݋֎~

;---------------------------------------------------------------
;EOI�̔��s

;End Of Interrupt
	mov	al,Int_HblankSet		;
	out	Int_Eoi,al			;�o��

	sti					;���荞�݋���
;---------------------------------------------------------------
;�o���N�̐ݒ�
	in	al,BankSram			;���݂�SRAM Bank�𓾂�
	cmp	al,BANK_USERDS0			;���[�U�̈�������Ă�����A
	jz	I_Start_Step1			;���̏����͍s��Ȃ��B
	cmp	al,BANK_USERDS1			;
	jz	I_Start_Step1			;'/ram0'�A�N�Z�X���́A
	jmp	I_Start_End			;���������Ȃ��B

I_Start_Step1:
;	push	ax				;

;---------------------------------------------------------------
;���[�N�G���A�A�h���X�̎擾

;	push	SRAM_Segment			;
;	pop	ds				;ds��SRAM�Z�O�����g
;	mov	bp,ds:[ProcContext_heap]	;ds:bx�����[�N�G���A�A�h���X
	WTD_WorkGet	ds,bp			;���[�N�G���A�A�h���X�̎擾
	mov	bx,bp				;
	add	bx,WTD_WorkAdd_System		;ds;bx�����ʍ\����

;---------------------------------------------------------------
;���t�E���ʉ��EPcmVoice���[�`���̌Ăяo��

;PCM Voice
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_Pcm	;
	jz	I_PcmStep				;
	call	I_Pcm					;PCM Voice
I_PcmStep:						;

;Music & Effect
	cmp	ds:[bx].WTD_Sys_TempoCounter,0		;if(TempoCounter == 0){
	jnz	I_MusicEffectStep			;    I_MusicEffect();
	call	I_MusicEffect				;};
I_MusicEffectStep:					;

;---------------------------------------------------------------
;�o���N�̕��A
;
;	pop	ax				;���A
;	out	BankSram,al			;�ݒ肷��B
;
;---------------------------------------------------------------
;���荞�݂̏I��

I_Start_End:
	cli				;���荞�݋֎~

	in	al,Int_Enable		;
	or	al,INT_HblankSet	;�^�C�}�[
	out	Int_Enable,al		;���荞�݋���

	pop	ds				;���W�X�^���A
	pop	bp				;
	pop	di				;
	pop	si				;
	pop	dx				;
	pop	cx				;
	pop	bx				;
	pop	ax				;
	iret					;
;****************************************************************
;*								*
;*			���荞�݃��[�`��			*
;*				���t�E���ʉ��E�o�b�l����	*
;*								*
;****************************************************************
;*								*
;*	�@���t����						*
;*								*
;*	�������E�Ԓl�i���̒l�͕ۂK�v������B�j		*
;*		ds:bx	���L�\���̃A�h���X			*
;*		ds:bp	���[�N�x�[�X�A�h���X			*
;*								*
;*	�����W�X�^����U��					*
;*		ax	�ėp(��Ɍv�Z)				*
;*		ds:bx	���L�\���̃A�h���X	����		*
;*		cx	�ėp(��ɃJ�E���^)			*
;*		dx	�ėp(��Ɍv�Z)				*
;*		ds:di	�ʍ\����				*
;*		es:si	���t�A�h���X				*
;*		ds:bp	���[�N�x�[�X�A�h���X	����		*
;*								*
;****************************************************************
;===============================================================|
;		PCM Main					|
;===============================================================|
	even					;�����A�h���X�z�u
I_Pcm:						;
;---------------------------------------------------------------
;PcmVioce���[�`��

;Pcm�����I���H
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_PcmEnd	;
	jnz	I_Pcm_PcmStep1				;

;���W�X�^�ݒ�
	mov	di,bp				;
	add	di,WTD_WorkAdd_PCM		;di���p�[�g�ʍ\����

;PcmVioce����					;
	call	I_PcmVoice			;�������[�`���Ăяo��

;---------------------------------------------------------------
;�J�E���g

;�e���|�p�J�E���^�[�@�f�B�N�������g
I_Pcm_PcmStep1:					;
	dec	ds:[bx].WTD_Sys_TempoCounter	;

;---------------------------------------------------------------
;�I���

	ret					;
;===============================================================|
;		Music Main					|
;===============================================================|
	even					;�����A�h���X�z�u
I_MusicEffect:					;
	push	es				;���W�X�^�ۑ�
;---------------------------------------------------------------
;���t���[�`��

;���t���邩�H
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_Music	;
	jz	I_MusicEffect_MusicStep			;

;���W�X�^�ݒ�
	mov	di,bp				;
	add	di,WTD_WorkAdd_Ch0		;di���p�[�g�ʍ\����
	mov	ax,ds:[bx].WTD_Sys_MusicSegment	;
	mov	es,ax				;es�����t�f�[�^�Z�O�����g


;���t�������[�`���̌Ăяo��
	xor	cx,cx				;���i�ł͍ő�'20'�B
	mov	cl,ds:[bx].WTD_Sys_MusicPart	;�����ł͍ő�' 4'�B
	or	cx,cx				;
	jz	I_MusicEffect_MusicStep		;
	even					;�����A�h���X�z�u
I_MusicEffect_MusicLoop:			;
	call	I_Play				;
	add	di,WTD_WorkChSize		;�\���̂̃T�C�Y��80h(0x80)
	sub	cx,1				;
	jnz	I_MusicEffect_MusicLoop		;

I_MusicEffect_MusicStep:

;---------------------------------------------------------------
;���ʉ����[�`��

;���ʉ����邩�H
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_Effect	;
	jz	I_MusicEffect_EffectStep		;

;���W�X�^�ݒ�
	mov	di,bp				;
	add	di,WTD_WorkAdd_Ech0		;di���p�[�g�ʍ\����
	mov	ax,ds:[bx].WTD_Sys_EffectSegment
	mov	es,ax				;es�����ʉ��f�[�^�Z�O�����g

;���t�������[�`���̌Ăяo��
	xor	cx,cx				;
	mov	cl,ds:[bx].WTD_Sys_EffectPart	;�ő�'3'�B
	or	cx,cx				;
	jz	I_MusicEffect_EffectStep	;
	even					;�����A�h���X�z�u
I_MusicEffect_EffectLoop:			;
	call	I_Play				;
	add	di,WTD_WorkChSize		;�\���̂̃T�C�Y��80h(0x80)
	sub	cx,1				;
	jnz	I_MusicEffect_EffectLoop	;

I_MusicEffect_EffectStep:			;

;---------------------------------------------------------------
;PCM Vioce���ʉ����������Ă���A�����I���ł���Ȃ�΁A
;�^�C�}�[��߂��B

;PCM Vioce �������ł��邩�H
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_Pcm	;
	jz	I_MusicEffect_PcmCheck_End		;

;PcmVioce�����I���H
	test	ds:[bx].WTD_Sys_Flag,WTD_Sys_PcmEnd	;
	jz	I_MusicEffect_PcmCheck_Step1		;

;��PcmVioce�����I���̏ꍇ�B
;�t���O������
	mov	ax,ds:[bx].WTD_Sys_Flag		;
	and	ax,WTD_Sys_PcmR			;���t�f�B�Z�[�u��
	and	ax,WTD_Sys_PcmEndR		;�I�����Z�b�g
	and	ax,WTD_Sys_EffectMask2R		;ch2 ���ʉ��}�X�NRes
	mov	ds:[bx].WTD_Sys_Flag,ax		;
;�^�C�}�[�ݒ�
	mov	ax,ds:[bx].WTD_Sys_Tempo	;�^�C�}�[�̐ݒ�
	call	T_Set_Frection			;
;�^�C�}�[�J�E���^�ݒ�
	xor	ax,ax				;ax��0
	mov	ds:[bx].WTD_Sys_TempoCounter,ax	;TempoCounter = 0
;channel 2  �ݒ蕜�A
	mov	ch,81h				;�ݒ蕜�Ach2
	call	I_Effect_Return			;
;�I��
	jmp	I_MusicEffect_PcmCheck_End	;

;��PcmVioce�����p���̏ꍇ
I_MusicEffect_PcmCheck_Step1:			;
;�^�C�}�[�ݒ�
	mov	ax,1				;���荞�ݎ����͍ő�
	call	T_Set_Frection			;(12KHz)
;�^�C�}�[�J�E���^�ݒ�
	mov	ax,ds:[bx].WTD_Sys_Tempo	;
	mov	ds:[bx].WTD_Sys_TempoCounter,ax	;TempoCounter
;�I��
;	jmp	I_MusicEffect_PcmCheck_End	;

;�����I���
I_MusicEffect_PcmCheck_End:			;

;---------------------------------------------------------------
;�I���
	pop	es				;���W�X�^���A
	ret					;
;****************************************************************
;*								*
;*			���荞�݃��[�`��			*
;*				�o�b�l���䕔			*
;*								*
;****************************************************************
;===============================================================|
;		PCM Control Main				|
;===============================================================|
;	�����W�X�^�g�p						|
;		ax	�ėp(��Ɍv�Z)				|
;		ds:bx	���L�\���̃A�h���X	����		|
;		cx	�ėp(��ɃJ�E���^)			|
;		dx	�ėp(��Ɍv�Z)				|
;		ds:di	�ʍ\����		����		|
;		ds:bp	���[�N�x�[�X�A�h���X	����		|
;		es	���t�Z�O�����g�A�h���X	����		|
;		si	���t�I�t�Z�b�g�A�h���X			|
;===============================================================|
	even					;�����A�h���X�z�u
I_PcmVoice:
	push	es				;���W�X�^�ۑ�
;---------------------------------------------------------------
;��������

;�A�h���X�擾
	les	si,dword ptr ds:[di].WTD_PcmAddress	;es:si��Play Address

;�f�[�^����
	mov	ch,1				;ch = 2
	mov	al,es:[si]			;
	inc	si				;
;�f�[�^�o��
	call	SP_Set_Volume			;Volume Set

;�A�h���X�擾
	mov	dx,es				;dx:si��Play Address
;�|�C���^�`�F�b�N�i�Z�O�����g���E�H�j
	cmp	si,0				;
	jnz	I_PcmVoice_Step1		;
	add	dx,1000h			;�Z�O�����g���₷
I_PcmVoice_Step1:				;

;�A�h���X�ۑ�
	mov	word ptr ds:[di].WTD_PcmAddress+0,si	;�A�h���X�ۑ�
	mov	word ptr ds:[di].WTD_PcmAddress+2,dx	;

;�I���H
	sub	word ptr ds:[di].WTD_PcmSize+0,1
	jnc	I_PcmVoice_Step2		;PcmSize �f�B�N�������g
	dec	word ptr ds:[di].WTD_PcmSize+2	;
I_PcmVoice_Step2:				;
	mov	ax,word ptr ds:[di].WTD_PcmSize+0
	or	ax,word ptr ds:[di].WTD_PcmSize+2
	jnz	I_PcmVoice_End			;

;�I������
	or	ds:[bx].WTD_Sys_Flag,WTD_Sys_PcmEnd	;�I���t���O='h'

;---------------------------------------------------------------
I_PcmVoice_End:
;�I���
	pop	es				;���W�X�^���A
	ret					;
;****************************************************************
;*								*
;*			���荞�݃��[�`��			*
;*				���t�E���ʉ����䕔		*
;*								*
;****************************************************************
;===============================================================|
;		Music Control Main				|
;===============================================================|
;	�����W�X�^�g�p						|
;		ax	�ėp(��Ɍv�Z)				|
;		ds:bx	���L�\���̃A�h���X	����		|
;		cx	�ėp(��ɃJ�E���^)			|
;		dx	�ėp(��Ɍv�Z)				|
;		ds:di	�ʍ\����		����		|
;		ds:bp	���[�N�x�[�X�A�h���X	����		|
;		es	���t�Z�O�����g�A�h���X	����		|
;		si	���t�I�t�Z�b�g�A�h���X			|
;===============================================================|
	even				;�����A�h���X�z�u
I_Play:					;
	pusha				;
;---------------------------------------------------------------

;���t�`�F�b�N
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PlayEnd
	jz	I_Play_Step1			;
	jmp	I_Play_StepE			;
I_Play_Step1:					;

;�����J�E���^�[�E�f�B�N�������g
	dec	ds:[di].WTD_LengCounter		;

;�����ɂ��A�L�[�I���f�B���C
	mov	ax,ds:[di].WTD_Leng		;'k'�R�}���h�̔���
	sub	ax,ds:[di].WTD_LengCounter	;
	cmp	ax,ds:[di].WTD_KeyOnDelay	;
	jnz	I_Play_Step2			;
	call	I_Play_KeyOn			;
I_Play_Step2:					;

;�����ɂ��A���F����
	mov	ax,ds:[di].WTD_Leng		;'@'�R�}���h
	sub	ax,ds:[di].WTD_LengCounter	;
	cmp	ax,ds:[di].WTD_ProgramRate	;
	jnz	I_Play_Step8			;
	test	ds:[di].WTD_Program2nd,80h	;�K�v���̊m�F
	jnz	I_Play_Step8			;
	push	ax				;
	mov	al,ds:[di].WTD_Program2nd	;
	and	al,07fh				;���bit�̃}�X�N
	mov	dx,offset I_Table_Voice		;
	call	I_Table_Jump			;
	pop	ax				;
I_Play_Step8:					;

;�����ɂ��A�Q�[�g�^�C������
	cmp	ax,ds:[di].WTD_GateTimeStepFirst
	jz	I_Play_Step3			;'u'�R�}���h�̔���
	mov	ax,ds:[di].WTD_Leng		;'Q','U','q'�R�}���h�̔���
	mov	ch,ds:[di].WTD_GateTime8	;ch��GateTime8
	rol	ch,1				;
	shr	ch,1				;Bit 7 Reset & Bit 7 -> Cy Flag
	jc	I_Play_Step5			;

	mov	dx,8				;'Q'�R�}���h
	sub	dl,ch				;dx = 8 �| ch
	mul	dx				;dx:ax = ax �~ dx
	shr	dx,1				;
	shr	ax,1				;
	shr	dx,1				;
	shr	ax,1				;
	shr	dx,1				;
	shr	ax,1				;ax = dx:ax �� cl
	jmp	short I_Play_Step6		;

	even					;�����A�h���X�z�u
I_Play_Step5:					;'U'�R�}���h
	mov	cl,100				;cl = 100
	mov	dx,100				;dx = 100
	sub	dl,ch				;dx = dx �| ch
	mul	dx				;dx:ax = ax �~ dx
	xor	ch,ch				;
	div	cx				;ax = dx:ax �� cl
I_Play_Step6:					;
	add	ax,ds:[di].WTD_GateTimeStepLast	;ax = ax + WTD_GateTimeStepLast
	jnc	I_Play_Step7			;�I�[�o�[�t���[������A
	mov	ax,0ffffh			;�ő�l�ɏC���B
I_Play_Step7:					;
	cmp	ax,ds:[di].WTD_LengCounter	;
	jnz	I_Play_Step4			;
I_Play_Step3:					;
	call	I_Play_KeyOff			;
I_Play_Step4:					;

;�����J�E���^�O�Ȃ�΁A�R�}���h����
	cmp	ds:[di].WTD_LengCounter,0		;�����J�E���^���O�H
	jnz	I_Play_StepE				;
	mov	si,ds:[di].WTD_Address			;es:si��Play Address
	call	I_Play_Loop				;���䃋�[�`���ցB
	mov	ds:[di].WTD_Address,si			;
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PlayEnd
	jnz	I_Play_StepE				;���t�I���H
	cmp	ds:[di].WTD_KeyOnDelay,0		;KeyOnDelay�͂O�H
	jnz	I_Play_StepE				;
	call	I_Play_KeyOn				;�ł���΁AKeyOn

;���䃋�[�`����
I_Play_StepE:					;
	call	I_Play_Pan			;�p������
	call	I_Play_Volume			;���ʐ���
	cmp	ds:[di].WTD_ExprSet,0		;�@���ʂO��������A
	jz	I_Play_StepEnd			;�@�ȉ��̏����͖����B
	call	I_Play_Frection			;��������

;---------------------------------------------------------------
I_Play_StepEnd:				;
	popa				;
	ret				;
;****************************************************************
;*								*
;*			���荞�݃��[�`��			*
;*				���t�E���ʉ����䕔		*
;*				���[�v				*
;*								*
;****************************************************************
	even				;�����A�h���X�z�u
I_Play_Loop:				;
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PlayEnd
	jnz	I_Loop_StepE		;���t�`�F�b�N
	cmp	ds:[di].WTD_LengCounter,0
	jnz	I_Loop_StepE		;�����`�F�b�N
	jmp	I_Loop_Step1		;
I_Loop_StepE:				;
	ret				;
	even				;�����A�h���X�z�u
I_Loop_Step1:				;

;���t�f�[�^�ǂݍ���
	mov	al,es:[si]		;
	inc	si			;

;�R�}���h�^�C�v�`�F�b�N
	rol	al,1			;
	shr	al,1			;cy��Command Type

;���ꂼ��֏����R�[���E���̌�A���[�v����B
	jc	I_Loop_Step2		;
	call	I_PlayCommand		;
	jmp	I_Play_Loop		;Loop
I_Loop_Step2:				;
	call	I_PlayKey		;
	jmp	I_Play_Loop		;Loop
;****************************************************************
;*								*
;*			���荞�݃��[�`��			*
;*				���t�E���ʉ����䕔		*
;*				KeyOn,KeyOff����		*
;*								*
;****************************************************************
;*	�����W�X�^�g�p						*
;*		ax	�ėp(��Ɍv�Z)				*
;*		ds:bx	���L�\���̃A�h���X	����		*
;*		cx	�ėp(��ɃJ�E���^)			*
;*		dx	�ėp(��Ɍv�Z)				*
;*		ds:di	�ʍ\����		����		*
;*		ds:bp	���[�N�x�[�X�A�h���X	����		*
;*		es:si	���t�A�h���X		����		*
;****************************************************************
;===============================================================|
;			KeyOn (Hardware,Software)		|
;===============================================================|
	even				;�����A�h���X�z�u
I_Play_KeyOn:				;
	cmp	ds:[di].WTD_Key,0ffh	;�x���H
	jnz	I_Play_KeyOn_Start	;
	jmp	I_Play_KeyOn_End	;

	even				;�����A�h���X�z�u
I_Play_KeyOn_Start:			;
	pusha				;���W�X�^�ۑ�

;�O��̉����́A�^�C�H
	test	ds:[di].WTD_FlagTai,02h	;�O��^�C���������H
	jnz	I_Play_KeyOn_StepEnd	;

;���F����
	mov	al,ds:[di].WTD_Program2nd	;'@'�R�}���h
	and	al,ds:[di].WTD_Program3rd	;�K�v���̊m�F
	and	al,080h				;��2,3�p�����[�^�̎w�肪
	jnz	I_Play_KeyOn_Step8		;����������A�����͖����B
	mov	al,ds:[di].WTD_Program1st	;
	and	al,07fh				;���bit�̃}�X�N
	mov	dx,offset I_Table_Voice		;
	call	I_Table_Jump			;
I_Play_KeyOn_Step8:				;

;����Emb�͏����K�v�B
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_ExprEmb
	jz	I_Play_KeyOn_Step4		;
	mov	cx,WTD_Ctrl_EmbVol		;
	mov	dx,WTD_ExprEmb			;
	call	I_Play_KeyOn_Emb		;
	jmp	I_Play_KeyOn_Step4End		;
I_Play_KeyOn_Step4:				;
	mov	ds:[di].WTD_ExprEmbLevelSet,0ffh
I_Play_KeyOn_Step4End:				;

	test	ds:[di].WTD_FlagControl,0037h	;����Emb�͏����K�v�B
	jz	I_Play_KeyOn_Step7	;�\�t�g�E�F�A�������Ȃ��������΂��B

;����LFO
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_BendLfo
	jz	I_Play_KeyOn_Step1		;
	mov	dx,WTD_BendLFO			;
	call	I_Play_KeyOn_LFO		;
I_Play_KeyOn_Step1:				;

;����Emb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_BendEmb
	jz	I_Play_KeyOn_Step2		;
	mov	cx,WTD_Ctrl_EmbFreq		;
	mov	dx,WTD_BendEmb			;
	call	I_Play_KeyOn_Emb		;
I_Play_KeyOn_Step2:				;

;����LFO
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_ExprLFO
	jz	I_Play_KeyOn_Step3		;
	mov	dx,WTD_ExprLFO			;
	call	I_Play_KeyOn_LFO		;
I_Play_KeyOn_Step3:				;

;�p��LFO
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PanLFO
	jz	I_Play_KeyOn_Step5		;
	mov	dx,WTD_PanLFO			;
	call	I_Play_KeyOn_LFO		;
I_Play_KeyOn_Step5:				;

;�p��Emb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PanEmb
	jz	I_Play_KeyOn_Step6		;
	mov	cx,WTD_Ctrl_EmbPan		;
	mov	dx,WTD_PanEmb			;
	call	I_Play_KeyOn_Emb		;
I_Play_KeyOn_Step6:				;

;���W�����[�V����
I_Play_KeyOn_Step7:
ifndef	hyoka	;--------------------------------�����ł͖���
	xor	ax,ax				;
	cmp	ds:[di].WTD_ModLevelSet,al	;
	jz	I_Play_KeyOn_StepEnd		;�O��Ƃ��Ȃ��H
	mov	ds:[di].WTD_ModLevelSet,al	;
	mov	cl,MIDI_Ctrl_Mod		;
	mov	dx,offset I_Table_CtrlChgB	;���W�����[�V������
	call	I_Table_Jump			;�O����B
endif	;----------------------------------------

I_Play_KeyOn_StepEnd:			;
	popa				;���W�X�^���A

I_Play_KeyOn_End:			;
	ret				;
;===============================================================|
;			KeyOff (Hardware,Software)		|
;===============================================================|
	even				;�����A�h���X�z�u
I_Play_KeyOff:
	test	ds:[di].WTD_FlagTai,01h	;�^�C�H
	jnz	I_Play_KeyOff_End	;

I_Play_KeyOff_Start:			;
	pusha				;���W�X�^�ۑ�

;�n�[�h�E�F�A��KeyOff
	mov	dx,offset I_Table_KeyOff	;
	call	I_Table_Jump			;KeyOff

;���F����
	test	ds:[di].WTD_Program3rd,80h	;'@'�R�}���h
	jnz	I_Play_KeyOff_Step5		;�K�v���̊m�F
	mov	al,ds:[di].WTD_Program3rd	;
	and	al,07fh				;���bit�̃}�X�N
	mov	dx,offset I_Table_Voice		;
	call	I_Table_Jump			;
I_Play_KeyOff_Step5:				;

;����Emb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_BendEmb
	jz	I_Play_KeyOff_Step1		;
	mov	cx,WTD_Ctrl_EmbFreq		;
	mov	dx,WTD_BendEmb			;
	call	I_Play_KeyOff_Emb		;
I_Play_KeyOff_Step1:				;

;����Emb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_ExprEmb
	jz	I_Play_KeyOff_Step2		;
	mov	cx,WTD_Ctrl_EmbVol		;
	mov	dx,WTD_ExprEmb			;
	call	I_Play_KeyOff_Emb		;
	jmp	I_Play_KeyOff_StepEnd		;
I_Play_KeyOff_Step2:				;
	test	ds:[di].WTD_Channel,80h		;MIDI�p�[�g�̏ꍇ�͑��삵�Ȃ��B
	jz	I_Play_KeyOff_Step3		;
	mov	ds:[di].WTD_ExprEmbLevelSet,000h
I_Play_KeyOff_Step3:				;

;�p��Emb
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PanEmb
	jz	I_Play_KeyOff_Step4		;
	mov	cx,WTD_Ctrl_EmbPan		;
	mov	dx,WTD_PanEmb			;
	call	I_Play_KeyOff_Emb		;
I_Play_KeyOff_Step4:				;

I_Play_KeyOff_StepEnd:				;
	popa					;���W�X�^���A

I_Play_KeyOff_End:			;
	ret				;
;****************************************************************
;*								*
;*			���荞�݃��[�`��			*
;*				���t�E���ʉ����䕔		*
;*				�����E���ʐ���			*
;****************************************************************
;*	�����W�X�^�g�p						*
;*		ax	�ėp(��Ɍv�Z)				*
;*		ds:bx	���L�\���̃A�h���X	����		*
;*		cx	�ėp					*
;*		dx	���[�N�A�h���X�擪(�ʍ\����)		*
;*		ds:di	�ʍ\����		����		*
;*		ds:bp	���[�N�x�[�X�A�h���X	����		*
;*		es:si	���t�A�h���X		����		*
;****************************************************************
;===============================================================|
;			�������� (Detune,LFO,Emb����)		|
;===============================================================|
	even				;�����A�h���X�z�u
I_Play_Frection:			;
	pusha				;

;���W�����[�V��������(MIDI)
ifndef	hyoka	;--------------------------------�����ł͖���
	mov	ax,ds:[di].WTD_Leng		;���W�����[�V����
	sub	ax,ds:[di].WTD_LengCounter	;
	cmp	ax,ds:[di].WTD_ModDecay		;
	jnz	I_Play_Frection_Step4		;
	mov	al,ds:[di].WTD_ModLevel		;
;	cmp	ds:[di].WTD_ModLevelSet,al	;
;	jz	I_Play_Frection_Step4		;�����ł͂Ȃ��ł��傤�B
	mov	ds:[di].WTD_ModLevelSet,al	;
	mov	cl,MIDI_Ctrl_Mod		;
	mov	dx,offset I_Table_CtrlChgB	;���W�����[�V������
	call	I_Table_Jump			;������B
endif	;----------------------------------------
I_Play_Frection_Step4:				;


;�����ǂݍ���
	mov	ax,ds:[di].WTD_Bend	;

;�f�B�`���[���̉��Z
	add	ax,ds:[di].WTD_BendDetune

;����LFO����
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_BendLFO
	jz	I_Play_Frection_Step1	;
	mov	dx,WTD_BendLFO		;
	call	I_Play_LFO		;
	add	ax,dx			;
I_Play_Frection_Step1:			;

;����Emb����
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_BendEmb
	jz	I_Play_Frection_Step2	;
	mov	cx,WTD_Ctrl_EmbFreq	;
	mov	dx,WTD_BendEmb		;
	call	I_Play_Emb		;
	sub	dl,80h			
	jnc	I_Play_Frection_Step3	;
	mov	dh,0ffh			;dx��dl(�����t)
I_Play_Frection_Step3:			;
	shl	dx,6			;�~2^6
	add	ax,dx			;���Z
I_Play_Frection_Step2:			;

;�����̏o��
	mov	dx,offset I_Table_Frection	;�����Z�b�g
	call	I_Table_Jump			;

	popa				;
	ret				;
;===============================================================|
;			���ʐ��� (Detune,LFO,Emb����)		|
;===============================================================|
	even				;�����A�h���X�z�u
I_Play_Volume:				;
	pusha				;

;���ʓǂݍ��݁�14bit�ɕϊ�
	xor	ax,ax			;
	mov	al,ds:[di].WTD_Expr	;
	inc	ax			;
	shl	ax,7			;128�{�ɂ���B
	dec	ax			;�iRange:0�`16383�j

;�f�B�`���[���̉��Z
	add	ax,ds:[di].WTD_ExprDetune

;����LFO����
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_ExprLFO
	jz	I_Play_Volume_Step1	;
	mov	dx,WTD_ExprLFO		;
	call	I_Play_LFO		;
	add	ax,dx			;
I_Play_Volume_Step1:			;

;����Emb����
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_ExprEmb
	jz	I_Play_Volume_Step2	;
	mov	cx,WTD_Ctrl_EmbVol	;
	mov	dx,WTD_ExprEmb		;
	call	I_Play_Emb		;
;	mov	ds:[di].WTD_ExprEmbLevelSet,dl	;�G���x���[�v�l
I_Play_Volume_Step2:			;

;���ʂ��A7bit�ɕ␳
	inc	ax			;
	shr	ax,7			;ax��{(ax+1)��128}-1
	dec	ax			;�iRange:0�`127�j
	test	ah,ah			;
	jnz	I_Play_Volume_Step4	;
	test	al,080h			;
	jz	I_Play_Volume_Step5	;
I_Play_Volume_Step3:			;if (128=>ax>255){
	mov	al,07fh			;	al = 0x7F;
	jmp	I_Play_Volume_Step5	;}
I_Play_Volume_Step4:			;if (ax>255){
	mov	al,000h			;	al = 0x00;
I_Play_Volume_Step5:			;}

;�G���x���[�v���ʂ̍���
	xor	cx,cx			;
	mov	cl,al			;
	inc	cx				;cx������+1
	xor	ax,ax				;ax��0
	mov	al,ds:[di].WTD_ExprEmbLevelSet	;ax������
	inc	ax				;ax���\�t�g����+1
	mul	cx			;
	dec	ax			;
	shl	ax,1			;al��((Vol.+1)�~(SoftVol.+1)-1)�^128
	mov	al,ah			;(Range:0�`255)

;�\�t�g�E�F�A���ʂ̍���
	xor	cx,cx			;
	mov	cl,al			;
	inc	cx			;cx������+1
	xor	ax,ax			;ax��0
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	I_Volume_SoftEffect		;���ʉ��H
	mov	al,ds:[bx].WTD_Sys_VolumeMusic	;ax�����y����
	jmp	I_Volume_SoftEnd		;
I_Volume_SoftEffect:				;
	mov	al,ds:[bx].WTD_Sys_VolumeEffect	;ax�����ʉ�����
I_Volume_SoftEnd:				;
	mov	bx,offset I_Volume_Table	;log���Z
	mov	si,ax			;
	and	si,00ffh		;
	mov	al,cs:[bx + si]		;
	inc	ax			;ax���\�t�g����+1
	mul	cx			;
	dec	ax			;al��((2*Vol.+1)�~(SoftVol.+1)�^256)-1
	mov	al,ah			;(Range:0�`255)

;���ʂ̏o��
	mov	dx,offset I_Table_Volume	;���ʃZ�b�g
	call	I_Table_Jump			;

	popa				;
	ret				;
;===============================================================|
;			�p���|�b�g���� (LFO,Emb����)		|
;===============================================================|
	even				;�����A�h���X�z�u
I_Play_Pan:				;
	pusha				;

;�p���|�b�g�ǂݍ���
	xor	ax,ax			;
	mov	al,ds:[di].WTD_Pan	;

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PanLFO + WTD_Ctrl_PanEmb
	jz	I_Play_Pan_Output	;�\�t�g�E�F�A�������Ȃ��������΂��B

;128�{�ɂ���B
	inc	ax			;
	shl	ax,7			;
	dec	ax			;�iRange:0�`16383�j

;�p���|�b�gLFO����
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PanLFO
	jz	I_Play_Pan_Step1	;
	mov	dx,WTD_PanLFO		;
	call	I_Play_LFO		;
	add	ax,dx			;
I_Play_Pan_Step1:			;

;�p���|�b�gEmb����
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_PanEmb
	jz	I_Play_Pan_Step2	;
	mov	cx,WTD_Ctrl_EmbPan	;
	mov	dx,WTD_PanEmb		;
	call	I_Play_Emb		;
	sub	dl,80h			;
	jnc	I_Play_Pan_Step3	;
	mov	dh,0ffh			;dx��dl(�����t)
I_Play_Pan_Step3:			;
	shl	dx,6			;�~2^6
	add	ax,dx			;���Z
I_Play_Pan_Step2:			;

;�p���|�b�g���A7bit�ɕ␳
	inc	ax			;
	shr	ax,7			;ax��{(ax+1)��128}-1
	dec	ax			;�iRange:0�`127�j
	test	ah,ah			;
	jnz	I_Play_Pan_Step5	;
	test	al,080h			;
	jz	I_Play_Pan_Step6	;
I_Play_Pan_Step4:			;if (128=>ax>255){
	mov	al,07fh			;	al = 0x7F;
	jmp	I_Play_Pan_Step6	;}
I_Play_Pan_Step5:			;if (ax>255){
	mov	al,000h			;	al = 0x00;
I_Play_Pan_Step6:			;}

;�p���|�b�g�̏o��
I_Play_Pan_Output:
	cmp	ds:[di].WTD_PanSet,al	;�����Ȃ�΁A�v��Ȃ��B
	jz	I_Play_Pan_End		;
	mov	ds:[di].WTD_PanSet,al	;��������
ifndef	hyoka	;------------------------�����ł͖���
	mov	cl,MIDI_Ctrl_Pan	;
	mov	dx,offset I_Table_CtrlChgB
	call	I_Table_Jump		;�p���|�b�g�Z�b�g
endif	;--------------------------------

I_Play_Pan_End:
	popa				;
	ret				;
;****************************************************************
;*								*
;*			���荞�݃��[�`��			*
;*				���t�E���ʉ����䕔		*
;*				�����E����LFO,Emb����		*
;*				�����A���ʂœ���̃��[�`��	*
;*								*
;****************************************************************
;*	�����W�X�^�g�p						*
;*		ax	�ėp(��Ɍv�Z)				*
;*		ds:bx	���L�\���̃A�h���X	����		*
;*		cx	�ėp(��ɃJ�E���^)			*
;*		dx	���[�N�A�h���X�擪(�ʍ\����)		*
;*		ds:di	�ʍ\����		����		*
;*		ds:bp	���[�N�x�[�X�A�h���X	����		*
;*		es:si	���t�A�h���X		����		*
;*	���Ԃ�l						*
;*		dx	�ψ�(���x��)				*
;****************************************************************
;===============================================================|
;			LFO����	KeyOn				|
;===============================================================|
	even				;�����A�h���X�z�u
I_Play_KeyOn_LFO:				;
	push	ax				;
	push	bp				;���W�X�^�ۑ�

	mov	bp,dx					;

;�J�E���^�[(Rate)�̏�����
	mov	ah,ds:[di + bp].WTD_ChLfo_DecayRate	;DR
	add	ah,ds:[di + bp].WTD_ChLfo_SpeedRate	;SR
	mov	ds:[di + bp].WTD_ChLfo_RateCounter,ah	;

;�J�E���^�[(Count)�̏�����
	mov	ah,ds:[di + bp].WTD_ChLfo_Count		;
	shr	ah,1					;ah = ah / 2
	mov	ds:[di + bp].WTD_ChLfo_CountCounter,ah	;

;���x���̏�����
	xor	ax,ax					;
	mov	ds:[di + bp].WTD_ChLfo_LevelSet,ax	;

	pop	bp					;���W�X�^���A
	pop	ax					;
	ret						;
;===============================================================|
;			Emb����	KeyOn				|
;===============================================================|
	even				;�����A�h���X�z�u
I_Play_KeyOn_Emb:				;
	pusha					;

	xchg	bp,dx				;

	mov	al,ds:[di + bp].WTD_ChEmb_Address	;
	and	al,0f0h					;
	mov	ds:[di + bp].WTD_ChEmb_Address,al	;�ʒu������

	mov	ah,00h				;��ʃA�h���X�̐ݒ�
	test	ds:[di].WTD_FlagControl,cx	;
	jz	I_Play_KeyOn_Emb_Step1		;
	mov	ah,01h				;
I_Play_KeyOn_Emb_Step1:				;

	mov	bx,dx				;bx���x�[�X�A�h���X
	add	bx,WTD_WorkAdd_Emb		;�G���x���[�v�A�h���X
	add	bx,ax				;�f�[�^�A�h���X
	mov	ax,ds:[bx]			;�ǂݍ��݁B
	add	bx,2				;
	mov	dx,ds:[bx]			;

	mov	ds:[di + bp].WTD_ChEmb_Rate,al		;
	cmp	ah,80h					;ah�́A��Βl���Ƃ�B
	jc	I_Play_KeyOn_Emb_Step9			;
	neg	ah					;
I_Play_KeyOn_Emb_Step9:					;
	mov	ds:[di + bp].WTD_ChEmb_Counter,ah	;
	mov	ds:[di + bp].WTD_ChEmb_MaxMin,dl	;
	mov	ds:[di + bp].WTD_ChEmb_LevelSet,dh	;

	popa					;
	ret					;
;===============================================================|
;			Emb����	KeyOff				|
;===============================================================|
	even				;�����A�h���X�z�u
I_Play_KeyOff_Emb:				;
	pusha					;

	xchg	bp,dx				;

	mov	al,ds:[di + bp].WTD_ChEmb_Address	;
	and	al,0f0h					;
	or	al,00cH					;
	mov	ds:[di + bp].WTD_ChEmb_Address,al	;�ʒu������

I_Play_KeyOnOff_Emb:					;

	mov	ah,00h				;��ʃA�h���X�̐ݒ�
	test	ds:[di].WTD_FlagControl,cx	;
	jz	I_Play_KeyOff_Emb_Step1		;
	mov	ah,01h				;
I_Play_KeyOff_Emb_Step1:			;

	mov	bx,dx				;bx���x�[�X�A�h���X
	add	bx,WTD_WorkAdd_Emb		;�G���x���[�v�A�h���X
	add	bx,ax				;�f�[�^�A�h���X
	mov	ax,ds:[bx]			;�ǂݍ��݁B
	add	bx,2				;
	mov	dx,ds:[bx]			;

	mov	ds:[di + bp].WTD_ChEmb_Rate,al		;
	cmp	ah,80h					;ah�́A��Βl���Ƃ�B
	jc	I_Play_KeyOff_Emb_Step9			;
	neg	ah					;
I_Play_KeyOff_Emb_Step9:				;
	mov	ds:[di + bp].WTD_ChEmb_Counter,ah	;
	mov	ds:[di + bp].WTD_ChEmb_MaxMin,dl	;

	popa					;
	ret					;
;===============================================================|
;			Emb����	���C��				|
;===============================================================|
	even				;�����A�h���X�z�u
I_Play_Emb:					;
	push	bp				;
	push	bx				;���W�X�^�ۑ�
	push	ax				;

	xchg	bp,dx				;

;��Speed����
	sub	ds:[di + bp].WTD_ChEmb_Counter,1
	jz	I_Play_Emb_Step1		;
	jmp	I_Play_Emb_End			;
I_Play_Emb_Step1:				;

;���A�h���X�̐ݒ�
	mov	ah,00h				;��ʃA�h���X�̐ݒ�
	test	ds:[di].WTD_FlagControl,cx	;
	jz	I_Play_Emb_Step2		;
	mov	ah,01h				;
I_Play_Emb_Step2:				;ax��Address
	mov	al,ds:[di + bp].WTD_ChEmb_Address
	mov	bx,dx				;bx���x�[�X�A�h���X
	add	bx,WTD_WorkAdd_Emb		;�G���x���[�v�A�h���X
	add	bx,ax				;bx���f�[�^�A�h���X

;��Count�Đݒ�
	mov	ah,ds:[bx].WTD_Emb_AS		;
	cmp	ah,80h				;ah�́A��Βl���Ƃ�B
	jc	I_Play_Emb_Step5		;
	neg	ah				;
I_Play_Emb_Step5:				;
	mov	ds:[di + bp].WTD_ChEmb_Counter,ah

;��Rate����
	mov	al,ds:[di + bp].WTD_ChEmb_LevelSet
	cmp	ds:[bx].WTD_Emb_AS,80h		;��r(�� or ��)
	jc	I_Play_Emb_Step7		;����
	sub	al,ds:[bx].WTD_Emb_AR		;��
	jmp	I_Play_Emb_Step8		;
I_Play_Emb_Step7:				;
	add	al,ds:[bx].WTD_Emb_AR		;��
I_Play_Emb_Step8:				;
	jc	I_Play_Emb_Step3		;

;��Level����
	cmp	ds:[bx].WTD_Emb_AS,80h		;��r(�� or ��)
	jc	I_Play_Emb_Step4		;����
	cmp	al,ds:[bx].WTD_Emb_AL		;�� �ŏ��l�`�F�b�N
	jc	I_Play_Emb_Step3		;
	jmp	I_Play_Emb_StepEnd		;
I_Play_Emb_Step4:				;�� �ő�l�`�F�b�N
	cmp	al,ds:[bx].WTD_Emb_AL		;
	jnc	I_Play_Emb_Step3		;
	jmp	I_Play_Emb_StepEnd		;

;���ő�l�𒴂����ꍇ
I_Play_Emb_Step3:					;
	mov	al,ds:[bx].WTD_Emb_AL			;
	mov	ah,ds:[di + bp].WTD_ChEmb_Address	;
	and	ah,0fh					;
	cmp	ah,08h					;
	jnc	I_Play_Emb_StepEnd			;

	push	ax					;
	add	ds:[di + bp].WTD_ChEmb_Address,04h	;
	add	bx,4					;�A�h���X�̐ݒ�
	mov	ax,ds:[bx]				;�ǂݍ��݁B
	add	bx,2					;
	mov	dx,ds:[bx]				;
	mov	ds:[di + bp].WTD_ChEmb_Rate,al		;
	cmp	ah,80h					;ah�́A��Βl���Ƃ�B
	jc	I_Play_Emb_Step6			;
	neg	ah					;
I_Play_Emb_Step6:					;
	mov	ds:[di + bp].WTD_ChEmb_Counter,ah	;
	mov	ds:[di + bp].WTD_ChEmb_MaxMin,dl	;
	pop	ax					;

I_Play_Emb_StepEnd:				;
	mov	ds:[di + bp].WTD_ChEmb_LevelSet,al

I_Play_Emb_End:					;
	xor	dx,dx				;
	mov	dl,ds:[di + bp].WTD_ChEmb_LevelSet

	pop	ax				;
	pop	bx				;
	pop	bp				;
	ret					;
;===============================================================|
;			LFO����	���C��				|
;===============================================================|
	even				;�����A�h���X�z�u
I_Play_LFO:					;
	push	ax				;
	push	bp				;���W�X�^�ۑ�

	mov	bp,dx				;

;Rate����
	sub	ds:[di + bp].WTD_ChLfo_RateCounter,1	;
	jnz	I_Play_LFO_End				;
	mov	al,ds:[di + bp].WTD_ChLfo_SpeedRate	;
	mov	ds:[di + bp].WTD_ChLfo_RateCounter,al	;

;Level����(dx��Level)
	mov	dx,ds:[di + bp].WTD_ChLfo_LevelSet	;dx��Level
	mov	al,ds:[di + bp].WTD_ChLfo_CountCounter	;
	mov	ah,ds:[di + bp].WTD_ChLfo_Count		;�����Z�̕���
	cmp	al,ah					;
	jz	I_Play_LFO_Add				;
	jc	I_Play_LFO_Add				;
I_Play_LFO_Sub:						;
	sub	dx,ds:[di + bp].WTD_ChLfo_Level		;���Z
	jmp	I_Play_LFO_Step				;
I_Play_LFO_Add:						;
	add	dx,ds:[di + bp].WTD_ChLfo_Level		;���Z
I_Play_LFO_Step:					;
	mov	ds:[di + bp].WTD_ChLfo_LevelSet,dx	;�ۑ�

;Count����
	sub	ds:[di + bp].WTD_ChLfo_CountCounter,1	;
	jnz	I_Play_LFO_End				;
	mov	al,ds:[di + bp].WTD_ChLfo_Count		;�J�E���^�[������
	shl	al,1					;al = al �~ 2
	mov	ds:[di + bp].WTD_ChLfo_CountCounter,al	;

I_Play_LFO_End:
	mov	dx,DS:[di + bp].WTD_ChLfo_LevelSet	;dx��LFO�̃��x��

	pop	bp				;���W�X�^���A
	pop	ax				;
	ret					;
;****************************************************************
;*								*
;*			���ʉ��I�����̐ݒ蕜�A			*
;*								*
;****************************************************************
;*	������							*
;*		ch	�`�����l��				*
;*		ds:bx	System Sturuc				*
;*		ds:di	Part Sturuc				*
;****************************************************************
	even				;�����A�h���X�z�u
I_Effect_Return:				;
	pusha					;���W�X�^�ۑ�
;---------------------------------------------------------------
;�t���O�̃��Z�b�g
	mov	cl,ch				;
	and	cl,07h				;
	inc	cl				;
	mov	ax,0f7ffh			;
	rol	ax,cl				;
	and	ds:[bx].WTD_Sys_Flag,ax		;
;---------------------------------------------------------------
;Channel Mode�̕��A
	mov	ax,ds:[bx].WTD_Sys_Flag		;ah��Channel Mode Flag
	and	ah,0fh				;ah�����̑���Flag��Mask
	shl	ah,4				;
	xchg	ah,al				;
	mov	ah,08h				;ah��08h
	mov	cl,ch				;
	and	cl,07h				;���5bit�}�X�N
	inc	cl				;
	shl	ah,cl				;ah = ah*2^cl (SetBit)
	call	SP_Set_Channel			;

;---------------------------------------------------------------
;�p�[�g��

;�p�[�g����
	mov	cl,20				;20�񃋁[�v
	mov	di,bp				;
	add	di,WTD_WorkAdd_Ch0		;di���\���̃A�h���X
I_Effect_Return_Loop0:				;
	cmp	byte ptr ds:[di].WTD_Channel,ch	;
	jz	I_Effect_Return_Step0		;
	add	di,WTD_WorkChSize		;�\���̂̃T�C�Y��80h(0x80)
	dec	cl				;
	jnz	I_Effect_Return_Loop0		;
	jmp	I_Effect_Return_End		;�����͎g���Ă��Ȃ��B
I_Effect_Return_Step0:

;���A
	and	ch,03h				;�`�����l����񂾂��ɂ���B
;���g��
	mov	ax,ds:[di].WTD_FrectionSet	;���g���̕��A
	call	SP_Set_Frection			;
;����
	mov	al,ds:[di].WTD_ExprPanSet	;���ʂ̕��A
	call	SP_Set_Volume			;
;���F
	push	si				;���F�̕��A
	mov	si,bp				;
	add	si,WTD_WorkAdd_Wave		;
	xor	ax,ax				;
	mov	al,ds:[di].WTD_Voice		;
	shl	ax,4				;
	add	si,ax				;ds:si�����F�̂���A�h���X
	call	SP_Set_Voice			;
	pop	si				;
;�X�E�B�[�v�l(ch=02h)
	cmp	ch,2				;�X�E�B�[�v�l�̕��A
	jnz	I_Effect_Return_Step2		;
	mov	al,ds:[di].WTD_SweepLevel	;
	mov	ah,ds:[di].WTD_SweepTime	;
	call	SP_Set_Sweep			;
I_Effect_Return_Step2:				;
;�m�C�Y���[�h(ch=03h)
	cmp	ch,3				;�m�C�Y���[�h�̕��A
	jnz	I_Effect_Return_Step3		;
	mov	ah,01fh				;
	mov	al,ds:[di].WTD_NoiseMode	;
	or	al,018h				;
	and	al,ah				;
	call	SP_Set_Noise			;
I_Effect_Return_Step3:				;

;---------------------------------------------------------------
I_Effect_Return_End:
	popa					;���W�X�^���A
	ret					;