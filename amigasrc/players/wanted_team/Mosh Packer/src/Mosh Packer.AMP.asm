	******************************************************
	****           Mosh Packer replayer for     	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: Mosh Packer player module V2.0 (16 Mar 2014)',0
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
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Save!EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	0

PlayerName
	dc.b	'Mosh Packer',0
Creator
	dc.b	'(c) 1990 by Mosh/Anarchy,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'MOSH.',0
	even
ModulePtr
	dc.l	0
SamplePtr
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
	movem.l	D1/A5,-(SP)
	move.w	A5,D1		;DFF0A0/B0/C0/D0
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
	move.w	A5,D1		;DFF0A0/B0/C0/D0
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
	move.w	A5,D1		;DFF0A0/B0/C0/D0
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
	move.w	A5,D1		;DFF0A0/B0/C0/D0
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

LED_Off
	movem.l	D0/D1/A5,-(SP)
	moveq	#1,D0
	moveq	#0,D1
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeCommand(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

LED_On
	movem.l	D0/D1/A5,-(SP)
	moveq	#1,D0
	moveq	#1,D1
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeCommand(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

***************************************************************************
****************************** EP_PatternInit *****************************
***************************************************************************

PATTERNINFO:
	DS.B	PI_Stripes	; This is the main structure

* Here you store the address of each "stripe" (track) for the current
* pattern so the PI engine can read the data for each row and send it
* to the CONVERTNOTE function you supply.  The engine determines what
* data needs to be converted by looking at the Pattpos and Modulo fields.

STRIPE1	DS.L	1
STRIPE2	DS.L	1
STRIPE3	DS.L	1
STRIPE4	DS.L	1

* More stripes go here in case you have more than 4 channels.


* Called at various and sundry times (e.g. StartInt, apparently)
* Return PatternInfo Structure in A0
PatternInit
	lea	PATTERNINFO(PC),A0

	moveq	#4,D0
	move.w	D0,PI_Voices(A0)	; Number of stripes (MUST be at least 4)
	move.l	#CONVERTNOTE,PI_Convert(A0)
	moveq	#16,D0
	move.l	D0,PI_Modulo(A0)	; Number of bytes to next row
	move.w	#64,PI_Pattlength(A0)	; Length of each stripe in rows
	move.w	InfoBuffer+Patterns+2(PC),PI_NumPatts(A0)	; Overall Number of Patterns
	clr.w	PI_Pattern(A0)		; Current Pattern (from 0)
	move.w	#6,PI_Speed(A0)		; Default Speed Value
	clr.w	PI_Pattpos(A0)		; Current Position in Pattern (from 0)
	clr.w	PI_Songpos(A0)		; Current Position in Song (from 0)
	move.w	InfoBuffer+Length+2(PC),PI_MaxSongPos(A0)	; Songlength

	move.w	#125,PI_BPM(A0)

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

	moveq	#0,D1		; Sample number
	moveq	#0,D3		; Command argument
	moveq	#$10,D0
	and.b	(A0),D0
	move.b	2(A0),D1
	lsr.b	#4,D1
	or.b	D0,D1
	move.w	(A0),D0		; Period? Note?
	and.w	#$FFF,D0
	moveq	#15,D2		; Command string
	and.b	2(A0),D2
	move.b	3(A0),D3
	rts

PATINFO
	movem.l	D0/A0-A2,-(SP)
	lea	PATTERNINFO(PC),A0
	lea	lbW003482(PC),A1
	move.b	(A1),PI_Speed+1(A0)		; Speed Value
	move.w	2(A1),D0
	lsr.w	#4,D0
	move.w	D0,PI_Pattpos(A0)		; Current Position in Pattern
	moveq	#0,D0
	move.b	1(A1),D0
	move.w	D0,PI_Songpos(A0)
	move.l	ModulePtr(PC),A2
	lea	250(A2),A2
	move.b	(A2,D0.W),D0
	move.w	D0,PI_Pattern(A0)	; Current Pattern
	lea	132(A2),A1
	moveq	#10,D1
	lsl.l	D1,D0
	add.l	D0,A1
	move.l	A1,PI_Stripes(A0)	; STRIPE1
	addq.l	#4,A1			; Distance to next stripe
	move.l	A1,PI_Stripes+4(A0)	; STRIPE2
	addq.l	#4,A1
	move.l	A1,PI_Stripes+8(A0)	; STRIPE3
	addq.l	#4,A1
	move.l	A1,PI_Stripes+12(A0)	; STRIPE4
	movem.l	(SP)+,D0/A0-A2
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

	move.l	SamplePtr(PC),A1
	moveq	#30,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	moveq	#0,D0
	move.w	6(A2),D0
	add.l	D0,D0
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	addq.l	#8,A2
	add.l	D0,A1
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	lea	lbW003482(PC),A0
	moveq	#0,D0
	move.b	1(A0),D0
	addq.b	#1,D0
	cmp.w	InfoBuffer+Length+2(PC),D0
	beq.b	MaxPos
	addq.b	#1,1(A0)
	clr.w	2(A0)
	clr.b	5(A0)
MaxPos
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	lea	lbW003482(PC),A0
	moveq	#0,D0
	move.b	1(A0),D0
	beq.b	MinPos
	subq.b	#1,1(A0)
	clr.w	2(A0)
	clr.b	5(A0)
MinPos
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

LoadSize	=	4
Samples		=	12
Length		=	20
SamplesSize	=	28
SongSize	=	36
CalcSize	=	44
Patterns	=	52
Unpacked	=	60

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Samples,0		;12
	dc.l	MI_Length,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Songsize,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_Pattern,0		;52
	dc.l	MI_Unpacked,0
	dc.l	MI_UnPackedSystem,MIUS_SoundTracker
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxSamples,31
	dc.l	MI_MaxPattern,64
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	moveq	#30,D1
NextInfos
	tst.w	(A0)+
	bmi.b	Fault
	tst.w	(A0)+
	bmi.b	Fault
	cmp.w	#$40,(A0)+
	bhi.b	Fault
	tst.w	(A0)+
	bmi.b	Fault
	dbf	D1,NextInfos
	cmp.l	#'M.K.',378-248(A0)
	bne.b	Fault

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
	move.l	A0,(A6)+			; module buffer

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	move.l	A0,A1
	moveq	#30,D0
	moveq	#0,D1
	moveq	#0,D2
	moveq	#0,D3
NextInfo
	move.w	6(A1),D1
	beq.b	Empty
	addq.l	#1,D2
	add.l	D1,D3
Empty
	addq.l	#8,A1
	dbf	D0,NextInfo
	add.l	D3,D3
	move.l	D3,SamplesSize(A4)
	move.l	D2,Samples(A4)
	move.b	(A1)+,D2
	move.l	D2,Length(A4)
	moveq	#0,D0
Loop
	cmp.b	(A1)+,D0
	bge.b	NextByte
	move.b	-1(A1),D0
NextByte
	dbf	D2,Loop
	addq.l	#1,D0
	move.l	D0,Patterns(A4)
	moveq	#10,D1
	lsl.l	D1,D0
	add.l	#382,D0
	move.l	D0,SongSize(A4)
	add.l	D0,A0
	move.l	A0,(A6)				; SamplePtr
	add.l	D0,D3
	move.l	D3,CalcSize(A4)
	cmp.l	LoadSize(A4),D3
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	add.l	#702,D3
	move.l	D3,Unpacked(A4)
	bsr.w	InitSamples

	moveq	#0,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.b	lbW003482+1(PC),D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	moveq	#3,D0
ClearIt
	lea	lbW003508(PC),A0
	clr.l	(A0)+
	clr.l	(A0)+
	clr.l	(A0)+
	clr.l	(A0)+
	clr.l	(A0)+
	addq.l	#2,A0
	clr.l	(A0)+
	clr.w	(A0)+
	dbf	D0,ClearIt

	move.l	ModulePtr(PC),A0
	bra.w	Init

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

	bsr.w	Play

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
**************************** Mosh Packer player ***************************
***************************************************************************

; Player from demo "Earwax Collection #1" (c) 1990 by Anarchy

Init
;lbC000DAA	LEA	(lbL01F780),A0

	move.l	ModulePtr(PC),A0

	MOVEA.L	A0,A1
	ADDA.L	#$FA,A1
	LEA	(lbW003482,PC),A4
	MOVE.B	(-1,A1),(8,A4)
	MOVE.B	#6,(A4)
	CLR.B	(1,A4)
	CLR.W	(2,A4)
	CLR.B	(4,A4)

	rts

InitSamples

	move.l	ModulePtr(PC),A0
	move.l	A0,A1
	lea	$FA(A1),A1

	MOVEQ	#$7F,D0
	MOVEQ	#0,D1
lbC000DD6	MOVE.L	D1,D2
	SUBQ.W	#1,D0
lbC000DDA	MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BGT.B	lbC000DD6
	DBRA	D0,lbC000DDA
	ADDQ.B	#1,D2
	LEA	(lbL00348C,PC),A1
	ASL.L	#8,D2
	ASL.L	#2,D2
	ADDI.L	#$17E,D2
	ADD.L	A0,D2
	MOVEA.L	D2,A2
	MOVEQ	#$1E,D0
lbC000DFA
;	CLR.L	(A2)
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	(6,A0),D1

	beq.b	No
	clr.w	(A2)

	ASL.L	#1,D1
	ADDA.L	D1,A2
No
	ADDA.L	#8,A0
	DBRA	D0,lbC000DFA
;	ORI.B	#2,($BFE001)
;	CLR.W	($DFF0A8)
;	CLR.W	($DFF0B8)
;	CLR.W	($DFF0C8)
;	CLR.W	($DFF0D8)
	RTS

;lbC000E34	CLR.W	($DFF0A8)
;	CLR.W	($DFF0B8)
;	CLR.W	($DFF0C8)
;	CLR.W	($DFF0D8)
;	MOVE.W	#15,($DFF096)
;	RTS

Play
;lbC000E56	MOVEM.L	D0-D4/A0-A6,-(SP)
	LEA	(lbW003482,PC),A4
;	LEA	(lbL01F780),A0

	move.l	ModulePtr(PC),A0

	ADDQ.B	#1,(4,A4)
	MOVE.B	(4,A4),D0
	CMP.B	(A4),D0
	BLT.B	lbC000E78
	CLR.B	(4,A4)
	BRA.W	lbC000F0C

lbC000E78	LEA	(lbW003508,PC),A6
	LEA	($DFF0A0),A5
	BSR.W	lbC001214
	LEA	(lbW003524,PC),A6
	LEA	($DFF0B0),A5
	BSR.W	lbC001214
	LEA	(lbW003540,PC),A6
	LEA	($DFF0C0),A5
	BSR.W	lbC001214
	LEA	(lbW00355C,PC),A6
	LEA	($DFF0D0),A5
	BSR.W	lbC001214
	BRA.W	lbC00112C

lbC000EB4	MOVEQ	#0,D0
	MOVE.B	(4,A4),D0
	DIVS.W	#3,D0
	SWAP	D0
	CMPI.W	#0,D0
	BEQ.B	lbC000EE2
	CMPI.W	#2,D0
	BEQ.B	lbC000ED6
	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	LSR.B	#4,D0
	BRA.B	lbC000EE8

lbC000ED6	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	BRA.B	lbC000EE8

lbC000EE2	MOVE.W	($10,A6),D2
	BRA.B	lbC000F06

lbC000EE8	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.W	($10,A6),D1
	LEA	(lbW003436,PC),A0
	MOVEQ	#$24,D7
lbC000EF6	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0),D1
	BGE.B	lbC000F06
	ADDQ.L	#2,A0
	DBRA	D7,lbC000EF6
	RTS

lbC000F06
;	MOVE.W	D2,(6,A5)		; Period

	move.l	D0,-(SP)
	move.w	D2,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	RTS

lbC000F0C
;	LEA	(lbL01F780),A0

	move.l	ModulePtr(PC),A0

	MOVEA.L	A0,A3
	MOVEA.L	A0,A2
	ADDA.L	#$FFFFFFF8,A3
	ADDA.L	#$FA,A2
	ADDA.L	#$17E,A0
	MOVEQ	#0,D0
	MOVE.L	D0,D1
	MOVE.B	(1,A4),D0
	MOVE.B	(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.W	(2,A4),D1
	CLR.W	(6,A4)
	LEA	($DFF0A0),A5
	LEA	(lbW003508,PC),A6
	BSR.B	lbC000F74
	LEA	($DFF0B0),A5
	LEA	(lbW003524,PC),A6
	BSR.B	lbC000F74
	LEA	($DFF0C0),A5
	LEA	(lbW003540,PC),A6
	BSR.B	lbC000F74
	LEA	($DFF0D0),A5
	LEA	(lbW00355C,PC),A6
	BSR.B	lbC000F74
	BRA.W	lbC001052

lbC000F74	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	(2,A6),D2
	ANDI.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	ANDI.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ.B	lbC000FF8
	MOVEQ	#0,D3
	LEA	(lbL00348C,PC),A1
	MOVE.L	D2,D4
	SUBQ.L	#1,D2
	ASL.L	#2,D2
	MULU.W	#8,D4
	MOVE.L	(A1,D2.L),(4,A6)
	MOVE.W	(6,A3,D4.L),(8,A6)
	MOVE.W	(4,A3,D4.L),($12,A6)
	MOVE.W	(2,A3,D4.L),D3
	TST.W	D3
	BEQ.B	lbC000FE2
	MOVE.L	(4,A6),D2
	ADD.W	D3,D3
	ADD.L	D3,D2
	MOVE.L	D2,(10,A6)
	MOVE.W	(2,A3,D4.L),D0
	ADD.W	(A3,D4.L),D0
	MOVE.W	D0,(8,A6)
	MOVE.W	(A3,D4.L),(14,A6)
;	MOVE.W	($12,A6),(8,A5)			; volume

	move.l	D0,-(SP)
	move.w	$12(A6),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	BRA.B	lbC000FF8

lbC000FE2	MOVE.L	(4,A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,(10,A6)
	MOVE.W	(A3,D4.L),(14,A6)
;	MOVE.W	($12,A6),(8,A5)			; volume

	move.l	D0,-(SP)
	move.w	$12(A6),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

lbC000FF8	MOVE.W	(A6),D0
	ANDI.W	#$FFF,D0
	BEQ.W	lbC0012FE
	MOVE.B	(2,A6),D0
	ANDI.B	#15,D0
	CMPI.B	#3,D0
	BNE.B	lbC001018
	BSR.W	lbC001138
	BRA.W	lbC0012FE

lbC001018	MOVE.W	(A6),($10,A6)
	ANDI.W	#$FFF,($10,A6)
	MOVE.W	($14,A6),D0
;	MOVE.W	D0,($DFF096)			; DMA off

	bsr.w	PokeDMA

	CLR.B	($1B,A6)
;	MOVE.L	(4,A6),(A5)			; address
;	MOVE.W	(8,A6),(4,A5)			; length

	move.l	D0,-(SP)
	move.l	4(A6),D0
	bsr.w	PokeAdr
	move.w	8(A6),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	MOVE.W	($10,A6),D0
	ANDI.W	#$FFF,D0
;	MOVE.W	D0,(6,A5)			; period

	bsr.w	PokePer

	MOVE.W	($14,A6),D0
	OR.W	D0,(6,A4)
	BRA.W	lbC0012FE

lbC001052
;	MOVE.W	#$12C,D0
;lbC001056	DBRA	D0,lbC001056
;	TST.W	(lbW003508)
;	BEQ.B	lbC00106C
;	MOVE.L	#$FFFFFFFF,(lbW0016D8)
;lbC00106C	TST.W	(lbW00355C)
;	BEQ.B	lbC00107E
;	MOVE.L	#$FFFFFFFF,(lbW0016DC)
;lbC00107E	TST.W	(lbW003524)
;	BEQ.B	lbC00108E
;	MOVE.B	#$FF,(lbB0016D6)
;lbC00108E	TST.W	(lbW003540)
;	BEQ.B	lbC00109E
;	MOVE.B	#$9D,(lbB0016D7)
lbC00109E	MOVE.W	(6,A4),D0
	ORI.W	#$8000,D0
;	MOVE.W	D0,($DFF096)			; DMA on

	bsr.w	PokeDMA

;	MOVE.W	#$12C,D0
;lbC0010B0	DBRA	D0,lbC0010B0
;	LEA	($DFF000),A5			; here

	lea	$DFF0D0,A5

	LEA	(lbW00355C,PC),A6
;	MOVE.L	(10,A6),($D0,A5)		; address
;	MOVE.W	(14,A6),($D4,A5)		; length

	move.l	D0,-(SP)
	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0
	lea	-$10(A5),A5

	LEA	(lbW003540,PC),A6
;	MOVE.L	(10,A6),($C0,A5)
;	MOVE.W	(14,A6),($C4,A5)

	move.l	D0,-(SP)
	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0
	lea	-$10(A5),A5

	LEA	(lbW003524,PC),A6
;	MOVE.L	(10,A6),($B0,A5)
;	MOVE.W	(14,A6),($B4,A5)

	move.l	D0,-(SP)
	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0
	lea	-$10(A5),A5

	LEA	(lbW003508,PC),A6
;	MOVE.L	(10,A6),($A0,A5)
;	MOVE.W	(14,A6),($A4,A5)

	move.l	D0,-(SP)
	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	ADDI.W	#$10,(2,A4)
	CMPI.W	#$400,(2,A4)
	BNE.B	lbC00112C
lbC001108	CLR.W	(2,A4)
	CLR.B	(5,A4)
	ADDQ.B	#1,(1,A4)
	ANDI.B	#$7F,(1,A4)
	MOVE.B	(1,A4),D1
;	CMP.B	(lbB01F878),D1

	move.l	ModulePtr(PC),A0
	cmp.b	248(A0),D1

	BNE.B	lbC00112C

	bsr.w	SongEnd

	MOVE.B	(8,A4),(1,A4)
lbC00112C	TST.B	(5,A4)
	BNE.B	lbC001108

	bsr.w	PATINFO

;	MOVEM.L	(SP)+,D0-D4/A0-A6
	RTS

lbC001138	MOVE.W	(A6),D2
	ANDI.W	#$FFF,D2
	MOVE.W	D2,($18,A6)
	MOVE.W	($10,A6),D0
	CLR.B	($16,A6)
	CMP.W	D0,D2
	BEQ.B	lbC001158
	BGE.B	lbC00115C
	MOVE.B	#1,($16,A6)
	RTS

lbC001158	CLR.W	($18,A6)
lbC00115C	RTS

lbC00115E	MOVE.B	(3,A6),D0
	BEQ.B	lbC00116C
	MOVE.B	D0,($17,A6)
	CLR.B	(3,A6)
lbC00116C	TST.W	($18,A6)
	BEQ.B	lbC00115C
	MOVEQ	#0,D0
	MOVE.B	($17,A6),D0
	TST.B	($16,A6)
	BNE.B	lbC00119E
	ADD.W	D0,($10,A6)
	MOVE.W	($18,A6),D0
	CMP.W	($10,A6),D0
	BGT.B	lbC001196
	MOVE.W	($18,A6),($10,A6)
	CLR.W	($18,A6)
lbC001196
;	MOVE.W	($10,A6),(6,A5)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	RTS

lbC00119E	SUB.W	D0,($10,A6)
	MOVE.W	($18,A6),D0
	CMP.W	($10,A6),D0
	BLT.B	lbC001196
	MOVE.W	($18,A6),($10,A6)
	CLR.W	($18,A6)
;	MOVE.W	($10,A6),(6,A5)			; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	RTS

lbC0011BE	MOVE.B	(3,A6),D0
	BEQ.B	lbC0011C8
	MOVE.B	D0,($1A,A6)
lbC0011C8	MOVE.B	($1B,A6),D0
	LEA	(lbW003416,PC),A4
	LSR.W	#2,D0
	ANDI.W	#$1F,D0
	MOVEQ	#0,D2
	MOVE.B	(A4,D0.W),D2
	MOVE.B	($1A,A6),D0
	ANDI.W	#15,D0
	MULU.W	D0,D2
	LSR.W	#6,D2
	MOVE.W	($10,A6),D0
	TST.B	($1B,A6)
	BMI.B	lbC0011F6
	ADD.W	D2,D0
	BRA.B	lbC0011F8

lbC0011F6	SUB.W	D2,D0
lbC0011F8
;	MOVE.W	D0,(6,A5)		; period

	bsr.w	PokePer

	MOVE.B	($1A,A6),D0
	LSR.W	#2,D0
	ANDI.W	#$3C,D0
	ADD.B	D0,($1B,A6)
	RTS

lbC00120C
;	MOVE.W	($10,A6),(6,A5)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	RTS

lbC001214	MOVE.W	(2,A6),D0
	ANDI.W	#$FFF,D0
	BEQ.B	lbC00120C
	MOVE.B	(2,A6),D0
	ANDI.B	#15,D0
	TST.B	D0
	BEQ.W	lbC000EB4
	CMPI.B	#1,D0
	BEQ.w	lbC00129A
	CMPI.B	#2,D0
	BEQ.W	lbC0012CC
	CMPI.B	#3,D0
	BEQ.W	lbC00115E
	CMPI.B	#4,D0
	BEQ.W	lbC0011BE
;	MOVE.W	($10,A6),(6,A5)			; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	CMPI.B	#10,D0
	BEQ.B	lbC001258
	RTS

lbC001258	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.B	lbC00127E
	ADD.W	D0,($12,A6)
	CMPI.W	#$40,($12,A6)
	BMI.B	lbC001276
	MOVE.W	#$40,($12,A6)
lbC001276
;	MOVE.W	($12,A6),(8,A5)		; volume

	move.l	D0,-(SP)
	move.w	$12(A6),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	RTS

lbC00127E	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	SUB.W	D0,($12,A6)
	BPL.B	lbC001292
	CLR.W	($12,A6)
lbC001292
;	MOVE.W	($12,A6),(8,A5)		; volume

	move.l	D0,-(SP)
	move.w	$12(A6),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	RTS

lbC00129A	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	SUB.W	D0,($10,A6)
	MOVE.W	($10,A6),D0
	ANDI.W	#$FFF,D0
	CMPI.W	#$71,D0
	BPL.B	lbC0012BE
	ANDI.W	#$F000,($10,A6)
	ORI.W	#$71,($10,A6)
lbC0012BE	MOVE.W	($10,A6),D0
	ANDI.W	#$FFF,D0
;	MOVE.W	D0,(6,A5)			; period

	bsr.w	PokePer

	RTS

lbC0012CC	CLR.W	D0
	MOVE.B	(3,A6),D0
	ADD.W	D0,($10,A6)
	MOVE.W	($10,A6),D0
	ANDI.W	#$FFF,D0
	CMPI.W	#$358,D0
	BMI.B	lbC0012F0
	ANDI.W	#$F000,($10,A6)
	ORI.W	#$358,($10,A6)
lbC0012F0	MOVE.W	($10,A6),D0
	ANDI.W	#$FFF,D0
;	MOVE.W	D0,(6,A5)			; period

	bsr.w	PokePer

	RTS

lbC0012FE	MOVE.B	(2,A6),D0
	ANDI.B	#15,D0
	CMPI.B	#14,D0
	BEQ.B	lbC001326
	CMPI.B	#13,D0
	BEQ.B	lbC001340
	CMPI.B	#11,D0
	BEQ.B	lbC001346
	CMPI.B	#12,D0
	BEQ.B	lbC001356
	CMPI.B	#15,D0
	BEQ.B	lbC00136C
	RTS

lbC001326	MOVE.B	(3,A6),D0
;	ANDI.B	#1,D0
;	ASL.B	#1,D0
;	ANDI.B	#$FD,($BFE001)
;	OR.B	D0,($BFE001)
;	RTS

	btst	#1,D0
	beq.w	LED_On
	bra.w	LED_Off

lbC001340	NOT.B	(5,A4)
	RTS

lbC001346	MOVE.B	(3,A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,(1,A4)
	NOT.B	(5,A4)

	bsr.w	SongEnd

	RTS

lbC001356	CMPI.B	#$40,(3,A6)
	BLE.B	lbC001364
	MOVE.B	#$40,(3,A6)
lbC001364
;	MOVE.B	(3,A6),(8,A5)			; 68040/060 bug !!!

	move.l	D0,-(SP)
	moveq	#0,D0
	move.b	3(A6),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	RTS

lbC00136C	MOVE.B	(3,A6),D0
	ANDI.W	#$1F,D0
	BEQ.B	lbC00137C
	CLR.B	(4,A4)
	MOVE.B	D0,(A4)
lbC00137C	RTS

lbW003416	dc.w	$18
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
lbW003436	dc.w	$358
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
	dc.w	0
	dc.w	0
lbW003482	dc.w	$600
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbL00348C	dc.l	0
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
lbW003508	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	1
	dc.w	0
	dc.w	0
	dc.w	0
lbW003524	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	2
	dc.w	0
	dc.w	0
	dc.w	0
lbW003540	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	4
	dc.w	0
	dc.w	0
	dc.w	0
lbW00355C	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	8
	dc.w	0
	dc.w	0
	dc.w	0


;lbL01F780
