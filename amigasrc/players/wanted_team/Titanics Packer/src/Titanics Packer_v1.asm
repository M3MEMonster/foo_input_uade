	*****************************************************
	****  Titanics Packer replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Titanics Packer player module V1.0 (20 Mar 2014)',0
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
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Save!EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart
	dc.l	0

PlayerName
	dc.b	'Titanics Packer',0
Creator
	dc.b	'(c) 1989 by Starbug/Titanics,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'TITS.',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
Offset
	dc.w	0
SpeedFix
	dc.w	0
Timer
	dc.w	0
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
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D2
	beq.b	return
	move.l	D2,A2

	moveq	#14,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2)+,A1
	add.l	D2,A1
	moveq	#0,D0
	move.w	(A2),D0
	add.l	D0,D0
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	addq.l	#8,A2
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
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
	dc.l	MI_UnPackedSystem,MIUS_OldSoundTracker
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxSamples,15
	dc.l	MI_MaxPattern,64
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	move.l	dtg_ChkSize(A5),D1
	cmp.l	#180+256,D1
	ble.b	Fault

	lea	180(A0),A1
	moveq	#127,D1
NextPC
	move.w	(A1)+,D2
	beq.b	Fault
	cmp.w	D0,D2
	beq.b	Later
	btst	#0,D2
	bne.b	Fault
	dbf	D1,NextPC
	rts
Later
	move.l	A1,D2
	sub.l	A0,D2
	lea	180(A0),A0
NextWord
	cmp.w	(A0)+,D2
	beq.b	Found
	cmp.l	A0,A1
	bne.b	NextWord
	rts
Found
	lea	Offset(PC),A0
	move.w	D2,(A0)

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
	move.w	(A6)+,D6			; Offset
	move.l	A7,D3
	lea	-2(A0,D6.W),A2			; end position
	lea	180(A0),A0			; start position
	sub.w	#182,D6
	lsr.w	#1,D6
	move.w	D6,Length+2(A4)
	clr.w	(A6)				; SpeedFix

NextOff
	move.w	-(A2),-(A7)
	cmp.l	A0,A2
	bne.b	NextOff
	move.l	A7,A0
	move.l	A0,A2
LoopMain
	move.w	(A2)+,D1
	beq.b	Test
	cmp.l	A2,D3
	beq.b	Skip
	move.l	A2,A0
LoopPos
	cmp.w	(A0)+,D1
	bne.b	NextPos
	clr.w	-2(A0)
	subq.w	#1,D6
NextPos
	cmp.l	A0,D3
	bne.b	LoopPos
Test
	cmp.l	A2,D3
	bne.b	LoopMain
Skip
	move.l	D3,A7
	move.w	D6,Patterns+2(A4)
	mulu.w	#1024,D6
	add.l	#600,D6

	moveq	#14,D0
	move.l	(A1),D1
	moveq	#0,D2
	moveq	#0,D3
	moveq	#0,D5
NextInfo
	move.l	(A1)+,D4
	beq.b	NoGreat
	addq.l	#1,D5
	cmp.l	D4,D1
	ble.b	NoLow
	move.l	D4,D1
NoLow
	cmp.l	D4,D2
	bge.b	NoGreat
	move.l	D4,D2
	move.w	(A1),D3
NoGreat
	addq.l	#8,A1
	dbf	D0,NextInfo
	add.l	D3,D3
	add.l	D2,D3

	cmp.l	LoadSize(A4),D3
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	cmp.l	#126346,D3			; A500 Demo
	bne.b	NoFix
	st	(A6)				; SpeedFix
NoFix
	move.l	D3,CalcSize(A4)
	move.l	D1,SongSize(A4)
	sub.l	D1,D3
	move.l	D3,SamplesSize(A4)
	move.l	D5,Samples(A4)
	add.l	D3,D6
	move.l	D6,Unpacked(A4)

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
	move.w	lbW001564(PC),D0
	lsr.w	#1,D0
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

	lea	OldVoice1(PC),A0
	clr.l	(A0)+
	clr.l	(A0)

	move.w	Timer(PC),D0
	bne.b	TimerSet
	lea	Timer(PC),A0
	move.w	dtg_Timer(A5),D0
	move.w	D0,(A0)
TimerSet
	tst.w	SpeedFix
	beq.b	NoSF
	add.w	D0,D0			; 25 Hz
	move.w	D0,dtg_Timer(A5)
NoSF
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
**************************** Titanics Packer player ***********************
***************************************************************************

; Player from demo Deluxe View (c) 1989 by Titanics

Init
	MOVE.L	A0,lbL001574
	MOVEQ	#0,D0
	MOVE.W	$B4(A0),D0
	ADDA.L	D0,A0
	MOVE.L	(A0),lbB00155E
;	BSR.S	lbC0010AE
	CLR.B	lbB001562
	CLR.W	lbW001568
	CLR.W	lbW001564
	CLR.W	lbW001566
	MOVE.B	#$40,lbB001563

	move.w	#6,SongSpeed

	RTS

;	ST	lbW001568
;lbC0010AE	LEA	$DFF000,A0
;	MOVE.W	#15,$96(A0)
;	CLR.W	$A8(A0)
;	CLR.W	$B8(A0)
;	CLR.W	$C8(A0)
;	CLR.W	$D8(A0)
;	RTS

Play
	MOVEM.L	D0-D7/A0-A6,-(SP)
	ADDQ.B	#1,lbB001562
;	CMPI.B	#6,lbB001562
;lbW0010D8	EQU	*-6
;	BGE.L	lbC00126C

	move.w	SongSpeed(PC),D0
	cmp.b	lbB001562(PC),D0
	ble.w	lbC00126C

	LEA	$DFF0A0,A5
	LEA	lbW001506(PC),A6
	MOVEQ	#0,D2
	TST.B	3(A6)
	BEQ.S	lbC0010F6
	BSR.S	lbC001138
lbC0010F6	LEA	$DFF0B0,A5
	LEA	lbW00151C(PC),A6
	MOVEQ	#1,D2
	TST.B	3(A6)
	BEQ.S	lbC00110A
	BSR.S	lbC001138
lbC00110A	LEA	$DFF0C0,A5
	LEA	lbW001532(PC),A6
	MOVEQ	#2,D2
	TST.B	3(A6)
	BEQ.S	lbC00111E
	BSR.S	lbC001138
lbC00111E	LEA	$DFF0D0,A5
	LEA	lbW001548(PC),A6
	MOVEQ	#3,D2
	TST.B	3(A6)
	BEQ.S	lbC001132
	BSR.S	lbC001138
lbC001132	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC001138	MOVE.B	2(A6),D0
	ANDI.B	#15,D0
	BEQ.S	lbC001190
	CMP.B	#1,D0
	BEQ.L	lbC0011FE
	CMP.B	#2,D0
	BEQ.L	lbC0011DC
	CMP.B	#12,D0
	BEQ.L	lbC001220
	CMP.B	#14,D0
	BEQ.L	lbC001242
	CMP.B	#15,D0
	BEQ.L	lbC00125C
	CMP.B	#5,D0
	BNE.S	lbC001176
	ST	lbB00156E
lbC001176	CMP.B	#4,D0
	BNE.S	lbC001182
	ST	lbB00156C
lbC001182	CMP.B	#3,D0
	BNE.S	lbC00118E
	ST	lbB00156A
lbC00118E	RTS

lbC001190	MOVE.B	lbB001562(PC),D0
	BEQ.S	lbC0011A8
	SUBQ.B	#1,D0
	BEQ.S	lbC0011B0
	SUBQ.B	#1,D0
	BEQ.S	lbC0011BA
	SUBQ.B	#1,D0
	BEQ.S	lbC0011B0
	SUBQ.B	#1,D0
	BEQ.S	lbC0011A8
	RTS

lbC0011A8	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	BRA.S	lbC0011BC

lbC0011B0	MOVE.B	3(A6),D0
	ANDI.W	#15,D0
	BRA.S	lbC0011BC

lbC0011BA	MOVEQ	#0,D0
lbC0011BC	MOVE.B	1(A6),D1
	ANDI.W	#$3F,D1
	ADD.B	D1,D0
	EXT.W	D0
	CMP.W	#$23,D0
	BHI.S	lbC0011DA
	ADD.W	D0,D0
	LEA	lbW00149E(PC),A0
	MOVE.W	0(A0,D0.W),6(A5)		; period

	move.l	D0,-(SP)
	move.w	(A0,D0.W),D0
	bsr.w	SetPer
	move.l	(SP)+,D0

lbC0011DA	RTS

lbC0011DC	MOVE.B	3(A6),D0
	ANDI.W	#15,D0
	ADD.W	D0,$10(A6)
	CMPI.W	#$358,$10(A6)
	BLS.S	lbC0011F6
	MOVE.W	#$358,$10(A6)
lbC0011F6	MOVE.W	$10(A6),6(A5)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	RTS

lbC0011FE	MOVE.B	3(A6),D0
	ANDI.W	#15,D0
	SUB.W	D0,$10(A6)
	CMPI.W	#$71,$10(A6)
	BHI.S	lbC001218
	MOVE.W	#$71,$10(A6)
lbC001218	MOVE.W	$10(A6),6(A5)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	RTS

lbC001220	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	SUB.W	lbW001572(PC),D0
	BPL.S	lbC00122E
	MOVEQ	#0,D0
lbC00122E	CMP.W	#$40,D0
	BLS.S	lbC001236
	MOVEQ	#$40,D0
lbC001236
;	MOVE.W	D0,8(A5)		; volume
;	MOVE.W	D0,D1
;	MOVE.W	D2,D0
;	BRA.L	lbC00149C

	bsr.w	ChangeVolume
	bsr.w	SetVol

	rts

lbC001242	MOVE.B	3(A6),D0
	ANDI.W	#1,D0
	LSL.W	#1,D0
	ANDI.B	#$FD,$BFE0FF
	OR.B	D0,$BFE0FF
	RTS

lbC00125C	MOVE.B	3(A6),D0
	ANDI.W	#15,D0
;	MOVE.W	D0,lbW0010D8

	move.w	D0,SongSpeed

	RTS

lbC00126C	CLR.B	lbB001562
	CLR.B	lbB001509
	CLR.B	lbB00151F
	CLR.B	lbB001535
	CLR.B	lbB00154B
	CLR.W	lbW001570
lbC001290	MOVE.B	lbB00155E(PC),D0
	ANDI.W	#$7F,D0
	BNE.S	lbC0012A0
	BSR.L	lbC00131E
	BRA.S	lbC001290

lbC0012A0	SUBQ.B	#1,lbB00155E
	MOVE.W	lbW001570(PC),D1
	BEQ.S	lbC001318
	LEA	$DFF000,A0
;	MOVE.B	$BFD800,D0
;	ADDI.B	#11,D0
;lbC0012BC	CMP.B	$BFD800,D0
;	BNE.S	lbC0012BC

	bsr.w	DMAWait

	ORI.W	#$8000,D1
	MOVE.W	D1,$96(A0)			; DMA on
;	ADDQ.B	#1,D0
;lbC0012CE	CMP.B	$BFD800,D0
;	BNE.S	lbC0012CE

	bsr.w	DMAWait

	MOVEQ	#1,D0
	CMP.W	lbW001514(PC),D0
	BNE.S	lbC0012E8
	CLR.W	lbW001514
	MOVE.W	D0,$A4(A0)			; length
lbC0012E8	CMP.W	lbW00152A(PC),D0
	BNE.S	lbC0012F8
	CLR.W	lbW00152A
	MOVE.W	D0,$B4(A0)			; length
lbC0012F8	CMP.W	lbW001540(PC),D0
	BNE.S	lbC001308
	CLR.W	lbW001540
	MOVE.W	D0,$C4(A0)			; length
lbC001308	CMP.W	lbW001556(PC),D0
	BNE.S	lbC001318
	CLR.W	lbW001556
	MOVE.W	D0,$D4(A0)			; length
lbC001318	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC00131E	MOVEQ	#0,D0
	MOVE.B	lbB00155F(PC),D0
	LSR.B	#6,D0
	MOVE.W	D0,D4
	LSL.W	#3,D0
	LEA	lbL0014E6(PC),A3
	MOVEA.L	0(A3,D0.W),A6
	MOVEA.L	4(A3,D0.W),A5
	MOVE.L	lbB00155E(PC),D0
	ANDI.L	#$3FFFFF,D0
	MOVE.L	D0,(A6)
	MOVE.B	lbB001563(PC),D2
	MOVE.B	lbB00155E(PC),D0
	BMI.S	lbC00135E
	MOVEQ	#0,D2
	MOVE.B	2(A6),D0
	ANDI.W	#15,D0
	CMP.W	#11,D0
	BNE.S	lbC001374
	MOVEQ	#1,D2
lbC00135E	CLR.W	lbW001566
	ADDQ.W	#2,lbW001564
	MOVE.B	#$40,lbB001563
	BRA.S	lbC00137A

lbC001374	ADDQ.W	#4,lbW001566
lbC00137A	MOVEA.L	lbL001574(PC),A0
	LEA	$B4(A0),A1
	MOVE.W	lbW001564(PC),D0
	MOVEQ	#0,D1
	MOVE.W	0(A1,D0.W),D1
	CMP.W	#$FFFF,D1
	BNE.S	lbC0013A0
;	ST	lbW001568
	CLR.W	lbW001564

	bsr.w	SongEnd

	BRA.S	lbC00137A

lbC0013A0	MOVEA.L	D1,A2
	ADDA.L	A0,A2
	ADDA.W	lbW001566(PC),A2
	MOVE.L	(A2),lbB00155E
	ADD.B	D2,lbB00155E
	MOVE.B	(A2),D0
	ANDI.B	#$7F,D0
	SUB.B	D0,lbB001563
	MOVEQ	#0,D2
	MOVE.B	2(A6),D2
	LSR.W	#4,D2
	BEQ.L	lbC00147C
	MOVE.W	$14(A6),D0
	MOVE.W	D0,$DFF096			; DMA off
	OR.W	D0,lbW001570
	SUBQ.W	#1,D2
	ADD.W	D2,D2
	ADD.W	D2,D2
	MOVE.W	D2,D0
	ADD.W	D2,D2
	ADD.W	D0,D2
	LEA	0(A0,D2.W),A2
	MOVE.L	(A2),D0
	ADD.L	A0,D0
	MOVE.L	D0,4(A6)
	MOVE.W	4(A2),8(A6)
	MOVE.W	6(A2),D1
	MOVE.B	2(A6),D0
	ANDI.W	#15,D0
	CMP.W	#12,D0
	BNE.S	lbC001412
	MOVEQ	#0,D1
	MOVE.B	3(A6),D1
lbC001412	SUB.W	lbW001572(PC),D1
	BPL.S	lbC00141A
	MOVEQ	#0,D1
lbC00141A	CMP.W	#$40,D1
	BLS.S	lbC001422
	MOVEQ	#$40,D1
lbC001422
;	MOVE.W	D1,8(A5)		; volume

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0

	MOVE.W	D1,$12(A6)
	MOVEQ	#0,D3
	MOVE.W	8(A2),D3
	ADD.L	4(A6),D3
	MOVE.L	D3,10(A6)
	MOVE.W	10(A2),14(A6)
	TST.W	14(A6)
	BNE.S	lbC00144A
	MOVE.W	#1,14(A6)
lbC00144A	CMPI.W	#1,14(A6)
	BEQ.S	lbC00145E
	MOVE.L	10(A6),4(A6)
	MOVE.W	14(A6),8(A6)
lbC00145E	MOVE.L	4(A6),0(A5)		; address
	MOVE.W	8(A6),4(A5)			; length

	bsr.w	SetTwo

;	MOVEM.L	A5/A6,-(SP)
;	MOVE.W	D4,D0
;	MOVE.W	$12(A6),D1
;	BSR.L	lbC00149C
;	MOVEM.L	(SP)+,A5/A6
lbC00147C	MOVEQ	#0,D0
	MOVE.B	1(A6),D0
	CMP.W	#$3F,D0
	BEQ.S	lbC00149A
	ADD.W	D0,D0
	LEA	lbW00149E(PC),A2
	MOVE.W	0(A2,D0.W),D0
	MOVE.W	D0,6(A5)			; period

	bsr.w	SetPer

	MOVE.W	D0,$10(A6)
lbC00149A	RTS

;lbC00149C	RTS

lbW00149E	dc.w	$358
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
lbL0014E6	dc.l	lbW001506
	dc.l	$DFF0A0
	dc.l	lbW00151C
	dc.l	$DFF0B0
	dc.l	lbW001532
	dc.l	$DFF0C0
	dc.l	lbW001548
	dc.l	$DFF0D0
lbW001506	dc.w	0
	dc.b	0
lbB001509	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
lbW001514	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	1
lbW00151C	dc.w	0
	dc.b	0
lbB00151F	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
lbW00152A	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	2
lbW001532	dc.w	0
	dc.b	0
lbB001535	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
lbW001540	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	4
lbW001548	dc.w	0
	dc.b	0
lbB00154B	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
lbW001556	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	8
lbB00155E	dc.b	0
lbB00155F	dc.b	0
	dc.w	0
lbB001562	dc.b	0
lbB001563	dc.b	0
lbW001564	dc.w	0
lbW001566	dc.w	0
lbW001568	dc.w	0
lbB00156A	dc.b	0
	dc.b	0
lbB00156C	dc.b	0
	dc.b	0
lbB00156E	dc.b	0
	dc.b	0
lbW001570	dc.w	0			; DMA
lbW001572	dc.w	0			; volume
lbL001574	dc.l	0

SongSpeed
	dc.w	0
