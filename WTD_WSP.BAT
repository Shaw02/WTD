del WTDMAKE.wup
del readme.wup
del user.wup
del develop.wup
del HCP.wup
del Design.wup
del user_doc.wup
del deve_doc.wup
del HCP_vsd.wup
del Desi_vsd.wup
DEL wtdil.lzh

rem ●ドキュメント・ヘッダー
c:\lsic86\WSP -W -A .\OLD_WTD\wtdil.hed wtdil.hed WTDMAKE.WUP

rem ●Wonder Witch 実行ファイル
c:\lsic86\WSP -W -A .\OLD_WTD\wtd.fx wtd.fx WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_h.fx wtd_h.fx WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtdsv.fx wtdsv.fx WTDMAKE.WUP

rem ●MS-DOS 実行ファイル
c:\lsic86\WSP -W -A .\OLD_WTD\wtc.com wtc.com WTDMAKE.WUP

rem ●WTD ヘッダーファイル
c:\lsic86\WSP -W -A .\OLD_WTD\service.inc service.inc WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\process.inc process.inc WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\timer.inc timer.inc WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\comm.inc comm.inc WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\sound.inc sound.inc WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\bank.inc bank.inc WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd.h wtd.h WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_def.inc wtd_def.inc WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_ver.inc wtd_ver.inc WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtc_def.inc wtc_def.inc WTDMAKE.WUP

rem ●WTD本体 ソースファイル
c:\lsic86\WSP -W -A .\OLD_WTD\wtd.asm wtd.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_h.asm wtd_h.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_ilf.asm wtd_ilf.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_int.asm wtd_int.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_icom.asm wtd_icom.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_idev.asm wtd_idev.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_tim.asm wtd_tim.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_com.asm wtd_com.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_snd.asm wtd_snd.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd.asm wtd.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_h.asm wtd_h.asm WTDMAKE.WUP

rem ●MMLコンパイラ ソースファイル
c:\lsic86\WSP -W -A .\OLD_WTD\wtc.asm wtc.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtc_main.asm wtc_main.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtc_sub.asm wtc_sub.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtc_hed.asm wtc_hed.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtc_voi.asm wtc_voi.asm WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtc_com.asm wtc_com.asm WTDMAKE.WUP

rem ●プレイヤー・ビュアー ソースファイル
c:\lsic86\WSP -W -A .\OLD_WTD\graphics.h graphics.h WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtdsv.h wtdsv.h WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtdsv.c wtdsv.c WTDMAKE.WUP

rem ●メイク・ファイル
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_make.bat wtd_make.bat WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_wsp.bat wtd_wsp.bat WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\bat.bat bat.bat WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtdsv.mak wtdsv.mak WTDMAKE.WUP

rem ●Wonder Witch転送形式変換ファイル
c:\lsic86\WSP -W -A .\OLD_WTD\wtd.cf wtd.cf WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_h.cf wtd_h.cf WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wtdsv.cf wtdsv.cf WTDMAKE.WUP

rem ●各種テキストファイル
c:\lsic86\WSP -W -A .\OLD_WTD\wtd_his.txt wtd_his.txt WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\wmsv_his.txt wmsv_his.txt WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\fspnet.txt fspnet.txt WTDMAKE.WUP

rem ●各種 説明書などのドキュメント
c:\lsic86\WSP -W -A .\OLD_WTD\readme.doc readme.doc WTDMAKE.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\user.doc user.doc user_doc.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\develop.doc develop.doc deve_doc.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\HCP.vsd HCP.vsd HCP_vsd.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\Design.vsd Design.vsd Desi_vsd.WUP

rem ●各種 ドキュメントのソースファイル
c:\lsic86\WSP -W -A .\OLD_WTD\readme.pdf readme.pdf readme.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\user.pdf user.pdf user.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\develop.PDF develop.PDF develop.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\HCP.pdf HCP.pdf HCP.WUP
c:\lsic86\WSP -W -A .\OLD_WTD\Design.pdf Design.pdf Design.WUP

rem ●各種 ドキュメントのソースファイル 購入申込書
c:\lsic86\WSP -W -A .\OLD_WTD\buy.xls buy.xls WTDMAKE.WUP

rem ●アーカイブの作成
c:\lsic86\lha a wtdil.lzh  wtdil.hed
c:\lsic86\lha a wtdil.lzh  WTDMAKE.wup  readme.wup
c:\lsic86\lha a wtdil.lzh  user.wup     develop.wup  HCP.wup     design.wup
c:\lsic86\lha a wtdil.lzh  user_doc.wup deve_doc.wup HCP_vsd.wup desi_vsd.wup

