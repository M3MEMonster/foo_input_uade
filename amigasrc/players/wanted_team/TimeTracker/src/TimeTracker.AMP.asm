	******************************************************
	****           TimeTracker replayer for     	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: TimeTracker player module V2.0 (7 Mar 2014)',0
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
	dc.l	DTP_ExtLoad,ExtLoad
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Packable!EPB_Restart
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	0

PlayerName
	dc.b	'TimeTracker',0
Creator
	dc.b	'(c) 1993 by BrainWasher & FireBlade,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	"TMK.",0
	even
ModulePtr
	dc.l	0
SamplesPtr
	dc.l	0
SamplesInfo
	dc.l	0
Play2Flag
	dc.w	0

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
	move.w	A4,D1		;DFF0A0/B0/C0/D0
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
	move.w	A4,D1		;DFF0A0/B0/C0/D0
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
	move.w	A4,D1		;DFF0A0/B0/C0/D0
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
	move.w	A4,D1		;DFF0A0/B0/C0/D0
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

LED_Off
	movem.l	D0/D1/A5,-(SP)
	moveq	#1,D0
	moveq	#0,D1
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeCommand(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

LED_On
	movem.l	D0/D1/A5,-(SP)
	moveq	#1,D0
	moveq	#1,D1
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeCommand(A5)
	movem.l	(SP)+,D0/D1/A5
	rts

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq	#1,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplesInfo(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	InfoBuffer+Samples(PC),D5
	subq.l	#1,D5
	move.l	SamplesPtr(PC),A1
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	moveq	#0,D0
	move.w	(A2),D0
	add.l	D0,D0
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	add.l	D0,A1
	addq.l	#8,A2
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

LoadSize	=	4
SubSongs	=	12
Length		=	20
SamplesSize	=	28
Samples		=	36

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_SubSongs,0		;12
	dc.l	MI_Length,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Prefix,Prefix
	dc.l	0

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
	movea.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	movea.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName
	move.l	D7,EPG_ARG1(A5)
	move.l	D6,EPG_ARGN(A5)
	jmp	ENPP_NewLoadFile(A5)

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

	move.l	A3,A1
loop2
	tst.b	(A1)+
	bne.s	loop2
	subq.l	#5,A1

	cmpi.b	#'.',(A1)+
	bne.s	Prefiks

	cmpi.b	#'p',(A1)
	beq.b	p_OK
	cmpi.b	#'P',(A1)
	bne.s	Prefiks
p_OK
	cmpi.b	#'a',1(A1)
	beq.b	a_OK
	cmpi.b	#'A',1(A1)
	bne.s	Prefiks
a_OK
	cmpi.b	#'t',2(A1)
	beq.b	t_OK
	cmpi.b	#'T',2(A1)
	bne.s	Prefiks
t_OK

	move.b	#'S',(A1)+
	move.b	#'A',(A1)+
	move.b	#'M',(A1)
	bra.b	ExtOK

Prefiks
	cmpi.b	#'T',(A3)
	beq.b	T_OK
	cmpi.b	#'t',(A3)
	bne.s	ExtError
T_OK
	cmpi.b	#'M',1(A3)
	beq.b	M_OK
	cmpi.b	#'m',1(A3)
	bne.s	ExtError
M_OK
	cmpi.b	#'K',2(A3)
	beq.b	K_OK
	cmpi.b	#'k',2(A3)
	bne.s	ExtError
K_OK
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
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	move.l	(A0),D1
	tst.b	D1
	beq.b	Fault
	clr.b	D1
	cmp.l	#$544D4B00,D1
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
	move.l	A0,(A6)				; module buffer
	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	moveq	#0,D0
	move.b	3(A0),D0
	move.l	D0,SubSongs(A4)
	moveq	#127,D3
	and.b	5(A0),D3
	move.l	D3,Samples(A4)
	add.w	D0,D0
	lea	4(A0,D0.W),A2

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	add.l	D0,LoadSize(A4)
	move.l	A0,A1
	move.l	(A6)+,A0			; module buffer
	move.l	A1,(A6)+			; samples buffer
	move.l	A2,(A6)				; SamplesInfo

	moveq	#0,D2
	moveq	#0,D1
	subq.w	#1,D3
NextInfo
	move.w	(A2),D1
	add.l	D1,D2
	addq.l	#8,A2
	dbf	D3,NextInfo
	add.l	D2,D2
	move.l	D2,SamplesSize(A4)

	cmp.l	D0,D2
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	bsr.w	InitPlay			; A0/A1 input

	moveq	#0,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.b	lbW003FE4+$1E(PC),D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	clr.w	Play2Flag
	move.w	dtg_SndNum(A5),D0
	bra.w	InitSong

***************************************************************************
****************************** DTP_Interrupt ******************************
***************************************************************************

Interrupt
	movem.l	D1-D7/A0-A6,-(SP)

	bsr.w	Play_1
	move.w	Play2Flag(PC),D0
	beq.b	NoPlay
	bsr.w	Play_2
NoPlay
	move.l	EagleBase(PC),A5
	jsr	ENPP_Amplifier(A5)

	movem.l	(SP)+,D1-D7/A0-A6
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
***************************** TimeTracker player **************************
***************************************************************************

; Player from demo "We're Still Alive" (c) 1993 by Eremation

InitPlay
lbC002C78	MOVEM.L	D0-D2/A0-A6,-(SP)
	LEA	(lbW003FE4,PC),A5
;	LEA	($DFF000),A6
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.B	(3,A0),D3
	ADD.W	D3,D3
	LEA	(2,A0,D3.W),A2
	MOVE.L	A0,(6,A5)
	MOVE.B	(1,A2),D2
	BPL.B	lbC002CD6
	ANDI.B	#$7F,D2
	MOVE.B	D2,(1,A2)
	ADDQ.L	#2,A2
	SUBQ.B	#1,D2
lbC002CAE	MOVE.W	(A2)+,D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	ADDQ.L	#6,A2
	DBRA	D2,lbC002CAE
	MOVEA.L	A1,A2
	ADDA.L	D0,A2
	SUBQ.L	#2,D0
lbC002CC0	MOVE.B	-(A2),D1
	ADD.B	D1,(-1,A2)
	MOVE.B	-(A2),D1
	ADD.B	D1,(-1,A2)
	SUBQ.L	#2,D0
	BNE.B	lbC002CC0
	MOVE.B	-(A2),D1
	ADD.B	D1,(-1,A2)
lbC002CD6	MOVEA.L	A1,A2			; samples
;	MOVE.L	(lbC002CFE,PC),D0
;	ADD.W	(6,A6),D0
;	SWAP	D0
;	SUB.W	(6,A6),D0
;	MOVE.B	(3,A0),D0
;	MOVE.L	D0,(A0)+

	addq.l	#4,A0

	ADDA.W	D3,A0
	SUBQ.L	#1,A0
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	LEA	(lbL003ED8,PC),A1
	SUBQ.B	#1,D0
	MOVE.L	A0,($12,A5)
lbC002CFE	CLR.L	(A2)
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	(A0),D1
	ADD.L	D1,D1
	ADDA.L	D1,A2
	ADDQ.L	#8,A0
	DBRA	D0,lbC002CFE
	MOVEM.L	(SP)+,D0-D2/A0-A6
	RTS

InitSong
lbC002D16	MOVEM.L	D0-D2/A0-A6,-(SP)
	LEA	(lbW003FE4,PC),A5
;	LEA	($DFF000),A6
	MOVEA.L	(6,A5),A0
	MOVEQ	#0,D1
	ADDQ.L	#3,A0
	MOVE.B	(A0)+,D1
	SUBQ.B	#1,D1
	ADD.W	D1,D1
	MOVEA.L	A0,A1
	ADDA.W	D1,A0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
lbC002D3A	SUBQ.B	#1,D0
	BEQ.B	lbC002D44
	MOVE.W	(A1)+,D2
	ADD.L	D2,D1
	BRA.B	lbC002D3A

lbC002D44	ADDA.L	D1,A0
	MOVEQ	#0,D2
	MOVE.B	(A0)+,D2
	MOVE.B	D2,($26,A5)

	lea	InfoBuffer(PC),A4
	move.l	D2,Length(A4)

	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	LSL.W	#3,D0
	ADDA.W	D0,A0
	MOVE.L	A0,(14,A5)
	ADDQ.B	#1,D2
	ANDI.B	#$FE,D2
	ADDA.W	D2,A0
	MOVE.L	A0,(10,A5)
;	ORI.B	#2,($BFE001)
	MOVE.B	#6,($1C,A5)
	CLR.L	(A5)
	CLR.B	($1D,A5)
	CLR.L	($1E,A5)
	CLR.W	($22,A5)
;	MOVE.W	#15,($96,A6)
;	CLR.W	($A8,A6)
;	CLR.W	($B8,A6)
;	CLR.W	($C8,A6)
;	CLR.W	($D8,A6)
	LEA	(lbL003E20,PC),A0
	MOVEQ	#1,D0
	BSR.B	lbC002DFC
	MOVEQ	#2,D0
	BSR.B	lbC002DFC
	MOVEQ	#4,D0
	BSR.B	lbC002DFC
	MOVEQ	#8,D0
	BSR.B	lbC002DFC
;	MOVE.L	($78).W,($16,A5)
;	LEA	($BFD000),A0
;	MOVE.B	($D00,A0),D0
;	ORI.B	#$80,D0
;	MOVE.B	D0,($24,A5)
;	MOVE.B	#$7F,($D00,A0)
;	MOVE.B	#$81,($D00,A0)
;	MOVE.B	($E00,A0),($25,A5)
;	CLR.B	($400,A0)
;	MOVE.B	#2,($500,A0)
;	MOVE.B	#$88,($E00,A0)
;	MOVE.W	#$2000,($9C,A6)
;	MOVE.W	#$A000,($9A,A6)
	ST	($27,A5)
	MOVEM.L	(SP)+,D0-D2/A0-A6
	RTS

lbC002DFC	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	SWAP	D0
	MOVE.L	D0,(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.W	(A0)+
	RTS

Play_2
lbC002E18
	clr.w	Play2Flag
	movem.l	D0/A0/A4,-(SP)

;	MOVEM.L	D0/A6,-(SP)
;	LEA	($DFF000),A6
;	MOVE.W	($1E,A6),D0
;	ANDI.W	#$2000,D0
;	BEQ.B	lbC002E58
;	BTST	#0,($BFDD00)
;	BEQ.B	lbC002E5E
	MOVE.W	(lbW003FE6,PC),D0
	ORI.W	#$8000,D0
;	MOVE.W	D0,($96,A6)			; DMA on

	bsr.w	PokeDMA

;	MOVE.W	#$2000,($9C,A6)
;	LEA	(lbC002E6A,PC),A6
;	MOVE.L	A6,($78).W
;	MOVE.B	#$89,($BFDE00)
;lbC002E58	MOVEM.L	(SP)+,D0/A6
;	RTE

;lbC002E5E	MOVE.W	#$2000,($9C,A6)
;	MOVEM.L	(SP)+,D0/A6
;	RTE


;lbC002E6A	MOVEM.L	D0/A0/A6,-(SP)
;	LEA	($DFF000),A6
;	MOVE.W	($1E,A6),D0
;	ANDI.W	#$2000,D0
;	BEQ.B	lbC002EBC
;	BTST	#0,($BFDD00)
;	BEQ.B	lbC002EB4
;	MOVEQ	#10,D0
;	LEA	(lbL003E2A,PC),A0
;	MOVEA.L	(lbL003F54,PC),A6
;	MOVE.L	(A0)+,(A6)+		; address
;	MOVE.W	(A0)+,(A6)+		; length
;	LEA	($28,A0),A0
;	ADDA.W	D0,A6
;	MOVE.L	(A0)+,(A6)+		; address
;	MOVE.W	(A0)+,(A6)+		; length
;	LEA	($28,A0),A0
;	ADDA.W	D0,A6
;	MOVE.L	(A0)+,(A6)+		; address
;	MOVE.W	(A0)+,(A6)+		; length
;	LEA	($28,A0),A0
;	ADDA.W	D0,A6
;	MOVE.L	(A0)+,(A6)+		; address
;	MOVE.W	(A0),(A6)		; length

	lea	lbL003E2A(PC),A0
	move.l	lbL003F54(PC),A4
	move.l	(A0)+,D0
	bsr.w	PokeAdr
	move.w	(A0)+,D0
	bsr.w	PokeLen
	lea	$28(A0),A0
	lea	16(A4),A4

	move.l	(A0)+,D0
	bsr.w	PokeAdr
	move.w	(A0)+,D0
	bsr.w	PokeLen
	lea	$28(A0),A0
	lea	16(A4),A4

	move.l	(A0)+,D0
	bsr.w	PokeAdr
	move.w	(A0)+,D0
	bsr.w	PokeLen
	lea	$28(A0),A0
	lea	16(A4),A4

	move.l	(A0)+,D0
	bsr.w	PokeAdr
	move.w	(A0)+,D0
	bsr.w	PokeLen

;lbC002EB4	MOVE.W	#$2000,($DFF09C)
;lbC002EBC	MOVEM.L	(SP)+,D0/A0/A6
;	RTE

	movem.l	(SP)+,D0/A0/A4

	rts

;lbC002EC2
;	MOVE.L	(lbL003FFA,PC),($78).W
;	LEA	($BFDD00),A0
;	MOVE.B	#$7F,(A0)
;	MOVE.B	#$7F,($100,A0)
;	MOVE.B	(lbB004008,PC),(A0)
;	MOVE.B	(lbB004009,PC),($100,A0)
;	LEA	($DFF000),A0
;	MOVE.W	#15,($96,A0)
;	CLR.W	($A8,A0)
;	CLR.W	($B8,A0)
;	CLR.W	($C8,A0)
;	CLR.W	($D8,A0)
;	MOVE.W	#15,($96,A0)
;	BCLR	#1,($BFE001)
;	RTS

Play_1
lbC002F0E	MOVEM.L	A5/A6,-(SP)
	LEA	(lbW003FE4,PC),A5
	TST.B	($27,A5)
	BEQ.W	lbC003064
;	LEA	($DFF0A8),A0

	lea	$DFF0A0,A4

	MOVEQ	#0,D0
	MOVE.B	(lbB003E33,PC),D0
	MOVE.B	($28,A5,D0.W),D0
;	MOVE.W	D0,(A0)			; volume

	bsr.w	PokeVol
	lea	16(A4),A4

	MOVE.B	(lbB003E61,PC),D0
	MOVE.B	($28,A5,D0.W),D0
;	MOVE.W	D0,($10,A0)		; volume

	bsr.w	PokeVol
	lea	16(A4),A4

	MOVE.B	(lbB003E8F,PC),D0
	MOVE.B	($28,A5,D0.W),D0
;	MOVE.W	D0,($20,A0)		; volume

	bsr.w	PokeVol
	lea	16(A4),A4

	MOVE.B	(lbB003EBD,PC),D0
	MOVE.B	($28,A5,D0.W),D0
;	MOVE.W	D0,($30,A0)		; volume

	bsr.w	PokeVol

	MOVE.W	#$FFF,D5
	LEA	($1D,A5),A0
	ADDQ.B	#1,(A0)
	MOVE.B	(A0),D0
	CMP.B	($1C,A5),D0
	BCS.B	lbC002F74
	CLR.B	(A0)
	TST.B	($23,A5)
	BEQ.B	lbC002FAA
	BSR.B	lbC002F7A
	BRA.W	lbC00300A

lbC002F74	BSR.B	lbC002F7A
	BRA.W	lbC00305E

lbC002F7A	MOVEA.L	(lbL003F54,PC),A4
	LEA	(lbL003E20,PC),A6
	BSR.W	lbC003202
	MOVEA.L	(lbL003F58,PC),A4
	LEA	(lbL003E4E,PC),A6
	BSR.W	lbC003202
	MOVEA.L	(lbL003F5C,PC),A4
	LEA	(lbL003E7C,PC),A6
	BSR.W	lbC003202
	MOVEA.L	(lbL003F60,PC),A4
	LEA	(lbL003EAA,PC),A6
	BRA.W	lbC003202

lbC002FAA	MOVEM.L	(10,A5),A0/A2/A3
	MOVEQ	#0,D0
	MOVE.B	($1E,A5),D0
	MOVE.B	(A2,D0.W),D0
	MOVE.W	(-$80,A5,D0.W),D0
	ADD.W	(A5),D0
	MOVE.W	(A0,D0.W),D0
	ADDA.L	D0,A0
	CLR.W	(2,A5)
	MOVEA.L	(lbL003F54,PC),A4
	LEA	(lbL003E20,PC),A6
	BSR.W	lbC00306A
	MOVEA.L	(lbL003F58,PC),A4
	LEA	(lbL003E4E,PC),A6
	BSR.W	lbC00306A
	MOVEA.L	(lbL003F5C,PC),A4
	LEA	(lbL003E7C,PC),A6
	BSR.W	lbC00306A
	MOVEA.L	(lbL003F60,PC),A4
	LEA	(lbL003EAA,PC),A6
	BSR.W	lbC00306A
;	LEA	(lbC002E18,PC),A4
;	MOVE.L	A4,($78).W
;	MOVE.B	#$89,($BFDE00)

	st	Play2Flag

lbC00300A	ADDQ.W	#2,(A5)
	MOVE.B	($22,A5),D0
	BEQ.B	lbC00301A
	MOVE.B	D0,($23,A5)
	CLR.B	($22,A5)
lbC00301A	TST.B	($23,A5)
	BEQ.B	lbC003028
	SUBQ.B	#1,($23,A5)
	BEQ.B	lbC003028
	SUBQ.W	#2,(A5)
lbC003028	TST.B	($20,A5)
	BEQ.B	lbC00303A
	SF	($20,A5)
	MOVE.W	($1A,A5),(A5)
	CLR.W	($1A,A5)
lbC00303A	CMPI.W	#$80,(A5)
	BCS.B	lbC00305E
lbC003040	MOVE.W	($1A,A5),(A5)
	CLR.W	($1A,A5)
	CLR.B	($1F,A5)
	ADDQ.B	#1,($1E,A5)
	MOVE.B	($1E,A5),D1
	CMP.B	($26,A5),D1
	BCS.B	lbC00305E
	CLR.B	($1E,A5)

	bsr.w	SongEnd

lbC00305E	TST.B	($1F,A5)
	BNE.B	lbC003040
lbC003064	MOVEM.L	(SP)+,A5/A6
	RTS

lbC00306A	TST.L	(A6)
	BNE.B	lbC003074
;	MOVE.W	($10,A6),(6,A4)			; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

lbC003074	ADDQ.W	#3,D1
	MOVEQ	#0,D2
	MOVE.B	(A0)+,D4
	BPL.B	lbC0030AC
	ANDI.B	#$7F,D4
	BNE.B	lbC003088
	CLR.L	(A6)
	BRA.W	lbC003682

lbC003088	BCLR	#6,D4
	BNE.B	lbC00309E
	ADD.W	D4,D4
	EXT.W	D4
	CLR.W	(2,A6)
	MOVE.B	(A0)+,D2
	BEQ.W	lbC00314E
	BRA.B	lbC0030D2

lbC00309E	CLR.W	(A6)
	MOVE.B	D4,(2,A6)
	MOVE.B	(A0)+,(3,A6)
	BRA.W	lbC003682

lbC0030AC	MOVE.B	(A0)+,D0
	MOVE.B	D0,D2
	ANDI.B	#15,D0
	MOVE.B	D0,(2,A6)
	MOVE.B	(A0)+,(3,A6)
	LSR.B	#4,D2
	BTST	#0,D4
	BEQ.B	lbC0030C8
	ORI.B	#$10,D2
lbC0030C8	ANDI.W	#$7E,D4
	TST.B	D2
	BEQ.W	lbC00314E
lbC0030D2	MOVEQ	#0,D3
	LEA	(lbL003ED8,PC),A1
	SUBQ.W	#1,D2
	ADD.W	D2,D2
	ADD.W	D2,D2
	MOVE.W	D2,D0
	ADD.W	D0,D0
	MOVE.L	(A1,D2.W),(4,A6)
	LEA	(A3,D0.W),A1
	MOVE.W	(A1)+,(8,A6)
	MOVE.W	(8,A6),($28,A6)
	MOVE.W	(4,A1),($12,A6)
	MOVE.W	(A1)+,D3
	BEQ.B	lbC00312E
	MOVE.L	(4,A6),D2
	ADD.W	D3,D3
	ADD.L	D3,D2
	MOVE.L	D2,(10,A6)
	MOVE.L	D2,($24,A6)
	MOVE.W	(A1),D2
	MOVE.W	D2,(14,A6)
	ADD.W	(-2,A1),D2
	MOVE.W	D2,(8,A6)
	MOVEQ	#0,D2
	MOVE.B	($13,A6),D2
	MOVE.B	($28,A5,D2.W),D2
;	MOVE.W	D2,(8,A4)		; volume

	move.l	D0,-(SP)
	move.w	D2,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	BRA.B	lbC00314E

lbC00312E	MOVE.L	(4,A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,(10,A6)
	MOVE.L	D2,($24,A6)
	MOVE.W	(A1),(14,A6)
	MOVEQ	#0,D0
	MOVE.B	($13,A6),D0
	MOVE.B	($28,A5,D0.W),D0
;	MOVE.W	D0,(8,A4)		; volume

	bsr.w	PokeVol

lbC00314E	LEA	(lbL0039A0,PC),A1
	MOVE.W	(-2,A1,D4.W),(A6)
	TST.W	D4
	BEQ.W	lbC003682
	MOVE.W	(2,A6),D0
	ANDI.W	#$FF0,D0
	CMPI.W	#$E50,D0
	BEQ.B	lbC00318E
	MOVE.B	(2,A6),D0
	CMPI.B	#3,D0
	BEQ.B	lbC003186
	CMPI.B	#5,D0
	BEQ.B	lbC003186
	CMPI.B	#9,D0
	BNE.B	lbC003192
	BSR.W	lbC003682
	BRA.B	lbC003192

lbC003186	BSR.W	lbC003354
	BRA.W	lbC003682

lbC00318E	BSR.W	lbC00374A
lbC003192	MOVEQ	#0,D0
	MOVE.B	($12,A6),D0
	BEQ.B	lbC0031A0
	ADD.W	D0,D0
	ADD.W	($6A,A5,D0.W),D4
lbC0031A0	MOVE.W	(-2,A1,D4.W),($10,A6)
	MOVE.W	(2,A6),D0
	ANDI.W	#$FF0,D0
	CMPI.W	#$ED0,D0
	BEQ.W	lbC003682
	MOVE.W	($14,A6),D0
	MOVE.W	D1,-(SP)
	MOVE.W	(4,A5),D1
	NOT.W	D1
	AND.W	D1,D0
;	MOVE.W	D0,($DFF096)			; DMA off

	bsr.w	PokeDMA

	MOVE.W	(SP)+,D1
	BTST	#2,($1E,A6)
	BNE.B	lbC0031D8
	CLR.B	($1B,A6)
lbC0031D8	BTST	#6,($1E,A6)
	BNE.B	lbC0031E4
	CLR.B	($1D,A6)
lbC0031E4
;	MOVE.L	(4,A6),(A4)			; address
;	MOVE.W	(8,A6),(4,A4)			; length

	move.l	D0,-(SP)
	move.l	4(A6),D0
	bsr.w	PokeAdr
	move.w	8(A6),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	MOVE.W	($10,A6),D0
;	MOVE.W	D0,(6,A4)			; period

	bsr.w	PokePer

	MOVE.W	($14,A6),D0
	OR.W	D0,(2,A5)
	BRA.W	lbC003682

lbC003202	MOVE.B	($1F,A6),D0
	LSR.B	#4,D0
	BEQ.B	lbC00320E
	BSR.W	lbC0038C4
lbC00320E	TST.W	(2,A6)
	BEQ.B	lbC003262
	MOVEQ	#0,D0
	MOVE.B	(2,A6),D0
	ADD.B	D0,D0
	ADD.B	D0,D0
	JMP	(lbC003222,PC,D0.W)

lbC003222	BRA.W	lbC00326A

	BRA.W	lbC0032D6

	BRA.W	lbC00331C

	BRA.W	lbC0033B2

	BRA.W	lbC003440

	BRA.W	lbC0034D8

	BRA.W	lbC0034E0

	BRA.W	lbC0034E6

	BRA.W	lbC003262

	BRA.W	lbC003262

	BRA.W	lbC0035C6

	BRA.W	lbC003262

	BRA.W	lbC003262

	BRA.W	lbC003262

	BRA.W	lbC0036B8

	BRA.W	lbC003262

lbC003262
;	MOVE.W	($10,A6),(6,A4)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

lbC003268	RTS

lbC00326A	MOVEQ	#0,D0
	MOVE.B	($1D,A5),D0
	DIVS.W	#3,D0
	SWAP	D0
	TST.W	D0
	BEQ.B	lbC003296
	CMPI.W	#2,D0
	BEQ.B	lbC00328A
	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	LSR.B	#4,D0
	BRA.B	lbC00329C

lbC00328A	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	BRA.B	lbC00329C

lbC003296	MOVE.W	($10,A6),D2
	BRA.B	lbC0032C4

lbC00329C	ADD.W	D0,D0
	MOVEQ	#0,D1
	MOVE.B	($12,A6),D1
	ADD.W	D1,D1
	LEA	(lbL0039A0,PC),A0
	ADDA.W	($6A,A5,D1.W),A0
	MOVEQ	#0,D1
	MOVE.W	($10,A6),D1
	MOVEQ	#$24,D7
lbC0032B6	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0)+,D1
	BCC.B	lbC0032C4
	DBRA	D7,lbC0032B6
	RTS

lbC0032C4
;	MOVE.W	D2,(6,A4)		; period

	move.l	D0,-(SP)
	move.w	D2,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	RTS

lbC0032CA	TST.B	($1D,A5)
	BNE.B	lbC003268
	MOVE.B	#15,($21,A5)
lbC0032D6	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	AND.B	($21,A5),D0
	MOVE.B	#$FF,($21,A5)
	SUB.W	D0,($10,A6)
	MOVE.W	($10,A6),D0
	AND.W	D5,D0
	CMPI.W	#$71,D0
	BPL.B	lbC003302
	ANDI.W	#$F000,($10,A6)
	ORI.W	#$71,($10,A6)
lbC003302	MOVE.W	($10,A6),D0
	AND.W	D5,D0
;	MOVE.W	D0,(6,A4)			; period

	bsr.w	PokePer

	RTS

lbC00330E	TST.B	($1D,A5)
	BNE.W	lbC003268
	MOVE.B	#15,($21,A5)
lbC00331C	CLR.W	D0
	MOVE.B	(3,A6),D0
	AND.B	($21,A5),D0
	MOVE.B	#$FF,($21,A5)
	ADD.W	D0,($10,A6)
	MOVE.W	($10,A6),D0
	AND.W	D5,D0
	CMPI.W	#$358,D0
	BMI.B	lbC003348
	ANDI.W	#$F000,($10,A6)
	ORI.W	#$358,($10,A6)
lbC003348	MOVE.W	($10,A6),D0
	AND.W	D5,D0
;	MOVE.W	D0,(6,A4)			; period

	bsr.w	PokePer

	RTS

lbC003354	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	MOVEQ	#0,D0
	MOVE.B	($12,A6),D0
	MULU.W	#$4A,D0
	LEA	(lbL0039A0,PC),A0
	ADDA.L	D0,A0
	MOVEQ	#0,D0
lbC00336A	CMP.W	(A0,D0.W),D2
	BCC.B	lbC00337A
	ADDQ.W	#2,D0
	CMPI.W	#$4A,D0
	BCS.B	lbC00336A
	MOVEQ	#$46,D0
lbC00337A	MOVE.B	($12,A6),D2
	ANDI.B	#8,D2
	BEQ.B	lbC00338A
	TST.W	D0
	BEQ.B	lbC00338A
	SUBQ.W	#2,D0
lbC00338A	MOVE.W	(A0,D0.W),D2
	MOVEA.L	(SP)+,A0
	MOVE.W	D2,($18,A6)
	MOVE.W	($10,A6),D0
	CLR.B	($16,A6)
	CMP.W	D0,D2
	BEQ.B	lbC0033AC
	BGE.W	lbC003268
	MOVE.B	#1,($16,A6)
	RTS

lbC0033AC	CLR.W	($18,A6)
	RTS

lbC0033B2	MOVE.B	(3,A6),D0
	BEQ.B	lbC0033C0
	MOVE.B	D0,($17,A6)
	CLR.B	(3,A6)
lbC0033C0	TST.W	($18,A6)
	BEQ.W	lbC003268
	MOVEQ	#0,D0
	MOVE.B	($17,A6),D0
	TST.B	($16,A6)
	BNE.B	lbC0033EE
	ADD.W	D0,($10,A6)
	MOVE.W	($18,A6),D0
	CMP.W	($10,A6),D0
	BGT.B	lbC003406
	MOVE.W	($18,A6),($10,A6)
	CLR.W	($18,A6)
	BRA.B	lbC003406

lbC0033EE	SUB.W	D0,($10,A6)
	MOVE.W	($18,A6),D0
	CMP.W	($10,A6),D0
	BLT.B	lbC003406
	MOVE.W	($18,A6),($10,A6)
	CLR.W	($18,A6)
lbC003406	MOVE.W	($10,A6),D2
	MOVE.B	($1F,A6),D0
	ANDI.B	#15,D0
	BEQ.B	lbC00343A
	MOVEQ	#0,D0
	MOVE.B	($12,A6),D0
	ADD.W	D0,D0
	LEA	(lbL0039A0,PC),A0
	ADDA.W	($6A,A5,D0.W),A0
	MOVEQ	#0,D0
lbC003426	CMP.W	(A0,D0.W),D2
	BCC.B	lbC003436
	ADDQ.W	#2,D0
	CMPI.W	#$48,D0
	BCS.B	lbC003426
	MOVEQ	#$46,D0
lbC003436	MOVE.W	(A0,D0.W),D2
lbC00343A
;	MOVE.W	D2,(6,A4)		; period

	move.l	D0,-(SP)
	move.w	D2,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	RTS

lbC003440	MOVE.B	(3,A6),D0
	BEQ.B	lbC00346A
	MOVE.B	($1A,A6),D2
	ANDI.B	#15,D0
	BEQ.B	lbC003456
	ANDI.B	#$F0,D2
	OR.B	D0,D2
lbC003456	MOVE.B	(3,A6),D0
	ANDI.B	#$F0,D0
	BEQ.B	lbC003466
	ANDI.B	#15,D2
	OR.B	D0,D2
lbC003466	MOVE.B	D2,($1A,A6)
lbC00346A	MOVE.B	($1B,A6),D0
	LEA	(lbW00397E,PC),A0
	LSR.W	#2,D0
	ANDI.W	#$1F,D0
	MOVEQ	#0,D2
	MOVE.B	($1E,A6),D2
	ANDI.B	#3,D2
	BEQ.B	lbC0034A4
	LSL.B	#3,D0
	CMPI.B	#1,D2
	BEQ.B	lbC003492
	MOVE.B	#$FF,D2
	BRA.B	lbC0034A8

lbC003492	TST.B	($1B,A6)
	BPL.B	lbC0034A0
	MOVE.B	#$FF,D2
	SUB.B	D0,D2
	BRA.B	lbC0034A8

lbC0034A0	MOVE.B	D0,D2
	BRA.B	lbC0034A8

lbC0034A4	MOVE.B	(A0,D0.W),D2
lbC0034A8	MOVE.B	($1A,A6),D0
	ANDI.W	#15,D0
	MULU.W	D0,D2
	LSR.W	#7,D2
	MOVE.W	($10,A6),D0
	TST.B	($1B,A6)
	BMI.B	lbC0034C2
	ADD.W	D2,D0
	BRA.B	lbC0034C4

lbC0034C2	SUB.W	D2,D0
lbC0034C4
;	MOVE.W	D0,(6,A4)		; period

	bsr.w	PokePer

	MOVE.B	($1A,A6),D0
	LSR.W	#2,D0
	ANDI.W	#$3C,D0
	ADD.B	D0,($1B,A6)
	RTS

lbC0034D8	BSR.W	lbC0033C0
	BRA.W	lbC0035C6

lbC0034E0	BSR.B	lbC00346A
	BRA.W	lbC0035C6

lbC0034E6
;	MOVE.W	($10,A6),(6,A4)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	MOVE.B	(3,A6),D0
	BEQ.B	lbC003516
	MOVE.B	($1C,A6),D2
	ANDI.B	#15,D0
	BEQ.B	lbC003502
	ANDI.B	#$F0,D2
	OR.B	D0,D2
lbC003502	MOVE.B	(3,A6),D0
	ANDI.B	#$F0,D0
	BEQ.B	lbC003512
	ANDI.B	#15,D2
	OR.B	D0,D2
lbC003512	MOVE.B	D2,($1C,A6)
lbC003516	MOVE.B	($1D,A6),D0
	LEA	(lbW00397E,PC),A0
	LSR.W	#2,D0
	ANDI.W	#$1F,D0
	MOVEQ	#0,D2
	MOVE.B	($1E,A6),D2
	LSR.B	#4,D2
	ANDI.B	#3,D2
	BEQ.B	lbC003552
	LSL.B	#3,D0
	CMPI.B	#1,D2
	BEQ.B	lbC003540
	MOVE.B	#$FF,D2
	BRA.B	lbC003556

lbC003540	TST.B	($1B,A6)
	BPL.B	lbC00354E
	MOVE.B	#$FF,D2
	SUB.B	D0,D2
	BRA.B	lbC003556

lbC00354E	MOVE.B	D0,D2
	BRA.B	lbC003556

lbC003552	MOVE.B	(A0,D0.W),D2
lbC003556	MOVE.B	($1C,A6),D0
	ANDI.W	#15,D0
	MULU.W	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	($13,A6),D0
	TST.B	($1D,A6)
	BMI.B	lbC003572
	ADD.W	D2,D0
	BRA.B	lbC003574

lbC003572	SUB.W	D2,D0
lbC003574	BPL.B	lbC003578
	CLR.W	D0
lbC003578	CMPI.W	#$40,D0
	BLS.B	lbC003582
	MOVE.W	#$40,D0
lbC003582	MOVE.B	($28,A5,D0.W),D0
;	MOVE.W	D0,(8,A4)			; volume

	bsr.w	PokeVol

	MOVE.B	($1C,A6),D0
	LSR.W	#2,D0
	ANDI.W	#$3C,D0
	ADD.B	D0,($1D,A6)
	RTS

lbC00359A	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	BEQ.B	lbC0035A6
	MOVE.B	D0,($20,A6)
lbC0035A6	MOVE.B	($20,A6),D0
	LSL.W	#7,D0
	CMP.W	(8,A6),D0
	BGE.B	lbC0035BE
	SUB.W	D0,(8,A6)
	LSL.W	#1,D0
	ADD.L	D0,(4,A6)
	RTS

lbC0035BE	MOVE.W	#1,(8,A6)
	RTS

lbC0035C6
;	MOVE.W	($10,A6),(6,A4)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.B	lbC0035F8
lbC0035D8	ADD.B	D0,($13,A6)
	CMPI.B	#$40,($13,A6)
	BMI.B	lbC0035EA
	MOVE.B	#$40,($13,A6)
lbC0035EA	MOVE.B	($13,A6),D0
	MOVE.B	($28,A5,D0.W),D0
;	MOVE.W	D0,(8,A4)			; volume

	bsr.w	PokeVol

	RTS

lbC0035F8	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
lbC003602	SUB.B	D0,($13,A6)
	BPL.B	lbC00360C
	CLR.B	($13,A6)
lbC00360C	MOVE.B	($13,A6),D0
	MOVE.B	($28,A5,D0.W),D0
;	MOVE.W	D0,(8,A4)			; volume

	bsr.w	PokeVol

	RTS

lbC00361A	MOVE.B	(3,A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,($1E,A5)

	bsr.w	SongEnd

lbC003624	CLR.W	($1A,A5)
	ST	($1F,A5)
	RTS

lbC00362E	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	CMPI.B	#$40,D0
	BLS.B	lbC00363C
	MOVEQ	#$40,D0
lbC00363C	MOVE.B	D0,($13,A6)
	MOVE.B	($28,A5,D0.W),D0
;	MOVE.W	D0,(8,A4)			; volume

	bsr.w	PokeVol

	RTS

lbC00364A	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU.W	#10,D0
	ANDI.B	#15,D2
	ADD.B	D2,D0
	CMPI.B	#$3F,D0
	BHI.B	lbC003624
	ADD.W	D0,D0
	MOVE.W	D0,($1A,A5)
	ST	($1F,A5)
	RTS

lbC003670	MOVE.B	(3,A6),D0
	BEQ.W	lbC003268
	CLR.B	($1D,A5)
	MOVE.B	D0,($1C,A5)
	RTS

lbC003682	MOVE.B	($1F,A6),D0
	LSR.B	#4,D0
	BEQ.B	lbC00368E
	BSR.W	lbC0038C4
lbC00368E	MOVE.B	(2,A6),D0
	BEQ.B	lbC0036B6
	SUBI.B	#9,D0
	BEQ.W	lbC00359A
	SUBQ.B	#2,D0
	BEQ.W	lbC00361A
	SUBQ.B	#1,D0
	BEQ.W	lbC00362E
	SUBQ.B	#1,D0
	BEQ.W	lbC00364A
	SUBQ.B	#1,D0
	BEQ.B	lbC0036B8
	SUBQ.B	#1,D0
	BEQ.B	lbC003670
lbC0036B6	RTS

lbC0036B8	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	ANDI.B	#$F0,D0
	LSR.B	#2,D0
	JMP	(lbC0036C8,PC,D0.W)

lbC0036C8	BRA.W	lbC003708

	BRA.W	lbC0032CA

	BRA.W	lbC00330E

	BRA.W	lbC003722

	BRA.W	lbC003736

	BRA.W	lbC00374A

	BRA.W	lbC003758

	BRA.W	lbC003794

	BRA.W	lbC0036B6

	BRA.W	lbC0037AA

	BRA.W	lbC00381A

	BRA.W	lbC003830

	BRA.W	lbC003846

	BRA.W	lbC003862

	BRA.W	lbC003880

	BRA.W	lbC0038A2

lbC003708	MOVE.B	(3,A6),D0
;	ANDI.B	#1,D0
;	ASL.B	#1,D0
;	ANDI.B	#$FD,($BFE001)
;	OR.B	D0,($BFE001)
;	RTS

	btst	#1,D0
	beq.w	LED_On
	bra.w	LED_Off

lbC003722	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	ANDI.B	#$F0,($1F,A6)
	OR.B	D0,($1F,A6)
	RTS

lbC003736	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	ANDI.B	#$F0,($1F,A6)
	OR.B	D0,($1F,A6)
	RTS

lbC00374A	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	MOVE.B	D0,($12,A6)
	RTS

lbC003758	TST.B	($1D,A5)
	BNE.W	lbC003268
	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	BEQ.B	lbC00378C
	TST.B	($22,A6)
	BEQ.B	lbC003786
	SUBQ.B	#1,($22,A6)
	BEQ.W	lbC003268
lbC003778	MOVEQ	#0,D0
	MOVE.B	($21,A6),($1B,A5)
	ST	($20,A5)
	RTS

lbC003786	MOVE.B	D0,($22,A6)
	BRA.B	lbC003778

lbC00378C	MOVE.B	(1,A5),($21,A6)
	RTS

lbC003794	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	LSL.B	#4,D0
	ANDI.B	#15,($1E,A6)
	OR.B	D0,($1E,A6)
	RTS

lbC0037AA	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	BEQ.B	lbC003816
	MOVEQ	#0,D1
	MOVE.B	($1D,A5),D1
	BNE.B	lbC0037CA
	MOVE.W	(A6),D1
	BNE.B	lbC003816
	MOVEQ	#0,D1
	MOVE.B	($1D,A5),D1
lbC0037CA	DIVU.W	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.B	lbC003816
lbC0037D2	MOVE.W	($14,A6),D0
	MOVE.W	(4,A5),D1
	NOT.W	D1
	AND.W	D1,D0
;	MOVE.W	D0,($DFF096)			; DMA off

	bsr.w	PokeDMA

;	MOVE.L	(4,A6),(A4)			; address
;	MOVE.W	(8,A6),(4,A4)			; length

	move.l	4(A6),D0
	bsr.w	PokeAdr
	move.w	8(A6),D0
	bsr.w	PokeLen

;	MOVE.W	#$12C,D0
;lbC0037F2	DBRA	D0,lbC0037F2
	MOVE.W	($14,A6),D0
	BSET	#15,D0
;	MOVE.W	D0,($DFF096)			; DMA on

	bsr.w	PokeDMA

;	MOVE.W	#$12C,D0
;lbC003808	DBRA	D0,lbC003808
;	MOVE.L	(10,A6),(A4)			; address
;	MOVE.L	(14,A6),(4,A4)			; length + period

	move.l	10(A6),D0
	bsr.w	PokeAdr
	move.w	14(A6),D0
	bsr.w	PokeLen
	move.w	16(A6),D0
	bsr.w	PokePer

lbC003816	MOVE.L	(SP)+,D1
	RTS

lbC00381A	TST.B	($1D,A5)
	BNE.W	lbC003268
	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	BRA.W	lbC0035D8

lbC003830	TST.B	($1D,A5)
	BNE.W	lbC003268
	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	BRA.W	lbC003602

lbC003846	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	CMP.B	($1D,A5),D0
	BNE.W	lbC003268
	CLR.B	($13,A6)
;	CLR.W	(8,A4)				; volume

	move.l	D0,-(SP)
	moveq	#0,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	RTS

lbC003862	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	CMP.B	($1D,A5),D0
	BNE.W	lbC003268
	MOVE.W	(A6),D0
	BEQ.W	lbC003268
	MOVE.L	D1,-(SP)
	BRA.W	lbC0037D2

lbC003880	TST.B	($1D,A5)
	BNE.W	lbC003268
	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	TST.B	($23,A5)
	BNE.W	lbC003268
	ADDQ.B	#1,D0
	MOVE.B	D0,($22,A5)
	RTS

lbC0038A2	TST.B	($1D,A5)
	BNE.W	lbC003268
	MOVE.B	(3,A6),D0
	ANDI.B	#15,D0
	LSL.B	#4,D0
	ANDI.B	#15,($1F,A6)
	OR.B	D0,($1F,A6)
	TST.B	D0
	BEQ.W	lbC003268
lbC0038C4	MOVEM.L	D1/D2/A0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	($1F,A6),D0
	LSR.B	#4,D0
	BEQ.B	lbC00391C
	LEA	(lbW00396E,PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,($23,A6)
	BTST	#7,($23,A6)
	BEQ.B	lbC00391C
	CLR.B	($23,A6)
	MOVE.L	(4,A6),D1
	MOVEQ	#0,D2
	MOVE.W	($28,A6),D2
	LSL.W	#1,D2
	ADD.L	D2,D1
	MOVE.W	(14,A6),D2
	LSL.L	#1,D2
	SUB.L	D2,D1
	MOVE.L	($24,A6),D2
	MOVEQ	#0,D0
	MOVE.W	(14,A6),D0
	ADD.L	D0,D0
	ADD.L	D0,D2
	CMP.L	D1,D2
	BLS.B	lbC003916
	MOVE.L	(10,A6),D2
lbC003916	MOVE.L	D2,($24,A6)
;	MOVE.L	D2,(A4)				; address

	move.l	D0,-(SP)
	move.l	D2,D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

lbC00391C	MOVEM.L	(SP)+,D1/D2/A0
	RTS

;lbC003922	LEA	(lbW00400C,PC),A0
;	LEA	($DFF004),A1
;	MOVEQ	#$3F,D0
;lbC00392E	MOVEQ	#1,D2
;lbC003930	MOVE.L	(A1),D1
;	ANDI.L	#$1FF00,D1
;	CMPI.L	#$11000,D1
;	BNE.B	lbC003930
;lbC003940	MOVE.L	(A1),D1
;	ANDI.L	#$1FF00,D1
;	CMPI.L	#$11000,D1
;	BEQ.B	lbC003940
;	DBRA	D2,lbC003930
;	MOVEQ	#$40,D1
;	LEA	($41,A0),A2
;lbC00395A	MOVE.W	D1,D2
;	MULS.W	D0,D2
;	LSR.W	#6,D2
;	MOVE.B	D2,-(A2)
;	DBRA	D1,lbC00395A
;	DBRA	D0,lbC00392E
;	BRA.W	lbC002EC2

lbW00396E	dc.w	5
	dc.w	$607
	dc.w	$80A
	dc.w	$B0D
	dc.w	$1013
	dc.w	$161A
	dc.w	$202B
	dc.w	$4080
lbW00397E	dc.w	$18
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
	dc.w	0
lbL0039A0	dc.l	$3580328
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
	dc.l	$3520322
	dc.l	$2F502CB
	dc.l	$2A2027D
	dc.l	$2590237
	dc.l	$21701F9
	dc.l	$1DD01C2
	dc.l	$1A90191
	dc.l	$17B0165
	dc.l	$151013E
	dc.l	$12C011C
	dc.l	$10C00FD
	dc.l	$EF00E1
	dc.l	$D500C9
	dc.l	$BD00B3
	dc.l	$A9009F
	dc.l	$96008E
	dc.l	$86007E
	dc.l	$770071
	dc.l	$34C031C
	dc.l	$2F002C5
	dc.l	$29E0278
	dc.l	$2550233
	dc.l	$21401F6
	dc.l	$1DA01BF
	dc.l	$1A6018E
	dc.l	$1780163
	dc.l	$14F013C
	dc.l	$12A011A
	dc.l	$10A00FB
	dc.l	$ED00E0
	dc.l	$D300C7
	dc.l	$BC00B1
	dc.l	$A7009E
	dc.l	$95008D
	dc.l	$85007D
	dc.l	$760070
	dc.l	$3460317
	dc.l	$2EA02C0
	dc.l	$2990274
	dc.l	$250022F
	dc.l	$21001F2
	dc.l	$1D601BC
	dc.l	$1A3018B
	dc.l	$1750160
	dc.l	$14C013A
	dc.l	$1280118
	dc.l	$10800F9
	dc.l	$EB00DE
	dc.l	$D100C6
	dc.l	$BB00B0
	dc.l	$A6009D
	dc.l	$94008C
	dc.l	$84007D
	dc.l	$76006F
	dc.l	$3400311
	dc.l	$2E502BB
	dc.l	$294026F
	dc.l	$24C022B
	dc.l	$20C01EF
	dc.l	$1D301B9
	dc.l	$1A00188
	dc.l	$172015E
	dc.l	$14A0138
	dc.l	$1260116
	dc.l	$10600F7
	dc.l	$E900DC
	dc.l	$D000C4
	dc.l	$B900AF
	dc.l	$A5009C
	dc.l	$93008B
	dc.l	$83007C
	dc.l	$75006E
	dc.l	$33A030B
	dc.l	$2E002B6
	dc.l	$28F026B
	dc.l	$2480227
	dc.l	$20801EB
	dc.l	$1CF01B5
	dc.l	$19D0186
	dc.l	$170015B
	dc.l	$1480135
	dc.l	$1240114
	dc.l	$10400F5
	dc.l	$E800DB
	dc.l	$CE00C3
	dc.l	$B800AE
	dc.l	$A4009B
	dc.l	$92008A
	dc.l	$82007B
	dc.l	$74006D
	dc.l	$3340306
	dc.l	$2DA02B1
	dc.l	$28B0266
	dc.l	$2440223
	dc.l	$20401E7
	dc.l	$1CC01B2
	dc.l	$19A0183
	dc.l	$16D0159
	dc.l	$1450133
	dc.l	$1220112
	dc.l	$10200F4
	dc.l	$E600D9
	dc.l	$CD00C1
	dc.l	$B700AC
	dc.l	$A3009A
	dc.l	$910089
	dc.l	$81007A
	dc.l	$73006D
	dc.l	$32E0300
	dc.l	$2D502AC
	dc.l	$2860262
	dc.l	$23F021F
	dc.l	$20101E4
	dc.l	$1C901AF
	dc.l	$1970180
	dc.l	$16B0156
	dc.l	$1430131
	dc.l	$1200110
	dc.l	$10000F2
	dc.l	$E400D8
	dc.l	$CC00C0
	dc.l	$B500AB
	dc.l	$A10098
	dc.l	$900088
	dc.l	$800079
	dc.l	$72006C
	dc.l	$38B0358
	dc.l	$32802FA
	dc.l	$2D002A6
	dc.l	$280025C
	dc.l	$23A021A
	dc.l	$1FC01E0
	dc.l	$1C501AC
	dc.l	$194017D
	dc.l	$1680153
	dc.l	$140012E
	dc.l	$11D010D
	dc.l	$FE00F0
	dc.l	$E200D6
	dc.l	$CA00BE
	dc.l	$B400AA
	dc.l	$A00097
	dc.l	$8F0087
	dc.l	$7F0078
	dc.l	$3840352
	dc.l	$32202F5
	dc.l	$2CB02A3
	dc.l	$27C0259
	dc.l	$2370217
	dc.l	$1F901DD
	dc.l	$1C201A9
	dc.l	$191017B
	dc.l	$1650151
	dc.l	$13E012C
	dc.l	$11C010C
	dc.l	$FD00EE
	dc.l	$E100D4
	dc.l	$C800BD
	dc.l	$B300A9
	dc.l	$9F0096
	dc.l	$8E0086
	dc.l	$7E0077
	dc.l	$37E034C
	dc.l	$31C02F0
	dc.l	$2C5029E
	dc.l	$2780255
	dc.l	$2330214
	dc.l	$1F601DA
	dc.l	$1BF01A6
	dc.l	$18E0178
	dc.l	$163014F
	dc.l	$13C012A
	dc.l	$11A010A
	dc.l	$FB00ED
	dc.l	$DF00D3
	dc.l	$C700BC
	dc.l	$B100A7
	dc.l	$9E0095
	dc.l	$8D0085
	dc.l	$7D0076
	dc.l	$3770346
	dc.l	$31702EA
	dc.l	$2C00299
	dc.l	$2740250
	dc.l	$22F0210
	dc.l	$1F201D6
	dc.l	$1BC01A3
	dc.l	$18B0175
	dc.l	$160014C
	dc.l	$13A0128
	dc.l	$1180108
	dc.l	$F900EB
	dc.l	$DE00D1
	dc.l	$C600BB
	dc.l	$B000A6
	dc.l	$9D0094
	dc.l	$8C0084
	dc.l	$7D0076
	dc.l	$3710340
	dc.l	$31102E5
	dc.l	$2BB0294
	dc.l	$26F024C
	dc.l	$22B020C
	dc.l	$1EE01D3
	dc.l	$1B901A0
	dc.l	$1880172
	dc.l	$15E014A
	dc.l	$1380126
	dc.l	$1160106
	dc.l	$F700E9
	dc.l	$DC00D0
	dc.l	$C400B9
	dc.l	$AF00A5
	dc.l	$9C0093
	dc.l	$8B0083
	dc.l	$7B0075
	dc.l	$36B033A
	dc.l	$30B02E0
	dc.l	$2B6028F
	dc.l	$26B0248
	dc.l	$2270208
	dc.l	$1EB01CF
	dc.l	$1B5019D
	dc.l	$1860170
	dc.l	$15B0148
	dc.l	$1350124
	dc.l	$1140104
	dc.l	$F500E8
	dc.l	$DB00CE
	dc.l	$C300B8
	dc.l	$AE00A4
	dc.l	$9B0092
	dc.l	$8A0082
	dc.l	$7B0074
	dc.l	$3640334
	dc.l	$30602DA
	dc.l	$2B1028B
	dc.l	$2660244
	dc.l	$2230204
	dc.l	$1E701CC
	dc.l	$1B2019A
	dc.l	$183016D
	dc.l	$1590145
	dc.l	$1330122
	dc.l	$1120102
	dc.l	$F400E6
	dc.l	$D900CD
	dc.l	$C100B7
	dc.l	$AC00A3
	dc.l	$9A0091
	dc.l	$890081
	dc.l	$7A0073
	dc.l	$35E032E
	dc.l	$30002D5
	dc.l	$2AC0286
	dc.l	$262023F
	dc.l	$21F0201
	dc.l	$1E401C9
	dc.l	$1AF0197
	dc.l	$180016B
	dc.l	$1560143
	dc.l	$1310120
	dc.l	$1100100
	dc.l	$F200E4
	dc.l	$D800CB
	dc.l	$C000B5
	dc.l	$AB00A1
	dc.l	$980090
	dc.l	$880080
	dc.l	$790072
lbL003E20	dc.l	0
	dc.l	0
	dc.w	0
lbL003E2A	dc.l	0
	dc.l	0
	dc.b	0
lbB003E33	dc.b	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL003E4E	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.b	0
lbB003E61	dc.b	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL003E7C	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.b	0
lbB003E8F	dc.b	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL003EAA	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
	dc.b	0
lbB003EBD	dc.b	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbL003ED8	dc.l	0
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
lbL003F54	dc.l	$DFF0A0
lbL003F58	dc.l	$DFF0B0
lbL003F5C	dc.l	$DFF0C0
lbL003F60	dc.l	$DFF0D0
	dc.l	$80
	dc.l	$1000180
	dc.l	$2000280
	dc.l	$3000380
	dc.l	$4000480
	dc.l	$5000580
	dc.l	$6000680
	dc.l	$7000780
	dc.l	$8000880
	dc.l	$9000980
	dc.l	$A000A80
	dc.l	$B000B80
	dc.l	$C000C80
	dc.l	$D000D80
	dc.l	$E000E80
	dc.l	$F000F80
	dc.l	$10001080
	dc.l	$11001180
	dc.l	$12001280
	dc.l	$13001380
	dc.l	$14001480
	dc.l	$15001580
	dc.l	$16001680
	dc.l	$17001780
	dc.l	$18001880
	dc.l	$19001980
	dc.l	$1A001A80
	dc.l	$1B001B80
	dc.l	$1C001C80
	dc.l	$1D001D80
	dc.l	$1E001E80
	dc.l	$1F001F80
lbW003FE4	dc.w	0
lbW003FE6	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
lbL003FFA	dc.l	0
	dc.l	0
	dc.l	0
	dc.w	0
lbB004008	dc.b	0
lbB004009	dc.b	0
	dc.b	0
	dc.b	0
lbW00400C	dc.w	1
	dc.w	$203
	dc.w	$405
	dc.w	$607
	dc.w	$809
	dc.w	$A0B
	dc.w	$C0D
	dc.w	$E0F
	dc.w	$1011
	dc.w	$1213
	dc.w	$1415
	dc.w	$1617
	dc.w	$1819
	dc.w	$1A1B
	dc.w	$1C1D
	dc.w	$1E1F
	dc.w	$2021
	dc.w	$2223
	dc.w	$2425
	dc.w	$2627
	dc.w	$2829
	dc.w	$2A2B
	dc.w	$2C2D
	dc.w	$2E2F
	dc.w	$3031
	dc.w	$3233
	dc.w	$3435
	dc.w	$3637
	dc.w	$3839
	dc.w	$3A3B
	dc.w	$3C3D
	dc.w	$3E3F
	dc.w	$4000
	dc.w	0
	dc.w	$48
	dc.w	$90
	dc.w	$D8
	dc.w	$120
	dc.w	$168
	dc.w	$1B0
	dc.w	$1F8
	dc.w	$240
	dc.w	$288
	dc.w	$2D0
	dc.w	$318
	dc.w	$360
	dc.w	$3A8
	dc.w	$3F0
	dc.w	$438
