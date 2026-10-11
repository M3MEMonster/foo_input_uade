	******************************************************
	****           Sierra AGI replayer for     	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include 'exec/exec_lib.i'
	include 'dos/dos_lib.i'
	include	'intuition/intuition.i'
	include	'intuition/intuition_lib.i'
	include	'intuition/screens.i'
	include 'libraries/gadtools.i'
	include 'libraries/gadtools_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: Sierra AGI player module V2.0 (14 Jan 2006)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!0
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	DTP_Config,Config
	dc.l	DTP_UserConfig,UserConfig
	dc.l	EP_Flags,EPB_Save!EPB_ModuleInfo!EPB_Songend!EPB_Packable!EPB_Restart
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	0

PlayerName
	dc.b	'Sierra AGI',0
Creator
	dc.b	"(c) 1986-88 by Sierra On-Line,",10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'AGI.',0
Text
	dc.b	'Player is now using V.'
Type
	dc.b	'1 replay!',0
Text2
	dc.b	'SFX file loaded!',0
CfgPath1
	dc.b	'Configs/EP-Sierra_AGI.cfg',0
CfgPath2
	dc.b	'EnvArc:EaglePlayer/EP-Sierra_AGI.cfg',0
CfgPath3
	dc.b	'Env:EaglePlayer/EP-Sierra_AGI.cfg',0
	even
ModulePtr
	dc.l	0
Timer
	dc.w	0
Repeat
	dc.w	0
PlayType
	dc.w	0
UsedType
	dc.w	0

*------------------------------ Amplifier Tags ---------------------------*
EagleBase	dc.l	0
AudTagliste	dc.l	EPAMT_NumStructs,4
		dc.l	EPAMT_AudioStructs,AudStruct0
		dc.l	EPAMT_Flags
Aud_NoteFlags	dc.l	0
AudStruct0	ds.b	AS_Sizeof*4

***************************************************************************
****************************** EP_InitAmplifier ***************************
***************************************************************************

InitAudstruct
	moveq	#EPAMB_WaitForStruct!EPAMB_Direct!EPAMB_8Bit,d7
	moveq	#0,d0
	jsr	ENPP_GetListData(a5)
	tst.l	d0
	beq.s	.Error

	move.l	a0,a1
	move.l	4,a6
	jsr	_LVOTypeOfMem(a6)
	btst	#1,d0
	beq.s	.NoChip
	or.w	#EPAMB_ChipRam,d7
.NoChip
	lea	AudStruct0,a0		;Audio Struktur vorbereiten
	move.l	d7,Aud_NoteFlags-AudStruct0(a0)
	lea	(a0),a1
	move.w	#AS_Sizeof*4-1,d0
.Clr
	clr.b	(a1)+
	dbf	d0,.Clr

	move.w	#01,AS_LeftRight(a0)			;1. Kanal links
	move.w	#-1,AS_LeftRight+AS_Sizeof*1(a0)	;2. Kanal rechts
	move.w	#-1,AS_LeftRight+AS_Sizeof*2(a0)	;3. Kanal rechts
	move.w	#01,AS_LeftRight+AS_Sizeof*3(a0)	;4. Kanal links

	lea	AudTagliste(pc),a0
	move.l	a0,EPG_AmplifierTagList(a5)
	moveq	#0,d0
	rts
.Error
	moveq	#EPR_NoModuleLoaded,d0
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Volume value
PokeVol
	movem.l	D1/A5,-(SP)
	move.w	A4,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
PokeAdr
	movem.l	D1/A5,-(SP)
	move.w	A4,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Length value
PokeLen
	movem.l	D1/A5,-(SP)
	move.w	A4,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	and.l	#$FFFF,D0
	jsr	ENPP_PokeLen(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Period value
PokePer
	movem.l	D1/A5,-(SP)
	move.w	A4,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokePer(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Bitmask
PokeDMA
	movem.l	D0/D1/A5,-(SP)
	move.w	D0,D1
	and.w	#$8000,D0	;D0.w neg=enable ; 0/pos=disable
	and.l	#15,D1		;D1 = Mask (LONG !!)
	move.l	EagleBase(PC),A5
	jsr	ENPP_DMAMask(a5)
	movem.l	(SP)+,D0/D1/A5
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
	dc.l	WA_InnerWidth,140
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
	dc.b	'Sierra AGI',0

MXLabelText0
	dc.b	'V.1',0
MXLabelText1
	dc.b	'V.2',0

GadgetText0
	dc.b	'Set replay type:',0
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
	lea	CfgPath1(PC),A0
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
	bne.b	Default
	moveq	#1,D0
	move.b	#'2',D2
	bra.b	PutMode2
Default
	tst.l	D5
	bne.b	SecondTry
	moveq	#0,D1				; default mode
PutMode
	move.b	#'1',D2
	moveq	#0,D0
PutMode2
	lea	PlayType(PC),A0
	move.w	D0,(A0)
	lea	Type(PC),A0
	move.b	D2,(A0)
	lea	TypeBase+2(PC),A0
	move.w	D1,(A0)
	moveq	#0,D0
	rts

LoadBuf
	dc.l	0

***************************************************************************
****************************** EP_NewModuleInfo ***************************
***************************************************************************

NewModuleInfo

CalcSize	=	4
LoadSize	=	12
SongSize	=	20
Voices		=	28
Special		=	36

InfoBuffer
	dc.l	MI_Calcsize,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_Voices,0		;28
	dc.l	MI_SpecialInfo,0	;36
	dc.l	MI_MaxVoices,4
	dc.l	MI_Prefix,Prefix
	dc.l	MI_About,Text
	dc.l	0

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.w	#$800,(A0)
	bne.b	Fault
	move.l	dtg_ChkSize(A5),D2
	move.l	A0,A1
	moveq	#0,D1
	moveq	#2,D3
NextInfo
	addq.l	#2,A1
	move.b	1(A1),D1
	lsl.w	#8,D1
	move.b	(A1),D1
	cmp.l	D1,D2
	ble.b	Fault
	tst.w	D1
	beq.b	Fault
	lea	(A0,D1.L),A2
	cmp.b	#-1,-1(A2)
	bne.b	Fault
	cmp.b	#-1,-2(A2)
	bne.b	Fault
	dbf	D3,NextInfo

	moveq	#0,D0
Fault
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)				; module buffer

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	moveq	#0,D1
	move.b	7(A0),D1
	lsl.w	#8,D1
	move.b	6(A0),D1
	subq.l	#1,D1

AddByte
	addq.l	#1,D1
	cmp.l	D1,D0
	ble.w	Short

	lea	(A0,D1.L),A1
	cmp.b	#-1,(A1)
	bne.b	AddByte
	cmp.b	#-1,1(A1)
	bne.b	AddByte
	addq.l	#2,D1

	move.l	D1,SongSize(A4)
	move.l	D1,CalcSize(A4)

	moveq	#4,D3
	moveq	#0,D1
	moveq	#3,D2
	move.l	A0,A2
CheckVoices
	move.b	1(A2),D1
	lsl.w	#8,D1
	move.b	(A2),D1
	lea	(A0,D1.L),A1
	cmp.b	#-1,(A1)
	bne.b	VoiceUsed
	cmp.b	#-1,1(A1)
	bne.b	VoiceUsed
	subq.l	#1,D3
VoiceUsed
	addq.l	#2,A2
	dbf	D2,CheckVoices
	move.l	D3,Voices(A4)
	moveq	#1,D1
	lea	Text2(PC),A2
	cmp.b	#-1,(A1)
	bne.b	RepeatOn
	cmp.b	#-1,1(A1)
	bne.b	RepeatOn
	moveq	#0,D1
	sub.l	A2,A2
RepeatOn
	move.l	A2,Special(A4)
	lea	Repeat(PC),A0
	move.w	D1,(A0)+
	move.w	(A0)+,(A0)			; copy type
	move.b	#'1',D1
	move.l	TypeBase(PC),D0
	beq.b	V1
	addq.b	#1,D1
V1
	lea	Type(PC),A0
	move.b	D1,(A0)
	lea	Buffy0,A0
	move.l	#$00800080,(A0)
	bsr.w	InitPlay2

	moveq	#0,D0
	rts

Short
	moveq	#EPR_ModuleTooShort,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	move.w	Timer(PC),D0
	bne.b	Done
	move.w	dtg_Timer(A5),D0
	mulu.w	#5,D0
	divu.w	#6,D0			; 60Hz
	lea	Timer(PC),A0
	move.w	D0,(A0)
Done
	move.w	D0,dtg_Timer(A5)
Init
	move.l	ModulePtr(PC),A1
	move.l	A1,A2
	move.w	UsedType(PC),D0
	bne.b	Init2
	bsr.w	InitSong
	bra.w	InitRegs
Init2
	bsr.w	InitSong2
	bra.w	InitRegs2

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

	move.w	UsedType(PC),D1
	bne.b	NoOne
	bsr.w	Play
	bra.b	SkipTwo
NoOne
	bsr.w	Play2
SkipTwo
	move.l	EagleBase(PC),A5
	jsr	ENPP_Amplifier(A5)

	movem.l	(A7)+,D1-A6
	moveq	#0,D0
	rts

SongEnd
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
	rts

***************************************************************************
***************************** Sierra AGI V.1 player ***********************
***************************************************************************

; Player from game "King's Quest II" (c) 1987 by Sierra

;	SECTION	Sierra_KQ200E894,CODE
;lbC00E894	LINK.W	A6,#-4
;	MOVEM.L	D6/D7,-(SP)
;	MOVEQ	#2,D0
;	MOVE.L	D0,-(SP)
;	MOVEQ	#4,D0
;	MOVE.L	D0,-(SP)
;	JSR	lbC010FD0
;	ADDQ.L	#8,SP
;	MOVE.L	D0,lbL00EF4C
;	TST.L	D0
;	BNE.S	lbC00E8BE
;	MOVEM.L	(SP)+,D6/D7
;	UNLK	A6
;	RTS

;lbC00E8BE	MOVEQ	#2,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	#$1000,-(SP)
;	JSR	lbC010FD0
;	ADDQ.L	#8,SP
;	MOVE.L	D0,lbL00EF50
;	TST.L	D0
;	BNE.S	lbC00E8F4
;	MOVEQ	#4,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	lbL00EF4C,-(SP)
;	JSR	lbC010FE8
;	ADDQ.L	#8,SP
;	MOVEM.L	(SP)+,D6/D7
;	UNLK	A6
;	RTS

;lbC00E8F4	MOVEQ	#0,D0
;	MOVEA.L	lbL00EF4C,A0
;	MOVE.B	D0,(A0)
;	MOVEQ	#-$80,D0
;	MOVEA.L	lbL00EF4C,A0
;	MOVE.B	D0,1(A0)
;	CLR.B	2(A0)
;	MOVEA.L	lbL00EF4C,A0
;	MOVE.B	D0,3(A0)
;	MOVEQ	#1,D6
;	MOVEQ	#0,D7
;lbC00E91C	CMPI.W	#$1000,D7
;	BCC.S	lbC00E960
;	MOVE.L	D6,D0
;	BTST	#0,D0
;	BEQ.S	lbC00E938
;	MOVE.L	D6,D0
;	MOVE.L	D6,D1
;	LSR.W	#1,D1
;	EORI.W	#$CA0,D1
;	MOVE.L	D1,D6
;	BRA.S	lbC00E93C

;lbC00E938	MOVE.L	D6,D0
;	LSR.W	#1,D6
;lbC00E93C	MOVE.L	D7,D0
;	ANDI.L	#$FFFF,D0
;	MOVEA.L	lbL00EF50,A0
;	ADDA.L	D0,A0
;	MOVE.L	D6,D0
;	ANDI.L	#$FFFF,D0
;	ANDI.L	#$FF,D0
;	MOVE.B	D0,(A0)
;	ADDQ.W	#1,D7
;	BRA.S	lbC00E91C

;lbC00E960	MOVE.L	#$10003,-(SP)
;	MOVEQ	#$44,D0
;	MOVE.L	D0,-(SP)
;	JSR	lbC010FD0
;	ADDQ.L	#8,SP
;	MOVE.L	D0,lbL00EF3C
;	TST.L	D0
;	BEQ.S	lbC00E9B2
;	MOVE.L	#$10003,-(SP)
;	MOVEQ	#$44,D0
;	MOVE.L	D0,-(SP)
;	JSR	lbC010FD0
;	ADDQ.L	#8,SP
;	MOVE.L	D0,lbL00EF40
;	TST.L	D0
;	BEQ.S	lbC00E9B2
;	CLR.L	-(SP)
;	PEA	AGIsoundport.MSG
;	JSR	lbC010CB0
;	ADDQ.L	#8,SP
;	MOVE.L	D0,lbL00EF48
;	TST.L	D0
;	BNE.S	lbC00E9BE
;lbC00E9B2	BSR.L	lbC00EE22
;	MOVEM.L	(SP)+,D6/D7
;	UNLK	A6
;	RTS

;lbC00E9BE	MOVEM.L	(SP)+,D6/D7
;	UNLK	A6
;	RTS

InitSong
;lbC00E9C6	LINK.W	A6,#-6
;	MOVEM.L	D7/A4/A5,-(SP)
;	MOVEA.L	8(A6),A5
	MOVEQ	#0,D7
lbC00E9D4	CMPI.W	#4,D7
	BCC.S	lbC00EA10
	MOVE.L	D7,D0
	MULS.W	#$16,D0
	MOVEA.L	D0,A0
	ADDA.L	#lbL00EEE4,A0
	MOVEA.L	A0,A4
	MOVE.W	D7,4(A4)
;	MOVE.L	D7,D0
;	MOVE.L	D7,D1
;	EXT.L	D1
;	ASL.L	#2,D1
;	MOVEA.L	A5,A0
;	ADDA.W	#10,A0
;	ADDA.L	D1,A0
;	MOVE.L	(A0),(A4)

	move.b	1(A1),D0
	lsl.w	#8,D0
	move.b	(A1),D0
	addq.l	#2,A1
	lea	(A2,D0.W),A0
	move.l	A0,(A4)

	MOVE.W	#1,6(A4)
	MOVEQ	#1,D1
	MOVE.L	D1,12(A4)
	ADDQ.W	#1,D7
	BRA.S	lbC00E9D4

lbC00EA10
;	TST.L	lbL00EF4C
;	BEQ.S	lbC00EA28
;	TST.L	lbL00EF50
;	BEQ.S	lbC00EA28
;	BSR.L	lbC00EC30
;	TST.L	D0
;	BNE.S	lbC00EA36
;lbC00EA28	JSR	lbC009A7A
;	MOVEM.L	(SP)+,D7/A4/A5
;	UNLK	A6
;	RTS

lbC00EA36	MOVE.W	#4,lbW00EF54
;	MOVEQ	#1,D0
;	MOVE.L	D0,lbL009AA4
;	MOVEM.L	(SP)+,D7/A4/A5
;	UNLK	A6
	RTS

;lbC00EA4E	LINK.W	A6,#-10
;	MOVEM.L	D2/D7/A4/A5,-(SP)
;	MOVEQ	#9,D0
;	MOVE.L	D0,-(SP)
;	JSR	lbC00DB90
;	ADDQ.L	#4,SP
;	TST.L	D0
;	BNE.S	lbC00EA74
;	JSR	lbC009A7A
;	MOVEM.L	(SP)+,D2/D7/A4/A5
;	UNLK	A6
;	RTS

Play
lbC00EA74	LEA	lbL00EEE4(pc),A5
lbC00EA7A	MOVEA.L	A5,A0
	CMPA.L	#lbL00EF3C,A0
	BCC.L	lbC00EB8A
	TST.L	12(A0)
	BEQ.L	lbC00EB82
	MOVEA.L	(A5),A4
	MOVE.W	6(A5),D0
	SUBQ.W	#1,D0
	MOVE.W	D0,6(A5)
	TST.W	D0
	BNE.L	lbC00EB82
	MOVE.B	(A4),D1
	ANDI.W	#$FF,D1
	MOVE.W	D1,6(A5)
	ADDQ.L	#1,A4
	MOVEQ	#0,D0
	MOVE.B	(A4),D0
	ADDQ.L	#1,A4
	ASL.L	#8,D0
	MOVEQ	#0,D2
	MOVE.W	6(A5),D2
	ADD.L	D0,D2
	MOVE.W	D2,6(A5)
	ADDQ.W	#1,D2
	BNE.S	lbC00EADE
	MOVE.W	lbW00EF54(pc),D0
	SUBQ.W	#1,D0
	MOVE.W	D0,lbW00EF54
	MOVE.L	A5,-(SP)
	BSR.L	lbC00ED9E
	ADDQ.L	#4,SP
	BRA.L	lbC00EB82

lbC00EADE	MOVE.W	4(A5),D0
	SUBQ.W	#3,D0
	BNE.S	lbC00EB22
	ADDQ.L	#1,A4
	MOVEQ	#0,D0
	MOVE.B	(A4),D0
	ADDQ.L	#1,A4
	ANDI.L	#3,D0
	CMPI.L	#4,D0
	BCC.S	lbC00EB56
	ASL.L	#1,D0
	JMP	lbC00EB02(PC,D0.L)

lbC00EB02	BRA.S	lbC00EB0A

	BRA.S	lbC00EB12

	BRA.S	lbC00EB1A

	BRA.S	lbC00EB1A

lbC00EB0A	MOVE.W	#$200,8(A5)
	BRA.S	lbC00EB56

lbC00EB12	MOVE.W	#$400,8(A5)
	BRA.S	lbC00EB56

lbC00EB1A	MOVE.W	#$800,8(A5)
	BRA.S	lbC00EB56

lbC00EB22	MOVEQ	#0,D0
	MOVE.B	(A4),D0
	ADDQ.L	#1,A4
	ANDI.L	#$3F,D0
	MOVEQ	#10,D1
	ASL.L	D1,D0
	MOVE.W	D0,8(A5)
	MOVEQ	#0,D1
	MOVE.B	(A4),D1
	ADDQ.L	#1,A4
	ANDI.L	#15,D1
	ASL.L	#6,D1
	MOVEQ	#0,D2
	MOVE.W	8(A5),D2
	OR.L	D1,D2
	MOVE.W	D2,8(A5)
	LSR.W	#2,D2
	MOVE.W	D2,8(A5)
lbC00EB56	MOVEQ	#0,D0
	MOVE.B	(A4),D0
	ADDQ.L	#1,A4
	ANDI.L	#15,D0
	MOVE.L	D0,D7
	MOVEQ	#15,D0
	SUB.W	D7,D0
	ASL.W	#6,D0
	ANDI.L	#$FFFF,D0
	DIVU.W	#15,D0
	MOVE.W	D0,10(A5)
	MOVE.L	A4,(A5)
	MOVE.L	A5,-(SP)
	BSR.L	lbC00EBDA
	ADDQ.L	#4,SP
lbC00EB82	ADDA.W	#$16,A5
	BRA.L	lbC00EA7A

lbC00EB8A	MOVE.W	lbW00EF54(pc),D0
	TST.W	D0
	BNE.S	lbC00EB9A
;	JSR	lbC009A7A

	bsr.w	SongEnd
	move.w	Repeat(PC),D0
	bne.b	NoRepeat
	bsr.w	Init
NoRepeat
lbC00EB9A
;	MOVEM.L	(SP)+,D2/D7/A4/A5
;	UNLK	A6
	RTS

;lbC00EBA2	LINK.W	A6,#-4
;	MOVEM.L	A5,-(SP)
;	CLR.L	lbL009AA4
;	LEA	lbL00EEE4,A5
;lbC00EBB6	MOVEA.L	A5,A0
;	CMPA.L	#lbL00EF3C,A0
;	BCC.S	lbC00EBCE
;	MOVE.L	A0,-(SP)
;	BSR.L	lbC00ED9E
;	ADDQ.L	#4,SP
;	ADDA.W	#$16,A5
;	BRA.S	lbC00EBB6

;lbC00EBCE	BSR.L	lbC00EDBC
;	MOVEM.L	(SP)+,A5
;	UNLK	A6
;	RTS

lbC00EBDA	LINK.W	A6,#-4
	MOVEM.L	A4/A5,-(SP)
	MOVEA.L	8(A6),A5
	MOVEA.L	$12(A5),A4
	MOVE.W	4(A5),D0
	SUBQ.W	#3,D0
	BNE.S	lbC00EC00
;	MOVE.L	lbL00EF50(pc),(A4)		; address
;	MOVE.W	#$800,4(A4)			; length

	move.l	D0,-(SP)
	move.l	lbL00EF50(PC),D0
	bsr.w	PokeAdr
	move.w	#$800,D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	BRA.S	lbC00EC0C

lbC00EC00
;	MOVE.L	lbL00EF4C(pc),(A4)		; address
;	MOVE.W	#2,4(A4)			; length

	move.l	D0,-(SP)
	move.l	lbL00EF4C(PC),D0
	bsr.w	PokeAdr
	moveq	#2,D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

lbC00EC0C
;	MOVE.W	8(A5),6(A4)			; period
;	MOVE.W	10(A5),8(A4)			; volume

	move.l	D0,-(SP)
	move.w	8(A5),D0
	bsr.w	PokePer
	move.w	10(A5),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	MOVE.W	$10(A5),D0
	ORI.W	#$8000,D0
;	MOVE.W	D0,$DFF096			; DMA

	bsr.w	PokeDMA

	MOVEM.L	(SP)+,A4/A5
	UNLK	A6
	RTS

;lbC00EC2E	RTS

;lbC00EC30	LINK.W	A6,#-4
;	MOVEM.L	A5,-(SP)
;	MOVEQ	#0,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	lbL00EF3C,-(SP)
;	MOVE.L	D0,-(SP)
;	PEA	audiodevice.MSG
;	JSR	lbC01110C
;	LEA	$10(SP),SP
;	TST.L	D0
;	BEQ.S	lbC00EC62
;	MOVEQ	#0,D0
;	MOVEM.L	(SP)+,A5
;	UNLK	A6
;	RTS

;lbC00EC62	MOVEA.L	lbL00EF3C,A0
;	MOVE.L	$14(A0),lbL00EF44
;	MOVE.B	#$D8,9(A0)
;	MOVEA.L	lbL00EF3C,A0
;	MOVE.L	lbL00EF48,14(A0)
;	MOVEA.L	lbL00EF3C,A0
;	MOVE.W	#$20,$1C(A0)
;	MOVEA.L	lbL00EF3C,A0
;	MOVE.B	#$40,$1E(A0)
;	MOVEA.L	lbL00EF3C,A0
;	MOVE.L	#AGIsoundport.MSG0,$22(A0)
;	MOVEQ	#1,D0
;	MOVEA.L	lbL00EF3C,A0
;	MOVE.L	D0,$26(A0)
;	MOVE.L	lbL00EF3C,-(SP)
;	JSR	lbC010C88
;	ADDQ.L	#4,SP
;	MOVE.L	lbL00EF3C,-(SP)
;	JSR	lbC01117C
;	ADDQ.L	#4,SP
;	TST.L	D0
;	BEQ.S	lbC00ECE4
;	BSR.L	lbC00EDBC
;	MOVEQ	#0,D0
;	MOVEM.L	(SP)+,A5
;	UNLK	A6
;	RTS

;lbC00ECE4	MOVEA.L	lbL00EF40,A0
;	MOVE.L	lbL00EF48,14(A0)
;	MOVEA.L	lbL00EF40,A0
;	MOVE.L	lbL00EF44,$14(A0)
;	MOVEA.L	lbL00EF3C,A0
;	MOVEA.L	lbL00EF40,A1
;	MOVE.L	$18(A0),$18(A1)
;	MOVEA.L	lbL00EF40,A0
;	MOVE.W	#13,$1C(A0)
;	MOVEA.L	lbL00EF3C,A0
;	MOVEA.L	lbL00EF40,A1
;	MOVE.W	$20(A0),$20(A1)
;	MOVE.L	lbL00EF40,-(SP)
;	JSR	lbC011154
;	ADDQ.L	#4,SP
;	MOVE.L	lbL00EF40,-(SP)
;	JSR	lbC011168
;	ADDQ.L	#4,SP
;	TST.L	D0
;	BEQ.S	lbC00ED5E
;	BSR.L	lbC00EDBC
;	MOVEQ	#0,D0
;	MOVEM.L	(SP)+,A5
;	UNLK	A6
;	RTS

InitRegs
lbC00ED5E	LEA	lbL00EEE4(pc),A5
lbC00ED64	MOVEA.L	A5,A0
	CMPA.L	#lbL00EF3C,A0
	BCC.S	lbC00ED94
	MOVE.W	4(A0),D0
	MOVEQ	#1,D1
	ASL.W	D0,D1
	MOVE.W	D1,$10(A0)
	MOVE.W	4(A0),D0
	EXT.L	D0
	ASL.L	#4,D0
	MOVEA.L	D0,A1
	ADDA.L	#$DFF0A0,A1
	MOVE.L	A1,$12(A0)
	ADDA.W	#$16,A5
	BRA.S	lbC00ED64

lbC00ED94
;	MOVEQ	#1,D0
;	MOVEM.L	(SP)+,A5
;	UNLK	A6
	RTS

lbC00ED9E	LINK.W	A6,#0
	MOVEA.L	8(A6),A0
	TST.L	12(A0)
	BEQ.S	lbC00EDB8
	CLR.L	12(A0)
;	MOVE.W	$10(A0),$DFF096			; DMA

	move.l	D0,-(SP)
	move.w	$10(A0),D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

lbC00EDB8	UNLK	A6
	RTS

;lbC00EDBC	TST.L	lbL00EF44
;	BEQ.S	lbC00EDEC
;	MOVEA.L	lbL00EF3C,A0
;	MOVE.W	#9,$1C(A0)
;	MOVE.L	lbL00EF3C,-(SP)
;	JSR	lbC011140
;	ADDQ.L	#4,SP
;	MOVE.L	lbL00EF3C,-(SP)
;	JSR	lbC01112C
;	ADDQ.L	#4,SP
;lbC00EDEC	SUBA.L	A0,A0
;	MOVE.L	A0,lbL00EF44
;	MOVE.L	A0,-(SP)
;	MOVEQ	#$44,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	lbL00EF3C,-(SP)
;	JSR	lbC00A598
;	LEA	12(SP),SP
;	CLR.L	-(SP)
;	MOVEQ	#$44,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	lbL00EF40,-(SP)
;	JSR	lbC00A598
;	LEA	12(SP),SP
;	RTS

;lbC00EE22	TST.L	lbL00EF4C
;	BEQ.S	lbC00EE42
;	MOVEQ	#4,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	lbL00EF4C,-(SP)
;	JSR	lbC010FE8
;	ADDQ.L	#8,SP
;	CLR.L	lbL00EF4C
;lbC00EE42	TST.L	lbL00EF50
;	BEQ.S	lbC00EE64
;	MOVE.L	#$1000,-(SP)
;	MOVE.L	lbL00EF50,-(SP)
;	JSR	lbC010FE8
;	ADDQ.L	#8,SP
;	CLR.L	lbL00EF50
;lbC00EE64	TST.L	lbL00EF48
;	BEQ.S	lbC00EE80
;	MOVE.L	lbL00EF48,-(SP)
;	JSR	lbC010D4C
;	ADDQ.L	#4,SP
;	CLR.L	lbL00EF48
;lbC00EE80	TST.L	lbL00EF40
;	BEQ.S	lbC00EEA0
;	MOVEQ	#$44,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	lbL00EF40,-(SP)
;	JSR	lbC010FE8
;	ADDQ.L	#8,SP
;	CLR.L	lbL00EF40
;lbC00EEA0	TST.L	lbL00EF3C
;	BEQ.S	lbC00EEC0
;	MOVEQ	#$44,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	lbL00EF3C,-(SP)
;	JSR	lbC010FE8
;	ADDQ.L	#8,SP
;	CLR.L	lbL00EF3C
;lbC00EEC0	RTS

;	dc.w	0

;	SECTION	Sierra_KQ200EEC4,DATA
;AGIsoundport.MSG0	dc.b	15
;AGIsoundport.MSG	dc.b	'AGI-sound-port',0
;audiodevice.MSG	dc.b	'audio.device',0,0
;	dc.w	0

;	SECTION	Sierra_KQ200EEE4,BSS
lbL00EEE4	ds.l	$16
lbL00EF3C
;	ds.l	1
;lbL00EF40	ds.l	1
;lbL00EF44	ds.l	1
;lbL00EF48	ds.l	1
lbL00EF4C	dc.l	Buffy0
lbL00EF50	dc.l	Buffy2
lbW00EF54	ds.w	2

***************************************************************************
***************************** Sierra AGI V.2 player ***********************
***************************************************************************

; Player from "Manhunter I" (c) 1988 Sierra On-Line

;lbC009B4C	MOVEQ	#$1A,D0
;	MOVE.L	D0,-(SP)
;	JSR	_GetMem
;	ADDQ.L	#4,SP
;	MOVEA.L	D0,A5
;	MOVEA.L	_prevSnd,A0
;	MOVE.L	A5,(A0)
;	CLR.L	(A5)
;lbC009B64	MOVEQ	#0,D0
;	MOVE.W	10(A6),D0
;	MOVE.L	D0,-(SP)
;	MOVEQ	#3,D1
;	MOVE.L	D1,-(SP)
;	JSR	_AddScript
;	ADDQ.L	#8,SP
;	MOVE.W	10(A6),D0
;	MOVE.W	D0,4(A5)
;	MOVEQ	#0,D1
;	MOVE.W	10(A6),D1
;	CLR.L	-(SP)
;	MOVE.L	D1,-(SP)
;	MOVEQ	#3,D0
;	MOVE.L	D0,-(SP)
;	JSR	_GetResource
;	LEA	12(SP),SP
;	MOVE.L	D0,6(A5)			; ModulePtr
;	CLR.W	-10(A6)
;	MOVEA.L	D0,A4
lbC009BA2
;	MOVE.W	-10(A6),D0
;	CMPI.W	#4,D0
;	BCC.S	__AllInBack
;	EXT.L	D0
;	ASL.L	#2,D0
;	MOVEA.L	A5,A0
;	ADDA.W	#10,A0
;	ADDA.L	D0,A0
;	MOVEQ	#0,D0
;	MOVE.B	(A4),D0
;	MOVEA.L	6(A5),A1
;	ADDA.L	D0,A1
;	MOVEQ	#0,D0
;	MOVE.B	1(A4),D0
;	ASL.L	#8,D0
;	ADDA.L	D0,A1
;	MOVE.L	A1,(A0)
;	ADDQ.W	#1,-10(A6)
;	ADDQ.L	#2,A4
;	BRA.S	lbC009BA2

;__AllInBack	JSR	_AllInBack
;	MOVE.L	A5,D0
;	MOVEM.L	(SP)+,A4/A5
;	UNLK	A6
;	RTS


;	SECTION	MH00F06C,CODE
;_InitSounds	LINK.W	A6,#-4
;	MOVEM.L	D6/D7,-(SP)
;	MOVEQ	#2,D0
;	MOVE.L	D0,-(SP)
;	MOVEQ	#8,D0
;	MOVE.L	D0,-(SP)
;	JSR	_AllocMem
;	ADDQ.L	#8,SP
;	MOVE.L	D0,_waveForm
;	TST.L	D0
;	BNE.S	lbC00F096
;	MOVEM.L	(SP)+,D6/D7
;	UNLK	A6
;	RTS

;lbC00F096	MOVEQ	#2,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	#$1000,-(SP)
;	JSR	_AllocMem
;	ADDQ.L	#8,SP
;	MOVE.L	D0,_noiseForm
;	TST.L	D0
;	BNE.S	lbC00F0CC
;	MOVEQ	#8,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	_waveForm,-(SP)
;	JSR	_FreeMem
;	ADDQ.L	#8,SP
;	MOVEM.L	(SP)+,D6/D7
;	UNLK	A6
;	RTS

InitPlay2
lbC00F0CC	MOVEQ	#0,D7
lbC00F0CE	CMPI.W	#8,D7
	BCC.S	lbC00F0F2
	MOVE.L	D7,D0
	ANDI.L	#$FFFF,D0
	MOVEA.L	_waveForm(pc),A0
	ADDA.L	D0,A0
	MOVEA.L	D0,A1
	ADDA.L	#_wf,A1
	MOVE.B	(A1),(A0)
	ADDQ.W	#1,D7
	BRA.S	lbC00F0CE

lbC00F0F2	MOVEQ	#1,D6
	MOVEQ	#0,D7
lbC00F0F6	CMPI.W	#$1000,D7
	BCC.S	lbC00F13A
	MOVE.L	D6,D0
	BTST	#0,D0
	BEQ.S	lbC00F112
	MOVE.L	D6,D0
	MOVE.L	D6,D1
	LSR.W	#1,D1
	EORI.W	#$CA0,D1
	MOVE.L	D1,D6
	BRA.S	lbC00F116

lbC00F112	MOVE.L	D6,D0
	LSR.W	#1,D6
lbC00F116	MOVE.L	D7,D0
	ANDI.L	#$FFFF,D0
	MOVEA.L	_noiseForm(pc),A0
	ADDA.L	D0,A0
	MOVE.L	D6,D0
	ANDI.L	#$FFFF,D0
	ANDI.L	#$FF,D0
	MOVE.B	D0,(A0)
	ADDQ.W	#1,D7
	BRA.S	lbC00F0F6

lbC00F13A
;	MOVE.L	#$10003,-(SP)
;	MOVEQ	#$44,D0
;	MOVE.L	D0,-(SP)
;	JSR	_AllocMem
;	ADDQ.L	#8,SP
;	MOVE.L	D0,_allocIOB
;	TST.L	D0
;	BEQ.S	__CleanUpAudio
;	MOVE.L	#$10003,-(SP)
;	MOVEQ	#$44,D0
;	MOVE.L	D0,-(SP)
;	JSR	_AllocMem
;	ADDQ.L	#8,SP
;	MOVE.L	D0,_lockIOB
;	TST.L	D0
;	BEQ.S	__CleanUpAudio
;	CLR.L	-(SP)
;	PEA	AGIsoundport.MSG
;	JSR	_CreatePort
;	ADDQ.L	#8,SP
;	MOVE.L	D0,_soundPort
;	TST.L	D0
;	BNE.S	lbC00F198
;__CleanUpAudio	BSR.L	_CleanUpAudio
;	MOVEM.L	(SP)+,D6/D7
;	UNLK	A6
	RTS

;lbC00F198	MOVEM.L	(SP)+,D6/D7
;	UNLK	A6
;	RTS

InitSong2
;_StartSound	LINK.W	A6,#-6
;	MOVEM.L	D7/A4/A5,-(SP)
;	MOVEA.L	8(A6),A5
	MOVEQ	#0,D7
lbC00F1AE	CMPI.W	#4,D7
	BCC.S	lbC00F1F8
;	MOVE.L	D7,D0
	MOVE.L	D7,D1
	EXT.L	D1
	ASL.L	#5,D1
	MOVEA.L	D1,A0
	ADDA.L	#_chan,A0
	MOVEA.L	A0,A4
	MOVE.W	D7,4(A4)
;	MOVE.L	D7,D1
;	EXT.L	D1
;	ASL.L	#2,D1
;	MOVEA.L	A5,A0
;	ADDA.W	#10,A0
;	ADDA.L	D1,A0
;	MOVE.L	(A0),(A4)

	move.b	1(A1),D0
	lsl.w	#8,D0
	move.b	(A1),D0
	addq.l	#2,A1
	lea	(A2,D0.W),A0
	move.l	A0,(A4)

	MOVE.W	#1,6(A4)
	MOVEQ	#1,D1
	MOVE.L	D1,$16(A4)
	LEA	_theEnvelope,A0
	MOVE.L	A0,$12(A4)
	MOVE.L	A0,14(A4)
	ADDQ.W	#1,D7
	BRA.S	lbC00F1AE

lbC00F1F8
;	TST.L	_waveForm
;	BEQ.S	__StopSnd
;	TST.L	_noiseForm
;	BEQ.S	__StopSnd
;	BSR.L	_AllocateChannels
;	TST.L	D0
;	BNE.S	lbC00F21E
;__StopSnd	JSR	_StopSnd
;	MOVEM.L	(SP)+,D7/A4/A5
;	UNLK	A6
;	RTS

lbC00F21E	MOVE.W	#4,_channelsPlaying
;	MOVEQ	#1,D0
;	MOVE.L	D0,_playSnd
;	MOVEM.L	(SP)+,D7/A4/A5
;	UNLK	A6
	RTS

;_PlayIt	LINK.W	A6,#-8
;	MOVEM.L	D2/A4/A5,-(SP)
;	MOVEQ	#9,D0
;	MOVE.L	D0,-(SP)
;	JSR	lbC00E26A
;	ADDQ.L	#4,SP
;	TST.L	D0
;	BNE.S	lbC00F25C
;	JSR	_StopSnd
;	MOVEM.L	(SP)+,D2/A4/A5
;	UNLK	A6
;	RTS

Play2
lbC00F25C	LEA	_chan,A5
lbC00F262	MOVEA.L	A5,A0
	CMPA.L	#_allocIOB,A0
	BCC.L	lbC00F38E
	TST.L	$16(A0)
	BEQ.L	lbC00F386
	MOVE.W	6(A5),D0
	SUBQ.W	#1,D0
	MOVE.W	D0,6(A5)
	TST.W	D0
	BEQ.S	lbC00F29A
	MOVE.L	A5,-(SP)
	BSR.L	_ApplyEnvelope
	ADDQ.L	#4,SP
;	MOVEA.L	$1C(A5),A0
;	MOVE.W	12(A5),8(A0)			; volume

	move.l	$1C(A5),A4
	move.l	D0,-(SP)
	move.w	12(A5),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	BRA.L	lbC00F386

lbC00F29A	MOVEA.L	(A5),A4
	MOVE.B	(A4),D0
	ANDI.W	#$FF,D0
	MOVE.W	D0,6(A5)
	ADDQ.L	#1,A4
	MOVEQ	#0,D1
	MOVE.B	(A4),D1
	ADDQ.L	#1,A4
	ASL.L	#8,D1
	MOVEQ	#0,D2
	MOVE.W	6(A5),D2
	ADD.L	D1,D2
	MOVE.W	D2,6(A5)
	ADDQ.W	#1,D2
	BNE.S	lbC00F2DA
	MOVE.W	_channelsPlaying,D0
	SUBQ.W	#1,D0
	MOVE.W	D0,_channelsPlaying
	MOVE.L	A5,-(SP)
	BSR.L	_ChannelOff
	ADDQ.L	#4,SP
	BRA.L	lbC00F386

lbC00F2DA	MOVE.W	4(A5),D0
	SUBQ.W	#3,D0
	BNE.S	lbC00F31E
	ADDQ.L	#1,A4
	MOVEQ	#0,D0
	MOVE.B	(A4),D0
	ADDQ.L	#1,A4
	ANDI.L	#3,D0
	CMPI.L	#4,D0
	BCC.S	lbC00F358
	ASL.L	#1,D0
	JMP	lbC00F2FE(PC,D0.L)

lbC00F2FE	BRA.S	lbC00F306

	BRA.S	lbC00F30E

	BRA.S	lbC00F316

	BRA.S	lbC00F316

lbC00F306	MOVE.W	#$200,8(A5)
	BRA.S	lbC00F358

lbC00F30E	MOVE.W	#$400,8(A5)
	BRA.S	lbC00F358

lbC00F316	MOVE.W	#$800,8(A5)
	BRA.S	lbC00F358

lbC00F31E	MOVE.L	14(A5),$12(A5)
	MOVEQ	#0,D0
	MOVE.B	(A4),D0
	ADDQ.L	#1,A4
	ANDI.L	#$3F,D0
	MOVEQ	#9,D1
	ASL.L	D1,D0
	MOVE.W	D0,8(A5)
	MOVEQ	#0,D1
	MOVE.B	(A4),D1
	ADDQ.L	#1,A4
	ANDI.L	#15,D1
	ASL.L	#5,D1
	MOVEQ	#0,D2
	MOVE.W	8(A5),D2
	OR.L	D1,D2
	MOVE.W	D2,8(A5)
	LSR.W	#3,D2
	MOVE.W	D2,8(A5)
lbC00F358	MOVEQ	#0,D0
	MOVE.B	(A4),D0
	ADDQ.L	#1,A4
	ANDI.L	#15,D0
	MOVE.W	D0,10(A5)
	MOVEQ	#15,D1
	SUB.W	D0,D1
	ASL.W	#6,D1
	ANDI.L	#$FFFF,D1
	DIVU.W	#15,D1
	MOVE.W	D1,12(A5)
	MOVE.L	A4,(A5)
	MOVE.L	A5,-(SP)
	BSR.L	_PlayNote
	ADDQ.L	#4,SP
lbC00F386	ADDA.W	#$20,A5
	BRA.L	lbC00F262

lbC00F38E	MOVE.W	_channelsPlaying(pc),D0
	TST.W	D0
	BNE.S	lbC00F39E
;	JSR	_StopSnd

	bsr.w	SongEnd
	move.w	Repeat(PC),D0
	bne.b	NoRepeat2
	bsr.w	Init
NoRepeat2
lbC00F39E
;	MOVEM.L	(SP)+,D2/A4/A5
;	UNLK	A6
	RTS

;_SoundOff	LINK.W	A6,#-4
;	MOVEM.L	A5,-(SP)
;	CLR.L	_playSnd
;	LEA	_chan,A5
;lbC00F3BA	MOVEA.L	A5,A0
;	CMPA.L	#_allocIOB,A0
;	BCC.S	__FreeChannels
;	MOVE.L	A0,-(SP)
;	BSR.L	_ChannelOff
;	ADDQ.L	#4,SP
;	ADDA.W	#$20,A5
;	BRA.S	lbC00F3BA

;__FreeChannels	BSR.L	_FreeChannels
;	MOVEM.L	(SP)+,A5
;	UNLK	A6
;	RTS

_PlayNote	LINK.W	A6,#-4
	MOVEM.L	A4/A5,-(SP)
	MOVEA.L	8(A6),A5
	MOVEA.L	$1C(A5),A4
;	MOVE.W	8(A5),6(A4)			; period

	move.l	D0,-(SP)
	move.w	8(A5),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	MOVE.L	A5,-(SP)
	BSR.S	_ApplyEnvelope
	ADDQ.L	#4,SP
;	MOVE.W	12(A5),8(A4)			; volume

	move.l	D0,-(SP)
	move.w	12(A5),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	MOVE.W	$1A(A5),D0
	ORI.W	#$8000,D0
;	MOVE.W	D0,$DFF096			; DMA

	bsr.w	PokeDMA

	MOVEM.L	(SP)+,A4/A5
	UNLK	A6
	RTS

_ApplyEnvelope	LINK.W	A6,#-4
	MOVEM.L	D7/A5,-(SP)
	MOVEA.L	8(A6),A5
	TST.L	$12(A5)
	BEQ.S	lbC00F46E
	MOVEA.L	$12(A5),A0
	CMPI.L	#$80,(A0)
	BNE.S	lbC00F43A
	CLR.L	$12(A5)
	BRA.S	lbC00F46E

lbC00F43A	MOVEA.L	$12(A5),A0
	ADDQ.L	#4,$12(A5)
	MOVEQ	#0,D0
	MOVE.W	10(A5),D0
	ADD.L	(A0),D0
	MOVE.L	D0,D7
	BGE.S	lbC00F452
	MOVEQ	#0,D7
	BRA.S	lbC00F45C

lbC00F452	CMPI.L	#15,D7
	BLE.S	lbC00F45C
	MOVEQ	#15,D7
lbC00F45C	MOVEQ	#15,D0
	SUB.L	D7,D0
	ASL.L	#6,D0
	MOVEQ	#15,D1
	JSR	lbC0154A0
	MOVE.W	D0,12(A5)
lbC00F46E	MOVEM.L	(SP)+,D7/A5
	UNLK	A6
	RTS

;_ErrBeep	RTS

;_AllocateChannels	LINK.W	A6,#-8
;	MOVEM.L	A4/A5,-(SP)
;	MOVEQ	#0,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	_allocIOB,-(SP)
;	MOVE.L	D0,-(SP)
;	PEA	audiodevice.MSG
;	JSR	_OpenDevice
;	LEA	$10(SP),SP
;	TST.L	D0
;	BEQ.S	lbC00F4AA
;	MOVEQ	#0,D0
;	MOVEM.L	(SP)+,A4/A5
;	UNLK	A6
;	RTS

;lbC00F4AA	MOVEA.L	_allocIOB,A0
;	MOVE.L	$14(A0),_audioDevice
;	MOVE.B	#$D8,9(A0)
;	MOVEA.L	_allocIOB,A0
;	MOVE.L	_soundPort,14(A0)
;	MOVEA.L	_allocIOB,A0
;	MOVE.W	#$20,$1C(A0)
;	MOVEA.L	_allocIOB,A0
;	MOVE.B	#$40,$1E(A0)
;	MOVEA.L	_allocIOB,A0
;	MOVE.L	#_allocationMap,$22(A0)
;	MOVEQ	#1,D0
;	MOVEA.L	_allocIOB,A0
;	MOVE.L	D0,$26(A0)
;	MOVE.L	_allocIOB,-(SP)
;	JSR	_BeginIO
;	ADDQ.L	#4,SP
;	MOVE.L	_allocIOB,-(SP)
;	JSR	_WaitIO
;	ADDQ.L	#4,SP
;	TST.L	D0
;	BEQ.S	lbC00F52C
;	BSR.L	_FreeChannels
;	MOVEQ	#0,D0
;	MOVEM.L	(SP)+,A4/A5
;	UNLK	A6
;	RTS

;lbC00F52C	MOVEA.L	_lockIOB,A0
;	MOVE.L	_soundPort,14(A0)
;	MOVEA.L	_lockIOB,A0
;	MOVE.L	_audioDevice,$14(A0)
;	MOVEA.L	_allocIOB,A0
;	MOVEA.L	_lockIOB,A1
;	MOVE.L	$18(A0),$18(A1)
;	MOVEA.L	_lockIOB,A0
;	MOVE.W	#13,$1C(A0)
;	MOVEA.L	_allocIOB,A0
;	MOVEA.L	_lockIOB,A1
;	MOVE.W	$20(A0),$20(A1)
;	MOVE.L	_lockIOB,-(SP)
;	JSR	_SendIO
;	ADDQ.L	#4,SP
;	MOVE.L	_lockIOB,-(SP)
;	JSR	_CheckIO
;	ADDQ.L	#4,SP
;	TST.L	D0
;	BEQ.S	lbC00F5A6
;	BSR.L	_FreeChannels
;	MOVEQ	#0,D0
;	MOVEM.L	(SP)+,A4/A5
;	UNLK	A6
;	RTS

InitRegs2
lbC00F5A6	LEA	_chan(pc),A5
lbC00F5AC	MOVEA.L	A5,A0
	CMPA.L	#_allocIOB,A0
	BCC.S	lbC00F600
	MOVE.W	4(A0),D0
	MOVEQ	#1,D1
	ASL.W	D0,D1
	MOVE.W	D1,$1A(A0)
	MOVE.W	4(A0),D0
	EXT.L	D0
	ASL.L	#4,D0
	MOVEA.L	D0,A1
	ADDA.L	#$DFF0A0,A1
	MOVE.L	A1,$1C(A0)
	MOVEA.L	A1,A4
	MOVE.W	4(A0),D0
	SUBQ.W	#3,D0
	BNE.S	lbC00F5EE
;	MOVE.L	_noiseForm(pc),(A4)		; address
;	MOVE.W	#$800,4(A4)			; length

	move.l	D0,-(SP)
	move.l	_noiseForm(PC),D0
	bsr.w	PokeAdr
	move.w	#$800,D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	BRA.S	lbC00F5FA

lbC00F5EE
;	MOVE.L	_waveForm(pc),(A4)		; address
;	MOVE.W	#4,4(A4)			; length

	move.l	D0,-(SP)
	move.l	_waveForm(PC),D0
	bsr.w	PokeAdr
	moveq	#4,D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

lbC00F5FA	ADDA.W	#$20,A5
	BRA.S	lbC00F5AC

lbC00F600
;	MOVEQ	#1,D0
;	MOVEM.L	(SP)+,A4/A5
;	UNLK	A6
	RTS

_ChannelOff	LINK.W	A6,#0
	MOVEA.L	8(A6),A0
	TST.L	$16(A0)
	BEQ.S	lbC00F624
	CLR.L	$16(A0)
;	MOVE.W	$1A(A0),$DFF096			; DMA

	move.l	D0,-(SP)
	move.w	$1A(A0),D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

lbC00F624	UNLK	A6
	RTS

;_FreeChannels	TST.L	_audioDevice
;	BEQ.S	lbC00F658
;	MOVEA.L	_allocIOB,A0
;	MOVE.W	#9,$1C(A0)
;	MOVE.L	_allocIOB,-(SP)
;	JSR	_DoIO
;	ADDQ.L	#4,SP
;	MOVE.L	_allocIOB,-(SP)
;	JSR	_CloseDevice
;	ADDQ.L	#4,SP
;lbC00F658	SUBA.L	A0,A0
;	MOVE.L	A0,_audioDevice
;	MOVE.L	A0,-(SP)
;	MOVEQ	#$44,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	_allocIOB,-(SP)
;	JSR	_FillMem
;	LEA	12(SP),SP
;	CLR.L	-(SP)
;	MOVEQ	#$44,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	_lockIOB,-(SP)
;	JSR	_FillMem
;	LEA	12(SP),SP
;	RTS

;_CleanUpAudio	TST.L	_waveForm
;	BEQ.S	lbC00F6AE
;	MOVEQ	#8,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	_waveForm,-(SP)
;	JSR	_FreeMem
;	ADDQ.L	#8,SP
;	CLR.L	_waveForm
;lbC00F6AE	TST.L	_noiseForm
;	BEQ.S	lbC00F6D0
;	MOVE.L	#$1000,-(SP)
;	MOVE.L	_noiseForm,-(SP)
;	JSR	_FreeMem
;	ADDQ.L	#8,SP
;	CLR.L	_noiseForm
;lbC00F6D0	TST.L	_soundPort
;	BEQ.S	lbC00F6EC
;	MOVE.L	_soundPort,-(SP)
;	JSR	_DeletePort
;	ADDQ.L	#4,SP
;	CLR.L	_soundPort
;lbC00F6EC	TST.L	_lockIOB
;	BEQ.S	lbC00F70C
;	MOVEQ	#$44,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	_lockIOB,-(SP)
;	JSR	_FreeMem
;	ADDQ.L	#8,SP
;	CLR.L	_lockIOB
;lbC00F70C	TST.L	_allocIOB
;	BEQ.S	lbC00F72C
;	MOVEQ	#$44,D0
;	MOVE.L	D0,-(SP)
;	MOVE.L	_allocIOB,-(SP)
;	JSR	_FreeMem
;	ADDQ.L	#8,SP
;	CLR.L	_allocIOB
;lbC00F72C	RTS

;	dc.w	0


;	SECTION	MH0154A0,CODE
lbC0154A0	MOVEM.L	D2-D5,-(SP)
	MOVE.L	D1,D5
	BEQ.S	lbC0154DA
	BPL.S	lbC0154AC
	NEG.L	D1
lbC0154AC	MOVE.L	D0,D4
	BEQ.S	lbC0154D8
	BPL.S	lbC0154B4
	NEG.L	D0
lbC0154B4	CLR.L	D2
	MOVEQ	#$1F,D3
lbC0154B8	ASL.L	#1,D0
	ROXL.L	#1,D2
	CMP.L	D1,D2
	BCS.S	lbC0154C4
	SUB.L	D1,D2
	ADDQ.L	#1,D0
lbC0154C4	DBRA	D3,lbC0154B8
	MOVE.L	D2,D1
	EOR.L	D4,D5
	BPL.S	lbC0154D0
	NEG.L	D0
lbC0154D0	EOR.L	D1,D4
	BPL.S	lbC0154DC
	NEG.L	D1
	BRA.S	lbC0154DC

lbC0154D8	CLR.L	D1
lbC0154DA	CLR.L	D0
lbC0154DC	MOVEM.L	(SP)+,D2-D5
	RTS

;	SECTION	MH00F730,DATA
_theEnvelope	dc.l	2
	dc.l	1
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	1
	dc.l	1
	dc.l	1
	dc.l	1
	dc.l	2
	dc.l	2
	dc.l	2
	dc.l	2
	dc.l	2
	dc.l	2
	dc.l	2
	dc.l	2
	dc.l	3
	dc.l	3
	dc.l	3
	dc.l	3
	dc.l	3
	dc.l	3
	dc.l	3
	dc.l	4
	dc.l	4
	dc.l	4
	dc.l	4
	dc.l	4
	dc.l	5
	dc.l	5
	dc.l	5
	dc.l	5
	dc.l	5
	dc.l	6
	dc.l	6
	dc.l	6
	dc.l	6
	dc.l	6
	dc.l	7
	dc.l	7
	dc.l	7
	dc.l	7
	dc.l	7
	dc.l	8
	dc.l	8
	dc.l	8
	dc.l	8
	dc.l	8
	dc.l	9
	dc.l	9
	dc.l	9
	dc.l	9
	dc.l	9
	dc.l	10
	dc.l	10
	dc.l	10
	dc.l	10
	dc.l	10
	dc.l	11
	dc.l	$80
_wf	dc.l	$407F40
	dc.l	$C081C0
;_allocationMap	dc.b	15
;AGIsoundport.MSG	dc.b	'AGI-sound-port',0
;audiodevice.MSG	dc.b	'audio.device',0,0
;	dc.b	0
;	dc.b	0

;	SECTION	MH00F850,BSS
_chan	ds.l	$20
_allocIOB
;	ds.l	1
;_lockIOB	ds.l	1
;_audioDevice	ds.l	1
;_soundPort	ds.l	1
_waveForm	dc.l	Buffy1
_noiseForm	dc.l	Buffy2
_channelsPlaying	ds.w	2

	Section	Buffy,BSS_C

Buffy0
	ds.b	4
Buffy1
	ds.b	8
Buffy2
	ds.b	$1000
