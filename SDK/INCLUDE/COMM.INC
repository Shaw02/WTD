;=======================================================================|
;									|
;			�v�����������r������				|
;				�ėp��`�t�@�C��			|
;				�a�h�n�r�ҁ@�|�V���A������		|
;									|
;						A.Watanabe (S.W.)	|
;									|
;=======================================================================|
;===============�@�\�ԍ���`	�iAH���W�X�^�ɑ�����A���荞�݂�������B�j
COMM_OPEN			equ	00h	;�ʐM�J�n
COMM_CLOSE			equ	01h	;�ʐM�I��
COMM_SEND_CHAR			equ	02h	;�P�o�C�g���M
COMM_RECEIVE_CHAR		equ	03h	;�P�o�C�g��M
COMM_RECEIVE_WITH_TIMEOUT	equ	04h	;��ѱ�Ďw��P�o�C�g��M
COMM_SEND_STRING		equ	05h	;�����񑗐M
COMM_SEND_BLOCK			equ	06h	;�u���b�N���M
COMM_RECEIVE_BLOCK		equ	07h	;�u���b�N��M
COMM_SET_TIMEOUT		equ	08h	;�^�C���A�E�g�ݒ�
COMM_SET_BAUDRATE		equ	09h	;�ʐM�{�[���[�g�ݒ�
COMM_GET_BAUDRATE		equ	0ah	;�ʐM�{�[���[�g����
COMM_SET_CANCEL_KEY		equ	0bh	;�ʐM�L�����Z���L�[�p�^�[���ݒ�
COMM_GET_CANCEL_KEY		equ	0ch	;�ʐM�L�����Z���L�[�p�^�[������
COMM_XMODEM			equ	0dh	;X-modem����M
;===============�{�[���[�g
COMM_SPEED_9600			equ	0	; 9600[bps]
COMM_SPEED_38400		equ	1	;38400[bps]
;===============XMODEM structure
xmodeminfo			struc
xmodeminfo_state		dw	?	;���[�J�����J
xmodeminfo_mode			db	?	;
xmodeminfo_retry_c		db	?	;
xmodeminfo_block_c		dw	?	;
xmodeminfo_block_max		dw	?	;
xmodeminfo_block_sixa		dw	?	;
xmodeminfo_bank			dw	?	;
xmodeminfo_offset		dw	?	;
xmodeminfo_timeout_c		dw	?	;
xmodeminfo			ends
;===============XMODEM state codes
XM_START			equ	1	;���[�J�����J
XM_NEGO				equ	2	;
XM_BLOCK			equ	3	;
XM_BLOCK_RETRY			equ	4	;
XM_CLOSE			equ	5	;
XM_ABORT			equ	6	;
XM_DONE				equ	7	;
XM_ERASE_BANK			equ	8	;
;===============XMODEM transfer modes
XMODE_SEND			equ	0	;���M�@���[�J�����J
XMODE_RECEIVE			equ	1	;��M
XMODE_SEND_ENCRYPTED		equ	2	;
XMODE_RECEIVE_ENCRYPTED		equ	3	;
XMODE_AUTO_ERASE		equ	4	;
;===============SIO error codes
ERR_SIO_OK			equ	0000h	;�G���[����
ERR_SIO_BUSY			equ	8100h	;�r�W�[
ERR_SIO_TIMEOUT			equ	8101h	;�^�C���A�E�g
ERR_SIO_OVERRUN			equ	8102h	;�I�[�o�[����
ERR_SIO_CANCEL			equ	8103h	;�L�����Z��
;===============XMODEM error codes
ERR_XM_STATECODE		equ	8104h	;�X�e�[�^�X�R�[�h
ERR_XM_CANCELED			equ	8105h	;�L�����Z�����ꂽ�B
ERR_XM_BLOCK_LOST		equ	8106h	;�u���b�N���������B
ERR_XM_TOO_LARGE		equ	8107h	;�傫�����B