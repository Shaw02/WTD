;=======================================================================|
;									|
;			�v�����������r������				|
;				�ėp��`�t�@�C��			|
;				���荞�ݕ�				|
;									|
;						A.Watanabe (S.W.)	|
;									|
;=======================================================================|
;************************************************************************
;*									*
;*			�a�h�n�r�t�@���N�V������`			*
;*									*
;************************************************************************
INT_BIOS_VECTOR_BASE		equ	010h
;===============���荞�ݔԍ���`
INT_EXIT	equ	INT_BIOS_VECTOR_BASE + 0	;�v���O�����̏I��
INT_KEY		equ	INT_BIOS_VECTOR_BASE + 1	;�L�[����
INT_DISP	equ	INT_BIOS_VECTOR_BASE + 2	;��ʐ���
INT_TEXT	equ	INT_BIOS_VECTOR_BASE + 3	;�e�L�X�g����
INT_COMM	equ	INT_BIOS_VECTOR_BASE + 4	;�V���A���ʐM����
INT_SOUND	equ	INT_BIOS_VECTOR_BASE + 5	;�T�E���h����
INT_TIMER	equ	INT_BIOS_VECTOR_BASE + 6	;�J�����_�^�^�C�}����
INT_SYSTEM	equ	INT_BIOS_VECTOR_BASE + 7	;�V�X�e������
INT_BANK	equ	INT_BIOS_VECTOR_BASE + 8	;�o���N����


;************************************************************************
;*									*
;*			�n�[�h�E�F�A���荞�ݒ�`			*
;*									*
;************************************************************************
INT_HARDHAEW_VECTOR_BASE	equ	028h
;===============���荞�ݔԍ���`
SYS_INT_SENDREADY		equ	0	;�V���A�����M�f�[�^�G���v�e�B�[
SYS_INT_KEY			equ	1	;�L�[���荞��
SYS_INT_CASETTE			equ	2	;�J�Z�b�g���荞��
SYS_INT_RECEIVEREADY		equ	3	;�V���A����M�f�[�^���f�B�[
SYS_INT_DISPLINE		equ	4	;�`�惉�C���ԍ����m���荞��
SYS_INT_VBLANK_COUNTUP		equ	5	;���������^�C�}�[���荞��
SYS_INT_VBLANK			equ	6	;�����������ԊJ�n
SYS_INT_HBLANK_COUNTUP		equ	7	;���������^�C�}�[���荞��

INT_SENDREADY		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_SENDREADY
INT_KEY_PUSH		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_KEY
INT_CASETTE		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_CASETTE
INT_RECEIVEREADY	equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_RECEIVEREADY
INT_DISPLINE		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_DISPLINE
INT_VBLANK_COUNTUP	equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_VBLANK_COUNTUP
INT_VBLANK		equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_VBLANK
INT_HBLANK_COUNTUP	equ INT_HARDHAEW_VECTOR_BASE + SYS_INT_HBLANK_COUNTUP


;************************************************************************
;*									*
;*			�V�X�e�����荞�ݒ�`				*
;*									*
;************************************************************************
INT_SYSCALL_VECTOR_BASE		equ	030h
;===============���荞�ݔԍ���`
INT_PROCESS	equ	INT_SYSCALL_VECTOR_BASE + 0	;�s��
INT_FILESYS	equ	INT_SYSCALL_VECTOR_BASE + 1	;�s��
INT_ILIB	equ	INT_SYSCALL_VECTOR_BASE + 2	;�s��

