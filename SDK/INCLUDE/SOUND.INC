;=======================================================================|
;									|
;			�v�����������r������				|
;				�ėp��`�t�@�C��			|
;				�a�h�n�r�ҁ@�|�T�E���h����		|
;									|
;						A.Watanabe (S.W.)	|
;									|
;=======================================================================|
;===============�@�\�ԍ���`	�iAH���W�X�^�ɑ�����A���荞�݂�������B�j
SOUND_INIT			equ	00h		;�T�E���h������
SOUND_SET_CHANNEL		equ	01h		;�o�́E���[�h�ݒ�
SOUND_GET_CHANNEL		equ	02h		;�o�́E���[�h�擾
SOUND_SET_OUTPUT		equ	03h		;�T�E���h�o�͐ݒ�
SOUND_GET_OUTPUT		equ	04h		;�T�E���h�o�͎擾
SOUND_SET_WAVE			equ	05h		;�g�`�ݒ�
SOUND_SET_PITCH			equ	06h		;�T�E���h���g���ݒ�
SOUND_GET_PITCH			equ	07h		;�T�E���h���g������
SOUND_SET_VOLUME		equ	08h		;�T�E���h���ʐݒ�
SOUND_GET_VOLUME		equ	09h		;�T�E���h���ʏ���
SOUND_SET_SWEEP			equ	0Ah		;�����3�����ߐݒ�
SOUND_GET_SWEEP			equ	0Bh		;�����3�����ߏ���
SOUND_SET_NOISE			equ	0Ch		;�����4ɲ�ސݒ�
SOUND_GET_NOISE			equ	0Dh		;�����4ɲ�ޏ���
SOUND_GET_RANDOM		equ	0Eh		;�����4�^�������ް�����