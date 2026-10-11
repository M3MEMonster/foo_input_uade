***************************************************************************
* Future Compose 1.4 Eagleplayer/Deliplayer1.3+ ,Playroutine by Supersero *
* adapted by Buggs of DEFECT                                              *
***************************************************************************

	incdir	Include:
	include	"misc/EaglePlayer.i"

	SECTION Player,Code

	PLAYERHEADER PlayerTagArray

	dc.b '$VER: FutureComposer 1.4 Eagleplayer module V1.3 (Jan/26/93)',0
	even

PlayerTagArray
	dc.l	DTP_RequestDTVersion,$ffff
	dc.l	EP_PlayerVersion,4
	dc.l	DTP_PlayerVersion,6
	dc.l	DTP_PlayerName,Fcname
	dc.l	DTP_Creator,Creator
	dc.l	DTP_Check2,testifitis
	dc.l	DTP_Interrupt,FC14_Music
	dc.l	DTP_InitPlayer,GetAudio
	dc.l	DTP_EndPlayer,Freeaudio
	dc.l	DTP_InitSound,init_Music
	dc.l	DTP_EndSound,End_Music

	dc.l	DTP_Volume,SetVoices
	dc.l	DTP_Balance,SetVoices
	dc.l	EP_Voices,SetVoices
;	dc.l	DTP_Nextpatt,nextpatt

	dc.l	EP_StructInit,StrukInit
	dc.l	EP_StructEnd,StrukEnd

	dc.l	EP_Flags,EPB_Packable!EPB_VolVoices!EPB_Save!EPB_Restart!EPB_Songend!EPB_Volume!EPB_Balance!EPB_Voices!EPB_Analyzer
	dc.l	0

;========================================================================

FCName	dc.b 'FutureComposer 1.4',0
Creator	dc.b 'SuperSero of the Superions,',10
	dc.b 'adapted by Buggs of DEFECT',0
	even
FC14_Data	dc.l	0
Dtbase		dc.l	0
FC_Structadr:	ds.b	UPS_Sizeof


FC_VolVoice1	dc.w	1
FC_VolVoice2	dc.w	1
FC_VolVoice3	dc.w	1
FC_VolVoice4	dc.w	1

Nextpatt
;	lea	audtemp(pc),a5
;	move.w	6(a5),4(a5)		;Restore replayspeed counter
;	moveq	#0,d5
;	lea	V1data(pc),a0		;Point to voice1 data area
;	cmp.w	#64,40(a0)
;	bsr	new_note
;	lea	V2data(pc),a0		;Point to voice2 data area
;	cmp.w	#64,40(a0)
;	bsr	new_note
;	lea	V3data(pc),a0		;Point to voice3 data area
;	cmp.w	#64,40(a0)
;	bsr	new_note
;	lea	V4data(pc),a0		;Point to voice4 data area
;	cmp.w	#64,40(a0)
;	bra	new_note
;=========== Struktur übergeben und Sampleadressen löschen ==============
Strukinit:
	lea	FC_StructAdr(pc),a0
StrukEnd:
	rts
;========= Load Module & Get Audio Channels ===========================
Getaudio
	moveq	#0,d0
	move.l	dtg_GetListData(a5),a0		; Function
	jsr	(a0)

	move.l	a0,FC14_Data
	move.l	a5,dtbase

	move.l	dtg_AudioAlloc(a5),a0
	jmp	(a0)
;=============== Free Audio Channels ===================================
Freeaudio
	move.l	dtg_AudioFree(a5),a0
	jmp	(a0)
;========================== Is is a Futurecomposer 1.4 Module ??? ========
testifitis
	move.l	dtg_ChkData(a5),a0
	move.l	(a0),d0
	sub.l	#"FC14",d0
	rts
;========================================================================
;==	d0 Bit 0-3 = Set Voices Bit=1 Voice on			       ==

*-----------------------------------------------------------------------*
*		d0 Bit 0-3 = Set Voices Bit=1 Voice on			*
SetVoices:	lea	FC_StructAdr+UPS_DmaCon(pc),a0
		move.w	EPG_Voices(a5),(a0)				;Voices retten
		lea	FC_VolVoice1(pc),a1
		move.l	EPG_Voice1Vol(a5),(a1)
		move.l	EPG_Voice3Vol(a5),4(a1)

		lea	FC_StructAdr+UPS_Voice1Vol(pc),a0
		lea	$dff0a0,a5
		moveq	#3,d1
.SetNew		moveq	#0,d0
		move.w	(a0),d0
		bsr.s	FC_SetVoices
		moveq	#UPS_Modulo,d0
		add.l	d0,a0
		addq.l	#8,a5
		addq.l	#8,a5
		dbf	d1,.SetNew
		rts

*-----------------------------------------------------------------------*
FC_SetVoices:	movem.l	a0/d0,-(a7)
		and.w	#$7f,d0
		lea	FC_StructAdr(pc),a0
		cmp.l	#$dff0a0,a5			;Left Volume
		bne.s	.NoVoice1
		move.w	d0,UPS_Voice1Vol(a0)
		mulu.w	FC_VolVoice1(pc),d0
		bra.b	.SetIt
.NoVoice1:	cmp.l	#$dff0b0,a5			;Right Volume
		bne.s	.NoVoice2
		move.w	d0,UPS_Voice2Vol(a0)
		mulu.w	FC_VolVoice2(pc),d0
		bra.b	.SetIt
.NoVoice2:	cmp.l	#$dff0c0,a5			;Right Volume
		bne.s	.NoVoice3
		move.w	d0,UPS_Voice3Vol(a0)
		mulu.w	FC_VolVoice3(pc),d0
		bra.b	.SetIt
.NoVoice3:	move.w	d0,UPS_Voice4Vol(a0)
		mulu.w	FC_VolVoice4(pc),d0
.SetIt:		lsr.w	#6,d0
		move.w	d0,8(a5)
.Return:	movem.l	(a7)+,a0/d0
		rts

*********************************************************
**  Amiga FUTURE COMPOSER  »» V1.4 ««  Replay routine  **
*********************************************************
;Doesn't work with V1.0 - V1.3 modules !!

END_MUSIC:
	clr.w	onoff
	lea	$dff096,a0
	clr.l	$10(A0)
	clr.l	$20(A0)
	clr.l	$30(A0)
	clr.l	$40(A0)
	move.w	#$000f,(a0)
	rts

INIT_MUSIC:
	move.w #1,onoff
	move.l FC14_Data,a0
	lea 180(a0),a1
	move.l a1,SEQpoint
	move.l a0,a1
	add.l 8(a0),a1
	move.l a1,PATpoint
	move.l a0,a1
	add.l 16(a0),a1
	move.l a1,FRQpoint
	move.l a0,a1
	add.l 24(a0),a1
	move.l a1,VOLpoint
	move.l 4(a0),d0
	divu #13,d0

	lea	40(a0),a1
	lea	SOUNDINFO+4,a2
	moveq	#10-1,d1
initloop:
	move.w (a1)+,(a2)+
	move.l (a1)+,(a2)+
	adda.w #10,a2
	dbf d1,initloop
	move.l a0,d1
	add.l 32(a0),d1
	lea SOUNDINFO,a3
	move.l d1,(a3)+
	moveq #9-1,d3
	moveq #0,d2
initloop1:
	move.w (a3),d2
	add.l d2,d1
	add.l d2,d1
	addq.l #2,d1
	adda.w #12,a3
	move.l d1,(a3)+
	dbf d3,initloop1

	lea 100(a0),a1
	lea SOUNDINFO+(10*16),a2
	move.l a0,a3
	add.l 36(a0),a3

	moveq #80-1,d1
	moveq #0,d2
initloop2:
	move.l a3,(a2)+
	move.b (a1)+,d2
	move.w d2,(a2)+
	clr.w (a2)+
	move.w d2,(a2)+
	addq.w #6,a2
	add.w d2,a3
	add.w d2,a3
	dbf d1,initloop2

	move.l SEQpoint(pc),a0
	moveq #0,d2
	move.b 12(a0),d2		;Get replay speed
	bne.s speedok
	move.b #3,d2			;Set default speed
speedok:
	move.w d2,respcnt		;Init repspeed counter
	move.w d2,repspd
INIT2:
	clr.w audtemp
	clr.w spdtemp
	move.w #$000f,$dff096		;Disable audio DMA
	move.w #$0780,$dff09a		;Disable audio IRQ
	moveq #0,d7
	mulu #13,d0
	moveq #4-1,d6			;Number of soundchannels-1
	lea V1data(pc),a0		;Point to 1st voice data area
	lea silent,a1
	lea Chandata(pc),a2
initloop3:
	move.l a1,10(a0)
	move.l a1,18(a0)
	clr.w 4(a0)
	move.w #$000d,6(a0)
	clr.w 8(a0)
	clr.l 14(a0)
	move.b #$01,23(a0)
	move.b #$01,24(a0)
	clr.b 25(a0)
	clr.l 26(a0)
	clr.w 30(a0)
	clr.l 38(a0)
	clr.w 42(a0)
	clr.l 44(a0)
	clr.l 48(a0)
	clr.w 56(a0)
	moveq #$00,d3
	move.w (a2)+,d1
	move.w (a2),d3
	divu #$0003,d3
	moveq #0,d4
	bset d3,d4
	move.w d4,32(a0)
	move.w (a2)+,d3
	andi.l #$00ff,d3
	andi.l #$00ff,d1
	lea $dff0a0,a6
	add.w d1,a6
	move.l #$0000,(a6)
	move.w #$0100,4(a6)
	move.w #$0000,6(a6)
	move.w #$0000,8(a6)
	move.l a6,60(a0)
	move.l SEQpoint(pc),(a0)
	move.l SEQpoint(pc),52(a0)
	add.l d0,52(a0)
	add.l d3,52(a0)
	add.l d7,(a0)
	add.l d3,(a0)
	move.l (a0),a3
	move.b (a3),d1
	andi.l #$00ff,d1
	lsl.w #6,d1
	move.l PATpoint(pc),a4
	adda.w d1,a4
	move.l a4,34(a0)
	move.b 1(a3),44(a0)
	move.b 2(a3),22(a0)
	lea $4a(a0),a0		;Point to next voice's data area
	dbf d6,initloop3
	rts
FC14_Music
	movem.l	d1-a6,-(sp)
	lea	FC_StructAdr(pc),a1
	moveq	#-1,d0
	move.w	d0,UPS_Enabled(a1)
	move.w	#UPSB_Adr!UPSB_LEN!UPSB_Per!UPSB_Vol!UPSB_DMACON,d0
		;UPSB_Note;UPSB_SNr;UPSB_STy;UPSB_Res
	move.w	d0,UPS_Flags(a1)
	clr.w	UPS_Voice1Per(a1)
	clr.w	UPS_Voice2Per(a1)
	clr.w	UPS_Voice3Per(a1)
	clr.w	UPS_Voice4Per(a1)

	bsr.s	PLAY

	lea	FC_StructAdr(pc),a1
	clr.w	UPS_Enabled(a1)

	movem.l	(a7)+,d1-a6
	moveq	#0,d0
	rts
PLAY:
	lea audtemp(pc),a5
	tst.w 8(a5)
	bne.s music_on
	rts
music_on:
	moveq #6,d6
	subq.w #1,4(a5)			;Decrease replayspeed counter
	bne.s nonewnote
	move.w 6(a5),4(a5)		;Restore replayspeed counter
	moveq #0,d5
	lea V1data(pc),a0		;Point to voice1 data area
	bsr new_note
	lea V2data(pc),a0		;Point to voice2 data area
	bsr new_note
	lea V3data(pc),a0		;Point to voice3 data area
	bsr new_note
	lea V4data(pc),a0		;Point to voice4 data area
	bsr new_note
nonewnote:
	clr.w (a5)
	lea $dff000,a6
	lea V1data(pc),a0
	bsr effects

	swap	d0
	move.w	d0,$a6(a6)
	move.w	d0,FC_StructAdr+UPS_Voice1per
	swap	d0

	move.w	d0,FC_StructAdr+UPS_Voice1Vol
	mulu	FC_Volvoice1(pc),d0
	lsr.w	#6,d0
	move.w	d0,$a8(a6)

	lea V2data(pc),a0
	bsr effects

	swap	d0
	move.w	d0,$b6(a6)
	move.w	d0,FC_StructAdr+UPS_Voice2per
	swap	d0

	move.w	d0,FC_StructAdr+UPS_Voice2Vol
	mulu	FC_volvoice2(pc),d0
	lsr.w	#6,d0
	move.w	d0,$b8(a6)

	lea V3data(pc),a0
	bsr effects

	swap	d0
	move.w	d0,$c6(a6)
	move.w	d0,FC_StructAdr+UPS_Voice3per
	swap	d0
	move.w	d0,FC_StructAdr+UPS_Voice3Vol
	mulu	FC_Volvoice3(pc),d0
	lsr.w	#6,d0
	move.w	d0,$c8(a6)

	lea V4data(pc),a0
	bsr effects

	swap	d0
	move.w	d0,$d6(a6)
	move.w	d0,FC_StructAdr+UPS_Voice4per
	swap	d0
	move.w	d0,FC_StructAdr+UPS_Voice4Vol
	mulu	FC_Volvoice4(pc),d0
	lsr.w	#6,d0
	move.w	d0,$d8(a6)

	lea V1data(pc),a0
	move.l 68+(0*74)(a0),a1		;Get samplepointer
	adda.w 64+(0*74)(a0),a1		;add repeat_start
	move.l 68+(1*74)(a0),a2
	adda.w 64+(1*74)(a0),a2
	move.l 68+(2*74)(a0),a3
	adda.w 64+(2*74)(a0),a3
	move.l 68+(3*74)(a0),a4
	adda.w 64+(3*74)(a0),a4
	move.w 66+(0*74)(a0),d1		;Get repeat_length
	move.w 66+(1*74)(a0),d2
	move.w 66+(2*74)(a0),d3
	move.w 66+(3*74)(a0),d4
	moveq #2,d0
	moveq #0,d5
	move.w (a5),d7
	ori.w #$8000,d7			;Set/clr bit = 1
	move.w d7,$dff096		;Enable audio DMA
chan1:
	lea V1data+72(pc),a0
	move.w (a0),d7
	beq.s chan2
	subq.w #1,(a0)
	cmp.w d0,d7
	bne.s chan2
	move.w d5,(a0)
	move.l	a1,$a0(a6)		;Set samplestart
	move.w	d1,$a4(a6)		;Set samplelength
	move.l	a1,FC_structadr+UPS_Voice1adr
	move.w	d1,FC_structadr+UPS_Voice1len
chan2:
	lea V2data+72(pc),a0
	move.w (a0),d7
	beq.s chan3
	subq.w #1,(a0)
	cmp.w d0,d7
	bne.s chan3
	move.w d5,(a0)
	move.l a2,$b0(a6)
	move.w d2,$b4(a6)
	move.l	a2,FC_structadr+UPS_Voice2adr
	move.w	d2,FC_structadr+UPS_Voice2len
chan3:
	lea V3data+72(pc),a0
	move.w (a0),d7
	beq.s chan4
	subq.w #1,(a0)
	cmp.w d0,d7
	bne.s chan4
	move.w d5,(a0)
	move.l a3,$c0(a6)
	move.w d3,$c4(a6)
	move.l	a3,FC_structadr+UPS_Voice3adr
	move.w	d3,FC_structadr+UPS_Voice3len
chan4:
	lea V4data+72(pc),a0
	move.w (a0),d7
	beq.s endplay
	subq.w #1,(a0)
	cmp.w d0,d7
	bne.s endplay
	move.w d5,(a0)
	move.l a4,$d0(a6)
	move.w d4,$d4(a6)
	move.l	a4,FC_structadr+UPS_Voice4adr
	move.w	d4,FC_structadr+UPS_Voice4len
endplay:
	rts
new_note:
	move.l 34(a0),a1
	adda.w 40(a0),a1
	cmp.b #$49,(a1)		;Check "END" mark in pattern
	beq.s patend
	cmp.w #64,40(a0)		;Have all the notes been played?
	bne samepat
patend:
	move.w d5,40(a0)
	move.l (a0),a2
	adda.w 6(a0),a2		;Point to next sequence row
	cmpa.l 52(a0),a2	;Is it the end?
	bne.s notend

	movem.l	d0-a6,-(sp)
	move.l	dtbase(pc),a5
	move.l	dtg_SongEnd(a5),a2
	jsr	(a2)		;End Of Song My Master
	movem.l	(sp)+,d0-a6

	move.w d5,6(a0)		;yes!
	move.l (a0),a2		;Point to first sequence
notend:
	lea spdtemp(pc),a3
	moveq #1,d1
	addq.b #1,(a3)
	cmpi.b #5,(a3)
	bne.s nonewspd
	move.b d1,(a3)
	move.b 12(a2),d1	;Get new replay speed
	beq.s nonewspd
	move.w d1,2(a3)		;store in counter
	move.w d1,4(a3)
nonewspd:
	move.b (a2)+,d1		;Pattern to play
	move.b (a2)+,44(a0)	;Transpose value
	move.b (a2)+,22(a0)	;Soundtranspose value
	lsl.w d6,d1
	move.l PATpoint(pc),a1	;Get pattern pointer
	add.w d1,a1
	move.l a1,34(a0)
	addi.w #$000d,6(a0)
samepat:
	move.b 1(a1),d1		;Get info byte
	move.b (a1)+,d0		;Get note
	bne.s ww1
	andi.w #%11000000,d1
	beq.s noport
	bra.s ww11
ww1:
	move.w d5,56(a0)
ww11:
	move.b d5,47(a0)
	btst #7,d1
	beq.s noport
	move.b 2(a1),47(a0)	
noport:
	andi.w #$007f,d0
	beq nextnote
	move.b d0,8(a0)
	move.b (a1),d1
	move.b d1,9(a0)
	move.w 32(a0),d3
	or.w d3,(a5)
	move.w d3,$dff096
	andi.w #$003f,d1	;Max 64 instruments
	add.b 22(a0),d1		;add Soundtranspose
	move.l VOLpoint(pc),a2
	lsl.w d6,d1
	adda.w d1,a2
	move.w d5,16(a0)
	move.b (a2),23(a0)
	move.b (a2)+,24(a0)
	moveq #0,d1
	move.b (a2)+,d1
	move.b (a2)+,27(a0)
	move.b #$40,46(a0)
	move.b (a2),28(a0)
	move.b (a2)+,29(a0)
	move.b (a2)+,30(a0)
	move.l a2,10(a0)
	move.l FRQpoint(pc),a2
	lsl.w d6,d1
	adda.w d1,a2
	move.l a2,18(a0)
	move.w d5,50(a0)
	move.b d5,25(a0)
	move.b d5,26(a0)
nextnote:
	addq.w #2,40(a0)
	rts

effects:
	moveq #0,d7
testsustain:
	tst.b 26(a0)		;Is sustain counter = 0
	beq.s sustzero
	subq.b #1,26(a0)	;if no, decrease counter
	bra VOLUfx
sustzero:		;Next part of effect sequence
	move.l 18(a0),a1	;can be executed now.
	adda.w 50(a0),a1
testeffects:
	cmpi.b #$e1,(a1)	;E1 = end of FREQseq sequence
	beq VOLUfx
	move.b (a1),d0
	cmpi.b #$e0,d0		;E0 = loop to other part of sequence
	bne.s testnewsound
	move.b 1(a1),d1		;loop to start of sequence + 1(a1)
	andi.w #$003f,d1
	move.w d1,50(a0)
	move.l 18(a0),a1
	adda.w d1,a1
	move.b (a1),d0
testnewsound:
	cmpi.b #$e2,d0		;E2 = set waveform
	bne.s testE4
	move.w 32(a0),d1
	or.w d1,(a5)
	move.w d1,$dff096
	moveq #0,d0
	move.b 1(a1),d0
	lea SOUNDINFO,a4
	lsl.w #4,d0
	adda.w d0,a4
	move.l 60(a0),a3
	move.l (a4)+,d1
	move.l d1,(a3)
	move.l d1,68(a0)
	move.w (a4)+,4(a3)
	move.l (a4),64(a0)
	move.w #$0003,72(a0)
	move.w d7,16(a0)
	move.b #$01,23(a0)
	addq.w #2,50(a0)
	bra transpose
testE4:
	cmpi.b #$e4,d0
	bne.s testE9
	moveq #0,d0
	move.b 1(a1),d0
	lea SOUNDINFO,a4
	lsl.w #4,d0
	adda.w d0,a4
	move.l 60(a0),a3
	move.l (a4)+,d1
	move.l d1,(a3)
	move.l d1,68(a0)
	move.w (a4)+,4(a3)
	move.l (a4),64(a0)
	move.w #$0003,72(a0)
	addq.w #2,50(a0)
	bra transpose
testE9:
	cmpi.b #$e9,d0
	bne testpatjmp
	move.w 32(a0),d1
	or.w d1,(a5)
	move.w d1,$dff096
	moveq #0,d0
	move.b 1(a1),d0
	lea SOUNDINFO,a4
	lsl.w #4,d0
	adda.w d0,a4
	move.l (a4),a2
	cmpi.l #"SSMP",(a2)+
	bne.s nossmp
	lea 320(a2),a4
	moveq #0,d1
	move.b 2(a1),d1
	lsl.w #4,d1
	add.w d1,a2
	add.l (a2),a4
	move.l 60(a0),a3
	move.l a4,(a3)
	move.l 4(a2),4(a3)
	move.l a4,68(a0)
	move.l 6(a2),64(a0)
	move.w d7,16(a0)
	move.b #1,23(a0)
	move.w #3,72(a0)
nossmp:
	addq.w #3,50(a0)
	bra.s transpose
testpatjmp:
	cmpi.b #$e7,d0
	bne.s testpitchbend
	moveq #0,d0
	move.b 1(a1),d0
	lsl.w d6,d0
	move.l FRQpoint(pc),a1
	adda.w d0,a1
	move.l a1,18(a0)
	move.w d7,50(a0)
	bra testeffects
testpitchbend:
	cmpi.b #$ea,d0
	bne.s testnewsustain
	move.b 1(a1),4(a0)
	move.b 2(a1),5(a0)
	addq.w #3,50(a0)
	bra.s transpose
testnewsustain:
	cmpi.b #$e8,d0
	bne.s testnewvib
	move.b 1(a1),26(a0)
	addq.w #2,50(a0)
	bra testsustain
testnewvib:
	cmpi.b #$e3,(a1)+
	bne.s transpose
	addq.w #3,50(a0)
	move.b (a1)+,27(a0)
	move.b (a1),28(a0)
transpose:
	move.l 18(a0),a1
	adda.w 50(a0),a1
	move.b (a1),43(a0)
	addq.w #1,50(a0)

VOLUfx:
	tst.b 25(a0)
	beq.s volsustzero
	subq.b #1,25(a0)
	bra calcperiod
volsustzero:
	tst.b 15(a0)
	bne.s do_VOLbend
	subq.b #1,23(a0)
	bne.s calcperiod
	move.b 24(a0),23(a0)
volu_cmd:
	move.l 10(a0),a1
	adda.w 16(a0),a1
	move.b (a1),d0
testvoluend:
	cmpi.b #$e1,d0
	beq.s calcperiod
	cmpi.b #$ea,d0
	bne.s testVOLsustain
	move.b 1(a1),14(a0)
	move.b 2(a1),15(a0)
	addq.w #3,16(a0)
	bra.s do_VOLbend
testVOLsustain:
	cmpi.b #$e8,d0
	bne.s testVOLloop
	addq.w #2,16(a0)
	move.b 1(a1),25(a0)
	bra.s calcperiod
testVOLloop:
	cmpi.b #$e0,d0
	bne.s setvolume
	move.b 1(a1),d0
	andi.w #$003f,d0
	subq.b #5,d0
	move.w d0,16(a0)
	bra.s volu_cmd
do_VOLbend:
	not.b 38(a0)
	beq.s calcperiod
	subq.b #1,15(a0)
	move.b 14(a0),d1
	add.b d1,45(a0)
	bpl.s calcperiod
	moveq #0,d1
	move.b d1,15(a0)
	move.b d1,45(a0)
	bra.s calcperiod
setvolume:
	move.b (a1),45(a0)
	addq.w #1,16(a0)
calcperiod:
	move.b 43(a0),d0
	bmi.s lockednote
	add.b 8(a0),d0
	add.b 44(a0),d0
lockednote:
	moveq #$7f,d1
	and.l d1,d0
	lea PERIODS,a1
	add.w d0,d0
	move.w d0,d1
	adda.w d0,a1
	move.w (a1),d0

	move.b 46(a0),d7
	tst.b 30(a0)		;Vibrato_delay = zero ?
	beq.s vibrator
	subq.b #1,30(a0)
	bra.s novibrato
vibrator:
	moveq #5,d2
	move.b d1,d5
	move.b 28(a0),d4
	add.b d4,d4
	move.b 29(a0),d1
	tst.b d7
	bpl.s vib1
	btst #0,d7
	bne.s vib4
vib1:
	btst d2,d7
	bne.s vib2
	sub.b 27(a0),d1
	bcc.s vib3
	bset d2,d7
	moveq #0,d1
	bra.s vib3
vib2:
	add.b 27(a0),d1
	cmp.b d4,d1
	bcs.s vib3
	bclr d2,d7
	move.b d4,d1
vib3:
	move.b d1,29(a0)
vib4:
	lsr.b #1,d4
	sub.b d4,d1
	bcc.s vib5
	subi.w #$0100,d1
vib5:
	addi.b #$a0,d5
	bcs.s vib7
vib6:
	add.w d1,d1
	addi.b #$18,d5
	bcc.s vib6
vib7:
	add.w d1,d0
novibrato:
	eori.b #$01,d7
	move.b d7,46(a0)

; DO THE PORTAMENTO THING
	not.b 39(a0)
	beq.s pitchbend
	moveq #0,d1
	move.b 47(a0),d1	;get portavalue
	beq.s pitchbend		;0=no portamento
	cmpi.b #$1f,d1
	bls.s portaup
portadown: 
	andi.w #$1f,d1
	neg.w d1
portaup:
	sub.w d1,56(a0)
pitchbend:
	not.b 42(a0)
	beq.s addporta
	tst.b 5(a0)
	beq.s addporta
	subq.b #1,5(a0)
	moveq #0,d1
	move.b 4(a0),d1
	bpl.s pitchup
	ext.w d1
pitchup:
	sub.w d1,56(a0)
addporta:
	add.w 56(a0),d0
	cmpi.w #$0070,d0
	bhi.s nn1
	move.w #$0071,d0
nn1:
	cmpi.w #$0d60,d0
	bls.s nn2
	move.w #$0d60,d0
nn2:
	swap d0
	move.b 45(a0),d0
	rts



V1data:  dcb.b 64,0	;Voice 1 data area
offset1: dcb.b 02,0	;Is added to start of sound
ssize1:  dcb.b 02,0	;Length of sound
start1:  dcb.b 06,0	;Start of sound

V2data:  dcb.b 64,0	;Voice 2 data area
offset2: dcb.b 02,0
ssize2:  dcb.b 02,0
start2:  dcb.b 06,0

V3data:  dcb.b 64,0	;Voice 3 data area
offset3: dcb.b 02,0
ssize3:  dcb.b 02,0
start3:  dcb.b 06,0

V4data:  dcb.b 64,0	;Voice 4 data area
offset4: dcb.b 02,0
ssize4:  dcb.b 02,0
start4:  dcb.b 06,0

audtemp: dc.w 0		;DMACON
spdtemp: dc.w 0
respcnt: dc.w 0		;Replay speed counter 
repspd:  dc.w 0		;Replay speed counter temp
onoff:   dc.w 0		;Music on/off flag.

Chandata: dc.l $00000000,$00100003,$00200006,$00300009
SEQpoint: dc.l 0
PATpoint: dc.l 0
FRQpoint: dc.l 0
VOLpoint: dc.l 0

PERIODS:dc.w $06b0,$0650,$05f4,$05a0,$054c,$0500,$04b8,$0474
	dc.w $0434,$03f8,$03c0,$038a,$0358,$0328,$02fa,$02d0
	dc.w $02a6,$0280,$025c,$023a,$021a,$01fc,$01e0,$01c5
	dc.w $01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d
	dc.w $010d,$00fe,$00f0,$00e2,$00d6,$00ca,$00be,$00b4
	dc.w $00aa,$00a0,$0097,$008f,$0087,$007f,$0078,$0071
	dc.w $0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071
	dc.w $0071,$0071,$0071,$0071,$0d60,$0ca0,$0be8,$0b40
	dc.w $0a98,$0a00,$0970,$08e8,$0868,$07f0,$0780,$0714
	dc.w $1ac0,$1940,$17d0,$1680,$1530,$1400,$12e0,$11d0
	dc.w $10d0,$0fe0,$0f00,$0e28,$06b0,$0650,$05f4,$05a0
	dc.w $054c,$0500,$04b8,$0474,$0434,$03f8,$03c0,$038a
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a
	dc.w $021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d,$0168
	dc.w $0153,$0140,$012e,$011d,$010d,$00fe,$00f0,$00e2
	dc.w $00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f
	dc.w $0087,$007f,$0078,$0071

	section	FCchip,data_c

silent: dc.w $0100,$0000,$0000,$00e1

SOUNDINFO:
;Start.l , Length.w , Repeat start.w , Repeat-length.w , blk.b 6,0

	dcb.b 10*16,0	;Reserved for samples
	dcb.b 80*16,0	;Reserved for waveforms
	end
