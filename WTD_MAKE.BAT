rem ●アセンブル

rem 廉価版
c:\lsic86\masm wtd_h;>wtdherr.txt
c:\lsic86\masm wtd_h;
c:\lsic86\link wtd_h;
c:\lsic86\exe2bin wtd_h.exe wtd_h.bin
c:\lsic86\mkfent wtd_h.cf

c:\lsic86\masm wtc_h;>wtcherr.txt
c:\lsic86\masm wtc_h;
c:\lsic86\link wtc_h;
c:\lsic86\exe2bin wtc_h.exe wtc_h.com

rem 通常版
c:\lsic86\masm wtd;>wtderror.txt
c:\lsic86\masm wtd;
c:\lsic86\link wtd;
c:\lsic86\exe2bin wtd.exe wtd.bin
c:\lsic86\mkfent wtd.cf

c:\lsic86\masm wtc;>wtcerr.txt
c:\lsic86\masm wtc;
c:\lsic86\link wtc;
c:\lsic86\exe2bin wtc.exe wtc.com

rem ●ファイルの削除

del *.bak
del wtd.bin
del wtd_h.bin
del wtd.obj
del wtd_h.obj
del wtc.obj
del wtc_h.obj
del wtd.exe
del wtd_h.exe
del wtc.exe
del wtc_h.exe
del wtdil_a.lzh
del wtdil_h.lzh
del wtdil_SE.lzh
del wtdil_DE.lzh


rem ●パッケージ作製

rem Advanced
rem c:\lsic86\lha a -d wtdil_a.lzh *.*

rem ・廉価版
c:\lsic86\lha a wtdil_h.lzh  wtdil.hed
c:\lsic86\lha a wtdil_h.lzh  wtd_h.fx
c:\lsic86\lha a wtdil_h.lzh  wmsvwtd.fx
c:\lsic86\lha a wtdil_h.lzh  wtc_h.com
c:\lsic86\lha a wtdil_h.lzh  readme.pdf 取説.pdf
c:\lsic86\lha a wtdil_h.lzh  wtd_his.txt wmsv_his.txt fspnet.txt

rem ・Stadard Edition
c:\lsic86\lha a wtdil_SE.lzh  wtdil.hed
c:\lsic86\lha a wtdil_SE.lzh  wtd.fx
c:\lsic86\lha a wtdil_SE.lzh  wtd_h.fx
c:\lsic86\lha a wtdil_SE.lzh  wmsvwtd.fx
c:\lsic86\lha a wtdil_SE.lzh  wtc.com
c:\lsic86\lha a wtdil_SE.lzh  wtc_h.com
c:\lsic86\lha a wtdil_SE.lzh  readme.pdf 取説.pdf
c:\lsic86\lha a wtdil_SE.lzh  wtd_his.txt wmsv_his.txt fspnet.txt

rem ・Professional Edition
c:\lsic86\lha a wtdil_PE.lzh  wtdil.hed
c:\lsic86\lha a wtdil_PE.lzh  wtd.fx
c:\lsic86\lha a wtdil_PE.lzh  wtd_h.fx
c:\lsic86\lha a wtdil_PE.lzh  wmsvwtd.fx
c:\lsic86\lha a wtdil_PE.lzh  wtc.com
c:\lsic86\lha a wtdil_PE.lzh  wtc_h.com
c:\lsic86\lha a wtdil_PE.lzh  readme.pdf 取説.pdf
c:\lsic86\lha a wtdil_PE.lzh  devloper.PDF
c:\lsic86\lha a wtdil_PE.lzh  wtd_his.txt wmsv_his.txt fspnet.txt
c:\lsic86\lha a wtdil_PE.lzh  service.inc timer.inc comm.inc sound.inc
c:\lsic86\lha a wtdil_PE.lzh  wtd.h wtd_def.inc wtd_ver.inc wtc_def.inc

rem ・Developer's Edtion
c:\lsic86\lha a wtdil_DE.lzh  wtdil.hed
c:\lsic86\lha a wtdil_DE.lzh  wtd.fx
c:\lsic86\lha a wtdil_DE.lzh  wtd_h.fx
c:\lsic86\lha a wtdil_DE.lzh  wmsvwtd.fx
c:\lsic86\lha a wtdil_DE.lzh  wtc.com
c:\lsic86\lha a wtdil_DE.lzh  wtc_h.com
c:\lsic86\lha a wtdil_DE.lzh  readme.pdf 取説.pdf
c:\lsic86\lha a wtdil_DE.lzh  devloper.PDF
c:\lsic86\lha a wtdil_DE.lzh  wtd_his.txt wmsv_his.txt fspnet.txt
c:\lsic86\lha a wtdil_DE.lzh  service.inc timer.inc comm.inc sound.inc
c:\lsic86\lha a wtdil_DE.lzh  wtd.h wtd_def.inc wtd_ver.inc wtc_def.inc
c:\lsic86\lha a wtdil_DE.lzh  wtd.asm wtd_h.asm wtd_ilf.asm wtd_int.asm
c:\lsic86\lha a wtdil_DE.lzh  wtd_tim.asm wtd_com.asm wtd_snd.asm
c:\lsic86\lha a wtdil_DE.lzh  wtd.asm wtd_h.asm
c:\lsic86\lha a wtdil_DE.lzh  wtc.asm wtc_h.asm wtc_main.asm wtc_sub.asm
c:\lsic86\lha a wtdil_DE.lzh  wtc_hed.asm wtc_voi.asm wtc_com.asm
c:\lsic86\lha a wtdil_DE.lzh  セレクタソースファイル
c:\lsic86\lha a wtdil_DE.lzh  wtd_make.bat セレクタメイクファイル
c:\lsic86\lha a wtdil_DE.lzh  wtd.cf wtd_h.cf セレクタcfファイル
c:\lsic86\lha a wtdil_DE.lzh  readme.doc 取説.doc
c:\lsic86\lha a wtdil_DE.lzh  devloper.doc
c:\lsic86\lha a wtdil_DE.lzh  取説_表.xls dev_表.xls buy.xls
