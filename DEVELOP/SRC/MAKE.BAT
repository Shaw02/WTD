path c:\masm611\bin;c:\masm611\binr;c:\WWitch\bin\;c:\WWitch\bin16\;c:\WWitch\lsic86ww\bin\;c:\WWitch\wtd\bin

rem ●DOS用ライブラリ
cd DOS_LIB
nmake
cd..

rem ●廉価版
cd wtd
rem mkfent wtd_h.cf
nmake
copy wtd.fx ..\..\..\bin\
copy wtd_h.fx ..\..\..\bin\
copy WTD_SRAM.LIB ..\..\..\bin\s\
copy WTDHSRAM.LIB ..\..\..\bin\s\
copy WTD_IRAM.LIB ..\..\..\bin\s\
copy WTDHIRAM.LIB ..\..\..\bin\s\
cd..

rem ●DAT2ASM
cd dat2asm
nmake
copy dat2asm.com ..\..\..\bin\
cd..

rem ●BIOS for WS Emulator ROM-Image
cd rom_img
nmake
copy rom_img.bin ..\..\..\bin\
cd..

rem ●ROM-Image Maker
cd wsmake
nmake
copy wsmake.com ..\..\..\bin\
cd..

rem ●コンパイラ
cd wtc
nmake
copy wtc.com ..\..\..\bin\
cd..

rem ●逆コンパイラ
cd wtuc
nmake
rem copy wtuc.com ..\..\tool\
cd..

●ファイル削除
del *.bak
del C:\WWitch\WTD\SDK\include\*.bak
