	******************************************************
	****          Andrew Parton replayer for     	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: Andrew Parton player module V2.1 (30 Apr 2014)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!1
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Packable!EPB_Restart
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	0

PlayerName
	dc.b	'Andrew Parton',0
Creator
	dc.b	'(c) 1993 by Andrew Parton,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'BYE.',0
	even
ModulePtr
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
	move.w	A5,D1		;DFF000/10/20/30
	sub.w	#$F000,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
PokeAdr
	movem.l	D1/A5,-(SP)
	move.w	A4,D1		;DFF000/10/20/30
	sub.w	#$F000,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Length value
PokeLen
	movem.l	D1/A5,-(SP)
	move.w	A4,D1		;DFF000/10/20/30
	sub.w	#$F000,D1
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
	move.w	A4,D1		;DFF000/10/20/30
	sub.w	#$F000,D1
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
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

	bsr.w	IntBits

	move.l	EagleBase(PC),A5
	jsr	ENPP_Amplifier(A5)

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

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.b	return

	lea	Base(PC),A2
	lea	80(A2),A1
	moveq	#19,D5
Next
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A1)+,EPS_Length(A3)		; sample length
	move.l	(A2)+,D0
	beq.b	Skip
	move.l	D0,A0
	move.l	A0,EPS_Adr(A3)			; sample address
	lea	-16(A0),A0
	move.l	A0,EPS_SampleName(A3)		; sample name
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#16,EPS_MaxNameLen(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
Skip
	dbf	D5,Next

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

LoadSize	=	4
Samples		=	12
CalcSize	=	20
SamplesSize	=	28
SongSize	=	36

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Samples,0		;12
	dc.l	MI_Calcsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Songsize,0		;36
	dc.l	MI_MaxSamples,20
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#'BANK',(A0)+
	bne.b	Fault
	move.l	#$200000,D1		; max. chip ram
	moveq	#19,D2
NextOff
	cmp.l	(A0)+,D1
	bls.b	Fault
	dbf	D2,NextOff

	move.l	#$10000,D1		; max. sample length
	moveq	#19+20,D2
NextOff2
	cmp.l	(A0)+,D1
	bls.b	Fault
	dbf	D2,NextOff2

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
	move.l	A0,(A6)				; songdata buffer
	lea	InfoBuffer(PC),A4		; A4 reserved for InfoBuffer
	move.l	D0,LoadSize(A4)
	lea	(A0,D0.L),A3			; end of file
	lea	SampleBase(PC),A1
	move.l	A0,D3
	move.l	A0,(A1)
	lea	484(A0),A2
	clr.l	(A0)+				; make empty sample
	lea	$50(A0),A1
	moveq	#$13,D1
	moveq	#0,D0
NextSam
	tst.l	(A0)+
	beq.b	NoSamp
	addq.l	#1,D0
	lea	16(A2),A2
	add.l	(A1),A2
NoSamp
	addq.l	#4,A1
	dbf	D1,NextSam
	lea	MusicBase(PC),A1
	move.l	A2,(A1)
	move.l	D0,Samples(A4)
	move.l	A2,D2
	sub.l	D3,D2
	move.l	D2,SamplesSize(A4)
	cmp.l	A2,A3
	blt.b	Short
	moveq	#-1,D1
NextByte
	cmp.b	(A2)+,D1
	beq.b	FlagFound
	cmp.l	A2,A3
	bne.b	NextByte
Short
	moveq	#EPR_ModuleTooShort,D0
	rts
FlagFound
	cmp.b	#$2F,(A2)+
	bne.b	InFile
	sub.l	D3,A2
	move.l	A2,CalcSize(A4)
	sub.l	D2,A2
	move.l	A2,SongSize(A4)

	moveq	#0,D0
	rts

InFile
	moveq	#EPR_ErrorInFile,D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	bra.w	StartMusic

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	bra.w	StopMusic

***************************************************************************
**************************** Andrew Parton player *************************
***************************************************************************

; Player from game B-17 Flying Fortress (c) 1993 by MicroProse

;	BRA.L	StartMusic

;	BRA.L	StopMusic

;	BRA.L	IntBits

MusicBase	dc.l	0
SampleBase	dc.l	0
;MPlaying	dc.w	0
;IntCount	dc.w	0
;MastVol	dc.w	$3F
;NTSCFlag	dc.w	0
Base	dc.l	0
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
SinWave	dc.w	0
	dc.w	1
	dc.w	1
	dc.w	2
	dc.w	3
	dc.w	4
	dc.w	4
	dc.w	5
	dc.w	5
	dc.w	4
	dc.w	3
	dc.w	2
	dc.w	2
	dc.w	1
	dc.w	1
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFE
	dc.w	$FFFD
	dc.w	$FFFC
	dc.w	$FFFC
	dc.w	$FFFB
	dc.w	$FFFC
	dc.w	$FFFC
	dc.w	$FFFD
	dc.w	$FFFE
	dc.w	$FFFE
	dc.w	$FFFF
	dc.w	$FFFF
Bits	dc.w	$102
	dc.w	$408
MidiBytes	dc.l	0
	dc.l	0
	dc.l	$1010001
	dc.l	$100
Periods	dc.w	$7F0
	dc.w	$780
	dc.w	$710
	dc.w	$6B0
	dc.w	$650
	dc.w	$5F0
	dc.w	$5A0
	dc.w	$550
	dc.w	$500
	dc.w	$4B0
	dc.w	$470
	dc.w	$430
	dc.w	$3F8
	dc.w	$3C0
	dc.w	$388
	dc.w	$358
	dc.w	$328
	dc.w	$2F8
	dc.w	$2D0
	dc.w	$2A8
	dc.w	$280
	dc.w	$258
	dc.w	$238
	dc.w	$218
	dc.w	$1FC
	dc.w	$1E0
	dc.w	$1C4
	dc.w	$1AC
	dc.w	$194
	dc.w	$17C
	dc.w	$168
	dc.w	$154
	dc.w	$140
	dc.w	$12C
	dc.w	$11C
	dc.w	$10C
	dc.w	$FE
	dc.w	$F0
	dc.w	$E2
	dc.w	$D6
	dc.w	$CA
	dc.w	$BE
	dc.w	$B4
	dc.w	$AA
	dc.w	$A0
	dc.w	$96
	dc.w	$8E
	dc.w	$86
	dc.w	$7F
	dc.w	$78
	dc.w	$71
	dc.w	$6B
	dc.w	$65
	dc.w	$5F
	dc.w	$5A
	dc.w	$55
	dc.w	$50
	dc.w	$4B
	dc.w	$47
	dc.w	$43
	dc.w	$3F
	dc.w	$3C
	dc.w	$38
	dc.w	$35
	dc.w	$32
	dc.w	$2F
	dc.w	$2D
	dc.w	$2A
	dc.w	$28
	dc.w	$25
	dc.w	$23
	dc.w	$21

IntBits
;	LEA	NTSCFlag(PC),A0
;	TST.W	(A0)
;	BEQ.S	noNTSC
;	LEA	Base(PC),A6
;	ADDI.B	#1,$25B(A6)
;	CMPI.B	#6,$25B(A6)
;	BNE.S	noNTSC
;	MOVE.B	#0,$25B(A6)
;	RTS

;noNTSC	LEA	IntCount(PC),A6
;	ADDI.W	#1,(A6)
	BSR.L	PlayRoutine
	BSR.L	NoteFX
	RTS

PlayNote	MOVEM.L	D0-D6/A0-A6,-(SP)
	LEA	Base(PC),A6
	LEA	Periods(PC),A0
	ANDI.W	#$7F,D0
	ANDI.W	#$7F,D1
	ANDI.L	#3,D2
	ANDI.W	#$7F,D3
	MOVE.W	D0,$23A(A6)
	MOVE.W	D2,$238(A6)
	MOVE.L	D2,D4
	ASL.W	#4,D4
	LEA	$1E2(A6),A5
	ADDA.L	D4,A5
	LEA	$244(A6),A2
	LSR.W	#1,D1
	CMPI.W	#0,D1
	BNE.S	nnoff
	MOVE.B	#$64,4(A5)
	BRA.L	OuttaHere

nnoff	MOVE.B	D0,0(A2,D2.W)
	MOVE.B	D1,7(A5)
	MOVE.B	#0,5(A5)
	MOVE.B	#0,4(A5)
	MOVE.B	#1,6(A5)
	SUBI.W	#$30,D0
	ASL.W	#2,D3
	MOVE.W	D3,$236(A6)
	LEA	$140(A6),A4
	MOVE.B	0(A4,D3.W),0(A5)
	MOVE.B	1(A4,D3.W),1(A5)
	MOVE.B	2(A4,D3.W),2(A5)
	MOVE.B	3(A4,D3.W),3(A5)
	LEA	$190(A6),A4
	MOVE.B	0(A4,D3.W),10(A5)
	MOVE.B	1(A4,D3.W),11(A5)
	MOVE.B	2(A4,D3.W),13(A5)
	MOVE.B	#0,12(A5)
	MOVE.B	2(A5),D4
	MULU.W	D1,D4
	LSR.W	#6,D4
	MOVE.B	D4,2(A5)
	LEA	$50(A6),A2
	MOVE.L	0(A2,D3.W),D4
	LSR.W	#1,D4
	ANDI.L	#$7F,D3
	LEA	0(A6,D3.W),A2
	MOVEA.L	(A2),A2
	ADD.W	D0,D0
	MOVE.W	0(A0,D0.W),D0
	LEA	$DFF000,A4
	LEA	Bits(PC),A0
	MOVE.B	0(A0,D2.W),D3
	ANDI.W	#15,D3
;	MOVE.W	D3,$DFF096		; DMA off

	move.l	D0,-(SP)
	move.w	D3,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	ASL.W	#4,D2
	ADDA.W	D2,A4
	CLR.W	D1
npb	MOVE.W	D0,8(A5)
;	MOVE.L	A2,$A0(A4)		; address
;	MOVE.W	D4,$A4(A4)		; length
;	MOVE.W	D0,$A6(A4)		; period

	move.l	D0,-(SP)
	bsr.w	PokePer
	move.l	A2,D0
	bsr.w	PokeAdr
	move.w	D4,D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	ORI.W	#$8200,D3
;	BSR.L	Delay
;	MOVE.W	D3,$DFF096		; DMA on
;	BSR.L	Delay

	move.l	D0,-(SP)
	move.w	D3,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	MOVE.W	$236(A6),D3
;	MOVE.L	A6,D0
;	ADDI.L	#$222,D0
	LEA	$A0(A6),A5
	CMPI.L	#0,0(A5,D3.W)
	BEQ.S	OneShot
	MOVE.L	0(A5,D3.W),D0
	LSR.W	#1,D0
;	MOVE.W	D0,$A4(A4)		; repeat length

	bsr.w	PokeLen

	LEA	$F0(A6),A0
	LEA	0(A6),A1
	MOVE.L	0(A0,D3.W),D0
	ADD.L	0(A1,D3.W),D0
;	MOVE.L	D0,$A0(A4)		; repeat address

	bsr.w	PokeAdr

	BRA.S	OuttaHere

OneShot
;	MOVE.L	D0,$A0(A4)
;	MOVE.W	#2,$A4(A4)		; repeat length

	move.l	D0,-(SP)
	move.l	SampleBase(PC),D0
	bsr.w	PokeAdr
	moveq	#2,D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

OuttaHere	MOVEM.L	(SP)+,D0-D6/A0-A6
	RTS

;Delay	MOVE.W	D0,-(SP)
;	MOVE.B	$DFF006,D0
;	ADDI.W	#4,D0
;wt2	CMP.B	$DFF006,D0
;	BNE.S	wt2
;	MOVE.W	(SP)+,D0
;	RTS

NoteFX	MOVE.W	#3,D7
	LEA	Base(PC),A6
	LEA	$1E2(A6),A6
	LEA	$DFF000,A5
llp	CMPI.B	#0,10(A6)
	BEQ.S	DoVib
	SUBI.B	#1,10(A6)
	BRA.S	OvVib

DoVib	MOVE.B	12(A6),D0
	ANDI.W	#$FF,D0
	ADD.W	D0,D0
	LEA	SinWave(PC),A0
	MOVE.W	0(A0,D0.W),D0
	MOVE.B	11(A6),D1
	ANDI.W	#$FF,D1
	MULU.W	D1,D0
	ADD.W	8(A6),D0
;	MOVE.W	D0,$A6(A5)		; period

	move.l	A4,-(SP)
	move.l	A5,A4
	bsr.w	PokePer
	move.l	(SP)+,A4

	MOVE.B	13(A6),D0
	ADD.B	D0,12(A6)
	ANDI.B	#$1F,12(A6)
OvVib	CMPI.B	#0,4(A6)
	BEQ.S	Att
	CMPI.B	#1,4(A6)
	BEQ.S	Sust
	CMPI.B	#$64,4(A6)
	BEQ.S	Rel
	BRA.L	Nxt

Att	MOVE.B	0(A6),D0
	ADD.B	D0,5(A6)
	CMPI.B	#$3F,5(A6)
	BLE.L	n64
	MOVE.B	#$3F,5(A6)
n64	MOVE.B	7(A6),D0
	CMP.B	5(A6),D0
	BGT.S	PutItIn
	ADDI.B	#1,4(A6)
	MOVE.B	7(A6),5(A6)
	BRA.S	PutItIn

;	NOP
Sust	MOVE.B	2(A6),D1
	CMP.B	5(A6),D1
	BEQ.S	IncCount
	BGT.S	Up
Down	MOVE.B	1(A6),D0
	SUB.B	D0,5(A6)
	BPL.S	nneg
	MOVE.B	#0,5(A6)
nneg	CMP.B	5(A6),D1
	BLT.S	PutItIn
	MOVE.B	D1,5(A6)
	BRA.S	PutItIn

IncCount	ADDI.B	#1,4(A6)
	BRA.S	Nxt

Up	MOVE.B	1(A6),D0
	ADD.B	D0,5(A6)
	CMP.B	5(A6),D1
	BGT.S	PutItIn
	MOVE.B	D1,5(A6)
	BRA.S	PutItIn

Rel	MOVE.B	3(A6),D0
	SUB.B	D0,5(A6)
	BPL.S	nneg2
	MOVE.B	#0,5(A6)
nneg2	BNE.S	PutItIn
	MOVE.B	#$FF,4(A6)
	MOVE.B	#0,6(A6)
;	BRA.S	PutItIn

;	NOP
PutItIn	MOVE.B	5(A6),D0
	ANDI.W	#$3F,D0
;	LEA	MastVol(PC),A0
;	ANDI.W	#$3F,(A0)
;	MULU.W	(A0),D0
;	LSR.W	#6,D0
;	MOVE.W	D0,$A8(A5)		; volume

	bsr.w	PokeVol

Nxt	LEA	$10(A6),A6
	LEA	$10(A5),A5
	DBRA	D7,llp
	RTS

StartMusic	MOVEM.L	D0-D6/A0-A6,-(SP)
	LEA	Base(PC),A6
	CLR.B	$248(A6)
;	LEA	IntCount(PC),A6
;	CLR.W	(A6)
;	MOVE.B	$BFE001,D0
;	ORI.W	#2,D0
;	MOVE.B	D0,$BFE001
	MOVE.W	#$1DF,D0
	LEA	SampleBase(PC),A0
	MOVEA.L	(A0),A0
	LEA	4(A0),A0
	LEA	Base(PC),A1
copysamples1	MOVE.B	(A0)+,(A1)+
	DBRA	D0,copysamples1
	LEA	Base(PC),A6
	CLR.L	$222(A6)
	LEA	0(A6),A1
	LEA	$50(A6),A2
	MOVE.W	#$13,D1
sb	TST.L	(A1)
	BEQ.S	nnxt
	LEA	$10(A0),A0
	MOVE.L	A0,(A1)
	ADDA.L	(A2),A0
nnxt	LEA	4(A1),A1
	LEA	4(A2),A2
	DBRA	D1,sb
	LEA	MusicBase(PC),A0
	MOVEA.L	(A0),A0
	LEA	1(A0),A0
	MOVE.L	A0,$23C(A6)
	MOVE.L	A0,$240(A6)
	MOVE.B	#1,$248(A6)
;	LEA	MPlaying(PC),A1
;	MOVE.W	#1,(A1)
	MOVE.B	#1,$249(A6)
outstartmusic	MOVEM.L	(SP)+,D0-D6/A0-A6
	RTS

StopMusic	MOVE.L	A6,-(SP)
	LEA	Base(PC),A6
	CLR.B	$248(A6)
	BSR.L	ShutUp
	MOVEA.L	(SP)+,A6
	RTS

PlayRoutine	LEA	Base(PC),A6
	TST.B	$248(A6)
	BEQ.S	NtPlaying
	SUBI.B	#1,$249(A6)
	BEQ.S	isplaying
NtPlaying	RTS

isplaying	MOVEA.L	$23C(A6),A0
prlp	MOVE.B	(A0)+,D1
	BTST	#7,D1
	BEQ.S	ncomm
	MOVE.B	D1,$24A(A6)
	MOVE.B	(A0)+,D1
ncomm	MOVE.B	$24A(A6),D0
	ANDI.B	#$F0,D0
	CMPI.B	#$90,D0
	BNE.S	nnon
	MOVE.B	D1,D0
	MOVE.B	(A0)+,D1
	BEQ.S	noff
	MOVE.B	$24A(A6),D2
	ANDI.W	#15,D2
	LEA	$24B(A6),A5
	MOVE.B	0(A5,D2.W),D3
	ANDI.W	#$1F,D3
	ANDI.W	#3,D2
	BSR.L	PlayNote
	BRA.L	nomore

nnon	CMPI.B	#$80,D0
	BNE.S	nnoteoff
	LEA	1(A0),A0
noff	MOVE.W	D1,D0
	MOVE.W	#0,D1
	MOVE.B	$24A(A6),D2
	ANDI.W	#3,D2
	BSR.L	PlayNote
	BRA.L	nomore

nnoteoff	CMPI.B	#$C0,D0
	BNE.S	nprog
	CMPI.B	#$7E,D1
	BNE.S	nrep
	MOVEA.L	$240(A6),A0
	LEA	1(A0),A0
	BRA.L	prlp

nrep	MOVE.B	$24A(A6),D0
	ANDI.W	#15,D0
	LEA	$24B(A6),A1
	MOVE.B	D1,0(A1,D0.W)
	BRA.L	nomore

nprog	CMPI.B	#$FF,$24A(A6)
	BNE.S	nend
	MOVE.B	#0,$248(A6)
;	LEA	MPlaying(PC),A1
;	CLR.W	(A1)

	bsr.w	SongEnd

	BRA.L	nomore

nend	CMPI.B	#$B0,D0
	BNE.S	nbo
	TST.B	(A6)+
	BRA.S	nomore

nbo	MOVE.B	$24A(A6),D0
	LSR.B	#4,D0
	ANDI.W	#15,D0
	LEA	MidiBytes(PC),A1
	TST.B	0(A1,D0.W)
	BEQ.S	nomore
	LEA	1(A0),A0
nomore	TST.B	(A0)+
	BEQ.L	prlp
	MOVE.B	-1(A0),$249(A6)
	MOVE.L	A0,$23C(A6)
	RTS

;VBLBase	dc.l	0
;	dc.w	0

ShutUp	MOVEM.L	D0/D6/A5/A6,-(SP)
;	LEA	$DFF000,A5
	LEA	Base(PC),A6
	LEA	$1E2(A6),A6
	MOVE.W	#3,D6
ll	MOVE.B	#$64,4(A6)
	MOVE.B	#0,5(A6)
;	MOVE.W	#0,$A8(A5)
;	LEA	$10(A5),A5
	LEA	$10(A6),A6
	DBRA	D6,ll
	MOVEM.L	(SP)+,D0/D6/A5/A6
	RTS

