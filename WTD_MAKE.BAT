rem ●アセンブル

rem 廉価版
d:\lsic86\masm wtd_h;>wtdherr.txt
d:\lsic86\masm wtd_h;
d:\lsic86\link wtd_h;
d:\lsic86\exe2bin wtd_h.exe wtd_h.bin
d:\lsic86\mkfent wtd_h.cf

rem 通常版
d:\lsic86\masm wtd;>wtderror.txt
d:\lsic86\masm wtd;
d:\lsic86\link wtd;
d:\lsic86\exe2bin wtd.exe wtd.bin
d:\lsic86\mkfent wtd.cf


rem ●ファイルの削除

del *.bak
del wtd.bin
del wtd_h.bin
del wtd.obj
del wtd_h.obj
del wtd.exe
del wtd_h.exe
del wtdil.lzh
del wtdil_h.lzh
del wtdil_a.lzh


rem ●パッケージ作製

rem Advanced
lha a -d wtdil_a.lzh *.*

rem 廉価版
lha a wtdil_h.lzh  wtd_h.hed wtd_h.fx
lha a wtdil_h.lzh  .\manual\取説.PDF
lha a wtdil_h.lzh  wtd.h wtd_def.asm
lha a wtdil_h.lzh  wtc_h.com

rem 通常版
lha a wtdil.lzh  wtd.hed wtd.fx wtdil_h.lzh
lha a wtdil.lzh  .\manual\*.PDF
lha a wtdil.lzh  wtd.h wtd_def.asm wtd_ilf.asm
lha a wtdil.lzh  wtc.com

