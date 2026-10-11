	*****************************************************
	****    TCB Tracker replayer for EaglePlayer	 ****
	****  written by meynaf, updated by Wanted Team	 ****
	****      DeliTracker (?) compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include "misc/eagleplayer2.01.i"
	include 'exec/exec_lib.i'
	include	'hardware/custom.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: TCB Tracker player module V1.2 (15 Aug 2009)',0
	even
Tags
	dc.l	DTP_PlayerVersion,3
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
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
	dc.l	TAG_DONE

; dt player pour tcb tracker

sheep equ 20+2+2+2+2+6		; taille 1v noteplayer interne
;debug equ 0			; test effets

; moveq #-1,d0
; rts
; dc.b "DELIRIUM"
; dc.l tags
;tags
; dc.l $80004456,17		; dt version
; dc.l $80004458,$10000		; player version
; dc.l $80004459,name		; player name
; dc.l $8000445a,auth		; about
; dc.l $8000445c,check		; check
; dc.l $8000445e,intdt		; interrupt
; dc.l $80004463,chgspl		; init module
; dc.l $80004465,initdt		; init
; dc.l $80004473,savea5		; delibase
; dc.l $80004474,2		; flags : songend
; dc.l $80004475,forswap-check	; player swapable
; dc.l $8000447a,note		; notestruct
; dc.l 0
PlayerName
	dc.b	"TCB Tracker",0
;auth	dc.b	"By Anders Nilsson (An Cool/TCB),",10
;	dc.b	"adapted for DT by meynaf.",10,0

Creator
	dc.b	"(c) 1990 by Anders 'AN Cool' Nilsson,",10
	dc.b	"adapted by meynaf, updated by WT",0
Prefix
	dc.b	"TCB.",0
	even
ModulePtr
	dc.l	0
EagleBase
	dc.l	0
SamplesPtr
	dc.l	0
EmptyPtr
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
	moveq	#8,D0
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

	moveq	#0,D0		; Period? Note?
	moveq	#0,D1		; Sample number
	moveq	#0,D2		; Command string
	moveq	#0,D3		; Command argument
	move.b	1(A0),D2
	move.b	(A0),D0
	beq.b	NoNote
	lea	ByteST(PC),A1
	move.b	(A1,D0.W),D0
	add.w	D0,D0
	lea	Periods(PC),A1
	move.w	(A1,D0.W),D0
	move.w	D2,D1
	lsr.w	#4,D1
	addq.w	#1,D1
NoNote
	and.b	#15,D2
	rts

Periods
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

PATINFO
	movem.l	A0/A1,-(SP)
	move.l	A0,A1
	lea	PATTERNINFO(PC),A0
	move.w	D2,PI_Speed(A0)		; Speed Value
	move.w	D6,PI_Pattpos(A0)	; Current Position in Pattern
	move.w	D4,PI_Songpos(A0)
	move.w	D5,PI_Pattern(A0)	; Current Pattern
	move.l	A1,PI_Stripes(A0)	; STRIPE1
	addq.l	#2,A1			; Distance to next stripe
	move.l	A1,PI_Stripes+4(A0)	; STRIPE2
	addq.l	#2,A1
	move.l	A1,PI_Stripes+8(A0)	; STRIPE3
	addq.l	#2,A1
	move.l	A1,PI_Stripes+12(A0)	; STRIPE4
	movem.l	(SP)+,A0/A1
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	moveq	#$3F,D0
	lea	saveregs+20,A0
	move.l	D0,(A0)
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	lea	saveregs+20,A0
	move.b	-8+3(A0),D0
	beq.b	MinPos
	bmi.b	MinPos
	subq.b	#2,-8+3(A0)
	moveq	#$3F,D0
	move.l	D0,(A0)
MinPos
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SamplesPtr(PC),D0
	beq.b	return
	move.l	D0,A2

	lea	$44(A2),A1
	moveq	#1,D4
	moveq	#15,D5
Normal
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	move.l	(A1)+,D0
	move.l	(A1)+,D1
	cmp.l	D4,D1
	beq.b	NoSamp
	add.l	A2,D0
	move.l	D0,EPS_Adr(A3)			; sample address
	move.l	D1,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
NoSamp
	dbf	D5,Normal

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

LoadSize	=	4
Length		=	12
SamplesSize	=	20
SongSize	=	28
Samples		=	36
CalcSize	=	44
Patterns	=	52

InfoBuffer
	dc.l	MI_LoadSize,0		;4
	dc.l	MI_Length,0		;12
	dc.l	MI_SamplesSize,0	;20
	dc.l	MI_Songsize,0		;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_Pattern,0		;52
	dc.l	MI_MaxSamples,16
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxPattern,128
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	move.l	saveregs+12,D0
	rts

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	move.l	dtg_ChkData(A5),A0
	move.l	dtg_ChkSize(A5),D0
	lea	(a0,d0.l),a2		; pour tests ultérieurs
	cmpi.l	 #$132,d0
	blo.w	.ohno			; trop petit
	cmpi.l	#"AN C",(a0)
	bne.w	.ohno
	moveq	#0,d3
	move.l	#"OOL!",d1		; marque avec "!"
	move.l	4(a0),d2
	cmp.l	d1,d2
	beq.s	.hm
	moveq	#1,d3
	move.b	#".",d1			; ou marque avec "."
	cmp.l	d1,d2
	bne.s	.ohno
.hm
	move.l	8(a0),d1
	cmpi.l	#127,d1			; nb patt : pas plus de 127, quand même ?
	bhi.s	.ohno
	cmpi.b	#15,12(a0)		; speed en 16-n donc <16
	bhi.s	.ohno
	tst.b	13(a0)			; à priori toujours 0
	bne.s	.ohno
	tst.b	$8e(a0)			; taille seq (peut pas être 0 ou >7f)
	ble.s	.ohno
	lea	$110(a0),a1		; patt
	tst.b	d3
	beq.s	.fmt1
;	tst.w	$128(a0)		; faut que ce soit 0
;	bne.s	.ohno			; or 2 too, like TCB.MDemo4 5
	lea	$132(a0),a1
.fmt1
	mulu.w	#$200,d1		; taille patt (on avait encore d1=nbr)
	add.l	d1,a1			; et adr suite
	lea	$d4(a1),a3
	cmp.l	a2,a3			; regarder qu'il ne manque pas qqch...
	bhs.s	.ohno
;	move.l	(a1),d3			; taille totale d'ici
;	add.l	d3,a1
;	cmp.l	a2,a1			; tronqué !
;	bhi.s	.ohno
	cmpi.l	#-1,-8(a3)		; FFFFFFFF
	bne.s	.ohno
	tst.l	-4(a3)			; 00000000 (juste avant spl)
	bne.s	.ohno
	cmpi.l	#$d4,-$90(a3)		; 1er spl toujours en +$d4
	bne.s	.ohno
; todo : vérifier que les effets <>0 ou <>13 ne sont pas utilisés
;.loop

; bon, ça devrait suffire...
; ok
	moveq	#0,d0
	rts
.ohno
	moveq	#-1,d0
	rts
;forswap				; pour calculer chklen

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
	move.b	$8E(A0),Length+3(A4)

	move.l	A0,D2

; spl non signé -> signé
;	lea	(a0,d0.l),a1		; end of mod
	lea	$110(a0),a2
	cmpi.b	#"!",7(a0)
	beq.s	.fmt1
	lea	$132(a0),a2		; adr patt
.fmt1
	move.l	8(a0),d1
	move.l	D1,Patterns(A4)
	mulu.w	#$200,d1		; taille patt
	add.l	d1,a2

	move.l	A2,(A6)+		; SamplesPtr

	lea	$48(A2),A3
	moveq	#15,D5
	moveq	#1,D4
	moveq	#0,D6
.Next
	cmp.l	(A3),D4
	beq.b	.NoSam
	addq.l	#1,D6
.NoSam
	addq.l	#8,A3
	dbf	D5,.Next
	move.l	D6,Samples(A4)

	moveq	#106,D5
	add.w	D5,D5
	move.l	(A2),D4
	sub.l	D5,D4
	move.l	D4,SamplesSize(A4)
;	lea	$d4(a2),a0		; deb spl

	lea	(A2,D5.W),A0
	move.l	A0,D3
	move.l	A0,(A6)
	subq.l	#4,(A6)			; EmptyPtr
	sub.l	D2,D3
	move.l	D3,SongSize(A4)
	add.l	D4,D3
	move.l	D3,CalcSize(A4)
	cmp.l	D3,D0
	blt.b	Short
	cmp.l	#51825,D3
	bne.b	NoXF
	move.l	ModulePtr(PC),A1
	cmp.l	#$1289,4494(A1)
	bne.b	NoXF
	addq.l	#8,4494(A1)		; quality fix for Xyphoes Fantasy
	subq.l	#8,4498(A1)
NoXF
	lea	(A0,D4.L),A1		; end of mod
	and.w	#$FFFC,D4
	lea	(A0,D4.L),A2		; divide by 4 end
.rel
	eor.l	#$80808080,(A0)+
	cmp.l	A2,A0
	bne.b	.rel
	cmp.l	A1,A0
	beq.b	.no
.re
	eori.b	#$80,(a0)+
	cmp.l	a1,a0
	bne.s	.re
.no

;	moveq	#0,d0			; pas d'erreur
;	rts

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

	bsr.w	clrpl
;	moveq	#0,d0
;	move.l	$38(a5),a0
;	jsr	(a0)

	move.l	ModulePtr(PC),A0
	move.l	8(a0),d1		; nb patt
	moveq	#16,d2
	sub.b	$c(a0),d2		; tempo
	lea	$e(a0),a2		; seq
	move.b	$8e(a0),d3		; taille seq
	lea	$110(a0),a3
	cmpi.b	#"!",7(a0)
	beq.s	.fmt1
	lea	$132(a0),a3		; patt
.fmt1
	mulu.w	#$200,d1
	lea	(a3,d1.l),a4		; ref spl
	moveq	#0,d4			; seq en cours
	st	d4			; (-1 .b)
	moveq	#0,d5			; patt en cours
	moveq	#-1,d6			; offs dans patt
	moveq	#1,d1			; count
	movem.l	d1-a6,saveregs
	rts

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

NotePlay
	lea	$dff000,A5			; load CustomBase

; Note: d2 must contain the DMA mask of the channels you want to stop,
;       and d3 the DMA mask of the channels you want to start.
;       The vhpos, vhposr, etc. definitions can be found in the
;       hardware/custom.i include file.
;       BTW - this routine cannot be used if a replay uses audio-interrupts
;       (because it uses the intreq/intreqr registers for waiting)!


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

	move.w	#1,6(A1)

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
	lsr.l	#1,D7
	move.w	D7,4(A1)

; Because of the period = 1 trick used above, you must _always_ set the period
; of the stopped channels here, otherwise the output will sound wrong
; If you want to mute a channel, you can either turn it off, but not on again
; (by setting the channel's DMA bit in the d2 register, and clearing the channel's
; DMA bit in the d3 register), or you have to play a oneshot-nullsample and
; a loop-nullsample (smiliar to ProTracker)

	move.w	D5,6(A1)
	bsr.w	SetAll

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
	lsr.l	#1,D6
	move.w	D6,4(A1)
.Done
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
	move.l	A2,(A0)
	move.w	D7,UPS_Voice1Len(A0)
	move.w	D5,UPS_Voice1Per(A0)
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
***************************** TCB Tracker player **************************
***************************************************************************

; written by meynaf for DT, updated by Wanted Team

int
	movem.l	saveregs,d1-a6
	subq.b	#1,d1
	bne.w	.tmpo
	addq.b	#1,d6
	andi.w	#$3f,d6
	bne.s	.norm
	addq.b	#1,d4
	cmp.b	d3,d4
	bne.s	.ouf
; st songendf

	bsr.w	SongEnd

	moveq	#0,d4
.ouf
	move.b	(a2,d4.w),d5
.norm
	move.w	d5,d0
	mulu.w	#$200,d0
	lea	(a3,d0.l),a0

	bsr.w	PATINFO

	move.w	d6,d0
	lsl.w	#3,d0
	add.w	d0,a0
	lea	pldata,a1		; ma struct ntp à moi

	moveq	#1,D7			; DMA bit

	moveq	#3,d1
.l0
	moveq	#0,d0
	move.b	(a0)+,d0
	beq.w	.rien
; divu #16,d0			; res:div
; swap d0			; div:res
; move.w d0,-(a7)		; push res
; swap d0
; subq.w #1,d0			; démarre d'octave 1
; mulu #12,d0			; div*12
; add.w (a7)+,d0		; +res
; add.w d0,d0
; lea per(pc),a5

	clr.l	22(A1)		; channel enabled + VBI counter
	lea	ByteST(PC),A5
	move.b	0(A5,D0.W),D0
	add.w	D0,D0
	add.w	D0,D0
	move.b	D0,23(A1)	; store value
	lea	PerST(PC),A5
	move.l	0(A5,D0.W),8(A1)

 moveq #0,d0
 move.b (a0),d0
 lsr.b #4,d0			; n° ins (0-15)
 lea 4(a4),a5			; vol/rep
 lea $40(a5),a6			; deb/tai
 add.w d0,d0
 add.w d0,d0
 move.b (a5,d0.w),-(a7)		; vol
 move.w 2(a5,d0.w),-(a7)	; rep
 add.w d0,d0
 move.l (a6,d0.w),a5
 add.l a4,a5
 move.l a5,(a1)			; adr
 move.l 4(a6,d0.w),d0

	subq.l	#1,D0
	bne.b	.NoZero
	move.l	D0,4(A1)	; len
	move.l	D0,16+2(A1)	; replen
	bra.w	.skippy

.NoZero
	addq.l	#1,D0

 move.l d0,4(a1)		; len
 add.l d0,a5
 moveq #0,d0
 move.w (a7)+,d0
 move.l d0,16+2(a1)		; replen

	bne.b	.SetRep
	move.l	A5,D0
	bclr	#0,D0
	move.l	D0,A5
	moveq	#-1,D0
	cmp.l	-4(A5),D0
	bne.b	.skippy
	cmp.l	-204(A5),D0
	bne.b	.skippy
	cmp.l	-404(A5),D0
	bne.b	.skippy
	cmp.l	-604(A5),D0
	bne.b	.skippy
	sub.l	#700,4(A1)	; len
	move.l	ModulePtr(PC),A5
	cmp.b	#'!',7(A5)
	bne.b	.skippy
	sub.l	#212,4(A1)
	bra.b	.skippy
.SetRep
	lea	-700(A5),A5
	move.l	ModulePtr(PC),A6
	cmp.b	#'!',7(A6)
	bne.b	.noold
	lea	-212(A5),A5
.noold
	move.l	A5,A6
	sub.l	D0,A5
 	move.l	A5,12+2(A1)	; rep
	cmpm.b	(A5)+,(A6)+
	bne.b	.ski
	cmpm.b	(A5)+,(A6)+
	bne.b	.ski
	cmpm.b	(A5)+,(A6)+
	bne.b	.ski
	cmpm.b	(A5)+,(A6)+
	bne.b	.ski
	cmpm.b	(A5)+,(A6)+
	bne.b	.ski
	cmpm.b	(A5)+,(A6)+
	beq.b	.skippy
.ski
	add.l	#700,12+2(A1)	; rep

; sub.l d0,a5
; move.l a5,12+2(a1)		; rep
; move.l #$2bc,d0		; d'origine il coupe les $2bc octets de la fin
; sub.l d0,4(a1)			; (donc je fais pareil)
; bcc.s .hmm1			; -> sans ça, meep dans zik powermonger
; clr.l 4(a1)			; il était trop petit ? oups...
;.hmm1
; sub.l d0,16+2(a1)
; bcc.s .hmm2
; clr.l 16+2(a1)		; pas de rep...
;.hmm2

.skippy
	moveq	#0,d0
	move.b	(a7)+,d0	; 00-7f -> 00-40
	beq.b	.Zero
	addq.w	#1,D0		; for D0=1
	lsr.w	#1,d0
.Zero
	move.w	d0,10+2(a1)
.rien
; oups : effet utilisé !!!
 moveq #15,d0
 and.b (a0)+,d0
 beq.w .nfx
; ifne debug
; move.b -1(a0),$100.w
; move.w #$f00,$dff180
; else

	move.l	ModulePtr(PC),A5
	cmp.b	#'!',7(A5)
	beq.w	.NoPitch
	cmp.b	#10,D0
	bgt.w	.NoPitch
	lea	274(A5),A5
	add.w	D0,D0
	move.w	(A5,D0.W),A5
	movem.l	D4/D5,-(SP)
	moveq	#0,D4
	move.b	23(A1),D4
	lea	PerST(PC),A6
	move.l	(A6,D4.W),D5
	move.l	A5,D0
	bpl.b	.Plus
	move.l	4(A6,D4.W),D4
	sub.l	D4,D5		; -
	neg.l	D5		; +
	muls.w	D5,D0		; diff * pitch
	divs.w	#800,D0
	ext.l	D0
	sub.l	D0,8(A1)
	cmp.l	8(A1),D4
	bgt.b	.InRange1
	addq.b	#4,23(A1)
.InRange1
	cmp.l	#$3C686,8(A1)
	blt.b	.PerOK1
	move.l	#$3C686,8(A1)
	move.b	#$23*4,23(A1)
.PerOK1
	bra.b	.PerOK2
.Plus
	move.l	-4(A6,D4.W),D4
	sub.l	D4,D5		; +
	muls.w	D5,D0		; diff * pitch
	divs.w	#800,D0
	ext.l	D0
	sub.l	D0,8(A1)
	cmp.l	8(A1),D4
	blt.b	.InRange2
	subq.b	#4,23(A1)
.InRange2
	cmp.l	#$8000,8(A1)
	bgt.b	.PerOK2
	move.l	#$8000,8(A1)
	clr.b	23(A1)
.PerOK2
	movem.l	(SP)+,D4/D5
	bra.w	.nfx
.NoPitch
	cmp.b	#11,D0
	bne.b	.NoInter
	move.l	8(A1),D0
	lsr.l	#3,D0
	beq.b	.Bug
	move.l	D4,-(SP)
	move.l	#3460228,D4	; correct value
	cmp.b	#'!',7(A5)
	beq.b	.AmigaByte
	tst.b	$91(A5)
	bne.b	.AmigaByte
	move.l	#2867490,D4	; *8287/10000
.AmigaByte
	divu.w	D0,D4
	addq.w	#1,D4		; Amiga period
	move.l	#70938,D0	; 50Hz = PAL (709379) ex_EClockFrequency/10
	divu.w	D4,D0
	addq.w	#1,D0
	bclr	#0,D0		; Amiga length
	move.w	D2,D4		; speed
	mulu.w	24(A1),D4	; total VBI
	mulu.w	D4,D0
	move.l	(A1),26(A1)
	move.l	4(A1),30(A1)
	add.l	D0,26(A1)	; new adr
	sub.l	D0,30(A1)	; new len
	move.l	(SP)+,D4
.Bug
	clr.w	24(A1)		; VBI counter
	cmp.b	#'!',7(A5)
	beq.b	.Stop
	cmp.w	#2,296(A5)
	beq.b	.nfx
.Stop
	move.w	D7,$DFF096	; channel stop
	st.b	22(A1)		; disable channel data
	bra.b	.nfx
.NoInter
	cmp.b	#12,D0
	bne.b	.NoRest
	move.l	26(A1),(A1)
	move.l	30(A1),4(A1)
	clr.b	22(A1)		; channel enabled
	bra.b	.nfx
.NoRest
	cmpi.b	#13,d0		; effets supportés : juste patt brk
	bne.s	.nfx
	moveq	#$3f,d6		; pas dur...
; endc
.nfx
	add.w	D7,D7		; DMA bit
	addq.w	#1,24(A1)

 lea sheep(a1),a1
 dbf d1,.l0
 move.b d2,d1
.tmpo
 movem.l d1-a6,saveregs
 rts

;initdt
; bsr clrpl			; clear noteplayer data
; bsr init			; init du player
; moveq #0,d0			; et dire que tout est ok
; rts


; interrupt routine (fait la conversion entre ma noteplayer interne et dt)
Play
; movem.l d0-d7/a0-a6,-(a7)
 bsr int
; move.l savea5,a5
 lea pldata,a0
; lea dtvoie0(pc),a1

	lea	$DFF0A0,A1
	moveq	#1,D2		; DMA bit

 moveq #3,D3
.loop
 move.l (a0)+,A2
 move.l (a0)+,D7		; 0 est valide -> coupe son
 bmi.s .n0
 bne.s .nz
	move.l	EmptyPtr(PC),A2
	moveq	#2,D7
.nz
; movem.l D6-D7,$10(a1)
; bset #1,$b(a1)
; tst.l 8(a0)			; repeat ?
; bpl.s .n0			; oui, on laisse passer
; set forcé d'un repeat vide si pas précisé
; move.l #silence,A3		; moveq #2,D6
; moveq #2,D6
; movem.l D6-D7,$18(a1)
; bset #2,$b(a1)
.n0
 move.l	(a0)+,D5
 beq.s .n1
; move.w D6,$20(a1)		; note
; bset #3,$b(a1)

	lsr.l	#3,D5
;Right period computation from the ST value is :
;3546895/(((245760/29)*val)/$10000)
;which can be simplified and ends up being :
;82287964 / (3*val)

; for 3546896, 82287987 / (3*val)
; for 3579545, 83045467 / (3*val)

	move.l	#3460228,D4	; correct value
	move.l	ModulePtr(PC),A5
	cmp.b	#'!',7(A5)
	beq.b	.AmigaByte
	tst.b	$91(A5)
	bne.b	.AmigaByte
	move.l	#2867490,D4	; *8287/10000
.AmigaByte
	divu.w	D5,D4
	move.w	D4,D5
	addq.w	#1,D5
	move.w	D5,6(A1)
.n1
 move.w (a0)+,D0
 bmi.s .n2
; move.w D6,$24(a1)		; volume
; bset #4,$b(a1)

	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	D0,8(A1)

.n2
 move.l (a0)+,A3
 move.l (a0)+,D6
 bmi.s .n3
 tst.l D6
 bne.s .nonul
	move.l	EmptyPtr(PC),A3
	moveq	#2,D6
.nonul
; movem.l D6-D7,$18(a1)
; bset #2,$b(a1)

	tst.b	(A0)
	bne.b	.n3
	bsr.w	NotePlay
	st.b	(A0)		; channel disabled
.n3
; lea dtvoie2-dtvoie1(a1),a1

	lea	12(A0),A0
	lea	16(A1),A1
	add.w	D2,D2		; DMA bit

 dbf D3,.loop
; move.l $74(a5),a0
; jsr (a0)			; call noteplayer
; tst.b songendf
; bpl.s .ne
; move.l $5c(a5),a0
; jsr (a0)			; call songend
; clr.b songendf
;.ne
; bsr.s	clrpl
; movem.l (a7)+,d0-d7/a0-a6
	rts

; vide struct pldata
clrpl
	moveq	#3,d0
	moveq	#-1,d1
	lea	pldata,a0
.loop
	clr.l	(a0)+
	move.l	d1,(a0)+
; clr.w (a0)+

	clr.l	(A0)+

	move.w	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+

	clr.l	(A0)+
	clr.l	(A0)+
	clr.l	(A0)+

	dbf	d0,.loop
	rts

;per
; dc.w $0344,$0315,$02e9,$02bf,$0298,$0272,$024f,$022e,$020f,$01f1,$01d5,$01bb
; dc.w $01a2,$018a,$0174,$015f,$014c,$0139,$0127,$0117,$0107,$00f8,$00ea,$00dd
; dc.w $00d1,$00c5,$00ba,$00af,$00a6,$009c,$0093,$008b,$0083,$007c,$0075,$006e

;note dc.l struct
;struct dc.l dtvoie0
; dc.w 2,$202,0,$70c3,$40,0		; $70c3 -> 28khz
; dc.l 0,0,0,0
;dtvoie0 dc.l dtvoie1,0,0,$80010000
; ds.l 12
;dtvoie1 dc.l dtvoie2,0,0,$7fff0000
; ds.l 12
;dtvoie2 dc.l dtvoie3,0,0,$7fff0000
; ds.l 12
;dtvoie3 dc.l 0,0,0,$80010000
; ds.l 12

ByteST
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$10203
	dc.l	$4050607
	dc.l	$8090A0B
	dc.l	0
	dc.l	$C0D0E0F
	dc.l	$10111213
	dc.l	$14151617
	dc.l	0
	dc.l	$18191A1B
	dc.l	$1C1D1E1F
	dc.l	$20212223
	dc.l	0

	dc.l	$78D0
PerST
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

	dc.l	$40000

	Section	Buffy,BSS

saveregs ds.l 14		; d1-a6
;savea5 ds.l 1			; dt base
pldata ds.b sheep*4		; 4 voies
songendf ds.b 1

;	Section	Chippy,BSS_C
;silence ds.l 1

; data module :
; 0-7	8.b marque an cool	("." ou "!" fait une p'tite diff sur format)
; 8	.l nb patt
; c	.b speed (en 16-n !)
; d	-
; e	128.b séquence
; 8e	.b taille séquence
; 8f	-
; 90	3.b ?
; 93	n.b titre, commentaires, sample names
; 112	.w (null terminateur ?)
; 114	10 .w pour effets sur période (n'est pas toujours présent)
; 128	.w (comparé avec 2 pour effet 11)
; 12a	4.w (0)
; 132	patt ($200 bytes, soit $100 .w, par patt)
;	par ligne : 2 .b par canal
;	.b	note (10-1b, 20-2b, 30-3b pour octave/note)
;		(00 = nop, lire quand même effet)
;	.b	high 4 bits = instrument
;		low 4 bits = effet
;			0	nop
;			1-10	effet sur période, mais bugué
;			11	save état voie (si $128<>2, +coupe son)
;			12	restore état voie
;			13	pattern break
;			14-15	nop
; (1932)	ref pour offs samples, ici .l = taille totale d'ici
; (1936) 2.w *16		volumes/repeat samples
; (1976) 2.l *16		deb/taille samples
; .l	?
; .l	1
; .l	ffffffff
; .l	0
; suite (1a06) : samples (unsigned)
