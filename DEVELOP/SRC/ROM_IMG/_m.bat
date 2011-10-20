	bmpcnv -p0037 ASCII_M.bmp ASCII_M.fr
	bmpcnv -m1    ASCII_C.bmp ASCII_C.fr
	dat2asm /w ASCII_M.fr > ASCII_M.asm
	dat2asm /d ASCII_C.fr > ASCII_C.asm
	masm ROM_BIOS.ASM /IC:\WWitch\WTD\SDK\include /ML /MX; >ERR_IMGA.txt
	lcc86 -o ROM_IMG.bin ROM_MAIN.C -m >ERR_IMGC.txt
	del *.bak
	del *.exe
