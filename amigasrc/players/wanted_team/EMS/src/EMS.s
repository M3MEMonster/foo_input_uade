***************************************************************************
**************************** EagleRipper V1.0 *****************************
***************** for Editeur Musical Sequentiel modules, *****************
************************* adapted by Wanted Team **************************
***************************************************************************

		incdir	dh2:include/
		include	misc/eagleplayerripper.i
		include	exec/exec_lib.i
			
		RIPPERHEADER	EMSTags

	dc.b	"EMS EagleRipper V1.0",10
	dc.b	"done by Wanted Team (6 Dec 2005)",0
	even

EMSTags		dc.l	RPT_Formatname,Formatname
		dc.l	RPT_Ripp1,EMSRipp1
		dc.l	RPT_RequestRipper,1
		dc.l	RPT_Version,1<<16!0
		dc.l	RPT_Creator,Creator
		dc.l	RPT_Playername,Playername
		dc.l	RPT_Prefix,Prefix
		dc.l	0

Creator		dc.b	"Thomas 'Tom' PIMMEL, adapted by Wanted Team",0
Formatname	dc.b	"Editeur Musical Sequentiel",0
Playername	dc.b	"EMS",0
Prefix		dc.b	"EMS.",0
		even

*-----------------------------------------------------------------------------*
* Input: a0=Adr (start of memory)
*	 d0=Size (size of memory)
*	 a1=current adr
*	 d1=(a1.l)
* Output:d0=Error oder NULL
*	 d1=Size
*	 a0=Startadr (data)
*-----------------------------------------------------------------------------*

EMSRipp1
	lsr.l	#8,D1
	lsr.l	#8,D1
	lsr.l	#8,D1
	cmp.b	#1,D1
	beq.b	check
	rts
check
	move.l	A1,A0
	cmp.w	#$0125,(A1)+
	bhi.w	Fault
	tst.w	(A1)
	beq.w	Fault
	cmp.w	#128,(A1)+
	bhi.w	Fault
	cmp.w	#63,(A1)
	bhi.b	Fault
	moveq	#0,D1
	move.w	(A1)+,D1
	lea	128(A1),A2
PatternCheck
	move.b	(A1)+,D2
	cmp.b	D1,D2
	bhi.b	Fault
	cmp.l	A1,A2
	bne.b	PatternCheck
	moveq	#10,D2
	addq.l	#1,D1
	lsl.l	D2,D1

	movem.l	A3/A4,-(SP)
	lea	PeriodEnd(PC),A2
	lea	180(A1),A1
	lea	(A1,D1.L),A3
	lea	(A0,D0.L),A4
	cmp.l	A3,A4
	ble.b	Fault2
	moveq	#0,D2
CheckPer
	move.w	(A1),D1
	bmi.w	Fault2
	beq.b	NoPer
	lea	PeriodTable(PC),A4
CheckTable
	cmp.w	(A4)+,D1
	beq.b	PerOK
	cmp.l	A4,A2
	bne.b	CheckTable
	bra.w	Fault2
PerOK
	addq.l	#1,D2
NoPer
	addq.l	#4,A1
	cmp.l	A1,A3
	bne.b	CheckPer
	tst.l	D2
	beq.b	Fault2
	lea	134+4(A0),A2
	moveq	#0,D2
	moveq	#0,D1
	moveq	#14,D0
NextInfo
	move.w	(A2),D2
	add.l	D2,D1
	lea	12(A2),A2
	dbf	D0,NextInfo
	lsl.l	#1,D1			;samples size
	sub.l	A0,A1			;song size
	moveq	#0,D0
	add.l	A1,D1
	movem.l	(SP)+,A3/A4
	rts
Fault2

	movem.l	(SP)+,A3/A4
Fault
	moveq	#-1,D0
	rts

PeriodTable
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
	dc.w	$71
PeriodEnd
