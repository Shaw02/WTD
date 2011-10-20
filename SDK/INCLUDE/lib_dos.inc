

ComSmole	proto	near,	sizeCOM:WORD
ExeSmole	proto	near,	szDGROUP:WORD
Memory_Open	proto	near,	ParaSize:word
Memory_Close	proto	near,	CloseSegment:word

File_Create	proto	near,	cFilename:dword,iAttr:word
File_Open	proto	near,	cFilename:dword,cMode:byte
File_Close	proto	near,	hFile:word
File_Load	proto	near,	hFile:word,	cBuff:dword
File_Load_S	proto	near,	hFile:word,	iSize:word,	cBuff:dword
File_Write	proto	near,	hFile:word,	iSize:word,	cBuff:dword
File_Seek	proto	near,	hFile:word,	iControl:BYTE,	dOffset	:dword

ChangeExt			proto	near,	cFilename:dword,cExt:dword
Change_Current_Directory	proto	near,	cDirname:dword

File_Err	proto	near



ASC2HEX8	proto	near
ASC2HEX16	proto	near
HEX2ASC8	proto	near
HEX2ASC16	proto	near
FH2A8		proto	near
FH2A16		proto	near
H2A_F		proto	near,	iValue	:WORD,	iForm	:WORD
H2A8		proto	near
dat2hex8	proto	near
dat2hex16	proto	near


