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
	dl	DTP_ExtLoad,LoadIns
	dl	DTP_InitPlayer,InitPly
	dl	DTP_InitSound,Init
	dl	DTP_Interrupt,Play
	dl	DTP_EndPlayer,EndPly

	dl	DTP_NextSong,NextSong
	dl	DTP_PrevSong,PrevSong
	dl	DTP_Volume,SetVol

	dl	TAG_DONE

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Name	db	"Infogrames Player",0
Comment	db	"Infogrames,",10
	db	"adapted by Andy Silva",0

	db	'$VER: a player for the famous DeliTracker',0
	even

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

LoadIns:
	push	a6
	move.l	dtg_PathArrayPtr(a5),a0
	clr.b	(a0)
	move.l	dtg_CopyDir(a5),a1
	jsr	(a1)
	move.l	dtg_CopyFile(a5),a1
	jsr	(a1)
	move.l	dtg_PathArrayPtr(a5),a0
li_lp1	tst.b	(a0)+
	bne.b	li_lp1
	subq.l	#1,a0
	move.l	a0,-(a7)
	cmp.b	#"M",-1(a0)
	beq.b	li_u
	cmp.b	#"m",-1(a0)
	bne.b	li_1
li_u	cmp.b	#"U",-2(a0)
	beq.b	li_d
	cmp.b	#"u",-2(a0)
	bne.b	li_1
li_d	cmp.b	#"D",-3(a0)
	beq.b	li_p
	cmp.b	#"d",-3(a0)
	bne.b	li_1
li_p	cmp.b	#".",-4(a0)
	bne.b	li_1
	subq.l	#4,a0
	move.l	a0,(a7)
li_1	bsr.b	AddIns
	move.l	dtg_DosBase(a5),a6
	move.l	dtg_PathArrayPtr(a5),d1
	move.l	#1005,d2
	jsr	-30(a6)
	move.l	d0,d1
	beq.b	li_2
	jsr	-36(a6)
	move.l	dtg_LoadFile(a5),a0
	jsr	(a0)
	tst.l	d0
	beq.b	li_ok
li_2	move.l	(a7),a0
	subq.l	#1,a0
	bsr	AddIns
	move.l	dtg_LoadFile(a5),a0
	jsr	(a0)
li_ok	addq.l	#4,a7
	pop	a6
	rts

AddIns:
	move.b	#".",(a0)+
	move.b	#"i",(a0)+
	move.b	#"n",(a0)+
	move.b	#"s",(a0)+
	clr.b	(a0)+
	rts

Checky:
	moveq	#0,d0
	move.l	dtg_ChkData(a5),a0
	move.w	(a0),d0
	beq.b	fail
	btst	#0,d0
	bne.b	fail
	move.l	dtg_ChkSize(a5),d1
	cmp.l	d0,d1
	ble.b	fail
	lea	(a0,d0.w),a1
	move.w	2(a1),d0
	tst.b	(a1,d0.w)
	bne.b	fail
	cmp.b	#$0f,1(a1,d0.w)
	bne.b	fail
	move.l	a0,data
	moveq	#0,d0
	rts
fail	moveq	#-1,d0
	rts

InitPly
	move.l	data(pc),a0
	move.l	a0,data1
	move.w	(a0),d0
	lsr.w	#1,d0
	subq.w	#1,d0
	move.w	d0,songnr
	move.l	dtg_GetListData(a5),a1
	moveq	#1,d0
	jsr	(a1)
	addq.l	#4,a0
	move.l	a0,samples
	move.l	(dtg_AudioAlloc,a5),a0
	jsr	(a0)
	tst.l	d0
	rts

EndPly	move.l	(dtg_AudioFree,a5),a0	; free audio channels
	jsr	(a0)
	rts

****

data1	dc.l	0
data	dc.l	0
songnr	dc.w	0
songs	dc.w	0
allow	dc.w	0

Init:
	pushm	d1-a6
	clr.w	allow
	move.w	#14209/2,dtg_Timer(a5)
	move.l	data1(pc),-(a7)
	move.w	songnr(pc),-(a7)
	bsr	_InitDum
	addq.l	#6,a7
	move.w	#$80,-(a7)
	clr.w	-(a7)
	bsr	_SndFunc
	addq.l	#4,a7
	move.w	#1,allow
	popm	d1-a6
	rts

Play:
	pushm	d1-a6
	tst.w	allow
	beq.b	p_rts
	bsr	_Play
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

SetVol:
	lea	SndTmp(pc),a6
	move.w	dtg_SndVol(a5),d0
	move.b	d0,$1d(a6)
	rts

***************                   *** ripped by: ****
*************** Infogrames Replay *** Andy Silva ****
***************                   *** in 11/1994 ****

_SndFunc1
	LINK	A6,#0
	MOVEM.L	D1-D7/A0-A6,-(SP)
	MOVE.L	#$FFFF,D0
	MOVE.W	(10,A6),D1
	MOVE.W	(8,A6),D5
	LEA	(SndTmp),A6
	MOVE.W	D1,D2
	AND.L	#15,D2			; 1? $000f    > 2cda
	BNE.B	lbC002CDA
	OR.W	#15,D2			; 1> $000f
lbC002CDA	LEA	(Voc1),A5
	MOVEQ	#0,D7
lbC002CE2	LSR.W	#1,D2		; 1? %...............1
	BCC.W	lbC002DA4
	MOVEA.L	($1C,A5),A0
	BTST	#15,D1			; 1? %1...............
	BEQ.B	lbC002CF6
	MOVE.B	D5,($2F,A0)
lbC002CF6	BTST	#13,D1		; 1? %..1.............
	BEQ.B	lbC002D04
	MOVE.B	D5,($2B,A0)
	MOVE.B	D5,($2F,A0)
lbC002D04	BTST	#8,D1		; 1? %.......1........
	BEQ.B	lbC002D16
	CLR.B	($2B,A0)
	MOVE.B	($1D,A6),D0
	MOVE.B	D0,($2F,A0)
lbC002D16	BTST	#9,D1		; 1? %......1.........
	BEQ.B	lbC002D22
	ORI.W	#$200,($26,A0)
lbC002D22	BTST	#6,D1		; 1? %.........1......
	BEQ.B	lbC002D40
	MOVE.W	#$40,($26,A0)
	BCLR	#1,($27,A5)
	BTST	#6,($27,A5)
	BEQ.B	lbC002D40
	BSR.W	lbC00336E
lbC002D40	BTST	#7,D1		; 1? %........1.......
	BEQ.B	lbC002D98
	BTST	#14,D1
	BEQ.B	lbC002D54
	BTST	#1,($27,A5)
	BNE.B	lbC002D98
lbC002D54	MOVE.B	D5,($2D,A0)
	LEA	($2D,A0),A1
	MOVE.L	A1,(0,A0)
	BCLR	#5,($27,A0)
	BCLR	#6,($27,A0)
	ORI.W	#$80,($26,A0)
	ORI.W	#1,($26,A0)
	ORI.W	#2,($26,A5)
	ORI.W	#2,($26,A0)
	MOVE.B	#$3F,($2B,A0)
	MOVE.B	#$3F,($2F,A0)
	ST	($1A,A6)
	MOVEA.L	($18,A0),A1
lbC002D98	BTST	#5,D1		; 1? $..........%.....
	BEQ.B	lbC002DA4
	ORI.W	#$20,($26,A0)
lbC002DA4	ADDA.L	#$50,A5
	ADDQ.W	#1,D7
	CMP.W	#4,D7
	BNE.W	lbC002CE2
	MOVE.L	D0,-(SP)
	MOVE.L	(SP)+,D0
	MOVEM.L	(SP)+,D1-D7/A0-A6
	UNLK	A6
	RTS

lbC002DC0	MOVE.W	(A0)+,D3
	BEQ.B	lbC002DD4
	CMP.W	D3,D1
	BEQ.B	lbC002DCE
	LEA	(4,A0),A0
	BRA.B	lbC002DC0

lbC002DCE	MOVEA.L	(A0),A0
	MOVE.L	A0,-(SP)
	RTS

lbC002DD4	ORI.B	#1,CCR
	RTS

SndSub7	MOVE.B	D5,($1C,A6)
	MOVE.B	D5,($1B,A6)
	ANDI.B	#$FE,CCR
	RTS

SndSub5	MOVE.B	D5,($1D,A6)	; mainvol
	ANDI.B	#$FE,CCR
	RTS

SndSub6	MOVE.B	D5,($1E,A6)
	ANDI.B	#$FE,CCR
	RTS

_InitIns
	move.l	4(sp),samples
	rts

_InitDum	LINK	A6,#0
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVEA.L	(10,A6),A0
	MOVE.W	(8,A6),D0
	LEA	(SndTmp),A6
	SF	($1A,A6)
	LSL.W	#1,D0
	MOVE.W	(A0,D0.W),D0	; lese Offset zu Untersong
	LEA	(A0,D0.W),A0	; mache Zeiger ..
	MOVE.L	A0,(12,A6)	; merke Zeiger ..
	MOVEA.L	A0,A1
	MOVE.W	(A0)+,D0	; Tempo?
	MOVE.B	D0,($1B,A6)
	MOVE.B	D0,($1C,A6)
	MOVE.W	(A0)+,D0	; Offsest zum Schrägen (000f...)
	LEA	(A1,D0.W),A2
	MOVE.L	A2,(4,A6)
	MOVE.W	(A0)+,D0	; Offset zum 2. Schrägen (0100...)
	LEA	(A1,D0.W),A2
	MOVE.L	A2,(8,A6)
	MOVE.W	(A0)+,D0
	LEA	(A1,D0.W),A3
	LEA	(Voc1),A2
	MOVE.L	A3,(0,A2)
	MOVE.W	(A0)+,D0
	LEA	(A1,D0.W),A3
	LEA	(Voc2),A2
	MOVE.L	A3,(0,A2)
	MOVE.W	(A0)+,D0
	LEA	(A1,D0.W),A3
	LEA	(Voc3),A2
	MOVE.L	A3,(0,A2)
	MOVE.W	(A0)+,D0
	LEA	(A1,D0.W),A3
	LEA	(Voc4),A2
	MOVE.L	A3,(0,A2)
	MOVE.W	(A0)+,D0	; Offset zum Ende (=Länge?)
	MOVE.L	A0,($10,A6)	; merke Zeiger auf Trackoffsets
	MOVE.B	#$3F,($1D,A6)
	MOVE.W	#3,D3
	LEA	(Voc1),A2
i_lp	ORI.W	#$40,($26,A2)
	MOVE.B	#$3F,($2B,A2)
	MOVE.B	#$3F,($2F,A2)
	ADDA.W	#$50,A2
	DBRA	D3,i_lp
	MOVEM.L	(SP)+,D0-D7/A0-A6
	UNLK	A6
	RTS

_SndFunc	LINK	A6,#0
	MOVEM.L	D1-D7/A0-A6,-(SP)
	MOVE.L	#$FFFF,D0
	MOVE.W	(10,A6),D1
	MOVE.W	(8,A6),D5
	LEA	(SndSubTable2),A0
	LEA	(SndTmp),A6
	BSR.W	lbC002DC0
	BCC.W	lbC002F9C
	MOVE.W	D1,D2
	AND.L	#15,D2
	BNE.B	lbC002EF4
	OR.W	#15,D2
lbC002EF4	LEA	(Voc1),A0
	MOVEQ	#0,D7
lbC002EFC	LSR.W	#1,D2
	BCC.W	lbC002F8C
	BTST	#15,D1
	BEQ.B	lbC002F10
	AND.B	#$3F,D5
	MOVE.B	D5,($2F,A0)
lbC002F10	BTST	#13,D1
	BEQ.B	lbC002F1E
	MOVE.B	D5,($2B,A0)
	MOVE.B	D5,($2F,A0)
lbC002F1E	BTST	#8,D1
	BEQ.B	lbC002F30
	CLR.B	($2B,A0)
	MOVE.B	($1D,A6),D0
	MOVE.B	D0,($2F,A0)
lbC002F30	BTST	#9,D1
	BEQ.B	lbC002F3A
	CLR.B	($2F,A0)
lbC002F3A	BTST	#6,D1
	BEQ.B	lbC002F4A
	ORI.W	#$40,($26,A0)
	BSR.W	lbC00336E
lbC002F4A	BTST	#7,D1
	BEQ.B	lbC002F64
	CLR.W	($26,A0)
	ORI.W	#$80,($26,A0)
	ORI.W	#1,($26,A0)
	ST	($1A,A6)
lbC002F64	BTST	#5,D1
	BEQ.B	lbC002F70
	ORI.W	#$20,($26,A0)
lbC002F70	BTST	#4,D1
	BEQ.B	lbC002F8C
	BTST	#6,($27,A0)
	BNE.B	lbC002F8C
	MOVEQ	#0,D6
	MOVE.W	($24,A0),D6
	CMP.L	D6,D0
	BCS.B	lbC002F8C
	MOVE.W	($24,A0),D0
lbC002F8C	ADDA.L	#$50,A0
	ADDQ.W	#1,D7
	CMP.W	#4,D7
	BNE.W	lbC002EFC
lbC002F9C	MOVEM.L	(SP)+,D1-D7/A0-A6
	UNLK	A6
	RTS

_Play	MOVEM.L	D0/A6,-(SP)
	LEA	SndTmp(pc),A6
	MOVEM.L	D0-D7/A0-A5,-(SP)
	SUBQ.B	#1,($1B,A6)
	MOVE.B	#$FF,($18,A6)
	MOVEQ	#0,D7
	LEA	Voc1(pc),A3
lbC002FD6	CLR.W	(A6)
	CLR.W	(2,A6)
	BSR.W	lbC003144
	MOVE.L	A3,-(SP)
	BTST	#1,($27,A3)
	BEQ.B	lbC002FF8
	MOVE.B	#$FF,($18,A6)
	MOVEA.L	($1C,A3),A3
	BSR.W	lbC003144
lbC002FF8	MOVEM.L	D0-D3/A0/A1,-(SP)
	MOVEQ	#0,D1
	MOVE.W	D7,D1
	LSL.W	#4,D1
	MOVEA.L	#$DFF0A0,A1
	MOVE.W	(0,A6),(8,A1,D1.W)
	MOVE.W	(2,A6),(6,A1,D1.W)
	CMPI.B	#$FF,($18,A6)
	BEQ.B	lbC003080
	MOVEQ	#0,D0
	MOVE.B	($18,A6),D0
	MOVE.B	#$FF,($18,A6)
	LSL.W	#4,D0
	MOVEQ	#0,D1
	MOVE.W	D7,D1
	LSL.W	#4,D1
	MOVEQ	#1,D2
	LSL.W	D7,D2
	MOVEA.L	(samples),A0
	MOVEA.L	#$DFF0A0,A1
	MOVE.L	(A0,D0.W),D3
	ADD.L	A0,D3
	MOVE.L	D3,(A1,D1.W)
	MOVE.W	(12,A0,D0.W),(4,A1,D1.W)
	MOVE.W	D2,($DFF096)
	MOVE.W	#$AA,D3
lbC00305A	DBRA	D3,lbC00305A
	ORI.W	#$8200,D2
	MOVE.W	D2,($DFF096)
	MOVE.W	#$64,D3
lbC00306C	DBRA	D3,lbC00306C
	MOVE.L	(4,A0,D0.W),D3
	ADD.L	A0,D3
	MOVE.L	D3,(A1,D1.W)
	MOVE.W	(14,A0,D0.W),(4,A1,D1.W)
lbC003080	MOVEM.L	(SP)+,D0-D3/A0/A1
	MOVEA.L	(SP)+,A3
	ADDA.W	#$50,A3
	ADDQ.W	#1,D7
	CMP.W	#4,D7
	BNE.W	lbC002FD6
	TST.B	($1B,A6)
	BNE.B	lbC0030A0
	MOVE.B	($1C,A6),($1B,A6)
lbC0030A0	ST	($1A,A6)
	MOVEM.L	(SP)+,D0-D7/A0-A5
lbC0030A8	MOVEM.L	(SP)+,D0/A6
	MOVEQ	#0,D0
	RTS

lbC0030B0	MOVEQ	#0,D3
	MOVE.B	(10,A0),D3
	MOVEA.L	(4,A0),A1
	LEA	(A1,D3.W),A1
	BCLR	#0,(11,A0)
	BEQ.B	lbC0030D0
	MOVE.B	(1,A1),D3
	EXT.W	D3
	ADD.W	D3,(2,A0)
lbC0030D0	ADD.W	(2,A0),D0
	SUB.W	(0,A0),D0
	BTST	#15,D0
	BEQ.B	lbC0030E0
	MOVEQ	#0,D0
lbC0030E0	BTST	#2,(11,A0)
	BNE.B	lbC00313A
	ADDQ.B	#1,(12,A0)
	MOVE.B	(2,A1),D3
	CMP.B	(12,A0),D3
	BNE.B	lbC00313A
	ADDQ.B	#1,(13,A0)
	CLR.B	(12,A0)
	MOVE.B	(0,A1),D3
	CMP.B	(13,A0),D3
	BNE.B	lbC003134
	CLR.B	(13,A0)
	MOVE.B	(10,A0),D3
	ADDQ.W	#3,D3
	CMP.B	#12,D3
	BNE.B	lbC003130
	TST.B	(11,A0)
	BEQ.B	lbC00313C
	CLR.B	(13,A0)
	MOVE.B	(8,A0),D3
	EXT.W	D3
	ADD.W	D3,(0,A0)
	MOVE.W	#3,D3
lbC003130	MOVE.B	D3,(10,A0)
lbC003134	BSET	#0,(11,A0)
lbC00313A	RTS

lbC00313C	BSET	#2,(11,A0)
	RTS

lbC003144	BTST	#6,($27,A3)
	BNE.W	lbC00336C
	MOVE.L	($18,A3),D0
	MOVE.L	D0,($14,A6)
	MOVE.B	($2F,A3),D0
	CMP.B	($2B,A3),D0
	BEQ.B	lbC003186
	ADDQ.B	#1,($2C,A3)
	MOVE.B	($2C,A3),D0
	CMP.B	($1E,A6),D0
	BLS.B	lbC003186
	CLR.B	($2C,A3)
	MOVE.B	($2F,A3),D0
	CMP.B	($2B,A3),D0
	BLS.B	lbC003182
	ADDQ.B	#1,($2B,A3)
	BRA.B	lbC003186

lbC003182	SUBQ.B	#1,($2B,A3)
lbC003186	BCLR	#0,($27,A3)
	BNE.B	lbC0031F4
	TST.B	($1B,A6)
	BNE.B	lbC003198
	SUBQ.B	#1,($28,A3)
lbC003198	TST.B	($28,A3)
	BNE.W	lbC00332C
	MOVE.B	($29,A3),($28,A3)
lbC0031A6	MOVEA.L	(8,A3),A0
	MOVE.B	(A0)+,D0
	CMP.B	#$FF,D0
	BNE.B	lbC003220
lbC0031B2	MOVEA.L	(12,A3),A0
	MOVE.B	(A0)+,D0
	CMP.B	#$FF,D0
	BNE.B	lbC003200
	BTST	#5,($27,A3)
	BNE.B	lbC0031F4
	MOVEA.L	(4,A3),A1
	BTST	#1,($27,A1)
	BEQ.B	lbC0031DE
	BTST	#1,($26,A3)
	BEQ.B	lbC0031DE
	CLR.B	($2B,A1)
lbC0031DE	BCLR	#1,($27,A1)
	ORI.W	#$40,($26,A3)
	MOVE.W	#0,(0,A6)
	BRA.W	lbC00336C

lbC0031F4	MOVE.L	(0,A3),(12,A3)
	CLR.W	($24,A3)
	BRA.B	lbC0031B2

lbC003200	MOVE.L	A0,(12,A3)
	ADDQ.W	#1,($24,A3)
	AND.W	#$FF,D0
	LSL.W	#1,D0
	MOVEA.L	($10,A6),A0
	MOVEA.W	(A0,D0.W),A0
	ADDA.L	(12,A6),A0
	MOVE.L	A0,(8,A3)
	BRA.B	lbC0031A6

lbC003220	MOVE.L	A0,(8,A3)
	AND.L	#$FF,D0
	BTST	#7,D0
	BNE.B	lbC003298
	LEA	(SndTable1),A0
	TST.B	D0
	BEQ.B	lbC00323E
	ADD.B	($2A,A3),D0
lbC00323E	LSL.W	#1,D0
	MOVE.W	(A0,D0.W),($22,A3)
	MOVE.W	(A0,D0.W),($20,A3)
	MOVEA.L	($10,A3),A0
	CLR.B	(10,A0)
	CLR.W	(2,A0)
	CLR.W	(0,A0)
	CLR.B	(13,A0)
	CLR.B	(12,A0)
	BSET	#0,(11,A0)
	BCLR	#2,(11,A0)
	MOVEA.L	($14,A3),A0
	CLR.B	(10,A0)
	CLR.W	(2,A0)
	CLR.W	(0,A0)
	CLR.B	(13,A0)
	CLR.B	(12,A0)
	BSET	#0,(11,A0)
	BCLR	#2,(11,A0)
	BRA.W	lbC00332C

lbC003298	BTST	#6,D0
	BNE.B	lbC0032CA
	BTST	#5,D0
	BEQ.B	lbC0032B0
	AND.W	#$1F,D0
	MOVE.B	D0,($18,A6)
	BRA.W	lbC0031A6

lbC0032B0	AND.B	#15,D0
	LEA	(SndIrMaskTable),A0
	MOVE.B	(A0,D0.W),($29,A3)
	MOVE.B	(A0,D0.W),($28,A3)
	BRA.W	lbC0031A6

lbC0032CA	BTST	#5,D0
	BNE.B	lbC00331A
	MOVEA.L	(4,A6),A0
	AND.W	#$1F,D0
	MULU.W	#13,D0
	LEA	(A0,D0.W),A0
	MOVEA.L	($10,A3),A2
	MOVE.B	(A0),D0
	AND.B	#$80,D0
	MOVE.B	D0,(11,A2)
	MOVE.B	(A0)+,D0
	AND.W	#$7F,D0
	MOVE.B	D0,(8,A2)
	CLR.B	(10,A2)
	CLR.W	(2,A2)
	CLR.W	(0,A2)
	CLR.B	(13,A2)
	CLR.B	(12,A2)
	BSET	#0,(11,A2)
	MOVE.L	A0,(4,A2)
	BRA.W	lbC0031A6

lbC00331A	LEA	(SndSubTable),A0
	AND.W	#7,D0
	LSL.W	#2,D0
	MOVE.L	(A0,D0.W),-(SP)
	RTS

lbC00332C	MOVEQ	#0,D0
	MOVEA.L	($10,A3),A0
	BSR.W	lbC0030B0
	MOVEQ	#0,D1
	MOVE.B	($2B,A3),D1
	CMP.B	($1D,A6),D1
	BLE.B	lbC003346
	MOVE.B	($1D,A6),D1
lbC003346	MOVEQ	#$3F,D2
	SUB.W	D1,D2
	SUB.W	D2,D0
	BCC.B	lbC003350
	MOVEQ	#0,D0
lbC003350	AND.W	#$FF,D0
	MOVE.W	D0,(0,A6)
	MOVEA.L	($14,A3),A0
	MOVE.W	($20,A3),D0
	MOVE.L	A1,-(SP)
	BSR.W	lbC0030B0
	MOVEA.L	(SP)+,A1
	MOVE.W	D0,(2,A6)
lbC00336C	RTS

lbC00336E	MOVEM.L	D1/D2/A1,-(SP)
	MOVEQ	#0,D1
	MOVE.W	D7,D1
	LSL.W	#4,D1
	MOVEQ	#1,D2
	LSL.W	D7,D2
	MOVEA.L	#$DFF0A0,A1
	MOVE.W	#0,(8,A1,D1.W)
	MOVE.W	D2,($DFF096)
	MOVEM.L	(SP)+,D1/D2/A1
	RTS

SndSub1	MOVEA.L	(8,A3),A0
	MOVE.B	(A0)+,($2A,A3)
	MOVE.L	A0,(8,A3)
	BRA.W	lbC0031A6

SndSub2	MOVEA.L	(8,A3),A0
	MOVE.B	(A0)+,D0
	MOVE.L	A0,(8,A3)
	MOVEA.L	(8,A6),A0
	AND.W	#$FF,D0
	MULU.W	#13,D0
	LEA	(A0,D0.W),A0
	MOVEA.L	($14,A3),A2
	MOVE.B	(A0)+,D0
	CLR.B	(11,A2)
	CLR.B	(8,A2)
	CLR.B	(10,A2)
	CLR.W	(2,A2)
	CLR.W	(0,A2)
	CLR.B	(13,A2)
	CLR.B	(12,A2)
	BSET	#0,(11,A2)
	MOVE.L	A0,(4,A2)
	BRA.W	lbC0031A6

SndSub3	MOVEA.L	(8,A3),A0
	MOVE.B	(A0)+,D0
	MOVE.L	A0,(8,A3)
	MOVEA.L	(8,A6),A0
	AND.W	#$FF,D0
	MULU.W	#13,D0
	LEA	(A0,D0.W),A0
	MOVEA.L	($14,A3),A2
	MOVE.B	(A0)+,D0
	MOVE.B	#$80,(11,A2)
	CLR.B	(8,A2)
	CLR.B	(10,A2)
	CLR.W	(2,A2)
	CLR.W	(0,A2)
	CLR.B	(13,A2)
	CLR.B	(12,A2)
	BSET	#0,(11,A2)
	MOVE.L	A0,(4,A2)
	BRA.W	lbC0031A6

SndSub4	BRA.W	lbC0031A6

samples	dc.l	0

SndTmp	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	lbL006F64
	dc.l	0
	dc.l	$00000800
SndSubTable
	dc.l	SndSub1
	dc.l	SndSub3
	dc.l	SndSub2
	dc.l	SndSub4
	dc.l	$1020408
SndIrMaskTable	dc.l	$2030406
	dc.l	$80C1018
	dc.l	$20304060
SndSubTable2
	dc.w	$800
	dc.l	SndSub5
	dc.w	$400
	dc.l	SndSub7
	dc.w	$1000
	dc.l	SndSub6
	dc.w	0
Voc1	dc.l	0
	dc.l	Voc1
	dc.l	0
	dc.l	0
	dc.l	lbL006D14
	dc.l	lbL006D24
	dc.l	lbL006F64
	dc.l	Voc1_a
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FF00
lbL006D14	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL006D24	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
Voc2	dc.l	0
	dc.l	Voc2
	dc.l	0
	dc.l	0
	dc.l	lbL006D64
	dc.l	lbL006D74
	dc.l	lbL006F64
	dc.l	Voc2_a
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FF00
lbL006D64	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL006D74	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
Voc3	dc.l	0
	dc.l	Voc3
	dc.l	0
	dc.l	0
	dc.l	lbL006DB4
	dc.l	lbL006DC4
	dc.l	lbL006F64
	dc.l	Voc3_a
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FF00
lbL006DB4	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL006DC4	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
Voc4	dc.l	0
	dc.l	Voc4
	dc.l	0
	dc.l	0
	dc.l	lbL006E04
	dc.l	lbL006E14
	dc.l	lbL006F64
	dc.l	Voc4_a
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FF00
lbL006E04	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL006E14	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
Voc1_a	dc.l	0
	dc.l	Voc1
	dc.l	0
	dc.l	0
	dc.l	lbL006E54
	dc.l	lbL006E64
	dc.l	lbL006F6C
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FF00
lbL006E54	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL006E64	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
Voc2_a	dc.l	0
	dc.l	Voc2
	dc.l	0
	dc.l	0
	dc.l	lbL006EA4
	dc.l	lbL006EB4
	dc.l	lbL006F6C
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FF00
lbL006EA4	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL006EB4	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
Voc3_a	dc.l	0
	dc.l	Voc3
	dc.l	0
	dc.l	0
	dc.l	lbL006EF4
	dc.l	lbL006F04
	dc.l	lbL006F6C
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FF00
lbL006EF4	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL006F04	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
Voc4_a	dc.l	0
	dc.l	Voc4
	dc.l	0
	dc.l	0
	dc.l	lbL006F44
	dc.l	lbL006F54
	dc.l	lbL006F6C
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	$FF00
lbL006F44	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL006F54	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
lbL006F64	dc.l	0
	dc.l	$3F00
lbL006F6C	dc.l	0
	dc.l	$3F00
	dc.l	$1005A
	dc.l	$7F5A00A6
	dc.l	$81A67F7F
	dc.l	$81817F7F
	dc.w	$8181
SndTable1	dc.l	$6ACC64CC
	dc.l	$5F2559CE
	dc.l	$54C35003
	dc.l	$4B864747
	dc.l	$43463F8B
	dc.l	$3BF33892
	dc.l	$35683269
	dc.l	$2F932CEA
	dc.l	$2A662801
	dc.l	$256623A5
	dc.l	$21AF1FC4
	dc.l	$1DFE1C4E
	dc.l	$1ABC1936
	dc.l	$17CC1676
	dc.l	$15331401
	dc.l	$12E411D5
	dc.l	$10D40FE3
	dc.l	$EFE0E26
	dc.l	$D5B0C9B
	dc.l	$BE50B3B
	dc.l	$A9B0A02
	dc.l	$97208E9
	dc.l	$86907F1
	dc.l	$77F0713
	dc.l	$6AD064D
	dc.l	$5F2059D
	dc.l	$54D0500
	dc.l	$4B80475
	dc.l	$43503F8
	dc.l	$3BF038A
	dc.l	$3560326
	dc.l	$2F902CF
	dc.l	$2A60280
	dc.l	$25C023A
	dc.l	$21A01FC
	dc.l	$1E001C5
	dc.l	$1AB0193
	dc.l	$17D0167
	dc.l	$1530140
	dc.l	$12E011D
	dc.l	$10D00FE
	dc.l	$F000E2
	dc.l	$D600CA
	dc.l	$BE00B4
	dc.l	$AA00A0
	dc.l	$97008F
	dc.l	$87007F
	dc.l	$780070
	dc.l	$600050
	dc.l	$400030
	dc.l	$200010
lbL007052	dc.l	0
lbL007056	dc.l	$202020
	dc.l	$20202020
	dc.l	$20203030
	dc.l	$30303020
	dc.l	$20202020
	dc.l	$20202020
	dc.l	$20202020
	dc.l	$20202020
	dc.l	$20904040
	dc.l	$40404040
	dc.l	$40404040
	dc.l	$40404040
	dc.l	$400C0C0C
	dc.l	$C0C0C0C
	dc.l	$C0C0C40
	dc.l	$40404040
	dc.l	$40400909
	dc.l	$9090909
	dc.l	$1010101
	dc.l	$1010101
	dc.l	$1010101
	dc.l	$1010101
	dc.l	$1010101
	dc.l	$40404040
	dc.l	$40400A0A
	dc.l	$A0A0A0A
	dc.l	$2020202
	dc.l	$2020202
	dc.l	$2020202
	dc.l	$2020202
	dc.l	$2020202
	dc.l	$40404040
	dc.w	$2000


	END

