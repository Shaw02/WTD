;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Serial Control				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
ifndef	hyoka
;===============================================================|
;			I/O Address				|
;===============================================================|
COMM_DATA		equ	0b1h	;Send / Receive data
COMM_STATUS		equ	0b3h	;Serial Status
;===============================================================|
;			INT Status bit flag			|
;===============================================================|
INT_CommSendSet		equ	001h	;CommSend�l�Z�b�g�@(or)
INT_CommSendReset	equ	0feh	;CommSend�l���Z�b�g(and)
;===============================================================|
;			COMM Status bit flag			|
;===============================================================|
COMM_Receive		equ	001h	;��M�f�[�^�L��i��M�j
COMM_OverRun		equ	002h	;�I�[�o�[�����E�G���[
COMM_SendEmpty		equ	004h	;���M�o�b�t�@��i���M�j
COMM_OrReset		equ	020h	;�I�[�o�[�����E�G���[�̃��Z�b�g
COMM_Baudrate9K		equ	000h	;�{�[���[�g�i 9600 [bps])(+)
COMM_Baudrate38k	equ	040h	;�{�[���[�g�i38400 [bps])(+)
COMM_Enable		equ	080h	;�ʐM�C�l�[�u��(or)
COMM_Disable		equ	07fh	;�ʐM�f�B�Z�[�u��(and)
;===============================================================|
;			�萔					|
;===============================================================|
COMM_TimeOut		equ	0ffffh	;�^�C���A�E�g�̎���
;===============================================================|
;			�ʐM������J��				|
;===============================================================|
;	������							|
;		����						|
;	�Ԃ�l							|
;		����						|
;	����							|
;		�����38400bps�ɐݒ�A�ʐM������J���B		|
;===============================================================|
	even				;�����A�h���X�z�u
C_Open	proc near			;
	push	ax			;
	push	bx			;
	
	mov	al,COMM_OrReset + COMM_Baudrate38k + COMM_Enable
	out	COMM_Status,al		;

	pop	bx			;
	pop	ax			;
	ret				;
C_Open	endp				;
;===============================================================|
;			�ʐM��������			|
;===============================================================|
;	������							|
;		����						|
;	�Ԃ�l							|
;		����						|
;	����							|
;		�ʐM��������B				|
;===============================================================|
	even				;�����A�h���X�z�u
C_Close	proc near			;
	push	ax			;

C_Close_2:				;
	in	al,COMM_Status		;�X�e�[�^�X�ǂݍ���
	test	al,COMM_Enable		;�ʐM�@�\�̓C�l�[�u���H
	jz	C_Close_1		;
	test	al,COMM_SendEmpty	;���M�f�[�^��H
	jz	C_Close_2		;��łȂ���΁A��ɂȂ�܂ő҂B
C_Close_1:				;
	and	al,COMM_Disable		;�ʐM�f�B�Z�[�u���ݒ�B
	out	COMM_Status,al		;�o��

	in	al,Int_Enable		;
	and	al,INT_CommSendReset	;�V���A�����M�G���v�e�B�[
	out	Int_Enable,al		;���荞�݋֎~

	pop	ax			;
	ret				;
C_Close	endp				;
;===============================================================|
;			1 byte���M				|
;===============================================================|
;	������							|
;		al	send data				|
;	�Ԃ�l							|
;		����						|
;	����							|
;		����Ƀf�[�^���o�͂���B			|
;===============================================================|
	even				;�����A�h���X�z�u
C_Send	proc near			;
	pushf				;
	push	es			;
	push	di			;
	push	bx			;
	push	ax			;���W�X�^�ۑ�
	cli

	in	al,Int_Enable		;
	and	al,INT_CommSendReset	;�V���A�����M�G���v�e�B�[
	out	Int_Enable,al		;���荞�݋֎~

	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	cmp	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	jnz	C_Send_0		;FIFO�o�b�t�@����H

	in	al,COMM_Status		;�X�e�[�^�X�ǂݍ���
	test	al,COMM_SendEmpty	;���M�o�b�t�@��H
	jz	C_send_0		;

	pop	ax			;
	out	COMM_DATA,al		;���M
	pop	bx			;
	pop	di			;
	pop	es			;
	popf				;
	ret				;
;----------------------------------------------------------------
C_Send_0:
	mov	ax,ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	mov	di,ax			;ax��FIFO�|�C���^Cnt

	mov	bx,ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt

	inc	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	cmp	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Size
	jnz	C_Send_1		;
	mov	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt,0
C_Send_1:				;
	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	cmp	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	jnz	C_Send_3		;FIFO�o�b�t�@�͂����ς��H
	mov	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt,bx
	call	IC_Send			;FIFO�̑��M�����݂āA
	jmp	C_Send_1		;��蒼���B

C_Send_3:				;
	mov	bx,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Offset
	mov	es,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Segment
	pop	ax			;FIFO�o�b�t�@�ɏ�������
	push	ax			;
	mov	byte ptr es:[di+bx],al	;

C_Send_e:
	in	al,Int_Enable		;�o�b�t�@�Ƀf�[�^�������̂ŁA
	or	al,INT_CommSendSet	;�V���A�����M�G���v�e�B�[
	out	Int_Enable,al		;���荞�݋���

	pop	ax			;
	pop	bx			;
	pop	di			;���W�X�^���A
	pop	es			;
	popf				;
	ret				;
C_Send	endp				;
;===============================================================|
;	even				;�����A�h���X�z�u
;C_Send	proc near			;
;	push	cx			;
;	push	ax			;���W�X�^�ۑ�
;
;	mov	cx,COMM_TimeOut		;count
;	xchg	al,ah			;
;C_send_1:				
;	dec	cx			;time count
;	jz	C_send_e		;�������[�v�΍�
;	in	al,COMM_Status		;�X�e�[�^�X�ǂݍ���
;	test	al,COMM_SendEmpty	;���M�o�b�t�@��H
;	jz	C_send_1		;
;	xchg	al,ah			;
;	out	COMM_DATA,al		;���M
;	or	ax,ax			;Cy flag reset
;
;C_Send_e:
;	pop	ax			;���W�X�^���A
;	pop	cx			;
;	ret				;
;C_Send	endp				;
;===============================================================|
;			2 byte���M				|
;===============================================================|
;	������							|
;		ax	send data(al:LSB,ah:MSB)		|
;	�Ԃ�l							|
;		����						|
;	����							|
;		����Ƀf�[�^���o�͂���B			|
;===============================================================|
	even				;�����A�h���X�z�u
C_Send_Word	proc near		;
	call	C_Send			;
	xchg	al,ah			;
	call	C_Send			;
	xchg	al,ah			;
	ret				;
C_Send_Word	endp			;
;===============================================================|
;			�u���b�N���M				|
;===============================================================|
;	������							|
;		CX	Size					|
;		DS:SI	Data Address				|
;	�Ԃ�l							|
;		����						|
;	����							|
;		����Ƀf�[�^���o�͂���B			|
;===============================================================|
	even				;�����A�h���X�z�u
C_Send_Block	proc near		;
	push	si			;
	push	cx			;
	push	ax			;���W�X�^�ۑ�

C_Send_Block_1:
	lods	byte ptr es:[si]	;
	call	C_Send			;���M
	loop	C_Send_Block_1		;
	
	pop	ax			;���W�X�^���A
	pop	cx			;
	pop	si			;
	ret				;
C_Send_Block	endp			;
;===============================================================|
;			1 byte���M				|
;===============================================================|
;	������							|
;		FIFO	send data				|
;	�Ԃ�l							|
;		����						|
;	����							|
;		����Ƀf�[�^���o�͂���B			|
;===============================================================|
	even				;�����A�h���X�z�u
IC_Send:
	push	es			;
	push	di			;
	push	bx			;
	push	ax			;
	pushf				;
	cli				;

;---------------------------------------------------------------
	in	al,Int_Enable		;
	and	al,INT_CommSendReset	;�V���A�����M�G���v�e�B�[
	out	Int_Enable,al		;���荞�݋֎~

	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Cnt
	cmp	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	jz	IC_Send_e		;FIFO�o�b�t�@����H

	in	al,COMM_Status		;�X�e�[�^�X�ǂݍ���
	test	al,COMM_SendEmpty	;���M�o�b�t�@��H
	jz	IC_send_e0		;Ze��'H'

	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	mov	di,ax			;FIFO�|�C���^�̎擾

	inc	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	mov	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr
	cmp	ax,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Size
	jnz	IC_Send_1		;
	mov	word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Adr,0
IC_Send_1:				;
	mov	bx,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Offset
	mov	es,word ptr ds:[bp].WTD_WorkAdd_System+WTD_Sys_ComFIFO_Segment
	mov	al,byte ptr es:[di+bx]	;
	out	COMM_DATA,al		;���M

IC_Send_e0:
	in	al,Int_Enable		;
	or	al,INT_CommSendSet	;�V���A�����M�G���v�e�B�[
	out	Int_Enable,al		;���荞�݋���

IC_Send_e:
	popf				;
	pop	ax			;
	pop	bx			;
	pop	di			;
	pop	es			;
	ret				;
;===============================================================|
endif