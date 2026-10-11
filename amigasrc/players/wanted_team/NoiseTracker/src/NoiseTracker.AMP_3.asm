	******************************************************
	****           NoiseTracker replayer for	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'
	include 'dos/dos_lib.i'
	include	'intuition/intuition.i'
	include	'intuition/intuition_lib.i'
	include	'intuition/screens.i'
	include 'libraries/gadtools.i'
	include 'libraries/gadtools_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: NoiseTracker player module V2.2 (30 June 2003)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!2
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_NextPatt,NextPattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	DTP_Config,Config
	dc.l	DTP_UserConfig,UserConfig
	dc.l	EP_Flags,EPB_Save!EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
	dc.l	0

PlayerName
	dc.b	'NoiseTracker',0
Creator
	dc.b	'(c) 1991 by Anders Berkeman & Per',10
	dc.b	'Tufvesson, adapted by Wanted Team',0
Prefix
	dc.b	'MOD.',0
Text
	dc.b	'SoundTracker (15 samples) module loaded!!!',0
Text2
	dc.b	'Player is now using Volume Slide as D command!',10,0
Text3
	dc.b	'Player is now using Pattern Break as D command!',10,0
Text4
	dc.b	'Player is now using The Ultimate Soundtracker mode!',10,0
CfgPath1
	dc.b	'Configs/EP-NoiseTracker.cfg',0
CfgPath2
	dc.b	'EnvArc:EaglePlayer/EP-NoiseTracker.cfg',0
CfgPath3
	dc.b	'Env:EaglePlayer/EP-NoiseTracker.cfg',0
	even
ModulePtr
	dc.l	0
Format
	dc.b	0
FormatNow
	dc.b	0
SynthLength
	dc.l	0
SamplesPtr
	dc.l	0
SongName
	ds.b	20
SynthPtr
	dc.l	0
UsedTimer
	dc.l	0
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
	movem.l	D0/D1/A5,-(SP)
	move.w	A5,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
PokeAdr
	movem.l	D0/D1/A5,-(SP)
	move.w	A5,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Length value
PokeLen
	movem.l	D0/D1/A5,-(SP)
	move.w	A5,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	and.l	#$FFFF,D0
	jsr	ENPP_PokeLen(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Period value
PokePer
	movem.l	D0/D1/A5,-(SP)
	move.w	A5,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokePer(A5)
	movem.l	(SP)+,D0/D1/A5
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

	move.w	DCommand+2(PC),CommandTemp

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

SetDCommand
	moveq	#0,D0
	move.w	im_Code(A1),D0			; get Number
	move.w	D0,CommandTemp
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
	move.w	CommandTemp(PC),DCommand+2
ExitConfig
	clr.w	QuitFlag			; quit config
	rts

VisualInfo
	dc.l	0
WindowPtr
	dc.l	0
SaveBuf
	dc.w	'WT'
CommandTemp
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
	dc.w	120,16,17,4
	dc.l	0,PLACETEXT_LEFT
	dc.l	SetDCommand
	dc.l	0

GadArray2
	dc.l	BUTTON_KIND,0
	dc.w	74,45+10,58,14
	dc.l	GadText2,PLACETEXT_IN
	dc.l	SaveConfig
	dc.l	0

GadArray3
	dc.l	BUTTON_KIND,0
	dc.w	8,45+10,58,14			; x/y/wysokosc/dlugosc
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
DCommand
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
	dc.b	'ST15 config',0

MXLabelText0
	dc.b	'Pattern Break',0
MXLabelText1
	dc.b	'Volume Slide ',0
MXLabelText2
	dc.b	'Ultimate ST  ',0

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
	cmp.w	#2,D1
	bls.b	PutMode
Default
	tst.l	D5
	bne.b	SecondTry
	moveq	#0,D1				; default mode
PutMode
	lea	DCommand+2(PC),A0
	move.w	D1,(A0)
	moveq	#0,D0
	rts

LoadBuf
	dc.l	0

***************************************************************************
****************************** EP_PatternInit *****************************
***************************************************************************

PATTERNINFO:
	DS.B	PI_Stripes	; This is the main structure

* Here you store the address of each "stripe" (track) for the current
* pattern so the PI engine can read the data for each row and send it
* to the CONVERTNOTE functino you supply.  The engine determines what
* data needs to be converted by looking at the Pattpos and Modulo fields.

STRIPE1	DS.L	1
STRIPE2	DS.L	1
STRIPE3	DS.L	1
STRIPE4	DS.L	1

* More stripes go here in case you have more than 4 channels.


* Called at various and sundry times (e.g. StartInt, apparently)
* Return PatternInfo Structure in A0
PatternInit
	LEA	PATTERNINFO(PC),A0

	MOVE.W	#4,PI_Voices(A0)	; Number of stripes (MUST be at least 4)
	MOVE.L	#CONVERTNOTE,PI_Convert(A0)
	MOVEQ.L	#16,D0
	MOVE.L	D0,PI_Modulo(A0)	; Number of bytes to next row
	MOVE.W	#64,PI_Pattlength(A0)	; Length of each stripe in rows


	MOVE.W	InfoBuffer+Patterns+2(PC),PI_NumPatts(A0)	; Overall Number of Patterns
	CLR.W	PI_Pattern(A0)		; Current Pattern (from 0)
	CLR.W	PI_Pattpos(A0)		; Current Position in Pattern (from 0)
	CLR.W	PI_Songpos(A0)		; Current Position in Song (from 0)
	MOVE.W	InfoBuffer+Length+2(PC),PI_MaxSongPos(A0)	; Songlengh

	MOVE.W	#6,PI_Speed(A0)		; Default Speed Value

	lea	STRIPE1(PC),A1
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A1)
	rts

* Called by the PI engine to get values for a particular row
CONVERTNOTE:


* The command string is a single character.  It is NOT ASCII, howver.
* The character mapping starts from value 0 and supports letters from A-Z

* $00 ~ '0'
* ...
* $09 ~ '9'
* $0A ~ 'A'
* ...
* $0F ~ 'F'
* $10 ~ 'G'
* etc.


* Routine ripped from the EP Protracker player.
	MOVEQ	#0,D0	; Period? Note?
	MOVEQ	#0,D1	; Sample number
	MOVEQ	#0,D2	; Command string
	MOVEQ	#0,D3	; Command argument
	MOVE.B	(A0),D0
	ANDI.B	#$10,D0
	MOVE.B	2(A0),D1
	LSR.B	#4,D1
	OR.B	D0,D1
	MOVE.W	(A0),D0
	ANDI.W	#$FFF,D0
	MOVE.B	2(A0),D2
	ANDI.W	#15,D2
	MOVE.B	3(A0),D3
	RTS

* Sets some current values for the PatternInfo structure.
* Call this every time something changes (or at least every interrupt).
* You can move these elsewhere if necessary, it is only important that
* you make sure the structure fields are accurate and updated regularly.

PATINFO:
	movem.l	D0/D1/A0/A1,-(SP)
	lea	PATTERNINFO(PC),A0
	move.l	lbW023E9C(PC),D0
	move.w	D0,PI_Songpos(A0)	; Position in Song
	move.l	ModulePtr(PC),A1
	lea	952(A1),A1
	tst.b	FormatNow
	beq.b	New1
	lea	-480(A1),A1
New1
	moveq	#0,D1
	move.b	(A1,D0.W),D1
	move.w	D1,PI_Pattern(A0)	; Current Pattern
	move.l	lbL023EA0(PC),D0
	lsr.l	#4,D0
	move.w	D0,PI_Pattpos(A0)	; Current Position in Pattern
	lea	132(A1),A1
	tst.b	FormatNow
	beq.b	New2
	subq.l	#4,A1
New2
	moveq	#10,D0
	lsl.l	D0,D1
	add.l	D1,A1			; Current Pattern
	move.l	A1,PI_Stripes(A0)	; STRIPE1
	addq.l	#4,A1			; Distance to next stripe
	move.l	A1,PI_Stripes+4(A0)	; STRIPE2
	addq.l	#4,A1
	move.l	A1,PI_Stripes+8(A0)	; STRIPE3
	addq.l	#4,A1
	move.l	A1,PI_Stripes+12(A0)	; STRIPE4
	move.w	lbW023E98+2(PC),PI_Speed(A0)		; Speed Value
	movem.l	(SP)+,D0/D1/A0/A1
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

NextPattern
	lea	lbW023E9C(PC),A0
	move.l	(A0),D0
	addq.b	#1,D0
	cmp.l	InfoBuffer+Length(PC),D0
	beq.b	MaxPos
	move.l	D0,(A0)+
	clr.l	(A0)
MaxPos
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	lea	lbW023E9C(PC),A0
	move.l	(A0),D0
	beq.b	MinPos
	subq.b	#1,D0
	move.l	D0,(A0)+
	clr.l	(A0)
MinPos
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	A2,A1
	lea	20(A2),A2
	move.l	SamplesPtr(PC),A1
	move.l	InfoBuffer+MaxSamples(PC),D5
	subq.l	#1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	moveq	#0,D0
	move.w	22(A2),D0
	add.l	D0,D0
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.l	A2,EPS_SampleName(A3)		; sample name
	move.w	#22,EPS_MaxNameLen(A3)
	cmp.l	#'Mupp',(A2)
	bne.b	NoMupp
	move.w	#USITY_AMSynth,EPS_Type(A3)
	bra.b	SkipRaw
NoMupp
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
SkipRaw
	lea	30(A2),A2
	add.l	D0,A1
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

SynthSamples	=	4
LoadSize	=	12
Samples		=	20
Length		=	28
SamplesSize	=	36
SongSize	=	44
CalcSize	=	52
Author		=	60
Patterns	=	68
MaxSamples	=	76
Special		=	84
About		=	92

InfoBuffer
	dc.l	MI_SynthSamples,0	;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_SamplesSize,0	;36
	dc.l	MI_Songsize,0		;44
	dc.l	MI_Calcsize,0		;52
	dc.l	MI_AuthorName,0		;60
	dc.l	MI_Pattern,0		;68
	dc.l	MI_MaxSamples,31	;76
	dc.l	MI_SpecialInfo,0	;84
	dc.l	MI_About,0		;92
	dc.l	MI_SongName,SongName
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxPattern,64
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	move.l	dtg_ChkSize(A5),D1
	cmp.l	#1024+600,D1
	ble.b	fail
	lea	Format(PC),A3

	cmp.l	#'FEST',1080(A0)		; ID from "Gnomie by Night"
	beq.b	Found
	cmp.l	#'M&K!',1080(A0)
	beq.s	Found
	bra.b	CheckOld
Found
	clr.b	(A3)
FoundOld
	moveq	#0,D0
fail
	rts

CheckOld
	lea	42(A0),A1
	lea	(A0,D1.L),A2
	moveq	#0,D4
	moveq	#0,D5
	moveq	#14,D1
NextSI
	move.w	(A1)+,D2
	bmi.b	fail
	beq.b	NoS
	addq.l	#1,D4
NoS
	tst.w	(A1)
	beq.b	NoVolu
	addq.l	#1,D5
NoVolu
	cmp.w	#64,(A1)+
	bhi.b	fail
	addq.l	#2,A1
	move.w	(A1)+,D3
	bmi.b	fail
	beq.b	NorRep
	cmp.w	#1,D3
	beq.b	NorRep
	cmp.w	D2,D3
	bgt.b	fail
NorRep
	lea	22(A1),A1
	dbf	D1,NextSI
	tst.l	D4
	beq.b	fail
	tst.l	D5
	beq.b	fail
	lea	470(A0),A1
	move.b	(A1)+,D2
	beq.b	fail
	cmp.b	#$80,D2
	bhi.b	fail
	moveq	#127,D1
	cmp.b	#$78,(A1)+
	beq.b	NoUlti
	move.b	D2,D1
	subq.l	#1,D1
NoUlti
	moveq	#0,D2
NextByte1
	move.b	(A1)+,D3
	cmp.b	#$3F,D3
	bhi.b	fail
	cmp.b	D3,D2
	bgt.b	PosMax
	move.b	D3,D2
PosMax
	dbra	D1,NextByte1
	addq.l	#1,D2
	lsl.l	#8,D2
	lsl.l	#2,D2
	lea	600(A0),A1
	move.l	A1,A4
	add.l	D2,A1
	cmp.l	A1,A2
	blt.w	fail
	lea	PeriodEnd(PC),A2
	lea	1624(A0),A0
CheckPer
	move.w	(A4),D1
	bmi.w	fail
	beq.b	PerOK
	lea	PeriodTable(PC),A1
CheckTable
	cmp.w	(A1)+,D1
	beq.b	PerOK
	cmp.l	A1,A2
	bne.b	CheckTable
	bra.w	fail
PerOK
	addq.l	#4,A4
	cmp.l	A4,A0
	bne.b	CheckPer

	st	(A3)
	bra.w	FoundOld

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A3
	move.l	A0,(A3)+			; module buffer
	move.b	(A3)+,(A3)+			; copy format

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	clr.l	About(A4)
	clr.l	Special(A4)
	moveq	#31,D1
	tst.b	-5(A3)
	beq.b	New3
	moveq	#15,D1
	lea	Text(PC),A1
	move.l	A1,Special(A4)
New3
	move.l	D1,MaxSamples(A4)

	lea	20(A0),A1
	moveq	#0,D0
	subq.l	#1,D1
	moveq	#0,D2
	moveq	#0,D3
	moveq	#0,D4
NextSampInfo
	cmp.l	#'Mupp',(A1)
	bne.b	NoSynth
	addq.l	#1,D0
NoSynth
	move.w	22(A1),D2
	beq.b	NoSamp
	addq.l	#1,D3
	add.l	D2,D2
	add.l	D2,D4
NoSamp
	lea	30(A1),A1
	dbf	D1,NextSampInfo
	move.l	D0,SynthSamples(A4)
	move.l	D3,Samples(A4)
	move.l	D4,SamplesSize(A4)
	lsl.l	#8,D0
	lsl.l	#4,D0
	move.l	D0,(A3)+			; SynthLength
	beq.b	NoSynth1
	move.l	#$10002,D1			; cleared chip memory ?
	move.l	4.W,A6
	jsr	_LVOAllocMem(A6)		; Alloc Mem
	tst.l	D0
	beq.b	NoMemory
	move.l	D0,lbL02B20C
	move.l	D0,SynthPtr
NoSynth1
	bsr.w	GetSongSize

	move.l	A2,(A3)+			; SamplesPtr
	move.l	A2,D5
	move.l	ModulePtr(PC),A0
	sub.l	A0,D5
	move.l	D5,SongSize(A4)
	add.l	D4,D5
	cmp.l	LoadSize(A4),D5
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	moveq	#4,D1
	move.l	A0,A1
CopyName
	move.l	(A1)+,(A3)+
	dbf	D1,CopyName
	move.b	950(A0),Length+3(A4)
	tst.b	FormatNow
	beq.b	New4
	move.b	470(A0),Length+3(A4)
New4
	move.l	D5,CalcSize(A4)
	move.l	D3,Patterns(A4)
	bsr.w	InstallSamples

	bsr.b	FindName
	moveq	#0,D0
	rts

NoMemory
	moveq	#EPR_NotEnoughMem,D0
	rts

FindName
	move.l	ModulePtr(PC),A0
	lea	20(A0),A1			; A1 - begin sampleinfo
	move.l	A1,EPG_ARG1(A5)
	moveq	#30,D0				; D0 - length per one sampleinfo
	move.l	D0,EPG_ARG2(A5)
	moveq	#22,D0				; D0 - max. sample name
	move.l	D0,EPG_ARG3(A5)
	move.l	InfoBuffer+MaxSamples(PC),D0	; D0 - max. samples number
	move.l	D0,EPG_ARG4(A5)
	moveq	#4,D0
	move.l	D0,EPG_ARGN(A5)
	jsr	ENPP_FindAuthor(A5)
	move.l	EPG_ARG1(A5),Author(A4)		; output
	rts

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	move.l	SynthLength(PC),D0
	beq.b	SkipFree
	move.l	SynthPtr(PC),A1
	move.l	4.W,A6
	jsr	_LVOFreeMem(A6) 		     ; FreeMem
SkipFree
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	lbW023E9C(PC),D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	lbL024BC8(PC),A0
	lea	20(A0),A2
	lea	lbW024C48(PC),A1
ClearThis
	clr.l	(A0)+
	cmp.l	A0,A1
	bne.b	ClearThis
	move.w	#1,(A2)
	lea	32(A2),A2
	move.w	#2,(A2)
	lea	32(A2),A2
	move.w	#4,(A2)
	lea	32(A2),A2
	move.w	#8,(A2)
	move.l	UsedTimer(PC),D0
	bne.b	TimerOK
	move.w	dtg_Timer(A5),D0
	addq.l	#2,D0
	lsr.w	#2,D0
	move.w	D0,UsedTimer+2
TimerOK
	lea	PATTERNINFO(PC),A1
	moveq	#125,D2
	lea	FormatNow(PC),A2
	tst.b	(A2)
	beq.b	New5
	st	(A2)
	lea	Text3(PC),A0
	move.w	DCommand+2(PC),D1
	beq.b	NewCom
	cmp.w	#1,D1
	bne.b	UST
	move.b	#1,(A2)
	lea	Text2(PC),A0
	bra.b	NewCom
UST
	move.b	#2,(A2)
	lea	Text4(PC),A0
NewCom
	lea	InfoBuffer(PC),A2
	move.l	A0,About(A2)
	move.l	ModulePtr(PC),A0
	moveq	#0,D1
	move.b	471(A0),D1
	cmp.b	#$78,D1
	beq.b	New5
	cmp.b	#31,D1
	bhi.b	BPMOk
	bra.b	New5
BPMOk
	move.l	D1,D2
	mulu.w	#125,D0
	divu.w	D2,D0
New5
	move.w	D0,dtg_Timer(A5)
	move.w	D2,PI_BPM(A1)
	bra.w	InitSong

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

; called 4 times per frame

Interrupt
	movem.l	D1-A6,-(A7)

	cmp.w	#3,lbW024208
	bne.b	NoMain

	bsr.w	Play

	bra.b	SkipHelp
NoMain
	bsr.w	Help
SkipHelp
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
**************************** NoiseTracker player **************************
***************************************************************************

; Player ripped from "His Master's Noise" (c) 1991 by Mahoney & Kaktus

GetSongSize
	move.l	ModulePtr(PC),A0
	lea	$3B8(A0),A1
	moveq	#$7F,D0
	tst.b	FormatNow
	beq.b	New6
	lea	472(A0),A1
	cmp.b	#$78,471(A0)
	beq.b	New6
	move.b	470(A0),D0
	subq.l	#1,D0
New6
	moveq	#0,D2
	moveq	#0,D1
NextByte
	move.b	(A1)+,D1
	cmp.b	D2,D1
	ble.b	Lower
	move.l	D1,D2
Lower
	dbf	D0,NextByte
	addq.l	#1,D2
	move.l	D2,D3
	asl.l	#8,D2
	asl.l	#2,D2
	tst.b	FormatNow
	beq.b	Exit
	lea	600(A0),A2
	add.l	D2,A2
	rts
Exit
	lea	4(A1,D2.L),A2
	rts

InstallSamples
	lea	PtrBase(PC),A1
	move.l	A0,(A1)+
	lea	$2A(A0),A0
	move.l	InfoBuffer+MaxSamples(PC),D0
	subq.l	#1,D0
	moveq	#0,D2
NextInfo
	addq.l	#1,D2
	cmp.l	#'Mupp',-22(A0)
	bne.b	NoMuppet
	move.w	D2,lbW023E92
	movem.l	D0-A6,-(SP)
	bsr.w	InstallSynth
	movem.l	(SP)+,D0-A6
	addq.l	#4,A1
	bra.b	SkipNormal
NoMuppet
	moveq	#0,D1
	move.w	(A0),D1
	beq.b	SampleNo
	clr.w	(A2)
SampleNo
	move.l	A2,(A1)+
	asl.l	#1,D1
	add.l	D1,A2
SkipNormal
	lea	$1E(A0),A0
	dbf	D0,NextInfo
	rts

InitSong
	moveq	#6,D0
	lea	lbL023E94(PC),A0
	move.l	D0,(A0)+			; speed counter
	move.l	D0,(A0)+			; default speed
	clr.l	(A0)+				; song position
	clr.l	(A0)+				; pattern position
	clr.l	(A0)+				; DMACon+voice1
	clr.l	(A0)+				; voice2+voice3
	clr.l	(A0)+				; voice4+break
	move.w	#3,(A0)				; help counter
	rts

lbL02AC50
	dc.l	PtrBase				; ptr to BasePtr
lbW023E92
	dc.w	0				; sample nr from 1
lbL02B20C
	dc.l	0				; ptr to synth samples buffer
lbC02BED4
	RTS

InstallSynth
	MOVEA.L	lbL02AC50(PC),A0
	MOVEA.L	(A0),A0
	LEA	$43C(A0),A1
	MOVE.W	lbW023E92(pc),D0
	MULU.W	#$1E,D0
	LEA	-10(A0,D0.W),A0
	CMPI.L	#'Mupp',(A0)
	BNE.L	lbC02BED4
	MOVEQ	#0,D0
	MOVE.B	4(A0),D0
	MULU.W	#$400,D0
	LEA	0(A1,D0.L),A1
	MOVEA.L	lbL02B20C(pc),A2
	ADDI.L	#$1000,lbL02B20C
	MOVE.W	lbW023E92,D0
	ASL.W	#2,D0
	MOVEA.L	lbL02AC50(PC),A5
	MOVE.L	A2,0(A5,D0.W)
	MOVEA.L	A1,A3
	MOVEA.L	A2,A4
	MOVEQ	#$1B,D7
lbC02BF30	MOVE.L	(A3)+,(A4)+
	MOVE.L	(A3)+,(A4)+
	MOVE.L	(A3)+,(A4)+
	MOVE.L	(A3)+,(A4)+
	MOVE.L	(A3)+,(A4)+
	MOVE.L	(A3)+,(A4)+
	MOVE.L	(A3)+,(A4)+
	MOVE.L	(A3)+,(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	CLR.L	(A4)+
	DBRA	D7,lbC02BF30
	LEA	$380(A1),A3
	LEA	$E00(A2),A4
	MOVEQ	#$3E,D7
lbC02BF7E	MOVE.B	(A3)+,D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.B	D0,(A4)+
	MOVE.B	(A3),D1
	ADD.W	D1,D1
	ADD.W	D1,D1
	ADD.W	D0,D1
	ADD.W	D0,D1
	ADD.W	D0,D1
	LSR.W	#2,D1
	MOVE.B	D1,(A4)+
	MOVE.B	(A3),D1
	ADD.W	D1,D1
	ADD.W	D1,D1
	ADD.W	D0,D1
	LSR.W	#1,D1
	MOVE.B	D1,(A4)+
	MOVE.B	(A3),D1
	ADD.W	D1,D1
	ADD.W	D1,D1
	ADD.W	D1,D0
	ADD.W	D1,D0
	ADD.W	D1,D0
	LSR.W	#2,D0
	MOVE.B	D0,(A4)+
	DBRA	D7,lbC02BF7E
	MOVE.B	(A3)+,D0
	ADD.W	D0,D0
	MOVE.B	D0,(A4)+
	MOVE.B	D0,(A4)+
	MOVE.B	D0,(A4)+
	MOVE.B	D0,(A4)+
	LEA	$3C0(A1),A3
	LEA	$F00(A2),A4
	MOVEQ	#$3E,D7
lbC02BFCC	MOVE.B	(A3)+,D0
	MOVE.B	D0,(A4)+
	ANDI.W	#$7F,D0
	MOVE.B	(A3),D1
	ANDI.W	#$7F,D1
	ADD.W	D0,D1
	ADD.W	D0,D1
	ADD.W	D0,D1
	LSR.W	#2,D1
	MOVE.B	D1,(A4)+
	MOVE.B	(A3),D1
	ANDI.W	#$7F,D1
	ADD.W	D0,D1
	LSR.W	#1,D1
	MOVE.B	D1,(A4)+
	MOVE.B	(A3),D1
	ANDI.W	#$7F,D1
	ADD.W	D1,D0
	ADD.W	D1,D0
	ADD.W	D1,D0
	LSR.W	#2,D0
	MOVE.B	D0,(A4)+
	DBRA	D7,lbC02BFCC
	MOVE.B	(A3)+,D0
	MOVE.B	D0,(A4)+
	MOVE.B	D0,(A4)+
	MOVE.B	D0,(A4)+
	MOVE.B	D0,(A4)+
	MOVEA.L	A2,A1
	LEA	$F00(A1),A5
	LEA	$F6C(A1),A6
lbC02C018	MOVEA.L	A5,A4
	TST.B	(A5)+
lbC02C01C	TST.B	(A5)+
	BPL.S	lbC02C01C
	TST.B	-(A5)
	MOVEA.L	A5,A3
	MOVE.L	A3,D0
	SUB.L	A4,D0
	MOVE.L	D0,D3
	SUBQ.L	#1,D0
	MOVE.L	A4,D1
	SUB.L	A1,D1
	SUBI.L	#$F00,D1
	MOVE.L	A3,D2
	SUB.L	A1,D2
	SUBI.L	#$F00,D2
	MULU.W	#$20,D1
	MULU.W	#$20,D2
	LEA	0(A1,D1.W),A2
	LEA	0(A1,D2.W),A3
	MOVEQ	#$1F,D7
lbC02C052	MOVE.W	D0,D6
	MOVEQ	#0,D1
	MOVE.B	(A2)+,D1
	EXT.W	D1
	EXT.L	D1
	MOVE.B	(A3)+,D2
	EXT.W	D2
	EXT.L	D2
	SUB.L	D1,D2
	ASL.L	#6,D2
	DIVS.W	D3,D2
	ASL.L	#8,D2
	ASL.L	#2,D2
	ANDI.L	#$FFFF,D1
	SWAP	D1
	LEA	$1F(A2),A4
	BRA.S	lbC02C086

lbC02C07A	ADD.L	D2,D1
	SWAP	D1
	MOVE.B	D1,(A4)
	SWAP	D1
	LEA	$20(A4),A4
lbC02C086	DBRA	D6,lbC02C07A
	DBRA	D7,lbC02C052
	CMPA.L	A5,A6
	BGT.L	lbC02C018
	RTS

lbL023E94	dc.l	0			; speed counter
lbW023E98	dc.l	6			; default speed
lbW023E9C	dc.w	0
	dc.b	0
lbB023E9F	dc.b	0			; song position
lbL023EA0	dc.l	0			; pattern position
lbW023EA4	dc.w	0			; DMACon
lbW023EA6	dc.w	0
lbW023EA8	dc.w	0
lbW023EAA	dc.w	0
lbW023EAC	dc.w	0
lbW023EAE	dc.w	0			; break
lbW024208	dc.w	0			; help counter


lbC023EB0
	LEA	lbL024BC8,A6
	LEA	$DFF0A0,A5
	BSR.L	lbC0245F6
	BSR.L	lbC023F22
	LEA	lbL024BE8,A6
	LEA	$DFF0B0,A5
	BSR.L	lbC0245F6
	BSR.L	lbC023F22
	LEA	lbL024C08,A6
	LEA	$DFF0C0,A5
	BSR.L	lbC0245F6
	BSR.L	lbC023F22
	LEA	lbL024C28,A6
	LEA	$DFF0D0,A5
	BSR.L	lbC0245F6
	BSR.L	lbC023F22
lbC023F20	RTS

lbC023F22	MOVE.W	2(A6),D0
	ANDI.W	#$FFF,D0
	BEQ.S	lbC023F20
	MOVE.W	(A6),D0
	ANDI.W	#$FFF,D0
	BEQ.S	lbC023F3C
	TST.L	lbL023E94
	BEQ.S	lbC023F20
lbC023F3C	MOVE.B	2(A6),D0
	ANDI.B	#15,D0
	CMPI.B	#1,D0
	BEQ.L	lbC024AF0
	CMPI.B	#2,D0
	BEQ.L	lbC024B14
	CMPI.B	#3,D0
	BEQ.L	lbC0247B8
	CMPI.B	#4,D0
	BEQ.L	lbC02481C
	CMPI.B	#5,D0
	BEQ.L	lbC024AEA
	CMPI.B	#6,D0
	BEQ.L	lbC024AE4
	MOVE.W	2(A6),D2
	ANDI.W	#$FFF,D2
	BEQ.S	lbC023F8C
	TST.B	D0
	BEQ.L	lbC023F20
	CMPI.B	#7,D0
	BEQ.L	lbC023F20
lbC023F8C	MOVE.L	D0,-(SP)
	MOVE.W	$10(A6),D0
	BSR.L	lbC0249F4
	MOVE.L	(SP)+,D0
	CMPI.B	#10,D0
	BEQ.L	lbC024A9E
	RTS

Help						; original at $D80
	MOVEM.L	D0-D7/A0-A6,-(SP)
	ADDQ.W	#1,lbW024208
	BSR.L	lbC023EB0
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

Play						; original at $3700
	CLR.W	lbW024208
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVEA.L	PtrBase(PC),A0
	ADDQ.L	#1,lbL023E94
	MOVE.L	lbL023E94(pc),D0
	CMP.L	lbW023E98(pc),D0
	BLT.S	lbC0242DC
	CLR.L	lbL023E94
	BRA.L	lbC0243BE

lbC0242DC	LEA	lbL024BC8(pc),A6
	LEA	$DFF0A0,A5
	BSR.L	lbC024A3A
	BSR.L	lbC0245F6
;	MOVE.L	10(A6),(A5)
;	MOVE.W	14(A6),4(A5)

	move.l	D0,-(SP)
	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	LEA	lbL024BE8(pc),A6
	LEA	$DFF0B0,A5
	BSR.L	lbC024A3A
	BSR.L	lbC0245F6
;	MOVE.L	10(A6),(A5)
;	MOVE.W	14(A6),4(A5)

	move.l	D0,-(SP)
	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	LEA	lbL024C08(pc),A6
	LEA	$DFF0C0,A5
	BSR.L	lbC024A3A
	BSR.L	lbC0245F6
;	MOVE.L	10(A6),(A5)
;	MOVE.W	14(A6),4(A5)

	move.l	D0,-(SP)
	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	LEA	lbL024C28(pc),A6
	LEA	$DFF0D0,A5
	BSR.L	lbC024A3A
	BSR.L	lbC0245F6
;	MOVE.L	10(A6),(A5)
;	MOVE.W	14(A6),4(A5)

	move.l	D0,-(SP)
	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	BRA.L	lbC024782

lbC024358	MOVE.L	A0,-(SP)
	MOVE.L	lbL023E94(pc),D0
	DIVS.W	#3,D0
	SWAP	D0
	TST.W	D0
	BEQ.S	lbC024386
	CMPI.W	#2,D0
	BEQ.S	lbC02437A
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	BRA.S	lbC02438C

lbC02437A	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	BRA.S	lbC02438C

lbC024386	MOVE.W	$10(A6),D2
	BRA.S	lbC0243B4

lbC02438C	ASL.W	#1,D0
	MOVEQ	#0,D2
	MOVE.W	$10(A6),D2
	ANDI.W	#$3FFF,D2
	LSR.W	#2,D2
	LEA	lbW024C48(pc),A0
	MOVEQ	#$36,D7
lbC0243A2	CMP.W	(A0)+,D2
	BGE.S	lbC0243AE
	DBRA	D7,lbC0243A2
	MOVEA.L	(SP)+,A0
	RTS

lbC0243AE	MOVE.W	-2(A0,D0.W),D2
	ASL.W	#2,D2
lbC0243B4	MOVE.W	D2,D0
	BSR.L	lbC0249F4
	MOVEA.L	(SP)+,A0
	RTS

lbC0243BE	MOVEA.L	PtrBase(PC),A0
	MOVEA.L	A0,A3
	MOVEA.L	A0,A2
	ADDA.L	#12,A3
	ADDA.L	#$3B8,A2
	ADDA.L	#$43C,A0

	tst.b	FormatNow
	beq.b	New7
	lea	588(A3),A0
	lea	460(A3),A2
New7
	MOVEQ	#0,D1
	MOVE.L	lbW023E9C(pc),D0
	MOVE.B	0(A2,D0.L),D1
	LSL.L	#8,D1
	LSL.L	#2,D1
	ADD.L	lbL023EA0(pc),D1
	CLR.W	lbW023EA4
	LEA	$DFF0A0,A5
	LEA	lbL024BC8(pc),A6
	LEA	lbW023EA6(PC),A2
	BSR.S	lbC024448
	ADDQ.L	#4,D1
	LEA	$DFF0B0,A5
	LEA	lbL024BE8(pc),A6
	LEA	lbW023EA8(PC),A2
	BSR.S	lbC024448
	ADDQ.L	#4,D1
	LEA	$DFF0C0,A5
	LEA	lbL024C08(pc),A6
	LEA	lbW023EAA(PC),A2
	BSR.S	lbC024448
	ADDQ.L	#4,D1
	LEA	$DFF0D0,A5
	LEA	lbL024C28(pc),A6
	LEA	lbW023EAC(PC),A2
	BSR.S	lbC024448
	BRA.L	lbC024662

lbC024448	MOVE.L	0(A0,D1.L),(A6)
	MOVEQ	#0,D2
	MOVE.B	2(A6),D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	ANDI.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ.L	lbC02456A
	MOVEQ	#0,D3
	MOVE.L	D2,D4
	LEA	PtrBase(PC),A1
	LSL.L	#2,D2
	MULU.W	#$1E,D4
	MOVE.L	0(A1,D2.L),4(A6)
	MOVE.B	2(A3,D4.L),$1E(A6)
	CLR.B	$1C(A6)
	CMPI.L	#'Mupp',-$16(A3,D4.L)
	BNE.S	lbC0244FE
	MOVE.L	A0,-(SP)
	MOVE.B	#1,$1C(A6)
	MOVEA.L	4(A6),A0
	MOVEQ	#0,D2
	MOVE.B	$F00(A0),$12(A6)
	ANDI.B	#$7F,$12(A6)
	MOVE.B	$E00(A0),D2
	MULU.W	#$20,D2
	LEA	0(A0,D2.W),A0
	MOVE.L	A0,10(A6)
	MOVEQ	#0,D2
	MOVE.B	3(A3,D4.L),D2
	ASL.W	#2,D2
	CMPI.W	#$100,D2
	BNE.S	lbC0244D2
	MOVE.W	#$FF,D2
lbC0244D2	MOVE.B	D2,$13(A6)
	MOVE.B	-$11(A3,D4.L),D2
	ASL.B	#2,D2
	MOVE.B	D2,8(A6)
	MOVE.B	-$10(A3,D4.L),D2
	ASL.W	#2,D2
	ADDQ.W	#3,D2
	MOVE.B	D2,9(A6)
	MOVE.W	#$10,14(A6)
	MOVEA.L	(SP)+,A0
	MOVE.W	$12(A6),(A2)
	ANDI.W	#$FF,(A2)
	BRA.w	lbC02456A

lbC0244FE	MOVE.W	0(A3,D4.L),8(A6)
	MOVE.W	2(A3,D4.L),D3
	ANDI.W	#$FF,D3
	ASL.W	#2,D3
	CMPI.W	#$FF,D3
	BLE.S	lbC024518
	MOVE.W	#$FF,D3
lbC024518	MOVE.W	D3,$12(A6)
	MOVE.B	#$40,$12(A6)
	MOVE.W	4(A3,D4.L),D3
	TST.W	D3
	BEQ.S	lbC024552
	MOVE.L	4(A6),D2

	tst.b	FormatNow
	bne.b	Old2

	ASL.W	#1,D3
Old2
	ADD.L	D3,D2
	MOVE.L	D2,10(A6)
	MOVE.W	4(A3,D4.L),D0

	tst.b	FormatNow
	beq.b	New9
	asr.w	#1,D0
New9
	ADD.W	6(A3,D4.L),D0
	MOVE.W	D0,8(A6)
	MOVE.W	6(A3,D4.L),14(A6)
	MOVE.W	$12(A6),(A2)
	ANDI.W	#$FF,(A2)
	BRA.S	lbC02456A

lbC024552
;	MOVE.L	#EmptyBuffer,D2

	move.l	4(A6),D2

	MOVE.L	D2,10(A6)
	MOVE.W	6(A3,D4.L),14(A6)
	MOVE.W	$12(A6),(A2)
	ANDI.W	#$FF,(A2)
lbC02456A	MOVE.W	(A6),D0
	ANDI.W	#$FFF,D0
	BEQ.L	lbC0245F2
	TST.W	8(A6)
	BEQ.S	lbC024596
	MOVE.B	2(A6),D0
	ANDI.B	#15,D0
	CMPI.B	#5,D0
	BEQ.S	lbC02458E
	CMPI.B	#3,D0
	BNE.S	lbC0245A4
lbC02458E	BSR.L	lbC024790
	BRA.L	lbC024B38

lbC024596	MOVE.W	$14(A6),D0
;	MOVE.W	D0,$DFF096

	bsr.w	PokeDMA

	BRA.L	lbC0245F2

lbC0245A4	MOVE.W	(A6),D0
	ANDI.W	#$FFF,D0
	ASL.W	#2,D0
	MOVE.W	D0,$10(A6)
;	MOVE.W	$14(A6),$DFF096

	move.l	D0,-(SP)
	move.w	$14(A6),D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	CLR.B	$1B(A6)
	CLR.B	$1D(A6)
	TST.B	$1C(A6)
	BEQ.S	lbC0245D2
;	MOVE.L	10(A6),(A5)				; address
;	MOVE.W	14(A6),4(A5)				; length

	move.l	D0,-(SP)
	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	BRA.S	lbC0245DC

lbC0245D2
;	MOVE.L	4(A6),(A5)				; address
;	MOVE.W	8(A6),4(A5)				; length

	move.l	D0,-(SP)
	move.l	4(A6),D0
	bsr.w	PokeAdr
	move.w	8(A6),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

lbC0245DC	MOVE.W	$10(A6),D0
	ANDI.W	#$3FFF,D0
	BSR.L	lbC0249F4
	MOVE.W	$14(A6),D0
	OR.W	D0,lbW023EA4
lbC0245F2	BRA.L	lbC024B38

lbC0245F6	TST.B	$1C(A6)
	BEQ.S	lbC02464C
	MOVEM.L	D0/D1/A0-A2,-(SP)
	MOVEQ	#0,D0
	MOVE.B	$1D(A6),D0
	MOVEA.L	4(A6),A0
	LEA	$E00(A0),A1
	LEA	$100(A1),A2
	MOVE.B	0(A2,D0.W),D1
	ANDI.W	#$7F,D1
	MOVE.B	D1,$12(A6)
	MOVE.B	0(A1,D0.W),D1
	MULU.W	#$20,D1
	LEA	0(A0,D1.W),A1
	MOVE.L	A1,10(A6)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	$1D(A6),D0
	MOVE.B	9(A6),D1
	ADDQ.W	#1,D0
	CMP.W	D1,D0
	BLE.S	lbC024644
	MOVE.B	8(A6),D0
lbC024644	MOVE.B	D0,$1D(A6)
	MOVEM.L	(SP)+,D0/D1/A0-A2
lbC02464C	MOVEQ	#0,D0
	MOVE.B	$13(A6),D0
	MOVEQ	#0,D3
	MOVE.B	$12(A6),D3
	MULU.W	D3,D0
	LSR.W	#8,D0
;	MOVE.W	D0,8(A5)			; volume

	bsr.w	PokeVol

	RTS

lbC024662
;	MOVE.W	#$190,D0
;lbC024666	DBRA	D0,lbC024666
	LEA	lbL024C28(pc),A6
	LEA	$DFF0D0,A5
	BSR.L	lbC0245F6
	LEA	lbL024C08(pc),A6
	LEA	$DFF0C0,A5
	BSR.L	lbC0245F6
	LEA	lbL024BE8(pc),A6
	LEA	$DFF0B0,A5
	BSR.L	lbC0245F6
	LEA	lbL024BC8(pc),A6
	LEA	$DFF0A0,A5
	BSR.L	lbC0245F6
	MOVE.W	lbW023EA4(pc),D0
	ORI.W	#$8000,D0
;	MOVE.W	D0,$DFF096

	bsr.w	PokeDMA

;	MOVE.W	#$190,D0
;lbC0246BE	DBRA	D0,lbC0246BE
	LEA	lbL024C28(pc),A6
	LEA	$DFF0D0,A5
;	MOVE.L	10(A6),(A5)
;	MOVE.W	14(A6),4(A5)

	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen

	LEA	lbL024C08(pc),A6
	LEA	$DFF0C0,A5
;	MOVE.L	10(A6),(A5)
;	MOVE.W	14(A6),4(A5)

	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen

	LEA	lbL024BE8(pc),A6
	LEA	$DFF0B0,A5
;	MOVE.L	10(A6),(A5)
;	MOVE.W	14(A6),4(A5)

	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen

	LEA	lbL024BC8(pc),A6
	LEA	$DFF0A0,A5
;	MOVE.L	10(A6),(A5)
;	MOVE.W	14(A6),4(A5)

	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen

	ADDI.L	#$10,lbL023EA0
	CMPI.L	#$400,lbL023EA0
	BNE.S	lbC024782
lbC024730	CLR.L	lbL023EA0
	CLR.W	lbW023EAE
	ADDQ.L	#1,lbW023E9C
	ANDI.L	#$7F,lbW023E9C
	MOVEA.L	PtrBase(PC),A0
	MOVEQ	#0,D0
	MOVE.B	$3B6(A0),D0

	tst.b	FormatNow
	beq.b	New8
	move.b	470(A0),D0
New8
	MOVE.L	lbW023E9C(pc),D1
	CMP.L	D0,D1
	BNE.S	lbC024782
	MOVEQ	#0,D0

	tst.b	FormatNow
	bne.b	Old1

	MOVE.B	$3B7(A0),D0
Old1
	MOVE.L	D0,lbW023E9C

	bsr.w	SongEnd

lbC024782	TST.W	lbW023EAE
	BNE.S	lbC024730
	MOVEM.L	(SP)+,D0-D7/A0-A6

	bsr.w	PATINFO

	RTS

lbC024790	MOVE.W	(A6),D2
	ANDI.W	#$FFF,D2
	ASL.W	#2,D2
	MOVE.W	D2,$18(A6)
	MOVE.W	$10(A6),D0
	CLR.B	$16(A6)
	CMP.W	D0,D2
	BEQ.S	lbC0247B2
	BGE.S	lbC0247B0
	MOVE.B	#1,$16(A6)
lbC0247B0	RTS

lbC0247B2	CLR.W	$18(A6)
	RTS

lbC0247B8	MOVE.B	3(A6),D0
	BEQ.S	lbC0247C6
	MOVE.B	D0,$17(A6)
	CLR.B	3(A6)
lbC0247C6	TST.W	$18(A6)
	BEQ.S	lbC0247B0
	MOVEQ	#0,D0
	MOVE.B	$17(A6),D0
	TST.B	$16(A6)
	BNE.S	lbC0247FA
	ADD.W	D0,$10(A6)
	MOVE.W	$18(A6),D0
	CMP.W	$10(A6),D0
	BGT.S	lbC0247F0
	MOVE.W	$18(A6),$10(A6)
	CLR.W	$18(A6)
lbC0247F0	MOVE.W	$10(A6),D0
	BSR.L	lbC0249F4
	RTS

lbC0247FA	SUB.W	D0,$10(A6)
	MOVE.W	$18(A6),D0
	CMP.W	$10(A6),D0
	BLT.S	lbC0247F0
	MOVE.W	$18(A6),$10(A6)
	CLR.W	$18(A6)
	MOVE.W	$10(A6),D0
	BSR.L	lbC0249F4
	RTS

lbC02481C	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BEQ.S	lbC024828
	MOVE.B	D0,$1A(A6)
lbC024828	MOVE.B	$1B(A6),D0
	LEA	lbW02486C(PC),A4
	LSR.W	#2,D0
	ANDI.W	#$1F,D0
	MOVEQ	#0,D2
	MOVE.B	0(A4,D0.W),D2
	MOVE.B	$1A(A6),D0
	ANDI.W	#15,D0
	MULU.W	D0,D2
	LSR.L	#5,D2
	MOVE.W	$10(A6),D0
	TST.B	$1B(A6)
	BMI.S	lbC024856
	ADD.W	D2,D0
	BRA.S	lbC024858

lbC024856	SUB.W	D2,D0
lbC024858	BSR.L	lbC0249F4
	MOVE.B	$1A(A6),D0
	LSR.W	#4,D0
	ANDI.W	#15,D0
	ADD.B	D0,$1B(A6)
	RTS

lbW02486C	dc.w	$18
	dc.w	$314A
	dc.w	$6178
	dc.w	$8DA1
	dc.w	$B4C5
	dc.w	$D4E0
	dc.w	$EBF4
	dc.w	$FAFD
	dc.w	$FFFD
	dc.w	$FAF4
	dc.w	$EBE0
	dc.w	$D4C5
	dc.w	$B4A1
	dc.w	$8D78
	dc.w	$614A
	dc.w	$3118
lbW02488C	dc.w	3
	dc.w	$70C
	dc.w	$F0C
	dc.w	$703
	dc.w	3
	dc.w	$70C
	dc.w	$F0C
	dc.w	$703
	dc.w	4
	dc.w	$70C
	dc.w	$100C
	dc.w	$704
	dc.w	4
	dc.w	$70C
	dc.w	$100C
	dc.w	$704
	dc.w	3
	dc.w	$80C
	dc.w	$F0C
	dc.w	$803
	dc.w	3
	dc.w	$80C
	dc.w	$F0C
	dc.w	$803
	dc.w	4
	dc.w	$80C
	dc.w	$100C
	dc.w	$804
	dc.w	4
	dc.w	$80C
	dc.w	$100C
	dc.w	$804
	dc.w	5
	dc.w	$80C
	dc.w	$110C
	dc.w	$805
	dc.w	5
	dc.w	$80C
	dc.w	$110C
	dc.w	$805
	dc.w	5
	dc.w	$90C
	dc.w	$110C
	dc.w	$905
	dc.w	5
	dc.w	$90C
	dc.w	$110C
	dc.w	$905
	dc.w	$C00
	dc.w	$700
	dc.w	$300
	dc.w	$700
	dc.w	$C00
	dc.w	$700
	dc.w	$300
	dc.w	$700
	dc.w	$C00
	dc.w	$700
	dc.w	$400
	dc.w	$700
	dc.w	$C00
	dc.w	$700
	dc.w	$400
	dc.w	$700
	dc.w	3
	dc.w	$703
	dc.w	$70C
	dc.w	$70C
	dc.w	$F0C
	dc.w	$70C
	dc.w	$703
	dc.w	$703
	dc.w	4
	dc.w	$704
	dc.w	$70C
	dc.w	$70C
	dc.w	$100C
	dc.w	$70C
	dc.w	$704
	dc.w	$704
	dc.w	$1F1B
	dc.w	$1813
	dc.w	$F0C
	dc.w	$703
	dc.w	3
	dc.w	$70C
	dc.w	$F13
	dc.w	$181B
	dc.w	$1F1C
	dc.w	$1813
	dc.w	$100C
	dc.w	$704
	dc.w	4
	dc.w	$70C
	dc.w	$1013
	dc.w	$181C
	dc.w	12
	dc.w	12
	dc.w	12
	dc.w	12
	dc.w	12
	dc.w	12
	dc.w	12
	dc.w	12
	dc.w	12
	dc.w	$180C
	dc.w	12
	dc.w	$180C
	dc.w	12
	dc.w	$180C
	dc.w	12
	dc.w	$180C
	dc.w	3
	dc.w	3
	dc.w	3
	dc.w	3
	dc.w	3
	dc.w	3
	dc.w	3
	dc.w	3
	dc.w	4
	dc.w	4
	dc.w	4
	dc.w	4
	dc.w	4
	dc.w	4
	dc.w	4
	dc.w	4

lbC02498C	MOVE.L	A0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	$1B(A6),D0
	ADDQ.B	#1,$1B(A6)
	ANDI.B	#15,D0
	MOVEQ	#0,D2
	LEA	lbW02488C(PC),A0
	MOVE.B	3(A6),D2
	ANDI.W	#15,D2
	ASL.W	#4,D2
	ADD.W	D0,D2
	MOVEQ	#0,D0
	MOVE.B	0(A0,D2.W),D0
	ADD.W	D0,D0
	MOVEQ	#0,D2
	MOVE.W	$10(A6),D2
	LSR.W	#2,D2
	ANDI.W	#$FFF,D2
	LEA	lbW024C48,A0
	MOVEQ	#$36,D7
lbC0249CA	CMP.W	(A0)+,D2
	BGE.S	lbC0249D4
	DBRA	D7,lbC0249CA
	RTS

lbC0249D4	LEA	-2(A0,D0.W),A0
lbC0249D8	CMPA.L	#lbL024C90,A0
	BLT.S	lbC0249E8
	SUBA.L	#$18,A0
	BRA.S	lbC0249D8

lbC0249E8	MOVE.W	(A0),D0
	ASL.W	#2,D0
	BSR.L	lbC0249F4
	MOVEA.L	(SP)+,A0
	RTS

lbC0249F4	MOVEM.L	D1/D2,-(SP)
	MOVE.W	D0,D2
	MOVE.B	$1E(A6),D1
	EXT.W	D1
	MULS.W	D1,D2
	ASR.L	#8,D2
	ADD.W	D2,D0
	LSR.W	#2,D0
;	MOVE.W	D0,6(A5)			; period

	bsr.w	PokePer

	MOVEM.L	(SP)+,D1/D2
	RTS

lbC024A30	MOVE.W	$10(A6),D0
	BSR.L	lbC0249F4
	RTS

lbC024A3A	MOVE.W	2(A6),D0
	ANDI.W	#$FFF,D0
	BEQ.L	lbC024A30
	MOVE.B	2(A6),D0
	ANDI.B	#15,D0
	BEQ.L	lbC024358
	CMPI.B	#1,D0
	BEQ.L	lbC024AF0
	CMPI.B	#2,D0
	BEQ.L	lbC024B14
	CMPI.B	#3,D0
	BEQ.L	lbC0247B8
	CMPI.B	#4,D0
	BEQ.L	lbC02481C
	CMPI.B	#5,D0
	BEQ.L	lbC024AEA
	CMPI.B	#6,D0
	BEQ.L	lbC024AE4
	CMPI.B	#7,D0
	BEQ.L	lbC02498C
	MOVE.L	D0,-(SP)
	MOVE.W	$10(A6),D0
	BSR.L	lbC0249F4
	MOVE.L	(SP)+,D0
	CMPI.B	#10,D0
	BNE.L	lbC0247B0
lbC024A9E	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	lbC024AC6
	MOVEQ	#0,D1
	MOVE.B	$13(A6),D1
	ADD.W	D0,D1
	CMPI.W	#$FF,D1
	BLE.S	lbC024ABE
	MOVE.W	#$FF,D1
lbC024ABE	MOVE.B	D1,$13(A6)
	MOVE.L	(SP)+,D1
	RTS

lbC024AC6	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	MOVEQ	#0,D1
	MOVE.B	$13(A6),D1
	SUB.W	D0,D1
	BPL.S	lbC024ADC
	CLR.W	D1
lbC024ADC	MOVE.B	D1,$13(A6)
	MOVE.L	(SP)+,D1
	RTS

lbC024AE4	BSR.L	lbC024828
	BRA.S	lbC024A9E

lbC024AEA	BSR.L	lbC0247C6
	BRA.S	lbC024A9E

lbC024AF0

	cmp.b	#2,FormatNow
	beq.w	lbC024358			; Arpeggio

	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
pit2
	SUB.W	D0,$10(A6)
	MOVE.W	$10(A6),D0
	CMPI.W	#$1C4,D0
	BPL.S	lbC024B0A
	MOVE.W	#$1C4,$10(A6)
lbC024B0A	MOVE.W	$10(A6),D0
	BSR.L	lbC0249F4
	RTS

lbC024B14	CLR.W	D0
	MOVE.B	3(A6),D0

	cmp.b	#2,FormatNow
	bne.b	pit1
	lsr.b	#4,D0
	bne.b	pit1
	move.b	3(A6),D0
	and.b	#$0F,D0
	bne.b	pit2
	rts
pit1
	ADD.W	D0,$10(A6)
	MOVE.W	$10(A6),D0
	CMPI.W	#$D60,D0
	BMI.S	lbC024B2E
	MOVE.W	#$D60,$10(A6)
lbC024B2E	MOVE.W	$10(A6),D0
	BSR.L	lbC0249F4
	RTS

lbC024B38	MOVE.B	2(A6),D0
	ANDI.B	#15,D0
	CMPI.B	#13,D0
	BEQ.S	lbC024B66
	CMPI.B	#11,D0
	BEQ.S	lbC024B70
	CMPI.B	#12,D0
	BEQ.S	lbC024B86
	CMPI.B	#15,D0
	BEQ.L	lbC024BA2
	MOVE.W	(A6),D2
	ANDI.W	#$FFF,D2
	BEQ.L	lbC024A3A
	RTS

lbC024B66
	cmp.b	#1,FormatNow
	beq.w	lbC024A9E

	MOVE.W	#1,lbW023EAE
	RTS

lbC024B70
	tst.b	FormatNow
	beq.b	New11
	bsr.w	SongEnd
New11
	MOVE.B	3(A6),D0
	MOVE.W	#1,lbW023EAE
	SUBQ.B	#1,D0
	MOVE.B	D0,lbB023E9F
	RTS

lbC024B86	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ASL.W	#2,D0
	CMPI.W	#$FF,D0
	BLE.S	lbC024B98
	MOVE.W	#$FF,D0
lbC024B98	MOVE.B	D0,1(A2)
	MOVE.B	D0,$13(A6)
	RTS

lbC024BA2	CMPI.B	#$1F,3(A6)
	BLS.S	lbC024BB0
	MOVE.B	#$1F,3(A6)
lbC024BB0	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BNE.S	lbC024BBA
	MOVEQ	#1,D0
lbC024BBA	MOVE.L	D0,lbW023E98
	CLR.L	lbL023E94
	RTS

lbL024BC8
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	1
	dc.w	0
	dc.l	0
	dc.l	0
lbL024BE8
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	2
	dc.w	0
	dc.l	0
	dc.l	0
lbL024C08
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	4
	dc.w	0
	dc.l	0
	dc.l	0
lbL024C28
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	8
	dc.w	0
	dc.l	0
	dc.l	0
PeriodTable
lbW024C48
	dc.w	$358
	dc.w	$328
	dc.w	$2FA
	dc.w	$2D0
	dc.w	$2A6
	dc.w	$280
	dc.w	$25C
	dc.w	$23A
	dc.w	$21A
	dc.w	$1FC
	dc.w	$1E0
	dc.w	$1C5
	dc.w	$1AC
	dc.w	$194
	dc.w	$17D
	dc.w	$168
	dc.w	$153
	dc.w	$140
	dc.w	$12E
	dc.w	$11D
	dc.w	$10D
	dc.w	$FE
	dc.w	$F0
	dc.w	$E2
	dc.w	$D6
	dc.w	$CA
	dc.w	$BE
	dc.w	$B4
	dc.w	$AA
	dc.w	$A0
	dc.w	$97
	dc.w	$8F
	dc.w	$87
	dc.w	$7F
	dc.w	$78
	dc.w	$71
PeriodEnd
lbL024C90
PtrBase
	ds.b	32*4

;	Section	Empty,BSS_C
;EmptyBuffer
;	ds.b	32
