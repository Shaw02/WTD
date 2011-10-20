;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				Convert Routine				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;---------------------------------------------------------------|
;		コンバート　メインルーチン			|
;---------------------------------------------------------------|
;	●引数							|
;			無し					|
;	●返り値						|
;			無し					|
;	●レジスタ						|
;		es:bx	変換中のポインタ			|
;		cx	サイズ用カウンタ			|
;		ds:dx	文字列表示用				|
;---------------------------------------------------------------|
.const
convert_ptStr	dw	offset convert_strDB
		dw	offset convert_strDW
		dw	offset convert_strDW	;Dummy
		dw	offset convert_strDD
convert_strDB	db	'	DB	0$'
convert_strDW	db	'	DW	0$'
convert_strDD	db	'	DD	0$'
convert_strh	db	'h',0dh,0ah,24h
convert_strCR	db	0dh,0ah,24h
.code
convert		proc	near		;
		pusha			;
		push	si		;
		push	ds		;
		push	es		;レジスタ保存

		mov	ax,word ptr cs:[segWtd_File]
		mov	es,ax		;es←メモリのアドレス
		mov	bx,0		;es:bx

		push	cs		;
		pop	ds		;ds←cs

		;ループ回数
		mov	cx,word ptr cs:[szWtd_File]
convert_loop:
		;printf("	DB	0")
		push	bx		;
		mov	bx,offset convert_ptStr
		mov	ax,word ptr cs:[OP_FLAG_LEN]
		dec	ax		;
		shl	ax,1		;
		add	bx,ax		;
		mov	dx,word ptr cs:[bx]
		mov	ah,9		;
		int	21h		;
		pop	bx		;

		push	cx		;データ長だけ、ループ
		mov	cx,word ptr cs:[OP_FLAG_LEN]
convert_loop_l:
		;printf("%02x",[bx])
		mov	si,cx		;
		mov	al,byte ptr es:[bx+si-1]
		call	dat2hex8	;文字列変換
		mov	ah,9		;
		int	21h		;変換結果表示
		loop	convert_loop_l	;

		;printf("h\n")
		mov	dx,offset convert_strh
		mov	ah,9		;
		int	21h		;

		pop	cx		;サイズ復帰

		mov	ax,word ptr cs:[OP_FLAG_LEN]
		add	bx,ax		;bx+=OP_FLAG_LEN
		sub	cx,ax		;cx-=OP_FLAG_LEN

		pushf			;
		mov	ax,0008h	;
		mul	word ptr cs:[OP_FLAG_LEN]
		dec	ax		;
		test	bx,ax		;
		jnz	convert_ChkOct	;if(0==(cx&0x0007)){
		mov	dx,offset convert_strCR
		mov	ah,9		;	printf("\n");
		int	21h		;};
convert_ChkOct:
		popf			;
		jz	convert_ChkSz	;
		jc	convert_ChkSz	;
		jmp	convert_loop	;
convert_ChkSz:				;

convert_end:				;
		pop	es		;レジスタ復帰
		pop	ds		;
		pop	si		;
		popa			;
		ret			;
convert		endp			;
