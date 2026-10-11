	*****************************************************
	****     Quartet PSG replayer for EaglePlayer    ****
	****         all adaptions by Wanted Team,	 ****
	****      DeliTracker (?) compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include "misc/eagleplayer2.01.i"
	include	'hardware/custom.i'
	include 'exec/exec_lib.i'
	include 'dos/dos_lib.i'
	include	'intuition/intuition.i'
	include	'intuition/intuition_lib.i'
	include	'intuition/screens.i'
	include 'libraries/gadtools.i'
	include 'libraries/gadtools_lib.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Quartet PSG player module V1.2 (30 Sep 2013)',0
	even
Tags
	dc.l	DTP_PlayerVersion,3
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	DTP_Config,Config
	dc.l	DTP_UserConfig,UserConfig
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevSong!EPB_NextSong!EPB_LoadFast
	dc.l	TAG_DONE

PlayerName
	dc.b	'Quartet PSG',0
Creator
	dc.b	'(c) 1990 by Rob Povey & Steve',10
	dc.b	'Wetherill, adapted by Wanted Team',0
Prefix
	dc.b	'SQT.',0
CfgPath0
	dc.b	'/'				; necessary for Config loading
CfgPath1
	dc.b	'Configs/EP-Quartet_PSG.cfg',0
CfgPath2
	dc.b	'EnvArc:EaglePlayer/EP-Quartet_PSG.cfg',0
CfgPath3
	dc.b	'Env:EaglePlayer/EP-Quartet_PSG.cfg',0
	even
Text
	dc.b	'Player is now using YM2149 emulation by '
Type
	dc.l	0
	dc.l	0
	dc.w	0
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
Songend
	dc.l	'WTWT'
EmuType
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
	sub.w	#160/2,D0
	bpl.s	SetLeftEdge
	moveq	#0,D0
SetLeftEdge
	move.w	D0,WindowTags+4+2		; Window-X

	move.l	dtg_IntuitionBase(A5),A6
	move.w	ib_MouseY(A6),D0
	sub.w	#63/2,D0
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

	move.w	TypeBase+2(PC),TypeTemp

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

SetTypeBase
	moveq	#0,D0
	move.w	im_Code(A1),D0			; get Number
	move.w	D0,TypeTemp
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
	move.w	TypeTemp(PC),TypeBase+2
ExitConfig
	clr.w	QuitFlag			; quit config
	rts

VisualInfo
	dc.l	0
WindowPtr
	dc.l	0
SaveBuf
	dc.w	'WT'
TypeTemp
	dc.w	0
QuitFlag
	dc.w	0

WindowTags
	dc.l	WA_Left,0
	dc.l	WA_Top,0
	dc.l	WA_InnerWidth,140+20
	dc.l	WA_InnerHeight,63
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
	dc.l	SetTypeBase
	dc.l	0

GadArray2
	dc.l	BUTTON_KIND,0
	dc.w	74,45,58,14
	dc.l	GadText2,PLACETEXT_IN
	dc.l	SaveConfig
	dc.l	0

GadArray3
	dc.l	BUTTON_KIND,0
	dc.w	8,45,58,14
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
TypeBase
	dc.l	0
	dc.l	GTMX_Spacing,4
	dc.l	TAG_DONE

MXLabels0
	dc.l	MXLabelText0
	dc.l	MXLabelText1
	dc.l	0

Topaz8
	dc.l	TOPAZname
	dc.w	TOPAZ_EIGHTY
	dc.b	$00,$01

TOPAZname
	dc.b	'topaz.font',0

WindowName
	dc.b	'Quartet PSG',0

MXLabelText0
	dc.b	'Mad Max',0
MXLabelText1
	dc.b	'meynaf ',0

GadgetText0
	dc.b	'Set emulation type:',0
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
	cmp.w	#1,D1
	beq.b	PutMode
Default
	tst.l	D5
	bne.b	SecondTry
	moveq	#0,D1				; default mode
PutMode
	lea	TypeBase+2(PC),A0
	move.w	D1,(A0)
	moveq	#0,D0
	rts

LoadBuf
	dc.l	0

***************************************************************************
*************************** DTP_Volume DTP_Balance ************************
***************************************************************************

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
	move.l	A1,D1
	cmp.w	#$F0A0,D1
	beq.s	Left1
	cmp.w	#$F0B0,D1
	beq.s	Right1
	cmp.w	#$F0C0,D1
	beq.s	Right2
	cmp.w	#$F0D0,D1
	bne.s	Exit
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
Exit
	move.l	(A7)+,D1
	rts

*-------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(SP)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(SP)+,A0
	rts

*-------------------------------- Set Two -------------------------------*

SetTwo
	move.l	A0,-(SP)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	A2,(A0)
	move.w	D4,UPS_Voice1Len(A0)
	move.l	(SP)+,A0
	rts

*-------------------------------- Set Per -------------------------------*

SetPer
	move.l	A0,-(SP)
	lea	StructAdr+UPS_Voice1Per(PC),A0
	cmp.l	#$DFF0A0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF0C0,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(SP)+,A0
	rts

***************************************************************************
****************************** EP_Voices  *********************************
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
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	move.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	moveq	#3,D1
GoodBra
	cmp.w	#$6000,(A0)+
	bne.b	Fault
	move.w	(A0)+,D2
	bmi.b	Fault
	beq.b	Fault
	btst	#0,D2
	bne.b	Fault
	dbf	D1,GoodBra
	cmp.w	#$49FA,(A0)
	bne.b	Fault
	subq.l	#6,A0
	add.w	(A0),A0
	cmp.l	#$48E7FFFE,(A0)+
	bne.b	Fault
	cmp.w	#$4DFA,(A0)
	bne.b	Fault
	cmp.w	#$51EE,4(A0)
	bne.b	Fault
	cmp.w	#$6100,8(A0)
	bne.b	Fault
	moveq	#0,D0
Fault
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

LoadSize	=	4
CalcSize	=	12
SubSongs	=	20
SongSize	=	28

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Calcsize,0		;12
	dc.l	MI_SubSongs,0		;20
	dc.l	MI_Songsize,0		;28
	dc.l	MI_Voices,3
	dc.l	MI_MaxVoices,3
	dc.l	MI_Prefix,Prefix
	dc.l	MI_About,Text
	dc.l	0

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq	#0,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	subq.l	#1,D1
	rts

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt	
	movem.l	D0-D7/A0-A6,-(SP)

	lea	StructAdr(PC),A0
	st	UPS_Enabled(A0)
	clr.w	UPS_Voice1Per(A0)
	clr.w	UPS_Voice2Per(A0)
	clr.w	UPS_Voice3Per(A0)
	clr.w	UPS_Voice4Per(A0)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)

	move.l	ModulePtr(PC),A0
	jsr	4(A0)
	move.w	EmuType(PC),D1
	bne.b	NoOne
	bsr.w	Play_Emu
	bra.b	SkipTwo
NoOne
	bsr.w	Play_Emu2
SkipTwo
	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D0-D7/A0-A6
	rts

SongEndTest
	move.l	$32(A4),A0
	movem.l	A1/A5,-(A7)
	lea	Songend(PC),A1
	cmp.b	#8,$3E(A4)
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.b	#10,$3E(A4)
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.b	#9,$3E(A4)
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)
	bne.b	SkipEnd
	move.l	#$FF00FFFF,(A1)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	lea	Noise,A0
	tst.l	(A0)
	bne.b	SampOK
	bsr.w	InitNoise
	bsr.w	InitNoise2
	move.l	#$7090B24D,(A0)		; pulse sample v2+v1
SampOK
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; module buffer
	move.l	A5,(A6)				; EagleBase
	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	move.l	A0,A1
	move.w	#$4E71,D1
Find1
	cmp.w	#$40C2,(A1)+
	bne.b	Find1
	subq.l	#2,A1
Nopuj1
	move.w	D1,(A1)+
	cmp.w	#$41FA,(A1)
	bne.b	Nopuj1

	addq.l	#6,A1
	move.l	A1,A2
	add.w	(A1)+,A2
Find1a
	cmp.w	#$43E9,(A1)+
	bne.b	Find1a
	add.w	(A1),A2
	add.w	(A1)+,A2
	move.l	A2,A3
	sub.l	A0,A2
	cmp.l	D0,A2
	bgt.w	Short
	move.l	A2,CalcSize(A4)

Find2
	cmp.l	#$206C0032,(A1)
	bne.b	NoTest
	addq.l	#8,A0
	move.l	A0,D2
	move.w	#$4EF9,(A0)+			; jmp
	lea	SongEndTest(PC),A2
	move.l	A2,(A0)				; to
	move.w	#$6100,(A1)+
	sub.l	A1,D2
	move.w	D2,(A1)+
NoTest
	cmp.l	#$8380007,(A1)
	beq.b	PK
	cmp.l	#$8390007,(A1)
	beq.b	PK
	addq.l	#2,A1
	bne.b	Find2
PK
	move.b	#$60,-8(A1)			; skip access to ST registers
Find3
	cmp.w	#$40C1,(A1)+
	bne.b	Find3
	move.w	#$4EB9,-2(A1)			; jsr
	lea	Patch(PC),A2
	move.l	A2,(A1)+			; to
Nopuj3
	move.w	D1,(A1)+
	cmp.w	#$4CDF,(A1)
	bne.b	Nopuj3

	moveq	#$56,D1
More
	cmp.l	(A1),D1
	beq.b	Later
	addq.l	#2,A1
	bra.b	More
Later
	moveq	#$46,D1
	moveq	#0,D0
Next
	cmp.w	(A1)+,D1
	bne.b	NoEnd
	addq.l	#1,D0
NoEnd
	cmp.l	A1,A3
	bne.b	Next
	lsr.l	#2,D0
	move.l	D0,SubSongs(A4)

	lea	Type(PC),A1
	move.l	#'Mad ',(A1)
	move.l	#'Max!',4(A1)
	move.l	TypeBase(PC),D0
	beq.b	V1
	move.l	#'meyn',(A1)
	move.l	#'af! ',4(A1)
V1
	lea	EmuType(PC),A0
	move.w	D0,(A0)

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

Short
	moveq	#EPR_ModuleTooShort,D0
	rts

Patch
	lea	YM2149Base(PC),A0
	move.b	(A5)+,6(A0)
	move.b	(A5)+,2(A0)
	move.b	(A5)+,14(A0)
	move.b	(A5)+,10(A0)
	move.b	(A5)+,22(A0)
	move.b	(A5)+,18(A0)
	move.b	(A5)+,26(A0)
	move.b	(A5)+,30(A0)
	move.b	(A5)+,34(A0)
	move.b	(A5)+,38(A0)
	move.b	(A5)+,42(A0)
	rts

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	movea.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	StructAdr(PC),A0
	lea	UPS_SizeOF(A0),A1
ClearUPS
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearUPS

	move.w	EmuType(PC),D0
	bne.b	Init2
	bsr.w	Init_Emu
	bra.b	SkipInit2
Init2
	bsr.w	Init_Emu2
SkipInit2
	lea	Songend(PC),A0
	move.l	#$FF00FFFF,(A0)
	move.w	dtg_SndNum(A5),D0
	move.l	ModulePtr(PC),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	lea	$DFF000,A0
	move.w	#15,$96(A0)
	moveq	#0,D0
	move.w	D0,$A8(A0)
	move.w	D0,$B8(A0)
	move.w	D0,$C8(A0)
	move.w	D0,$D8(A0)
	rts

***************************************************************************
***************************************************************************
***************************************************************************

; called before Init song routine

Init_Emu
	moveq	#64,D0
	lsl.w	#2,D0			; 256
	lea	CanalA(PC),A0
	move.l	D0,(A0)+		; volume/period canal A
	clr.w	(A0)+			; status canal A
	move.l	D0,(A0)+		; volume/period canal B
	clr.w	(A0)+			; status canal B
	move.l	D0,(A0)+		; volume/period canal C
	clr.l	(A0)+			; status canal C/counter canal noise
	move.l	D0,(A0)+		; volume/period canal noise
	clr.w	(A0)			; status canal noise
	lea	YM2149Base(PC),A0
	clr.b	0*4+2(A0)
	clr.b	1*4+2(A0)
	clr.b	2*4+2(A0)
	clr.b	3*4+2(A0)
	clr.b	4*4+2(A0)
	clr.b	5*4+2(A0)
	clr.b	6*4+2(A0)
	move.b	#$3F,7*4+2(A0)
	clr.b	8*4+2(A0)
	clr.b	9*4+2(A0)
	clr.b	10*4+2(A0)
	clr.b	11*4+2(A0)
	clr.b	12*4+2(A0)
	move.b	#10,13*4+2(A0)
	rts

; called after Play song routine

Play_Emu
	lea	YM2149Base(PC),A6
	move.b	$1E(A6),D7		; mixer control bits
	not.b	D7
	lea	$DFF0A0,A1		; first Amiga channel (left)
	lea	CanalA(PC),A0
	moveq	#0,D5			; canal A pulse bit
	moveq	#3,D6			; canal A noise bit
	move.w	6(A6),D4		; canal A MSB period
	move.b	2(A6),D4		; canal A LSB period
	moveq	#15,D3
	and.b	$22(A6),D3		; canal A volume
	bsr.w	ConvertToAmiga
	lea	$30(A1),A1		; fourth Amiga channel (left)
	lea	CanalB(PC),A0
	moveq	#1,D5			; canal B pulse bit
	moveq	#4,D6			; canal B noise bit
	move.w	14(A6),D4		; canal B MSB period
	move.b	10(A6),D4		; canal B LSB period
	moveq	#15,D3
	and.b	$26(A6),D3		; canal B volume
	bsr.w	ConvertToAmiga
	lea	-$10(A1),A1		; third Amiga channel (right)
	lea	CanalC(PC),A0
	moveq	#2,D5			; canal C pulse bit
	moveq	#5,D6			; canal C noise bit
	move.w	$16(A6),D4		; canal C MSB period
	move.b	$12(A6),D4		; canal C LSB period
	moveq	#15,D3
	and.b	$2A(A6),D3		; canal C volume
	bsr.w	ConvertToAmiga
	moveq	#3,D5
	lea	-$10(A1),A1		; second Amiga channel (right)
	lea	CanalNoise(PC),A0
	move.w	(A0)+,D0		; counter
	bne.b	ExtraNoise
	tst.w	4(A0)
	bne.b	Disable
	rts
ExtraNoise
	subq.w	#1,D0
	beq.b	NoiseVolOk
	subq.w	#1,D0
	beq.b	TwoNoise
	moveq	#0,D1
	move.w	(A0),D1
	divu.w	#3,D1			; /3
	move.w	D1,(A0)
	bra.b	NoiseVolOk
TwoNoise
	lsr	(A0)			; /2
NoiseVolOk
	bsr.b	NoiseOn
	clr.w	(A0)			; noise volume
	clr.w	-(A0)			; counter
	rts

CanalA
	dc.w	0			; volume
	dc.w	0			; period
	dc.w	0			; status
CanalB
	dc.w	0			; volume
	dc.w	0			; period
	dc.w	0			; status
CanalC
	dc.w	0			; volume
	dc.w	0			; period
	dc.w	0			; status
CanalNoise
	dc.w	0			; counter
	dc.w	0			; volume
	dc.w	0			; period
	dc.w	0			; status

VolTable
	dc.b	0
	dc.b	1			; 1
	dc.b	2			; 1
	dc.b	3			; 1
	dc.b	4			; 1
	dc.b	5			; 1
	dc.b	7			; 2
	dc.b	9			; 2
	dc.b	12			; 3
	dc.b	16			; 4
	dc.b	21			; 5
	dc.b	27			; 6
	dc.b	34			; 7
	dc.b	42			; 8
	dc.b	52			;10
	dc.b	64			;12

ConvertToAmiga
	move.b	VolTable(PC,D3.W),1(A0) ; Amiga volume
	btst	D5,D7
	bne.b	PulseOn			; pulse channel on
	btst	D6,D7
	bne.b	NoiseOn			; noise channel on
Disable
	lea	Empty,A2		; null sample
	move.l	A2,A3			; repeat address
	move.l	#$10001,D4		; repeat length/length
	clr.w	(A0)			; volume
	move.l	#$1000000,2(A0)		; period/status
	bsr.w	NotePlay
PutVolPer
	move.w	(A0),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,8(A1)
	move.w	2(A0),D0
	move.w	D0,6(A1)
	bra.w	SetPer

NoiseOn
	moveq	#31,D0
	and.b	$1A(A6),D0		; noise period
	lsl.w	#4,D0    		; *16
	add.w	#142,D0
	move.w	D0,2(A0)		; period
	move.w	4(A0),D0
	subq.w	#2,D0
	beq.b	PutVolPer
	move.w	#2,4(A0)		; noise sample set
	lea	Noise,A2		; noise sample
	move.l	A2,A3			; repeat address
	move.l	#$2000200,D4		; repeat length/length
	bsr.b	NotePlay
	bra.b	PutVolPer

;2005312/16=125331.9875			YM2149 clock/16 (internally)
;123331.9875*2=250663.975		size of pulse sample = 2
;3546895/250663.975=14.149		PAL timer
;3579546/250663.975=14.28		NTSC timer

PulseOn
	and.w	#$FFF,D4
	mulu.w	#14540,D4		; 14.2*1024
	moveq	#10,D0
	lsr.l	D0,D4			; * 14.2
	addq.w	#1,D4
	move.w	D4,2(A0)		; Amiga period
	btst	D6,D7
	beq.b	OnlyPulse
	lea	CanalNoise(PC),A2
	addq.w	#1,(A2)+		; counter
	move.w	(A0),D0			; volume
	add.w	D0,(A2)			; noise volume
OnlyPulse
	move.w	4(A0),D0
	subq.w	#1,D0
	beq.b	PutVolPer
	move.w	#1,4(A0)		; pulse sample set
	lea	Pulse,A2		; pulse sample
	move.l	A2,A3			; repeat address
	move.l	#$10001,D4		; repeat length/length
	bsr.b	NotePlay
	bra.w	PutVolPer

Voice
	dc.b	1			; left 1
	dc.b	8			; left 2
	dc.b	4			; right 2
	dc.b	2			; right 1
NotePlay
	lea	$dff000,A5			; load CustomBase

; Note: d2 must contain the DMA mask of the channels you want to stop,
;       and d3 the DMA mask of the channels you want to start.
;       The vhpos, vhposr, etc. definitions can be found in the
;       hardware/custom.i include file.
;       BTW - this routine cannot be used if a replay uses audio-interrupts
;       (because it uses the intreq/intreqr registers for waiting)!

	moveq	#0,D2
	move.b	Voice(PC,D5.W),D2

.StopDMA
	move.b	vhposr(A5),d1
.WaitLine1
	cmp.b	vhposr(A5),d1			; sync routine to start at linestart
	beq.s	.WaitLine1
.WaitDMA1
	cmp.b	#$16,vhposr+1(A5)		; wait til after Audio DMA slots
	bcs.s	.WaitDMA1
	move.w	#1,6(A1)

	move.w	dmaconr(A5),d0			; get active channels
	and.w	d2,d0
	move.w	d0,d1
	lsl.w	#7,d0
	move.w	d0,intreq(A5)			; clear requests
	move.w	d1,dmacon(A5)			; stop channels
.WaitStop
	move.w	intreqr(A5),d1			; wait until all channels are stopped
	and.w	d0,d1
	cmp.w	d0,d1
	bne.s	.WaitStop
.Skip

; Here you must set the oneshot-parts of the samples you stopped before

	move.l	A2,(A1)
	move.w	D4,4(A1)
	bsr.w	SetTwo
	swap	D4

; Because of the period = 1 trick used above, you must _always_ set the period
; of the stopped channels here, otherwise the output will sound wrong
; If you want to mute a channel, you can either turn it off, but not on again
; (by setting the channel's DMA bit in the d2 register, and clearing the channel's
; DMA bit in the d3 register), or you have to play a oneshot-nullsample and
; a loop-nullsample (smiliar to ProTracker)

	move.w	2(A0),6(A1)			; period

	move.b	vhposr(A5),d1
.WaitLine2
	cmp.b	vhposr(A5),d1			; sync routine to start at linestart
	beq.s	.WaitLine2
.WaitDMA2
	cmp.b	#$16,vhposr+1(A5)		; wait til after Audio DMA slots
	bcs.s	.WaitDMA2
.StartDMA
	move.w	dmaconr(A5),d0			; get active channels
	not.w	d0
	and.w	D2,D0

	move.w	d0,d1
	or.w	#$8000,d1
	lsl.w	#7,d0
	move.w	d0,intreq(A5)			; clear requests
	move.w	d1,dmacon(A5)			; start channels
.WaitStart
	move.w	intreqr(A5),d1			; wait until all channels are running
	and.w	d0,d1
	cmp.w	d0,d1
	bne.s	.WaitStart

	move.b	vhposr(A5),d1
.WaitLine3
	cmp.b	vhposr(A5),d1			; sync routine to start at linestart
	beq.s	.WaitLine3
.WaitDMA3
	cmp.b	#$16,vhposr+1(A5)		; wait til after Audio DMA slots
	bcs.s	.WaitDMA3

; Here you must set the loop-parts of the samples. If a sample doesn't have
; a loop, then you have to play a nullsample of length 1 (similiar to ProTracker).

	move.l	A3,(A1)
	move.w	D4,4(A1)
.Done
	rts

InitNoise
	move.l	#$E90,D3
	move.l	#'HIPP',D1
	move.w	#$3FF,D2
NextNoiseByte
	move.l	D1,D0
	asl.l	#3,D1
	sub.l	D0,D1
	asl.l	#3,D1
	add.l	D0,D1
	add.l	D1,D1
	add.l	D0,D1
	asl.l	#4,D1
	sub.l	D0,D1
	add.l	D1,D1
	sub.l	D0,D1
	add.l	D3,D0
	lsl.w	#4,D0
	add.l	D1,D0
	bclr	#$1F,D0
	subq.l	#1,D0
	move.l	D0,D1
	lsr.w	#8,D0
	move.b	D0,(A0)+
	dbf	D2,NextNoiseByte
	rts

YM2149Base
	dc.l	0		; YM-2149 LSB period base (canal A)
	dc.l	$1000000	; YM-2149 MSB period base (canal A)
	dc.l	$2000000	; YM-2149 LSB period base (canal B)
	dc.l	$3000000	; YM-2149 MSB period base (canal B)
	dc.l	$4000000	; YM-2149 LSB period base (canal C)
	dc.l	$5000000	; YM-2149 MSB period base (canal C)
	dc.l	$6000000	; Noise period
	dc.l	$700FF00	; Mixer control
	dc.l	$8000000	; YM-2149 volume base register (canal A)
	dc.l	$9000000	; YM-2149 volume base register (canal B)
	dc.l	$A000000	; YM-2149 volume base register (canal C)
	dc.l	$B000000	; YM-2149 envelope LSB period
	dc.l	$C000000	; YM-2149 envelope MSB period
	dc.l	$D000000        ; YM-2149 envelope wave form

Init_Emu2
	lea	Noise2,A2
	lea	Pulse2,A0
	moveq	#1,D0
	move.w	#$2000,D1
	lea	StructAdr+UPS_Voice1Adr(PC),A1
	move.l	A0,(A1)+
	move.w	D0,(A1)+
	move.w	D0,(A1)+
	addq.l	#8,A1
	move.w	D0,(A1)+	; repeat on
	move.l	A0,(A1)+
	move.w	D0,(A1)+
	move.w	D0,(A1)+
	addq.l	#8,A1
	move.w	D0,(A1)+	; repeat on
	move.l	A0,(A1)+
	move.w	D0,(A1)+
	move.w	D0,(A1)+
	addq.l	#8,A1
	move.w	D0,(A1)+	; repeat on
	move.l	A2,(A1)+
	move.w	D1,(A1)+
	move.w	D0,(A1)+
	addq.l	#8,A1
	move.w	D0,(A1)		; repeat on
	moveq	#0,D2
	move.w	#15,$DFF096
	lea	$DFF0A0,A1
	move.l	A0,(A1)+	; address
	move.w	D0,(A1)+	; length
	move.w	D0,(A1)+	; period
	move.l	D2,(A1)+	; volume + data
	addq.l	#4,A1
	move.l	A0,(A1)+
	move.w	D0,(A1)+
	move.w	D0,(A1)+
	move.l	D2,(A1)+
	addq.l	#4,A1
	move.l	A0,(A1)+
	move.w	D0,(A1)+
	move.w	D0,(A1)+
	move.l	D2,(A1)+
	addq.l	#4,A1
	move.l	A2,(A1)+
	move.w	D1,(A1)+
	move.w	D0,(A1)+
	move.l	D2,(A1)
	lea	YM2149Base(PC),A0
	clr.b	2(A0)
	clr.b	6(A0)
	clr.b	10(A0)
	clr.b	14(A0)
	clr.b	18(A0)
	clr.b	22(A0)
	clr.b	26(A0)
	st.b	30(A0)
	clr.b	34(A0)
	clr.b	38(A0)
	clr.b	42(A0)
	rts

GetData
	moveq	#0,D2
	moveq	#0,D3
	move.b	6(A0),D0
	lsl.w	#8,D0
	move.b	2(A0),D0
	addq.l	#8,A0
	and.w	#$FFF,D0
	move.b	(A4),D1
	addq.l	#4,A4
	and.w	#15,D1
	lsr.b	#1,D7
	tst.w	D0
	beq.b	NoCalc
	mulu.w	#$58B,D0
	divu.w	#$64,D0
	move.w	D0,D3
NoCalc
	btst	#2,D7
	BNE.S	mbC00025A
	MOVE.W	D1,D2
	BEQ.S	mbC00025A
	TST.W	D3
	BEQ.S	mbC00025A
	SUBQ.B	#2,D1
	BCC.S	mbC000254
	MOVEQ	#1,D1
mbC000254	SUBQ.B	#1,D2
	BNE.S	mbC00025A
	moveq	#1,D2
mbC00025A
	cmp.w	#$7B,D3
	bcc.b	PeriodOK
	moveq	#0,D3
PeriodOK
	lea	VolumeTable2(PC),A2
	move.b	(A2,D1.W),D1
	move.b	(A2,D2.W),D2
	rts

Play_Emu2
	lea	YM2149Base(PC),A5
	move.l	A5,A0
	lea	34(A0),A4
	lea	$DFF0A0,A1
	move.b	30(A5),D7
	moveq	#2,D6
	moveq	#0,D4
	moveq	#0,D5
NextChannel2
	bsr.w	GetData
	add.w	D2,D5
	move.w	D3,D0
	beq.b	ZeroPeriod
	move.w	D3,6(A1)
	bsr.w	SetPer
	bset	#3,D4
ZeroPeriod
	move.w	D1,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,8(A1)
	lsr.w	#1,D4
	lea	$10(A1),A1
	dbf	D6,NextChannel2
	lea	NoisePeriod2(PC),A2
	move.b	26(A5),D2
	and.w	#$1F,D2
	add.w	D2,D2
	move.w	(A2,D2.W),D0
	move.w	D0,6(A1)
	bsr.w	SetPer
	cmp.w	#64,D5
	bcs.b	NotTooHigh
	moveq	#64,D5
NotTooHigh
	move.w	D5,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,8(A1)
	move.b	30(A5),D2
	moveq	#$38,D3
	and.w	D3,D2
	eor.w	D3,D2
	sne	D2
	and.w	#8,D2
	add.w	D2,D4
	or.w	#$8000,D4
	move.w	D4,$DFF096
	eor.w	#$800F,D4
	move.w	D4,$DFF096
	rts

InitNoise2
	MOVE.W	#$3FFF,D2
	MOVEQ	#0,D3
NextByte2
	MOVE.L	D3,D0
	MOVE.L	D0,D1
	ASL.L	#3,D1
	SUB.L	D0,D1
	ASL.L	#3,D1
	ADD.L	D0,D1
	ADD.L	D1,D1
	ADD.L	D0,D1
	ASL.L	#4,D1
	SUB.L	D0,D1
	ADD.L	D1,D1
	SUB.L	D0,D1
	ADDI.L	#$E90,D0
	LSL.W	#4,D0
	ADD.L	D0,D1
	BCLR	#$1F,D1
	SUBQ.L	#1,D1
	MOVE.L	D1,D3
	LSR.W	#8,D1
	MOVE.B	D1,(A0)+
	DBRA	D2,NextByte2
	RTS

NoisePeriod2
	dc.w	$80
	dc.w	$A0
	dc.w	$C0
	dc.w	$E0
	dc.w	$100
	dc.w	$120
	dc.w	$140
	dc.w	$160
	dc.w	$180
	dc.w	$1A0
	dc.w	$1C0
	dc.w	$1E0
	dc.w	$200
	dc.w	$220
	dc.w	$240
	dc.w	$260
	dc.w	$280
	dc.w	$2A0
	dc.w	$2C0
	dc.w	$2E0
	dc.w	$300
	dc.w	$320
	dc.w	$340
	dc.w	$360
	dc.w	$380
	dc.w	$3A0
	dc.w	$3C0
	dc.w	$3E0
	dc.w	$400
	dc.w	$420
	dc.w	$440
	dc.w	$460
VolumeTable2
	dc.w	1
	dc.w	$101
	dc.w	$202
	dc.w	$304
	dc.w	$608
	dc.w	$B10
	dc.w	$1720
	dc.w	$2D40

	Section	Buffy,BSS_C
Noise
	ds.b	1024
Noise2
	ds.b	16384
Pulse2
	ds.b	2
Pulse
	ds.b	2
Empty
	ds.b	2
