;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				Un MML Compiler Program			|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|

assume	cs:code,ds:code,es:code,ss:code

code	segment

.186

	org	0100h

WTD_UnMML_Compiler_:
;=======================================================================|
;				Start Up				|
;=======================================================================|
	jmp	_main			;メインルーチンへ
;=======================================================================|
;				define					|
;=======================================================================|
WtdIL_Name		equ	'WTD',0
MusicMaxPart		equ	20	;製品版は20パート
EffectMaxPart		equ	3	;効果音は3 パート
;
;		コンパイル情報
;
D_ZEN	DB	128		;１分音符分割数	初期値
;=======================================================================|
;				Start					|
;=======================================================================|
include bank.inc	;バンク
include wtd_ver.inc	;WTD Version infomation
include wtd_def.inc	;WTD Define infomation
include wtc_def.inc	;Define
include wtuc_sub.asm	;Sub
include wtuc_cmd.asm	;Command
;===============================================================|
;								|
;		オプション処理					|
;								|
;===============================================================|
OP_FLAG_ZEMLEN	DB	0			;オプションフラグ−分割数指定
OP_FLAG_HELP	DB	0			;オプションフラグ−ヘルプ表示
OP_FLAG_FILE	DB	081H	DUP(00H)	;ファイル名（１２８文字分）
OP_HELP	DB	0DH,0AH
	DB	"	Wonder Swan Total Sound Driver Un MML Compiler",0DH,0AH
	DB	"			Programmed by  A.Watanabe",0DH,0AH
	DB	0DH,0AH
	DB	"	 [32;4m Filename[32;0m [m"
	DB	"ファイルの読み込み",0DH,0AH
	DB	"	>[32;4m Filename[32;0m [m"
	DB	"ファイルへ書き込み",0DH,0AH
	DB	"	/Z :１分音符の分割数（1〜255）",0DH,0AH
	DB	"	/? :ヘルプの表示",0DH,0AH
	DB	024H
;****************************************************************
;*		オプション処理					*
;****************************************************************
Op_:
	CALL	OPTION_FLAG		;フラグ立て
	MOV	AL,0			;チェック用
OP_L00:	CMP	CS:[OP_FLAG_ZEMLEN],AL	;一分音符分割数
	JZ	OP_L01			;
	CALL	OPTION_ZEMLEN		;
OP_L01:	CMP	CS:[OP_FLAG_HELP],AL	;ヘルプ表示
	JZ	OP_L02			;
	CALL	OPTION_HELP		;
OP_L02:	CMP	CS:[OP_FLAG_FILE],AL	;ファイル読み込み
	JZ	OP_L03			;
	CALL	OPTION_FILE		;
	jmp	OP_LEE			;
OP_L03:	jmp	COMEND			;ファイル名の指定が無ければ、
OP_LEE:	RET				;RETURN
;****************************************************************
;*		オプションフラグ立て				*
;****************************************************************
;	使用レジスタ						*
;	BX	オプション文字列アドレス			*
;	CX	オプション文字列最終アドレス＋１		*
;****************************************************************
OPTION_FLAG:				;
	MOV	AX,CS			;
	MOV	DS,AX			;DS←CS

	MOV	AX,0000H		;
	MOV	BX,0080H		;BX←オプション文字列先頭アドレス−１
	MOV	AL,CS:[BX]		;AL←オプション文字数
	ADD	AX,BX			;
	MOV	CX,AX			;CX←オープション文字列最終番地
OP_LOOP:
	INC	BX			;
	CMP	CX,BX			;オプション終了
	JNC	OP_LP0			;だったらフラグ立て処理正常終了
	RET				;
OP_LP0:
	MOV	AL,CS:[BX]		;文字列読み込み
	CMP	AL,21H			;
	JC	OP_LOOP			;
	CMP	AL,"/"			;'/'or'-'であったら、オプション
	JZ	OP_SW			;
	CMP	AL,"-"			;
	JZ	OP_SW			;
	JMP	OP_FILE_SET		;それ以外はファイル指定
OP_SW:
	INC	BX			;アドレスインクリメント
	CMP	CX,BX			;オプション終了？
	JNC	OP_S00			;
	JMP	OPTION_ERROR		;だったらエラー
OP_S00:	
	MOV	AH,0FFH			;フラグ立て用。
	MOV	DX,OFFSET OP_FLAG_HELP	;フラグアドレス
	MOV	AL,CS:[BX]		;
	CMP	AL,"?"			;Help表示
	JNZ	OP_S01			;
	JMP	OP_FLAG_SET		;
OP_S01:	CMP	AL,"h"			;
	JNZ	OP_S02			;
	JMP	OP_FLAG_SET		;
OP_S02:	CMP	AL,"H"			;
	JNZ	OP_S03			;
	JMP	OP_FLAG_SET		;
OP_S03:	MOV	DX,OFFSET OP_FLAG_ZEMLEN
	CMP	AL,"z"			;一分音符分割数
	JNZ	OP_S04			;
	JMP	OP_ZEMLEN_SET		;
OP_S04:	CMP	AL,"Z"			;
	JNZ	OP_S05			;
	JMP	OP_ZEMLEN_SET		;
OP_S05:	
OP_SEE:	JMP	OPTION_ERROR		;無かったらエラー
;****************************************************************
OP_ZEMLEN_SET:
	INC	BX			;
	PUSH	DX			;
OP_ZEMLEN_SET_1:			;
	MOV	DX,BX			;DX←オプションアドレス
	CALL	ASC2HEX8		;AH←文字列（数値）
	JC	OP_ZEMLEN_SET_1		;
	DEC	BX			;
	MOV	AL,AH			;AL←数値
	POP	DX			;
;****************************************************************
OP_FLAG_SET:
	XCHG	BX,DX			;
	MOV	CS:[BX],AL		;フラグセット
	XCHG	BX,DX			;
	JMP	OP_LOOP			;ループに戻る
;****************************************************************
OP_FILE_SET:
	MOV	DX,OFFSET OP_FLAG_FILE	;ファイルだべ。
	XCHG	BX,DX			;
	MOV	AH,CS:[BX]		;
	XCHG	BX,DX			;
	CMP	AH,0			;
	JZ	OP_FILE_SET_1		;
	JMP	OPTION_ERROR		;ファイル名が２つ書いてあるよぉ〜
OP_FILE_SET_1:
	DEC	BX			;オプションポインタ一つ戻す
	PUSH	CX			;レジスタ保存
	MOV	CX,080H			;ファイル名（拡張子含）最大サイズ
OP_FILE_SET_2:
	INC	BX			;
	MOV	AL,CS:[BX]		;AL←文字列読み込み
	CMP	AL,21H			;最後？
	JC	OP_FILE_SET_3		;
	XCHG	BX,DX			;
	MOV	CS:[BX],AL		;文字列セット
	XCHG	BX,DX			;
	INC	DX			;インクリメント
	DEC	CX			;１２文字超えた？
	JNZ	OP_FILE_SET_2		;
OP_FILE_SET_3:
	MOV	AL,0			;
	XCHG	BX,DX			;
	MOV	CS:[BX],AL		;'0' をセット
	XCHG	BX,DX			;
	POP	CX			;レジスタ復帰
	JMP	OP_LOOP			;ループに戻る
;****************************************************************
OPTION_ZEMLEN:				;
	PUSH	AX			;
	MOV	AL,CS:[OP_FLAG_ZEMLEN]	;
	MOV	CS:[D_ZEN],AL		;設定
	POP	AX			;
	RET				;RETURN
;****************************************************************
OPTION_HELP:				;
	MOV	DX,OFFSET OP_HELP	;表示
	MOV	AH,09H			;
	INT	21H			;
	JMP	COMEND			;プログラム終了
;****************************************************************
OPTION_FILE:				;
	pusha				;

;●ファイルのオープン
	MOV	AX,3D00H		;ファイルのオープン
	MOV	DX,OFFSET OP_FLAG_FILE	;DX←ファイル名アドレス
	MOV	CX,00H			;普通
	INT	21H			;ax←ファイルハンドル
	jnc	Option_File_ErrOp	;
	jmp	SOPEN_ERROR		;
Option_File_ErrOp:			;
	mov	word ptr cs:[hWtd_File],ax

;●ファイルのロード
	PUSH	DS			;
	MOV	AX,word ptr CS:[segWtd_File]
	MOV	DS,AX			;
	MOV	DX,0000H		;
	MOV	CX,0FFFFH		;
	MOV	BX,word ptr CS:[hWtd_File]
	MOV	AH,3FH			;
	INT	21H			;
	POP	DS			;
	JNC	Option_File_ErrLd	;
	JMP	READ_ERROR		;
Option_File_ErrLd:			;

;●ファイルのクローズ
	MOV	BX,WORD PTR CS:[hWtd_File]
	MOV	AH,3EH			;
	INT	21H			;
	JNC	Option_File_ErrCl	;
	JMP	CLOSE_ERROR		;
Option_File_ErrCl:			;

	popa				;
	RET				;RETURN
;=======================================================================|
;				main					|
;=======================================================================|
_main:
	MOV	AX,OFFSET WTD_UnMML_Compiler_End + BSTACK	;
	MOV	SP,AX			;

	MOV	AX,CS			;
	MOV	DS,AX			;
	MOV	ES,AX			;セグメントがえへへへ。
	MOV	SS,AX			;

	call	ComSmole		;メモリの最小化

	call	Memory_Open		;メモリの確保
	call	Op_			;オプション処理
	call	UnMML_COMPAILE		;逆ＭＭＬコンパイル部
	call	Memory_Close		;メモリの解放

_main_End:
COMEND:
	STI				;割り込み許可
	MOV	AX,04C00H		;
	INT	21H			;MS-DOS RET
;=======================================================================|
;				End					|
;=======================================================================|
WTD_UnMML_Compiler_End:
CODE	ENDS
	END	WTD_UnMML_Compiler_
