path c:\masm611\bin;c:\masm611\binr;c:\WWitch\bin

rem ��������
cd wtd
rem mkfent wtd_h.cf
nmake
copy wtd.fx ..\..\..\bin\
copy wtd_h.fx ..\..\..\bin\
cd..

rem ���R���p�C��
cd wtc
nmake
copy wtc.com ..\..\..\bin\
cd..

rem ���t�R���p�C��
cd wtuc
nmake
copy wtuc.com ..\..\tool\
cd..

���t�@�C���폜
del *.bak
del C:\WWitch\WTD\SDK\include\*.bak