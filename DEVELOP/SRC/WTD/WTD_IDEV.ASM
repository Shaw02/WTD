;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Interrupt device accsess program	|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;****************************************************************
;*								*
;*			���荞�݃��[�`��			*
;*				���t�E���ʉ����䕔		*
;*				�f�o�C�X�o��			*
;*								*
;****************************************************************
;===============================================================|
;		�f�o�C�X�ɂ�郋�[�`���̕���			|
;===============================================================|
;	�����W�X�^�g�p						|
;		ax	�ėp�i��Ɍv�Z�p�j			|
;		ds:bx	���L�\���̃A�h���X		����	|
;		cx	�ėp					|
;		dx	�W�����v�e�[�u���̃A�h���X	����	|
;		ds:di	�ʍ\����			����	|
;		ds:bp	���[�N�x�[�X�A�h���X		����	|
;		es;si	���t�A�h���X			����	|
;								|
;	���[�`���ɓn������					|
;		cl	�ėp�i��ɃJ�E���^�p�j			|
;		ch	���݂̃`�����l��			|
;		dx						|
;		ss:[bp + 04h]	�Ăяo������CX���W�X�^�B	|
;		ss:[bp + 06h]	�Ăяo������DX���W�X�^�B	|
;		ss:[bp + 08h]	�Ăяo������BP���W�X�^�B	|
;		�@DX���W�X�^���g���ꍇ�A���[�`���ňȉ��̏������K�v�B
;		push	bp					|
;		mov	bp,sp					|
;		�i�����j					|
;		pop	bp					|
;		ret						|
;								|
;	�f�o�C�X�A�N�Z�X���ŁAbp���W�X�^���g�p���Ă���̂ŁA	|
;	���ӂ���B						|
;								|
;===============================================================|
	even				;�����A�h���X�z�u
I_Table_Jump:				;
	push	bp			;
	push	dx			;
	push	cx			;
	push	bx			;
	push	ax			;���W�X�^�ۑ�

;---------------------------------------------------------------

;�W�����v�e�[�u���A�h���X�̐ݒ�
	mov	bx,dx			;bx��dx(Jump table address)
;�`�����l���E�������̎擾
	xor	ax,ax			;
	mov	al,ds:[di].WTD_Channel	;ax��Channel

;�`�����l���Ɖ������̌ʉ�
;ch���`�����l�����
	mov	ch,al			;
	and	ch,0fh			;ch���`�����l��(������񖳂�)
;ax���������~�Q
	shr	ax,6			;ax�������^�C�v(���_��)
	not	ax			;ax�����_���ɂ���B
	and	ax,02h			;ax�������^�C�v�ȊO�������B
;�W�����v�A�h���X�i�[�A�h���X�̎擾
	add	bx,ax			;bx�������^�C�v�����Z

;�W�����v�A�h���X�̎擾
	mov	dx,word ptr cs:[bx]	;

;---------------------------------------------------------------

;�s�K�v�ȃ��W�X�^�̕��A
	pop	ax			;���W�X�^���A
	pop	bx			;
;���[�`���Ăяo��
	call	dx			;�Ăяo��
;�c�������W�X�^�̕��A
	pop	cx			;
	pop	dx			;�c��̃��W�X�^���A
	pop	bp			;
;�I��
	ret				;
;===============================================================|
;			KeyOn					|
;===============================================================|
;	����							|
;		al	�L�[�E�R�[�h				|
;	�Ԓl							|
;		����						|
;	����							|
;		�f�o�C�X��KeyOn����B				|
;		�x���̏ꍇ�́A���̃��[�`�����Ă΂Ȃ��B		|
;===============================================================|
	even				;�����A�h���X�z�u
;-------------[	  Table   ]-------------
I_Table_KeyOn:				
	dw	I_SP_KeyOn		
	dw	I_SM_KeyOn		
;-------------[	WS����PCM ]-------------
	even				;�����A�h���X�z�u
I_SP_KeyOn:				;
	push	cx			;
	push	bx			;
	push	ax			;���W�X�^�ۑ�

	mov	ds:[di].WTD_KeySet,al	;����̃f�[�^����������

;�L�[�R�[�h�̕����i�L�[�C�I�N�^�[�u�j
	xor	ah,ah				;ax��KeyCode
	mov	cl,12				;
	idiv	cl				;ah��Key(�]) / al��Octave(��)
;�I�N�^�[�u�̏�������
	dec	al				;�I�N�^�[�u�␳(Drv�l)
	mov	ds:[di].WTD_OctaveSet,al	;�I�N�^�[�u��������
;�e�[�u���ǂݍ��݁i�x���h�ϊ��j
	mov	al,ah				;
	mov	ah,0				;ax��Key
	shl	ax,1				;
	mov	bx,offset I_Frection_Table	;
	add	bx,ax				;
	mov	ax,cs:[bx]			;ax��Pitch Bend
;�x���h�̏�������
	mov	ds:[di].WTD_Frection,ax		;Bend�Ƃ��ď���
;�i�n�[�h�E�F�A��KeyOn�͖����B�j

	pop	ax			;���W�X�^���A
	pop	bx			;
	pop	cx			;
	ret				;
;-------------[	�O��MIDI  ]-------------
	even				;�����A�h���X�z�u
I_SM_KeyOn:				;
ifndef	hyoka	;------------------------�����ł͖���
	push	bx			;
	push	ax			;���W�X�^�ۑ�

;���ۂɏo�͂����I�N�^�[�u�B
;�iMIDI����ł͗v��Ȃ����ǁA�r���A�[�p�Ɍv�Z���Ă����B�j
;���W�X�^�ۑ�
	push	ax				;
	push	cx				;
;�L�[�R�[�h�̕����i�L�[�C�I�N�^�[�u�j
	xor	ah,ah				;ax��KeyCode
	mov	cl,12				;
	idiv	cl				;ah��Key(�]) / al��Octave(��)
;�I�N�^�[�u�̏�������
	dec	al				;
	mov	ds:[di].WTD_OctaveSet,al	;�I�N�^�[�u��������
;���W�X�^���A
	pop	cx				;
	pop	ax				;

;�o�b�t�@��������
	xor	bx,bx				;
	mov	bl,ds:[di].WTD_KeySetPointer	;�|�C���^�ǂݍ���
	mov	al,ds:[di+bx].WTD_KeySet	;�o�b�t�@�ǂݍ���
	cmp	al,0ffh				;���e�͋�H
	jz	I_SM_KeyOn_ChkEnd		;��łȂ�������
	call	SM_KeyOff			;��Ƃ������Ƃɂ���B
I_SM_KeyOn_ChkEnd:				;
	pop	ax				;
	push	ax				;ax�������𕜋A
	mov	ds:[di+bx].WTD_KeySet,al	;����̃f�[�^����������
	inc	bx				;�|�C���^�C���N�������g
	and	bx,07h				;
	mov	ds:[di].WTD_KeySetPointer,bl	;�|�C���^�ۑ�

;���M
I_SM_KeyOn_Out:
	mov	ah,ds:[di].WTD_Velocity	;ah���x���V�e�B�[
	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Acsent
	jz	I_SM_KeyOn_DeviceOut	;�����A�N�Z���g��������A����p�B
	mov	ah,ds:[di].WTD_AcsentVelocity
	and	ds:[di].WTD_FlagControl,WTD_Ctrl_AcsentR
I_SM_KeyOn_DeviceOut:			;
	call	SM_KeyOn		;�f�o�C�X�o�́B

	pop	ax			;���W�X�^���A
	pop	bx			;
endif	;--------------------------------
	ret				;
;===============================================================|
;			KeyOff					|
;===============================================================|
;	����							|
;		����						|
;	�Ԓl							|
;		����						|
;	����							|
;		�f�o�C�X��KeyOff����B				|
;===============================================================|
	even				;�����A�h���X�z�u
;-------------[	  Table   ]-------------
I_Table_KeyOff:				
	dw	I_SP_KeyOff		
	dw	I_SM_KeyOff		
;-------------[	WS����PCM ]-------------
	even				;�����A�h���X�z�u
I_SP_KeyOff:				;
	mov	ds:[di].WTD_KeySet,0ffh	;��f�[�^�̏�������
	ret				;
;-------------[	�O��MIDI  ]-------------
	even				;�����A�h���X�z�u
I_SM_KeyOff:				;
ifndef	hyoka	;------------------------�����ł͖���
	push	bx			;
	push	ax			;���W�X�^�ۑ�

;�o�b�t�@�ɏ�����Ă�����e��S��keyOff���A��ɂ���B
	mov	cl,8				;�W�񃋁[�v
	xor	bx,bx				;

I_SM_KeyOff_Loop:				;
	mov	al,ds:[di+bx].WTD_KeySet	;�o�b�t�@�ǂݍ���
	mov	ds:[di+bx].WTD_KeySet,0ffh	;��f�[�^�̏�������
	inc	bx				;
	cmp	al,0ffh				;
	jz	I_SM_KeyOff_Step1		;
	call	SM_KeyOff			;KeyOff�̑��M
I_SM_KeyOff_Step1:
	dec	cl				;�J�E���^�f�B�N�������g
	jnz	I_SM_KeyOff_Loop		;
;
;	�@�|�C���^�͖ʓ|������߂��Ȃ��B
;	�ǂ����A�N���N������Ă��邩��A�������Ԃ����ʁB
;
	pop	ax			;���W�X�^���A
	pop	bx			;
endif	;--------------------------------
	ret				;
;===============================================================|
;			Volume					|
;===============================================================|
;	����							|
;		al���{�����[��					|
;	�Ԓl							|
;		����						|
;	����							|
;		���ʂ��o�͂���B				|
;===============================================================|
	even				;�����A�h���X�z�u
;-------------[	  Table   ]-------------
I_Table_Volume:				
	dw	I_SP_Volume		
	dw	I_SM_Volume		
;-------------[	WS����PCM ]-------------
	even				;�����A�h���X�z�u
I_SP_Volume:				;
;���ʕۑ��B
	mov	ds:[di].WTD_ExprSet,al	;
;�p���|�b�g�ƍ�������̂ŁA���������l���`�F�b�N����B

;���W�X�^�ۑ�
	push	dx			;
	push	bx			;
	push	cx			;
	push	si				;

;���ʂ̎�����[dB]�ɕϊ�
;	shl	al,1			;(Range:0�`255)
;	and	ax,00ffh			;
;	mov	bx,offset I_Volume_Table	;
;	mov	si,ax				;
;	mov	al,cs:[bx + si]		;cl��int(256*(log(al+1)/log(257)))
	mov	cl,al			;

;�p���|�b�g�ǂݍ���
	mov	al,ds:[di].WTD_PanSet		;
	shl	al,1				;
	mov	ah,0ffh				;al�����̃��x��
	sub	ah,al				;ah���E�̃��x��
;�p���|�b�g�̎�����[dB]�ɕϊ�
	mov	bx,offset I_Volume_Table	;
	mov	si,ax				;
	and	si,00ffh			;
	mov	al,cs:[bx + si]			;
	xchg	al,ah				;ch�����̃��x��
	mov	bx,offset I_Volume_Table	;
	mov	si,ax				;
	and	si,00ffh			;
	mov	al,cs:[bx + si]			;cl���E�̃��x��
	xchg	ax,cx				;al������

;�p���|�b�g�̍���
;�����Z
	push	ax			;
	xor	ah,ah			;
	inc	ax			;ax������+1
	push	cx			;
	mov	cl,ch			;
	xor	ch,ch			;
	inc	cx			;cx�����̃��x��+1
	mul	cx			;
	dec	ax			;
	pop	cx			;
	mov	ch,ah			;ch�����̉���
	pop	ax			;
;�E���Z
	xor	ah,ah			;
	inc	ax			;ax������+1
	push	cx			;
	xor	ch,ch			;
	inc	cx			;cx���E�̃��x��+1
	mul	cx			;
	dec	ax			;
	pop	cx			;
	mov	cl,ah			;cl���E�̉���
;����
	and	ch,0f0h			;���4bit�̂�
	and	cl,0f0h			;���4bit�̂�
	shr	cl,4			;
	or	ch,cl			;
	mov	al,ch			;al�����E�̉���

	pop	si			;
	pop	cx			;�`�����l������߂��B

	cmp	ds:[di].WTD_ExprPanSet,al	;
	jz	I_SP_Volume_End			;�O��Ɠ����������炢��Ȃ��B

	mov	ds:[di].WTD_ExprPanSet,al	;
	call	SP_Set_Volume			;

I_SP_Volume_End:
	pop	bx			;
	pop	dx			;
	ret				;
;-------------[	�O��MIDI  ]-------------
	even				;�����A�h���X�z�u
I_SM_Volume:				;
ifndef	hyoka	;------------------------�����ł͖���
	shr	al,1			;al��2 (Range:0�`127)
	cmp	ds:[di].WTD_ExprSet,al	;
	jz	I_SM_Volume_End		;�O��Ɠ����������炢��Ȃ��B

	push	cx			;���W�X�^�ۑ�
	mov	ds:[di].WTD_ExprSet,al	;
	mov	cl,MIDI_Ctrl_Expression	;
	call	SM_ControlByte		;
	pop	cx			;���W�X�^���A

I_SM_Volume_End:			;
endif	;--------------------------------
	ret				;
;===============================================================|
;			Frection(Pitch�@Bend)			|
;===============================================================|
;	����							|
;		ax��Bend(Frection)				|
;	�Ԓl							|
;		����						|
;	����							|
;		���g���^�s�b�`�x���h���o�͂���B		|
;===============================================================|
	even				;�����A�h���X�z�u
;-------------[	  Table   ]-------------
I_Table_Frection:			
	dw	I_SP_Frection		
	dw	I_SM_Frection		
;-------------[	WS����PCM ]-------------
	even				;�����A�h���X�z�u
;DeviceOut = 2048 - (Table / 2^(3 + Octave))
I_SP_Frection:				;
	push	cx			;
	push	ax			;���W�X�^�ۑ�

;�I�N�^�[�u����
	mov	cl,ds:[di].WTD_OctaveSet
	add	cl,3			;
	shr	ax,cl			;
	mov	bx,ax			;
	mov	ax,2048			;
	sub	ax,bx			;
	jnc	I_SP_Frection_Step	;
	xor	ax,ax			;�I�[�o�[�t���[������A�O�ɂ���B
I_SP_Frection_Step:			;

	cmp	ds:[di].WTD_FrectionSet,ax	;�O��Ɠ����������炢��Ȃ��B
	jz	I_SP_Frection_End		;

	mov	ds:[di].WTD_FrectionSet,ax	;
	call	SP_Set_Frection			;���g���̐ݒ�

I_SP_Frection_End:			;
	pop	ax			;���W�X�^���A
	pop	cx			;
	ret				;
;-------------[	�O��MIDI  ]-------------
	even				;�����A�h���X�z�u
I_SM_Frection:				;
ifndef	hyoka	;------------------------�����ł͖���
	cmp	ds:[di].WTD_BendSet,ax	;�O��Ɠ����������炢��Ȃ��B
	jz	I_SM_Frection_End	;

	mov	ds:[di].WTD_BendSet,ax	;
	call	SM_PitchBend		;
I_SM_Frection_End:			;
endif	;--------------------------------
	ret				;
;===============================================================|
;			Voice & Program				|
;===============================================================|
;	����							|
;		al�����F�ԍ�					|
;	�Ԓl							|
;		����						|
;	����							|
;		���F��]������B				|
;===============================================================|
	even				;�����A�h���X�z�u
;-------------[	  Table   ]-------------
I_Table_Voice:				
	dw	I_SP_Voice		
	dw	I_SM_Voice		
;-------------[	WS����PCM ]-------------
	even				;�����A�h���X�z�u
I_SP_Voice:				;
	cmp	ds:[di].WTD_Voice,al	;�O��Ɠ����������炢��Ȃ��B
	jz	I_SP_Voice_End		;

	push	ax			;
	push	si			;���W�X�^�ۑ�

	mov	ds:[di].WTD_Voice,al	;���F�ԍ��ۑ�
	xor	ah,ah			;
	shl	ax,4			;ax��al�~16
	mov	si,bp			;
	add	si,WTD_WorkAdd_Wave	;
	add	si,ax			;ds:si�����F�̂���A�h���X

	call	SP_Set_Voice		;���F�Z�b�g

	pop	si			;���W�X�^���A
	pop	ax			;
I_SP_Voice_End:				;
	ret				;
;-------------[	�O��MIDI  ]-------------
	even				;�����A�h���X�z�u
I_SM_Voice:				;
ifndef	hyoka	;------------------------�����ł͖���
	cmp	ds:[di].WTD_Program,al	;�O��Ɠ����������炢��Ȃ��B
	jz	I_SM_Voice_End		;

	mov	ds:[di].WTD_Program,al	;
	call	SM_Program		;
I_SM_Voice_End:				;
endif	;-------------------------------
	ret				;
;===============================================================|
;			Poly Key Pressior			|
;===============================================================|
;	����							|
;		al��Key						|
;		ah��pressior					|
;	�Ԓl							|
;		����						|
;	����							|
;		�|���t�H�j�b�N�@�L�[�@�v���b�V���[�̑��M	|
;===============================================================|
	even				;�����A�h���X�z�u
;-------------[	  Table   ]-------------
I_Table_PolyKeyPress:			
	dw	I_SP_PolyKeyPress	
	dw	I_SM_PolyKeyPress	
;-------------[	WS����PCM ]-------------
	even				;�����A�h���X�z�u
I_SP_PolyKeyPress:			;
;	��������			;
	ret				;
;-------------[	�O��MIDI  ]-------------
	even				;�����A�h���X�z�u
I_SM_PolyKeyPress:			;
ifndef	hyoka	;------------------------�����ł͖���
	call	SM_KeyPress		;
endif	;--------------------------------
	ret				;
;===============================================================|
;			Poly Channel Pressior			|
;===============================================================|
;	����							|
;		al��pressior					|
;	�Ԓl							|
;		����						|
;	����							|
;		�|���t�H�j�b�N�@�L�[�@�v���b�V���[�̑��M	|
;===============================================================|
	even				;�����A�h���X�z�u
;-------------[	  Table   ]-------------
I_Table_PolyChPress:			
	dw	I_SP_PolyChPress	
	dw	I_SM_PolyChPress	
;-------------[	WS����PCM ]-------------
	even				;�����A�h���X�z�u
I_SP_PolyChPress:			;
;	��������			;
	ret				;
;-------------[	�O��MIDI  ]-------------
	even				;�����A�h���X�z�u
I_SM_PolyChPress:			;
ifndef	hyoka	;------------------------�����ł͖���
	call	SM_ChPress		;
endif	;--------------------------------
	ret				;
;===============================================================|
;			Control Change Byte			|
;===============================================================|
;	����							|
;		al���f�[�^					|
;		cl���@�\�ԍ�					|
;	�Ԓl							|
;		����						|
;	����							|
;		�R���g���[���`�F���W�̑��M			|
;===============================================================|
	even				;�����A�h���X�z�u
;-------------[	  Table   ]-------------
I_Table_CtrlChgB:			
	dw	I_SP_CtrlChgB		
	dw	I_SM_CtrlChgB		
;-------------[	WS����PCM ]-------------
	even				;�����A�h���X�z�u
I_SP_CtrlChgB:				;
;	��������			;
	ret				;
;-------------[	�O��MIDI  ]-------------
	even				;�����A�h���X�z�u
I_SM_CtrlChgB:				;
ifndef	hyoka	;------------------------�����ł͖���
	push	bp			;
	mov	bp,sp			;
	push	cx			;���W�X�^�ۑ�

	mov	cl,[bp + 04h]		;
	mov	bp,[bp + 08h]		;bp���W�X�^�̕��A
	call	SM_ControlByte		;

	pop	cx			;���W�X�^���A
	pop	bp			;
endif	;--------------------------------
	ret				;
;===============================================================|
;			Control Change Word			|
;===============================================================|
;	����							|
;		ax���f�[�^					|
;		cl���@�\�ԍ�					|
;	�Ԓl							|
;		����						|
;	����							|
;		�R���g���[���`�F���W�̑��M			|
;===============================================================|
	even				;�����A�h���X�z�u
;-------------[	  Table   ]-------------
I_Table_CtrlChgW:			
	dw	I_SP_CtrlChgW		
	dw	I_SM_CtrlChgW		
;-------------[	WS����PCM ]-------------
	even				;�����A�h���X�z�u
I_SP_CtrlChgW:				;
;	��������			;
	ret				;
;-------------[	�O��MIDI  ]-------------
	even				;�����A�h���X�z�u
I_SM_CtrlChgW:				;
ifndef	hyoka	;------------------------�����ł͖���
	push	bp			;
	mov	bp,sp			;
	push	cx			;���W�X�^�ۑ�

	mov	cl,[bp + 04h]		;
	mov	bp,[bp + 08h]		;bp���W�X�^�̕��A
	call	SM_ControlWord		;

	pop	cx			;���W�X�^���A
	pop	bp			;
endif	;--------------------------------
	ret				;
;===============================================================|
;	WS����PCM Channel���[�h	/ MIDI Dumper Switch		|
;===============================================================|
;	����							|
;		al�����[�h�X�C�b�`				|
;	�Ԓl							|
;		����						|
;	����							|
;		���[�h						|
;===============================================================|
	even				;�����A�h���X�z�u
;-------------[	  Table   ]-------------
I_Table_Mode:				
	dw	I_SP_Mode		
	dw	I_SM_Mode		
;-------------[	WS����PCM ]-------------
	even				;�����A�h���X�z�u
I_SP_Mode:				;
	push	cx			;
	push	ax			;���W�X�^�ۑ�

	and	ax,0001h		;and	al,01h
	or	ax,0100h		;set	0,ah
	mov	cl,ch			;
	add	cl,4			;
	shl	ax,cl			;

	call	SP_Set_Channel		;

	pop	ax			;���W�X�^���A
	pop	cx			;
	ret				;
;-------------[	�O��MIDI  ]-------------
	even				;�����A�h���X�z�u
I_SM_Mode:				;
ifndef	hyoka	;------------------------�����ł͖���
	push	cx			;���W�X�^�ۑ�

	shl	al,6			;���l��64�{����B
	and	al,40h			;0��64�����B
	mov	cl,MIDI_Ctrl_Hold	;
	call	SM_ControlWord		;�_���p�[�X�C�b�`�̑��M

	pop	cx			;���W�X�^���A
endif	;--------------------------------
	ret				;