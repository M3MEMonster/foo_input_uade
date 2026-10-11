**
** DeliTracker Player for (see below)
**
	incdir	"Include:"
	include	"silva/easy.i"
	include	"misc/DeliPlayer.i"

	PLAYERHEADER PlayerTagArray

PlayerTagArray
	dl	DTP_PlayerVersion,1
	dl	DTP_PlayerName,Name
	dl	DTP_Creator,Comment

	dl	DTP_Check2,Checky
	dl	DTP_InitPlayer,InitPly
	dl	DTP_InitSound,Init
	dl	DTP_Interrupt,Play
	dl	DTP_EndSound,_Stop
	dl	DTP_EndPlayer,EndPly

	dl	DTP_NextSong,NextSong
	dl	DTP_PrevSong,PrevSong

	dl	TAG_DONE

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Name	db	"Follin Player II",0
Comment	db	"Tim Follin / Mike D.,",10
	db	"adapted by Andy Silva",0

	db	'$VER: a player for the famous DeliTracker',0
	even

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Checky:
	moveq	#-1,d0
	move.l	dtg_ChkData(a5),a0
	move.w	#$4ef9,d1
	cmp.w	(a0),d1
	bne.b	c_2
	cmp.w	6(a0),d1
	bne.b	c_rts
	cmp.w	$c(a0),d1
	bne.b	c_rts
	cmp.w	$12(a0),d1
	bne.b	c_rts
	cmp.w	$18(a0),d1
	bne.b	c_rts
	cmp.w	$1e(a0),d1
	bne.b	c_rts
	move.l	$2c(a0),d1
	sub.l	2(a0),d1
	cmp.w	#$a0,d1
	move.l	a0,begadr
	clr.w	mode
	moveq	#0,d0
c_rts	rts
c_2	cmp.w	#$601a,(a0)
	bne.b	c_3
	lea	$1c(a0),a0
c_3	cmp.w	#$1010,(a0)
	beq.b	c_3a
	cmp.w	#$1012,(a0)
	bne.b	c_rts
c_3a	addq.l	#2,a0
	move.l	4(a0),d1
	cmp.l	8(a0),d1
	bne.b	c_rts
	cmp.l	$c(a0),d1
	bne.b	c_rts
	cmp.l	$10(a0),d1
	bne.b	c_rts
	move.l	a0,begadr
	move.w	#1,mode
	moveq	#0,d0
	rts

****

InitPly
	move.l	(dtg_AudioAlloc,a5),a0
	jsr	(a0)
	clr.w	songnr
	move.w	#14,songs
	pushm	d1-a6
	move.l	dtg_ChkSize(a5),d1
	move.l	begadr(pc),a5
	bsr	ReCalcMod
	popm	d1-a6
	rts

EndPly	move.l	(dtg_AudioFree,a5),a0	; free audio channels
	jsr	(a0)
	rts

****

mode	dc.w	0
songnr	dc.w	0
songs	dc.w	0
allow	dc.w	0

Init:
	pushm	d1-a6
	clr.w	allow
	move.l	begadr(pc),a5
	bsr	_Init0
	move.w	songnr(pc),d0
	addq.w	#1,d0
	bsr	_Init
	move.w	#1,allow
	popm	d1-a6
	rts

Play:
	pushm	d1-a6
	tst.w	allow
	beq.b	p_rts
	bsr	_Play2
	bsr	_Play1
p_rts	popm	d1-a6
	rts

NextSong:
	addq.w	#1,songnr
	move.w	songnr(pc),d0
	cmp.w	songs(pc),d0
	ble.b	Init
	clr.w	songnr
	bra.b	Init
PrevSong:
	subq.w	#1,songnr
	bge.b	Init
	move.w	songs(pc),songnr
	bra.b	Init

***********************************************

ReCalcMod:
	tst.w	mode
	beq.b	rm_a
	move.l	a5,a0
rm_lp	cmp.l	#$81043202,(a0)
	bne.b	rm_lpc
	cmp.w	#$8f00,4(a0)
	bne.b	rm_lpc
	move.l	a0,d0
	sub.l	4(a5),d0
	bra.b	rm_do
rm_lpc	addq.l	#2,a0
	subq.l	#2,d1
	bne.b	rm_lp
	moveq	#-1,d0		; err: merkmal nicht gefunden
	rts
rm_a	move.l	a5,d0
	sub.l	2(a5),d0
	lea	$432(a5),a5
	move.l	a5,begadr
rm_do	move.l	d0,(dx)
	move.l	a5,a1		; a5 begadr, d0 dx
rm_lp1	tst.b	(a1)
	bne.b	rm_1
	add.l	d0,(a1)+	; erste Tab (zeigt auf die mittleren)
	bra.b	rm_lp1
rm_1	lea	$194(a5),a1
rm_lp2	tst.w	(a1)
	beq.b	rm_ok
	move.l	(a1),a2
	add.l	d0,a2		; zweite Tab (zeigt auf letzte)
	move.l	a2,(a1)+
	add.l	d0,2(a2)	; letzte Tabelle relokieren
	bra.b	rm_lp2
rm_ok	moveq	#0,d0
	rts

dx	dc.l	0
begadr	dc.l	0

* routines and datas

_stop
	move.w	#$f,$dff096
	RTS

_init0:
	moveq	#0,d0
_init:	LEA	tmp,A0
	moveq	#127,D1
L_AF8	CLR.w	(A0)+
	dbf	D1,L_AF8
	and.w	#$f,d0
	MOVE.W	d0,L_12E6
	LEA	$144(a5),A0
	MOVE.B	(A0,D0.W),d1
	MOVE.B	d1,L_12EA
	ASL.W	#4,D0
	LEA	4(a5),A0
	lea	tmp,a6
	MOVE.L	(A0,D0.W),$80(a6)
	MOVE.L	4(A0,D0.W),$84(a6)
	MOVE.L	8(A0,D0.W),$88(a6)
	CMP.B	#4,D1
	BNE.W	L_B48
	MOVE.L	$C(A0,D0.W),$8C(a6)
L_B48	MOVE.L	#L_12A2,$a0(a6)
	MOVE.L	#L_12B2,$a4(a6)
	MOVE.L	#L_12C2,$a8(a6)
	CMP.B	#4,D1
	BNE.W	L_B78
	MOVE.L	#L_12D2,$aC(a6)
L_B78	MOVE.B	#-1,D0
	CMPI.B	#$0E,L_12E6.L
	BNE.W	L_B8A
	CLR.B	D0
L_B8A	MOVE.B	D0,$70(a6)
	MOVE.B	D0,$71(a6)
	MOVE.B	D0,$72(a6)
	CMP.B	#4,D1
	BNE.W	L_BAE
	MOVE.B	D0,$73(a6)
	BRA.W	L_BB6
L_BAE	MOVE.B	#0,$73(a6)
L_BB6	MOVE.B	D0,$5C(a6)
	MOVE.B	D0,$5D(a6)
	MOVE.B	D0,$5E(a6)
	CMP.B	#4,D1
	BNE.W	L_BD6
	MOVE.B	D0,$5F(a6)
L_BD6	MOVE.B	#1,D0
	MOVE.B	D0,$34(a6)
	MOVE.B	D0,$35(a6)
	MOVE.B	D0,$36(a6)
	CMP.B	#4,D1
	BNE.W	L_BFA
	MOVE.B	D0,$37(a6)
L_BFA	RTS

_play1	lea	tmp,a6
	LEA	$80(a6),A6
	LEA	ChipRegs(pc),A5
	LEA	DmaMasks(pc),A4
	CLR.L	D6
	CLR.L	D5
	CLR.L	D4
	TST.B	L_12ED.L
	BEQ.W	L_CF0
	SUBQ.B	#1,L_12ED.L
	BEQ.W	_init0
	SUBQ.B	#1,L_12ED.L
	BEQ.W	_init0
L_CF0	MOVE.B	D6,D5
	ASL.W	#1,D5
	MOVE.B	D5,D4
	ASL.W	#1,D4
	BSR.W	L_E1E
	ADDQ.B	#1,D6
	CMP.B	#4,D6
	BNE.W	L_CF0
L_D0E	RTS	

_play2	lea	tmp,a6
	LEA	$80(a6),A6
	LEA	ChipRegs(pc),A5
	LEA	DmaMasks(pc),A4
	CLR.L	D6
	CLR.L	D5
	CLR.L	D4
L_D28	MOVE.B	D6,D5
	ASL.W	#1,D5
	MOVE.B	D5,D4
	ASL.W	#1,D4
	BSR.W	L_D40
	ADDQ.B	#1,D6
	CMP.B	#4,D6
	BNE.W	L_D28
	RTS	

L_D40	TST.B	-8(A6,D6.W)
	BEQ.W	L_D0E
	CLR.B	-8(A6,D6.W)
	CLR.L	D2
	MOVE.B	-$0020(A6,D6.W),D2
	ANDI.B	#$003F,D2
	ASL.W	#2,D2
	MOVE.W	L_12E6(pc),D1
	ASL.W	#2,D1
	move.l	begadr(pc),a1
	LEA	$104(a1),A1
	MOVEA.L	(A1,D1.W),A1
	MOVEA.L	(A1,D2.W),A3		; hit!
	add.l	dx(pc),a3
	lea	$32(A3),a2
	MOVEA.L	$20(A5,D4.W),A1
	MOVE.L	A2,(A1)
	MOVEA.L	$10(A5,D4.W),A1
	MOVE.W	(A3),(A1)		; .hit!
	MOVE.W	8(A4,D5.W),$00DFF096.L
	RTS	

L_D8E	MOVEA.L	$0030(A6,D4.W),A2
	MOVEA.L	A2,A3
	ADDA.L	#$00000032,A2
	MOVEA.L	$0020(A5,D4.W),A1
	MOVE.L	A2,(A1)
	MOVEA.L	$0010(A5,D4.W),A1
	MOVE.W	0(A3),(A1)
	MOVE.W	8(A4,D5.W),$00DFF096.L
	CLR.L	D2
	MOVE.B	-$0020(A6,D6.W),D2
	MOVE.B	D2,D3
	ANDI.B	#$0040,D3
	BEQ.W	L_DC6
	MOVE.B	#1,-8(A6,D6.W)
L_DC6	BRA.W	L_DDA

L_dca	CMPI.B	#4,-4(a6,d6.w)
	BGE.W	L_D0E
	BRA.W	L_1226

L_dd8	RTS

L_DDA	MOVEA.L	(A5,D4.W),A1
	MOVE.W	D0,(A1)
	RTS	

L_DE2	ANDI.W	#$00FF,D0
	MOVE.B	L_12ED(pc),D3
	BEQ.W	L_DFA
	LSR.B	#2,D3
	CMP.B	D3,D0
	BLT.W	L_DFA
	MOVE.B	D3,D0
L_DFA	CMPI.W	#$000D,L_12E6.L
	BNE.W	L_E16
	TST.B	-$000C(A6,D6.W)
	BEQ.W	L_E16
	MOVE.B	-$0028(A6,D6.W),D0
	ADDI.B	#1,D0
L_E16	MOVEA.L	$0030(A5,D4.W),A1
	MOVE.W	D0,(A1)
	RTS	

L_E1E	TST.B	-$0010(A6,D6.W)		; play-core ffb0
	BPL.W	L_10E0
	CMPI.B	#4,-4(A6,D6.W)
	BGE.W	L_E86
	SUBQ.B	#1,-$0018(A6,D6.W)
	BNE.W	L_E86
	MOVE.B	-$001C(A6,D6.W),-$0018(A6,D6.W)
	MOVEA.L	$0030(A6,D4.W),A1
	ADDA.L	#$00000032,A1
	CLR.W	D0
	MOVE.B	$005C(A6,D6.W),D0
	TST.B	$0058(A6,D6.W)
	BNE.W	L_E70
	ADDQ.B	#1,D0
	CMP.B	#$001E,D0
	BNE.W	L_E66
	MOVE.B	#-1,$0058(A6,D6.W)
L_E66	MOVE.B	#-$0080,(A1,D0.W)
	BRA.W	L_E82

L_E70	SUBQ.B	#1,D0
	CMP.B	#4,D0
	BNE.W	L_E7E
	CLR.B	$0058(A6,D6.W)
L_E7E	CLR.B	(A1,D0.W)
L_E82	MOVE.B	D0,$005C(A6,D6.W)
L_E86	TST.B	$0060(A6,D6.W)
	BNE.W	L_EC2
	SUBQ.B	#1,$0064(A6,D6.W)
	BPL.W	L_EFC
	MOVE.B	$0068(A6,D6.W),$0064(A6,D6.W)
	MOVE.B	-$0014(A6,D6.W),D0
	ADD.B	-$0050(A6,D6.W),D0
	MOVE.B	D0,-$0014(A6,D6.W)
	CMPI.B	#$003F,-$0014(A6,D6.W)
	BNE.W	L_EFC
	MOVE.B	#1,$0060(A6,D6.W)
	MOVE.B	$006C(A6,D6.W),$0064(A6,D6.W)
	BRA.W	L_EFC

L_EC2	CMPI.B	#1,$0060(A6,D6.W)
	BNE.W	L_EFC
	SUBQ.B	#1,$0064(A6,D6.W)
	BPL.W	L_EFC
	MOVE.B	$006C(A6,D6.W),$0064(A6,D6.W)
	MOVE.B	-$0014(A6,D6.W),D0
	CMP.B	$0070(A6,D6.W),D0
	BEQ.W	L_EF6
	MOVE.B	-$0014(A6,D6.W),D0
	SUB.B	-$0050(A6,D6.W),D0
	MOVE.B	D0,-$0014(A6,D6.W)
	BPL.W	L_EFC
L_EF6	MOVE.B	#2,$0060(A6,D6.W)
L_EFC	MOVE.B	-$0014(A6,D6.W),D0
	BSR.W	L_DE2
	TST.B	$0074(A6,D6.W)
	BEQ.W	L_F5E
	TST.B	$0078(A6,D6.W)
	BEQ.W	L_F1C
	SUBQ.B	#1,$0078(A6,D6.W)
	BNE.W	L_F5E
L_F1C	MOVE.W	$0048(A6,D5.W),D0
	CLR.L	D1
	MOVE.B	-$0078(A6,D6.W),D1
	TST.B	-$0074(A6,D6.W)
	BEQ.W	L_F34
	ADD.W	D1,D0
	BRA.W	L_F36

L_F34	SUB.W	D1,D0
L_F36	MOVE.W	D0,$0048(A6,D5.W)
	BSR.W	L_DDA
	SUBQ.B	#1,-$0070(A6,D6.W)
	BNE.W	L_F98
	MOVE.B	-$006C(A6,D6.W),D0
	BEQ.W	L_F98
	ASL.B	#1,D0
	MOVE.B	D0,-$0070(A6,D6.W)
	EORI.B	#1,-$0074(A6,D6.W)
	BRA.W	L_F98

L_F5E	TST.B	-$0068(A6,D6.W)
	BEQ.W	L_F98
	SUBQ.B	#1,-$0068(A6,D6.W)
	BNE.W	L_F98
	MOVE.B	-$0060(A6,D6.W),D1
	MOVE.B	-$005C(A6,D6.W),D0
	EORI.B	#1,-$0074(A6,D6.W)
	BEQ.W	L_F8C
	ADD.B	D1,D0
	MOVE.B	-$0064(A6,D6.W),-$0068(A6,D6.W)
	BRA.W	L_FD0

L_F8C	SUB.B	D1,D0
	MOVE.B	$007C(A6,D6.W),-$0068(A6,D6.W)
	BRA.W	L_FD0

L_F98	TST.B	-$0058(A6,D6.W)
	BEQ.W	L_FEC
	MOVE.B	-$0058(A6,D6.W),D2
	MOVE.B	-$005C(A6,D6.W),D0
	CMP.B	-$0054(A6,D6.W),D0
	BEQ.W	L_FEC
	BCS.W	L_FC2
	SUB.B	D2,D0
	CMP.B	-$0054(A6,D6.W),D0
	BCC.W	L_FD0
	BRA.W	L_FCC

L_FC2	ADD.B	D2,D0
	CMP.B	-$0054(A6,D6.W),D0
	BCS.W	L_FD0
L_FCC	MOVE.B	-$0054(A6,D6.W),D0
L_FD0	MOVE.B	D0,-$005C(A6,D6.W)
	ANDI.W	#$00FF,D0
	ASL.B	#1,D0
	LEA	Periodes(pc),A2
	MOVE.W	(A2,D0.W),D0
	MOVE.W	D0,$0048(A6,D5.W)
	BSR.W	L_DDA
L_FEC	SUBQ.B	#1,-$004C(A6,D6.W)
	CMPI.B	#1,-$004C(A6,D6.W)
	BEQ.W	L_1006
	TST.B	-$004C(A6,D6.W)
	BNE.W	L_10E0
	BRA.W	L_101A

L_1006	TST.B	-$0020(A6,D6.W)
	BPL.W	L_10E0
	MOVE.W	(A4,D5.W),$00DFF096.L
	BRA.W	L_10E0
L_101A	MOVEA.L	(A6,D4.W),A0
L_101E	CLR.L	D0
	MOVE.B	(A0)+,D0
	BEQ.W	L_102A
	BPL.W	L_103E
L_102A	ANDI.W	#$007F,D0
	add.w	d0,d0
	add.w	d0,d0
	lea	bratab(pc),A1
	move.l	(a1,d0.w),a1
	jmp	(a1)

bratab	DC.l	L_10E2
	DC.l	L_11F2
	DC.l	L_1120
	DC.l	L_1150
	DC.l	L_10E6
	DC.l	L_10F2
	DC.l	L_1166
	DC.l	L_11AE
	DC.l	L_119E
	DC.l	L_11B6
	DC.l	L_115E
	DC.l	L_1102
	DC.l	L_1196
	DC.l	L_11E2
	DC.l	L_1218
	DC.l	L_110A
	DC.l	L_11EA
	DC.l	L_11CA
	DC.l	L_113E

L_103E	MOVE.B	D0,D2
	TST.B	-$0030(A6,D6.W)
	BEQ.W	L_1052
	CLR.B	D0
	MOVE.B	D0,-$0030(A6,D6.W)
	BRA.W	L_1056

L_1052	MOVE.B	-$0034(A6,D6.W),D0
L_1056	ADD.B	D2,D0
	TST.B	-$0058(A6,D6.W)
	BEQ.W	L_1068
	MOVE.B	D0,-$0054(A6,D6.W)
	MOVE.B	-$005C(A6,D6.W),D0
L_1068	ANDI.W	#$00FF,D0
	MOVE.B	D0,-$005C(A6,D6.W)
	ASL.B	#1,D0
	LEA	Periodes(pc),A2
	MOVE.W	(A2,D0.W),D0
	MOVE.W	D0,$0048(A6,D5.W)
	BSR.W	L_D8E
	MOVE.B	-$002C(A6,D6.W),D0
	TST.B	D0
	BNE.W	L_1090
	MOVE.B	(A0)+,D0
L_1090	MOVE.B	D0,-$004C(A6,D6.W)
	MOVE.L	A0,(A6,D4.W)
	MOVE.B	-$0064(A6,D6.W),-$0068(A6,D6.W)
	MOVE.B	$0074(A6,D6.W),D0
	BEQ.W	L_10B4
	MOVE.B	D0,$0078(A6,D6.W)
	MOVE.B	-$006C(A6,D6.W),-$0070(A6,D6.W)
	MOVE.B	-$0048(A6,D6.W),D0
L_10B4	MOVE.B	D0,-$0074(A6,D6.W)
	TST.B	-$0044(A6,D6.W)
	BEQ.W	L_10E0
	MOVE.B	-$0040(A6,D6.W),$0060(A6,D6.W)
	MOVE.B	$0068(A6,D6.W),D0
	TST.B	$0060(A6,D6.W)
	BEQ.W	L_10D6
	MOVE.B	$006C(A6,D6.W),D0
L_10D6	MOVE.B	D0,$0064(A6,D6.W)
	MOVE.B	-$003C(A6,D6.W),-$0014(A6,D6.W)
L_10E0	RTS	

L_10e2	BRA.W	L_101E

L_10e6	MOVE.B	(A0)+,-$0038(A6,D6.W)
	MOVE.L	A0,$0010(A6,D4.W)
	BRA.W	L_101E

L_10f2	SUBQ.B	#1,-$0038(A6,D6.W)
	BEQ.W	L_101E
	MOVEA.L	$0010(A6,D4.W),A0
	BRA.W	L_101E

L_1102	MOVE.B	(A0)+,-$002C(A6,D6.W)
	BRA.W	L_101E

L_110a	CLR.B	-$0010(A6,D6.W)
	MOVE.W	(A4,D5.W),$00DFF096.L
	MOVEA.L	$0030(A5,D4.W),A1
	CLR.W	(A1)
	BRA.W	L_10E0

L_1120	MOVE.L	A0,D0
	BTST	#0,D0
	BEQ.W	L_112C
	ADDQ.L	#1,A0
L_112C	MOVEA.L	(A0)+,A1
	add.l	dx(pc),a1
	MOVEA.L	$0020(A6,D4.W),A2
	MOVE.L	A0,(A2)+
	MOVE.L	A2,$0020(A6,D4.W)
	MOVEA.L	A1,A0
	BRA.W	L_101E

L_113e	MOVE.L	A0,D0
	BTST	#0,D0
	BEQ.W	L_114A
	ADDQ.L	#1,A0
L_114A	MOVEA.L	(A0)+,A0
	add.l	dx(pc),a0
	BRA.W	L_101E

L_1150	MOVEA.L	$0020(A6,D4.W),A1
	MOVEA.L	-(A1),A0
	MOVE.L	A1,$0020(A6,D4.W)
	BRA.W	L_101E

L_115e	MOVE.B	(A0)+,-$0034(A6,D6.W)
	BRA.W	L_101E

L_1166	MOVE.B	(A0),D0
	LSR.W	#4,D0
	ASL.W	#2,D0
	MOVE.B	D0,-$003C(A6,D6.W)
	MOVE.B	(A0)+,D0
	ANDI.B	#$000F,D0
	ASL.W	#2,D0
	MOVE.B	D0,$0070(A6,D6.W)
	MOVE.B	(A0),D0
	LSR.B	#4,D0
	MOVE.B	D0,$0068(A6,D6.W)
	MOVE.B	(A0)+,$006C(A6,D6.W)
	ANDI.B	#$000F,$006C(A6,D6.W)
	MOVE.B	(A0)+,-$0040(A6,D6.W)
	BRA.W	L_101E

L_1196	MOVE.B	(A0)+,-$0044(A6,D6.W)
	BRA.W	L_101E

L_119e	MOVE.B	(A0)+,-$0060(A6,D6.W)
	MOVE.B	(A0)+,-$0064(A6,D6.W)
	MOVE.B	(A0)+,$007C(A6,D6.W)
	BRA.W	L_101E

L_11ae	MOVE.B	(A0)+,-$0058(A6,D6.W)
	BRA.W	L_101E

L_11b6	MOVE.B	(A0)+,$0074(A6,D6.W)
	MOVE.B	(A0)+,-$0078(A6,D6.W)
	MOVE.B	(A0)+,-$006C(A6,D6.W)
	MOVE.B	(A0)+,-$0048(A6,D6.W)
	BRA.W	L_101E

L_11ca	MOVE.B	#-1,-$0030(A6,D6.W)
	BRA.W	L_101E

L_11d4	MOVE.B	(A0)+,D0
	BRA.W	L_101E

L_11da	MOVE.W	(A0)+,$0040(A6,D5.W)
	BRA.W	L_101E

L_11e2	MOVE.B	(A0)+,-$0020(A6,D6.W)
	BRA.W	L_101E

L_11ea	MOVE.B	(A0)+,-$0050(A6,D6.W)
	BRA.W	L_101E

L_11f2	CLR.L	D0
	MOVE.B	(A0)+,D0
	MOVE.B	D0,-4(A6,D6.W)
	ASL.W	#2,D0
	MOVE.W	L_12E6(pc),D1
	ASL.W	#2,D1
	move.l	begadr(pc),a1
	LEA	$104(a1),A1
	MOVEA.L	(A1,D1.W),A1
	MOVE.L	(A1,D0.W),d7
	add.l	dx(pc),d7
	move.l	d7,$0030(A6,D4.W)
	BRA.W	L_101E

L_1218	CLR.L	D0
	MOVE.B	(A0)+,-$001C(A6,D6.W)
	BSR.W	L_1226
	BRA.W	L_101E

L_1226	MOVE.B	-$001C(A6,D6.W),-$0018(A6,D6.W)
	CLR.B	$0058(A6,D6.W)
	MOVE.B	#7,$005C(A6,D6.W)
	MOVEA.L	$0030(A6,D4.W),A1
	move.l	a1,d7
	beq.b	l_rts
	ADDQ.L	#2,A1
	MOVE.L	#$80808080,(A1)+
	MOVE.L	#$80808080,(A1)+
	CLR.L	(A1)+
	CLR.L	(A1)+
	CLR.L	(A1)+
	CLR.L	(A1)+
	CLR.L	(A1)+
	CLR.L	(A1)+
l_rts	RTS	

L_12a2	DC.L	0,0,0,0
L_12b2	DC.L	0,0,0,0
L_12c2	DC.L	0,0,0,0
L_12d2	DC.L	0,0,0,0
	DC.L	0
L_12e6	DC.W	0,0
L_12ea	DC.B	0,0,0
L_12ed	DC.B	0,0,0
DmaMasks DC.W	$0001,$0002,$0004,$0008		; a4
	DC.W	$8201,$8202,$8204,$8208
ChipRegs DC.L	$DFF0A6,$DFF0B6,$DFF0C6,$DFF0D6	; a5
	DC.L	$DFF0A4,$DFF0B4,$DFF0C4,$DFF0D4
	DC.L	$DFF0A0,$DFF0B0,$DFF0C0,$DFF0D0
	DC.L	$DFF0A8,$DFF0B8,$DFF0C8,$DFF0D8
	DC.W	$FFF
Periodes DC.W	$EEE,$E18,$D4D,$C8E,$BDA,$B2F,$A8F,$9F7,$968,$8E1,$861,$7E9
	DC.W	$777,$70C,$6A7,$647,$5ED,$598,$547,$4FC,$4B4,$470,$431,$3F4
	DC.W	$3BC,$386,$353,$324,$2F6,$2CC,$2A4,$27E,$25A,$238,$218,$1FA
	DC.W	$1DE,$1C3,$1AA,$192,$17B,$166,$152,$13F,$12D,$11C,$10C,$0FD
	DC.W	$EF,$E1,$D5,$C9,$BE,$B3,$A9,$9F,$96,$8E,$86,$7F,$77,$71,$6A
	DC.W	$64,$5f,$59,$54,$50,$4B,$47,$43,$3F,$3C,$38,$35,$32,$2F,$2D
	DC.W	$2A,$28,$26,$24,$22,$20,$1E,$1C,$1B,$19,$18,$16,$15,$14,$13
	DC.W	$12,$11,$10,$08
	DC.B	$A,$14,$1E,$28,$32,$3C,$46,$50
	DC.B	$A,$14,$1E,$28,$32,$3C,$46,$50
	DC.B	' MIKE/Tim Follin, improved by ANDY SILVA '
	even

	section	"Buffer",bss

tmp	blk.l	428,0

	END

