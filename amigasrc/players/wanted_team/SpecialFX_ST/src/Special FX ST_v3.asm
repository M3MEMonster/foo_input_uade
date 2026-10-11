	*****************************************************
	****    Special FX ST replayer for EaglePlayer   ****
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

	dc.b	'$VER: Special FX ST player module V1.2 (18 Aug 2012)',0
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
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	DTP_Config,Config
	dc.l	DTP_UserConfig,UserConfig
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevSong!EPB_NextSong!EPB_LoadFast
	dc.l	TAG_DONE

PlayerName
	dc.b	'Special FX ST',0
Creator
	dc.b	'(c) 1989-92 by Matthew Cannon &',10
	dc.b	'Jonathan Dunn, adapted by Wanted Team',0
Prefix
	dc.b	'DODA.',0
CfgPath0
	dc.b	'/'				; necessary for Config loading
CfgPath1
	dc.b	'Configs/EP-Special_FX_ST.cfg',0
CfgPath2
	dc.b	'EnvArc:EaglePlayer/EP-Special_FX_ST.cfg',0
CfgPath3
	dc.b	'Env:EaglePlayer/EP-Special_FX_ST.cfg',0
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
	dc.b	'Special FX ST',0

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
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	lbL000030+10(PC),D0
	sub.l	lbL000030+6(PC),D0
	rts

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

	move.l	dtg_ChkSize(A5),D1
	cmp.l	#2300,D1
	ble.b	Fault
	tst.l	(A0)
	beq.b	Later
	cmp.w	#$101,(A0)
	beq.b	Later
	cmp.l	#$101,(A0)
	beq.b	Later
	cmp.w	#$6000,(A0)
	bne.b	Fault
Later
	lea	140(A0),A1
	lea	-4(A0,D1.L),A2
Checky
	cmp.l	#$00090800,(A0)
	beq.b	More
	addq.l	#2,A0
	cmp.l	A0,A1
	bne.b	Checky
Fault
	rts
More
	cmp.l	#$01120900,74(A0)
	bne.b	Fault
	cmp.l	#$02240A00,74*2(A0)
	bne.b	Fault
	cmp.l	#$00090800,74*3(A0)
	bne.b	Fault
	cmp.l	#$01120900,74*4(A0)
	bne.b	Fault
	cmp.l	#$02240A00,74*5(A0)
	bne.b	Fault
	lea	1860(A1),A0
Chicky
	cmp.l	#$0EF80E10,(A0)
	beq.b	OKi
	addq.l	#2,A0
	cmp.l	A0,A2
	bgt.b	Chicky
	rts
OKi
	moveq	#0,D0
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
Length		=	36
Voices		=	44

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Calcsize,0		;12
	dc.l	MI_SubSongs,0		;20
	dc.l	MI_Songsize,0		;28
	dc.l	MI_Length,0		;36
	dc.l	MI_Voices,0		;44
	dc.l	MI_MaxVoices,3
	dc.l	MI_Prefix,Prefix
	dc.l	MI_About,Text
	dc.l	0

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq	#1,D0
	move.l	InfoBuffer+SubSongs(PC),D1
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

	move.w	lbL000030(PC),D1
	bmi.b	PlayIt
	move.w	lbL00007A(PC),D1
	bmi.b	PlayIt
	move.w	lbL0000C4(PC),D1
	bmi.b	PlayIt
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A0
	jsr	(A0)
	move.l	InfoBuffer+Length(PC),D1
	cmp.w	#10,D1
	ble.b	PlayIt
	bsr.w	InitSound			; repeat on
PlayIt
	bsr.w	Play
	move.w	EmuType(PC),D1
	bne.b	NoOne
	bsr.w	Play_Emu1
	bra.b	SkipTwo
NoOne
	bsr.w	Play_Emu2
SkipTwo
	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D0-D7/A0-A6
	rts

SongEndTest
	movem.l	A0/A5,-(A7)
	lea	Songend(PC),A0
	cmp.b	#8,72(A1)
	bne.b	test1
	clr.b	(A0)
	bra.b	test
test1
	cmp.b	#10,72(A1)
	bne.b	test3
	clr.b	2(A0)
	bra.b	test
test3
	cmp.b	#9,72(A1)
	bne.b	test
	clr.b	3(A0)
	tst.w	74(A1)
	bmi.b	test
	clr.b	2(A0)
test
	tst.l	(A0)
	bne.b	SkipEnd
	move.l	#$FF00FFFF,(A0)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A0
	jsr	(A0)
SkipEnd
	movem.l	(A7)+,A0/A5
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	lea	Noise1,A0
	tst.l	(A0)
	bne.b	SampOK
	bsr.w	InitNoise1
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
	moveq	#0,D7
	move.l	D7,CalcSize(A4)
	move.l	D7,SongSize(A4)
	moveq	#10,D1
	move.l	A0,A1
Find1
	subq.l	#2,D0
	bmi.w	Error
	cmp.w	#$E740,(A1)+
	bne.b	Find1
	lea	-4(A1),A2
	move.w	-8(A2),SubSongs+2(A4)
	add.w	(A2),A2
	move.l	A2,lbL00123E
Find2
	cmp.l	#$101A234A,(A1)
	bne.b	NoSpec
	sub.l	D1,D0
	bmi.w	Error
	lea	8(A1),A2
	add.w	(A2),A2
	move.l	A2,lbL00138A
	add.l	D1,A1
	bra.b	Skippy
NoSpec
	cmp.l	#$4880D040,(A1)
	beq.b	OK2
Skippy
	subq.l	#2,D0
	bmi.w	Error
	addq.l	#2,A1
	bra.b	Find2
OK2
	lea	-2(A1),A2
	add.w	(A2),A2
	move.l	A2,lbL001296
Find3
	cmp.l	#$08C70007,(A1)
	beq.b	OK3
	subq.l	#2,D0
	bmi.w	Error
	addq.l	#2,A1
	bra.b	Find3
OK3
	move.l	A1,A2
Find4
	cmp.w	#$41FA,-(A2)
	bne.b	Find4
	addq.l	#2,A2
	add.w	(A2),A2
	move.l	A2,lbL00119A

Find5
	subq.l	#2,D0
	bmi.w	Error
	cmp.w	#$41F9,(A1)
	bne.b	NoFull1
	move.l	2(A1),A2
	bra.b	Full1
NoFull1
	cmp.w	#$41FA,(A1)+
	bne.b	Find5
	move.l	A1,A2
	add.w	(A2),A2
Full1
	move.l	A2,lbL00116C

Find6
	cmp.l	#$08870002,(A1)
	beq.b	OK6
	subq.l	#2,D0
	bmi.w	Error
	addq.l	#2,A1
	bra.b	Find6
OK6
	lea	6(A1),A2

	cmp.w	#$41F9,-2(A2)
	bne.b	NoFull2
	move.l	(A2),A2
	move.l	A2,D7				; Base
	bra.b	Full2
NoFull2
	add.w	(A2),A2
Full2
	move.l	A2,lbL000CC0

Find7
	cmp.l	#$08C70002,(A1)
	beq.b	OK7
	subq.l	#2,D0
	bmi.w	Error
	addq.l	#2,A1
	bra.b	Find7
OK7
	sub.l	D1,D0
	bmi.w	Error
	add.l	D1,A1
	move.l	A1,A2

	cmp.w	#$41F9,-2(A2)
	bne.b	NoFull3
	move.l	(A2),A2
	bra.b	Full3
NoFull3
	add.w	(A2),A2
Full3
	move.l	A2,lbL000D22

Find8
	subq.l	#2,D0
	bmi.w	Error
	cmp.w	#$41FA,(A1)+
	bne.b	Find8
	move.l	A1,A2
	add.w	(A2),A2
	move.l	A2,lbL000E5A

Find9
	cmp.l	#$0EF80E10,(A1)
	beq.w	Skip2
	cmp.l	#$7000101A,(A1)
	beq.b	OK9
	subq.l	#2,D0
	bmi.w	Error
	addq.l	#2,A1
	bra.b	Find9
OK9
	lea	-2(A1),A2
	add.w	(A2),A2
	move.l	A2,lbL002D7C

FindA
	subq.l	#2,D0
	bmi.w	Error

	cmp.l	#$0EF80E10,(A1)
	beq.b	Skip2
	cmp.w	#$41FA,(A1)+
	bne.b	FindA
	move.l	A1,A2
	add.w	(A1),A1
	move.l	A1,lbL002FE4

	sub.l	A0,A1
	move.l	A1,CalcSize(A4)
	move.l	A1,SongSize(A4)
	cmp.l	LoadSize(A4),A1
	bgt.w	Short
	tst.l	D7				; Base
	beq.b	Skip2
FindEnd
	cmp.w	#$41FA,(A2)
	bne.b	FindTable
	lea	2(A2),A1
	add.w	(A1),A1
	lea	14(A1),A1
	sub.l	A0,A1
	move.l	A1,CalcSize(A4)
	move.l	A1,SongSize(A4)
FindTable
	cmp.l	#$110010,(A2)
	beq.b	EndTable
	addq.l	#2,A2
	bra.b	FindEnd
EndTable
	addq.l	#4,A2
	move.l	A2,D1
	lea	lbL000CC0(PC),A1
	sub.l	D7,(A1)
	add.l	D1,(A1)
	lea	lbL000D22(PC),A1
	sub.l	D7,(A1)
	add.l	D1,(A1)
	lea	lbL00116C(PC),A1
	sub.l	D7,(A1)
	add.l	D1,(A1)
Skip2
	move.l	lbL001296(PC),D0
	sub.l	lbL00123E(PC),D0
	bmi.b	Skip
	lsr.l	#3,D0
	beq.b	Skip
	move.l	D0,SubSongs(A4)
Skip
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
Error
	moveq	#EPR_ErrorInFile,D0
	rts

SetEmu
	lea	YM2149Base(PC),A0
	move.b	(A2)+,2(A0)
	move.b	(A2)+,6(A0)
	move.b	(A2)+,10(A0)
	move.b	(A2)+,14(A0)
	move.b	(A2)+,18(A0)
	move.b	(A2)+,22(A0)
	move.b	(A2)+,26(A0)
	move.b	(A2)+,30(A0)
	move.b	(A2)+,34(A0)
	move.b	(A2)+,38(A0)
	move.b	(A2)+,42(A0)
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
	bsr.w	Init_Emu1
	bra.b	SkipInit2
Init2
	bsr.w	Init_Emu2
SkipInit2
	lea	Songend(PC),A0
	move.l	#$FF00FFFF,(A0)

	lea	InfoBuffer+Voices(PC),A4
	moveq	#3,D0
	move.l	D0,(A4)
	move.w	dtg_SndNum(A5),D0
	bsr.w	Init
	moveq	#1,D0
	cmp.l	(A4),D0
	beq.b	One
	move.l	lbL00007A+6(PC),D0
	sub.l	lbL000030+6(PC),D0
	bpl.b	One
	moveq	#1,D0
	move.l	lbL000030+6(PC),A0
More1
	cmp.b	#$80,(A0)
	beq.b	One
	cmp.b	#$81,(A0)
	beq.b	One
	addq.l	#1,D0
	addq.l	#1,A0
	bra.b	More1
One
	move.l	D0,Length-Voices(A4)
	rts

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

Init_Emu1
lbC000392	LEA	lbL000616(PC),A0
	MOVE.W	#0,10(A0)
	LEA	lbL000622(PC),A0
	MOVE.W	#0,10(A0)
	LEA	lbL00062E(PC),A0
	MOVE.W	#0,10(A0)

	lea	NoiseFlag(PC),A0		;+
	clr.w	(A0)				;+
	clr.w	2(A0)				;+
	clr.w	12(A0)

	LEA	YM2149Base(PC),A0

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

	RTS

Play_Emu1
	LEA	YM2149Base(PC),A6
	MOVE.B	$1E(A6),D7
	NOT.B	D7
	ANDI.W	#$3F,D7

	lea	$DFF0A0,A1

	LEA	lbL000616(PC),A0
	MOVEQ	#0,D5
	MOVEQ	#3,D6
	MOVE.B	6(A6),D4
	LSL.W	#8,D4
	MOVE.B	2(A6),D4
	MOVE.B	$22(A6),D3
	BSR.L	lbC0004DC

	lea	$DFF0D0,A1

	LEA	lbL000622(PC),A0
	MOVEQ	#1,D5
	MOVEQ	#4,D6
	MOVE.B	14(A6),D4
	LSL.W	#8,D4
	MOVE.B	10(A6),D4
	MOVE.B	$26(A6),D3
	BSR.L	lbC0004DC

	lea	$DFF0C0,A1

	LEA	lbL00062E(PC),A0
	MOVEQ	#2,D5
	MOVEQ	#5,D6
	MOVE.B	$16(A6),D4
	LSL.W	#8,D4
	MOVE.B	$12(A6),D4
	MOVE.B	$2A(A6),D3
	BSR.L	lbC0004DC

	moveq	#3,D5
	lea	$DFF0B0,A1
	lea	NoiseFlag(PC),A0			;+
	tst.w	(A0)+
	bne.b	ExtraNoise
	tst.w	10(A0)
	beq.b	Off
	bra.w	Disable
ExtraNoise
	bsr.w	lbC00054A
	clr.w	(A0)
Off
	RTS

NoiseFlag
	dc.w	0
NoiseVol
	dc.w	0
NoisePer
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0

lbB0004CA	dc.b	0
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	2
	dc.b	2
	dc.b	3
	dc.b	4
	dc.b	6
	dc.b	8
	dc.b	11
	dc.b	16
	dc.b	23
	dc.b	32
	dc.b	45
	dc.b	64

lbC0004DC

	and.w	#15,D3

	MOVE.B	lbB0004CA(PC,D3.W),1(A0)
;	MULU.W	#7,D4

;2005312/16=125331.9875			YM2149 clock/16 (internally)
;123331.9875*2=250663.975		size of pulse sample = 2
;3546895/250663.975=14.149		PAL timer
;3579546/250663.975=14.28		NTSC timer

	and.w	#$FFF,D4
	mulu.w	#14540,D4		; 14.2*1024
	moveq	#10,D0
	lsr.l	D0,D4			; * 14.2
	addq.w	#1,D4

	MOVE.W	D4,2(A0)
	BTST	D5,D7
	BNE.L	lbC0005DA
	BTST	D6,D7
	BNE.L	lbC00054A
Disable
	lea	Empty,A2
	move.l	A2,A3
	move.l	#$10001,D4
	bsr.w	NotePlay

	MOVE.W	#0,0(A0)
	MOVE.W	#$100,2(A0)
	MOVE.W	#0,10(A0)
lbC000530
	move.w	(A0),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,8(A1)
	move.w	2(A0),D0
	move.w	D0,6(A1)
	bsr.w	SetPer

	RTS

lbC00054A	MOVE.W	10(A0),D0
	CMP.W	#2,D0
	BEQ.S	lbC000582
	MOVE.W	#2,10(A0)

	lea	Noise1,A2
	move.l	A2,A3
	move.l	#$2000200,D4
	bsr.w	NotePlay

lbC000582	MOVEQ	#0,D0
	MOVE.B	$1A(A6),D0
	ANDI.W	#$1F,D0
	ADD.W	D0,D0
	MOVE.W	lbW00059A(PC,D0.W),D0
	MOVE.W	D0,2(A0)
	BRA.L	lbC000530

lbW00059A
	dc.w	142+14*31
	dc.w	142+14*30
	dc.w	142+14*29
	dc.w	142+14*28
	dc.w	142+14*27
	dc.w	142+14*26
	dc.w	142+14*25
	dc.w	142+14*24
	dc.w	142+14*23
	dc.w	142+14*22
	dc.w	142+14*21
	dc.w	142+14*20
	dc.w	142+14*19
	dc.w	142+14*18
	dc.w	142+14*17
	dc.w	142+14*16
	dc.w	142+14*15
	dc.w	142+14*14
	dc.w	142+14*13
	dc.w	142+14*12
	dc.w	142+14*11
	dc.w	142+14*10
	dc.w	142+14*9
	dc.w	142+14*8
	dc.w	142+14*7
	dc.w	142+14*6
	dc.w	142+14*5
	dc.w	142+14*4
	dc.w	142+14*3
	dc.w	142+14*2
	dc.w	142+14*1
	dc.w	142+14*0

;	dc.w	$280
;	dc.w	$270
;	dc.w	$260
;	dc.w	$250
;	dc.w	$240
;	dc.w	$230
;	dc.w	$220
;	dc.w	$210
;	dc.w	$200
;	dc.w	$1F0
;	dc.w	$1E0
;	dc.w	$1D0
;	dc.w	$1C0
;	dc.w	$1B0
;	dc.w	$1A0
;	dc.w	$190
;	dc.w	$180
;	dc.w	$170
;	dc.w	$160
;	dc.w	$150
;	dc.w	$140
;	dc.w	$130
;	dc.w	$120
;	dc.w	$110
;	dc.w	$100
;	dc.w	$F0
;	dc.w	$E0
;	dc.w	$D0
;	dc.w	$C0
;	dc.w	$B0
;	dc.w	$A0
;	dc.w	$90

lbC0005DA
	btst	D6,D7				; +
	beq.b	SetPulse
	st	NoiseFlag
	move.w	(A0),D0
	subq.b	#1,D3
	bmi.b	.Skip
	lea	lbB0004CA(PC),A2
	move.b	(A2,D3.W),D0
.Skip
	cmp.w	NoiseVol(PC),D0
	ble.b	SetPulse
	move.w	D0,NoiseVol
SetPulse
	MOVE.W	10(A0),D0
	CMP.W	#1,D0
	BEQ.S	lbC000612
	MOVE.W	#1,10(A0)

	lea	Pulse1,A2
	move.l	A2,A3
	move.l	#$10001,D4
	bsr.w	NotePlay

lbC000612	BRA.L	lbC000530

lbL000616	dc.l	0
	dc.l	0
	dc.l	0
lbL000622	dc.l	0
	dc.l	0
	dc.l	0
lbL00062E	dc.l	0
	dc.l	0
	dc.l	0

InitNoise1
	MOVE.W	#$3FF,D2
lbC000DD4	BSR.S	lbC000DE2
	MOVE.B	D0,(A0)+
	DBRA	D2,lbC000DD4
	RTS

lbL000DDE	dc.l	'HIPP'

lbC000DE2	MOVE.L	lbL000DDE,D0
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
	MOVE.L	D1,D0
	SUBQ.L	#1,D0
	MOVE.L	D0,lbL000DDE
	LSR.L	#8,D0
	RTS

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

***************************************************************************
**************************** Special FX ST player *************************
***************************************************************************

; Player from game "Addams Family" (c) 1992 by Ocean

;	BRA.L	lbC000388

;	BRA.L	lbC000388

;	BRA.L	lbC000388

;	BRA.L	lbC000412

;	BRA.L	lbC000226

;	BRA.L	lbC0002F0

;	BRA.L	lbC000462

;lbW00001C	dc.w	0
;lbB00001E	dc.b	1
;lbB00001F	dc.b	1
;lbB000020	dc.b	0
;lbB000021	dc.b	0
;lbB000022	dc.b	0
;	dc.b	0
;lbW000024	dc.w	0
;lbL000026	dc.l	0
;	dc.l	0
;	dc.w	0
lbL000030	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	9
	dc.w	$800
lbL00007A	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$112
	dc.w	$900
lbL0000C4	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$224
	dc.w	$A00
;lbL00010E	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	9
;	dc.w	$800
;lbL000158	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	$112
;	dc.w	$900
;lbL0001A2	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	$224
;	dc.w	$A00
lbB0001EC	dc.b	0
lbB0001ED	dc.b	0
lbB0001EE	dc.b	0
lbB0001EF	dc.b	0
lbB0001F0	dc.b	0
lbB0001F1	dc.b	0
lbB0001F2	dc.b	0
lbB0001F3	dc.b	0
lbB0001F4	dc.b	0
lbB0001F5	dc.b	0
lbB0001F6	dc.b	0
		dc.b	0

;	MOVE.B	-$5E7,D0
;	BNE.L	lbC000202
;	MOVEQ	#-1,D0
;lbC000202	MOVE.B	D0,lbB000022
;	CLR.B	-$5E7
;	BRA.L	lbC000356

;	MOVE.B	lbB000022,D0
;	BMI.L	lbC00021E
;	MOVE.B	D0,-$5E7
;lbC00021E	CLR.B	lbB000022
;	RTS

Init
lbC000226	BSR.L	lbC000388
;	CLR.W	lbW00001C
	SUBQ.W	#1,D0
;	BMI.L	lbC0002EE
;	CMPI.W	#11,D0
;	BCC.L	lbC0002EE
;	LEA	lbL00123E(PC),A0

	move.l	lbL00123E(PC),A0

	ASL.W	#3,D0
	LEA	0(A0,D0.W),A0
	LEA	lbL000030,A1
	MOVEQ	#2,D7
lbC000250	MOVE.W	(A0)+,D0
;	BEQ.L	lbC0002DE

	bne.b	VoiceOK
	subq.l	#1,(A4)
	bra.w	lbC0002DE
VoiceOK
	LEA	-2(A0,D0.W),A2
	MOVE.L	A2,6(A1)
	MOVE.B	#0,$41(A1)
	MOVE.B	#1,14(A1)
	MOVE.B	#1,$3F(A1)
	MOVE.W	#$8000,(A1)
lbC000274	MOVE.B	(A2)+,D0
	BPL.L	lbC0002CA
	ANDI.B	#$7F,D0
	BEQ.S	lbC0002A0
	CMPI.B	#$7F,D0
	BNE.S	lbC0002A6
	MOVE.B	(A2)+,D0
	MOVE.L	A2,10(A1)
;	LEA	lbL00138A(PC),A2

	move.l	lbL00138A(PC),A2			; extra

	EXT.W	D0
	ADD.W	D0,D0
	ADDA.W	D0,A2
	ADDA.W	(A2),A2
	MOVE.L	A2,2(A1)
	BRA.L	lbC0002DE

lbC0002A0	CLR.W	(A1)
	BRA.L	lbC0002DE

lbC0002A6	SUBQ.B	#1,D0
	BNE.L	lbC0002B4
	MOVE.B	(A2),D0
	EXT.W	D0
	ADDA.W	D0,A2
	BRA.S	lbC000274

lbC0002B4	SUBQ.B	#1,D0
	BNE.L	lbC0002C0
	MOVE.B	(A2)+,14(A1)
	BRA.S	lbC000274

lbC0002C0	SUBQ.B	#1,D0
	BNE.S	lbC000274
	MOVE.B	(A2)+,$41(A1)
	BRA.S	lbC000274

lbC0002CA	MOVE.L	A2,10(A1)
;	LEA	lbL001296(PC),A2

	move.l	lbL001296(PC),A2

	EXT.W	D0
	ADD.W	D0,D0
	ADDA.W	D0,A2
	ADDA.W	(A2),A2
	MOVE.L	A2,2(A1)
lbC0002DE	LEA	$4A(A1),A1
	DBRA	D7,lbC000250
;	MOVE.B	#1,lbB000020
lbC0002EE	RTS

;lbC0002F0	CLR.B	lbB000021
;	SUBQ.W	#1,D0
;	BMI.L	lbC0003E4
;	CMPI.W	#$1A,D0
;	BCC.L	lbC0003E4
;	LEA	lbL002E32(PC),A0
;	ASL.W	#3,D0
;	LEA	0(A0,D0.W),A0
;	LEA	lbL00010E,A1
;	MOVEQ	#2,D7
;lbC000316	MOVE.W	(A0)+,D0
;	BEQ.L	lbC000344
;	LEA	-2(A0,D0.W),A2
;	MOVE.L	A2,2(A1)
;	BTST	#8,1(A1)
;	BEQ.L	lbC00033A
;	MOVEQ	#0,D0
;	MOVE.B	D0,-$5E7
;	MOVE.W	D0,lbW000024
;lbC00033A	MOVE.W	#$8000,(A1)
;	MOVE.B	#1,$3F(A1)
;lbC000344	LEA	$4A(A1),A1
;	DBRA	D7,lbC000316
;	MOVE.B	#1,lbB000021
;	RTS

;lbC000356	LEA	-$7800,A0
;	MOVE.W	#$A00,D0
;	MOVEQ	#2,D1
;	MOVE.W	#$100,D2
;lbC000364	MOVEP.W	D0,0(A0)
;	SUB.W	D2,D0
;	DBRA	D1,lbC000364
;	MOVE.W	#$7F8,D0
;	MOVEP.W	D0,0(A0)
;	MOVE.W	#$600,D0
;	MOVEQ	#6,D1
;lbC00037C	MOVEP.W	D0,0(A0)
;	SUB.W	D2,D0
;	DBRA	D1,lbC00037C
;	RTS

lbC000388	MOVEM.L	D0-D2/A0,-(SP)
;	MOVEQ	#0,D0
;	MOVE.W	D0,lbB000020
;	MOVE.B	D0,-$5E7
;	MOVE.W	D0,lbW000024
;	BSR.S	lbC000356
;	MOVEQ	#0,D0
;	MOVE.W	D0,lbL000030
;	MOVE.W	D0,lbL00007A
;	MOVE.W	D0,lbL0000C4
;	MOVE.W	D0,lbL00010E
;	MOVE.W	D0,lbL000158
;	MOVE.W	D0,lbL0001A2
;	MOVE.B	D0,lbB000022
;	MOVE.B	D0,lbB0001F4
;	MOVE.B	D0,lbB0001F5
;	MOVE.B	D0,lbB0001F6

	lea	lbB0001EC(PC),A0
	clr.l	(A0)+
	clr.l	(A0)+
	clr.l	(A0)
	lea	lbL000030(PC),A0
	moveq	#$46,D7
Clear1
	clr.b	(A0)+
	dbf	D7,Clear1
	lea	lbL00007A(PC),A0
	moveq	#$46,D7
Clear2	clr.b	(A0)+
	dbf	D7,Clear2
	lea	lbL0000C4(PC),A0
	moveq	#$46,D7
Clear3	clr.b	(A0)+
	dbf	D7,Clear3

	MOVEM.L	(SP)+,D0-D2/A0
	RTS

;lbC0003E4	CLR.B	lbB000021
;	LEA	lbL00010E,A1
;	MOVEQ	#2,D7
;lbC0003F2	BTST	#0,(A1)
;	BEQ.L	lbC000406
;	MOVEQ	#0,D0
;	MOVE.B	D0,-$5E7
;	MOVE.W	D0,lbW000024
;lbC000406	CLR.W	(A1)
;	LEA	$4A(A1),A1
;	DBRA	D7,lbC0003F2
;	RTS

;lbC000412	CLR.B	lbB000021
;	SUBQ.W	#1,D0
;	BMI.S	lbC0003E4
;	CMPI.W	#$1A,D0
;	BCC.S	lbC0003E4
;	LEA	lbL002E32(PC),A0
;	ASL.W	#2,D0
;	LEA	0(A0,D0.W),A0
;	LEA	lbL000030,A1
;	MOVEQ	#2,D7
;lbC000434	MOVE.W	(A0)+,D0
;	BEQ.L	lbC000450
;	BCLR	#0,(A1)
;	BEQ.L	lbC00044E
;	MOVEQ	#0,D0
;	MOVE.B	D0,-$5E7
;	MOVE.W	D0,lbW000024
;lbC00044E	CLR.W	(A1)
;lbC000450	LEA	$4A(A1),A1
;	DBRA	D7,lbC000434
;	MOVE.B	#1,lbB000021
;	RTS

Play
;lbC000462	TST.B	lbB000022
;	BNE.L	lbC0006B8
	MOVE.B	#$FF,lbB0001F3
;	BCLR	#0,lbB000020
;	BEQ.L	lbC000564
;	ADDQ.W	#1,lbW00001C
	LEA	lbL000030(pc),A1
	MOVE.W	(A1),D7
	BPL.L	lbC0004CA
;	BSET	#0,lbB000020
	MOVEA.L	2(A1),A2
	BSR.L	lbC0006BA
	MOVE.L	A2,2(A1)
	MOVE.W	D7,(A1)
	MOVE.B	D1,lbB0001F4
	MOVE.B	D0,lbB0001EC
	LSR.W	#8,D0
	MOVE.B	D0,lbB0001ED
	BTST	#5,D7
	BEQ.L	lbC0004CA
	MOVE.B	D0,lbB0001F2
lbC0004CA	LEA	lbL00007A(pc),A1
	MOVE.W	(A1),D7
	BPL.L	lbC00050E
;	BSET	#0,lbB000020
	MOVEA.L	2(A1),A2
	BSR.L	lbC0006BA
	MOVE.L	A2,2(A1)
	MOVE.W	D7,(A1)
	MOVE.B	D1,lbB0001F5
	MOVE.B	D0,lbB0001EE
	LSR.W	#8,D0
	MOVE.B	D0,lbB0001EF
	BTST	#5,D7
	BEQ.L	lbC00050E
	MOVE.B	D0,lbB0001F2
lbC00050E	LEA	lbL0000C4(pc),A1
	MOVE.W	(A1),D7
	BPL.L	lbC000552
;	BSET	#0,lbB000020
	MOVEA.L	2(A1),A2
	BSR.L	lbC0006BA
	MOVE.L	A2,2(A1)
	MOVE.W	D7,(A1)
	MOVE.B	D1,lbB0001F6
	MOVE.B	D0,lbB0001F0
	LSR.W	#8,D0
	MOVE.B	D0,lbB0001F1
	BTST	#5,D7
	BEQ.L	lbC000552
	MOVE.B	D0,lbB0001F2
lbC000552
;	TST.B	lbB00001E
;	BNE.L	lbC000564
;	MOVE.B	#$FF,lbB0001F3
lbC000564
;	TST.B	lbB00001F
;	BEQ.L	lbC000646
;	BCLR	#0,lbB000021
;	BEQ.L	lbC000646
;	LEA	lbL00010E,A1
;	MOVE.W	(A1),D7
;	BPL.L	lbC0005BE
;	BSET	#0,lbB000021
;	MOVEA.L	2(A1),A2
;	BSR.L	lbC0006BA
;	MOVE.L	A2,2(A1)
;	MOVE.W	D7,(A1)
;	MOVE.B	D1,lbB0001F4
;	MOVE.B	D0,lbB0001EC
;	LSR.W	#8,D0
;	MOVE.B	D0,lbB0001ED
;	BTST	#5,D7
;	BEQ.L	lbC0005BE
;	MOVE.B	D0,lbB0001F2
;lbC0005BE	LEA	lbL000158,A1
;	MOVE.W	(A1),D7
;	BPL.L	lbC000602
;	BSET	#0,lbB000021
;	MOVEA.L	2(A1),A2
;	BSR.L	lbC0006BA
;	MOVE.L	A2,2(A1)
;	MOVE.W	D7,(A1)
;	MOVE.B	D1,lbB0001F5
;	MOVE.B	D0,lbB0001EE
;	LSR.W	#8,D0
;	MOVE.B	D0,lbB0001EF
;	BTST	#5,D7
;	BEQ.L	lbC000602
;	MOVE.B	D0,lbB0001F2
;lbC000602	LEA	lbL0001A2,A1
;	MOVE.W	(A1),D7
;	BPL.L	lbC000646
;	BSET	#0,lbB000021
;	MOVEA.L	2(A1),A2
;	BSR.L	lbC0006BA
;	MOVE.L	A2,2(A1)
;	MOVE.W	D7,(A1)
;	MOVE.B	D1,lbB0001F6
;	MOVE.B	D0,lbB0001F0
;	LSR.W	#8,D0
;	MOVE.B	D0,lbB0001F1
;	BTST	#5,D7
;	BEQ.L	lbC000646
;	MOVE.B	D0,lbB0001F2
;lbC000646	MOVE.B	lbB00001E,D0
;	AND.B	lbB000020,D0
;	MOVE.B	lbB00001F,D1
;	AND.B	lbB000021,D1
;	OR.B	D1,D0
;	BEQ.L	lbC0006B8
;	LEA	-$7800,A0
	LEA	lbB0001EC(pc),A2

	bsr.w	SetEmu

;	MOVEQ	#0,D0
;	MOVE.W	#$100,D1
;	MOVEQ	#7,D2
;lbC000676	MOVE.B	(A2)+,D0
;	MOVEP.W	D0,0(A0)
;	ADD.W	D1,D0
;	DBRA	D2,lbC000676
;	MOVE.W	lbW000024,D2
;	MOVE.W	#$800,D0
;	CMP.W	D2,D0
;	BEQ.L	lbC000698
;	MOVE.B	(A2)+,D0
;	MOVEP.W	D0,0(A0)
;lbC000698	MOVE.W	#$900,D0
;	CMP.W	D2,D0
;	BEQ.L	lbC0006A8
;	MOVE.B	(A2)+,D0
;	MOVEP.W	D0,0(A0)
;lbC0006A8	MOVE.W	#$A00,D0
;	CMP.W	D2,D0
;	BEQ.L	lbC0006B8
;	MOVE.B	(A2)+,D0
;	MOVEP.W	D0,0(A0)
lbC0006B8	RTS

lbC0006BA	SUBQ.B	#1,$3F(A1)
	BNE.L	lbC000752
lbC0006C2	MOVE.B	(A2)+,D0
	BMI.L	lbC0008C0
	ADD.B	$41(A1),D0
	MOVE.B	D0,$42(A1)
	BTST	#0,D7
	BEQ.L	lbC0006E2
	ADD.B	$10(A1),D0
	MOVE.B	$11(A1),$12(A1)
lbC0006E2	MOVE.B	D0,$43(A1)
	LEA	lbW000C02(PC),A0
	EXT.W	D0
	ADD.W	D0,D0
	MOVE.W	0(A0,D0.W),$44(A1)
	MOVEQ	#1,D0
	MOVE.L	$1C(A1),$20(A1)
	MOVE.B	$24(A1),$25(A1)
	MOVE.B	D0,$27(A1)
	MOVE.L	$28(A1),$2C(A1)
	MOVE.W	D0,$30(A1)
	MOVE.L	$34(A1),$38(A1)
	MOVE.B	D0,$3C(A1)
	MOVEQ	#0,D0
	MOVE.B	D0,$3D(A1)
	MOVE.B	D0,$40(A1)
	BSET	#3,D7
	BCLR	#7,D7
;	BCLR	#8,D7
;	BEQ.L	lbC000740
;	MOVEQ	#0,D0
;	MOVE.B	D0,-$5E7
;	MOVE.W	D0,lbW000024
lbC000740	MOVE.B	$3E(A1),D0
	BTST	#6,D7
	BNE.L	lbC00074E
	MOVE.B	(A2)+,D0
lbC00074E	MOVE.B	D0,$3F(A1)
lbC000752
;	BTST	#8,D7
;	BEQ.S	lbC000778
;	MOVE.B	lbB0001F3,D0
;	MOVE.B	$47(A1),D1
;	OR.B	D1,D0
;	ANDI.B	#7,D1
;	EOR.B	D1,D0
;	MOVE.B	D0,lbB0001F3
;	MOVEQ	#0,D0
;	MOVEQ	#0,D1
;	BRA.L	lbC0008BE

lbC000778	BTST	#7,D7
	BEQ.S	lbC0007B6
	MOVEA.L	$18(A1),A0
	MOVE.B	lbB0001F3(pc),D0
	MOVE.B	$47(A1),D1
	OR.B	D1,D0
	AND.B	(A0)+,D1
	BEQ.L	lbC0007AE
	EOR.B	D1,D0
	MOVE.B	D0,lbB0001F3
	MOVE.B	(A0)+,D1
	MOVE.W	(A0)+,D0
	MOVE.B	D0,lbB0001F2
	MOVE.L	A0,$18(A1)
	BRA.L	lbC0008BE

lbC0007AE	MOVEQ	#0,D0
	MOVEQ	#0,D1
	BRA.L	lbC0008BE

lbC0007B6	MOVE.B	lbB0001F3(pc),D0
	OR.B	$47(A1),D0
	MOVE.B	15(A1),D1
	EOR.B	D1,D0
	MOVE.B	D0,lbB0001F3
	MOVE.W	$44(A1),D0
	BTST	#0,D7
	BEQ.L	lbC0007F4
	SUBQ.B	#1,$12(A1)
	BCC.L	lbC0007F4
	LEA	lbW000C02(PC),A0
	MOVE.B	$42(A1),D2
	MOVE.B	D2,$43(A1)
	EXT.W	D2
	ADD.W	D2,D2
	MOVE.W	0(A0,D2.W),D0
lbC0007F4	BTST	#1,D7
	BEQ.L	lbC000836
	SUBQ.B	#1,$27(A1)
	BNE.L	lbC000836
	MOVEA.L	$20(A1),A0
	MOVE.B	(A0)+,D0
	SUBQ.B	#1,$25(A1)
	BNE.L	lbC00081C
	MOVEA.L	$1C(A1),A0
	MOVE.B	$24(A1),$25(A1)
lbC00081C	MOVE.L	A0,$20(A1)
	MOVE.B	$26(A1),$27(A1)
	LEA	lbW000C02(PC),A0
	ADD.B	$43(A1),D0
	EXT.W	D0
	ADD.W	D0,D0
	MOVE.W	0(A0,D0.W),D0
lbC000836	BTST	#2,D7
	BEQ.L	lbC000864
	SUBQ.W	#1,$30(A1)
	BNE.L	lbC000860
	MOVEA.L	$2C(A1),A0
	MOVE.W	(A0)+,$30(A1)
	BPL.L	lbC000858
	ADDA.W	(A0),A0
	MOVE.W	(A0)+,$30(A1)
lbC000858	MOVE.W	(A0)+,$32(A1)
	MOVE.L	A0,$2C(A1)
lbC000860	ADD.W	$32(A1),D0
lbC000864	MOVE.W	D0,$44(A1)
	BTST	#4,D7
	BEQ.L	lbC000888
	MOVE.B	$13(A1),D1
	CMP.B	$3F(A1),D1
	BNE.L	lbC000888
	MOVE.L	$14(A1),$38(A1)
	MOVE.B	#1,$3C(A1)
lbC000888	BTST	#3,D7
	BEQ.L	lbC0008BA
	SUBQ.B	#1,$3C(A1)
	BNE.L	lbC0008BA
	MOVEA.L	$38(A1),A0
	MOVE.B	(A0)+,$3C(A1)
	BEQ.L	lbC0008BA
	BPL.L	lbC0008B2
	MOVE.B	(A0),D2
	EXT.W	D2
	ADDA.W	D2,A0
	MOVE.B	(A0)+,$3C(A1)
lbC0008B2	MOVE.B	(A0)+,$40(A1)
	MOVE.L	A0,$38(A1)
lbC0008BA	MOVE.B	$40(A1),D1
lbC0008BE	RTS

lbC0008C0	CMPI.B	#$90,D0
	BCS.L	lbC0009BA
	ADDI.B	#$20,D0
	BCS.L	lbC0009A6
	ADDI.B	#$20,D0
	BCS.L	lbC00097E
	ADDI.B	#$20,D0
	BCS.L	lbC000948
	ADDI.B	#8,D0
	BCS.L	lbC000920
	ADDI.B	#8,D0
	BCS.L	lbC0008F4
	BRA.L	lbC0006C2

lbC0008F4
;	LEA	lbL00119A(PC),A0

	move.l	lbL00119A(PC),A0

	EXT.W	D0
	ADD.W	D0,D0
	ADDA.W	D0,A0
	ADDA.W	(A0),A0
	MOVE.L	A0,$18(A1)
	BSET	#7,D7
;	BCLR	#8,D7
;	BEQ.L	lbC000740
;	MOVEQ	#0,D0
;	MOVE.B	D0,-$5E7
;	MOVE.W	D0,lbW000024
	BRA.L	lbC000740

lbC000920	BEQ.L	lbC000940
	BSET	#4,D7
;	LEA	lbL00116C(PC),A0

	move.l	lbL00116C(PC),A0

	EXT.W	D0
	ADD.W	D0,D0
	ADDA.W	D0,A0
	ADDA.W	(A0),A0
	MOVE.B	(A0)+,$13(A1)
	MOVE.L	A0,$14(A1)
	BRA.L	lbC0006C2

lbC000940	BCLR	#4,D7
	BRA.L	lbC0006C2

lbC000948	BEQ.L	lbC000976
	BSET	#1,D7
	BCLR	#2,D7
;	LEA	lbL000CC0(PC),A0

	move.l	lbL000CC0(PC),A0

	EXT.W	D0
	ADD.W	D0,D0
	ADDA.W	D0,A0
	ADDA.W	(A0),A0
	MOVE.B	(A0)+,$26(A1)
	MOVE.B	(A0)+,$24(A1)
	MOVE.L	A0,$1C(A1)
	MOVE.B	#1,$27(A1)
	BRA.L	lbC0006C2

lbC000976	BCLR	#1,D7
	BRA.L	lbC0006C2

lbC00097E	BEQ.L	lbC00099E
	BSET	#2,D7
	BCLR	#1,D7
;	LEA	lbL000D22(PC),A0

	move.l	lbL000D22(PC),A0

	EXT.W	D0
	ADD.W	D0,D0
	ADDA.W	D0,A0
	ADDA.W	(A0),A0
	MOVE.L	A0,$28(A1)
	BRA.L	lbC0006C2

lbC00099E	BCLR	#2,D7
	BRA.L	lbC0006C2

lbC0009A6
;	LEA	lbL000E5A(PC),A0

	move.l	lbL000E5A(PC),A0

	EXT.W	D0
	ADD.W	D0,D0
	ADDA.W	D0,A0
	ADDA.W	(A0),A0
	MOVE.L	A0,$34(A1)
	BRA.L	lbC0006C2

lbC0009BA	LEA	lbW0009D2(PC),A0
	SUBI.B	#$80,D0
	EXT.W	D0
	ADD.W	D0,D0
	ADDA.W	D0,A0
	MOVE.W	(A0),D0
	BEQ.L	lbC0006C2
	JMP	0(A0,D0.W)

lbW0009D2	dc.w	lbC0009F2-lbW0009D2
lbW0009D4	dc.w	lbC000A0E-lbW0009D4
lbW0009D6	dc.w	lbC000A18-lbW0009D6
lbW0009D8	dc.w	lbC000A94-lbW0009D8
lbW0009DA	dc.w	lbC000AA6-lbW0009DA
lbW0009DC	dc.w	lbC000AB8-lbW0009DC
lbW0009DE	dc.w	lbC000ACA-lbW0009DE
lbW0009E0	dc.w	lbC000ACE-lbW0009E0
lbW0009E2	dc.w	lbC000ADA-lbW0009E2
lbW0009E4	dc.w	lbC000AE6-lbW0009E4
lbW0009E6	dc.w	lbC000AEE-lbW0009E6
lbW0009E8	dc.w	lbC000B02-lbW0009E8
lbW0009EA	dc.w	lbC000B0A-lbW0009EA
lbW0009EC	dc.w	lbC000B28-lbW0009EC
	dc.w	0
	dc.w	0

lbC0009F2
;	BCLR	#8,D7
;	BEQ.L	lbC000A04
;	MOVE.B	D0,-$5E7
;	MOVE.W	D0,lbW000024
lbC000A04	MOVEQ	#0,D7
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	BRA.L	lbC0008BE

lbC000A0E	MOVE.B	(A2),D0
	EXT.W	D0
	ADDA.W	D0,A2
	BRA.L	lbC0006C2

lbC000A18	MOVEA.L	10(A1),A2
	MOVE.B	-1(A2),D0
	SUBQ.B	#1,14(A1)
	BNE.L	lbC000A80
	MOVE.B	#1,14(A1)
	MOVE.B	#0,$41(A1)
lbC000A34	MOVE.B	(A2)+,D0
	BPL.L	lbC000A80
	ANDI.B	#$7F,D0
	BEQ.S	lbC0009F2
	CMPI.B	#$7F,D0
	BNE.S	lbC000A5C
	MOVE.B	(A2)+,D0
	MOVE.L	A2,10(A1)
;	LEA	lbL00138A(PC),A2

	move.l	lbL00138A(PC),A2			; extra

	EXT.W	D0
	ADD.W	D0,D0
	ADDA.W	D0,A2
	ADDA.W	(A2),A2
	BRA.L	lbC0006C2

lbC000A5C	SUBQ.B	#1,D0
	BNE.L	lbC000A6A
	MOVE.B	(A2),D0
	EXT.W	D0
	ADDA.W	D0,A2

	bsr.w	SongEndTest

	BRA.S	lbC000A34

lbC000A6A	SUBQ.B	#1,D0
	BNE.L	lbC000A76
	MOVE.B	(A2)+,14(A1)
	BRA.S	lbC000A34

lbC000A76	SUBQ.B	#1,D0
	BNE.S	lbC000A34
	MOVE.B	(A2)+,$41(A1)
	BRA.S	lbC000A34

lbC000A80	MOVE.L	A2,10(A1)
;	LEA	lbL001296(PC),A2

	move.l	lbL001296(PC),A2

	EXT.W	D0
	ADD.W	D0,D0
	ADDA.W	D0,A2
	ADDA.W	(A2),A2
	BRA.L	lbC0006C2

lbC000A94	MOVEQ	#7,D0
	AND.B	$47(A1),D0
	MOVE.B	D0,15(A1)
	BCLR	#5,D7
	BRA.L	lbC0006C2

lbC000AA6	MOVEQ	#$38,D0
	AND.B	$47(A1),D0
	MOVE.B	D0,15(A1)
	BSET	#5,D7
	BRA.L	lbC0006C2

lbC000AB8	MOVEQ	#$3F,D0
	AND.B	$47(A1),D0
	MOVE.B	D0,15(A1)
	BSET	#5,D7
	BRA.L	lbC0006C2

lbC000ACA	BRA.L	lbC000740

lbC000ACE	BCLR	#3,D7
	CLR.B	$40(A1)
	BRA.L	lbC000740

lbC000ADA	MOVE.B	(A2)+,$3E(A1)
	BSET	#6,D7
	BRA.L	lbC0006C2

lbC000AE6	BCLR	#6,D7
	BRA.L	lbC0006C2

lbC000AEE	BSET	#0,D7
	BCLR	#1,D7
	MOVE.B	(A2)+,$10(A1)
	MOVE.B	(A2)+,$11(A1)
	BRA.L	lbC0006C2

lbC000B02	BCLR	#0,D7
	BRA.L	lbC0006C2

lbC000B0A	BSET	#2,D7
	BCLR	#1,D7
;	LEA	lbL002D7C(PC),A0

	move.l	lbL002D7C(PC),A0

	MOVEQ	#0,D0
	MOVE.B	(A2)+,D0
	ADD.W	D0,D0
	ADDA.W	D0,A0
	ADDA.W	(A0),A0
	MOVE.L	A0,$28(A1)
	BRA.L	lbC0006C2

lbC000B28	BCLR	#7,D7		; removed, never (?) uses digi samples for ST music
;	BTST	#8,D7
;	BNE.L	lbC000B3E
;	TST.W	lbW000024
;	BNE.L	lbC000B82
;lbC000B3E	MOVE.B	#0,-$5E7
;	LEA	lbL002FE4(PC),A0
;	MOVE.B	(A2)+,D0
;	EXT.W	D0
;	ASL.W	#2,D0
;	ADDA.W	D0,A0
;	MOVEM.L	(A0),D0/D1
;	ADD.L	A0,D0
;	LEA	4(A0,D1.L),A0
;	MOVEM.L	D0/A0,lbL000026
;	MOVE.W	$48(A1),lbW000024
;	MOVE.B	(A2)+,-$5E1
;	LEA	lbC000B88(PC),A0
;	MOVE.L	A0,$134
;	MOVE.B	(A2)+,-$5E7
;	BSET	#8,D7
;	BRA.L	lbC000740

lbC000B82	ADDQ.L	#3,A2
	BRA.L	lbC000ACE

;lbC000B88	MOVE.W	#$700,-$7DC0
;	MOVEM.L	D0/A0/A1,-(SP)
;	LEA	lbW000024(PC),A0
;	MOVE.W	(A0)+,D0
;	MOVEA.L	(A0)+,A1
;	CMPA.L	(A0),A1
;	BEQ.L	lbC000BAE
;	MOVE.B	(A1),D0
;	ANDI.B	#15,D0
;	LEA	lbC000BC8(PC),A1
;	MOVE.L	A1,$134
;lbC000BAE	LEA	-$7800,A0
;	MOVEP.W	D0,0(A0)
;	MOVEM.L	(SP)+,D0/A0/A1
;	BCLR	#5,-$5F1
;	MOVE.W	#$777,-$7DC0
;	RTE

;lbC000BC8	MOVE.W	#$700,-$7DC0
;	MOVEM.L	D0/A0/A1,-(SP)
;	LEA	lbC000B88(PC),A0
;	MOVE.L	A0,$134
;	LEA	lbW000024(PC),A0
;	MOVE.W	(A0)+,D0
;	MOVEA.L	(A0),A1
;	MOVE.B	(A1)+,D0
;	MOVE.L	A1,(A0)
;	LSR.B	#4,D0
;	LEA	-$7800,A0
;	MOVEP.W	D0,0(A0)
;	MOVEM.L	(SP)+,D0/A0/A1
;	BCLR	#5,-$5F1
;	MOVE.W	#$777,-$7DC0
;	RTE

lbW000C02	dc.w	$EF8
	dc.w	$E10
	dc.w	$D60
	dc.w	$C80
	dc.w	$BD8
	dc.w	$B28
	dc.w	$A88
	dc.w	$9F0
	dc.w	$960
	dc.w	$8E0
	dc.w	$858
	dc.w	$7E0
	dc.w	$77C
	dc.w	$708
	dc.w	$6B0
	dc.w	$640
	dc.w	$5EC
	dc.w	$594
	dc.w	$544
	dc.w	$4F8
	dc.w	$4B0
	dc.w	$470
	dc.w	$42C
	dc.w	$3F0
	dc.w	$3BE
	dc.w	$384
	dc.w	$358
	dc.w	$320
	dc.w	$2F6
	dc.w	$2CA
	dc.w	$2A2
	dc.w	$27C
	dc.w	$258
	dc.w	$238
	dc.w	$216
	dc.w	$1F8
	dc.w	$1DF
	dc.w	$1C2
	dc.w	$1AC
	dc.w	$190
	dc.w	$17B
	dc.w	$165
	dc.w	$151
	dc.w	$13E
	dc.w	$12C
	dc.w	$11C
	dc.w	$10B
	dc.w	$FC
	dc.w	$EF
	dc.w	$E1
	dc.w	$D6
	dc.w	$C8
	dc.w	$BD
	dc.w	$B2
	dc.w	$A8
	dc.w	$9F
	dc.w	$96
	dc.w	$8E
	dc.w	$85
	dc.w	$7E
	dc.w	$77
	dc.w	$70
	dc.w	$6B
	dc.w	$64
	dc.w	$5E
	dc.w	$59
	dc.w	$54
	dc.w	$4F
	dc.w	$4B
	dc.w	$47
	dc.w	$42
	dc.w	$3F
	dc.w	$3B
	dc.w	$38
	dc.w	$35
	dc.w	$32
	dc.w	$2F
	dc.w	$2C
	dc.w	$2A
	dc.w	$27
	dc.w	$25
	dc.w	$23
	dc.w	$21
	dc.w	$1F
	dc.w	$1D
	dc.w	$1C
	dc.w	$1A
	dc.w	$19
	dc.w	$17
	dc.w	$16
	dc.w	$15
	dc.w	$13
	dc.w	$12
	dc.w	$11
	dc.w	$10
lbL000CC0
	dc.l	0
lbL000D22
	dc.l	0
lbL000E5A
	dc.l	0
lbL00116C
	dc.l	0
lbL00119A
	dc.l	0
lbL00123E
	dc.l	0
lbL001296
	dc.l	0
lbL00138A
	dc.l	0
lbL002D7C
	dc.l	0
;lbL002E32
;	dc.l	0
lbL002FE4
	dc.l	0

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
Noise1
	ds.b	1024
Noise2
	ds.b	16384
Pulse2
	ds.b	2
Pulse1
	ds.b	2
Empty
	ds.b	2
