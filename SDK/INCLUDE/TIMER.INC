;=======================================================================|
;									|
;			�v�����������r������				|
;				�ėp��`�t�@�C��			|
;				�a�h�n�r�ҁ@�|�J�����_�^�^�C�}�[����	|
;									|
;						A.Watanabe (S.W.)	|
;									|
;=======================================================================|
;===============�@�\�ԍ���`	�iAH���W�X�^�ɑ�����A���荞�݂�������B�j
RTC_RESET			equ	00h	;RTC���Z�b�g
RTC_GET_DATETIME		equ	01h	;RTC���t���Ԏ擾
RTC_SET_DATETIME		equ	02h	;RTC���t���Ԑݒ�
RTC_SET_DATETIME_STRUCT		equ	03h	;RTC���t���Ԉꊇ�ݒ�
RTC_GET_DATETIME_STRUCT		equ	04h	;RTC���t���Ԉꊇ�擾
RTC_ENABLE_ALARM		equ	05h	;RTC�A���[�����荞�ݐݒ�
RTC_DISABLE_ALARM		equ	06h	;RTC���荞�݉���
TIMER_ENABLE			equ	07h	;�^�C�}�[���荞�ݐݒ�
TIMER_DISABLE			equ	08h	;�^�C�}�[���荞�݋֎~
TIMER_GET_COUNT			equ	09h	;�^�C�}�[�J�E���g�l�擾
;===============�J�����_�E���v
RTC_YEAR			equ	00h	;�N
RTC_MONTH			equ	01h	;��
RTC_DATE			equ	02h	;��
RTC_DAY_OF_WEEK			equ	03h	;�j��
RTC_HOUR			equ	04h	;����
RTC_MIN				equ	05h	;��
RTC_SEC				equ	06h	;�b
;===============timer_type
TIMER_HBLANK			equ	00h	;HBLANK_CoundUp
TIMER_VBLANK			equ	01h	;VBLANK_CountUp
;===============timer_preset_type
TIMER_ONESHOT			equ	00h	;OneShotType
TIMER_AUTOPRESET		equ	01h	;AutoPresetType