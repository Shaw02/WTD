;=======================================================================|
;									|
;		Wander Swan Total Sound Driver				|
;				define file				|
;					for Assemble Language		|
;									|
;					Programmed by			|
;						A.Watanabe		|
;									|
;=======================================================================|
;****************************************************************
;*								*
;*			�}�N����`				*
;*								*
;****************************************************************
;===============================================================|
;	�}�N��	���[�N�G���A�̃A�h���X���擾����		|
;===============================================================|
;	���}�N������						|
;		WTD_WorkGet	reg1,reg2			|
;	���Ԓl							|
;		reg1	Segment Address				|
;		reg2	Offset  Address				|
;===============================================================|
WTD_WorkGet	macro	segment,offset			;
		push	SRAM_Segment			;
		pop	segment				;segment
		mov	offset,ds:[ProcContext_heap]	;offset
		endm					;

;****************************************************************
;*								*
;*			�萔					*
;*								*
;****************************************************************
;===============================================================|
;		Wander Swan Segment Address			|
;===============================================================|
;�Z�O�����g�A�h���X��`
IRAM_Segment		equ	0000h			;�{��RAM
SRAM_Segment		equ	BANK_SRAM_ADDRESS	;SRAM
FROM_Segment		equ	BANK_ROM0_ADDRESS	;ROM

;===============================================================|
;		�{��RAM Work Address				|
;===============================================================|
CommEnpty_intvector	equ	000a0h		;���荞�݃x�N�^(028h�~4)
Hblank_intvector	equ	000bch		;���荞�݃x�N�^(02fh�~4)

;===============================================================|
;		���[�N�̈�A�h���X				|
;===============================================================|
;�\���̈ʒu
WTD_WorkAdd_User	equ	0000h		;���[�U�p���[�N
WTD_WorkAdd_Wave	equ	0100h		;���F
WTD_WorkAdd_Emb		equ	0200h		;�G���x���[�v
WTD_WorkAdd_System	equ	0380h		;�p�[�g���ʍ\����

WTD_WorkAdd_Ech0	equ	0400h		;Effect ch1
WTD_WorkAdd_Ech1	equ	0480h		;Effect ch2
WTD_WorkAdd_Ech2	equ	0500h		;Effect ch3
WTD_WorkAdd_PCM		equ	0580h		;Effect PCM Voice

WTD_WorkAdd_Ch0		equ	0600h		;ch0
WTD_WorkAdd_Ch1		equ	0680h		;ch1
WTD_WorkAdd_Ch2		equ	0700h		;ch2
WTD_WorkAdd_Ch3		equ	0780h		;ch3
WTD_WorkAdd_Ch4		equ	0800h		;ch4
WTD_WorkAdd_Ch5		equ	0880h		;ch5
WTD_WorkAdd_Ch6		equ	0900h		;ch6
WTD_WorkAdd_Ch7		equ	0980h		;ch7
WTD_WorkAdd_Ch8		equ	0a00h		;ch8
WTD_WorkAdd_Ch9		equ	0a80h		;ch9
WTD_WorkAdd_Ch10	equ	0b00h		;ch10
WTD_WorkAdd_Ch11	equ	0b80h		;ch11
WTD_WorkAdd_Ch12	equ	0c00h		;ch12
WTD_WorkAdd_Ch13	equ	0c80h		;ch13
WTD_WorkAdd_Ch14	equ	0d00h		;ch14
WTD_WorkAdd_Ch15	equ	0d80h		;ch15
WTR_WorkAdd_Ch16	equ	0e00h		;ch16
WTD_WorkAdd_Ch17	equ	0e80h		;ch17
WTD_WorkAdd_Ch18	equ	0f00h		;ch18
WTD_WorkAdd_Ch19	equ	0f80h		;ch19

WTD_WorkChSize		equ	080h		;���[�N�̃T�C�Y
WTD_WorkSize		equ	1000h		;���[�N�̃T�C�Y

WTD_WorkAdd_End		equ	WTD_WorkSize	;���[�N�̍Ō�{�P

;****************************************************************
;*								*
;*			�\���̒�`				*
;*								*
;****************************************************************
;===============================================================|
;		Micro Soft  RIFF and Wave data formats		|
;===============================================================|
;�\���̒�` RIFF Header
Riff			struc			;
Riff_Head		db	4	dup(?)	;'RIFF'
Riff_Size		dd	?		;File Size(�S��-8)
Riff_Type		db	4	dup(?)	;'WAVE'
Riff_Data		db	?		;�f�[�^
Riff			ends

;�\���̒�`	RIFF struct
RiffHed			struc			;
RiffHed_Head		db	4	dup(?)	;�w�b�_
RiffHed_Size		dd	?		;�w�b�_�̃f�[�^�̃T�C�Y
RiffHed_Data		db	?		;�w�b�_�̃f�[�^
RiffHed			ends			;

;�\���̒�`	WAVE fmt
WaveFmt			struc			;
WaveFmt_Head		db	4	dup(?)	;'fmt '
WaveFmt_Size		dd	?		;16	[byte]
WaveFmt_Type		dw	?		;1	(wave)
WaveFmt_Channel		dw	?		;1	(mono)
WaveFmt_SamplingRate	dd	?		;11025	[Hz]
WaveFmt_SamplingSec	dd	?		;11025	[Byte]
WaveFmt_DataSize	dw	?		;1	[Byte]
WaveFmt_ChannelSize	dw	?		;8	[bit]
WaveFmt			ends			;

;�\���̒�`	WAVE Data
WaveData		struc			;
WaveData_Head		db	4	dup(?)	;'data'
WaveData_Size		dd	?		;Data Size
WaveData_Data		db	?		;wave data
WaveData		ends			;

;===============================================================|
;		�p�[�g�ʃ��[�N�\����				|
;===============================================================|
;�\���̒萔��`
WTD_NoiseMode		equ	WTD_SweepLevel	;
WTD_Voice		equ	WTD_Program	;
WTD_VoiceRate		equ	WTD_ProgramRate	;
WTD_VoiceCnt		equ	WTD_ProgramCnt	;
WTD_Voice1st		equ	WTD_Program1st	;
WTD_Voice2nd		equ	WTD_Program2nd	;
WTD_Voice3rd		equ	WTD_Program3rd	;
WTD_Frection		equ	WTD_Bend	;
WTD_FrectionSet		equ	WTD_BendSet	;
WTD_Velocity		equ	WTD_ExprPanSet	;
WTD_PcmAddress		equ	WTD_LoopCount	;�������A�h���X
WTD_PcmSize		equ	WTD_LoopCount+4	;�����I���A�h���X
;---------------------------------------------------------------
;�p�[�g�ʍ\���̒�`
WTD			struc			;�e�p�[�g�ʗp	
WTD_FlagControl		dw	?		;00-01	�t���O
WTD_FlagTai		db	?		;02	�^�C�t���O
WTD_FlagSharp		db	?		;03	#�t���O
WTD_FlagFlat		db	?		;04	b�t���O
WTD_Channel		db	?		;05	�����/�ׯ�
WTD_Address		dw	?		;06-07	���t���̱��ڽ
WTD_LoopCount		db	8	dup(?)	;08-0F	���[�v��/PCM Address
WTD_LoopCountPointer	db	?		;10	��L�߲��
WTD_Program		db	?		;11	�o�͂������F
WTD_SweepLevel		db	?		;12	�����ߒl/ɲ��Ӱ��
WTD_SweepTime		db	?		;13	�����ߎ���
WTD_Leng		dw	?		;14-15	����
WTD_LengCounter		dw	?		;16-17	�����J�E���^�[
WTD_LengDefault		dw	?		;18-19	��̫�Ẳ���
WTD_KeyOffTime		dw	?		;1A-1B	�ް���ѐ���l
WTD_KeyOnDelay		dw	?		;1C-1D	�����ިڲ
WTD_KeyShift		db	?		;1E	�ڒ��l
WTD_Key			db	?		;1F	����
WTD_KeySet		db	8	dup(?)	;20-27	�o�͂�������
WTD_KeySetPointer	db	?		;28	��L�߲��
WTD_AcsentVelocity	db	?		;29	�A�N�Z���g�l
WTD_BendSet		dw	?		;2A-2B	�o�͂������g��
WTD_Bend		dw	?		;2C-2D	�w����g��
WTD_BendDetune		dw	?		;2E-2F	�f�B�`���[��
WTD_BendLfoDecayRate	db	?		;30	LFO�f�B�P�C���C�g
WTD_BendLfoSpeedRate	db	?		;31	LFO�X�s�[�h
WTD_BendLfoLevel	dw	?		;32-33	LFO�ψ�����
WTD_BendLfoCount	db	?		;34	LFO�ω���
WTD_BendLfoRateCounter	db	?		;35	LFO���C�g�p�J�E���^
WTD_BendLfoLevelSet	dw	?		;36-37	LFO���݂̕ψ�����
WTD_BendLfoCountCounter	db	?		;38	LFO�񐔗p�J�E���^
WTD_BendEmbAddress	db	?		;39	EMB�ԍ��i���ڽ�j
WTD_BendEmbRate		db	?		;3A	EMB���C�g
WTD_BendEmbCounter	db	?		;3B	EMB�J�E���^�[
WTD_BendEmbMaxMin	db	?		;3C	EMB�ő�^�ŏ��l
WTD_BendEmbLevelSet	db	?		;3D	EMB�ψ�����
WTD_Null_3E		db	?		;3E	���g�p
WTD_ExprPanSet		db	?		;3F	�o��/�ުۼè�
WTD_ExprSet		db	?		;40	�o�͉���/�����گ���
WTD_Expr		db	?		;41	����/�����گ���
WTD_ExprDetune		dw	?		;42-43	���ʑ����l
WTD_ExprLfoDecayRate	db	?		;44	LFO�f�B�P�C���C�g
WTD_ExprLfoSpeedRate	db	?		;45	LFO�X�s�[�h
WTD_ExprLfoLevel	dw	?		;46-47	LFO�ψ�����
WTD_ExprLfoCount	db	?		;48	LFO�ω���
WTD_ExprLfoRateCounter	db	?		;49	LFO���C�g�p�J�E���^
WTD_ExprLfoLevelSet	dw	?		;4A-4B	LFO���݂̕ψ�����
WTD_ExprLfoCountCounter	db	?		;4C	LFO�񐔗p�J�E���^
WTD_ExprEmbAddress	db	?		;4D	EMB�ԍ��i���ڽ�j
WTD_ExprEmbRate		db	?		;4E	EMB���C�g
WTD_ExprEmbCounter	db	?		;4F	EMB�J�E���^�[
WTD_ExprEmbMaxMin	db	?		;50	EMB�ő�^�ŏ��l
WTD_ExprEmbLevelSet	db	?		;51	EMB�ψ�����
WTD_WorkAddress		db	?		;52	���[�N���ڽ���8BIT
WTD_OctaveSet		db	?		;53	�o�͂����I�N�^�[�u
WTD_Octave		db	?		;54	�w��I�N�^�[�u
WTD_GateTime8		db	?		;55	�ް���сiQ,U)
WTD_GateTimeStepLast	dw	?		;56-57	�ް����(q)
WTD_GateTimeStepFirst	dw	?		;58-59	�ް����(u)
WTD_VolumeUpDown	db	?		;5A	���΃{�����[���̑����l
WTD_ModDecay		dw	?		;5B-5C	Ӽޭڰ��� �ި��ڲ�
WTD_ModLevel		db	?		;5D	Ӽޭڰ��� ����
WTD_ModLevelSet		db	?		;5E	���݂�Ӽޭڰ��� ����
WTD_Null_5F		db	?		;5F	���g�p
WTD_PanSet		db	?		;60	�o�̓p���|�b�g
WTD_Pan			db	?		;61	�p���|�b�g
WTD_PanDetune		dw	?		;62-63	���ʑ����l
WTD_PanLfoDecayRate	db	?		;64	LFO�f�B�P�C���C�g
WTD_PanLfoSpeedRate	db	?		;65	LFO�X�s�[�h
WTD_PanLfoLevel		dw	?		;66-67	LFO�ψ�����
WTD_PanLfoCount		db	?		;68	LFO�ω���
WTD_PanLfoRateCounter	db	?		;69	LFO���C�g�p�J�E���^
WTD_PanLfoLevelSet	dw	?		;6A-6B	LFO���݂̕ψ�����
WTD_PanLfoCountCounter	db	?		;6C	LFO�񐔗p�J�E���^
WTD_PanEmbAddress	db	?		;6D	EMB�ԍ��i���ڽ�j
WTD_PanEmbRate		db	?		;6E	EMB���C�g
WTD_PanEmbCounter	db	?		;6F	EMB�J�E���^�[
WTD_PanEmbMaxMin	db	?		;60	EMB�ő�^�ŏ��l
WTD_PanEmbLevelSet	db	?		;61	EMB�ψ�����
WTD_ProgramRate		dw	?		;62-63	���F��ς���B
WTD_Program1st		db	?		;64	���F�̏����l
WTD_Program2nd		db	?		;65	�o���ω�
WTD_Program3rd		db	?		;66	KeyOff�㉹�F
WTD			ends
;---------------------------------------------------------------
;�\���̈ʒu
WTD_BendLFO		equ	WTD_BendLfoDecayRate	;ChLFO�\���̐擪
WTD_ExprLFO		equ	WTD_ExprLfoDecayRate	;ChLFO�\���̐擪
WTD_PanLFO		equ	WTD_PanLfoDecayRate	;ChLFO�\���̐擪
WTD_BendEmb		equ	WTD_BendEmbAddress	;ChEmb�\���̐擪
WTD_ExprEmb		equ	WTD_ExprEmbAddress	;ChEmb�\���̐擪
WTD_PanEmb		equ	WTD_PanEmbAddress	;ChEmb�\���̐擪

;ChLFO�\����
WTD_ChLfo		struc
WTD_ChLfo_DecayRate	db	?		;	LFO�f�B�P�C���C�g
WTD_ChLfo_SpeedRate	db	?		;	LFO�X�s�[�h
WTD_ChLfo_Level		dw	?		;	LFO�ψ�����
WTD_ChLfo_Count		db	?		;	LFO�ω���
WTD_ChLfo_RateCounter	db	?		;	LFO���C�g�p�J�E���^
WTD_ChLfo_LevelSet	dw	?		;	LFO���݂̕ψ�����
WTD_ChLfo_CountCounter	db	?		;	LFO�񐔗p�J�E���^
WTD_ChLfo		ends
;ChEmb�\����
WTD_ChEmb		struc
WTD_ChEmb_Address	db	?		;	EMB�ԍ��i���ڽ�j
WTD_ChEmb_Rate		db	?		;	EMB���C�g
WTD_ChEmb_Counter	db	?		;	EMB�J�E���^�[
WTD_ChEmb_MaxMin	db	?		;	EMB�ő�^�ŏ��l
WTD_ChEmb_LevelSet	db	?		;	EMB�ψ�����
WTD_ChEmb		ends
;---------------------------------------------------------------
;�t���O�r�b�g�E�Z�b�g
WTD_Ctrl_BendLfo	equ	00001h		;�����k�e�n�X�C�b�`
WTD_Ctrl_BendEmb	equ	00002h		;�����G���x���[�v�X�C�b�`
WTD_Ctrl_ExprLfo	equ	00004h		;���ʂk�e�n�X�C�b�`
WTD_Ctrl_ExprEmb	equ	00008h		;���ʃG���x���[�v�X�C�b�`
WTD_Ctrl_PanLfo		equ	00010h		;�p���k�e�n�X�C�b�`
WTD_Ctrl_PanEmb		equ	00020h		;�p���G���x���[�v�X�C�b�`
WTD_Ctrl_Acsent		equ	00040h		;���̉��K�̓A�N�Z���g
WTD_Ctrl_EmbFreq	equ	00080h		;�����G���x���[�v ���bit
WTD_Ctrl_EmbVol		equ	00100h		;���ʃG���x���[�v ���bit
WTD_Ctrl_EmbPan		equ	00200h		;�p���G���x���[�v ���bit
WTD_Ctrl_Vol0		equ	00400h		;���ʁ��O & Relase
WTD_Ctrl_WorkSw		equ	00800h		;���̃R�}���h�́A���[�N�Q��
WTD_Ctrl_WorkCy		equ	01000h		;���[�N���Z���ʁA�I�[�o�[�t���[
WTD_Ctrl_WorkZe		equ	02000h		;���[�N���Z���ʁA�O�ɂȂ����B
WTD_Ctrl_Effect		equ	04000h		;���̃p�[�g�͌��ʉ����H
WTD_Ctrl_PlayEnd	equ	08000h		;���t�I��
;---------------------------------------------------------------
;�t���O�r�b�g�E���Z�b�g
WTD_Ctrl_BendLfoR	equ	0fffeh		;�����k�e�n�X�C�b�`
WTD_Ctrl_BendEmbR	equ	0fffdh		;�����G���x���[�v�X�C�b�`
WTD_Ctrl_ExprLfoR	equ	0fffbh		;���ʂk�e�n�X�C�b�`
WTD_Ctrl_ExprEmbR	equ	0fff7h		;���ʃG���x���[�v�X�C�b�`
WTD_Ctrl_PanLfoR	equ	0ffefh		;�p���k�e�n�X�C�b�`
WTD_Ctrl_PamEmbR	equ	0ffdfh		;�p���G���x���[�v�X�C�b�`
WTD_Ctrl_AcsentR	equ	0ffbfh		;���̉��K�̓A�N�Z���g
WTD_Ctrl_EmbFreqR	equ	0ff7fh		;�����G���x���[�v ���bit
WTD_Ctrl_EmbVolR	equ	0feffh		;���ʃG���x���[�v ���bit
WTD_Ctrl_EmbPanR	equ	0fdffh		;�p���G���x���[�v ���bit
WTD_Ctrl_Vol0R		equ	0fbffh		;���ʁ��O & Relase
WTD_Ctrl_WorkSwR	equ	0f7ffh		;���̃R�}���h�́A���[�N�Q��
WTD_Ctrl_WorkCyR	equ	0efffh		;���[�N���Z���ʁA�I�[�o�[�t���[
WTD_Ctrl_WorkZeR	equ	0dfffh		;���[�N���Z���ʁA�O�ɂȂ����B
WTD_Ctrl_EffectR	equ	0bfffh		;���̃p�[�g�͌��ʉ����H
WTD_Ctrl_PlayEndR	equ	07fffh		;���t�I��

;===============================================================|
;		�p�[�g���ʃ��[�N�\����				|
;===============================================================|
WTD_Sys			struc			;�V�X�e���S��	
WTD_Sys_Flag		dw	?		;00	Flag
WTD_Sys_ProgramOffset	dw	?		;02	Program Offset Address
WTD_Sys_ProgramSegment	dw	?		;04	Program Segment Address
WTD_Sys_MusicOffset	dw	?		;06	Music Offset Address
WTD_Sys_MusicSegment	dw	?		;08	Music Segment Address
WTD_Sys_EffectOffset	dw	?		;0a	Effect Offset Address
WTD_Sys_EffectSegment	dw	?		;0c	Effect Segment Address
WTD_Sys_PcmOffset	dw	?		;0e	Pcm Offset Address
WTD_Sys_PcmSegment	dw	?		;10	Pcm Segment Address
WTD_Sys_StayOutMask	dw	?		;12	�풓�����֎~
WTD_Sys_OldIntvector	dw	2	dup(?)	;14-17	�O�̊��荞�݃x�N�^
WTD_Sys_OldIntvectorCom	dw	2	dup(?)	;18-1B	�O�̊��荞�݃x�N�^
WTD_Sys_ComFIFO_Offset	dw	?		;1C-1D	FIFO Offset Address
WTD_Sys_ComFIFO_Segment	dw	?		;1E-1F	FIFO Segment Address
WTD_Sys_Null_20		db	?		;20	���g�p
WTD_Sys_VolumeMusic	db	?		;21	�\�t�g�E�F�A���� ���t
WTD_Sys_VolumeEffect	db	?		;22	�\�t�g�E�F�A���� ���ʉ�
WTD_Sys_VolumePCM	db	?		;23	�\�t�g�E�F�A���� PCM
WTD_Sys_Tempo		dw	?		;24	�e���|
WTD_Sys_TempoCounter	dw	?		;26	�e���|�J�E���^
WTD_Sys_MusicPart	db	?		;28	���t�̃p�[�g��(�ő�20)
WTD_Sys_EffectPart	db	?		;29	���ʉ��̃p�[�g��(�ő�3)
WTD_Sys_ComFIFO_Cnt	dw	?		;2A-2B	FIFO �|�C���^ ��������
WTD_Sys_ComFIFO_Adr	dw	?		;2C-2D	FIFO �|�C���^ ���M
WTD_Sys_ComFIFO_Size	dw	?		;2E-2F	FIFO �T�C�Y
WTD_Sys_RunningStatus	db	?		;30	MIDI Running Status
WTD_Sys			ends			
;---------------------------------------------------------------
;�t���O�r�b�g�E�Z�b�g
WTD_Sys_Music		equ	00001h		;���t��
WTD_Sys_Effect		equ	00002h		;���ʉ�������
WTD_Sys_Pcm		equ	00004h		;PCM�{�C�X������
WTD_Sys_PcmEnd		equ	00008h		;PCM�{�C�X�����I��
WTD_Sys_Midi		equ	00010h		;MIDI���[�h(�V�X�e���ł͖��g�p)
WTD_Sys_5		equ	00020h		;
WTD_Sys_6		equ	00040h		;
WTD_Sys_7		equ	00080h		;
WTD_Sys_ChannelMode1	equ	00100h		;�`�����l�����[�h ch1
WTD_Sys_ChannelMode2	equ	00200h		;�`�����l�����[�h ch2
WTD_Sys_ChannelMode3	equ	00400h		;�`�����l�����[�h ch3
WTD_Sys_ChannelMode4	equ	00800h		;�`�����l�����[�h ch4
WTD_Sys_EffectMask1	equ	01000h		;���ʉ��p�[�g�}�X�N ch1
WTD_Sys_EffectMask2	equ	02000h		;���ʉ��p�[�g�}�X�N ch2
WTD_Sys_EffectMask3	equ	04000h		;���ʉ��p�[�g�}�X�N ch3
WTD_Sys_EffectMask4	equ	08000h		;���ʉ��p�[�g�}�X�N ch4
;---------------------------------------------------------------
;�t���O�r�b�g�E���Z�b�g
WTD_Sys_MusicR		equ	0fffeh		;���t��
WTD_Sys_EffectR		equ	0fffdh		;���ʉ�������
WTD_Sys_PcmR		equ	0fffbh		;PCM�{�C�X������
WTD_Sys_PcmEndR		equ	0fff7h		;PCM�{�C�X�����I��
WTD_Sys_MidiR		equ	0ffefh		;MIDI���[�h(�V�X�e���ł͖��g�p)
WTD_Sys_5R		equ	0ffdfh		;
WTD_Sys_6R		equ	0ffbfh		;
WTD_Sys_7R		equ	0ff7fh		;
WTD_Sys_ChannelMode1R	equ	0feffh		;�`�����l�����[�h ch1
WTD_Sys_ChannelMode2R	equ	0fdffh		;�`�����l�����[�h ch2
WTD_Sys_ChannelMode3R	equ	0fbffh		;�`�����l�����[�h ch3
WTD_Sys_ChannelMode4R	equ	0f7ffh		;�`�����l�����[�h ch4
WTD_Sys_EffectMask1R	equ	0efffh		;���ʉ��p�[�g�}�X�N ch1
WTD_Sys_EffectMask2R	equ	0dfffh		;���ʉ��p�[�g�}�X�N ch2
WTD_Sys_EffectMask3R	equ	0bfffh		;���ʉ��p�[�g�}�X�N ch3
WTD_Sys_EffectMask4R	equ	07fffh		;���ʉ��p�[�g�}�X�N ch4

;===============================================================|
;		�\�t�g�E�F�A�G���x���[�v�\����			|
;===============================================================|
WTD_Emb			struc
WTD_Emb_AR		db	?		;00h	:Attack Rate
WTD_Emb_AS		db	?		;01h	:Attack Speed (001h)
WTD_Emb_AL		db	?		;02h	:Attack Level (0FFh)
WTD_Emb_FL		db	?		;03h	:First Level
WTD_Emb_DR		db	?		;04h	:Decay Rate
WTD_Emb_DS		db	?		;05h	:Decay Speed (081h)
WTD_Emb_DL		db	?		;06h	:Decay Level
WTD_Emb_Null1		db	?		;07h	:���g�p
WTD_Emb_SR		db	?		;08h	:Sustain Rate
WTD_Emb_SS		db	?		;09h	:Sustain Speed (081h)
WTD_Emb_SL		db	?		;0Ah	:Sustain Level (000h)
WTD_Emb_Null2		db	?		;0Bh	:���g�p
WTD_Emb_RR		db	?		;0Ch	:Relase Rate
WTD_Emb_RS		db	?		;0Dh	:Relase Speed (081h)
WTD_Emb_RL		db	?		;0Eh	:Relase Level (000h)
WTD_Emb_Null3		db	?		;0Fh	:���g�p
WTD_Emb			ends				

;===============================================================|
;			�ȃf�[�^�\����				|
;===============================================================|
WTD_Mus			struc
WTD_Mus_Name		db	4	dup(?)	;00-03h	:�I�ʎq
WTD_Mus_Version		dw	?		;04-05h	:Version
WTD_Mus_Extr		dw	?		;06-07h	:�g���w�b�_�T�C�Y
WTD_Mus_Emb		db	?		;08h	:�G���x���[�v����
WTD_Mus_Voice		db	?		;09h	:�g�`�f�[�^����
WTD_Mus_Part		db	?		;0Ah	:�p�[�g��
WTD_Mus_TimeBase	db	?		;0Bh	:�S�������̕�����
WTD_Mus_ExtrAdr		dw	?		;0Ch	:�g���w�b�_�̃A�h���X
WTD_Mus_DataAdr		dw	?		;0Eh	:�f�[�^�̃A�h���X
WTD_Mus_PartAdr		dw	?		;10h	:�ȃf�[�^�A�h���X
WTD_Mus			ends

;===============================================================|
;			�g���w�b�_�[�\���̒�`			|
;===============================================================|
WTD_MusEx		struc
;
;			���݁A���g�p
;
WTD_MusEx		ends
