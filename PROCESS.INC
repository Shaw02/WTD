;=======================================================================|
;									|
;			ＷａｎｄｅｒＳｗａｎ				|
;				汎用定義ファイル			|
;				ＯＳ編　－プロセス			|
;									|
; Copyright (c) 1999-2000, Qute Corporation. All rights reserved.	|
;									|
; FreyaOS process control block structure				|
;	$Id: process.h,v 1.4 2001/09/27 07:39:36 satoo Exp $		|
;									|
;						A.Watanabe (S.W.)	|
;									|
;=======================================================================|
;===============ProcIL return codes
E_PROC_SUCCESS		equ	0
E_PROC_CANTLOAD		equ	-1

;===============process status codes */
S_PCB_NOT_USED		equ	0
S_PCB_LOAD		equ	1
S_PCB_RUN		equ	2
S_PCB_SUSPEND		equ	3

;===============maximum process count: 0 for FreyaOS itself */
MAXPROCESSES		equ	3

ProcControl		struc			;
ProcControl_status	dw	?		;status of process
ProcControl_exit_code	dw	?		;process exit code
;if			HOLD_TIME_INFO
ProcControl_born	dd	?		;process born time
ProcControl_started	dd	?		;recent starting time
ProcControl_ellapse	dd	?		;total ellapse time
;endif
ProcControl		ends			;

ProcContext		struc			;
ProcContext_id		db	4	dup(?)	; mark: "LCC"/"TCC"
ProcContext_pid		dw	?		; pid of process
ProcContext_ppid	dw	?		; pid of parent process
ProcContext_pcbid	dw	?		; pcbid of process
ProcContext_ppcbib	dw	?		; parent's pcbid
ProcContext_ilib	dd	?		; IlibIL for this process
ProcContext_proc	dd	?		; ProcIL for this process
ProcContext_cwfs	dd	?		; current working filesystem
ProcContext_currentdir	db	64	dup(?)	; current working directory
ProcContext_argv	dw 	?		; execution arguments
ProcContext_resource	dd	?		; poiter to resource
ProcContext_heap	dw	?		; poiter to free heap area
ProcContext		ends			;

;手動で書いて！！
;#define pcbid2bankno(id)	(BANK_OSWORK - (id))

;使う命令のコメントを外して！！
;int near pcb_get_pcbid(void);
;EXTRN	_pcb_get_pcbid:near
;int near pcb_get_ppcbid(int id);
;EXTRN	_pcb_get_ppcbid:near
;int near pcb_get_pid(int id);
;EXTRN	_pcb_get_pid:near
;int near pcb_get_ppid(int id);
;EXTRN	_pcb_get_ppid:near
;int near pcb_get_status(int id);
;EXTRN	_pcb_get_status:near
;int near pcb_get_argv(int id, int index, char far *buf, int len);
;EXTRN	_pcb_get_argv:near
;int near pcb_get_srambank(void);
;EXTRN	_pcb_get_srambank:near

;if	HOLD_TIME_INFO

;time_t near pcb_get_born_time(int id);
;EXTRN	_pcb_get_born_time:near
;unsigned long near pcb_get_started_tick(int id);
;EXTRN	_pcb_get_started_tick:near
;unsigned long near pcb_get_ellapsed_tick(int id);
;EXTRN	_pcb_get_ellapsed_tick:near

;endif


