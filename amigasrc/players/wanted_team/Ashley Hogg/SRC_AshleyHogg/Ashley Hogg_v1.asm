	*****************************************************
	****     Ashley Hogg replayer for EaglePlayer	 ****
	****        all adaptions by Wanted Team,	 ****
	****     DeliTracker 2.32 compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'hardware/custom.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Ashley Hogg player module V1.0 (28 Oct 2010)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,'WT'
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
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	TAG_DONE

PlayerName
	dc.b	'Ashley Hogg',0
Creator
	dc.b	'(c) 1991-93 by Ashley Hogg & Jonathan',10
	dc.b	'Menzies, adapted by Wanted Team',0
Prefix
	dc.b	'ASH.',0
	even
ModulePtr
	dc.l	0
Format
	dc.b	0
CurrentFormat
	dc.b	0
Change
	dc.w	0
EagleBase
	dc.l	0
PlayPtr
	dc.l	0
SongsPtr
Play2Ptr
	dc.l	0
SamplesPtr
	dc.l	0
SamplesInfoPtr
Base
	dc.l	0
FirstBase
	dc.l	0
OldBase
	dc.l	0
Songend
	dc.l	'WTWT'
TempEnd
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
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.b	CurrentFormat(PC),D0
	beq.b	OldPos
	moveq	#0,D0
	move.l	Base(PC),A0
	move.w	$F4(A0),D0
	rts
OldPos
	move.l	OldBase(PC),A0
	move.l	$32(A0),D0
	sub.l	$3A(A0),D0
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplesPtr(PC),D0
	beq.b	return
	move.l	D0,A0

	move.l	InfoBuffer+Samples(PC),D5
	beq.b	return
	subq.l	#1,D5
	move.l	A0,D2
	move.b	CurrentFormat(PC),D1
	beq.b	OldForm
	moveq	#104,D3
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A0),A1
	add.l	D2,A1
	moveq	#0,D1
	move.w	8(A0),D1
	add.l	D1,D1
	cmp.l	#'NAME',-64(A1)
	bne.b	NoName
	lea	-58(A1),A2
	move.w	(A2)+,EPS_MaxNameLen(A3)
	move.l	A2,EPS_SampleName(A3)		; sample name
	add.l	D3,D1
	sub.l	D3,A1
NoName
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	lea	16(A0),A0
	dbf	D5,hop
Back
	moveq	#0,D7
return
	move.l	D7,D0
	rts

OldForm
	move.l	SamplesInfoPtr(PC),A1
hop2
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	$20(A1),D0
	bmi.b	SkipSam
	add.l	D2,D0
	moveq	#0,D1
	move.w	$28(A1),D1
	add.l	D1,D1
	move.l	D0,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
SkipSam
	lea	$2C(A1),A1
	dbf	D5,hop2
	bra.b	Back

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	move.b	Format(PC),D0
	beq.b	NoExt
	movea.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	movea.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName
	movea.l	dtg_LoadFile(A5),A0
	jmp	(A0)

NoExt
	moveq	#0,D0
	rts
CopyName
	movea.l	dtg_PathArrayPtr(A5),A0
loop
	tst.b	(A0)+
	bne.s	loop
	subq.l	#1,A0
	movea.l	A0,A3
	movea.l	dtg_FileArrayPtr(A5),A1
smp
	move.b	(A1)+,(A0)+
	bne.s	smp

	cmpi.b	#'A',(A3)
	beq.b	A_OK
	cmpi.b	#'a',(A3)
	bne.s	ExtError
A_OK
	cmpi.b	#'S',1(A3)
	beq.b	S_OK
	cmpi.b	#'s',1(A3)
	bne.s	ExtError
S_OK
	cmpi.b	#'H',2(A3)
	beq.b	H_OK
	cmpi.b	#'h',2(A3)
	bne.s	ExtError
H_OK
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
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	ModulePtr(PC),EPG_ARG1(A5)

	move.b	CurrentFormat(PC),D1
	bne.b	No1
	lea	PatchTable1(PC),A1
	move.l	#1800,D1
	bra.b	RightPatch
No1
	lea	PatchTable(PC),A1
	move.l	#3500,D1
RightPatch
	move.l	A1,EPG_ARG3(A5)
	move.l	D1,EPG_ARG2(A5)
	moveq	#-2,D0
	move.l	d0,EPG_ARG5(A5)		
	moveq	#1,D0
	move.l	d0,EPG_ARG4(A5)			;Search-Modus
	moveq	#5,D0
	move.l	d0,EPG_ARGN(A5)
	move.l	EPG_ModuleChange(A5),A0
	jsr	(A0)
NoChange
	move.w	#1,Change
	moveq	#0,D0
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
	lsr.w	#6,D0

	move.w	D0,LeftVolume

	move.w	dtg_SndRBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0

	move.w	D0,RightVolume

	moveq	#0,D0
	rts

ChangeVolume
	move.l	D2,-(A7)
	and.w	#$7F,D6
	move.l	A1,D2
	cmp.w	#$F0A0,D2
	beq.s	Left1
	cmp.w	#$F0B0,D2
	beq.s	Right1
	cmp.w	#$F0C0,D2
	beq.s	Right2
	cmp.w	#$F0D0,D2
	bne.s	Exit2
Left2
	mulu.w	LeftVolume(PC),D6
	and.w	Voice4(PC),D6
	bra.s	Ex
Left1
	mulu.w	LeftVolume(PC),D6
	and.w	Voice1(PC),D6
	bra.s	Ex

Right1
	mulu.w	RightVolume(PC),D6
	and.w	Voice2(PC),D6
	bra.s	Ex
Right2
	mulu.w	RightVolume(PC),D6
	and.w	Voice3(PC),D6
Ex
	lsr.w	#6,D6
	move.w	D6,8(A1)
Exit2
	move.l	(A7)+,D2
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
	move.w	D6,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Adr/Len -------------------------------*

SetTwo
	move.l	a2,-(a7)
	lea	StructAdr+UPS_Voice1Adr(pc),A2
	cmp.l	#$dff0A0,a1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(pc),A2
	cmp.l	#$dff0B0,a1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(pc),A2
	cmp.l	#$dff0C0,a1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(pc),A2
.SetVoice
	move.l	A3,(A2)
	move.w	$28(A0),UPS_Voice1Len(A2)
	move.l	(a7)+,a2
	rts

*------------------------------- Set Per -------------------------------*

SetPer
	move.l	a0,-(a7)
	lea	StructAdr+UPS_Voice1Per(pc),a0
	cmp.l	#$dff0A0,a1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(pc),a0
	cmp.l	#$dff0B0,a1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(pc),a0
	cmp.l	#$dff0C0,a1
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(pc),a0
.SetVoice
	move.w	D2,(a0)
	move.l	(a7)+,a0
	rts

ChangeVolume2
	move.l	D1,-(A7)
	and.w	#$7F,D4
	move.l	A5,D1
	cmp.w	#$F0A0,D1
	beq.s	Left13
	cmp.w	#$F0B0,D1
	beq.s	Right13
	cmp.w	#$F0C0,D1
	beq.s	Right23
	cmp.w	#$F0D0,D1
	bne.s	Exit23
Left23
	mulu.w	LeftVolume(PC),D4
	and.w	Voice4(PC),D4
	bra.s	Ex3
Left13
	mulu.w	LeftVolume(PC),D4
	and.w	Voice1(PC),D4
	bra.s	Ex3

Right13
	mulu.w	RightVolume(PC),D4
	and.w	Voice2(PC),D4
	bra.s	Ex3
Right23
	mulu.w	RightVolume(PC),D4
	and.w	Voice3(PC),D4
Ex3
	lsr.w	#6,D4
	move.w	D4,8(A5)
Exit23
	move.l	(A7)+,D1
	rts

*------------------------------- Set Vol -------------------------------*

SetVol2
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
	move.w	D4,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Adr/Len -------------------------------*

SetTwo2
	move.l	a0,-(a7)
	lea	StructAdr+UPS_Voice1Adr(pc),a0
	cmp.l	#$dff0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(pc),a0
	cmp.l	#$dff0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(pc),a0
	cmp.l	#$dff0C0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(pc),a0
.SetVoice
	move.l	$18(A1),(A0)
	move.w	$20(A1),UPS_Voice1Len(A0)
	move.l	(a7)+,a0
	rts

*------------------------------- Set Per -------------------------------*

SetPer2
	move.l	a0,-(a7)
	lea	StructAdr+UPS_Voice1Per(pc),a0
	cmp.l	#$dff0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(pc),a0
	cmp.l	#$dff0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(pc),a0
	cmp.l	#$dff0C0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(pc),a0
.SetVoice
	move.w	D3,(A0)
	move.l	(a7)+,a0
	rts

***************************************************************************
**************************** EP_Voices ************************************
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
	moveq	#0,D0
	rts

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	moveq	#3,D1
	move.w	#$6000,D3
loop1
	cmp.w	(A0)+,D3
	bne.b	fail
	move.w	(A0)+,D2
	beq.b	fail
	bmi.b	fail
	btst	#0,D2
	bne.b	fail
	dbf	D1,loop1
	lea	Format(PC),A1
	cmp.w	(A0)+,D3
	bne.b	OldCheck
	move.w	(A0)+,D2
	beq.b	fail
	bmi.b	fail
	btst	#0,D2
	bne.b	fail
	cmp.w	(A0)+,D3
	bne.b	fail
	move.w	(A0),D2
	beq.b	fail
	bmi.b	fail
	btst	#0,D2
	bne.b	fail
	add.w	D2,A0
	cmp.l	#$48E7FFFE,(A0)+
	bne.b	fail
	cmp.w	#$6100,(A0)+
	bne.b	fail
	add.w	(A0),A0
	cmp.w	#$4DF9,(A0)+
	bne.b	fail
	cmp.l	#$00DFF000,(A0)+
	bne.b	fail
	st	(A1)
found
	moveq	#0,D0
fail
	rts

OldCheck
	subq.l	#2,A0
	cmp.l	#$303C0000,(A0)+
	bne.b	fail
	cmp.l	#$662233C0,(A0)+
	bne.b	fail
	clr.b	(A1)
	bra.b	found

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

Get_ModuleInfo
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
LoadSize	=	12
SongSize	=	20
SamplesSize	=	28
Samples		=	36
CalcSize	=	44
Length		=	52
Special		=	60

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_Length,0		;52
	dc.l	MI_SpecialInfo,0	;60
	dc.l	MI_Prefix,Prefix
	dc.l	0

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

	move.l	PlayPtr(PC),A0
	jsr	(A0)

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

SongEndTest
	movem.l	A1/A5,-(A7)
	lea	Songend(PC),A1
	move.l	FirstBase(PC),A5
	cmp.l	A0,A5
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	lea	74(A5),A5
	cmp.l	A0,A5
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	lea	74(A5),A5
	cmp.l	A0,A5
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	lea	74(A5),A5
	cmp.l	A0,A5
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)+
	bne.b	SkipEnd
	move.l	(A1),-(A1)
EndOK
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
	rts

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange	
	moveq	#1,D0
	move.l	InfoBuffer+SubSongs(PC),D1
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
	move.b	(A6)+,(A6)+			; Current Format
	clr.w	(A6)+				; Change
	move.l	A5,(A6)+			; EagleBase

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	move.b	CurrentFormat(PC),D1
	beq.w	Old
	move.l	A0,A1
	lea	-2(A0,D0.L),A3
	lea	12(A0),A2
	move.l	A2,(A6)+			; PlayPtr
	lea	28(A0),A2
	addq.l	#2,A0
	add.w	(A0),A0				; end of info text
	move.l	A2,Special(A4)
More
	cmp.b	#$20,(A2)+
	bne.b	No
	cmp.b	#$20,(A2)+
	bne.b	No
Yes
	cmp.b	#$20,(A2)+
	beq.b	Yes
	move.b	#10,-2(A2)
No
	cmp.l	A2,A0
	bgt.b	More
	clr.b	-1(A0)
Find1
	cmp.w	#$45FA,(A0)+
	bne.b	Find1
	move.l	A0,A2
	add.w	(A0),A0
	cmp.l	A0,A3
	blt.w	Short
	move.w	(A0),D0
	add.w	D0,A0
	lsr.w	#2,D0
	move.w	D0,SubSongs+2(A4)
	cmp.l	A0,A3
	blt.w	Short
	add.w	-2(A0),A0
FoundEnd
	cmp.l	A0,A3
	blt.w	Short
	cmp.w	#$03F2,(A0)+
	bne.b	FoundEnd
	sub.l	A1,A0
	move.l	A0,SongSize(A4)
	move.l	A0,CalcSize(A4)
Find2
	cmp.w	#$49FA,(A2)+
	bne.b	Find2
	add.w	(A2),A2
	move.l	A2,(A6)+			; Play2Ptr
	bra.w	SkipOld
Old
	clr.l	Special(A4)
	move.l	A0,D1
	lea	16(A0),A2
	move.l	A2,(A6)+			; PlayPtr
	addq.l	#2,A0
	add.w	(A0),A0
Find3
	cmp.w	#$1970,(A0)+
	bne.b	Find3
	lea	-4(A0),A1
	add.w	(A1),A1				; end of songs
Find4
	cmp.w	#$41FA,(A0)+
	bne.b	Find4
	add.w	(A0),A0
	move.l	A0,(A6)+			; SongsPtr
	move.l	A1,D0
	sub.l	A0,D0
	lsr.w	#4,D0
	move.l	D0,SubSongs(A4)
Find5
	cmp.w	#$C2FC,(A2)+
	bne.b	Find5
	addq.l	#4,A2
	move.l	A2,A1
	add.w	(A1),A1
Find6
	cmp.w	#$47FA,(A2)+
	bne.b	Find6
	move.l	A2,A0
	add.w	(A2),A2
	move.l	A2,(A6)+			; SamplesPtr
	move.l	A1,(A6)				; SamplesInfoPtr
	sub.l	D1,A2
	move.l	A2,SongSize(A4)
Find7
	cmp.w	#$49FA,(A0)+
	bne.b	Find7
Find8
	cmp.w	#$49FA,(A0)+
	bne.b	Find8
	add.w	(A0),A0
	move.l	A0,D0
	sub.l	A1,D0
	divu.w	#$2C,D0
	move.l	D0,Samples(A4)
	moveq	#0,D1
NextInfo
	move.l	$20(A1),D2
	bmi.b	High
	cmp.l	D2,D1
	bgt.b	High
	move.l	D2,D1
	move.l	A1,A3
High
	lea	$2C(A1),A1
	cmp.l	A1,A0
	bgt.b	NextInfo
	moveq	#0,D0
	move.w	$28(A3),D0
	add.l	D0,D0
	add.l	D0,D1
	move.l	D1,SamplesSize(A4)
	add.l	D1,A2
	move.l	A2,CalcSize(A4)
	cmp.l	LoadSize(A4),A2
	bgt.b	Short
SkipOld
	bsr.w	ModuleChange

	move.b	CurrentFormat(PC),D1
	beq.b	OneFile

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	move.l	A0,(A6)				; SamplesPtr
	add.l	D0,LoadSize(A4)
	move.l	(A0),D1
	lea	(A0,D1.L),A2
	moveq	#0,D2
Sammy
	move.l	(A0),D3
	beq.b	ExSammy
	tst.w	8(A0)
	bmi.b	ExSammy
	addq.l	#1,D2
	cmp.l	D3,D1
	bgt.b	NoSammy
	move.l	D3,D1
	move.l	A0,A1
NoSammy
	lea	16(A0),A0
	cmp.l	A0,A2
	bgt.b	Sammy
ExSammy
	moveq	#0,D3
	move.w	8(A1),D3
	add.l	D3,D3
	add.l	D3,D1
	sub.l	D1,D0
	bmi.b	Short
	move.l	D1,SamplesSize(A4)
	move.l	D2,Samples(A4)
	add.l	D1,CalcSize(A4)
OneFile
	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)
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
	move.w	dtg_SndNum(A5),D0
	move.b	CurrentFormat(PC),D1
	beq.b	OldFormat
	move.l	SamplesPtr(PC),A1
	jsr	(A0)			; set samples, VBR at A2 is ignored
	jsr	4(A0)			; set subsong
	jsr	12(A0)			; first interrupt call
	move.l	Base(PC),A0
	move.w	$F6(A0),D0
	lea	InfoBuffer(PC),A0
	move.w	D0,Length+2(A0)
	rts

OldFormat
	subq.w	#1,D0
	move.l	D0,-(SP)
	move.l	ModulePtr(PC),A0
	jsr	(A0)
	move.l	(SP)+,D0
	move.l	SongsPtr(PC),A3
	lsl.w	#4,D0
	add.w	D0,A3
	moveq	#-127,D1
	moveq	#-128,D2
	moveq	#3,D4
	moveq	#0,D5
	lea	FirstBase(PC),A1
	move.l	A4,(A1)+
	lea	Songend(PC),A2
	move.l	D2,(A2)				; Songend
NextLength
	tst.l	(A3)+
	bne.b	NoLength
	clr.b	(A2)+
	bra.b	MaxLength
NoLength
	addq.l	#1,A2
	move.l	$32(A4),D0
	move.l	D0,A0
FindByte
	move.b	(A0)+,D3
	cmp.b	D3,D2
	beq.b	EndByte
	cmp.b	D3,D1
	bne.b	FindByte
EndByte
	sub.l	D0,A0
	cmp.l	A0,D5
	bgt.b	MaxLength
	move.l	A0,D5
	move.l	A4,(A1)
MaxLength
	lea	74(A4),A4
	dbf	D4,NextLength
	move.l	-4(A2),(A2)
	lea	InfoBuffer(PC),A1
	move.l	D5,Length(A1)
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

	*--------------- PatchTable for Ashley Hogg ------------------*

PatchTable
	dc.w	Code1-PatchTable,(Code1End-Code1)/2-1,Patch1-PatchTable
	dc.w	Code2-PatchTable,(Code2End-Code2)/2-1,Patch2-PatchTable
	dc.w	Code3-PatchTable,(Code3End-Code3)/2-1,Patch3-PatchTable
	dc.w	Code4-PatchTable,(Code4End-Code4)/2-1,Patch4-PatchTable
	dc.w	Code5-PatchTable,(Code5End-Code5)/2-1,Patch5-PatchTable
	dc.w	Code6-PatchTable,(Code6End-Code6)/2-1,Patch6-PatchTable
	dc.w	Code7-PatchTable,(Code7End-Code7)/2-1,Patch7-PatchTable
	dc.w	Code8-PatchTable,(Code8End-Code8)/2-1,Patch8-PatchTable
	dc.w	Code9-PatchTable,(Code9End-Code9)/2-1,Patch9-PatchTable
	dc.w	0
PatchTable1
	dc.w	CodeH-PatchTable1,(CodeHEnd-CodeH)/2-1,PatchH-PatchTable1
	dc.w	CodeI-PatchTable1,(CodeIEnd-CodeI)/2-1,PatchI-PatchTable1
	dc.w	CodeJ-PatchTable1,(CodeJEnd-CodeJ)/2-1,PatchJ-PatchTable1
	dc.w	CodeK-PatchTable1,(CodeKEnd-CodeK)/2-1,PatchK-PatchTable1
	dc.w	CodeL-PatchTable1,(CodeLEnd-CodeL)/2-1,PatchL-PatchTable1
	dc.w	CodeR-PatchTable1,(CodeREnd-CodeR)/2-1,PatchR-PatchTable1
	dc.w	0

; Timer interrupt patch for Ashley Hogg replay from 1993

Code1
	LEA	$BFE001,A0
Code1End
Patch1
	lea	Base(PC),A1
	move.l	A0,(A1)
	addq.l	#4,SP				; no return
	movem.l	(SP)+,D0-D7/A0-A6		; restore registers
	rts

; Timer interrupt patch for Ashley Hogg replay from 1993

Code2
	LEA	$BFD000,A4
	TST.B	$D00(A4)
Code2End
Patch2
	bsr.w	DMAWait
	move.l	Play2Ptr(PC),A0
	jsr	(A0)
	addq.l	#4,SP				; no return
	movem.l	(SP)+,D0-D7/A0-A6		; restore registers
	rts

; Timer interrupt patch for Ashley Hogg replay from 1993

Code3
	MOVE.L	A1,$78(A0)
	TST.B	$BFDD00
	MOVE.W	#$2000,$DFF09C
Code3End
Patch3
	bsr.w	DMAWait
	jsr	(A1)				; call third interrupt
	addq.l	#4,SP				; no return
	movem.l	(SP)+,D0/A0/A1/A6		; restore registers
	rts

; Timer interrupt patch for Ashley Hogg replay from 1993

Code4
	MOVE.L	A1,$78(A0)
	TST.B	$BFDD00
	MOVE.B	#$80,$BFDE00
Code4End
Patch4
	addq.l	#4,SP				; no return
	movem.l	(SP)+,A0/A1/A6			; restore registers
	rts

; SongEnd patch for Ashley Hogg replay from 1993 (Fantastic Dizzy)

Code5
	dc.l	$0C680008
	dc.w	$00F2
Code5End
Patch5
	bsr.w	SongEnd
	addq.l	#8,(SP)				; skip 3 commands
	rts

; SongEnd patch for Ashley Hogg replay from 1993

Code6
	CMP.W	D0,D1
	BNE.S	lbC0006E2
	CLR.W	D0
lbC0006E2
Code6End
Patch6
	cmp.w	D0,D1
	bne.b	NoEnd
	bsr.w	SongEnd
	clr.w	D0
NoEnd
	rts

; Address/length patch for Ashley Hogg replay from 1993

Code7
	MOVE.L	$18(A1),0(A5)
	MOVE.W	$20(A1),4(A5)
Code7End
Patch7
	move.l	$18(A1),(A5)
	move.w	$20(A1),4(A5)
	bsr.w	SetTwo2
	rts

; Period patch for Ashley Hogg replay from 1993

Code8
	MOVE.W	D3,6(A5)
	RTS
Code8End
Patch8
	move.w	D3,6(A5)
	bsr.w	SetPer2
	addq.l	#4,SP				; no return
	rts

; Volume patch for Ashley Hogg replay from 1993

Code9
	MOVE.W	D4,8(A5)
	RTS
Code9End
Patch9
	bsr.w	ChangeVolume2
	bsr.w	SetVol2
	addq.l	#4,SP				; no return
	rts

; SongEnd (loop) patch for Ashley Hogg replay from 1991

CodeH
	MOVEA.L	$32(A0),A1
	MOVEQ	#2,D0
CodeHEnd
PatchH
	move.l	$32(A0),A1
	moveq	#2,D0
	cmp.b	#$81,(A1)
	bne.b	NoBye
	bsr.w	SongEndTest
NoBye
	rts

; Address/length patch for Ashley Hogg replay from 1991

CodeI
	MOVE.L	A3,(A1)
	MOVE.W	$28(A0),4(A1)
CodeIEnd
PatchI
	move.l	A3,(A1)
	move.w	$28(A0),4(A1)
	bsr.w	SetTwo
	rts

; Volume patch for Ashley Hogg replay from 1991

CodeJ
	LSR.W	#6,D6
	MOVE.W	D6,8(A1)
CodeJEnd
PatchJ
	lsr.w	#6,D6
;	move.w	D6,8(A1)
	bsr.w	ChangeVolume
	bsr.w	SetVol
	rts

; Period patch for Ashley Hogg replay from 1991

CodeK
	ADD.W	$2C(A0),D2
	MOVE.W	D2,6(A1)
CodeKEnd
PatchK
	add.w	$2C(A0),D2
	move.w	D2,6(A1)
	bsr.w	SetPer
	rts

; SongEnd patch for Ashley Hogg replay from 1991

CodeL
	MOVE.W	D0,$DFF0A8
CodeLEnd
PatchL
	bsr.w	SongEnd
	move.w	D0,$DFF0A8
	rts

; Bugfix patch for Ashley Hogg replay from 1991 (Noddy & Spikey)

CodeR
	MOVE.B	0,8(A0)
CodeREnd
PatchR
	move.b	#0,8(A0)
	rts
