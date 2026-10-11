	******************************************************
	****        Kim Christensen replayer for	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: Kim Christensen player module V2.0 (14 June 2011)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!0
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_NextPatt,NextPattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_Save!EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt!EPB_CalcDuration
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
Origin
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
	move.w	A1,D1		;DFF0A0/B0/C0/D0
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
	move.w	A1,D1		;DFF0A0/B0/C0/D0
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
	move.w	A1,D1		;DFF0A0/B0/C0/D0
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
	move.w	A1,D1		;DFF0A0/B0/C0/D0
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
******************************** EP_Check5 ********************************
***************************************************************************

Check5
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
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

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

	bsr.w	Play_1
	bsr.w	Play_2

	move.l	EagleBase(PC),A5
	jsr	ENPP_Amplifier(A5)

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
	divu.w	#50,D0				; 50 Hz
	move.w	D0,Duration+2(A4)

	moveq	#0,D0
	rts
Short
	moveq	#EPR_ModuleTooShort,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	lbL0004D6(PC),A0
	lea	lbW000594(PC),A1
Cleo
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	Cleo
	bra.w	Init

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
;	MOVE.W	lbW000142,$DFF096		; DMA off

	move.w	lbW000142(PC),D0
	bsr.w	PokeDMA

	RTS

lbW000140	dc.w	0
lbW000142	dc.w	0

Play_2
;lbC000144	MOVEM.L	D0-D2/D7/A0/A1,-(SP)
	ORI.W	#$8000,lbW000142
;	MOVE.W	lbW000142,$DFF096		; DMA on

	move.w	lbW000142(PC),D0
	bsr.w	PokeDMA

;	MOVE.L	D7,-(SP)
;	MOVE.L	#$64,D7
;lbC000162	DBRA	D7,lbC000162
;	MOVE.L	(SP)+,D7
;	MOVE.W	lbW000142,D0
;	ASL.W	#7,D0
;	MOVE.W	D0,$DFF09C
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

	movem.l	D0/A1,-(SP)
	move.l	A0,A1
	move.l	lbL0005EA(PC),D0
	bsr.w	PokeAdr
	moveq	#2,D0
	bsr.w	PokeLen
	movem.l	(SP)+,D0/A1

	BRA.L	lbC0001BC

lbC0001B2
;	MOVE.L	6(A1),(A0)			; repeat address
;	MOVE.W	10(A1),4(A0)			; repeat length

	move.l	D0,-(SP)
	exg	A0,A1
	move.l	6(A0),D0
	bsr.w	PokeAdr
	move.w	10(A0),D0
	bsr.w	PokeLen
	exg	A0,A1
	move.l	(SP)+,D0

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
;	MOVE.L	0(A2),(A1)		; address
;	MOVE.W	4(A2),4(A1)		; length
;	MOVE.W	12(A2),8(A1)		; volume

	move.l	(A2),D0
	bsr.w	PokeAdr
	move.w	4(A2),D0
	bsr.w	PokeLen
	move.w	12(A2),D0
	bsr.w	PokeVol

	MOVE.W	14(A2),D0
	ASR.W	#4,D0
;	MOVE.W	D0,6(A1)		; period

	bsr.w	PokePer

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

	bsr.w	PokeVol

	ASR.W	#4,D1
;	MOVE.W	D1,(A2)			; period

	move.w	D1,D0
	bsr.w	PokePer

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
