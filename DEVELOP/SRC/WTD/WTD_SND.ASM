;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Sound Control				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;****************************************************************
;*								*
;*		�v�����������@�r�������@�����o�b�l		*
;*								*
;****************************************************************
;===============================================================|
;			I/O Address				|
;===============================================================|
PCM_Com_Frection	equ	080h			;���g��
PCM_Com_FrectionCh1	equ	PCM_Com_Frection + 0	;���g��
PCM_Com_FrectionCh2	equ	PCM_Com_Frection + 2	;���g��
PCM_Com_FrectionCh3	equ	PCM_Com_Frection + 4	;���g��
PCM_Com_FrectionCh4	equ	PCM_Com_Frection + 6	;���g��
PCM_Com_Volume		equ	088h			;����
PCM_Com_VolumeCh1	equ	PCM_Com_Volume + 0	;����
PCM_Com_VolumeCh2	equ	PCM_Com_Volume + 1	;����
PCM_Com_VolumeCh3	equ	PCM_Com_Volume + 2	;����
PCM_Com_VolumeCh4	equ	PCM_Com_Volume + 3	;����
PCM_Com_PCMVoice	equ	Pcm_Com_VolumeCh2	;PCM Voice
PCM_Com_Sweep		equ	08Ch			;Sweep
PCM_Com_SweepLevel	equ	PCM_Com_Sweep + 0	;Sweep Level
PCM_Com_SweepTime	equ	PCM_Com_Sweep + 1	;Sweep time
PCM_Com_Noise		equ	08Eh			;Noise mode
PCM_Com_VoiceAddress	equ	08Fh			;���FWave table address
PCM_Com_Channel		equ	090h			;Channel mode
PCM_Com_Output		equ	091h			;Output mode
PCM_Com_Random		equ	092h			;Random get
PCM_Com_VolumePCM	equ	094h			;PCM Voice Volume
;===============================================================|
;			Work Address				|
;===============================================================|
PCM_Wrok_Segment	equ	0000h	;FreyaBIOS Work Area
PCM_Wrok_VoiceTable	equ	0180h	;FreyaBIOS Work Area
;===============================================================|
;			�萔					|
;===============================================================|
PCM_Channel_mask	equ	0300h	;�}�X�N
PcmVoiceMode_Set	equ	2020h	;Channel Mode  PCM Voice Mode Set
PcmVoiceMode_Reset	equ	2000h	;Channel Mode  PCM Voice Mode Reset
;===============================================================|
;		�T�E���h�̏�����				|
;===============================================================|
;	������							|
;		����						|
;	�Ԃ�l							|
;		����						|
;	����							|
;		device�̏�����					|
;===============================================================|
	even				;�����A�h���X�z�u
SP_init	proc near			;
	push	ax			;
	push	cx			;
	push	di			;
	push	es			;���W�X�^�ۑ�

	mov	ax,PCM_Wrok_VoiceTable	;
	call	SP_Set_VoiceAdd		;���F�e�[�u���̐ݒ�

	push	PCM_Wrok_Segment	;
	pop	es			;
	mov	di,ax			;es:di��0000h:0180h

	xor	ax,ax			;�e�f�o�C�X�̏�����
	mov	cx,0020h		;64byte�]��
	rep	stosw			;���F�̏�����
	xor	ax,ax			;
	out	PCM_Com_FrectionCh1,ax	;
	out	PCM_Com_FrectionCh2,ax	;
	out	PCM_Com_FrectionCh3,ax	;
	out	PCM_Com_FrectionCh4,ax	;
	out	PCM_Com_VolumeCh1,al	;
	out	PCM_Com_VolumeCh2,al	;
	out	PCM_Com_VolumeCh3,al	;
	out	PCM_Com_VolumeCh4,al	;
	out	PCM_Com_SweepLevel,al	;
	out	PCM_Com_SweepTime,al	;
	out	PCM_Com_Noise,al	;
	mov	al,00fh			;
	out	PCM_Com_Channel,al	;
	mov	al,00fh			;
	out	PCM_Com_Output,al	;
	out	PCM_Com_VolumePCM,al	;

	pop	es			;���W�X�^���A
	pop	di			;
	pop	cx			;
	pop	ax			;
	ret				;
SP_init	endp				;
;===============================================================|
;			���g���̃Z�b�g				|
;===============================================================|
;	������							|
;		CH	Channel					|
;		AX	Frection				|
;	�Ԃ�l							|
;		����						|
;	����							|
;		���g���̃Z�b�g					|
;===============================================================|
	even				;�����A�h���X�z�u
SP_Set_Frection	proc near		;
	push	cx			;
	push	dx			;���W�X�^�ۑ�

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Frection_Step	;���ʉ��p�[�g�H
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Frection_End	;���ʉ����Ă��邩�H

SP_Set_Frection_Step:			;
	mov	dx,PCM_Com_Frection	;dx��I/O Address base
	and	cx,PCM_Channel_mask	;
	shr	cx,7			;cx = ch * 2
	add	dx,cx			;dx��I/O Address
	out	dx,ax			;out(dx),ax

SP_Set_Frection_End:			;
	pop	dx			;���W�X�^���A
	pop	cx			;
	ret				;
SP_Set_Frection	endp			;
;===============================================================|
;			���ʂ̃Z�b�g				|
;===============================================================|
;	������							|
;		CH	Channel					|
;		AL	Volume					|
;	�Ԃ�l							|
;		����						|
;	����							|
;		���ʂ̃Z�b�g					|
;===============================================================|
	even				;�����A�h���X�z�u
SP_Set_Volume	proc near		;
	push	cx			;
	push	dx			;���W�X�^�ۑ�

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Volume_Step	;���ʉ��p�[�g�H
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Volume_End	;���ʉ����Ă��邩�H

SP_Set_Volume_Step:			;
	mov	dx,PCM_Com_Volume	;dx��I/O Address base
	and	cx,PCM_Channel_mask	;
	shr	cx,8			;cx = cl
	add	dx,cx			;dx��I/O Address
	out	dx,al			;out(dx),ax

SP_Set_Volume_End:			;
	pop	dx			;���W�X�^���A
	pop	cx			;
	ret				;
SP_Set_Volume	endp			;
;===============================================================|
;			�X�E�B�[�v�̃Z�b�g			|
;===============================================================|
;	������							|
;		AL	Sweep Level				|
;		AH	Sweep Time				|
;	�Ԃ�l							|
;		����						|
;	����							|
;		�X�E�B�[�v�̐ݒ�				|
;===============================================================|
	even				;�����A�h���X�z�u
SP_Set_Sweep	proc near		;
	push	dx

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Sweep_Step	;���ʉ��p�[�g�H
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Sweep_End	;���ʉ����Ă��邩�H

SP_Set_Sweep_Step:			;
	out	PCM_Com_SweepLevel,al	;�o��
	xchg	al,ah			;
	out	PCM_Com_SweepTime,al	;�o��
	xchg	al,ah			;

SP_Set_Sweep_End:			;
	pop	dx			;
	ret				;
SP_Set_Sweep	endp			;
;===============================================================|
;			�m�C�Y���[�h�̃Z�b�g			|
;===============================================================|
;	������							|
;		AL	Set Data				|
;		AH	Set bit					|
;	�Ԃ�l							|
;		����						|
;	����							|
;		�m�C�Y���[�h�̐ݒ�				|
;===============================================================|
	even				;�����A�h���X�z�u
SP_Set_Noise	proc near		;
	push	dx			;���W�X�^�̕ۑ�

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Noise_Step	;���ʉ��p�[�g�H
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Noise_End	;���ʉ����Ă��邩�H

SP_Set_Noise_Step:			;
	mov	dx,PCM_Com_Noise	;dx��I/O Address
	call	SP_Set_with_mask	;

SP_Set_Noise_End:			;
	pop	dx			;
	ret				;���W�X�^�̕��A
SP_Set_Noise	endp			;
;===============================================================|
;			���F�e�[�u���̃A�h���X			|
;===============================================================|
;	������							|
;		AX	Address					|
;	�Ԃ�l							|
;		����						|
;	����							|
;		���F�e�[�u���̃A�h���X�ݒ�			|
;===============================================================|
	even				;�����A�h���X�z�u
SP_Set_VoiceAdd	proc near		;
	push	ax			;���W�X�^�̕ۑ�
	push	dx			;

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_VoiceAdd_Step	;���ʉ��p�[�g�H
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_VoiceAdd_End	;���ʉ����Ă��邩�H

SP_Set_VoiceAdd_Step:			;
	shr	ax,6			;64Byte�P�ʁB64�Ŋ���B
	out	PCM_Com_VoiceAddress,al	;�o��

SP_Set_VoiceAdd_End:			;
	pop	dx			;
	pop	ax			;���W�X�^�̕��A
	ret				;
SP_Set_VoiceAdd	endp			;
;===============================================================|
;			Channel mode�̐ݒ�			|
;===============================================================|
;	������							|
;		AL	Channel mode				|
;		AH	Set bit					|
;	�Ԃ�l							|
;		����						|
;	����							|
;		�`�����l�����[�h�̐ݒ�				|
;===============================================================|
	even				;�����A�h���X�z�u
SP_Set_Channel	proc near		;
	push	dx			;���W�X�^�̕ۑ�

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Channel_Step	;���ʉ��p�[�g�H
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Channel_End	;���ʉ����Ă��邩�H

SP_Set_Channel_Step:			;
	mov	dx,PCM_Com_Channel	;dx��I/O Address
	call	SP_Set_with_mask	;

SP_Set_Channel_End:			;
	pop	dx			;
	ret				;���W�X�^�̕��A
SP_Set_Channel	endp			;
;===============================================================|
;			Channel mode�̎擾			|
;===============================================================|
;	������							|
;		����						|
;	�Ԃ�l							|
;		AX	Channel mode(ah = 00h)			|
;	����							|
;		�`�����l�����[�h�̎擾				|
;===============================================================|
	even				;�����A�h���X�z�u
SP_Get_Channel	proc near		;
	xor	ax,ax			;
	in	al,PCM_Com_Channel	;����
	ret				;
SP_Get_Channel	endp			;
;===============================================================|
;			Output mode�̐ݒ�			|
;===============================================================|
;	������							|
;		AL	Output mode				|
;		AH	Set bit					|
;	�Ԃ�l							|
;		����						|
;	����							|
;		�o�̓��[�h�̐ݒ�				|
;===============================================================|
	even				;�����A�h���X�z�u
SP_Set_Output	proc near		;
	push	dx			;���W�X�^�̕ۑ�

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Output_Step	;���ʉ��p�[�g�H
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Output_End	;���ʉ����Ă��邩�H

SP_Set_Output_Step:			;
	mov	dx,PCM_Com_Output	;dx��I/O Address
	call	SP_Set_with_mask	;

SP_Set_Output_End:			;
	pop	dx			;
	ret				;���W�X�^�̕��A
SP_Set_Output	endp			;
;===============================================================|
;			Output mode�̎擾			|
;===============================================================|
;	������							|
;		����						|
;	�Ԃ�l							|
;		AX	Output mode (AH = 0)			|
;	����							|
;		�o�̓��[�h�̎擾				|
;===============================================================|
	even				;�����A�h���X�z�u
SP_Get_Output	proc near		;
	xor	ax,ax			;
	in	al,PCM_Com_Output	;����
	ret				;
SP_Get_Output	endp			;
;===============================================================|
;			�^�������̎擾				|
;===============================================================|
;	������							|
;		����						|
;	�Ԃ�l							|
;		AX	�^������				|
;	����							|
;		�^�������̎擾					|
;===============================================================|
	even				;�����A�h���X�z�u
SP_Get_Random	proc near		;
	in	ax,PCM_Com_Random	;����
	ret				;
SP_Get_Random	endp			;
;===============================================================|
;			PCM Volume Volume�̐ݒ�			|
;===============================================================|
;	������							|
;		AL	PCM Voice Volume			|
;		AH	Set bit					|
;	�Ԃ�l							|
;		����						|
;	����							|
;		�o�̓��[�h�̐ݒ�				|
;===============================================================|
	even				;�����A�h���X�z�u
SP_Set_VolumePCM	proc near	;
	push	dx			;���W�X�^�̕ۑ�

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_VolumePCM_Step	;���ʉ��p�[�g�H
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_VolumePCM_End	;���ʉ����Ă��邩�H

SP_Set_VolumePCM_Step:			;
	mov	dx,PCM_Com_VolumePCM	;dx��I/O Address
	call	SP_Set_with_mask	;

SP_Set_VolumePCM_End:			;
	pop	dx			;
	ret				;���W�X�^�̕��A
SP_Set_VolumePCM	endp		;
;===============================================================|
;			PCM Volume Volume�̐ݒ�			|
;===============================================================|
;	������							|
;		AL	PCM Voice Volume			|
;		AH	Set bit					|
;	�Ԃ�l							|
;		����						|
;	����							|
;		�o�̓��[�h�̐ݒ�				|
;===============================================================|
	even				;�����A�h���X�z�u
SP_Get_VolumePCM	proc near	;
	in	al,PCM_Com_VolumePCM	;����
	ret				;
SP_Get_VolumePCM	endp		;
;===============================================================|
;			���F�̐ݒ�				|
;===============================================================|
;	������							|
;		CH	�`�����l��				|
;		DS:SI	���F�f�[�^�̃A�h���X			|
;	�Ԃ�l							|
;		����						|
;	����							|
;		���F��ݒ肷��					|
;===============================================================|
	even				;�����A�h���X�z�u
SP_Set_Voice	proc	near		;
	push	cx			;
	push	dx			;
	push	di			;
	push	si			;
	push	es			;���W�X�^�ۑ�

	test	ds:[di].WTD_FlagControl,WTD_Ctrl_Effect
	jnz	SP_Set_Voice_Step	;���ʉ��p�[�g�H
	mov	cl,ch			;
	inc	cl			;
	mov	dx,00800h		;
	shl	dx,cl			;
	test	ds:[bp].WTD_WorkAdd_System+WTD_Sys_Flag,dx
	jnz	SP_Set_Voice_End	;���ʉ����Ă��邩�H

SP_Set_Voice_Step:			;

	cld				;�C���N�������g���[�h

	push	PCM_Wrok_Segment	;es��0000h
	pop	es			;
	mov	di,PCM_Wrok_VoiceTable	;0180h(���F�e�[�u���A�h���X)
	and	cx,PCM_Channel_mask	;
	shr	cx,4			;
	add	di,cx			;es:di��0000h:0180h + ch �~ 16
	mov	cx,8			;16byte�]������B
	rep	movsw			;�]��

SP_Set_Voice_End:			;
	pop	es			;���W�X�^���A
	pop	si			;
	pop	di			;
	pop	dx
	pop	cx			;
	ret				;
SP_Set_Voice	endp			;
;---------------------------------------------------------------|
;		�}�X�N�𗘗p���Ĉꕔ�o��			|
;---------------------------------------------------------------|
;	dx		i/o address				|
;	al		set data				|
;	ah		set bit					|
;---------------------------------------------------------------|
	even				;�����A�h���X�z�u
SP_Set_with_mask:			;
	push	ax			;
	push	cx			;���W�X�^�ۑ�

	and	al,ah			;�}�X�N
	mov	cl,al			;ch��Set Data
	not	ah			;�}�X�N�f�[�^�̔��]
	in	al,dx			;����
	and	al,ah			;�}�X�N
	or	al,cl			;�_���a
	out	dx,al			;�o��

	pop	cx			;���W�X�^���A
	pop	ax			;
	ret				;
;****************************************************************
;*								*
;*			�l�h�c�h����				*
;*				JIS X 6054-1			*
;*				JIS X 6054-2 �Q��		*
;*								*
;****************************************************************
ifndef	hyoka
;===============================================================|
;			�R�}���h				|
;===============================================================|
MIDI_Com_KeyOff		equ	080h	;
MIDI_Com_KeyOn		equ	090h	;
MIDI_Com_KeyPress	equ	0A0h	;
MIDI_Com_Control	equ	0B0h	;
MIDI_Com_Program	equ	0C0h	;
MIDI_Com_ChPress	equ	0D0h	;
MIDI_Com_PitchBend	equ	0E0h	;
MIDI_Com_Exclucive	equ	0F0h	;
;===============================================================|
;			�R���g���[���R�[�h			|
;===============================================================|
MIDI_Ctrl_MSB		equ	20h	;
MIDI_Ctrl_Bank		equ	00h	;
MIDI_Ctrl_Mod		equ	01h	;
MIDI_Ctrl_Bress		equ	02h	;
MIDI_Ctrl_Foot		equ	04h	;
MIDI_Ctrl_PolTime	equ	05h	;
MIDI_Ctrl_DataEntly	equ	06h	;
MIDI_Ctrl_Volume	equ	07h	;
MIDI_Ctrl_Blance	equ	08h	;
MIDI_Ctrl_Pan		equ	0Ah	;
MIDI_Ctrl_Expression	equ	0Bh	;
MIDI_Ctrl_Effect1	equ	0Ch	;
MIDI_Ctrl_Effect2	equ	0Dh	;
MIDI_Ctrl_Hold		equ	40h	;
MIDI_Ctrl_PolSW		equ	41h	;�|���^�����g�X�C�b�`
MIDI_Ctrl_S		equ	42h	;�\�k�[�e�[�g
MIDI_Ctrl_Soft		equ	43h	;�\�t�g�y�_��
MIDI_Ctrl_Legert	equ	44h	;���K�[�g�X�C�b�`
MIDI_Ctrl_Hold2		equ	45h	;�z�[���h
MIDI_Ctrl_PolControl	equ	54h	;�|���^�����g�R���g���[��
MIDI_Ctrl_Reverv	equ	5Bh	;���o�[�u
MIDI_Ctrl_Tremono	equ	5Ch	;�g�����m
MIDI_Ctrl_Chorus	equ	5Dh	;�R�[���X
MIDI_Ctrl_Delay		equ	5Eh	;�f�B���C
MIDI_Ctrl_F		equ	5Fh	;�t�F�U�[
MIDI_Ctrl_DataInc	equ	60h	;
MIDI_Ctrl_DaraDec	equ	61h	;
MIDI_Ctrl_NonRegLSB	equ	62h	;�f�B���C
MIDI_Ctrl_NonRegMSB	equ	63h	;�t�F�U�[
MIDI_Ctrl_RegLSB	equ	64h	;
MIDI_Ctrl_RegMSB	equ	65h	;
;===============================================================|
;			���W�X�^�[�h�p�����[�^			|
;===============================================================|
;				LSB-MSB
MIDI_Reg_PitchBend	equ	0000h	;�s�b�`�x���h�Z���V�e�B�r�e�B
MIDI_Reg_Fain		equ	0001h	;�t�@�C���`���[��
MIDI_Reg_Cose		equ	0002h	;�R�[�X�`���[��
MIDI_Reg_CProgram	equ	0003h	;�`���[�j���O�v���O�����Z���N�g
MIDI_Reg_CBank		equ	0004h	;�`���[�j���O�o���N�Z���N�g
MIDI_Reg_NULL		equ	7F7Fh	;�k��
;===============================================================|
;			�萔					|
;===============================================================|
MIDI_Channel_mask	equ	0Fh	;�}�X�N
;===============================================================|
;			�G�N�X�N���[�V�u			|
;===============================================================|
	even				;�����A�h���X�z�u
MIDI_Ex_GmReset		db	6,0f0h,7eh,7fh,09h,01h,0f7h
MIDI_Ex_GsReset		db	0
MIDI_Ex_XgReset		db	0
;===============================================================|
;			MIDI Running Status			|
;===============================================================|
;	������							|
;		al	MIDI Command				|
;	�Ԃ�l							|
;		����						|
;	����							|
;		�����j���O�E�X�e�[�^�X���l�������R�}���h���M	|
;===============================================================|
SM_Send_With_Running_Status:		;
	cmp	ds:[bp].WTD_WorkAdd_System+WTD_Sys_RunningStatus,al
	jz	SM_Send_With_Running_Status_e
	call	C_Send			;�R�}���h�̑��M
	mov	ds:[bp].WTD_WorkAdd_System+WTD_Sys_RunningStatus,al
SM_Send_With_Running_Status_e:		;
	ret				;
;===============================================================|
;			MIDI�̏�����				|
;===============================================================|
;	������							|
;		����						|
;	�Ԃ�l							|
;		����						|
;	����							|
;			GM Reset�̑��M				|
;===============================================================|
	even				;�����A�h���X�z�u
SM_init	proc near			;
	push	cx			;
	push	si			;
	push	es			;���W�X�^�ۑ�

	push	cs			;
	pop	es			;ds��cs
	xor	cx,cx			;cx��MIDI_Ex_GmReset
	mov	cl,byte ptr es:[MIDI_Ex_GmReset]
	mov	si,offset MIDI_Ex_GmReset + 1
	call	C_Send_Block		;�u���b�N���M

	;�����j���O�X�e�[�^�X�̏�����
	mov	ds:[bp].WTD_WorkAdd_System+WTD_Sys_RunningStatus,0

	pop	es			;���W�X�^���A
	pop	si			;
	pop	cx			;
	ret				;
SM_init	endp				;
;===============================================================|
;			KeyOff					|
;===============================================================|
;	������							|
;		CH	Track					|
;		AL	Key					|
;	�Ԃ�l							|
;		AH	00h					|
;	����							|
;		KeyOff						|
;===============================================================|
	even				;�����A�h���X�z�u
SM_KeyOff:				;
	xor	ah,ah			;������~(KeyOff)
;===============================================================|
;			KeyOn					|
;===============================================================|
;	������							|
;		CH	Track					|
;		AH	Velocity (0:KeyOff)			|
;		AL	Key					|
;	�Ԃ�l							|
;		����						|
;	����							|
;		KeyOn						|
;===============================================================|
	even				;�����A�h���X�z�u
SM_KeyOn	proc near		;
	push	cx			;���W�X�^�ۑ�

	push	ax			;���W�X�^�ۑ�
	mov	al,MIDI_Com_KeyOn	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;�R�}���h�̑��M
	pop	ax			;���W�X�^���A
	call	C_Send_Word		;�f�[�^�̑��M

	pop	cx			;���W�X�^���A
	ret				;
SM_KeyOn	endp			;
;===============================================================|
;			Poly Key Press				|
;===============================================================|
;	������							|
;		CH	Track					|
;		AH	Pressior				|
;		AL	Key					|
;	�Ԃ�l							|
;		����						|
;	����							|
;		�L�[�v���b�V���[�i�A�t�^�[�^�b�`�j�̑��M	|
;===============================================================|
	even				;�����A�h���X�z�u
SM_KeyPress	proc near		;
	push	cx			;���W�X�^�ۑ�

	push	ax			;���W�X�^�ۑ�
	mov	al,MIDI_Com_KeyPress	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;�R�}���h�̑��M
	pop	ax			;���W�X�^���A
	call	C_Send_Word		;�f�[�^�̑��M

	pop	cx			;���W�X�^���A
	ret				;
SM_KeyPress	endp			;
;===============================================================|
;			Control Change Byte			|
;===============================================================|
;	������							|
;		CH	Track					|
;		CL	Reg.					|
;		AL	Data					|
;	�Ԃ�l							|
;		����						|
;	����							|
;		Control Change					|
;===============================================================|
	even				;�����A�h���X�z�u
SM_ControlByte	proc near		;
	push	ax			;
	push	cx			;���W�X�^�ۑ�

	push	ax			;�ۑ�
	mov	al,MIDI_Com_Control	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;�R�}���h�̑��M
	pop	ax			;���A
	mov	ah,al			;
	mov	al,cl			;
	call	C_Send_Word		;�f�[�^�̑��M

	pop	cx			;���W�X�^���A
	pop	ax			;
	ret				;
SM_ControlByte	endp			;
;===============================================================|
;			Control Change Word			|
;===============================================================|
;	������							|
;		CH	Track					|
;		CL	Reg.					|
;		AX	Data					|
;	�Ԃ�l							|
;		����						|
;	����							|
;		Control Change					|
;===============================================================|
	even				;�����A�h���X�z�u
SM_ControlWord	proc near		;
	push	ax			;
	push	cx			;���W�X�^�ۑ�

	shl	ax,1			;
	shr	al,1			;
	and	ax,07f7fh		;�f�[�^�̕���

	push	ax			;�ۑ�
	mov	al,MIDI_Com_Control	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;�R�}���h�̑��M
	pop	ax			;���A
	push	ax			;
	mov	al,cl			;
	call	C_Send_Word		;���W�X�^(ah)�C�f�[�^�̑��M(ah(LSB))
	pop	ax			;���A
	mov	ah,al			;
	mov	al,cl			;
	add	al,MIDI_Ctrl_MSB	;
	call	C_Send_Word		;���W�X�^(ah)�C�f�[�^�̑��M(al(MSB))

	pop	cx			;���W�X�^���A
	pop	ax			;
	ret				;
SM_ControlWord	endp			;
;===============================================================|
;			Program Change				|
;===============================================================|
;	������							|
;		CH	Track					|
;		AL	Program					|
;	�Ԃ�l							|
;		����						|
;	����							|
;		Program Change					|
;===============================================================|
	even				;�����A�h���X�z�u
SM_Program	proc near		;
	push	ax			;
	push	cx			;���W�X�^�ۑ�

	mov	ah,al			;
	mov	al,MIDI_Com_Program	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;�R�}���h�̑��M
	mov	al,ah			;
	call	C_Send			;�f�[�^�̑��M

	pop	cx			;���W�X�^���A
	pop	ax			;
	ret				;
SM_Program	endp			;
;===============================================================|
;			Program Change with Bank		|
;===============================================================|
;	������							|
;		CH	Track					|
;		AL	Program					|
;		BX	Bank(AH:Msb,AL:Lsb)			|
;	�Ԃ�l							|
;		����						|
;	����							|
;		Program Change��Bank Select�̑��M		|
;===============================================================|
	even				;�����A�h���X�z�u
SM_BankProgram	proc near		;
	push	cx			;���W�X�^�̕ۑ�

	push	ax			;
	mov	cl,MIDI_Ctrl_Bank	;�o���N�Z���N�g
	mov	ax,bx			;�o���N
	shl	al,1			;
	shr	ax,1			;
	and	ax,03fffh		;�f�[�^����
	call	SM_ControlWord		;
	pop	ax			;
	call	SM_Program		;�v���O�����`�F���W
	
	pop	cx			;���W�X�^�̕��A
	ret				;
SM_BankProgram	endp			;
;===============================================================|
;			Poly Ch Press				|
;===============================================================|
;	������							|
;		CH	Track					|
;		AL	Pressior				|
;	�Ԃ�l							|
;		����						|
;	����							|
;		�L�[�v���b�V���[�i�A�t�^�[�^�b�`�j�̑��M	|
;===============================================================|
	even				;�����A�h���X�z�u
SM_ChPress	proc near		;
	push	cx			;
	push	ax			;���W�X�^�ۑ�

	mov	ah,al			;
	mov	al,MIDI_Com_KeyPress	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;�R�}���h�̑��M
	mov	al,ah			;
	call	C_Send			;�f�[�^�̑��M

	pop	ax			;���W�X�^���A
	pop	cx			;
	ret				;
SM_ChPress	endp			;
;===============================================================|
;			Pitch Bend				|
;===============================================================|
;	������							|
;		CH	Track					|
;		AX	Pitch Bend				|
;	�Ԃ�l							|
;		����						|
;	����							|
;		Pitch Bend�̑��M				|
;===============================================================|
	even				;�����A�h���X�z�u
SM_PitchBend	proc near		;
	push	cx			;���W�X�^�ۑ�

	push	ax			;���W�X�^�ۑ�
	mov	al,MIDI_Com_PitchBend	;
	and	ch,MIDI_Channel_mask	;
	or	al,ch			;
	call	SM_Send_With_Running_Status	;�R�}���h�̑��M
	pop	ax			;���W�X�^���A
	push	ax			;���W�X�^�ۑ�
	shl	ax,1			;
	shr	al,1			;
	and	ax,07f7fh		;�f�[�^�̕���
	call	C_Send_Word		;�f�[�^�̑��M
	pop	ax			;���W�X�^���A

	pop	cx			;���W�X�^���A
	ret				;
SM_PitchBend	endp			;
;===============================================================|
endif