;=======================================================================|
;									|
;	�ϊ��T�u���[�`��						|
;		10�i�iASCII�j	���@16�i(BIN)				|
;		16�i�iBIN�j	�|�@10�i�iASCII�j			|
;		16�i�iBIN�j	�|�@16�i�iASCII�j			|
;									|
;					Programmed by			|
;						��������		|
;									|
;=======================================================================|
;---------------------------------------------------------------|
;		ASCII CODE���P�U�i�R�[�h(-128�`256)		|
;			���l�f�[�^������܂ł�����		|
;---------------------------------------------------------------|
;	����							|
;		CS:[pMML_File] ���ϊ�������������擪�A�h���X	|
;		ES��MML Data�̂���Z�O�����g			|
;	�Ԃ�l							|
;		AH���f�[�^					|
;		CS:[pMML_File] �����̃A�h���X			|
;---------------------------------------------------------------|
.code
A2H8R	proc	near
	PUSH	BX			;
	PUSH	CX			;
	PUSH	DX			;
	PUSH	DS			;
	MOV	CL,AL			;AL�̕ۑ�
	PUSH	AX			;
	MOV	AX,ES			;
	MOV	DS,AX			;
	POP	AX			;
	MOV	DX,CS:[pMML_File]	;
A2H8R1:	CALL	COMMENT_CHK		;�R�����g�`�F�b�N
	CALL	ASC2HEX8		;ASC Code ��16�iCode�ϊ�
	MOV	DX,BX			;
	JNC	A2H8RR			;�ϊ��s�\�H��������
	JMP	A2H8R1			;��蒼���B
A2H8RR:	MOV	CS:[pMML_File],DX	;
	MOV	AL,CL			;AL�̕��A
	POP	DS			;
	POP	DX			;
	POP	CX			;
	POP	BX			;
	RET				;RETURN
A2H8R	endp
;---------------------------------------------------------------|
;		ASCII CODE���P�U�i�R�[�h(-32767�`65535)		|
;			���l�f�[�^������܂ł�����		|
;---------------------------------------------------------------|
;	����							|
;		CS:[pMML_File] ���ϊ�������������擪�A�h���X	|
;		ES��MML Data�̂���Z�O�����g			|
;	�Ԃ�l							|
;		AX���f�[�^					|
;		CS:[pMML_File] �����̃A�h���X			|
;---------------------------------------------------------------|
A2H16R	proc	near
	CALL	COMMENT_CHK		;�R�����g�`�F�b�N

	PUSH	BX			;
	PUSH	DX			;
	PUSH	DS			;
	PUSH	AX			;
	MOV	AX,ES			;
	MOV	DS,AX			;
	POP	AX			;
	MOV	DX,CS:[pMML_File]	;
A2H16R1:CALL	ASC2HEX16		;ASC Code ��16�iCode�ϊ�
	MOV	DX,BX			;
	JNC	A2H16RR			;�ϊ��s�\�H��������
	JMP	A2H16R1			;��蒼���B
A2H16RR:MOV	CS:[pMML_File],DX	;
	POP	DS			;
	POP	DX			;
	POP	BX			;
	RET				;RETURN
A2H16R	endp
;---------------------------------------------------------------|
;		�R���p�C���f�[�^�ǂݍ���			|
;---------------------------------------------------------------|
;	����							|
;		CS:[pMML_File]�F�R���p�C���A�h���X		|
;		ES��MML Data�̂���Z�O�����g			|
;	�Ԃ�l							|
;		AH	 �@�F�f�[�^				|
;		CS:[pMML_File]�F���̃A�h���X			|
;---------------------------------------------------------------|
CREAD	proc	near	uses	si

	call	COMMENT_CHK		;
	MOV	si,CS:[pMML_File]	;BX���R���p�C������A�h���X
	mov	ah,es:[si]		;AH�������̃f�[�^
	inc	si			;BX�i�|�C���^�j�𑝉�
	mov	cs:[pMML_File],si	;
	cmp	cs:[szMml_File],si	;�|�C���^���T�C�Y���z���Ă�����Cy��'H'

	RET				;
CREAD	endp
;---------------------------------------------------------------|
CREAD_L	proc	near	uses	si

	call	COMMENT_CHK		;
	MOV	si,CS:[pMML_File]	;si���R���p�C������A�h���X
	lodsb	es:[si]			;AL�������̃f�[�^
	mov	cs:[pMML_File],si	;
	cmp	cs:[szMml_File],si	;�|�C���^���T�C�Y���z���Ă�����Cy��'H'

	RET				;
CREAD_L	endp
;---------------------------------------------------------------|
;		�R���p�C���f�[�^��������			|
;---------------------------------------------------------------|
;	����							|
;		AH	 �@�F�f�[�^				|
;		CS:[pWTD_File]�F�R���p�C���A�h���X		|
;		DS��FSP �f�[�^�������Z�O�����g			|
;	�Ԃ�l							|
;		CS:[pWTD_File]�F���̃A�h���X			|
;---------------------------------------------------------------|
CSET	proc	near	uses	di
	MOV	di,CS:[pWTD_File]	;di���R���p�C�������A�h���X
	MOV	DS:[di],AH		;��������
	inc	CS:[pWTD_File]		;�i�|�C���^�j����
	RET				;
CSET	endp
;---------------------------------------------------------------
CSET_L	proc	near	uses	di
	MOV	di,CS:[pWTD_File]	;di���R���p�C�������A�h���X
	MOV	DS:[di],al		;��������
	inc	CS:[pWTD_File]		;�i�|�C���^�j����
	RET				;
CSET_L	endp
;---------------------------------------------------------------
CSET16	proc	near	uses	di
	MOV	di,CS:[pWTD_File]	;di���R���p�C�������A�h���X
	MOV	DS:[di],ax		;��������
	add	CS:[pWTD_File],2	;�i�|�C���^�j����
	RET				;
CSET16	endp
;---------------------------------------------------------------|
;		�R�����g�`�F�b�N				|
;---------------------------------------------------------------|
COMMENT_CHK	proc	near	uses ax si
	MOV	si,CS:[pMML_File]	;BX���R���p�C�����A�h���X
	MOV	al,ES:[si]		;AH�������̃f�[�^
	CMP	al,';'			;�����R�����g������������s�܂ŃW�����v
	JNZ	REMCHK			;
	CALL	CRJUMP			;
REMCHK:	
	RET				;
COMMENT_CHK	endp
;---------------------------------------------------------------|
;		���s�܂Ŕ�΂�					|
;---------------------------------------------------------------|
CRJUMP	proc	near	uses	ax si

	mov	si,CS:[pMML_File]	;BX���R���p�C������A�h���X
	.repeat
	lodsb	es:[si]			;AH�������̃f�[�^
	.until	(al == 0dh)		;���s�H

	dec	si
	mov	CS:[pMML_File],si	;�|�C���^�𑝉�

	RET				;
CRJUMP	endp
