	*****************************************************
	****   Kim Christensen replayer for EaglePlayer  ****
	****         all adaptions by Wanted Team,	 ****
	****      DeliTracker (?) compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include "misc/eagleplayer2.01.i"

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Kim Christensen player module V1.0 (14 June 2011)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_NextPatt,NextPattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_Flags,EPB_Save!EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt!EPB_CalcDuration
	dc.l	DTP_Duration,CalcDuration
	dc.l	TAG_DONE

PlayerName
	dc.b	'Kim Christensen',0
Creator
	dc.b	'(c) 1989 by Kim Christensen,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'KIM.',0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
Origin
	dc.l	0
Interrupts
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
******************************* DTP_Duration ******************************
***************************************************************************

CalcDuration
	move.l	Interrupts(PC),D0
	mulu.w	dtg_Timer(A5),D0
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

NextPattern
	move.b	lbB000590(PC),D0
	cmp.b	InfoBuffer+Length+3(PC),D0
	beq.b	MaxPos
	addq.b	#1,lbB000590
	clr.b	lbB000591
MaxPos
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	move.b	lbB000590(PC),D0
	beq.b	MinPos
	subq.b	#1,D0
	move.b	D0,lbB000590
	clr.b	lbB000591
MinPos
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.b	lbB000590(PC),D0
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
	move.w	D0,8(A1)
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

*-------------------------------- Set All -------------------------------*

SetAll
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
	move.l	(A2),(A0)
	move.w	4(A2),UPS_Voice1Len(A0)
	move.w	D0,UPS_Voice1Per(A0)
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
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	lbL001D82(PC),D0
	beq.b	return

	move.l	D0,A2
	move.l	Origin(PC),D2
	move.l	ModulePtr(PC),D3

	move.l	InfoBuffer+Samples(PC),D5
	subq.l	#1,D5
Next
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2)+,D0
	sub.l	D2,D0
	add.l	D3,D0
	move.l	D0,EPS_Adr(A3)			; sample address
	moveq	#0,D0
	move.w	(A2)+,D0
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	dbf	D5,Next

	moveq	#0,D7
return
	move.l	D7,D0
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
	moveq	#-1,D0

	move.l	dtg_ChkSize(A5),D2
	sub.l	#1800,D2
	bmi.b	Fault
	moveq	#100-1,D2
Find
	cmp.w	#$207C,(A0)+
	beq.b	OK
	dbf	D2,Find
Fault
	rts
OK
	move.w	#800-1,D2
OK1
	cmp.w	#$0680,(A0)+
	beq.b	OK2
	dbf	D2,OK1
	bra.b	Fault
OK2
	cmp.w	#$E341,(A0)+
	beq.b	OK3
	dbf	D2,OK2
	bra.b	Fault
OK3
	cmp.w	#$227C,(A0)+
	beq.b	OK4
	dbf	D2,OK3
	bra.b	Fault
OK4
	cmp.w	#$0680,(A0)+
	beq.b	OK5
	dbf	D2,OK4
	bra.b	Fault
OK5
	cmp.w	#$0087,(A0)+
	beq.b	OK6
	dbf	D2,OK5
	bra.b	Fault
OK6
	moveq	#0,D0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

LoadSize	=	4
CalcSize	=	12
SamplesSize	=	20
SongSize	=	28
Length		=	36
Samples		=	44
Duration	=	52

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Calcsize,0		;12
	dc.l	MI_SamplesSize,0	;20
	dc.l	MI_Songsize,0		;28
	dc.l	MI_Length,0		;36
	dc.l	MI_Samples,0		;44
	dc.l	MI_Duration,0		;52
	dc.l	MI_Prefix,Prefix
	dc.l	MI_AuthorName,PlayerName
	dc.l	0

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

	bsr.w	Play_1
	bsr.b	DMAWait
	bsr.w	Play_2

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D1-A6
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
Find1
	cmp.w	#$207C,(A1)+
	bne.b	Find1
	move.l	(A1)+,D0		; 0602
Find2
	cmp.w	#$0680,(A1)+
	bne.b	Find2
	move.l	(A1)+,D1		; 065A
Find3
	cmp.w	#$E341,(A1)+
	bne.b	Find3
	move.l	-6(A1),D7		; 0594
Find4
	cmp.w	#$227C,(A1)+
	bne.b	Find4
	move.l	(A1)+,D2		; 1C02
Find5
	cmp.w	#$0680,(A1)+
	bne.b	Find5
	move.l	(A1)+,D3		; 1D82

FindPer
	cmp.w	#$0087,(A1)+		; 0594
	bne.b	FindPer
	subq.l	#4,A1
	sub.l	A0,A1
	sub.l	A1,D7
	move.l	D7,(A6)				; origin
	move.l	D3,D5
	sub.l	D7,D0
	sub.l	D7,D1
	sub.l	D7,D2
	sub.l	D7,D3
	add.l	A0,D0
	add.l	A0,D1
	add.l	A0,D2
	add.l	A0,D3

	lea	lbL000602(PC),A1
	movem.l	D0-D3,(A1)
	move.l	D0,A2
	move.l	-4(A2),D4
	bne.b	NoTit
	move.l	#$02000077,D4
NoTit
	move.l	D4,-(A1)
	move.b	D4,Length+3(A4)
	subq.l	#8,A2
	move.l	A2,-(A1)

	move.l	D3,A1
	move.l	(A1),D3
	beq.b	Short
	bmi.b	Short
	move.l	D3,D2
	sub.l	D5,D3
	divu.w	#6,D3
	move.l	D3,Samples(A4)
	subq.w	#1,D3
	moveq	#0,D0
NextInfo
	move.l	(A1),D1
	cmp.l	D1,D0
	bgt.b	NoMax
	moveq	#0,D0
	move.w	4(A1),D0
	add.l	D1,D0
NoMax
	addq.l	#6,A1
	dbf	D3,NextInfo
	sub.l	D2,D0
	move.l	D0,SamplesSize(A4)
	sub.l	D7,D2
	move.l	D2,SongSize(A4)
	add.l	D2,D0
	move.l	D0,CalcSize(A4)
	cmp.l	LoadSize(A4),D0
	bgt.b	Short

	moveq	#1,D0
	add.b	lbW0005FE(PC),D0		; song speed
	moveq	#1,D1
	add.b	lbB000601(PC),D1		; song length
	mulu.w	D1,D0
	lsl.l	#4,D0				; * 16 (number of rows)
	lea	Interrupts(PC),A0
	move.l	D0,(A0)				; Interrupts

	divu.w	#50,D0				; 50 Hz
	move.w	D0,Duration+2(A4)

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
	lea	lbL0004D6(PC),A0
	lea	lbW000594(PC),A1
Cleo
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	Cleo
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
*************************** Kim Christensen player ************************
***************************************************************************

; Player from game "Rotor" (Bios music) (c) 1989 by Arcana

;	MOVE.L	#lbC000144,$80
;	MOVE.L	#lbC00001A,$84
;	MOVEQ	#-1,D0
;	TRAP	#1
;	RTS

Init
;lbC00001A	MOVEM.L	D0-D7/A0-A6,-(SP)
;	TST.B	D0
;	BEQ.L	lbC000044
;	MOVE.W	#15,$DFF096
	MOVE.B	lbB000600,lbB000590
	MOVE.B	#0,lbB000591
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTE

	rts

Play_1
lbC000044	JSR	lbC000072
	JSR	lbC00038C
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;	RTE

	rts

lbC000056	MOVE.B	lbB000590,D0
	CMP.B	lbB000601,D0
	BLS.L	lbC000070
	MOVE.B	lbB000600,lbB000590

	bsr.w	SongEnd

lbC000070	RTS

lbC000072	SUBQ.B	#1,lbW000140
	BMI.L	lbC0000B4
	RTS

lbC00007E
;	MOVEA.L	#lbL000602,A0

	move.l	lbL000602(PC),A0

	MOVEQ	#0,D0
	MOVE.B	lbB000590,D0
	ADDA.L	D0,A0
lbC00008E	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	CMPI.B	#$FF,D0
	BNE.L	lbC0000A6
	ADDQ.L	#1,A0
	ADDQ.B	#1,lbB000590
	BRA.L	lbC00008E

lbC0000A6	MULU.W	#$84,D0
;	ADDI.L	#lbL00065A,D0

	add.l	lbL00065A(PC),D0

	MOVEA.L	D0,A0
	RTS

lbC0000B4	MOVE.W	#0,lbW00058E
	MOVE.W	#0,lbW000142
	BSR.L	lbC00007E
	MOVE.B	lbW0005FE,lbW000140
	ADDQ.L	#4,A0
	MOVEQ	#0,D0
	MOVE.B	lbB000591,D0
	ASL.W	#1,D0
	ADDA.L	D0,A0
	ADDQ.B	#1,lbB000591
	CMPI.B	#$10,lbB000591
	BNE.L	lbC000104
	ADDQ.B	#1,lbB000590
	MOVE.B	#0,lbB000591
	BSR.L	lbC000056
lbC000104	MOVE.W	#0,lbW000346
	MOVE.L	#3,D7
lbC000112	TST.B	(A0)
	BEQ.L	lbC000124
	JSR	lbC0001FC
	JSR	lbC000348
lbC000124	ADDA.L	#$20,A0
	ADDQ.W	#1,lbW00058E
	DBRA	D7,lbC000112
	MOVE.W	lbW000142,$DFF096		; DMA off
	RTS

lbW000140	dc.w	0
lbW000142	dc.w	0

Play_2
;lbC000144	MOVEM.L	D0-D2/D7/A0/A1,-(SP)
	ORI.W	#$8000,lbW000142
	MOVE.W	lbW000142,$DFF096		; DMA on
;	MOVE.L	D7,-(SP)
;	MOVE.L	#$64,D7
;lbC000162	DBRA	D7,lbC000162
;	MOVE.L	(SP)+,D7
;	MOVE.W	lbW000142,D0
;	ASL.W	#7,D0
;	MOVE.W	D0,$DFF09C

	bsr.w	DMAWait

	MOVEQ	#0,D0
	MOVE.W	lbW000346,D1
	MOVE.W	lbW000142,D2
	MOVE.L	#3,D7
	MOVEA.L	#$DFF0A0,A0
	MOVEA.L	#lbL0004D6,A1
lbC000196	BTST	D0,D2
	BEQ.L	lbC0001BC
	BTST	D0,D1
	BNE.L	lbC0001B2
;	MOVE.L	#lbL0005EA,(A0)			; repeat address
;	MOVE.W	#10,4(A0)			; repeat length

	move.l	lbL0005EA(PC),(A0)
	move.w	#2,4(A0)

	BRA.L	lbC0001BC

lbC0001B2	MOVE.L	6(A1),(A0)		; repeat address
	MOVE.W	10(A1),4(A0)			; repeat length
lbC0001BC	ADDQ.B	#1,D0
	ADDA.L	#$10,A0
	ADDA.L	#$10,A1
	DBRA	D7,lbC000196
;	MOVEM.L	(SP)+,D0-D2/D7/A0/A1
;	RTE

	rts

lbC0001D4	MOVEM.L	D1/A1,-(SP)
	MOVE.L	D0,D1
	MOVEQ	#0,D0
	MOVEA.L	#lbW000594,A1
	ASL.W	#1,D1
	MOVE.W	0(A1,D1.L),D0
	MOVEM.L	(SP)+,D1/A1
	RTS

lbC0001EE	TST.W	D1
	BEQ.L	lbC0001F8
	DIVS.W	D1,D0
	RTS

lbC0001F8	MOVEQ	#0,D0
	RTS

lbC0001FC	MOVEQ	#0,D0
	MOVE.W	lbW00058E,D0
	MOVE.L	#1,D1
	ASL.W	D0,D1
	MOVE.W	D1,lbW000592
	MOVEA.L	#lbL0004D6,A2
	MOVEQ	#0,D0
	MOVE.W	lbW00058E,D0
	ASL.W	#4,D0
	ADDA.L	D0,A2
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	BSR.L	lbC0001D4
	ASL.W	#4,D0
	MOVE.W	D0,14(A2)
;	MOVEA.L	#lbL001C02,A1

	move.l	lbL001C02(PC),A1

	MOVEQ	#0,D0
	MOVE.B	1(A0),D0
	MULU.W	#$20,D0
	ADDA.L	D0,A1
	MOVEQ	#0,D0
	MOVE.B	$13(A1),D0
	MULU.W	#6,D0
;	ADDI.L	#lbL001D82,D0

	add.l	lbL001D82(PC),D0

	MOVEA.L	D0,A3
	MOVE.W	lbW000592,D0
	TST.B	$12(A1)
	BEQ.L	lbC00026A
	OR.W	D0,lbW000346
lbC00026A
;	MOVE.L	(A3),(A2)
;	MOVE.L	(A3),6(A2)

	move.l	(A3),D0
	sub.l	Origin(PC),D0
	add.l	ModulePtr(PC),D0
	move.l	D0,(A2)
	move.l	D0,6(A2)

	MOVE.L	$14(A1),D0
	ADD.L	D0,(A2)
	MOVE.L	$1A(A1),D0
	ADD.L	D0,6(A2)
	MOVE.W	$18(A1),4(A2)
	MOVE.W	$1E(A1),10(A2)
	MOVE.W	#0,12(A2)
	MOVEA.L	#lbL000516,A2
	MOVEQ	#0,D0
	MOVE.W	lbW00058E,D0
	MULU.W	#$1E,D0
	ADDA.L	D0,A2
	MOVE.L	#3,D2
	MOVEQ	#0,D3
lbC0002AC	MOVE.B	1(A1),(A2)
	MOVEQ	#0,D0
	MOVE.B	(A1),D0
	MOVE.L	D0,D4
	SUB.L	D3,D0
	MOVE.L	D4,D3
	ASL.L	#8,D0
	MOVEQ	#0,D1
	MOVE.B	1(A1),D1
	BSR.L	lbC0001EE
	MOVE.W	D0,2(A2)
	ADDQ.L	#2,A1
	ADDQ.L	#4,A2
	DBRA	D2,lbC0002AC
	MOVE.L	#1,D2
	MOVEQ	#0,D5
	MOVE.B	(A0),D5
lbC0002DC	MOVE.B	(A1),(A2)
	MOVE.B	1(A1),1(A2)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	D5,D0
	BSR.L	lbC0001D4
	MOVE.L	D0,D3
	MOVEQ	#0,D0
	MOVE.B	D5,D0
	MOVE.B	2(A1),D1
	SUBI.B	#$18,D1
	ADD.B	D1,D0
	MOVE.L	D0,D5
	BSR.L	lbC0001D4
	MOVE.L	D0,D4
	SUB.L	D3,D4
	MOVE.L	D4,D0
	ASL.L	#4,D0
	MOVEQ	#0,D1
	MOVE.B	1(A1),D1
	BSR.L	lbC0001EE
	MOVE.W	D0,2(A2)
	ADDQ.L	#3,A1
	ADDQ.L	#4,A2
	DBRA	D2,lbC0002DC
	MOVE.B	(A1),(A2)
	MOVEQ	#0,D0
	MOVE.B	1(A1),D0
	MOVE.L	D0,D1
	ASR.W	#1,D0
	MOVE.B	D0,2(A2)
	MOVE.B	D1,3(A2)
	MOVEQ	#0,D0
	MOVE.B	2(A1),D0
	SUBI.W	#$63,D0
	MOVE.W	D0,4(A2)
	RTS

lbW000346	dc.w	0

lbC000348	MOVEA.L	#lbL0004D6,A2
	MOVEQ	#0,D0
	MOVE.W	lbW00058E,D0
	ASL.W	#4,D0
	ADDA.L	D0,A2
	ADDI.L	#$DFF0A0,D0
	MOVEA.L	D0,A1
	MOVE.L	0(A2),(A1)		; address
	MOVE.W	4(A2),4(A1)		; length
;	MOVE.W	12(A2),8(A1)		; volume

	move.w	12(A2),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol

	MOVE.W	14(A2),D0
	ASR.W	#4,D0
	MOVE.W	D0,6(A1)		; period

	bsr.w	SetAll

	MOVEQ	#0,D0
	MOVE.W	lbW000592,D0
	OR.W	D0,lbW000142
	RTS

lbC00038C	MOVEA.L	#lbL000516,A0
	MOVEA.L	#lbL0004D6,A1
	MOVE.L	#3,D7
lbC00039E	JSR	lbC000484
	ADDA.L	#$10,A0
	JSR	lbC00043A
	ADDA.L	#8,A0
	JSR	lbC000406
	ADDA.L	#6,A0
	ADDA.L	#$10,A1
	DBRA	D7,lbC00039E
	MOVEA.L	#lbL0004D6,A0
;	MOVEA.L	#$DFF0A6,A2

	lea	$DFF0A0,A1

	MOVE.L	#3,D7
lbC0003DE	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	12(A0),D0
	MOVE.W	14(A0),D1
	ASR.W	#8,D0
;	MOVE.W	D0,2(A2)		; volume

	bsr.w	ChangeVolume
	bsr.w	SetVol

	ASR.W	#4,D1
;	MOVE.W	D1,(A2)			; period

	move.w	D1,6(A1)

	ADDA.L	#$10,A0
;	ADDA.L	#$10,A2

	lea	$10(A1),A1

	DBRA	D7,lbC0003DE
	RTS

lbC000406	MOVE.W	14(A1),D0
	TST.B	(A0)
	BEQ.L	lbC000416
	SUBQ.B	#1,(A0)
	BRA.L	lbC000434

lbC000416	TST.B	2(A0)
	BEQ.L	lbC00042A
	SUBQ.B	#1,2(A0)
	ADD.W	4(A0),D0
	BRA.L	lbC000434

lbC00042A	MOVE.B	3(A0),2(A0)
	NEG.W	4(A0)
lbC000434	MOVE.W	D0,14(A1)
	RTS

lbC00043A	MOVE.W	14(A1),D0
	TST.B	(A0)
	BEQ.L	lbC00044A
	SUBQ.B	#1,(A0)
	BRA.L	lbC00047E

lbC00044A	TST.B	1(A0)
	BEQ.L	lbC00045E
	SUBQ.B	#1,1(A0)
	ADD.W	2(A0),D0
	BRA.L	lbC00047E

lbC00045E	TST.B	4(A0)
	BEQ.L	lbC00046E
	SUBQ.B	#1,4(A0)
	BRA.L	lbC00047E

lbC00046E	TST.B	5(A0)
	BEQ.L	lbC00047E
	SUBQ.B	#1,5(A0)
	ADD.W	6(A0),D0
lbC00047E	MOVE.W	D0,14(A1)
	RTS

lbC000484	MOVE.W	12(A1),D0
	TST.B	(A0)
	BEQ.L	lbC000498
	SUBQ.B	#1,(A0)
	ADD.W	2(A0),D0
	BRA.L	lbC0004D0

lbC000498	TST.B	4(A0)
	BEQ.L	lbC0004AC
	SUBQ.B	#1,4(A0)
	ADD.W	6(A0),D0
	BRA.L	lbC0004D0

lbC0004AC	TST.B	8(A0)
	BEQ.L	lbC0004C0
	SUBQ.B	#1,8(A0)
	ADD.W	10(A0),D0
	BRA.L	lbC0004D0

lbC0004C0	TST.B	12(A0)
	BEQ.L	lbC0004D0
	SUBQ.B	#1,12(A0)
	ADD.W	14(A0),D0
lbC0004D0	MOVE.W	D0,12(A1)
	RTS

lbL0004D6	dc.l	0
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
lbL000516	dc.l	0
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
lbW00058E	dc.w	0
lbB000590	dc.b	0
lbB000591	dc.b	0
lbW000592	dc.w	0
lbW000594	dc.w	0
	dc.w	$87
	dc.w	$8F
	dc.w	$97
	dc.w	$A0
	dc.w	$AA
	dc.w	$B4
	dc.w	$BE
	dc.w	$CA
	dc.w	$D6
	dc.w	$E2
	dc.w	$F0
	dc.w	$FE
	dc.w	$10D
	dc.w	$11D
	dc.w	$12E
	dc.w	$140
	dc.w	$153
	dc.w	$168
	dc.w	$17D
	dc.w	$194
	dc.w	$1AC
	dc.w	$1C5
	dc.w	$1E0
	dc.w	$1FC
	dc.w	$21A
	dc.w	$23A
	dc.w	$25C
	dc.w	$280
	dc.w	$2A8
	dc.w	$2D0
	dc.w	$30E
	dc.w	$328
	dc.w	$358
	dc.w	$38A
	dc.w	$3C0
	dc.w	$3F8
	dc.w	$434
	dc.w	$474
	dc.w	$4B8
	dc.w	$500
	dc.w	$550
	dc.w	$5A0

lbL0005EA	dc.l	0		; empty sample
lbW0005FE	dc.w	0		; song speed
lbB000600	dc.b	0		; repeat position
lbB000601	dc.b	0		; song length
lbL000602	dc.l	0		; song position
lbL00065A	dc.l	0		; patterns
lbL001C02	dc.l	0		; something
lbL001D82	dc.l	0		; samples info
