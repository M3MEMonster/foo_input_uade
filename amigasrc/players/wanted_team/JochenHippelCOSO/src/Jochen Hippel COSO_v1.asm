	*****************************************************
	**** Jochen Hippel COSO replayer for EaglePlayer ****
	****         all adaptions by Wanted Team,	 ****
	****      DeliTracker (?) compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include "misc/eagleplayer2.01.i"

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Jochen Hippel COSO player module V1.0 (7 Nov 2006)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
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
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_NextSong!EPB_PrevSong!EPB_Packable!EPB_Restart
	dc.l	TAG_DONE

PlayerName
	dc.b	'Jochen Hippel COSO',0
Creator
	dc.b	'(c) 1990-91 Jochen ''Mad Max'' Hippel,',10
	dc.b	'adapted by Wanted Team',0
Mad
	dc.b	"Jochen 'Mad Max' Hippel",0
Prefix
	dc.b	'SOC.',0
SampleName
	dc.b	'SMP.set',0
SMP
	dc.b	'SMP.',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
TwoFiles
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
	move.l	lbL000C70(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	InfoBuffer+Samples(PC),D5
	beq.b	return
	subq.l	#1,D5
	move.l	lbL000C78(PC),A1
Normal
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2)+,D0
	lea	(A1,D0.L),A0
	moveq	#0,D1
	move.w	(A2)+,D1
	add.l	D1,D1
	move.l	A0,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)

	addq.l	#4,A2
	dbf	D5,Normal

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	move.l	TwoFiles(PC),D1
	bne.b	ExtLoadOK
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
	jmp	(A0)

ExtLoadOK
	moveq	#0,D0
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
	cmpi.b	#'O',1(A3)
	beq.b	O_OK
	cmpi.b	#'o',1(A3)
	bne.s	ExtError
O_OK
	cmpi.b	#'C',2(A3)
	beq.b	C_OK
	cmpi.b	#'c',2(A3)
	bne.s	ExtError
C_OK
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
	moveq	#0,D0
	move.w	lbL000A98+$3A(PC),D0
	divu.w	#12,D0
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
	move.l	(A0),D1
	cmp.w	#$F0A0,D1
	beq.s	Left1
	cmp.w	#$F0B0,D1
	beq.s	Right1
	cmp.w	#$F0C0,D1
	beq.s	Right2
	cmp.w	#$F0D0,D1
	bne.s	Exit
Left2
	mulu.w	LeftVolume(PC),D2
	and.w	Voice4(PC),D2
	bra.s	Ex
Left1
	mulu.w	LeftVolume(PC),D2
	and.w	Voice1(PC),D2
	bra.s	Ex

Right1
	mulu.w	RightVolume(PC),D2
	and.w	Voice2(PC),D2
	bra.s	Ex
Right2
	mulu.w	RightVolume(PC),D2
	and.w	Voice3(PC),D2
Ex
	lsr.w	#6,D2
Exit
	move.l	(A7)+,D1
	rts

*-------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A1,-(SP)
	lea	StructAdr+UPS_Voice1Vol(PC),A1
	cmp.l	#$DFF0A0,(A0)
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A1
	cmp.l	#$DFF0B0,(A0)
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A1
	cmp.l	#$DFF0C0,(A0)
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A1
.SetVoice
	move.w	D2,(A1)
	move.l	(SP)+,A1
	rts

*-------------------------------- Set All -------------------------------*

SetAll
	move.l	A1,-(SP)
	lea	StructAdr+UPS_Voice1Adr(PC),A1
	cmp.l	#$DFF0A0,A3
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A1
	cmp.l	#$DFF0B0,A3
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A1
	cmp.l	#$DFF0C0,A3
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A1
.SetVoice
	move.l	A2,(A1)
	move.w	4(A4),UPS_Voice1Len(A1)
	move.w	$2E(A0),UPS_Voice1Per(A1)
	move.l	(SP)+,A1
	rts

*-------------------------------- Set All -------------------------------*

SetAll2
	move.l	A2,-(SP)
	lea	StructAdr+UPS_Voice1Adr(PC),A2
	cmp.l	#$DFF0A0,(A0)
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A2
	cmp.l	#$DFF0B0,(A0)
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A2
	cmp.l	#$DFF0C0,(A0)
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A2
.SetVoice
	move.l	A1,(A2)
	move.w	D2,UPS_Voice1Len(A2)
	move.w	$2E(A0),UPS_Voice1Per(A2)
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
	cmp.l	#'COSO',(A0)
	bne.b	Fault
	cmp.l	#'TFMX',32(A0)
	bne.b	Fault
	tst.w	48(A0)				; FX check
	beq.b	Fault
	tst.w	64(A0)
	beq.b	Fault				; longword type check
	move.l	dtg_ChkSize(A5),D2
	move.l	28(A0),D1
	beq.b	Fault
	sub.l	D1,D2
	bmi.b	Fault

; extra check routine taken from Jochen Hippel ST player

	BSR.S	lbC000284
	CMP.L	D6,D7
	BLT.S	lbC00029E
Fault
	moveq	#-1,D0
	rts

lbC000284	MOVEA.L	A0,A2
	ADDA.L	4(A0),A2
	MOVEQ	#0,D6
	MOVEQ	#0,D7
	MOVE.W	$24(A0),D0
lbC000292	MOVEA.W	(A2)+,A1
	ADDA.L	A0,A1
	BSR.S	lbC0002B6
	DBRA	D0,lbC000292
	RTS

lbC00029E	MOVE.L	$10(A0),D0
	LEA	0(A0,D0.W),A1
	CMPI.B	#$FF,3(A1)
	beq.b	Fault
	lea	TwoFiles(PC),A1
	move.l	D2,(A1)
	moveq	#0,D0			; found
	rts

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

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
LoadSize	=	12
CalcSize	=	20
Pattern		=	28
Length		=	36
SamplesSize	=	44
SongSize	=	52
Samples		=	60

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Calcsize,0		;20
	dc.l	MI_Pattern,0		;28
	dc.l	MI_Length,0		;36
	dc.l	MI_SamplesSize,0	;44
	dc.l	MI_Songsize,0		;52
	dc.l	MI_Samples,0		;60
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
	move.l	A5,(A6)				; EagleBase
	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)

	bsr.w	InitPlay

	move.l	28(A0),D7
	move.l	D7,SongSize(A4)
	cmp.l	#$1646,28(A0)			; Australian Pioneers ongame fix
	bne.b	NoFix
	cmp.l	#$00FF00FF,5580(A0)
	bne.b	NoFix
	clr.l	5580(A0)
NoFix
	move.w	48(A0),SubSongs+2(A4)
	moveq	#1,D1
	add.w	40(A0),D1
	move.l	D1,Pattern(A4)
	move.w	50(A0),D1
	move.w	D1,Samples+2(A4)
	mulu.w	#10,D1
	add.l	24(A0),A0
	add.w	D1,A0

	moveq	#0,D0
	move.w	-6(A0),D0
	add.l	D0,D0
	add.l	-10(A0),D0
	move.l	D0,SamplesSize(A4)
	add.l	D0,D7
	move.l	D7,CalcSize(A4)

	move.l	TwoFiles(PC),D1
	bne.b	NoExt

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	lbL000C78(PC),A1
	move.l	A0,(A1)
	add.l	D0,LoadSize(A4)
NoExt
	cmp.l	LoadSize(A4),D7
	bgt.b	Short

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

	move.l	lbL000C80(PC),A0
	moveq	#0,D0
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
	bra.w	InitSong

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
************************* Jochen Hippel COSO player ***********************
***************************************************************************

; Player from game Amberstar (c) 1991 by Thalion

;	BRA.L	lbC00002E

;	BRA.L	lbC0000D8

;	BRA.L	lbC000022

;	dc.b	'MUSIC BY JOCHEN HIPPEL'

;lbC000022	PEA	(A0)
;	LEA	lbW000C8A(PC),A0		; master volume
;	MOVE.W	D0,(A0)
;	MOVEA.L	(SP)+,A0
;	RTS

;lbC00002E	MOVEM.L	D0-D7/A0-A6,-(SP)
;	LEA	lbL000C78(PC),A2
;	MOVE.L	A1,(A2)
;	MOVE.W	D0,-(SP)
;	BSR.L	lbC000072
;	MOVE.W	(SP)+,D0
;	BNE.L	lbC00004C
;	LEA	lbW000A8E(PC),A6
;	ST	(A6)
;	BRA.S	lbC00006C

InitSong
lbC00004C	MOVEA.L	lbL000C80(PC),A1
	SUBQ.L	#1,D0
	ADD.W	D0,D0
	MOVE.W	D0,D1
	ADD.W	D0,D0
	ADD.W	D1,D0
	ADDA.W	D0,A1
	MOVE.W	(A1)+,D0
	MOVE.W	(A1)+,D1
	LEA	lbW000A8A(PC),A6
	MOVE.W	(A1),(A6)+
	MOVE.W	(A1)+,(A6)+
	BSR.L	lbC000442
;lbC00006C	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

InitPlay
lbC000072	LEA	lbW000C88(PC),A1
;	BSET	#1,$BFE001
	LEA	lbL000C84(PC),A2
	MOVE.L	A0,(A2)
	MOVEA.L	4(A0),A1
	ADDA.L	A0,A1
	LEA	lbL000C5C(PC),A2
	MOVE.L	A1,(A2)
	MOVEA.L	8(A0),A1
	ADDA.L	A0,A1
	LEA	lbL000C64(PC),A2
	MOVE.L	A1,(A2)
	MOVEA.L	12(A0),A1
	ADDA.L	A0,A1
	LEA	lbL000C58(PC),A2
	MOVE.L	A1,(A2)
	MOVEA.L	$10(A0),A1
	ADDA.L	A0,A1
	LEA	lbL000C6C(PC),A2
	MOVE.L	A1,(A2)
	MOVEA.L	$14(A0),A1
	ADDA.L	A0,A1
	LEA	lbL000C80(PC),A2
	MOVE.L	A1,(A2)
	LEA	lbL000C70(PC),A2
	MOVEA.L	$18(A0),A1
	ADDA.L	A0,A1
	MOVE.L	A1,(A2)
	LEA	lbL000C78(PC),A2
	MOVEA.L	$1C(A0),A1
	ADDA.L	A0,A1

	move.l	A1,(A2)

	RTS

Play
;lbC0000D8	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVEQ	#0,D7
	MOVE.W	lbW000A8E(PC),D0
	BEQ.S	lbC00010A
	MOVE.W	#15,$DFF096
	MOVE.L	D7,$DFF0A6
	MOVE.L	D7,$DFF0B6
	MOVE.L	D7,$DFF0C6
	MOVE.L	D7,$DFF0D6
;	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC00010A	LEA	$DFF000,A6
	LEA	lbL000A92(PC),A5
	MOVE.W	D7,(A5)
	LEA	lbL000A98(PC),A0
	BSR.L	lbC000552
	MOVE.L	D0,-(SP)
	LEA	lbL000AEE(PC),A0
	BSR.L	lbC000552
	MOVE.L	D0,-(SP)
	LEA	lbL000B44(PC),A0
	BSR.L	lbC000552
	MOVE.L	D0,-(SP)
;	MOVE.W	lbW000C8C(PC),D1
;	BNE.S	lbC000146
	LEA	lbL000B9A(PC),A0
	BSR.L	lbC000552
;	BRA.L	lbC000206

;lbC000146	MOVE.L	lbL000C70(PC),-(SP)
;	MOVE.L	lbL000C78(PC),-(SP)
;	MOVE.L	lbL000C5C(PC),-(SP)
;	MOVE.L	lbL000C64(PC),-(SP)
;	LEA	lbL000C74(PC),A0
;	LEA	lbL000C7C(PC),A1
;	LEA	lbL000C60(PC),A2
;	LEA	lbL000C68(PC),A3
;	MOVE.L	(A0),-(A0)
;	MOVE.L	(A1),-(A1)
;	MOVE.L	(A2),-(A2)
;	MOVE.L	(A3),-(A3)
;	LEA	lbL000BF0(PC),A0
;	BSR.L	lbC000552
;	MOVEA.W	$38(A0),A1
;	ADDA.L	$10(A0),A1
;	CMPI.B	#$E1,(A1)
;	BNE.S	lbC0001EE
;	LEA	lbW000C8C(PC),A0
;	CLR.W	(A0)
;	LEA	lbL000B9A(PC),A0
;	LEA	lbL000A6C(PC),A1
;	MOVE.L	A1,$10(A0)
;	MOVE.L	A1,$14(A0)
;	MOVE.B	#1,$44(A0)
;	MOVE.B	#1,$45(A0)
;	SF	$46(A0)
;	MOVE.W	D7,$38(A0)
;	SF	$47(A0)
;	SF	$48(A0)
;	SF	$49(A0)
;	SF	$32(A0)
;	MOVE.B	D7,$40(A0)
;	SF	$4A(A0)
;	SF	$4B(A0)
;	MOVE.B	#$64,$51(A0)
;	ST	$4C(A0)
;	SF	$4D(A0)
;	SF	$4F(A0)
;	MOVE.W	D7,$36(A0)
;	MOVE.W	D7,$1C(A0)
;	MOVE.W	#1,$34(A0)
;	MOVE.L	A1,12(A0)
;lbC0001EE	LEA	lbL000C64(PC),A0
;	LEA	lbL000C5C(PC),A1
;	LEA	lbL000C78(PC),A2
;	LEA	lbL000C70(PC),A3
;	MOVE.L	(SP)+,(A0)
;	MOVE.L	(SP)+,(A1)
;	MOVE.L	(SP)+,(A2)
;	MOVE.L	(SP)+,(A3)
lbC000206	MOVE.L	D0,-(SP)
	MOVE.W	(A5),D7
	BEQ.L	lbC00027C
	ORI.W	#$8000,D7
	MOVEA.L	lbL000AA4(PC),A0
	MOVE.W	lbL000ACC(PC),D0
	MOVEA.L	lbL000AFA(PC),A1
	MOVE.W	lbL000B22(PC),D1
	MOVEA.L	lbL000B50(PC),A2
	MOVE.W	lbL000B78(PC),D2
;	MOVE.W	lbW000C8C(PC),D3
;	BNE.S	lbC00023A
	MOVEA.L	lbL000BA6(PC),A3
	MOVE.W	lbL000BCE(PC),D3
;	BRA.S	lbC000242

	bsr.w	DMAWait

;lbC00023A	MOVEA.L	lbL000BFC(PC),A3
;	MOVE.W	lbL000C24(PC),D3
lbC000242	MOVE.W	D7,$96(A6)
;	BSR.L	lbC0002C0

	bsr.w	DMAWait

	MOVE.L	(SP)+,$D6(A6)
	MOVE.L	(SP)+,$C6(A6)
	MOVE.L	(SP)+,$B6(A6)
	MOVE.L	(SP)+,$A6(A6)
	MOVE.L	A0,$A0(A6)
	MOVE.W	D0,$A4(A6)
	MOVE.L	A1,$B0(A6)
	MOVE.W	D1,$B4(A6)
	MOVE.L	A2,$C0(A6)
	MOVE.W	D2,$C4(A6)
	MOVE.L	A3,$D0(A6)
	MOVE.W	D3,$D4(A6)
	BRA.S	lbC00028C

lbC00027C	MOVE.L	(SP)+,$D6(A6)
	MOVE.L	(SP)+,$C6(A6)
	MOVE.L	(SP)+,$B6(A6)
	MOVE.L	(SP)+,$A6(A6)
lbC00028C	LEA	lbW000A8A(PC),A0
	SUBQ.W	#1,(A0)+
	BNE.S	lbC0002BA
	MOVE.W	(A0),-(A0)
	MOVEQ	#0,D5
	MOVEQ	#6,D6
	LEA	lbL000A98(PC),A0
	BSR.L	lbC0002D0
	LEA	lbL000AEE(PC),A0
	BSR.L	lbC0002D0
	LEA	lbL000B44(PC),A0
	BSR.L	lbC0002D0
	LEA	lbL000B9A(PC),A0
	BSR.L	lbC0002D0
lbC0002BA
;	MOVEM.L	(SP)+,D0-D7/A0-A6
lbC0002BE	RTS

;lbC0002C0	MOVE.W	D0,-(SP)
;	MOVE.B	6(A6),D0
;lbC0002C6	CMP.B	6(A6),D0
;	BEQ.S	lbC0002C6
;	MOVE.W	(SP)+,D0
;	RTS

lbC0002D0	SUBQ.B	#1,$3C(A0)
	BPL.S	lbC0002BE
	MOVE.B	$3D(A0),$3C(A0)
lbC0002DC	MOVEA.L	$18(A0),A1
lbC0002E0	MOVE.B	(A1)+,D0
	CMP.B	#$FF,D0
	BNE.L	lbC000380
	MOVEA.L	8(A0),A3
	MOVEA.L	4(A0),A2
	ADDA.W	$3A(A0),A2
	CMPA.L	A3,A2
	BNE.S	lbC000302

	cmp.l	#$DFF0A0,(A0)
	bne.b	NoEnd
	bsr.w	SongEnd
NoEnd

	MOVE.W	D5,$3A(A0)
	MOVEA.L	4(A0),A2
lbC000302	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	(A2)+,D1
	MOVE.B	(A2)+,$4E(A0)
	MOVE.B	(A2),D2
	CMP.W	#$7F,D2
	BLE.S	lbC000360
	MOVE.B	D2,D3
	LSR.W	#4,D3
	ANDI.W	#15,D3
	ANDI.W	#15,D2
	CMP.B	#15,D3
	BNE.S	lbC000340
	MOVEQ	#$64,D3
	TST.W	D2
	BEQ.S	lbC00033A
	MOVEQ	#15,D3
	SUB.W	D2,D3
	ADDQ.W	#1,D3
	ADD.W	D3,D3
	MOVE.W	D3,D2
	ADD.W	D3,D3
	ADD.W	D2,D3
lbC00033A	MOVE.B	D3,$51(A0)
	BRA.S	lbC000364

lbC000340	CMP.B	#8,D3
	BNE.S	lbC00034E

	bsr.w	SongEnd

	LEA	lbW000A8E(PC),A2
	ST	(A2)
	BRA.S	lbC000364

lbC00034E	CMP.B	#14,D3
	BNE.S	lbC00035E
	ANDI.W	#15,D2
	LEA	lbW000A8C(PC),A2
	MOVE.W	D2,(A2)
lbC00035E	BRA.S	lbC000364

lbC000360	MOVE.B	D2,$43(A0)
lbC000364	ADD.W	D1,D1
	MOVEA.L	lbL000C58(PC),A3
	ADDA.W	D1,A3
	MOVEA.W	(A3),A3
	ADDA.L	lbL000C84(PC),A3
	MOVE.L	A3,$18(A0)
	ADDI.W	#12,$3A(A0)
	BRA.L	lbC0002DC

lbC000380	CMP.B	#$FE,D0
	BNE.S	lbC000392
	MOVE.B	(A1),$3D(A0)
	MOVE.B	(A1)+,$3C(A0)
	BRA.L	lbC0002E0

lbC000392	CMP.B	#$FD,D0
	BNE.S	lbC0003A6
	MOVE.B	(A1),$3D(A0)
	MOVE.B	(A1)+,$3C(A0)
	MOVE.L	A1,$18(A0)
	RTS

lbC0003A6	MOVE.B	D0,$41(A0)
	MOVE.B	(A1)+,D1
	MOVE.B	D1,$42(A0)
	ANDI.W	#$E0,D1
	BEQ.S	lbC0003BA
	MOVE.B	(A1)+,$4B(A0)
lbC0003BA	MOVE.L	A1,$18(A0)
	MOVE.W	D5,$1C(A0)
	TST.B	D0
	BMI.L	lbC000440
	MOVE.B	$42(A0),D1
	ANDI.W	#$1F,D1
	ADD.B	$43(A0),D1
	MOVEA.L	lbL000C64(PC),A2
	ADD.W	D1,D1
	ADDA.W	D1,A2
	MOVEA.W	(A2),A2
	ADDA.L	lbL000C84(PC),A2
	MOVE.W	D5,$38(A0)
	MOVE.B	(A2),$44(A0)
	MOVE.B	(A2)+,$45(A0)
	MOVEQ	#0,D1
	MOVE.B	(A2)+,D1
	MOVE.B	(A2)+,$48(A0)
	MOVEQ	#0,D0
	MOVE.B	#$40,$50(A0)
	MOVE.B	(A2)+,D0
	MOVE.B	D0,$49(A0)
	MOVE.B	D0,$40(A0)
	MOVE.B	(A2)+,$4A(A0)
	MOVE.L	A2,$10(A0)
	MOVE.B	D5,$46(A0)
	CMP.B	#$80,D1
	BEQ.S	lbC000440
	MOVEA.L	lbL000C5C(PC),A2
	BTST	#6,$42(A0)
	BEQ.S	lbC00042A
	MOVE.B	$4B(A0),D1
lbC00042A	ADD.W	D1,D1
	ADDA.W	D1,A2
	MOVEA.W	(A2),A2
	ADDA.L	lbL000C84(PC),A2
	MOVE.L	A2,$14(A0)
	MOVE.W	D5,$36(A0)
	MOVE.B	D5,$47(A0)
lbC000440	RTS

lbC000442	MOVEQ	#0,D5
	LEA	$DFF000,A6
	MOVE.W	#15,$96(A6)
	MOVE.W	#$780,$9A(A6)
	MOVE.L	D0,D7
	MULU.W	#12,D7
	MOVE.L	D1,D6
	ADDQ.L	#1,D6
	MULU.W	#12,D6
	MOVEQ	#3,D0
	LEA	lbL000A98(PC),A0
	LEA	lbL000A6C(PC),A1
	LEA	lbW000C46(PC),A2
	LEA	lbL000A84(PC),A5
lbC000476	SF	$52(A0)
	MOVE.L	A1,$10(A0)
	MOVE.L	A1,$14(A0)
	MOVE.B	#1,$44(A0)
	MOVE.B	#1,$45(A0)
	SF	$46(A0)
	MOVE.W	D5,$38(A0)
	SF	$47(A0)
	SF	$48(A0)
	SF	$49(A0)
	SF	$32(A0)
	SF	$53(A0)
	MOVE.B	D5,$40(A0)
	SF	$4A(A0)
	SF	$4B(A0)
	MOVE.B	#$64,$51(A0)
	ST	$4C(A0)
	ST	$3C(A0)
	SF	$4D(A0)
	SF	$4F(A0)
	MOVE.W	D5,$36(A0)
	MOVE.W	D5,$1C(A0)
	MOVE.W	D5,$34(A0)
	MOVE.W	(A2)+,D1
	MOVE.W	(A2)+,D3
	DIVU.W	#3,D3
	MOVEQ	#0,D4
	BSET	D3,D4
	MOVE.W	D4,$3E(A0)
	MULU.W	#3,D3
	ANDI.L	#$FF,D3
	ANDI.L	#$FF,D1
	ADD.L	A6,D1
	MOVEA.L	D1,A4
	MOVE.L	lbL000C78(PC),(A4)+
	MOVE.W	#1,(A4)+
	MOVE.W	D5,(A4)+
	MOVE.W	D5,(A4)+
	MOVE.L	D1,0(A0)
	LEA	lbW000550(PC),A3
	MOVE.L	A3,$18(A0)
	MOVE.L	lbL000C6C(PC),4(A0)
	MOVE.L	lbL000C6C(PC),8(A0)
	ADD.L	D6,8(A0)
	ADD.L	D3,8(A0)
	ADD.L	D7,4(A0)
	ADD.L	D3,4(A0)
	MOVE.W	D5,$3A(A0)
	LEA	$56(A0),A0
	DBRA	D0,lbC000476
	LEA	lbW000A8A(PC),A0
	MOVE.W	#1,(A0)
	MOVE.W	D5,4(A0)
;	LEA	lbW000C8C(PC),A0
;	CLR.W	(A0)
	RTS

lbW000550	dc.w	$FFFF

lbC000552	TST.B	$47(A0)
	BEQ.S	lbC000560
	SUBQ.B	#1,$47(A0)
	BRA.L	lbC00084E

lbC000560	MOVEA.L	$14(A0),A1
	ADDA.W	$36(A0),A1
lbC000568	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	CMP.W	#$E0,D0
	BLT.L	lbC000846

	cmp.w	#$EA,D0				; for safety
	bgt.w	lbC000846

	SUBI.W	#$E0,D0
	ADD.W	D0,D0
	MOVE.W	lbW000582(PC,D0.W),D0
	JMP	lbC000598(PC,D0.W)

lbW000582	dc.w	lbC0005BE-lbC000598
	dc.w	lbC00084E-lbC000598
	dc.w	lbC00079C-lbC000598
	dc.w	lbC0005B0-lbC000598
	dc.w	lbC000804-lbC000598
	dc.w	lbC0006DA-lbC000598
	dc.w	lbC000770-lbC000598
	dc.w	lbC0005CE-lbC000598
	dc.w	lbC0005A6-lbC000598
	dc.w	lbC00063C-lbC000598
	dc.w	lbC000598-lbC000598

lbC000598	MOVE.B	(A1)+,$53(A0)
	SF	$54(A0)
	ADDQ.W	#2,$36(A0)
	BRA.S	lbC000568

lbC0005A6	MOVE.B	(A1)+,$47(A0)
	ADDQ.W	#2,$36(A0)
	BRA.S	lbC000552

lbC0005B0	ADDQ.W	#3,$36(A0)
	MOVE.B	(A1)+,$48(A0)
	MOVE.B	(A1)+,$49(A0)
	BRA.S	lbC000568

lbC0005BE	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$36(A0)
	MOVEA.L	$14(A0),A1
	ADDA.W	D0,A1
	BRA.S	lbC000568

lbC0005CE	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	CMP.B	$4C(A0),D1
	BEQ.S	lbC000626
	SF	$53(A0)
	MOVE.B	D1,$4C(A0)
	MOVE.W	D0,-(SP)
	MOVE.W	$3E(A0),D0
	OR.W	D0,(A5)
	MOVE.W	D0,$DFF096
	MOVE.W	(SP)+,D0
	MOVEA.L	lbL000C70(PC),A4
	MOVE.W	D1,D3
	LSL.W	#3,D1
	ADD.W	D3,D3
	ADD.W	D3,D1
	ADDA.W	D1,A4
	MOVEA.L	0(A4),A2
	ADDA.L	lbL000C78(PC),A2
	MOVEA.L	0(A0),A3

	bsr.w	SetAll

	MOVE.L	A2,(A3)+			; address
	MOVE.W	4(A4),(A3)+			; length
	MOVE.W	#4,(A3)+			; period
	MOVEQ	#0,D1
	MOVE.W	6(A4),D1
	ADDA.L	D1,A2
	MOVE.L	A2,12(A0)
	MOVE.W	8(A4),$34(A0)
lbC000626	MOVE.W	D7,$38(A0)
	MOVE.B	#1,$44(A0)
	ADDQ.W	#2,$36(A0)
	SF	$32(A0)
	BRA.L	lbC000568

lbC00063C	SF	$53(A0)
	ST	$4C(A0)
	MOVE.W	D0,-(SP)
	MOVE.W	$3E(A0),D0
	OR.W	D0,(A5)
	MOVE.W	D0,$DFF096
	MOVE.W	(SP)+,D0
	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	MOVEA.L	lbL000C70(PC),A4
	MOVE.W	D1,D3
	LSL.W	#3,D1
	ADD.W	D3,D3
	ADD.W	D3,D1
	ADDA.W	D1,A4
	MOVEA.L	0(A4),A2
	ADDA.L	lbL000C78(PC),A2
	MOVEQ	#0,D0
	MOVE.W	4(A2),D0
	MOVE.W	6(A2),D2
	LSL.W	#2,D2
	MULU.W	#$18,D0
	ADDQ.L	#8,A2
	MOVEA.L	A2,A4
	ADDA.L	D0,A2
	ADDA.W	D2,A2
	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	MULU.W	#$18,D1
	ADDA.L	D1,A4
	MOVE.L	(A4)+,D1
	MOVE.L	(A4)+,D2
	ANDI.L	#$FFFFFFFE,D1
	ANDI.L	#$FFFFFFFE,D2
	SUB.L	D1,D2
	LSR.L	#1,D2
	ADD.L	A2,D1
	MOVEA.L	0(A0),A3

	move.l	A1,-(SP)
	move.l	D1,A1
	bsr.w	SetAll2
	move.l	(SP)+,A1

	MOVE.L	D1,(A3)+			; address
	MOVE.W	D2,(A3)+			; length
	MOVE.W	#4,(A3)				; period
	MOVE.L	D1,12(A0)
	PEA	(A2)
	MOVEA.L	D1,A2
	MOVE.B	(A2)+,(A2)
	MOVEA.L	(SP)+,A2
	MOVEQ	#1,D1
	MOVE.W	D1,$34(A0)
	MOVE.W	D7,$38(A0)
	MOVE.B	#1,$44(A0)
	ADDQ.W	#3,$36(A0)
	SF	$32(A0)
	BRA.L	lbC000568

lbC0006DA	SF	$53(A0)
	MOVE.W	D0,-(SP)
	MOVE.W	$3E(A0),D0
	OR.W	D0,(A5)
	MOVE.W	D0,$DFF096
	MOVE.W	(SP)+,D0
	MOVEA.L	0(A0),A3
	MOVE.W	#4,6(A3)			; period
	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	MOVEA.L	lbL000C70(PC),A4
	MOVE.W	D1,D3
	LSL.W	#3,D1
	ADD.W	D3,D3
	ADD.W	D3,D1
	ADDA.W	D1,A4
	MOVEA.L	0(A4),A2
	MOVE.L	A2,$1E(A0)
	MOVEQ	#0,D0
	MOVE.W	4(A4),D0
	MOVE.W	D0,D1
	ADD.L	D0,D0
	ADDA.L	D0,A2
	MOVE.L	A2,$22(A0)
	MOVE.B	(A1)+,-(SP)
	MOVE.W	(SP)+,D0
	MOVE.B	(A1)+,D0
	CMP.W	#$FFFF,D0
	BNE.S	lbC000730
	MOVE.W	D1,D0
lbC000730	MOVE.W	D0,$26(A0)
	MOVE.B	(A1)+,-(SP)
	MOVE.W	(SP)+,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$2A(A0)
	MOVE.B	(A1)+,-(SP)
	MOVE.W	(SP)+,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$28(A0)
	SF	$30(A0)
	MOVE.B	(A1)+,$31(A0)
	SF	$33(A0)
	SF	$2C(A0)
	ST	$32(A0)
	MOVE.W	D7,$38(A0)
	MOVE.B	#1,$44(A0)
	ADDI.W	#9,$36(A0)
	BRA.L	lbC000568

lbC000770	MOVE.B	(A1)+,-(SP)
	MOVE.W	(SP)+,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$2A(A0)
	MOVE.B	(A1)+,-(SP)
	MOVE.W	(SP)+,D0
	MOVE.B	(A1)+,D0
	MOVE.W	D0,$28(A0)
	SF	$30(A0)
	MOVE.B	(A1)+,$31(A0)
	SF	$2C(A0)
	SF	$33(A0)
	ADDQ.W	#6,$36(A0)
	BRA.L	lbC000568

lbC00079C	SF	$53(A0)
	ST	$4C(A0)
	MOVE.W	D0,-(SP)
	MOVE.W	$3E(A0),D0
	OR.W	D0,(A5)
	MOVE.W	D0,$DFF096
	MOVE.W	(SP)+,D0
	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	MOVEA.L	lbL000C70(PC),A4
	MOVE.W	D1,D3
	LSL.W	#3,D1
	ADD.W	D3,D3
	ADD.W	D3,D1
	ADDA.W	D1,A4
	MOVEA.L	0(A4),A2
	ADDA.L	lbL000C78(PC),A2
	MOVEA.L	0(A0),A3

	bsr.w	SetAll

	MOVE.L	A2,(A3)+			; address
	MOVE.W	4(A4),(A3)+			; length
	MOVE.W	#4,(A3)				; period
	MOVEQ	#0,D1
	MOVE.W	6(A4),D1
	ADDA.L	D1,A2
	MOVE.L	A2,12(A0)
	MOVE.W	8(A4),$34(A0)
	MOVE.W	D7,$38(A0)
	MOVE.B	#1,$44(A0)
	ADDQ.W	#2,$36(A0)
	SF	$32(A0)
	BRA.L	lbC000568

lbC000804	MOVEQ	#0,D1
	MOVE.B	(A1)+,D1
	MOVEA.L	lbL000C70(PC),A4
	MOVE.W	D1,D3
	LSL.W	#3,D1
	ADD.W	D3,D3
	ADD.W	D3,D1
	ADDA.W	D1,A4
	MOVEA.L	0(A4),A2
	ADDA.L	lbL000C78(PC),A2
	MOVEA.L	0(A0),A3

	bsr.w	SetAll

	MOVE.L	A2,(A3)+			; address
	MOVEQ	#0,D1
	MOVE.W	6(A4),D1
	ADDA.L	D1,A2
	MOVE.L	A2,12(A0)
	MOVE.W	4(A4),(A3)			; length
	MOVE.W	8(A4),$34(A0)
	ADDQ.W	#2,$36(A0)
	SF	$32(A0)
	BRA.L	lbC000568

lbC000846	MOVE.B	D0,$4D(A0)
	ADDQ.W	#1,$36(A0)
lbC00084E	TST.B	$32(A0)
	BEQ.L	lbC0008D2
	TST.B	$33(A0)
	BNE.L	lbC0008D2
	SUBQ.B	#1,$30(A0)
	BPL.L	lbC0008D2
	MOVE.B	$31(A0),$30(A0)
	MOVEA.L	$1E(A0),A1
	MOVEA.L	$22(A0),A2
	MOVEQ	#0,D0
	MOVE.W	$26(A0),D0
	MOVE.W	$28(A0),D1
	MOVE.W	$2A(A0),D2
	TST.B	$2C(A0)
	BNE.S	lbC00088E
	ST	$2C(A0)
	BRA.S	lbC0008B6

lbC00088E	EXT.L	D1
	ADD.L	D1,D0
	BPL.S	lbC00089C
	ST	$33(A0)
	SUB.L	D1,D0
	BRA.S	lbC0008B6

lbC00089C	MOVEA.L	A1,A3
	MOVE.L	D0,D3
	ADD.L	D3,D3
	ADDA.L	D3,A3
	MOVEQ	#0,D3
	MOVE.W	D2,D3
	ADD.L	D3,D3
	ADDA.L	D3,A3
	CMPA.L	A2,A3
	BLE.S	lbC0008B6
	ST	$33(A0)
	SUB.L	D1,D0
lbC0008B6	MOVE.W	D0,$26(A0)
	ADDA.L	lbL000C78(PC),A1
	ADD.L	D0,D0
	ADDA.L	D0,A1
	MOVE.W	D2,$34(A0)
	MOVE.L	A1,12(A0)
	MOVEA.L	0(A0),A2

	bsr.w	SetAll2

	MOVE.L	A1,(A2)+			; address
	MOVE.W	D2,(A2)+			; length
lbC0008D2	TST.B	$46(A0)
	BEQ.S	lbC0008DE
	SUBQ.B	#1,$46(A0)
	BRA.S	lbC00093C

lbC0008DE	SUBQ.B	#1,$44(A0)
	BNE.S	lbC00093C
	MOVE.B	$45(A0),$44(A0)
lbC0008EA	MOVEA.L	$10(A0),A1
	ADDA.W	$38(A0),A1
	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	CMP.W	#$E0,D0
	BLT.S	lbC000934
	SUBI.W	#$E0,D0
	ADD.W	D0,D0
	MOVE.W	lbW00090A(PC,D0.W),D0
	JMP	lbC00091C(PC,D0.W)

lbW00090A	dc.w	lbC000926-lbC00091C
	dc.w	lbC000932-lbC00091C
	dc.w	lbC000932-lbC00091C
	dc.w	lbC000932-lbC00091C
	dc.w	lbC000932-lbC00091C
	dc.w	lbC000932-lbC00091C
	dc.w	lbC000932-lbC00091C
	dc.w	lbC000932-lbC00091C
	dc.w	lbC00091C-lbC00091C

	dc.w	FixUp-lbC00091C
	dc.w	FixUp-lbC00091C
	dc.w	FixUp-lbC00091C
	dc.w	FixUp-lbC00091C
	dc.w	FixUp-lbC00091C
	dc.w	FixUp-lbC00091C
	dc.w	FixUp-lbC00091C

FixUp
	addq.w	#2,$38(A0)
	bra.b	lbC0008EA

lbC00091C	MOVE.B	(A1),$46(A0)
	ADDQ.W	#2,$38(A0)
	BRA.S	lbC0008D2

lbC000926	MOVEQ	#0,D0
	MOVE.B	(A1),D0
	SUBQ.W	#5,D0
	MOVE.W	D0,$38(A0)
	BRA.S	lbC0008EA

lbC000932	BRA.S	lbC00093C

lbC000934	MOVE.B	D0,$4F(A0)
	ADDQ.W	#1,$38(A0)
lbC00093C	MOVE.B	$4D(A0),D0
	BMI.S	lbC00094A
	ADD.B	$41(A0),D0
	ADD.B	$4E(A0),D0
lbC00094A	ANDI.W	#$7F,D0
	LEA	lbL000C8E(PC),A1
	ADD.W	D0,D0
	MOVE.W	0(A1,D0.W),D0
	MOVEQ	#10,D2
	TST.B	$4A(A0)
	BEQ.S	lbC000966
	SUBQ.B	#1,$4A(A0)
	BRA.S	lbC0009AE

lbC000966	MOVEQ	#0,D1
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVE.B	$50(A0),D6
	MOVE.B	$49(A0),D4
	MOVE.B	$48(A0),D5
	MOVE.B	$40(A0),D1
	BTST	#5,D6
	BNE.S	lbC00098E
	SUB.W	D5,D1
	BPL.S	lbC00099A
	BSET	#5,D6
	MOVEQ	#0,D1
	BRA.S	lbC00099A

lbC00098E	ADD.W	D5,D1
	CMP.W	D4,D1
	BLE.S	lbC00099A
	BCLR	#5,D6
	MOVE.W	D4,D1
lbC00099A	MOVE.B	D1,$40(A0)
	MOVE.B	D6,$50(A0)
	LSR.W	#1,D4
	SUB.W	D4,D1
	EXT.L	D1
	MULS.W	D0,D1
	ASR.L	D2,D1
	ADD.L	D1,D0
lbC0009AE	BTST	#5,$42(A0)
	BEQ.S	lbC0009DE
	MOVEQ	#0,D1
	MOVE.B	$4B(A0),D1
	BMI.S	lbC0009CE
	ADD.W	D1,$1C(A0)
	MOVE.W	$1C(A0),D1
	MULU.W	D0,D1
	LSR.L	D2,D1
	SUB.W	D1,D0
	BRA.S	lbC0009DE

lbC0009CE	NEG.B	D1
	ADD.W	D1,$1C(A0)
	MOVE.W	$1C(A0),D1
	MULU.W	D0,D1
	LSR.L	D2,D1
	ADD.W	D1,D0
lbC0009DE	MOVE.W	D0,$2E(A0)
	TST.B	$52(A0)
	BEQ.S	lbC0009F8
	MOVEA.L	0(A0),A3
	MOVE.W	#1,6(A3)			; period
	MOVE.W	#0,10(A3)			; data
lbC0009F8	SWAP	D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	$4F(A0),D2
	LEA	lbL000BF0(PC),A1
	CMPA.L	A0,A1
	BEQ.S	lbC000A4C
	MOVE.B	$51(A0),D1
	SUB.W	lbW000C8A(PC),D1
	MOVEQ	#0,D3
	MOVE.B	$53(A0),D3
	BEQ.S	lbC000A40
	MOVEQ	#0,D4
	MOVE.B	$54(A0),D4
	BNE.S	lbC000A3C
	SF	$53(A0)
	MOVE.W	D7,-(SP)
	BSR.L	lbC000A50
	ANDI.W	#$FF,D7
	MULU.W	D7,D3
	DIVU.W	#$FF,D3
	MOVE.B	D3,$54(A0)
	MOVE.W	D3,D4
lbC000A3C	SUB.W	D4,D1
	MOVE.W	(SP)+,D7
lbC000A40	TST.W	D1
	BPL.S	lbC000A46
	MOVEQ	#0,D1
lbC000A46	MULU.W	D1,D2
	DIVU.W	#$64,D2
lbC000A4C
	bsr.w	ChangeVolume
	bsr.w	SetVol

	MOVE.W	D2,D0
	RTS

lbC000A50	PEA	(A0)
	MOVE.W	D6,-(SP)
	LEA	lbW000A90(PC),A0
	MOVE.W	(A0),D7
	ADDI.W	#$4793,D7
	MOVE.W	D7,D6
	ROR.W	#6,D7
	EOR.W	D6,D7
	MOVE.W	D7,(A0)
	MOVE.W	(SP)+,D6
	MOVEA.L	(SP)+,A0
	RTS

lbL000A6C	dc.l	$1000000
	dc.l	$E1
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000A84	dc.l	0
	dc.w	0
lbW000A8A	dc.w	0
lbW000A8C	dc.w	0
lbW000A8E	dc.w	0
lbW000A90	dc.w	0
lbL000A92	dc.l	0
	dc.w	0
lbL000A98	dc.l	0
	dc.l	0
	dc.l	0
lbL000AA4	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000ACC	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000AEE	dc.l	0
	dc.l	0
	dc.l	0
lbL000AFA	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000B22	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000B44	dc.l	0
	dc.l	0
	dc.l	0
lbL000B50	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000B78	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000B9A	dc.l	0
	dc.l	0
	dc.l	0
lbL000BA6	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000BCE	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL000BF0	dc.l	0
	dc.l	0
	dc.l	0
lbL000BFC	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL000C24	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbW000C46	dc.w	$A0
	dc.w	0
	dc.w	$B0
	dc.w	3
	dc.w	$C0
	dc.w	6
	dc.w	$D0
	dc.w	9
	dc.w	$40
lbL000C58	dc.l	0
lbL000C5C	dc.l	0
lbL000C60	dc.l	0
lbL000C64	dc.l	0
lbL000C68	dc.l	0
lbL000C6C	dc.l	0
lbL000C70	dc.l	0
lbL000C74	dc.l	0
lbL000C78	dc.l	0
lbL000C7C	dc.l	0
lbL000C80	dc.l	0
lbL000C84	dc.l	0
lbW000C88	dc.w	0
lbW000C8A	dc.w	0
;lbW000C8C	dc.w	0			; fx
lbL000C8E	dc.l	$6B00650
	dc.l	$5F405A0
	dc.l	$54C0500
	dc.l	$4B80474
	dc.l	$43403F8
	dc.l	$3C0038A
	dc.l	$3580328
	dc.l	$2FA02D0
	dc.l	$2A60280
	dc.l	$25C023A
	dc.l	$21A01FC
	dc.l	$1E001C5
	dc.l	$1AC0194
	dc.l	$17D0168
	dc.l	$1530140
	dc.l	$12E011D
	dc.l	$10D00FE
	dc.l	$F000E2
	dc.l	$D600CA
	dc.l	$BE00B4
	dc.l	$AA00A0
	dc.l	$97008F
	dc.l	$87007F
	dc.l	$780071
	dc.l	$710071
	dc.l	$710071
	dc.l	$710071
	dc.l	$710071
	dc.l	$710071
	dc.l	$710071
	dc.l	$D600CA0
	dc.l	$BE80B40
	dc.l	$A980A00
	dc.l	$97008E8
	dc.l	$86807F0
	dc.l	$7800714
