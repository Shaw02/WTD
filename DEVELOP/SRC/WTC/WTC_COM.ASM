;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				Command Compile Routine			|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;===============================================================|
;		���ߒ�`�@�i�R���p�C�����j			|
;===============================================================|
;---------------------------------------------------------------|
;	�@�R�}���h������					|
;		�Ō��00h�ŏI���				|
;	�A�o�[�W����						|
;		byte	������	�^	byte	������		|
;	�B�o�͕�����B						|
;		�Ō��00h�ŏI���				|
;	�C�o�͂���ꏊ						|
;	    00h	�I���						|
;	    1xh �f�[�^�ǂݍ��݁���������			|
;		x	0:4bit�~2 / 1:Byte / 2:Word		|
;	    20h �����p���l�������݁B				|(�ύX��)
;		�uZenlen��(�ǂݍ���)�v���������ށB		|
;		�i'%'�w�肾������A���̂܂܂̐��l�B�j		|
;		�i�t�_���`�F�b�N����B�j			|
;		01	l�R�}���h�̏ꍇ�w�肷��B		|
;		01�ȊO	l�R�}���h�ȊO�B				|
;	    8xh	���K��������					|(�ύX��)
;		x	0�E�E�E�x��				|
;			1�E�E�E�h�@�^�@7�E�E�E�V		|
;		('#','+','-','&'�̃`�F�b�N�B)			|
;		(���ɁA���l�����邩�`�F�b�N�B��'20h'�Ɠ�������)	|
;	    F0h	�v���O����					|
;		nnnn	Offset Address				|
;---------------------------------------------------------------
c_Command_Data:
;		Strings		Version	Strings	Command
cMCD_0	db	0dh,0ah,'C',0,	0,1,	0,	0f0h	;<CR+LF>+'C'
	dw		offset cMCD_CH			;
	db		0				;
cMCD_1	db	0dh,0ah,0,	0,1,	0,	0f0h	;<CR+LF>���s
	dw		offset cMCD_CR			;
	db		0				;�|�ŏ��ɉ��s�`�F�b�N
cMCD_2	db	'$',0,		0,1,	0,	0f0h	;<CR+LF>+'$'
	dw		offset cMCD_Macro		;
	db		0				;
cMCD_3	db	'a',0,		0,1,	0,	86h,0	;a	��
cMCD_4	db	'b',0,		0,1,	0,	87h,0	;b	�V
cMCD_5	db	'c',0,		0,1,	0,	81h,0	;c	�h
cMCD_6	db	'd',0,		0,1,	0,	82h,0	;d	��
cMCD_7	db	'e',0,		0,1,	0,	83h,0	;e	�~
cMCD_8	db	'f',0,		0,1,	0,	84h,0	;f	�t�@
cMCD_9	db	'g',0,		0,1,	0,	85h,0	;g	�\
cMCD_10	db	'h',0,		0,0,	0,	0	;h
cMCD_11	db	'i',0,		0,0,	0,	0	;i
cMCD_12	db	'j',0,		0,0,	0,	0	;j
cMCD_13	db	'k',0,		0,1,	'k',0,	11h,0	;k	Velocity
cMCD_14	db	'l',0,		0,1,	'l',0,	20h,1,0	;l	Lengs
cMCD_15	db	'n',0,		0,1,	'n',0,	11h,0	;n	Noise mode
cMCD_16	db	'm',0,		0,4,	'm',0,	11h,11h,11h,12h,11h,0	;m
cMCD_17	db	'o',0,		0,1,	'o',0,	11h,0	;o	Octave
cMCD_18	db	'p',0,		0,2,	'p',0,	11h,0	;p	Pan
cMCD_19	db	'q',0,		0,1,	'q',0,	12h,0	;q	Gate Step
cMCD_20	db	'r',0,		0,1,	0,	80h,0	;r	�x��
cMCD_21	db	's',0,		0,5,	's',0,	11h,11h,0   ;s	Sweep
cMCD_22	db	't',0,		0,2,	't',0,	0f0h	;t	Tempo
	dw		offset cMCD_st
	db		0
cMCD_23	db	'u',0,		0,1,	'u',0,	12h,0	;u	Gate Step
cMCD_24	db	'v',0,		0,1,	'v',0,	11h,0	;v	Volume
cMCD_25	db	'w',0,		0,0,	0,	0	;w
cMCD_26	db	'x',0,		0,5,	'x',0,	11h,0	;x	Volume UpDown
cMCD_27	db	'y',0,		0,5,	'y',0,	11h,11h,0   ;y	Conroll Change
cMCD_28	db	'z',0,		0,0,	0,	0	;z
cMCD_29	db	'A',0,		0,0,	0,	0	;A
cMCD_30	db	'B',0,		0,8,	'B',0,	0f0h	;B	Bend
	dw		offset cMCD_lb
	db		0
cMCD_31	db	'C',0,		0,1,	'C',0,	11h,0	;C	Channel
cMCD_32	db	'D',0,		0,1,	'D',0,	12h,0	;D	Detune
cMCD_33	db	'E',0,		0,5,	'E',0,	11h,11h,0   ;E	Emb
cMCD_34	db	'F',0,		0,8,	'F',0,	11h,0	;F	Volume
cMCD_35	db	'G',0,		0,8,	'G',0,	11h,0	;G	Plessior
cMCD_36	db	'H',0,		0,8,	'H',0,	11h,11h,0   ;H	Bank
cMCD_37	db	'I',0,		0,0,	0,	0	;I
cMCD_38	db	'J',0,		0,0,	0,	0	;J
cMCD_39	db	'K',0,		0,1,	'K',0,	12h,0	;K	KeyDelay
cMCD_40	db	'L',0,		0,3,	0,	0f0h	;L	Loop
	dw		offset cMCD_lL			;
	db		0				;
cMCD_41	db	'N',0,		0,8,	'N',0,	11h,0	;N	NPR
cMCD_42	db	'M',0,		0,0ah,	'M',0,	12h,11h,0   ;M	Mod
cMCD_43	db	'O',0,		0,8,	'O',0,	11h,0	;O	Son
cMCD_44	db	'P',0,		0,3,	'P',0,	11h,0	;P	Switch
cMCD_45	db	'Q',0,		0,1,	'Q',0,	11h,0	;Q	Gate time
cMCD_46	db	'R',0,		0,8,	'R',0,	11h,0	;R	Bless
cMCD_47	db	'S',0,		0,8,	'S',0,	11h,0	;S	Soft
cMCD_48	db	'T',0,		0,8,	'T',0,	11h,0	;T	Foot
cMCD_49	db	'U',0,		0,1,	'U',0,	11h,0	;U	Gate time
cMCD_50	db	'V',0,		0,1,	'V',0,	12h,0	;V	V dev
cMCD_51	db	'W',0,		0,8,	'W',0,	11h,0	;W	Blance
cMCD_52	db	'X',0,		0,5,	'X',0,	0f0h	;X
	dw		offset cMCD_lX			;
	db		0				;
cMCD_53	db	'Y',0,		0,0,	0,	0	;Y
cMCD_54	db	'Z',0,		0,5,	'Z',0,	0f0h	;Z
	dw		offset cMCD_lZ			;
	db		0				;
cMCD_55	db	'!',0,		0,1,	'!',0,	0	;!	Work Sw
cMCD_56	db	'"',0,		0,1,	'"',0,	11h,0	;"	Work Add
cMCD_57	db	27h,0,		0,1,	27h,0,	11h,0	;'	Acsent
cMCD_58	db	'(',0,		0,1,	'(',0,	0	;(	Volume Down
cMCD_59	db	')',0,		0,1,	')',0,	0	;)	Volume Up
cMCD_60	db	'0',0,		1,0,	'0',0,	11h,11h,0   ;0	ld
cMCD_61	db	'1',0,		1,0,	'1',0,	11h,11h,0   ;1	add
cMCD_62	db	'2',0,		1,0,	'2',0,	11h,11h,0   ;2	sub
cMCD_63	db	'3',0,		1,0,	'3',0,	11h,11h,0   ;3	and
cMCD_64	db	'4',0,		1,0,	'4',0,	11h,11h,0   ;4	or
cMCD_65	db	'5',0,		1,0,	'5',0,	11h,11h,0   ;5	xor
cMCD_66	db	'6',0,		1,0,	'6',0,	11h,11h,0   ;6	set
cMCD_67	db	'7',0,		1,0,	'7',0,	11h,11h,0   ;7	reset
cMCD_68	db	'8',0,		1,0,	'8',0,	11h,11h,0   ;8	cmp
cMCD_69	db	'9',0,		1,0,	'9',0,	11h,11h,0   ;9	test
cMCD_70	db	'*',0,		0,4,	'*',0,	11h,11h,0   ;*	LFO Switch
cMCD_71	db	'/',0,		0,5,	'/',0,	11h,11h,0   ;/	Emb Switch
cMCD_72	db	':',0,		0,3,	':',0,	0f0h	;:	Loop Jump
	dw		offset cMCD_Loop_Jump		;
	db		0				;
cMCD_73	db	3bh,0,		1,0,	3bh,0,	11h,0f0h    ;;	Loop Flag
	dw		offset cMCD_Loop_Jump		;
	db		0				;
cMCD_74	db	'[',0,		0,3,	'[',0,	0f0h	;[	Loop Start
	dw		offset cMCD_Loop_Start		;
	db		0				;
cMCD_75	db	']',0,		0,3,	']',0,	0f0h	;]	Loop End
	dw		offset cMCD_Loop_End		;
	db		0				;
cMCD_76	db	'<',0,		0,1,	'<',0,	0	;<
cMCD_77	db	'>',0,		0,1,	'>',0,	0	;>
cMCD_78	db	'@F',0,		1,5,	'@',80h,0,    11h,0	;@F
cMCD_79	db	'@S',0,		1,5,	'@',81h,0,    11h,12h,0	;@S
cMCD_80	db	'@R',0,		1,5,	'@',82h,0,    11h,0	;@R
cMCD_81	db	'@',0,		0,1,	'@',0,	11h,0	;@
cMCD_82	db	'_',0,		0,1,	'_',0,	11h,0	;_
cMCD_83	db	'{',0,		0,8,	'{',0,	0f0h	;{
	dw		offset cMCD_trance		;
	db		0				;
;===============================================================
c_Command_Adrs:				;�R�}���h�E�f�[�^�̃A�h���X�B
	dw	84			;����
	dw	offset cMCD_0		;<CR+LF>+"C"
	dw	offset cMCD_1		;<CR+LF>+"!"
	dw	offset cMCD_2		;<CR+LF>
	dw	offset cMCD_3		;a	��
	dw	offset cMCD_4		;b	�V
	dw	offset cMCD_5		;c	�h
	dw	offset cMCD_6		;d	��
	dw	offset cMCD_7		;e	�~
	dw	offset cMCD_8		;f	�t�@
	dw	offset cMCD_9		;g	�\
	dw	offset cMCD_10		;h	
	dw	offset cMCD_11		;i	
	dw	offset cMCD_12		;j	
	dw	offset cMCD_13		;k	
	dw	offset cMCD_14		;l	
	dw	offset cMCD_15		;n	
	dw	offset cMCD_16		;m	
	dw	offset cMCD_17		;o	
	dw	offset cMCD_18		;p	
	dw	offset cMCD_19		;q	
	dw	offset cMCD_20		;r	
	dw	offset cMCD_21		;s	
	dw	offset cMCD_22		;t	
	dw	offset cMCD_23		;u	
	dw	offset cMCD_24		;v	
	dw	offset cMCD_25		;w	
	dw	offset cMCD_26		;x	
	dw	offset cMCD_27		;y	
	dw	offset cMCD_28		;z	
	dw	offset cMCD_29		;A	
	dw	offset cMCD_30		;B	
	dw	offset cMCD_31		;C	
	dw	offset cMCD_32		;D	
	dw	offset cMCD_33		;E	
	dw	offset cMCD_34		;F	
	dw	offset cMCD_35		;G	
	dw	offset cMCD_36		;H	
	dw	offset cMCD_37		;I	
	dw	offset cMCD_38		;J	
	dw	offset cMCD_39		;K	
	dw	offset cMCD_40		;L	
	dw	offset cMCD_41		;N	
	dw	offset cMCD_42		;M	
	dw	offset cMCD_43		;O	
	dw	offset cMCD_44		;P	
	dw	offset cMCD_45		;Q	
	dw	offset cMCD_46		;R	
	dw	offset cMCD_47		;S	
	dw	offset cMCD_48		;T	
	dw	offset cMCD_49		;U	
	dw	offset cMCD_50		;V	
	dw	offset cMCD_51		;W	
	dw	offset cMCD_52		;X	
	dw	offset cMCD_53		;Y	
	dw	offset cMCD_54		;Z	
	dw	offset cMCD_55		;!	
	dw	offset cMCD_56		;"	
	dw	offset cMCD_57		;'	
	dw	offset cMCD_58		;(	
	dw	offset cMCD_59		;)	
	dw	offset cMCD_60		;0	
	dw	offset cMCD_61		;1	
	dw	offset cMCD_62		;2	
	dw	offset cMCD_63		;3	
	dw	offset cMCD_64		;4	
	dw	offset cMCD_65		;5	
	dw	offset cMCD_66		;6	
	dw	offset cMCD_67		;7	
	dw	offset cMCD_68		;8	
	dw	offset cMCD_69		;9	
	dw	offset cMCD_70		;*	
	dw	offset cMCD_71		;/	
	dw	offset cMCD_72		;:	
	dw	offset cMCD_73		;	
	dw	offset cMCD_74		;[	
	dw	offset cMCD_75		;]	
	dw	offset cMCD_76		;<	
	dw	offset cMCD_77		;>	
	dw	offset cMCD_78		;@F	
	dw	offset cMCD_79		;@S	
	dw	offset cMCD_80		;@R	
	dw	offset cMCD_81		;@	
	dw	offset cMCD_82		;_	
	dw	offset cMCD_83		;{	
;===============================================================
;���݃R���p�C�����̃`�����l���B
cMCD_ChannelWTD	db	?		;�R���p�C�����́B
cMCD_ChannelMML	db	?		;�l�l�k���́B
cMCD_MacroCount	dw	-2		;�}�N���̃X�^�b�N�|�C���^
cMCD_MacroAdr	dw	8	dup(0)	;�}�N���̃X�^�b�N�G���A
;�������[�v�A�h���X
cMCD_LoopL	dw	0000h		;
;����'l'
dMCD_lengs	dw	48		;
;���[�v
cMCD_LoopCount	dw	-2		;
cMCD_LoopEnd	dw	8	dup(0)	;
cMCD_LoopJump	dw	8	dup(0)	;

;===============================================================
cMCD_CRS:				;Serach
	pusha				;���s����������s����B
	jmp	cMCD_CR_Loop		;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cMCD_CR:
	call	cMCD_MacroEndChk	;�}�N���̏I�����ǂ������`�F�b�N
	jc	cMCD_CR_EndM		;

					;���䕶���ł��邩�`�F�b�N���A
	pusha				;�����łȂ�������A���s�������s���B
	call	CREAD			;
	cmp	ah,21h			;���䕶���ł��邩�H
	jc	cMCD_CR_Step		;����ȊO��������A���s��������B
cMCD_CR_Loop:				;
	call	CREAD			;
	jc	cMCD_CR_End		;�t�@�C���I����������A�I���B
	cmp	ah,0dh			;�i���̂Ƃ��A�|�C���^�͉��s�̎��B�j
	jnz	cMCD_CR_Loop		;���s���������B

;�|�C���^�����s���O�ɖ߂��B
cMCD_CR_Step:				;
	dec	cs:[pMML_File]		;
;�I��
cMCD_CR_End:				;
	popa				;���W�X�^���A
cMCD_CR_EndM:				;
	ret				;
;---------------------------------------------------------------
cMCD_CH:				;�`�����l���ݒ�
	call	cMCD_MacroEndChk	;�}�N���̏I�����ǂ������`�F�b�N
	jc	cMCD_CH_EndM		;
	pusha				;

	mov	ah,0ffh			;�_�~�[�̐ݒ�
	mov	cs:[cMCD_ChannelMML],ah	;�ۑ�
cMCD_CH_Loop:				;
	call	A2H8R			;�ǂݍ���

	cmp	ah,cs:[cMCD_ChannelWTD]	;��r
	jnz	cMCD_CH_Step		;
	call	cMCD_CH_Set		;������������ݒ�B
cMCD_CH_Step:				;

	call	CREAD			;�J���}����������A
	cmp	ah,','			;�g���b�N�̕����w��B
	jz	cMCD_CH_Loop		;

;�I��
cMCD_CH_End:
	popa				;���W�X�^���A
cMCD_CH_EndM:				;
	ret				;
cMCD_CH_Set:
	mov	cs:[cMCD_ChannelMML],ah	;�ۑ�
	ret
;---------------------------------------------------------------
cMCD_Macro:				;�}�N��
	call	cMCD_MacroEndChk	;�}�N���̏I�����ǂ������`�F�b�N
	jc	cMCD_Macro_EndM		;

;�����W�X�^�̕ۑ�
	pusha				;

;���}�N�����̎擾
	xor	bx,bx			;
	call	CREAD			;
	mov	bl,ah			;bl���}�N������
	push	cs:[pMML_File]		;
	call	CREAD			;
	pop	cs:[pMML_File]		;ah�������擪����
	cmp	ah,30h			;
	jc	cMCD_Macro_Step0	;
	cmp	ah,3Ah			;
	jnc	cMCD_Macro_Step0	;
	call	A2H8R			;
	mov	bh,ah			;bh���}�N������

;���}�N���̌���
cMCD_Macro_Step0:			;
	mov	dx,cs:[pMML_File]	;dx��MML�̃|�C���^
	xor	ax,ax			;�|�C���^��擪��
	mov	cs:[pMML_File],ax	;
cMCD_Macro_Loop0:			;
	call	cread			;
	jnc	cMCD_Macro_Step1	;
	jmp	MACRO_ERROR		;���݂��Ȃ��}�N���̌Ăяo��
cMCD_Macro_Step1:			;
	cmp	ah,'$'			;
	jnz	cMCD_Macro_Loop0	;
	call	CREAD			;
	mov	cl,ah			;cl���}�N������
	push	cs:[pMML_File]		;�|�C���^���A
	mov	ch,0			;
	call	CREAD			;
	pop	cs:[pMML_File]		;�|�C���^���A
	cmp	ah,30h			;
	jc	cMCD_Macro_Step2	;
	cmp	ah,3Ah			;
	jnc	cMCD_Macro_Step2	;
	call	A2H8R			;
	mov	ch,ah			;ch���ԍ�
cMCD_Macro_Step2:			;
	cmp	bx,cx			;
	jnz	cMCD_Macro_Loop0	;

;���}�N��
	add	cs:[cMCD_MacroCount],2	;
	mov	bx,cs:[cMCD_MacroCount]	;�}�N���̃|�C���^
	cmp	bx,10			;
	jc	cMCD_Macro_Step3	;�}�N�����Ăт����B
	jmp	MACRO_ERROR2		;
cMCD_Macro_Step3:			;
	mov	cs:[cMCD_MacroAdr + bx],dx

;�����W�X�^�̕��A
	popa				;���W�X�^���A
cMCD_Macro_EndM:			;
	ret				;
;---------------------------------------------------------------
cMCD_MacroEndChk:			;�}�N���̏I���H
	pusha				;

	cmp	cs:[cMCD_MacroCount],-2	;�}�N���̃X�^�b�N�͋�H
	jz	cMCD_MacroEndChk_End	;�󂾂�����A�I��

	mov	bx,cs:[cMCD_MacroCount]	;�}�N���̃|�C���^
	sub	cs:[cMCD_MacroCount],2	;
	mov	ax,cs:[cMCD_MacroAdr + bx]
	mov	cs:[pMML_File],ax	;

	stc				;Cy��'h'
cMCD_MacroEndChk_End:			;
	popa				;���W�X�^���A
	ret				;
;---------------------------------------------------------------
cMCD_st:
	pusha				;

;���l�ǂݍ���
	call	A2H16R			;cx��Tempo
	mov	cx,ax			;
	xor	bx,bx			;bx��TimeBase
	mov	bl,ds:[0].WTD_Mus_TimeBase

;���Z
	mov	dx,0000ah		;
	mov	ax,0fc80h		;
	div	bx			;
	xor	dx,dx			;
	div	cx			;ax��12000 * 60 / (Tempo * TimeBase)

;��������
	call	CSET16			;

;�I��
	popa				;
	ret				;
;---------------------------------------------------------------
cMCD_lB:				;'B'�R�}���h
	push	ax			;
	
	call	A2H16R			;
	call	CSET16			;

	call	CREAD			;�J���}����������A
	cmp	ah,','			;�x���h�����W
	jnz	cMCD_lB_End		;

	push	bx			;�r�b�g�Z�b�g
	mov	bx,CS:[pWTD_File]	;
	dec	bx			;
	dec	bx			;
	or	ds:[bx],8000h		;
	pop	bx			;

	call	A2H8R			;
	call	CSET			;


cMCD_lB_End:				;
	pop	ax			;
	ret				;
;---------------------------------------------------------------
cMCD_lL:				;'L'�R�}���h
	push	ax			;
	
	mov	ax,cs:[pWTD_File]	;
	mov	cs:[cMCD_LoopL],ax	;
	
	pop	ax			;�A�h���X�̕ۑ�
	ret				;
;---------------------------------------------------------------
cMCD_lX_CRC	db	?		;
cMCD_lX_Flag	db	?		;
cMCD_lX:				;'X'�R�}���h
	pusha				;

	mov	cs:[cMCD_lX_CRC],0	;CRC��0x00�ɂ���B
	mov	cs:[cMCD_lX_Flag],0	;Flag��0x00�ɂ���B

	mov	ah,0f0h			;�G�N�X�N���[�V�u�J�n
	call	cset			;

cMCD_lX_Loop:				;
	push	cs:[pMML_File]		;
	call	CREAD			;
	pop	cs:[pMML_File]		;
	cmp	ah,'}'			;
	jz	cMCD_lX_StepEnd		;
	cmp	ah,'('			;
	jnz	cMCD_lX_Step0		;
	mov	cs:[cMCD_lX_Flag],1	;Flag��0x01�ɂ���B
cMCD_lX_Step0:				;
	cmp	ah,')'			;
	jnz	cMCD_lX_Step1		;
	mov	cs:[cMCD_lX_Flag],0	;Flag��0x00�ɂ���B
	push	ax			;
	mov	cl,cs:[cMCD_lX_CRC]	;
	and	cl,07fh			;
	mov	al,128			;
	sub	al,cl			;
	mov	ah,al			;
	call	CSET			;CRC�̏o��
	pop	ax			;
cMCD_lX_Step1:				;
	cmp	ah,030h			;
	jc	cMCD_lX_Step9		;
	cmp	ah,03ah			;
	jnc	cMCD_lX_Step9		;
	call	A2H8R			;�ǂݍ���
	call	CSET			;
	cmp	cs:[cMCD_lX_Flag],1	;
	jnz	cMCD_lX_Step2		;
	add	cs:[cMCD_lX_CRC],ah	;
cMCD_lX_Step2:				;
	jmp	cMCD_lX_Loop		;
cMCD_lX_Step9:				;
	inc	cs:[pMML_File]		;
	jmp	cMCD_lX_Loop		;

cMCD_lX_StepEnd:			;
	mov	ah,0f7h			;�G�N�X�N���[�V�u�I��
	call	cset			;

	popa				;
	ret				;
;---------------------------------------------------------------
cMCD_lZ:				;'Z'�R�}���h
	pusha				;

	mov	dx,cs:[pWTD_File]	;
	xor	cx,cx			;
	call	CSET			;�|�C���^�ړ�

cMCD_lZ_Loop:				;
	inc	cx			;
	call	A2H8R			;�ǂݍ���
	call	CSET			;

	push	cs:[pMML_File]		;
	call	CREAD			;
	pop	cs:[pMML_File]		;
	cmp	ah,'}'			;
	jnz	cMCD_lZ_Loop		;

	push	cs:[pWTD_File]		;
	mov	cs:[pWTD_File],dx	;
	mov	ah,cl			;
	call	CSET			;
	pop	cs:[pWTD_File]		;

	popa				;
	ret				;
;---------------------------------------------------------------
cMCD_Loop_Start:			;
	push	ax			;
	push	bx			;

	add	cs:[cMCD_LoopCount],2	;�|�C���^�E�C���N�������g

	cmp	cs:[cMCD_LoopCount],18	;�l�X�g�W�񒴂����H
	jc	cMCD_Loop_Start_Step1	;
	jmp	LOOP_ERROR		;��������A�G���[�B
cMCD_Loop_Start_Step1:			;
	mov	ax,cs:[pWTD_File]	;�|�C���^�ǂݍ��݁B
	mov	bx,cs:[cMCD_LoopCount]	;

	mov	cs:[cMCD_LoopEnd + bx],ax

	mov	ah,2			;�Ƃ肠�����A�Q���������݁B
	call	cset			;

	pop	bx			;
	pop	ax			;
	ret				;
;---------------------------------------------------------------
cMCD_Loop_End:				;
	push	ax			;
	push	bx			;

	mov	bx,cs:[cMCD_LoopCount]	;�|�C���^�ǂݍ��݁B

	mov	ax,cs:[cMCD_LoopEnd + bx]
	inc	ax			;1�i�񂾏ꏊ���������݁B
	call	cset16			;�߂�A�h���X�̏������݁B
	dec	ax			;

	push	cs:[pWTD_File]		;
	mov	cs:[pWTD_File],ax	;
	call	A2H8R			;
	call	CSET			;���[�v��
	pop	cs:[pWTD_File]		;

	mov	ax,cs:[cMCD_LoopJump + bx]
	cmp	ax,0			;���[�v�A�h���X
	jz	cMCD_Loop_End_End	;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	mov	cx,cs:[pWTD_File]	;Loop Jump

	push	cs:[pWTD_File]		;
	mov	cs:[pWTD_File],ax	;
	mov	ax,cx			;
	call	cset16			;
	pop	cs:[pWTD_File]		;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
cMCD_Loop_End_End:			;
	xor	ax,ax			;ax��0
	mov	cs:[cMCD_LoopJump + bx],ax
	mov	cs:[cMCD_LoopEnd + bx],ax
	sub	bx,2			;
	mov	cs:[cMCD_LoopCount],bx	;�|�C���^��������

	pop	bx			;
	pop	ax			;
	ret				;
;---------------------------------------------------------------
cMCD_Loop_Jump:				;
	push	ax			;
	push	bx			;

	mov	ax,cs:[pWTD_File]	;�|�C���^�ǂݍ��݁B
	mov	bx,cs:[cMCD_LoopCount]	;

	mov	cs:[cMCD_LoopJump + bx],ax

	call	cset16			;

	pop	bx			;
	pop	ax			;
	ret				;
;---------------------------------------------------------------
cMCD_tranceFlag	db	00h
cMCD_trance:
	pusha				;���W�X�^�ۑ�

	mov	bx,offset cMCD_tranceFlag
	call	CREAD			;�ǂݍ���
	cmp	ah,'='			;
	jz	cMCD_tranceNatu		;
	cmp	ah,'+'			;
	jz	cMCD_tranceSharp	;
	cmp	ah,'#'			;
	jz	cMCD_tranceSharp	;
	cmp	ah,'-'			;
	jz	cMCD_tranceFlat		;
	cmp	ah,'b'			;
	jz	cMCD_tranceFlat		;
cMCD_tranceLoop:
	call	CREAD			;
	cmp	ah,'}'			;
	jz	cMCD_tranceEnd		;
	sub	ah,'c'			;
	jnc	cMCD_tranceStep0	;
	add	ah,7			;
cMCD_tranceStep0:			;
	mov	cl,ah			;
	mov	al,01h			;
	cmp	cl,0			;
	jz	cMCD_tranceStep1	;
	shl	al,cl			;
cMCD_tranceStep1:			;
	or	cs:[cMCD_tranceFlag],al	;
	jmp	cMCD_tranceLoop		;

cMCD_tranceSharp:				;
	mov	cs:[cMCD_tranceFlag],000h	;������
	jmp	cMCD_tranceLoop			;

cMCD_tranceFlat:				;
	mov	cs:[cMCD_tranceFlag],080h	;������
	jmp	cMCD_tranceLoop			;

cMCD_tranceNatu:				;
	mov	cs:[cMCD_tranceFlag],000h	;������

cMCD_tranceEnd:
	mov	ah,cs:[cMCD_tranceFlag]	;
	call	CSET			;

	popa				;���W�X�^���A
	ret
;===============================================================|
;			�R�}���h�E�R���p�C��			|
;===============================================================|
c_Command:				;�p�[�g�R���p�C��
	pusha				;���W�X�^�ۑ�

;�p�[�g���ǂݍ���
	xor	cx,cx			;
	mov	cl,byte ptr ds:[0].WTD_Mus_Part

;-----------------------------------------------------------------------
;�g���b�N�R���p�C���J�n
c_Command_Loop0:

	push	cx			;���W�X�^�ۑ�

;�����ݒ�
;�R���p�C�����̃`�����l���֘A
	mov	byte ptr cs:[cMCD_ChannelMML],0ffh
	mov	byte ptr cs:[cMCD_ChannelWTD],ch
;�������[�v�A�h���X
	mov	word ptr cs:[cMCD_LoopL],0000h
;����
	mov	word ptr cs:[dMCD_lengs],48
;���[�v
	mov	word ptr cs:[cMCD_LoopCount],0
	mov	bx,14			;
c_Command_Loop6:
	mov	word ptr cs:[cMCD_LoopEnd+bx],0
	mov	word ptr cs:[cMCD_LoopJump+bx],0
	sub	bx,2			;
	jnc	c_Command_Loop6		;

;MML�t�@�C���̐擪�ɂ����B
	xor	bx,bx			;
	mov	cs:[pMML_File],bx	;bx
;�g���b�N�擪�A�h���X�ۑ�
	mov	ax,cs:[pWTD_File]	;
	mov	bl,byte ptr cs:[cMCD_ChannelWTD]
	shl	bx,1			;
	add	bx,WTD_Mus_PartAdr	;
	mov	ds:[bx],ax		;

;�R�}���h����
;�R�}���h���ʂ̓ǂݍ���
c_Command_Loop1:			;

;�`�����l������v���Ȃ�������A���s��T���B
	mov	ah,cs:[cMCD_ChannelMML]	;
	mov	al,cs:[cMCD_ChannelWTD]	;
	cmp	al,ah			;��r
	jz	c_Command_Step0		;�`�����l������v���Ȃ�������A
	call	cMCD_CRS		;���s��T���B
c_Command_Step0:			;

	xor	di,di			;di���ϊ���`�A�h���X�̃|�C���^
	mov	cx,cs:[offset c_Command_Adrs + di]
					;������`�F�b�N�̃J�E���^
;�|�C���^�ǂݍ���
c_Command_Loop2:			;
	push	cs:[pMML_File]		;�|�C���^�ۑ�
	add	di,2			;�|�C���^�C���N�������g(Word)
	mov	si,cs:[offset c_Command_Adrs + di]	;si���ϊ���`�A�h���X
;�P�����ǂݍ���
c_Command_Loop3:			;
	call	cread			;MML�t�@�C������P�����ǂݍ���
	jnc	c_Command_Step1		;
	pop	cs:[pMML_File]		;�|�C���^���A
	jmp	c_Command_End		;MML�t�@�C����[EOF]�Ȃ�ΏI��
c_Command_Step1:			;
;�P�����`�F�b�N�i00h�܂ށj
	mov	al,cs:[si]		;
	inc	si			;
	cmp	al,00h			;�����I���H
	jz	c_Command_Step2		;�Ȃ�΁A�������v�ŏ������s�B
	cmp	ah,al			;������v�H
	jz	c_Command_Loop3		;�Ȃ�΁A�����`�F�b�N�B
;�����`�F�b�N�ň�v���Ȃ������ꍇ�B
	pop	cs:[pMML_File]		;�|�C���^���A
	sub	cx,1			;�J�E���^�[�E�f�B�N�������g
	jnz	c_Command_Loop2		;���̃R�}���h�Ŕ�r
	inc	CS:[pMML_File]		;�|�C���^�E�C���N�������g
	mov	ax,CS:[szMML_File]	;
	cmp	ax,CS:[pMML_File]	;MML�t�@�C���̏I���`�F�b�N
	jnc	c_Command_Loop1		;�������r�J�n�B
	jmp	c_Command_End		;MML�t�@�C����[EOF]�Ȃ�ΏI��
;-----------------------------------------------------------------------
;�R�}���h�����B
c_Command_Step2:			;
	pop	ax			;'pMML_File'�|�C���^�̕��A(�l�͖߂���)
	push	ds			;�Z�O�����g�̕ۑ�

;�o�[�W������r
	mov	ax,cs:[si]		;
	add	si,2			;�o�[�W�����ǂݍ���
	mov	cx,ds:[0].WTD_Mus_Version
	xchg	ah,al			;�t�ɓ����Ă���B
	xchg	ch,cl			;(80�`���ł͂Ȃ�Word)
	cmp	cx,ax			;��r�B
	jnc	c_Command_Step10	;
	xchg	ah,al			;���̃R�}���h�̃o�[�W�����̕���
	mov	ds:[0].WTD_Mus_Version,ax
c_Command_Step10:			;������΁A���l�Z�b�g�B

;�R�}���h�o��
c_Command_Loop5:			;
	mov	ah,cs:[si]		;al���R�}���h
	inc	si			;
	cmp	ah,0			;�O�Ȃ�ΏI���B
	jz	c_Command_Step11	;
	call	CSET			;
	jmp	c_Command_Loop5		;
c_Command_Step11:

;�|�C���^�����ɖ߂��B
	dec	cs:[pMML_File]		;�|�C���^�E�f�B�N�������g

;�R�}���h����
c_Command_Loop4:			;
	mov	al,cs:[si]		;al���R�}���h
	inc	si			;
	cmp	al,00h			;�I��
	jnz	c_Command_Step3		;
	jmp	c_Command_Step99	;
c_Command_Step3:			;
	cmp	al,010h			;4bit �~ 2
	jnz	c_Command_Step4		;
	call	A2H8R			;
	and	ah,0fh			;
	mov	al,ah			;
	call	A2H8R			;
	and	ah,0fh			;
	shl	ah,4			;
	or	ah,al			;
	call	cset			;
	jmp	c_Command_Loop4		;
c_Command_Step4:			;
	cmp	al,011h			;Byte
	jnz	c_Command_Step5		;
	call	A2H8R			;
	call	CSET			;
	jmp	c_Command_Loop4		;
c_Command_Step5:			;
	cmp	al,012h			;Word
	jnz	c_Command_Step6		;
	call	A2H16R			;
	call	CSET16			;
	jmp	c_Command_Loop4		;
c_Command_Step6:			;
	cmp	al,020h			;Step
	jnz	c_Command_Step7		;
	call	cread			;1�����ǂݍ��݁B
	dec	cs:[pMML_File]		;(�|�C���^�́A���炳�Ȃ��B)
	xchg	ax,cx			;
	call	A2H16R			;cx������
	xchg	ax,cx			;
	cmp	ah,'%'			;���l�̑O��'%'�������Ă���H
	mov	ax,cx			;ax�����l��ۑ��B
	jz	c_Command_Step6_Step1	;
	xor	ax,ax			;
	mov	al,ds:[0].WTD_Mus_TimeBase
	shl	ax,2			;dx:ax���S�������̕������B
	xor	dx,dx			;
	div	cx			;ax��Step���B
c_Command_Step6_Step1:			;
	mov	cl,cs:[si]		;al���R�}���h
	inc	si			;
	cmp	cl,01h			;
	jnz	c_Command_Step6_Step3	;
	mov	cs:[dMCD_lengs],ax	;
c_Command_Step6_Step3:			;
	cmp	ax,00FFh		;
	jnc	c_Command_Step6_Step2	;
	mov	ah,al			;
	call	cset			;
	jmp	c_Command_Loop4		;
c_Command_Step6_Step2:			;
	push	ax			;
	mov	ah,0ffh			;
	call	cset			;
	pop	ax			;
	call	cset16			;
	jmp	c_Command_Loop4		;
c_Command_Step7:			;
	cmp	al,080h			;Key
	jc	c_Command_Step8		;
	cmp	al,088h			;al��Command
	jnc	c_Command_Step8		;
	call	c_Command_KeyCode	;
	jmp	c_Command_Loop4		;
c_Command_Step8:			;
	cmp	al,0F0h			;Call (Other Program)
	jnz	c_Command_Step9		;
	mov	dx,cs:[si]		;
	add	si,2			;
	call	dx			;
	jmp	c_Command_Loop4		;
c_Command_Step9:			;

;�R���p�C���������[�v
	jmp	c_Command_Loop4		;

;���߃R���p�C�������I��
c_Command_Step99:			;
	pop	ds			;�Z�O�����g�̕��A
	jmp	c_Command_Loop1		;�������r�J�n�B
;-----------------------------------------------------------------------
;�g���b�N�I��
c_Command_End:

;�g���b�N�I���̏�������
	mov	ah,'L'			;
	call	cset			;
	mov	ax,word ptr cs:[cMCD_LoopL]
	call	cset16			;

	pop	cx			;

	inc	ch			;
	sub	cl,1			;
	jz	c_Command_End99		;
	jmp	c_Command_Loop0		;

;-----------------------------------------------------------------------
;�I��
c_Command_End99:			;
	popa				;���W�X�^���A
	ret				;
;=======================================================================
;���K
;	al��Command Code
;	dx��
cCKD_Key	db	?		;Key
cCKD_lengs	dw	?		;lengs
c_Command_KeyCode:
	pusha				;

	mov	dx,cs:[dMCD_lengs]	;dx�������̉��K�B
	mov	cs:[cCKD_lengs],dx	;
	mov	byte ptr cs:[cCKD_Key],al	;�R�}���h�̕ۑ��B
	call	CREAD			;�ǂݍ��݁B
	dec	cs:[pMML_File]		;(�|�C���^�͂��炳���B)

	cmp	ah,'#'			;
	jnz	c_Command_KeyCode_Step1	;
	or	byte ptr cs:[cCKD_Key],008h	;
	inc	cs:[pMML_File]		;
	call	CREAD			;�ǂݍ��݁B
	dec	cs:[pMML_File]		;(�|�C���^�͂��炳���B)
	jmp	c_Command_KeyCode_Step7	;
c_Command_KeyCode_Step1:		;
	cmp	ah,'+'			;
	jnz	c_Command_KeyCode_Step2	;
	or	byte ptr cs:[cCKD_Key],008h	;
	inc	cs:[pMML_File]		;
	call	CREAD			;�ǂݍ��݁B
	dec	cs:[pMML_File]		;(�|�C���^�͂��炳���B)
	jmp	c_Command_KeyCode_Step7	;
c_Command_KeyCode_Step2:		;
	cmp	ah,'-'			;
	jnz	c_Command_KeyCode_Step3	;
	or	byte ptr cs:[cCKD_Key],010h	;
	inc	cs:[pMML_File]		;
	call	CREAD			;�ǂݍ��݁B
	dec	cs:[pMML_File]		;(�|�C���^�͂��炳���B)
	jmp	c_Command_KeyCode_Step7	;
c_Command_KeyCode_Step3:
	cmp	ah,'='			;
	jnz	c_Command_KeyCode_Step7	;
	or	byte ptr cs:[cCKD_Key],018h	;
	inc	cs:[pMML_File]		;
	call	CREAD			;�ǂݍ��݁B
	dec	cs:[pMML_File]		;(�|�C���^�͂��炳���B)
;	jmp	c_Command_KeyCode_Step7	;
c_Command_KeyCode_Step7:		;
	cmp	ah,'%'			;
	jz	c_Command_KeyCode_Step7_Step1
	cmp	ah,30h			;
	jc	c_Command_KeyCode_Step4	;
	cmp	ah,3Ah			;
	jnc	c_Command_KeyCode_Step4	;
c_Command_KeyCode_Step7_Step1:		;
	call	cread			;1�����ǂݍ��݁B
	dec	cs:[pMML_File]		;(�|�C���^�́A���炳�Ȃ��B)
	xchg	ax,cx			;
	call	A2H16R			;cx������
	dec	cs:[pMML_File]		;(�|�C���^�́A���炳�Ȃ��B)
	or	ax,ax			;������0��������A���Z�Ȃ��B
	jz	c_Command_KeyCode_Step7_Step2
	xchg	ax,cx			;
	cmp	ah,'%'			;���l�̑O��'%'�������Ă���H
	mov	ax,cx			;ax�����l��ۑ��B
	jz	c_Command_KeyCode_Step7_Step2
	xor	ax,ax			;
	mov	al,ds:[0].WTD_Mus_TimeBase
	shl	ax,2			;dx:ax���S�������̕������B
	xor	dx,dx			;
	div	cx			;ax��Step���B
c_Command_KeyCode_Step7_Step2:		;
	mov	dx,ax			;
	mov	cs:[cCKD_lengs],dx	;
	inc	cs:[pMML_File]		;
	call	CREAD			;�ǂݍ��݁B
	dec	cs:[pMML_File]		;
c_Command_KeyCode_Step4:		;
	cmp	ah,'.'			;
	jnz	c_Command_KeyCode_Step5	;
	shr	word ptr cs:[cCKD_lengs],1
	add	dx,word ptr cs:[cCKD_lengs]
	inc	cs:[pMML_File]		;
	call	CREAD			;�ǂݍ��݁B
	dec	cs:[pMML_File]		;(�|�C���^�͂��炳���B)
	jmp	c_Command_KeyCode_Step4	;
c_Command_KeyCode_Step5:		;
	cmp	ah,'&'			;
	jnz	c_Command_KeyCode_Step6	;
	or	byte ptr cs:[cCKD_Key],020h	;
c_Command_KeyCode_Step6:		;
	cmp	dx,cs:[dMCD_lengs]	;
	jz	c_Command_KeyCode_Step8	;
	or	byte ptr cs:[cCKD_Key],040h	;
c_Command_KeyCode_Step8:		;
	mov	ah,cs:[cCKD_Key]	;
	call	CSET			;�������݁B
	test	byte ptr cs:[cCKD_Key],040h	;
	jz	c_Command_KeyCode_End	;

	mov	ax,dx			;

	cmp	ax,00FFh		;
	jnc	c_Command_KeyCode_Step9	;
	mov	ah,al			;
	call	cset			;
	jmp	c_Command_KeyCode_End	;
c_Command_KeyCode_Step9:
	push	ax			;
	mov	ah,0ffh			;
	call	cset			;
	pop	ax			;
	call	cset16			;

c_Command_KeyCode_End:			;
	popa				;
	ret				;