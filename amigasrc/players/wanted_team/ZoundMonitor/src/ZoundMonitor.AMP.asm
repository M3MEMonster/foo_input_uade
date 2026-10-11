	******************************************************
	****          ZoundMonitor replayer for     	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: ZoundMonitor player module V2.0 (29 Sep 2014)',0
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
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Packable!EPB_Restart
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	TAG_DONE
PlayerName
	dc.b	'ZoundMonitor',0
Creator
	dc.b	"(c) 1988 by AJ of Activas,",10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'.SNG',0
SamplesPath
	dc.b	'Samples/',0
	even
ModulePtr
	dc.l	0
SampleInfoPtr
	dc.l	0
TrackPtr
	dc.l	0
StepPtr
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
	move.w	A3,D1		;DFF0A0/B0/C0/D0
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
	move.w	A3,D1		;DFF0A0/B0/C0/D0
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
	move.w	A3,D1		;DFF0A0/B0/C0/D0
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
	move.w	A3,D1		;DFF0A0/B0/C0/D0
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
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SampleInfoPtr(PC),D0
	beq.b	return
	move.l	D0,A2
	moveq	#15-1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	moveq	#0,D0
	move.w	46(A2),D0
	add.l	D0,D0
	move.l	(A2)+,EPS_Adr(A3)		; sample address
	move.l	A2,EPS_SampleName(A3)		; sample name
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#32,EPS_MaxNameLen(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	lea	$32(A2),A2
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.b	lbB0051E7(PC),D0
	rts

***************************************************************************
******************************* DTP_ExtLoad *******************************
***************************************************************************

ExtLoad
	move.l	dtg_ChkData(A5),A1
	move.l	4.W,A6
	jsr	_LVOTypeOfMem(A6)
	moveq	#1,D6
	moveq	#0,D7
	btst	#1,D0
	beq.b	NoChip
	moveq	#2,D7
NoChip
	moveq	#15,D2
	lea	9(A1),A2
LoadNextSample
	tst.b	(A2)
	beq.b	NoSamp
	move.l	A2,A3
	bsr.b	LoadFile
	bne.b	ExtError2
NoSamp
	lea	54(A2),A2
	dbf	D2,LoadNextSample
ExtError2
	rts

LoadFile
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.b	CopyName
	move.l	D7,EPG_ARG1(A5)
	move.l	D6,EPG_ARGN(A5)
	jmp	ENPP_NewLoadFile(A5)

CopyName
	movea.l	dtg_PathArrayPtr(A5),A0
loop1
	tst.b	(A0)+
	bne.s	loop1
	subq.l	#1,A0
	lea	SamplesPath(PC),A1
smp1
	move.b	(A1)+,(A0)+
	bne.s	smp1
	subq.l	#1,A0
smp2
	move.b	(A3)+,(A0)+
	bne.s	smp2
	rts

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	move.l	dtg_ChkData(A5),A0

	moveq	#0,D1
	move.b	(A0),D1
	addq.w	#1,D1
	lsl.l	#4,D1
	moveq	#0,D0
	move.b	1(A0),D0
	addq.w	#1,D0
	lsl.l	#7,D0
	add.l	D0,D1
	add.l	#869,D1
	cmp.l	dtg_ChkSize(A5),D1
	bge.b	fault
	add.l	D1,A0
	cmp.b	#'d',(A0)+
	beq.b	drive
	cmp.b	#'a',(A0)+
	bne.b	fault
	cmp.b	#'m',(A0)+
	bne.b	fault
	cmp.b	#'p',(A0)
	bne.b	fault
	bra.b	found
drive
	cmp.b	#'f',(A0)+
	bne.b	fault
	cmp.b	#':',1(A0)
	bne.b	fault
found
	moveq	#0,D0
	rts
fault
	moveq	#-1,D0
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

Steps		=	4
LoadSize	=	12
Samples		=	20
Length		=	28
SamplesSize	=	36
SongSize	=	44
CalcSize	=	52
Pattern		=	60
Duration	=	68

InfoBuffer
	dc.l	MI_Duration,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_SamplesSize,0	;36
	dc.l	MI_Songsize,0		;44
	dc.l	MI_Calcsize,0		;52
	dc.l	MI_Pattern,0		;60
	dc.l	MI_MaxLength,256
	dc.l	MI_MaxSamples,15
	dc.l	MI_MaxPattern,256
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	move.l	dtg_GetListData(A5),A0
	jsr	(A0)
	lea	ModulePtr(PC),A3
	move.l	A0,(A3)+			; module buffer
	lea	InfoBuffer(PC),A6
	move.l	D0,LoadSize(A6)

	lea	WT(PC),A4
	move.l	A0,A1
	move.l	A0,D1
	move.l	A1,(A3)+			; SampleInfoPtr
	move.b	(A0)+,D0
	move.b	D0,lbB0051E4-WT(A4)
	moveq	#0,D0
	move.b	(A0)+,D0
	move.b	D0,lbB0051E3-WT(A4)
	addq.l	#1,D0
	move.l	D0,Pattern(A6)
	move.b	(A0)+,lbB0051EA-WT(A4)
	moveq	#0,D0
	move.b	(A0)+,D0
	move.b	D0,lbB0051EB-WT(A4)
	move.l	D0,D2				; length
	addq.l	#1,D0
	move.l	D0,Length(A6)
	move.b	(A0)+,lbB004C7F-WT(A4)		; song speed
	move.w	#$36*16-1,D0
CopySI
	move.b	(A0)+,(A1)+
	dbf	D0,CopySI
	move.l	A1,(A3)+			; TrackPtr

	moveq	#0,D0
	move.b	lbB0051E4-WT(A4),D0
	addq.w	#1,D0
	lsl.l	#4,D0
	subq.w	#1,D0
CopyData
	move.b	(A0)+,(A1)+
	dbf	D0,CopyData
	move.l	A1,(A3)+			; StepPtr

	moveq	#0,D0
	move.b	lbB0051E3-WT(A4),D0
	addq.w	#1,D0
	lsl.l	#7,D0
	subq.w	#1,D0
CopyData2
	move.b	(A0)+,(A1)+
	dbf	D0,CopyData2

	sub.l	D1,A0
	lea	101(A0),A0
	move.l	A0,SongSize(A6)
	move.l	A0,CalcSize(A6)
	moveq	#0,D1
	move.b	lbB004C7F-WT(A4),D1	; song speed
	lsl.w	#5,D2			; length * 32 (rows)
	mulu.w	D1,D2			; speed*length*rows
	divu.w	#50,D2			; /50Hz
	addq.w	#1,D2
	move.w	D2,Duration+2(A6)
	move.l	SampleInfoPtr(PC),A4
	moveq	#15-1,D5		; number of samples
	moveq	#1,D6			; file number
	moveq	#0,D2
	moveq	#0,D3
	moveq	#0,D4
NextSample
	tst.b	4(A4)
	beq.b	NoSam
	move.l	D6,D0
	move.l	dtg_GetListData(A5),A0
	jsr	(A0)

	add.l	D0,D2
	moveq	#0,D0
	move.w	46(A4),D0
	add.l	D0,D3

	cmp.l	#'FORM',(A0)
	bne.b	NoIFF
	lea	100(A0),A0		; better quality fix
	move.l	(A0)+,D0
	lsr.l	#1,D0
	move.w	D0,46(A4)
NoIFF
	clr.w	(A0)			; make empty sample
	move.l	A0,(A4)
	addq.l	#1,D6
	addq.l	#1,D4
NoSam
	lea	$36(A4),A4
	dbf	D5,NextSample

	add.l	D2,LoadSize(A6)
	add.l	D3,D3
	move.l	D3,SamplesSize(A6)
	move.l	D4,Samples(A6)
	add.l	D3,CalcSize(A6)

	moveq	#0,D0
	rts

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(SP)

	bsr.w	Play

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
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	bra.w	Init

***************************************************************************
**************************** ZoundMonitor player **************************
***************************************************************************

; Player from demo "The Musical FruitBasket" (c) 1988 by Activas

;lbC001266	BTST	#5,($DFF01F)
;	BEQ.B	lbC00127C
;	MOVEM.L	D0-D7/A0-A6,-(SP)
;	BSR.W	lbC00131E
;	MOVEM.L	(SP)+,D0-D7/A0-A6
;lbC00127C	JMP	(0)
;lbL00127E	EQU	*-4

lbL001282	dc.l	0

lbC001286
;	MOVEQ	#$31,D0

	moveq	#160/4-1,D0

	LEA	(lbL00E54E-WT,A4),A0
lbC00128C	CLR.L	(A0)+
	DBRA	D0,lbC00128C
	MOVE.W	#1,(lbW00E554-WT,A4)
	MOVE.W	#2,(lbW00E57C-WT,A4)
	MOVE.W	#4,(lbW00E5A4-WT,A4)
	MOVE.W	#8,(lbW00E5CC-WT,A4)
;	CLR.W	($DFF0A8)
;	CLR.W	($DFF0B8)
;	CLR.W	($DFF0C8)
;	CLR.W	($DFF0D8)
	CLR.B	(lbB0051E6-WT,A4)
	MOVE.B	(lbB0051E8-WT,A4),(lbB0051E7-WT,A4)
	MOVE.B	(lbB004C7F-WT,A4),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,(lbB0051E5-WT,A4)
	LEA	(lbL001282,PC),A0
	MOVE.L	A4,(A0)
;	MOVE.W	#$4000,($DFF09A)
;	LEA	(lbL00127E,PC),A0
;	MOVE.L	($6C).W,(A0)
;	MOVE.L	#lbC001266,($6C).W
;	MOVE.W	#$C000,($DFF09A)
	RTS

;lbC0012FE	MOVE.W	#$4000,($DFF09A)
;	MOVE.L	(lbL00127E,PC),($6C).W
;	MOVE.W	#$C000,($DFF09A)
;	MOVE.W	#15,($DFF096)
;	RTS

Play
lbC00131E	MOVEA.L	(lbL001282,PC),A4
	ADDQ.B	#1,(lbB0051E5-WT,A4)
	MOVE.B	(lbB0051E5-WT,A4),D1
	CMP.B	(lbB004C7F-WT,A4),D1
	BEQ.W	lbC001434
	TST.W	(lbW00E54C-WT,A4)
	BEQ.B	lbC00134A
	MOVE.W	(lbW00E54C-WT,A4),D0
	OR.W	#$8200,D0
;	MOVE.W	D0,($DFF096)			; DMA on

	bsr.w	PokeDMA

	CLR.W	(lbW00E54C-WT,A4)
lbC00134A	MOVEA.L	#$DFF0A0,A3
;	MOVEQ	#$18,D0
;lbC001352	DBRA	D0,lbC001352
	MOVEQ	#3,D5
	LEA	(lbL00E54E-WT,A4),A2
	MOVEQ	#1,D1
lbC00135E	MOVE.W	(lbW004C80-WT,A4),D2
	AND.W	D1,D2
	BEQ.B	lbC00136C
	MOVE.L	D1,-(SP)
	BSR.B	lbC001380
	MOVE.L	(SP)+,D1
lbC00136C	ADDA.L	#$28,A2
	ADDA.L	#$10,A3
	ASL.L	#1,D1
	DBRA	D5,lbC00135E
	RTS

lbC001380	BTST	#0,($15,A2)
	BEQ.B	lbC0013E4
	BTST	#1,($15,A2)
	BNE.B	lbC0013C0
	ADDQ.W	#1,($1E,A2)
	BTST	#0,($1F,A2)
	BNE.w	lbC0013FC
	MOVE.W	($1E,A2),D1
	ASR.L	#1,D1
	DIVU.W	#3,D1
	SWAP	D1
	CLR.L	D2
	MOVE.B	($16,A2,D1.W),D2
	ADD.B	($14,A2),D2
	ASL.L	#1,D2
	LEA	(lbW004C34-WT,A4),A0
;	MOVE.W	(A0,D2.L),(6,A3)		; period

	move.l	D0,-(SP)
	move.w	(A0,D2.L),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	BRA.B	lbC0013FC

lbC0013C0	MOVE.W	($1E,A2),D0
	CMP.W	($22,A2),D0
	BEQ.B	lbC0013FC
	ADDQ.W	#1,D0
	MOVE.W	D0,($1E,A2)
	MOVE.W	($20,A2),D2
	MULS.W	D0,D2
	DIVS.W	($22,A2),D2
	ADD.W	(4,A2),D2
;	MOVE.W	D2,(6,A3)			; period

	move.l	D0,-(SP)
	move.w	D2,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	BRA.B	lbC0013FC

lbC0013E4	BTST	#1,($15,A2)
	BEQ.B	lbC0013FC
	MOVE.W	(2,A2),D1
	ADD.W	(4,A2),D1
	MOVE.W	D1,(4,A2)
;	MOVE.W	D1,(6,A3)			; period

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

lbC0013FC
;	MOVE.L	($10,A2),(A3)			; address
;	MOVE.W	(10,A2),(4,A3)			; length

	move.l	D0,-(SP)
	move.l	$10(A2),D0
	bsr.w	PokeAdr
	move.w	10(A2),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	RTS

lbC001408	CLR.L	D0
	MOVE.W	($1A,A2),D0
	MOVE.L	D4,D1
	LSR.W	#8,D1
	EXT.W	D1
	ADD.W	D1,D0
	MOVE.B	(1,A5),D1
	EXT.W	D1
	ADD.W	D1,D0
	CMP.W	#$40,D0
	BCS.B	lbC001430
	TST.W	D0
	BMI.B	lbC00142E
	MOVE.W	#$40,D0
	BRA.B	lbC001430

lbC00142E	CLR.W	D0
lbC001430	MOVE.W	D0,(A2)
	RTS

lbC001434	CLR.B	(lbB0051E5-WT,A4)
	MOVEQ	#3,D5
	LEA	(lbL00E54E-WT,A4),A2
	MOVEA.L	#$DFF0A0,A3
;	LEA	(lbL0051EC-WT,A4),A5

	move.l	TrackPtr(PC),A5

	CLR.L	D0
	MOVE.B	(lbB0051E7-WT,A4),D0
	ASL.L	#4,D0
	ADDA.L	D0,A5
	MOVEQ	#1,D1
lbC001454	MOVE.L	D1,-(SP)
	MOVE.W	(lbW004C80-WT,A4),D2
	AND.W	D1,D2
	BEQ.W	lbC001604
	BTST	#0,($1D,A2)
	BEQ.B	lbC001476
	BCLR	#0,($1D,A2)
	BSR.W	lbC001380
	BRA.W	lbC001604

lbC001476	CLR.L	D0
	MOVE.B	(A5),D0
	ASL.L	#7,D0
	CLR.L	D1
	MOVE.B	(lbB0051E6-WT,A4),D1
	ASL.L	#2,D1
	ADD.L	D1,D0
;	LEA	(lbL00654C-WT,A4),A1

	move.l	StepPtr(PC),A1

	MOVE.L	(A1,D0.L),D4
	MOVE.L	(4,A1,D0.L),D7
	MOVE.L	D4,D0
	MOVEQ	#$18,D1
	ASR.L	D1,D0
	AND.B	#$3F,D0
	BNE.B	lbC0014A6
	BSR.W	lbC001380
	BRA.W	lbC001604

lbC0014A6	MOVE.B	D0,($14,A2)
	MOVE.L	D4,D0
	AND.L	#$F0000,D0
	MOVEQ	#$10,D1
	ASR.L	D1,D0
	MOVE.B	D0,($15,A2)
	BTST	#2,($15,A2)
	BNE.B	lbC0014CA
	MOVE.B	(3,A5),D0
	ADD.B	D0,($14,A2)
lbC0014CA	CLR.W	D0
	MOVE.B	($14,A2),D0
	ASL.W	#1,D0
	LEA	(lbW004C34-WT,A4),A0
	MOVE.W	(A0,D0.W),(4,A2)
	BTST	#0,($15,A2)
	BEQ.B	lbC001548
	BTST	#1,($15,A2)
	BNE.B	lbC001504
	MOVE.L	D4,D0
	LSR.B	#4,D0
	MOVE.B	D0,($17,A2)
	MOVE.L	D4,D0
	AND.B	#15,D0
	MOVE.B	D0,($18,A2)
	CLR.W	($1E,A2)
	BRA.B	lbC00155C

lbC001504	BSET	#0,($1D,A2)
	MOVEQ	#$18,D0
	MOVE.L	D7,D1
	ASR.L	D0,D1
	BTST	#$12,D7
	BNE.B	lbC00151A
	ADD.B	(3,A5),D1
lbC00151A	AND.W	#$3F,D1
	ASL.W	#1,D1
	LEA	(lbW004C34-WT,A4),A0
	MOVE.W	(A0,D1.W),D0
	SUB.W	(4,A2),D0
	MOVE.W	D0,($20,A2)
	CLR.W	($1E,A2)
	MOVE.W	D4,D0
	AND.W	#$FF,D0
	CLR.W	D1
	MOVE.B	(lbB004C7F-WT,A4),D1
	MULU.W	D1,D0
	MOVE.W	D0,($22,A2)
	BRA.B	lbC00155C

lbC001548	BTST	#1,($15,A2)
	BEQ.B	lbC00155C
	MOVE.L	D4,D0
	AND.W	#$FF,D0
	EXT.W	D0
	MOVE.W	D0,(2,A2)
lbC00155C	MOVE.L	D4,D0
	AND.L	#$F00000,D0
	MOVE.W	#$14,D1
	ASR.L	D1,D0
	BEQ.B	lbC00157A
	BTST	#3,($15,A2)
	BNE.B	lbC001578
	ADD.B	(2,A5),D0
lbC001578	BNE.B	lbC001580
lbC00157A	BSR.W	lbC001408
	BRA.B	lbC0015C4

lbC001580	CMP.B	($25,A2),D0
	BEQ.B	lbC00157A
	MOVE.B	D0,($25,A2)
	SUBQ.L	#1,D0
	MULU.W	#$36,D0
;	LEA	(lbL0061EC-WT,A4),A6

	move.l	SampleInfoPtr(PC),A6

	ADDA.L	D0,A6
	MOVE.B	($2C,A6),D0
	EXT.W	D0
	MOVE.W	D0,($1A,A2)
	BSR.W	lbC001408
	MOVE.L	(A6),(12,A2)			; sample address
	MOVE.W	($2E,A6),(8,A2)
	MOVE.W	($30,A6),(10,A2)
	CLR.L	D0
	MOVE.W	($32,A6),D0
	ASL.L	#1,D0
	ADD.L	(12,A2),D0
	MOVE.L	D0,($10,A2)
lbC0015C4	BTST	#$1F,D4
	BEQ.B	lbC0015D8
	MOVE.B	($25,A2),D0
	CMP.B	($24,A2),D0
	BEQ.B	lbC0015FA
	MOVE.B	D0,($24,A2)
lbC0015D8
;	MOVE.W	(6,A2),($DFF096)	; DMA

	move.l	D0,-(SP)
	move.w	6(A2),D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	CMPI.B	#$3F,($14,A2)
	BEQ.B	lbC001604
	MOVE.W	(6,A2),D0
	OR.W	D0,(lbW00E54C-WT,A4)
;	MOVE.L	(12,A2),(A3)			; address
;	MOVE.W	(8,A2),(4,A3)			; length

	move.l	D0,-(SP)
	move.l	12(A2),D0
	bsr.w	PokeAdr
	move.w	8(A2),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

lbC0015FA
;	MOVE.W	(4,A2),(6,A3)			; period
;	MOVE.W	(A2),(8,A3)			; volume

	move.l	D0,-(SP)
	move.w	4(A2),D0
	bsr.w	PokePer
	move.w	(A2),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

lbC001604	MOVE.L	(SP)+,D1
	ADDA.L	#$28,A2
	ADDA.L	#$10,A3
	ADDQ.L	#4,A5
	ASL.L	#1,D1
	DBRA	D5,lbC001454
	ADDQ.B	#1,(lbB0051E6-WT,A4)
	CMPI.B	#$20,(lbB0051E6-WT,A4)
	BNE.B	lbC00163E
	CLR.B	(lbB0051E6-WT,A4)
	ADDQ.B	#1,(lbB0051E7-WT,A4)
	MOVE.B	(lbB0051E7-WT,A4),D1
	CMP.B	(lbB0051E9-WT,A4),D1
	BNE.B	lbC00163E
	MOVE.B	(lbB0051E8-WT,A4),(lbB0051E7-WT,A4)

	bsr.w	SongEnd

lbC00163E	RTS

Init
	lea	WT(PC),A4
	clr.w	lbW00E54C-WT(A4)

;lbC001640	LINK.W	A5,#0
;	MOVEM.L	D4/D5,-(SP)
;	MOVE.B	(11,A5),D4
;	MOVE.B	(15,A5),D5
;	TST.B	D4
;	BNE.B	lbC001658
;	TST.B	D5
;	BEQ.B	lbC001662
;lbC001658	MOVE.B	D4,(lbB0051E8-WT,A4)
;	MOVE.B	D5,(lbB0051E9-WT,A4)
;	BRA.B	lbC00166E

lbC001662	MOVE.B	(lbB0051EA-WT,A4),(lbB0051E8-WT,A4)
	MOVE.B	(lbB0051EB-WT,A4),(lbB0051E9-WT,A4)
;lbC00166E	TST.L	($10,A5)
;	BEQ.B	lbC00167A
;	MOVE.B	($13,A5),(lbB004C7F-WT,A4)
lbC00167A	JSR	(lbC001286,PC)
;	MOVEM.L	(SP)+,D4/D5
;	UNLK	A5
	RTS

WT

lbW004C34	dc.w	0
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
	dc.b	2
lbB004C7F	dc.b	6
lbW004C80	dc.w	15

lbB0051E2	ds.b	1
lbB0051E3	ds.b	1
lbB0051E4	ds.b	1
lbB0051E5	ds.b	1
lbB0051E6	ds.b	1
lbB0051E7	ds.b	1
lbB0051E8	ds.b	1
lbB0051E9	ds.b	1
lbB0051EA	ds.b	1
lbB0051EB	ds.b	1
;lbL0051EC	ds.l	$400
;lbL0061EC	ds.l	1
;lbL0061F0	ds.l	10
;	ds.w	1
;lbL00621A	ds.l	$CC
;	ds.w	1
;lbL00654C	ds.l	$197E
;	ds.w	1

lbW00E54C	ds.w	1
lbL00E54E	ds.l	1
	ds.w	1
lbW00E554	ds.w	$14
lbW00E57C	ds.w	$14
lbW00E5A4	ds.w	$14
lbW00E5CC	ds.b	34
