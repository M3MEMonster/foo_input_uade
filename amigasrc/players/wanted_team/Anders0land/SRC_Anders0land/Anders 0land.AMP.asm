	******************************************************
	****           Anders 0land replayer for	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player_Code,CODE

	EPPHEADER Tags

	dc.b	'$VER: Anders 0land player module V2.0 (1 Nov 2007)',0
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
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	EP_InitAmplifier,InitAudstruct
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_Flags,EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Packable!EPB_Restart!EPB_PrevSong!EPB_NextSong
	dc.l	TAG_DONE
PlayerName
	dc.b	'Anders 0land',0
Creator
	dc.b	"(c) 1993 by Anders 'Zonix' 0land,",10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'HOT.',0
	even
ModulePtr
	dc.l	0
SongPtr
	dc.l	0
SamplesPtr
	dc.l	0
SongEnd
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
	move.w	D5,D1		;00/10/20/30
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Address value
PokeAdr
	movem.l	D1/A5,-(SP)
	move.w	D5,D1		;00/10/20/30
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeAdr(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Length value
PokeLen
	movem.l	D1/A5,-(SP)
	move.w	D5,D1		;00/10/20/30
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
	move.w	D5,D1		;00/10/20/30
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
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange
	moveq 	#0,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	subq.l	#1,D1
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SongPtr(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	A2,A4
	add.w	18(A2),A2
	add.w	20(A4),A4
	move.l	SamplesPtr(PC),A1
	move.l	InfoBuffer+Samples(PC),D5
	subq.l	#1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2)+,D0
	add.l	A1,D0
	move.l	D0,EPS_Adr(A3)			; sample address
	moveq	#0,D0
	move.w	(A4)+,D0
	add.l	D0,D0
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
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
	move.b	lbL00062A+$1E+3(PC),D0
	rts

***************************************************************************
******************************** EP_Check5 ********************************
***************************************************************************

Check5
	move.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	move.l	dtg_ChkSize(A5),D2
	move.l	4(A0),D1
	sub.l	D1,D2
	bmi.b	fault
	move.l	A0,A1
	cmp.w	#'mp',(A1)+
	bne.b	fault
	cmp.b	#'l',(A1)
	bne.b	fault
	btst	#0,D1
	bne.b	fault
	add.l	D1,A0
	move.l	4(A0),D1
	sub.l	D1,D2
	bmi.b	fault
	move.l	A0,A1
	cmp.w	#'md',(A1)+
	bne.b	fault
	cmp.b	#'t',(A1)
	bne.b	fault
	btst	#0,D1
	bne.b	fault
	add.l	D1,A0
	move.l	4(A0),D1
	sub.l	D1,D2
	bmi.b	fault
	move.l	A0,A1
	cmp.w	#'ms',(A1)+
	bne.b	fault
	cmp.b	#'m',(A1)
	bne.b	fault
	moveq	#0,D0
fault
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
SubSongs	=	52
Special		=	60

InfoBuffer
	dc.l	MI_Calcsize,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_SamplesSize,0	;36
	dc.l	MI_Songsize,0		;44
	dc.l	MI_SubSongs,0		;52
	dc.l	MI_SpecialInfo,0	;60
	dc.l	MI_AuthorName,PlayerName
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
	move.l	4(A0),D1
	lea	8(A0,D1.L),A2
	move.l	A2,(A3)+			; SongPtr
	move.w	4(A2),D1
	sub.w	2(A2),D1
	lsr.w	#2,D1
	move.w	D1,SubSongs+2(A6)
	add.l	-4(A2),A2
	move.l	A2,(A3)				; SamplesPtr
	move.l	-4(A2),D1
	move.l	D1,SamplesSize(A6)
	sub.l	A0,A2
	subq.l	#8,A2
	move.l	A2,SongSize(A6)
	add.l	D1,A2
	move.l	A2,CalcSize(A6)
	cmp.l	A2,D0
	blt.b	Short
	move.l	SongPtr(PC),A1
	move.w	20(A1),D1
	sub.w	18(A1),D1
	lsr.w	#2,D1
	move.w	D1,Samples+2(A6)
	move.w	(A1),D1
	moveq	#0,D2
	move.w	6(A1),D2
	sub.w	D1,D2
	add.w	D1,A1
	sub.l	12(A1),D2
	move.l	D2,Length(A6)

	addq.l	#8,A0
	cmp.w	#$6000,(A0)+
	bne.b	Byte
	move.w	(A0),D1
	bra.b	SkipByte
Byte
	move.b	-1(A0),D1
	ext.w	D1
SkipByte
	lea	(A0,D1.W),A1
	clr.b	(A1)
	addq.l	#8,A0
	move.l	A0,Special(A6)
NextByte
	cmp.b	#$3A,(A0)
	bne.b	NoByte1
	addq.l	#1,A0
	move.b	#10,(A0)+
NoByte1
	cmp.b	#$2D,(A0)
	bne.b	NoByte2
	cmp.b	#$20,1(A0)
	bne.b	NoByte2
	move.b	#10,(A0)+
NoByte2
	addq.l	#1,A0
	cmp.l	A0,A1
	bne.b	NextByte

	moveq	#0,D0
	rts

Short
	moveq	#EPR_ModuleTooShort,D0
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

SongEndTest
	movem.l	A1/A5,-(A7)
	lea	SongEnd(PC),A1
	tst.w	D5
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.w	#4,D5
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.w	#8,D5
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.w	#12,D5
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)
	bne.b	SkipEnd
	move.l	#'WTWT',(A1)
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
	lea	SongEnd(PC),A0
	move.l	#'WTWT',(A0)
	move.l	SamplesPtr(PC),D1
	move.l	SongPtr(PC),D2
	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	bra.w	Init

***************************************************************************
**************************** Anders 0land player **************************
***************************************************************************

; Player from game Prime Mover (c) 1993 by Psygnosis

;	dc.b	'mpl1'
;	dc.l	$78C

;	BRA.S	lbC000062

;	BRA.L	lbC000132

;	BRA.L	lbC000132

;	dc.b	'-=*> Music & Player by: Anders 0land/Soul Sy'
;	dc.b	'ndicate! - All Rigths Reserved! <=*-'

Init
lbC000062	LEA	lbL00062A(PC),A0
	LEA	lbL00069E(PC),A1
;	BTST	#15,D0
;	BEQ.S	lbC000082
;	BSET	#7,6(A0)
;	ANDI.W	#$7FFF,D0
;	MOVE.W	#0,$3C(A1)
;	RTS

;lbC000082	BSET	#1,$BFE001
;	MOVE.W	#15,$DFF096
;	CLR.W	$DFF0A8
;	CLR.W	$DFF0B8
;	CLR.W	$DFF0C8
;	CLR.W	$DFF0D8
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVE.W	#$D4,D3
	SUBQ.W	#1,D3
lbC0000B4	CLR.B	0(A0,D3.W)
	DBRA	D3,lbC0000B4
	MOVE.L	D1,$52(A1)				; samples
	MOVE.L	D2,$56(A1)				; song
	MOVEA.L	D2,A6
	MOVEA.L	A6,A4
	ADDA.W	0(A6),A6
	LEA	(A6),A3
	MOVEA.L	A4,A5
	ADDA.W	2(A4),A4
	ADDA.W	4(A5),A5
	LSL.W	#2,D0
	ADDA.W	D0,A4
	ADDA.W	D0,A5
	MOVE.L	(A4),$22(A0)
	MOVE.B	(A5),1(A0)
	MOVE.B	1(A5),2(A0)
	MOVE.B	2(A5),11(A0)
	MOVE.B	3(A5),0(A0)
	MOVE.B	#$80,10(A0)
	MOVE.B	#15,3(A0)
	MOVE.B	#15,4(A0)
	CLR.L	$1E(A0)
;	ASL.W	#2,D0
	LEA	lbB00078B(PC),A4
lbC000114	MOVE.L	0(A6,D5.W),D0
	ADD.L	A6,D0
	MOVE.L	D0,14(A0,D5.W)
	MOVE.L	A4,$26(A0,D5.W)
	ADDI.B	#1,D6
	ADDI.B	#4,D5
	CMPI.B	#$10,D5
	BNE.S	lbC000114
	RTS

Play
lbC000132	LEA	lbL00062A(PC),A1
	LEA	lbL00069E(PC),A5
	LEA	$DFF0A0,A6
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVEQ	#0,D7
	CMPI.B	#1,5(A1)
	BEQ.S	lbC00017C
	BGT.L	lbC0003B0
	MOVE.B	8(A1),9(A1)
	MOVE.L	$3E(A1),$62(A1)
	MOVE.B	#0,8(A1)
	MOVE.B	#0,7(A1)
	BCLR	#5,6(A1)
	BRA.S	lbC00018C

lbC00017C	MOVEQ	#2,D7
	MOVEQ	#4,D6
	MOVEQ	#8,D5
	BCLR	#5,6(A1)
;	BRA.L	lbC00018C

lbC00018C	BTST	D7,1(A1)
	BEQ.L	lbC0003A0
	TST.B	$5E(A1,D7.W)
	BNE.L	lbC00039C
	CLR.W	$6C(A1,D6.W)
	BCLR	#6,6(A1)
	BSET	D7,8(A1)
	BCLR	D7,7(A1)
	LEA	$26(A1),A0
	MOVEA.L	0(A0,D5.W),A0
	MOVE.B	$36(A1,D7.W),D0
	MOVE.B	0(A0,D0.W),D1
	CMPI.B	#$FF,D1
	BNE.L	lbC000250
	MOVEQ	#0,D0
	MOVEA.L	14(A1,D5.W),A4
	MOVE.B	$1E(A1,D7.W),D2
	MOVE.B	0(A4,D2.W),D3
	CMPI.B	#$FF,D3
	BNE.S	lbC0001E8
	MOVE.B	$22(A1,D7.W),D2
	MOVE.B	D2,$1E(A1,D7.W)
	MOVE.B	0(A4,D2.W),D3

	bsr.w	SongEndTest

	BRA.S	lbC000206

lbC0001E8	CMPI.B	#$FE,D3
	BNE.S	lbC000206
	BCLR	D7,1(A1)
	BCLR	D7,10(A1)
	CLR.B	$24(A5,D7.W)
	BSET	D7,8(A1)
	BCLR	D7,7(A1)

	bsr.w	SongEndTest

	BRA.L	lbC0003A0

lbC000206	BTST	#7,D3
	BEQ.S	lbC000224
	ANDI.B	#$7F,D3
	MOVE.B	D3,$5A(A1,D7.W)
	MOVEA.L	14(A1,D5.W),A4
	MOVE.B	$1E(A1,D7.W),D2
	MOVE.B	1(A4,D2.W),D3
	ADDQ.B	#1,$1E(A1,D7.W)
lbC000224	ADDQ.B	#1,D2
	ADDQ.B	#1,$1E(A1,D7.W)
	SF	$36(A1,D7.W)
	MOVEA.L	$56(A5),A3
	ADDA.W	10(A3),A3
	LSL.L	#2,D3
	LEA	$26(A1),A0
	MOVE.L	0(A3,D3.W),D4
	ADD.L	A3,D4
	MOVE.L	D4,0(A0,D5.W)
	MOVEA.L	0(A3,D3.W),A0
	ADDA.L	A3,A0
	MOVE.B	0(A0,D0.W),D1
lbC000250	BTST	#7,D1
	BEQ.S	lbC000266
	MOVE.B	1(A0,D0.W),D2
	MOVE.B	D2,D3
	ANDI.B	#$7F,D3
	MOVE.B	D3,$3A(A1,D7.W)
	BRA.S	lbC0002D8

lbC000266	BTST	#6,D1
	BEQ.S	lbC0002BA
	MOVEA.L	$56(A5),A3
	ADDA.W	$10(A3),A3
	MOVE.B	1(A0,D0.W),D2
	MOVE.B	D2,D3
	ANDI.B	#$7F,D3
	ADD.B	D3,D3
	MOVE.W	0(A3,D3.W),D4
	BTST	#14,D4
	BEQ.S	lbC000296
	BSET	#7,6(A1)
	MOVE.B	D4,2(A5)
	BRA.S	lbC0002D8

lbC000296	BTST	#13,D4
	BEQ.S	lbC0002A2
	MOVE.B	D4,0(A1)
	BRA.S	lbC0002D8

lbC0002A2	BTST	#12,D4
	BNE.S	lbC0002B4
	ANDI.W	#$FFF,D4
	NEG.W	D4
lbC0002AE	MOVE.W	D4,$6C(A1,D6.W)
	BRA.S	lbC0002D8

lbC0002B4	ANDI.W	#$FFF,D4
	BRA.S	lbC0002AE

lbC0002BA	BTST	#5,D1
	BEQ.S	lbC0002CC
	BCLR	#6,6(A1)
	ADDQ.B	#1,$36(A1,D7.W)
	BRA.S	lbC0002F4

lbC0002CC	BSET	#6,6(A1)
	ADDQ.B	#2,$36(A1,D7.W)
	BRA.S	lbC0002F4

lbC0002D8	BTST	#7,D2
	BNE.S	lbC0002EA
	ADDQ.B	#3,$36(A1,D7.W)
	BSET	#6,6(A1)
	BRA.S	lbC0002F4

lbC0002EA	ADDQ.B	#2,$36(A1,D7.W)
	BCLR	#6,6(A1)
lbC0002F4	BTST	#5,D1
	BEQ.S	lbC00032C
	BTST	D7,6(A1)
	BNE.S	lbC00035E
	BSET	D7,6(A1)
	MOVEA.L	$56(A5),A3
	ADDA.W	12(A3),A3
	MOVE.B	$3A(A1,D7.W),D3
	LSL.L	#3,D3
	MOVE.B	1(A3,D3.W),D4
	ANDI.B	#$7F,D4
	MOVE.B	D4,$24(A5,D7.W)
	MOVE.B	1(A3,D3.W),D4
	MOVE.B	3(A3,D3.W),D3
	MOVE.B	D3,$3E(A1,D7.W)
	BRA.S	lbC00035E

lbC00032C	BCLR	D7,6(A1)
	MOVEA.L	$56(A5),A3
	ADDA.W	12(A3),A3
	MOVEQ	#0,D3
	MOVE.B	$3A(A1,D7.W),D3
	LSL.W	#3,D3
	MOVE.B	0(A3,D3.W),D4
	MOVE.B	D4,$24(A5,D7.W)
	ANDI.B	#$7F,$24(A5,D7.W)
	MOVE.B	2(A3,D3.W),D3
	BCLR	D7,$66(A1)
	MOVE.B	D3,$3E(A1,D7.W)
	BRA.L	lbC00035E

lbC00035E	MOVE.B	D1,D2
	ANDI.B	#$1F,D2
	MOVE.B	D2,$5E(A1,D7.W)
	BTST	#6,6(A1)
	BEQ.S	lbC0003A0
	ANDI.B	#$C0,D1
	BEQ.S	lbC000378
	ADDQ.B	#1,D0
lbC000378	MOVE.B	1(A0,D0.W),D3
	LEA	lbW0006FE(PC),A3
	BTST	#7,D3
	BEQ.S	lbC00038A
	BSET	D7,7(A1)
lbC00038A	ANDI.B	#$7F,D3
	ADD.B	$5A(A1,D7.W),D3
	ADD.W	D3,D3
	MOVE.W	0(A3,D3.W),$4A(A1,D6.W)
	BRA.S	lbC0003A0

lbC00039C	SUBQ.B	#1,$5E(A1,D7.W)
lbC0003A0	ADDQ.B	#4,D5
	ADDQ.B	#2,D6
	ADDQ.B	#1,D7
	BCHG	#5,6(A1)
	BEQ.L	lbC00018C
lbC0003B0	MOVE.B	0(A1),D0
	SUBQ.B	#1,D0
	CMP.B	5(A1),D0
	BNE.S	lbC0003D2
	MOVE.B	7(A1),D2
	ANDI.B	#15,D2
	MOVE.B	8(A1),D1
	EOR.B	D2,D1
;	MOVE.W	D1,$DFF096			; DMA off

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	BRA.S	lbC000426

lbC0003D2
;	MOVE.W	10(A1),$DFF096			; DMA on

	move.l	D0,-(SP)
	move.w	10(A1),D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	CMPI.B	#1,5(A1)
	BNE.S	lbC000426
	MOVEA.L	$56(A5),A0
	MOVEA.L	A0,A2
	ADDA.W	$16(A0),A0
	ADDA.W	$18(A2),A2
	MOVEQ	#0,D1
	MOVEQ	#0,D3
lbC0003F4	BTST	D1,11(A1)
	BEQ.S	lbC00041A
	BTST	D1,9(A1)
	BEQ.S	lbC00041A
	MOVE.B	$62(A1,D1.W),D2
	ADD.L	D2,D2
;	MOVE.W	0(A2,D2.W),4(A6,D3.W)		; length

	movem.l	D0/D5,-(SP)
	move.l	D3,D5
	move.w	0(A2,D2.W),D0
	bsr.w	PokeLen

	ADD.L	D2,D2
	MOVE.L	0(A0,D2.W),D4
	ADD.L	$52(A5),D4
;	MOVE.L	D4,0(A6,D3.W)			; address

	move.l	D4,D0
	bsr.w	PokeAdr
	movem.l	(SP)+,D0/D5

lbC00041A	ADDI.B	#$10,D3
	ADDQ.B	#1,D1
	CMPI.B	#4,D1
	BNE.S	lbC0003F4
lbC000426	ADDQ.B	#1,5(A1)
	MOVE.B	0(A1),D0
	CMP.B	5(A1),D0
	BNE.L	lbC000504
	CLR.B	5(A1)
	MOVEQ	#0,D7
	MOVEQ	#0,D6
	MOVEQ	#0,D5
	MOVEA.L	$56(A5),A0
	ADDA.W	12(A0),A0
lbC000448	BTST	D7,11(A1)
	BEQ.L	lbC0004F4
	BTST	D7,7(A1)
	BNE.L	lbC0004E8
	BTST	D7,8(A1)
	BEQ.L	lbC0004F4
	BTST	D7,6(A1)
	BNE.S	lbC000494
	CLR.W	4(A5,D6.W)
	MOVE.B	$3A(A1,D7.W),D0
	LSL.W	#3,D0
	MOVE.B	4(A0,D0.W),12(A5,D7.W)
	MOVE.B	5(A0,D0.W),$10(A5,D7.W)
	MOVE.B	6(A0,D0.W),D1
	MOVE.B	D1,$14(A5,D7.W)
	LSR.B	#1,D1
	MOVE.B	D1,$5C(A5,D7.W)
	CLR.W	$18(A5,D6.W)
	MOVE.B	7(A0,D0.W),$20(A5,D7.W)
lbC000494	MOVEA.L	$56(A5),A3
	MOVEA.L	A3,A4
	MOVEA.L	A4,A2
	ADDA.W	$12(A3),A3
	ADDA.W	$14(A4),A4
	ADDA.W	$16(A2),A2
	MOVE.B	$3E(A1,D7.W),D1
	ADD.B	D1,D1
	MOVE.W	0(A2,D1.W),$42(A1,D6.W)
;	MOVE.W	0(A4,D1.W),4(A6,D5.W)		; length

	move.l	D0,-(SP)
	move.w	0(A4,D1.W),D0
	bsr.w	PokeLen
	move.l	(SP)+,D0

	ADD.B	D1,D1
	MOVE.L	0(A3,D1.W),D2
	ADD.L	$52(A5),D2
;	MOVE.L	D2,0(A6,D5.W)			; address

	move.l	D0,-(SP)
	move.l	D2,D0
	bsr.w	PokeAdr
	move.l	(SP)+,D0

	MOVE.B	$24(A5,D7.W),D0
	CLR.B	$2C(A5,D7.W)
	MOVEA.L	$56(A5),A3
	ADDA.W	14(A3),A3
	LSL.W	#2,D0
	MOVE.B	0(A3,D0.W),D1
	CMPI.B	#$FF,D1
	BEQ.S	lbC0004E8
	MOVE.B	D1,$30(A5,D7.W)
lbC0004E8	MOVE.W	$4A(A1,D6.W),$52(A1,D6.W)
	MOVE.W	$6C(A1,D6.W),$34(A5,D6.W)
lbC0004F4	ADDI.W	#$10,D5
	ADDQ.W	#2,D6
	ADDQ.W	#1,D7
	CMPI.W	#4,D7
	BNE.L	lbC000448
lbC000504	MOVEQ	#0,D7
	MOVEQ	#0,D6
	MOVEQ	#0,D5
	MOVEA.L	$56(A5),A2
	ADDA.W	14(A2),A2
lbC000512	BTST	D7,1(A1)
	BEQ.L	lbC0005DC
	BTST	D7,11(A1)
	BEQ.L	lbC0005DC
	BTST	D7,8(A1)
	BNE.L	lbC0005DC
	BTST	D7,#15
	BEQ.S	lbC000568
	CMPI.B	#$FF,12(A5,D7.W)
	BEQ.S	lbC000568
	TST.B	12(A5,D7.W)
	BEQ.S	lbC000544
	SUBQ.B	#1,12(A5,D7.W)
	BRA.S	lbC000568

lbC000544	MOVE.B	$10(A5,D7.W),D0
	EXT.W	D0
	LSL.W	#4,D0
	ADD.W	D0,$18(A5,D6.W)
	MOVE.B	$18(A5,D6.W),D0
	MOVE.B	D0,5(A5,D6.W)
	SUBQ.B	#1,$5C(A5,D7.W)
	BNE.S	lbC000568
	NEG.B	$10(A5,D7.W)
	MOVE.B	$14(A5,D7.W),$5C(A5,D7.W)
lbC000568	BTST	D7,3(A1)
	BEQ.S	lbC0005AC
	TST.B	$2C(A5,D7.W)
	BEQ.S	lbC000584
	MOVEQ	#0,D0
	MOVE.B	$28(A5,D7.W),D0
	ADD.B	D0,$30(A5,D7.W)
	SUBQ.B	#1,$2C(A5,D7.W)
	BRA.S	lbC0005AC

lbC000584	MOVEQ	#0,D0
	MOVE.B	$24(A5,D7.W),D0
	LSL.W	#2,D0
	CMPI.B	#$FF,0(A2,D0.W)
	BEQ.S	lbC00059A
	MOVE.B	0(A2,D0.W),$30(A5,D7.W)
lbC00059A	MOVE.B	1(A2,D0.W),$28(A5,D7.W)
	MOVE.B	2(A2,D0.W),$2C(A5,D7.W)
	MOVE.B	3(A2,D0.W),$24(A5,D7.W)
lbC0005AC	BTST	#7,6(A1)
	BEQ.S	lbC0005DC
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	$30(A5,D7.W),D0
	MOVE.W	$3C(A5),D1
	DIVU.W	#$40,D0
	MULU.W	D1,D0
	SUB.B	D0,$30(A5,D7.W)
	ADDQ.W	#1,$3C(A5)
	CMPI.W	#$40,$3C(A5)
	BNE.S	lbC0005DC
	BCLR	#7,6(A1)
lbC0005DC	ADDI.B	#$10,D5
	ADDQ.B	#2,D6
	ADDQ.B	#1,D7
	CMPI.B	#4,D7
	BNE.L	lbC000512
	MOVEQ	#0,D7
	MOVEQ	#0,D6
	MOVEQ	#0,D5
	MOVEQ	#0,D4
lbC0005F4	BTST	D7,11(A1)
	BEQ.S	lbC000618
	MOVE.W	$52(A1,D6.W),D0
	ADD.W	$34(A5,D6.W),D0
	MOVE.W	D0,$52(A1,D6.W)
	MOVE.B	5(A5,D6.W),D3
	EXT.W	D3
	ADD.W	D3,D0
;	MOVE.W	D0,6(A6,D5.W)			; period
;	MOVE.B	$30(A5,D7.W),9(A6,D5.W)		; volume

	move.l	D0,-(SP)
	bsr.w	PokePer
	moveq	#0,D0
	move.b	$30(A5,D7.W),D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

lbC000618	ADDI.B	#$10,D5
	ADDQ.B	#4,D4
	ADDQ.B	#2,D6
	ADDQ.B	#1,D7
	CMPI.B	#4,D7
	BNE.S	lbC0005F4
	RTS

lbL00062A	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL00069E	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbW0006FE	dc.w	$D60
	dc.w	$CA0
	dc.w	$BE8
	dc.w	$B40
	dc.w	$A98
	dc.w	$A00
	dc.w	$970
	dc.w	$8E8
	dc.w	$868
	dc.w	$7F0
	dc.w	$780
	dc.w	$714
	dc.w	$6B0
	dc.w	$650
	dc.w	$5F4
	dc.w	$5A0
	dc.w	$54C
	dc.w	$500
	dc.w	$4B8
	dc.w	$474
	dc.w	$434
	dc.w	$3F8
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
	dc.w	$72
	dc.w	$6B
	dc.w	$65
	dc.w	$5F
	dc.w	$55
	dc.w	$50
	dc.w	$50
	dc.w	$50
	dc.w	$50
	dc.w	$50
	dc.w	$8000
	dc.b	0
lbB00078B	dc.b	$FF
