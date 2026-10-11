
	incdir	"Amiga:Includes/"
	include "misc/DeliPlayer.i"
	include "exec/types.i"

	STRUCTURE	MT_PATTERN,0
	UWORD	MT_PATTERN_PERIOD	rs	1	* 0
	* 0xQW where Q is instrument (1-15) and W is effect number
	UBYTE	MT_PATTERN_EFF		rs.b	1		* 2
	UBYTE	MT_PATTERN_EFF_PAR	rs.b	1	* 3: parameter of the effect
	APTR	MT_PATTERN_SAMPLE_PTR	rs.l	1	* 4
	UWORD	MT_PATTERN_SAMPLE_LEN	rs	1	* 8: Written to audxlen
	* This is a pointer to the beginning of the sample for the first repeat.
	* This is used for "one hit" samples by setting this pointer to a zero sample
	* with length of 1 word.
	UWORD	MT_PATTERN_SAMPLE_LOOP_PTR	rs	1	* 10
	UWORD	MT_PATTERN_OFF_12	rs	1	* 12
	UWORD	MT_PATTERN_SAMPLE_LOOP_LEN	rs	1	* 14
	UWORD	MT_PATTERN_ARPEGGIO_PAR	rs	1	* 16
	UWORD	MT_PATTERN_VOL		rs	1	* 18: Written to audxvol
	UWORD	MT_PATTERN_DMA_MASK	rs	1	* 20: values: 1, 2, 4, 8
	* This is the effective value written to AUXxPER. Also changed by effects (e.g. portamento).
	UWORD	MT_PATTERN_DYN_PERIOD	rs	1	* 22
	UBYTE	MT_PATTERN_E_COMMAND	rs.b	1	* 24
	UBYTE	MT_PATTERN_E_PAR	rs.b	1	* 25: Defines exact E command
	LABEL	MT_PATTERN_SIZE

CMD_VOL	equ	12
CMD_E	equ	14

	SECTION Player,Code

	PLAYERHEADER PlayerTagArray

	dc.b '$VER: Soundtracker IV player 2025-11-05',0
	even

PlayerTagArray
	dc.l	DTP_PlayerVersion,1
	dc.l	DTP_PlayerName,PName
	dc.l	DTP_Creator,CName
	dc.l	DTP_Check2,Chk
	dc.l	DTP_Interrupt,mt_newirq
	dc.l	DTP_InitPlayer,InitPlay
	dc.l	DTP_EndPlayer,EndPlay
	dc.l	DTP_InitSound,InitSnd
	dc.l	DTP_EndSound,RemSnd
	dc.l	DTP_Flags,PLYF_SONGEND
	dc.l	DTP_FormatName,Formatpointer
	dc.l	TAG_DONE

*-----------------------------------------------------------------------*
;
; Player/Creatorname und lokale Daten
Formatpointer	dc.l	FName
delibase	dc.l	0
song		dc.l	0

PName	dc.b 'Soundtracker IV',0
FName	dc.b 'Soundtracker II - V or compatible',0
CName	dc.b "'88 by DOC, Il Scuro, The Exterminator",10
	dc.b 'adapted for UADE by mld',10
	dc.b '-----------------------',10
	dc.b 'note: filedetection checks for uade!',0
	
	even


*-----------------------------------------------------------------------*
;
; Test Soundtracker-Module

Chk	
	move.l	dtg_ChkData(a5),a0
	move.l	dtg_ChkSize(a5),d1
	move.l	a0,mt_song
; mod_check.s no longer compiles with this and amifilemagic should have done the magic already
;	bsr.w	mcheck_moduledata		; currently -1 for no mod
;	cmp.l	#"M15.",d0
;	bne	.Chk_fail
.Chk_ok: moveq	#0,d0
	rts

.Chk_fail:	
	moveq	#-1,d0
	rts


*-----------------------------------------------------------------------*
;
; Init Player

InitPlay
	move.l	a5,delibase
	moveq	#0,d0

	move.l	dtg_AudioAlloc(a5),a0		; Function
	jsr	(a0)				; returncode is already set !
	sf 	ep_Songendflag
	rts

*-----------------------------------------------------------------------*
;
; End Player

EndPlay
	sf 	ep_Songendflag
	move.l	dtg_AudioFree(a5),a0		; Function
	jsr	(a0)
	rts


*-----------------------------------------------------------------------*
;
; Remove Sound

RemSnd
	lea	$dff000,a0
	moveq	#0,d0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.w	#$000F,$96(a0)			; End Sound
	rts


*-----------------------------------------------------------------------*




***********************************
***********************************
**                               **
** SoundTracker V4.0 Playroutine **
**                               **
**   Coder 1 : Karsten Obarski   **
**                               **
**   Coder 2 : The Exterminator  **
**                               **
**   Coder 3 : Il Scuro          **
**                               **
**   Coder 4 : DOC               **
**                               **
***********************************
***********************************



InitSnd:
    move.l	mt_song,a0
    add.l	#$1d8,a0
    move.l	#$80,d0
    moveq	#$00,d1

mt_init1:
    move.l	d1,d2
    subq.w	#1,d0
mt_init2:
    move.b	(a0)+,d1
    cmp.b	d2,d1
    bgt.s	mt_init1
    dbf		d0,mt_init2
    addq.b	#1,d2

mt_init3:
    move.l	mt_song,a0
    lea		mt_sample_ptrs+4(pc),a1
    asl.l	#8,d2
    asl.l	#2,d2
    add.l	#$258,d2
    add.l	a0,d2
    moveq	#15-1,d0
mt_init4:
    move.l	d2,(a1)+
    move.l	d2,a2
    clr.w	(a2)
    moveq	#$00,d1
    move.w	42(a0),d1
    asl.l	#1,d1
    add.l	d1,d2
    add.l	#$1e,a0
    dbf		d0,mt_init4
  
    move.w	#0,$dff0a8
    move.w	#0,$dff0b8
    move.w	#0,$dff0c8
    move.w	#0,$dff0d8
    clr.l	mt_partnrplay
    clr.l	mt_partnote
    clr.l	mt_partpoint

    move.l	mt_song,a0
    move.b	$1d6(a0),mt_maxpart+1
    move.b	$1d7(a0),mt_kn1+1
    rts


mt_newirq:
    tst.b	ep_Songendflag
    beq		.mt_replay
    bsr		ep_Songend
.mt_replay
    movem.l	d0-d7/a0-a6,-(a7)
    bsr		mt_music
    movem.l	(a7)+,d0-d7/a0-a6
    rts


mt_music:
    addq.l	#1,mt_counter
    move.l	mt_tempo,d0
    cmp.l	mt_counter,d0
    bne.s	mt_notsix
    clr.l	mt_counter
    bra.w	mt_rout2

mt_notsix:
    lea		mt_aud1temp,a6
    tst.b	MT_PATTERN_EFF_PAR(a6)
    beq.s	mt_arp1
    move.l	#$dff0a0,a5
    bsr.s	mt_arprout

mt_arp1:
    lea		mt_aud2temp,a6
    tst.b	MT_PATTERN_EFF_PAR(a6)
    beq.s	mt_arp2
    move.l	#$dff0b0,a5
    bsr.s	mt_arprout

mt_arp2:
    lea		mt_aud3temp,a6
    tst.b	MT_PATTERN_EFF_PAR(a6)
    beq.s	mt_arp3
    move.l	#$dff0c0,a5
    bsr.s	mt_arprout

mt_arp3:
    lea		mt_aud4temp,a6
    tst.b	MT_PATTERN_EFF_PAR(a6)
    beq.s	mt_arp4
    move.l	#$dff0d0,a5
    bsr.s	mt_arprout
mt_arp4:
    bra.w	mt_stop


mt_arprout:
    tst.w	MT_PATTERN_E_COMMAND(a6)
    beq.s	mt_noslide

    clr.w	d0
    move.b	MT_PATTERN_E_PAR(a6),d0
    lsr.b	#4,d0
    tst.b	d0
    beq.s	mt_voldwn2
    bsr.w	mt_increase_volume
    bra.s	mt_noslide

mt_voldwn2:
    clr.w	d0
    move.b	MT_PATTERN_E_PAR(a6),d0
    bsr.w	mt_decrease_volume

mt_noslide:
    move.b	MT_PATTERN_EFF(a6),d0
    and.b	#$0f,d0
    tst.b	d0
    beq.w	mt_arpegrt
    cmp.b	#3,d0
    beq.w	mt_arpegrt
    cmp.b	#4,d0
    beq.w	mt_arpegrt
    cmp.b	#5,d0
    beq.w	mt_arpegrt
    cmp.b	#1,d0
    beq.s	mt_portup
    cmp.b	#6,d0
    beq.s	mt_portup
    cmp.b	#7,d0
    beq.s	mt_portup
    cmp.b	#8,d0
    beq.s	mt_portup
    cmp.b	#2,d0
    beq.s	mt_portdwn
    cmp.b	#9,d0
    beq.s	mt_portdwn
    cmp.b	#10,d0
    beq.s	mt_portdwn
    cmp.b	#11,d0
    beq.s	mt_portdwn
    cmp.b	#13,d0
    beq.s	mt_volup
    rts

mt_portup:
    clr.w	d0
    move.b	MT_PATTERN_EFF_PAR(a6),d0
    sub.w	d0,MT_PATTERN_DYN_PERIOD(a6)
    cmp.w	#$71,MT_PATTERN_DYN_PERIOD(a6)
    bpl.s	mt_ok1
    move.w	#$71,MT_PATTERN_DYN_PERIOD(a6)

mt_ok1:
    move.w	MT_PATTERN_DYN_PERIOD(a6),6(a5)
    rts

mt_portdwn:
    clr.w	d0
    move.b	MT_PATTERN_EFF_PAR(a6),d0
    add.w	d0,MT_PATTERN_DYN_PERIOD(a6)
    cmp.w	#$358,MT_PATTERN_DYN_PERIOD(a6)
    bmi.s	mt_ok2
    move.w	#$358,MT_PATTERN_DYN_PERIOD(a6)
mt_ok2:
    move.w	MT_PATTERN_DYN_PERIOD(a6),6(a5)
    rts

mt_volup:
    clr.w	d0
    move.b	MT_PATTERN_EFF_PAR(a6),d0
    lsr.b	#4,d0
    tst.b	d0
    beq.s	mt_voldwn
mt_increase_volume:
    add.w	d0,MT_PATTERN_VOL(a6)
    cmp.w	#$40,MT_PATTERN_VOL(a6)
    bmi.s	mt_ok3
    move.w	#$40,MT_PATTERN_VOL(a6)
mt_ok3:
    move.w	MT_PATTERN_VOL(a6),8(a5)
    rts

mt_voldwn:
    clr.w	d0
    move.b	MT_PATTERN_EFF_PAR(a6),d0
mt_decrease_volume:
    and.b	#$0f,d0
    sub.w	d0,MT_PATTERN_VOL(a6)
    bpl.s	mt_ok4
    clr.w	MT_PATTERN_VOL(a6)
mt_ok4:
    move.w	MT_PATTERN_VOL(a6),8(a5)
    rts

mt_arpegrt:
    cmp.l	#1,mt_counter
    beq.s	mt_loop2
    cmp.l	#2,mt_counter
    beq.s	mt_loop3
    cmp.l	#3,mt_counter
    beq.s	mt_loop4
    cmp.l	#4,mt_counter
    beq.s	mt_loop2
    cmp.l	#5,mt_counter
    beq.s	mt_loop3
    rts

mt_loop2:
    clr.l	d0
    move.b	MT_PATTERN_EFF_PAR(a6),d0
    lsr.b	#4,d0
    bra.s	mt_cont

mt_loop3:
    clr.l	d0
    move.b	MT_PATTERN_EFF_PAR(a6),d0
    and.b	#$0f,d0
    bra.s	mt_cont

mt_loop4:
    move.w	MT_PATTERN_ARPEGGIO_PAR(a6),d2
    bra.s	mt_endpart

mt_cont:
    lsl.w	#1,d0
    clr.l	d1
    move.w	MT_PATTERN_ARPEGGIO_PAR(a6),d1
    lea		mt_arpeggio,a0
mt_loop5:
    move.w	(a0,d0),d2
    cmp.w	(a0),d1
    beq.s	mt_endpart
    addq.l	#2,a0
    bra.s	mt_loop5

mt_endpart:
    move.w		d2,6(a5)
    rts

mt_rout2:
    move.l	mt_song,a0
    move.l	a0,a3
    add.l	#$0c,a3
    move.l	a0,a2
    add.l	#$1d8,a2
    add.l	#$258,a0
    move.l	mt_partnrplay,d0
    clr.l	d1
    move.b	(a2,d0),d1
    mulu	#$0400,d1
    add.l	mt_partnote,d1
    move.l	d1,mt_partpoint
    clr.w	mt_dmacon

    move.l	#$dff0a0,a5
    lea		mt_aud1temp,a6
    bsr.w	mt_playit

    move.l	#$dff0b0,a5
    lea		mt_aud2temp,a6
    bsr.w	mt_playit

    move.l	#$dff0c0,a5
    lea		mt_aud3temp,a6
    bsr.w	mt_playit

    move.l	#$dff0d0,a5
    lea		mt_aud4temp,a6
    bsr.w	mt_playit

mt_rls:
    movem.l	d0-d7/a0-a6,-(a7)
    move.l	delibase,a5
    move.l	dtg_WaitAudioDMA(a5),a0		; Function
    jsr	(a0)
    movem.l	(a7)+,d0-d7/a0-a6

    move.l	#$8000,d0
    add.w	mt_dmacon,d0
    move.w	d0,$dff096

    move.l	#mt_aud4temp,a6
    cmp.w	#1,MT_PATTERN_SAMPLE_LOOP_LEN(a6)
    bne.s	mt_voice3
    move.l	MT_PATTERN_SAMPLE_LOOP_PTR(a6),$dff0d0
    move.w	#1,$dff0d4
mt_voice3:
    move.l	#mt_aud3temp,a6
    cmp.w	#1,MT_PATTERN_SAMPLE_LOOP_LEN(a6)
    bne.s	mt_voice2
    move.l	MT_PATTERN_SAMPLE_LOOP_PTR(a6),$dff0c0
    move.w	#1,$dff0c4
mt_voice2:
    move.l	#mt_aud2temp,a6
    cmp.w	#1,MT_PATTERN_SAMPLE_LOOP_LEN(a6)
    bne.s	mt_voice1
    move.l	MT_PATTERN_SAMPLE_LOOP_PTR(a6),$dff0b0
    move.w	#1,$dff0b4
mt_voice1:
    move.l	#mt_aud1temp,a6
    cmp.w	#1,MT_PATTERN_SAMPLE_LOOP_LEN(a6)
    bne.s	mt_voice0
    move.l	MT_PATTERN_SAMPLE_LOOP_PTR(a6),$dff0a0
    move.w	#1,$dff0a4

mt_voice0:
    add.l       #16,mt_partnote
    move.l	mt_partnote,d0
    cmp.l	#$400,d0
    bne.s	mt_stop
    clr.l	mt_partnote
    addq.l	#1,mt_partnrplay
    clr.l	d0
    move.w	mt_maxpart,d0
    move.l	mt_partnrplay,d1
    cmp.l	d0,d1
    bne.s	mt_stop
    st		ep_Songendflag
    clr.l	mt_partnrplay
mt_stop:
    rts


mt_playit:
    move.l	(a0,d1),(a6)	* MT_PATTERN_PERIOD (use faster syntax)
    addq.l	#4,d1
    clr.l	d2
    move.b	MT_PATTERN_EFF(a6),d2
    and.b	#$f0,d2
    lsr.b	#4,d2
    tst.b	d2
    beq.s	mt_nosamplechange

    clr.l	d3
    lea		mt_sample_ptrs,a1
    move.l	d2,d4
    mulu	#4,d2
    mulu	#$1e,d4
    move.l	(a1,d2),MT_PATTERN_SAMPLE_PTR(a6)
    move.w	(a3,d4),MT_PATTERN_SAMPLE_LEN(a6)
    move.w	2(a3,d4),MT_PATTERN_VOL(a6)
    move.w	4(a3,d4),d3
    tst.w	d3
    beq.s	mt_displace
    move.l	MT_PATTERN_SAMPLE_PTR(a6),d2
    add.l	d3,d2
    move.l	d2,MT_PATTERN_SAMPLE_PTR(a6)
    move.l	d2,MT_PATTERN_SAMPLE_LOOP_PTR(a6)
    move.w	6(a3,d4),MT_PATTERN_SAMPLE_LEN(a6)
    move.w	6(a3,d4),MT_PATTERN_SAMPLE_LOOP_LEN(a6)
    move.w	MT_PATTERN_VOL(a6),8(a5)
    bra.s	mt_nosamplechange
mt_displace:
    * Loops the sample from the same place. Possibly with a length of 1.
    move.l	MT_PATTERN_SAMPLE_PTR(a6),d2
    add.l	d3,d2
    move.l	d2,MT_PATTERN_SAMPLE_LOOP_PTR(a6)
    move.w	6(a3,d4),MT_PATTERN_SAMPLE_LOOP_LEN(a6)
    move.w	MT_PATTERN_VOL(a6),8(a5)
mt_nosamplechange:
    tst.w	(a6)
    beq.s	mt_retrout
    move.w	(a6),MT_PATTERN_ARPEGGIO_PAR(a6)
    move.w	MT_PATTERN_DMA_MASK(a6),$dff096
    move.l	MT_PATTERN_SAMPLE_PTR(a6),(a5)
    move.w	MT_PATTERN_SAMPLE_LEN(a6),4(a5)
    move.w	(a6),6(a5)
    move.w	MT_PATTERN_DMA_MASK(a6),d0
    or.w	d0,mt_dmacon

mt_retrout:
    move.w	MT_PATTERN_DMA_MASK(a6),d0
    lsl.w	#4,d0
    add.w	MT_PATTERN_DMA_MASK(a6),d0
    move.w	d0,$dff09e

    tst.w	(a6)
    beq.s	mt_nonewper
    move.w	(a6),MT_PATTERN_DYN_PERIOD(a6)
mt_nonewper:

    move.b	MT_PATTERN_EFF(a6),d0
    and.b	#$0f,d0
    cmp.b	#CMD_E,d0
    beq.s	mt_e_command
    cmp.b	#15,d0
    bne.s	mt_noset

    move.w	MT_PATTERN_EFF(a6),d0
    and.l	#$f,d0
    move.l	d0,mt_tempo
    rts

mt_e_command:
    move.w	MT_PATTERN_EFF(a6),MT_PATTERN_E_COMMAND(a6)
    rts

mt_noset:
    tst.b	MT_PATTERN_EFF_PAR(a6)
    bne.s	mt_noclr
    clr.w	MT_PATTERN_E_COMMAND(a6)
mt_noclr:
    cmp.b	#3,d0
    beq.s	mt_modulate_volume
    cmp.b	#6,d0
    beq.s	mt_modulate_volume
    cmp.b	#9,d0
    beq.s	mt_modulate_volume
    cmp.b	#4,d0
    beq.s	mt_modulate_period
    cmp.b	#7,d0
    beq.s	mt_modulate_period
    cmp.b	#10,d0
    beq.s	mt_modulate_period
    cmp.b	#5,d0
    beq.s	mt_modulate_volume_and_period
    cmp.b	#8,d0
    beq.s	mt_modulate_volume_and_period
    cmp.b	#11,d0
    beq.s	mt_modulate_volume_and_period
    cmp.b	#CMD_VOL,d0
    bne.s	mt_nochnge
    move.b	MT_PATTERN_EFF_PAR(a6),8(a5)
mt_nochnge:
    rts

mt_modulate_volume:
    move.w	MT_PATTERN_DMA_MASK(a6),d0
    bra.s	mt_push

mt_modulate_period:
    move.w	MT_PATTERN_DMA_MASK(a6),d0
    lsl.w	#4,d0
    bra.s	mt_push

mt_modulate_volume_and_period:
    move.w	MT_PATTERN_DMA_MASK(a6),d0
    lsl.w	#4,d0
    add.w	MT_PATTERN_DMA_MASK(a6),d0

mt_push:
    add.w	#$8000,d0
    move.w	d0,$dff09e
    rts

	incdir "amiga:work/players/tracker/common/"
;	include	"mod_check.s"   ; no longer compiles with this and amifilemagic should have done the magic already
	include	"ep_misc.s"

* Each mt_audXtemp structure has size MT_PATTERN_SIZE
mt_aud1temp:	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w $0000,$0000,$0001,$0000,$0000
mt_aud2temp:	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w $0000,$0000,$0002,$0000,$0000
mt_aud3temp:	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w $0000,$0000,$0004,$0000,$0000
mt_aud4temp:	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		dc.w $0000,$0000,$0008,$0000,$0000
mt_partnote: 	dc.l 0
mt_partnrplay:	dc.l 0
mt_counter:	dc.l 0
mt_tempo:	dc.l 6
mt_partpoint:	dc.l 0

* mt_samples_ptrs is index by values 1 to 15.
* The first dc.l is for unused sample number 0.
mt_sample_ptrs:
	dc.l 0
	dcb.l 15,0

mt_maxpart:	dc.w $0000
mt_kn1:		dc.w $0000
mt_dmacon:	dc.w $0000

mt_arpeggio:
		dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
		dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
		dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
		dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
		dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000

mt_song		dc.l	0
