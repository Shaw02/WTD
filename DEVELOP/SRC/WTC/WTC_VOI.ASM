;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				Voice Compile Routine			|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
c_Voice:
	pusha				;���W�X�^�ۑ�

;�R���p�C�����
	call	c_Voice_Pcm_first	;
	call	c_Voice_Emb_first	;

;�I��
	popa				;���W�X�^���A
	ret				;�I��
;---------------------------------------------------------------|
;		���F�R���p�C��					|
;---------------------------------------------------------------|
;	����							|
;		����						|
;	�Ԃ�l							|
;		����						|
;	�g�p���W�X�^						|
;		cx	�R�}���h���J�E���^			|
;		di	c_Voice_Pcm_Adrs�|�C���^		|
;		si	c_Voice_Pcm_Data�|�C���^		|
;---------------------------------------------------------------|
c_Voice_Pcm_first:				;
	pusha				;���W�X�^�ۑ�

;�w�b�_�[�����ݒ�
	call	c_Voice_Pcm_first_Start	;

;�R�}���h����
;�R�}���h���ʂ̓ǂݍ���
c_Voice_Pcm_first_Loop1:		;cx���R�}���h�̐���
	xor	di,di			;di���ϊ���`�A�h���X�̃|�C���^
	mov	cx,cs:[offset c_Voice_Pcm_Adrs + di]
					;������`�F�b�N�̃J�E���^
;�|�C���^�ǂݍ���
c_Voice_Pcm_first_Loop2:		;
	push	cs:[pMML_File]		;�|�C���^�ۑ�
	add	di,2			;�|�C���^�C���N�������g(Word)
	mov	si,cs:[offset c_Voice_Pcm_Adrs + di]	;si���ϊ���`�A�h���X
;�P�����ǂݍ���
c_Voice_Pcm_first_Loop3:		;
	call	cread			;MML�t�@�C������P�����ǂݍ���
c_Voice_Pcm_first_Step1:		;
;�P�����`�F�b�N�i24h�܂ށj
	mov	al,cs:[si]		;
	inc	si			;
	cmp	al,24h			;�����I���H
	jz	c_Voice_Pcm_first_Step2	;�Ȃ�΁A�������v�ŏ������s�B
	cmp	ah,al			;������v�H
	jz	c_Voice_Pcm_first_Loop3	;�Ȃ�΁A�����`�F�b�N�B
;�����`�F�b�N�ň�v���Ȃ������ꍇ�B
	pop	cs:[pMML_File]		;�|�C���^���A
	sub	cx,1			;�J�E���^�[�E�f�B�N�������g
	jnz	c_Voice_Pcm_first_Loop2	;���̃R�}���h�Ŕ�r
	inc	CS:[pMML_File]		;�|�C���^�E�C���N�������g
	mov	ax,CS:[szMML_File]	;
	cmp	ax,CS:[pMML_File]	;MML�t�@�C���̏I���`�F�b�N
	jnc	c_Voice_Pcm_first_Loop1	;�������r�J�n�B
	jmp	c_Voice_Pcm_first_End	;MML�t�@�C����[EOF]�Ȃ�ΏI��
;-----------------------------------------------------------------------
;�R�}���h�����B
c_Voice_Pcm_first_Step2:			;
	pop	ax			;�|�C���^�̕��A(�l�͖߂����B)
	push	ds			;�Z�O�����g�̕ۑ�

;�|�C���^�����ɖ߂��B
	dec	cs:[pMML_File]		;�|�C���^�E�f�B�N�������g

;�R�}���h����
c_Voice_Pcm_first_Loop4:		;
	mov	al,cs:[si]		;al���R�}���h
	inc	si			;
	mov	cl,cs:[si]		;
	inc	si			;
	cmp	al,00h			;�I��
	jnz	c_Voice_Pcm_first_Step3	;
	jmp	c_Voice_Pcm_first_Step99
c_Voice_Pcm_first_Step3:		;
	cmp	al,010h			;4bit �~ 2
	jnz	c_Voice_Pcm_first_Step4	;
c_Voice_Pcm_first_Step3_Loop:		;
	call	A2H8R			;
	and	ah,0fh			;
	mov	al,ah			;
	call	A2H8R			;
	and	ah,0fh			;
	shl	ah,4			;
	or	ah,al			;
	call	cset			;
	sub	cl,1			;
	jnz	c_Voice_Pcm_first_Step3_Loop
	jmp	c_Voice_Pcm_first_Loop4	;
c_Voice_Pcm_first_Step4:		;
	cmp	al,011h			;Byte
	jnz	c_Voice_Pcm_first_Step5	;
c_Voice_Pcm_first_Step4_Loop:		;
	call	A2H8R			;
	call	CSET			;
	sub	cl,1			;
	jnz	c_Voice_Pcm_first_Step4_Loop
	jmp	c_Voice_Pcm_first_Loop4	;
c_Voice_Pcm_first_Step5:		;
	cmp	al,012h			;Word
	jnz	c_Voice_Pcm_first_Step6	;
c_Voice_Pcm_first_Step5_Loop:		;
	call	A2H16R			;
	call	CSET16			;
	sub	cl,1			;
	jnz	c_Voice_Pcm_first_Step5_Loop
	jmp	c_Voice_Pcm_first_Loop4	;
c_Voice_Pcm_first_Step6:		;
	cmp	al,0F0h			;Call (Other Program)
	jnz	c_Voice_Pcm_first_Step7	;

	dec	si			;Count�͖����̂ŁAsi��߂��B
	mov	dx,cs:[si]		;
	add	si,2			;
	call	dx			;
;	jmp	c_Voice_Pcm_first_Loop4	;
c_Voice_Pcm_first_Step7:		;

;�R���p�C���������[�v
	jmp	c_Voice_Pcm_first_Loop4	;

;���߃R���p�C�������I��
c_Voice_Pcm_first_Step99:		;

;�J�E���^�C���N�������g
	inc	byte ptr ds:[0].WTD_Mus_Voice

;�߂�
	pop	ds			;�Z�O�����g�̕��A
	jmp	c_Voice_Pcm_first_Loop1	;�������r�J�n�B
;-----------------------------------------------------------------------
;�I��
c_Voice_Pcm_first_End:			;
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
c_Voice_Pcm_first_Start:
	pusha				;���W�X�^�ۑ�

;�|�C���^�[�̐ݒ�y�сA�g���b�N�A�h���X�̏�����������B
	xor	bx,bx			;
	mov	cs:[pMML_File],bx	;MML�t�@�C���̃|�C���^��擪�ɂ���B
	mov	cl,ds:[bx].WTD_Mus_Part	;�p�[�g����ǂݍ��݁B
	cmp	cl,MusicMaxPart			;�p�[�g���`�F�b�N
	jc	c_Voice_Pcm_first_Start_Step0	;
	mov	cl,MusicMaxPart			;
	mov	ds:[bx].WTD_Mus_Part,cl	;�p�[�g�����������݁B
c_Voice_Pcm_first_Start_Step0:		;
	mov	bx,0010h		;
c_Voice_Pcm_first_Start_Loop1:		;�p�[�g���������[�v����B
	sub	cl,1			;�J�E���^�E�f�B�N�������g
	jc	c_Voice_Pcm_first_Start_Step1
	mov	word ptr ds:[bx],0000h	;�g���b�N�̃A�h���X�̏�����
	add	bx,2			;�|�C���^�E�C���N�������g
	jmp	c_Voice_Pcm_first_Start_Loop1
c_Voice_Pcm_first_Start_Step1:		;
	mov	cs:[pWTD_File],bx	;WTD�t�@�C���̃|�C���^��ݒ肷��B

;	�A�h���X�ݒ�
	mov	word ptr ds:[0].WTD_Mus_DataAdr,bx

;�I��
	popa				;���W�X�^���A
	ret				;Return
;===============================================================|
;			����					|
;===============================================================|
c_Voice_Pcm_Adrs:
	dw	3			;����
	dw	offset cVPD_0		;#Voice
	dw	offset cVPD_1		;@F
	dw	offset cVPD_2		;@
;---------------------------------------------------------------|
;	�@�R�}���h������					|
;		�Ō��24h�ŏI���				|
;	�A�o�͂���ꏊ						|
;	    00h	�I���						|
;	    1xh		�f�[�^��������				|
;		x	0:4bit�~2 / 1:Byte / 2:Word		|
;		byte	Count					|
;	    F0h	�v���O����					|
;		nnnn	Offset Address				|
;---------------------------------------------------------------
c_Voice_Pcm_Data:
cVPD_0	db	'#voice'    ,24h, 011h,1, 010h,16, 00h
cVPD_1	db	0dh,0ah,'@F',24h, 011h,1, 0F0h	;@�̑O�ɂ��鎖�I�I
	dw	offset c_Voice_Pcm_File
	db	00h
cVPD_2	db	0dh,0ah,'@' ,24h, 011h,1, 010h,16, 00h
;---------------------------------------------------------------|
;���t�@�C������̓ǂݍ���		;
c_Voice_File	DB	'            ',00h,0dh,0ah,24h
c_Voice_Pcm_File:			;
	pusha				;���W�X�^�ۑ�

	call	A2H8R			;���F�ԍ��ǂݍ���
	push	ax			;�ԍ��ۑ�

;�t�@�C����������擪�̌���
c_Voice_Pcm_File_Step1:
	call	cread			;
	cmp	ah,21H			;
	jc	c_Voice_Pcm_File_Step1	;20�����̃R�[�h�͔�΂�
	mov	bx,offset c_Voice_File	;bx���t�@�C�������i�[����A�h���X
	mov	cl,13			;cl���t�@�C�����̍ő啶����
	dec	cs:[pMML_File]		;�|�C���^����߂��B

;�t�@�C������������s�b�N�A�b�v
c_Voice_Pcm_File_Step2:			;
	call	cread			;
	CMP	AH,0DH			;���s��������
	JZ	c_Voice_Pcm_File_Step3	;�i�[�I��
	MOV	CS:[BX],AH		;
	INC	BX			;
	DEC	CL			;
	JNZ	c_Voice_Pcm_File_Step2	;������I�[�o
	JMP	VOI_ERROR		;���݂��Ȃ��t�@�C��
c_Voice_Pcm_File_Step3:			;
	MOV	AH,00H			;
	MOV	CS:[BX],AH		;

;�t�@�C���̓ǂݍ���
	call	VOPEN			;
	call	VOI_FILE_OPEN		;
	call	VOI_MREAD		;

;���F�̓]��
	pop	bx			;���F�ԍ��̕��A

	mov	bl,bh			;
	xor	bh,bh			;
	shl	bx,4			;
	push	es			;
	mov	es,cs:[segVoice_File]	;es:bx�����F�A�h���X
	mov	cl,16			;
c_Voice_Pcm_File_Step4:			;
	mov	ah,es:[bx]		;
	inc	bx			;
	call	CSET			;
	sub	cl,1			;
	jnz	c_Voice_Pcm_File_Step4	;
	pop	es			;

	call	VOI_FILE_CLOSE		;
	call	VCLOSE			;

	dec	cs:[pMML_File]		;�|�C���^�P�߂��B

	popa				;���W�X�^���A
	ret				;
;---------------------------------------------------------------|
;		���F�R���p�C��					|
;---------------------------------------------------------------|
;	����							|
;		����						|
;	�Ԃ�l							|
;		����						|
;	�g�p���W�X�^						|
;		cx	�R�}���h���J�E���^			|
;		di	c_Voice_Emb_Adrs�|�C���^		|
;		si	c_Voice_Emb_Data�|�C���^		|
;---------------------------------------------------------------|
c_Voice_Emb_first:				;
	pusha				;���W�X�^�ۑ�

;�w�b�_�[�����ݒ�
	call	c_Voice_Emb_first_Start	;

;�R�}���h����
;�R�}���h���ʂ̓ǂݍ���
c_Voice_Emb_first_Loop1:		;cx���R�}���h�̐���
	xor	di,di			;di���ϊ���`�A�h���X�̃|�C���^
	mov	cx,cs:[offset c_Voice_Emb_Adrs + di]
					;������`�F�b�N�̃J�E���^
;�|�C���^�ǂݍ���
c_Voice_Emb_first_Loop2:		;
	push	cs:[pMML_File]		;�|�C���^�ۑ�
	add	di,2			;�|�C���^�C���N�������g(Word)
	mov	si,cs:[offset c_Voice_Emb_Adrs + di]	;si���ϊ���`�A�h���X
;�P�����ǂݍ���
c_Voice_Emb_first_Loop3:		;
	call	cread			;MML�t�@�C������P�����ǂݍ���
c_Voice_Emb_first_Step1:		;
;�P�����`�F�b�N�i24h�܂ށj
	mov	al,cs:[si]		;
	inc	si			;
	cmp	al,24h			;�����I���H
	jz	c_Voice_Emb_first_Step2	;�Ȃ�΁A�������v�ŏ������s�B
	cmp	ah,al			;������v�H
	jz	c_Voice_Emb_first_Loop3	;�Ȃ�΁A�����`�F�b�N�B
;�����`�F�b�N�ň�v���Ȃ������ꍇ�B
	pop	cs:[pMML_File]		;�|�C���^���A
	sub	cx,1			;�J�E���^�[�E�f�B�N�������g
	jnz	c_Voice_Emb_first_Loop2	;���̃R�}���h�Ŕ�r
	inc	CS:[pMML_File]		;�|�C���^�E�C���N�������g
	mov	ax,CS:[szMML_File]	;
	cmp	ax,CS:[pMML_File]	;MML�t�@�C���̏I���`�F�b�N
	jnc	c_Voice_Emb_first_Loop1	;�������r�J�n�B
	jmp	c_Voice_Emb_first_End	;MML�t�@�C����[EOF]�Ȃ�ΏI��
;-----------------------------------------------------------------------
;�R�}���h�����B
c_Voice_Emb_first_Step2:			;
	pop	ax			;�|�C���^�̕��A(�l�͖߂����B)
	push	ds			;�Z�O�����g�̕ۑ�

;�|�C���^�����ɖ߂��B
	dec	cs:[pMML_File]		;�|�C���^�E�f�B�N�������g

;�R�}���h����
c_Voice_Emb_first_Loop4:		;
	mov	al,cs:[si]		;al���R�}���h
	inc	si			;
	cmp	al,0FFh			;�I��
	jnz	c_Voice_Emb_first_Step3	;
	jmp	c_Voice_Emb_first_Step99
c_Voice_Emb_first_Step3:		;
	cmp	al,0F0h			;Call (Other Program)
	jnz	c_Voice_Emb_first_Step7	;
	mov	dx,cs:[si]		;
	add	si,2			;
	call	dx			;
	jmp	c_Voice_Emb_first_Loop4	;
c_Voice_Emb_first_Step7:		;
	cmp	al,010h			;
	jnz	c_Voice_Emb_first_Step4	;
	call	A2H8R			;
	call	CSET			;
	jmp	c_Voice_Emb_first_Loop4	;
c_Voice_Emb_first_Step4:		;
	xor	bx,bx			;
	mov	bl,al			;
	rol	bl,1			;
	shr	bl,1			;Bit 7 Reset & Bit 7 -> Cy Flag
	jc	c_Voice_Emb_first_Step5	;
	call	A2H8R			;al���f�[�^(MML File)
	jmp	c_Voice_Emb_first_Step6	;
c_Voice_Emb_first_Step5:		;
	mov	ah,cs:[si]		;al���f�[�^(�ݒ�l)
	inc	si			;
c_Voice_Emb_first_Step6:		;
	add	bx,cs:[pWTD_File]	;
	mov	byte ptr ds:[bx],ah	;�f�[�^��������

;�R���p�C���������[�v
	jmp	c_Voice_Emb_first_Loop4	;

;���߃R���p�C�������I��
c_Voice_Emb_first_Step99:		;

;�J�E���^�C���N�������g
	inc	byte ptr ds:[0].WTD_Mus_Emb
;�|�C���^����
	add	cs:[pWTD_File],16	;16Byte������(���������Ă����)

;�߂�
	pop	ds			;�Z�O�����g�̕��A
	jmp	c_Voice_Emb_first_Loop1	;�������r�J�n�B
;-----------------------------------------------------------------------
;�I��
c_Voice_Emb_first_End:			;
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
c_Voice_Emb_first_Start:
	pusha				;���W�X�^�ۑ�

;�|�C���^�[�̐ݒ�B
	xor	bx,bx			;
	mov	cs:[pMML_File],bx	;MML�t�@�C���̃|�C���^��擪�ɂ���B


;�I��
	popa				;���W�X�^���A
	ret				;Return
;===============================================================|
;			����					|
;===============================================================|
c_Voice_Emb_Adrs:
	dw	2			;����
	dw	offset cVED_0		;E
	dw	offset cVED_1		;Ex
;---------------------------------------------------------------|
;	�@�R�}���h������					|
;		�Ō��24h�ŏI���				|
;	�A�o�͂���ꏊ						|
;	    0xh		Address (Emb.Sturc)			|
;	    8xh		Address (Emb.Sturc)			|
;		byte	Data					|
;	    F0h	�v���O����					|
;		nnnn	Offset Address				|
;	    FFh	�I���						|
;---------------------------------------------------------------
c_Voice_Emb_Data:
cVED_0	db	0dh,0ah,'Ex',24h,10h
	db	WTD_Emb_FL
	db	WTD_Emb_AR
	db	WTD_Emb_AS
	db	WTD_Emb_AL
	db	WTD_Emb_DR
	db	WTD_Emb_DS
	db	WTD_Emb_DL
	db	WTD_Emb_SR
	db	WTD_Emb_SS
	db	WTD_Emb_SL
	db	WTD_Emb_RR
	db	WTD_Emb_RS
	db	WTD_Emb_RL
	db	0FFh
cVED_1	db	0dh,0ah,'E', 24h,10h
	db	WTD_Emb_FL
	db	WTD_Emb_AR
	db	WTD_Emb_AS + 80h,001h
	db	WTD_Emb_AL + 80h,0ffh
	db	WTD_Emb_DR
	db	WTD_Emb_DS + 80h,0ffh
	db	WTD_Emb_DL
	db	WTD_Emb_SR
	db	WTD_Emb_SS + 80h,0ffh
	db	WTD_Emb_SL + 80h,000h
	db	WTD_Emb_RR
	db	WTD_Emb_RS + 80h,0ffh
	db	WTD_Emb_RL + 80h,000h
	db	0FFh