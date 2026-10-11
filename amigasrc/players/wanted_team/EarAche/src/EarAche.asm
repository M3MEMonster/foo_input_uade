	******************************************************
	****       EarAche replayer for EaglePlayer       ****
	****        all adaptions by Wanted Team,         ****
	****      DeliTracker compatible (?) version      ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: EarAche 1.05 player module V1.0 (26 Jan 2005)',0
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
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Save!EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart
	dc.l	0

PlayerName
	dc.b	'EarAche',0
Creator
	dc.b	"(c) 1990 by Morten Grouleff,",10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'EA.',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
DataPtr
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
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	DataPtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	A2,A4
	add.l	12(A2),A2
	move.l	InfoBuffer+Samples(PC),D5
	beq.b	return
	subq.l	#1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	moveq	#0,D0
	move.w	(A2)+,D0
	moveq	#0,D1
	move.w	(A2)+,D1
	lsl.l	#1,D1
	lsl.l	#2,D0
	add.l	A4,D0
	move.l	D0,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
****************************** EP_NewModuleInfo ***************************
***************************************************************************

NewModuleInfo

CalcSize	=	4
LoadSize	=	12
Samples		=	20
Length		=	28
SamplesSize	=	36
SongSize	=	44

InfoBuffer
	dc.l	MI_Calcsize,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_SamplesSize,0	;36
	dc.l	MI_Songsize,0		;44
	dc.l	MI_MaxLength,256
	dc.l	MI_MaxSamples,128
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	tst.w	(A0)
	beq.b	CheckRout
	cmp.l	#'EASO',(A0)
	bne.b	NoHead
	addq.l	#4,A0
	bra.b	CheckRout
NoHead
	cmp.w	#$6000,(A0)+
	bne.b	Fault
	move.l	A0,A1
	move.w	(A0)+,D1
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	cmp.w	#$6000,(A0)+
	bne.b	Fault
	move.w	(A0)+,D2
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D2
	bne.b	Fault
	add.w	D1,A1
	cmp.l	#$33FC000F,(A1)+
	bne.b	Fault
	cmp.l	#$00DFF096,(A1)+
	bne.b	Fault
	cmp.w	#$43FA,(A1)+
	bne.b	Fault
	move.w	(A1),D1
	beq.b	Fault
	bmi.b	Fault
	btst	#0,D1
	bne.b	Fault
	add.w	D1,A1
	move.l	A1,A0
CheckRout
	cmp.l	#$18,(A0)		; check routine taken from EarAche editor
	bne.b	Fault
	move.l	4(A0),D2
	sub.l	(A0),D2
	ble.b	Fault
	and.w	#7,D2
	bne.b	Fault
	move.l	$10(A0),D2
	sub.l	8(A0),D2
	ble.b	Fault
	and.w	#15,D2
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

	tst.w	(A1)
	beq.b	DataOK
	cmp.w	#$6000,(A1)+
	bne.b	NoMod
	add.w	(A1),A1
	lea	10(A1),A1
	add.w	(A1),A1
	bra.w	DataOK
NoMod
	addq.l	#2,A1
DataOK
	move.l	A1,(A6)+
	move.l	A1,A2
	add.l	4(A2),A1
	moveq	#0,D1
CheckL
	cmp.w	#-1,(A1)
	beq.b	EndL
	addq.l	#1,D1
	addq.l	#4,A1
	bra.b	CheckL
EndL
	move.l	D1,Length(A4)

	add.l	12(A2),A2
	moveq	#0,D0
	move.w	(A2),D0
	moveq	#0,D1
	moveq	#0,D2
	moveq	#0,D3
NextS
	tst.l	(A2)
	beq.b	NoMore
	addq.l	#1,D1
	cmp.w	(A2),D2
	bhi.b	NoMax
	move.w	(A2),D2
	move.w	2(A2),D3
NoMax
	addq.l	#4,A2
	bra.b	NextS
NoMore
	lsl.l	#2,D0
	lsl.l	#2,D2
	lsl.l	#1,D3
	add.l	D3,D2
	move.l	DataPtr(PC),A2
	lea	(A2,D0.L),A1
	sub.l	A0,A1
	sub.l	D0,D2

	move.l	D1,Samples(A4)
	move.l	A1,SongSize(A4)
	move.l	D2,SamplesSize(A4)
	add.l	D2,A1
	move.l	A1,CalcSize(A4)

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
	move.l	lbL000014(PC),D0
	move.l	DataPtr(PC),A0
	sub.l	A0,D0
	sub.l	4(A0),D0
	lsr.l	#2,D0
	rts

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
******************** DTP_Volume DTP_Balance *******************************
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
	and.w	#$7F,D0
	move.l	A1,D1
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
	move.w	D0,8(A1)
Exit2
	move.l	(A7)+,D1
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Two -------------------------------*

SetTwo
	move.l	A0,-(SP)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A4
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A4
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A4
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	D0,(A0)
	move.w	$18(A1),UPS_Voice1Per(A0)
	move.l	(SP)+,A0
	rts

*------------------------------- Set Len -------------------------------*

SetLen
	move.l	A0,-(SP)
	lea	StructAdr+UPS_Voice1Len(PC),A0
	cmp.l	#$DFF0A0,A4
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Len(PC),A0
	cmp.l	#$DFF0B0,A4
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Len(PC),A0
	cmp.l	#$DFF0C0,A4
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Len(PC),A0
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
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	StructAdr(PC),A0
	lea	UPS_SizeOF(A0),A1
ClearUPS
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearUPS
	move.l	DataPtr(PC),A1
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
****************************** EarAche 1.05 player ************************
***************************************************************************

; Player from "SkyDance" module

WT
lbC000000
;	BRA.L	lbC000128

;	BRA.L	lbC000156

;lbL000008	dc.l	0
lbL00000C	dc.l	0
lbW000010	dc.w	0
lbW000012	dc.w	0
lbL000014	dc.l	0
lbW000018	dc.w	0
	dc.w	$D60
	dc.w	$CA0
	dc.w	$BEA
	dc.w	$B40
	dc.w	$AA0
	dc.w	$9FC
	dc.w	$976
	dc.w	$8EE
	dc.w	$86E
	dc.w	$7F4
	dc.w	$782
	dc.w	$716
	dc.w	$6B0
	dc.w	$650
	dc.w	$5F4
	dc.w	$5A0
	dc.w	$54E
	dc.w	$502
	dc.w	$4BA
	dc.w	$476
	dc.w	$436
	dc.w	$3F9
	dc.w	$3C0
	dc.w	$38A
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
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
	dc.w	$71
lbB0000A6	dc.b	1
lbB0000A7	dc.b	1
lbL0000A8	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	2
	dc.l	0
lbL0000C8	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	4
	dc.l	0
lbL0000E8	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	1
	dc.l	0
lbL000108	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	8
	dc.l	0

Init
;lbC000128	MOVE.W	#15,$DFF096
;	LEA	lbL00048E(PC),A1
	MOVE.L	4(A1),D0
	ADD.L	A1,D0
	LEA	lbC000000(PC),A0
	MOVE.L	A1,lbL00000C-WT(A0)
	MOVE.L	D0,lbL000014-WT(A0)
	MOVE.L	#0,lbW000010-WT(A0)
	MOVE.W	#$101,lbB0000A6-WT(A0)
	RTS

Play
lbC000156	LEA	lbC000000(PC),A6
	SUBI.B	#1,lbB0000A6-WT(A6)
	BNE.L	lbC000172
	MOVE.B	lbB0000A7-WT(A6),lbB0000A6-WT(A6)
	MOVEA.L	lbL00000C-WT(A6),A5
	BSR.L	lbC0002B6
lbC000172	LEA	lbL0000C8(PC),A0
	LEA	$DFF0C0,A1
	BSR.L	lbC0001AC
	LEA	lbL0000E8(PC),A0
	LEA	$DFF0A0,A1
	BSR.L	lbC0001AC
	LEA	lbL0000A8(PC),A0
	LEA	$DFF0B0,A1
	BSR.L	lbC0001AC
	LEA	lbL000108(PC),A0
	LEA	$DFF0D0,A1
	BSR.L	lbC0001AC
	RTS

lbC0001AC	TST.W	$18(A0)
	BEQ.L	lbC0002B4
	MOVE.B	$1C(A0),D0
	BEQ.L	lbC0001D6
	SUBI.B	#1,D0
	BNE.L	lbC0001D6
	MOVE.W	$1A(A0),$DFF096
;	LEA	lbL000008-WT(A6),A2

	lea	Empty,A2

	MOVE.L	A2,(A1)				; address
	CLR.W	$18(A0)
lbC0001D6	MOVE.B	D0,$1C(A0)
	MOVE.B	(A0),D0
	BEQ.L	lbC00021E
	SUBI.B	#1,D0
	BNE.L	lbC00021C
	MOVEA.L	2(A0),A2
lbC0001EC	MOVE.B	(A2)+,D0
	ANDI.W	#$FF,D0
	CMPI.W	#$40,D0
	BLE.L	lbC000210
	CMPI.W	#$FF,D0
	BNE.L	lbC00020A
	MOVEA.L	6(A0),A2
	BRA.L	lbC0001EC

lbC00020A	CLR.B	D0
	BRA.L	lbC00021C

lbC000210
;	MOVE.B	D0,9(A1)		; volume

	bsr.w	ChangeVolume
	bsr.w	SetVol

	MOVE.B	1(A0),D0
	MOVE.L	A2,2(A0)
lbC00021C	MOVE.B	D0,(A0)
lbC00021E	TST.L	$10(A0)
	BNE.L	lbC000268
	ADDI.B	#1,13(A0)
	ANDI.B	#3,13(A0)
	MOVE.B	13(A0),D0
	BEQ.L	lbC00024C
	ANDI.W	#$FF,D0
	MOVE.B	9(A0,D0.W),D0
	BNE.L	lbC00024C
	MOVE.B	#2,13(A0)
lbC00024C	ANDI.W	#$FF,D0
	LEA	lbW000018(PC),A2
	ADD.W	$14(A0),D0
	LSL.W	#1,D0
	ANDI.W	#$FFE,D0
	MOVE.W	0(A2,D0.W),6(A1)		; period
	BRA.L	lbC0002B4

lbC000268	MOVE.B	10(A0),D0
	BEQ.L	lbC0002B4
	SUBI.B	#1,D0
	BNE.L	lbC0002B0
	MOVEA.L	12(A0),A2
	MOVE.B	(A2)+,D0
	CMPI.B	#$40,D0
	BLE.L	lbC00028C
	MOVEA.L	$10(A0),A2
	MOVE.B	(A2)+,D0
lbC00028C	MOVE.W	$18(A0),D1
	EXT.W	D0
	ADD.W	D0,D1
	CMPI.W	#$64,D1
	BGE.L	lbC0002A0
	MOVE.W	#$64,D1
lbC0002A0	MOVE.W	D1,6(A1)		; period
	MOVE.W	D1,$18(A0)
	MOVE.L	A2,12(A0)
	MOVE.B	11(A0),D0
lbC0002B0	MOVE.B	D0,10(A0)
lbC0002B4	RTS

lbC0002B6	LEA	lbC000000(PC),A6
	MOVE.W	lbW000010(PC),D0
	ADDI.W	#1,D0
	MOVE.W	D0,lbW000010-WT(A6)
	CMP.W	lbW000012(PC),D0
	BLE.L	lbC000332
	MOVEA.L	lbL000014(PC),A0
lbC0002D2	MOVEQ	#15,D1
	MOVE.W	(A0)+,D0
	CMPI.W	#$FFFF,D0
	BNE.L	lbC000308

	bsr.w	SongEnd

lbC0002DE	MOVE.W	(A0)+,D0
	MOVEA.L	4(A5),A0
	LEA	0(A0,A5.L),A0
	ANDI.W	#$FFF,D0
	LSL.W	#2,D0
	LEA	0(A0,D0.W),A0
	MOVE.W	(A0)+,D0
	CMPI.W	#$FFFF,D0
	BNE.L	lbC000308
	DBRA	D1,lbC0002DE
	LEA	2(A0),A0
	BRA.L	lbC0002D2

lbC000308	ANDI.W	#$FFF,D0
	MOVE.W	D0,lbW000010-WT(A6)
	MOVE.W	(A0)+,D1
	MOVE.W	D1,lbW000012-WT(A6)
	ANDI.W	#$FFF,lbW000012-WT(A6)
	ROL.W	#4,D1
	ANDI.W	#15,D1
	MOVE.B	D1,lbB0000A6-WT(A6)
	MOVE.B	D1,lbB0000A7-WT(A6)
	MOVE.L	A0,lbL000014-WT(A6)
	SUBI.W	#1,D1
lbC000332	LSL.W	#3,D0
	MOVEA.L	0(A5),A0
	LEA	0(A0,A5.L),A0
	LEA	0(A0,D0.W),A0
	LEA	lbL0000E8(PC),A1
	LEA	$DFF0A0,A4
	BSR.L	lbC000374
	LEA	lbL0000A8(PC),A1
	LEA	$DFF0B0,A4
	BSR.L	lbC000374
	LEA	lbL0000C8(PC),A1
	LEA	$DFF0C0,A4
	BSR.L	lbC000374
	LEA	lbL000108(PC),A1
	LEA	$DFF0D0,A4
lbC000374	MOVE.W	(A0),D0
	BEQ.L	lbC000488
	MOVEA.L	8(A5),A2
	LEA	0(A2,A5.L),A2
	MOVE.W	#$78,6(A4)			; period
	MOVE.W	$1A(A1),$DFF096
	ANDI.W	#$FF,D0
	LSL.W	#4,D0
	LEA	0(A2,D0.W),A2
	MOVE.B	(A2),D0
	ANDI.W	#$7F,D0
	LSL.W	#2,D0
	MOVEA.L	12(A5),A3
	LEA	0(A3,A5.L),A3
	MOVE.L	0(A3,D0.W),D0
	MOVE.W	D0,4(A4)			; length

	bsr.w	SetLen

	CLR.W	D0
	SWAP	D0
	LSL.L	#2,D0
	ADD.L	A5,D0
	MOVE.L	D0,(A4)				; address

	bsr.w	SetTwo

	MOVE.B	2(A2),D0
	ANDI.L	#$7F,D0
	LSL.W	#6,D0
	ADD.L	$10(A5),D0
	ADD.L	A5,D0
	MOVE.L	D0,2(A1)
	MOVE.L	D0,6(A1)
	MOVE.B	3(A2),D0
	BGE.L	lbC0003F4
	ANDI.W	#$7F,D0
	MOVE.B	D0,12(A1)
	MOVE.B	#2,13(A1)
	CLR.L	$10(A1)
	BRA.L	lbC00040A

lbC0003F4	ANDI.L	#$7F,D0
	LSL.W	#6,D0
	ADD.L	$14(A5),D0
	ADD.L	A5,D0
	MOVE.L	D0,12(A1)
	MOVE.L	D0,$10(A1)
lbC00040A	MOVE.W	4(A2),(A1)
	MOVE.W	6(A2),10(A1)
	MOVE.B	(A0),D0
	ANDI.L	#$FF,D0
	MOVE.W	D0,$14(A1)
	MOVE.L	D0,D2
	LSL.W	#1,D0
	LEA	lbW000018(PC),A3
	MOVE.W	0(A3,D0.W),D0
	DIVU.W	#12,D2
	NEG.W	D2
	ADDI.W	#5,D2
	MOVE.B	10(A2),D1
	EXT.W	D1
	ANDI.W	#7,D2
	BEQ.L	lbC000446
	LSL.W	D2,D1
lbC000446	ADD.W	D1,D0
	MOVE.W	D0,$18(A1)
;	MOVE.W	D0,D1
;	LSR.W	#2,D1
;	MOVE.B	9(A2),8(A4)			; volume
;lbC000456	DBRA	D1,lbC000456

	movem.l	D0/A1,-(SP)
	move.b	9(A2),D0
	move.l	A4,A1
	bsr.w	ChangeVolume
	bsr.w	SetVol
	movem.l	(SP)+,D0/A1
	bsr.w	DMAWait

	MOVE.W	D0,6(A4)			; period
	MOVE.W	$1A(A1),D1
	ORI.W	#$8000,D1
	MOVE.W	D1,$DFF096
	MOVE.B	1(A2),D0
	BNE.L	lbC000482
	MOVE.W	#1,4(A4)			; length
	CLR.B	$1C(A1)
	BRA.L	lbC000488

lbC000482	ADDQ.W	#1,D0
	MOVE.B	D0,$1C(A1)
lbC000488	LEA	2(A0),A0
	RTS

;lbL00048E	dc.l	$18

	Section	Buffy,BSS_C

Empty
	ds.b	4
