;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				Heder Compile Routine			|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;---------------------------------------------------------------|
;		�w�b�_�[�R���p�C��	����			|
;---------------------------------------------------------------|
;	����							|
;		����						|
;	�Ԃ�l							|
;		����						|
;	�g�p���W�X�^						|
;		cx	�R�}���h���J�E���^			|
;		di	c_Head_Com_Adrs�|�C���^			|
;		si	c_Hear_Com_Data�|�C���^			|
;---------------------------------------------------------------|
c_Head_first:				;
	pusha				;���W�X�^�ۑ�

;�w�b�_�[�����ݒ�
	call	c_Head_first_Start	;

;�R�}���h����
;�R�}���h���ʂ̓ǂݍ���
c_Head_first_Loop1:			;cx���R�}���h�̐���
	xor	di,di			;di���ϊ���`�A�h���X�̃|�C���^
	mov	cx,cs:[offset c_Head_Com_Adrs + di]
					;������`�F�b�N�̃J�E���^
;�|�C���^�ǂݍ���
c_Head_first_Loop2:			;
	push	cs:[pMML_File]		;�|�C���^�ۑ�
	add	di,2			;�|�C���^�C���N�������g(Word)
	mov	si,cs:[offset c_Head_Com_Adrs + di]	;si���ϊ���`�A�h���X
;�P�����ǂݍ���
c_Head_first_Loop3:			;
	call	cread			;MML�t�@�C������P�����ǂݍ���
c_Head_first_Step1:			;
;�P�����`�F�b�N�i24h�܂ށj
	mov	al,cs:[si]		;
	inc	si			;
	cmp	al,24h			;�����I���H
	jz	c_Head_first_Step2	;�Ȃ�΁A�������v�ŏ������s�B
	cmp	ah,al			;������v�H
	jz	c_Head_first_Loop3	;�Ȃ�΁A�����`�F�b�N�B
;�����`�F�b�N�ň�v���Ȃ������ꍇ�B
	pop	cs:[pMML_File]		;�|�C���^���A
	sub	cx,1			;�J�E���^�[�E�f�B�N�������g
	jnz	c_Head_first_Loop2	;���̃R�}���h�Ŕ�r
	inc	CS:[pMML_File]		;�|�C���^�E�C���N�������g
	mov	ax,CS:[szMML_File]	;
	cmp	ax,CS:[pMML_File]	;MML�t�@�C���̏I���`�F�b�N
	jnc	c_Head_first_Loop1	;�������r�J�n�B
	jmp	c_Head_first_End	;MML�t�@�C����[EOF]�Ȃ�ΏI��
;-----------------------------------------------------------------------
;�R�}���h�����B
c_Head_first_Step2:			;
	pop	ax			;�|�C���^�̕��A(�l�͖߂����B)
	push	ds			;�Z�O�����g�̕ۑ�

;�|�C���^�����ɖ߂��B
	dec	cs:[pMML_File]		;�|�C���^�E�f�B�N�������g
					;�|�C���^�̓R�}���h�̎��ɂ���B

;�Z�O�����g�̐ݒ�
c_Head_first_Loop4:			;
	mov	al,cs:[si]		;
	inc	si			;
	cmp	al,00h			;�I��
	jnz	c_Head_first_Step9	;
	jmp	c_Head_first_Step99	;
c_Head_first_Step9:			;
	cmp	al,010h			;CS (Program Segment)
	jnz	c_Head_first_Step3	;
	push	cs			;
	pop	ds			;
c_Head_first_Step3:			;
	cmp	al,011h			;DS (WTD Segment)
	jnz	c_Head_first_Step4	;
	mov	ds,cs:[segWTD_File]	;
c_Head_first_Step4:			;
	cmp	al,012h			;ES (MML Segment)
	jnz	c_Head_first_Step5	;
	mov	ds,cs:[segMML_File]	;
c_Head_first_Step5:			;
	cmp	al,0F0h			;Call (Other Program)
	jnz	c_Head_first_Step11	;
	mov	dx,cs:[si]		;
	add	si,2			;
	call	dx			;
	jmp	c_Head_first_Loop4	;
c_Head_first_Step11:			;

;�I�t�Z�b�g�̐ݒ�
	mov	bx,cs:[si]		;bx��Offset Address
	add	si,2			;

;�f�[�^�̏�������
	mov	al,cs:[si]		;
	inc	si			;
	cmp	al,000h			;Byte Write
	jnz	c_Head_first_Step6	;
	call	A2H8R			;
	mov	ds:[bx],ah		;
c_Head_first_Step6:			;
	cmp	al,001h			;Word Write
	jnz	c_Head_first_Step7	;
	call	A2H16R			;
	mov	ds:[bx],ax		;
c_Head_first_Step7:			;
	cmp	al,020h			;Strings Write
	jnz	c_Head_first_Step8	;End of '$'(24h)
;
;	������ꊇ�]��(���Ή�)
;
c_Head_first_Step8:			;

;�R���p�C���������[�v
	jmp	c_Head_first_Loop4	;

;���߃R���p�C�������I��
c_Head_first_Step99:			;
	pop	ds			;�Z�O�����g�̕��A
	jmp	c_Head_first_Loop1	;�������r�J�n�B
;-----------------------------------------------------------------------
;�I��
c_Head_first_End:			;
	popa				;���W�X�^���A
	ret				;
;---------------------------------------------------------------|
;		�����ݒ�					|
;---------------------------------------------------------------|
;	����							|
;		����						|
;	�Ԃ�l							|
;		����						|
;---------------------------------------------------------------|
c_Head_first_Start:
	pusha				;���W�X�^�ۑ�

;�|�C���^�[��擪�ɂ���B
	xor	ax,ax			;
	mov	cs:[pMML_File],ax	;
	mov	cs:[pWTD_File],ax	;�|�C���^�[��擪�ɂ���B

;WTD�t�@�C���̃A�h���X�擾
	mov	ds,cs:[segWTD_File]	;
	xor	bx,bx			;ds:bx��WTD File Segment Address

;�w�b�_�[�����l�̐ݒ�
	mov	word ptr ds:[bx].WTD_Mus_Name + 0	,5457h	;
	mov	word ptr ds:[bx].WTD_Mus_Name + 2	,0044h	;'WTD',00h
	mov	word ptr ds:[bx].WTD_Mus_Version	,0100h	;Version
	mov	word ptr ds:[bx].WTD_Mus_Extr		,0000h	;
	mov	byte ptr ds:[bx].WTD_Mus_Emb		,0	;
	mov	byte ptr ds:[bx].WTD_Mus_Voice		,0	;
	mov	byte ptr ds:[bx].WTD_Mus_Part		,0	;
	mov	byte ptr ds:[bx].WTD_Mus_TimeBase	,48	;
	mov	word ptr ds:[bx].WTD_Mus_ExtrAdr	,0000h	;
	mov	word ptr ds:[bx].WTD_Mus_DataAdr	,0000h	;

;�I��
	popa				;���W�X�^���A
	ret				;Return
;===============================================================|
;			����	����				|
;===============================================================|
c_Head_Com_Adrs:
	dw	11			;����
	dw	offset cHCD_0		;TB
	dw	offset cHCD_1		;PA
	dw	offset cHCD_2		;FX
	dw	offset cHCD_3		;TI
	dw	offset cHCD_4		;FI
	dw	offset cHCD_5		;#timebase
	dw	offset cHCD_6		;#part
	dw	offset cHCD_7		;#version
	dw	offset cHCD_8		;#Switch
	dw	offset cHCD_9		;#title
	dw	offset cHCD_10		;#filename
;---------------------------------------------------------------|
;	�@�R�}���h������					|
;		�Ō��24h�ŏI���				|
;	�A�o�͂���ꏊ						|
;	    00h	�I���						|
;	    1xh	CS	�v���O����				|
;		x	Segment		0:CS / 1:DS(WTD) / 2:ES(MML)
;		word	Offset		Offset Address		|
;		byte	Output Type	00h:Byte / 01:Word	|
;					20h:������+24h		|
;	    F0h	�v���O����					|
;		nnnn	Offset Address				|
;---------------------------------------------------------------
c_Hear_Com_Data:
cHCD_0	db	0dh,0ah,'TB',24h, 011h	;Seg = WTD
	dw	WTD_Mus_TimeBase	;Time base
	db	00h,00h			;Byte , End
cHCD_1	db	0dh,0ah,'PA',24h, 011h	;Seg = WTD
	dw	WTD_Mus_Part		;Music Part count
	db	00h,00h			;Byte , End
cHCD_2	db	0dh,0ah,'FX',24h, 010h	;Seg = CS
	dw	offset cHCD_FlagFx	;FX File Make
	db	00h,00h			;Byte , End
cHCD_3	db	0dh,0ah,'TI',24h, 0f0h	;
	dw	offset cHCD_Set_title	;
	db	00h			;
cHCD_4	db	0dh,0ah,'FI',24h, 0f0h	;
	dw	offset cHCD_Set_filename
	db	00h			;
cHCD_5	db	'#timebase',24h, 11h	;Seg = WTD
	dw	WTD_Mus_TimeBase	;Time base
	db	00h,00h			;Byte , End
cHCD_6	db	'#part',24h, 11h	;Seg = WTD
	dw	WTD_Mus_Part		;Music Part count
	db	00h,00h			;Byte , End
cHCD_7	db	'#version',24h, 11h	;Seg = WTD
	dw	WTD_Mus_Version + 0	;Music Version
	db	00h,11h			;Seg = WTD
	dw	WTD_Mus_Version + 1	;Music Version
	db	00h,00h			;Byte , End
cHCD_8	db	'#switch',24h, 10h	;Seg = CS
	dw	cHCD_FlagFx		;FX File Make
	db	00h,00h			;Byte , End
cHCD_9	db	'#title',24h, 0f0h	;
	dw	offset cHCD_Set_title	;
	db	00h			;
cHCD_10	db	'#filename',24h, 0f0h	;
	dw	offset cHCD_Set_filename
	db	00h			;
;---------------------------------------------------------------
cHCD_Flag	dw	0000h		;�t���O
cHCD_FlagFx	db	00h		;�t���O FX�t�@�C������
cHCD_voice	db	00h		;���F�E�G���x���[�v����
;---------------------------------------------------------------
FX:		db	23h,21h,77h,73h	;#!ws
		db	60	Dup(0FFh)
FX_filename	db	16	dup(0)	;�t�@�C����
FX_title	db	24	dup(0)	;�^�C�g��
FX_fileadr	dd	0FFFFFFFFh	;�t�@�C���̃A�h���X�B
FX_filesize	dd	?		;�t�@�C���T�C�Y
FX_block	dw	?		;�u���b�N��
FX_mode		dw	0006h		;���[�h
FX_data		dd	?		;�N�E����
FX_type		dd	000000000h	;�t�@�C���̎��
FX_resouce	dd	0FFFFFFFFh	;���\�[�X�̈ʒu�B
;---------------------------------------------------------------
cHCD_Set_title:				;
	push	ax			;
	push	bx			;
	push	cx			;���W�X�^�ۑ�

	mov	bx,offset FX_title	;
	mov	cx,24			;

	jmp	cHCD_Set_Loop		;
;---------------------------------------------------------------
cHCD_Set_filename:			;
	push	ax			;
	push	bx			;
	push	cx			;���W�X�^�ۑ�

	mov	bx,offset FX_filename	;
	mov	cx,16			;

cHCD_Set_Loop:				;
	call	cread			;�󔒂̃`�F�b�N
	cmp	ah,21h			;
	jc	cHCD_Set_Loop		;
	dec	cs:[pMML_File]		;�|�C���^�E�f�B�N�������g

cHCD_Set_Str:				;
;���s�`�F�b�N
	call	cread			;ah���f�[�^
	dec	cs:[pMML_File]		;�|�C���^�E�f�B�N�������g
	cmp	ah,0dh			;
	jz	cHCD_Set_Str_End	;

;�]��
	mov	cs:[bx],ah		;�����̓]��
	inc	bx			;

;�������`�F�b�N
	inc	cs:[pMML_File]		;�|�C���^�E�C���N�������g
	dec	cx			;
	cmp	cx,0			;
	jnz	cHCD_Set_Str		;

cHCD_Set_Str_End:			;
	pop	cx			;���W�X�^���A
	pop	bx			;
	pop	ax			;
	ret				;
;---------------------------------------------------------------|
;		�w�b�_�[�R���p�C��	���			|
;---------------------------------------------------------------|
;	����							|
;		����						|
;	�Ԃ�l							|
;		����						|
;	�g�p���W�X�^						|
;		cx	�R�}���h���J�E���^			|
;		di	c_Head_Com_Adrs�|�C���^			|
;		si	c_Hear_Com_Data�|�C���^			|
;---------------------------------------------------------------|
;��������
c_Head_Version	db	'This Music Data is version $'
c_Head_Point	db	'.$'
c_Head_CR	db	0dh,0ah,24h
c_Head_Size	db	'Filesize = '     ,24h
c_Head_Byte	db	' [Byte]   ( $'
c_Head_Block	db	' [Block] )',0dh,0ah,24h
;---------------------------------------------------------------
c_Head_end:				;
	pusha				;���W�X�^�ۑ�
	push	ds
	push	es

	push	ds			;
	pop	es			;es��ds
	push	cs			;
	pop	ds			;ds��cs
;---------------------------------------------------------------
;�o�[�W�������̕\��

	xor	bx,bx			;ds:bx��WTD File Segment Address

	mov	dx,offset c_Head_Version
	mov	ah,09h			;
	int	21h			;"This Music Data is Version "

	mov	ax,word ptr es:[bx].WTD_Mus_Version

	push	ax			;
	xchg	ah,al			;
	call	HEX2ASC8		;
	mov	ah,09h			;
	int	21h			;���l�̕\��
	mov	dx,offset c_Head_Point	;
	mov	ah,09h			;
	int	21h			;�u�_�v�̕\��
	pop	ax			;
	call	HEX2ASC8		;
	mov	ah,09h			;
	int	21h			;���l�̕\��
	mov	dx,offset c_Head_CR	;
	mov	ah,09h			;
	int	21h			;���s�̕\��

;---------------------------------------------------------------
;FX�`���w�b�_�[�̍쐬
;��filename,title�͍쐬�ς݁B

;���t�@�C���T�C�Y�E�u���b�N��
	mov	dx,offset c_Head_Size	;
	mov	ah,09h			;
	int	21h			;"Filesize = "�̕\��

	xor	dx,dx			;
	mov	ax,cs:[pWTD_File]	;
	dec	ax			;dx:ax���t�@�C���T�C�Y�B
	mov	word ptr cs:[FX_filesize + 0],ax
	mov	word ptr cs:[FX_filesize + 2],dx

	push	ax			;
	push	dx			;
	call	HEX2ASC16		;
	mov	ah,09h			;
	int	21h			;���l�̕\��
	mov	dx,offset c_Head_Byte	;
	mov	ah,09h			;
	int	21h			;" [Byte]"�̕\��
	pop	dx			;
	pop	ax			;

	mov	cx,128			;
	div	cx			;128�Ŋ���B
	cmp	dx,0			;
	jz	c_Head_end_Step0	;�]�肪��������A
	inc	ax			;���ɂP�𑫂��B
c_Head_end_Step0:			;
	mov	word ptr cs:[FX_block],ax

	call	HEX2ASC16		;���l�̕\��
	mov	ah,09h			;
	int	21h			;
	mov	dx,offset c_Head_Block	;
	mov	ah,09h			;
	int	21h			;" [Byte]"�̕\��

;---------------------------------------------------------------
;���N�E���Ԃ̍쐬
;	bit 25-31	�N-2000	(7)
;	bit 21-24	��	(4)
;	bit 16-20	��	(5)
;	bit 11-15	��	(5)
;	bit  5-10	��	(6)
;	bit  0- 4	�b/2	(5)

	mov	ah,02ah			;
	int	21h			;���t�̎擾
	xor	ax,ax			;

	sub	cx,2000			;�N-2000
	and	cx,007Fh		;
	or	ax,cx			;

	shl	ax,4			;��
	mov	bx,dx			;
	xchg	bh,bl			;
	and	bx,000fh		;
	or	ax,bx			;

	shl	ax,5			;��
	and	dx,001fh		;
	or	ax,dx			;

	push	ax			;���t�̕ۑ�

	mov	ah,02ch			;
	int	21h			;���Ԃ̎擾
	xor	ax,ax			;

	mov	bx,cx			;��
	xchg	bh,bl			;
	and	bx,001fh		;
	or	ax,bx			;

	shl	ax,6			;��
	and	cx,003fh		;
	or	ax,cx			;

	shl	ax,5			;�b/2
	xchg	dh,dl			;
	shr	dx,1			;
	and	dx,001fh		;
	or	ax,dx			;

	pop	dx			;���t�̕��A

	mov	word ptr cs:[FX_data + 0],ax
	mov	word ptr cs:[FX_data + 2],dx

;---------------------------------------------------------------
;�I��
	pop	es			;���W�X�^���A
	pop	ds			;
	popa				;
	ret				;Return