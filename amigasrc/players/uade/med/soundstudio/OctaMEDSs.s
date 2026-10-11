**
** DeliTracker Player for OctaMED Soundstudio
** Uses 8-bit mixing with frequency 24000Hz, no smoothing
**
	incdir	"../../../../score/"
	include	"misc/DeliPlayer.i"

	PLAYERHEADER PlayerTagArray
	dc.b	'$VER: Octamed Soundstudio player for UADE (20231009)',0
	even

PlayerTagArray
	dc.l	DTP_PlayerVersion,1
	dc.l	DTP_PlayerName,Name
	dc.l	DTP_ModuleName,MNamePTR
	dc.l	DTP_Creator,Comment

	dc.l	DTP_Check2,Checky
	dc.l	DTP_InitPlayer,InitPly
	dc.l	DTP_InitSound,InitSnd
	dc.l	DTP_StartInt,StartInt
	dc.l	DTP_StopInt,StopInt
	dc.l	DTP_EndPlayer,EndPly
	dc.l	DTP_FormatName,FormatPtr

	dc.l	DTP_SubSongRange,SubsongRange
	dc.l	DTP_Flags,PLYF_SONGEND
	dc.l	TAG_DONE

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MNamePTR dc.l	MName
Name	dc.b	"OctaMED Soundstudio",0
Comment	dc.b	"OctaMED promixplayer 7.1 replay",10
        dc.b    "(c) by Teijo Kinnunen & Ray Burt Frost",10
	dc.b	"http://www.med.uk.com .",10
	dc.b	"adapted for uade by Tundrah / RNO",10
	dc.b	"based on OctaMED adaption by mld",0
MName
	dc.b	"<no songtitle>"
	dc.b	0
	even

mmd0	dc.l	0	; pointer to our mod
dtg	dc.l	0	; delibase

FormatPtr	dc.l	Format
Format		dc.l	"MMDx"
		dc.b	0
		even
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Checky:
	moveq	#-1,d0
	move.l	dtg_ChkData(a5),a0
	move.l	a0,mmd0			; save med module pointer
	move.l	(a0),a1
	sub.l	#$4d4d4430,a1		; clear MMDx

	cmp.l	#2,a1			; MMD2-3 ???
	blt	c_rts
	cmp.l	#3,a1
	bgt	c_rts

	move.l	(a0),Format		; save type
	move.l	a5,dtg
	add.l	mmd_songinfo(a0),a0
	tst.b	msng_flags2(a0)		; mixing?
	bpl.s	c_rts

c_ok	moveq	#0,d0
c_rts	rts

****

InitPly
	moveq	#0,d0
	move.l	dtg_AudioAlloc(a5),a0
	jsr	(a0)

	move.l	mmd0,a2
	jsr	_RelocModule
	jsr	_InitPlayerM
	bsr.w	SetMName
	rts

EndPly
	move.l	dtg_AudioFree(a5),a0
	jmp	(a0)
	jsr	_AudioRem
	rts
	
InitSnd:
	bsr	uade_playtable_cls
	move.l	dtg(pc),a5
	move.w	dtg_SndNum(a5),_modnumm
	sub.w	#1,_modnumm
	rts

StartInt:
	move.l	mmd0,a0
	jsr	_PlayModuleM
	rts

StopInt:
	jsr	_StopPlayerM
	move.w	#$f,$dff096
	rts

SubsongRange:
	moveq	#1,d0		; min
	moveq	#1,d1		; max
	move.l	mmd0,a0
ssrloop:
	move.l	mmd_expdata(a0),a1
	tst.l	(a1)
	beq	ssr_end
	addq	#1,d1
	move.l	(a1),a0	
	bra	ssrloop
ssr_end	rts

SetMName:
	move.l	mmd0,a0
	move.l	mmd_expdata(a0),d1	;expdatablock ?
	beq.s	SetNoMName

	move.l	d1,a1
	tst.l	48(a1)			; how long
	beq SetNoMName	
	move.l	44(a1),d1		; title
	beq.s	SetNoMName
	move.l	d1,MNamePTR
	rts
	
	SetNoMName:
	rts


Songend:
	movem.l	d0-d6/a0-a6,-(sp)
	move.l	dtg(pc),a5
	move.l	dtg_SongEnd(a5),a0
	jsr	(a0)
	movem.l	(sp)+,d0-d6/a0-a6
	rts	

uade_playtable_setd1:
	movem.l	d0-d6/a0-a6,-(sp)
	move.l	d1,d0
	bra	ups1
uade_playtable_set:
	movem.l	d0-d6/a0-a6,-(sp)
ups1:	lea.l	uade_playtable(pc),a0
	moveq	#7,d1
	sub	d0,d1	; bit position
	lsr	#3,d0	; byte position
	add	d0,a0
	btst	d1,(a0)
	beq	uade_playtable_nvb	; not visited before
	st	uade_songend_flag
uade_playtable_nvb:
	bset	d1,(a0)	; set bit
	movem.l	(sp)+,d0-d6/a0-a6
	rts

uade_playtable_cls:
	movem.l	d0-d6/a0-a6,-(sp)
	sf	uade_songend_flag
	move.w	#256/8,d0
	lea.l	uade_playtable(pc),a0
clearplayt:
	move.b	#0,(a0)+
	dbra	d0,clearplayt
	movem.l	(sp)+,d0-d6/a0-a6
	rts

uade_playtable:    dcb.b	256/8,0
uade_songend_flag: dc.b		0
		even

		incdir	"../common/"
		include	"reloc.a"
		even
		include "med-mixasm.a"
		even
		include "promixplayer.a"
