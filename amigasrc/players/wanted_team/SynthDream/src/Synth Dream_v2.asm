	*****************************************************
	****     Synth Dream replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****      DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Synth Dream player module V1.1 (28 Apr 2007)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	EP_Get_ModuleInfo,Get_ModuleInfo
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_LoadFast!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	TAG_DONE
PlayerName
	dc.b	'Synth Dream',0
Creator
	dc.b	"(c) 1991 by Laurens 'Lotus' Tummers &",10
	dc.b	'John Tonnard, adapted by Wanted Team',0
Prefix
	dc.b	'SDR.',0
SampleName
	dc.b	'SMP.set',0
	even
ModulePtr
	dc.l	0
EndInfo
	dc.l	0
SamplesPtr
	dc.l	0
EagleBase
	dc.l	0
SongEnd
	dc.l	'WTWT'
SongEndTemp
	dc.l	0
Position
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
	move.l	SamplesPtr(PC),D0
	beq.b	return
	move.l	D0,A0

	move.l	ModulePtr(PC),A1
	add.l	(A1),A1
	move.l	EndInfo(PC),D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	tst.l	16(A1)
	beq.b	Normal
	move.w	#USITY_AMSynth,EPS_Type(A3)
	lea	32(A1),A1
	bra.b	Skiper
Normal
	lea	20(A1),A1
	move.l	(A1)+,D1
	add.l	A0,D1
	moveq	#0,D0
	move.w	(A1),D0
	add.l	D0,D0
	move.l	D1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	addq.l	#8,A1
Skiper
	cmp.l	A1,D5
	bne.b	hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	Position(PC),A0
	move.l	4(A0),D0
	sub.l	(A0),D0
	divu.w	#12,D0
	rts

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
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
	cmp.w	#$F0A6,D1
	beq.s	Left1
	cmp.w	#$F0B6,D1
	beq.s	Right1
	cmp.w	#$F0C6,D1
	beq.s	Right2
	cmp.w	#$F0D6,D1
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
	cmp.l	#$DFF0A6,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B6,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C6,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(SP)+,A0
	rts

*-------------------------------- Set All -------------------------------*

SetAll
	move.l	A2,-(SP)
	lea	StructAdr+UPS_Voice1Adr(PC),A2
	cmp.l	#$DFF0A6,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A2
	cmp.l	#$DFF0B6,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A2
	cmp.l	#$DFF0C6,A1
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A2
.SetVoice
	move.l	D5,(A2)
	move.w	(A6),UPS_Voice1Len(A2)
	move.w	$6A(A0),UPS_Voice1Per(A2)
	move.l	(SP)+,A2
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
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	move.l	dtg_ChkSize(A5),D1
	cmp.l	(A0),D1
	bls.b	error
	move.l	A0,A1
	move.l	(A1)+,D1
	beq.b	error
	bmi.b	error
	btst	#0,D1
	bne.b	error
	lea	(A0,D1.L),A2
	cmp.w	#-1,-2(A2)
	bne.b	error
	moveq	#0,D1
	moveq	#1,D2
FirstCheck
	bsr.b	CheckOne
	bne.b	error
	bsr.b	CheckTwo
	bne.b	error
	dbf	D2,FirstCheck
	moveq	#3,D2
SecondCheck
	bsr.b	CheckOne
	bne.b	error
	cmp.w	#40,D1
	beq.b	OK
	lea	-2(A0,D1.W),A2
	cmp.w	#$FEFF,(A2)			; loop
	beq.b	OK
	cmp.w	#$FFFF,(A2)			; stop
	bne.b	error
OK
	dbf	D2,SecondCheck
	moveq	#0,D0
	rts
error
	moveq	#-1,D0
	rts

CheckOne
	tst.w	(A1)+
	bne.b	error
	move.w	(A1)+,D1
	beq.b	error
	bmi.b	error
	btst	#0,D1
	bne.b	error
	rts

CheckTwo
	divu.w	#4,D1
	swap	D1
	tst.w	D1
	bne.b	error
	moveq	#0,D1
	rts

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

	cmpi.b	#'S',(A3)
	beq.b	S_OK
	cmpi.b	#'s',(A3)
	bne.s	ExtError
S_OK
	cmpi.b	#'D',1(A3)
	beq.b	D_OK
	cmpi.b	#'d',1(A3)
	bne.s	ExtError
D_OK
	cmpi.b	#'R',2(A3)
	beq.b	R_OK
	cmpi.b	#'r',2(A3)
	bne.s	ExtError
R_OK
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
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

Get_ModuleInfo
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
LoadSize	=	12
Samples		=	20
Length		=	28
Voices		=	36
SynthSamples	=	44

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_Voices,0		;36
	dc.l	MI_SynthSamples,0	;44
	dc.l	MI_MaxVoices,4
	dc.l	MI_Prefix,Prefix
	dc.l	0

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

	move.l	4(A0),D2
	moveq	#-12,D1
	add.l	D2,D1
	cmp.l	4(A0,D2.L),D0
	ble.b	Short
	lsr.l	#4,D1
	move.l	D1,SubSongs(A4)

	add.l	(A0),A0
	moveq	#0,D1
	moveq	#0,D2
NextSamp
	tst.b	(A0)
	bne.b	LastSamp
	tst.l	16(A0)
	beq.b	Nor
	addq.l	#1,D2
	bra.b	SkipNor
Nor
	tst.w	24(A0)
	beq.b	SkipNor
	addq.l	#1,D1
SkipNor
	lea	32(A0),A0
	bra.b	NextSamp
LastSamp
	move.l	A0,(A6)+			; EndInfo
	move.l	D1,Samples(A4)
	move.l	D2,SynthSamples(A4)

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	move.l	A0,(A6)+			; SamplesPtr
	add.l	D0,LoadSize(A4)
	lea	lbL00001A(PC),A1
	move.l	A0,(A1)

	move.l	A5,(A6)				; EagleBase

	move.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

Short
	moveq	#EPR_ModuleTooShort,D0
	rts

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	move.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(SP)

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

	movem.l	(SP)+,D1-A6
	moveq	#0,D0
	rts

SongEndTest
	movem.l	A1/A5,-(A7)
	lea	SongEnd(PC),A1
	cmp.l	#$DFF0A0,110(A0)
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.l	#$DFF0B0,110(A0)
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.l	#$DFF0C0,110(A0)
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.l	#$DFF0D0,110(A0)
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)+
	bne.b	SkipEnd
	move.l	(A1),-(A1)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
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
	lea	lbL000016(PC),A1
	move.l	A0,(A1)
	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	move.l	D0,D1
	lsl.l	#4,D1
	lea	12(A0,D1.L),A1
	lea	lbL000494+2(PC),A3
	moveq	#3,D3
	moveq	#0,D5
NextLength
	move.l	(A1)+,D1
	lea	(A0,D1.L),A2
	moveq	#0,D1
FindLast
	cmp.w	#$FEFF,(A2)
	beq.b	Last
	cmp.w	#$FFFF,(A2)
	beq.b	Last
	addq.l	#1,D1
	lea	12(A2),A2
	bra.b	FindLast
Last
	cmp.l	D1,D5
	bgt.b	MaxLength
	move.l	D1,D5
	lea	Position(PC),A4
	move.l	A3,(A4)
MaxLength
	lea	206(A3),A3
	dbf	D3,NextLength

	lea	InfoBuffer(PC),A4
	move.l	D5,Length(A4)
	lea	SongEnd(PC),A3
	move.l	#'WTWT',(A3)
	moveq	#4,D4
	bsr.w	Init
	move.l	D4,Voices(A4)
	move.l	-4(A3),(A3)			; SongEndTemp
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
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange	
	moveq	#0,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	subq.l	#1,D1
	rts

***************************************************************************
**************************** Synth Dream player ***************************
***************************************************************************

; Player from game Monster Business (c) 1991 by Eclipse

;	BRA.L	lbC000824

;	BRA.L	lbC000BF8

;	BRA.L	lbC0007DA

;	BRA.L	lbC000800

;lbB000010	dc.b	0
;lbB000011	dc.b	0
;lbB000012	dc.b	0
;lbB000013	dc.b	0
;lbB000014	dc.b	0
;lbB000015	dc.b	0
lbL000016	dc.l	0			; song ptr
lbL00001A	dc.l	0			; samples ptr
;lbL00001E	dc.l	0
;lbW000022	dc.w	0

Play
;lbC000024	NOP
;lbC000026	NOP
	LEA	lbL000494(PC),A0

	tst.b	$78(A0)
	bne.b	Off1

	BSR.S	lbC000060
;	NOP

Off1
	LEA	lbL000562(PC),A0

	tst.b	$78(A0)
	bne.b	Off2

	BSR.S	lbC000060
;	NOP

Off2
	LEA	lbL000630(PC),A0

	tst.b	$78(A0)
	bne.b	Off3

	BSR.S	lbC000060
;	NOP

Off3
	LEA	lbL0006FE(PC),A0

	tst.b	$78(A0)
	bne.b	Off4

	BSR.S	lbC000060
;	MOVE.B	lbL00050C(PC),lbB000012-lbL0006FE(A0)
;	MOVE.B	lbL0005DA(PC),lbB000013-lbL0006FE(A0)
;	MOVE.B	lbL0006A8(PC),lbB000014-lbL0006FE(A0)
;	MOVE.B	lbL000776(PC),lbB000015-lbL0006FE(A0)

Off4
	RTS

lbC000060	TST.W	$1A(A0)
	BNE.L	lbC00010E
	BRA.S	lbC0000C4

lbC00006A	TST.B	$13(A0)
	BEQ.S	lbC00007C
	SUBQ.B	#1,$13(A0)
	MOVE.L	10(A0),14(A0)
	BRA.S	lbC0000C4

lbC00007C	CLR.L	$B0(A0)
	CLR.L	$B6(A0)
	MOVEA.L	6(A0),A1
	CMPI.B	#$FE,(A1)
	BCS.S	lbC0000B2			; song loop
	BHI.S	lbC000096			; song stop
	MOVEA.L	2(A0),A1

	bsr.w	SongEndTest

	BRA.S	lbC0000B2

lbC000096
;	LEA	lbC000026(PC),A1
;	LEA	lbL000494(PC),A2
;lbC00009E	CMPA.L	A0,A2
;	BNE.S	lbC0000A8
;	MOVE.W	#$6006,(A1)			; bra.b

	st	$78(A0)
	bsr.w	SongEndTest

	RTS

;lbC0000A8	LEA	8(A1),A1
;	LEA	$CE(A2),A2
;	BRA.S	lbC00009E

lbC0000B2	MOVEM.L	(A1)+,D0-D2
	MOVE.L	D0,10(A0)
	MOVEM.L	D0-D2,14(A0)
	MOVE.L	A1,6(A0)
lbC0000C4
;	TST.B	$78(A0)				; FX check in original
;	BNE.S	lbC0000D6
	CLR.L	$5E(A0)
	CLR.L	$56(A0)
	CLR.L	$5A(A0)
lbC0000D6	MOVEA.L	14(A0),A1
	ADDA.L	lbL000016(PC),A1
	CMPI.B	#$FF,(A1)
	BEQ.S	lbC00006A
	LEA	lbW000C40(PC),A3
	MOVE.W	(A1)+,D2
	MOVE.W	0(A3,D2.W),D2
	JSR	0(A3,D2.W)
lbC0000F2	CMPI.W	#$24,(A1)
	BCS.S	lbC000106
	BMI.S	lbC000106
	MOVE.W	(A1),D2
	MOVE.W	0(A3,D2.W),D2
	JSR	0(A3,D2.W)
	BRA.S	lbC0000F2

lbC000106	SUBA.L	lbL000016(PC),A1
	MOVE.L	A1,14(A0)
lbC00010E	MOVE.L	lbL000016(PC),D5
;	TST.B	$78(A0)
;	BNE.L	lbC000950			; FX check in original
	TST.B	$61(A0)
	BEQ.S	lbC00012E
	MOVE.W	$74(A0),$DFF096			; DMA off
	SUBQ.W	#1,$1A(A0)
	RTS

lbC00012E	TST.L	$B0(A0)
	BEQ.S	lbC000150
	TST.W	$AE(A0)
	BNE.S	lbC00014C
	MOVE.L	$B0(A0),$46(A0)
	CLR.W	$B0(A0)
	SF	$56(A0)
	SF	$5A(A0)
lbC00014C	SUBQ.W	#1,$AE(A0)
lbC000150	TST.L	$B6(A0)
	BEQ.S	lbC000172
	TST.W	$B4(A0)
	BNE.S	lbC00016E
	MOVE.L	$B6(A0),$4A(A0)
	CLR.W	$B6(A0)
	SF	$57(A0)
	SF	$5B(A0)
lbC00016E	SUBQ.W	#1,$B4(A0)
lbC000172	MOVE.B	#$40,$6D(A0)
	MOVEM.L	$46(A0),A3-A6
	TST.L	$2A(A0)
	BEQ.S	lbC0001D0
	TST.B	$56(A0)
	BNE.S	lbC0001C0
	TST.B	$5A(A0)
	BEQ.S	lbC0001A0
	MOVE.W	$62(A0),D0
	SUBA.W	D0,A3
	MOVE.B	D0,$56(A0)
	SUBQ.B	#1,$5A(A0)
	BRA.S	lbC0001C0

lbC0001A0	CMPI.B	#$FF,0(A3,D5.L)
	BNE.S	lbC0001AC
	MOVEA.L	$2A(A0),A3
lbC0001AC	MOVE.B	0(A3,D5.L),$56(A0)
	MOVE.B	0(A3,D5.L),$63(A0)
	MOVE.B	1(A3,D5.L),$5A(A0)
	ADDQ.W	#2,A3
lbC0001C0	MOVE.B	0(A3,D5.L),$6D(A0)
	ADDQ.W	#1,A3
	MOVE.L	A3,$46(A0)
	SUBQ.B	#1,$56(A0)
lbC0001D0	MOVE.B	$6D(A0),D0
	SUB.B	$21(A0),D0
	SUB.B	$17(A0),D0
;	SUB.B	lbB000011(PC),D0
	BPL.S	lbC0001E4
	MOVEQ	#0,D0
lbC0001E4	MOVE.B	D0,$6D(A0)
	TST.L	$32(A0)
	BEQ.S	lbC00023A
	TST.B	$58(A0)
	BNE.S	lbC00022A
	TST.B	$5C(A0)
	BEQ.S	lbC00020A
	MOVE.W	$66(A0),D0
	SUBA.W	D0,A5
	MOVE.B	D0,$58(A0)
	SUBQ.B	#1,$5C(A0)
	BRA.S	lbC00022A

lbC00020A	CMPI.B	#$FF,0(A5,D5.L)
	BNE.S	lbC000216
	MOVEA.L	$32(A0),A5
lbC000216	MOVE.B	0(A5,D5.L),$58(A0)
	MOVE.B	0(A5,D5.L),$67(A0)
	MOVE.B	1(A5,D5.L),$5C(A0)
	ADDQ.W	#2,A5
lbC00022A	MOVE.B	0(A5,D5.L),$60(A0)
	ADDQ.W	#1,A5
	MOVE.L	A5,$4E(A0)
	SUBQ.B	#1,$58(A0)
lbC00023A	TST.L	$2E(A0)
	BEQ.L	lbC00030A
	TST.B	$57(A0)
	BNE.S	lbC000280
	TST.B	$5B(A0)
	BEQ.S	lbC000260
	MOVE.W	$64(A0),D0
	SUBA.W	D0,A4
	SUBA.W	D0,A4
	MOVE.B	D0,$57(A0)
	SUBQ.B	#1,$5B(A0)
	BRA.S	lbC000280

lbC000260
;	CMPI.B	#$FF,0(A4,D5.W)				; bug!!!

	cmp.b	#$FF,(A4,D5.L)

	BNE.S	lbC00026C
	MOVEA.L	$2E(A0),A4
lbC00026C	MOVE.B	0(A4,D5.L),$57(A0)
	MOVE.B	0(A4,D5.L),$65(A0)
	MOVE.B	1(A4,D5.L),$5B(A0)
	ADDQ.W	#2,A4
lbC000280	MOVE.B	0(A4,D5.L),$CC(A0)
	MOVE.B	1(A4,D5.L),$CD(A0)
	MOVE.W	$CC(A0),D4
	ADDQ.W	#2,A4
	MOVE.L	A4,$4A(A0)
	SUBQ.B	#1,$57(A0)
	MOVEQ	#0,D3
	TST.W	D4
	BMI.S	lbC0002D4
	LEA	lbL0013F6(PC),A1
	LEA	lbL000FB6(PC),A5
	MOVE.W	$1E(A0),D0
	TST.B	$27(A0)
	BNE.S	lbC0002B6
	ADD.B	$12(A0),D0
lbC0002B6	ADD.B	$60(A0),D0
	ADD.W	D0,D0
	MOVE.W	0(A5,D0.W),D3
	ADD.W	D4,D4
	MOVE.W	0(A1,D4.W),D2
	MULU.W	D2,D3
	LSR.L	#8,D3
	LSR.L	#5,D3
	MOVE.W	D3,$6A(A0)
	BRA.L	lbC000328

lbC0002D4	MOVEQ	#0,D3
	LEA	lbL0010D6(PC),A1
	LEA	lbL000FB6(PC),A5
	MOVE.W	$1E(A0),D0
	TST.B	$27(A0)
	BNE.S	lbC0002EC
	ADD.B	$12(A0),D0
lbC0002EC	ADD.B	$60(A0),D0
	ADD.W	D0,D0
	MOVE.W	0(A5,D0.W),D3
	NEG.W	D4
	ADD.W	D4,D4
	MOVE.W	0(A1,D4.W),D2
	MULU.W	D2,D3
	LSR.L	#8,D3
	LSR.L	#5,D3
	MOVE.W	D3,$6A(A0)
	BRA.S	lbC000328

lbC00030A	LEA	lbL000FB6(PC),A5
	MOVE.W	$1E(A0),D0
	TST.B	$27(A0)
	BNE.S	lbC00031C
	ADD.B	$12(A0),D0
lbC00031C	ADD.B	$60(A0),D0
	ADD.W	D0,D0
	MOVE.W	0(A5,D0.W),$6A(A0)
lbC000328	MOVE.W	$6A(A0),D3
	MOVE.W	$5E(A0),D6
	BEQ.S	lbC000354
	TST.W	$AC(A0)
	BEQ.S	lbC00033E
	SUBQ.W	#1,$AC(A0)
	BRA.S	lbC000354

lbC00033E	MOVE.W	$76(A0),D7
	MULU.W	D7,D6
	MOVEQ	#13,D7
	LSR.L	D7,D6
	MOVE.W	D6,$5E(A0)
	MULU.W	D6,D3
	LSR.L	D7,D3
	MOVE.W	D3,$6A(A0)
lbC000354	TST.L	$36(A0)
	BEQ.L	lbC0003E4
	TST.B	$59(A0)
	BNE.S	lbC00039A
	TST.B	$5D(A0)
	BEQ.S	lbC00037A
	MOVE.W	$68(A0),D0
	SUBA.W	D0,A6
	SUBA.W	D0,A6
	MOVE.B	D0,$59(A0)
	SUBQ.B	#1,$5D(A0)
	BRA.S	lbC00039A

lbC00037A	CMPI.B	#$FF,0(A6,D5.L)
	BNE.S	lbC000386
	MOVEA.L	$36(A0),A6
lbC000386	MOVE.B	0(A6,D5.L),$59(A0)
	MOVE.B	0(A6,D5.L),$69(A0)
	MOVE.B	1(A6,D5.L),$5D(A0)
	ADDQ.W	#2,A6
lbC00039A	MOVE.B	0(A6,D5.L),$CC(A0)
	MOVE.B	1(A6,D5.L),$CD(A0)
	MOVE.W	$CC(A0),D4
	ADDQ.W	#2,A6
	MOVE.W	D4,D7
	MOVE.L	A6,$52(A0)
	SUBQ.B	#1,$59(A0)
	LSR.W	#8,D4
	MOVE.W	D4,D6
	LSL.W	#4,D4
	ANDI.W	#$FF,D7
	LEA	lbL001716(PC),A1
	MOVEM.L	0(A1,D4.W),D0-D3
;	LEA	$BA(A0),A1

	move.l	$BA(A0),A1

	MOVEM.L	D0-D3,(A1)
	SUB.B	D7,0(A1,D6.W)
	LEA	lbL000FAA(PC),A6
	SUBA.L	D5,A1
	MOVE.L	A1,(A6)
	MOVE.L	A1,6(A6)
	BRA.S	lbC0003EC

lbC0003E4	MOVE.L	lbL00001A(PC),D5
	LEA	$3A(A0),A6
lbC0003EC	MOVE.W	$28(A0),D2
	MOVE.W	$6A(A0),D3
	TST.W	D2
	BEQ.S	lbC00041E
	BMI.S	lbC00040C
	LEA	lbL0013F6(PC),A1
	MOVEQ	#13,D0
	MULU.W	0(A1,D2.W),D3
	LSR.L	D0,D3
	MOVE.W	D3,$6A(A0)
	BRA.S	lbC00041E

lbC00040C	NEG.W	D2
	LEA	lbL0010D6(PC),A1
	MOVEQ	#13,D0
	MULU.W	0(A1,D2.W),D3
	LSR.L	D0,D3
	MOVE.W	D3,$6A(A0)
lbC00041E	MOVEA.L	$6E(A0),A1
	MOVE.W	$1C(A0),D0
	SUBQ.W	#1,D0
	CMP.W	$1A(A0),D0
	BCS.S	lbC00044C
	BNE.S	lbC000464
	ADD.L	6(A6),D5
	MOVE.L	D5,(A1)+			; address
	MOVE.W	10(A6),(A1)+			; length
;	MOVE.L	$6A(A0),(A1)			; period/volume

	move.w	$6A(A0),(A1)
	move.l	D0,-(SP)
	move.w	$6C(A0),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,2(A1)
	move.l	(SP)+,D0

	MOVE.W	$72(A0),$DFF096			; DMA on
	SUBQ.W	#1,$1A(A0)
	RTS

lbC00044C	ADD.L	(A6)+,D5
	MOVE.L	D5,(A1)+			; address
	MOVE.W	(A6),(A1)+			; length	
;	MOVE.L	$6A(A0),(A1)			; period/volume

	move.w	$6A(A0),(A1)
	bsr.w	SetAll
	move.l	D0,-(SP)
	move.w	$6C(A0),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,2(A1)
	move.l	(SP)+,D0

	MOVE.W	$72(A0),$DFF096			; DMA on
	SUBQ.W	#1,$1A(A0)
	RTS

lbC000464
;	MOVE.L	$6A(A0),6(A1)			; period/volume

	addq.l	#6,A1
	move.w	$6A(A0),(A1)
	move.l	D0,-(SP)
	move.w	$6C(A0),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,2(A1)
	move.l	(SP)+,D0

	CMPI.W	#1,$1A(A0)
	BNE.S	lbC000486
	TST.B	$CA(A0)
	BNE.S	lbC000480
	MOVE.W	$74(A0),$DFF096			; DMA off
lbC000480	SUBQ.W	#1,$1A(A0)
	RTS

lbC000486	MOVE.W	$72(A0),$DFF096		; DMA on
	SUBQ.W	#1,$1A(A0)
	RTS

lbL000494	dc.l	0
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
	dc.w	0
lbL000502	dc.l	0
	dc.l	0
	dc.w	0
lbL00050C
	dc.w	0
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
	dc.l	Buffy				; +
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbW000560	dc.w	0
lbL000562	dc.l	0
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
lbL0005DA
	dc.w	0
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
	dc.l	Buffy+16			; +
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000630	dc.l	0
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
lbL0006A8
	dc.w	0
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
	dc.l	Buffy+32			; +
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL0006FE	dc.l	0
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
lbL000776
	dc.w	0
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
	dc.l	Buffy+48			; +
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbW0007CC	dc.w	0
lbL0007CE	dc.l	0
lbL0007D2	dc.l	0
lbL0007D6	dc.l	0

;lbC0007DA	LEA	lbW0007CC(PC),A6
;	TST.B	(A6)
;	BNE.S	lbC0007FC
;	MOVE.B	lbB000010(PC),(A6)
;	LEA	lbB000011(PC),A5
;	CMPI.B	#$40,(A5)
;	BNE.S	lbC0007FA
;	LEA	lbB000010(PC),A6
;	BSET	#7,(A6)
;	RTS

;lbC0007FA	ADDQ.B	#1,(A5)
;lbC0007FC	SUBQ.B	#1,(A6)
;	RTS

;lbC000800	LEA	lbW0007CC(PC),A6
;	TST.B	(A6)
;	BNE.S	lbC000820
;	MOVE.B	lbB000010(PC),(A6)
;	LEA	lbB000011(PC),A5
;	TST.B	(A5)
;	BNE.S	lbC00081E
;	LEA	lbB000010(PC),A6
;	BSET	#7,(A6)
;	RTS

;lbC00081E	SUBQ.B	#1,(A5)
;lbC000820	SUBQ.B	#1,(A6)
;	RTS

Init
;lbC000824	MOVEM.L	D0-D7/A0-A6,-(SP)
;	ANDI.L	#$FF,D0
;	CMP.B	#$FF,D0
;	BNE.S	lbC000868
;	CLR.W	$DFF0A8
;	CLR.W	$DFF0B8
;	CLR.W	$DFF0C8
;	CLR.W	$DFF0D8
;	MOVE.W	#15,$DFF096
;	LEA	lbC000024(PC),A0
;	MOVE.W	#$4E75,(A0)			; rts
;	ANDI.B	#$FD,$BFE001
;	BRA.L	lbC00093E

lbC000868	MOVEA.L	lbL000016(PC),A0
	LEA	lbL0007CE(PC),A1
	MOVEM.L	(A0),D1-D3
	ADD.L	A0,D1
	ADD.L	A0,D2
	ADD.L	A0,D3
	MOVEM.L	D1-D3,(A1)
;	LEA	lbC000024(PC),A3
;	MOVE.W	#$4E71,(A3)+			; nop
	LSL.W	#4,D0
	LEA	lbL000494(PC),A1
	MOVEQ	#3,D1
lbC00088E	CLR.W	(A1)
	CLR.W	$1A(A1)
	CLR.B	$78(A1)
	SF	$CA(A1)
	MOVEA.L	12(A0,D0.W),A2
	ADDA.L	A0,A2
	MOVE.L	A2,2(A1)
	MOVE.L	A2,6(A1)
	MOVE.L	(A2),10(A1)
	MOVE.L	(A2),14(A1)
	MOVE.L	4(A2),$12(A1)
	MOVE.L	8(A2),$16(A1)
	ADDI.L	#12,6(A1)
;	MOVE.W	#$4E71,(A3)			; nop
	CMPI.B	#$FF,(A2)
	BNE.S	lbC0008D4
;	MOVE.W	#$6006,(A3)			; bra.b

	st	$78(A1)
	clr.b	(A3)
	subq.l	#1,D4

lbC0008D4
;	ADDQ.W	#8,A3

	addq.l	#1,A3

	LEA	$CE(A1),A1
	ADDQ.W	#4,D0
	DBRA	D1,lbC00088E
	LEA	lbL000502(PC),A0
	MOVE.L	#$DFF0A0,(A0)
	MOVE.L	#$DFF0B0,$CE(A0)
	MOVE.L	#$DFF0C0,$19C(A0)
	MOVE.L	#$DFF0D0,$26A(A0)
	MOVE.L	#$80010001,4(A0)
	MOVE.L	#$80020002,$D2(A0)
	MOVE.L	#$80040004,$1A0(A0)
	MOVE.L	#$80080008,$26E(A0)
;	TST.B	lbW000022-lbL000502(A0)
;	BNE.S	lbC000932
;	ORI.B	#2,$BFE001
;	BRA.S	lbC00093A

;lbC000932	ANDI.B	#$FD,$BFE001
;lbC00093A	SF	$2CA(A0)
;lbC00093E	LEA	lbB000012(PC),A0
;	SF	(A0)+
;	SF	(A0)+
;	SF	(A0)+
;	SF	(A0)
;	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

;lbC000950	MOVE.L	lbL00001E(PC),D5
;	SUBQ.W	#1,$1A(A0)
;	TST.W	$7C(A0)
;	BNE.S	lbC000968
;	SF	$78(A0)
;	ST	$61(A0)
;	RTS

;lbC000968	ST	$78(A0)
;	MOVE.B	#$40,$6D(A0)
;	MOVEM.L	$80(A0),A3-A6
;	TST.L	$90(A0)
;	BEQ.S	lbC0009C8
;	TST.B	$56(A0)
;	BNE.S	lbC0009B8
;	TST.B	$5A(A0)
;	BEQ.S	lbC00099A
;	MOVE.W	$62(A0),D0
;	SUBA.W	D0,A3
;	MOVE.B	D0,$56(A0)
;	SUBQ.B	#1,$5A(A0)
;	BRA.S	lbC0009B8

;lbC00099A	CMPI.B	#$FF,(A3)
;	BNE.S	lbC0009A4
;	MOVEA.L	$90(A0),A3
;lbC0009A4	MOVE.B	0(A3,D5.L),$56(A0)
;	MOVE.B	0(A3,D5.L),$63(A0)
;	MOVE.B	1(A3,D5.L),$5A(A0)
;	ADDQ.W	#2,A3
;lbC0009B8	MOVE.B	0(A3,D5.L),$6D(A0)
;	ADDQ.W	#1,A3
;	MOVE.L	A3,$80(A0)
;	SUBQ.B	#1,$56(A0)
;lbC0009C8	MOVE.B	$6D(A0),D0
;	SUB.B	$7F(A0),D0
;	SUB.B	lbB000011(PC),D0
;	BPL.S	lbC0009D8
;	MOVEQ	#0,D0
;lbC0009D8	MOVE.B	D0,$6D(A0)
;	TST.L	$98(A0)
;	BEQ.S	lbC000A2C
;	TST.B	$58(A0)
;	BNE.S	lbC000A1C
;	TST.B	$5C(A0)
;	BEQ.S	lbC0009FE
;	MOVE.W	$66(A0),D0
;	SUBA.W	D0,A5
;	MOVE.B	D0,$58(A0)
;	SUBQ.B	#1,$5C(A0)
;	BRA.S	lbC000A1C

;lbC0009FE	CMPI.B	#$FF,(A5)
;	BNE.S	lbC000A08
;	MOVEA.L	$98(A0),A5
;lbC000A08	MOVE.B	0(A5,D5.L),$58(A0)
;	MOVE.B	0(A5,D5.L),$67(A0)
;	MOVE.B	1(A5,D5.L),$5C(A0)
;	ADDQ.W	#2,A5
;lbC000A1C	MOVE.B	0(A5,D5.L),$60(A0)
;	ADDQ.W	#1,A5
;	MOVE.L	A5,$88(A0)
;	SUBQ.B	#1,$58(A0)
;lbC000A2C	TST.L	$94(A0)
;	BEQ.L	lbC000AEA
;	TST.B	$57(A0)
;	BNE.S	lbC000A70
;	TST.B	$5B(A0)
;	BEQ.S	lbC000A52
;	MOVE.W	$64(A0),D0
;	SUBA.W	D0,A4
;	SUBA.W	D0,A4
;	MOVE.B	D0,$57(A0)
;	SUBQ.B	#1,$5B(A0)
;	BRA.S	lbC000A70

;lbC000A52	CMPI.B	#$FF,(A4)
;	BNE.S	lbC000A5C
;	MOVEA.L	$94(A0),A4
;lbC000A5C	MOVE.B	0(A4,D5.L),$57(A0)
;	MOVE.B	0(A4,D5.L),$65(A0)
;	MOVE.B	1(A4,D5.L),$5B(A0)
;	ADDQ.W	#2,A4
;lbC000A70	MOVE.B	0(A4,D5.L),$CC(A0)
;	MOVE.B	1(A4,D5.L),$CD(A0)
;	ADDQ.W	#2,A4
;	MOVE.W	lbW000560(PC),D4
;	MOVE.L	A4,$84(A0)
;	SUBQ.B	#1,$57(A0)
;	MOVEQ	#0,D3
;	TST.W	D4
;	BMI.S	lbC000ABC
;	LEA	lbL0013F6(PC),A1
;	LEA	lbL000FB6(PC),A5
;	MOVEQ	#0,D0
;	MOVE.B	$7E(A0),D0
;	ADD.B	$60(A0),D0
;	ADD.W	D0,D0
;	MOVE.W	0(A5,D0.W),D3
;	ADD.W	D4,D4
;	MOVE.W	0(A1,D4.W),D2
;	MULU.W	D2,D3
;	MOVEQ	#13,D7
;	LSR.L	D7,D3
;	MOVE.W	D3,$6A(A0)
;	BRA.L	lbC000B00

;lbC000ABC	MOVEQ	#0,D3
;	LEA	lbL0010D6(PC),A1
;	LEA	lbL000FB6(PC),A5
;	MOVEQ	#0,D0
;	MOVE.B	$7E(A0),D0
;	ADD.B	$60(A0),D0
;	ADD.W	D0,D0
;	MOVE.W	0(A5,D0.W),D3
;	NEG.W	D4
;	ADD.W	D4,D4
;	MOVE.W	0(A1,D4.W),D2
;	MULU.W	D2,D3
;	MOVEQ	#13,D7
;	LSR.L	D7,D3
;	MOVE.W	D3,$6A(A0)
;	BRA.S	lbC000B00

;lbC000AEA	LEA	lbL000FB6(PC),A5
;	MOVEQ	#0,D0
;	MOVE.B	$7E(A0),D0
;	ADD.B	$60(A0),D0
;	ADD.W	D0,D0
;	MOVE.W	0(A5,D0.W),$6A(A0)
;lbC000B00	TST.L	$9C(A0)
;	BEQ.S	lbC000B82
;	TST.B	$59(A0)
;	BNE.S	lbC000B44
;	TST.B	$5D(A0)
;	BEQ.S	lbC000B24
;	MOVE.W	$68(A0),D0
;	SUBA.W	D0,A6
;	SUBA.W	D0,A6
;	MOVE.B	D0,$59(A0)
;	SUBQ.B	#1,$5D(A0)
;	BRA.S	lbC000B44

;lbC000B24	CMPI.B	#$FF,0(A6,D5.L)
;	BNE.S	lbC000B30
;	MOVEA.L	$9C(A0),A6
;lbC000B30	MOVE.B	0(A6,D5.L),$59(A0)
;	MOVE.B	0(A6,D5.L),$69(A0)
;	MOVE.B	1(A6,D5.L),$5D(A0)
;	ADDQ.W	#2,A6
;lbC000B44	MOVE.W	0(A6,D5.L),D4
;	ADDQ.W	#2,A6
;	MOVE.W	D4,D7
;	MOVE.L	A6,$8C(A0)
;	SUBQ.B	#1,$59(A0)
;	LSR.W	#8,D4
;	MOVE.W	D4,D6
;	LSL.W	#4,D4
;	ANDI.W	#$FF,D7
;	LEA	lbL001716(PC),A1
;	MOVEM.L	0(A1,D4.W),D0-D3
;	LEA	$BA(A0),A1
;	MOVEM.L	D0-D3,(A1)
;	SUB.B	D7,0(A1,D6.W)
;	LEA	lbL000FAA(PC),A6
;	SUBA.L	D5,A1
;	MOVE.L	A1,(A6)
;	MOVE.L	A1,6(A6)
;	BRA.S	lbC000B8A

;lbC000B82	LEA	$A0(A0),A6
;	MOVE.L	lbL00001A(PC),D5
;lbC000B8A	MOVEA.L	$6E(A0),A1
;	MOVE.W	$7A(A0),D0
;	CMP.W	$7C(A0),D0
;	BCS.S	lbC000BB6
;	BNE.S	lbC000BCE
;	ADD.L	6(A6),D5
;	MOVE.L	D5,(A1)+
;	MOVE.W	10(A6),(A1)+
;	MOVE.L	$6A(A0),(A1)+
;	MOVE.W	$72(A0),$DFF096
;	SUBQ.W	#1,$7C(A0)
;	RTS

;lbC000BB6	ADD.L	(A6)+,D5
;	MOVE.L	D5,(A1)+
;	MOVE.W	(A6),(A1)+
;	MOVE.L	$6A(A0),(A1)+
;	MOVE.W	$72(A0),$DFF096
;	SUBQ.W	#1,$7C(A0)
;	RTS

;lbC000BCE	MOVE.L	$6A(A0),6(A1)
;	CMPI.W	#1,$7C(A0)
;	BNE.S	lbC000BEA
;	MOVE.W	$74(A0),$DFF096
;	SUBQ.W	#1,$7C(A0)
;	RTS

;lbC000BEA	MOVE.W	$72(A0),$DFF096
;	SUBQ.W	#1,$7C(A0)
;	RTS

;lbC000BF8	LEA	lbL000494(PC),A0
;	MULU.W	#$CE,D0
;	LEA	0(A0,D0.W),A0
;	MOVE.W	$74(A0),$DFF096
;	LSL.W	#5,D1
;	MOVEA.L	lbL00001E(PC),A1
;	MOVEM.L	0(A1,D1.W),D0-D7
;	MOVEM.L	D0-D7,$7C(A0)
;	MOVEM.L	D1-D7,$90(A0)
;	MOVE.W	$7C(A0),$7A(A0)
;	SUBQ.W	#1,$7A(A0)
;	SF	$60(A0)
;	CLR.L	$5A(A0)
;	CLR.L	$56(A0)
;	ST	$78(A0)
;	RTS

lbW000C40	dc.w	lbC000CDC-lbW000C40
	dc.w	lbC000CF0-lbW000C40
	dc.w	lbC000D06-lbW000C40
	dc.w	lbC000D1E-lbW000C40
	dc.w	lbC000D36-lbW000C40
	dc.w	lbC000D62-lbW000C40
	dc.w	lbC000D7C-lbW000C40
	dc.w	lbC000D96-lbW000C40
	dc.w	lbC000DC4-lbW000C40
	dc.w	lbC000DE0-lbW000C40
	dc.w	lbC000E10-lbW000C40
	dc.w	lbC000E2E-lbW000C40
	dc.w	lbC000E60-lbW000C40
	dc.w	lbC000EC8-lbW000C40
	dc.w	lbC000EFC-lbW000C40
	dc.w	lbC000F32-lbW000C40
	dc.w	lbC000F4C-lbW000C40
	dc.w	lbC000F4C-lbW000C40
	dc.w	lbC000CB4-lbW000C40
	dc.w	lbC000CAC-lbW000C40
	dc.w	lbC000CA4-lbW000C40
	dc.w	lbC000C70-lbW000C40
	dc.w	lbC000C8A-lbW000C40
	dc.w	lbC000CC8-lbW000C40

lbC000C70	ADDQ.W	#2,A1
	LEA	lbL0010D6(PC),A2
	MOVE.W	(A1)+,$AC(A0)
	MOVE.W	(A1)+,D0
	MOVE.W	0(A2,D0.W),$76(A0)
	MOVE.W	#$2000,$5E(A0)
	RTS

lbC000C8A	ADDQ.W	#2,A1
	LEA	lbL0013F6(PC),A2
	MOVE.W	(A1)+,$AC(A0)
	MOVE.W	(A1)+,D0
	MOVE.W	0(A2,D0.W),$76(A0)
	MOVE.W	#$2000,$5E(A0)
	RTS

lbC000CA4	ST	$CA(A0)
	ADDQ.W	#2,A1
	RTS

lbC000CAC	SF	$CA(A0)
	ADDQ.W	#2,A1
	RTS

lbC000CB4	ADDQ.W	#2,A1
	MOVE.W	(A1)+,$AE(A0)
	MOVEA.L	lbL0007D2(PC),A6
	MOVE.W	(A1)+,D0
	MOVE.L	0(A6,D0.W),$B0(A0)
	RTS

lbC000CC8	ADDQ.W	#2,A1
	MOVE.W	(A1)+,$B4(A0)
	MOVEA.L	lbL0007D6(PC),A6
	MOVE.W	(A1)+,D0
	MOVE.L	0(A6,D0.W),$B6(A0)
	RTS

lbC000CDC	MOVE.W	$1C(A0),$1A(A0)
	MOVEM.L	$2A(A0),D1-D4
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000CF0	MOVE.W	(A1),$1C(A0)
	MOVE.W	(A1)+,$1A(A0)
	MOVEM.L	$2A(A0),D1-D4
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000D06	MOVE.W	$1C(A0),$1A(A0)
	MOVE.W	(A1)+,$1E(A0)
	MOVEM.L	$2A(A0),D1-D4
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000D1E	MOVE.W	$1C(A0),$1A(A0)
	MOVE.W	(A1)+,$20(A0)
	MOVEM.L	$2A(A0),D1-D4
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000D36	MOVE.W	$1C(A0),$1A(A0)
	MOVE.W	(A1)+,D0
	CMP.B	$14(A0),D0
	BNE.S	lbC000D48
	MOVE.B	$15(A0),D0
lbC000D48	LSL.W	#5,D0
	MOVEA.L	lbL0007CE(PC),A2
	MOVEM.L	0(A2,D0.W),D0-D7
	MOVEM.L	D0-D7,$26(A0)
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000D62	MOVE.W	(A1),$1C(A0)
	MOVE.W	(A1)+,$1A(A0)
	MOVE.W	(A1)+,$1E(A0)
	MOVEM.L	$2A(A0),D1-D4
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000D7C	MOVE.W	(A1),$1C(A0)
	MOVE.W	(A1)+,$1A(A0)
	MOVE.W	(A1)+,$20(A0)
	MOVEM.L	$2A(A0),D1-D4
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000D96	MOVE.W	(A1),$1C(A0)
	MOVE.W	(A1)+,$1A(A0)
	MOVE.W	(A1)+,D0
	CMP.B	$14(A0),D0
	BNE.S	lbC000DAA
	MOVE.B	$15(A0),D0
lbC000DAA	LSL.W	#5,D0
	MOVEA.L	lbL0007CE(PC),A2
	MOVEM.L	0(A2,D0.W),D0-D7
	MOVEM.L	D0-D7,$26(A0)
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000DC4	MOVE.W	$1C(A0),$1A(A0)
	MOVE.W	(A1)+,$1E(A0)
	MOVE.W	(A1)+,$20(A0)
	MOVEM.L	$2A(A0),D1-D4
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000DE0	MOVE.W	$1C(A0),$1A(A0)
	MOVE.W	(A1)+,$1E(A0)
	MOVE.W	(A1)+,D0
	CMP.B	$14(A0),D0
	BNE.S	lbC000DF6
	MOVE.B	$15(A0),D0
lbC000DF6	LSL.W	#5,D0
	MOVEA.L	lbL0007CE(PC),A2
	MOVEM.L	0(A2,D0.W),D0-D7
	MOVEM.L	D0-D7,$26(A0)
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000E10	MOVE.W	(A1),$1C(A0)
	MOVE.W	(A1)+,$1A(A0)
	MOVE.W	(A1)+,$1E(A0)
	MOVE.W	(A1)+,$20(A0)
	MOVEM.L	$2A(A0),D1-D4
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000E2E	MOVE.W	(A1),$1C(A0)
	MOVE.W	(A1)+,$1A(A0)
	MOVE.W	(A1)+,$1E(A0)
	MOVE.W	(A1)+,D0
	CMP.B	$14(A0),D0
	BNE.S	lbC000E46
	MOVE.B	$15(A0),D0
lbC000E46	LSL.W	#5,D0
	MOVEA.L	lbL0007CE(PC),A2
	MOVEM.L	0(A2,D0.W),D0-D7
	MOVEM.L	D0-D7,$26(A0)
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000E60	MOVEQ	#0,D0
	MOVE.W	(A1),$1C(A0)
	MOVE.W	(A1)+,$1A(A0)
	MOVEM.L	$2A(A0),D1-D4
	MOVEM.L	D1-D4,$46(A0)
	MOVE.W	(A1)+,$1E(A0)
	CMPI.W	#$FD00,(A1)+
	BNE.S	lbC000EA4
	LEA	lbL0013F6(PC),A2
	MOVE.W	(A1)+,D0
	MOVE.W	$1C(A0),D1
	MOVE.W	(A1)+,D2
	MOVE.W	D2,$AC(A0)
	SUB.W	D2,D1
	DIVU.W	D1,D0
	ADD.W	D0,D0
	MOVE.W	0(A2,D0.W),$76(A0)
	MOVE.W	#$2000,$5E(A0)
	RTS

lbC000EA4	LEA	lbL0010D6(PC),A2
	MOVE.W	(A1)+,D0
	MOVE.W	$1C(A0),D1
	MOVE.W	(A1)+,D2
	MOVE.W	D2,$AC(A0)
	SUB.W	D2,D1
	DIVU.W	D1,D0
	ADD.W	D0,D0
	MOVE.W	0(A2,D0.W),$76(A0)
	MOVE.W	#$2000,$5E(A0)
	RTS

lbC000EC8	MOVE.W	$1C(A0),$1A(A0)
	MOVE.W	(A1)+,$1E(A0)
	MOVE.W	(A1)+,$20(A0)
	MOVE.W	(A1)+,D0
	CMP.B	$14(A0),D0
	BNE.S	lbC000EE2
	MOVE.B	$15(A0),D0
lbC000EE2	LSL.W	#5,D0
	MOVEA.L	lbL0007CE(PC),A2
	MOVEM.L	0(A2,D0.W),D0-D7
	MOVEM.L	D0-D7,$26(A0)
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000EFC	MOVE.W	(A1),$1C(A0)
	MOVE.W	(A1)+,$1A(A0)
	MOVE.W	(A1)+,$1E(A0)
	MOVE.W	(A1)+,$20(A0)
lbC000F0C	MOVE.W	(A1)+,D0
	CMP.B	$14(A0),D0
	BNE.S	lbC000F18
	MOVE.B	$15(A0),D0
lbC000F18	LSL.W	#5,D0
	MOVEA.L	lbL0007CE(PC),A2
	MOVEM.L	0(A2,D0.W),D0-D7
	MOVEM.L	D0-D7,$26(A0)
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000F32	ST	$61(A0)
	MOVE.W	(A1),$1C(A0)
	MOVE.W	(A1)+,$1A(A0)
	MOVEM.L	$2A(A0),D1-D4
	MOVEM.L	D1-D4,$46(A0)
	RTS

lbC000F4C	MOVEQ	#0,D0
	MOVE.W	(A1),$1C(A0)
	MOVE.W	(A1)+,$1A(A0)
	MOVE.W	(A1)+,$1E(A0)
	CMPI.W	#$FD00,(A1)+
	BNE.S	lbC000F84
	LEA	lbL0013F6(PC),A2
	MOVE.W	(A1)+,D0
	MOVE.W	$1C(A0),D1
	MOVE.W	(A1)+,D2
	MOVE.W	D2,$AC(A0)
	SUB.W	D2,D1
	DIVU.W	D1,D0
	ADD.W	D0,D0
	MOVE.W	0(A2,D0.W),$76(A0)
	MOVE.W	#$2000,$5E(A0)
	BRA.S	lbC000F0C

lbC000F84	LEA	lbL0010D6(PC),A2
	MOVE.W	(A1)+,D0
	MOVE.W	$1C(A0),D1
	MOVE.W	(A1)+,D2
	MOVE.W	D2,$AC(A0)
	SUB.W	D2,D1
	DIVU.W	D1,D0
	ADD.W	D0,D0
	MOVE.W	0(A2,D0.W),$76(A0)
	MOVE.W	#$2000,$5E(A0)
	BRA.L	lbC000F0C

lbL000FAA	dc.l	0
	dc.l	$80000
	dc.l	8
lbL000FB6	dc.l	$D0ADC4F7
	dc.l	$B9E9AF79
	dc.l	$A5A09C54
	dc.l	$938E8B46
	dc.l	$83757C14
	dc.l	$751D6E8B
	dc.l	$6856627B
	dc.l	$5CF457BD
	dc.l	$52D04E2A
	dc.l	$49C745A3
	dc.l	$41BA3E0A
	dc.l	$3A8F3745
	dc.l	$342B313E
	dc.l	$2E7A2BDE
	dc.l	$29682715
	dc.l	$24E422D2
	dc.l	$20DD1F05
	dc.l	$1D471BA3
	dc.l	$1A16189F
	dc.l	$173D15EF
	dc.l	$14B4138B
	dc.l	$12721169
	dc.l	$106F0F83
	dc.l	$EA40DD1
	dc.l	$D0B0C4F
	dc.l	$B9F0AF8
	dc.l	$A5A09C5
	dc.l	$93908B4
	dc.l	$83707C1
	dc.l	$75206E9
	dc.l	$6850628
	dc.l	$5CF057C
	dc.l	$52D04E3
	dc.l	$49C045A
	dc.l	$41C03E1
	dc.l	$3A90374
	dc.l	$3430314
	dc.l	$2E802BE
	dc.l	$2970271
	dc.l	$24E022D
	dc.l	$20E01F0
	dc.l	$1D401BA
	dc.l	$1A1018A
	dc.l	$174015F
	dc.l	$14B0139
	dc.l	$1270117
	dc.l	$10700F8
	dc.l	$EA00DD
	dc.l	$D100C5
	dc.l	$BA00AF
	dc.l	$A6009C
	dc.l	$94008B
	dc.l	$83007C
	dc.l	$75006F
	dc.l	$680062
	dc.l	$5D0058
	dc.l	$53004E
	dc.l	$4A0046
	dc.l	$42003E
	dc.l	$3B0037
	dc.l	$340031
	dc.l	$2E002C
	dc.l	$290027
	dc.l	$250023
	dc.l	$21001F
	dc.l	$1D001C
	dc.l	$1A0019
	dc.l	$170016
	dc.l	$150014
	dc.l	$120011
	dc.l	$100010
	dc.l	$F000E
lbL0010D6	dc.l	$20001FFF
	dc.l	$1FFE1FFC
	dc.l	$1FFB1FFA
	dc.l	$1FF91FF8
	dc.l	$1FF71FF5
	dc.l	$1FF41FF3
	dc.l	$1FF21FF1
	dc.l	$1FEF1FEE
	dc.l	$1FED1FEC
	dc.l	$1FEB1FEA
	dc.l	$1FE81FE7
	dc.l	$1FE61FE5
	dc.l	$1FE41FE2
	dc.l	$1FE11FE0
	dc.l	$1FDF1FDE
	dc.l	$1FDD1FDB
	dc.l	$1FDA1FD9
	dc.l	$1FD81FD7
	dc.l	$1FD61FD4
	dc.l	$1FD31FD2
	dc.l	$1FD11FD0
	dc.l	$1FCE1FCD
	dc.l	$1FCC1FCB
	dc.l	$1FCA1FC9
	dc.l	$1FC71FC6
	dc.l	$1FC51FC4
	dc.l	$1FC31FC2
	dc.l	$1FC01FBF
	dc.l	$1FBE1FBD
	dc.l	$1FBC1FBB
	dc.l	$1FB91FB8
	dc.l	$1FB71FB6
	dc.l	$1FB51FB3
	dc.l	$1FB21FB1
	dc.l	$1FB01FAF
	dc.l	$1FAE1FAC
	dc.l	$1FAB1FAA
	dc.l	$1FA91FA8
	dc.l	$1FA71FA5
	dc.l	$1FA41FA3
	dc.l	$1FA21FA1
	dc.l	$1FA01F9E
	dc.l	$1F9D1F9C
	dc.l	$1F9B1F9A
	dc.l	$1F991F97
	dc.l	$1F961F95
	dc.l	$1F941F93
	dc.l	$1F921F90
	dc.l	$1F8F1F8E
	dc.l	$1F8D1F8C
	dc.l	$1F8B1F89
	dc.l	$1F881F87
	dc.l	$1F861F85
	dc.l	$1F841F82
	dc.l	$1F811F80
	dc.l	$1F7F1F7E
	dc.l	$1F7D1F7B
	dc.l	$1F7A1F79
	dc.l	$1F781F77
	dc.l	$1F761F74
	dc.l	$1F731F72
	dc.l	$1F711F70
	dc.l	$1F6F1F6D
	dc.l	$1F6C1F6B
	dc.l	$1F6A1F69
	dc.l	$1F681F66
	dc.l	$1F651F64
	dc.l	$1F631F62
	dc.l	$1F611F60
	dc.l	$1F5E1F5D
	dc.l	$1F5C1F5B
	dc.l	$1F5A1F59
	dc.l	$1F571F56
	dc.l	$1F551F54
	dc.l	$1F531F52
	dc.l	$1F501F4F
	dc.l	$1F4E1F4D
	dc.l	$1F4C1F4B
	dc.l	$1F4A1F48
	dc.l	$1F471F46
	dc.l	$1F451F44
	dc.l	$1F431F41
	dc.l	$1F401F3F
	dc.l	$1F3E1F3D
	dc.l	$1F3C1F3A
	dc.l	$1F391F38
	dc.l	$1F371F36
	dc.l	$1F351F34
	dc.l	$1F321F31
	dc.l	$1F301F2F
	dc.l	$1F2E1F2D
	dc.l	$1F2C1F2A
	dc.l	$1F291F28
	dc.l	$1F271F26
	dc.l	$1F251F23
	dc.l	$1F221F21
	dc.l	$1F201F1F
	dc.l	$1F1E1F1D
	dc.l	$1F1B1F1A
	dc.l	$1F191F18
	dc.l	$1F171F16
	dc.l	$1F141F13
	dc.l	$1F121F11
	dc.l	$1F101F0F
	dc.l	$1F0E1F0C
	dc.l	$1F0B1F0A
	dc.l	$1F091F08
	dc.l	$1F071F06
	dc.l	$1F041F03
	dc.l	$1F021F01
	dc.l	$1F001EFF
	dc.l	$1EFE1EFC
	dc.l	$1EFB1EFA
	dc.l	$1EF91EF8
	dc.l	$1EF71EF6
	dc.l	$1EF41EF3
	dc.l	$1EF21EF1
	dc.l	$1EF01EEF
	dc.l	$1EEE1EEC
	dc.l	$1EEB1EEA
	dc.l	$1EE91EE8
	dc.l	$1EE71EE6
	dc.l	$1EE41EE3
	dc.l	$1EE21EE1
	dc.l	$1EE01EDF
	dc.l	$1EDE1EDC
	dc.l	$1EDB1EDA
	dc.l	$1ED91ED8
	dc.l	$1ED71ED6
	dc.l	$1ED41ED3
	dc.l	$1ED21ED1
	dc.l	$1ED01ECF
	dc.l	$1ECE1ECC
	dc.l	$1ECB1ECA
	dc.l	$1EC91EC8
	dc.l	$1EC71EC6
	dc.l	$1EC41EC3
	dc.l	$1EC21EC1
	dc.l	$1EC01EBF
	dc.l	$1EBE1EBD
	dc.l	$1EBB1EBA
	dc.l	$1EB91EB8
	dc.l	$1EB71EB6
	dc.l	$1EB51EB3
	dc.l	$1EB21EB1
	dc.l	$1EB01EAF
	dc.l	$1EAE1EAD
	dc.l	$1EAB1EAA
	dc.l	$1EA91EA8
	dc.l	$1EA71EA6
	dc.l	$1EA51EA4
	dc.l	$1EA21EA1
	dc.l	$1EA01E9F
	dc.l	$1E9E1E9D
	dc.l	$1E9C1E9A
	dc.l	$1E991E98
	dc.l	$1E971E96
	dc.l	$1E951E94
	dc.l	$1E931E91
	dc.l	$1E901E8F
	dc.l	$1E8E1E8D
	dc.l	$1E8C1E8B
	dc.l	$1E8A1E88
	dc.l	$1E871E86
	dc.l	$1E851E84
	dc.l	$1E831E82
	dc.l	$1E811E7F
	dc.l	$1E7E1E7D
	dc.l	$1E7C1E7B
	dc.l	$1E7A1E79
	dc.l	$1E781E76
	dc.l	$1E751E74
	dc.l	$1E731E72
	dc.l	$1E711E70
	dc.l	$1E6E1E6D
	dc.l	$1E6C1E6B
	dc.l	$1E6A1E69
	dc.l	$1E681E67
	dc.l	$1E661E64
	dc.l	$1E631E62
	dc.l	$1E611E60
	dc.l	$1E5F1E5E
	dc.l	$1E5D1E5B
	dc.l	$1E5A1E59
	dc.l	$1E581E57
	dc.l	$1E561E55
	dc.l	$1E541E52
	dc.l	$1E511E50
	dc.l	$1E4F1E4E
	dc.l	$1E4D1E4C
	dc.l	$1E4B1E49
	dc.l	$1E481E47
	dc.l	$1E461E45
	dc.l	$1E441E43
	dc.l	$1E421E41
	dc.l	$1E3F1E3E
	dc.l	$1E3D1E3C
	dc.l	$1E3B1E3A
	dc.l	$1E391E38
	dc.l	$1E361E35
lbL0013F6	dc.l	$20002001
	dc.l	$20022004
	dc.l	$20052006
	dc.l	$20072008
	dc.l	$2009200B
	dc.l	$200C200D
	dc.l	$200E200F
	dc.l	$20112012
	dc.l	$20132014
	dc.l	$20152017
	dc.l	$20182019
	dc.l	$201A201B
	dc.l	$201C201E
	dc.l	$201F2020
	dc.l	$20212022
	dc.l	$20242025
	dc.l	$20262027
	dc.l	$2028202A
	dc.l	$202B202C
	dc.l	$202D202E
	dc.l	$202F2031
	dc.l	$20322033
	dc.l	$20342035
	dc.l	$20372038
	dc.l	$2039203A
	dc.l	$203B203D
	dc.l	$203E203F
	dc.l	$20402041
	dc.l	$20432044
	dc.l	$20452046
	dc.l	$20472048
	dc.l	$204A204B
	dc.l	$204C204D
	dc.l	$204E2050
	dc.l	$20512052
	dc.l	$20532054
	dc.l	$20562057
	dc.l	$20582059
	dc.l	$205A205C
	dc.l	$205D205E
	dc.l	$205F2060
	dc.l	$20622063
	dc.l	$20642065
	dc.l	$20662068
	dc.l	$2069206A
	dc.l	$206B206C
	dc.l	$206E206F
	dc.l	$20702071
	dc.l	$20722074
	dc.l	$20752076
	dc.l	$20772078
	dc.l	$207A207B
	dc.l	$207C207D
	dc.l	$207E2080
	dc.l	$20812082
	dc.l	$20832084
	dc.l	$20862087
	dc.l	$20882089
	dc.l	$208A208C
	dc.l	$208D208E
	dc.l	$208F2090
	dc.l	$20922093
	dc.l	$20942095
	dc.l	$20962098
	dc.l	$2099209A
	dc.l	$209B209C
	dc.l	$209E209F
	dc.l	$20A020A1
	dc.l	$20A220A4
	dc.l	$20A520A6
	dc.l	$20A720A9
	dc.l	$20AA20AB
	dc.l	$20AC20AD
	dc.l	$20AF20B0
	dc.l	$20B120B2
	dc.l	$20B320B5
	dc.l	$20B620B7
	dc.l	$20B820B9
	dc.l	$20BB20BC
	dc.l	$20BD20BE
	dc.l	$20BF20C1
	dc.l	$20C220C3
	dc.l	$20C420C6
	dc.l	$20C720C8
	dc.l	$20C920CA
	dc.l	$20CC20CD
	dc.l	$20CE20CF
	dc.l	$20D020D2
	dc.l	$20D320D4
	dc.l	$20D520D7
	dc.l	$20D820D9
	dc.l	$20DA20DB
	dc.l	$20DD20DE
	dc.l	$20DF20E0
	dc.l	$20E120E3
	dc.l	$20E420E5
	dc.l	$20E620E8
	dc.l	$20E920EA
	dc.l	$20EB20EC
	dc.l	$20EE20EF
	dc.l	$20F020F1
	dc.l	$20F220F4
	dc.l	$20F520F6
	dc.l	$20F720F9
	dc.l	$20FA20FB
	dc.l	$20FC20FD
	dc.l	$20FF2100
	dc.l	$21012102
	dc.l	$21042105
	dc.l	$21062107
	dc.l	$2108210A
	dc.l	$210B210C
	dc.l	$210D210F
	dc.l	$21102111
	dc.l	$21122113
	dc.l	$21152116
	dc.l	$21172118
	dc.l	$211A211B
	dc.l	$211C211D
	dc.l	$211E2120
	dc.l	$21212122
	dc.l	$21232125
	dc.l	$21262127
	dc.l	$21282129
	dc.l	$212B212C
	dc.l	$212D212E
	dc.l	$21302131
	dc.l	$21322133
	dc.l	$21352136
	dc.l	$21372138
	dc.l	$2139213B
	dc.l	$213C213D
	dc.l	$213E2140
	dc.l	$21412142
	dc.l	$21432144
	dc.l	$21462147
	dc.l	$21482149
	dc.l	$214B214C
	dc.l	$214D214E
	dc.l	$21502151
	dc.l	$21522153
	dc.l	$21542156
	dc.l	$21572158
	dc.l	$2159215B
	dc.l	$215C215D
	dc.l	$215E2160
	dc.l	$21612162
	dc.l	$21632165
	dc.l	$21662167
	dc.l	$21682169
	dc.l	$216B216C
	dc.l	$216D216E
	dc.l	$21702171
	dc.l	$21722173
	dc.l	$21752176
	dc.l	$21772178
	dc.l	$217A217B
	dc.l	$217C217D
	dc.l	$217E2180
	dc.l	$21812182
	dc.l	$21832185
	dc.l	$21862187
	dc.l	$2188218A
	dc.l	$218B218C
	dc.l	$218D218F
	dc.l	$21902191
	dc.l	$21922194
	dc.l	$21952196
	dc.l	$21972199
	dc.l	$219A219B
	dc.l	$219C219D
	dc.l	$219F21A0
	dc.l	$21A121A2
	dc.l	$21A421A5
	dc.l	$21A621A7
	dc.l	$21A921AA
	dc.l	$21AB21AC
	dc.l	$21AE21AF
	dc.l	$21B021B1
	dc.l	$21B321B4
	dc.l	$21B521B6
	dc.l	$21B821B9
	dc.l	$21BA21BB
	dc.l	$21BD21BE
	dc.l	$21BF21C0
	dc.l	$21C221C3
	dc.l	$21C421C5
	dc.l	$21C721C8
	dc.l	$21C921CA
	dc.l	$21CC21CD
	dc.l	$21CE21CF
	dc.l	$21D121D2
	dc.l	$21D321D4
	dc.l	$21D621D7
	dc.l	$21D821D9
	dc.l	$21DB21DC
	dc.l	$21DD21DE
	dc.l	$21E021E1
	dc.l	$21E221E3
	dc.l	$21E521E6
lbL001716	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$817F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81817F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$8181817F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$817F7F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81817F7F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$8181817F
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$7F7F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$817F7F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81817F7F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$8181817F
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$7F7F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$817F7F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81817F7F
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$81818181
	dc.l	$8181817F

	Section	Buffy,BSS_C
Buffy
	ds.b	16*4
