	******************************************************
	**** Editeur Musical Sequentiel 1.24 replayer for ****
	****    EaglePlayer 2.00+ (Amplifier version),    ****
	****         all adaptions by Wanted Team	  ****
	******************************************************

	incdir	"dh2:include/"
	include 'misc/eagleplayer2.01.i'
	include	'misc/eagleplayerengine.i'
	include	'exec/exec_lib.i'

	SECTION	Player,CODE

	EPPHEADER Tags

	dc.b	'$VER: Editeur Musical Sequentiel 1.24 player module V2.0 (5 Dec 2005)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2<<16!0
	dc.l	EP_PlayerVersion,11
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	EP_Check5,Check5
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	EP_NewModuleInfo,NewModuleInfo
	dc.l	EP_GetPositionNr,GetPosition
	dc.l	EP_SampleInit,SampleInit
	dc.l	DTP_NextPatt,Next_Pattern
	dc.l	DTP_PrevPatt,BackPattern
	dc.l	EP_PatternInit,PatternInit
	dc.l	EP_Flags,EPB_Save!EPB_ModuleInfo!EPB_SampleInfo!EPB_Songend!EPB_Packable!EPB_Restart!EPB_PrevPatt!EPB_NextPatt
	dc.l	EP_EagleBase,EagleBase
	dc.l	EP_InitAmplifier,InitAudstruct
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
	move.w	A0,D1		;DFF0A0/B0/C0/D0
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
	move.w	A0,D1		;DFF0A0/B0/C0/D0
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
	move.w	A1,D1		;DFF0A0/B0/C0/D0
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
***************************** EP_NewModuleInfo ****************************
***************************************************************************

NewModuleInfo

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
******************************** EP_Check5 ********************************
***************************************************************************

Check5
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
	move.l	A1,(A6)				; SamplesPtr

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
	moveq	#0,D0
	rts

***************************************************************************
********************************* EP_GetPosNr *****************************
***************************************************************************

GetPosition
	moveq	#0,D0
	move.w	ems_posi(PC),D0
	rts

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	move.l	ModulePtr(PC),ems_module
	bra.w	ems_Init

***************************************************************************
***************************** DTP_Interrupt *******************************
***************************************************************************

Interrupt
	movem.l	D1-A6,-(A7)

	bsr.w	ems_play

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
;	move.w	d7,$dff096		;couper		; DMA!

	MOVE.L	D0,-(SP)
	MOVE.W	D7,D0
	BSR.W	PokeDMA
	MOVE.L	(SP)+,D0

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
	BSR.W	PokeVol
	MOVE.L	(SP)+,D0

	**********************************************période
ems_noaddrs
	move.w	(a5),d2
	tst.w	d2
	beq.s	ems_noper
;	move.w	d2,c_per(a4)			; PERIOD!

	MOVEM.L	D0/A1,-(SP)
	MOVE.L	A4,A1
	MOVE.W	D2,D0
	BSR.W	PokePer
	MOVEM.L	(SP)+,D0/A1

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
	BSR.W	PokeVol
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
;	bset	#1,$bfe001

	bsr.w	LED_Off

	rts
ems_ledof
;	bclr	#1,$bfe001

	bsr.w	LED_On

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
;	bsr	ems_makewait		;attendre dma
;initialisation du DMA
	lea	$dff0a0,a0
	lea	ems_snd(pc),a1
	moveq	#3,d0
ems_docloop
	move.l	(a1),d1
	tst.l	d1
	beq.s	ems_nosample
;	move.l	d1,(a0)			;addrs		; ADDRESS!
;	move.w	len(a1),c_len(a0)			; LENGTH!

	MOVE.L	D0,-(SP)
	MOVE.L	D1,D0
	BSR.W	PokeAdr
	MOVE.W	len(A1),D0
	BSR.W	PokeLen
	MOVE.L	(SP)+,D0

ems_nosample	lea	$10(A0),A0
	lea	14(A1),A1
	dbf	d0,ems_docloop
;	move.w	d7,$dff096		;boum!		; DMA!

	MOVE.L	D0,-(SP)
	MOVE.W	D7,D0
	BSR.W	PokeDMA
	MOVE.L	(SP)+,D0

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
;	move.l	d1,(a0)				; ADDRESS!
;	move.w	repl(a1),c_len(a0)		; LENGTH!

	MOVE.L	D0,-(SP)
	MOVE.L	D1,D0
	BSR.W	PokeAdr
	MOVE.W	repl(A1),D0
	BSR.W	PokeLen
	MOVE.L	(SP)+,D0

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
	BSR.W	PokeVol
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
;	move.w	d4,c_per(a1)				; PERIOD!

	MOVE.L	D0,-(SP)
	MOVE.W	D4,D0
	BSR.W	PokePer
	MOVE.L	(SP)+,D0

.rts
	rts
ems_down
	move.w	2(a0),d3
	move.w	per(a2),d4
	add.w	d3,d4
	cmp.w	#$6b0,d4
	bgt.s	.rts
	move.w	d4,per(a2)
;	move.w	d4,c_per(a1)				; PERIOD!

	MOVE.L	D0,-(SP)
	MOVE.W	D4,D0
	BSR.W	PokePer
	MOVE.L	(SP)+,D0

.rts
	rts
ems_vib
	move.w	2(a0),d4
	move.w	per(a2),d5
	move.w	ems_count(pc),d3
	btst	#0,d3
	bne.s	ems_d
	sub.w	d4,d5
;	move.w	d5,c_per(a1)				; PERIOD!

	MOVE.L	D0,-(SP)
	MOVE.W	D5,D0
	BSR.W	PokePer
	MOVE.L	(SP)+,D0

	rts
ems_d
	add.w	d4,d5
;	move.w	d5,c_per(a1)				; PERIOD!

	MOVE.L	D0,-(SP)
	MOVE.W	D5,D0
	BSR.W	PokePer
	MOVE.L	(SP)+,D0

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
