;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Main program				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|

	ASSUME	CS:CODE

CODE	SEGMENT

.186

	org	0000h
WanderSwanTotalSoundDriver_:
;=======================================================================|
;				define					|
;=======================================================================|
;
;	�@���t�J�n�t�@���N�V�����̂Ƃ���ŁA�`�F�b�N����B
;	�p�[�g����ǉ�����ꍇ�́A���̕��������[�N���m�ۂ��鎖�B
;
ifdef	hyoka	;------------------------
WtdIL_Name		equ	'WTD_h',0
MusicMaxPart		equ	4	;�����ł�4 �p�[�g
else	;--------------------------------
WtdIL_Name		equ	'WTD',0
MusicMaxPart		equ	20	;���i�ł�20�p�[�g
endif	;--------------------------------
EffectMaxPart		equ	3	;���ʉ���3 �p�[�g
;=======================================================================|
;				Start					|
;=======================================================================|
include process.inc	;��`�t�@�C���@�v���Z�X
include	service.inc	;��`�t�@�C���@���荞��
include	timer.inc	;��`�t�@�C���@�^�C�}�[
include	comm.inc	;��`�t�@�C���@�ʐM
include	sound.inc	;��`�t�@�C���@�T�E���h
include	bank.inc	;��`�t�@�C���@�o���N
include	wtd_def.inc	;��`�t�@�C���@�h���C�o�[
include	wtd_ver.inc	;�o�[�W�������
include	wtd_ilf.asm	;IL�\����,ILinfo�\����,IL�t�@���N�V����
include	wtd_int.asm	;���荞�݁@���C�����[�`��
include	wtd_icmd.asm	;���荞�݁@�R�}���h���ߕ�
include	wtd_idev.asm	;���荞�݁@�f�o�C�X���䕔
include	wtd_icom.asm	;���荞�݁@�V���A���ʐM����
include	wtd_tim.asm	;�^�C�}�[����p�T�u���[�`��
include	wtd_snd.asm	;�T�E���h����p�T�u���[�`��
include	wtd_com.asm	;�V���A������p�T�u���[�`��
;=======================================================================|
;				End					|
;=======================================================================|
CODE	ENDS
	END	WanderSwanTotalSoundDriver_