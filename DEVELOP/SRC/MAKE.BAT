path c:\masm611\bin;c:\masm611\binr;c:\WWitch\bin

rem ●廉価版
cd wtd
rem mkfent wtd_h.cf
nmake
copy wtd.fx ..\..\..\bin\
copy wtd_h.fx ..\..\..\bin\
cd..

rem ●コンパイラ
cd wtc
nmake
copy wtc.com ..\..\..\bin\
cd..

rem ●逆コンパイラ
cd wtuc
nmake
copy wtuc.com ..\..\tool\
cd..

●ファイル削除
del *.bak
del C:\WWitch\WTD\SDK\include\*.bak
