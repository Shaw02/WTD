;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				UnMML Compiler Program			|
;				データ情報				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;************************************************************************
;*									*
;*		各コマンドの引き数量（Byte）				*
;*									*
;************************************************************************
;	0～127	引数量
;	128	可変1 データ量が最初に書いてある(Z)
;	129	可変2 0xF7までが引数。(X)
;	130	可変3 音色(@)
;	131	可変4 Bend(B)
;	132	可変5 音長(l)
;	255	トラック・エンド
UC_DATA_Size: ;	  0 1   2 3 4 5 6 7   8 9   a b   c d e f
	DB	  ?,?,  ?,?,?,?,?,?,  ?,?,  ?,?,  ?,?,?,?	;00H～0FH
	DB	  ?,?,  ?,?,?,?,?,?,  ?,?,  ?,?,  ?,?,?,?	;10H～1FH
	DB	  ?,0,  1,?,?,?,?,1,  0,0,  2,?,  ?,?,?,2	;20H～2FH
	DB	  2,2,  2,2,2,2,2,2,  2,2,  2,3,  0,?,0,?	;30H～3FH
	DB	130,?,131,1,2,2,1,1,  2,?,  ?,2,  2,3,3,1	;40H～4FH
	DB	  1,1,  1,1,1,1,2,?,129,1,128,1,  ?,2,?,1	;50H～5FH
	DB	  ?,?,  ?,?,?,?,?,?,  ?,?,  ?,1,132,6,1,1	;60H～6FH
	DB	  1,2,  ?,2,2,2,1,?,  1,2,  ?,1,  ?,?,?,?	;70H～7FH
;************************************************************************
;*									*
;*		逆ＭＭＬ変換情報のあるアドレス				*
;*									*
;************************************************************************
UC_DATA_ADDRESS:
	DW	OFFSET UC_D00	;コマンド00h
	DW	OFFSET UC_D01
	DW	OFFSET UC_D02
	DW	OFFSET UC_D03
	DW	OFFSET UC_D04
	DW	OFFSET UC_D05
	DW	OFFSET UC_D06
	DW	OFFSET UC_D07
	DW	OFFSET UC_D08
	DW	OFFSET UC_D09
	DW	OFFSET UC_D0A
	DW	OFFSET UC_D0B
	DW	OFFSET UC_D0C
	DW	OFFSET UC_D0D
	DW	OFFSET UC_D0E
	DW	OFFSET UC_D0F
	DW	OFFSET UC_D10
	DW	OFFSET UC_D11
	DW	OFFSET UC_D12
	DW	OFFSET UC_D13
	DW	OFFSET UC_D14
	DW	OFFSET UC_D15
	DW	OFFSET UC_D16
	DW	OFFSET UC_D17
	DW	OFFSET UC_D18
	DW	OFFSET UC_D19
	DW	OFFSET UC_D1A
	DW	OFFSET UC_D1B
	DW	OFFSET UC_D1C
	DW	OFFSET UC_D1D
	DW	OFFSET UC_D1E
	DW	OFFSET UC_D1F
	DW	OFFSET UC_D20
	DW	OFFSET UC_D21
	DW	OFFSET UC_D22
	DW	OFFSET UC_D23
	DW	OFFSET UC_D24
	DW	OFFSET UC_D25
	DW	OFFSET UC_D26
	DW	OFFSET UC_D27
	DW	OFFSET UC_D28
	DW	OFFSET UC_D29
	DW	OFFSET UC_D2A
	DW	OFFSET UC_D2B
	DW	OFFSET UC_D2C
	DW	OFFSET UC_D2D
	DW	OFFSET UC_D2E
	DW	OFFSET UC_D2F
	DW	OFFSET UC_D30
	DW	OFFSET UC_D31
	DW	OFFSET UC_D32
	DW	OFFSET UC_D33
	DW	OFFSET UC_D34
	DW	OFFSET UC_D35
	DW	OFFSET UC_D36
	DW	OFFSET UC_D37
	DW	OFFSET UC_D38
	DW	OFFSET UC_D39
	DW	OFFSET UC_D3A
	DW	OFFSET UC_D3B
	DW	OFFSET UC_D3C
	DW	OFFSET UC_D3D
	DW	OFFSET UC_D3E
	DW	OFFSET UC_D3F
	DW	OFFSET UC_D40
	DW	OFFSET UC_D41
	DW	OFFSET UC_D42
	DW	OFFSET UC_D43
	DW	OFFSET UC_D44
	DW	OFFSET UC_D45
	DW	OFFSET UC_D46
	DW	OFFSET UC_D47
	DW	OFFSET UC_D48
	DW	OFFSET UC_D49
	DW	OFFSET UC_D4A
	DW	OFFSET UC_D4B
	DW	OFFSET UC_D4C
	DW	OFFSET UC_D4D
	DW	OFFSET UC_D4E
	DW	OFFSET UC_D4F
	DW	OFFSET UC_D50
	DW	OFFSET UC_D51
	DW	OFFSET UC_D52
	DW	OFFSET UC_D53
	DW	OFFSET UC_D54
	DW	OFFSET UC_D55
	DW	OFFSET UC_D56
	DW	OFFSET UC_D57
	DW	OFFSET UC_D58
	DW	OFFSET UC_D59
	DW	OFFSET UC_D5A
	DW	OFFSET UC_D5B
	DW	OFFSET UC_D5C
	DW	OFFSET UC_D5D
	DW	OFFSET UC_D5E
	DW	OFFSET UC_D5F
	DW	OFFSET UC_D60
	DW	OFFSET UC_D61
	DW	OFFSET UC_D62
	DW	OFFSET UC_D63
	DW	OFFSET UC_D64
	DW	OFFSET UC_D65
	DW	OFFSET UC_D66
	DW	OFFSET UC_D67
	DW	OFFSET UC_D68
	DW	OFFSET UC_D69
	DW	OFFSET UC_D6A
	DW	OFFSET UC_D6B
	DW	OFFSET UC_D6C
	DW	OFFSET UC_D6D
	DW	OFFSET UC_D6E
	DW	OFFSET UC_D6F
	DW	OFFSET UC_D70
	DW	OFFSET UC_D71
	DW	OFFSET UC_D72
	DW	OFFSET UC_D73
	DW	OFFSET UC_D74
	DW	OFFSET UC_D75
	DW	OFFSET UC_D76
	DW	OFFSET UC_D77
	DW	OFFSET UC_D78
	DW	OFFSET UC_D79
	DW	OFFSET UC_D7A
	DW	OFFSET UC_D7B
	DW	OFFSET UC_D7C
	DW	OFFSET UC_D7D
	DW	OFFSET UC_D7E
	DW	OFFSET UC_D7F
;************************************************************************
;*									*
;*		逆ＭＭＬ情報						*
;*									*
;************************************************************************
;*	（最初に変換アドレス＋１されている。）				*
;*	00h	変換終了						*
;*	10h	符号無しＢｙｔｅ変換	アドレス＋１			*
;*	11h	符号有りＢｙｔｅ変換	アドレス＋１			*
;*	12h	符号無しＷｏｒｄ変換	アドレス＋１			*
;*	13h	符号有りＷｏｒｄ変換	アドレス＋１			*
;*	20h	文字列出力　'$'まで出力する。				*
;*	24h	次のコードの出力					*
;*	80h	パート終了						*
;*	F0h	アドレス＋１	（未解析コマンドの引き数）		*
;*	FFh	次に示すアドレスをコールする				*
;************************************************************************
UC_D00	DB	0
UC_D01	DB	0
UC_D02	DB	0
UC_D03	DB	0
UC_D04	DB	0
UC_D05	DB	0
UC_D06	DB	0
UC_D07	DB	0
UC_D08	DB	0
UC_D09	DB	0
UC_D0A	DB	0
UC_D0B	DB	0
UC_D0C	DB	0
UC_D0D	DB	0
UC_D0E	DB	0
UC_D0F	DB	0
UC_D10	DB	0
UC_D11	DB	0
UC_D12	DB	0
UC_D13	DB	0
UC_D14	DB	0
UC_D15	DB	0
UC_D16	DB	0
UC_D17	DB	0
UC_D18	DB	0
UC_D19	DB	0
UC_D1A	DB	0
UC_D1B	DB	0
UC_D1C	DB	0
UC_D1D	DB	0
UC_D1E	DB	0
UC_D1F	DB	0
UC_D20	DB	0
UC_D21	DB	" !$",0			;!
UC_D22	DB	20h,22h,24h,10h,0	;"
UC_D23	DB	0
UC_D24	DB	0
UC_D25	DB	0
UC_D26	DB	0
UC_D27	DB	20h,27h,24h,10h,0	;'
UC_D28	DB	0
UC_D29	DB	0
UC_D2A	DB	" *$",10h," ,$",10h,0	;*
UC_D2B	DB	0
UC_D2C	DB	0
UC_D2D	DB	0
UC_D2E	DB	0
UC_D2F	DB	" /$",10h," ,$",10h,0	;*
UC_D30	DB	" 0,$",10h," ,$",10h,0	;0
UC_D31	DB	" 1,$",10h," ,$",10h,0	;1
UC_D32	DB	" 2,$",10h," ,$",10h,0	;2
UC_D33	DB	" 3,$",10h," ,$",10h,0	;3
UC_D34	DB	" 4,$",10h," ,$",10h,0	;4
UC_D35	DB	" 5,$",10h," ,$",10h,0	;5
UC_D36	DB	" 6,$",10h," ,$",10h,0	;6
UC_D37	DB	" 7,$",10h," ,$",10h,0	;7
UC_D38	DB	" 8,$",10h," ,$",10h,0	;8
UC_D39	DB	" 9,$",10h," ,$",10h,0	;9
UC_D3A	DB	" :$",0F0h,0F0h,0	;:
UC_D3B	DB	" ;$",10h,0F0h,0F0h,0	;;
UC_D3C	DB	0
UC_D3D	DB	0
UC_D3E	DB	0
UC_D3F	DB	0
UC_D40	DB	0
UC_D41	DB	0
UC_D42	DB	0
UC_D43	DB	0
UC_D44	DB	0
UC_D45	DB	0
UC_D46	DB	0
UC_D47	DB	0
UC_D48	DB	0
UC_D49	DB	0
UC_D4A	DB	0
UC_D4B	DB	0
UC_D4C	DB	0
UC_D4D	DB	0
UC_D4E	DB	0
UC_D4F	DB	0
UC_D50	DB	0
UC_D51	DB	0
UC_D52	DB	0
UC_D53	DB	0
UC_D54	DB	0
UC_D55	DB	0
UC_D56	DB	0
UC_D57	DB	0
UC_D58	DB	0
UC_D59	DB	0
UC_D5A	DB	0
UC_D5B	DB	" [$",0FFh		;[
;	DW	offset			;
	DB	0			;
UC_D5C	DB	0
UC_D5D	DB	" ]$",0F0h,0F0h,0FFh	;]
;	DW	offset			;
	DB	0			;
UC_D5E	DB	0
UC_D5F	DB	0
UC_D60	DB	0
UC_D61	DB	0
UC_D62	DB	0
UC_D63	DB	0
UC_D64	DB	0
UC_D65	DB	0
UC_D66	DB	0
UC_D67	DB	0
UC_D68	DB	0
UC_D69	DB	0
UC_D6A	DB	0
UC_D6B	DB	0
UC_D6C	DB	0
UC_D6D	DB	0
UC_D6E	DB	0
UC_D6F	DB	0
UC_D70	DB	0
UC_D71	DB	0
UC_D72	DB	0
UC_D73	DB	0
UC_D74	DB	0
UC_D75	DB	0
UC_D76	DB	0
UC_D77	DB	0
UC_D78	DB	0
UC_D79	DB	0
UC_D7A	DB	0
UC_D7B	DB	0
UC_D7C	DB	0
UC_D7D	DB	0
UC_D7E	DB	0
UC_D7F	DB	0
;===============================================================
;		複雑な変換処理
;===============================================================
;●ループ
UC_LoopSP	dw	-2
UC_LoopEnd	dw	8	Dup(0)
UC_LoopJump	dw	8	Dup(0)
UC_LoopL	dw	0
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
UC4C:
	ret
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
UC5B:	
	ret
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
UC5D:	
	ret
;---------------------------------------------------------------
