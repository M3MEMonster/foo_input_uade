	******************************************************
	**** Editeur Musical Sequentiel 1.24 replayer for ****
	****  EaglePlayer  all adaptions by Wanted Team,  ****
	****      DeliTracker compatible (?) version      ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Editeur Musical Sequentiel 1.24 player module V1.0 (5 Dec 2005)',0
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
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_Flags,EPB_Save!EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
	dc.l	0

PlayerName
	dc.b	'Editeur Musical Sequentiel',0
Creator
	dc.b	"(c) 1989-91 by Thomas 'Tom' PIMMEL,",10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'EMS.',0
	even
ModulePtr
	dc.l	0
SamplesPtr
	dc.l	0
EagleBase
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

	moveq	#0,D0		; Period? Note?
	moveq	#0,D1		; Sample number
	moveq	#0,D2		; Command string
	moveq	#0,D3		; Command argument
	move.w	(A0),D0
	move.b	2(A0),D1
	lsr.w	#4,D1
	move.b	2(A0),D2
	and.b	#15,D2
	move.b	3(A0),D3
	rts

PATINFO
	movem.l	D0/D1/A0/A1,-(SP)
	lea	PATTERNINFO(PC),A0
	move.w	ems_speedi(PC),PI_Speed(A0)		; Speed Value
	move.w	ems_posi(PC),D0
	move.w	D0,PI_Songpos(A0)	; Position in Song
	move.l	ModulePtr(PC),A1
	move.b	6(A1,D0.W),D0
	move.w	D0,PI_Pattern(A0)	; Current Pattern
	move.w	ems_mesure(PC),PI_Pattpos(A0)		; Current Position in Pattern
	moveq	#10,D1
	lsl.l	D1,D0
	lea	314(A1),A1
	add.l	D0,A1
	move.l	A1,PI_Stripes(A0)	; STRIPE1
	addq.l	#4,A1			; Distance to next stripe
	move.l	A1,PI_Stripes+4(A0)	; STRIPE2
	addq.l	#4,A1
	move.l	A1,PI_Stripes+8(A0)	; STRIPE3
	addq.l	#4,A1
	move.l	A1,PI_Stripes+12(A0)	; STRIPE4
	movem.l	(SP)+,D0/D1/A0/A1
	rts

***************************************************************************
******************************* DTP_NextPatt ******************************
***************************************************************************

Next_Pattern
	moveq	#0,D0
	move.w	ems_posi(PC),D0
	addq.w	#1,D0
	cmp.w	InfoBuffer+Length+2(PC),D0
	bne.b	NoMax
	moveq	#0,D0
	bsr.w	SongEnd
NoMax
	move.w	D0,ems_posi
	move.l	ModulePtr(PC),A0
	move.b	6(A0,D0.W),D0
	lea	314(A0),A0
	moveq	#10,D1
	lsl.l	D1,D0
	add.l	D0,A0
	move.l	A0,ems_actual
	clr.w	ems_mesure
	rts

***************************************************************************
******************************* DTP_BackPatt ******************************
***************************************************************************

BackPattern
	moveq	#0,D0
	move.w	ems_posi(PC),D0
	beq.b	MinPos
	subq.w	#1,D0
	bra.b	NoMax
MinPos
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

	lea	138(A2),A2
	move.l	SamplesPtr(PC),A1
	moveq	#14,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	moveq	#0,D0
	move.w	(A2),D0
	lsl.l	#1,D0
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
	add.l	D0,A1
	lea	12(A2),A2
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

Get_ModuleInfo
	lea	InfoBuffer(PC),A0
	rts

Patterns	=	4
LoadSize	=	12
Samples		=	20
Length		=	28
SamplesSize	=	36
SongSize	=	44
CalcSize	=	52

InfoBuffer
	dc.l	MI_Pattern,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Samples,0		;20
	dc.l	MI_Length,0		;28
	dc.l	MI_SamplesSize,0	;36
	dc.l	MI_Songsize,0		;44
	dc.l	MI_Calcsize,0		;52
	dc.l	MI_MaxLength,128
	dc.l	MI_MaxSamples,15
	dc.l	MI_MaxPattern,64
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
******************************* DTP_Check2 ********************************
***************************************************************************

Check2
	movea.l	dtg_ChkData(A5),A0
	moveq	#-1,D0

	cmp.l	#1338,dtg_ChkSize(A5)
	ble.b	Fault
	cmp.b	#$01,(A0)+
	bne.b	Fault
	cmp.b	#$25,(A0)+
	bhi.b	Fault
	tst.w	(A0)
	beq.b	Fault
	cmp.w	#128,(A0)+
	bhi.b	Fault
	cmp.w	#63,(A0)
	bhi.b	Fault
	move.w	(A0)+,D1
	lea	128(A0),A1
PatternCheck
	move.b	(A0)+,D2
	cmp.b	D1,D2
	bhi.b	Fault
	cmp.l	A0,A1
	bne.b	PatternCheck

	lea	PeriodEnd(PC),A2
	lea	180(A0),A0
	lea	1024(A0),A3
	moveq	#0,D2
CheckPer
	move.w	(A0),D1
	bmi.w	Fault
	beq.b	NoPer
	lea	PeriodTable(PC),A1
CheckTable
	cmp.w	(A1)+,D1
	beq.b	PerOK
	cmp.l	A1,A2
	bne.b	CheckTable
	bra.w	Fault
PerOK
	addq.l	#1,D2
NoPer
	addq.l	#4,A0
	cmp.l	A0,A3
	bne.b	CheckPer
	tst.l	D2
	beq.b	Fault
	moveq	#0,D0
Fault
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

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	moveq	#0,D0
	movea.l	dtg_GetListData(A5),A0
	jsr	(A0)

	lea	ModulePtr(PC),A6
	move.l	A0,(A6)+			; module buffer

	lea	InfoBuffer(PC),A4
	move.l	D0,LoadSize(A4)
	move.w	2(A0),Length+2(A4)
	moveq	#1,D0
	add.w	4(A0),D0
	move.l	D0,Patterns(A4)
	moveq	#10,D1
	lsl.l	D1,D0
	add.l	#314,D0
	move.l	D0,SongSize(A4)
	lea	(A0,D0.L),A1
	move.l	A1,(A6)+			; SamplesPtr

	lea	134+4(A0),A1
	moveq	#0,D1
	moveq	#0,D3
	moveq	#0,D4
	moveq	#14,D2
NextInfo
	move.w	(A1),D3
	beq.b	NoSamp
	addq.l	#1,D1
	add.l	D3,D4
NoSamp
	lea	12(A1),A1
	dbf	D2,NextInfo
	lsl.l	#1,D4
	move.l	D4,SamplesSize(A4)
	move.l	D1,Samples(A4)
	add.l	D4,D0
	move.l	D0,CalcSize(A4)
	cmp.l	LoadSize(A4),D0
	ble.b	SizeOK
	moveq	#EPR_ModuleTooShort,D0
	rts
SizeOK
	move.l	A5,(A6)				; EagleBase

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

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
	move.w	ems_posi(PC),D0
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

SetBalance
SetVolume
	move.w	dtg_SndLBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0				; durch 64
	move.w	D0,LeftVolume

	move.w	dtg_SndRBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0				; durch 64
	move.w	D0,RightVolume			; Right Volume

	lea	OldVoice1(PC),A0
	lea	$DFF0A0,A4
	moveq	#3,D1
SetNew
	move.w	(A0)+,D0
	bsr.b	ChangeVolume
	lea	16(A4),A4
	dbf	D1,SetNew
	rts

ChangeVolume
	and.w	#$7F,D0
	cmpa.l	#$DFF0A0,A4			;Left Volume
	bne.b	NoVoice1
	move.w	D0,OldVoice1
	tst.w	Voice1
	bne.b	Voice1On
	moveq	#0,D0
Voice1On
	mulu.w	LeftVolume(PC),D0
	bra.b	SetIt

NoVoice1
	cmpa.l	#$DFF0B0,A4			;Right Volume
	bne.b	NoVoice2
	move.w	D0,OldVoice2
	tst.w	Voice2
	bne.b	Voice2On
	moveq	#0,D0
Voice2On
	mulu.w	RightVolume(PC),D0
	bra.b	SetIt

NoVoice2
	cmpa.l	#$DFF0C0,A4			;Right Volume
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
	move.w	D0,8(A4)
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A2,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A2
	cmp.l	#$DFF0A0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A2
	cmp.l	#$DFF0B0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A2
	cmp.l	#$DFF0C0,A4
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A2
.SetVoice
	move.w	D0,(A2)
	move.l	(A7)+,A2
	rts

SetAll
	move.l	A2,-(SP)
	lea	StructAdr+UPS_Voice1Adr(PC),A2
	cmp.l	#$DFF0A0,A0
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A2
	cmp.l	#$DFF0B0,A0
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A2
	cmp.l	#$DFF0C0,A0
	beq.b	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A2
.SetVoice
	move.l	D1,(A2)
	move.w	len(A1),UPS_Voice1Len(A2)
	move.w	per(A1),UPS_Voice1Per(A2)
	move.l	(SP)+,A2
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
	move.l	ModulePtr(PC),ems_module
	bra.w	ems_Init

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

	bsr.w	ems_play

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

ems_makewait
DMAWait
	movem.l	D0/D1,-(SP)
	moveq	#8,D0
.dma1	move.b	$DFF006,D1
.dma2	cmp.b	$DFF006,D1
	beq.b	.dma2
	dbeq	D0,.dma1
	movem.l	(SP)+,D0/D1
	rts

***************************************************************************
********************** Editeur Musical Séquentiel player ******************
***************************************************************************

; Player taken from ECOPLAYER II

;	include	exec/types.i
; STRUCTURE eco,0
;	USHORT	PlayVolume	** volume du morceau
;	APTR	PlayModule	** addrs du module
;	APTR	PlayModuleSize	** taille du module
;	APTR	PlayAlloc	** allouer les canaux
;	APTR	PlayFree	** liberer les canaux
;	LABEL	PP_SIZEOF

;Start
;	moveq	#-1,d0
;	rts
;EcoPlay	dc.b	'ECOPLAY2'
;	dc.l	EcoPlay
;	dc.l	0		** espace pour liens entre players
;	dc.l	0		** pas de custom interrupts
;	dc.l	ems_Check	** test si PT
;	dc.l	ems_Init	** std init
;	dc.l	ems_End		** std end
;	dc.l	ems_play	** std play
;	dc.l	ems_volume
;	dc.l	ems_Creator	** créateurs
;	dc.l	-1		** fin

;	dc.b	'$VER: EMS 2.0 (7.6.99)',$a,0
;ems_Creator
;	dc.b	"Player EMS-Raw 2.0",$a
;	dc.b	"Thomas PIMMEL (07-Jun-99)",0
;	even

;ems_Check
;	move.l	PlayModule(a5),a0
;	move.w	(a0)+,d0
;	cmp.w	#$125,d0
;	bne.s	.non
;	move.w	(a0),d0
;	move.w	d0,d1
;	and.w	#$ff,d1
;	cmp.w	d0,d1
;	bne.s	.non
;	moveq	#1,d0
;	rts
;.non
;	moveq	#0,d0
;	rts

;ems_volume
;	lea	ems_voldiv(pc),A0
;	move.w	PlayVolume(a5),(a0)
;	rts

*********************************************
*** NewPlayer EMS de Modules Format brute ***
** Version 1.24 Spread interdit sous peine **
** d'exil a Gorcki. Thomas Van Pimmel ASOC **
** 		22-MAR-91		   **
*********************************************

*********************************************
*** Déclaration des constantes **************
*********************************************
;-- DMA
c_per = 6
c_len = 4
c_vol = 8

;-- EMS
len  = 4		;snd length
rep  = 6		;repeat
repl = 8		;replen
vol = 10		;volume
per = 12		;period

;-- Autres
VALDIV = 1		;division du volume
WAIT = 5		;temporisation raster

*********************************************
****************** PGM **********************
*********************************************

***SP's
;ems_End	;sans param
;	move.w	#$f,$dff096
;	move.l	PlayFree(a5),a0
;	jsr	(a0)			;Free
;	rts

** initialisation d'une partition
** a0 format brut music
** a1 format brut son
** IRQ possible ; durée négligeable
ems_Init
;	move.l	PlayAlloc(a5),a0
;	jsr	(a0)			;allouer
;	tst.w	d0
;	bne.s	.ok
;	rts
;.ok
;	move.l	PlayModule(a5),ems_module
;	lea	ems_voldiv(pc),a0
;	move.w	PlayVolume(a5),(a0)
	move.w	#6,ems_speedi
	;EMS off
	move.l	ems_module(pc),a0
	clr.w	ems_posi
	clr.w	ems_mesure
	;init des variables principales
	move.l	a0,ems_part		;save mus ptr
	move.w	2(a0),d0
	subq.w	#1,d0
	move.w	d0,ems_length
	addq.w	#6,a0
	moveq	#0,d0			;clr d0
	move.b	(a0),d0			;1er partition
	move.l	a0,ems_seq		;table séquences
	lea	128(a0),a0
	move.l	a0,ems_sample		;table des sons
	move.l	a0,a2
	lea	12*15(A2),A2
	lsl.l	#5,d0
	lsl.l	#5,d0
	;=>	mulu	#1024,d0
	add.l	d0,a2
	move.l	a2,ems_actual		;partition actuelle

	;init table des sons
	* trouver les sons
	move.l	ems_module(pc),a1
	move.l	a1,d0
	add.l	#$538,d0		** passer infos
	moveq	#0,d1
	move.w	4(a1),d1
	lsl.l	#5,d1
	lsl.l	#5,d1
	add.l	d1,d0
	move.l	d0,a1
	** 
	moveq	#14,d0			;15 sons
.loop
	tst.w	len(a0)
	beq.s	.jmp
	clr.w	(a1)
	move.l	a1,(a0)
	moveq	#0,d1
	move.w	len(a0),d1
	lsl.l	#1,d1
	add.l	d1,a1
.jmp
	lea	12(A0),A0
	dbf	d0,.loop
	;-- EMS On
	rts

*******This is THE player of EMS*************
ems_play				;pas d'arguments
	move.w	ems_count(pc),d0
	cmp.w	ems_speedi,d0
	bcs	ems_notyet		;traitements intermédiaires
	clr.w	ems_count
	******permit?
ems_permit
	******oui :
	lea	ems_com(pc),a0		;efface commandes
	clr.l	(a0)
	clr.l	4(a0)
	clr.l	8(a0)
	clr.l	12(a0)
;---là tous les six de balayage
;---A5 partition, A0 dma, d2 dma value, d0 compteur boucle, 
;-- d1 flag occupation, d3 ctrl register
;-- d4-6 intermédiaires, d7 val dma fin
;-couper les voies
	move.l	ems_actual(pc),a5
	move.w	ems_mesure(pc),d0
	lsl.w	#4,d0			;*16
	add.w	d0,a5
	;---
	moveq	#3,d0			;4 voies
	moveq	#1,d2
	moveq	#0,d3
	moveq	#0,d7
ems_cut
	move.b	2(a5),d4		;instr
	lsr.b	#4,d4
	tst.b	d4
	beq.s	ems_nosamplechg		;pas de chgment instr
	or.w	d2,d7
ems_nosamplechg
	addq.w	#1,d3			;ctrl reg
	lsl.w	#1,d2			;dma
	tst.l	(a5)+			;next
	dbf	d0,ems_cut
	move.w	d7,$dff096		;couper		; DMA!
*	bsr	ems_initwait		;temporisation dma

***************coeur de la routine**************
;documentation de ems_snd
	lea	-16(A5),A5	;retour debut partition
	moveq	#3,d0
	moveq	#0,d3
	move.w	ems_voldiv(pc),d5
	lea	ems_snd(pc),a1
	lea	$dff0a0,a4
	lea	ems_com(pc),a3	;table des commandes spéciales
ems_loop
	clr.l	(a1)		;par default pas de son
	moveq	#0,d2
	move.b	2(a5),d2
	lsr.b	#4,d2
	tst.b	d2
	beq.s	ems_noaddrs	;pas de son spécial
	**********************************************nouveau son
	*mulu	#12,d2
	subq.w	#1,d2
	move.w	d2,d4
	lsl.w	#2,d4		;*4
	lsl.w	#3,d2		;*8
	add.w	d4,d2		;=> *12
	move.l	ems_sample(pc),a0	;table des sons
	add.w	d2,a0
	move.l	(a0),(a1)	;addrs (pas de tst validité du son)
	move.w	len(a0),len(a1)
	move.w	rep(a0),rep(a1)
	move.w	repl(a0),repl(a1)
	move.w	vol(a0),d4
	;si volume diminué
	mulu	d5,d4
	lsr.w	#6,d4

	move.w	d4,vol(a1)
;	move.w	d4,c_vol(a4)			; VOLUME!

	MOVE.L	D0,-(SP)
	MOVE.W	D4,D0
	BSR.W	ChangeVolume
	BSR.W	SetVol
	MOVE.L	(SP)+,D0

	**********************************************période
ems_noaddrs
	move.w	(a5),d2
	tst.w	d2
	beq.s	ems_noper
	move.w	d2,c_per(a4)			; PERIOD!
	move.w	d2,per(a1)	;mieux que per(couilles)
ems_noper
	*************commandes
	moveq	#0,d2
	move.b	2(a5),d2	;commandes
	and.b	#$f,d2
ems_force			;saut de retour si cmd break ou speed
	move.b	3(a5),d4	;args
	tst.b	d2
	beq	ems_retval	;pas de commandes
	and.w	#$ff,d4
	move.w	d2,d6
	subq.w	#7,d6
	blt	ems_retval
	lsl.w	#2,d6
	pea	ems_retval
	lea	ems_jmpt(pc),a0
	move.l	(a0,d6.w),a2
	jmp	(a2)
;--EMS ne contient ni rétansorbe ni colorant. Etonnant non?
ems_vol
	mulu	d5,d4
	lsr.w	#6,d4

;	move.w	d4,c_vol(a4)			; VOLUME!

	MOVE.L	D0,-(SP)
	MOVE.W	D4,D0
	BSR.W	ChangeVolume
	BSR.W	SetVol
	MOVE.L	(SP)+,D0

	move.w	d4,vol(a1)
	rts
ems_repeat
	move.w	len(a1),repl(a1)
	clr.w	rep(a1)
	rts
ems_speed
	tst.w	d4
	beq.s	ems_retval
	move.w	d4,ems_speedi
	rts
ems_led
	tst.w	d4
	beq.s	ems_ledof
	bset	#1,$bfe001
	rts
ems_ledof
	bclr	#1,$bfe001
	rts
ems_break
	move.w	d4,ems_cbreak
	move.w	#63,ems_mesure
	rts
ems_special
	move.w	d2,(a3)
	move.w	d4,2(a3)
	rts

;ems_isallocate		;break et speed à traiter même si alloc
;	moveq	#0,d2
;	move.b	2(a5),d2	;commandes
;	and.b	#$f,d2
;	cmp.b	#8,d2
;	beq	ems_force
;	cmp.b	#9,d2
;	beq	ems_force
ems_retval
	addq.w	#1,d3		;ctrl
	lea	14(A1),A1		;ems_snd
	lea	$10(A4),A4		;dma
	tst.l	(a5)+		;partitions
	tst.l	(a3)+
	dbf	d0,ems_loop
	addq.w	#1,ems_mesure
	cmp.w	#64,ems_mesure
	bne.s	ems_suite
	*******chg patern
	move.w	ems_cbreak(pc),ems_mesure
	clr.w	ems_cbreak
	move.l	ems_seq(pc),a0
	addq.w	#1,ems_posi
	move.w	ems_posi(pc),d0
	cmp.w	ems_length(pc),d0
	bls.s	.ok

	BSR.W	SongEnd

	clr.w	ems_posi
	moveq	#0,d0
.ok
	moveq	#0,d1
	move.b	(a0,d0.w),d1
	lsl.l	#5,d1
	lsl.l	#5,d1
	add.l	ems_part,d1
	add.l	#128+12*15+6,d1
	move.l	d1,ems_actual
ems_suite
	********************************

	BSR.W	PATINFO

	or.w	#$8000,d7
	bsr	ems_makewait		;attendre dma
;initialisation du DMA
	lea	$dff0a0,a0
	lea	ems_snd(pc),a1
	moveq	#3,d0
ems_docloop
	move.l	(a1),d1
	tst.l	d1
	beq.s	ems_nosample
	move.l	d1,(a0)			;addrs		; ADDRESS!
	move.w	len(a1),c_len(a0)			; LENGTH!

	BSR.W	SetAll

ems_nosample	lea	$10(A0),A0
	lea	14(A1),A1
	dbf	d0,ems_docloop
	move.w	d7,$dff096		;boum!		; DMA!
	rts
*********************************************************
**************** 	IFNE	6	*****************
*********************************************************
ems_notyet				;traitement repeat et replen
	tst.w	ems_count
	bne.s	ems_norepeat
	moveq	#3,d0
	lea	$dff0a0,a0
	lea	ems_snd(pc),a1
ems_shit
	move.l	(a1),d1
	tst.l	d1
	beq.s	ems_no
	clr.l	(a1)
	moveq	#0,d2
	move.w	rep(a1),d2
	lsl.l	#1,d2
	add.l	d2,d1
	move.l	d1,(a0)				; ADDRESS!
	move.w	repl(a1),c_len(a0)		; LENGTH!
ems_no	lea	$10(A0),A0
	lea	14(A1),A1
	dbf	d0,ems_shit

ems_norepeat
	***************************************commandes spéciales
	lea	ems_com(pc),a0
	lea	$dff0a0,a1
	lea	ems_snd(pc),a2
	moveq	#3,d0
	moveq	#0,d2
ems_cmd
	move.w	(a0),d3
	tst.b	d3
	beq	ems_nofree
	pea	ems_nofree
	cmp.b	#7,d3
	beq.s	ems_voldown
	cmp.b	#12,d3
	beq.s	ems_down
	cmp.b	#13,d3
	beq.s	ems_vib
	cmp.b	#11,d3
	beq.s	ems_up
	rts
	***************************commandes 1/50eme
ems_voldown
	move.w	2(a0),d3
	sub.w	d3,vol(a2)
	bgt.s	.rts
	clr.w	vol(a2)
	clr.l	(a0)
.rts
;	move.w	vol(a2),c_vol(a1)			; VOLUME!

	MOVEM.L	D0/A4,-(SP)
	MOVE.L	A1,A4
	MOVE.W	vol(A2),D0
	BSR.W	ChangeVolume
	BSR.W	SetVol
	MOVEM.L	(SP)+,D0/A4

	rts
ems_up
	*rts
	move.w	2(a0),d3
	move.w	per(a2),d4
	sub.w	d3,d4
	cmp.w	#$70,d4
	blt.s	.rts
	move.w	d4,per(a2)
	move.w	d4,c_per(a1)				; PERIOD!
.rts
	rts
ems_down
	move.w	2(a0),d3
	move.w	per(a2),d4
	add.w	d3,d4
	cmp.w	#$6b0,d4
	bgt.s	.rts
	move.w	d4,per(a2)
	move.w	d4,c_per(a1)				; PERIOD!
.rts
	rts
ems_vib
	move.w	2(a0),d4
	move.w	per(a2),d5
	move.w	ems_count(pc),d3
	btst	#0,d3
	bne.s	ems_d
	sub.w	d4,d5
	move.w	d5,c_per(a1)				; PERIOD!
	rts
ems_d
	add.w	d4,d5
	move.w	d5,c_per(a1)				; PERIOD!
	rts
ems_nofree
	tst.l	(a0)+
	lea	$10(A1),A1
	lea	14(A2),A2
	addq.w	#1,d2
	dbf	d0,ems_cmd
	****************************************restorer volume?
	********counter ++
	addq.w	#1,ems_count
	rts

*************Temporisation
*ems_initwait

;ems_makewait

*	move.b	$dff006,d0	;raster
*	addq.b	#WAIT,d0	;nb de lignes attentes

	* routine 3
;	bsr.s	ems_wait
;	bsr.s	ems_wait
;	bsr.s	ems_wait
;	bsr.s	ems_wait
;	bsr	ems_wait
;ems_wait
;	move.b	$dff006,d0
;.wait
;	cmp.b	$dff006,d0
;	beq.s	.wait
;	rts

**	moveq	#0,d0
**	move.b	$bfda00,d0
**	lsl.w	#8,d0
**	move.b	$bfd900,d0
**	lsl.l	#8,d0
**	move.b	$bfd800,d0

**	addq.l	#WAIT,d0
**	and.l	#$ffffff,d0

*	move.l	d0,ems_raster
*	rts
*ems_makewait
*	move.l	ems_raster(pc),d0
.loop
*	move.b	$dff006,d6
*	cmp.b	d0,d6
*	bls.s	.loop

**	moveq	#0,d6
**	move.b	$bfda00,d6
**	lsl.w	#8,d6
**	move.b	$bfd900,d6
**	lsl.l	#8,d6
**	move.b	$bfd800,d6

**	cmp.l	d0,d6
**	bls.s	.loop
**	rts


*********************************************
***********VARIABLES EMS ********************
*********************************************

;-- jmp table
ems_jmpt				;switch/case
	dc.l	ems_special
	dc.l	ems_break
	dc.l	ems_speed
	dc.l	ems_led
	dc.l	ems_special
	dc.l	ems_special
	dc.l	ems_special
	dc.l	ems_vol
	dc.l	ems_repeat
;-- Longwords
ems_part	dc.l	0	;addrs format brut music
ems_seq		dc.l	0	;addrs table sequences
ems_actual	dc.l	0	;addrs partition actuelle
ems_sample	dc.l	0	;addrs table sons
ems_com		ds.l	4	;table des commandes enregistrées
;-- Words
ems_length	dc.w	0	;longueur du morceau
ems_cbreak	dc.w	0	;valeur du break ou zero
ems_posi	dc.w	0	;position dans sequence
ems_raster	dc.l	0	;ligne d'attente
ems_voldiv	dc.w	64	;valeur volume
ems_mesure	dc.w	0	;start mesure
ems_count	dc.w	0	;irq count
ems_speedi	dc.w	6
;-- Tables
;-- Table id pour chaque voie
ems_snd		dc.l	0	;addrs
		dc.w	0	;length
		dc.w	0	;rep
		dc.w	0	;repl
		dc.w	0	;vol
		dc.w	0	;per
		;autres voies
		ds.b	14*3
ems_module	dc.l	0
