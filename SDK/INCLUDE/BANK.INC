;=======================================================================|
;									|
;			�v�����������r������				|
;				�ėp��`�t�@�C��			|
;				�a�h�n�r�ҁ@�|�o���N����		|
;									|
;						A.Watanabe (S.W.)	|
;									|
;=======================================================================|
;===============�@�\�ԍ���`	�iAH���W�X�^�ɑ�����A���荞�݂�������B�j
BANK_SET_MAP			equ	00h	;�o���N�}�b�s���O�ݒ�
BANK_GET_MAP			equ	01h	;�o���N�}�b�s���O�擾
BANK_READ_BYTE			equ	02h	;�o���N�w��P�o�C�g�ǂ݂���
BANK_WRITE_BYTE			equ	03h	;�o���N�w��P�o�C�g��������
BANK_READ_WORD			equ	04h	;�o���N�w��P���[�h�ǂ݂���
BANK_WRITE_WORD			equ	05h	;�o���N�w��P���[�h��������
BANK_READ_BLOCK			equ	06h	;�o���N�w��u���b�N�ǂ݂���
BANK_WRITE_BLOCK		equ	07h	;�o���N�w��u���b�N��������
BANK_FILL_BLOCK			equ	08h	;�o���N�w��u���b�N�t�B��
BANK_ERASE_FLASH		equ	09h	;�ׯ���т��ׯ���i���[�J�����J�j
;===============bank identifiers
BANK_SRAM			equ	0	;�o���N SRAM
BANK_ROM0			equ	1	;�o���N ROM0
BANK_ROM1			equ	2	;�o���N ROM1

BANK_SRAM_ADDRESS		equ	01000h	;SRAM�@�̃Z�O�����g�A�h���X
BANK_ROM0_ADDRESS		equ	02000h	;ROM0�@�̃Z�O�����g�A�h���X
BANK_ROM1_ADDRESS		equ	03000h	;ROM1�@�̃Z�O�����g�A�h���X

BANK_MAX_BANKS			equ	7Fh	;�o���N�̍ő�

BANK_SOFTFS			equ	00h	;SRAM FreyaOS Filesys
BANK_USERDS1			equ	01h	;SRAM FreyaOS Process 2
BANK_USERDS0			equ	02h	;SRAM FreyaOS Peocess 1
BANK_OSWORK			equ	03h	;SRAM FreyaOS Work

;#define sram_get_map()		bank_get_map(BANK_SRAM)
SRAM_GET_MAP	macro
		mov	ah,BANK_GET_MAP		;�t�@���N�V�����ԍ�
		mov	bl,BANK_SRAM		;�o���N�̎�ށ@SRAM
		int	INT_BANK		;�t�@���N�V�����Ăяo��
		endm

;#define sram_set_map(bank)	bank_set_map(BANK_SRAM, bank)
SRAM_SET_MAP	macro	bank
		mov	ah,BANK_SET_MAP		;�t�@���N�V�����ԍ�
		mov	bl,BANK_SRAM		;�o���N�̎�ށ@SRAM
		mov	cx,bank			;�o���N�ԍ�
		int	INT_BANK		;�t�@���N�V�����Ăяo��
		endm

;#define rom0_get_map()		bank_get_map(BANK_ROM0)
ROM0_GET_MAP	macro
		mov	ah,BANK_GET_MAP		;�t�@���N�V�����ԍ�
		mov	bl,BANK_ROM0		;�o���N�̎�ށ@ROM0
		int	INT_BANK		;�t�@���N�V�����Ăяo��
		endm

;#define rom0_set_map(bank)	bank_set_map(BANK_ROM0, bank)
ROM0_SET_MAP	macro	bank
		mov	ah,BANK_SET_MAP		;�t�@���N�V�����ԍ�
		mov	bl,BANK_ROM0		;�o���N�̎�ށ@ROM0
		mov	cx,bank			;�o���N�ԍ�
		int	INT_BANK		;�t�@���N�V�����Ăяo��
		endm

;#define rom1_get_map()		bank_get_map(BANK_ROM1)
ROM1_GET_MAP	macro
		mov	ah,BANK_GET_MAP		;�t�@���N�V�����ԍ�
		mov	bl,BANK_ROM1		;�o���N�̎�ށ@ROM1
		int	INT_BANK		;�t�@���N�V�����Ăяo��
		endm

;#define rom1_set_map(bank)	bank_set_map(BANK_ROM1, bank)
ROM1_SET_MAP	macro	bank
		mov	ah,BANK_SET_MAP		;�t�@���N�V�����ԍ�
		mov	bl,BANK_ROM1		;�o���N�̎�ށ@ROM1
		mov	cx,bank			;�o���N�ԍ�
		int	INT_BANK		;�t�@���N�V�����Ăяo��
		endm