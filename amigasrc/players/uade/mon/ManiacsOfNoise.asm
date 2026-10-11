;               T

	include	custom.i
	include	rmacros.i
	include	misc/DeliPlayer.i
	include exec_lib.i

CHANNEL_POSITION_SIZE	equ	12
UadeSongEndHelperStep	equ	-30	* uade.library

	section	monplayer,code
	moveq	#-1,d0
	rts
	dc.b	'DELIRIUM'
	dc.l	table
	dc.b	'$VER: MON player module V0.1 for UADE (01.01.2002)',0
	dc.b	'$COPYRIGHT: Heikki Orsila <heikki.orsila@tut.fi>',0
	dc.b	'$LICENSE: GNU LGPL',0
	even

table	dc.l	DTP_PlayerName,monplayer
	dc.l	DTP_Creator,moncreator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_Volume,Volume
	dc.l	$80004474,2			* songend support
	dc.l	0
monplayer	dc.b	'MON',0
moncreator	dc.b	'MON player for UADE by shd (based on replayer by '
	dc.b	'Frederick Hahn and Maniacs of Noise/Charles Deenen)',0
uadename	dc.b	'uade.library',0
	even

format_variant_constants
	* Format variant 0
	dc	72	* state offset
	dc	84	* per channel state size
	dc	$24	* channel offset: number of frames to next song pos
	dc	$3d	* channel offset: pattern repeat counter
	* Format variant 1
	dc	32	* state offset
	dc	64	* per channel state size
	dc	$1c	* channel offset: number of frames to next song pos
	dc	$32	* channel offset: pattern repeat counter
	* Format variant 2
	dc	56	* state offset
	dc	64	* per channel state size
	dc	$1c	* channel offset: number of frames to next song pos
	dc	$32	* channel offset: pattern repeat counter

Check2	move.l	dtg_ChkData(a5),a0
	move.l	a0,modptr
	move.l	a5,delibase
	moveq	#-1,d0
	move	#$4efa,d1
	cmp	(a0),d1
	bne.w	endcheck2
	cmp	4(a0),d1
	bne.w	endcheck2
	cmp	8(a0),d1
	bne.w	endcheck2

	move	2(a0),d1        * init routine offset - 2
	lea	2(a0,d1),a1

	move	8(a1),d1
	moveq	#0,d2
	cmp	#$19a,d1
	beq.b	.format_done
	cmp	#$122,d1
	bne.b	.not_format_1
	moveq	#1,d2
	bra.b	.format_done
.not_format_1:
	cmp	#$13a,d1
	bne.b	.format_done
	moveq	#2,d2
.format_done
	move	d2,format_variant

	cmp	#$4bfa,(a1)
	bne.b	endcheck2
	cmp.l	#$08ad0000,4(a1)
	bne.b	endcheck2
	move	2(a1),d1
	lea	2(a1,d1),a1
	move.l	a1,structptr

	* Beginning of player state is stored in structptr.
        *
	* The data layout for format_variant == 0 is:
	* - 72 bytes of generic state
	* - 4 x 84 bytes of per channel state
	*
	* Channel state has the following layout:
	* - Offset 0: Track start pointer
	* - Offset 4: Track pointer
	* - Offset 8: Pattern start position pointer
	* - Offset 12: Pattern position pointer
	* - Offset 0x24: Counter for number of frames until next song pos
        *                (word). down to 1. Wraps at 1 so that 1 is observed
	*                but 0 is not.
	* - Offset 0x3d: Pattern repeat counter (byte).
	*                Wraps at 1 so that 1 is observed but 0 is not.
	*
	* format_variatn == 1 layout:
	* - 32 bytes of generic state
	* - 4 x 64 bytes of per channel state
	*
	* Format 2 layout:
	* - 56 bytes of generic state
	* - 4 x 64 bytes of per channel state

	move	10(a0),d2
	lea	10(a0,d2),a2
	cmp	#$b02d,$16(a2)
	bne.b	nomaxsub
	moveq	#0,d1
	move	$18(a2),d2
	move.b	(a1,d2),d1
	move.l	d1,maxsubsong
nomaxsub	moveq	#0,d0			* ok, it's mon, i think ;-)
endcheck2	rts

SubSongRange	moveq	#1,D0
	move.l	maxsubsong,d1
	rts


InitPlayer	push	all
	move.l	dtg_AudioAlloc(a5),A0
	jsr	(A0)
	moveq	#0,d0
	move.l	modptr,a0
	jsr	(a0)
	move.l	a1,volumeptr

	* Note: the player should work without uade.library,
	* but song end detection does not.
	move.l	4.w,a6
	lea	uadename(pc),a1
	moveq	#0,d0
	jsr	OpenLibrary(a6)
	move.l	d0,uadebase

	pull	all
	moveq	#0,d0
	rts

InitSound	push	all
	moveq	#0,d0
	move.l	modptr,a0
	jsr	(a0)
        movem.l (a7),d0-d7/a0-a6
	moveq	#0,d0
	move	dtg_SndNum(a5),d0
	moveq	#0,d1
	move.l	modptr,a0
	jsr	8(a0)
	pull	all
	bra	Volume

Interrupt	push	all
	move.l	uadebase(pc),d0
	beq	.no_uade_lib
	* Generate a state tuple for the song position that uniquely identifies
	* a point in time during playback. When the same state tuple is
	* encountered twice, the song has looped and we can end it.
	* The uade.library is used to report 
	move.l	d0,a6
	move.l	structptr(pc),a0
	lea	song_position_data,a1
	moveq	#4-1,d7
	lea	format_variant_constants,a2
	move	format_variant(pc),d0
	lsl	#3,d0
	add	d0,a2
	add	(a2),a0		* offset to beginning of per channel state
	move	4(a2),d1	* offset of counter of frames to next song pos
	move	6(a2),d2	* offset of pattern repeat
.song_end_loop_0:
	move.l	4(a0),d0
	sub.l	(a0),d0
	move.l	d0,(a1)+	* track index
	move.l	12(a0),d0
	sub.l	8(a0),d0
	move.l	d0,(a1)+	* pattern position index
	move	(a0,d1),(a1)+	* frames until next song pos
	move.b	(a0,d2),(a1)+	* pattern repeat counter
	clr.b   (a1)+
	add	2(a2),a0
	dbf	d7,.song_end_loop_0

	lea	song_position_data,a0
	moveq	#4*CHANNEL_POSITION_SIZE,d0
	jsr	UadeSongEndHelperStep(a6)
	tst     d0
	beq.b   .no_uade_lib
	push    all
	move.l	delibase(pc),a5
	move.l	dtg_SongEnd(a5),a0
	jsr	(a0)
	pull    all
.no_uade_lib

	* call interrupt
	move.l	modptr(pc),a0
	jsr	4(a0)
	pull	all
	rts

Volume	push	all
	move.l	volumeptr,a0
	move	dtg_SndVol(a5),d0
	move	d0,(a0)
	pull	all
	rts

EndSound	push	all
	move.l	modptr,a0
	moveq	#0,d0
	moveq	#0,d1
	jsr	8(a0)
	lea	$dff000,a2
	moveq	#0,d0
	move	d0,aud0vol(a2)
	move	d0,aud1vol(a2)
	move	d0,aud2vol(a2)
	move	d0,aud3vol(a2)
	move	#$000f,dmacon(a2)
	pull	all
	rts

EndPlayer	move.l	dtg_AudioFree(a5),A0
	jsr	(a0)
	rts

modptr	dc.l	0
maxsubsong	dc.l	0
delibase	dc.l	0
structptr	dc.l	0
volumeptr	dc.l	0
uadebase	dc.l	0
* Identifies the type of maniacs of noise song file.
* valid values are: 0, 1, 2. This is used as an index to 
* format_variant_constants array.
format_variant      dc      0

	section bss,bss
song_position_data
	ds.b	4*CHANNEL_POSITION_SIZE

	end
