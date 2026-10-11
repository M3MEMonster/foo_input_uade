	******************************************************
	****          Dirk Bialluch replayer for     	  ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: Dirk Bialluch player module V2.0 (8 Apr 2006)',0
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
	dc.b	'Dirk Bialluch',0
Creator
	dc.b	'(c) 1993 by Dirk Bialluch,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	"TPU.",0
SMP
	dc.b	'SMP.',0
	even
MSEQ
	dc.l	0
MPTN
	dc.l	0
MPRG
	dc.l	0
MGRV
	dc.l	0
MSMP
	dc.l	0
MARP
	dc.l	0
MSNG
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
	move.w	A0,D1		;DFF0A0/B0/C0/D0
	sub.w	#$F0A0,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	move.l	EagleBase(PC),A5
	jsr	ENPP_PokeVol(A5)
	movem.l	(SP)+,D1/A5
	rts

*---------------------------------------------------------------------------*
* Input		D0 = Period value
PokePer
	movem.l	D1/A5,-(SP)
	move.w	A0,D1		;DFF0A0/B0/C0/D0
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
	move.l	MSMP(PC),D0
	beq.b	return
	move.l	D0,A2

	move.l	InfoBuffer+Samples(PC),D5
	subq.l	#1,D5
	addq.l	#6,A2
	move.l	lbL0038EC(PC),A1
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A2)+,D1
	move.l	(A2),D0
	sub.l	D1,D0
	lea	(A1,D1.L),A0
	move.l	A0,EPS_Adr(A3)			; sample address
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
	move.l	dtg_PathArrayPtr(A5),A0
	clr.b	(A0)
	move.l	dtg_CopyDir(A5),A0
	jsr	(A0)
	bsr.s	CopyName
	move.l	D7,EPG_ARG1(A5)
	move.l	D6,EPG_ARGN(A5)
	jmp	ENPP_NewLoadFile(A5)

CopyName
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

	cmpi.b	#'T',(A3)
	beq.b	P_OK
	cmpi.b	#'t',(A3)
	bne.s	ExtError
T_OK
	cmpi.b	#'P',1(A3)
	beq.b	P_OK
	cmpi.b	#'p',1(A3)
	bne.s	ExtError
P_OK
	cmpi.b	#'U',2(A3)
	beq.b	U_OK
	cmpi.b	#'u',2(A3)
	bne.s	ExtError
U_OK
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

	move.l	dtg_ChkSize(A5),D1
	cmp.l	#'MSNG',(A0)+
	bne.b	Fault
	subq.l	#4,D1
	lea	514(A0),A1
Find
	cmp.l	#'MSEQ',(A0)
	beq.b	Found
	subq.l	#2,D1
	bmi.b	Fault
	move.w	(A0)+,D2
	and.w	#$F000,D2
	bne.b	Fault
	cmp.l	A0,A1
	bne.b	Find
Fault
	rts
Found
	moveq	#0,D0
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	MSNG(PC),A6
	move.l	A0,(A6)				; module buffer
	move.l	A0,A1
	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
FindMSEQ
	cmp.l	#'MSEQ',(A0)
	beq.b	MSEQ_OK
	addq.l	#2,A0
	subq.l	#2,D0
	bmi.w	Error
	bra.b	FindMSEQ
MSEQ_OK
	move.l	A0,-24(A6)
	move.l	A0,D1
FindMPTN
	cmp.l	#'MPTN',(A0)
	beq.b	MPTN_OK
	addq.l	#2,A0
	subq.l	#2,D0
	bmi.w	Error
	bra.b	FindMPTN
MPTN_OK
	move.l	A0,D2
	move.l	A0,-20(A6)
FindMPRG
	cmp.l	#'MPRG',(A0)
	beq.b	MPRG_OK
	addq.l	#2,A0
	subq.l	#2,D0
	bmi.b	Error
	bra.b	FindMPRG
MPRG_OK
	move.l	A0,-16(A6)
FindMGRV
	cmp.l	#'MGRV',(A0)
	beq.b	MGRV_OK
	addq.l	#2,A0
	subq.l	#2,D0
	bmi.b	Error
	bra.b	FindMGRV
MGRV_OK
	move.l	A0,-12(A6)
FindMARP
	cmp.l	#'MARP',(A0)
	beq.b	MARP_OK
	addq.l	#2,A0
	subq.l	#2,D0
	bmi.b	Error
	bra.b	FindMARP
MARP_OK
	move.l	A0,-4(A6)
	sub.l	D1,D2
	lsr.l	#3,D2
	move.l	D2,Length(A4)
	sub.l	A1,D1
	subq.l	#6,D1
	lsr.l	#1,D1
	move.l	D1,SubSongs(A4)

	moveq	#1,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	add.l	D0,LoadSize(A4)
	cmp.l	#'MSMP',(A0)
	bne.b	Error
	move.l	A0,-8(A6)
	moveq	#0,D0
	move.w	4(A0),D0
	move.w	D0,Samples+2(A4)
	addq.w	#3,D0
	lsl.w	#2,D0
	addq.l	#2,D0
	add.l	-4(A0,D0.L),D0
	move.l	D0,SamplesSize(A4)

	moveq	#0,D0
	rts

Error
	moveq	#EPR_CorruptModule,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.w	lbW003972(PC),D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	lbL0038B4(PC),A0
	lea	lbW003992(PC),A1
Clear
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	Clear
	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	lsl.w	#1,D0
	movem.l	(MSEQ),A0-A6
	move.w	2(A6,D0.W),D0
	bsr.w	Init_1
	bra.w	Init_2

***************************************************************************
****************************** DTP_Interrupt ******************************
***************************************************************************

Interrupt
	movem.l	D1-D7/A0-A6,-(SP)

	moveq	#0,D0
	moveq	#0,D1
	moveq	#0,D2
	moveq	#0,D3
	moveq	#0,D4
	moveq	#0,D5
	moveq	#0,D6
	moveq	#0,D7

	bsr.w	Play
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
**************************** Dirk Bialluch player *************************
***************************************************************************

; Player from game "Time Lock" (c) 1993 by Boeder Software

Init_1
lbC0030BA	CLR.B	lbB003971
	MOVE.W	D0,lbW003972
	CMPI.L	#'MSEQ',(A0)+
	BNE.L	lbC0031A6
	MOVE.L	A0,lbL0038D8
	CMPI.L	#'MPTN',(A1)+
	BNE.L	lbC0031A6
	MOVE.W	(A1)+,D0
	MOVE.L	A1,lbL0038F0
	ADDQ.W	#2,D0
	ADD.W	D0,D0
	ADDA.L	D0,A1
	MOVE.L	A1,lbL0038DC
	CMPI.L	#'MPRG',(A2)+
	BNE.L	lbC0031A6
	MOVE.W	(A2)+,D0
	MOVE.L	A2,lbL0038F4
	ADDQ.W	#2,D0
	ADD.W	D0,D0
	ADDA.L	D0,A2
	MOVE.L	A2,lbL0038E0
	CMPI.L	#'MGRV',(A3)+
	BNE.L	lbC0031A6
	MOVE.L	A3,lbL0038E4
	CMPI.L	#'MSMP',(A4)+
	BNE.S	lbC0031A6
	MOVE.W	(A4)+,D0
	MOVE.L	A4,lbL0038F8
	ADDQ.W	#2,D0
	ASL.W	#2,D0
	ADDA.L	D0,A4
	MOVE.L	A4,lbL0038EC
	CMPI.L	#'MARP',(A5)+
	BNE.S	lbC0031A6
	MOVE.L	A5,lbL0038E8
	CMPI.L	#'MSNG',(A6)+
	BNE.S	lbC0031A6
	MOVE.L	A6,lbL0038B4
	MOVE.B	#1,lbB003974
	CLR.B	lbB003975
	CLR.B	lbB003977
	MOVE.L	lbL0038E0(PC),lbL003954
	MOVE.L	lbL0038E0(PC),lbL003958
	MOVE.L	lbL0038E0(PC),lbL00395C
	MOVE.L	lbL0038E0(PC),lbL003960
	CLR.L	lbL00393C
	CLR.B	lbB003990
;	MOVE.W	#$FF,$DFF09E
	MOVEQ	#1,D0
	RTS

lbC0031A6	MOVEQ	#0,D0
	RTS

Init_2
lbC0031AA	MOVE.B	#1,lbB003971
	RTS

End
;	CLR.B	lbB003971
;	MOVE.W	#15,$DFF096
;	RTS

Play
lbC0031C4	LEA	lbL003914(PC),A2
	TST.B	$5D(A2)
	BNE.S	lbC0031D0
	RTS

lbC0031D0	MOVEM.W	D0-D7,$64(A2)
	TST.B	$61(A2)
	BEQ.S	lbC0031E4
	SUBQ.B	#1,$61(A2)
	BRA.L	lbC003454

lbC0031E4	TST.B	$60(A2)
	BEQ.S	lbC003234
	CLR.L	(A2)
	CLR.L	4(A2)
	CLR.L	8(A2)
	ANDI.W	#$FFF,$5E(A2)
	MOVEA.L	-$3C(A2),A0
	MOVEQ	#0,D0
	MOVE.W	$5E(A2),D0
	ASL.W	#3,D0
	ADDA.L	D0,A0
	LEA	$58(A2),A3
	LEA	-$4C(A2),A4
	MOVEA.L	-$24(A2),A1
	MOVEQ	#3,D1
lbC003216	MOVE.L	-$38(A2),(A4)
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	ADD.W	D0,D0
	MOVE.W	0(A1,D0.W),D0
	ADD.L	D0,(A4)+
	MOVE.B	(A0)+,(A3)+
	DBRA	D1,lbC003216
	ADDQ.W	#1,$5E(A2)
	CLR.B	$60(A2)
lbC003234	LEA	lbL0038D8(PC),A3
	LEA	lbW0039DC(PC),A4
	LEA	lbL003ADC(PC),A5
	LEA	lbC00327A(PC),A6
	MOVEQ	#3,D7
lbC003246	MOVEA.L	-(A3),A0
	MOVEQ	#0,D0
	MOVE.B	0(A2,D7.W),D0
	TST.B	4(A2,D7.W)
	BEQ.S	lbC003260
	SUBQ.B	#1,4(A2,D7.W)
	DBRA	D7,lbC003246
	BRA.L	lbC00342C

lbC003260	MOVE.B	0(A0,D0.W),D2
	MOVEQ	#0,D6
	MOVE.B	0(A4,D2.W),D6
	ADD.W	D6,D6
	ADD.W	D6,D6
	MOVE.L	0(A5,D6.W),D6
	JMP	0(A6,D6.W)

lbC003276	MOVE.B	D0,0(A2,D7.W)
lbC00327A	DBRA	D7,lbC003246
	BRA.L	lbC00342C

lbC003282	MOVE.B	1(A0,D0.W),$2C(A2,D7.W)
	MOVE.B	D2,D6
	ADD.B	$58(A2,D7.W),D6
	ADD.B	D6,D6
	MOVE.B	D6,12(A2,D7.W)
	MOVE.B	2(A0,D0.W),$10(A2,D7.W)
	ADDQ.W	#3,D0
	BRA.S	lbC003260

lbC00329E	MOVE.B	#$40,$2C(A2,D7.W)
	MOVE.B	D2,D6
	SUBI.B	#$40,D6
	ADD.B	$58(A2,D7.W),D6
	ADD.B	D6,D6
	MOVE.B	D6,12(A2,D7.W)
	MOVE.B	2(A0,D0.W),$10(A2,D7.W)
	MOVE.B	1(A0,D0.W),4(A2,D7.W)
	ADDQ.W	#3,D0
	BRA.S	lbC003276

lbC0032C4	MOVE.B	2(A0,D0.W),4(A2,D7.W)
	ADDQ.W	#3,D0
	BRA.S	lbC003276

lbC0032CE	MOVE.B	2(A0,D0.W),$62(A2)
	CLR.B	$63(A2)
	ADDQ.W	#3,D0
	BRA.S	lbC003260

lbC0032DC
;	BCLR	#1,$BFE001

	bsr.w	LED_On

	ADDQ.W	#3,D0
	BRA.L	lbC003260

lbC0032EA
;	BSET	#1,$BFE001

	bsr.w	LED_Off

	ADDQ.W	#3,D0
	BRA.L	lbC003260

lbC0032F8	MOVE.B	1(A0,D0.W),D6
	ADD.B	$58(A2,D7.W),D6
	ADD.B	D6,D6
	MOVE.B	D6,-$10(A2,D7.W)
	MOVE.B	2(A0,D0.W),-$14(A2,D7.W)
	ADDQ.W	#3,D0
	BRA.L	lbC003260

lbC003312	MOVE.B	2(A0,D0.W),$5C(A2)
	ADDQ.W	#3,D0
	BRA.L	lbC003260

lbC00331E	MOVE.B	2(A0,D0.W),$2C(A2,D7.W)
	MOVE.B	1(A0,D0.W),4(A2,D7.W)
	ADDQ.W	#3,D0
	BRA.L	lbC003276

lbC003330	MOVE.B	2(A0,D0.W),D6
	ADD.B	D6,$2C(A2,D7.W)
	MOVE.B	1(A0,D0.W),4(A2,D7.W)
	ADDQ.W	#3,D0
	BRA.L	lbC003276

lbC003344	MOVE.B	2(A0,D0.W),D6
	SUB.B	D6,$2C(A2,D7.W)
	MOVE.B	1(A0,D0.W),4(A2,D7.W)
	ADDQ.W	#3,D0
	BRA.L	lbC003276

lbC003358	TST.B	8(A2,D7.W)
	BEQ.S	lbC00336A
	SUBQ.B	#1,8(A2,D7.W)
	BNE.S	lbC003370
	ADDQ.W	#3,D0
	BRA.L	lbC003276

lbC00336A	MOVE.B	1(A0,D0.W),8(A2,D7.W)
lbC003370	MOVE.B	2(A0,D0.W),D6
	MOVE.B	D6,D0
	ADD.B	D6,D6
	ADD.B	D6,D0
	BRA.L	lbC003276

lbC00337E	MOVE.B	2(A0,D0.W),-4(A2,D7.W)
	ADDQ.W	#3,D0
	BRA.L	lbC003260

lbC00338A	MOVE.B	2(A0,D0.W),-4(A2,D7.W)
	MOVE.B	1(A0,D0.W),4(A2,D7.W)
	ADDQ.W	#3,D0
	BRA.L	lbC003276

lbC00339C	MOVE.B	2(A0,D0.W),-8(A2,D7.W)
	CLR.B	-12(A2,D7.W)
	ADDQ.W	#3,D0
	BRA.L	lbC003260

lbC0033AC	MOVE.B	1(A0,D0.W),$5E(A2)
	MOVE.B	2(A0,D0.W),$5F(A2)
	MOVE.B	#1,$60(A2)

	bsr.w	SongEnd

	BRA.L	lbC00327A

lbC0033C2

	bsr.w	SongEnd

	CLR.B	$5D(A2)
	BRA.L	lbC00327A

lbC0033CA	MOVE.B	#1,$60(A2)
	BRA.L	lbC00327A

lbC0033D4	MOVE.L	-$38(A2),D5
	MOVEA.L	-$24(A2),A1
	MOVEQ	#0,D6
	MOVE.B	2(A0,D0.W),D6
	ADD.W	D6,D6
	MOVE.W	0(A1,D6.W),D6
	ADD.L	D6,D5
	MOVE.L	D7,D6
	ADD.B	D6,D6
	ADD.B	D6,D6
	MOVE.L	D5,-$4C(A2,D6.W)
	MOVE.B	1(A0,D0.W),D6
	MOVE.B	D6,D0
	ADD.B	D6,D6
	ADD.B	D6,D0
	BRA.L	lbC003276

lbC003402	MOVE.B	2(A0,D0.W),$7C(A2)
	ADDQ.W	#3,D0
	BRA.L	lbC003260

lbC00340E	MOVE.B	1(A0,D0.W),$30(A2)
	MOVE.B	2(A0,D0.W),$31(A2)
	ADDQ.W	#3,D0
	BRA.L	lbC003260

lbC003420	MOVE.B	2(A0,D0.W),$33(A2)
	ADDQ.W	#3,D0
	BRA.L	lbC003260

lbC00342C	MOVEA.L	-$30(A2),A0
	MOVEQ	#0,D0
	MOVE.B	$62(A2),D0
	ADDA.L	D0,A0
	MOVE.B	$63(A2),D0
	CMPI.B	#$FF,0(A0,D0.W)
	BNE.S	lbC00344A
	CLR.B	$63(A2)
	MOVEQ	#0,D0
lbC00344A	MOVE.B	0(A0,D0.W),$61(A2)
	ADDQ.B	#1,$63(A2)
lbC003454	MOVEA.L	-$20(A2),A1
	LEA	lbL003964(PC),A0
	MOVEQ	#8,D3
	MOVEQ	#3,D1
lbC003460	SUBQ.L	#4,A0
	SUBQ.W	#2,D3
	MOVEQ	#0,D0
	MOVE.B	$10(A2,D1.W),D0
	BNE.S	lbC00347A
	MOVE.B	$65(A2,D3.W),D0
	BNE.S	lbC0034C4
	DBRA	D1,lbC003460
	BRA.L	lbC00350C

lbC00347A	MOVEA.L	-$34(A2),A4
	ADD.W	D0,D0
	MOVE.W	0(A1,D0.W),D0
	ADDA.L	D0,A4
	MOVE.B	(A4),D2
	MOVEA.L	(A0),A5
	CMP.B	(A5),D2
	BCS.S	lbC0034B8
	MOVE.L	A4,(A0)
	CLR.B	-$18(A2,D1.W)
	CLR.B	-$14(A2,D1.W)
	CLR.B	-4(A2,D1.W)
	CLR.B	$14(A2,D1.W)
	CLR.B	$18(A2,D1.W)
	CLR.B	$1C(A2,D1.W)
	CLR.W	$20(A2,D3.W)
	CLR.W	$38(A2,D3.W)
	CLR.B	$28(A2,D1.W)
	CLR.B	$34(A2,D1.W)
lbC0034B8	MOVE.B	$65(A2,D3.W),D0
	BNE.S	lbC00350C
	DBRA	D1,lbC003460
	BRA.S	lbC00350C

lbC0034C4	MOVEA.L	-$34(A2),A4
	ADD.W	D0,D0
	MOVE.W	0(A1,D0.W),D0
	ADDA.L	D0,A4
	MOVE.B	(A4),D2
	MOVEA.L	(A0),A5
	CMP.B	(A5),D2
	BCS.S	lbC003508
	MOVE.L	A4,(A0)
	CLR.B	-$18(A2,D1.W)
	CLR.B	-$14(A2,D1.W)
	CLR.B	-12(A2,D1.W)
	CLR.B	-8(A2,D1.W)
	CLR.B	-4(A2,D1.W)
	CLR.B	$14(A2,D1.W)
	CLR.B	$18(A2,D1.W)
	CLR.B	$1C(A2,D1.W)
	CLR.B	$34(A2,D1.W)
	CLR.W	$38(A2,D3.W)
	MOVE.B	#1,$28(A2,D1.W)
lbC003508	DBRA	D1,lbC003460
lbC00350C	CLR.L	$10(A2)
	LEA	(A2),A1
	MOVEQ	#3,D0
lbC003514	SUBQ.L	#2,A1
	TST.B	$28(A2,D0.W)
	BEQ.S	lbC00352C
	CLR.W	$28(A1)
	MOVE.B	$75(A1),$2C(A2,D0.W)
	MOVE.B	#$32,12(A2,D0.W)
lbC00352C	CLR.B	$6D(A1)
	DBRA	D0,lbC003514
	LEA	lbL003964(PC),A3
	LEA	lbW003B38(PC),A1
	LEA	lbC003586(PC),A6
	MOVEQ	#$10,D2
	MOVEQ	#$40,D4
	MOVEQ	#3,D7
lbC003546	SUBI.B	#$10,D4
	LSR.B	#1,D2
	MOVEA.L	-(A3),A0
	ADDQ.L	#4,A0
	MOVEQ	#0,D0
	MOVE.B	$14(A2,D7.W),D0
	TST.B	$18(A2,D7.W)
	BEQ.S	lbC003568
	SUBQ.B	#1,$18(A2,D7.W)
	DBRA	D7,lbC003546
	BRA.L	lbC003770

lbC003568	MOVE.B	0(A0,D0.W),D3
	MOVEQ	#0,D6
	MOVE.B	0(A1,D3.W),D6
	ADD.W	D6,D6
	ADD.W	D6,D6
	LEA	lbL003C38(PC),A5
	MOVE.L	0(A5,D6.W),D6
	JMP	0(A6,D6.W)

lbC003582	MOVE.B	D0,$14(A2,D7.W)
lbC003586	DBRA	D7,lbC003546
	BRA.L	lbC003770

lbC00358E
;	LEA	$DFF0A6,A4
;	MOVE.W	#$50,0(A4,D4.W)			; period

	movem.l	D0/D1/A5,-(SP)
	move.l	EagleBase(PC),A5
	move.w	D4,D1
	lsr.w	#4,D1		;Number the channel from 0-3
	moveq	#$50,D0
	jsr	ENPP_PokePer(A5)
	movem.l	(SP)+,D0/D1/A5

	MOVEQ	#0,D6
	MOVE.B	3(A0,D0.W),D6
	ADD.W	D6,D6
	ADD.W	D6,D6
	MOVEA.L	-$1C(A2),A5
	MOVE.L	D7,D5
	ADD.W	D5,D5
	ADD.W	D5,D5
	MOVE.L	0(A5,D6.W),D6
	ADD.L	-$28(A2),D6
	MOVE.L	D6,-$5C(A2,D5.W)
;	MOVE.W	D2,$DFF096			; DMA

	move.l	D0,-(SP)
	move.w	D2,D0
	bsr.w	PokeDMA
	move.l	(SP)+,D0

	ADDQ.W	#4,D0
	BRA.S	lbC003568

lbC0035C4	MOVE.L	D7,D5
	ADD.W	D5,D5
	ADD.W	D5,D5
	MOVEQ	#0,D6
	MOVE.W	2(A0,D0.W),D6
	ADD.L	D6,-$5C(A2,D5.W)
	ADDQ.W	#4,D0
	BRA.S	lbC003568

lbC0035D8	MOVE.L	0(A0,D0.W),D6
	LSR.L	#1,D6
	MOVE.L	D7,D5
	ADD.B	D5,D5
	MOVE.W	D6,$50(A2,D5.W)
	ADDQ.W	#4,D0
	BRA.S	lbC003582

lbC0035EA	MOVEQ	#0,D6
	MOVE.B	3(A0,D0.W),D6
	ADD.W	D6,D6
	ADD.W	D6,D6
	MOVEA.L	-$1C(A2),A5
	MOVE.L	D7,D5
	ADD.W	D5,D5
	ADD.W	D5,D5
	MOVE.L	0(A5,D6.W),D6
	ADD.L	-$28(A2),D6
	MOVE.L	D6,-$5C(A2,D5.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003568

lbC003610	MOVE.L	D7,D5
	ADD.W	D5,D5
	ADD.W	D5,D5
	MOVEQ	#0,D6
	MOVE.W	2(A0,D0.W),D6
	SUB.L	D6,-$5C(A2,D5.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003568

lbC003626	MOVE.B	2(A0,D0.W),$18(A2,D7.W)
	MOVE.B	3(A0,D0.W),$34(A2,D7.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003582

lbC003638	MOVE.B	2(A0,D0.W),$18(A2,D7.W)
	MOVE.B	3(A0,D0.W),D6
	ADD.B	D6,$34(A2,D7.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003582

lbC00364C	MOVE.B	2(A0,D0.W),$18(A2,D7.W)
	MOVE.B	3(A0,D0.W),D6
	SUB.B	D6,$34(A2,D7.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003582

lbC003660	MOVE.B	3(A0,D0.W),$34(A2,D7.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003568

lbC00366C	MOVE.B	3(A0,D0.W),D6
	ADD.B	D6,$34(A2,D7.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003568

lbC00367A	MOVE.B	3(A0,D0.W),D6
	SUB.B	D6,$34(A2,D7.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003568

lbC003688	MOVE.B	2(A0,D0.W),$18(A2,D7.W)
	MOVE.L	D7,D6
	ADD.B	D6,D6
	MOVEQ	#0,D5
	MOVE.B	3(A0,D0.W),D5
	SUB.W	D5,$38(A2,D6.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003582

lbC0036A2	MOVE.B	2(A0,D0.W),$18(A2,D7.W)
	MOVE.L	D7,D6
	ADD.B	D6,D6
	MOVEQ	#0,D5
	MOVE.B	3(A0,D0.W),D5
	ADD.W	D5,$38(A2,D6.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003582

lbC0036BC	MOVE.L	D7,D6
	ADD.B	D6,D6
	MOVEQ	#0,D5
	MOVE.B	3(A0,D0.W),D5
	SUB.W	D5,$38(A2,D6.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003568

lbC0036D0	MOVE.L	D7,D6
	ADD.B	D6,D6
	MOVEQ	#0,D5
	MOVE.B	3(A0,D0.W),D5
	ADD.W	D5,$38(A2,D6.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003568

lbC0036E4	MOVE.B	3(A0,D0.W),-$18(A2,D7.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003568

lbC0036F0	MOVE.B	3(A0,D0.W),$18(A2,D7.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003582

lbC0036FC	MOVE.B	2(A0,D0.W),D5
	CMP.B	-4(A2,D7.W),D5
	BNE.S	lbC003716
	CLR.B	-4(A2,D7.W)
	MOVE.B	3(A0,D0.W),D0
	ADD.B	D0,D0
	ADD.B	D0,D0
	BRA.L	lbC003568

lbC003716	ADDQ.W	#4,D0
	BRA.L	lbC003582

lbC00371C	MOVE.B	3(A0,D0.W),-8(A2,D7.W)
	CLR.B	-12(A2,D7.W)
	ADDQ.W	#4,D0
	BRA.L	lbC003568

lbC00372C	TST.B	$1C(A2,D7.W)
	BEQ.S	lbC00373E
	SUBQ.B	#1,$1C(A2,D7.W)
	BNE.S	lbC003744
	ADDQ.W	#4,D0
	BRA.L	lbC003582

lbC00373E	MOVE.B	2(A0,D0.W),$1C(A2,D7.W)
lbC003744	MOVE.B	3(A0,D0.W),D0
	ADD.B	D0,D0
	ADD.B	D0,D0
	BRA.L	lbC003582

lbC003750	MOVE.L	D7,D5
	ADD.B	D5,D5
	ADD.B	D5,D5
	MOVE.L	-$34(A2),$40(A2,D5.W)
	CLR.B	$28(A2,D7.W)
	MOVEQ	#0,D0
	BRA.L	lbC003582

lbC003766	MOVE.B	3(A0,D0.W),$10(A2,D7.W)
	BRA.L	lbC003586

lbC003770	TST.B	$33(A2)
	BEQ.S	lbC0037BC
	TST.B	$32(A2)
	BEQ.S	lbC003782
	SUBQ.B	#1,$32(A2)
	BRA.S	lbC0037BC

lbC003782	MOVE.B	$31(A2),$32(A2)
	MOVE.B	$30(A2),D0
	SUB.B	D0,$5C(A2)
	BPL.S	lbC0037BC
	MOVEQ	#0,D0
	MOVE.B	$33(A2),D0
	SUBQ.B	#1,D0
	ASL.W	#1,D0
	MOVEA.L	-$60(A2),A1
	MOVE.W	0(A1,D0.W),$5E(A2)
	CLR.B	$33(A2)
	CLR.B	$32(A2)
	CLR.B	$5C(A2)
	MOVE.B	#1,$60(A2)
	CLR.B	$61(A2)
lbC0037BC	MOVEQ	#0,D6
	MOVE.B	$5C(A2),D6
	LEA	$DFF0E0,A0
	MOVEA.L	-$2C(A2),A1
	LEA	lbW003992(PC),A4
	LEA	lbL00393C(PC),A6
	MOVEQ	#0,D3
	MOVEQ	#3,D0
lbC0037D8	LEA	-$10(A0),A0
	MOVEQ	#0,D1
	MOVE.B	$2C(A2,D0.W),D1
	ADD.B	$34(A2,D0.W),D1
	BPL.S	lbC0037EE
;	CLR.B	9(A0)				; volume

	move.l	D0,-(SP)
	moveq	#0,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

	BRA.S	lbC0037F6

lbC0037EE	MULU.W	D6,D1
	LSR.W	#6,D1
;	MOVE.B	D1,9(A0)			; volume

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokeVol
	move.l	(SP)+,D0

lbC0037F6	MOVEQ	#0,D2
	MOVE.B	-$18(A2,D0.W),D2
	BEQ.S	lbC00380E
	ADD.B	D2,D2
;	MOVE.W	0(A4,D2.W),6(A0)		; period

	move.l	D0,-(SP)
	move.w	0(A4,D2.W),D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	SUBQ.L	#2,A6
	DBRA	D0,lbC0037D8
	BRA.S	lbC003878

lbC00380E	MOVE.B	-8(A2,D0.W),D2
	ADD.B	-12(A2,D0.W),D2
	CMPI.B	#$80,0(A1,D2.W)
	BNE.S	lbC003826
	CLR.B	-12(A2,D0.W)
	MOVE.B	-8(A2,D0.W),D2
lbC003826	MOVE.B	0(A1,D2.W),D2
	ADD.B	D2,D2
	ADDQ.B	#1,-12(A2,D0.W)
	MOVEQ	#0,D1
	MOVE.B	12(A2,D0.W),D1
	ADD.B	D2,D1
	MOVE.W	0(A4,D1.W),D1
	MOVE.B	-$10(A2,D0.W),D3
	MOVE.W	0(A4,D3.W),D2
	MOVE.B	-$14(A2,D0.W),D3
	SUB.W	D1,D2
	MOVE.W	D2,D4
	SUB.W	-(A6),D4
	BPL.S	lbC00385E
	SUB.W	D3,(A6)
	CMP.W	(A6),D2
	BLT.S	lbC00386A
	CLR.B	-$14(A2,D0.W)
	MOVE.W	D2,(A6)
	BRA.S	lbC00386A

lbC00385E	ADD.W	D3,(A6)
	CMP.W	(A6),D2
	BGT.S	lbC00386A
	CLR.B	-$14(A2,D0.W)
	MOVE.W	D2,(A6)
lbC00386A	ADD.W	(A6),D1
	ADD.W	$18(A6),D1
;	MOVE.W	D1,6(A0)			; period

	move.l	D0,-(SP)
	move.w	D1,D0
	bsr.w	PokePer
	move.l	(SP)+,D0

	DBRA	D0,lbC0037D8
lbC003878

;	LEA	$DFF096,A0
;	MOVE.L	-$5C(A2),10(A0)			; address
;	MOVE.L	-$58(A2),$1A(A0)
;	MOVE.L	-$54(A2),$2A(A0)
;	MOVE.L	-$50(A2),$3A(A0)
;	MOVE.W	$50(A2),14(A0)			; length
;	MOVE.W	$52(A2),$1E(A0)
;	MOVE.W	$54(A2),$2E(A0)
;	MOVE.W	$56(A2),$3E(A0)
;	MOVE.W	#$820F,(A0)			; DMA

	movem.l	D0/D1/A5,-(SP)
	move.l	EagleBase(PC),A5
	moveq	#0,D1				; channel 0
	move.l	-$5C(A2),D0
	jsr	ENPP_PokeAdr(A5)
	moveq	#0,D0
	move.w	$50(A2),D0
	jsr	ENPP_PokeLen(A5)
	moveq	#1,D1				; channel 1
	move.l	-$58(A2),D0
	jsr	ENPP_PokeAdr(A5)
	moveq	#0,D0
	move.w	$52(A2),D0
	jsr	ENPP_PokeLen(A5)
	moveq	#2,D1				; channel 2
	move.l	-$54(A2),D0
	jsr	ENPP_PokeAdr(A5)
	moveq	#0,D0
	move.w	$54(A2),D0
	jsr	ENPP_PokeLen(A5)
	moveq	#3,D1				; channel 3
	move.l	-$50(A2),D0
	jsr	ENPP_PokeAdr(A5)
	moveq	#0,D0
	move.w	$56(A2),D0
	jsr	ENPP_PokeLen(A5)
	move.w	#$820F,D0
	bsr.w	PokeDMA
	movem.l	(SP)+,D0/D1/A5

	RTS

lbL0038B4	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL0038D8	dc.l	0
lbL0038DC	dc.l	0
lbL0038E0	dc.l	0
lbL0038E4	dc.l	0
lbL0038E8	dc.l	0
lbL0038EC	dc.l	0
lbL0038F0	dc.l	0
lbL0038F4	dc.l	0
lbL0038F8	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL003914	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL00393C	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL003954	dc.l	0
lbL003958	dc.l	0
lbL00395C	dc.l	0
lbL003960	dc.l	0
lbL003964	dc.l	0
	dc.l	0
	dc.l	0
	dc.b	0
lbB003971	dc.b	0
lbW003972	dc.w	0
lbB003974	dc.b	0
lbB003975	dc.b	0
	dc.b	0
lbB003977	dc.b	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbB003990	dc.b	0
	dc.b	0
lbW003992	dc.w	$FFFF
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
lbW0039DC	dc.w	1
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$101
	dc.w	$100
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	2
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$202
	dc.w	$200
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$304
	dc.w	$506
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$700
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$809
	dc.w	$A0B
	dc.w	$1500
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$D0E
	dc.w	$1400
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$F00
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$1600
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
	dc.w	$C13
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$1011
	dc.w	$1200
lbL003ADC	dc.l	lbC00327A-lbC00327A
	dc.l	lbC003282-lbC00327A
	dc.l	lbC00329E-lbC00327A
	dc.l	lbC0032C4-lbC00327A
	dc.l	lbC0032CE-lbC00327A
	dc.l	lbC0032DC-lbC00327A
	dc.l	lbC0032EA-lbC00327A
	dc.l	lbC0032F8-lbC00327A
	dc.l	lbC003312-lbC00327A
	dc.l	lbC00331E-lbC00327A
	dc.l	lbC003330-lbC00327A
	dc.l	lbC003344-lbC00327A
	dc.l	lbC003358-lbC00327A
	dc.l	lbC00337E-lbC00327A
	dc.l	lbC00338A-lbC00327A
	dc.l	lbC00339C-lbC00327A
	dc.l	lbC0033AC-lbC00327A
	dc.l	lbC0033C2-lbC00327A
	dc.l	lbC0033CA-lbC00327A
	dc.l	lbC0033D4-lbC00327A
	dc.l	lbC003402-lbC00327A
	dc.l	lbC00340E-lbC00327A
	dc.l	lbC003420-lbC00327A
lbW003B38	dc.w	1
	dc.w	$203
	dc.w	$405
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$607
	dc.w	$800
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$90A
	dc.w	$B00
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$C0D
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$E0F
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$1000
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
	dc.w	$1100
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
	dc.w	$1200
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$1300
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
	dc.w	$1400
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	$1615
lbL003C38	dc.l	lbC003586-lbC003586
	dc.l	lbC00358E-lbC003586
	dc.l	lbC0035C4-lbC003586
	dc.l	lbC0035D8-lbC003586
	dc.l	lbC0035EA-lbC003586
	dc.l	lbC003610-lbC003586
	dc.l	lbC003626-lbC003586
	dc.l	lbC003638-lbC003586
	dc.l	lbC00364C-lbC003586
	dc.l	lbC003660-lbC003586
	dc.l	lbC00366C-lbC003586
	dc.l	lbC00367A-lbC003586
	dc.l	lbC003688-lbC003586
	dc.l	lbC0036A2-lbC003586
	dc.l	lbC0036BC-lbC003586
	dc.l	lbC0036D0-lbC003586
	dc.l	lbC0036E4-lbC003586
	dc.l	lbC0036F0-lbC003586
	dc.l	lbC0036FC-lbC003586
	dc.l	lbC00371C-lbC003586
	dc.l	lbC00372C-lbC003586
	dc.l	lbC003750-lbC003586
	dc.l	lbC003766-lbC003586
