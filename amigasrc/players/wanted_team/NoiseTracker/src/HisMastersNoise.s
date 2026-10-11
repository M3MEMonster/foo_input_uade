***************************************************************************
**************************** EagleRipper V1.0 *****************************
**************** for His Masters Noise musicdisk modules, *****************
************************* adapted by Wanted Team **************************
***************************************************************************

	incdir	dh2:include/
	include	misc/eagleplayerripper.i
			
	RIPPERHEADER	HMNTags

	dc.b	"HMN EagleRipper V1.0",10
	dc.b	"done by Wanted Team (27 Aug 2001)",0
	even

HMNTags
	dc.l	RPT_Formatname,Formatname
	dc.l	RPT_Ripp1,HMNRipp1
	dc.l	RPT_RequestRipper,1
	dc.l	RPT_Version,1<<16!0
	dc.l	RPT_Creator,Creator
	dc.l	RPT_Playername,Playername
	dc.l	RPT_GetModuleName,GetModuleName
	dc.l	RPT_Prefix,Prefix
	dc.l	0

Creator
	dc.b	"Mahoney & Kaktus, adapted by Wanted Team",0
Formatname
	dc.b	"His Masters Noise musicdisk (NoiseTracker)",0
Playername
	dc.b	"NoiseTracker",0
Prefix	
	dc.b	"MOD.",0
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

HMNRipp1
	cmp.l	#'FORM',D1
	beq.b	check
	rts
check
	cmp.l	#1051656,D0
	bne.s	error
	lea	3080(A1),A2		; memory base
	move.l	#281194,D1
	add.l	D1,A1
	cmp.l	#' Eli',(A1)		; more check
	beq.b	CalcSize
error
	moveq	#-1,D0
	rts

CalcSize
	movem.l	D3-D7/A3-A6,-(SP)
	lea	192(A2),A1		; info base
	move.l	#524288,D1
	lea	(A2,D1.L),A0		; restore base
	move.l	(A1)+,D7
	lea	(A2,D7.L),A3		; songdata ptr
	moveq	#127,D0
	lea	952(A3),A4
	moveq	#0,D2
	moveq	#0,D1
NextByte
	move.b	(A4)+,D1
	cmp.b	D2,D1
	ble.b	Lower
	move.l	D1,D2
Lower
	dbf	D0,NextByte
	addq.l	#1,D2
	asl.l	#8,D2
	asl.l	#2,D2
	lea	4(A4,D2.L),A4
	move.l	A0,A5
CopyData
	move.l	(A3)+,(A5)+
	cmp.l	A3,A4
	bne.b	CopyData
	moveq	#30,D0
	lea	42(A0),A4

NextSample
	move.l	(A1)+,D7
	lea	(A2,D7.L),A3		; sample ptr
	moveq	#0,D1
	move.w	(A4),D1
	beq.b	NoSample
	add.l	D1,D1
	lea	(A3,D1.L),A6
CopySamp
	move.w	(A3)+,(A5)+
	cmp.l	A3,A6
	bne.b	CopySamp
NoSample
	lea	30(A4),A4
	dbf	D0,NextSample

	move.l	#'M&K!',1080(A0)	; add NoiseTracker ID
	sub.l	A0,A5
	move.l	A5,D1
	movem.l	(SP)+,D3-D7/A3-A6
	bsr.b	GetModuleName
	moveq	#0,D0
	rts

*-----------------------------------------------------------------------------*
* Input: a0=Start of Modul
*	 d0=Size
* Output:d0=Ptr to name or NULL
*-----------------------------------------------------------------------------*

GetModuleName
	move.l	A0,D0
	rts
