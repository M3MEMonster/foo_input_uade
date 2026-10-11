	*****************************************************
	****     Mosh Packer replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Mosh Packer player module V1.0 (16 Mar 2014)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_Get_ModuleInfo,Get_ModuleInfo
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Save!EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
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
EagleBase
	dc.l	0
SamplePtr
	dc.l	0
RightVolume
	dc.w	64
LeftVolume
	dc.w	64
Voice1
	dc.w	1
Voice2
	dc.w	1
Voice3
	dc.w	1
Voice4
	dc.w	1
OldVoice1
	dc.w	0
OldVoice2
	dc.w	0
OldVoice3
	dc.w	0
OldVoice4
	dc.w	0
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
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

Get_ModuleInfo
	lea	InfoBuffer(PC),A0
	rts

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
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
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

	move.l	A5,(A6)+			; EagleBase

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

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

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
	move.b	lbW003482+1(PC),D0
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

	lea	OldVoice1(PC),A1
	moveq	#3,D1
	lea	$DFF0A0,A5
SetNew
	move.w	(A1)+,D0
	bsr.b	ChangeVolume
	lea	16(A5),A5
	dbf	D1,SetNew
	rts

ChangeVolume
	and.w	#$7F,D0
	cmpa.l	#$DFF0A0,A5			;Left Volume
	bne.b	NoVoice1
	move.w	D0,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D0
Voice1On
	mulu.w	LeftVolume(PC),D0
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF0B0,A5			;Right Volume
	bne.b	NoVoice2
	move.w	D0,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D0
Voice2On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF0C0,A5			;Right Volume
	bne.b	NoVoice3
	move.w	D0,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D0
Voice3On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt
NoVoice3
	move.w	D0,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D0
Voice4On
	mulu.w	LeftVolume(PC),D0
SetIt
	lsr.w	#6,D0
	move.w	D0,8(A5)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Two -------------------------------*

SetTwo
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
	move.l	4(A6),(A0)
	move.w	8(A6),UPS_Voice1Len(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Per -------------------------------*

SetPer
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Per(PC),A0
	cmp.l	#$DFF0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF0C0,A5
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
	moveq	#1,D1
	move.w	D1,(A0)+			Voice1=0 setzen
	btst	#0,D0
	bne.b	No_Voice1
	clr.w	-2(A0)
	clr.w	$DFF0A8
	clr.w	UPS_Voice1Vol(A1)
No_Voice1
	move.w	D1,(A0)+			Voice2=0 setzen
	btst	#1,D0
	bne.b	No_Voice2
	clr.w	-2(A0)
	clr.w	$DFF0B8
	clr.w	UPS_Voice2Vol(A1)
No_Voice2
	move.w	D1,(A0)+			Voice3=0 setzen
	btst	#2,D0
	bne.b	No_Voice3
	clr.w	-2(A0)
	clr.w	$DFF0C8
	clr.w	UPS_Voice3Vol(A1)
No_Voice3
	move.w	D1,(A0)+			Voice4=0 setzen
	btst	#3,D0
	bne.b	No_Voice4
	clr.w	-2(A0)
	clr.w	$DFF0D8
	clr.w	UPS_Voice4Vol(A1)
No_Voice4
	move.w	D0,UPS_DMACon(A1)	;Stimme an = Bit gesetzt
					;Bit 0 = Kanal 1 usw.
	moveq	#0,D0
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

	lea	OldVoice1(PC),A0
	clr.l	(A0)+
	clr.l	(A0)

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
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

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

DMAWait
	movem.l	D0/D1,-(SP)
	moveq	#8,D0
.dma1	move.b	$DFF006,D1
.dma2	cmp.b	$DFF006,D1
	beq.b	.dma2
	dbeq	D0,.dma1
	movem.l	(SP)+,D0/D1
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

	or.b	#2,$BFE001

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

lbC000F06	MOVE.W	D2,(6,A5)		; Period

	move.l	D0,-(SP)
	move.w	D2,D0
	bsr.w	SetPer
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
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0

	BRA.B	lbC000FF8

lbC000FE2	MOVE.L	(4,A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,(10,A6)
	MOVE.W	(A3,D4.L),(14,A6)
;	MOVE.W	($12,A6),(8,A5)			; volume

	move.l	D0,-(SP)
	move.w	$12(A6),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
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
	MOVE.W	D0,($DFF096)			; DMA off
	CLR.B	($1B,A6)
	MOVE.L	(4,A6),(A5)			; address
	MOVE.W	(8,A6),(4,A5)			; length

	bsr.w	SetTwo

	MOVE.W	($10,A6),D0
	ANDI.W	#$FFF,D0
	MOVE.W	D0,(6,A5)			; period

	bsr.w	SetPer

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

	bsr.w	DMAWait

	ORI.W	#$8000,D0
	MOVE.W	D0,($DFF096)			; DMA on
;	MOVE.W	#$12C,D0
;lbC0010B0	DBRA	D0,lbC0010B0

	bsr.w	DMAWait

	LEA	($DFF000),A5
	LEA	(lbW00355C,PC),A6
	MOVE.L	(10,A6),($D0,A5)		; address
	MOVE.W	(14,A6),($D4,A5)		; length
	LEA	(lbW003540,PC),A6
	MOVE.L	(10,A6),($C0,A5)
	MOVE.W	(14,A6),($C4,A5)
	LEA	(lbW003524,PC),A6
	MOVE.L	(10,A6),($B0,A5)
	MOVE.W	(14,A6),($B4,A5)
	LEA	(lbW003508,PC),A6
	MOVE.L	(10,A6),($A0,A5)
	MOVE.W	(14,A6),($A4,A5)
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
lbC001196	MOVE.W	($10,A6),(6,A5)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	RTS

lbC00119E	SUB.W	D0,($10,A6)
	MOVE.W	($18,A6),D0
	CMP.W	($10,A6),D0
	BLT.B	lbC001196
	MOVE.W	($18,A6),($10,A6)
	CLR.W	($18,A6)
	MOVE.W	($10,A6),(6,A5)			; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	SetPer
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
lbC0011F8	MOVE.W	D0,(6,A5)		; period

	bsr.w	SetPer

	MOVE.B	($1A,A6),D0
	LSR.W	#2,D0
	ANDI.W	#$3C,D0
	ADD.B	D0,($1B,A6)
	RTS

lbC00120C	MOVE.W	($10,A6),(6,A5)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	SetPer
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
	MOVE.W	($10,A6),(6,A5)			; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	SetPer
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
	bsr.w	ChangeVolume
	bsr.w	SetVol
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
	bsr.w	ChangeVolume
	bsr.w	SetVol
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
	MOVE.W	D0,(6,A5)			; period

	bsr.w	SetPer

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
	MOVE.W	D0,(6,A5)			; period

	bsr.w	SetPer

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
	ANDI.B	#1,D0
	ASL.B	#1,D0
	ANDI.B	#$FD,($BFE001)
	OR.B	D0,($BFE001)
	RTS

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
	move.b	3(A6),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
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
