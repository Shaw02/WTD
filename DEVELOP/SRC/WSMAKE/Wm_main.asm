;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				Main Routine				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
BIOS_FILE	db	'ROM_IMG.BIN',0,0ah,0dh,24h
LOAD_MSG	db	'を読み込みます。',0ah,0dh,24h
MUS_ERR		db	'WTD形式のデータではありません。'
_main:
		MOV	AX,OFFSET WTD_MML_Compiler_End + BSTACK	;
		MOV	SP,AX			;

		MOV	AX,CS			;
		MOV	DS,AX			;
		MOV	ES,AX			;セグメントの設定。
		MOV	SS,AX			;
	
		CALL	TPRINT			;タイトルの表示
		CALL	ComSmole		;メモリの最小化

		cld				;インクリメントモード

		;-----------------------
		;file_open("*.WTD")
		call	Search_FileName		;ファイル名の解決
		push	cs			;
		pop	ds			;
		mov	dx,cs:[F_ADD]		;ds:dx←ファイル名
		mov	al,0			;read mode
		call	File_Open		;WTDファイルのopen
		mov	cs:[hWtd_File],ax	;

		;-----------------------
		;memory alloc()
		mov	ax,02000h		;128kのメモリ確保
		call	Memory_Open		;
		mov	cs:[pWSC_File],ax	;
		mov	es,ax			;
		mov	di,0			;es:di← 確保したセグメント
		mov	cx,08000h		;
		mov	ax,0			;
	rep	stosw				;０初期化
		mov	ax,cs:[pWSC_File]	;
		add	ax,01000h		;
		mov	es,ax			;
		mov	di,0			;es:di← 確保したセグメント
		mov	cx,08000h		;
		mov	ax,0			;
	rep	stosw				;０初期化

		;-----------------------
		;file_load("*.wtd")
		mov	dx,0000			;
		mov	ds,cs:[pWSC_File]	;
		mov	ax,cs:[hWtd_File]	;
		call	File_Load		;

		;-----------------------
		;file_Close("*.wtd")
		mov	ax,cs:[hWtd_File]	;
		call	File_Close		;

		;-----------------------
		;file_open(ROM_IMG.BIN)
		push	cs			;
		pop	ds			;
		mov	dx,offset BIOS_FILE	;ds:dx←ファイル名
		mov	al,0			;read mode
		call	File_Open		;BIOSファイルのopen
		mov	cs:[hBin_File],ax	;

		;-----------------------
		;file_load(ROM_IMG.BIN)
		mov	dx,0000			;
		mov	ax,cs:[pWSC_File]	;
		add	ax,01000h		;
		mov	ds,ax			;
		mov	ax,cs:[hBin_File]	;
		call	File_Load		;

		;-----------------------
		;file_Close(ROM_IMG.BIN)
		mov	ax,cs:[hWtd_File]	;
		call	File_Close		;


		;-----------------------
		;Wonder Swan ROM 設定
		mov	ax,cs:[pWSC_File]	;
		add	ax,01000h		;
		mov	ds,ax			;
		mov	bx,0FFF0h		;
		mov	byte ptr ds:[bx],0EAh	;jmp
		inc	bx			;
		mov	word ptr ds:[bx],00000h	;
		add	bx,2			;
		mov	word ptr ds:[bx],0F000h	;
		mov	bx,0FFFAh		;ROM容量
		mov	byte ptr ds:[bx],0	;
		mov	bx,0FFFBh		;RAM容量
		mov	byte ptr ds:[bx],0	;
		mov	bx,0FFFCh		;ROM Wate
		mov	byte ptr ds:[bx],0	;
		mov	bx,0FFFDh		;Sub System LSI
		mov	byte ptr ds:[bx],0	;
		mov	bx,0FFFEh		;CRC
		mov	word ptr ds:[bx],0	;

		;-----------------------
		;file_open("*.WSC")
		call	Set_Filename_Ext	;
		push	cs			;
		pop	ds			;
		mov	dx,cs:[F_ADD]		;ds:dx←ファイル名
		mov	al,0			;read mode
		call	File_Create		;WSCファイルのopen
		mov	cs:[hWSC_File],ax	;

		;-----------------------
		;ROMイメージの作成
		mov	ax,cs:[pWSC_File]	;
		mov	ds,ax			;
		mov	dx,0			;ds:di← 確保したセグメント

		;WTD形式かチェック		;
		mov	bx,dx			;
		cmp	word ptr ds:[bx],'TW'	;
		jz	_main_L00		;
		add	dx,80h			;
		mov	bx,dx			;
		cmp	word ptr ds:[bx],'TW'	;
		jz	_main_L00		;
		push	cs			;
		pop	ds			;
		mov	dx,offset MUS_ERR	;
		mov	ah,09h			;
		int	21h			;
		jmp	_main_End		;
_main_L00:
		mov	ax,cs:[hWSC_File]	;0xE0000～0xE7FFF
		mov	cx,08000h		;
		push	dx			;
		call	File_Write		;
		pop	dx			;

		mov	ax,cs:[pWSC_File]	;
		add	ax,00800h		;0xE8000～0xEFFFF
		mov	ds,ax			;
		mov	ax,cs:[hWSC_File]	;
		mov	cx,08000h		;
		call	File_Write		;

		mov	ax,cs:[pWSC_File]	;0xF0000～0xF7FFF
		add	ax,01000h		;
		mov	ds,ax			;
		mov	dx,0			;es:di← 確保したセグメント
		mov	ax,cs:[hWSC_File]	;
		mov	cx,08000h		;
		call	File_Write		;

		mov	ax,cs:[pWSC_File]	;0xF8000～0xFFFFF
		add	ax,01800h		;
		mov	ds,ax			;
		mov	dx,0			;es:di← 確保したセグメント
		mov	ax,cs:[hWSC_File]	;
		mov	cx,08000h		;
		call	File_Write		;

		;file_Close("*.wtd")
		mov	ax,cs:[hWSC_File]	;
		call	File_Close		;

_main_End:
COMEND:
	STI				;割り込み許可
	MOV	AX,04C00H		;
	INT	21H			;MS-DOS RET
