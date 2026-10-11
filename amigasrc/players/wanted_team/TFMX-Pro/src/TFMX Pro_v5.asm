	*****************************************************
	****      TFMX Pro replayer for EaglePlayer,     ****
	****	     all adaptions by Wanted Team	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include 'hardware/intbits.i'
	include 'exec/exec_lib.i'
	include 'dos/dos_lib.i'
	include	'intuition/intuition.i'
	include	'intuition/intuition_lib.i'
	include	'intuition/screens.i'
	include 'libraries/gadtools.i'
	include 'libraries/gadtools_lib.i'

	SECTION	Player_Code,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: TFMX Pro player module V1.4 (16 June 2009)',0
	even
Tags
	dc.l	DTP_PlayerVersion,5
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,'WT'
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Save,Save
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	DTP_Config,Config
	dc.l	DTP_UserConfig,UserConfig
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_LoadFast!EPB_Voices!EPB_SampleInfo!EPB_Save!EPB_PrevPatt!EPB_NextPatt!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	DTP_DeliBase,DeliBase
	dc.l	EP_EagleBase,Eagle2Base
	dc.l	0

PlayerName
	dc.b	'TFMX Pro',0
Creator
	dc.b	'(c) 1990-94 by Chris Hülsbeck,',10
	dc.b	'adapted by Wanted Team',0
TFMXmdat
	dc.b	'mdat.',0
TFMXsmpl
	dc.b	'smpl.',0
TFMXobj
	dc.b	'tfmx.',0
ExPlayerName
	dc.b	'tfmx.obj',0
Text2
	dc.b	'Player is now using '
	even
Wait
	dc.b	'VBI wait mode!',0
Text
	dc.b	'SFX file loaded (no real subsongs)!!!',0
CfgPath0
	dc.b	'/'				; necessary for load from Configs dir
CfgPath1
	dc.b	'Configs/EP-TFMX_Pro.cfg',0
CfgPath2
	dc.b	'EnvArc:EaglePlayer/EP-TFMX_Pro.cfg',0
CfgPath3
	dc.b	'Env:EaglePlayer/EP-TFMX_Pro.cfg',0
	even
DeliBase
	dc.l	0
Eagle2Base
	dc.l	0
ModulePtr
	dc.l	0
SFXFlag
	dc.w	0
SamplePtr
	dc.l	0
SampleLen
	dc.l	0
EagleBase
	dc.l	0
SubsongsTable
	ds.b	32
MacrosNr
	dc.w	0
NoDMAWait
	dc.w	'WT'
Change
	dc.b	0
AudioFlag
	dc.b	0
ObjectPtr
	dc.l	0
ObjectSize
	dc.l	0
CHField2Base
	dc.l	0
Timer
	dc.w	0
RightVolume
	dc.w	64
LeftVolume
	dc.w	64
Voice1
	dc.w	-1
Voice2
	dc.w	-1
Voice3
	dc.w	-1
Voice4
	dc.w	-1
StructAdr
	ds.b	UPS_SizeOF

***************************************************************************
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.b	Change(PC),D0
	bne.s	NoChange

	lea	PatchTable(PC),A1
	move.l	ObjectPtr(PC),A0
	move.l	ObjectSize(PC),D1
	move.l	A0,EPG_ARG1(A5)
	move.l	A1,EPG_ARG3(A5)
	move.l	D1,EPG_ARG2(A5)
	moveq	#-2,D0
	move.l	d0,EPG_ARG5(A5)		
	moveq	#1,D0
	move.l	d0,EPG_ARG4(A5)			;Search-Modus
	moveq	#5,D0
	move.l	d0,EPG_ARGN(A5)
	move.l	EPG_ModuleChange(A5),A0
	jsr	(A0)
	lea	Change(PC),A0
	st.b	(A0)
NoChange
	moveq	#0,D0
	rts

***************************************************************************
**************************** DTP_UserConfig *******************************
***************************************************************************

UserConfig
	tst.l	dtg_GadToolsBase(A5)
	beq.w	ExitCfg
	sub.l	A0,A0
	move.l	dtg_IntuitionBase(A5),A6
	jsr	_LVOLockPubScreen(A6)		; try to lock the default pubscreen
	move.l	D0,PubScrnPtr+4
	beq.w	ExitCfg				; couldn't lock the screen

	move.w	ib_MouseX(A6),D0
	sub.w	#140/2,D0
	bpl.s	SetLeftEdge
	moveq	#0,D0
SetLeftEdge
	move.w	D0,WindowTags+4+2		; Window-X

	move.l	dtg_IntuitionBase(A5),A6
	move.w	ib_MouseY(A6),D0
	sub.w	#73/2,D0
	move.l	PubScrnPtr+4(PC),A0
	move.l	sc_Font(A0),A0
	sub.w	ta_YSize(A0),D0
	bpl.s	SetTopEdge
	moveq	#0,D0
SetTopEdge
	move.w	D0,WindowTags+12+2		; Window-Y

	move.l	PubScrnPtr+4(PC),A0
	suba.l	A1,A1
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOGetVisualInfoA(A6)		; get vi
	move.l	D0,VisualInfo
	beq.w	RemLock

	lea	GadgetList+4(PC),A0		; create a place for context data
	jsr	_LVOCreateContext(A6)
	move.l	D0,D4
	beq.w	FreeVi

	lea	GadArray0(PC),A4		; list with gadget definitions
	sub.w	#gng_SIZEOF,SP
CreateGadLoop
	move.l	(A4)+,D0			; gadget kind
	bmi.b	CreateGadEnd			; end of Gadget List reached !
	move.l	D4,A0				; previous
	move.l	SP,A1				; newgad
	move.l	(A4)+,A2			; tagList
	clr.w	gng_GadgetID(A1)		; gadget ID
	move.l	PubScrnPtr+4(PC),A3
	moveq	#0,D1
	move.b	sc_WBorLeft(A3),D1
	add.w	(A4)+,D1
	move.w	D1,gng_LeftEdge(A1)		; x-pos
	move.l	PubScrnPtr+4(PC),A3
	moveq	#1,D1
	add.b	sc_WBorTop(A3),D1
	move.l	sc_Font(A3),A3
	add.w	ta_YSize(A3),D1
	add.w	(A4)+,D1
	move.w	D1,gng_TopEdge(A1)		; y-pos
	move.w	(A4)+,gng_Width(A1)		; width
	move.w	(A4)+,gng_Height(A1)		; height
	move.l	(A4)+,gng_GadgetText(A1)	; gadget label
	move.l	#Topaz8,gng_TextAttr(A1)	; font for gadget label
	move.l	(A4)+,gng_Flags(A1)		; gadget flags
	move.l	VisualInfo(PC),gng_VisualInfo(A1)	; VisualInfo
	move.l	(A4)+,gng_UserData(A1)		; gadget UserData
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOCreateGadgetA(A6)		; create the gadget
	move.l	D0,(A4)+			; store ^gadget
	move.l	D0,D4
	bne.s	CreateGadLoop			; Creation failed !
CreateGadEnd
	add.w	#gng_SIZEOF,SP
	tst.l	D4
	beq.w	FreeGads			; Gadget creation failed !

	lea	WindowTags(PC),A1		; ^Window
	suba.l	A0,A0
	move.l	dtg_IntuitionBase(A5),A6
	jsr	_LVOOpenWindowTagList(A6)	; Window sollte aufgehen (WA_AutoAdjust)
	move.l	D0,WindowPtr			; Window really open ?
	beq.s	FreeGads

	move.l	WindowPtr(PC),A0		; ^Window
	suba.l	A1,A1				; should always be NULL
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOGT_RefreshWindow(A6)	; refresh all GadTools gadgets

	move.w	#-1,QuitFlag			; kein Ende :-)

	move.w	WaitBase+2(PC),WaitTemp

*-----------------------------------------------------------------------*
;
; Hauptschleife

MainLoop
	moveq	#0,D0				; clear Mask
	move.l	WindowPtr(PC),A0		; WindowMask holen
	move.l	wd_UserPort(A0),A0
	move.b	MP_SIGBIT(A0),D1
	bset.l	D1,D0
	move.l	4.W,A6
	jsr	_LVOWait(A6)			; Schlaf gut
ConfigLoop
	move.l	WindowPtr(PC),A0		; WindowMask holen
	move.l	wd_UserPort(A0),A0
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOGT_GetIMsg(A6)
	tst.l	D0				; no further IntuiMsgs pending?
	beq.s	ConfigExit			; nope, exit
	move.l	D0,-(SP)
	move.l	D0,A1				; ^IntuiMsg
	bsr.s	ProcessEvents
	move.l	(SP)+,A1
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOGT_ReplyIMsg(A6)		; reply msg
	bra.s	ConfigLoop			; get next IntuiMsg

ConfigExit
	tst.w	QuitFlag			; end ?
	bne.s	MainLoop			; nope !

*-----------------------------------------------------------------------*
;
; Shutdown

CloseWin
	move.l	WindowPtr(PC),A0
	move.l	dtg_IntuitionBase(A5),A6
	jsr 	_LVOCloseWindow(A6)			; Window zu
FreeGads
	move.l	GadgetList+4(PC),A0
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOFreeGadgets(A6)		; free linked list of gadgets
	clr.l	GadgetList+4
FreeVi
	move.l	VisualInfo(PC),A0
	move.l	dtg_GadToolsBase(A5),A6
	jsr	_LVOFreeVisualInfo(A6)		; free vi
RemLock
	suba.l	A0,A0
	move.l	PubScrnPtr+4(PC),A1
	move.l	dtg_IntuitionBase(A5),A6
	jsr	_LVOUnlockPubScreen(A6)		; unlock the screen
ExitCfg
	moveq	#0,D0				; no error
	rts

*-----------------------------------------------------------------------*
;
; Events auswerten

ProcessEvents
	move.l	im_Class(A1),D0			; get class
	cmpi.l	#IDCMP_CLOSEWINDOW,D0		; Close ?
	beq.w	ExitConfig
	cmpi.l	#MXIDCMP,D0			; MX-Gadget ?
	beq.s	DoGadget
	cmpi.l	#BUTTONIDCMP,D0			; Button-Gadget ?
	beq.s	DoGadget
	rts

DoGadget
	move.l	im_IAddress(A1),A0		; auslösendes Intuitionobjekt
	move.l	gg_UserData(A0),D0		; GadgetUserData ermitteln
	beq.s	DoGadgetEnd			; raus, falls nicht benutzt
	move.l	D0,A0				; Pointer kopieren
	jsr	(A0)				; Routine anspringen
DoGadgetEnd
	rts

*-----------------------------------------------------------------------*

SetWaitBase
	moveq	#0,D0
	move.w	im_Code(A1),D0			; get Number
	move.w	D0,WaitTemp
	rts

SaveConfig
	move.l	dtg_DOSBase(A5),A6
	moveq	#2,D5
NextPath
	cmp.w	#2,D5
	bne.b	NoPath3
	lea	CfgPath3(PC),A0
	bra.b	PutPath
NoPath3
	cmp.w	#1,D5
	bne.b	NoPath2
	lea	CfgPath2(PC),A0
	bra.b	PutPath
NoPath2
	lea	CfgPath1(PC),A0
PutPath
	move.l	A0,D1
	move.l	#1006,D2			; new file
	jsr	_LVOOpen(A6)
	move.l	D0,D1				; file handle
	beq.b	WrongPath
	move.l	D0,-(SP)
	lea	SaveBuf(PC),A0
	move.l	A0,D2
	moveq	#4,D3				; save size
	jsr	_LVOWrite(A6)
	move.l	(SP)+,D1
	jsr	_LVOClose(A6)
WrongPath
	dbf	D5,NextPath
UseConfig
	move.w	WaitTemp(PC),WaitBase+2
ExitConfig
	clr.w	QuitFlag			; quit config
	rts

VisualInfo
	dc.l	0
WindowPtr
	dc.l	0
SaveBuf
	dc.w	'WT'
WaitTemp
	dc.w	0
QuitFlag
	dc.w	0

WindowTags
	dc.l	WA_Left,0
	dc.l	WA_Top,0
	dc.l	WA_InnerWidth,140
	dc.l	WA_InnerHeight,63+10
GadgetList
	dc.l	WA_Gadgets,0
	dc.l	WA_Title,WindowName
	dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW!MXIDCMP!BUTTONIDCMP
	dc.l	WA_Flags,WFLG_ACTIVATE!WFLG_DRAGBAR!WFLG_DEPTHGADGET!WFLG_CLOSEGADGET!WFLG_RMBTRAP
PubScrnPtr
	dc.l	WA_PubScreen,0
	dc.l	WA_AutoAdjust,1
	dc.l	TAG_DONE

GadArray0
	dc.l	TEXT_KIND,GadTagList0
	dc.w	8,4,120,8
	dc.l	0,PLACETEXT_LEFT
	dc.l	0
	dc.l	0

GadArray1
	dc.l	MX_KIND,GadTagList1
	dc.w	96,16,17,9
	dc.l	0,PLACETEXT_LEFT
	dc.l	SetWaitBase
	dc.l	0

GadArray2
	dc.l	BUTTON_KIND,0
	dc.w	74,45+10,58,14
	dc.l	GadText2,PLACETEXT_IN
	dc.l	SaveConfig
	dc.l	0

GadArray3
	dc.l	BUTTON_KIND,0
	dc.w	8,45+10,58,14
	dc.l	GadText3,PLACETEXT_IN
	dc.l	UseConfig
	dc.l	0

	dc.l -1				; end of gadgets definitions

GadTagList0
	dc.l	GTTX_Text,GadgetText0
	dc.l	TAG_DONE

GadTagList1
	dc.l	GTMX_Labels,MXLabels0
	dc.l	GTMX_Active
WaitBase
	dc.l	0
	dc.l	GTMX_Spacing,4
	dc.l	TAG_DONE

MXLabels0
	dc.l	MXLabelText0
	dc.l	MXLabelText1
	dc.l	MXLabelText2
	dc.l	0

Topaz8
	dc.l	TOPAZname
	dc.w	TOPAZ_EIGHTY
	dc.b	$00,$01

TOPAZname
	dc.b	'topaz.font',0

WindowName
	dc.b	'TFMX Pro',0

MXLabelText0
	dc.b	'VBI wait',0
MXLabelText1
	dc.b	'DMA wait',0
MXLabelText2
	dc.b	'External',0

GadgetText0
	dc.b	'Set replay mode:',0
GadText2
	dc.b	'Save',0
GadText3
	dc.b	'Use',0
	even

***************************************************************************
******************************** DTP_Config *******************************
***************************************************************************

Config
	move.l	dtg_DOSBase(A5),A6
	moveq	#-1,D5
	lea	CfgPath3(PC),A0
	bra.b	SkipPath
SecondTry
	moveq	#0,D5
	lea	CfgPath0(PC),A0
SkipPath
	move.l	A0,D1
	move.l	#1005,D2			; old file
	jsr	_LVOOpen(A6)
	move.l	D0,D1				; file handle
	beq.b	Default
	move.l	D0,-(SP)
	lea	LoadBuf(PC),A4
	clr.l	(A4)
	move.l	A4,D2
	moveq	#4,D3				; load size
	jsr	_LVORead(A6)
	move.l	(SP)+,D1
	jsr	_LVOClose(A6)
	cmp.w	#'WT',(A4)+
	bne.b	Default
	move.w	(A4),D1
	beq.b	PutMode
	cmp.w	#2,D1
	bhi.b	Default
	bra.b	PutMode
Default
	tst.l	D5
	bne.b	SecondTry
	moveq	#0,D1				; default mode
PutMode
	lea	WaitBase+2(PC),A0
	move.w	D1,(A0)
	moveq	#0,D0
	rts

LoadBuf
	dc.l	0

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	move.b	AudioFlag(PC),D1
	beq.b	NoAudi
	bsr.w	ClearAudioVector
NoAudi
	cmp.w	#2,NoDMAWait
	bne.w	alloff
	move.l	ObjectPtr(PC),A0
	jmp	40(A0)

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-D7/A0-A6,-(A7)

	lea	StructAdr(PC),A2
	st	UPS_Enabled(A2)
	clr.w	UPS_Voice1Per(A2)
	clr.w	UPS_Voice2Per(A2)
	clr.w	UPS_Voice3Per(A2)
	clr.w	UPS_Voice4Per(A2)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A2)

	cmp.w	#2,NoDMAWait
	bne.b	NoObj1
	move.l	ObjectPtr(PC),A0
	jsr	36(A0)
	bra.b	Skip1
NoObj1
	tst.w	SFXFlag
	bne.b	Play

	lea	CHfield2(PC),A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play
	addq.l	#4,A0
	cmp.b	#-1,patterns(A0)
	bne.b	Play

	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
Play
	bsr.w	irqin
Skip1
	lea	StructAdr(PC),A2
	clr.w	UPS_Enabled(A2)

	movem.l	(A7)+,D1-D7/A0-A6
	moveq	#0,D0
	rts

DMAWait
	movem.l	D0/D1,-(SP)
	moveq	#8,D0
.dma1	move.b	$DFF006,D1
.dma2	cmp.b	$DFF006,D1
	beq.b	.dma2
	dbeq	D0,.dma1
	movem.l	(SP)+,D0/D1
	rts

SongEnd
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
	rts

SetAudioVector
	movem.l	D0/A1/A6,-(A7)
	movea.l	4.W,A6
	lea	StructInt(PC),A1
	moveq	#INTB_AUD0,D0
	jsr	_LVOSetIntVector(A6)		; SetIntVector
	move.l	D0,Channel0
	lea	StructInt(PC),A1
	moveq	#INTB_AUD1,D0
	jsr	_LVOSetIntVector(A6)
	move.l	D0,Channel1
	lea	StructInt(PC),A1
	moveq	#INTB_AUD2,D0
	jsr	_LVOSetIntVector(A6)
	move.l	D0,Channel2
	lea	StructInt(PC),A1
	moveq	#INTB_AUD3,D0
	jsr	_LVOSetIntVector(A6)
	move.l	D0,Channel3
	movem.l	(A7)+,D0/A1/A6
	rts

ClearAudioVector
	movea.l	4.W,A6
	movea.l	Channel0(PC),A1
	moveq	#INTB_AUD0,D0
	jsr	_LVOSetIntVector(A6)
	movea.l	Channel1(PC),A1
	moveq	#INTB_AUD1,D0
	jsr	_LVOSetIntVector(A6)
	movea.l	Channel2(PC),A1
	moveq	#INTB_AUD2,D0
	jsr	_LVOSetIntVector(A6)
	movea.l	Channel3(PC),A1
	moveq	#INTB_AUD3,D0
	jmp	_LVOSetIntVector(A6)

Channel0
	dc.l	0
Channel1
	dc.l	0
Channel2
	dc.l	0
Channel3
	dc.l	0
StructInt
	dc.l	0
	dc.l	0
	dc.w	$205
	dc.l	IntName
	dc.l	0
AudioBase
	dc.l	mwadr
IntName
	dc.b	'TFMX Pro Audio Interrupt',0,0
	even

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	move.l	CHField2Base(PC),D0
	beq.b	MaxPos
	move.l	D0,A0
	move.w	2(A0),D0
	cmp.w	4(A0),D0
	beq.b	MaxPos
	addq.w	#1,4(A0)
	bsr.w	SongNumber
	cmp.w	#2,NoDMAWait
	bne.w	playcont
	move.l	ObjectPtr(PC),A0
	jmp	96(A0)
MaxPos
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	move.l	CHField2Base(PC),D0
	beq.b	MinPos
	move.l	D0,A0
	move.w	(A0),D0
	cmp.w	4(A0),D0
	beq.b	MinPos
	subq.w	#1,4(A0)
	bsr.w	SongNumber
	cmp.w	#2,NoDMAWait
	bne.w	playcont
	move.l	ObjectPtr(PC),A0
	jmp	96(A0)
MinPos
	rts

***************************************************************************
********************************* EP_Save *********************************
***************************************************************************

	*------------------- Save Mem to Disk ----------------------*
	*---- ARG1 = StartAdr					----*
	*---- ARG2 = EndAdr					----*
	*---- ARG3 = PathAdr					----*

Save
	move.l	EPG_ARG1(A5),A2
	move.l	EPG_ARG2(A5),A3
	move.l	dtg_PathArrayPtr(A5),EPG_ARG3(A5)
	move.l	ModulePtr(PC),EPG_ARG1(A5)
	move.l	InfoBuffer+Songsize(PC),EPG_ARG2(A5)
	moveq	#-1,D0
	move.l	D0,EPG_ARG4(A5)
	clr.l	EPG_ARG5(A5)
	moveq	#5,D0
	move.l	D0,EPG_ARGN(A5)
	move.l	EPG_SaveMem(A5),A0
	jsr	(A0)
	bne.b	NoSave
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	A2,A0
	move.l	dtg_CopyString(A5),A1
	jsr	(A1)
	lea	TFMXsmpl(PC),A0
	move.l	dtg_CopyString(A5),A1
	jsr	(A1)
	move.l	A3,A0
	addq.l	#5,A0
	move.l	dtg_CopyString(A5),A1
	jsr	(A1)
	move.l	dtg_PathArrayPtr(A5),EPG_ARG3(A5)
	move.l	SamplePtr(PC),EPG_ARG1(A5)
	move.l	SampleLen(PC),D0
	cmp.l	InfoBuffer+SamplesSize(PC),D0
	blt.b	LoadedSizeLower
	move.l	InfoBuffer+SamplesSize(PC),D0
LoadedSizeLower
	move.l	D0,EPG_ARG2(A5)
	moveq	#-1,D0
	move.l	D0,EPG_ARG4(A5)
	moveq	#2,D0
	move.l	D0,EPG_ARG5(A5)
	moveq	#5,D0
	move.l	D0,EPG_ARGN(A5)
	move.l	EPG_SaveMem(A5),A0
	jsr	(A0)
NoSave
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplePtr(PC),D0
	beq.w	return
	move.l	D0,A2

	move.l	A2,A4
	moveq	#127,D5
	move.l	ModulePtr(PC),A1
	tst.l	464(A1)
	beq.b	OldFormat
	move.w	MacrosNr(PC),D5
	subq.l	#1,D5
	move.l	472(A1),D1
	add.l	D1,A1
	bra.b	Sample
OldFormat
	move.l	A1,A0
	lea	1536(A1),A1
	add.l	InfoBuffer+Songsize(PC),A0
	subq.l	#4,A0
NextCheck
	subq.l	#8,A0
	cmp.w	#$0700,(A0)
	bne.b	Sample
	dbf	D5,NextCheck
Sample
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3
NextShort
	move.l	A4,A2				; SamplesPtr
	move.l	ModulePtr(PC),A0
	move.l	(A1)+,D2			; FirstMacro
	add.l	D2,A0
NextMac
	cmp.b	#02,(A0)
	beq.b	SampleNor
	cmp.b	#$22,(A0)
	beq.b	SampleSynth
	cmp.l	#$07000000,(A0)+
	beq.b	NoSample
	bra.b	NextMac
SampleNor
	move.l	(A0),D4
	and.l	#$00FFFFFF,D4
	add.l	D4,A2
	moveq	#0,D1
	addq.l	#6,A0
	move.w	(A0),D1
	lsl.l	#1,D1
	bra.b	Normal
SampleSynth
	move.w	#USITY_AMSynth,EPS_Type(A3)
	bra.b	SkipInfo
NoSample
	dbf	D5,NextShort
	bra.b	Skip
Normal
	move.l	A2,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
SkipInfo
	dbf	D5,Sample
Skip
	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.l	CHField2Base(PC),D1
	beq.b	PosOK
	move.l	D1,A0
	move.w	4(A0),D0
	sub.w	(A0),D0
	bpl.b	PosOK
	move.w	4(A0),D0
PosOK
	rts

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
LoadSize	=	12
Songsize	=	20
Length		=	28
Samples		=	36
SamplesSize	=	44
Calcsize	=	52
Pattern		=	60
SynthSamples	=	68
ExtraInfo	=	76
Author		=	84

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_Calcsize,0		;52
	dc.l	MI_Pattern,0		;60
	dc.l	MI_SynthSamples,0	;68
	dc.l	MI_ExtraInfo,0		;76
	dc.l	MI_AuthorName,0		;84
	dc.l	MI_SpecialInfo,Header
	dc.l	MI_MaxSubSongs,32
	dc.l	MI_MaxPattern,128
	dc.l	MI_MaxSamples,128
	dc.l	MI_MaxLength,512
	dc.l	MI_Prefix,TFMXmdat
	dc.l	MI_About,Text2
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#'tfmx',(A0)
	bne.b	CheckAnother
	addq.l	#4,A0
	cmp.l	#'song',(A0)+
	bne.w	Fault
	tst.w	(A0)
	bne.w	Fault
	bra.w	OK1
CheckAnother
	cmp.l	#'TFMX',(A0)
	bne.w	Fault
	cmp.l	#'-SON',4(A0)
	bne.w	Fault
	cmp.w	#'G ',8(A0)
	bne.w	Fault
	move.l	464(A0),D1
	beq.b	late
	tst.w	D1
	bne.b	OK2
	swap	D1			; PC test
	cmp.b	#1,D1
	bgt.w	OK1
	bra.w	Fault
late
	tst.w	12(A0)
	bne.w	Fault
	cmp.w	#'  ',16(A0)
	beq.w	Fault
	cmp.w	#$303D,16(A0)		; extension for Lethal Zone
	beq.w	Fault
	cmp.l	#'(Emp',16(A0)
	bne.b	OK
	cmp.l	#'ty) ',20(A0)
	bne.b	OK
	cmp.w	#$0E60,14(A0)		; extension for Z-Out (title)
	beq.b	OK
	cmp.w	#$0860,14(A0)		; extension for Metal Law (jingle)
	bne.b	NextNew1
	cmp.w	#$090C,4644(A0)
	beq.b	OK
NextNew1
	cmp.w	#$0B20,14(A0)		; extension for Bug Bomber (unpacked)
	bne.b	NextNew2
	cmp.w	#$8C26,5120(A0)
	beq.b	OK
NextNew2
	cmp.w	#$0920,14(A0)		; extension for Metal Law (preview)
	bne.w	Fault
	cmp.w	#$9305,3876(A0)
	bne.b	Fault
OK
	move.l	#2048,D1
OK2
	cmp.w	#$8B0,14(A0)
	bne.b	NoException		; BMW exception
	cmp.l	#$01F4FF00,516(A0)
	beq.b	Fault
NoException
	moveq	#31,D2
	lea	256(A0),A1
NextPos
	moveq	#0,D3
	move.w	(A1)+,D3
	cmp.w	#$01FF,D3
	beq.b	SkipIt
	lsl.l	#4,D3				; * 16
	add.l	D1,D3
	lea	(A0,D3.L),A2
CheckEFFE
	cmp.w	#$EFFE,(A2)+
	beq.b	SevenVoice_Test
SkipIt
	dbf	D2,NextPos

	move.l	468(A0),D2
	beq.b	NoPack
	move.l	472(A0),D1
	move.l	(A0,D1.L),D1
	bra.b	CheckST
NoPack
	move.l	1536(A0),D1
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	move.l	2044(A0),D2
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D2
	bne.b	Fault
CheckST
	lea	(A0,D2.L),A1
	lea	(A0,D1.L),A0
CheckForST
	cmp.b	#63,(A0)
	bhi.b	Fault
	addq.l	#4,A0
	cmp.l	A0,A1
	bne.b	CheckForST
OK1
	moveq	#0,D0
Fault
	rts

SevenVoice_Test
	cmp.w	#$0003,(A2)+
	bne.b	CheckNext
	tst.b	(A2)
	bne.b	Fault
	tst.b	3(A2)
	beq.b	Fault
CheckNext
	addq.l	#4,A2
	addq.l	#8,A2
	bra.b	CheckEFFE

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	movea.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	movea.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName
	movea.l	dtg_LoadFile(A5),A0
	jsr	(A0)
	tst.l	D0
	bne.b	Exodus
	cmp.w	#2,WaitBase+2
	bne.b	Exodus
	movea.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	movea.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName2
	movea.l	dtg_LoadFile(A5),A0
	jsr	(A0)
	tst.l	D0
	beq.b	Exodus
	movea.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	movea.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	movea.l	dtg_PathArrayPtr(A5),A0
loop3
	tst.b	(A0)+
	bne.s	loop3
	subq.l	#1,A0
	lea	ExPlayerName(PC),A1
smp
	move.b	(A1)+,(A0)+
	bne.s	smp
	movea.l	dtg_LoadFile(A5),A0
	jmp	(A0)
Exodus
	rts

CopyName2
	move.l	dtg_PathArrayPtr(a5),a0
loop2	tst.b	(a0)+
	bne.s	loop2
	subq.l	#1,a0
	lea	TFMXobj(pc),a1
	bra.b	smpl

CopyName
	move.l	dtg_PathArrayPtr(a5),a0
loop	tst.b	(a0)+
	bne.s	loop
	subq.l	#1,a0
	lea	TFMXsmpl(pc),a1
smpl	move.b	(a1)+,(a0)+
	bne.s	smpl
	subq.l	#1,a0

	move.l	dtg_FileArrayPtr(a5),a1
	lea	TFMXmdat(pc),a2
mdat	move.b	(a2)+,d0
	beq.s	copy
	move.b	(a1)+,d1
	bset	#5,d1
	cmp.b	d0,d1
	beq.s	mdat

	move.l	dtg_FileArrayPtr(a5),a1
copy	move.b	(a1)+,(a0)+
	bne.s	copy
	rts

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq	#0,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	subq.l	#1,D1
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A1
	move.l	A0,(A1)+			; songdata buffer
	clr.w	(A1)				; SFXFlag

	lea	InfoBuffer(PC),A2	; A2 reserved for InfoBuffer
	move.l	D0,LoadSize(A2)
	clr.l	ExtraInfo(A2)

	cmp.w	#$0A40,14(A0)
	bne.b	NoSilva
	cmp.w	#$0026,274(A0)
	bne.b	NoSilva
	tst.w	338(A0)
	bne.b	NoSilva
	move.w	#$0026,338(A0)		; fix for Silva
NoSilva
	lea	SubsongsTable(PC),A3
	move.l	A3,A4
	clr.b	(A3)+
	moveq	#0,D1			; subsongs check
	moveq	#30,D5
	move.l	A0,A1			; A0 reserved for later use
	lea	60(A1),A6
Next
	addq.l	#1,D1
	move.w	258(A1),D2
	move.w	322(A1),D3
	bne.b	NoZero
	tst.b	(A4)
	bne.b	NoSub
NoZero
	cmp.w	#$1FF,D2
	beq.b	NoSub

	cmp.l	A1,A6
	bgt.b	CheckLater
	cmp.w	320(A1),D3
	beq.b	NoSub
CheckLater
	cmp.w	324(A1),D3
	bne.b	NoLast
	cmp.w	260(A1),D2
	beq.b	ReallyLast
NoLast
	move.b	D1,(A3)+
NoSub
	subq.l	#1,D5
	addq.l	#2,A1
	tst.l	D5
	bmi.b	Exit
	bra.b	Next
ReallyLast
	tst.b	(A4)
	bne.b	SkipPrev
	st	(A4)
	cmp.w	320(A1),D3
	beq.b	NoSub
SkipPrev
	move.w	D3,D4
	sub.w	D2,D4
	beq.b	NoSub

	cmp.l	A1,A6
	bgt.b	NoSub

	cmp.w	326(A1),D3
	bne.b	NoLast
	bra.b	NoSub

Exit
	clr.b	(A4)
	sub.l	A4,A3
	move.l	A3,SubSongs(A2)

	move.l	A0,A4
	add.l	D0,A4

	move.l	464(A0),D2
	bne.w	Packed

	move.l	A0,A3			; calculate length of songdata
	lea	1024(A3),A1
	add.l	2044(A3),A3
FindEndMacro
	cmp.l	#$07000000,(A3)+
	beq.b	LastMacro
	cmp.l	A3,A4
	bgt.b	FindEndMacro
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
LastMacro
	sub.l	A0,A3
	move.l	A3,Songsize(A2)
	move.l	A3,Calcsize(A2)

	lea	512(A1),A4

	moveq	#127,D4			; calculate number of patterns
	moveq	#0,D5
CheckPattern
	tst.l	D4
	beq.b	LastPattern
	subq.l	#1,D4
NextPattern
	move.l	(A1)+,D1
	move.l	(A1),D2
	sub.l	D1,D2
	cmp.w	#8,D2
	beq.b	CheckPattern
	addq.l	#1,D5
	dbf	D4,NextPattern
LastPattern
	move.l	D5,Pattern(A2)
	bne.b	NoSFX2
	st	SFXFlag
	lea	Text(PC),A1
	move.l	A1,ExtraInfo(A2)

NoSFX2
	moveq	#127,D4		; calculate number and length of samples
back1
	moveq	#0,D5
	moveq	#0,D3
	moveq	#0,D6
CheckMacro
	tst.l	D4
	beq.b	FoundLast
	subq.l	#1,D4
NextMacro
	move.l	(A4)+,D1
	move.l	A0,A1
	tst.l	464(A0)
	bne.b	SkipNew
	move.l	(A4),D2
	sub.l	D1,D2
	cmp.w	#8,D2
	beq.b	CheckMacro
SkipNew
	add.l	D1,A1
FindSample
	cmp.b	#02,(A1)
	beq.b	SampleFound
	cmp.b	#$22,(A1)
	beq.b	SynthFound
	cmp.l	#$07000000,(A1)+
	beq.b	CheckMacro
	bra.b	FindSample
SynthFound
	addq.l	#1,D6
	bra.b	SkipNormal
SampleFound
	addq.l	#1,D3
SkipNormal
	move.l	(A1),D1
	and.l	#$00FFFFFF,D1
	addq.l	#6,A1
	moveq	#0,D2
	move.w	(A1),D2
	lsl.l	#1,D2
	add.l	D2,D1
	cmp.l	D1,D5
	bgt.b	NextSample
	move.l	D1,D5
NextSample
	dbf	D4,NextMacro
FoundLast
	tst.l	464(A0)
	bne.b	NoSFXSub
	tst.w	SFXFlag
	beq.b	NoSFXSub
	move.l	D3,SubSongs(A2)
NoSFXSub
	move.l	D3,Samples(A2)
	move.l	D6,SynthSamples(A2)
	move.l	D5,SamplesSize(A2)
	add.l	D5,Calcsize(A2)

	cmp.l	#40000,Songsize(A2)		; Monkey Island (title) fix
	blt.b	NoFix
	cmp.w	#$0028,264(A0)
	bne.b	NoFix
	subq.w	#1,264(A0)
NoFix
	lea	16(A0),A3
	lea	Header,A1
	lea	248(A1),A0
	moveq	#5,D3
NextLine
	moveq	#39,D2
copy2
	move.b	(A3),(A0)+
	move.b	(A3)+,(A1)+
	dbf	D2,copy2
	move.b	#10,(A1)+	                 ; insert linefeeds
	clr.b	(A0)+
	dbf	D3,NextLine
	clr.w	(A1)
	clr.w	(A0)

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	SamplePtr(PC),A1
	move.l	A0,(A1)+			; sample buffer
	move.l	D0,(A1)+			; sample length
	add.l	D0,LoadSize(A2)

	move.l	A5,(A1)				; EagleBase

	move.l	Eagle2Base(PC),D0
	bne.b	Eagle2
	move.l	DeliBase(PC),D0
	bne.b	NoName
Eagle2
	bsr.w	FindName
NoName

	lea	NoDMAWait(PC),A4
	move.w	#'WT',(A4)
	st	2(A4)			; Change
	st	3(A4)			; AudioFlag
	lea	Wait(PC),A3
	move.l	#'VBI ',(A3)
	move.l	#'wait',4(A3)
	move.l	WaitBase(PC),D0
	beq.b	VBIWait
	clr.w	(A4)
	move.l	#'DMA ',(A3)
	move.l	#'wait',4(A3)
VBIWait
	cmp.w	#2,D0
	beq.b	ObjectRep
	lea	mwadr(PC),A0
	move.l	A0,AudioBase
	lea	CHfield2(PC),A0
	move.l	A0,CHField2Base
	bra.w	NoObject
ObjectRep
	move.l	#'exte',(A3)
	move.l	#'rnal',4(A3)
	move.w	D0,(A4)+		; NoDMAWait
	clr.w	(A4)			; Change + AudioFlag

	moveq	#2,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ObjectPtr(PC),A1
	move.l	A0,(A1)+			; object buffer
	add.l	D0,LoadSize(A2)
	cmp.l	#$000003F3,(A0)
	bne.w	InFile
	cmp.w	#$6000,32(A0)
	bne.w	InFile
	cmp.w	#$6000,96(A0)
	bne.w	InFile
	move.l	20(A0),D1
	cmp.w	#$900,D1		; no 7v replays
	bhi.w	InFile
	addq.l	#8,D1
	lsl.l	#2,D1
	sub.l	D1,D0
	bmi.w	InFile
	lea	LongVol(PC),A2
	clr.l	(A2)+
	clr.l	(A2)+
	clr.l	(A2)
	lea	32(A0),A2
	move.l	A0,A3
	add.l	D1,A0
	cmp.l	#$000003F2,(A0)
	bne.w	InFile
	sub.w	#700,D1
	move.l	D1,(A1)+		; patch size
	clr.l	(A1)			; CHField2Base

ScanObject
	cmp.l	#$BFD700,(A2)
	bne.b	No1
	lea	timerspeed(PC),A1
	move.l	A1,(A2)+
No1
	cmp.l	#$BFD600,(A2)
	bne.b	No2
	lea	timerspeed+1(PC),A1
	move.l	A1,(A2)+
No2
	cmp.w	#$4E73,(A2)
	bne.b	No3
	addq.w	#2,(A2)+		; rts
No3
	cmp.l	#$12390000,(A2)
	bne.b	No4
	move.l	#$4E71122D,(A2)+	; nop + move.b $xx(A5),D1
	addq.l	#2,A2
No4
	cmp.l	#$2D790000,(A2)
	bne.b	No5
	cmp.w	#$0070,4(A2)
	bne.b	No5
	move.w	#$4E71,D1
	move.w	D1,(A2)+
	move.w	D1,(A2)+
	move.w	D1,(A2)+
	move.w	D1,(A2)+
	addq.l	#2,A2
	move.l	A2,A1
	add.w	(A2)+,A1
	move.l	A1,AudioBase
	lea	AudioFlag(PC),A1
	st	(A1)
	lea	SetAudioVector(PC),A1
	move.w	#$4EB9,(A2)+		; jsr to
	move.l	A1,(A2)+		; Audio Vector
No5
	cmp.l	#$39400008,(A2)
	bne.b	No6

	move.l	LongVol(PC),D1
	bne.b	PatchSet
	move.l	A3,D1
	lea	LongVol(PC),A1
	move.l	D1,(A1)
	move.w	#$4EF9,(A3)+
	lea	PatchVol(PC),A1
	move.l	A1,(A3)+
PatchSet
	move.w	#$6100,(A2)+
	sub.l	A2,D1
	move.w	D1,(A2)+
No6
	cmp.l	#$28414290,(A2)
	bne.b	No7
	addq.l	#4,(A2)+		; empty sample fix for Gem'X and MI
No7
	cmp.l	#$39410004,(A2)
	bne.b	No8
	move.l	LongLen(PC),D1
	bne.b	PatchSet2
	move.l	A3,D1
	lea	LongLen(PC),A1
	move.l	D1,(A1)
	move.w	#$4EF9,(A3)+
	lea	PatchLen(PC),A1
	move.l	A1,(A3)+
PatchSet2
	move.w	#$6100,(A2)+
	sub.l	A2,D1
	move.w	D1,(A2)+
No8
	cmp.w	#$2880,(A2)
	bne.b	No9
	cmp.w	#$2B40,-4(A2)
	bne.b	No9
	move.w	-2(A2),D1
	lea	Code5(PC),A1
	move.w	D1,2(A1)
	move.w	D1,8(A1)
No9
	cmp.l	#$39400006,(A2)
	bne.b	No10

	move.l	LongPer(PC),D1
	bne.b	PatchSet3
	move.l	A3,D1
	lea	LongPer(PC),A1
	move.l	D1,(A1)
	move.w	#$4EF9,(A3)+
	lea	PatchPer(PC),A1
	move.l	A1,(A3)+
PatchSet3
	move.w	#$6100,(A2)+
	sub.l	A2,D1
	move.w	D1,(A2)+
No10
	cmp.l	#$0A8F09F7,(A2)			; no Atari ST replays
	beq.b	InFile
	addq.l	#2,A2
	cmp.l	A2,A0
	bne.w	ScanObject

	bsr.w	ModuleChange
NoObject
	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

LongVol
	dc.l	0
LongLen
	dc.l	0
LongPer
	dc.l	0

PatchLen
	move.w	D1,4(A4)
	move.l	D0,-(A7)
	move.w	D1,D0
	bsr.w	SetLen
	move.l	(A7)+,D0
	rts

PatchVol
	bsr.w	ChangeVolume
	bsr.w	SetVol
	rts

PatchPer
	move.w	D0,6(A4)
	bsr.w	SetPer
	rts

FindName
	lea	Header+248,A1			; A1 - begin sampleinfo
	move.l	A1,EPG_ARG1(A5)
	moveq	#41,D0				; D0 - length per one sampleinfo
	move.l	D0,EPG_ARG2(A5)
	moveq	#40,D0				; D0 - max. sample name
	move.l	D0,EPG_ARG3(A5)
	moveq	#6,D0				; D0 - max. samples number
	move.l	D0,EPG_ARG4(A5)
	moveq	#4,D0
	move.l	D0,EPG_ARGN(A5)
	jsr	ENPP_FindAuthor(A5)
	move.l	EPG_ARG1(A5),Author(A2)		; output
	rts

InFile
	moveq	#EPR_ErrorInFile,D0
	rts

OneMacro
	move.l	D4,A3
FindStop3
	tst.b	(A3)
	bmi.b	back2
	subq.l	#4,A3
	bra.b	FindStop3
Packed
	tst.w	D2			; PC songs tests
	bne.b	NoPC
	swap	D2
	ror.w	#8,D2
	move.l	D2,464(A0)
	move.l	468(A0),D1
	ror.w	#8,D1
	swap	D1
	ror.w	#8,D1
	move.l	D1,468(A0)
	move.l	472(A0),D1
	ror.w	#8,D1
	swap	D1
	ror.w	#8,D1
	move.l	D1,472(A0)
NoPC
	move.l	468(A0),D1
	lea	(A0,D1.L),A3
	sub.l	472(A0),D1
	bne.b	NoSFX
	sub.w	#$200,D2
	lsr.l	#3,D2
	move.l	D2,SubSongs(A2)
	lea	SFXFlag(PC),A1
	st	(A1)				; SFXFlag
	lea	Text(PC),A1
	move.l	A1,ExtraInfo(A2)
NoSFX
	move.l	(A3),D2
FindStop1
	cmp.l	#$07000000,-(A3)
	bne.b	FindStop1
	move.l	A3,D4
FindStop2
	cmp.l	#'    ',(A3)
	beq.b	OneMacro
	cmp.l	#$07000000,-(A3)
	bne.b	FindStop2
back2
	addq.l	#4,A3
	sub.l	A0,A3
	move.l	472(A0),D3
	lea	(A0,D3.L),A1
	moveq	#0,D4
NextLong
	addq.l	#1,D4
	move.l	(A1)+,D1
	beq.b	Error
	bmi.b	Error
	cmp.l	D1,A3
	beq.b	EndLong
	cmp.l	A1,A4
	bgt.b	NextLong
Error
	moveq	#EPR_ModuleTooShort,D0		; error message
	rts
EndLong
	sub.l	A0,A1
	move.l	A1,Songsize(A2)
	move.l	A1,Calcsize(A2)

	cmp.w	#2,WaitBase+2
	beq.b	NoTur
	cmp.l	#13024,A1			; Turrican II level 1 fix
	bne.b	NoTur
	cmp.l	#$04000027,12068(A0)
	bne.b	NoTur
	subq.l	#1,12068(A0)
NoTur
	sub.l	464(A0),D2
	lsr.l	#4,D2
	move.l	D2,Pattern(A2)
	move.w	D4,MacrosNr
	lea	(A0,D3.L),A4
	bra.w	back1

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	movea.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

SongNumber
	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	lea	SubsongsTable(PC),A0
	move.b	(A0,D0.W),D0
	rts

InitSound
	lea	StructAdr(PC),A0
	lea	UPS_SizeOF(A0),A1
ClearUPS
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearUPS

	move.w	Timer(PC),D2
	bne.b	TimerOK
	lea	Timer(PC),A0
	move.w	dtg_Timer(A5),D2
	move.w	D2,(A0)
TimerOK
	move.l	ModulePtr(PC),D0
	move.l	D0,A1
	btst	#1,11(A1)
	beq.b	PALik
	mulu.w	#50,D2
	divu.w	#60,D2
PALik
	lea	timerspeed(PC),A0
	move.w	D2,(A0)
	move.l	SamplePtr(PC),D1
	move.w	NoDMAWait(PC),D2
	cmp.w	#2,D2
	bne.b	NoObj2
	move.l	ObjectPtr(PC),A0
	jsr	52(A0)
	bra.b	Skip2
NoObj2
	bsr.w	initdata
Skip2
	bsr.b	SongNumber
	move.l	D0,D1
	move.l	ModulePtr(PC),A3
	lsl.l	#1,D1
	add.l	D1,A3
	move.w	320(A3),D6
	sub.w	256(A3),D6
	lea	InfoBuffer(PC),A1
	tst.w	D6
	bpl.b	LengthOK
	moveq	#1,D6
LengthOK
	move.w	D6,Length+2(A1)
	cmp.w	#2,D2
	bne.b	NoObj3
	move.l	ObjectPtr(PC),A0
	jsr	44(A0)
	bra.b	Skip3
NoObj3
	bsr.w	songplay
Skip3
	tst.w	SFXFlag
	beq.b	NoPlaySFX
	move.w	dtg_SndNum(A5),D0
	cmp.w	#2,D2
	bne.b	NoObj4
	move.l	ObjectPtr(PC),A0
	jsr	92(A0)
	bra.b	Skip4
NoObj4
	bsr.w	fxplay
Skip4
	clr.l	Length(A1)
NoPlaySFX
	move.w	timerspeed(PC),dtg_Timer(A5)
	rts

***************************************************************************
************************* DTP_Volume, DTP_Balance *************************
***************************************************************************
; Copy Volume and Balance Data to internal buffer

SetVolume
SetBalance
	move.w	dtg_SndLBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0

	move.w	D0,LeftVolume

	move.w	dtg_SndRBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0

	move.w	D0,RightVolume

	moveq	#0,D0
	rts

ChangeVolume
	move.l	D1,-(A7)
	and.w	#$7F,D0
	move.l	A4,D1
	cmp.w	#$F0A0,D1
	beq.s	Left1
	cmp.w	#$F0B0,D1
	beq.s	Right1
	cmp.w	#$F0C0,D1
	beq.s	Right2
	cmp.w	#$F0D0,D1
	bne.s	Exit2
Left2
	mulu.w	LeftVolume(PC),D0
	and.w	Voice4(PC),D0
	bra.s	Ex
Left1
	mulu.w	LeftVolume(PC),D0
	and.w	Voice1(PC),D0
	bra.s	Ex

Right1
	mulu.w	RightVolume(PC),D0
	and.w	Voice2(PC),D0
	bra.s	Ex
Right2
	mulu.w	RightVolume(PC),D0
	and.w	Voice3(PC),D0
Ex
	lsr.w	#6,D0
	move.w	D0,8(A4)
Exit2
	move.l	(A7)+,D1
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Adr -------------------------------*

SetAdr
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Len(PC),A0
	cmp.l	#$DFF0A0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A0
	cmp.l	#$DFF0B0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A0
	cmp.l	#$DFF0C0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Len(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Per -------------------------------*

SetPer
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Per(PC),A0
	cmp.l	#$DFF0A0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF0B0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF0C0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

***************************************************************************
**************************** EP_Voices ************************************
***************************************************************************

SetVoices
	lea	Voice1(PC),A0
	lea	StructAdr(PC),A1
	move.w	#$FFFF,D1
	move.w	D1,(A0)+			Voice1=0 setzen
	btst	#0,D0
	bne.s	.NoVoice1
	clr.w	-2(A0)
	clr.w	$DFF0A8
	clr.w	UPS_Voice1Vol(A1)
.NoVoice1
	move.w	D1,(A0)+			Voice2=0 setzen
	btst	#1,D0
	bne.s	.NoVoice2
	clr.w	-2(A0)
	clr.w	$DFF0B8
	clr.w	UPS_Voice2Vol(A1)
.NoVoice2
	move.w	D1,(A0)+			Voice3=0 setzen
	btst	#2,D0
	bne.s	.NoVoice3
	clr.w	-2(A0)
	clr.w	$DFF0C8
	clr.w	UPS_Voice3Vol(A1)
.NoVoice3
	move.w	D1,(A0)+			Voice4=0 setzen
	btst	#3,D0
	bne.s	.NoVoice4
	clr.w	-2(A0)
	clr.w	$DFF0D8
	clr.w	UPS_Voice4Vol(A1)
.NoVoice4
	move.w	D0,UPS_DMACon(A1)
	moveq	#0,D0
	rts

***************************************************************************
***************************** TFMX Pro player *****************************
***************************************************************************

; TFMX-ROUTINE
;versionnum = $0892
;        by
;  Chris Huelsbeck
; last 18.9.92 time 125
;
;	TFMX-OPTIONS (0=off,1=on)
;
;vbihelp	= 1+loadall+edit+demo	;vbi-routine (initializing)
;timerint	= 1;+edit+demo		;1=timerint. (problems with system !)
;trackq		= 8			;quantity of tracks (1-8)
;onseq		= 1+edit+demo		;0=only fx/1=sequencer
;onmutes	= 1+edit		;sequencer mute	0=off
;onpcont	= 1+edit+demo		;patterncont	0=off
;onpgoto	= 1+edit+demo		;pgosub/return	0=off
;onpfade	= 1+edit+demo		;pfade		0=off
;onpplay	= 1+edit+demo		;playsequence	0=off
;onpsend	= 1+edit+demo		;send flags	0=off
;onvibra	= 1+edit+demo		;vibrato	0=off
;onporta	= 1+edit+demo		;portamento	0=off
;onenvel	= 1+edit+demo		;envelope	0=off
;onsplit	= 1+edit+demo		;splitkey	0=off
;onriffs	= 1+edit+demo		;riffplaying	0=off
;onims		= 1+edit+demo	;Interference-modulation-synthesis 0=off
;on7voice	= 0;+edit+demo		;7 voices       0=off
;on7exec	= 0			;1= vector 4 server !
;onpsg		= 0;+edit		;ST Soundchip	0=off
;onwwait	= 1;+edit+demo+on7voice	;wavewait	0=off
;onmloop	= 1+edit+demo		;macroloops	0=off
;onlastn	= 1+edit+demo		;lastnotes	0=off
;onmgoto	= 1+edit+demo		;mgosub/return	0=off
;onmsetp	= 1+edit+demo		;set period	0=off
;onmsend	= 1+edit+demo		;send flags	0=off
;onlwave	= 1+edit+demo		;auto addbegin	0=off
;onmove		= 1+edit+demo		;move next to	0=off
;oncheck	= 1;+edit		;cracker nightmares	0=off
;outvol		= 0			;1=volume set only if changed
;nodmawait	= ?+edit+demo		;0=DMAwait 1 vbi (low rastertime)
;fxenable	= 1+edit+demo		;fxplay 	0=off
;custompplay	= 1+rec+demo		;1=patternplay (Trackq must be 8!)
;statm_end	= 1+edit+demo		;1=bad statements are not played
;note_vol	= 1+edit+demo		;1=set addvolume+note

;				Hardware-register
CHIP		= $dff000
;
INTENA		= $09a
INTENAR		= $01c
INTREQ		= $09c
INTREQR		= $01e
DMACON		= $096
ADKCON		= $09e
;
PRA		= $bfe001
AUDADR		= 0
AUDLEN		= 4
AUDPER		= 6
AUDVOL		= 8
;
paltimval	= 1790456
;

tfmx
;		bra.w	alloff		;+32 play from cli (loadsong)
;		bra.w	irqin		;+36 JSR from your irq
;		bra.w	alloff		;+40 clear all channels
;		bra.w	songplay	;+44 d0 = songnr.
;		bra.w	noteport	;+48 longword in d0
					;00000000
					;xx	 = note    00-3f
					;  xx	 = macro   00-7f
					;    x   = volume   0- f
					;     x  = channel  0- 3
					;      xx= detune  00-7f=pos / ff-80=neg
;		bra.w	initdata	;+52 mdatbase	in d0.l
					;    smplbase	in d1.l
					;    7voicebase in d2.l (1140 bytes)
					;    7voicerate in d3.w (0-22 KHz)
;		bra.w	vbion		;+56
;		bra.w	vbioff		;+60
;		bra.w	channeloff	;+64 channelno. in d0
;		bra.w	songplay	;+68 (Editor)
;		bra.w	fade		;+72 longword in d0
					;00000000
					;xx	 = unused
					;  xx	 = counter
					;    xx  = unused
					;      xx= endvolume
;		bra.w	info		;+76
					;a0	   = pointer to data
					;data+0.w  = fade end
					;data+2.w  = errorflag 0=ok,1=loop,2=songend
					;data+16.l = uservbi vector (+2)
					;data+30.w = 4 words programmer flags
;		bra.w	alloff		;+80 editor text (givetext)
					;a0=states
					;a1=notes
					;a2=specials
;		bra.w	playpatt1	;+84
					;d0.w = xx/xx pattern/transpose
;		bra.w	playpatt2	;+88
					;d0.w = 80/xx 80/transpose
					;a1.l = pointer to custompattern
;		bra.w	fxplay		;+92 d0.w = fx-number
;		bra.w	playcont	;+96 d0.w = songnr.
;		bra.w	alloff		;+100 (record)
					;a0.l = pointer to record buffer
					;d0.w = len of rec buffer in longwords
					;d1.w = song
					;d2.w = precounter
					;d3.w = metrocounter 1 clickspeed
					;d4.w = metrocounter 2 stepcounter
					;d5.w = Quantize
					;d6.l =
					;d7.l = bits for record options
					;bits		    		 1    0
					;bit 0 = metronome 		on/ off 
					;bit 1 = write note data	on/ off
					;bit 2 = record mode	      midi/keyboard
					;bit 3 = key ups	       yes/  no
					;bit 4 = songrecord	       yes/  no
;		bra.w	alloff		;+104 (metronome)
					;d0.w = 1/on 0/off
					;d3.w = metronome counter 1 clickspeed
					;d4.w = metronome counter 2 stepcounter
;		bra.w	alloff		;+108 (version)
					;d0.w = version number (decimal hexnumber)
;		bra.w	alloff		;+112
;		bra.w	installtimer	;+116 timer initialisieren
;		bra.w	alloff		;+120 lamerroutine (lamerin)
;		bra.w	initims		;+124 initimis
;		bra.w	alloff		;+128 set7freq

irqin
		movem.l	d0-d7/a0-a6,-(sp)
		lea	CHfield0(pc),a6
		move.l	help1(a6),-(sp)

	tst.w	NoDMAWait
	beq.b	.nodwait

		move.w	dmaconhelp+2(a6),d0
		beq.s	.nodwait
		move.w	d0,CHIP+DMACON
		moveq	#9,d1
		btst.l	#0,d0
		beq.s	.v2
		move.w	d1,AUDPER+$dff0a0
.v2
		btst.l	#1,d0
		beq.s	.v3
		move.w	d1,AUDPER+$dff0b0
.v3
		btst.l	#2,d0
		beq.s	.v4
		move.w	d1,AUDPER+$dff0c0
.v4
		btst.l	#3,d0
		beq.s	.v5
		move.w	d1,AUDPER+$dff0d0
.v5
		clr.w	dmaconhelp+2(a6)
.nodwait
		tst.b	allon(a6)
		bne.s	.cont
		bra.w	allout
.cont
		bsr.w	synthesizer
		tst.b	song(a6)
		bmi.s	.onlysynth
		bsr.w	sequencer
.onlysynth

	tst.w	NoDMAWait
	beq.b	allout

		lea	Synthfield0(pc),a5
		move.w	period(a5),AUDPER+$dff0a0
		lea	Synthfield1(pc),a5
		move.w	period(a5),AUDPER+$dff0b0
		lea	Synthfield2(pc),a5
		move.w	period(a5),AUDPER+$dff0c0
		lea	Synthfield3(pc),a5
		move.w	period(a5),AUDPER+$dff0d0

	bsr.w	DMAWait

		move.w	dmaconhelp(a6),CHIP+DMACON
		clr.w	dmaconhelp(a6)
allout
		move.l	(sp)+,help1(a6)
		movem.l	(sp)+,d0-d7/a0-a6
out5		rts

sequencer
		lea	CHfield2(pc),a5
		move.l	database(a6),a4
		subq.w	#1,scount(a6)
		bpl.s	out5
		move.w	speed(a5),scount(a6)
		move.w	mutes(a4),muteflags(a5)
		move.w	mutes+2(a4),muteflags+4(a5)
		move.w	mutes+4(a4),muteflags+8(a5)
		move.w	mutes+6(a4),muteflags+12(a5)
		move.w	mutes+8(a4),muteflags+16(a5)
		move.w	mutes+10(a4),muteflags+20(a5)
		move.w	mutes+12(a4),muteflags+24(a5)
		move.w	mutes+14(a4),muteflags+28(a5)

patternplay
		move.l	a5,a0
		clr.b	newstep(a6)
		bsr.s	play1x
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne.s	patternplay
		bsr.s	play1
		tst.b	newstep(a6)
		bne.s	patternplay
		rts

play1
		addq.l	#4,a0
play1x
		cmp.b	#$90,patterns(a0)	;pattern-number
		bcs.s	.play			;<$90 then play it
		cmp.b	#$fe,patterns(a0)	;is it $fe
		bne.s	out6			;no then out
		st.b	patterns(a0)		;set flag (done it)
		move.b	patterns+1(a0),d0	;channel-number in d0
		tst.w	muteflags(a0)		;track mutet ?
		beq.w	channeloff		;yes then clear channel
		rts				;no - out
.play
		lea	infodat(pc),a1
		st.b	info_seqrun(a1)
		tst.b	pawait(a0)		;waitmode on ?
		beq.s	play2			;no then next note/states
		subq.b	#1,pawait(a0)		;wait-1 and out
out6		rts
play2
		move.w	pstep(a0),d0		;actual pattern-step
		add.w	d0,d0			;*2 (word)
		add.w	d0,d0			;*2 (longword)
		move.l	padress(a0),a1		;a1=patternadress

		move.l	(a1,d0.w),help1(a6)	;get note/statment
		move.b	help1(a6),d0
		cmp.b	#$f0,d0			;if first byte > $ef
		bcc.s	play3			;then it's a statement
		move.b	d0,d7
		cmp.b	#$c0,d0			;>$bf
		bcc.s	.nonotewait
		cmp.b	#$7f,d0			;>$7f
		bcs.s	.nonotewait
		move.b	help1+3(a6),pawait(a0)	;set wait len
		clr.b	help1+3(a6)
.nonotewait
		move.b	patterns+1(a0),d1	;it's a note
		add.b	d1,d0			;add transpose to note
		cmp.b	#$c0,d7			;>$c0
		bcc.s	.porta
		and.b	#$3f,d0
.porta
		move.b	d0,help1(a6)
		move.l	help1(a6),d0		;d0=note/macro/vol/chan/detune
		tst.w	muteflags(a0)		;track mutet ?
		bne.s	.noplay			;yes then play not
		bsr.w	noteport		;note to synthesizer
.noplay
		cmp.b	#$c0,d7			;$c0<=d7
		bcc.s	play4
		cmp.b	#$7f,d7			;$7f>d7
		bcs.s	play4
		bra.w	play5
play3
		and.w	#$f,d0			;statement number
		add.w	d0,d0			;extend to word pointer
		add.w	d0,d0			;extend to longword pointer
		jmp	.jumptable2(pc,d0.w)
.jumptable2
		bra.w	pend		;$f0
		bra.w	ploop		;$f1	
		bra.w	pcont		;$f2
		bra.w	pwait		;$f3
		bra.w	pstop		;$f4
		bra.w	pkeyup		;$f5
		bra.w	pportsp		;$f6
		bra.w	pportsp		;$f7
		bra.w	pgosub		;$f8
		bra.w	preturn		;$f9
		bra.w	pfade		;$fa
		bra.w	ppseq		;$fb
		bra.w	pportsp		;$fc
		bra.w	psendflag	;$fd
		bra.w	pstopcus	;$fe
;		bra.w	play4		;$ff
play4
		addq.w	#1,pstep(a0)		;pattern-step +1
		bra.w	play2			;next note/statment

pend						;stament $f0 (end)
		st.b	patterns(a0)		;stop playing pattern
		move.w	cstep(a5),d0		;current track-step
		cmp.w	lstep(a5),d0		;= last step
		bne.s	seq1			;no then next step
		move.w	fstep(a5),cstep(a5)	;set first step

	bsr.w	SongEnd

		bra.s	seq2			;continue playing
seq1
		addq.w	#1,cstep(a5)		;current step +1
seq2
		bsr.w	newtrack		;set new tracks
		st.b	newstep(a6)		;set return flag and out
		rts
ploop						;statment $f1 (loop)
		tst.b	ploopcount(a0)		;loopcounter and flag
		beq.s	.set			;=0   then set new loop
		subq.b	#1,ploopcount(a0)	;loopcounter -1
		beq.s	play4			;next patternstep
		move.w	help1+2(a6),pstep(a0)	;set step
		bra.w	play2			;continue playing
.set
		move.b	help1+1(a6),ploopcount(a0)
		move.w	help1+2(a6),pstep(a0)	;set step
		bra.w	play2			;continue playing
pcont						;statment $f2 (cont)
		move.b	help1+1(a6),d0		;get patternnumber
		move.b	d0,patterns(a0)		;store pattern
		add.w	d0,d0
		add.w	d0,d0			;extend to longword pointer
		move.l	pattnbase(a6),a1	;a1=patternbase
		move.l	(a1,d0.w),d0		;get patternadress
		add.l	a4,d0			;add database
		move.l	d0,padress(a0)		;store patternadress
		move.w	help1+2(a6),pstep(a0)	;and pattern-step
		bra.w	play2			;and play it

pwait						;statment $f3 (wait)
		move.b	help1+1(a6),pawait(a0);set wait len
play5
		addq.w	#1,pstep(a0)		;pattern-step +1
		rts				;out - next track

pstopcus
		clr.w	custom(a6)
pstop						;statment $f4 (stop)
		st.b	patterns(a0)		;stop playing pattern
		rts				;on this track - out

pkeyup						;statment $f5 keyoff
		move.b	patterns+1(a0),d1	;it's a note
		add.b	d1,help1+1(a6)		;add transpose to note
pportsp						;statment $f5 keyoff/$f6 vibrato/$f7 envelope/$fc fxprio
		move.l	help1(a6),d0		;d0=$f5xxx/channel/xx
		tst.w	muteflags(a0)		;track mutet ?
		bne.s	.noplay			;yes, then no keyoff
		bsr.w	noteport		;to synthesizer
.noplay
		bra.w	play4			;continue playing

pgosub
		move.l	padress(a0),psubadr(a0)
		move.w	pstep(a0),psubstep(a0)

		move.b	help1+1(a6),d0		;get patternnumber
		move.b	d0,patterns(a0)		;store pattern
		add.w	d0,d0
		add.w	d0,d0			;extend to longword pointer
		move.l	pattnbase(a6),a1	;a1=patternbase
		move.l	(a1,d0.w),d0		;get patternadress
		add.l	a4,d0			;add database
		move.l	d0,padress(a0)		;store patternadress
		move.w	help1+2(a6),pstep(a0)	;and pattern-step
		bra.w	play2			;and play it
preturn
		move.l	psubadr(a5),padress(a5)
		move.w	psubstep(a5),pstep(a5)
		bra.w	play4
pfade
		lea	infodat(pc),a1
		tst.w	info_fade(a1)
		bne.w	play4
		move.w	#1,info_fade(a1)
		move.b	help1+3(a6),fadeend(a6)
		move.b	help1+1(a6),fadecount1(a6)
		move.b	help1+1(a6),fadecount2(a6)
		beq.s	.norm
		move.b	#1,fadeadd(a6)
		move.b	fadevol(a6),d0
		cmp.b	fadeend(a6),d0
		beq.s	.nofad
		bcs.w	play4
		neg.b	fadeadd(a6)
		bra.w	play4
.norm
		move.b	fadeend(a6),fadevol(a6)
.nofad
		clr.b	fadeadd(a6)
		clr.w	info_fade(a1)
		bra.w	play4

psendflag
		lea	infodat(pc),a1
		move.b	help1+1(a6),d0
		and.w	#$03,d0
		add.w	d0,d0
		move.w	help1+2(a6),info_flags(a1,d0.w)
		bra.w	play4

ppseq
		move.b	help1+2(a6),d1
		and.w	#$7,d1
		add.w	d1,d1
		add.w	d1,d1
		move.b	help1+1(a6),d0
		move.b	d0,patterns(a5,d1.w)
		move.b	help1+3(a6),patterns+1(a5,d1.w)
		and.w	#$7f,d0
		add.w	d0,d0			;*2
		add.w	d0,d0			;*2
		move.l	pattnbase(a6),a1	;a1=patternbase
		move.l	(a1,d0.w),d0		;get 1st patternadress
		add.l	a4,d0			;add database
		move.l	d0,padress(a5,d1.w)	;store pattern-adress
		clr.l	pstep(a5,d1.w)		;clear pattern-step
		sf.b	ploopcount(a5,d1.w)	;reset loops
		bra.w	play4

newtrack
		movem.l	a0-a1,-(sp)
back
		move.w	cstep(a5),d0		;current step
		lsl.w	#4,d0			;*16
		move.l	trackbase(a6),a0	;track-step-table
		add.w	d0,a0			;+step
		move.l	pattnbase(a6),a1	;pattern-adress-table

		move.w	(a0)+,d0		;get statment (? special)
		cmp.w	#$effe,d0		;if not equal $effe
		bne.s	cont			;to continue (normal step)
		move.w	(a0)+,d0		;get special-statment
		add.w	d0,d0
		add.w	d0,d0			;d0*4=pointer to adress of routine
		cmp.w	#efxx2,d0
		bcs.s	.ok
		moveq.l	#0,d0
.ok
		jmp	jumptable3(pc,d0.w)
jumptable3
		bra.w	stopsong	;$0000
		bra.w	loopsong	;$0001
		bra.w	speedsong	;$0002
		bra.w	set7freq	;$0003
		bra.w	fadesong	;$0004
efxx1
efxx2	= efxx1-jumptable3
cont
					;track 1
		move.w	d0,patterns(a5)	;store patternnumber/transpose
		bmi.s	.pp1		;play pattern ?
		clr.b	d0		;yes
		lsr.w	#6,d0		;*64
		move.l	(a1,d0.w),d0	;get 1st patternadress
		add.l	a4,d0		;add database
		move.l	d0,padress(a5)	;store pattern-adress
		clr.l	pstep(a5)	;clear pattern-step
		sf.b	ploopcount(a5)	;reset loops
.pp1
		movem.w	(a0)+,d0-d6
		move.w	d0,patterns+4(a5)
		bmi.s	.pp2
		clr.b	d0
		lsr.w	#6,d0
		move.l	(a1,d0.w),d0
		add.l	a4,d0
		move.l	d0,padress+4(a5)
		clr.l	pstep+4(a5)
		sf.b	ploopcount+4(a5)
.pp2
		move.w	d1,patterns+8(a5)
		bmi.s	.pp3
		clr.b	d1
		lsr.w	#6,d1
		move.l	(a1,d1.w),d0
		add.l	a4,d0
		move.l	d0,padress+8(a5)
		clr.l	pstep+8(a5)
		sf.b	ploopcount+8(a5)
.pp3
		move.w	d2,patterns+12(a5)
		bmi.s	.pp4
		clr.b	d2
		lsr.w	#6,d2
		move.l	(a1,d2.w),d0
		add.l	a4,d0
		move.l	d0,padress+12(a5)
		clr.l	pstep+12(a5)
		sf.b	ploopcount+12(a5)
.pp4
		move.w	d3,patterns+16(a5)
		bmi.s	.pp5
		clr.b	d3
		lsr.w	#6,d3
		move.l	(a1,d3.w),d0
		add.l	a4,d0
		move.l	d0,padress+16(a5)
		clr.l	pstep+16(a5)
		sf.b	ploopcount+16(a5)
.pp5
		move.w	d4,patterns+20(a5)
		bmi.s	.pp6
		clr.b	d4
		lsr.w	#6,d4
		move.l	(a1,d4.w),d0
		add.l	a4,d0
		move.l	d0,padress+20(a5)
		clr.l	pstep+20(a5)
		sf.b	ploopcount+20(a5)
.pp6
		move.w	d5,patterns+24(a5)
		bmi.s	.pp7
		clr.b	d5
		lsr.w	#6,d5
		move.l	(a1,d5.w),d0
		add.l	a4,d0
		move.l	d0,padress+24(a5)
		clr.l	pstep+24(a5)
		sf.b	ploopcount+24(a5)
.pp7
		tst.w	custom(a6)
		bne.s	.pp8
		move.w	d6,patterns+28(a5)
		bmi.s	.pp8
		clr.b	d6
		lsr.w	#6,d6
		move.l	(a1,d6.w),d0
		add.l	a4,d0
		move.l	d0,padress+28(a5)
		clr.l	pstep+28(a5)
		sf.b	ploopcount+28(a5)
.pp8
		movem.l	(sp)+,a0-a1
		rts

stopsong				;stat $effe 0000
		clr.b	allon(a6)
		movem.l	(sp)+,a0-a1	;jump out

	bsr.w	SongEnd

		rts
loopsong				;stat $effe 0001 xxxx (yyyy)
					;x=trackstep y=len (1-$7fff)
		tst.w	tloopcount(a6)
		beq.s	.pl1
		bmi.s	.pl2
		subq.w	#1,tloopcount(a6)
		bra.s	.pl3
.pl1
		move.w	#-1,tloopcount(a6)
		addq.w	#1,cstep(a5)	;current step +1
		bra.w	back		;continue playing
.pl2
		move.w	2(a0),d0

	bgt.s	.skip
	bsr.w	SongEnd
.skip

		subq.w	#1,d0
		move.w	d0,tloopcount(a6)
.pl3
		move.w	(a0),cstep(a5)	;set current step
		bra.w	back		;continue playing
speedsong				;stat $effe 0002 xxxx (yyyy zzzz)
					;x=speed/clicks y=BPM z=delay
		move.w	(a0),speed(a5)	;set new speed
		move.w	(a0),scount(a6)
		move.w	2(a0),d0
		bmi.s	.notim
		and.w	#$01ff,d0
		tst.w	d0
		beq.s	.notim
		move.l	#paltimval,d1
		divu.w	d0,d1
		move.w	d1,timersp(a6)

	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.w	D1,dtg_Timer(A5)
	move.l	dtg_SetTimer(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5

.notim
		addq.w	#1,cstep(a5)	;current step +1
		bra.w	back		;continue playing
set7freq				;stat $effe 0003 xxxx yyyy

fadesong				;stat $effe 0004 xxxx xxxx
		addq.w	#1,cstep(a5)	;current step +1
		lea	infodat(pc),a1
		tst.w	info_fade(a1)
		bne	back
		move.w	#1,info_fade(a1)
		move.b	3(a0),fadeend(a6)
		move.b	1(a0),fadecount1(a6)
		move.b	1(a0),fadecount2(a6)
		beq.s	.norm

		move.b	#1,fadeadd(a6)
		move.b	fadevol(a6),d0
		cmp.b	fadeend(a6),d0
		beq.s	.nofad
		bcs.w	back
		neg.b	fadeadd(a6)
		bra.w	back
.norm
		move.b	fadeend(a6),fadevol(a6)
.nofad
		move.b	#0,fadeadd(a6)
		clr.w	info_fade(a1)
		bra.w	back
synthesizer
		lea	Synthfield0(pc),a5
		bsr.s	specials
		lea	Synthfield1(pc),a5
		bsr.s	specials
		lea	Synthfield2(pc),a5
		bsr.s	specials
		lea	Synthfield3(pc),a5
specials
		move.l	audioadr(a5),a4
		tst.w	priocount(a5)
		bmi.s	.sp4
		subq.w	#1,priocount(a5)
		bra.s	.sp3
.sp4
		clr.b	priority(a5)
		clr.b	priority2(a5)
.sp3
		move.l	fxnote(a5),d0
		beq.s	.nofx
		clr.l	fxnote(a5)
		clr.b	priority(a5)
		bsr	noteport
		move.b	priority2(a5),priority(a5)
.nofx
macros
		tst.b	mstatus(a5)
		beq.w	modulations
mac1
		tst.w	mawait(a5)
		beq.s	mac2
		subq.w	#1,mawait(a5)
out1
		bra.w	modulations
mac2
		move.l	madress(a5),a0
		move.w	mstep(a5),d0
		add.w	d0,d0			;*2
		add.w	d0,d0			;*2

		lea	(a0,d0.w),a0
		move.l	(a0),help1(a6)		;store complete statment
		moveq.l	#0,d0
		move.b	help1(a6),d0		;macro-statment
		clr.b	help1(a6)
		add.w	d0,d0			;*2
		add.w	d0,d0			;*2 Extent to lw-pointer
		cmp.w	#mxx2,d0		;<-- num of statments *****
		bcc.w	macadd
		jmp	jumptable1(pc,d0.w)
jumptable1
		bra.w	mdmaoff		;$00
		bra.w	mdmaon		;$01
		bra.w	msetbegin	;$02
		bra.w	msetlen		;$03
		bra.w	mwait		;$04
		bra.w	mloop		;$05 *onmloop
		bra.w	mcont		;$06 *onmgoto
		bra.w	mstop		;$07
		bra.w	maddnote	;$08
		bra.w	msetnote	;$09
		bra.w	mclear		;$0a *onmclrs
		bra.w	mporta		;$0b *onporta
		bra.w	mvibrato	;$0c *onvibra
		bra.w	maddvolume	;$0d
		bra.w	msetvolume	;$0e
		bra.w	menvelope	;$0f
		bra.w	mloopkey	;$10 *onmloop
		bra.w	maddbegin	;$11
		bra.w	maddlen		;$12
		bra.w	mdmaoff2	;$13
		bra.w	mwaitkeyo	;$14
		bra.w	mgosub		;$15 *onmgoto
		bra.w	mreturn		;$16 *onmgoto
		bra.w	msetperiod	;$17 *onmsetp
		bra.w	msampleloop	;$18
		bra.w	msetone		;$19
		bra.w	mwavewait	;$1a *onwwait
		bra.w	mriff		;$1b *onriffs
		bra.w	msplitk		;$1c *onsplit
		bra.w	msplitv		;$1d *onsplit
		bra.w	mriff2		;$1e
		bra.w	mlastnote	;$1f *onlastn
		bra.w	msendflag	;$20
		bra.w	mplaynote	;$21
		bra.w	mimssstart	;$22
		bra.w	mimsslen	;$23
		bra.w	mimsset1	;$24
		bra.w	mimsmod1	;$25
		bra.w	mimsset2	;$26
		bra.w	mimsmod2	;$27
		bra.w	mimsdelta	;$28
		bra.w	mimsoff		;$29
		bra.w	mac3		;$2a
		bra.w	mchecksetrnd	;$2b
		bra.w	mbyteset	;$2c
		bra.w	mbytecheck	;$2d
		bra.w	msetchip	;$2e
		bra.w	mmovenextto	;$2f
		bra.w	mskip		;$30
		bra.w	mskeyup		;$31
		bra.w	maddword	;$32
		bra.w	mandword	;$33
mxx1

mxx2	= mxx1-jumptable1

macadd
	tst.w	NoDMAWait
	beq.b	.nodwait1

		tst.b	nwait(a5)
		beq.s	.nw
.nodwait1
		addq.w	#1,mstep(a5)
		bra.w	modulations

	tst.w	NoDMAWait
	beq.b	.nodwait2
.nw
		st.b	nwait(a5)
.nodwait2
mac3
		addq.w	#1,mstep(a5)
		bra.w	mac2

mdmaoff
		clr.b	envelope(a5)
		clr.b	vibsize1(a5)
		clr.w	potime(a5)
		clr.b	riffstats(a5)
		clr.w	ims_dlen(a5)
mdmaoff2
		addq.w	#1,mstep(a5)

	tst.w	NoDMAWait
	beq.b	.nodwait

		tst.b	help1+1(a6)
		bne.s	.nodirect
.nodwait
		move.w	offbits(a5),CHIP+DMACON	;dma disable

	bsr.b	.VolFix

		bra.w	mac2

*******************************************************************************
; Volume fix for "Gem'X" and "Monkey Island"

.VolFix
	tst.b	help1+2(A6)
	beq.b	.fader
	move.b	help1+3(A6),D0
	bra.b	.fade
.fader
	tst.b	help1+3(A6)
	beq.b	.noset
	move.w	basevol(A5),D0
	add.w	D0,D0
	add.w	basevol(A5),D0
	add.w	help1+2(A6),D0
.fade
	move.b	D0,volume(A5)
	moveq	#0,D1
	move.b	fadevol(A6),D1
	moveq	#0,D0
	move.b	volume(A5),D0
	btst	#6,D1
	bne.b	.nofad
	add.w	D0,D0
	add.w	D0,D0
	mulu.w	D1,D0
	lsr.w	#8,D0
.nofad
;	move.w	D0,AUDVOL(A4)

	bsr.w	ChangeVolume
	bsr.w	SetVol

.noset
	rts

*******************************************************************************

.nodirect
		move.w	offbits(a5),d0		;audiodma bits
		or.w	d0,dmaconhelp+2(a6)	;save the bits
		clr.b	nwait(a5)

	bsr.b	.VolFix

		bra.w	modulations

mdmaon
		move.w	clibits(a5),CHIP+INTENA
		move.w	clibits(a5),CHIP+INTREQ
		move.b	help1+1(a6),modstatus(a5)	;set wait
		addq.w	#1,mstep(a5)

	bsr.w	DMAWait
	tst.w	NoDMAWait
	beq.b	.nodwait

		move.w	onbits(a5),d0		;audiodma bits
		or.w	d0,dmaconhelp(a6)	;save the bits
		bra.w	mac2

.nodwait

		move.w	onbits(a5),CHIP+DMACON		;dma enable

	bsr.w	DMAWait

		bra.w	mac2

msetbegin
		clr.b	mabcount1(a5)
		move.l	help1(a6),d0		;startadress
		add.l	samplebase(a6),d0	;+base
addbeg
		move.l	d0,sbegin(a5)		;adress for synthesizing
;		move.l	d0,AUDADR(a4)		;set adress

	bsr.w	DMAWait
	move.l	D0,(A4)
	bsr.w	SetAdr

		addq.w	#1,mstep(a5)
		bra.w	mac2
maddbegin
		move.b	help1+1(a6),mabcount1(a5)
		move.b	help1+1(a6),mabcount2(a5)
		move.w	help1+2(a6),d1
		ext.l	d1
		move.l	d1,mabadd(a5)
		move.l	sbegin(a5),d0
		add.l	d1,d0
		tst.w	ims_dlen(a5)
		beq.s	addbeg
		move.l	d0,sbegin(a5)		;adress for synthesizing
		move.l	d0,ims_sstart(a5)	;adress for imsstart
		addq.w	#1,mstep(a5)
		bra.w	mac2

maddlen
		move.w	help1+2(a6),d0
		move.w	samplen(a5),d1
		add.w	d0,d1
		move.w	d1,samplen(a5)
		tst.w	ims_dlen(a5)
		beq.s	.addl
		move.w	d1,ims_slen(a5)
		addq.w	#1,mstep(a5)
		bra.w	mac2
.addl
		move.w	d1,AUDLEN(a4)

	move.l	D0,-(A7)
	move.w	d1,D0
	bsr.w	SetLen
	move.l	(A7)+,D0

		addq.w	#1,mstep(a5)
		bra.w	mac2
msetlen
		move.w	help1+2(a6),samplen(a5)
		move.w	help1+2(a6),AUDLEN(a4)	;set samplelength

	move.l	D0,-(A7)
	move.w	help1+2(A6),D0
	bsr.w	SetLen
	move.l	(A7)+,D0

		addq.w	#1,mstep(a5)
		bra.w	mac2

mbytecheck
		move.b	help1+1(a6),d0
		move.w	help1+2(a6),d1
		moveq	#$8,d2
		swap	d2
		ext.l	d1
		add.l	d2,d1
		and.l	#$7ffff,d1
		move.l	d1,a0
		cmp.b	(a0),d0
		bne.w	mac3
		addq.w	#2,mstep(a5)
		bra.w	mac2

msetchip
		move.l	a4,d1
		moveq	#0,d0
		move.b	help1+1(a6),d0
		lsl.w	#1,d0
		and.w	#$ff00,d1
		move.l	d1,a0
		move.w	help1+2(a6),(a0,d0.w)
		bra.w	mac3
;
mbyteset
		moveq	#$8,d2
		swap	d2
		move.w	help1+2(a6),d1
		ext.l	d1
		add.l	d2,d1
		and.l	#$7ffff,d1
		move.l	d1,a0
		move.b	help1+1(a6),(a0)
		bra.w	mac3
;
mchecksetrnd
		move.b	help1+1(a6),d0
		move.w	help1+2(a6),d1
		moveq	#$8,d2
		swap	d2
		ext.l	d1
		add.l	d2,d1
		and.l	#$7ffff,d1
		move.l	d1,a0
		cmp.b	(a0),d0
		beq.w	mac3
		moveq	#$34,d0
		move.l	d0,a1
		move.l	a4,d1
		sub.b	d1,d1
		move.l	d1,a0
		move.b	$7-$34(a0,d0.w),d1
		lsl.w	#8,d1
		move.b	$7-$34(a0,d0.w),d1
		move.b	d1,124(a1,d1.w)
		bra.w	mac3
mwait
		btst.b	#0,help1+1(a6)
		beq.s	.noriff
		tst.b	rifftrigg(a5)
		bne.w	out1
		move.b	#1,rifftrigg(a5)
		bra.w	mac3
.noriff
		move.w	help1+2(a6),mawait(a5)	;set wait
		bra.w	macadd
mwavewait
		move.w	help1+2(a6),irwait(a5)	;set wait
		clr.b	mstatus(a5)
		move.w	intbits(a5),CHIP+INTENA
		bra.w	macadd

mwadr
		movem.l	d0/a5,-(sp)
		lea	Synthfield0(pc),a5
		move.w	CHIP+INTREQR,d0
		and.w	CHIP+INTENAR,d0
		btst.l	#7,d0
		bne.s	.mw1
		lea	Synthfield1(pc),a5
		btst.l	#8,d0
		bne.s	.mw1
		lea	Synthfield2(pc),a5
		btst.l	#9,d0
		bne.s	.mw1
		lea	Synthfield3(pc),a5
.mw1
		move.w	clibits(a5),CHIP+INTREQ
		subq.w	#1,irwait(a5)
		bpl.s	.notyet
		move.b	#-1,mstatus(a5)
		move.w	clibits(a5),CHIP+INTENA
.notyet
		movem.l	(sp)+,d0/a5
;		rte

	rts

msplitk
		move.b	help1+1(a6),d0
		cmp.b	basenote+1(a5),d0		;note
		bhs.w	mac3
		move.w	help1+2(a6),mstep(a5)		;set jump step
		bra.w	mac2		

msplitv
		move.b	help1+1(a6),d0
		cmp.b	volume(a5),d0		;volume
		bhs.w	mac3
		move.w	help1+2(a6),mstep(a5)	;set jump step
		bra.w	mac2		

mmovenextto
		move.b	help1+1(a6),d0
		and.l	#$7f,d0
		move.l	macrobase(a6),a1
		add.w	d0,d0
		add.w	d0,d0
		adda.w	d0,a1
		move.l	(a1),a1			;get relative adress
		add.l	database(a6),a1		;+base
		move.w	help1+2(a6),d0		;step
		add.w	d0,d0
		add.w	d0,d0
		move.l	4(a0),(a1,d0.w)		;move statment to macro
		addq.w	#2,mstep(a5)
		bra.w	mac2

maddword
		move.w	help1(a6),d1
		add.w	d1,d1
		move.w	help1+2(a6),d0
		add.w	d0,(a0,d1.w)
		bra.w	mac3
mandword
		move.w	help1(a6),d1
		add.w	d1,d1
		move.w	help1+2(a6),d0
		and.w	d0,(a0,d1.w)
		bra.w	mac3
mriff
		move.b	help1+1(a6),riffmacro(a5)
		move.w	help1+2(a6),riffspeed(a5)
		move.w	#$0101,riffcount(a5)
		bsr.w	riffplay
		move.b	#1,rifftrigg(a5)
		bra.w	mac3

mriff2
		move.b	help1+1(a6),riffAND(a5)
		bra.w	mac3

mloopkey
		tst.b	keyflag(a5)		;keyflag=0 ?
		beq.w	mac3			;yes, then next macrostep
mloop
		tst.b	mloopcount(a5)
		beq.s	.set
		subq.b	#1,mloopcount(a5)
		beq.w	mac3
		move.w	help1+2(a6),mstep(a5)	;set loop step
		bra.w	mac2
.set
		move.b	help1+1(a6),mloopcount(a5)
		move.w	help1+2(a6),mstep(a5)	;set loop step
		bra.w	mac2

mstop
		clr.b	mstatus(a5)
		bra.w	modulations
maddvolume
		cmp.b	#$fe,help1+2(a6)
		bne.s	.no
		move.b	basenote+1(a5),d2	;note
		move.b	help1+3(a6),d3
		clr.w	help1+2(a6)
		lea	.back(pc),a1
		bra.w	mputnote
.back
		move.b	d3,help1+3(a6)
.no
		move.w	basevol(a5),d0
		add.w	d0,d0
		add.w	basevol(a5),d0
		add.w	help1+2(a6),d0
		move.b	d0,volume(a5)
		addq.w	#1,mstep(a5)
		bra.w	mac2
msetvolume
		cmp.b	#$fe,help1+2(a6)
		bne.s	.no
		move.b	basenote+1(a5),d2	;note
		move.b	help1+3(a6),d3
		clr.w	help1+2(a6)
		lea	.back(pc),a1
		bra.s	mputnote
.back
		move.b	d3,help1+3(a6)
.no
		move.b	help1+3(a6),volume(a5)
		addq.w	#1,mstep(a5)
		bra.w	mac2
mplaynote
		move.b	basenote+1(a5),help1(a6)
		move.b	basevol+1(a5),d0
		lsl.b	#4,d0
		or.b	d0,help1+2(a6)
		move.l	help1(a6),d0
		bsr.w	noteport
		bra.w	mac3
mskeyup
		move.b	#$f5,help1(a6)
		move.l	help1(a6),d0
		bsr.w	noteport
		bra.w	mac3
mlastnote
		move.b	basenote(a5),d2
		lea	macadd(pc),a1
		bra.s	mputnote
msetnote
		moveq.l	#0,d2
		lea	macadd(pc),a1
		bra.s	mputnote
maddnote
		move.b	basenote+1(a5),d2	;note
		lea	macadd(pc),a1
mputnote
		move.b	help1+1(a6),d0
		add.b	d2,d0
		and.b	#$3f,d0
		ext.w	d0
		add.w	d0,d0
		lea	nottab(pc),a0		;note-periods		
		move.w	(a0,d0.w),d0
		move.w	detunes(a5),d1
		add.w	help1+2(a6),d1
		beq.s	.zero
		add.w	#256,d1
		mulu.w	d1,d0
		lsr.l	#8,d0
.zero
		move.w	d0,baseperiod(a5)
		tst.w	potime(a5)
		bne.s	.no

	bsr.w	SetPer
	tst.w	NoDMAWait
	beq.b	.nodwait

		move.w	d0,period(a5)
	jmp	(A1)

.nodwait
		move.w	d0,AUDPER(a4)		;set period

.no
		jmp	(a1)
msetperiod
		move.w	help1+2(a6),baseperiod(a5)
		tst.w	potime(a5)
		bne.w	mac3

	move.l	D0,-(A7)
	move.w	help1+2(a6),D0
	bsr.w	SetPer
	move.l	(A7)+,D0
	tst.w	NoDMAWait
	beq.b	.nodwait

		move.w	help1+2(a6),period(a5)
		bra.w	mac3
.nodwait
		move.w	help1+2(a6),AUDPER(a4)

	bra.w	mac3

mporta
		move.b	help1+1(a6),pospeed(a5)
		move.b	#1,pocount(a5)
		tst.w	potime(a5)
		bne.s	.noperiod
		move.w	baseperiod(a5),poperiod(a5)
.noperiod
		move.w	help1+2(a6),potime(a5)
		bra.w	mac3
mvibrato	
		move.b	help1+1(a6),d0
		move.b	d0,vibsize1(a5)
		lsr.b	#1,d0
		move.b	d0,vibsize2(a5)
		move.b	help1+3(a6),vibrate(a5)
		move.b	#1,vibcount(a5)

		tst.w	potime(a5)
		bne.w	mac3

	move.l	D0,-(A7)
	move.w	baseperiod(A5),D0
	bsr.w	SetPer
	move.l	(A7)+,D0
	tst.w	NoDMAWait
	beq.b	.nodwait

		move.w	baseperiod(a5),period(a5)

	bra.b	.skip
.nodwait
		move.w	baseperiod(a5),AUDPER(a4)
.skip
		clr.w	vibperiod(a5)
		addq.w	#1,mstep(a5)
		bra.w	mac2
menvelope
		move.b	help1+2(a6),envelope(a5)
		move.b	help1+1(a6),envspeed(a5)
		move.b	help1+2(a6),envcount(a5)
		move.b	help1+3(a6),envolume(a5)
		addq.w	#1,mstep(a5)
		bra.w	mac2
mclear
		clr.b	riffstats(a5)
		clr.w	ims_dlen(a5)
		clr.b	mabcount1(a5)
		clr.b	envelope(a5)
		clr.b	vibsize1(a5)
		clr.w	potime(a5)
		bra.w	mac3
mwaitkeyo
		tst.b	keyflag(a5)		;keyflag=0 ?
		beq.w	mac3			;yes, then next macrostep
		tst.b	mloopcount(a5)		;loopcount=0
		beq.s	.set			;yes, then set new counter
		subq.b	#1,mloopcount(a5)	;mloopcount-1
		beq.w	mac3			;now zero then next step
		bra.w	modulations		;go on
.set
		move.b	help1+3(a6),mloopcount(a5)	;wait to loopcount
		bra.w	modulations		;go on
mgosub
		move.l	madress(a5),msubadr(a5)
		move.w	mstep(a5),msubstep(a5)
mcont
		move.b	help1+1(a6),d0
		and.l	#$7f,d0
		move.l	macrobase(a6),a0
		add.w	d0,d0
		add.w	d0,d0
		adda.w	d0,a0
		move.l	(a0),d0			;get relative adress
		add.l	database(a6),d0		;+base
		move.l	d0,madress(a5)		;=macroadress
		move.w	help1+2(a6),mstep(a5)
		sf.b	mloopcount(a5)
		sf.b	mskipflag(a5)
		bra.w	mac2
mskip
		tst.b	mskipflag(a5)
		bne.s	.skip
		st.b	mskipflag(a5)
		bra.w	mac3
.skip
		move.w	help1+2(a6),mstep(a5)
		bra.w	mac2
mreturn
		move.l	msubadr(a5),madress(a5)
		move.w	msubstep(a5),mstep(a5)
		bra.w	mac3
msampleloop
		move.l	help1(a6),d0		;macro statment
		add.l	d0,sbegin(a5)		;+base
;		move.l	sbegin(a5),AUDADR(a4)	;set adress

	move.l	sbegin(a5),(a4)

		lsr.w	#1,d0
		sub.w	d0,samplen(a5)
		move.w	samplen(a5),AUDLEN(a4)
		addq.w	#1,mstep(a5)
		bra.w	mac2
msetone
		clr.b	mabcount1(a5)
		move.l	samplebase(a6),sbegin(a5)
;		move.l	samplebase(a6),AUDADR(a4)

	move.l	samplebase(a6),(a4)

		move.w	#1,samplen(a5)
		move.w	#1,AUDLEN(a4)		;set samplelength
		addq.w	#1,mstep(a5)
		bra.w	mac2
msendflag
		move.b	help1+1(a6),d0
		and.w	#3,d0
		add.w	d0,d0
		lea	infodat(pc),a0
		move.w	help1+2(a6),info_flags(a0,d0.w)
		bra.w	mac3

mimssstart
		clr.b	mabcount1(a5)
		move.l	help1(a6),d0
		add.l	samplebase(a6),d0	;+base
		move.l	d0,ims_sstart(a5)
		move.l	d0,sbegin(a5)		;adress for synthesizing
		move.l	samplebase(a6),d0
		add.l	ims_doffs(a5),d0
;		move.l	d0,AUDADR(a4)		;set adress

	bsr.w	DMAWait
	move.l	d0,(a4)
	bsr.w	SetAdr

		addq.w	#1,mstep(a5)
		bra.w	mac2
mimsslen
		move.w	help1(a6),d0
		bne.s	.no100
		move.w	#$100,d0
.no100
		lsr.w	#1,d0
		move.w	d0,AUDLEN(a4)	;set samplelength

	bsr.w	SetLen

		move.w	help1(a6),d0
		subq.w	#1,d0
		and.w	#$ff,d0
		move.w	d0,ims_dlen(a5)
		move.w	help1+2(a6),ims_slen(a5)
		move.w	help1+2(a6),samplen(a5)
		addq.w	#1,mstep(a5)
		bra.w	mac2
mimsset1
		move.l	help1(a6),d0
		lsl.l	#8,d0
		move.l	d0,ims_mod1(a5)
		addq.w	#1,mstep(a5)
		bra.w	mac2
mimsset2
		move.l	help1(a6),ims_mod2(a5)
		addq.w	#1,mstep(a5)
		bra.w	mac2
mimsmod1
		move.w	help1(a6),ims_mod1len(a5)
		move.w	help1(a6),ims_mod1len2(a5)
		move.w	help1+2(a6),ims_mod1add(a5)
		addq.w	#1,mstep(a5)
		bra.w	mac2
mimsmod2
		move.w	help1(a6),ims_mod2len(a5)
		move.w	help1(a6),ims_mod2len2(a5)
		move.w	help1+2(a6),ims_mod2add(a5)
		addq.w	#1,mstep(a5)
		bra.w	mac2
mimsdelta
		move.b	help1+3(a6),ims_delta(a5)
		move.b	help1+2(a6),d0
		ext.w	d0
		lsl.w	#4,d0
		move.w	d0,ims_fspeed(a5)
		move.w	help1(a6),ims_flen1(a5)
		move.w	help1(a6),ims_flen2(a5)
		addq.w	#1,mstep(a5)
		bra.w	mac2
mimsoff
		addq.w	#1,mstep(a5)
		clr.w	ims_dlen(a5)
		tst.b	help1+1(a6)
		beq.w	mac2
		clr.l	ims_mod1(a5)
		clr.w	ims_mod1len(a5)
		clr.w	ims_mod1len2(a5)
		clr.w	ims_mod1add(a5)
		clr.l	ims_mod2(a5)
		clr.w	ims_mod2len(a5)
		clr.w	ims_mod2len2(a5)
		clr.w	ims_mod2add(a5)
		clr.b	ims_delta(a5)
		clr.w	ims_fspeed(a5)
		clr.w	ims_flen1(a5)
		clr.w	ims_flen2(a5)
		move.b	help1+3(a6),ims_dolby(a5)
		bra.w	mac2
modulations
		tst.b	modstatus(a5)
		bmi.s	.ms1			;negative = no mods
		bne.s	.ms2			;positive = do mods
		move.b	#1,modstatus(a5)	;0	  = one vbi wait
.ms1
		bra.w	fader
.ms2

;	Modulation

smodin
		tst.b	mabcount1(a5)
		beq.s	imsin
		move.l	sbegin(a5),d0
		add.l	mabadd(a5),d0
		move.l	d0,sbegin(a5)
		tst.w	ims_dlen(a5)
		beq.s	.doit
		move.l	d0,ims_sstart(a5)	;adress for imsstart
		bra.s	.nodo

.doit	
;		move.l	d0,AUDADR(a4)

	move.l	d0,(a4)
	bsr.w	SetAdr

.nodo
;		sub.b	#1,mabcount1(a5)
		subq.b	#1,mabcount1(a5)
		bne.s	imsin
		move.b	mabcount2(a5),mabcount1(a5)
		neg.l	mabadd(a5)
imsin
		tst.w	ims_dlen(a5)
		beq.w	vibratos
		move.l	ims_sstart(a5),a0
		move.l	ims_mod1(a5),d4
		move.l	ims_mod2(a5),a3
		move.l	ims_doffs(a5),a1
		add.l	imsbase(a6),a1
		lea	$100(a1),a2	;next buffer for surround
		move.w	ims_dlen(a5),d7
		move.w	ims_slen(a5),d6
		move.b	ims_delta(a5),d3
		move.b	ims_dolby(a5),d5
		moveq.l	#0,d0
		move.b	ims_deltaold(a5),d1	;delta old
.loop
		add.l	a3,d4
		swap	d0
		add.l	d4,d0
		swap	d0
		and.w	d6,d0
		move.b	(a0,d0.w),d2	;get amplitude
		tst.b	d3
		beq.s	.nodelta
		cmp.b	d1,d2
		beq.s	.clr
		bgt.s	.add
		subx.b	d3,d1
		bvs.s	.clr
		cmp.b	d1,d2
		bge.s	.clr
.set
		move.b	d1,(a1)+
		tst.b	d5
		beq.s	.nodolby
		neg.b	d1
		move.b	d1,(a2)+
		neg.b	d1
		dbra	d7,.loop
		bra.s	.endloop
.add
		addx.b	d3,d1
		bvs.s	.clr
		cmp.b	d1,d2
		bgt.s	.set
.clr
		move.b	d2,d1
.nodelta
		move.b	d2,(a1)+
		tst.b	d5
		beq.s	.nodolby
		neg.b	d2
		move.b	d2,(a2)+
.nodolby
		dbra	d7,.loop
.endloop
		move.b	d1,ims_deltaold(a5)
		tst.b	d3
		beq.s	.setmod1
		move.w	ims_fspeed(a5),d0
		add.w	d0,ims_delta(a5)
		subq.w	#1,ims_flen1(a5)
		bne.s	.setmod1
		move.w	ims_flen2(a5),ims_flen1(a5)
		neg.w	ims_fspeed(a5)
.setmod1
		move.w	ims_mod1add(a5),d0
		ext.l	d0
		add.l	d0,ims_mod1(a5)
		subq.w	#1,ims_mod1len(a5)
		bne.s	.setmod2
		move.w	ims_mod1len2(a5),ims_mod1len(a5)
		beq.s	.setmod2
		neg.w	ims_mod1add(a5)
.setmod2
		move.w	ims_mod2add(a5),d0
		ext.l	d0
		add.l	d0,ims_mod2(a5)
		subq.w	#1,ims_mod2len(a5)
		bne.s	vibratos
		move.w	ims_mod2len2(a5),ims_mod2len(a5)
		beq.s	vibratos
		neg.w	ims_mod2add(a5)
;
vibratos
		tst.b	vibsize1(a5)
		beq.s	glides

		move.b	vibrate(a5),d0
		ext.w	d0
		add.w	d0,vibperiod(a5)
		move.w	baseperiod(a5),d0
		move.w	vibperiod(a5),d1
		beq.s	.zero
		and.l	#$ffff,d0
		add.w	#2048,d1
		mulu.w	d1,d0
		lsl.l	#5,d0
		swap d0
.zero
		tst.w	potime(a5)
		bne.s	.glide

;	bsr.w	SetPer
	tst.w	NoDMAWait
	beq.b	.nodwait

		move.w	d0,period(a5)

	bra.b	.glide

.nodwait
		move.w	d0,AUDPER(a4)
.glide
		subq.b	#1,vibsize2(a5)
		bne.s	glides
		move.b	vibsize1(a5),vibsize2(a5)

		eor.b	#$ff,vibrate(a5)
		addq.b	#1,vibrate(a5)
;
glides
		tst.w	potime(a5)
		beq.w	envelopes

		subq.b	#1,pocount(a5)
		bne.s	envelopes
		move.b	pospeed(a5),pocount(a5)

		move.w	baseperiod(a5),d1
		moveq.l	#0,d0
		move.w	poperiod(a5),d0
		cmp.w	d1,d0
		beq.s	.end
		bcs.s	.add

		move.w	#256,d2
		sub.w	potime(a5),d2
		mulu.w	d2,d0
		lsr.l	#8,d0
		cmp.w	d1,d0
		beq.s	.end
		bcc.s	.set
.end
		clr.w	potime(a5)
		move.w	baseperiod(a5),d0
.set
		and.w	#$07ff,d0
		move.w	d0,poperiod(a5)

	bsr.w	SetPer
	tst.w	NoDMAWait
	beq.b	.nodwait

		move.w	d0,period(a5)

		bra.s	envelopes
.nodwait
		move.w	d0,AUDPER(a4)

	bra.s	envelopes

.add
		move.w	potime(a5),d2
		add.w	#256,d2
		mulu.w	d2,d0
		lsr.l	#8,d0
		cmp.w	d1,d0
		beq.s	.end
		bcc.s	.end
		bra.s	.set
;
envelopes
		tst.b	envelope(a5)	;active ?
		beq.s	out4		;no then out
		tst.b	envcount(a5)	;delaycounter=0 ?
		beq.s	env1		;yes then do
		subq.b	#1,envcount(a5)	;delaycounter-1 and out
		bra.s	out4
env1
		move.b	envelope(a5),envcount(a5)	;set new delaycounter
		move.b	envolume(a5),d0	;endvolume of envelope
		cmp.b	volume(a5),d0	;compare with current volume
		bgt.s	.add		;endvolume greater - then add
		move.b	envspeed(a5),d1	;subvalue
		sub.b	d1,volume(a5)	;volume-subvalue
		bmi.s	.clr
		cmp.b	volume(a5),d0	;compare endvol with current volume
		bge.s	.clr		;
		bra.s	out4
.clr
		move.b	envolume(a5),volume(a5)
		clr.b	envelope(a5)
		bra.s	out4
.add
		move.b	envspeed(a5),d1
		add.b	d1,volume(a5)
		cmp.b	volume(a5),d0
		ble.s	.clr		
out4
;	timerfade
;		tst.w	timersp(a6)
;		beq.s	.notim2
;		move.b	timersp(a6),TBHIB
;		move.b	timersp+1(a6),TBLOB
;.notim2
;
;	Ballblazer special routine
;
riffplay	
		tst.b	riffstats(a5)
		beq.w	fader
		bmi.s	.play
		move.b	riffmacro(a5),d0
		and.l	#$7f,d0
		move.l	macrobase(a6),a0
		add.w	d0,d0		;*2
		add.w	d0,d0		;*2
		adda.w	d0,a0
		move.l	(a0),d0			;relative adress
		add.l	database(a6),d0		;+base
		move.l	d0,riffadres(a5)
		clr.w	riffsteps(a5)
		move.b	#-1,riffstats(a5)
		btst.b	#0,riffrandm(a5)
		beq.w	.play
		bsr.w	.fchoose
.play
		subq.b	#1,riffcount(a5)
		bne.w	.askecho
		move.b	riffspeed(a5),riffcount(a5)
		move.l	riffadres(a5),a0
.loop
		move.w	riffsteps(a5),d0
		move.b	(a0,d0.w),d0
		move.b	d0,help1(a6)
		bne.s	.set
		tst.w	riffsteps(a5)
		beq.w	fader
		clr.w	riffsteps(a5)
		bra.s	.loop
.set
		add.b	basenote+1(a5),d0	;note
		and.w	#$3f,d0
		beq.w	.fchoose
		add.w	d0,d0

		lea	nottab(pc),a0		;note-periods		
		move.w	(a0,d0.w),d0
		move.w	detunes(a5),d1
		beq.s	.zero
		add.w	#256,d1
		mulu.w	d1,d0
		lsr.l	#8,d0
.zero
		btst.b	#0,riffrandm(a5)
		bne.s	.ballblazer
		move.w	d0,baseperiod(a5)
		tst.w	potime(a5)
		bne.w	fader

	bsr.w	SetPer
	tst.w	NoDMAWait
	beq.b	.nodwait

		move.w	d0,period(a5)

	bra.b	.skip
.nodwait

		move.w	d0,AUDPER(a4)
.skip

		btst.b	#7,help1(a6)
		beq.s	.noclw
		clr.b	rifftrigg(a5)
.noclw
		addq.w	#1,riffsteps(a5)
		bra.w	fader
.ballblazer
		bsr.w	randomize
		btst.b	#2,riffrandm(a5)
		bne.s	.plnote
		move.w	riffsteps(a5),d1
		and.w	#3,d1
		tst.w	d1
		bne.s	.plnote
		moveq.l	#16,d1
		cmp.b	random+1(a6),d1
		bcc.s	.nonote
.plnote
		btst.b	#7,help1(a6)
		beq.s	.noclw2
		clr.b	rifftrigg(a5)
.noclw2
		move.w	d0,baseperiod(a5)
		tst.w	potime(a5)
		bne.w	.nonote

	bsr.w	SetPer
	tst.w	NoDMAWait
	beq.b	.nodwait2

		move.w	d0,period(a5)
	bra.b	.nonote

.nodwait2
		move.w	d0,AUDPER(a4)
.nonote
		addq.w	#1,riffsteps(a5)
		btst.b	#6,help1(a6)
		beq.w	fader
		bsr.w	randomize
		move.w	#6,d1
		cmp.b	random(a6),d1
		bcc.w	fader
.fchoose
		bsr.w	randomize
		moveq.l	#0,d1
		move.b	random+1(a6),d1
		and.b	riffAND(a5),d1
		move.w	d1,riffsteps(a5)
		bra.w	fader
.askecho
		btst.b	#1,riffrandm(a5)
		beq.s	fader
		moveq.l	#0,d0
		move.b	riffspeed(a5),d0
		mulu	#3,d0
		lsr.w	#3,d0
		cmp.b	riffcount(a5),d0
		bne.s	fader
		move.w	baseperiod(a5),d0
		moveq.l	#0,d1
		move.b	volume(a5),d1
		mulu	#5,d1
		lsr.w	#3,d1
		move.l	a5,-(sp)
		add.l	channadd(a5),a5
		move.l	audioadr(a5),a4
		move.b	d1,volume(a5)
		cmp.w	baseperiod(a5),d0
		beq.s	.nonot
		move.w	d0,baseperiod(a5)

	bsr.w	SetPer
	tst.w	NoDMAWait
	beq.b	.nodwait3

		move.w	d0,period(a5)

	bra.b	.skip2

.nodwait3
		move.w	d0,AUDPER(a4)

.skip2
		btst.b	#7,help1(a6)
		beq.s	.nonot
		clr.b	rifftrigg(a5)
.nonot
		move.l	(sp)+,a5
		move.l	audioadr(a5),a4
;
;	fade in/out	! Must be the last routine of modulations !!
;
fader
		tst.b	fadeadd(a6)
		beq.s	.fade
		subq.b	#1,fadecount1(a6)
		bne.s	.fade
		move.b	fadecount2(a6),fadecount1(a6)
		move.b	fadeadd(a6),d0
		add.b	d0,fadevol(a6)
		move.b	fadeend(a6),d0
		cmp.b	fadevol(a6),d0
		bne.s	.fade
		clr.b	fadeadd(a6)
		lea	infodat(pc),a0
		clr.w	info_fade(a0)
.fade
		moveq.l	#0,d1
		move.b	fadevol(a6),d1
		moveq.l	#0,d0
		move.b	volume(a5),d0
		tst.w	priocount(a5)
		bpl.s	.nofad
		btst.l	#6,d1
		bne.s	.nofad
		add.w	d0,d0
		add.w	d0,d0
		mulu.w	d1,d0
		lsr.w	#8,d0
.nofad
;		move.w	d0,AUDVOL(a4)

	bsr.w	ChangeVolume
	bsr.w	SetVol

.noset
		rts
randomize
		move.w	$dff006,d7
		eor.w	d7,random(a6)
		move.w	random(a6),d7
		add.l	#$57294335,d7
		move.w	d7,random(a6)
		rts
;
noteport
		movem.l	d0/a4-a6,-(sp)
		lea	CHfield0(pc),a6
		move.l	help1(a6),-(sp)
		lea	Synoffsets(pc),a5

		move.l	d0,help1(a6)
		move.b	help1+2(a6),d0
		and.w	#$f,d0
		add.w	d0,d0			;Extent to word pointer
		add.w	d0,d0			;Extent to longword pointer
		move.l	(a5,d0.w),a5

		move.b	help1(a6),d0
		cmp.b	#$fc,d0
		bne.s	.nofxprio
		move.b	help1+1(a6),priority(a5)
		move.b	help1+3(a6),d0
		move.w	d0,priocount(a5)
		bra.w	npout
.nofxprio
		tst.b	priority(a5)
		bne.w	npout
		tst.b	d0
		bpl.w	.noteonly
		cmp.b	#$f7,d0
		bne.s	.noenv
		move.b	help1+1(a6),envspeed(a5)
		move.b	help1+2(a6),d0
		lsr.b	#4,d0
		addq.b	#1,d0
		move.b	d0,envcount(a5)
		move.b	d0,envelope(a5)
		move.b	help1+3(a6),envolume(a5)
		bra.w	npout
.noenv
		cmp.b	#$f6,d0
		bne.s	.novib
		move.b	help1+1(a6),d0
		and.b	#$fe,d0
		move.b	d0,vibsize1(a5)
		lsr.b	#1,d0
		move.b	d0,vibsize2(a5)
		move.b	help1+3(a6),vibrate(a5)
		move.b	#1,vibcount(a5)
		clr.w	vibperiod(a5)
		bra.w	npout
.novib
		cmp.b	#$f5,d0
		bne.s	.keyon
		clr.b	keyflag(a5)
		bra.s	npout
.keyon
		cmp.b	#$bf,d0
		bcc.s	portnote
.noteonly
		move.b	help1+3(a6),d0
		ext.w	d0
		move.w	d0,detunes(a5)

		move.b	help1+2(a6),d0
		lsr.b	#4,d0
		and.w	#$f,d0			;!!and.w - Hibyte is zero
		move.b	d0,basevol+1(a5)

		move.b	help1+1(a6),d0
		move.b	basenote+1(a5),basenote(a5)
		move.b	help1(a6),basenote+1(a5)
		move.l	macrobase(a6),a4
		add.w	d0,d0			;!!Be careful - Hibyte must be zero
		add.w	d0,d0			;Extent to longword pointer
		adda.w	d0,a4
		move.l	(a4),a4
		add.l	database(a6),a4
		cmp.l	madress(a5),a4
		beq.s	.skip
		sf.b	mskipflag(a5)
.skip
		move.l	a4,madress(a5)
		clr.w	mstep(a5)
		clr.w	mawait(a5)
		clr.b	modstatus(a5)
		sf.b	mloopcount(a5)
		st.b	mstatus(a5)
		clr.w	irwait(a5)
		move.w	clibits(a5),CHIP+INTENA
		move.w	clibits(a5),CHIP+INTREQ
		move.b	#1,keyflag(a5)
npout
		move.l	(sp)+,help1(a6)
		movem.l	(sp)+,d0/a4-a6
		rts
portnote
		move.b	help1+1(a6),pospeed(a5)
		move.b	#1,pocount(a5)
		tst.w	potime(a5)
		bne.s	.noperiod
		move.w	baseperiod(a5),poperiod(a5)
.noperiod
		clr.w	potime(a5)
		move.b	help1+3(a6),potime+1(a5)

		move.b	help1(a6),d0
		and.w	#$3f,d0
		move.b	d0,basenote+1(a5)
		add.w	d0,d0

		lea	nottab(pc),a4		;note-periods		
		move.w	(a4,d0.w),baseperiod(a5)
		bra.s	npout
;
channeloff
		move.l	a5,-(sp)
		lea	Synoffsets(pc),a5	;a5=synthesizervar.
		and.w	#$f,d0			;channelnumber
		add.w	d0,d0
		add.w	d0,d0			;extend to lw-pointer
		move.l	(a5,d0.w),a5		;get channelbase
		tst.b	priority(a5)
		bne.s	.out
		move.w	clibits(a5),CHIP+INTENA
		move.w	offbits(a5),CHIP+DMACON	;dma disable
		clr.b	mstatus(a5)		;stop macro
		clr.w	ims_dlen(a5)
		clr.b	riffstats(a5)
.out
		move.l	(sp)+,a5
		rts
;
;fade
;		movem.l	a5/a6,-(sp)
;		lea	CHfield0(pc),a6
;		lea	infodat(pc),a5
;		move.w	#1,info_fade(a5)
;		move.b	d0,fadeend(a6)
;		swap	d0
;		move.b	d0,fadecount1(a6)
;		move.b	d0,fadecount2(a6)
;		beq.s	.norm
;		move.b	fadevol(a6),d0
;		move.b	#1,fadeadd(a6)
;		cmp.b	fadeend(a6),d0
;		beq.s	.nofad
;		bcs.s	.out
;		neg.b	fadeadd(a6)
;		bra.s	.out
;.norm
;		move.b	fadeend(a6),fadevol(a6)
;.nofad
;		clr.b	fadeadd(a6)
;		clr.w	info_fade(a5)
;.out
;		movem.l	(sp)+,a5/a6
;		rts

;info
;		lea	infodat(pc),a0
;		move.l	a1,-(sp)
;		lea	CHfield0(pc),a1
;		move.l	a1,info_ch0(a0)
;		lea	CHfield2(pc),a1
;		move.l	a1,info_ch2(a0)
;		move.l	(sp)+,a1
;		rts

playpatt1
		movem.l	a3-a6,-(sp)
		lea	CHfield0(pc),a6
		lea	CHfield2(pc),a5
		move.w	#1,custom(a6)
		move.l	database(a6),a4
		move.l	pattnbase(a6),a3
		move.w	d0,patterns+28(a5)
		clr.b	d0
		lsr.w	#6,d0
		move.l	(a3,d0.w),d0
		add.l	a4,d0
		move.l	d0,padress+28(a5)
		clr.l	pstep+28(a5)
		sf.b	ploopcount+28(a5)
		movem.l	(sp)+,a3-a6
		rts
;playpatt2
;		movem.l	a5/a6,-(sp)
;		lea	CHfield0(pc),a6
;		lea	CHfield2(pc),a5
;		move.w	#1,custom(a6)
;		move.w	d0,patterns+28(a5)
;		move.l	a1,padress+28(a5)
;		clr.l	pstep+28(a5)
;		sf.b	ploopcount+28(a5)
;		movem.l	(sp)+,a5/a6
;		rts
fxplay
		movem.l	d1/d2/d3/a4/a5/a6,-(sp)
		lea	CHfield0(pc),a6		;datafield
		lea	Synoffsets(pc),a4	;datafield synthesizer

		move.w	d0,d2		;d2=fxnumber
		move.l	database(a6),a5	;baseadress of muzakdata
		tst.l	tracks(a5)
		bne.s	.noold
		move.l	1532(a5),a5	;patternadress ($7f=special fx)
		add.l	database(a6),a5	;make absolute adress
		bra.s	.old
.noold
		move.l	fxbase(a6),a5	;fxadress
.old
		lsl.w	#3,d2		;*8
		cmp.b	#$fb,(a5,d2.w)
		bne.s	.fx5
		move.w	2(a5,d2.w),d0
		bsr.w	playpatt1
		bra.s	.fx2
.fx5
		move.b	2(a5,d2.w),d3	;volume/channel
		tst.b	song(a6)	;emptysong
		bpl.s	.fx4
		move.b	4(a5,d2.w),d3	;special channel
.fx4
		and.w	#$f,d3		;isolate channel
		add.w	d3,d3		;*2
		add.w	d3,d3		;*2
		move.l	(a4,d3.w),a4
		lsl.w	#6,d3		;shift to next byte

		move.b	5(a5,d2.w),d1	;get priority
		bclr.l	#7,d1
		cmp.b	priority2(a4),d1	;compare with old priority
		bcc.s	.fx3			;if new greater/equal as old 
						;then play it
		tst.w	priocount(a4)	;test counter
		bpl.s	.fx2		;if not negative then out
.fx3
		cmp.b	oldfx(a4),d2	;same like old
		bne.s	.fx1		;no then play note
		tst.w	priocount(a4)	;test counter
		bmi.s	.fx1		;if negative then play
		btst.b	#7,5(a5,d2.w)	;test on "no repeat mode"
		bne.s	.fx2		;set - then out
.fx1
		move.l	(a5,d2.w),d0			;get note of effect
		and.l	#$fffff0ff,d0			;remove	channel
		or.w	d3,d0				;right channel
		move.l	d0,fxnote(a4)
		move.b	d1,priority2(a4)		;save new priority
		move.w	6(a5,d2.w),priocount(a4)	;save counter
		move.b	d2,oldfx(a4)			;save fxnumber
.fx2
		movem.l	(sp)+,d1/d2/d3/a4/a5/a6
		rts
;
aclear
		clr.b	mstatus(a6)		;stop macro
		sf.b	mskipflag(a6)
		clr.l	priority(a6)		;clr priority/priority2/priocount
		clr.l	fxnote(a6)
		clr.w	ims_dlen(a6)
		clr.b	riffstats(a6)
		rts
;
alloff
		move.l	a6,-(sp)
		lea	CHfield0(pc),a6
		clr.b	allon(a6)		;disable routine

	tst.w	NoDMAWait
	beq.b	.nodwait
		clr.w	dmaconhelp(a6)
.nodwait
		lea	Synthfield0(pc),a6
		bsr.s	aclear
		lea	Synthfield1(pc),a6
		bsr.s	aclear
		lea	Synthfield2(pc),a6
		bsr.s	aclear
		lea	Synthfield3(pc),a6
		bsr.s	aclear
		clr.w	$dff0a8			;clr volume channel 1-...
		clr.w	$dff0b8
		clr.w	$dff0c8
		clr.w	$dff0d8			;...-4
		move.w	#$f,CHIP+DMACON		;stop sound DMA
		move.w	#$780,CHIP+INTREQ	;clr soundirqs
		move.w	#$780,CHIP+INTENA	;disable soundirq
		move.w	#$780,CHIP+INTREQ	;clr soundirqs
		lea	infodat(pc),a6
		clr.b	info_seqrun(a6)
		move.l	(sp)+,a6
		rts
;
songplay
		movem.l	d1-d7/a0-a6,-(sp)
		lea	CHfield0(pc),a6
		move.b	d0,songfl+1(a6)
		bsr.s	songset
		movem.l	(sp)+,d1-d7/a0-a6
		rts
;
playcont
		movem.l	d1-d7/a0-a6,-(sp)
		lea	CHfield0(pc),a6
		or.w	#%100000000,d0
		move.w	d0,songfl(a6)
		bsr.s	songset
		movem.l	(sp)+,d1-d7/a0-a6
		rts
;		
;songset2
;		lea	CHfield0(pc),a6
songset
		bsr	alloff
		clr.b	allon(a6)		;disable routine
		clr.w	custom(a6)		;disable custom pattern
		move.l	database(a6),a4		;adress of musicdata
		move.b	songfl+1(a6),d0		;new songnumber
		and.w	#$1f,d0
		add.w	d0,d0			;extend to wordpointer
		adda.w	d0,a4			;add database

		lea	CHfield2(pc),a5		;a5=sequencervar.
		move.b	song(a6),d1		;old song number
		bmi.w	.nocont
		and.w	#$1f,d1
		add.w	d1,d1			;extend to wordpointer
		lea	songcont(pc),a0		;a0=contvar.
		adda.w	d1,a0
		move.w	cstep(a5),(a0)		;put current step to buffer
		move.b	speed+1(a5),65(a0)	;and songspeed
		move.w	timersp(a6),128(a0)	;and timerspeed
.nocont
;		bsr.w	installtimer

	move.w	Timer(PC),D2
	move.l	(A6),A0
	btst	#1,11(A0)
	beq.b	.PALsong
	mulu.w	#50,D2
	divu.w	#60,D2
.PALsong
	move.w	D2,timersp(A6)

		move.w	fsteps(a4),cstep(a5)	;set current step
		move.w	fsteps(a4),fstep(a5)	;set first   step
		move.w	lsteps(a4),lstep(a5)	;set last    step
		move.w	speeds(a4),d2		;set song speed
		btst.b	#0,songfl(a6)		;test cont flag
		beq.s	.norm1

		lea	songcont(pc),a0		;a0=contvar.
		adda.w	d0,a0
		move.w	(a0),cstep(a5)		;set old current step
		moveq.l	#0,d2
		move.b	65(a0),d2		;and songspeed
		tst.w	128(a0)
		beq.s	.norm1
		move.w	128(a0),timersp(a6)
;		move.b	128(a0),TBHIB
;		move.b	129(a0),TBLOB
		clr.w	128(a0)
;		move.b	#1,timirq(a6)
		bra.s	.notim
.norm1
;		move.b	ntscflag(a6),timirq(a6)
		cmp.w	#$f,d2
		bls.s	.notim
		move.w	d2,d0
		move.w	speed(a5),d2
		move.l	#paltimval,d1	;Constant for PAL
		divu.w	d0,d1
		move.w	d1,timersp(a6)
;		move.b	timersp(a6),TBHIB
;		move.b	d1,TBLOB
;		move.b	#1,timirq(a6)
.notim
		move.w	#28,d1
		lea	emptypatt(pc),a4
.loop
		move.l	a4,padress(a5,d1.w)
		move.w	#$ff00,patterns(a5,d1.w)
		clr.l	pstep(a5,d1.w)
		subq.w	#4,d1
		bpl.s	.loop
		move.w	d2,speed(a5)

		tst.b	songfl+1(a6)
		bmi.s	.noplay
		move.l	database(a6),a4		;a4=adress of musicdata
		bsr	newtrack
.noplay
		clr.b	newstep(a6)		;clr flag for endofpattern
		clr.w	scount(a6)		;clr sequencer speed counter
		st.b	tloopcount(a6)
		move.b	songfl+1(a6),song(a6)	;save new songnumber
		clr.b	songfl(a6)		;clr songmode

	tst.w	NoDMAWait
	beq.b	.nodwait

		clr.w	dmaconhelp(a6)
.nodwait
		lea	infodat(pc),a4
		clr.w	info_fade(a4)
		clr.b	info_seqrun(a4)

		bset.b	#1,PRA			;disable low-pass filter
		move.w	#$ff,CHIP+ADKCON	;clr modulations
		move.b	#1,allon(a6)		;enable routine
		rts
;
initdata
		movem.l	a2-a6,-(sp)
		lea	CHfield0(pc),a6
		move.l	#$40400000,fadevol(a6)
		clr.b	fadeadd(a6)		;clear fade
		move.l	d0,database(a6)
		move.l	d1,samplebase(a6)
		move.l	d1,a4
		clr.l	(a4)			;clear oneshoot loopsample
		move.l	d1,imsbase(a6)
		move.l	d0,a4
		tst.l	tracks(a4)
		beq.s	.oldversion
		move.l	tracks(a4),d1
		add.l	d0,d1
		move.l	d1,trackbase(a6)
		move.l	ptable(a4),d1
		add.l	d0,d1
		move.l	d1,pattnbase(a6)
		move.l	mtable(a4),d1
		add.l	d0,d1
		move.l	d1,macrobase(a6)
		add.l	#fxtable,d0
		move.l	d0,fxbase(a6)
		bra.s	.goon
.oldversion
		move.l	#$800,d1
		add.l	d0,d1
		move.l	d1,trackbase(a6)
		move.l	#$400,d1
		add.l	d0,d1
		move.l	d1,pattnbase(a6)
		move.l	#$600,d1
		add.l	d0,d1
		move.l	d1,macrobase(a6)
.goon
;		tst.l	oldvec4(a6)
;		bne.w	.saved
;		move.l	IRQVEC4,oldvec4(a6)
;.saved
;		lea	mwadr(pc),a4		;set wavewait adress to
;		move.l	a4,IRQVEC4		;audio-interrupt vector

	bsr.w	SetAudioVector

		lea	CHfield2(pc),a5
		move.w	#5,speed(a5)
		lea	songcont(pc),a6
		move.w	#$1f,d0
.contset
		move.w	#5,64(a6)
		clr.w	128(a6)
		clr.w	(a6)+
		dbra	d0,.contset
		lea	CHfield0(pc),a6
		lea	Synoffsets(pc),a4
		lea	Synthfield0(pc),a5
		move.l	a5,(a4)+
		lea	Synthfield1(pc),a5
		move.l	a5,(a4)+
		lea	Synthfield2(pc),a5
		move.l	a5,(a4)+
		lea	Synthfield3(pc),a5
		move.l	a5,(a4)+
		moveq.l	#11,d0
.filfld
		move.l	-16(a4),(a4)+
		dbra	d0,.filfld
		movem.l	(sp)+,a2-a6
		rts
;initims
;		move.l	a6,-(sp)
;		lea	CHfield0(pc),a6
;		subq.l	#4,a0
;		move.l	a0,imsbase(a6)
;		move.l	(sp)+,a6
;		rts
;installtimer
;		movem.l	a5/a6,-(sp)
;		lea	CHfield0(pc),a6
;		clr.b	ntscflag(a6)
;		clr.w	timersp(a6)
;		move.l	4,a5
;		cmp.b	#50,530(a5)
;		bne.s	.ntscamiga
;		move.l	database(a6),a5	;50 Hz Amiga
;		btst.b	#1,$b(a5)	;on 50 Hz composed ?
;		beq.s	.install	;yes, then out (vbi is active)
;		move.b	#1,ntscflag(a6)
;		move.b	#$2e,$bfd700	;HI
;		move.b	#$2e,$bfd600	;LO
;		move.w	#$2e2e,timersp(a6)
;		bra.s	.install
;.ntscamiga
;		move.l	database(a6),a5	;60 Hz Amiga
;		btst.b	#1,$b(a5)	;on 60 Hz composed ?
;		bne.s	.install	;yes, then out (vbi is active)
;		move.b	#1,ntscflag(a6)
;		move.b	#$37,$bfd700	;HI
;		move.b	#$f0,$bfd600	;LO
;		move.w	#$37f0,timersp(a6)
;.install
;		tst.l	oldvec6(a6)
;		bne.s	out8
;		move.l	IRQVEC6,oldvec6(a6)
;		lea	timerin(pc),a6
;		move.l	a6,IRQVEC6
;		move.b	#%00010001,$bfdf00	;CRAB
;		move.b	#$82,$bfdd00		;ICR		
;		move.w	#$a000,CHIP+INTENA
;out8
;		movem.l	(sp)+,a5/a6
;		rts
;timerin
;		move.l	a6,-(sp)
;		tst.b	$bfdd00
;		move.w	#$2000,CHIP+INTREQ
;		lea	CHfield0(pc),a6
;		tst.b	timirq(a6)
;		beq.s	.notim
;		bsr	irqin
;.notim
;		move.l	(sp)+,a6
;		rte
;vbion
;		movem.l	a0/a6,-(sp)
;		lea	CHfield0(pc),a6
;		move.w	CHIP+INTENAR,imask(a6)
;		move.l	IRQVEC3,oldvec3(a6)
;		lea	irq1(pc),a0
;		move.l	a0,IRQVEC3
;		tst.l	oldvec4(a6)
;		bne.w	.saved
;		move.l	IRQVEC4,oldvec4(a6)
;.saved
;		lea	mwadr(pc),a0		;set wavewait adress to
;		move.l	a0,IRQVEC4		;audio-interrupt vector
;		move.w	#$8020,CHIP+INTENA
;		movem.l	(sp)+,a0/a6
;		rts
;
;vbioff
;		move.l	a6,-(sp)
;		move.w	#$4780,CHIP+INTENA
;		lea	CHfield0(pc),a6
;		bsr	alloff
;		tst.l	oldvec4(a6)
;		beq.s	.nowwait
;		move.l	oldvec4(a6),IRQVEC4
;		clr.l	oldvec4(a6)
;.nowwait
;		tst.l	oldvec3(a6)
;		beq.w	.novbi
;		move.l	oldvec3(a6),IRQVEC3
;		clr.l	oldvec3(a6)
;.novbi
;		tst.l	oldvec6(a6)
;		beq.s	.notimer
;		move.b	#$02,$bfdd00		;TimerIRQ loeschen
;		tst.b	$bfdd00
;		move.l	oldvec6(a6),IRQVEC6
;		clr.l	oldvec6(a6)
;.notimer
;		lea	CHfield0(pc),a6
;		or.w	#$c000,imask(a6)
;		move.w	imask(a6),CHIP+INTENA
;		move.l	(sp)+,a6
;		rts
;irq1
;		movem.l	d0-d7/a0-a6,-(sp)
;		move.w	CHIP+INTREQR,d0
;		and.w	CHIP+INTENAR,d0
;		btst.l	#4,d0
;		beq.s	vbitest
;		bsr.w	irqin
;		move.w	#$0010,CHIP+INTREQ
;		bra.s	novbi
;vbitest
;		move.l	CHIP+VPOSR,d1
;		and.l	#$1ff00,d1
;		cmp.l	#$00a00,d1
;		bcc.s	novbi
;		btst.l	#5,d0
;		beq.s	novbi
;		lea	CHfield0(pc),a6
;		tst.b	timirq(a6)
;		bne.s	novbi
;		bsr.w	irqin
;novbi
;		movem.l	(sp)+,d0-d7/a0-a6
;		move.l	doldvec3(pc),-(sp)
;		rts

;
;	Variables
;
;	offsets datafile
fsteps		= 256
lsteps		= 320
speeds		= 384
mutes		= 448
fxtable		= 512
tracks		= $1d0
ptable		= $1d4
mtable		= $1d8
;***
	RSRESET
	EVEN
CHfield0
database	rs.l 1
	 	dc.l 0
samplebase	rs.l 1
		dc.l 0
imsbase		rs.l 1
 		dc.l 0

		rs.b 1		;!O
 		dc.b 0
newstep		rs.b 1		;!E
 		dc.b 0
imask		rs.w 1
 		dc.w 0

song		rs.b 1		;!O
 		dc.b 0

fadeadd		rs.b 1		;!E
 		dc.b 0

random		rs.w 1
 		dc.w 0

oldvec3		rs.l 1
doldvec3	dc.l 0

help1		rs.l 1
 		dc.l 0
scount		rs.w 1
 		dc.w 0
allon		rs.b 1
 		dc.b 0
fxflag		rs.b 1
 		dc.b 0
oldvec6		rs.l 1
doldvec6	dc.l 0
timersp		rs.w 1
timerspeed
		dc.w $7fff
timirq		rs.b 1		;!O
 		dc.b 0
ntscflag	rs.b 1		;!E
 		dc.b 0
oldvec4		rs.l 1
doldvec4	dc.l 0
songfl		rs.w 1
 		dc.w 0
custom		rs.w 1
 		dc.w 0
fadevol		rs.b 1		;!O
 		dc.b $40
fadeend		rs.b 1		;!E
 		dc.b $40
fadecount1	rs.b 1		;!O
 		dc.b 0
fadecount2	rs.b 1		;!E
 		dc.b 0
		rs.b 1		;!O
 		dc.b 0
re_in_save	rs.b 1		;!E
 		dc.b 0
tloopcount	rs.w 1
 		dc.w -1
trackbase	rs.l 1
 		dc.l 0
pattnbase	rs.l 1
 		dc.l 0
macrobase	rs.l 1
 		dc.l 0
fxbase		rs.l 1
 		dc.l 0
dmaconhelp	rs.l 1
 		dc.l 0

;***
;	offsets for Synthfields (synthesizer)
;
Synoffsets
 		ds.l	16
	RSRESET
;0
mstatus		rs.b	1	;	 **
modstatus	rs.b	1	;	**
offdma		rs.b	1	;	 **
mabcount1	rs.b	1	;	**
basenote	rs.w	1	;
irwait		rs.w	1	;
basevol		rs.w	1	;
detunes		rs.w	1	;
madress		rs.l	1	;
;1
mstep		rs.w	1	;
mawait		rs.w	1	;
onbits		rs.w	1	;
offbits		rs.w	1	;
volume		rs.b	1	;	 **
oldvol		rs.b	1	;	**
mloopcount	rs.b	1	;	 **
mabcount2	rs.b	1	;	**
envelope	rs.b	1	;	 **
envcount	rs.b	1	;	**
envolume	rs.b	1	;	 **
envspeed	rs.b	1	;	**
;2
vibrate		rs.b	1	;	 **
vibcount	rs.b	1	;	**
pospeed		rs.b	1	;	 **
pocount		rs.b	1	;	**
vibperiod	rs.w	1	;
vibsize1	rs.b	1	;	 **
vibsize2	rs.b	1	;	**
baseperiod	rs.w	1	;
beginadd	rs.w	1	;
sbegin		rs.l	1	;
;3
potime		rs.w	1	;
poperiod	rs.w	1	;
samplen		rs.w	1	;
keyflag		rs.b	1	;	 **
riffAND		rs.b	1	;	**
msubadr		rs.l	1	;
priority	rs.b	1	;	 **	----
priority2	rs.b	1	;	**
priocount	rs.w	1	;
;4
msubstep	rs.w	1	;		----
oldfx		rs.b	1	;	 **
ims_deltaold	rs.b	1	;	**
intbits		rs.w	1	;
clibits		rs.w	1	;
riffspeed	rs.b	1	;	 **	----
riffrandm	rs.b	1	;	**
riffcount	rs.b	1	;	 **
riffstats	rs.b	1	;	**
riffadres	rs.l	1	;		----
;5
riffsteps	rs.w	1	;		----
riffmacro	rs.b	1	;	 **
rifftrigg	rs.b	1	;	**
channadd	rs.l	1	;		----
audioadr	rs.l	1	;
mabadd		rs.l	1	;
;6
ims_doffs	rs.l	1	;
ims_sstart	rs.l	1	;
ims_slen	rs.w	1	;
ims_dlen	rs.w	1	;
ims_mod1	rs.l	1	;
;7
ims_mod1len	rs.w	1	;
ims_mod1len2	rs.w	1	;
ims_mod1add	rs.w	1	;
ims_delta	rs.w	1	;
ims_mod2	rs.l	1	;
ims_flen1	rs.w	1	;
ims_flen2	rs.w	1	;
;8
ims_fspeed	rs.w	1	;
ims_mod2add	rs.w	1	;
ims_mod2len	rs.w	1	;
ims_mod2len2	rs.w	1	;
ims_dolby	rs.b	1	;	 **
		rs.b	1	;	**
fxnote		rs.l	1	;
period		rs.w	1	;
nwait		rs.b	1	;	 **
mskipflag	rs.b	1	;	**

;10
;
	EVEN
Synthfield0
;0
 	dc.l	0		;(mstatus.b/modstatus.b/offdma.b/mabcount1.b)
 	dc.l	0		;(last+basenote.w/irwait.w)
 	dc.l	0		;(basevol/detunes)
 	dc.l	0		;(macroadress)
;1
 	dc.l	0		;(mstep/mawait)
 	dc.l	$82010001	;dmabits(on/off)
 	dc.l	0		;(volume.b/oldvol.b/mloopcount.b/mabcount2.b)
 	dc.l	0		;(envelope.b/envcount.b/envolume.b/envspeed.b)
;2
 	dc.l	0		;(vibrate/vibcount/pospeed/pocount)
 	dc.l	0		;(vibperiod/vibsize1/vibsize2)
 	dc.l	0		;(baseperiod/beginadd)
 	dc.l	0		;(sbegin.l)
;3
 	dc.l	0		;(potime.w/poperiod.w)
 	dc.l	0		;(samplen.w/keyflag.b/riffAND.b)
 	dc.l	0		;(msubadr.l)
 	dc.l	0		;(priority.b/priority2.b/priocount.w) !CLR by alloff
;4
 	dc.l	0		;(msubstep.w/oldfx.b/ims_delatold.b)
 	dc.l	$80800080	;irqbits(on/off)
 	dc.l	0		;(riffspeed.b/riffrandm.b/riffcount.b/riffstats.b)
 	dc.l	0		;(riffadres.l)
;5
 	dc.l	0		;(riffsteps.w/riffmacro.b/rifftrigg.b)
 	dc.l	Synthfield1-Synthfield0	;(channadd.l)
 	dc.l	$dff0a0		;(audioadr.l)
 	dc.l	0		;(mabadd.l)
;6
 	dc.l	$4		;(ims_doffs.l)
 	dc.l	0		;(ims_sstart.l)
 	dc.l	0		;(ims_slen.w/ims_dlen.w)
 	dc.l	0		;(ims_mod1.l)
;7
 	dc.l	0		;(ims_mod1len.w/ims_mod1len2.w)
 	dc.l	0		;(ims_mod1add.w/ims_delta.w)
 	dc.l	0		;(ims_mod2.l)
 	dc.l	0		;(ims_flen1.w/ims_flen2.w)
;8
 	dc.l	0		;(ims_fspeed.w/ims_mod2add.w)
 	dc.l	0		;(ims_mod2len.w/ims_mod2len2.w)
 	dc.w	0	  	;(ims_Dolby.b/)
 	dc.l	0		;(fxnote.l)
 	dc.l	$0000ff00	;(period.w/nwait.b/mskipflag)

;
Synthfield1
;0
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;1
 	dc.l	0		;
 	dc.l	$82020002	;dmabits
 	dc.l	0		;
 	dc.l	0		;
;2
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;3
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;4
 	dc.l	0		;
 	dc.l	$81000100	;irqbits
 	dc.l	0		;
 	dc.l	0		;
;5
 	dc.l	0		;
 	dc.l	Synthfield2-Synthfield1	;
 	dc.l	$dff0b0		;
 	dc.l	0		;
;6
 	dc.l	$104		;imsdoffs
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;7
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;8
 	dc.l	0		;
 	dc.l	0		;
 	dc.w	0	  	;(ims_Dolby.b/)
 	dc.l	0		;
 	dc.l	$0000ff00	;(period.w/nwait.b/mskipflag)
;
Synthfield2
;0
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;1
 	dc.l	0		;
 	dc.l	$82040004	;dmabits(on/off)
 	dc.l	0		;
 	dc.l	0		;
;2
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;3
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;4
 	dc.l	0		;
 	dc.l	$82000200	;
 	dc.l	0		;
 	dc.l	0		;
;5
 	dc.l	0		;
 	dc.l	Synthfield3-Synthfield2	;
 	dc.l	$dff0c0		;
 	dc.l	0		;
;6
 	dc.l	$204		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;7
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;8
 	dc.l	0		;
 	dc.l	0		;
 	dc.w	0	  	;(ims_Dolby.b/)
 	dc.l	0		;
 	dc.l	$0000ff00	;(period.w/nwait.b/mskipflag)
;
Synthfield3
;0
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;1
 	dc.l	0		;
 	dc.l	$82080008	;dmabits(on/off)
 	dc.l	0		;
 	dc.l	0		;
;2
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;3
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;4
 	dc.l	0		;
 	dc.l	$84000400	;
 	dc.l	0		;
 	dc.l	0		;
;5
 	dc.l	0		;
 	dc.l	-(Synthfield3-Synthfield0)	;
 	dc.l	$dff0d0		;
 	dc.l	0		;
;6
 	dc.l	$304		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;7
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
 	dc.l	0		;
;8
 	dc.l	0		;
 	dc.l	0		;
 	dc.w	0	  	;(ims_Dolby.b/)
 	dc.l	0		;
 	dc.l	$0000ff00	;(period.w/nwait.b/mskipflag)
;

;***
;	offsets	for CHfield2 (sequencer)
;
fstep		= 0	;.w
lstep		= 2	;.w
cstep		= 4	;.w
speed		= 6	;.w
muteflags	= 8	;8*.w
padress		= 40	;8*.l
patterns	= 72	;8*.w
ploopcount	= 74	;8*.b
; ***		= 75	;8*.b
pstep		= 104	;8*.w
pawait		= 106	;8*.b
; ***		= 107	;8*.b
psubadr		= 136	;8*.l
psubstep	= 168	;8*.w
	EVEN
CHfield2
 	dc.w	0	;fstep
 	dc.w	0	;lstep
 	dc.w	0	;cstep
 	dc.w	6	;speed
;8
 	dc.l	0,0,0,0,0,0,0,0	;(trackmutes.w//pstep.w)
;40
 	dc.l	0,0,0,0,0,0,0,0 ;(patternadress.l)
;72
 	dc.l	0,0,0,0,0,0,0,0 ;(patterns.w/ploopcount.b/)
;104
 	dc.l	0,0,0,0,0,0,0,0 ;(pstep.w/pawait.b/) !Cleared by newtrack
;136
 	dc.l	0,0,0,0,0,0,0,0	;(psubadr.l)
;168
 	dc.l	0,0,0,0,0,0,0,0	;(psubstep.w/)
; ***
songcont
 	ds.w 32	;contstep
;64
 	ds.w 32	;/songspeed
;128
 	ds.w 32	;timerspeed
;***
info_fade	= 0
info_error	= 2
info_ch0	= 4
info_ch1	= 8
info_ch2	= 12
info_uvbi	= 16
info_cliout	= 20
info_seqrun	= 21
info_rec	= 22
info_midi	= 26
info_flags	= 30
; ***
	EVEN
infodat
 	dc.w	0	;fadeend		0
 	dc.w	0	;errorflag		2
 	dc.l	0	;adress CHfield0	4
 	dc.l	0	;adress CHfield1	8
 	dc.l	0	;adress CHfield2	12
 	dc.l	0	;adress pointer to uservbi	16
 	dc.b	0	;cliout flag		20
 	dc.b	0	;sequencer running	21
 	dc.l	0	;adress recfield	22
 	dc.l	0	;adress midifield	26
 	dc.w	0,0,0,0 ;Programmer flags       30-37  (set by macrostatment $20
		;				or patternstatment $fd !)

emptypatt
 dc.l	$f4000000,$f0000000
;		Note-table v1.0
; dc.w 3420,3228,3048,2876,2714,2562,2418,2282,2154,2034,1920,1816
nottab
 dc.w 1710,1614,1524,1438,1357,1281,1209,1141,1077,1017, 960, 908
 dc.w  856, 810, 764, 720, 680, 642, 606, 571, 539, 509, 480, 454
 dc.w  428, 404, 381, 360, 340, 320, 303, 286, 270, 254, 240, 227
 dc.w  214, 202, 191, 180, 170, 160, 151, 143, 135, 127, 120, 113
 dc.w  214, 202, 191, 180, 170, 160, 151, 143, 135, 127, 120, 113
 dc.w  214, 202, 191, 180

	*--------------- PatchTable for tfmx.obj ------------------*

PatchTable
	dc.w	Code1-PatchTable,(Code1End-Code1)/2-1,Patch1-PatchTable
	dc.w	Code2-PatchTable,(Code2End-Code2)/2-1,Patch2-PatchTable
	dc.w	Code3-PatchTable,(Code3End-Code3)/2-1,Patch3-PatchTable
	dc.w	Code4-PatchTable,(Code4End-Code4)/2-1,Patch4-PatchTable
	dc.w	Code5-PatchTable,(Code5End-Code5)/2-1,Patch5-PatchTable
	dc.w	Code6-PatchTable,(Code6End-Code6)/2-1,Patch6-PatchTable
	dc.w	Code7-PatchTable,(Code7End-Code7)/2-1,Patch7-PatchTable
;	dc.w	Code8-PatchTable,(Code8End-Code8)/2-1,Patch8-PatchTable
;	dc.w	Code9-PatchTable,(Code9End-Code9)/2-1,Patch9-PatchTable
;	dc.w	CodeA-PatchTable,(CodeAEnd-CodeA)/2-1,PatchA-PatchTable
;	dc.w	CodeB-PatchTable,(CodeBEnd-CodeB)/2-1,PatchB-PatchTable
	dc.w	0

; CHField2base patch for tfmx.obj

Code1
	ADDA.W	D1,A0
	MOVE.W	4(A5),(A0)
Code1End
Patch1
	add.w	D1,A0
	move.w	4(A5),(A0)
	move.l	A5,CHField2Base
	rts

; Timer patch for tfmx.obj (timer version)

Code2
	MOVE.L	#$1B51F8,D1
	DIVU.W	D0,D1
Code2End
Patch2
	move.l	#$1B51F8,D1
	divu.w	D0,D1
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.w	D1,dtg_Timer(A5)
	move.l	dtg_SetTimer(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
	rts

; SongEnd patch for tfmx.obj

Code3
	MOVE.W	0(A5),4(A5)
Code3End
Patch3
	move.w	(A5),4(A5)
	bsr.w	SongEnd
	rts

; Timer install patch for tfmx.obj
Code4
	MOVEA.L	4,A5
	CMPI.B	#$32,$212(A5)
Code4End
Patch4
	lea	12(SP),SP		; no return
	rts

; Address patch for tfmx.obj
Code5
	MOVE.L	D0,$B0(A5)
	MOVE.L	D0,(A4)
Code5End
Patch5
	move.l	D0,$B0(A5)
	move.l	D0,(A4)
	bsr.w	SetAdr
	rts

; Length patch for tfmx.obj (for IMS)
Code6
	LSR.W	#1,D0
	MOVE.W	D0,4(A4)
Code6End
Patch6
	lsr.w	#1,D0
	move.w	D0,4(A4)
	bsr.w	SetLen
	rts

; Timer install patch for tfmx.obj (Master Blazer title)
Code7
	dc.l	$4DFA016E
	CLR.B	$56(A6)
Code7End
Patch7
	lea	12(SP),SP		; no return
	rts

	Section HeaderBuffer,BSS
Header
	ds.b	248*2
