;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				MML Compiler Program			|
;				Define file				|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;****************************************************************
;*								*
;*			�ϐ�					*
;*								*
;****************************************************************
;===============================================================|
;		MS-DOS	File�n���h�� & �t�@�C������p		|
;===============================================================|
.data?
;���R���p�C���O�t�@�C��
hMml_File	dw	?		;�n���h��(h)
szMml_File	dw	?		;�t�@�C���T�C�Y(sz)
pMml_File	dw	?		;�A�h���X�Ǘ�(p)
segMml_File	dw	?		;�A�h���X�Ǘ�(Segment)

;���R���p�C����t�@�C��
hWtd_File	dw	?		;
szWtd_File	dw	?		;
pWtd_File	dw	?		;
segWtd_File	dw	?		;

;�����F�t�@�C���p�i�S�āAlocal�ϐ��ɂ����B�j
;hVoice_File	dw	?		;
;szVoice_File	dw	?		;
;pVoice_File	dw	?		;
;segVoice_File	dw	?		;

;���C���N���[�h�t�@�C���p�i�S�āAlocal�ϐ��ɂ����B�j
;hInclude_File		dw	?		;
;szInclude_File		dw	?		;
;pInclude_File		dw	?		;
;segInclude_File	dw	?		;

;���f�o�b�O�p�i�S�āAlocal�ϐ��ɂ����B�j
;hTest_File	dw	?		;
;szTest_File	dw	?		;
;pTest_File	dw	?		;
;segTest_File	dw	?		;
