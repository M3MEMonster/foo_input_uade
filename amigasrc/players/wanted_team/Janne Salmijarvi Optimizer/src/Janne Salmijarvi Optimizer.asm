	*****************************************************
	****   Janne Salmijarvi Optimizer replayer for	 ****
	****  EaglePlayer all adaptions by Wanted Team,	 ****
	****     DeliTracker compatible (?) version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Janne Salmijarvi Optimizer player module V1.0 (22 Apr 2014)',0
	even
Tags
	dc.l	DTP_PlayerVersion,1
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,DELIVERSION
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_Get_ModuleInfo,Get_ModuleInfo
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_Flags,EPB_Save!EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
	dc.l	DTP_DeliBase,DeliBase
	dc.l	EP_EagleBase,Eagle2Base
	dc.l	0

PlayerName
	dc.b	'Janne Salmijarvi Optimizer',0
Creator
	dc.b	'(c) 1992 by Janne Salmijarvi,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'JS.',0
	even
DeliBase
	dc.l	0
Eagle2Base
	dc.l	0
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
SamplesPtr
	dc.l	0
RightVolume
	dc.w	64
LeftVolume
	dc.w	64
Voice1
	dc.w	1
Voice2
	dc.w	1
Voice3
	dc.w	1
Voice4
	dc.w	1
OldVoice1
	dc.w	0
OldVoice2
	dc.w	0
OldVoice3
	dc.w	0
OldVoice4
	dc.w	0
StructAdr
	ds.b	UPS_SizeOF

***************************************************************************
****************************** EP_PatternInit *****************************
***************************************************************************

PATTERNINFO:
	DS.B	PI_Stripes	; This is the main structure

* Here you store the address of each "stripe" (track) for the current
* pattern so the PI engine can read the data for each row and send it
* to the CONVERTNOTE function you supply.  The engine determines what
* data needs to be converted by looking at the Pattpos and Modulo fields.

STRIPE1	DS.L	1
STRIPE2	DS.L	1
STRIPE3	DS.L	1
STRIPE4	DS.L	1

* More stripes go here in case you have more than 4 channels.


* Called at various and sundry times (e.g. StartInt, apparently)
* Return PatternInfo Structure in A0
PatternInit
	lea	PATTERNINFO(PC),A0

	moveq	#4,D0
	move.w	D0,PI_Voices(A0)	; Number of stripes (MUST be at least 4)
	move.l	#CONVERTNOTE,PI_Convert(A0)
	moveq	#16,D0
	move.l	D0,PI_Modulo(A0)	; Number of bytes to next row
	move.w	#64,PI_Pattlength(A0)	; Length of each stripe in rows
	move.w	InfoBuffer+Patterns+2(PC),PI_NumPatts(A0)	; Overall Number of Patterns
	clr.w	PI_Pattern(A0)		; Current Pattern (from 0)
	move.w	#6,PI_Speed(A0)		; Default Speed Value
	clr.w	PI_Pattpos(A0)		; Current Position in Pattern (from 0)
	clr.w	PI_Songpos(A0)		; Current Position in Song (from 0)
	move.w	InfoBuffer+Length+2(PC),PI_MaxSongPos(A0)	; Songlength

	move.w	#125,PI_BPM(A0)

	lea	STRIPE1(PC),A1
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A1)+
	clr.l	(A1)
	rts

* Called by the PI engine to get values for a particular row
CONVERTNOTE:


* The command string is a single character.  It is NOT ASCII, howver.
* The character mapping starts from value 0 and supports letters from A-Z

* $00 ~ '0'
* ...
* $09 ~ '9'
* $0A ~ 'A'
* ...
* $0F ~ 'F'
* $10 ~ 'G'
* etc.

	moveq	#0,D1		; Sample number
	move.b	1(A0),D1
	moveq	#0,D2
	move.b	2(A0),D2	; Command string
	moveq	#0,D3		; Command argument
	move.b	3(A0),D3
	moveq	#0,D0
	move.b	(A0),D0		; Period? Note?
	beq.b	Skip
	lea	lbW01172A(PC),A1
	move.w	(A1,D0.W),D0
Skip
	rts

PATINFO
	movem.l	D0/A0-A2,-(SP)
	lea	PATTERNINFO(PC),A0
	lea	lbL011C5C(PC),A1
	move.b	4(A1),PI_Speed+1(A0)		; Speed Value
	move.w	14(A1),D0
	lsr.w	#4,D0
	move.w	D0,PI_Pattpos(A0)		; Current Position in Pattern
	moveq	#0,D0
	move.b	6(A1),D0
	move.w	D0,PI_Songpos(A0)
	move.l	ModulePtr(PC),A2
	lea	952(A2),A2
	move.b	(A2,D0.W),D0
	move.w	D0,PI_Pattern(A0)	; Current Pattern
	lea	132(A2),A1
	moveq	#10,D1
	lsl.l	D1,D0
	add.l	D0,A1
	move.l	A1,PI_Stripes(A0)	; STRIPE1
	addq.l	#4,A1			; Distance to next stripe
	move.l	A1,PI_Stripes+4(A0)	; STRIPE2
	addq.l	#4,A1
	move.l	A1,PI_Stripes+8(A0)	; STRIPE3
	addq.l	#4,A1
	move.l	A1,PI_Stripes+12(A0)	; STRIPE4
	movem.l	(SP)+,D0/A0-A2
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	ModulePtr(PC),D0
	beq.b	return
	move.l	D0,A2

	lea	20(A2),A2
	move.l	SamplesPtr(PC),A1
	moveq	#30,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	moveq	#0,D0
	move.w	22(A2),D0
	add.l	D0,D0
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.l	A2,EPS_SampleName(A3)		; sample name
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#22,EPS_MaxNameLen(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	lea	30(A2),A2
	add.l	D0,A1
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************
Next_Pattern
	lea	lbL011C5C(PC),A0
	moveq	#0,D0
	move.b	6(A0),D0
	addq.b	#1,D0
	cmp.w	InfoBuffer+Length+2(PC),D0
	beq.b	MaxPos
	addq.b	#1,6(A0)
	move.b	7(A0),D0
	lsl.w	#4,D0
	move.w	D0,14(A0)
	clr.b	7(A0)
	clr.b	8(A0)
MaxPos
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	lea	lbL011C5C(PC),A0
	moveq	#0,D0
	move.b	6(A0),D0
	beq.b	MinPos
	subq.b	#1,6(A0)
	move.b	7(A0),D0
	lsl.w	#4,D0
	move.w	D0,14(A0)
	clr.b	7(A0)
	clr.b	8(A0)
MinPos
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

Get_ModuleInfo
	lea	InfoBuffer(PC),A0
	rts

LoadSize	=	4
Samples		=	12
Length		=	20
SamplesSize	=	28
SongSize	=	36
CalcSize	=	44
Patterns	=	52
Unpacked	=	60
Author		=	68
Name		=	76

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Samples,0		;12
	dc.l	MI_Length,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Songsize,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_Pattern,0		;52
	dc.l	MI_Unpacked,0		;60
	dc.l	MI_AuthorName,0		;68
	dc.l	MI_SongName,0		;76
	dc.l	MI_UnPackedSystem,MIUS_ProTracker
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxSamples,31
	dc.l	MI_MaxPattern,64
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	move.l	dtg_ChkSize(A5),D1
	cmp.l	#1084+1024+4,D1
	ble.b	Fault

	cmp.l	#'JS92',1080(A0)
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
	move.l	A0,(A6)+			; module buffer
	move.l	A5,(A6)+			; EagleBase

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	move.l	A0,Name(A4)

	lea	lbL011C72(PC),A2
	move.l	A0,(A2)
	lea	1084(A0),A1
	lea	lbL011C76(PC),A2
	move.l	A1,(A2)

	lea	42(A0),A1
	moveq	#30,D0
	moveq	#0,D1
	moveq	#0,D2
	moveq	#0,D3
NextInfo
	move.w	(A1),D1
	beq.b	Empty
	addq.l	#1,D2
	add.l	D1,D3
Empty
	lea	30(A1),A1
	dbf	D0,NextInfo
	add.l	D3,D3
	move.l	D3,SamplesSize(A4)
	move.l	D2,Samples(A4)
	lea	950(A0),A1
	move.b	(A1)+,D2
	move.l	D2,Length(A4)
	move.b	(A1)+,D2
	moveq	#0,D0
Loop
	cmp.b	(A1)+,D0
	bge.b	NextByte
	move.b	-1(A1),D0
NextByte
	dbf	D2,Loop
	addq.l	#1,D0
	move.l	D0,Patterns(A4)
	moveq	#10,D1
	lsl.l	D1,D0
	add.l	#1084,D0
	move.l	D0,SongSize(A4)
	add.l	D0,A0
	move.l	A0,(A6)				; SamplesPtr

	lea	lbL011C7A(PC),A2
	move.l	A0,(A2)
;	lea	lbW011C7E(PC),A2
;	move.w	#$40,(A2)			; master volume

	add.l	D0,D3
	move.l	D3,CalcSize(A4)
	cmp.l	LoadSize(A4),D3
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	clr.w	(A0)				; empty sample
	move.l	D3,Unpacked(A4)

	move.l	Eagle2Base(PC),D0
	bne.b	Eagle2
	move.l	DeliBase(PC),D0
	bne.b	NoName
Eagle2
	bsr.b	FindName
NoName

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

FindName
	move.l	ModulePtr(PC),A0
	lea	20(A0),A1			; A1 - begin sampleinfo
	move.l	A1,EPG_ARG1(A5)
	moveq	#30,D0				; D0 - length per one sampleinfo
	move.l	D0,EPG_ARG2(A5)
	moveq	#22,D0				; D0 - max. sample name
	move.l	D0,EPG_ARG3(A5)
	moveq	#31,D0				; D0 - max. samples number
	move.l	D0,EPG_ARG4(A5)
	moveq	#4,D0
	move.l	D0,EPG_ARGN(A5)
	jsr	ENPP_FindAuthor(A5)
	move.l	EPG_ARG1(A5),Author(A4)		; output
	rts

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	movea.l	dtg_AudioFree(A5),A0
	jmp	(A0)

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.b	lbL011C5C+6(PC),D0
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
	lsr.w	#6,D0				; durch 64
	move.w	D0,LeftVolume

	move.w	dtg_SndRBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0				; durch 64
	move.w	D0,RightVolume			; Right Volume

	lea	OldVoice1(PC),A1
	moveq	#3,D1
	lea	$DFF0A0,A5
SetNew
	move.w	(A1)+,D0
	bsr.b	ChangeVolume
	lea	16(A5),A5
	dbf	D1,SetNew
	rts

ChangeVolume
	and.w	#$7F,D0
	cmpa.l	#$DFF0A0,A5			;Left Volume
	bne.b	NoVoice1
	move.w	D0,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D0
Voice1On
	mulu.w	LeftVolume(PC),D0
	bra.b	SetIt
NoVoice1
	cmpa.l	#$DFF0B0,A5			;Right Volume
	bne.b	NoVoice2
	move.w	D0,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D0
Voice2On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt
NoVoice2
	cmpa.l	#$DFF0C0,A5			;Right Volume
	bne.b	NoVoice3
	move.w	D0,OldVoice3
	tst.w	Voice3
	bne.b	Voice3On
	moveq	#0,D0
Voice3On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt
NoVoice3
	move.w	D0,OldVoice4
	tst.w	Voice4
	bne.b	Voice4On
	moveq	#0,D0
Voice4On
	mulu.w	LeftVolume(PC),D0
SetIt
	lsr.w	#6,D0
	move.w	D0,8(A5)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
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
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Two -------------------------------*

SetTwo
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	4(A6),(A0)
	move.w	8(A6),UPS_Voice1Len(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set Per -------------------------------*

SetPer
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Per(PC),A0
	cmp.l	#$DFF0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Per(PC),A0
	cmp.l	#$DFF0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Per(PC),A0
	cmp.l	#$DFF0C0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Per(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

***************************************************************************
**************************** EP_Voices ************************************
***************************************************************************

SetVoices
	lea	Voice1(PC),A0
	lea	StructAdr(PC),A1
	moveq	#1,D1
	move.w	D1,(A0)+			Voice1=0 setzen
	btst	#0,D0
	bne.b	No_Voice1
	clr.w	-2(A0)
	clr.w	$DFF0A8
	clr.w	UPS_Voice1Vol(A1)
No_Voice1
	move.w	D1,(A0)+			Voice2=0 setzen
	btst	#1,D0
	bne.b	No_Voice2
	clr.w	-2(A0)
	clr.w	$DFF0B8
	clr.w	UPS_Voice2Vol(A1)
No_Voice2
	move.w	D1,(A0)+			Voice3=0 setzen
	btst	#2,D0
	bne.b	No_Voice3
	clr.w	-2(A0)
	clr.w	$DFF0C8
	clr.w	UPS_Voice3Vol(A1)
No_Voice3
	move.w	D1,(A0)+			Voice4=0 setzen
	btst	#3,D0
	bne.b	No_Voice4
	clr.w	-2(A0)
	clr.w	$DFF0D8
	clr.w	UPS_Voice4Vol(A1)
No_Voice4
	move.w	D0,UPS_DMACon(A1)	;Stimme an = Bit gesetzt
					;Bit 0 = Kanal 1 usw.
	moveq	#0,D0
	rts

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

	move.l	Timer(PC),D0
	bne.b	TimerSet
	moveq	#125,D0
	mulu.w	dtg_Timer(A5),D0
	lea	Timer(PC),A0
	move.l	D0,(A0)
TimerSet
	lea	OldVoice1(PC),A0
	clr.l	(A0)+
	clr.l	(A0)

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
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

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
********************* Janne Salmijarvi Optimizer player *******************
***************************************************************************

; Player from music disk "A Taste Of U4IA" (c) 1992 by Megawatts

Timer
lbL000D8A	dc.l	0

;lbC0109EC	RTS

Play
;lbC0109EE	TST.B	lbB011C69
;	BEQ.L	lbC0109EC
;	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVEQ	#0,D0
	LEA	lbL011C5C(PC),A2
	LEA	lbL011C6E(PC),A4
	MOVE.B	(A4),D0
	BNE.L	lbC010A14
	BSR.L	lbC010BCC
	BRA.L	lbC010A68

lbC010A14	CMP.B	#3,D0
	BEQ.L	lbC010A68
	TST.W	2(A4)
	BEQ.L	lbC010A44
	CMP.B	#1,D0
	BNE.L	lbC010A34
	BSR.L	lbC010A8A
	BRA.L	lbC010A68

lbC010A34	CMP.B	#2,D0
	BNE.L	lbC010A68
	BSR.L	lbC010ADA
	BRA.L	lbC010A68

lbC010A44	TST.W	$10(A2)
	BEQ.L	lbC010A68
	CMP.B	#1,D0
	BNE.L	lbC010A5C
	BSR.L	lbC010A7A
	BRA.L	lbC010A68

lbC010A5C	CMP.B	#2,D0
	BNE.L	lbC010A68
	BSR.L	lbC010A9A
lbC010A68	LEA	lbL011C6E(PC),A4
	ADDI.B	#1,(A4)
	ANDI.B	#3,(A4)
;	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

lbC010A7A	MOVE.W	$10(A2),D0
	ORI.W	#$8000,D0
	MOVE.W	D0,$DFF096			; DMA on
	RTS

lbC010A8A	ORI.W	#$8000,2(A4)
	MOVE.W	2(A4),$DFF096			; DMA on
	RTS

lbC010A9A	LEA	$DFF000,A5
	LEA	lbL011BAC(PC),A6
	MOVE.L	10(A6),$A0(A5)			; address
	MOVE.W	14(A6),$A4(A5)			; length
	MOVE.L	$36(A6),$B0(A5)			; address
	MOVE.W	$3A(A6),$B4(A5)			; length
	MOVE.L	$62(A6),$C0(A5)			; address
	MOVE.W	$66(A6),$C4(A5)			; length
	MOVE.L	$8E(A6),$D0(A5)			; address
	MOVE.W	$92(A6),$D4(A5)			; length
	CLR.W	$10(A2)
	RTS

lbC010ADA	LEA	$DFF0A0,A5
	LEA	lbL011BAC(PC),A6
	BTST	#0,3(A4)
	BEQ.L	lbC010AF8
	MOVE.L	10(A6),(A5)			; address
	MOVE.W	14(A6),4(A5)			; length
lbC010AF8	BTST	#1,3(A4)
	BEQ.L	lbC010B0E
	MOVE.L	$36(A6),$10(A5)			; address
	MOVE.W	$3A(A6),$14(A5)			; length
lbC010B0E	BTST	#2,3(A4)
	BEQ.L	lbC010B24
	MOVE.L	$62(A6),$20(A5)			; address
	MOVE.W	$66(A6),$24(A5)			; length
lbC010B24	BTST	#3,3(A4)
	BEQ.L	lbC010B3A
	MOVE.L	$8E(A6),$30(A5)			; address
	MOVE.W	$92(A6),$34(A5)			; length
lbC010B3A	CLR.W	2(A4)
	RTS

Init
lbC010B40	MOVEA.L	lbL011C72(PC),A0	; ModulePtr
	MOVE.L	A0,lbL011C5C
	MOVEA.L	A0,A1
	LEA	$3B8(A1),A1
	MOVEQ	#$7F,D0
	MOVEQ	#0,D1
lbC010B54	MOVE.L	D1,D2
	SUBQ.W	#1,D0
lbC010B58	MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BGT.L	lbC010B54
	DBRA	D0,lbC010B58
	ADDQ.B	#1,D2
	LEA	lbL011C86(PC),A1
	MOVEA.L	lbL011C7A,A2			; SamplesPtr
	MOVEQ	#$1E,D0
lbC010B72	MOVEQ	#0,D1
	MOVE.L	A2,(A1)+
	MOVE.W	$2A(A0),D1
	ASL.L	#1,D1
	ADDA.L	D1,A2
	ADDA.L	#$1E,A0
	DBRA	D0,lbC010B72
	ORI.B	#2,$BFE001
	LEA	lbB011C60(PC),A0
	MOVE.L	#$6000000,(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.W	(A0)
	MOVE.W	#$7D,D0
	BSR.L	lbC01142A
;lbC010BA8	SF	lbB011C69
	LEA	$DFF000,A0
	CLR.W	$A8(A0)
	CLR.W	$B8(A0)
	CLR.W	$C8(A0)
	CLR.W	$D8(A0)
	MOVE.W	#15,$96(A0)
	RTS

lbC010BCC	ADDQ.B	#1,5(A2)
	MOVE.B	5(A2),D0
	CMP.B	4(A2),D0
	BCS.L	lbC010BF0
	CLR.B	5(A2)
	TST.B	12(A2)
	BEQ.L	lbC010C8A
	BSR.L	lbC010BF8
	BRA.L	lbC010EAE

lbC010BF0	BSR.L	lbC010BF8
	BRA.L	lbC010F32

lbC010BF8	LEA	$DFF0A0,A5
	LEA	lbL011BAC(PC),A6
	BSR.L	lbC010C26
	LEA	$10(A5),A5
	LEA	$2C(A6),A6
	BSR.L	lbC010C26
	LEA	$10(A5),A5
	LEA	$2C(A6),A6
	BSR.L	lbC010C26
	LEA	$10(A5),A5
	LEA	$2C(A6),A6
lbC010C26	BSR.L	lbC0116C6
	MOVE.W	2(A6),D0
	BEQ.L	lbC010C42
	MOVEQ	#0,D0
	MOVE.B	2(A6),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVEA.L	lbL010C4A(PC,D0.W),A4
	JMP	(A4)

lbC010C42	MOVE.W	$10(A6),6(A5)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	RTS

lbL010C4A	dc.l	lbC010F5C
	dc.l	lbC01103A
	dc.l	lbC011078
	dc.l	lbC0110A8
	dc.l	lbC011166
	dc.l	lbC011230
	dc.l	lbC011238
	dc.l	lbC011240
	dc.l	lbC01102A
	dc.l	lbC01102A
	dc.l	lbC01135E
	dc.l	lbC01102A
	dc.l	lbC01102A
	dc.l	lbC01102A
	dc.l	lbC0114C2
	dc.l	lbC01102A

lbC010C8A	MOVEA.L	$16(A2),A0
	LEA	12(A0),A3
	LEA	$3B8(A0),A4
	MOVEA.L	$1A(A2),A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	6(A2),D0
	MOVE.B	0(A4,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.W	14(A2),D1
	CLR.W	lbW011C6C
	LEA	$DFF0A0,A5
	LEA	lbL011BAC(PC),A6
	BSR.L	lbC010CEC
	LEA	$10(A5),A5
	LEA	$2C(A6),A6
	BSR.L	lbC010CEC
	LEA	$10(A5),A5
	LEA	$2C(A6),A6
	BSR.L	lbC010CEC
	LEA	$10(A5),A5
	LEA	$2C(A6),A6
	BSR.L	lbC010CEC
	BRA.L	lbC010EAE

lbC010CEA	RTS

lbC010CEC	MOVE.L	0(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	TST.L	(A6)
	BEQ.L	lbC010CEA
	MOVEQ	#0,D2
	MOVE.B	1(A6),D2
	BEQ.L	lbC010DAC
	MOVEQ	#0,D3
	LEA	lbL011C86(PC),A1
	MOVE.W	D2,D4
	SUBQ.W	#1,D2
	ADD.W	D2,D2
	ADD.W	D2,D2
	ADD.W	D4,D4
	MOVE.W	lbW010D54(PC,D4.W),D4
	MOVE.L	0(A1,D2.W),4(A6)
	MOVE.W	0(A3,D4.W),8(A6)
	MOVE.W	0(A3,D4.W),$28(A6)
	MOVE.B	2(A3,D4.W),$12(A6)
	MOVE.B	3(A3,D4.W),$13(A6)
	MOVE.W	6(A3,D4.W),D0
	MOVE.W	D0,14(A6)
	CMP.W	#1,D0
	BNE.L	lbC010D94
;	MOVE.L	lbL011C82(PC),10(A6)

	move.l	SamplesPtr(PC),10(A6)

	MOVE.L	10(A6),$24(A6)
	BRA.L	lbC010DAC

lbW010D54	dc.w	0
	dc.w	$1E
	dc.w	$3C
	dc.w	$5A
	dc.w	$78
	dc.w	$96
	dc.w	$B4
	dc.w	$D2
	dc.w	$F0
	dc.w	$10E
	dc.w	$12C
	dc.w	$14A
	dc.w	$168
	dc.w	$186
	dc.w	$1A4
	dc.w	$1C2
	dc.w	$1E0
	dc.w	$1FE
	dc.w	$21C
	dc.w	$23A
	dc.w	$258
	dc.w	$276
	dc.w	$294
	dc.w	$2B2
	dc.w	$2D0
	dc.w	$2EE
	dc.w	$30C
	dc.w	$32A
	dc.w	$348
	dc.w	$366
	dc.w	$384
	dc.w	$3A2

lbC010D94	MOVEQ	#0,D3
	MOVE.W	4(A3,D4.W),D3
	ADD.W	D3,D3
	MOVE.L	4(A6),10(A6)
	ADD.L	D3,10(A6)
	MOVE.L	10(A6),$24(A6)
lbC010DAC	TST.B	0(A6)
	BEQ.L	lbC01146E
	MOVE.W	2(A6),D0
	LSR.W	#4,D0
	CMP.B	#$E5,D0
	BEQ.L	lbC010DE6
	MOVE.B	2(A6),D0
	CMP.B	#3,D0
	BEQ.L	lbC010DEE
	CMP.B	#5,D0
	BEQ.L	lbC010DEE
	CMP.B	#9,D0
	BNE.L	lbC010E0C
	BSR.L	lbC01146E
	BRA.L	lbC010E0C

lbC010DE6	BSR.L	lbC01154E
	BRA.L	lbC010E0C

lbC010DEE	BSR.L	lbC010FC6
	BSR.L	lbC01146E
	MOVE.B	$13(A6),D0
	ANDI.W	#$FF,D0
;	MULU.W	lbW011C7E(pc),D0
;	LSR.W	#6,D0
;	MOVE.W	D0,8(A5)			; volume

	bsr.w	ChangeVolume
	bsr.w	SetVol

	RTS

lbC010E0C	MOVEQ	#0,D0
	MOVE.B	0(A6),D0
	MOVE.B	D0,$2A(A6)
	LEA	lbW01172A(PC),A1
	ADDA.L	D0,A1
	MOVE.B	$12(A6),D0
	ADD.W	D0,D0
	MOVE.W	lbW010E8E(PC,D0.W),D0
	MOVE.W	0(A1,D0.W),$10(A6)
	MOVE.W	2(A6),D0
	LSR.W	#4,D0
	CMP.B	#$ED,D0
	BEQ.L	lbC01146E
	MOVE.W	$14(A6),$DFF096			; DMA off
	BTST	#2,$1E(A6)
	BNE.L	lbC010E50
	CLR.B	$1B(A6)
lbC010E50	BTST	#6,$1E(A6)
	BNE.L	lbC010E5E
	CLR.B	$1D(A6)
lbC010E5E	MOVE.L	4(A6),(A5)		; address
	MOVE.W	8(A6),4(A5)			; length
	MOVE.W	$10(A6),6(A5)			; period

	bsr.w	SetTwo
	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	MOVE.B	$13(A6),D0
	ANDI.W	#$FF,D0
;	MULU.W	lbW011C7E(pc),D0
;	LSR.W	#6,D0
;	MOVE.W	D0,8(A5)			; volume

	bsr.w	ChangeVolume
	bsr.w	SetVol

	MOVE.W	$14(A6),D0
	OR.W	D0,$10(A2)
	BRA.L	lbC01146E

lbW010E8E	dc.w	0
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

lbC010EAE	ADDI.W	#$10,14(A2)
	MOVE.B	11(A2),D0
	BEQ.L	lbC010EC4
	MOVE.B	D0,12(A2)
	CLR.B	11(A2)
lbC010EC4	TST.B	12(A2)
	BEQ.L	lbC010EDA
	SUBQ.B	#1,12(A2)
	BEQ.L	lbC010EDA
	SUBI.W	#$10,14(A2)
lbC010EDA	TST.B	9(A2)
	BEQ.L	lbC010EF6
	SF	9(A2)
	MOVEQ	#0,D0
	MOVE.B	7(A2),D0
	CLR.B	7(A2)
	LSL.W	#4,D0
	MOVE.W	D0,14(A2)
lbC010EF6	CMPI.W	#$400,14(A2)
	BCS.L	lbC010F32
lbC010F00	MOVEQ	#0,D0
	MOVE.B	7(A2),D0
	LSL.W	#4,D0
	MOVE.W	D0,14(A2)
	CLR.B	7(A2)
	CLR.B	8(A2)
	MOVE.B	6(A2),D1
	ADDQ.B	#1,D1
	ANDI.B	#$7F,D1
	MOVE.B	D1,6(A2)
	MOVEA.L	0(A2),A0
	CMP.B	$3B6(A0),D1
	BCS.L	lbC010F32
	CLR.B	6(A2)

	bsr.w	SongEnd

lbC010F32	TST.B	8(A2)
	BNE.L	lbC010F00

	bsr.w	PATINFO

	RTS

lbW010F3C	dc.w	1
	dc.w	$200
	dc.w	$102
	dc.w	1
	dc.w	$200
	dc.w	$102
	dc.w	1
	dc.w	$200
	dc.w	$102
	dc.w	1
	dc.w	$200
	dc.w	$102
	dc.w	1
	dc.w	$200
	dc.w	$102
	dc.w	1

lbC010F5C	MOVEQ	#0,D0
	MOVE.B	5(A2),D0
	MOVE.B	lbW010F3C(PC,D0.W),D0
	CMP.B	#0,D0
	BEQ.L	lbC010F8E
	CMP.B	#2,D0
	BEQ.L	lbC010F82
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	BRA.L	lbC010F96

lbC010F82	MOVE.B	3(A6),D0
	ANDI.W	#15,D0
	BRA.L	lbC010F96

lbC010F8E	MOVE.W	$10(A6),D2
	BRA.L	lbC010FC0

lbC010F96	ADD.W	D0,D0
	MOVEQ	#0,D1
	MOVE.B	$12(A6),D1
	ADD.W	D1,D1
	MOVE.W	lbW01100A(PC,D1.W),D1
	LEA	lbW01172A(PC),A0
	MOVEQ	#0,D2
	MOVE.B	$2A(A6),D2
	ADD.W	D0,D2
	CMP.W	#$48,D2
	BLS.L	lbC010FBA
	MOVEQ	#$48,D2
lbC010FBA	ADD.W	D1,D2
	MOVE.W	0(A0,D2.W),D2
lbC010FC0	MOVE.W	D2,6(A5)		; period

	move.l	D0,-(SP)
	move.w	D2,D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	RTS

lbC010FC6	MOVE.L	A0,-(SP)
	MOVEQ	#0,D2
	MOVE.B	0(A6),D2
	MOVEQ	#0,D0
	MOVE.B	$12(A6),D0
	ADD.W	D0,D0
	MOVE.W	lbW01100A(PC,D0.W),D0
	LEA	lbW01172A(PC),A0
	ADDA.L	D0,A0
	MOVE.W	0(A0,D2.W),D2
	MOVEA.L	(SP)+,A0
	MOVE.W	D2,$18(A6)
	MOVE.W	$10(A6),D0
	CLR.B	$16(A6)
	CMP.W	D0,D2
	BEQ.L	lbC011004
	BGE.L	lbC011002
	MOVE.B	#1,$16(A6)
lbC011002	RTS

lbC011004	CLR.W	$18(A6)
	RTS

lbW01100A	dc.w	0
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

lbC01102A	RTS

lbC01102C	TST.B	5(A2)
	BNE.L	lbC01102A
	MOVE.B	#15,10(A2)
lbC01103A	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	AND.B	10(A2),D0
	MOVE.B	#$FF,10(A2)
	SUB.W	D0,$10(A6)
	MOVE.W	$10(A6),D0
	CMP.W	#$71,D0
	BGT.L	lbC011060
	MOVE.W	#$71,$10(A6)
lbC011060	MOVE.W	$10(A6),6(A5)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	SetPer
	move.l	(SP)+,D0

lbC011066	RTS

lbC011068	TST.B	lbB011C61
	BNE.L	lbC011066
	MOVE.B	#15,10(A2)
lbC011078	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	AND.B	10(A2),D0
	MOVE.B	#$FF,10(A2)
	ADD.W	D0,$10(A6)
	MOVE.W	$10(A6),D0
	CMP.W	#$358,D0
	BLT.L	lbC01109E
	MOVE.W	#$358,$10(A6)
lbC01109E	MOVE.W	$10(A6),6(A5)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	RTS

lbC0110A6	RTS

lbC0110A8	MOVE.B	3(A6),D0
	BEQ.L	lbC0110B8
	MOVE.B	D0,$17(A6)
	CLR.B	3(A6)
lbC0110B8	MOVE.W	$18(A6),D1
	BEQ.L	lbC0110A6
	MOVEQ	#0,D0
	MOVE.B	$17(A6),D0
	TST.B	$16(A6)
	BNE.L	lbC0110E8
	ADD.W	D0,$10(A6)
	CMP.W	$10(A6),D1
	BGT.L	lbC011102
	MOVE.W	$18(A6),$10(A6)
	CLR.W	$18(A6)
	BRA.L	lbC011102

lbC0110E8	SUB.W	D0,$10(A6)
	MOVE.W	$18(A6),D0
	CMP.W	$10(A6),D0
	BLT.L	lbC011102
	MOVE.W	$18(A6),$10(A6)
	CLR.W	$18(A6)
lbC011102	MOVE.W	$10(A6),D2
	MOVE.B	$1F(A6),D0
	ANDI.B	#15,D0
	BEQ.L	lbC011140
	MOVEQ	#0,D0
	MOVE.B	$12(A6),D0
	ADD.W	D0,D0
	MOVE.W	lbW011146(PC,D0.W),D0
	LEA	lbW01172C(PC),A0
	LEA	0(A0,D0.W),A0
	MOVEQ	#0,D0
lbC011128	CMP.W	0(A0,D0.W),D2
	BCC.L	lbC01113C
	ADDQ.W	#2,D0
	CMP.W	#$48,D0
	BCS.L	lbC011128
	MOVEQ	#$46,D0
lbC01113C	MOVE.W	0(A0,D0.W),D2
lbC011140	MOVE.W	D2,6(A5)		; period

	move.l	D0,-(SP)
	move.w	D2,D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	RTS

lbW011146	dc.w	0
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

lbC011166	MOVE.B	3(A6),D0
	BEQ.L	lbC011196
	MOVE.B	$1A(A6),D2
	ANDI.B	#15,D0
	BEQ.L	lbC011180
	ANDI.B	#$F0,D2
	OR.B	D0,D2
lbC011180	MOVE.B	3(A6),D0
	ANDI.B	#$F0,D0
	BEQ.L	lbC011192
	ANDI.B	#15,D2
	OR.B	D0,D2
lbC011192	MOVE.B	D2,$1A(A6)
lbC011196	MOVE.B	$1B(A6),D0
	LSR.W	#2,D0
	ANDI.W	#$1F,D0
	MOVEQ	#0,D2
	MOVE.B	$1E(A6),D2
	ANDI.B	#3,D2
	BEQ.L	lbC0111D8
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.L	lbC0111C0
	MOVE.B	#$FF,D2
	BRA.L	lbC0111DC

lbC0111C0	TST.B	$1B(A6)
	BPL.L	lbC0111D2
	MOVE.B	#$FF,D2
	SUB.B	D0,D2
	BRA.L	lbC0111DC

lbC0111D2	MOVE.B	D0,D2
	BRA.L	lbC0111DC

lbC0111D8	MOVE.B	lbB011210(PC,D0.W),D2
lbC0111DC	MOVE.B	$1A(A6),D0
	ANDI.W	#15,D0
	MULU.W	D0,D2
	LSR.W	#7,D2
	MOVE.W	$10(A6),D0
	TST.B	$1B(A6)
	BMI.L	lbC0111FA
	ADD.W	D2,D0
	BRA.L	lbC0111FC

lbC0111FA	SUB.W	D2,D0
lbC0111FC	MOVE.W	D0,6(A5)		; period

	bsr.w	SetPer

	MOVE.B	$1A(A6),D0
	LSR.W	#2,D0
	ANDI.W	#$3C,D0
	ADD.B	D0,$1B(A6)
	RTS

lbB011210	dc.b	0
	dc.b	$18
	dc.b	$31
	dc.b	$4A
	dc.b	$61
	dc.b	$78
	dc.b	$8D
	dc.b	$A1
	dc.b	$B4
	dc.b	$C5
	dc.b	$D4
	dc.b	$E0
	dc.b	$EB
	dc.b	$F4
	dc.b	$FA
	dc.b	$FD
	dc.b	$FF
	dc.b	$FD
	dc.b	$FA
	dc.b	$F4
	dc.b	$EB
	dc.b	$E0
	dc.b	$D4
	dc.b	$C5
	dc.b	$B4
	dc.b	$A1
	dc.b	$8D
	dc.b	$78
	dc.b	$61
	dc.b	$4A
	dc.b	$31
	dc.b	$18

lbC011230	BSR.L	lbC0110B8
	BRA.L	lbC011364

lbC011238	BSR.L	lbC011196
	BRA.L	lbC011364

lbC011240	MOVE.W	$10(A6),6(A5)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	MOVE.B	3(A6),D0
	BEQ.L	lbC011276
	MOVE.B	$1C(A6),D2
	ANDI.B	#15,D0
	BEQ.L	lbC011260
	ANDI.B	#$F0,D2
	OR.B	D0,D2
lbC011260	MOVE.B	3(A6),D0
	ANDI.B	#$F0,D0
	BEQ.L	lbC011272
	ANDI.B	#15,D2
	OR.B	D0,D2
lbC011272	MOVE.B	D2,$1C(A6)
lbC011276	MOVE.B	$1D(A6),D0
	LSR.W	#2,D0
	ANDI.W	#$1F,D0
	MOVEQ	#0,D2
	MOVE.B	$1E(A6),D2
	LSR.B	#4,D2
	ANDI.B	#3,D2
	BEQ.L	lbC0112BA
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.L	lbC0112A2
	MOVE.B	#$FF,D2
	BRA.L	lbC0112BE

lbC0112A2	TST.B	$1B(A6)
	BPL.L	lbC0112B4
	MOVE.B	#$FF,D2
	SUB.B	D0,D2
	BRA.L	lbC0112BE

lbC0112B4	MOVE.B	D0,D2
	BRA.L	lbC0112BE

lbC0112BA	MOVE.B	lbB01130E(PC,D0.W),D2
lbC0112BE	MOVE.B	$1C(A6),D0
	ANDI.W	#15,D0
	MULU.W	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	$13(A6),D0
	TST.B	$1D(A6)
	BMI.L	lbC0112DE
	ADD.W	D2,D0
	BRA.L	lbC0112E0

lbC0112DE	SUB.W	D2,D0
lbC0112E0	BPL.L	lbC0112E6
	CLR.W	D0
lbC0112E6	CMP.W	#$40,D0
	BLS.L	lbC0112F2
	MOVE.W	#$40,D0
lbC0112F2
;	MULU.W	lbW011C7E(pc),D0
;	LSR.W	#6,D0
;	MOVE.W	D0,8(A5)			; volume

	bsr.w	ChangeVolume
	bsr.w	SetVol

	MOVE.B	$1C(A6),D0
	LSR.W	#2,D0
	ANDI.W	#$3C,D0
	ADD.B	D0,$1D(A6)
	RTS

lbB01130E	dc.b	0
	dc.b	$18
	dc.b	$31
	dc.b	$4A
	dc.b	$61
	dc.b	$78
	dc.b	$8D
	dc.b	$A1
	dc.b	$B4
	dc.b	$C5
	dc.b	$D4
	dc.b	$E0
	dc.b	$EB
	dc.b	$F4
	dc.b	$FA
	dc.b	$FD
	dc.b	$FF
	dc.b	$FD
	dc.b	$FA
	dc.b	$F4
	dc.b	$EB
	dc.b	$E0
	dc.b	$D4
	dc.b	$C5
	dc.b	$B4
	dc.b	$A1
	dc.b	$8D
	dc.b	$78
	dc.b	$61
	dc.b	$4A
	dc.b	$31
	dc.b	$18

lbC01132E	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BEQ.L	lbC01133C
	MOVE.B	D0,$20(A6)
lbC01133C	MOVE.B	$20(A6),D0
	LSL.W	#7,D0
	CMP.W	8(A6),D0
	BGE.L	lbC011356
	SUB.W	D0,8(A6)
	ADD.W	D0,D0
	ADD.L	D0,4(A6)
	RTS

lbC011356	MOVE.W	#1,8(A6)
	RTS

lbC01135E	MOVE.W	$10(A6),6(A5)		; period

	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	SetPer
	move.l	(SP)+,D0

lbC011364	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.L	lbC01139C
lbC011372	ADD.B	D0,$13(A6)
	CMPI.B	#$40,$13(A6)
	BMI.L	lbC011386
	MOVE.B	#$40,$13(A6)
lbC011386	MOVE.B	$13(A6),D0
	ANDI.W	#$FF,D0
;	MULU.W	lbW011C7E(pc),D0
;	LSR.W	#6,D0
;	MOVE.W	D0,8(A5)			; volume

	bsr.w	ChangeVolume
	bsr.w	SetVol

	RTS

lbC01139C	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
lbC0113A6	SUB.B	D0,$13(A6)
	BPL.L	lbC0113B2
	CLR.B	$13(A6)
lbC0113B2	MOVE.B	$13(A6),D0
	ANDI.W	#$FF,D0
;	MULU.W	lbW011C7E(pc),D0
;	LSR.W	#6,D0
;	MOVE.W	D0,8(A5)			; volume

	bsr.w	ChangeVolume
	bsr.w	SetVol

	RTS

lbC0113C8	MOVE.B	3(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,6(A2)
	CLR.B	7(A2)
	ST	8(A2)

	bsr.w	SongEnd

	RTS

lbC0113DC	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	CMP.B	#$40,D0
	BLS.L	lbC0113EC
	MOVEQ	#$40,D0
lbC0113EC	MOVE.B	D0,$13(A6)
	ANDI.W	#$FF,D0
;	MULU.W	lbW011C7E(pc),D0
;	LSR.W	#6,D0
;	MOVE.W	D0,8(A5)			; volume

	bsr.w	ChangeVolume
	bsr.w	SetVol

	RTS

lbC011402	MOVE.B	3(A6),7(A2)
	ST	8(A2)
	RTS

lbC01140E	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BEQ.L	lbC011428
	CMP.B	#$20,D0
	BCC.L	lbC01142A
	CLR.B	5(A2)
	MOVE.B	D0,4(A2)
lbC011428	RTS

lbC01142A
;	MOVE.L	lbL000D82,D2		; timer
;	BEQ.L	lbC011428
	ADD.W	D0,D0
	ADD.W	D0,D0
;	MOVE.W	D0,lbW000D6E
	MOVE.L	lbL000D8A,D2
	DIVU.W	D0,D2
;	MOVEA.L	lbL000D70,A4
;	MOVE.L	lbL000D86,D0
;	BEQ.L	lbC011462
;	MOVE.B	D2,$600(A4)
;	LSR.W	#8,D2
;	MOVE.B	D2,$700(A4)

	movem.l	A1/A5,-(SP)
	lsr.w	#2,D0
	lea	PATTERNINFO(PC),A1
	move.w	D0,PI_BPM(A1)
	move.l	EagleBase(PC),A5
	move.w	D2,dtg_Timer(A5)
	move.l	dtg_SetTimer(A5),A1
	jsr	(A1)
	movem.l	(SP)+,A1/A5

	RTS

;lbC011462	MOVE.B	D2,$400(A4)
;	LSR.W	#8,D2
;	MOVE.B	D2,$500(A4)
;	RTS

lbC01146E	BSR.L	lbC0116C6
	MOVEQ	#0,D0
	MOVE.B	2(A6),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVEA.L	lbL011482(PC,D0.W),A4
	JMP	(A4)

lbL011482	dc.l	lbC010C42
	dc.l	lbC010C42
	dc.l	lbC010C42
	dc.l	lbC010C42
	dc.l	lbC010C42
	dc.l	lbC010C42
	dc.l	lbC010C42
	dc.l	lbC010C42
	dc.l	lbC010C42
	dc.l	lbC01132E
	dc.l	lbC010C42
	dc.l	lbC0113C8
	dc.l	lbC0113DC
	dc.l	lbC011402
	dc.l	lbC0114C2
	dc.l	lbC01140E

lbC0114C2	MOVE.B	3(A6),D0
	ANDI.W	#$F0,D0
	LSR.B	#2,D0
	MOVEA.L	lbL0114D2(PC,D0.W),A4
	JMP	(A4)

lbL0114D2	dc.l	lbC011512
	dc.l	lbC01102C
	dc.l	lbC011068
	dc.l	lbC011526
	dc.l	lbC01153A
	dc.l	lbC01154E
	dc.l	lbC01155C
	dc.l	lbC0115A2
	dc.l	lbC01102A
	dc.l	lbC0115B8
	dc.l	lbC01161A
	dc.l	lbC011630
	dc.l	lbC011646
	dc.l	lbC011664
	dc.l	lbC011682
	dc.l	lbC0116A4

lbC011512	MOVE.B	3(A6),D0
	ANDI.B	#$FD,$BFE001
	OR.B	D0,$BFE001
	RTS

lbC011526	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	ANDI.B	#$F0,$1F(A6)
	OR.B	D0,$1F(A6)
	RTS

lbC01153A	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	ANDI.B	#$F0,$1E(A6)
	OR.B	D0,$1E(A6)
	RTS

lbC01154E	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	MOVE.B	D0,$12(A6)
	RTS

lbC01155C	TST.B	lbB011C61
	BNE.L	lbC01158C
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	BEQ.L	lbC011596
	TST.B	$22(A6)
	BEQ.L	lbC01158E
	SUBQ.B	#1,$22(A6)
	BEQ.L	lbC01158C
lbC011582	MOVE.B	$21(A6),7(A2)
	ST	9(A2)
lbC01158C	RTS

lbC01158E	MOVE.B	D0,$22(A6)
	BRA.L	lbC011582

lbC011596	MOVE.W	14(A2),D0
	LSR.W	#4,D0
	MOVE.B	D0,$21(A6)
	RTS

lbC0115A2	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	LSL.B	#4,D0
	ANDI.B	#15,$1E(A6)
	OR.B	D0,$1E(A6)
	RTS

lbC0115B8	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	BEQ.L	lbC011618
	MOVEQ	#0,D7
	MOVE.B	5(A2),D7
	BNE.L	lbC0115D8
	TST.B	0(A6)
	BNE.L	lbC011618
lbC0115D8	SUB.W	D0,D7
	BEQ.L	lbC0115E4
	BCC.L	lbC0115D8
	RTS

lbC0115E4	MOVE.W	$14(A6),$DFF096		; DMA off
	MOVE.L	4(A6),(A5)			; address
	MOVE.W	8(A6),4(A5)			; length
	MOVE.W	$10(A6),6(A5)			; period

	bsr.w	SetTwo
	move.l	D0,-(SP)
	move.w	$10(A6),D0
	bsr.w	SetPer
	move.l	(SP)+,D0

	MOVE.B	$13(A6),D0
	ANDI.W	#$FF,D0
;	MULU.W	lbW011C7E(pc),D0
;	LSR.W	#6,D0
;	MOVE.W	D0,8(A5)			; volume

	bsr.w	ChangeVolume
	bsr.w	SetVol

	MOVE.W	$14(A6),D0
	OR.W	D0,$14(A2)
lbC011618	RTS

lbC01161A	TST.B	5(A2)
	BNE.L	lbC011618
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	BRA.L	lbC011372

lbC011630	TST.B	5(A2)
	BNE.L	lbC011618
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	BRA.L	lbC0113A6

lbC011646	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	CMP.B	5(A2),D0
	BNE.L	lbC011662
	CLR.B	$13(A6)
;	MOVE.W	#0,8(A5)			; volume

	move.l	D0,-(SP)
	moveq	#0,D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0

lbC011662	RTS

lbC011664	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	CMP.B	5(A2),D0
	BNE.L	lbC011662
	TST.B	0(A6)
	BEQ.L	lbC011662
	BRA.L	lbC0115E4

lbC011682	TST.B	5(A2)
	BNE.L	lbC011662
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	TST.B	12(A2)
	BNE.L	lbC0116A2
	ADDQ.B	#1,D0
	MOVE.B	D0,11(A2)
lbC0116A2	RTS

lbC0116A4	TST.B	5(A2)
	BNE.L	lbC0116A2
	MOVE.B	3(A6),D0
	ANDI.B	#15,D0
	LSL.B	#4,D0
	ANDI.B	#15,$1F(A6)
	OR.B	D0,$1F(A6)
	TST.B	D0
	BEQ.L	lbC0116A2
lbC0116C6	MOVEM.L	D1/A0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	$1F(A6),D0
	LSR.B	#4,D0
	BEQ.L	lbC011716
	MOVE.B	lbB01171C(PC,D0.W),D0
	ADD.B	D0,$23(A6)
	BTST	#7,$23(A6)
	BEQ.L	lbC011716
	CLR.B	$23(A6)
	MOVE.L	10(A6),D0
	MOVEQ	#0,D1
	MOVE.W	14(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVEA.L	$24(A6),A0
	ADDQ.L	#1,A0
	CMPA.L	D0,A0
	BCS.L	lbC01170A
	MOVEA.L	10(A6),A0
lbC01170A	MOVE.L	A0,$24(A6)
	MOVEQ	#-1,D0
	SUB.B	0(A0),D0
	MOVE.B	D0,(A0)
lbC011716	MOVEM.L	(SP)+,D1/A0
	RTS

lbB01171C	dc.b	0
	dc.b	5
	dc.b	6
	dc.b	7
	dc.b	8
	dc.b	10
	dc.b	11
	dc.b	13
	dc.b	$10
	dc.b	$13
	dc.b	$16
	dc.b	$1A
	dc.b	$20
	dc.b	$2B
lbW01172A	dc.w	$4080
lbW01172C	dc.w	$358
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
	dc.w	$352
	dc.w	$322
	dc.w	$2F5
	dc.w	$2CB
	dc.w	$2A2
	dc.w	$27D
	dc.w	$259
	dc.w	$237
	dc.w	$217
	dc.w	$1F9
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
	dc.w	$EF
	dc.w	$E1
	dc.w	$D5
	dc.w	$C9
	dc.w	$BD
	dc.w	$B3
	dc.w	$A9
	dc.w	$9F
	dc.w	$96
	dc.w	$8E
	dc.w	$86
	dc.w	$7E
	dc.w	$77
	dc.w	$71
	dc.w	$34C
	dc.w	$31C
	dc.w	$2F0
	dc.w	$2C5
	dc.w	$29E
	dc.w	$278
	dc.w	$255
	dc.w	$233
	dc.w	$214
	dc.w	$1F6
	dc.w	$1DA
	dc.w	$1BF
	dc.w	$1A6
	dc.w	$18E
	dc.w	$178
	dc.w	$163
	dc.w	$14F
	dc.w	$13C
	dc.w	$12A
	dc.w	$11A
	dc.w	$10A
	dc.w	$FB
	dc.w	$ED
	dc.w	$E0
	dc.w	$D3
	dc.w	$C7
	dc.w	$BC
	dc.w	$B1
	dc.w	$A7
	dc.w	$9E
	dc.w	$95
	dc.w	$8D
	dc.w	$85
	dc.w	$7D
	dc.w	$76
	dc.w	$70
	dc.w	$346
	dc.w	$317
	dc.w	$2EA
	dc.w	$2C0
	dc.w	$299
	dc.w	$274
	dc.w	$250
	dc.w	$22F
	dc.w	$210
	dc.w	$1F2
	dc.w	$1D6
	dc.w	$1BC
	dc.w	$1A3
	dc.w	$18B
	dc.w	$175
	dc.w	$160
	dc.w	$14C
	dc.w	$13A
	dc.w	$128
	dc.w	$118
	dc.w	$108
	dc.w	$F9
	dc.w	$EB
	dc.w	$DE
	dc.w	$D1
	dc.w	$C6
	dc.w	$BB
	dc.w	$B0
	dc.w	$A6
	dc.w	$9D
	dc.w	$94
	dc.w	$8C
	dc.w	$84
	dc.w	$7D
	dc.w	$76
	dc.w	$6F
	dc.w	$340
	dc.w	$311
	dc.w	$2E5
	dc.w	$2BB
	dc.w	$294
	dc.w	$26F
	dc.w	$24C
	dc.w	$22B
	dc.w	$20C
	dc.w	$1EF
	dc.w	$1D3
	dc.w	$1B9
	dc.w	$1A0
	dc.w	$188
	dc.w	$172
	dc.w	$15E
	dc.w	$14A
	dc.w	$138
	dc.w	$126
	dc.w	$116
	dc.w	$106
	dc.w	$F7
	dc.w	$E9
	dc.w	$DC
	dc.w	$D0
	dc.w	$C4
	dc.w	$B9
	dc.w	$AF
	dc.w	$A5
	dc.w	$9C
	dc.w	$93
	dc.w	$8B
	dc.w	$83
	dc.w	$7C
	dc.w	$75
	dc.w	$6E
	dc.w	$33A
	dc.w	$30B
	dc.w	$2E0
	dc.w	$2B6
	dc.w	$28F
	dc.w	$26B
	dc.w	$248
	dc.w	$227
	dc.w	$208
	dc.w	$1EB
	dc.w	$1CF
	dc.w	$1B5
	dc.w	$19D
	dc.w	$186
	dc.w	$170
	dc.w	$15B
	dc.w	$148
	dc.w	$135
	dc.w	$124
	dc.w	$114
	dc.w	$104
	dc.w	$F5
	dc.w	$E8
	dc.w	$DB
	dc.w	$CE
	dc.w	$C3
	dc.w	$B8
	dc.w	$AE
	dc.w	$A4
	dc.w	$9B
	dc.w	$92
	dc.w	$8A
	dc.w	$82
	dc.w	$7B
	dc.w	$74
	dc.w	$6D
	dc.w	$334
	dc.w	$306
	dc.w	$2DA
	dc.w	$2B1
	dc.w	$28B
	dc.w	$266
	dc.w	$244
	dc.w	$223
	dc.w	$204
	dc.w	$1E7
	dc.w	$1CC
	dc.w	$1B2
	dc.w	$19A
	dc.w	$183
	dc.w	$16D
	dc.w	$159
	dc.w	$145
	dc.w	$133
	dc.w	$122
	dc.w	$112
	dc.w	$102
	dc.w	$F4
	dc.w	$E6
	dc.w	$D9
	dc.w	$CD
	dc.w	$C1
	dc.w	$B7
	dc.w	$AC
	dc.w	$A3
	dc.w	$9A
	dc.w	$91
	dc.w	$89
	dc.w	$81
	dc.w	$7A
	dc.w	$73
	dc.w	$6D
	dc.w	$32E
	dc.w	$300
	dc.w	$2D5
	dc.w	$2AC
	dc.w	$286
	dc.w	$262
	dc.w	$23F
	dc.w	$21F
	dc.w	$201
	dc.w	$1E4
	dc.w	$1C9
	dc.w	$1AF
	dc.w	$197
	dc.w	$180
	dc.w	$16B
	dc.w	$156
	dc.w	$143
	dc.w	$131
	dc.w	$120
	dc.w	$110
	dc.w	$100
	dc.w	$F2
	dc.w	$E4
	dc.w	$D8
	dc.w	$CC
	dc.w	$C0
	dc.w	$B5
	dc.w	$AB
	dc.w	$A1
	dc.w	$98
	dc.w	$90
	dc.w	$88
	dc.w	$80
	dc.w	$79
	dc.w	$72
	dc.w	$6C
	dc.w	$38B
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
	dc.w	$384
	dc.w	$352
	dc.w	$322
	dc.w	$2F5
	dc.w	$2CB
	dc.w	$2A3
	dc.w	$27C
	dc.w	$259
	dc.w	$237
	dc.w	$217
	dc.w	$1F9
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
	dc.w	$E6
	dc.w	$E1
	dc.w	$D4
	dc.w	$C8
	dc.w	$BD
	dc.w	$B3
	dc.w	$A9
	dc.w	$9F
	dc.w	$96
	dc.w	$8E
	dc.w	$86
	dc.w	$7E
	dc.w	$77
	dc.w	$37E
	dc.w	$34C
	dc.w	$31C
	dc.w	$2F0
	dc.w	$2C5
	dc.w	$29E
	dc.w	$278
	dc.w	$255
	dc.w	$233
	dc.w	$214
	dc.w	$1F6
	dc.w	$1DA
	dc.w	$1BF
	dc.w	$1A6
	dc.w	$18E
	dc.w	$178
	dc.w	$163
	dc.w	$14F
	dc.w	$13C
	dc.w	$12A
	dc.w	$11A
	dc.w	$10A
	dc.w	$FB
	dc.w	$ED
	dc.w	$DF
	dc.w	$D3
	dc.w	$C7
	dc.w	$BC
	dc.w	$B1
	dc.w	$A7
	dc.w	$9E
	dc.w	$95
	dc.w	$8D
	dc.w	$85
	dc.w	$7D
	dc.w	$76
	dc.w	$377
	dc.w	$346
	dc.w	$317
	dc.w	$2EA
	dc.w	$2C0
	dc.w	$299
	dc.w	$274
	dc.w	$250
	dc.w	$22F
	dc.w	$210
	dc.w	$1F2
	dc.w	$1D6
	dc.w	$1BC
	dc.w	$1A3
	dc.w	$18B
	dc.w	$175
	dc.w	$160
	dc.w	$14C
	dc.w	$13A
	dc.w	$128
	dc.w	$118
	dc.w	$108
	dc.w	$F9
	dc.w	$EB
	dc.w	$DE
	dc.w	$D1
	dc.w	$C6
	dc.w	$BB
	dc.w	$B0
	dc.w	$A6
	dc.w	$9D
	dc.w	$94
	dc.w	$8C
	dc.w	$84
	dc.w	$7D
	dc.w	$76
	dc.w	$371
	dc.w	$340
	dc.w	$311
	dc.w	$2E5
	dc.w	$2BB
	dc.w	$294
	dc.w	$26F
	dc.w	$24C
	dc.w	$22B
	dc.w	$20C
	dc.w	$1EE
	dc.w	$1D3
	dc.w	$1B9
	dc.w	$1A0
	dc.w	$188
	dc.w	$172
	dc.w	$15E
	dc.w	$14A
	dc.w	$138
	dc.w	$126
	dc.w	$116
	dc.w	$106
	dc.w	$F7
	dc.w	$E9
	dc.w	$DC
	dc.w	$D0
	dc.w	$C4
	dc.w	$B9
	dc.w	$AF
	dc.w	$A5
	dc.w	$9C
	dc.w	$93
	dc.w	$8B
	dc.w	$83
	dc.w	$7B
	dc.w	$75
	dc.w	$36B
	dc.w	$33A
	dc.w	$30B
	dc.w	$2E0
	dc.w	$2B6
	dc.w	$28F
	dc.w	$26B
	dc.w	$248
	dc.w	$227
	dc.w	$208
	dc.w	$1EB
	dc.w	$1CF
	dc.w	$1B5
	dc.w	$19D
	dc.w	$186
	dc.w	$170
	dc.w	$15B
	dc.w	$148
	dc.w	$135
	dc.w	$124
	dc.w	$114
	dc.w	$104
	dc.w	$F5
	dc.w	$E8
	dc.w	$DB
	dc.w	$CE
	dc.w	$C3
	dc.w	$B8
	dc.w	$AE
	dc.w	$A4
	dc.w	$9B
	dc.w	$92
	dc.w	$8A
	dc.w	$82
	dc.w	$7B
	dc.w	$74
	dc.w	$364
	dc.w	$334
	dc.w	$306
	dc.w	$2DA
	dc.w	$2B1
	dc.w	$28B
	dc.w	$266
	dc.w	$244
	dc.w	$223
	dc.w	$204
	dc.w	$1E7
	dc.w	$1CC
	dc.w	$1B2
	dc.w	$19A
	dc.w	$183
	dc.w	$16D
	dc.w	$159
	dc.w	$145
	dc.w	$133
	dc.w	$122
	dc.w	$112
	dc.w	$102
	dc.w	$F4
	dc.w	$E6
	dc.w	$D9
	dc.w	$CD
	dc.w	$C1
	dc.w	$B7
	dc.w	$AC
	dc.w	$A3
	dc.w	$9A
	dc.w	$91
	dc.w	$89
	dc.w	$81
	dc.w	$7A
	dc.w	$73
	dc.w	$35E
	dc.w	$32E
	dc.w	$300
	dc.w	$2D5
	dc.w	$2AC
	dc.w	$286
	dc.w	$262
	dc.w	$23F
	dc.w	$21F
	dc.w	$201
	dc.w	$1E4
	dc.w	$1C9
	dc.w	$1AF
	dc.w	$197
	dc.w	$180
	dc.w	$16B
	dc.w	$156
	dc.w	$143
	dc.w	$131
	dc.w	$120
	dc.w	$110
	dc.w	$100
	dc.w	$F2
	dc.w	$E4
	dc.w	$D8
	dc.w	$CB
	dc.w	$C0
	dc.w	$B5
	dc.w	$AB
	dc.w	$A1
	dc.w	$98
	dc.w	$90
	dc.w	$88
	dc.w	$80
	dc.w	$79
	dc.w	$72
lbL011BAC	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$10000
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
	dc.l	$20000
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
	dc.l	$40000
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
	dc.l	$80000
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL011C5C	dc.l	0
lbB011C60	dc.b	6
lbB011C61	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
lbB011C69	dc.b	0
	dc.b	0
	dc.b	0
lbW011C6C	dc.w	0
lbL011C6E	dc.l	0
lbL011C72	dc.l	0			; ModulePtr
lbL011C76	dc.l	0			; PatternPtr
lbL011C7A	dc.l	0			; SamplesPtr
;lbW011C7E	dc.w	0			; Master Volume
;	dc.w	0
;lbL011C82	dc.l	lbL0109E4		; empty sample
lbL011C86	dc.l	0
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

;	SECTION	Chipka,DATA_C

;lbL0109E4	dc.l	0
;	dc.l	0
