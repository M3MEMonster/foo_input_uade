	*****************************************************
	****  Jochen Hippel ST replayer for EaglePlayer	 ****
	****   written by Jochen Hippel, updated by WT	 ****
	****      DeliTracker (?) compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include "misc/eagleplayer2.01.i"
	include 'exec/exec_lib.i'
	include	'hardware/custom.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Jochen Hippel ST player module V1.3 (13 Dec 2008)',0
	even
Tags
	dc.l	DTP_PlayerVersion,4
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	TAG_DONE

PlayerName
	dc.b	'Jochen Hippel ST',0
Creator
	dc.b	'written by Jochen Hippel,',10
	dc.b	'updated by Wanted Team',0
Mad
	dc.b	"Jochen 'Mad Max' Hippel",0
Prefix
	dc.b	'HST.',0
SampleName
	dc.b	'SMP.set',0
SMP
	dc.b	'SMP.',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
TypeAdr
	dc.b	0
TypePlay
	dc.b	0
Period
	dc.w	0
TypeSID
	dc.b	0
TypePeriod
	dc.b	0
TwoFiles
	dc.l	0
Size
	dc.l	0
FastPtr
	dc.l	0
FastLength
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
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	move.l	TwoFiles(PC),D0
	beq.b	ExtLoadOK
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

	cmpi.b	#'H',(A3)
	beq.b	H_OK
	cmpi.b	#'h',(A3)
	bne.s	ExtError
H_OK
	cmpi.b	#'S',1(A3)
	beq.b	S_OK
	cmpi.b	#'s',1(A3)
	bne.s	ExtError
S_OK
	cmpi.b	#'T',2(A3)
	beq.b	T_OK
	cmpi.b	#'t',2(A3)
	bne.s	ExtError
T_OK
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
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	InfoBuffer+Length(PC),D0
	sub.w	lbL000E72+$1C(PC),D0
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
	move.l	dtg_ChkSize(A5),D0
	move.l	A0,A4
	bsr.w	Check
	cmp.w	#2,D0
	bne.b	Fault
	moveq	#0,D1
	cmp.l	#'LSMP',$1C(A0)
	bne.b	OneFile
	moveq	#1,D1
OneFile
	lea	TwoFiles(PC),A1
	move.l	D1,(A1)+
	sub.l	A4,A0
	move.l	A0,(A1)
	moveq	#0,D0
	bra.b	Found

Fault	moveq	#-1,D0
Found	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
LoadSize	=	12
CalcSize	=	20
SongSize	=	28
Length		=	36
SamplesSize	=	44
Fast		=	52
Special		=	60

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Calcsize,0		;20
	dc.l	MI_Songsize,0		;28
	dc.l	MI_Length,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_OtherSize,0		;52
	dc.l	MI_SpecialInfo,0	;60
	dc.l	MI_Prefix,Prefix
	dc.l	MI_AuthorName,Mad
	dc.l	0

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

	bsr.w	Play
	bsr.w	Play_Emu

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D0-D7/A0-A6
	rts

SongEnd
	movem.l	A1/A5,-(A7)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
	movem.l	(A7)+,A1/A5
	rts

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
;	move.l	D2,D3

;	tst.w	d2				; necessary to stop channels ?
;	beq.s	.Skip				; no !
.StopDMA
	move.b	vhposr(A5),d1
.WaitLine1
	cmp.b	vhposr(A5),d1			; sync routine to start at linestart
	beq.s	.WaitLine1
.WaitDMA1
	cmp.b	#$16,vhposr+1(A5)		; wait til after Audio DMA slots
	bcs.s	.WaitDMA1
	moveq	#1,d0

	move.w	D0,6(A1)

;.MaxPeriod0
;	btst.l	#0,d2
;	beq.s	.MaxPeriod1
;	move.w	d0,aud0+ac_per(A5)		; max. speed
;.MaxPeriod1
;	btst.l	#1,d2
;	beq.s	.MaxPeriod2
;	move.w	d0,aud1+ac_per(A5)		; max. speed
;.MaxPeriod2
;	btst.l	#2,d2
;	beq.s	.MaxPeriod3
;	move.w	d0,aud2+ac_per(A5)		; max. speed
;.MaxPeriod3
;	btst.l	#3,d2
;	beq.s	.MaxPeriod4
;	move.w	d0,aud3+ac_per(A5)		; max. speed
.MaxPeriod4
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

;	move.w	per,ac_per(a6)

;	tst.w	d3				; necessary to start channels ?
;	beq.s	.Done				; no !

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
;	and.w	d3,d0

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
	lea	lbL001070,A0
	tst.l	(A0)
	bne.b	SampOK
	bsr.w	InitSamp
	move.l	#$B2B24D4D,(A0)+		; pulse sample
	move.w	#$8080,(A0)			; SID sample
SampOK
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; module buffer
	move.l	A5,(A6)				; EagleBase

	lea	FastLength(PC),A1
	clr.l	(A1)

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	clr.l	Fast(A4)
	clr.l	Special(A4)
	move.l	Size(PC),D4
	lea	(A0,D4.L),A0
	sub.l	D4,D0
	move.l	A0,A2

	cmp.l	#'COSO',(A0)
	beq.w	Packed
	cmp.l	#'MMME',$20(A0)
	beq.w	Packed
	move.l	A0,D6
	addq.l	#4,A0
	moveq	#2,D1
	add.w	(A0)+,D1
	add.w	(A0)+,D1
	lsl.l	#6,D1
	moveq	#1,D2
	add.w	(A0)+,D2
	moveq	#1,D3
	add.w	(A0)+,D3
	mulu.w	#12,D3
	mulu.w	(A0)+,D2
	add.l	D2,D1
	add.l	D3,D1
	addq.l	#2,A0
	moveq	#2,D2
	add.w	(A0)+,D2
	add.w	(A0),D2
	mulu.w	#6,D2
	add.l	D2,D1
	moveq	#32,D2
	add.l	D2,D1
	moveq	#0,D3
	moveq	#0,D7
	sub.l	D1,D0
	bmi.w	Short
	beq.b	NoDigi2
	lea	(A2,D1),A1
	cmp.w	#$80,(A1)
	beq.b	Diga
	cmp.w	#$100,(A1)
	beq.b	Diga
	tst.b	(A1)
	beq.b	NoDigi2
	move.l	A1,Special(A4)
	bra.b	NoDigi2
Diga
	move.l	A1,D7
NextDig2
	move.w	(A1),D3
	addq.l	#8,A1
	tst.w	(A1)
	bne.b	NextDig2
	sub.l	D3,D0
	bmi.w	Short
NoDigi2
	move.l	D1,D0				; calc size
	move.l	D1,Fast(A4)
	add.l	D4,D1
	move.l	D1,SongSize(A4)
	add.l	D3,D1
	move.l	D1,CalcSize(A4)
	move.l	D3,SamplesSize(A4)

	move.l	D0,D5
	move.l	4.W,A6				; exec base
	move.l	#$10001,D1			; cleared fast memory ?
	jsr	_LVOAllocMem(A6)		; Alloc Mem
	lea	FastPtr(PC),A3
	move.l	D0,(A3)+			; FastPtr
	beq.w	NoMemory
	move.l	D5,(A3)				; FastLength
	move.l	D0,A1
	move.l	D6,A0
	movem.l	D0-A6,-(SP)
	bsr.w	Compress
	movem.l	(SP)+,D0-A6
	move.l	A1,A0
	tst.l	D7
	beq.b	SkipCO
	sub.l	A1,D7
	move.l	D7,$1C(A1)
	bra.b	SkipCO
Packed
	move.l	A0,A1
	move.l	24(A0),D2
	move.w	50(A0),D3
	addq.w	#1,D3
	mulu.w	#6,D3
	add.l	D3,D2
	moveq	#0,D3
	sub.l	D2,D0
	bmi.w	Short
	beq.b	NoDigi
	add.l	D2,A1
	cmp.w	#$80,(A1)
	beq.b	Digital
	cmp.w	#$100,(A1)
	beq.b	Digital
	tst.b	(A1)
	beq.b	NoDigi
	move.l	A1,Special(A4)
	bra.b	NoDigi
Digital
	move.l	A1,D5
	sub.l	A0,D5
	move.l	D5,28(A0)
NextDig
	move.w	(A1),D3
	addq.l	#8,A1
	tst.w	(A1)
	bne.b	NextDig
	sub.l	D3,D0
	bmi.w	Short
NoDigi
	add.l	D2,D4
	move.l	D4,SongSize(A4)
	add.l	D3,D4
	move.l	D4,CalcSize(A4)
	move.l	D3,SamplesSize(A4)
SkipCO
	move.w	48(A0),SubSongs+2(A4)

	moveq	#0,D5
	moveq	#0,D6
	moveq	#0,D7
	tst.w	64(A0)
	beq.b	LongType
	not.w	D7
LongType
	move.l	ModulePtr(PC),A1
	cmp.l	A2,A1
	beq.b	NoRep
CheckReplay
	cmp.w	#$FA23,(A1)
	bne.b	NoTime1
	tst.l	D5
	bne.b	NoTime1
	move.b	-1(A1),D5
NoTime1
	cmp.w	#$FA1F,(A1)
	bne.b	NoTime2
	tst.l	D5
	bne.b	NoTime2
	move.b	-1(A1),D5
NoTime2
	cmp.w	#$FA25,(A1)
	bne.b	NoTime3
	tst.l	D5
	bne.b	NoTime3
	move.b	-1(A1),D5
NoTime3
	cmp.w	#$FA21,(A1)			; never used timer ?
	bne.b	NoTime4
	tst.l	D5
	bne.b	NoTime4
	move.b	-1(A1),D5
NoTime4
	cmp.l	#$484049FA,(A1)			; standard sample
	bne.b	NoSpec1
	or.w	#2,D6
NoSpec1
	cmp.l	#$3C686,(A1)			; ST periods table
	bne.b	NoSpec2
	or.w	#1,D6
NoSpec2
	cmp.w	#$4EFB,(A1)+			; JMP xx(PC,D1.W)
	beq.b	NoRep
	cmp.l	A2,A1
	bne.b	CheckReplay
	clr.b	D7
NoRep
	lea	TypeAdr(PC),A6
	move.w	D7,(A6)+		; Types

	move.w	#$248,D7		; default period for $65 (timer value)
	tst.l	D5
	beq.b	NoTimer
	move.w	D5,D7
	move.l	#2457600,D5
	divu.w	D7,D5
	lsr.w	#2,D5			; /4
	move.l	#$361F10,D7		; Amiga PAL clock * 5 + 1
	divu.w	D5,D7
	addq.w	#1,D7
NoTimer
	move.w	D7,(A6)			; Period
	move.l	A0,A6
	bsr.w	InitPlay
	move.l	EagleBase(PC),A5
	move.l	TwoFiles(PC),D1
	beq.b	NoExt

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	lbL000F6A(PC),A1
	move.l	A0,(A1)
	add.l	D0,LoadSize(A4)

	moveq	#0,D1
NextDig1
	move.w	(A0),D1
	addq.l	#8,A0
	tst.w	(A0)
	bne.b	NextDig1
	sub.l	D1,D0
	bmi.b	Short
	move.l	D1,SamplesSize(A4)
	add.l	D1,CalcSize(A4)
NoExt
	lea	TypeSID(PC),A3
	move.w	D6,(A3)				; period type
	beq.b	NoConv
	cmp.w	#2,D6
	bge.b	NoConv
	move.l	SamplesSize(A4),D1
	beq.b	NoConv
	move.l	lbL000F6A(PC),A0
	lea	(A0,D1.L),A1			; samples end
	add.w	(A0),A0				; samples start
	move.l	(A0),D1
	and.l	#$F0F0F0F0,D1
	bne.b	NoConv
	bsr.b	Conv
NoConv
	cmp.l	#'MMME',(A6)
	bne.b	NoSID
	move.l	lbL000F4A(PC),A0
	add.w	(A0),A0
	move.l	lbL000F4E(PC),A1
SIDCheck
	cmp.b	#$EF,(A0)+
	beq.b	SIDNew
	cmp.l	A0,A1
	bne.b	SIDCheck
	bra.b	NoSID
SIDNew
	st.b	(A3)
NoSID
	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

Short
	moveq	#EPR_ModuleTooShort,D0
	rts

NoMemory
	moveq	#EPR_NotEnoughMem,D0
	rts

Conv
	lea	Bit8Table(PC),A2
NextByte
	move.b	(A0),D0
	bpl.b	Bit4
	cmp.b	#$88,D0
	bne.b	NoFF
	moveq	#17,D0
	bra.b	Skip8
NoFF
	moveq	#16,D0
	bra.b	Skip8
Bit4
	and.w	#15,D0
Skip8
	move.b	0(A2,D0.W),(A0)+
	cmp.l	A1,A0
	blt.b	NextByte
	rts

Bit8Table
	dc.b	$80
	dc.b	$93
	dc.b	$A7
	dc.b	$BF
	dc.b	$CF
	dc.b	$DF
	dc.b	$EF
	dc.b	$FF
	dc.b	15
	dc.b	$1F
	dc.b	$2F
	dc.b	$3F
	dc.b	$4F
	dc.b	$5F
	dc.b	$6F
	dc.b	$7F
	dc.b	$00
	dc.b	$FF

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	move.l	4.W,A6
	move.l	FastLength(PC),D0
	beq.b	SkipFast
	move.l	FastPtr(PC),A1
	jsr	_LVOFreeMem(A6) 		     ; FreeMem
SkipFast
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

	bsr.w	Init_Emu

	move.l	lbL000F5A(PC),A0
	move.w	dtg_SndNum(A5),D0
	move.w	D0,D1
	subq.w	#1,D1
	mulu.w	#6,D1
	tst.w	4(A0,D1.W)
	bne.b	SpeedOK
	move.w	#4,4(A0,D1.W)			; default speed
SpeedOK
	move.w	2(A0,D1.W),D2
	sub.w	0(A0,D1.W),D2
	bpl.b	LengthOK
	clr.l	0(A0,D1.W)
	moveq	#0,D2
LengthOK
	addq.w	#1,D2
	lea	InfoBuffer(PC),A0
	move.w	D2,Length+2(A0)
	bra.w	Init

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	moveq	#0,D0
	bsr.w	Init
	lea	$DFF000,A0
	move.w	#15,$96(A0)
	moveq	#0,D0
	move.w	D0,$A8(A0)
	move.w	D0,$B8(A0)
	move.w	D0,$C8(A0)
	move.w	D0,$D8(A0)
	rts

***************************************************************************
*************************** Jochen Hippel ST player ***********************
***************************************************************************

; Resourced NotePlayer

;	SECTION	HippelST_note000000,CODE
;ProgStart
;	MOVEQ	#-1,D0
;	RTS

;	dc.b	'DELIRIUM'
;	dc.l	lbL00004C
;	dc.b	'$VER: Jochen Hippel Atari-ST player module V'
;	dc.b	'1.1 (21 Jan 97)',0
;lbL00004C
;	dc.l	DTP_RequestDTVersion,DELIVERSION
;	dc.l	DTP_RequestDTVersion
;	dc.l	$11
;	dc.l	DTP_PlayerVersion
;	dc.l	$1000A
;	dc.l	DTP_PlayerName
;	dc.l	HippelST.MSG
;	dc.l	DTP_Creator
;	dc.l	writtenbyJoch.MSG
;	dc.l	DTP_DeliBase
;	dc.l	lbL000106
;	dc.l	DTP_Flags
;	dc.l	2
;	dc.l	DTP_Check2
;	dc.l	lbC0001A6
;	dc.l	DTP_CheckLen
;	dc.l	$128
;	dc.l	DTP_ExtLoad
;	dc.l	lbC0002CE
;	dc.l	DTP_SubSongRange
;	dc.l	lbC000328
;	dc.l	DTP_Config
;	dc.l	lbC00013E
;	dc.l	DTP_InitNote
;	dc.l	lbC00015E
;	dc.l	DTP_NoteStruct
;	dc.l	lbL00011A
;	dc.l	DTP_Interrupt
;	dc.l	lbC00018A
;	dc.l	DTP_InitPlayer
;	dc.l	lbC000330
;	dc.l	DTP_EndPlayer
;	dc.l	lbC000376
;	dc.l	DTP_InitSound
;	dc.l	lbC00037A
;	dc.l	DTP_EndSound
;	dc.l	lbC00038A
;	dc.l	0
;HippelST.MSG	dc.b	'Hippel-ST',0
;writtenbyJoch.MSG	dc.b	'written by Jochen Hippel',$A
;	dc.b	' ',0,0
;lbL000106	dc.l	0
;lbL00010A	dc.l	0
;	dc.l	0
;lbW000112	dc.w	0
;samp.MSG	dc.b	'.samp',0
;lbL00011A	dc.l	lbL00011E
;lbL00011E	dc.l	lbL00147C
;	dc.l	$20212
;	dc.l	$70C3
;	dc.l	$400000
;	dc.l	0
;	dc.l	0
;	dc.l	0
;	dc.l	0

;lbC00013E	MOVEA.L	lbL00011E(PC),A0		; config
;	MOVEQ	#2,D0
;lbC000144	LEA	$40(A0),A1
;	MOVE.L	A1,0(A0)
;	MOVEA.L	A1,A0
;	DBRA	D0,lbC000144
;	CLR.L	0(A0)
;	BSR.L	lbC000DCA
;	MOVEQ	#0,D0
;	RTS

;lbC00015E	MOVEQ	#4,D1				; initnote
;	MOVEQ	#2,D2
;	MOVE.L	lbL00011E(PC),D0
;	MOVE.W	#$8001,D3
;lbC00016A	MOVEA.L	D0,A0
;	SUBQ.W	#1,D1
;	BCC.S	lbC000174
;	MOVE.W	#$8000,D3
;lbC000174	MOVE.W	D3,12(A0)
;	SUBQ.W	#1,D2
;	BNE.S	lbC000180
;	MOVEQ	#2,D2
;	NEG.W	D3
;lbC000180	MOVE.L	0(A0),D0
;	BNE.S	lbC00016A
;	MOVEQ	#0,D0
;	RTS

;lbC00018A	MOVEM.L	D2-D7/A2-A6,-(SP)		; interrupt
;	BSR.L	lbC0006D6
;	BSR.L	lbC0003DA
;	MOVEA.L	lbL000106(PC),A0
;	MOVEA.L	$74(A0),A0
;	JSR	(A0)
;	MOVEM.L	(SP)+,D2-D7/A2-A6
;	RTS

;lbC0001A6	MOVEA.L	$24(A5),A0			; check2
;	MOVE.L	$28(A5),D0
;	BSR.L	lbC0001C0
;	CMP.W	#2,D0
;	BNE.S	lbC0001BC
;	MOVEQ	#0,D0
;	BRA.S	lbC0001BE

;lbC0001BC	MOVEQ	#-1,D0
;lbC0001BE	RTS

Check
lbC0001C0	MOVEA.L	A0,A1
	MOVEQ	#$7F,D1
	BRA.S	lbC0001DA

lbC0001C6	CMPI.W	#$41FA,(A1)+
	BNE.S	lbC0001F2
	MOVE.W	(A1),D2
	BMI.S	lbC0001F2
	BTST	#0,D2
	BNE.S	lbC0001F2
	LEA	0(A1,D2.W),A0
lbC0001DA	CMPI.L	#'MMME',(A0)
	BEQ.S	lbC0001FC
	CMPI.L	#'TFMX',(A0)
	BEQ.S	lbC000204
	CMPI.L	#'COSO',(A0)
	BEQ.S	lbC000262
lbC0001F2	SUBQ.L	#2,D0
	DBMI	D1,lbC0001C6
lbC0001F8	MOVEQ	#0,D0
	RTS

lbC0001FC
;	MOVEQ	#1,D0
;	RTS


lbC000200	MOVEQ	#2,D0
	RTS

lbC000204	CMPI.W	#$200,4(A0)
	BGE.S	lbC0001F8

	tst.w	16(A0)				; FX Check
	beq.b	lbC0001F8

	BSR.S	lbC000216
	CMP.L	D6,D7
	BLT.S	lbC000230
	MOVEQ	#1+1,D0
	RTS

lbC000216	MOVE.W	4(A0),D0
	LEA	$20(A0),A1
	MOVEQ	#0,D6
	MOVEQ	#0,D7
lbC000222	BSR.L	lbC0002B6
	LEA	$40(A1),A1
	DBRA	D0,lbC000222
	RTS

lbC000230
;	MOVEQ	#2,D0
;	ADD.W	4(A0),D0
;	ADD.W	6(A0),D0
;	MULU.W	#$40,D0
;	LEA	$20(A0,D0.W),A1
;	MOVE.W	8(A0),D0
;	MOVE.W	12(A0),D1
;	ADDQ.W	#1,D0
;	MULU.W	D0,D1
;	ADDA.L	D1,A1
;	MOVE.B	3(A1),D1
;	CMP.B	#$FF,D1
;	BNE.S	lbC00025E
	MOVEQ	#5,D0
	RTS

;lbC00025E	MOVEQ	#3,D0
;	RTS

lbC000262
	tst.w	48(A0)				; FX Check
	beq.w	lbC0001F8
	tst.l	24(A0)
	beq.b	lbC0001F8

	CMPI.L	#'TFMX',$20(A0)
	BEQ.S	lbC00027A
	CMPI.L	#'MMME',$20(A0)
	BEQ.w	lbC000200
	MOVEQ	#0,D0
	RTS

lbC00027A	BSR.S	lbC000284
	CMP.L	D6,D7
	BLT.S	lbC00029E
	MOVEQ	#2,D0
	RTS

lbC000284	MOVEA.L	A0,A2
	ADDA.L	4(A0),A2
	MOVEQ	#0,D6
	MOVEQ	#0,D7
	MOVE.W	$24(A0),D0
lbC000292
	tst.w	64(A0)
	beq.b	Longer

	MOVEA.W	(A2)+,A1

	bra.b	SkipLon
Longer
	move.l	(A2)+,A1
SkipLon
	ADDA.L	A0,A1
	BSR.S	lbC0002B6
	DBRA	D0,lbC000292
	RTS

lbC00029E
;	MOVE.L	$10(A0),D0
;	LEA	0(A0,D0.W),A1
;	CMPI.B	#$FF,3(A1)
;	BEQ.S	lbC0002B2
	MOVEQ	#4,D0
	RTS

;lbC0002B2	MOVEQ	#6,D0
;	RTS

lbC0002B6	MOVEA.L	A1,A3
	MOVEQ	#0,D1
	MOVE.B	(A3)+,D1
	CMP.B	#$E2,D1
	BNE.S	lbC0002CC
	TST.B	(A3)
	BMI.S	lbC0002CA
	ADDQ.W	#1,D6
	BRA.S	lbC0002CC

lbC0002CA	ADDQ.W	#1,D7
lbC0002CC	RTS

;lbC0002CE	MOVEA.L	$24(A5),A0			; extload
;	MOVE.L	$28(A5),D0
;	BSR.L	lbC0001C0
;	MOVEQ	#0,D0
;	CMPI.L	#'LSMP',$1C(A0)
;	BNE.S	lbC000326
;	MOVEA.L	$20(A5),A0
;	CLR.B	(A0)
;	MOVEA.L	$40(A5),A0
;	JSR	(A0)
;	MOVEA.L	$44(A5),A0
;	JSR	(A0)
;	MOVEA.L	$60(A5),A0
;	JSR	(A0)
;	MOVEA.L	$20(A5),A0
;	MOVEQ	#1,D0
;lbC000304	ADDQ.L	#1,D0
;	TST.B	(A0)+
;	BNE.S	lbC000304
;lbC00030A	SUBQ.L	#1,D0
;	BEQ.S	lbC000316
;	CMPI.B	#$2E,-(A0)
;	BNE.S	lbC00030A
;	CLR.B	(A0)
;lbC000316	LEA	samp.MSG(PC),A0
;	MOVEA.L	$48(A5),A1
;	JSR	(A1)
;	MOVEA.L	$3C(A5),A0
;	JSR	(A0)
;lbC000326	RTS

;lbC000328	MOVEQ	#1,D0			; subsong range
;	MOVE.W	lbW000112(PC),D1
;	RTS

;lbC000330	MOVEQ	#0,D0			; init player
;	MOVEA.L	$38(A5),A0
;	JSR	(A0)
;	BSR.L	lbC0001C0
;	TST.W	D0
;	BEQ.S	lbC000376
;	MOVE.L	A0,lbL00010A
;	MOVE.W	$30(A0),lbW000112
;	CMPI.L	#'LSMP',$1C(A0)
;	BNE.S	lbC00036A
;	MOVEQ	#1,D0
;	MOVEA.L	$38(A5),A0
;	JSR	(A0)
;	MOVEA.L	lbL00010A(PC),A1
;	SUBA.L	A1,A0
;	MOVE.L	A0,$1C(A1)
;lbC00036A	MOVEA.L	lbL00010A(PC),A0
;	BSR.L	lbC000664
;	MOVEQ	#0,D0
;	RTS

;lbC000376	MOVEQ	#-1,D0
;	RTS

;lbC00037A	BSR.L	lbC000392		; initsound
;	MOVEQ	#0,D0
;	MOVE.W	$2C(A5),D0
;	BSR.L	lbC00063C
;	RTS

;lbC00038A	MOVEQ	#0,D0			; endsound
;	BSR.L	lbC00063C
;	RTS

Init_Emu
lbC000392	LEA	lbL000616(PC),A0
	MOVE.W	#0,10(A0)
	LEA	lbL000622(PC),A0
	MOVE.W	#0,10(A0)
	LEA	lbL00062E(PC),A0
	MOVE.W	#0,10(A0)
	LEA	lbL000E26(PC),A0
	MOVE.B	#$3B,$1E(A0)
	MOVE.B	#$10,$2A(A0)
	MOVE.B	#0,$26(A0)
	MOVE.B	#0,$22(A0)
	MOVE.B	#4,$16(A0)
	MOVE.B	#0,$12(A0)

	lea	lbW0004C8(PC),A0
	clr.w	(A0)

	RTS

Play_Emu
lbC0003DA	LEA	lbL000E26(PC),A6
	MOVE.B	$1E(A6),D7
	NOT.B	D7
	ANDI.W	#$3F,D7
;	LEA	lbL00147C,A1

	lea	$DFF0A0,A1

	LEA	lbL000616(PC),A0
	MOVEQ	#0,D5
	MOVEQ	#3,D6
	MOVE.B	6(A6),D4
	LSL.W	#8,D4
	MOVE.B	2(A6),D4
	MOVEQ	#0,D3
	MOVE.B	$22(A6),D3
	BSR.L	lbC0004DC
;	LEA	lbL0014BC,A1

	lea	$DFF0D0,A1

	LEA	lbL000622(PC),A0
	MOVEQ	#1,D5
	MOVEQ	#4,D6
	MOVE.B	14(A6),D4
	LSL.W	#8,D4
	MOVE.B	10(A6),D4
	MOVEQ	#0,D3
	MOVE.B	$26(A6),D3
	BSR.L	lbC0004DC
;	LEA	lbL00153C,A1

	lea	$DFF0C0,A1

	LEA	lbL00062E(PC),A0
	MOVEQ	#2,D5
	MOVEQ	#5,D6
	MOVE.B	$16(A6),D4
	LSL.W	#8,D4
	MOVE.B	$12(A6),D4
	MOVEQ	#0,D3
	MOVE.B	$2A(A6),D3
	BSR.L	lbC0004DC
;	LEA	lbL0014FC,A0

	moveq	#3,D5
	lea	$DFF0B0,A1

	TST.W	lbW0004C8
	BNE.S	lbC00046C
;	MOVE.L	#lbL001470,$10(A0)
;	MOVE.W	#1,$14(A0)

	lea	lbL001470,A2
	move.l	#$10001,D4
	move.l	A2,A3

	BRA.S	lbC00048A

lbC00046C	CMPI.W	#1,lbW0004C8
	BNE.S	lbC0004BC
	MOVE.W	#2,lbW0004C8
;	MOVE.L	lbL0004BE(PC),$10(A0)
;	MOVE.W	lbW0004C2(PC),$14(A0)

	move.l	lbL0004BE(PC),A2
	move.l	RepStart(PC),A3
	move.w	RepLen(PC),D4
	swap	D4
	move.w	lbW0004C2(PC),D4

lbC00048A
;	MOVE.W	lbW0004C4(PC),$20(A0)
;	MOVE.W	lbW0004C6(PC),$24(A0)
;	MOVE.L	#lbL001470,$18(A0)
;	MOVE.W	#1,$1C(A0)
;	BSET	#1,11(A0)
;	BSET	#2,11(A0)
;	BSET	#4,11(A0)
;	BSET	#3,11(A0)

	bsr.w	NotePlay
;	move.w	lbW0004C4(PC),6(A1)
;	move.w	lbW0004C6(PC),8(A1)

	move.w	lbW0004C4(PC),D0
	move.w	D0,6(A1)
	bsr.w	SetPer
	move.w	lbW0004C6(PC),D0
	bpl.b	NoSIDVol
	move.w	lbL000616(PC),D0		; use canal A volume
NoSIDVol
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,8(A1)

lbC0004BC	RTS

RepStart
	dc.l	0
RepLen
	dc.w	0

lbL0004BE	dc.l	0
lbW0004C2	dc.w	0
lbW0004C4	dc.w	$240
lbW0004C6	dc.w	$40
lbW0004C8	dc.w	0
lbB0004CA	dc.b	0
	dc.b	1
	dc.b	2
	dc.b	3
	dc.b	4
	dc.b	6
	dc.b	8
	dc.b	10
	dc.b	13
	dc.b	$10
	dc.b	$14
	dc.b	$18
	dc.b	$1E
	dc.b	$26
	dc.b	$30
	dc.b	$40
	dc.b	$20
	dc.b	0

lbC0004DC	MOVE.B	lbB0004CA(PC,D3.W),1(A0)

	and.w	#$FFF,D4

	MULU.W	#7,D4

	addq.w	#1,D4

	MOVE.W	D4,2(A0)
	BTST	D5,D7
	BNE.L	lbC0005DA
	BTST	D6,D7
	BNE.L	lbC00054A
;	MOVE.L	#lbL001470,$10(A1)		; address ?
;	MOVE.W	#1,$14(A1)			; length ?
;	BSET	#1,11(A1)
;	MOVE.L	#lbL001470,$18(A1)		; repeat address ?
;	MOVE.W	#1,$1C(A1)			; repeat length ?
;	BSET	#2,11(A1)

	lea	lbL001470,A2
	move.l	A2,A3
	move.l	#$10001,D4
	bsr.w	NotePlay

	MOVE.W	#0,0(A0)
	MOVE.W	#$100,2(A0)
	MOVE.W	#0,10(A0)
lbC000530
;	MOVE.W	0(A0),$24(A1)			; volume ?
;	BSET	#4,11(A1)
;	MOVE.W	2(A0),$20(A1)			; period ?
;	BSET	#3,11(A1)

;	move.w	(A0),8(A1)
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
;	MOVE.L	#lbL001070,$10(A1)		; address ?
;	MOVE.W	#$200,$14(A1)			; length ?
;	BSET	#1,11(A1)
;	MOVE.L	#lbL001070,$18(A1)		; address ?
;	MOVE.W	#$200,$1C(A1)			; length ?
;	BSET	#2,11(A1)

	lea	lbL001070,A2
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

lbW00059A	dc.w	$280
	dc.w	$270
	dc.w	$260
	dc.w	$250
	dc.w	$240
	dc.w	$230
	dc.w	$220
	dc.w	$210
	dc.w	$200
	dc.w	$1F0
	dc.w	$1E0
	dc.w	$1D0
	dc.w	$1C0
	dc.w	$1B0
	dc.w	$1A0
	dc.w	$190
	dc.w	$180
	dc.w	$170
	dc.w	$160
	dc.w	$150
	dc.w	$140
	dc.w	$130
	dc.w	$120
	dc.w	$110
	dc.w	$100
	dc.w	$F0
	dc.w	$E0
	dc.w	$D0
	dc.w	$C0
	dc.w	$B0
	dc.w	$A0
	dc.w	$90

lbC0005DA	MOVE.W	10(A0),D0
	CMP.W	#1,D0
	BEQ.S	lbC000612
	MOVE.W	#1,10(A0)
;	MOVE.L	#lbL001478,$10(A1)		; address ?
;	MOVE.W	#2,$14(A1)			; length ?
;	BSET	#1,11(A1)
;	MOVE.L	#lbL001478,$18(A1)		; repeat address ?
;	MOVE.W	#2,$1C(A1)			; repeat length ?
;	BSET	#2,11(A1)

	lea	lbL001478,A2
	move.l	A2,A3
	move.l	#$20002,D4
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
;	dc.w	0

Init
lbC00063C	TST.W	D0
	BEQ.S	lbC00065A
	SUBQ.W	#1,D0
	MOVEA.L	lbL000F5A(PC),A1
	MULU.W	#6,D0
	ADDA.W	D0,A1
	MOVE.W	(A1)+,D0
	MOVE.W	(A1)+,D1
	LEA	lbW000E6E(PC),A5
	MOVE.W	(A1),(A5)
	BRA.L	lbC0008FE

lbC00065A	LEA	lbW000E70(PC),A0
	ST	(A0)
	BRA.L	lbC0006D6

InitPlay
lbC000664	LEA	lbB000F6F(PC),A1
	SF	(A1)
	CMPI.L	#'MMME',$20(A0)
	BNE.S	lbC000678
	MOVE.B	#1,(A1)
lbC000678	LEA	lbL000F66(PC),A5
	MOVE.L	A0,(A5)
	MOVEA.L	4(A0),A1
	ADDA.L	A0,A1
	LEA	lbL000F4A(PC),A5
	MOVE.L	A1,(A5)
	MOVEA.L	8(A0),A1
	ADDA.L	A0,A1
	LEA	lbL000F4E(PC),A5
	MOVE.L	A1,(A5)
	MOVEA.L	12(A0),A1
	ADDA.L	A0,A1
	LEA	lbL000F46(PC),A5
	MOVE.L	A1,(A5)
	MOVEA.L	$10(A0),A1
	ADDA.L	A0,A1
	LEA	lbL000F52(PC),A5
	MOVE.L	A1,(A5)
	MOVEA.L	$14(A0),A1
	ADDA.L	A0,A1
	LEA	lbL000F5A(PC),A5
	MOVE.L	A1,(A5)+
	MOVEA.L	$18(A0),A1
	ADDA.L	A0,A1
	MOVE.L	A1,(A5)+
	MOVEA.L	$1C(A0),A1
	ADDA.L	A0,A1
	LEA	lbL000F6A(PC),A5
	MOVE.L	A1,(A5)+
;	LEA	lbW000F58(PC),A5
;	ST	(A5)
	RTS

Play
lbC0006D6	LEA	lbL000E26(PC),A5
	LEA	lbW000E6C(PC),A4
	TST.B	4(A4)
	BEQ.S	lbC000706
	TST.B	5(A4)
	BNE.S	lbC000704
	ST	5(A4)
	MOVEQ	#0,D0
	MOVE.B	D0,$12(A5)
	MOVE.B	D0,$16(A5)
	MOVE.B	D0,$22(A5)
	MOVE.B	D0,$26(A5)
	MOVE.B	D0,$2A(A5)
lbC000704	RTS

lbC000706	LEA	lbL000E64(PC),A4
	LEA	lbL000E72(PC),A0
	BSR.L	lbC0009F6
	MOVE.W	D0,-(SP)
	MOVE.B	(SP)+,6(A5)
	MOVE.B	D0,2(A5)
	MOVE.B	D1,$22(A5)

	tst.b	TypeSID
	bne.w	SID_New
	move.b	$36(A0),D5
	bmi.w	SID00038A			; SID off check
	beq.w	SID000384
	cmp.b	#1,D5
	beq.b	SID000314
	cmp.b	#4,D5
	beq.b	SID00037C
	cmp.b	#2,D5
	bne.b	SID00030A
	move.w	SID2(PC),D0
	bra.b	SID000314

SID00030A
	cmp.b	#3,D5
	bne.b	SID000314
	move.w	SID3(PC),D0
SID000314
	cmp.w	#$10,D0
	ble.b	SID000384
	cmp.w	#$EEE,D0
	bhi.b	SID000384
	mulu.w	#7,D0
	addq.w	#1,D0
	move.w	D0,lbW0004C4
SID00037C
	lea	Bit8Table(PC),A0
	and.w	#15,D1
	move.b	(A0,D1.W),D1
	lea	SIDword+1,A0
	move.b	D1,(A0)
	move.l	A0,lbL0004BE
	move.l	A0,RepStart
	st.b	lbW0004C6
	moveq	#1,D0
	move.w	D0,lbW0004C2
	move.w	D0,RepLen
	move.w	D0,lbW0004C8			; channel start
	bra.b	SID00038A

SID000384
	st	$36(A0)				; SID off
	clr.w	lbW0004C8			; channel off
	bra.w	SID00038A
SID_New

; space for Warptyme SID code

SID00038A
	LEA	lbL000EA6(PC),A0
	BSR.L	lbC0009F6
	MOVE.W	D0,-(SP)
	MOVE.B	(SP)+,14(A5)
	MOVE.B	D0,10(A5)
	MOVE.B	D1,$26(A5)
	LEA	lbL000EDA(PC),A0
	BSR.L	lbC0009F6
	MOVE.W	D0,-(SP)
	MOVE.B	(SP)+,$16(A5)
	MOVE.B	D0,$12(A5)
	MOVE.B	D1,$2A(A5)
;	MOVEQ	#0,D6
;	MOVE.B	(A4)+,D7
;	OR.B	D6,D7
;	MOVE.B	D7,$1E(A5)

	move.b	(A4)+,$1E(A5)

	MOVE.B	(A4)+,$1A(A5)
	LEA	lbW000E6C(PC),A5
	SUBQ.W	#1,(A5)+
	BNE.S	lbC000782
	MOVE.W	(A5),-(A5)
	MOVEQ	#0,D5
	MOVEQ	#0,D4
	LEA	lbL000E72(PC),A0
	BSR.L	lbC000784
	ST	D4
	LEA	lbL000EA6(PC),A0
	BSR.L	lbC000784
	LEA	lbL000EDA(PC),A0
	BSR.L	lbC000784
lbC000782	RTS

lbC000784	SUBQ.B	#1,$1A(A0)
	BPL.L	lbC000782
	MOVE.B	$1B(A0),$1A(A0)
lbC000792	MOVEA.L	12(A0),A1
lbC000796	MOVE.B	(A1)+,D0
	CMP.B	#$FF,D0
	BNE.L	lbC00082E
	MOVEA.L	0(A0),A2
	ADDA.W	$14(A0),A2
	TST.B	D4
	BNE.S	lbC0007D6
	SUBQ.W	#1,$1C(A0)
	BPL.S	lbC0007D6
;	MOVE.L	A0,-(SP)
;	MOVEA.L	lbL000106(PC),A0
;	MOVEA.L	$5C(A0),A0
;	JSR	(A0)
;	MOVEA.L	(SP)+,A0

	bsr.w	SongEnd
	bsr.w	Init_Emu
	lea	lbL000E72(PC),A0
	st	$36(A0)				; SID off

	MOVE.W	lbW000F44(PC),$1C(A0)
	MOVE.W	D5,$14(A0)
	MOVE.W	D5,$48+4(A0)			; + SID size
	MOVE.W	D5,$7C+8(A0)			; + SID size
	MOVEA.L	0(A0),A2
lbC0007D6	MOVEQ	#0,D1
	MOVE.B	(A2),D1
	MOVE.B	1(A2),$21(A0)
	MOVE.B	2(A2),$20(A0)
	MOVE.B	3(A2),D0
	MOVE.B	D0,D2
	ANDI.W	#$F0,D2
	CMP.W	#$F0,D2
	BNE.S	lbC000802
	MOVE.B	D0,D2
	ANDI.B	#15,D2
	MOVE.B	D2,$30(A0)
	BRA.S	lbC000812

lbC000802	CMP.B	#$E0,D2
	BNE.S	lbC000812
	MOVE.B	D0,D2
	ANDI.W	#15,D2
	MOVE.W	D2,2(A5)
lbC000812	ADD.W	D1,D1
	MOVEA.L	lbL000F46(PC),A3

	tst.b	TypeAdr
	bne.b	Short1
	add.w	D1,D1
	move.l	0(A3,D1.W),A3
	bra.b	Skip1
Short1
	MOVEA.W	0(A3,D1.W),A3
Skip1
	ADDA.L	lbL000F66(PC),A3
	MOVE.L	A3,12(A0)
	ADDI.W	#12,$14(A0)
	BRA.L	lbC000792

lbC00082E	CMP.B	#$FE,D0
	BNE.S	lbC000840
	MOVE.B	(A1),$1B(A0)
	MOVE.B	(A1)+,$1A(A0)
	BRA.L	lbC000796

lbC000840	CMP.B	#$FD,D0
	BNE.S	lbC000854
	MOVE.B	(A1),$1B(A0)
	MOVE.B	(A1)+,$1A(A0)
	MOVE.L	A1,12(A0)
	RTS

lbC000854	MOVE.B	D0,$1E(A0)
	MOVE.B	(A1)+,D1
	MOVE.B	D1,$1F(A0)
	ANDI.W	#$E0,D1
	BEQ.S	lbC000868
	MOVE.B	(A1)+,$2C(A0)
lbC000868	MOVE.L	A1,12(A0)
	MOVE.L	D5,$10(A0)
	TST.B	D0
	BMI.L	lbC0008FC
	MOVE.B	$1F(A0),D1
	MOVE.B	D1,D0
	ANDI.W	#$1F,D1
	ADD.B	$20(A0),D1
	MOVEA.L	lbL000F66(PC),A3
	CMP.W	$26(A3),D1
	BLS.S	lbC000890
	MOVEQ	#0,D1
lbC000890	MOVEA.L	lbL000F4E(PC),A2
	ADD.W	D1,D1

	tst.b	TypeAdr
	bne.b	Short2
	add.w	D1,D1
	move.l	0(A2,D1.W),A2
	bra.b	Skip2
Short2
	MOVEA.W	0(A2,D1.W),A2
Skip2
	ADDA.L	lbL000F66(PC),A2
	MOVE.W	D5,$16(A0)
	MOVE.B	(A2),$23(A0)
	MOVE.B	(A2)+,$22(A0)
	MOVEQ	#0,D1
	MOVE.B	(A2)+,D1
	MOVE.B	(A2)+,$27(A0)
	MOVE.B	#$40,$2B(A0)
	MOVE.B	(A2),$28(A0)
	MOVE.B	(A2)+,$29(A0)
	MOVE.B	(A2)+,$2A(A0)
	MOVE.L	A2,4(A0)
	ANDI.B	#$40,D0
	BEQ.S	lbC0008D2
	MOVE.B	$2C(A0),D1
lbC0008D2	MOVEA.L	lbL000F66(PC),A3
	CMP.W	$24(A3),D1
	BLS.S	lbC0008DE
	MOVEQ	#0,D1
lbC0008DE	MOVEA.L	lbL000F4A(PC),A2
	ADD.W	D1,D1

	tst.b	TypeAdr
	bne.b	Short3
	add.w	D1,D1
	move.l	0(A2,D1.W),A2
	bra.b	Skip3
Short3
	MOVEA.W	0(A2,D1.W),A2
Skip3
	ADDA.L	lbL000F66(PC),A2
	MOVE.L	A2,8(A0)
	MOVE.W	D5,$18(A0)
	MOVE.B	D5,$25(A0)
	MOVE.B	D5,$24(A0)
lbC0008FC	RTS

lbC0008FE	MOVE.L	D0,D7
	MOVE.L	D1,D6
	SUB.L	D0,D1
	ADDQ.L	#1,D6
	MULU.W	#12,D7
	MULU.W	#12,D6
	LEA	lbW000F44(PC),A0
	MOVE.W	D1,(A0)
	MOVEQ	#2,D0
	LEA	lbL000E72(PC),A0
	LEA	lbW000E1A(PC),A1
	LEA	lbW000E22(PC),A2
lbC000922	MOVE.L	A1,8(A0)
	CLR.W	$18(A0)
	MOVE.L	A1,4(A0)
	CLR.W	$16(A0)
	SF	$1E(A0)
	SF	$1F(A0)
	SF	$26(A0)
	SF	$2F(A0)
	MOVE.B	#1,$23(A0)
	MOVE.B	#1,$22(A0)

	st	$36(A0)				; SID off
	sf	$37(A0)

	SF	$24(A0)
	SF	$25(A0)
	SF	$27(A0)
	SF	$28(A0)
	SF	$29(A0)
	SF	$2A(A0)
	SF	$2C(A0)
	SF	$2D(A0)
	MOVE.B	(A2),D3
	ANDI.W	#15,D3
	ADD.W	D3,D3
	ADD.W	D3,D3
	MOVE.B	(A2)+,$2E(A0)
	MOVEA.L	lbL000F52(PC),A3
	ADDA.L	D7,A3
	ADDA.W	D3,A3
	MOVE.L	A3,0(A0)
	MOVE.W	#12,$14(A0)
	MOVE.W	lbW000F44(PC),$1C(A0)
	MOVEQ	#0,D1
	MOVE.B	(A3)+,D1
	ADD.W	D1,D1
	MOVEA.L	lbL000F46(PC),A4

	tst.b	TypeAdr
	bne.b	Short4
	add.w	D1,D1
	move.l	0(A4,D1.W),A4
	bra.b	Skip4
Short4
	MOVEA.W	0(A4,D1.W),A4
Skip4
	ADDA.L	lbL000F66(PC),A4
	MOVE.L	A4,12(A0)
	CLR.W	$1A(A0)
	MOVE.B	#2,$32(A0)
	MOVE.B	(A3)+,$21(A0)
	SF	$33(A0)
	MOVE.B	(A3)+,$20(A0)
	SF	$31(A0)
	SF	$30(A0)
	MOVE.B	(A3)+,D1
	MOVE.B	D1,D2
	ANDI.W	#$F0,D1
	CMP.W	#$F0,D1
	BNE.S	lbC0009DC
	SUB.B	D1,D2
	MOVE.B	D2,$30(A0)
lbC0009DC	CLR.L	$10(A0)
	LEA	$34+4(A0),A0				; + SID size
	DBRA	D0,lbC000922
	LEA	lbW000E6C(PC),A0
	MOVE.W	#1,(A0)
	CLR.W	4(A0)
	RTS

lbC0009F6	MOVEQ	#0,D7
	MOVE.B	D7,$2D(A0)
lbC0009FC	TST.B	$25(A0)
	BEQ.S	lbC000A0A
	SUBQ.B	#1,$25(A0)
	BRA.L	lbC000B70

lbC000A0A	MOVEA.L	8(A0),A1
	ADDA.W	$18(A0),A1
lbC000A12	MOVE.B	(A1)+,D0
	MOVEQ	#0,D1
	MOVE.B	D0,D1

	tst.b	TypePlay
	bne.b	Jump
	cmp.w	#$EB,D1
	bge.w	lbC000B68
	tst.l	InfoBuffer+SamplesSize
	bne.b	Jump
	cmp.w	#$EA,D1
	beq.w	lbC000B68
Jump
	cmp.w	#$EF,D1				; for safety
	bgt.w	lbC000B68

	SUBI.W	#$E0,D1
	BMI.L	lbC000B68
	ADD.W	D1,D1
	MOVE.W	lbW000A2A(PC,D1.W),D1
	JMP	lbW000A2A(PC,D1.W)

lbW000A2A	dc.w	lbC000AB6-lbW000A2A	;e0 a few diff now OK
	dc.w	lbC000AC8-lbW000A2A		;e1 diff now OK?
	dc.w	lbC000AD2-lbW000A2A		;e2 diff now OK?
	dc.w	lbC000AE4-lbW000A2A		;e3 OK
	dc.w	lbC000AF4-lbW000A2A		;e4 OK
	dc.w	lbC000B04-lbW000A2A		;e5 OK
	dc.w	lbC000B12-lbW000A2A		;e6 OK
	dc.w	lbC000B20-lbW000A2A		;e7 diff now OK?
	dc.w	lbC000B40-lbW000A2A		;e8 OK
	dc.w	lbC000B4C-lbW000A2A		;e9 OK
	dc.w	lbC000B56-lbW000A2A		;ea diff now OK?
	dc.w	lbC000AAA-lbW000A2A
	dc.w	lbC000A46-lbW000A2A
	dc.w	lbC000A9A-lbW000A2A
	dc.w	SIDCom-lbW000A2A
	dc.w	SIDCom2-lbW000A2A

lbC000A46	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	MOVEA.L	lbL000F6A(PC),A2
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.W	0(A2,D0.W),D1
	MOVEQ	#0,D2

	move.w	2(A2,D0.W),D2
	beq.b	Stand
	cmp.w	#$0010,D2
	bne.b	NoStand
	move.w	D2,D0
	lsr.w	#1,D0
	move.w	D0,RepLen
	move.l	A2,D0
	add.l	D1,D0
	move.l	D0,RepStart
	bra.b	OldStand
Stand
	ADDQ.W	#8,D0
	MOVE.W	0(A2,D0.W),D2

NoStand
	move.l	#lbL001470,RepStart
	move.w	#1,RepLen

	SUB.L	D1,D2
OldStand
	ADD.L	A2,D1
	LSR.W	#1,D2
;	SUBQ.W	#1,D2
	MOVE.W	D2,lbW0004C2
;	ADDQ.L	#1,D1
;	BCLR	#0,D1
	MOVE.L	D1,lbL0004BE
	MOVE.W	#$40,lbW0004C6
;	MOVE.W	#$240,lbW0004C4

	move.w	Period(PC),D1
	tst.b	TypePeriod
	beq.b	Out
	lea	Table(PC),A2
	move.b	(A1)+,D0
	bmi.b	NewPeriod
	add.b	$1E(A0),D0
	add.b	$21(A0),D0
NewPeriod
	and.w	#$7F,D0
	cmp.w	#96,D0				; out of table check
	bge.b	Out1
	lsl.w	#2,D0
	move.l	(A2,D0.W),D0
	lsr.l	#3,D0
	mulu.w	#$10000/8,D1
	divu.w	D0,D1
	addq.w	#1,D1
Out1
	addq.w	#1,$18(A0)
Out
	move.w	D1,lbW0004C4

	MOVE.W	#1,lbW0004C8
	ADDQ.W	#2,$18(A0)
	BRA.L	lbC000A12

Table
	dc.l	$400
	dc.l	$43C
	dc.l	$47D
	dc.l	$4C1
	dc.l	$50A
	dc.l	$556
	dc.l	$5A8
	dc.l	$5FE
	dc.l	$659
	dc.l	$6BA
	dc.l	$720
	dc.l	$78D
	dc.l	$800
	dc.l	$879
	dc.l	$8FA
	dc.l	$983
	dc.l	$A14
	dc.l	$AAD
	dc.l	$B50
	dc.l	$BFC
	dc.l	$CB2
	dc.l	$D74
	dc.l	$E41
	dc.l	$F1A
	dc.l	$1000
	dc.l	$10F3
	dc.l	$11F5
	dc.l	$1306
	dc.l	$1428
	dc.l	$155B
	dc.l	$16A0
	dc.l	$17F9
	dc.l	$1965
	dc.l	$1AE8
	dc.l	$1C82
	dc.l	$1E34
	dc.l	$2000
	dc.l	$21E7
	dc.l	$23EB
	dc.l	$260D
	dc.l	$2851
	dc.l	$2AB7
	dc.l	$2D41
	dc.l	$2FF2
	dc.l	$32CB
	dc.l	$35D1
	dc.l	$3904
	dc.l	$3C68
	dc.l	$4000
	dc.l	$43CE
	dc.l	$47D6
	dc.l	$4C1B
	dc.l	$50A2
	dc.l	$556E
	dc.l	$5A82
	dc.l	$5FE4
	dc.l	$6597
	dc.l	$6BA2
	dc.l	$7208
	dc.l	$78D0
	dc.l	$8000
	dc.l	$879C
	dc.l	$8FAC
	dc.l	$9837
	dc.l	$A145
	dc.l	$AADC
	dc.l	$B504
	dc.l	$BFC8
	dc.l	$CB2F
	dc.l	$D744
	dc.l	$E411
	dc.l	$F1A1
	dc.l	$10000
	dc.l	$10F38
	dc.l	$11F59
	dc.l	$1306F
	dc.l	$1428A
	dc.l	$155B8
	dc.l	$16A09
	dc.l	$17F91
	dc.l	$1965F
	dc.l	$1AE89
	dc.l	$1C823
	dc.l	$1E343
	dc.l	$20000
	dc.l	$21E71
	dc.l	$23EB3
	dc.l	$260DF
	dc.l	$28514
	dc.l	$2AB70
	dc.l	$2D413
	dc.l	$2FF22
	dc.l	$32CBF
	dc.l	$35D13
	dc.l	$39047
	dc.l	$3C686

lbC000A9A	ADDQ.W	#1,$18(A0)
	MOVE.W	#0,lbW0004C8
	BRA.L	lbC000A12

SIDCom2
	move.b	(A1)+,$37(A0)
	bra.b	ComSet

SIDCom
	move.b	(A1)+,$36(A0)
ComSet	addq.w	#2,$18(A0)
	bra.w	lbC000A12

lbC000AAA	MOVE.B	(A1)+,$33(A0)
	ADDQ.W	#2,$18(A0)
	BRA.L	lbC000A12

lbC000AB6	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0

	tst.b	TypePlay
	bne.b	NoAnd
	and.w	#$3F,D0
NoAnd
	MOVE.W	D0,$18(A0)
	MOVEA.L	8(A0),A1
	ADDA.L	D0,A1
	BRA.L	lbC000A12

lbC000AC8
	tst.b	TypePlay
	beq.w	lbC000B70

	MOVE.B	-2(A1),$26(A0)
	BRA.L	lbC000B70

lbC000AD2
	tst.b	TypePlay
	bne.b	No
	clr.w	$16(A0)
	bra.b	Skippy
No
	MOVE.W	D7,$16(A0)
Skippy
	MOVE.B	#1,$22(A0)
	ADDQ.W	#1,$18(A0)
	BRA.L	lbC000A12

lbC000AE4	MOVE.B	(A1)+,$27(A0)
	MOVE.B	(A1)+,$28(A0)
	ADDQ.W	#3,$18(A0)
	BRA.L	lbC000A12

lbC000AF4	MOVE.B	D7,$32(A0)
	MOVE.B	(A1)+,$2D(A0)
	ADDQ.W	#2,$18(A0)
	BRA.L	lbC000A12

lbC000B04	MOVE.B	#1,$32(A0)
	ADDQ.W	#1,$18(A0)
	BRA.L	lbC000A12

lbC000B12	MOVE.B	#2,$32(A0)
	ADDQ.W	#1,$18(A0)
	BRA.L	lbC000A12

lbC000B20
	tst.b	TypePlay
	beq.w	lbC000A9A

	MOVE.B	#0,D1
	MOVE.B	(A1)+,D1
	MOVEA.L	lbL000F4E(PC),A1
	ADD.W	D1,D1
	MOVEA.W	0(A2,D1.W),A1
	ADDA.L	lbL000F66(PC),A1
	MOVE.L	A1,8(A0)
	MOVE.W	D7,$18(A0)
	BRA.L	lbC000A12

lbC000B40	MOVE.B	(A1)+,$25(A0)
	ADDQ.W	#2,$18(A0)
	BRA.L	lbC0009FC

lbC000B4C	ADDQ.L	#1,A1
	ADDQ.W	#2,$18(A0)
	BRA.L	lbC000A12

lbC000B56
	tst.b	TypePlay
	beq.w	lbC000A46

	MOVE.B	#$20,$1F(A0)
	MOVE.B	(A1)+,$2C(A0)
	ADDQ.W	#2,$18(A0)
	BRA.L	lbC000A12

lbC000B68	MOVE.B	D0,$26(A0)
	ADDQ.W	#1,$18(A0)
lbC000B70	TST.B	$24(A0)
	BEQ.S	lbC000B7E
	SUBQ.B	#1,$24(A0)
	BRA.L	lbC000BE8

lbC000B7E	SUBQ.B	#1,$22(A0)
	BNE.L	lbC000BE8
	MOVE.B	$23(A0),$22(A0)
	MOVEA.L	4(A0),A1
	ADDA.W	$16(A0),A1
lbC000B94	MOVEQ	#0,D1
	MOVE.B	(A1)+,D0
	MOVE.B	D0,D1
	SUBI.W	#$E0,D1
	BMI.S	lbC000BE0
	ADD.W	D1,D1
	MOVE.W	lbW000BAA(PC,D1.W),D1
	JMP	lbC000BBC(PC,D1.W)

lbW000BAA	dc.w	lbC000BBC1-lbC000BBC	;e0 a few diff
	dc.w	lbC000BCE-lbC000BBC		;e1 diff now OK ?
	dc.w	lbC000BBC-lbC000BBC
	dc.w	lbC000BBC-lbC000BBC
	dc.w	lbC000BBC-lbC000BBC
	dc.w	lbC000BBC-lbC000BBC
	dc.w	lbC000BBC-lbC000BBC
	dc.w	lbC000BBC-lbC000BBC
	dc.w	lbC000BD6-lbC000BBC		;e8 OK

lbC000BBC
	rts

lbC000BBC1	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1

	tst.b	TypePlay
	bne.b	NoAndy
	and.w	#$3F,D1
NoAndy
	SUBQ.W	#5,D1
	MOVE.W	D1,$16(A0)
	MOVEA.L	4(A0),A1
	ADDA.W	D1,A1
	BRA.S	lbC000B94

lbC000BCE
	tst.b	TypePlay
	beq.b	lbC000BE8

	MOVE.B	-2(A1),$2F(A0)
	BRA.S	lbC000BE8

lbC000BD6	ADDQ.W	#2,$16(A0)
	MOVE.B	(A1),$24(A0)
	BRA.w	lbC000B70

lbC000BE0	MOVE.B	D0,$2F(A0)
	ADDQ.W	#1,$16(A0)
lbC000BE8	MOVE.B	$26(A0),D0
	BMI.S	lbC000BF6
	ADD.B	$1E(A0),D0
	ADD.B	$21(A0),D0
lbC000BF6	ANDI.W	#$7F,D0
	LEA	lbW000F70(PC),A1
	ADD.W	D0,D0
	MOVE.W	D0,D1
	MOVE.W	0(A1,D0.W),D0
	MOVE.B	$2E(A0),D3
	MOVE.B	$32(A0),D2
	BNE.S	lbC000C18
	BCLR	D3,(A4)
	ADDQ.W	#3,D3
	BCLR	D3,(A4)
	BRA.S	lbC000C46

lbC000C18	CMP.B	#1,D2
	BNE.S	lbC000C40
	BSET	D3,(A4)
	ADDQ.W	#3,D3
	BCLR	D3,(A4)
	MOVE.B	$1E(A0),$2D(A0)
	MOVE.B	$26(A0),D4
	BPL.S	lbC000C3A
	ANDI.B	#$7F,D4
	MOVE.B	D4,$2D(A0)
	BRA.S	lbC000C46

lbC000C3A	ADD.B	D4,$2D(A0)
	BRA.S	lbC000C46

lbC000C40	BCLR	D3,(A4)
	ADDQ.W	#3,D3
	BSET	D3,(A4)
lbC000C46	TST.B	$2D(A0)
	BEQ.S	lbC000C5A
	MOVE.B	$2D(A0),D3
	NOT.B	D3
	ANDI.B	#$1F,D3
	MOVE.B	D3,1(A4)
lbC000C5A	MOVE.B	lbB000F6F(PC),D2
	BEQ.L	lbC000D1C
	TST.B	$2A(A0)
	BEQ.S	lbC000C6E
	SUBQ.B	#1,$2A(A0)
	BRA.S	lbC000CBA

lbC000C6E	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.B	$29(A0),D1
	MOVE.B	$28(A0),D2
	MOVE.W	D2,D5
	ADD.W	D5,D5
	MOVE.B	$27(A0),D3
	MOVE.B	$2B(A0),D4
	BTST	#5,D4
	BEQ.S	lbC000C9A
	SUB.W	D3,D1
	BPL.S	lbC000CA6
	MOVEQ	#0,D1
	BCHG	#5,D4
	BRA.S	lbC000CA6

lbC000C9A	ADD.W	D3,D1
	CMP.W	D5,D1
	BLE.S	lbC000CA6
	MOVE.W	D5,D1
	BCHG	#5,D4
lbC000CA6	MOVE.B	D1,$29(A0)
	MOVE.B	D4,$2B(A0)
	SUB.W	D2,D1
	EXT.L	D1
	MULS.W	D0,D1
	ASR.L	#8,D1
	ASR.L	#2,D1
	ADD.W	D1,D0
lbC000CBA	BTST	#5,$1F(A0)
	BEQ.S	lbC000CDE
	MOVEQ	#0,D1
	MOVE.B	$2C(A0),D1
	EXT.W	D1
	EXT.L	D1
	MOVE.L	$10(A0),D2
	ADD.L	D1,D2
	MOVE.L	D2,$10(A0)
	MULS.W	D0,D2
	ASR.L	#8,D2
	ASR.W	#2,D2
	SUB.W	D2,D0
lbC000CDE

	move.w	D0,$34(A0)

	MOVE.B	$2F(A0),D1
	SUB.B	$30(A0),D1
;	SUB.W	lbW000E62(PC),D1
	SUB.B	$31(A0),D1
	BPL.S	lbC000CF2
	MOVEQ	#0,D1
lbC000CF2	MOVE.B	$33(A0),D7
	BEQ.S	lbC000D1A
	MOVE.W	D0,D2
	BTST	#1,D7
	BEQ.S	lbC000D02
	SUB.W	D0,D0
lbC000D02	BTST	#3,D7
	BEQ.S	lbC000D0E
	MOVE.W	D2,D7
	LSR.W	#3,D7
	BRA.S	lbC000D1A

lbC000D0E	BTST	#2,D7
	BNE.S	lbC000D16
	LSR.W	#1,D7
lbC000D16	MOVE.W	D2,D7
	LSR.W	#4,D7
lbC000D1A	RTS

lbC000D1C	TST.B	$2A(A0)
	BEQ.S	lbC000D2A
	SUBQ.B	#1,$2A(A0)
	BRA.L	lbC000D92

lbC000D2A	MOVE.B	D1,D5
	MOVE.B	$2B(A0),D6
	MOVE.B	$28(A0),D4
	BMI.S	lbC000D3A
	ADD.B	D4,D4
	BRA.S	lbC000D3E

lbC000D3A	ANDI.B	#$7F,D4
lbC000D3E	MOVE.B	$29(A0),D1
	TST.B	D6
	BPL.S	lbC000D4A
	BTST	D7,D6
	BNE.S	lbC000D70
lbC000D4A	BTST	#5,D6
	BNE.S	lbC000D5E
	SUB.B	$27(A0),D1
	BCC.S	lbC000D6C
	BSET	#5,D6
	MOVEQ	#0,D1
	BRA.S	lbC000D6C

lbC000D5E	ADD.B	$27(A0),D1
	CMP.B	D4,D1
	BCS.S	lbC000D6C
	BCLR	#5,D6
	MOVE.B	D4,D1
lbC000D6C	MOVE.B	D1,$29(A0)
lbC000D70	LSR.B	#1,D4
	SUB.B	D4,D1
	BCC.S	lbC000D7A
	SUBI.W	#$100,D1
lbC000D7A	ADDI.B	#$A0,D5
	BCS.S	lbC000D8A
lbC000D80	ADD.W	D1,D1
	ADDI.B	#$18,D5
	BCC.L	lbC000D80
lbC000D8A	ADD.W	D1,D0
	BCHG	D7,D6
	MOVE.B	D6,$2B(A0)
lbC000D92	BTST	#5,$1F(A0)
	BEQ.S	lbC000DB4
	MOVEQ	#0,D1
	MOVE.B	$2C(A0),D1
	EXT.W	D1
	SWAP	D1
	ASR.L	#4,D1
	MOVE.L	$10(A0),D2
	ADD.L	D1,D2
	MOVE.L	D2,$10(A0)
	SWAP	D2
	SUB.W	D2,D0
lbC000DB4

	move.w	D0,$34(A0)

	MOVE.B	$2F(A0),D1
	SUB.B	$30(A0),D1
;	SUB.W	lbW000E62(PC),D1
	SUB.B	$31(A0),D1
	BPL.S	lbC000DC8
	MOVEQ	#0,D1
lbC000DC8	RTS

InitSamp
;lbC000DCA	LEA	lbL001070,A0
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

lbW000E1A	dc.w	$100
	dc.w	0
	dc.w	0
	dc.w	$E1
lbW000E22	dc.w	1
	dc.w	$200
lbL000E26
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
;	dc.l	0
;	dc.l	$2062200
;	dc.l	$A0E2600
;	dc.l	$12162A00
;lbW000E62	dc.w	0
lbL000E64	dc.w	0
;	dc.w	0
;	dc.l	0
lbW000E6C	dc.w	4
lbW000E6E	dc.w	4
lbW000E70	dc.w	$FF00
lbL000E72	dc.l	0
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

SID1
	ds.b	4

lbL000EA6	dc.l	0
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

SID2
	ds.b	4

lbL000EDA	dc.l	0
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

SID3
	ds.b	4

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
;	dc.w	$40
lbW000F44	dc.w	0
lbL000F46	dc.l	0
lbL000F4A	dc.l	0
lbL000F4E	dc.l	0
lbL000F52	dc.l	0
;	dc.w	0
;lbW000F58	dc.w	0
lbL000F5A	dc.l	0
	dc.l	0
;	dc.l	0
lbL000F66	dc.l	0
lbL000F6A	dc.l	0
	dc.b	0
lbB000F6F	dc.b	0
lbW000F70	dc.w	$EEE
	dc.w	$E17
	dc.w	$D4D
	dc.w	$C8E
	dc.w	$BD9
	dc.w	$B2F
	dc.w	$A8E
	dc.w	$9F7
	dc.w	$967
	dc.w	$8E0
	dc.w	$861
	dc.w	$7E8
	dc.w	$777
	dc.w	$70B
	dc.w	$6A6
	dc.w	$647
	dc.w	$5EC
	dc.w	$597
	dc.w	$547
	dc.w	$4FB
	dc.w	$4B3
	dc.w	$470
	dc.w	$430
	dc.w	$3F4
	dc.w	$3BB
	dc.w	$385
	dc.w	$353
	dc.w	$323
	dc.w	$2F6
	dc.w	$2CB
	dc.w	$2A3
	dc.w	$27D
	dc.w	$259
	dc.w	$238
	dc.w	$218
	dc.w	$1FA
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
	dc.w	$B2
	dc.w	$A8
	dc.w	$9F
	dc.w	$96
	dc.w	$8E
	dc.w	$86
	dc.w	$7E
	dc.w	$77
	dc.w	$70
	dc.w	$6A
	dc.w	$64
	dc.w	$5E
	dc.w	$59
	dc.w	$54
	dc.w	$4F
	dc.w	$4B
	dc.w	$47
	dc.w	$43
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
	dc.w	15
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0

; Routine taken from Delitracker

Compress
	MOVEA.L	A1,A4
	MOVE.L	#'COSO',(A4)
	LEA	$20(A4),A4
	MOVE.L	(A0),(A4)+
	MOVE.L	4(A0),(A4)+
	MOVE.L	8(A0),(A4)+
	MOVE.L	12(A0),(A4)+
	MOVE.L	$10(A0),(A4)+
	MOVE.L	$14(A0),(A4)+
	MOVE.L	$18(A0),(A4)+
	MOVE.L	$1C(A0),(A4)+
	LEA	$20(A0),A2
	BSR.L	lbC0028CA
	MOVE.L	A4,D7
	SUB.L	A1,D7
	MOVE.L	D7,4(A1)
	MOVE.W	4(A0),D0
	MOVE.W	D0,D1
	ADDQ.W	#1,D0
	ADD.W	D0,D0
	MOVEA.L	A4,A3
	ADDA.W	D0,A4
lbC002786	BSR.L	lbC0028DA
	MOVEA.L	A2,A5
	BSR.L	lbC0028E4
	LEA	$40(A2),A2
	DBRA	D1,lbC002786
	BSR.L	lbC0028CA
	MOVE.L	A4,D7
	SUB.L	A1,D7
	MOVE.L	D7,8(A1)
	MOVE.W	6(A0),D1
	MOVE.W	D1,D0
	ADDQ.W	#1,D0
	ADD.W	D0,D0
	MOVEA.L	A4,A3
	ADDA.W	D0,A4
lbC0027B2	BSR.L	lbC0028DA
	MOVEA.L	A2,A5
	BSR.L	lbC0028E4
	LEA	$40(A2),A2
	DBRA	D1,lbC0027B2
	BSR.L	lbC0028CA
	MOVE.L	A4,D7
	SUB.L	A1,D7
	MOVE.L	D7,12(A1)
	MOVE.W	8(A0),D0
	MOVE.W	D0,D1
	ADDQ.W	#1,D1
	ADD.W	D1,D1
	MOVEA.L	A4,A3
	ADDA.W	D1,A4
lbC0027DE	BSR.L	lbC0028DA
	MOVEA.L	A2,A5
	BSR.L	lbC002922
	ADDA.W	12(A0),A2
	DBRA	D0,lbC0027DE
	BSR.L	lbC0028CA
	MOVE.L	A4,D7
	SUB.L	A1,D7
	MOVE.L	D7,$10(A1)
	MOVE.W	10(A0),D7
lbC002800
	MOVE.L	(A2)+,(A4)+
	MOVE.L	(A2)+,(A4)+
	MOVE.L	(A2)+,(A4)+
lbC00281E	DBRA	D7,lbC002800
	MOVE.L	A4,D7
	SUB.L	A1,D7
	MOVE.L	D7,$14(A1)
	MOVE.W	$10(A0),D7
lbC00282E
	MOVE.W	(A2)+,(A4)+
	MOVE.W	(A2)+,(A4)+
	MOVE.W	(A2)+,(A4)+
lbC002846	DBRA	D7,lbC00282E
	MOVE.L	A4,D7
	SUB.L	A1,D7
	MOVE.L	D7,$18(A1)
	MOVEA.L	A4,A3
	MOVE.W	$12(A0),D7
lbC002858	MOVE.L	A2,D2
	MOVE.W	(A2)+,(A4)+
	MOVE.W	(A2)+,(A4)+
	MOVE.W	(A2)+,(A4)+
lbC00287E	DBRA	D7,lbC002858
	MOVE.L	A4,D7
	SUB.L	A1,D7
	MOVE.L	D7,$1C(A1)
	RTS

lbC0028CA	MOVE.W	D7,-(SP)
	MOVE.W	A4,D7
	BTST	#0,D7
	BEQ.S	lbC0028D6
	CLR.B	(A4)+
lbC0028D6	MOVE.W	(SP)+,D7
	RTS

lbC0028DA	PEA	(A4)
	SUBA.L	A1,A4
	MOVE.W	A4,(A3)+
	MOVEA.L	(SP)+,A4
	RTS

lbC0028E4	PEA	(A4)
	LEA	$40(A5),A4
	MOVEQ	#$3F,D7
lbC0028EC
	CMPI.B	#$E1,-(A4)
	BEQ.S	lbC002918
	CMPI.B	#$E0,(A4)
	BEQ.S	lbC002916
	DBRA	D7,lbC0028EC
	MOVEQ	#$3F,D7
	BRA.S	lbC002918

lbC002916	ADDQ.W	#1,D7
lbC002918	MOVEA.L	(SP)+,A4
lbC00291A	MOVE.B	(A5)+,(A4)+
	DBRA	D7,lbC00291A
	RTS

lbC002922	MOVEQ	#0,D6
	MOVEQ	#-1,D7
	MOVE.W	12(A0),D5
	LSR.W	#1,D5
lbC00292C	CMPI.B	#1,(A5)
	BEQ.S	lbC00293E
	TST.B	(A5)
	BNE.S	lbC002952
	ADDQ.W	#2,A5
	ADDQ.W	#1,D6
	CMP.W	D5,D6
	BNE.S	lbC00292C
lbC00293E	TST.W	D6
	BEQ.S	lbC00294C
	SUBQ.W	#1,D6
	MOVE.W	D6,D7
	MOVE.B	#$FD,(A4)+
	MOVE.B	D6,(A4)+
lbC00294C	MOVE.B	#$FF,(A4)+
	RTS

lbC002952	TST.W	D6
	BEQ.S	lbC002962
	SUBQ.W	#1,D6
	MOVE.W	D6,D7
	MOVE.B	#$FD,(A4)+
	MOVE.B	D6,(A4)+
	ADDQ.W	#1,D6
lbC002962	MOVEQ	#0,D4
	MOVE.B	(A5),D1
	MOVE.B	1(A5),D2
	MOVE.B	D2,D3
	ANDI.B	#$E0,D3
	BNE.S	lbC002978
	LEA	lbC0029CE(PC),A6
	BRA.S	lbC00298A

lbC002978	MOVEA.L	A5,A6
	TST.W	D6
	BNE.S	lbC002982
	ADDA.W	12(A0),A6
lbC002982	MOVE.B	-1(A6),D3
	LEA	lbC0029C6(PC),A6
lbC00298A	ADDQ.W	#2,A5
	ADDQ.W	#1,D6
	ADDQ.W	#1,D4
	CMP.W	D5,D6
	BEQ.S	lbC0029B0
	CMPI.B	#1,(A5)
	BEQ.S	lbC0029B0
	TST.B	(A5)
	BEQ.S	lbC00298A
	SUBQ.W	#1,D4
	CMP.W	D7,D4
	BEQ.S	lbC0029AC
	MOVE.W	D4,D7
	MOVE.B	#$FE,(A4)+
	MOVE.B	D4,(A4)+
lbC0029AC	JSR	(A6)
	BRA.S	lbC002962

lbC0029B0	SUBQ.W	#1,D4
	CMP.W	D7,D4
	BEQ.S	lbC0029BE
	MOVE.W	D4,D7
	MOVE.B	#$FE,(A4)+
	MOVE.B	D4,(A4)+
lbC0029BE	JSR	(A6)
	MOVE.B	#$FF,(A4)+
	RTS

lbC0029C6	MOVE.B	D1,(A4)+
	MOVE.B	D2,(A4)+
	MOVE.B	D3,(A4)+
	RTS

lbC0029CE	MOVE.B	D1,(A4)+
	MOVE.B	D2,(A4)+
	RTS

;	SECTION	HippelST_note001070,DATA_C

	Section	Buffy,BSS_C

lbL001070
	ds.b	1024

;lbL001470	dc.l	0
;	dc.l	0
;lbL001478	dc.l	$B2B24D4D

lbL001478
	ds.b	4
SIDword
	ds.b	2
lbL001470
	ds.b	2

;	SECTION	HippelST_note00147C,BSS
;lbL00147C	ds.l	$10		; left1
;lbL0014BC	ds.l	$10		; left2
;lbL0014FC	ds.l	$10		; right1
;lbL00153C	ds.l	$10		; right2
