	include	custom.i
	include	rmacros.i
	include	exec_lib.i
	include	misc/DeliPlayer.i

	section	hipcplayer,code_c
	moveq	#-1,d0
	rts
	dc.b	'DELIRIUM'
	dc.l	table
	dc.b	'NO NO... UADE TEAM',0
	dc.b	'$VER: hipc player module V0.2 for UADE (17.02.2003)',0
	even

table	dc.l	DTP_PlayerName,hipcname
	dc.l	DTP_Creator,hipccreator
	dc.l	DTP_Check2,Check2
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_EndSound,EndSound
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_DeliBase,delibase
	dc.l	$80004474,2			* songend support
	dc.l	0
hipcname	dc.b	'Hippel-COSO',0
hipccreator	dc.b	'Hippel-COSO player by Jochen Hippel,',10
	dc.b	'Adapted for UADE by shd',0
uadename	dc.b	'uade.library',0
weirdentry	dc.b	'illegal jump table index in hippel-coso player',0
	even

openuade	push	all
	move.l	uadebase,d0
	bne.b	lib_opened
	lea	uadename(pc),a1
	moveq	#0,d0
	move.l	4.w,a6
	call	OpenLibrary
	move.l	d0,uadebase
lib_opened	pull	all
	rts

* message in a0
dispstring	bsr	openuade
	push	d0/a6
	move.l	uadebase,d0
	beq.b	not_opened_1
	move.l	d0,a6
	jsr	-12(a6)			* display string
not_opened_1	pull	d0/a6
	rts

Check2	move.l	dtg_ChkData(a5),a0
	moveq	#-1,d0
	cmp.l	#'COSO',(a0)
	bne.b	endcheck2
	cmp.l	#'TFMX',$20(a0)
	bne.b	endcheck2
	move.l	$14(a0),d1
	move.l	$18(a0),d2
	sub.l	d1,d2
	divu	#6,d2
	ext.l	d2
	subq.l	#1,d2
	move.l	d2,maxsubsong
	moveq	#0,d0			* ok, it's hipc, i think ;-)
endcheck2	rts


SubSongRange	moveq	#1,D0
	move.l	maxsubsong,d1
	rts

* a0 src a1 dst d0 bytes
memcpy	tst.l	d0
	bne.b	memcpy_nonzero
	rts
memcpy_nonzero	push	d0/a0/a1
memcpy_l	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.b	memcpy_l
	pull	d0/a0/a1
	rts

* a0 string returns the zero byte in a0
strendptr	tst.b	(a0)+
	bne.b	strendptr
	subq.l	#1,a0
	rts

strrchr	push	d1-d7/a0-a6
	move.l	a0,a1
	bsr	strendptr
	move.l	d0,d1
	moveq	#0,d0
strchr_l	cmp.l	a0,a1
	beq.b	strchr_e
	cmp.b	-(a0),d1
	bne.b	strchr_l
	move.l	a0,d0
strchr_e	pull	d1-d7/a0-a6
	tst.l	d0
	rts

full_name_to_array
	move.l	dtg_PathArrayPtr(a5),a0
	clr.b	(a0)
	move.l	dtg_CopyDir(a5),a0
	jsr	(a0)
	move.l	dtg_CopyFile(a5),a0
	jsr	(a0)
	rts

InitPlayer	moveq	#0,d0
	move.l	dtg_GetListData(a5),a0
	jsr	(a0)
	move.l	a0,modptr
	move.l	a0,finalmodptr
	move.l	d0,modsize
	move.l	$1c(a0),d1
	cmp.l	d0,d1
	blt	no_load

	bsr	full_name_to_array
	move.l	dtg_PathArrayPtr(a5),a0
	move.b	#'.',d0
	bsr	strrchr
	tst.l	d0
	beq.b	next_name_variation
	move.l	d0,a0
	clr.b	(a0)
	lea	samplepostfix,a0
	move.l	dtg_CopyString(a5),a1
	jsr	(a1)
	move.l	dtg_LoadFile(a5),a0
	jsr	(a0)
	tst.l	d0
	beq.b	samples_loaded

next_name_variation
	bsr	full_name_to_array
	lea	samplepostfix,a0
	move.l	dtg_CopyString(a5),a1
	jsr	(a1)
	move.l	dtg_LoadFile(a5),a0
	jsr	(a0)
	tst.l	d0
	beq.b	samples_loaded
	lea	nosamplefile,a0
	bsr	dispstring
	bra	no_load
samples_loaded
	moveq	#1,d0
	move.l	dtg_GetListData(a5),a0
	jsr	(a0)
	move.l	a0,sampleptr
	move.l	d0,samplesize
	add.l	modsize,d0
	moveq	#2,d1
	move.l	4.w,a6
	call	AllocMem
	tst.l	d0
	bne.b	mem_allocated
	lea	nomem,a0
	bsr	dispstring
	bra.b	no_load
mem_allocated	move.l	d0,finalmodptr
	move.l	modptr,a0
	move.l	finalmodptr,a1
	move.l	modsize,d0
	bsr	memcpy			* copy song data
	move.l	sampleptr,a0
	move.l	finalmodptr,a1
	add.l	$1c(a1),a1		* sample offset
	move.l	samplesize,d0
	bsr	memcpy			* copy sample data
no_load	move.l	dtg_AudioAlloc(a5),A0
	jmp	(A0)

InitSound	push	all
	moveq	#0,d0
	move	dtg_SndNum(a5),d0
	move.l	finalmodptr,a0
	jsr	hipc_init
	pull	all
	rts

Interrupt	push	all
	jsr	hipc_int
	pull	all
	rts

SongEndFunc	push	all
	move.l	delibase(pc),a5
	move.l	dtg_SongEnd(a5),a0
	jsr	(a0)
	pull	all
	rts

EndSound	push	all
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

check_table_jump
	cmp	#10,d0
	blt.b	jump_ok
	push	all
	lea	weirdentry(pc),a0
	bsr	dispstring
	pull	all
jump_ok	rts

modptr	dc.l	0
modsize	dc.l	0
sampleptr	dc.l	0
samplesize	dc.l	0
finalmodptr	dc.l	0
maxsubsong	dc.l	0
delibase	dc.l	0
uadebase	dc.l	0
samplepostfix	dc.b	'.samp',0
nomem	dc.b	'not enough memory for hippel-coso',0
nosamplefile	dc.b	'couldnt load the sample file for hippel-coso',0
	even

	include	hipccode.asm
