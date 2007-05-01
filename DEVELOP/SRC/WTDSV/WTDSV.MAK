include c:/wwitch/makefile.dmc

all:    wtdsv.fx

wtdsv.fx:  wtdsv.bin
wtdsv.bin: wtdsv.obj

wtdsv.obj: wtdsv.c
