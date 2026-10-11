***************************************************************************
**************************** EagleRipper V1.0 *****************************
************************ for Sierra AGI modules,  *************************
************************* adapted by Wanted Team **************************
***************************************************************************

		incdir	dh2:include/
		include	misc/eagleplayerripper.i
		include	exec/exec_lib.i
			
		RIPPERHEADER	AGITags

	dc.b	"Sierra AGI EagleRipper V1.0",10
	dc.b	"done by Wanted Team (2 Jan 2006)",0
	even

AGITags		dc.l	RPT_Formatname,Formatname
		dc.l	RPT_Ripp1,AGIRipp1
		dc.l	RPT_RequestRipper,1
		dc.l	RPT_Version,1<<16!0
		dc.l	RPT_Creator,Creator
		dc.l	RPT_Playername,Playername
		dc.l	RPT_Prefix,Prefix
		dc.l	0

Creator		dc.b	"Sierra On-Line, adapted by Wanted Team",0
Formatname	dc.b	"Sierra AGI",0
Playername	dc.b	"Sierra AGI",0
Prefix		dc.b	"AGI.",0
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

AGIRipp1
	lsr.l	#8,D1
	lsr.l	#8,D1
	cmp.w	#$1234,D1
	beq.b	Check2
	lsr.l	#8,D1
	cmp.b	#$34,D1
	beq.b	Check1
	rts

Check1
	cmp.b	#$12,-1(A1)
	bne.b	Fault
	subq.l	#1,A1
Check2
	addq.l	#3,A1
	tst.b	3(A1)
	bne.b	Fault
	cmp.b	#8,2(A1)
	bne.b	Fault

	moveq	#0,D1
	move.b	1(A1),D1
	lsl.l	#8,D1
	move.b	(A1),D1
	tst.l	D1
	beq.b	Fault
	addq.l	#2,A1
	move.l	A1,A0
	moveq	#0,D0
	rts

Fault
	moveq	#-1,D0
	rts
