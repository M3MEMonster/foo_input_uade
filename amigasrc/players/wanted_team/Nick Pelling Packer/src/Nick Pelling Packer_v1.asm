	******************************************************
	**** Nick Pelling Packer replayer for EaglePlayer ****
	****        all adaptions by Wanted Team,	  ****
	****      DeliTracker compatible (?) version	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Nick Pelling Packer player module V1.0 (1 Nov 2009)',0
	even

Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	EP_Get_ModuleInfo,Get_ModuleInfo
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_PatternInit,PatternInit
	dc.l	DTP_NextPatt,NextPattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt!EPB_LoadFast
	dc.l	0

PlayerName
	dc.b	'Nick Pelling Packer',0
Creator
	dc.b	'(c) 1992-93 by Nick Pelling,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	"NPP.",0
SampleName
	dc.b	"SMP.set",0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
SampleNames
lbL0061E6
	dc.l	0
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
****************************** EP_PatternInit *****************************
***************************************************************************

PATTERNINFO:
	DS.B	PI_Stripes	; This is the main structure

* Here you store the address of each "stripe" (track) for the current
* pattern so the PI engine can read the data for each row and send it
* to the CONVERTNOTE function you supply.  The engine determines what
* data needs to be converted by looking at the Pattpos and Modulo fields.

STRIPE1	DC.L	lbL005DDE
STRIPE2	DC.L	lbL005DDE+4
STRIPE3	DC.L	lbL005DDE+8
STRIPE4	DC.L	lbL005DDE+12

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
	MOVEQ.L	#125,D0
	MOVE.W	D0,PI_BPM(A0)		; Beats Per Minute
	RTS

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
	movem.l	D0/A0/A1,-(SP)

	lea	PATTERNINFO(PC),A0
	moveq	#0,D0
	move.b	lbB006203(PC),D0
	move.w	D0,PI_Songpos(A0)		; Position in Song

	move.l	lbL0061EA(PC),A1
	move.b	(A1,D0.W),D0
	move.w	D0,PI_Pattern(A0)		; Current Pattern
	move.w	lbW006210(PC),PI_Pattpos(A0)	; Current Position in Pattern
	move.b	lbB006201(PC),PI_Speed+1(A0)	; Speed Value
	movem.l	(SP)+,D0/A0/A1
	RTS

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SampleNames(PC),D0
	beq.b	return
	move.l	D0,A2

	lea	lbL005BEE(PC),A1
	moveq	#30,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A1),EPS_Adr(A3)		; sample address
	moveq	#0,D0
	move.w	4(A1),D0
	add.l	D0,D0
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.l	A2,EPS_SampleName(A3)		; sample name
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#22,EPS_MaxNameLen(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
NextByte
	tst.b	(A2)+
	bne.b	NextByte
	lea	16(A1),A1
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

NextPattern
	moveq	#0,D0
	move.b	lbB006203(PC),D0
	addq.b	#1,D0
	cmp.b	InfoBuffer+Length+3(PC),D0
	beq.b	MaxPos
	clr.b	lbB006208
	clr.w	lbW006210
	move.b	D0,lbB006203
	bsr.w	lbC0040CE
MaxPos
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	moveq	#0,D0
	move.b	lbB006203(PC),D0
	beq.b	MinPos
	subq.b	#1,D0
	clr.b	lbB006208
	clr.w	lbW006210
	move.b	D0,lbB006203
	bsr.w	lbC0040CE
MinPos
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

Get_ModuleInfo
	lea	InfoBuffer(PC),A0
	rts

LoadSize	=	4
Samples		=	12
Length		=	20
SamplesSize	=	28
Patterns	=	36
SongName	=	44

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Samples,0		;12
	dc.l	MI_Length,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Pattern,0		;52
	dc.l	MI_SongName,0		;60
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxSamples,31
	dc.l	MI_MaxPattern,64
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName2
	move.l	dtg_LoadFile(A5),A0
	jsr	(A0)
	tst.l	D0
	beq.b	ExtLoadOK
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.b	CopyName
	move.l	dtg_LoadFile(A5),A0
	jsr	(A0)
ExtLoadOK
	rts

CopyName
	movea.l	dtg_PathArrayPtr(A5),A0
loop1
	tst.b	(A0)+
	bne.s	loop1
	subq.l	#1,A0
	lea	SampleName(PC),A3
smp2
	move.b	(A3)+,(A0)+
	bne.s	smp2
	rts

CopyName2
	move.l	dtg_PathArrayPtr(A5),A0
loop
	tst.b	(A0)+
	bne.s	loop
	subq.l	#1,A0
	move.l	A0,A3
	move.l	dtg_FileArrayPtr(A5),A1
smp
	move.b	(A1)+,(A0)+
	bne.s	smp

	cmpi.b	#'N',(A3)
	beq.b	OK_1
	cmpi.b	#'n',(A3)
	bne.s	ExtError
OK_1
	cmpi.b	#'P',1(A3)
	beq.b	OK_2
	cmpi.b	#'p',1(A3)
	bne.s	ExtError
OK_2
	cmpi.b	#'P',2(A3)
	beq.b	OK_3
	cmpi.b	#'p',2(A3)
	bne.s	ExtError
OK_3
	cmpi.b	#'.',3(A3)
	bne.s	ExtError

	move.b	#'S',(A3)+
	move.b	#'M',(A3)+
	move.b	#'P',(A3)

	bra.b	ExtOK
ExtError
	clr.b	-2(A0)
ExtOK
	clr.b	-1(A0)
	rts

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#'COMP',(A0)+
	bne.b	fail
	tst.w	(A0)+
	bne.b	fail
	move.w	(A0),D1
	beq.b	fail
	cmp.w	#$110,D1
	bhi.b	fail
	cmp.w	#$10,D1
	blt.b	fail
	move.w	D1,D2
	and.w	#3,D1
	bne.b	fail
	move.l	dtg_ChkSize(A5),D1
	move.l	-10(A0,D2.W),D2
	cmp.l	D1,D2
	bhi.b	fail
	moveq	#0,D0
fail
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
	move.l	A5,(A6)+			; EagleBase

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	move.l	4(A0),D0
	lea	(A0,D0.L),A1
	move.l	A1,SongName(A4)
	lsr.l	#2,D0
	subq.l	#3,D0
	move.l	D0,Patterns(A4)
	move.l	8(A0),D1
	move.b	(A0,D1.L),Length+3(A4)
SkipName
	tst.b	(A1)+
	bne.b	SkipName
	move.l	A1,(A6)				;SampleNames
	add.l	8(A0),A0
	moveq	#0,D1
More
	tst.b	(A1)
	beq.b	Skippy
	addq.l	#1,D1
Skippy
	cmp.l	A0,A1
	beq.b	NoMore
	tst.b	(A1)+
	bne.b	Skippy
	cmp.l	A0,A1
	bne.b	More
NoMore
	move.l	D1,Samples(A4)

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	lbL004236(PC),A1
	move.l	A0,(A1)				; sample buffer
	add.l	D0,LoadSize(A4)
	move.w	(A0)+,D3
	beq.b	Corrupt
	cmp.w	#31,D3
	bhi.b	Corrupt
	move.w	D3,D1
	mulu.w	#30,D1
	addq.l	#2,D1
	subq.w	#1,D3
NextInfo
	moveq	#0,D2
	move.w	22(A0),D2
	add.l	D2,D2
	add.l	D2,D1
	lea	30(A0),A0
	dbf	D3,NextInfo
	cmp.l	D1,D0
	blt.b	Short
	move.l	D1,SamplesSize(A4)

	lea	lbL005BEE(PC),A0
	lea	lbL005DDE(PC),A1
Clear
	clr.l	(A0)+
	cmp.l	A0,A1
	bne.b	Clear

	move.w	lbL00577C(PC),D0
	bne.b	InitDone
	bsr.w	InitPlay
InitDone
	bsr.w	InitSamp

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

Corrupt
	moveq	#EPR_CorruptModule,D0
	rts

Short
	moveq	#EPR_ModuleTooShort,D0
	rts

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	movea.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.b	lbB006203(PC),D0
	rts

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
************************* DTP_Volume, DTP_Balance *************************
***************************************************************************
; Copy Volume and Balance Data to internal buffer

SetVolume
SetBalance
	move.w	dtg_SndLBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0				; durch 64
	move.w	D0,LeftVolume

	move.w	dtg_SndRBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0				; durch 64
	move.w	D0,RightVolume			; Right Volume
	rts

*------------------------------- Set All -------------------------------*

SetAll
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	(A1),(A0)
	move.w	4(A1),UPS_Voice1Len(A0)
	move.w	$22(A6),UPS_Voice1Per(A0)
	move.l	(A7)+,A0
	rts

***************************************************************************
****************************** EP_Voices **********************************
***************************************************************************

SetVoices
	lea	Voice1(pc),a0
	lea	StructAdr(pc),a1
	move.w	#$ffff,d1
	move.w	d1,(a0)+			Voice1=0 setzen
	btst	#0,d0
	bne.s	.NoVoice1
	clr.w	-2(a0)
	clr.w	$dff0a8
	clr.w	UPS_Voice1Vol(a1)
.NoVoice1
	move.w	d1,(a0)+			Voice2=0 setzen
	btst	#1,d0
	bne.s	.NoVoice2
	clr.w	-2(a0)
	clr.w	$dff0b8
	clr.w	UPS_Voice2Vol(a1)
.NoVoice2
	move.w	d1,(a0)+			Voice3=0 setzen
	btst	#2,d0
	bne.s	.NoVoice3
	clr.w	-2(a0)
	clr.w	$dff0c8
	clr.w	UPS_Voice3Vol(a1)
.NoVoice3
	move.w	d1,(a0)+			Voice4=0 setzen
	btst	#3,d0
	bne.s	.NoVoice4
	clr.w	-2(a0)
	clr.w	$dff0d8
	clr.w	UPS_Voice4Vol(a1)
.NoVoice4
	move.w	d0,UPS_DMACon(a1)
	moveq	#0,d0
	rts

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
	move.l	ModulePtr(PC),A0
	bra.w	Init

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
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt
	movem.l	D1-D7/A0-A6,-(SP)

	lea	StructAdr(PC),A0
	st	UPS_Enabled(A0)
	clr.w	UPS_Voice1Per(A0)
	clr.w	UPS_Voice2Per(A0)
	clr.w	UPS_Voice3Per(A0)
	clr.w	UPS_Voice4Per(A0)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)

	bsr.w	Play

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D1-D7/A0-A6
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

***************************************************************************
************************* Nick Pelling Packer player **********************
***************************************************************************

; Player from "Battletoads" (c) 1993 by Mindscape

;lbC003CB0	BSR.L	lbC003CCA
;	BSR.L	lbC004288
;	BSR.L	lbC003DB2
;	MOVEQ	#1,D0
;	RTS


;	BSR.L	lbC003D3E
;	BSR.L	lbC004118
;	RTS

;lbC003CCA	MOVE.W	#$7D,lbW00620A
;	MOVE.W	lbW00620A,lbW00620C
;	RTS

;lbC003CDE	MOVE.L	#$186A,D0
;	MOVE.W	4(SP),D1
;	DIVU.W	D1,D0
;	MOVE.W	D0,lbW00620A
;	MOVE.W	D0,lbW00620C
;	RTS

;lbL003CF8	dc.l	0
;lbL003CFC	dc.l	0
;lbW003D00	dc.w	0
;lbW003D02	dc.w	0
;lbW003D04	dc.w	$40

;lbC003D06	MOVE.W	4(SP),lbW003D04
;	RTS

;lbC003D0E	TST.L	4(SP)
;	BEQ.S	lbC003D3C
;	BSR.L	lbC004118
;	LEA	lbC003DE2(PC),A1
;	MOVEA.L	4(SP),A0
;	CMPI.L	#'COMP',(A0)
;	BNE.S	lbC003D2C
;	LEA	lbC003EA8(PC),A1
;lbC003D2C	JSR	(A1)
;	CLR.W	lbW003D00
;	CLR.W	lbW003D02
;	ST	lbB006209
;lbC003D3C	RTS

;lbC003D3E	CLR.B	lbB006209
;	CLR.L	lbL003CFC
;	CLR.L	lbL0043D6
;	CLR.B	lbW0043DC
;	CLR.B	lbB0043DB
;	BRA.L	lbC004118

;	TST.B	lbB006209
;	BEQ.S	lbC003D0E
;	MOVE.L	4(SP),D0
;	MOVE.L	D0,lbL003CFC
;	RTS

;	MOVE.L	4(SP),D0
;	CMP.L	lbL003CF8,D0
;	BEQ.S	lbC003D98
;	TST.B	lbB006209
;	BEQ.L	lbC003D98
;	CMP.L	lbL0043D6,D0
;	BEQ.S	lbC003D98
;	MOVE.L	D0,lbL0043D6
;	ST	lbW0043DC
;lbC003D98	RTS

;	BSR.S	lbC003D3E
;	RTS

;lbC003D9E	SUBQ.B	#1,lbB006200
;	BMI.S	lbC003DAA
;	BSR.L	lbC0043DE
;lbC003DAA	ADDQ.B	#1,lbB006200
;	RTS

InitPlay
;lbC003DB2	CLR.B	lbB006209
;	BSR.L	lbC003F42
	LEA	lbW0051FC(pc),A0
	LEA	lbL00577C(pc),A1
	MOVEQ	#$46,D0
	ADDA.W	D0,A0
	CLR.W	D1
lbC003DCE	CMP.W	(A0),D1
	BLS.S	lbC003DD6
	SUBQ.L	#2,A0
	SUBQ.W	#2,D0
lbC003DD6	MOVE.B	D0,(A1)+
	ADDQ.W	#1,D1
	CMPI.W	#$358,D1
	BLE.S	lbC003DCE
	RTS

;lbC003DE2	MOVEM.L	D2-D4/A0-A3/A5/A6,-(SP)
;	MOVE.L	A0,lbL003CF8
;	MOVE.L	$438(A0),D0
;	CMPI.L	#'M.K.',D0
;	BNE.S	lbC003E0E
;	MOVEQ	#$1F,D0
;	LEA	$14(A0),A1
;	LEA	$3B8(A0),A2
;	LEA	$43C(A0),A3
;	MOVE.B	$3B6(A0),D1
;	MOVE.B	$3B7(A0),D2
;	BRA.S	lbC003E24

;lbC003E0E	MOVEQ	#15,D0
;	LEA	$14(A0),A1
;	LEA	$1D8(A0),A2
;	LEA	$258(A0),A3
;	MOVE.B	$1D6(A0),D1
;	MOVE.B	$1D7(A0),D2
;lbC003E24	MOVE.L	A0,lbL0061DE		; module ptr
;	MOVE.L	A1,lbL0061E6			; sample info ptr
;	MOVE.L	A2,lbL0061EA			; song position
;	MOVE.L	A3,lbL0061EE			; patterns ptr
;	MOVE.W	D0,lbW0061FA			; number of samples
;	MOVE.B	D1,lbB0061FE			; song length
;	MOVE.B	D2,lbB0061FF			; song BPM
;	BSR.L	lbC003F42
;	BSR.L	lbC003FAC
;	BSR.L	lbC003FD2
;	ORI.B	#2,$BFE001
;	MOVE.B	#6,lbB006201
;	CLR.B	lbB006202
;	CLR.B	lbB006203
;	CLR.W	lbW006210
;	CLR.B	lbB006207
;	CLR.B	lbB006208
;	CLR.B	lbB006205
;	CLR.W	lbW00620E
;	CLR.B	lbB006204
;	BSR.L	lbC0040CE
;	BSR.L	lbC004118
;	MOVEM.L	(SP)+,D2-D4/A0-A3/A5/A6
;	RTS

Init
;lbC003EA8	MOVEM.L	D2-D4/A0-A3/A5/A6,-(SP)
;	MOVE.L	A0,lbL003CF8
;	MOVEQ	#$1F,D0
	MOVEA.L	A0,A2
	ADDA.L	8(A0),A2
	MOVE.B	(A2)+,D1
;	MOVEA.L	A0,A3
;	ADDA.L	4(A0),A3
;lbC003EC0	TST.B	(A3)+
;	BNE.S	lbC003EC0
	MOVE.L	A0,lbL0061DE			; COMP Ptr
;	MOVE.L	A1,lbL0061E2
	MOVE.L	A2,lbL0061EA			; song position
;	MOVE.L	A3,lbL0061E6			; sample names ptr
;	MOVE.W	D0,lbW0061FA			; number of samples
	MOVE.B	D1,lbB0061FE			; song length
	BSR.L	lbC003F42
;	BSR.L	lbC003FAC
;	BSR.L	lbC00400E
	ORI.B	#2,$BFE001
	MOVE.B	#6,lbB006201
	CLR.B	lbB006202
	CLR.B	lbB006203
	CLR.W	lbW006210
	CLR.B	lbB006207
	CLR.B	lbB006208
	CLR.B	lbB006205
	CLR.W	lbW00620E
	CLR.B	lbB006204
	BSR.L	lbC0040CE
	BSR.L	lbC004118
;	MOVEM.L	(SP)+,D2-D4/A0-A3/A5/A6
	RTS

lbC003F42	LEA	$DFF0A0,A0
	LEA	lbL005AD6(pc),A1
	MOVEQ	#3,D0
	MOVEQ	#1,D1
	MOVE.W	#$80,D2
	MOVEQ	#-1,D3
lbC003F58	MOVE.W	D1,$1E(A1)
	MOVE.W	D2,$20(A1)
	MOVE.L	D3,(A1)
	CLR.W	$24(A1)
	CLR.W	$26(A1)
	MOVE.W	#$8000,$28(A1)
	MOVE.W	#0,8(A0)
	MOVE.W	#$7C,$22(A1)
	MOVE.W	#$7C,6(A0)
	ADD.W	D1,D1
	ADD.W	D2,D2
	LEA	$10(A0),A0
	LEA	$46(A1),A1
	DBRA	D0,lbC003F58
	LEA	$DFF000,A0
	MOVE.W	#15,$96(A0)
	MOVE.W	#$780,$9A(A0)
	MOVE.W	#$780,$9C(A0)
	RTS

;lbC003FAC	MOVEA.L	lbL0061EA(pc),A1
;	MOVEQ	#$7F,D0
;	MOVEQ	#0,D1
;lbC003FB6	MOVE.L	D1,D2
;lbC003FB8	MOVE.B	(A1)+,D1
;	CMP.B	D2,D1
;	DBGT	D0,lbC003FB8
;	DBLE	D0,lbC003FB6
;	BLE.S	lbC003FC8
;	MOVE.L	D1,D2
;lbC003FC8	ADDQ.W	#1,D2
;	MOVE.W	D2,lbW0061FC
;	RTS

;lbC003FD2	MOVEA.L	lbL0061E6,A3
;	LEA	lbL005BEE,A2
;	MOVE.W	lbW0061FA,D4
;	SUBQ.W	#1,D4
;lbC003FE6	PEA	lbL00422E
;	PEA	(A3)
;	BSR.L	lbC0042F6
;	ADDQ.L	#8,SP
;	MOVEM.L	(lbL00422E),A0/A1
;	BSR.L	lbC00404E
;	LEA	$1E(A3),A3
;	LEA	$10(A2),A2
;	DBRA	D4,lbC003FE6
;	RTS

InitSamp
lbC00400E	MOVEA.L	lbL0061E6(pc),A3
	LEA	lbL005BEE(pc),A2
;	MOVE.W	lbW0061FA,D4
;	SUBQ.W	#1,D4

	moveq	#30,D4

lbC004022	TST.B	(A3)
	BEQ.S	lbC004040
	PEA	lbL00422E
	PEA	(A3)
	BSR.L	lbC0042F6
	ADDQ.L	#8,SP
	MOVEM.L	(lbL00422E),A0/A1
	BSR.L	lbC00404E
lbC004040	TST.B	(A3)+
	BNE.S	lbC004040
	LEA	$10(A2),A2
	DBRA	D4,lbC004022
	RTS

lbC00404E	MOVEM.L	D2/A3,-(SP)
	MOVE.L	A0,D0
	BEQ.S	lbC00407C
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.W	$16(A0),D0
;	MOVE.W	$1C(A0),D1
	MOVE.W	$1A(A0),D2
	MOVE.L	A1,(A2)
	MOVE.W	D0,4(A2)

	bclr	#7,$18(A0)
	beq.b	NoAdd
	add.l	D0,D0
	subq.l	#2,D0
	move.l	A1,A3
NextAdd
	move.b	(A3)+,D1
	add.b	D1,(A3)
	dbf	D0,NextAdd
NoAdd
	move.w	$1C(A0),D1

	CMPI.W	#4,D1
	BCS.S	lbC00409A
	ADD.L	D2,D2
	LEA	0(A1,D2.L),A3
	BRA.S	lbC0040A0

lbC00407C	SUBA.L	A3,A3
	MOVEQ	#2,D0
	MOVE.L	A3,(A2)
	MOVE.W	D0,4(A2)
	MOVE.L	A3,6(A2)
	MOVE.W	D0,10(A2)
	MOVE.W	A3,12(A2)
	MOVE.W	A3,14(A2)
	BRA.L	lbC0040C8

lbC00409A	CLR.L	(A1)			; warning check sample length!!!
	MOVEA.L	A1,A3
	MOVEQ	#2,D1
lbC0040A0	MOVE.L	A3,6(A2)
	MOVE.W	D1,10(A2)
	CLR.W	D0
	MOVE.B	$19(A0),D0
	CMPI.W	#$40,D0
	BCS.S	lbC0040B6
	MOVEQ	#$40,D0
lbC0040B6	MOVE.W	D0,12(A2)
	MOVEQ	#15,D0
	AND.B	$18(A0),D0
	MULU.W	#$48,D0
	MOVE.W	D0,14(A2)
lbC0040C8	MOVEM.L	(SP)+,D2/A3
	RTS

lbC0040CE	MOVEA.L	lbL0061DE(pc),A0
	MOVEA.L	lbL0061EA(pc),A1
	MOVEQ	#0,D0
	MOVE.B	lbB006203(pc),D0
	MOVE.B	0(A1,D0.W),D0
;	CMPI.L	#'COMP',(A0)
;	BEQ.S	lbC004102
;	SWAP	D0
;	LSR.L	#6,D0
;	MOVEA.L	lbL0061EE,A0
;	ADDA.L	D0,A0
;	MOVE.L	A0,lbL0061F2
;	RTS

lbC004102	ASL.W	#2,D0
	ADDA.L	12(A0,D0.W),A0
	LEA	lbL005DDE(pc),A1
	MOVE.L	A1,lbL0061F2
	BRA.L	lbC004F9E

lbC004118	LEA	$DFF000,A0
	MOVE.W	#15,$96(A0)
	CLR.W	D0
	MOVE.W	D0,$AA(A0)
	MOVE.W	D0,$BA(A0)
	MOVE.W	D0,$CA(A0)
	MOVE.W	D0,$DA(A0)
	MOVE.W	#$780,$9A(A0)
	MOVE.W	#$780,$9C(A0)
	RTS

;lbC004144	MOVEM.L	D2-D4,-(SP)
;	LEA	lbL005AD6,A0
;	SUBA.L	A1,A1
;	MOVEQ	#3,D2
;lbC004152	LSR.W	#1,D0
;	BCC.S	lbC004174
;	CMP.W	$28(A0),D1
;	BLT.S	lbC004174
;	MOVE.L	A1,D3
;	BNE.S	lbC004168
;	MOVEA.L	A0,A1
;	MOVE.W	$28(A0),D4
;	BRA.S	lbC004174

;lbC004168	MOVE.W	$28(A0),D3
;	CMP.W	D4,D3
;	BGE.S	lbC004174
;	MOVEA.L	A0,A1
;	MOVE.W	D3,D4
;lbC004174	LEA	$46(A0),A0
;	DBRA	D2,lbC004152
;	MOVE.L	A1,D0
;	MOVEM.L	(SP)+,D2-D4
;	RTS

;	MOVEM.L	D2/A2/A3,-(SP)
;	MOVEA.L	$10(SP),A0
;	TST.L	(A0)+
;	BEQ.L	lbC004216
;	TST.L	(A0)+
;	BEQ.L	lbC004216
;	MOVE.W	$1C(SP),D0
;	MOVE.W	$1A(SP),D1
;	TST.B	lbB006209
;	BNE.S	lbC0041AA
;	MOVEQ	#-1,D0
;lbC0041AA	BSR.S	lbC004144
;	TST.L	D0
;	BEQ.S	lbC004216
;	MOVEA.L	D0,A3
;	LEA	$2A(A3),A2
;	MOVEA.L	$10(SP),A0
;	MOVEM.L	(A0),A0/A1
;	CLR.B	$3A(A3)
;	MOVE.W	#$FFFF,$26(A3)
;	MOVE.W	$18(SP),12(A3)
;	MOVE.W	$1A(SP),$28(A3)
;	MOVE.W	$16(SP),D2
;	CMPI.W	#$80,D2
;	BCS.S	lbC0041E0
;	MOVEQ	#$40,D2
;lbC0041E0	MOVEQ	#0,D0
;	MOVE.B	$18(A0),D0
;	BNE.S	lbC0041EA
;	MOVEQ	#8,D0
;lbC0041EA	MULU.W	#$3E8,D0
;	MOVE.L	#$369E9A,D1
;	DIVU.W	D0,D1
;	MOVE.W	D1,$22(A3)
;	MOVE.W	D1,$10(A3)
;	BSR.L	lbC00404E
;	CLR.W	14(A2)
;	MOVE.L	A2,4(A3)
;	ST	$3A(A3)
;	MOVE.W	$14(SP),$26(A3)
;	MOVE.L	A3,D0
;lbC004216	MOVEM.L	(SP)+,D2/A2/A3
;	RTS

;	MOVE.L	4(SP),D0
;	BEQ.S	lbC00422C
;	MOVEA.L	D0,A0
;	CLR.B	$3A(A0)
;	CLR.W	$26(A0)
;lbC00422C	RTS

lbL00422E	dc.l	0
	dc.l	0
lbL004236	dc.l	0
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
;	dc.l	0
;	dc.l	0
;	dc.l	0
;lbW004286	dc.w	0

;lbC004288	CLR.W	lbW004286
;	RTS

;lbC00428E	MOVEA.L	4(SP),A0
;	BSR.L	lbC004388
;	MOVE.W	lbW004286,D0
;	CMPI.W	#$14,D0
;	BCC.S	lbC0042C6
;	LEA	lbL004236,A0
;	MOVEA.L	4(SP),A1
;	MOVE.W	D0,D1
;	SUBQ.W	#1,D1
;	BMI.S	lbC0042B8
;lbC0042AE	CMPA.L	(A0)+,A1
;	DBEQ	D1,lbC0042AE
;	BEQ.L	lbC0042C6
;lbC0042B8	LEA	lbL004236,A0
;	ASL.W	#2,D0
;	MOVE.L	A1,0(A0,D0.W)
;	ADDQ.W	#1,lbW004286
;lbC0042C6	RTS

;	MOVE.W	lbW004286,D0
;	BEQ.S	lbC0042F4
;	LEA	lbL004236,A0
;	MOVE.L	4(SP),D1
;	SUBQ.W	#1,D0
;lbC0042D8	CMP.L	(A0)+,D1
;	DBEQ	D0,lbC0042D8
;	BNE.S	lbC0042F4
;	LEA	-4(A0),A1
;	SUBQ.W	#1,D0
;	BMI.S	lbC0042EE
;lbC0042E8	MOVE.L	(A0)+,(A1)+
;	DBRA	D0,lbC0042E8
;lbC0042EE	CLR.L	(A1)
;	SUBQ.W	#1,lbW004286
;lbC0042F4	RTS

lbC0042F6	MOVEM.L	D2/A2/A3/A5/A6,-(SP)
;	MOVE.W	lbW004286,D0
;	BEQ.S	lbC004378
	MOVEA.L	$18(SP),A1
	TST.B	(A1)
	BEQ.S	lbC004378
	LEA	lbL004236(pc),A0
;	SUBQ.W	#1,D0
lbC00430E	MOVEA.L	(A0)+,A2
	MOVE.W	(A2)+,D1
	MOVEQ	#$1E,D2
	MULU.W	D1,D2
	LEA	0(A2,D2.L),A3
	SUBQ.W	#1,D1
lbC00431C	MOVEA.L	A1,A5
	LEA	(A2),A6
lbC004320	MOVE.B	(A5)+,D2
	CMP.B	(A6)+,D2
	BNE.S	lbC004362
	TST.B	D2
	BNE.S	lbC004320
	TST.W	$16(A2)
	BNE.S	lbC004352
	MOVE.W	$1A(A2),D1
	MOVEA.L	-(A0),A2
	MOVEQ	#$1E,D2
	MULU.W	(A2)+,D2
	LEA	0(A2,D2.L),A3
	BRA.S	lbC00434A

lbC004340	MOVEQ	#0,D2
	MOVE.W	$16(A2),D2
	ADD.L	D2,D2
	ADDA.L	D2,A3
lbC00434A	LEA	$1E(A2),A2
	DBRA	D1,lbC004340
lbC004352	MOVEA.L	$1C(SP),A0
	MOVE.L	A2,(A0)
	MOVE.L	A3,4(A0)
	MOVEM.L	(SP)+,D2/A2/A3/A5/A6
	RTS

lbC004362	MOVEQ	#0,D2
	MOVE.W	$16(A2),D2
	ADD.L	D2,D2
	ADDA.L	D2,A3
	LEA	$1E(A2),A2
	DBRA	D1,lbC00431C
;	DBRA	D0,lbC00430E
lbC004378	MOVEA.L	$1C(SP),A0
	CLR.L	(A0)
	CLR.L	4(A0)
	MOVEM.L	(SP)+,D2/A2/A3/A5/A6
	RTS

;lbC004388	MOVEM.L	D2/D3/A2,-(SP)
;	MOVE.L	A0,D0
;	BEQ.S	lbC0043D0
;	MOVE.W	(A0)+,D0
;	MOVEQ	#$1E,D1
;	MULU.W	D0,D1
;	LEA	0(A0,D1.L),A1
;	SUBQ.W	#1,D0
;lbC00439C	MOVEQ	#0,D1
;	MOVE.W	$16(A0),D1
;	ADD.L	D1,D1
;	BCLR	#7,$18(A0)
;	BEQ.S	lbC0043C6
;	TST.L	D1
;	BEQ.S	lbC0043C6
;	MOVEA.L	A1,A2
;	MOVE.L	D1,D2
;	SUBQ.L	#2,D2
;lbC0043B6	MOVE.B	(A2)+,D3
;	ADD.B	D3,(A2)
;	DBRA	D2,lbC0043B6
;	SUBI.L	#$10000,D2
;	BGE.S	lbC0043B6
;lbC0043C6	ADDA.L	D1,A1
;	LEA	$1E(A0),A0
;	DBRA	D0,lbC00439C
;lbC0043D0	MOVEM.L	(SP)+,D2/D3/A2
;	RTS

;lbL0043D6	dc.l	0
;lbB0043DA	dc.b	0
;lbB0043DB	dc.b	0
;lbW0043DC	dc.w	0

Play
;lbC0043DE	MOVEM.L	D0-D4/A0-A2/A5/A6,-(SP)
	CLR.W	lbW006212
;	CLR.B	lbB0043DA
;	TST.B	lbB006209
;	BEQ.L	lbC0045AA
;	MOVE.W	lbW00620A,D0
;	SUB.W	D0,lbW00620C
;	BGT.S	lbC004418
lbC004404	BSR.L	lbC0045EC
;	TST.B	lbB0043DA
;	BNE.S	lbC004422
;	ADDI.W	#$7D,lbW00620C
;	BLE.S	lbC004404
lbC004418	BSR.L	lbC004484
;lbC00441C	MOVEM.L	(SP)+,D0-D4/A0-A2/A5/A6
	RTS

;lbC004422	TST.B	lbW0043DC
;	BNE.S	lbC00443E
;	CLR.B	lbB0043DB
;	MOVE.L	lbL003CFC(pc),D0
;	BNE.S	lbC00446C
;	MOVE.W	#$FFFF,lbW003D02
;	BSR.L	lbC003D3E
;	BRA.S	lbC00441C

;lbC00443E	TST.B	lbB0043DB
;	BNE.S	lbC004450
;	TST.L	lbL003CFC
;	BNE.S	lbC004450
;	MOVE.L	lbL003CF8,lbL003CFC
;lbC004450	MOVE.L	lbL0043D6(pc),-(SP)
;	CLR.L	lbL003CF8
;	CLR.L	lbL0043D6
;	BSR.L	lbC003D0E
;	ADDQ.L	#4,SP
;	CLR.B	lbW0043DC
;	ST	lbB0043DB
;	BRA.S	lbC004418

;lbC00446C	CLR.L	lbL003CFC
;	MOVE.L	D0,-(SP)
;	BSR.L	lbC003D0E
;	ADDQ.L	#4,SP
;	BRA.S	lbC004418

;lbC00447A	BSR.L	lbC004484
;	MOVEM.L	(SP)+,D0-D4/A0-A2/A5/A6
;	RTS

lbC004484	LEA	$DFF000,A0
	LEA	lbL005AD6(pc),A1
	MOVE.W	$24(A1),D0
;	MULU.W	12(A1),D0

	lea	StructAdr+UPS_Voice1Vol(PC),A2
	mulu.w	LeftVolume(PC),D0
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D0
Voice1On

	LSR.W	#6,D0
	MOVE.W	D0,$A8(A0)			; volume

	move.w	D0,(A2)

	MOVE.W	$22(A1),$A6(A0)			; period
	LEA	lbL005B1C(pc),A1
	MOVE.W	$24(A1),D0
;	MULU.W	12(A1),D0

	lea	StructAdr+UPS_Voice2Vol(PC),A2
	mulu.w	RightVolume(PC),D0
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D0
Voice2On

	LSR.W	#6,D0
	MOVE.W	D0,$B8(A0)			; volume

	move.w	D0,(A2)

	MOVE.W	$22(A1),$B6(A0)			; period
	LEA	lbL005B62(pc),A1
	MOVE.W	$24(A1),D0
;	MULU.W	12(A1),D0

	lea	StructAdr+UPS_Voice3Vol(PC),A2
	mulu.w	RightVolume(PC),D0
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D0
Voice3On

	LSR.W	#6,D0
	MOVE.W	D0,$C8(A0)			; volume

	move.w	D0,(A2)

	MOVE.W	$22(A1),$C6(A0)			; period
	LEA	lbL005BA8(pc),A1
	MOVE.W	$24(A1),D0
;	MULU.W	12(A1),D0

	lea	StructAdr+UPS_Voice4Vol(PC),A2
	mulu.w	LeftVolume(PC),D0
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D0
Voice4On

	LSR.W	#6,D0
	MOVE.W	D0,$D8(A0)			; volume

	move.w	D0,(A2)

	MOVE.W	$22(A1),$D6(A0)			; period
	MOVE.W	lbW006212(pc),D0
	BEQ.L	lbC0045A8
	BSET	#15,D0
;	LEA	$BFD800,A0
;	MOVEQ	#7,D3
;	MOVE.B	(A0),D1
;lbC00450A	MOVEQ	#1,D2
;	DIVU.W	D2,D2
;	DIVU.W	D2,D2
;lbC004510	MOVEQ	#1,D2
;	DIVU.W	D2,D2
;	MOVE.B	(A0),D2
;	CMP.B	D1,D2
;	BEQ.S	lbC004510
;	MOVE.B	D2,D1
;	DBRA	D3,lbC00450A
;	LEA	$DFF000,A0

	bsr.w	DMAWait

	MOVE.W	D0,$96(A0)			; DMA on

	bsr.w	DMAWait

;	LEA	$BFD800,A0
;	MOVEQ	#1,D3
;	MOVE.B	(A0),D1
;lbC004534	MOVEQ	#1,D2
;	DIVU.W	D2,D2
;	DIVU.W	D2,D2
;lbC00453A	MOVEQ	#1,D2
;	DIVU.W	D2,D2
;	MOVE.B	(A0),D2
;	CMP.B	D1,D2
;	BEQ.S	lbC00453A
;	MOVE.B	D2,D1
;	DBRA	D3,lbC004534
;	LEA	$DFF000,A0

	LSR.W	#1,D0
	BCC.S	lbC004566
	MOVEA.L	lbL005ADA(pc),A1
	MOVE.L	6(A1),$A0(A0)			; address
	MOVE.W	10(A1),$A4(A0)			; length
lbC004566	LSR.W	#1,D0
	BCC.S	lbC00457C
	MOVEA.L	lbL005B20(pc),A1
	MOVE.L	6(A1),$B0(A0)			; address
	MOVE.W	10(A1),$B4(A0)			; length
lbC00457C	LSR.W	#1,D0
	BCC.S	lbC004592
	MOVEA.L	lbL005B66(pc),A1
	MOVE.L	6(A1),$C0(A0)			; address
	MOVE.W	10(A1),$C4(A0)			; length
lbC004592	LSR.W	#1,D0
	BCC.S	lbC0045A8
	MOVEA.L	lbL005BAC(pc),A1
	MOVE.L	6(A1),$D0(A0)			; address
	MOVE.W	10(A1),$D4(A0)			; length
lbC0045A8	RTS

;lbC0045AA	LEA	$DFF0A0,A5
;	LEA	lbL005AD6,A6
;	BSR.L	lbC0045E2
;	LEA	$10(A5),A5
;	LEA	$46(A6),A6
;	BSR.L	lbC0045E2
;	LEA	$10(A5),A5
;	LEA	$46(A6),A6
;	BSR.L	lbC0045E2
;	LEA	$10(A5),A5
;	LEA	$46(A6),A6
;	BSR.L	lbC0045E2
;	BRA.L	lbC00447A

;lbC0045E2	TST.W	$26(A6)
;	BNE.L	lbC0048E8
;	RTS

lbC0045EC	ADDQ.B	#1,lbB006202
	MOVE.B	lbB006202(pc),D0
	CMP.B	lbB006201(pc),D0
	BCS.S	lbC004614
	CLR.B	lbB006202
	TST.B	lbB006208
	BEQ.S	lbC004662
	BSR.S	lbC00461A
	BRA.L	lbC0047F4

lbC004614	BSR.S	lbC00461A
	BRA.L	lbC0048CE

lbC00461A	LEA	$DFF0A0,A5
	LEA	lbL005AD6(pc),A6
	BSR.L	lbC004970
;	TST.B	lbB0043DA
;	BNE.S	lbC004660
	LEA	$10(A5),A5
	LEA	$46(A6),A6
	BSR.L	lbC004970
;	TST.B	lbB0043DA
;	BNE.S	lbC004660
	LEA	$10(A5),A5
	LEA	$46(A6),A6
	BSR.L	lbC004970
;	TST.B	lbB0043DA
;	BNE.S	lbC004660
	LEA	$10(A5),A5
	LEA	$46(A6),A6
	BRA.L	lbC004970

;lbC004660	RTS

lbC004662	MOVEA.L	lbL0061F2(pc),A2
	MOVE.W	lbW006210(pc),D1
	ASL.W	#4,D1
	ADDA.W	D1,A2
	LEA	$DFF0A0,A5
	LEA	lbL005AD6(pc),A6
	BSR.S	lbC0046B4
;	TST.B	lbB0043DA
;	BNE.S	lbC0046B0
	LEA	$10(A5),A5
	LEA	$46(A6),A6
	BSR.S	lbC0046B4
;	TST.B	lbB0043DA
;	BNE.S	lbC0046B0
	LEA	$10(A5),A5
	LEA	$46(A6),A6
	BSR.S	lbC0046B4
;	TST.B	lbB0043DA
;	BNE.S	lbC0046B0
	LEA	$10(A5),A5
	LEA	$46(A6),A6
	BSR.S	lbC0046B4
lbC0046B0	BRA.L	lbC0047F4

lbC0046B4	TST.L	(A6)
	BNE.S	lbC0046BE
	MOVE.W	$10(A6),$22(A6)
lbC0046BE	MOVE.L	(A2)+,D0
	MOVE.L	D0,(A6)
;	TST.W	$26(A6)
;	BNE.L	lbC0048E8
	SWAP	D0
	ROL.W	#4,D0
	ROL.L	#4,D0
	EXT.W	D0
	BEQ.L	lbC0046F8
	SUBQ.W	#1,D0
	LEA	lbL005BEE(pc),A1
	ASL.W	#4,D0
	ADDA.W	D0,A1
	MOVE.L	A1,4(A6)
	MOVE.W	12(A1),D0
	MOVE.W	D0,14(A6)
	MOVE.W	D0,$24(A6)
	MOVE.W	14(A1),$16(A6)
lbC0046F8	MOVE.W	(A6),D0
	ANDI.W	#$FFF,D0
	BEQ.L	lbC004C70
	MOVEQ	#15,D0
	AND.B	2(A6),D0
	ADD.W	D0,D0
	MOVE.W	lbW004712(PC,D0.W),D0
	JMP	lbW004712(PC,D0.W)

lbW004712	dc.w	lbC004754-lbW004712
	dc.w	lbC004754-lbW004712
	dc.w	lbC004754-lbW004712
	dc.w	lbC00474C-lbW004712
	dc.w	lbC004754-lbW004712
	dc.w	lbC00474C-lbW004712
	dc.w	lbC004754-lbW004712
	dc.w	lbC004754-lbW004712
	dc.w	lbC004754-lbW004712
	dc.w	lbC004732-lbW004712
	dc.w	lbC004754-lbW004712
	dc.w	lbC004754-lbW004712
	dc.w	lbC004754-lbW004712
	dc.w	lbC004754-lbW004712
	dc.w	lbC00473A-lbW004712
	dc.w	lbC004754-lbW004712

lbC004732	BSR.L	lbC004C70
	BRA.L	lbC004754

lbC00473A	MOVEQ	#-$10,D0
	AND.B	3(A6),D0
	CMPI.B	#$50,D0
	BNE.S	lbC004754
	BSR.L	lbC004E6C
	BRA.S	lbC004754

lbC00474C	BSR.L	lbC004A16
	BRA.L	lbC004C70

lbC004754	MOVE.W	(A6),D1
	ANDI.W	#$FFF,D1
	LEA	lbL00577C(pc),A0
	MOVE.B	0(A0,D1.W),D1
	EXT.W	D1
	MOVE.W	D1,$1A(A6)
	ADD.W	$16(A6),D1
	MOVE.W	D1,$1C(A6)
	LEA	lbW0051FC(pc),A0
	MOVE.W	0(A0,D1.W),D1
	MOVE.W	D1,$10(A6)
	MOVE.W	D1,$22(A6)
;	MOVE.W	lbW003D04,12(A6)
	MOVE.W	2(A6),D0
	ANDI.W	#$FF0,D0
	CMPI.W	#$ED0,D0
	BEQ.S	lbC0047E4
	LEA	$DFF000,A0
	MOVEA.L	4(A6),A1
	MOVE.L	(A1),(A5)			; address
	MOVE.W	4(A1),4(A5)			; length
	MOVE.W	$22(A6),6(A5)			; period
	MOVE.W	#0,8(A5)			; volume

	bsr.w	SetAll

	MOVE.W	$1E(A6),D0
	MOVE.W	D0,$96(A0)			; DMA off
	OR.W	D0,lbW006212
	CLR.W	$18(A6)
	MOVE.B	$41(A6),D1
	BTST	#2,D1
	BNE.S	lbC0047D6
	CLR.B	$3E(A6)
lbC0047D6	BTST	#6,D1
	BNE.S	lbC0047E0
	CLR.B	$40(A6)
lbC0047E0	BRA.L	lbC004C70

lbC0047E4	CMPI.B	#$10,$42(A6)
	BCS.S	lbC0047F0
	BSR.L	lbC004F9C
lbC0047F0	BRA.L	lbC004F50

lbC0047F4	ADDQ.W	#1,lbW006210
	MOVE.B	lbB006207(pc),D0
	BEQ.S	lbC00480E
	MOVE.B	D0,lbB006208
	CLR.B	lbB006207
lbC00480E	TST.B	lbB006208
	BEQ.S	lbC004824
	SUBQ.B	#1,lbB006208
	BEQ.S	lbC004824
	SUBQ.W	#1,lbW006210
lbC004824	TST.B	lbB006205
	BEQ.S	lbC004842
	CLR.B	lbB006205
	MOVE.W	lbW00620E(pc),lbW006210
	CLR.W	lbW00620E
lbC004842
;	MOVEQ	#15,D0
;	AND.W	lbW006210,D0
;	BNE.S	lbC004850
;	ADDQ.W	#1,lbW003D00
;lbC004850	MOVEQ	#$1F,D0
;	AND.W	lbW006210,D0
;	BNE.S	lbC004882
;	TST.B	lbW0043DC
;	BNE.S	lbC004872
;	TST.B	lbB0043DB
;	BNE.S	lbC004882
;	MOVE.L	lbL003CFC,D0
;	BEQ.S	lbC004882
;	CMP.L	lbL003CF8,D0
;	BEQ.S	lbC004882
;lbC004872	ST	lbB0043DA
;	RTS

;lbC004878	CLR.B	lbB0043DB
;	ST	lbB0043DA
;	RTS

lbC004882	CMPI.W	#$40,lbW006210
	BCS.S	lbC0048CE
lbC00488C	MOVE.W	lbW00620E(pc),lbW006210
	CLR.W	lbW00620E
	CLR.B	lbB006204
	ADDQ.B	#1,lbB006203
	ANDI.B	#$7F,lbB006203
	MOVE.B	lbB006203(pc),D1
	CMP.B	lbB0061FE(pc),D1
	BCS.S	lbC0048CA

	bsr.w	SongEnd

;	TST.B	lbB0043DB
;	BNE.S	lbC004878
	CLR.B	lbB006203
lbC0048CA	BSR.L	lbC0040CE
lbC0048CE	TST.B	lbB006204
	BEQ.S	lbC0048E6
	MOVEQ	#15,D0
	AND.W	lbW006210(pc),D0
;	BEQ.S	lbC0048E4
;	ADDQ.W	#1,lbW003D00
lbC0048E4	BRA.S	lbC00488C

lbC0048E6

	bsr.w	PATINFO

	RTS

;lbC0048E8	TST.B	$3A(A6)
;	BEQ.S	lbC00492A
;	CLR.B	$3A(A6)
;	LEA	$DFF000,A0
;	MOVEA.L	4(A6),A1
;	MOVE.L	(A1),(A5)
;	MOVE.W	4(A1),4(A5)
;	MOVE.W	$22(A6),6(A5)
;	MOVE.W	#0,8(A5)
;	MOVE.W	$1E(A6),D0
;	MOVE.W	D0,$96(A0)
;	OR.W	D0,lbW006212
;	MOVE.W	12(A1),D0
;	MOVE.W	D0,14(A6)
;	MOVE.W	D0,$24(A6)
;lbC00492A	SUBQ.W	#1,$26(A6)
;	BEQ.S	lbC004952
;	CMPI.W	#8,lbW0062AC
;	BNE.S	lbC00496C
;	MOVE.W	$26(A6),D0
;	MOVE.W	D0,lbW00496E
;	CMPI.W	#0,D0
;	BEQ.S	lbC004952
;	CMPI.W	#$C8,D0
;	BPL.S	lbC004952
;	BRA.S	lbC00496C

;lbC004952	LEA	$DFF000,A0
;	MOVE.W	#$8000,$28(A6)
;	MOVE.W	$1E(A6),D0
;	MOVE.W	D0,$96(A0)
;	MOVE.W	#0,8(A0)
;lbC00496C	RTS

;lbW00496E	dc.w	0

lbC004970
;	TST.W	$26(A6)
;	BNE.L	lbC0048E8
	CMPI.B	#$10,$42(A6)
	BCS.S	lbC004984
	BSR.L	lbC004F9C
lbC004984	MOVEQ	#15,D0
	AND.B	2(A6),D0
	ADD.W	D0,D0
	MOVE.W	lbW004994(PC,D0.W),D0
	JMP	lbW004994(PC,D0.W)

lbW004994	dc.w	lbC0049CA-lbW004994
	dc.w	lbC004D3A-lbW004994
	dc.w	lbC004D7A-lbW004994
	dc.w	lbC004A52-lbW004994
	dc.w	lbC004AEC-lbW004994
	dc.w	lbC004B82-lbW004994
	dc.w	lbC004B8A-lbW004994
	dc.w	lbC0049B6-lbW004994
	dc.w	lbC0049B4-lbW004994
	dc.w	lbC0049B4-lbW004994
	dc.w	lbC0049C0-lbW004994
	dc.w	lbC0049B4-lbW004994
	dc.w	lbC0049B4-lbW004994
	dc.w	lbC0049B4-lbW004994
	dc.w	lbC004DBA-lbW004994
	dc.w	lbC0049B4-lbW004994

lbC0049B4	RTS

lbC0049B6	MOVE.W	$10(A6),$22(A6)
	BRA.L	lbC004B90

lbC0049C0	MOVE.W	$10(A6),$22(A6)
	BRA.L	lbC004C22

lbC0049CA	MOVE.B	3(A6),D1
	BEQ.S	lbC0049F2
	MOVE.W	$18(A6),D0
	ADDQ.W	#1,D0
	CMPI.W	#3,D0
	BCS.S	lbC0049DE
	CLR.W	D0
lbC0049DE	MOVE.W	D0,$18(A6)
	ADD.W	D0,D0
	MOVE.W	lbW0049EC(PC,D0.W),D0
	JMP	lbW0049EC(PC,D0.W)

lbW0049EC	dc.w	lbC0049FC-lbW0049EC
	dc.w	lbC0049F2-lbW0049EC
	dc.w	lbC0049FA-lbW0049EC

lbC0049F2	MOVE.W	$10(A6),$22(A6)
	RTS

lbC0049FA	LSR.B	#4,D1
lbC0049FC	LEA	lbW0051FC(pc),A0
	ANDI.W	#15,D1
	ADD.W	D1,D1
	ADD.W	$1C(A6),D1
	MOVE.W	0(A0,D1.W),D1
	MOVE.W	D1,$22(A6)
	RTS

lbC004A16	LEA	lbL00577C(pc),A0
	MOVE.W	(A6),D2
	ANDI.W	#$FFF,D2
	MOVEQ	#0,D1
	MOVE.B	0(A0,D2.W),D1
	ADD.W	$16(A6),D1
	LEA	lbW0051FC,A0
	MOVE.W	0(A0,D1.W),D2
	MOVE.W	D2,$12(A6)
	MOVEQ	#0,D1
	CMP.W	$10(A6),D2
	BEQ.S	lbC004A4C
	BGT.S	lbC004A46
	MOVEQ	#1,D1
lbC004A46	MOVE.B	D1,$3B(A6)
	RTS

lbC004A4C	CLR.W	$12(A6)
	RTS

lbC004A52	MOVE.B	3(A6),D0
	BEQ.S	lbC004A60
	MOVE.B	D0,$3C(A6)
	CLR.B	3(A6)
lbC004A60	TST.W	$12(A6)
	BEQ.L	lbC004AEA
	MOVEQ	#0,D0
	MOVE.B	$3C(A6),D0
	TST.B	$3B(A6)
	BNE.S	lbC004A8E
	ADD.W	D0,$10(A6)
	MOVE.W	$12(A6),D0
	CMP.W	$10(A6),D0
	BGT.S	lbC004AA6
	MOVE.W	$12(A6),$10(A6)
	CLR.W	$12(A6)
	BRA.S	lbC004AA6

lbC004A8E	SUB.W	D0,$10(A6)
	MOVE.W	$12(A6),D0
	CMP.W	$10(A6),D0
	BLT.S	lbC004AA6
	MOVE.W	$12(A6),$10(A6)
	CLR.W	$12(A6)
lbC004AA6	MOVE.W	$10(A6),D2
	MOVEQ	#15,D0
	AND.B	$42(A6),D0
	BEQ.S	lbC004AE6
	LEA	lbW0051FC(pc),A0
	ADDA.W	$1C(A6),A0
	CMP.W	(A0),D2
	BEQ.S	lbC004AE6
	BGT.S	lbC004AD4
	CMP.W	-2(A0),D2
	BGT.S	lbC004AE6
	MOVE.W	-(A0),D2
	SUBQ.W	#2,$1A(A6)
	SUBQ.W	#2,$1C(A6)
	BRA.S	lbC004AE6

lbC004AD4	CMP.W	2(A0),D2
	BLT.S	lbC004AE6
	MOVE.W	2(A0),D2
	ADDQ.W	#2,$1A(A6)
	ADDQ.W	#2,$1C(A6)
lbC004AE6	MOVE.W	D2,$22(A6)
lbC004AEA	RTS

lbC004AEC	MOVE.B	3(A6),D0
	BEQ.S	lbC004B16
	MOVE.B	$3D(A6),D2
	ANDI.B	#15,D0
	BEQ.S	lbC004B02
	ANDI.B	#$F0,D2
	OR.B	D0,D2
lbC004B02	MOVE.B	3(A6),D0
	ANDI.B	#$F0,D0
	BEQ.S	lbC004B12
	ANDI.B	#15,D2
	OR.B	D0,D2
lbC004B12	MOVE.B	D2,$3D(A6)
lbC004B16	MOVEQ	#$7C,D0
	AND.B	$3E(A6),D0
	LSR.W	#2,D0
	MOVEQ	#3,D2
	AND.B	$41(A6),D2
	BEQ.S	lbC004B2E
	SUBQ.B	#1,D2
	BEQ.S	lbC004B3A
	ST	D0
	BRA.S	lbC004B44

lbC004B2E	LEA	lbW0051CC(pc),A0
	MOVE.B	0(A0,D0.W),D0
	BRA.S	lbC004B44

lbC004B3A	LSL.B	#3,D0
	TST.B	$3E(A6)
	BPL.S	lbC004B44
	NOT.B	D0
lbC004B44	MOVEQ	#15,D2
	AND.B	$3D(A6),D2
	MULU.W	D0,D2
	LSR.W	#7,D2
	MOVE.W	$10(A6),D0
	TST.B	$3E(A6)
	BPL.S	lbC004B5A
	NEG.W	D2
lbC004B5A	ADD.W	D2,D0
	CMPI.W	#$7C,D0
	BGE.S	lbC004B66
	MOVEQ	#$7C,D0
	BRA.S	lbC004B70

lbC004B66	CMPI.W	#$358,D0
	BLE.S	lbC004B70
	MOVE.W	#$358,D0
lbC004B70	MOVE.W	D0,$22(A6)
	MOVEQ	#-$10,D0
	AND.B	$3D(A6),D0
	LSR.B	#2,D0
	ADD.B	D0,$3E(A6)
	RTS

lbC004B82	BSR.L	lbC004A60
	BRA.L	lbC004C22

lbC004B8A	BSR.S	lbC004B16
	BRA.L	lbC004C22

lbC004B90	MOVE.B	3(A6),D0
	BEQ.S	lbC004BBA
	MOVE.B	$3F(A6),D2
	ANDI.B	#15,D0
	BEQ.S	lbC004BA6
	ANDI.B	#$F0,D2
	OR.B	D0,D2
lbC004BA6	MOVE.B	3(A6),D0
	ANDI.B	#$F0,D0
	BEQ.S	lbC004BB6
	ANDI.B	#15,D2
	OR.B	D0,D2
lbC004BB6	MOVE.B	D2,$3F(A6)
lbC004BBA	MOVEQ	#$7C,D0
	AND.B	$40(A6),D0
	LSR.W	#2,D0
	MOVEQ	#$30,D2
	AND.B	$41(A6),D2
	BEQ.S	lbC004BD4
	CMPI.W	#$10,D2
	BEQ.S	lbC004BE0
	ST	D0
	BRA.S	lbC004BEA

lbC004BD4	LEA	lbW0051CC(pc),A0
	MOVE.B	0(A0,D0.W),D0
	BRA.S	lbC004BEA

lbC004BE0	ASL.B	#3,D0
	TST.B	$40(A6)
	BPL.S	lbC004BEA
	NOT.B	D0
lbC004BEA	MOVEQ	#15,D2
	AND.B	$3F(A6),D2
	MULU.W	D0,D2
	LSR.W	#6,D2
	MOVE.W	14(A6),D0
	TST.B	$40(A6)
	BPL.S	lbC004C00
	NEG.W	D2
lbC004C00	ADD.W	D2,D0
	TST.W	D0
	BPL.S	lbC004C08
	MOVEQ	#0,D0
lbC004C08	CMPI.W	#$40,D0
	BLE.S	lbC004C10
	MOVEQ	#$40,D0
lbC004C10	MOVE.W	D0,$24(A6)
	MOVEQ	#-$10,D0
	AND.B	$3F(A6),D0
	LSR.W	#2,D0
	ADD.B	D0,$40(A6)
	RTS

lbC004C22	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	CMPI.B	#$10,D0
	BCS.S	lbC004C4E
	LSR.B	#4,D0
	EXT.W	D0
lbC004C32	ADD.W	14(A6),D0
	TST.W	D0
	BPL.S	lbC004C3C
	MOVEQ	#0,D0
lbC004C3C	CMPI.W	#$40,D0
	BLE.S	lbC004C44
	MOVEQ	#$40,D0
lbC004C44	MOVE.W	D0,14(A6)
	MOVE.W	D0,$24(A6)
	RTS

lbC004C4E	ANDI.W	#15,D0
lbC004C52	NEG.W	D0
	ADD.W	14(A6),D0
	TST.W	D0
	BPL.S	lbC004C5E
	MOVEQ	#0,D0
lbC004C5E	CMPI.W	#$40,D0
	BLE.S	lbC004C66
	MOVEQ	#$40,D0
lbC004C66	MOVE.W	D0,14(A6)
	MOVE.W	D0,$24(A6)
	RTS

lbC004C70	CMPI.B	#$10,$42(A6)
	BCS.S	lbC004C7C
	BSR.L	lbC004F9C
lbC004C7C	MOVEQ	#15,D0
	AND.B	2(A6),D0
	ADD.W	D0,D0
	MOVE.W	lbW004C8C(PC,D0.W),D0
	JMP	lbW004C8C(PC,D0.W)

lbW004C8C	dc.w	lbC004CAC-lbW004C8C
	dc.w	lbC004CAC-lbW004C8C
	dc.w	lbC004CAC-lbW004C8C
	dc.w	lbC004CAC-lbW004C8C
	dc.w	lbC004CAC-lbW004C8C
	dc.w	lbC004CAC-lbW004C8C
	dc.w	lbC004CAC-lbW004C8C
	dc.w	lbC004CAC-lbW004C8C
	dc.w	lbC004CAC-lbW004C8C
	dc.w	lbC004CB4-lbW004C8C
	dc.w	lbC004CAC-lbW004C8C
	dc.w	lbC004CB6-lbW004C8C
	dc.w	lbC004CD2-lbW004C8C
	dc.w	lbC004CF0-lbW004C8C
	dc.w	lbC004DBA-lbW004C8C
	dc.w	lbC004D1E-lbW004C8C

lbC004CAC	MOVE.W	$10(A6),$22(A6)
	RTS

lbC004CB4	RTS

lbC004CB6	MOVEQ	#$7F,D0
	AND.B	3(A6),D0

	move.l	D1,-(SP)
	move.b	lbB006203(PC),D1
	addq.b	#1,D1
	cmp.b	InfoBuffer+Length+3(PC),D1
	bne.b	NoOne
	bsr.w	SongEnd
NoOne
	move.l	(SP)+,D1

	SUBQ.B	#1,D0
	MOVE.B	D0,lbB006203
	CLR.W	lbW00620E
	ST	lbB006204
	RTS

lbC004CD2	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	TST.W	D0
	BPL.S	lbC004CDE
	MOVEQ	#0,D0
lbC004CDE	CMPI.W	#$40,D0
	BLE.S	lbC004CE6
	MOVEQ	#$40,D0
lbC004CE6	MOVE.W	D0,14(A6)
	MOVE.W	D0,$24(A6)
	RTS

lbC004CF0	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LEA	lbW00567C(pc),A0
	MOVE.B	0(A0,D0.W),D0
	BMI.S	lbC004D10
	MOVE.W	D0,lbW00620E
	ST	lbB006204
	RTS

lbC004D10	CLR.W	lbW00620E
	ST	lbB006204
	RTS

lbC004D1E	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BEQ.S	lbC004D34
	CLR.B	lbB006202
	MOVE.B	D0,lbB006201
	RTS

lbC004D34
;	ST	lbB0043DA

	bsr.w	SongEnd

	RTS

lbC004D3A	CLR.W	D0
	MOVE.B	3(A6),D0
	AND.B	lbB006206(pc),D0
	ST	lbB006206
	MOVE.W	$10(A6),D2
	MOVE.W	D2,D3
	ANDI.W	#$FFF,D2
	SUB.W	D2,D3
	SUB.W	D0,D2
	CMPI.W	#$7C,D2
	BGE.S	lbC004D64
	MOVEQ	#$7C,D2
	BRA.S	lbC004D6E

lbC004D64	CMPI.W	#$358,D2
	BLE.S	lbC004D6E
	MOVE.W	#$358,D2
lbC004D6E	MOVE.W	D2,$22(A6)
	OR.W	D3,D2
	MOVE.W	D2,$10(A6)
	RTS

lbC004D7A	CLR.W	D0
	MOVE.B	3(A6),D0
	AND.B	lbB006206(pc),D0
	ST	lbB006206
	MOVE.W	$10(A6),D2
	MOVE.W	D2,D3
	ANDI.W	#$FFF,D2
	SUB.W	D2,D3
	ADD.W	D0,D2
	CMPI.W	#$7C,D2
	BGE.S	lbC004DA4
	MOVEQ	#$7C,D2
	BRA.S	lbC004DAE

lbC004DA4	CMPI.W	#$358,D2
	BLE.S	lbC004DAE
	MOVE.W	#$358,D2
lbC004DAE	MOVE.W	D2,$22(A6)
	OR.W	D3,D2
	MOVE.W	D2,$10(A6)
	RTS

lbC004DBA	MOVE.B	3(A6),D0
	ANDI.W	#$F0,D0
	LSR.W	#3,D0
	TST.B	lbB006202
	BEQ.S	lbC004DD0
	ADDI.W	#$20,D0
lbC004DD0	MOVE.W	lbW004DD8(PC,D0.W),D0
	JMP	lbW004DD8(PC,D0.W)

lbW004DD8	dc.w	lbC004E1A-lbW004DD8
	dc.w	lbC004E30-lbW004DD8
	dc.w	lbC004E3C-lbW004DD8
	dc.w	lbC004E48-lbW004DD8
	dc.w	lbC004E5A-lbW004DD8
	dc.w	lbC004E6C-lbW004DD8
	dc.w	lbC004E84-lbW004DD8
	dc.w	lbC004EC0-lbW004DD8
	dc.w	lbC004ED4-lbW004DD8
	dc.w	lbC004E18-lbW004DD8
	dc.w	lbC004F24-lbW004DD8
	dc.w	lbC004F2E-lbW004DD8
	dc.w	lbC004F38-lbW004DD8
	dc.w	lbC004F50-lbW004DD8
	dc.w	lbC004F64-lbW004DD8
	dc.w	lbC004F7C-lbW004DD8
	dc.w	lbC004E18-lbW004DD8
	dc.w	lbC004E18-lbW004DD8
	dc.w	lbC004E18-lbW004DD8
	dc.w	lbC004E18-lbW004DD8
	dc.w	lbC004E18-lbW004DD8
	dc.w	lbC004E18-lbW004DD8
	dc.w	lbC004E18-lbW004DD8
	dc.w	lbC004E18-lbW004DD8
	dc.w	lbC004EDE-lbW004DD8
	dc.w	lbC004E18-lbW004DD8
	dc.w	lbC004E18-lbW004DD8
	dc.w	lbC004E18-lbW004DD8
	dc.w	lbC004F38-lbW004DD8
	dc.w	lbC004F50-lbW004DD8
	dc.w	lbC004E18-lbW004DD8
	dc.w	lbC004E18-lbW004DD8

lbC004E18	RTS

lbC004E1A	MOVEQ	#1,D0
	AND.B	3(A6),D0
	ADD.B	D0,D0
;	LEA	$BFD100,A0				; bug !!!

	lea	$BFE001,A0

	ANDI.B	#$FD,(A0)
	OR.B	D0,(A0)
	RTS

lbC004E30	MOVE.B	#15,lbB006206
	BRA.L	lbC004D3A

lbC004E3C	MOVE.B	#15,lbB006206
	BRA.L	lbC004D7A

lbC004E48	MOVEQ	#15,D0
	AND.B	3(A6),D0
	ANDI.B	#$F0,$42(A6)
	OR.B	D0,$42(A6)
	RTS

lbC004E5A	MOVEQ	#15,D0
	AND.B	3(A6),D0
	ANDI.B	#$F0,$41(A6)
	OR.B	D0,$41(A6)
	RTS

lbC004E6C	MOVEQ	#15,D0
	AND.B	3(A6),D0
	MULU.W	#$48,D0
	MOVE.W	D0,$16(A6)
	ADD.W	$1A(A6),D0
	MOVE.W	D0,$1C(A6)
	RTS

lbC004E84	MOVEQ	#15,D0
	AND.B	3(A6),D0
	BEQ.S	lbC004EB4
	TST.B	$45(A6)
	BEQ.S	lbC004EAE
	SUBQ.B	#1,$45(A6)
	BEQ.L	lbC004EAC
lbC004E9A	CLR.W	D0
	MOVE.B	$44(A6),D0
	MOVE.W	D0,lbW00620E
	ST	lbB006205
lbC004EAC	RTS

lbC004EAE	MOVE.B	D0,$45(A6)
	BRA.S	lbC004E9A

lbC004EB4	MOVE.W	lbW006210(pc),D0
	MOVE.B	D0,$44(A6)
	RTS

lbC004EC0	MOVEQ	#15,D0
	AND.B	3(A6),D0
	ASL.B	#4,D0
	ANDI.B	#15,$41(A6)
	OR.B	D0,$41(A6)
	RTS

lbC004ED4	MOVE.W	(A6),D1
	ANDI.W	#$FFF,D1
	BNE.S	lbC004F22
	BRA.S	lbC004EF6

lbC004EDE	MOVEQ	#15,D0
	AND.B	3(A6),D0
	BEQ.S	lbC004F22
	MOVEQ	#0,D1
	MOVE.B	lbB006202(pc),D1
	DIVU.W	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	lbC004F22
lbC004EF6	LEA	$DFF000,A0
	MOVE.W	$1E(A6),D0
	MOVEA.L	4(A6),A1
	MOVE.L	(A1),(A5)			; address
	MOVE.W	4(A1),4(A5)			; length
	MOVE.W	$10(A6),$22(A6)
	MOVE.W	14(A6),$24(A6)
	MOVE.W	D0,$96(A0)			; DMA off
	OR.W	D0,lbW006212
lbC004F22	RTS

lbC004F24	MOVEQ	#15,D0
	AND.B	3(A6),D0
	BRA.L	lbC004C32

lbC004F2E	MOVEQ	#15,D0
	AND.B	3(A6),D0
	BRA.L	lbC004C52

lbC004F38	MOVEQ	#15,D0
	AND.B	3(A6),D0
	SUB.B	lbB006202(pc),D0
	BNE.S	lbC004F4E
	MOVE.W	D0,14(A6)
	MOVE.W	D0,$24(A6)
lbC004F4E	RTS

lbC004F50	MOVEQ	#15,D0
	AND.B	3(A6),D0
	CMP.B	lbB006202(pc),D0
	BNE.S	lbC004F4E
	MOVE.W	(A6),D0
	BEQ.S	lbC004F4E
	BRA.S	lbC004EF6

lbC004F64	TST.B	lbB006208
	BNE.S	lbC004F7A
	MOVEQ	#15,D0
	AND.B	3(A6),D0
	ADDQ.B	#1,D0
	MOVE.B	D0,lbB006207
lbC004F7A	RTS

lbC004F7C	MOVEQ	#15,D0
	AND.B	3(A6),D0
	LSL.B	#4,D0
	ANDI.B	#15,$42(A6)
	OR.B	D0,$42(A6)
	CMPI.B	#$10,$42(A6)
	BCS.S	lbC004F9A
	BSR.L	lbC004F9C
lbC004F9A	RTS

lbC004F9C	RTS

lbC004F9E	MOVE.L	A2,D1
	BRA.L	lbC0051A4

	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(A1)+
lbC0051A4	MOVE.B	(A0)+,D0
	EXT.W	D0
	BMI.S	lbC0051B8
	ADDQ.W	#1,D0
	MOVEA.L	A0,A2
	ADDA.W	D0,A0
	NEG.W	D0
	ADD.W	D0,D0
	JMP	lbC0051A4(PC,D0.W)

lbC0051B8	LEA	0(A1,D0.W),A2
	MOVE.B	(A0)+,D0
	BEQ.S	lbC0051C8
	NEG.B	D0
	ADD.W	D0,D0
	JMP	lbC0051A4(PC,D0.W)

lbC0051C8	MOVEA.L	D1,A2
	RTS

lbW0051CC	dc.w	$18
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
	dc.w	5
	dc.w	$607
	dc.w	$80A
	dc.w	$B0D
	dc.w	$1013
	dc.w	$161A
	dc.w	$202B
	dc.w	$4080
lbW0051FC	dc.w	$358
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
	dc.w	$352
	dc.w	$322
	dc.w	$2F5
	dc.w	$2CB
	dc.w	$2A2
	dc.w	$27D
	dc.w	$259
	dc.w	$237
	dc.w	$217
	dc.w	$1F9
	dc.w	$1DD
	dc.w	$1C2
	dc.w	$1A9
	dc.w	$191
	dc.w	$17B
	dc.w	$165
	dc.w	$151
	dc.w	$13E
	dc.w	$12C
	dc.w	$11C
	dc.w	$10C
	dc.w	$FD
	dc.w	$EF
	dc.w	$E1
	dc.w	$D5
	dc.w	$C9
	dc.w	$BD
	dc.w	$B3
	dc.w	$A9
	dc.w	$9F
	dc.w	$96
	dc.w	$8E
	dc.w	$86
	dc.w	$7E
	dc.w	$77
	dc.w	$71
	dc.w	$34C
	dc.w	$31C
	dc.w	$2F0
	dc.w	$2C5
	dc.w	$29E
	dc.w	$278
	dc.w	$255
	dc.w	$233
	dc.w	$214
	dc.w	$1F6
	dc.w	$1DA
	dc.w	$1BF
	dc.w	$1A6
	dc.w	$18E
	dc.w	$178
	dc.w	$163
	dc.w	$14F
	dc.w	$13C
	dc.w	$12A
	dc.w	$11A
	dc.w	$10A
	dc.w	$FB
	dc.w	$ED
	dc.w	$E0
	dc.w	$D3
	dc.w	$C7
	dc.w	$BC
	dc.w	$B1
	dc.w	$A7
	dc.w	$9E
	dc.w	$95
	dc.w	$8D
	dc.w	$85
	dc.w	$7D
	dc.w	$76
	dc.w	$70
	dc.w	$346
	dc.w	$317
	dc.w	$2EA
	dc.w	$2C0
	dc.w	$299
	dc.w	$274
	dc.w	$250
	dc.w	$22F
	dc.w	$210
	dc.w	$1F2
	dc.w	$1D6
	dc.w	$1BC
	dc.w	$1A3
	dc.w	$18B
	dc.w	$175
	dc.w	$160
	dc.w	$14C
	dc.w	$13A
	dc.w	$128
	dc.w	$118
	dc.w	$108
	dc.w	$F9
	dc.w	$EB
	dc.w	$DE
	dc.w	$D1
	dc.w	$C6
	dc.w	$BB
	dc.w	$B0
	dc.w	$A6
	dc.w	$9D
	dc.w	$94
	dc.w	$8C
	dc.w	$84
	dc.w	$7D
	dc.w	$76
	dc.w	$6F
	dc.w	$340
	dc.w	$311
	dc.w	$2E5
	dc.w	$2BB
	dc.w	$294
	dc.w	$26F
	dc.w	$24C
	dc.w	$22B
	dc.w	$20C
	dc.w	$1EF
	dc.w	$1D3
	dc.w	$1B9
	dc.w	$1A0
	dc.w	$188
	dc.w	$172
	dc.w	$15E
	dc.w	$14A
	dc.w	$138
	dc.w	$126
	dc.w	$116
	dc.w	$106
	dc.w	$F7
	dc.w	$E9
	dc.w	$DC
	dc.w	$D0
	dc.w	$C4
	dc.w	$B9
	dc.w	$AF
	dc.w	$A5
	dc.w	$9C
	dc.w	$93
	dc.w	$8B
	dc.w	$83
	dc.w	$7C
	dc.w	$75
	dc.w	$6E
	dc.w	$33A
	dc.w	$30B
	dc.w	$2E0
	dc.w	$2B6
	dc.w	$28F
	dc.w	$26B
	dc.w	$248
	dc.w	$227
	dc.w	$208
	dc.w	$1EB
	dc.w	$1CF
	dc.w	$1B5
	dc.w	$19D
	dc.w	$186
	dc.w	$170
	dc.w	$15B
	dc.w	$148
	dc.w	$135
	dc.w	$124
	dc.w	$114
	dc.w	$104
	dc.w	$F5
	dc.w	$E8
	dc.w	$DB
	dc.w	$CE
	dc.w	$C3
	dc.w	$B8
	dc.w	$AE
	dc.w	$A4
	dc.w	$9B
	dc.w	$92
	dc.w	$8A
	dc.w	$82
	dc.w	$7B
	dc.w	$74
	dc.w	$6D
	dc.w	$334
	dc.w	$306
	dc.w	$2DA
	dc.w	$2B1
	dc.w	$28B
	dc.w	$266
	dc.w	$244
	dc.w	$223
	dc.w	$204
	dc.w	$1E7
	dc.w	$1CC
	dc.w	$1B2
	dc.w	$19A
	dc.w	$183
	dc.w	$16D
	dc.w	$159
	dc.w	$145
	dc.w	$133
	dc.w	$122
	dc.w	$112
	dc.w	$102
	dc.w	$F4
	dc.w	$E6
	dc.w	$D9
	dc.w	$CD
	dc.w	$C1
	dc.w	$B7
	dc.w	$AC
	dc.w	$A3
	dc.w	$9A
	dc.w	$91
	dc.w	$89
	dc.w	$81
	dc.w	$7A
	dc.w	$73
	dc.w	$6D
	dc.w	$32E
	dc.w	$300
	dc.w	$2D5
	dc.w	$2AC
	dc.w	$286
	dc.w	$262
	dc.w	$23F
	dc.w	$21F
	dc.w	$201
	dc.w	$1E4
	dc.w	$1C9
	dc.w	$1AF
	dc.w	$197
	dc.w	$180
	dc.w	$16B
	dc.w	$156
	dc.w	$143
	dc.w	$131
	dc.w	$120
	dc.w	$110
	dc.w	$100
	dc.w	$F2
	dc.w	$E4
	dc.w	$D8
	dc.w	$CC
	dc.w	$C0
	dc.w	$B5
	dc.w	$AB
	dc.w	$A1
	dc.w	$98
	dc.w	$90
	dc.w	$88
	dc.w	$80
	dc.w	$79
	dc.w	$72
	dc.w	$6C
	dc.w	$38B
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
	dc.w	$384
	dc.w	$352
	dc.w	$322
	dc.w	$2F5
	dc.w	$2CB
	dc.w	$2A3
	dc.w	$27C
	dc.w	$259
	dc.w	$237
	dc.w	$217
	dc.w	$1F9
	dc.w	$1DD
	dc.w	$1C2
	dc.w	$1A9
	dc.w	$191
	dc.w	$17B
	dc.w	$165
	dc.w	$151
	dc.w	$13E
	dc.w	$12C
	dc.w	$11C
	dc.w	$10C
	dc.w	$FD
	dc.w	$EE
	dc.w	$E1
	dc.w	$D4
	dc.w	$C8
	dc.w	$BD
	dc.w	$B3
	dc.w	$A9
	dc.w	$9F
	dc.w	$96
	dc.w	$8E
	dc.w	$86
	dc.w	$7E
	dc.w	$77
	dc.w	$37E
	dc.w	$34C
	dc.w	$31C
	dc.w	$2F0
	dc.w	$2C5
	dc.w	$29E
	dc.w	$278
	dc.w	$255
	dc.w	$233
	dc.w	$214
	dc.w	$1F6
	dc.w	$1DA
	dc.w	$1BF
	dc.w	$1A6
	dc.w	$18E
	dc.w	$178
	dc.w	$163
	dc.w	$14F
	dc.w	$13C
	dc.w	$12A
	dc.w	$11A
	dc.w	$10A
	dc.w	$FB
	dc.w	$ED
	dc.w	$DF
	dc.w	$D3
	dc.w	$C7
	dc.w	$BC
	dc.w	$B1
	dc.w	$A7
	dc.w	$9E
	dc.w	$95
	dc.w	$8D
	dc.w	$85
	dc.w	$7D
	dc.w	$76
	dc.w	$377
	dc.w	$346
	dc.w	$317
	dc.w	$2EA
	dc.w	$2C0
	dc.w	$299
	dc.w	$274
	dc.w	$250
	dc.w	$22F
	dc.w	$210
	dc.w	$1F2
	dc.w	$1D6
	dc.w	$1BC
	dc.w	$1A3
	dc.w	$18B
	dc.w	$175
	dc.w	$160
	dc.w	$14C
	dc.w	$13A
	dc.w	$128
	dc.w	$118
	dc.w	$108
	dc.w	$F9
	dc.w	$EB
	dc.w	$DE
	dc.w	$D1
	dc.w	$C6
	dc.w	$BB
	dc.w	$B0
	dc.w	$A6
	dc.w	$9D
	dc.w	$94
	dc.w	$8C
	dc.w	$84
	dc.w	$7D
	dc.w	$76
	dc.w	$371
	dc.w	$340
	dc.w	$311
	dc.w	$2E5
	dc.w	$2BB
	dc.w	$294
	dc.w	$26F
	dc.w	$24C
	dc.w	$22B
	dc.w	$20C
	dc.w	$1EE
	dc.w	$1D3
	dc.w	$1B9
	dc.w	$1A0
	dc.w	$188
	dc.w	$172
	dc.w	$15E
	dc.w	$14A
	dc.w	$138
	dc.w	$126
	dc.w	$116
	dc.w	$106
	dc.w	$F7
	dc.w	$E9
	dc.w	$DC
	dc.w	$D0
	dc.w	$C4
	dc.w	$B9
	dc.w	$AF
	dc.w	$A5
	dc.w	$9C
	dc.w	$93
	dc.w	$8B
	dc.w	$83
	dc.w	$7B
	dc.w	$75
	dc.w	$36B
	dc.w	$33A
	dc.w	$30B
	dc.w	$2E0
	dc.w	$2B6
	dc.w	$28F
	dc.w	$26B
	dc.w	$248
	dc.w	$227
	dc.w	$208
	dc.w	$1EB
	dc.w	$1CF
	dc.w	$1B5
	dc.w	$19D
	dc.w	$186
	dc.w	$170
	dc.w	$15B
	dc.w	$148
	dc.w	$135
	dc.w	$124
	dc.w	$114
	dc.w	$104
	dc.w	$F5
	dc.w	$E8
	dc.w	$DB
	dc.w	$CE
	dc.w	$C3
	dc.w	$B8
	dc.w	$AE
	dc.w	$A4
	dc.w	$9B
	dc.w	$92
	dc.w	$8A
	dc.w	$82
	dc.w	$7B
	dc.w	$74
	dc.w	$364
	dc.w	$334
	dc.w	$306
	dc.w	$2DA
	dc.w	$2B1
	dc.w	$28B
	dc.w	$266
	dc.w	$244
	dc.w	$223
	dc.w	$204
	dc.w	$1E7
	dc.w	$1CC
	dc.w	$1B2
	dc.w	$19A
	dc.w	$183
	dc.w	$16D
	dc.w	$159
	dc.w	$145
	dc.w	$133
	dc.w	$122
	dc.w	$112
	dc.w	$102
	dc.w	$F4
	dc.w	$E6
	dc.w	$D9
	dc.w	$CD
	dc.w	$C1
	dc.w	$B7
	dc.w	$AC
	dc.w	$A3
	dc.w	$9A
	dc.w	$91
	dc.w	$89
	dc.w	$81
	dc.w	$7A
	dc.w	$73
	dc.w	$35E
	dc.w	$32E
	dc.w	$300
	dc.w	$2D5
	dc.w	$2AC
	dc.w	$286
	dc.w	$262
	dc.w	$23F
	dc.w	$21F
	dc.w	$201
	dc.w	$1E4
	dc.w	$1C9
	dc.w	$1AF
	dc.w	$197
	dc.w	$180
	dc.w	$16B
	dc.w	$156
	dc.w	$143
	dc.w	$131
	dc.w	$120
	dc.w	$110
	dc.w	$100
	dc.w	$F2
	dc.w	$E4
	dc.w	$D8
	dc.w	$CB
	dc.w	$C0
	dc.w	$B5
	dc.w	$AB
	dc.w	$A1
	dc.w	$98
	dc.w	$90
	dc.w	$88
	dc.w	$80
	dc.w	$79
	dc.w	$72
lbW00567C	dc.w	1
	dc.w	$203
	dc.w	$405
	dc.w	$607
	dc.w	$809
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$A0B
	dc.w	$C0D
	dc.w	$E0F
	dc.w	$1011
	dc.w	$1213
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$1415
	dc.w	$1617
	dc.w	$1819
	dc.w	$1A1B
	dc.w	$1C1D
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$1E1F
	dc.w	$2021
	dc.w	$2223
	dc.w	$2425
	dc.w	$2627
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$2829
	dc.w	$2A2B
	dc.w	$2C2D
	dc.w	$2E2F
	dc.w	$3031
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$3233
	dc.w	$3435
	dc.w	$3637
	dc.w	$3839
	dc.w	$3A3B
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$3C3D
	dc.w	$3E3F
	dc.w	$4041
	dc.w	$4243
	dc.w	$4445
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$4647
	dc.w	$4849
	dc.w	$4A4B
	dc.w	$4C4D
	dc.w	$4E4F
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$5051
	dc.w	$5253
	dc.w	$5455
	dc.w	$5657
	dc.w	$5859
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$5A5B
	dc.w	$5C5D
	dc.w	$5E5F
	dc.w	$6061
	dc.w	$6263
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
lbL00577C
	ds.b	858
lbL005AD6
	ds.b	4
lbL005ADA	dc.l	0
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
	dc.w	0
lbL005B1C	dc.l	0
lbL005B20	dc.l	0
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
	dc.w	0
lbL005B62	dc.l	0
lbL005B66	dc.l	0
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
	dc.w	0
lbL005BA8	dc.l	0
lbL005BAC	dc.l	0
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
	dc.w	0
lbL005BEE
	ds.b	4*31			; sample address
	ds.b	2*31			; sample length
	ds.b	4*31			; repeat address
	ds.b	2*31			; repeat length
	ds.b	2*31			; volume
	ds.b	2*31			; octave ?
lbL005DDE
	ds.b	1024			; pattern size

lbL0061DE	dc.l	0
;lbL0061E2	dc.l	0
;lbL0061E6	dc.l	0
lbL0061EA	dc.l	0
;lbL0061EE	dc.l	0
lbL0061F2	dc.l	0
;	dc.l	0
;lbW0061FA	dc.w	0
;lbW0061FC	dc.w	0
lbB0061FE	dc.b	0		; song length
;lbB0061FF	dc.b	0
;lbB006200	dc.b	1
lbB006201	dc.b	6		; song speed
lbB006202	dc.b	0
lbB006203	dc.b	0
lbB006204	dc.b	0
lbB006205	dc.b	0
lbB006206	dc.b	0
lbB006207	dc.b	0
lbB006208	dc.b	0
lbB006209	dc.b	0
;lbW00620A	dc.w	0
;lbW00620C	dc.w	0
lbW00620E	dc.w	0
lbW006210	dc.w	0
lbW006212	dc.w	0
