**************************************************************************
*              Tronic Eagleplayer/DelitrackerReplay                      *
*   Playroutine ripped and made usable for Deli/Eagle by Marley/Infect   *
*    Eagleplayer Adaptions (Vol,Bal,Voices) by Buggs / Defect            *
*        Note by Buggs: Doesn`t look like a "Tracker"                    *
**************************************************************************
	;
	incdir	include:
	include	misc/eagleplayer.i
	;
	SECTION	0,CODE

test	=	0

	ifne	test

	lea	mod,a0
	move.l	a0,tr_data
	bsr	tr_init
wa
	move.b	$dff006,d0
	cmp.b	#$50,d0
	bne	wa

	bsr	tr_music

	btst	#6,$bfe001
	bne	wa
	move.w	#15,$dff096
	illegal

	endc

	Playerheader	Tags
	dc.b	'$VER: TronicTracker(?) replay module V1.1 (12-Apr-93 &'
	dc.b	' 17-Apr-93)',0
Tags
	dc.l	DTP_RequestDTVersion,$ffff
	dc.l	EP_PlayerVersion,4
	dc.l	DTP_Volume,SetVoices
	dc.l	DTP_Balance,SetVoices
	dc.l	EP_Voices,SetVoices
	dc.l	DTP_Playerversion,2
	dc.l	DTP_Playername,Player
	dc.l	DTP_Creator,Creator

	dc.l	DTP_Check2,Checkmod

	dc.l	DTP_InitPlayer,InitPlay
	dc.l	DTP_EndPlayer,EndPlay

	dc.l	DTP_InitSound,TR_Init
	dc.l	DTP_EndSound,TR_End
	dc.l	DTP_Interrupt,TR_Music

	dc.l	EP_flags,EPB_Volvoices!EPB_Packable!EPB_restart!EPB_songend!EPB_Volume!EPB_Balance!EPB_Voices!EPB_Analyzer
	dc.l	EP_StructInit,GetStrucAdr
	dc.l	0
;==========================================================================
TR_Data		dc.l	0
dtbase:		dc.l	0

TR_VolVoice1	dc.w	1
TR_VolVoice2	dc.w	1
TR_VolVoice3	dc.w	1
TR_VolVoice4	dc.w	1


StructAdr:
	ds.b	UPS_SizeOF

Player	dc.b	'TronicTracker(?)',0
Creator	dc.b	'?????, adapted by',$A
	dc.b	'marley/INFECT & Buggs/DEFECT',0,0
	even
;=========================================================================
GetStrucAdr:
	lea	StructAdr(pc),a0
	rts
;==========================================================================
*-----------------------------------------------------------------------*
*		d0 Bit 0-3 = Set Voices Bit=1 Voice on			*
SetVoices:	lea	structadr+UPS_DmaCon(pc),a0
		move.w	EPG_Voices(a5),(a0)				;Voices retten
		lea	TR_VolVoice1(pc),a1
		move.l	EPG_Voice1Vol(a5),(a1)
		move.l	EPG_Voice3Vol(a5),4(a1)

		lea	structadr+UPS_Voice1Vol(pc),a0
		lea	$dff0a0,a1
		moveq	#3,d1
.SetNew		moveq	#0,d0
		move.w	(a0),d0
		bsr.s	TR_SetVoices
		moveq	#UPS_Modulo,d0
		add.l	d0,a0
		addq.l	#8,a1
		addq.l	#8,a1
		dbf	d1,.SetNew
		rts

*-----------------------------------------------------------------------*
TR_SetVoices:	movem.l	a0/d0,-(a7)
		and.w	#$7f,d0
		lea	structadr(pc),a0
		cmp.l	#$dff0a0,a1			;Left Volume
		bne.s	.NoVoice1
		move.w	d0,UPS_Voice1Vol(a0)
		mulu.w	TR_VolVoice1(pc),d0
		bra.b	.SetIt
.NoVoice1:	cmp.l	#$dff0b0,a1			;Right Volume
		bne.s	.NoVoice2
		move.w	d0,UPS_Voice2Vol(a0)
		mulu.w	TR_VolVoice2(pc),d0
		bra.b	.SetIt
.NoVoice2:	cmp.l	#$dff0c0,a1			;Right Volume
		bne.s	.NoVoice3
		move.w	d0,UPS_Voice3Vol(a0)
		mulu.w	TR_VolVoice3(pc),d0
		bra.b	.SetIt
.NoVoice3:	move.w	d0,UPS_Voice4Vol(a0)
		mulu.w	TR_VolVoice4(pc),d0
.SetIt:		lsr.w	#6,d0
		move.w	d0,8(a1)
.Return:	movem.l	(a7)+,a0/d0
		rts

;==========================================================================
Checkmod
	movem.l	d1-d4,-(sp)
	move.l	DTG_ChkData(a5),a0
	moveq	#-1,d0
	movem.l	(a0)+,d1-d4
	add.w	d1,a0
	add.w	d2,a0
	add.w	d3,a0
	add.w	d4,a0
	move.l	a0,d1
	btst	#0,d1
	bne.s	.fail
	add.w	(a0),d1
	btst	#0,d1
	bne.s	.fail
	move.l	d1,a0
	cmp.l	#$5800b0,4(a0)
	bne.s	.fail
	moveq	#0,d0
.fail
	movem.l	(sp)+,d1-d4
	rts
;==========================================================================
InitPlay
	moveq	#0,d0
	move.l	DTG_GetListData(a5),a0
	jsr	(a0)
	move.l	a0,TR_Data
	move.l	a5,dtbase
	move.l	DTG_AudioAlloc(a5),a0
	jmp	(a0)
;==========================================================================
EndPlay
	move.l	DTG_AudioFree(a5),a0
	jmp	(a0)
;==========================================================================
Getadr
	move.l	a2,-(sp)
	lea	Structadr(pc),a2	;1.Kanal
	cmp.l	#$dff0a0,a1
	beq.s	.yes
	lea	Structadr+ups_modulo(pc),a2	;2.Kanal
	cmp.l	#$dff0b0,a1
	beq.s	.yes
	lea	Structadr+ups_modulo*2(pc),a2	;3.Kanal
	cmp.l	#$dff0c0,a1
	beq.s	.yes
	lea	Structadr+ups_modulo*3(pc),a2	;4.Kanal
.yes
	move.l	a4,UPS_Voice1adr(a2)
	move.l	(sp)+,a2
	rts
getper
	move.l	a2,-(sp)
	lea	structadr(pc),a2	;1.kanal

	cmp.l	#$dff0a0,a1
	beq.s	.yes
	lea	structadr+ups_modulo(pc),a2	;2.kanal
	cmp.l	#$dff0b0,a1
	beq.s	.yes
	lea	structadr+ups_modulo*2(pc),a2	;3.kanal
	cmp.l	#$dff0c0,a1
	beq.s	.yes
	lea	structadr+ups_modulo*3(pc),a2	;4.kanal
.yes
	move.w	d0,ups_voice1per(a2)
	move.l	(sp)+,a2
	rts
GetLen
	move.l	a2,-(sp)
	lea	structadr(pc),a2	;1.kanal

	cmp.l	#$dff0a0,a1
	beq.s	.yes
	lea	structadr+ups_modulo(pc),a2	;2.kanal
	cmp.l	#$dff0b0,a1
	beq.s	.yes
	lea	structadr+ups_modulo*2(pc),a2	;3.kanal
	cmp.l	#$dff0c0,a1
	beq.s	.yes
	lea	structadr+ups_modulo*3(pc),a2	;4.kanal
.yes
	move.w	d0,ups_voice1len(a2)
	move.l	(sp)+,a2
	rts
;==========================================================================
TR_Init
	movem.l	d1-d7/a0-a6,-(sp)
	lea	$dff000,a2
	move.w	#15,$96(a2)

;	bset	#1,$bfe001

	lea	TR_EmptyWave(pc),a0
	move.l	a0,$a0(a2)
	move.l	a0,$b0(a2)
	move.l	a0,$c0(a2)
	move.l	a0,$d0(a2)
	move.w	#4,$a4(a2)
	move.w	#4,$b4(a2)
	move.w	#4,$c4(a2)
	move.w	#4,$d4(a2)
	moveq	#0,d0
	move.l	d0,$a6(a2)
	move.l	d0,$b6(a2)
	move.l	d0,$c6(a2)
	move.l	d0,$d6(a2)

	move.l	tr_data(pc),a0
	lea	TR_7de(pc),a1
	move.w	#$8000,(a1)
	move.b	#$3f,$2e(a1)

	move.l	(a0)+,$3e(a1)
	move.l	(a0)+,$42(a1)
	move.l	(a0)+,$46(a1)
	move.l	(a0)+,$4a(a1)

	move.l	a0,10(a1)
	add.w	$40(a1),a0
	move.l	a0,14(a1)
	add.w	$44(a1),a0
	move.l	a0,$12(a1)
	add.w	$48(a1),a0
	move.l	a0,$16(a1)
	add.w	$4c(a1),a0
	moveq	#0,d0
	move.w	(a0)+,d0
	move.l	a0,$3a(a1)
	add.w	d0,a0
	move.w	(a0)+,d0
	move.l	a0,6(a1)
	add.w	d0,a0
	move.l	a0,2(a1)
	move.w	-2(a0),d0
	add.l	#$58,d0
	add.w	d0,a0
	move.w	(a0)+,d0
	move.l	a0,$4e(a1)
	add.w	d0,a0
	move.w	(a0)+,d0
	move.l	a0,$52(a1)
	add.w	d0,a0
	move.l	(a0)+,d0
	move.l	a0,$1a(a1)
	add.l	d0,a0
	move.l	a0,$26(a1)
	lea	$20(a0),a0
	move.l	a0,$22(a1)
	move.b	#5,$2f(a1)
	clr.b	$30(a1)

	lea	TR_83c(pc),a2

	lea	TR_Voice1(pc),a0
	move.l	10(a1),10(a0)
	move.l	$3e(a1),$36(a0)
	bsr.s	TR_InitVoice

	lea	TR_Voice2(pc),a0
	move.l	14(a1),10(a0)
	move.l	$42(a1),$36(a0)
	bsr.s	TR_InitVoice

	lea	TR_Voice3(pc),a0
	move.l	$12(a1),10(a0)
	move.l	$46(a1),$36(a0)
	bsr.s	TR_InitVoice

	lea	TR_Voice4(pc),a0
	move.l	$16(a1),10(a0)
	move.l	$4a(a1),$36(a0)
	bsr.s	TR_InitVoice

	movem.l	(sp)+,d1-d7/a0-a6
	moveq	#0,d0
	rts

TR_InitVoice
	MOVE.L	A2,6(A0)
	MOVE.L	$3A(A1),$2C(A0)
	MOVE.B	#$3F,$1D(A0)
	CLR.L	14(A0)
	CLR.L	$12(A0)
	CLR.L	$16(A0)
	CLR.W	$1A(A0)
	CLR.B	$1C(A0)
	CLR.L	$1E(A0)
	CLR.L	$22(A0)
	CLR.L	$26(A0)
	CLR.W	$2A(A0)
	CLR.L	$30(A0)
	CLR.W	$34(A0)
	RTS

tr_end
	MOVE.L	A2,-(SP)

	LEA	$DFF000,A2
	MOVE.W	#15,$96(A2)
	MOVEQ	#0,D0
	MOVE.L	D0,$A6(A2)
	MOVE.L	D0,$B6(A2)
	MOVE.L	D0,$C6(A2)
	MOVE.L	D0,$D6(A2)

;	BCLR	#1,$BFE001

	lea	structadr(pc),a2
	move.w	d0,UPS_Flags(a2)
	move.l	d0,ups_voice1adr(a2)
	move.l	d0,ups_voice2adr(a2)
	move.l	d0,ups_voice3adr(a2)
	move.l	d0,ups_voice4adr(a2)
	move.w	#1,ups_enabled(a2)

	MOVE.L	(SP)+,A2
	MOVEQ	#0,D0
	RTS

TR_Music
	MOVEM.L	D1-D7/A0-A6,-(SP)

	lea	StructAdr(pc),a0
	move.w	#-1,UPS_Enabled(a0)
	move.w	#UPSB_Adr!UPSB_LEN!UPSB_Per!UPSB_Vol!UPSB_DMACON,UPS_Flags(a0)
	clr.w	UPS_Voice1Per(a0)
	clr.w	UPS_Voice2Per(a0)
	clr.w	UPS_Voice3Per(a0)
	clr.w	UPS_Voice4Per(a0)

	LEA	TR_7DE(PC),A6
	CLR.B	1(A6)
	SUBQ.B	#1,$30(A6)
	BPL.S	TR_2DC
	MOVE.B	$2F(A6),$30(A6)
TR_2DC
	LEA	TR_Voice1(PC),A0
	BSR.S	TR_302
	LEA	TR_Voice2(PC),A0
	BSR.S	TR_302
	LEA	TR_Voice3(PC),A0
	BSR.S	TR_302
	LEA	TR_Voice4(PC),A0
	BSR.S	TR_302

	MOVE.W	(A6),$DFF096

	lea	StructAdr(pc),a1
	clr.w	UPS_Enabled(a1)

	MOVEM.L	(SP)+,D1-D7/A0-A6
	MOVEQ	#0,D0
	RTS

TR_302
	MOVE.L	(A0),A1
	MOVE.L	6(A0),A2
	TST.B	$33(A0)
	BPL.S	TR_33A
	CLR.B	$33(A0)
	MOVEQ	#0,D0
	MOVE.L	$26(A6),A3
	MOVE.B	$27(A2),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	D0,A3
	MOVE.L	(A3),A4
	ADD.L	$22(A6),A4

	MOVE.W	4(A2),d0
	move.w	d0,4(A1)		;Len
	bsr	getlen

	MOVEQ	#0,D0
	MOVE.W	2(A2),D0
	CLR.W	(A4)
	ADD.W	D0,A4
	MOVE.L	A4,(A1)			;Adr
	bsr	getadr

TR_33A
	TST.B	$30(A6)
	BNE	TR_484

	TST.W	$14(A0)
	BNE.S	TR_378
	MOVEQ	#0,D0
	MOVE.L	10(A0),A3
	MOVE.W	$12(A0),D1
	MOVE.B	0(A3,D1.W),D0
	MOVE.B	1(A3,D1.W),$2B(A0)
	ASL.L	#6,D0
	ADD.L	$1A(A6),D0
	MOVE.L	D0,14(A0)
	ADDQ.W	#2,D1
	MOVE.W	D1,$12(A0)
	CMP.W	$38(A0),D1
	BMI.S	TR_378
	MOVE.W	$36(A0),$12(A0)

	ifeq	test

	move.l	a2,-(sp)
	move.l	dtbase(pc),a2
	move.l	dtg_songend(a2),a2
	jsr	(a2)
	move.l	(sp)+,a2

	endc

TR_378	MOVEQ	#0,D0
	MOVE.L	14(A0),A3
	MOVE.W	$14(A0),D0
	ADD.L	D0,A3
	MOVEQ	#0,D0
	MOVE.B	(A3),D0
	BEQ	TR_40E
	MOVE.W	4(A0),$DFF096
	MOVE.B	D0,$1C(A0)
	LEA	TR_Periods(PC),A4
	ADD.B	$2B(A0),D0
	ADD.W	D0,D0
	MOVE.W	0(A4,D0.W),$1A(A0)
	MOVEQ	#0,D1
	MOVE.B	1(A3),D1
	ADD.W	D1,D1
	SUBQ.W	#2,D1
	MOVE.L	6(A6),A4
	ADD.W	D1,A4
	MOVEQ	#0,D2
	MOVE.W	(A4),D2
	ADD.L	2(A6),D2
	MOVE.L	D2,6(A0)
	MOVE.L	D2,A2
	MOVE.B	$26(A2),$33(A0)
	BPL.S	TR_3EA
	MOVEQ	#0,D0
	MOVE.L	$26(A6),A4
	MOVE.B	$27(A2),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	D0,A4
	MOVE.L	(A4),A4
	ADD.L	$22(A6),A4
	MOVE.L	A4,(A1)			;Adr
	bsr	getadr
	move.w	(a2),d0
	MOVE.W	d0,4(A1)		;Len
	bsr	getlen
TR_3EA
	CLR.W	$16(A0)
	CLR.L	$20(A0)
	CLR.B	$24(A0)
	CLR.W	$30(A0)
	CLR.L	$26(A0)
	MOVE.B	$16(A2),$2A(A0)
	CLR.B	$34(A0)
	MOVE.B	$17(A2),$35(A0)
TR_40E
	moveq	#0,d0
	MOVE.B	2(A3),D0
	SUBQ.B	#1,D0
	BMI.S	TR_47A
	MOVE.B	3(A3),D1

	ADD.W	D0,D0
	JMP	TR_420(PC,D0.W)

TR_420
	BRA.S	TR_430

	BRA.S	TR_436

	BRA.S	TR_44E

	BRA.S	TR_456

	BRA.S	TR_45C

	BRA.S	TR_462

	BRA.S	TR_468

	BRA.S	TR_46E

TR_430	MOVE.B	D1,$2F(A6)
	BRA.S	TR_47A

TR_436	TST.B	D1
	BNE.S	TR_444
;	BSET	#1,$BFE001
	BRA.S	TR_47A

TR_444
;	BCLR	#1,$BFE001
	BRA.S	TR_47A

TR_44E	NEG.W	D1
	MOVE.W	D1,$1E(A0)
	BRA.S	TR_47A

TR_456	MOVE.W	D1,$1E(A0)
	BRA.S	TR_47A

TR_45C	MOVE.B	D1,$25(A0)
	BRA.S	TR_47A

TR_462	MOVE.B	D1,$1D(A0)
	BRA.S	TR_47A

TR_468	MOVE.B	D1,$2E(A6)
	BRA.S	TR_47A

TR_46E	ASL.L	#4,D1
	MOVE.L	$3A(A6),A4
	ADD.L	D1,A4
	MOVE.L	A4,$2C(A0)
TR_47A	ADDQ.W	#4,$14(A0)
	AND.W	#$3F,$14(A0)
TR_484	TST.B	$26(A2)
	BMI.S	TR_4E0
	TST.B	$16(A0)
	BEQ.S	TR_496
	SUBQ.B	#1,$16(A0)
	BRA.S	TR_4E0

TR_496	MOVE.B	$27(A2),$16(A0)
	MOVEQ	#0,D0
	MOVEQ	#0,D2
	LEA	$28(A2),A3
	MOVE.B	$17(A0),D0
TR_4A8	MOVE.B	D0,D1
	MOVE.B	0(A3,D0.W),D2
	CMP.B	#$FF,D2
	BNE.S	TR_4C4
	MOVE.B	1(A3,D0.W),D0
	MOVE.B	0(A3,D0.W),D2
	CMP.B	#$FF,D2
	BNE.S	TR_4A8
	BRA.S	TR_4E0

TR_4C4	ADD.W	D2,D2
	ADD.L	$4E(A6),D2
	MOVE.L	D2,A3
	MOVE.W	(A3),D2
	MOVE.L	$52(A6),A3
	ADD.W	D2,A3

	move.l	a4,-(sp)
	move.l	a3,a4
	MOVE.L	A4,(A1)			;Adr
	bsr	getadr
	move.l	(sp)+,a4

	MOVE.W	(A2),d0			;Len
	move.w	d0,4(a1)
	bsr	getlen

	ADDQ.B	#1,D1
	MOVE.B	D1,$17(A0)
TR_4E0	MOVEQ	#0,D0
	LEA	$15(A2),A3
	MOVE.B	$34(A0),D0
	ADD.W	D0,A3
	MOVE.B	(A3),D0
	TST.B	$27(A0)
	BNE.S	TR_4FA
	ADD.W	D0,$28(A0)
	BRA.S	TR_4FE

TR_4FA	SUB.W	D0,$28(A0)
TR_4FE	SUBQ.B	#1,$2A(A0)
	BNE.S	TR_50E
	MOVE.B	1(A3),$2A(A0)
	NOT.B	$27(A0)
TR_50E	TST.B	$35(A0)
	BEQ.S	TR_51A
	SUBQ.B	#1,$35(A0)
	BRA.S	TR_532

TR_51A	ADDQ.B	#3,$34(A0)
	CMP.B	#15,$34(A0)
	BNE.S	TR_52C
	MOVE.B	#12,$34(A0)
TR_52C	MOVE.B	5(A3),$35(A0)
TR_532	TST.B	$24(A0)
	BEQ.S	TR_53E
	SUBQ.B	#1,$24(A0)
	BRA.S	TR_598

TR_53E	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	$22(A0),D0
	LEA	6(A2),A3
	ADD.W	D0,A3
	MOVE.B	(A3),D0
	MOVE.B	1(A3),D1
	CMP.W	$20(A0),D1
	BPL.S	TR_572
	SUB.W	D0,$20(A0)
	CMP.W	$20(A0),D1
	BMI.S	TR_598
	MOVE.W	D1,$20(A0)
	ADDQ.W	#3,$22(A0)
	MOVE.B	2(A3),$24(A0)
	BRA.S	TR_598

TR_572	ADD.W	D0,$20(A0)
	CMP.W	$20(A0),D1
	BPL.S	TR_598
	MOVE.W	D1,$20(A0)
	ADDQ.W	#3,$22(A0)
	CMP.W	#15,$22(A0)
	BNE.S	TR_592
	MOVE.W	#12,$22(A0)
TR_592	MOVE.B	2(A3),$24(A0)
TR_598	MOVEQ	#0,D0
	MOVE.B	$25(A0),D0
	BEQ.S	TR_5C8
	MOVE.W	$1A(A0),D1
	CMP.W	$18(A0),D1
	BPL.S	TR_5BA
	SUB.W	D0,$18(A0)
	CMP.W	$18(A0),D1
	BMI.S	TR_5C8
	MOVE.W	D1,$18(A0)
	BRA.S	TR_5C8

TR_5BA
	ADD.W	D0,$18(A0)
	CMP.W	$18(A0),D1
	BPL.S	TR_5C8
	MOVE.W	D1,$18(A0)
TR_5C8	
	MOVEQ	#0,D0
	MOVE.L	$2C(A0),A3
	MOVE.W	$30(A0),D1
	MOVE.B	0(A3,D1.W),D0
	CMP.B	#$80,D0
	BNE.S	TR_5E2
	CLR.W	$30(A0)
	BRA.S	TR_5C8

TR_5E2
	ADDQ.W	#1,$30(A0)
	AND.W	#15,$30(A0)
	TST.B	$25(A0)
	BEQ.S	TR_5F8
	MOVE.W	$18(A0),D0
	BRA.S	TR_60E

TR_5F8
	LEA	TR_Periods(PC),A3
	ADD.B	$1C(A0),D0
	ADD.B	$2B(A0),D0
	ADD.W	D0,D0
	MOVE.W	0(A3,D0.W),D0
	MOVE.W	D0,$18(A0)
TR_60E
	MOVE.W	$24(A2),D1
	SUB.W	$1E(A0),D1
	SUB.W	D1,$28(A0)
	ADD.W	$28(A0),D0

	MOVE.W	D0,6(A1)		;Per
	bsr	getper
	MOVE.W	$20(A0),D0
	ROR.W	#2,D0
	AND.W	#$3F,D0
	CMP.B	$1D(A0),D0
	BMI.S	TR_636
	MOVE.B	$1D(A0),D0
TR_636
	CMP.B	$2E(A6),D0
	BMI.S	TR_640
	MOVE.B	$2E(A6),D0
TR_640
	bsr	TR_Setvoices
;	MOVE.W	D0,8(A1)		;Vol

	MOVE.W	4(A0),D0
	OR.W	D0,(A6)
	RTS

TR_Voice1
	dc.l	$DFF0A0
	dc.l	$10000
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0
TR_Voice2
	dc.l	$DFF0B0
	dc.l	$20000
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0
TR_Voice3
	dc.l	$DFF0C0
	dc.l	$40000
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0
TR_Voice4
	dc.l	$DFF0D0
	dc.l	$80000
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0

TR_Periods
	dc.l	$1AC0,$194017D0,$16801530,$140012E0,$11D010D0,$FE00F00,$E200D60
	dc.l	$CA00BE8,$B400A98,$A000970,$8E80868,$7F00780,$71006B0,$65005F4
	dc.l	$5A0054C,$50004B8,$4740434,$3F803C0,$3880358,$32802FA,$2D002A6
	dc.l	$280025C,$23A021A,$1FC01E0,$1C401AC,$194017D,$1680153,$140012E
	dc.l	$11D010D,$FE00F0,$E200D6,$CA00BE,$B400AA,$A00097,$8F0087,$7F0078
	dc.l	$710071,$710071,$710071,$710071,$710071,$710071,$71
TR_7DE
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0
TR_EmptyWave
	dc.l	0,0
TR_83C
	dc.l	$40000
	dc.l	1
	dc.l	$FF000000
	dc.l	0
	dc.l	0
	dc.l	$101
	dc.l	$2020202
	dc.l	$2020202
	dc.l	$2020202
	dc.l	$FE
	dc.l	$FF0000

	ifne	test
mod
	incdir	vr0:
	incbin	tron.jetsons

	endc

	END

