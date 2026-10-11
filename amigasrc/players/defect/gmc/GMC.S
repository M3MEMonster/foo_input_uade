***************************************************************************
*     Game Music Creator Playroutine for Delitracker1.3/Eagleplayer       *
*   Playroutine by Andreas Tadic                                          *
*   Adaption for Delitracker by Delirium,for Eagleplayer by Buggs         *
*     neue Checkroutine, sicherer und besser von Buggs/DFT                *
***************************************************************************
;Aufbau:
; ab Offset 0 Instrumente (max. 15)
; auf Offset 240.l Songlänge in Patterns
; ab Offset 240 Songpositionen als Offsets zu den Patterns wortweise
; ab Offset 444 Patterns,Patternlänge $400, wie bei Soundtracker
	;
	incdir	include:
	include	misc/EaglePlayer.i

	SECTION 0,Code

test	=	0
begin
	ifne	test
	lea	mod,a0
	move.l	#modlen,d5
	bra	check
	endc

	PLAYERHEADER PlayerTagArray

	dc.b '$VER: Game Music Creator player module V1.6 (9 May 93)',0
	even

PlayerTagArray
	dc.l	DTP_RequestDTVersion,$ffff
	dc.l	EP_PlayerVersion,4
	dc.l	DTP_PlayerVersion,6
	dc.l	DTP_PlayerName,PName
	dc.l	DTP_Creator,CName
	dc.l	DTP_Check2,Check
	dc.l	DTP_Interrupt,Int
	dc.l	DTP_InitPlayer,InitPlay
	dc.l	DTP_EndPlayer,EndPlay
	dc.l	DTP_InitSound,MU_startmusic
	dc.l	DTP_EndSound,RemSnd

	dc.l	EP_StructInit,GetStrucAdr

	dc.l	DTP_NextPatt,MU_NextPatt
	dc.l	DTP_PrevPatt,MU_PrevPatt
	dc.l	EP_GetPositionNr,MU_GetPosNr

	dc.l	EP_Get_ModuleInfo,GetInfos

	dc.l	DTP_Volume,SetVoices
	dc.l	DTP_Balance,SetVoices
	dc.l	EP_Voices,SetVoices
	dc.l	EP_Flags,EPB_packable!EPB_VolVoices!EPB_Save!EPB_Restart!EPB_Songend!EPB_Volume!EPB_Balance!EPB_Voices!EPB_Analyzer!EPB_Moduleinfo!EPB_Nextpatt!EPB_Prevpatt
	dc.l	0
*-----------------------------------------------------------------------*
;
; Player/Creatorname und lokale Daten

PName	dc.b 'G.M.C',0
CName	dc.b 'Andreas Tadic, adapted',10
	dc.b `by Delirium & (much more) by Buggs`,0
	even
dtbase:		dc.l	0
MU_Len:		dc.l	0
MU_Speed	dc.w	0
MU_TimerOn	dc.w	0


MU_VolVoice1	dc.w	1
MU_VolVoice2	dc.w	1
MU_VolVoice3	dc.w	1
MU_VolVoice4	dc.w	1
StructAdr:	ds.b	UPS_SizeOF
;==================== Tag-Item Struktur für Module-Info ===================
MU_InfoBuffer:	
	dc.l	MI_Samples,0			;4
	dc.l	MI_MaxSamples,15		;12
	dc.l	MI_Length,0			;20
	dc.l	MI_Pattern,0			;28
	dc.l	MI_SongSize,0			;36
	dc.l	MI_SamplesSize,0		;44
	dc.l	MI_Calcsize,0			;52
	dc.l	MI_MaxPattern,64		;60
	dc.l	MI_MaxLength,100		;68
	dc.l	0
;========================================================================
Getinfos:
	lea	mu_infobuffer(pc),a4
	clr.l	4(a4)
	clr.l	20(a4)
	clr.l	28(a4)
	clr.l	36(a4)
	clr.l	44(a4)
	clr.l	52(a4)

	move.l	mu_data(pc),d0
	beq.s	nomod

	move.l	d0,a0
	lea	244(a0),a1			; Positionlist
	move.l	240(a0),d0			; Songlänge
	move.l	d0,20(A4)

	subq.l	#1,d0
	moveq	#0,d2
Chk_bigpat:					; find biggest Pattern
	move.w	(a1)+,d1
	cmp.w	d1,d2
	bge.s	Chk_nobigpat
	move.w	d1,d2
Chk_nobigpat:
	dbf	d0,Chk_bigpat
	move.l	d2,d0
	rol.w	#6,d0				;durch 1024 dividieren
	move.l	d0,28(A4)
	
	add.l	#444+1024,d2			; + Patternbeginn + 1 Pattern
	move.l	d2,36(A4)			;Songsize
	move.l	d2,52(A4)			;Calcsize

	moveq	#0,d3
	moveq	#0,d4
	moveq	#14,d0
.calcins:
	tst.l	(a0)				; Sample da ?
	beq.s	.nocalc				; Nein !
	moveq	#0,d1
	move.w	4(a0),d1			; add sampletable
	lsl.l   #1,d1
	add.l   d1,d4
	addq.w	#1,d3
.nocalc:
	lea	16(a0),a0			; next sample
	dbf     d0,.calcins
	move.l	d3,4(A4)			;NumSamples
	move.l	d4,44(a4)			;Samplessize
	add.l	d4,52(A4)			;Calcsize
nomod
	lea	(a4),a0
	rts
;========================================================================
GetStrucAdr:	lea	StructAdr(pc),a0
Return		rts
;========================================================================
MU_GetPosNr
	move.l	MU_pospointer(pc),d0
	rts
;========================================================================
MU_prevpatt:
	lea	mu_datas(pc),a3
	move.l	MU_pospointer-mu_datas(a3),d0
	subq.l	#1,d0
	blt.s	Return
	subq.l	#1,d0
;	blt.s	Return
	move.l	d0,mu_pospointer-mu_datas(A3)
;========================================================================
MU_nextpatt:
	lea	mu_datas(pc),a3
.MU_setnewpat:
	******* calc position ****
	addq.l	#1,MU_pospointer-mu_datas(a3)
	move.l	MU_pospointer-mu_datas(a3),d0
	move.l	MU_data-mu_datas(a3),a5
	cmp.l	240(a5),d0
	bhi	.MU_setstart
	***********************
	move.w	#1,MU_patterncount-mu_datas(a3)
	addq.l	#2,MU_tablepos-mu_datas(a3)
	move.l	MU_tablepos-mu_datas(a3),a0
	clr.l	d0
	move.w	(a0),d0
	move.l	MU_data-mu_datas(a3),a0
	add.l	#444,d0
	add.l	d0,a0
	move.l	a0,MU_songpointer-mu_datas(a3)
	bra	.MU_rts
	************************
.MU_setstart:
	clr.l	MU_pospointer-mu_datas(a3)
	move.l	MU_data-mu_datas(a3),MU_tablepos-mu_datas(a3)
	add.l	#242,MU_tablepos-mu_datas(a3)

	move.l	a2,-(sp)
	move.l	dtbase(pc),a2
	move.l	dtg_SongEnd(a2),a2
	jsr	(a2)		;End of Song for Playerprogram
	move.l	(sp)+,a2

	bra	.MU_setnewpat
.mu_rts
	move.l	MU_pospointer(pc),d0
	rts


*-----------------------------------------------------------------------*
*		d0 Bit 0-3 = Set Voices Bit=1 Voice on			*
SetVoices:	lea	StructAdr+UPS_DmaCon(pc),a0
		move.w	EPG_Voices(a5),(a0)				;Voices retten
		lea	MU_VolVoice1(pc),a1
		move.l	EPG_Voice1Vol(a5),(a1)
		move.l	EPG_Voice3Vol(a5),4(a1)

		lea	StructAdr+UPS_Voice1Vol(pc),a0
		lea	$dff0a0,a5
		moveq	#3,d1
.SetNew		moveq	#0,d0
		move.w	(a0),d0
		bsr.s	MU_SetVoices
		moveq	#UPS_Modulo,d0
		add.l	d0,a0
		addq.l	#8,a5
		addq.l	#8,a5
		dbf	d1,.SetNew
		rts

*-----------------------------------------------------------------------*
MU_SetVoices:	movem.l	a0/d0,-(a7)
		and.w	#$7f,d0
		lea	StructAdr(pc),a0
		cmp.l	#$dff0a0,a5			;Left Volume
		bne.s	.NoVoice1
		move.w	d0,UPS_Voice1Vol(a0)
		mulu.w	MU_VolVoice1(pc),d0
		bra.b	.SetIt
.NoVoice1:	cmp.l	#$dff0b0,a5			;Right Volume
		bne.s	.NoVoice2
		move.w	d0,UPS_Voice2Vol(a0)
		mulu.w	MU_VolVoice2(pc),d0
		bra.b	.SetIt
.NoVoice2:	cmp.l	#$dff0c0,a5			;Right Volume
		bne.s	.NoVoice3
		move.w	d0,UPS_Voice3Vol(a0)
		mulu.w	MU_VolVoice3(pc),d0
		bra.b	.SetIt
.NoVoice3:	move.w	d0,UPS_Voice4Vol(a0)
		mulu.w	MU_VolVoice4(pc),d0
.SetIt:		lsr.w	#6,d0
		move.w	d0,8(a5)
.Return:	movem.l	(a7)+,a0/d0
		rts
;========================================================================
Setvoice0
	move.w	d0,StructAdr+UPS_Voice1Vol
	mulu.w	MU_Volvoice1(pc),d0
	lsr.w	#6,d0
	move.w	d0,$dff0a8
	rts
Setvoice1
	move.w	d0,StructAdr+UPS_Voice2Vol
	mulu.w	MU_Volvoice2(pc),d0
	lsr.w	#6,d0
	move.w	d0,$dff0b8
	rts
Setvoice2
	move.w	d0,StructAdr+UPS_Voice3Vol
	mulu.w	MU_Volvoice3(pc),d0
	lsr.w	#6,d0
	move.w	d0,$dff0c8
	rts
Setvoice3
	move.w	d0,StructAdr+UPS_Voice4Vol
	mulu.w	MU_Volvoice4(pc),d0
	lsr.w	#6,d0
	move.w	d0,$dff0d8
	rts
*-----------------------------------------------------------------------*
;
;Interrupt für G.M.C Replay

Int
	movem.l	d0-d7/a0-a6,-(sp)
	lea	StructAdr(pc),a1
	move.w	#1,UPS_Enabled(a1)
	move.w	#UPSB_Adr!UPSB_LEN!UPSB_Per!UPSB_Vol!UPSB_DMACON,d0
	move.w	d0,UPS_Flags(a1)
	clr.w	UPS_Voice1Per(a1)
	clr.w	UPS_Voice2Per(a1)
	clr.w	UPS_Voice3Per(a1)
	clr.w	UPS_Voice4Per(a1)

	bsr	MU_playsong 			; DudelDiDum

	lea	StructAdr(pc),a1
	clr.w	ups_enabled(a1)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

*-----------------------------------------------------------------------*
;       Testet auf GameMusicCreator-Modul,neue Checkroutine !

Check
	ifeq	test
	move.l	dtg_ChkData(a5),a0
	move.l	dtg_Chksize(a5),d5
	endc

	cmp.l	#$400+444,d5			;min. Länge 1Pattern + Vorblock
	blt.w	CHK_fail
	cmp.l	#100,240(a0)			;Songlänge > 100
	bhi.w	CHK_fail

	lea	(a0),a1
	moveq	#14,d4
.chksam
	cmp.w	#2,12(A1)
	beq.s	.noloop
	move.l  (a1),d0
	move.l  8(a1),d1
	sub.l	d0,d1				;repeat
	blt.w	CHK_Fail
.noloop
	cmp.w	#$40,6(a1)			;Lautstärke
	bhi.w	CHK_FAIL
	move.w	4(a1),d0			;Samplelänge
	sub.w	12(a1),d0			;minus Repeatlänge
	blt.w	CHK_FAIL
	lea	16(a1),a1

	dbf	d4,.chksam

	lea	244(a0),a1
	move.l	240(a0),d0
	subq.w	#1,d0
	moveq	#0,d3
.patts	move.w	(A1)+,d1
	cmp.w	d3,d1
	ble.s	.ok
	move.w	d1,d3
.ok
	and.w	#$3ff,d1
	bne.s	CHK_FAIL
	dbf	d0,.patts

	add.l	#1024+444,d3
	cmp.l	d5,d3
	bge.s	CHK_Fail

	moveq	#0,d0				; Modul erkannt
	rts
Chk_fail
	moveq	#-1,d0				; Modul nicht erkannt
	rts

*-----------------------------------------------------------------------*
;
; Init Player

InitPlay
	moveq	#0,d0
	move.l	dtg_GetListData(a5),a0		; Function
	jsr	(a0)
	move.l	a5,dtbase
	move.l	a0,mu_data

	move.l	dtg_AudioAlloc(a5),a0		; Function
	jmp	(a0)				; returncode is already set !

*-----------------------------------------------------------------------*
;
; End Player

EndPlay
	clr.l	mu_data
	
	move.l	dtg_AudioFree(a5),a0		; Function
	jmp	(a0)

*-----------------------------------------------------------------------*
;
; End Sound

RemSnd
	bra.w	MU_stopmusic
	;
	*******************************************************
	******** GameMusicCreator Replay-routine v1.0 *********
	*******************************************************
MU_startmusic:
	lea	mu_datas(pc),a3

;	move.l	a0,MU_data-mu_datas(A3)
	move.l	MU_data(pc),a0

	move.l	a0,MU_tablepos-mu_datas(A3)
	move.l	a0,MU_songpointer-mu_datas(A3)
	add.l	#242,MU_tablepos-mu_datas(A3)
	add.l	#444,MU_songpointer-mu_datas(A3)
	move.w	#64,MU_patterncount-mu_datas(A3)
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	clr.l	MU_vol0-mu_datas(A3)
	clr.l	MU_vol2-mu_datas(A3)
	clr.l   MU_pospointer-mu_datas(A3)
	clr.w   MU_songspeed-mu_datas(A3)
	clr.w   MU_note0-mu_datas(A3)
	clr.w   MU_note1-mu_datas(A3)
	clr.w   MU_note2-mu_datas(A3)
	clr.w   MU_note3-mu_datas(A3)
	clr.w   MU_slide0-mu_datas(A3)
	clr.w   MU_slide1-mu_datas(A3)
	clr.w   MU_slide2-mu_datas(A3)
	clr.w   MU_slide3-mu_datas(A3)
	clr.w   MU_stop-mu_datas(A3)
	clr.l   MU_chan0-mu_datas(A3)
	clr.l   MU_chan1-mu_datas(A3)
	clr.l   MU_chan2-mu_datas(A3)
	clr.l   MU_chan3-mu_datas(A3)
	move.w	#6,MU_songstep-mu_datas(A3)
	move.l	a0,a2
	add.l	#244,a2
	move.l	240(a0),d1
	sub.l	#1,d1
	clr.l	d0
MU_sizeloop:
	move.w	(a2)+,d2
	cmp.w	d2,d0
	bge	MU_nosizeadd
	move.w	d2,d0
MU_nosizeadd:
	dbf	d1,MU_sizeloop
	add.l	#1024,d0
	lea.l	444(a0),a1
	add.l	d0,a1

	moveq	#14,d7
;	bsr	MU_calcins
;	move.l	$6c,MU_oldirq+2			; schauder !!!
;	move.l	#MU_interrupt,$6c		; würg !!!
;	rts

MU_calcins:
	tst.l	(a0)
	bne	MU_calcit
	addq.l	#8,a0
	addq.l	#8,a0
	dbf	d7,MU_calcins
	rts

MU_calcit:
	move.l  (a0),d0
	move.l  8(a0),d1
	sub.l   d0,d1  ;repeat
	move.l  a1,(a0)
	move.l  a1,d0
	add.l   d1,d0
	move.l  d0,8(a0) ;set repeat
	cmp.w   #2,12(a0)
	bne     MU_looping
	move.l  #MU_empty,8(a0)
MU_looping:
	clr.l   d0
	move.w  4(a0),d0 ;add sampletable
	lsl.l   #1,d0
	add.l   d0,a1
	add.l   #16,a0
	dbf     d7,MU_calcins
	rts

MU_stopmusic:
;	move.l  MU_oldirq+2,$6c			; hilfe !!!
	clr.w   $dff0a8
	clr.w   $dff0b8
	clr.w   $dff0c8
	clr.w   $dff0d8
	move.w  #$f,$dff096
	rts

;MU_interrupt:
;	movem.l  d0-d7/a0-a6,-(a7)
;	btst     #5,$dff01f			; kotz !!
;	beq      MU_novertblank
;	bsr      MU_playsong
;MU_novertblank:
;	movem.l  (a7)+,d0-d7/a0-a6
;MU_oldirq:  jmp $0				; oh weh !!!

MU_playsong:
	lea	mu_datas(pc),a3
	lea	$dff0a0,a4
	bsr	MU_everyvert
	add.w	#1,MU_songspeed-mu_datas(a3)
	move.w	MU_songstep-mu_datas(a3),d0
	cmp.w	MU_songspeed-mu_datas(a3),d0
	ble	MU_okplay
	rts
MU_okplay: 
	clr.w	MU_songspeed-mu_datas(a3)
	add.w	#1,MU_patterncount-mu_datas(a3)
	cmp.w	#65,MU_patterncount-mu_datas(a3)
	bne	MU_playit
MU_setnewpat:
	******* calc position ****
	add.l	#1,MU_pospointer-mu_datas(a3)
	move.l	MU_pospointer-mu_datas(a3),d0
	move.l	MU_data-mu_datas(a3),a5
	cmp.l	240(a5),d0
	bhi	MU_setstart
	***********************
	move.w	#1,MU_patterncount-mu_datas(a3)
	add.l	#2,MU_tablepos-mu_datas(a3)
	move.l	MU_tablepos-mu_datas(a3),a0
	clr.l	d0
	move.w	(a0),d0
	move.l	MU_data-mu_datas(a3),a0
	add.l	#444,a0
	add.l	d0,a0
	move.l	a0,MU_songpointer-mu_datas(a3)
	bra	MU_playit
	************************
MU_setstart:
	clr.l	MU_pospointer-mu_datas(a3)
	move.l	MU_data-mu_datas(a3),MU_tablepos-mu_datas(a3)
	add.l	#242,MU_tablepos-mu_datas(a3)

	move.l	a2,-(sp)
	move.l	dtbase(pc),a2
	move.l	dtg_SongEnd(a2),a2
	jsr	(a2)		;End of Song for Playerprogram
	move.l	(sp)+,a2

	bra	MU_setnewpat
MU_playit:
	move.l	MU_songpointer-mu_datas(a3),a0
	add.l	#16,MU_songpointer-mu_datas(a3)
	move.l	(a0),d0
	clr.w	d3
	move.w	#1,d2
	bsr	MU_setinstr
	bsr	MU_seteffect
	move.l	4(a0),d0
	move.w	#2,d2
	bsr	MU_setinstr
	bsr	MU_seteffect
	move.l	8(a0),d0
	move.w	#3,d2
	bsr	MU_setinstr
	bsr	MU_seteffect
	move.l  12(a0),d0
	move.w  #4,d2
	bsr     MU_setinstr
	bsr     MU_seteffect
	move.w  d3,$dff096
	rts

MU_setinstr:
	move.w  d0,d5
	and.w   #$f000,d0
	cmp.w   #0,d0
	bne     MU_setit
	rts

MU_setit:
	swap    d0
	move.w  d0,d1
	clr.w   d0
	swap    d0
	lsr.w   #8,d0
	lsr.w   #4,d0
	sub.w   #1,d0
	lsl.w   #4,d0
	move.l  MU_data-mu_datas(a3),a6
	add.l   d0,a6
	cmp.w   #1,d2
	bne     MU_conti1
	clr.w   $dff0a8
	move.l  a6,MU_chan0-mu_datas(a3)
	move.l  (a6),(a4)
	move.l	(a6),structadr+ups_voice1adr-mu_datas(a3)
	move.w  4(a6),4(A4)
	move.w	4(a6),structadr+ups_voice1len-mu_datas(a3)
	move.w  d1,6(A4)
	move.w	d1,structadr+ups_voice1per-mu_datas(a3)
	move.w  d1,MU_note0-mu_datas(a3)
	move.w  6(a6),MU_vol0-mu_datas(a3)
	move.w	6(a6),structadr+ups_voice1vol-mu_datas(a3)
	clr.w   MU_slide0-mu_datas(a3)
	bset    #0,d3
	rts

MU_conti1:
	cmp.w   #2,d2
	bne     MU_conti2
	clr.w   $dff0b8
	move.l  a6,MU_chan1-mu_datas(a3)
	move.l  (a6),$10(a4)
	move.w  4(a6),$14(A4)
	move.w  d1,$16(A4)
	move.w  d1,MU_note1-mu_datas(a3)
	move.w  6(a6),MU_vol1-mu_datas(a3)

	move.w	d1,structadr+ups_voice2per-mu_datas(a3)
	move.l	(a6),structadr+ups_voice2adr-mu_datas(a3)
	move.w	4(a6),structadr+ups_voice2len-mu_datas(a3)
	move.w	6(a6),structadr+ups_voice2vol-mu_datas(a3)
	clr.w   MU_slide1-mu_datas(a3)
	bset    #1,d3
	rts

MU_conti2:
	cmp.w   #3,d2
	bne     MU_conti3
	clr.w   $dff0c8
	move.l  a6,MU_chan2-mu_datas(a3)
	move.l  (a6),$20(A4)
	move.w  4(a6),$24(A4)
	move.w  d1,$26(A4)
	move.w  d1,MU_note2-mu_datas(a3)
	move.w  6(a6),MU_vol2-mu_datas(a3)

	move.w	d1,structadr+ups_voice3per-mu_datas(a3)
	move.l	(a6),structadr+ups_voice3adr-mu_datas(a3)
	move.w	4(a6),structadr+ups_voice3len-mu_datas(a3)
	move.w	6(a6),structadr+ups_voice3vol-mu_datas(a3)

	clr.w   MU_slide2
	bset    #2,d3
	rts

MU_conti3:
	clr.w   $dff0d8
	move.l  a6,MU_chan3-mu_datas(a3)
	move.l  (a6),$30(A4)
	move.w  4(a6),$34(A4)
	move.w  d1,$36(A4)
	move.w  d1,MU_note3-mu_datas(a3)
	move.w  6(a6),MU_vol3-mu_datas(a3)
	move.w	d1,structadr+ups_voice4per-mu_datas(a3)

	move.l	(a6),structadr+ups_voice4adr-mu_datas(a3)
	move.w	4(a6),structadr+ups_voice4len-mu_datas(a3)
	move.w	6(a6),structadr+ups_voice4vol-mu_datas(a3)

	clr.w   MU_slide3-mu_datas(a3)
	bset    #3,d3
	rts

MU_seteffect:
	move.w  d5,d6
	and.w   #$00ff,d5
	and.w   #$0f00,d6
	cmp.w   #0,d6
	beq     MU_effjump2

	cmp.w   #$0100,d6
	beq     MU_slideup

	cmp.w   #$0200,d6
	beq     MU_slidedown

	cmp.w   #$0300,d6
	beq     MU_setvolume

	cmp.w   #$0500,d6
	beq     MU_posjump

	cmp.w   #$0400,d6
	bne     MU_nobreak
MU_itsabreak:
	move.w  #64,MU_patterncount-mu_datas(a3)
	rts

MU_nobreak:
	cmp.w   #$0800,d6
	bne     MU_effjump0
	move.w  d5,MU_songstep
	rts

MU_effjump0:
	cmp.w   #$0600,d6
	bne     MU_effjump1
;	bclr    #1,$bfe001
	rts

MU_effjump1:
	cmp.w   #$0700,d6
	bne     MU_effjump2
;	bset    #1,$bfe001
MU_effjump2:
	rts

MU_posjump:
	clr.l   d4
	move.w  d5,d4
	sub.l   #1,d4
	move.l  d4,MU_pospointer-mu_datas(a3)
	add.l   #1,d4
	lsl.w   #1,d4
	sub.w   #2,d4
	move.l  MU_data-mu_datas(a3),a0
	add.l   #244,a0
	add.l   d4,a0
	move.l  a0,MU_tablepos-mu_datas(a3)
	bra     MU_itsabreak
MU_slideup:
	neg.w   d5
MU_slidedown:
	cmp.w   #1,d2
	bne     MU_j1
	move.w  d5,MU_slide0-mu_datas(a3)
	rts

MU_j1:
	cmp.w   #2,d2
	bne     MU_j2
	move.w  d5,MU_slide1-mu_datas(a3)
	rts

MU_j2:
	cmp.w   #3,d2
	bne     MU_j3
	move.w  d5,MU_slide2-mu_datas(a3)
	rts

MU_j3:
	move.w  d5,MU_slide3-mu_datas(a3)
	rts

MU_setvolume:
	cmp.w   #1,d2
	bne     MU_j00
	move.w  d5,MU_vol0-mu_datas(a3)
	;move.w  d5,$dff0a8
	rts
MU_j00:
	cmp.w   #2,d2
	bne     MU_j22
	move.w  d5,MU_vol1-mu_datas(a3)
	;move.w  d5,$dff0b8
	rts
MU_j22:
	cmp.w   #3,d2
	bne     MU_j33
	move.w  d5,MU_vol2-mu_datas(a3)
	;move.w  d5,$dff0c8
	rts
MU_j33:
	move.w  d5,MU_vol3-mu_datas(a3)
	;move.w  d5,$dff0d8
	rts
MU_everyvert:
	move.w  MU_slide0-mu_datas(a3),d0
	add.w   d0,MU_note0-mu_datas(a3)
	move.w  MU_note0-mu_datas(a3),$6(a4)
;	move.w	MU_note0-mu_datas(a3),structadr+ups_voice1per-mu_datas(a3)
	move.w  MU_slide1-mu_datas(a3),d0
	add.w   d0,MU_note1-mu_datas(a3)
	move.w  MU_note1-mu_datas(a3),$16(A4)
;	move.w	MU_note1-mu_datas(a3),structadr+ups_voice2per-mu_datas(a3)
	move.w  MU_slide2-mu_datas(a3),d0
	add.w   d0,MU_note2-mu_datas(a3)
	move.w  MU_note2-mu_datas(a3),$26(A4)
;	move.w	MU_note2-mu_datas(a3),structadr+ups_voice3per-mu_datas(a3)
	move.w  MU_slide3-mu_datas(a3),d0
	add.w   d0,MU_note3-mu_datas(a3)
	move.w  MU_note3-mu_datas(a3),$36(A4)
;	move.w	MU_note3-mu_datas(a3),structadr+ups_voice4per-mu_datas(a3)
	btst    #0,MU_stop-mu_datas(a3)
	beq     MU_ok1
	bclr    #0,MU_stop-mu_datas(a3)
	move.l  MU_chan0-mu_datas(a3),a0
	move.l  8(a0),(A4)
	move.w  12(a0),$4(A4)
	move.l	8(a0),structadr+ups_voice1adr-mu_datas(a3)
	move.w	12(a0),structadr+ups_voice1len-mu_datas(a3)
	clr.l   MU_chan0-mu_datas(a3)
MU_ok1:
	btst    #1,MU_stop-mu_datas(a3)
	beq     MU_ok2
	bclr    #1,MU_stop-mu_datas(a3)
	move.l  MU_chan1-mu_datas(a3),a0
	move.l  8(a0),$10(A4)
	move.w  12(a0),$14(A4)
	move.l	8(a0),structadr+ups_voice2adr-mu_datas(a3)
	move.w	12(a0),structadr+ups_voice2len-mu_datas(a3)
	clr.l   MU_chan1-mu_datas(a3)
MU_ok2:
	btst    #2,MU_stop-mu_datas(a3)
	beq     MU_ok3
	bclr    #2,MU_stop-mu_datas(a3)
	move.l  MU_chan2-mu_datas(a3),a0
	move.l  8(a0),$20(A4)
	move.w  12(a0),$24(A4)
	move.l	8(a0),structadr+ups_voice3adr-mu_datas(a3)
	move.w	12(a0),structadr+ups_voice3len-mu_datas(a3)
	clr.l   MU_chan2-mu_datas(a3)
MU_ok3:
	btst    #3,MU_stop-mu_datas(a3)
	beq     MU_ok4
	bclr    #3,MU_stop-mu_datas(a3)
	move.l  MU_chan3-mu_datas(a3),a0
	move.l  8(a0),$30(A4)
	move.w  12(a0),$34(A4)
	move.l	8(a0),structadr+ups_voice4adr-mu_datas(a3)
	move.w	12(a0),structadr+ups_voice4len-mu_datas(a3)
	clr.l   MU_chan3-mu_datas(a3)
MU_ok4:
	move.w   #$8000,d3
	cmp.l    #0,MU_chan0-mu_datas(a3)
	beq.s	MU_okk1
	bset     #0,MU_stop-mu_datas(a3)
	bset     #0,d3
MU_okk1:
	cmp.l    #0,MU_chan1-mu_datas(a3)
	beq.s	MU_okk2
	bset     #1,MU_stop-mu_datas(a3)
	bset     #1,d3
MU_okk2:
	cmp.l    #0,MU_chan2-mu_datas(a3)
	beq.s	MU_okk3
	bset     #2,MU_stop-mu_datas(a3)
	bset     #2,d3
MU_okk3:
	cmp.l    #0,MU_chan3-mu_datas(a3)
	beq.s	MU_okk4
	bset     #3,MU_stop-mu_datas(a3)
	bset     #3,d3
MU_okk4:
	move.w   d3,-10(A4)

	move.w   MU_vol0-mu_datas(a3),d0
	bsr	setvoice0			;$dff0a8
	move.w   MU_vol1-mu_datas(a3),d0
	bsr	setvoice1			;$dff0b8
	move.w   MU_vol2-mu_datas(a3),d0
	bsr	setvoice2			;$dff0c8
	move.w   MU_vol3-mu_datas(a3),d0
	bsr	setvoice3			;$dff0d8
	rts

	********** variables *****
mu_datas:
MU_stop:  dc.w 0
MU_slide0: dc.w 0
MU_slide1: dc.w 0
MU_slide2: dc.w 0
MU_slide3: dc.w 0
MU_chan0: dc.l 0
MU_chan1: dc.l 0
MU_chan2: dc.l 0
MU_chan3: dc.l 0
MU_note0: dc.w 0
MU_note1: dc.w 0
MU_note2: dc.w 0
MU_note3: dc.w 0
MU_vol0: dc.w 0
MU_vol1: dc.w 0
MU_vol2: dc.w 0
MU_vol3: dc.w 0
MU_songspeed: dc.w 0
MU_songstep: dc.w 5
MU_patterncount: dc.w 0
MU_songpointer: dc.l 0
MU_tablepos: dc.l 0
MU_pospointer: dc.l 0 
MU_data: dc.l  0

;
;
	SECTION GMCData,Data_C
;
;

MU_empty: dcb.l 2,0

	ifne	test
mod
	incdir	vr0:
	incbin	gmc.melody
;	incbin	gmc.knightsofsky_title
modlen=*-mod
	endc
	end
