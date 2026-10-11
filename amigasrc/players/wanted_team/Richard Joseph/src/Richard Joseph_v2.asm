	*****************************************************
	****   Richard Joseph replayer for EaglePlayer,  ****
	****        all adaptions by Wanted Team	 ****
	****     DeliTracker 2.32 compatible version	 ****
	*****************************************************

	incdir	"dh2:include/"
	include "misc/eagleplayer2.01.i"
	include "hardware/intbits.i"
	include "exec/exec_lib.i"
	include	"dos/dos_lib.i"

	SECTION	Player,CODE

	PLAYERHEADER Tags

	dc.b	'$VER: Richard Joseph player module V1.1 (1 Oct 2012)',0
	even
Tags
	dc.l	DTP_PlayerVersion,2
	dc.l	EP_PlayerVersion,9
	dc.l	DTP_RequestDTVersion,'WT'
	dc.l	DTP_PlayerName,PlayerName
	dc.l	DTP_Creator,Creator
	dc.l	DTP_DeliBase,DeliBase
	dc.l	DTP_Check1,Check1
	dc.l	EP_Check3,Check3
	dc.l	DTP_Interrupt,Interrupt
	dc.l	DTP_SubSongRange,SubSongRange
	dc.l	DTP_InitPlayer,InitPlayer
	dc.l	DTP_EndPlayer,EndPlayer
	dc.l	DTP_InitSound,InitSound
	dc.l	DTP_EndSound,EndSound
	dc.l	EP_Get_ModuleInfo,GetInfos
	dc.l	EP_SampleInit,SampleInit
	dc.l	EP_ModuleChange,ModuleChange
	dc.l	DTP_Volume,SetVolume
	dc.l	DTP_Balance,SetBalance
	dc.l	EP_Voices,SetVoices
	dc.l	EP_StructInit,StructInit
	dc.l	EP_Flags,EPB_Volume!EPB_Balance!EPB_ModuleInfo!EPB_Voices!EPB_SampleInfo!EPB_Songend!EPB_Analyzer!EPB_Restart!EPB_NextSong!EPB_PrevSong
	dc.l	TAG_DONE
PlayerName
	dc.b	'Richard Joseph',0
Creator
	dc.b	'(c) 1989-92 by Richard Joseph,',10
	dc.b	'adapted by Wanted Team',0
Prefix
	dc.b	'RJ.',0
	even
DeliBase
	dc.l	0
ModulePtr
	dc.l	0
PlayPtr
	dc.l	0
AudioPtr
	dc.l	0
InitPlayerPtr
	dc.l	0
InitSongPtr
	dc.l	0
SampleInfoPtr
	dc.l	0
EndSampleInfoPtr
	dc.l	0
Change
	dc.w	0
EagleBase
	dc.l	0
VoicesBase
	dc.l	0
SongEnd
	dc.l	'WTWT'
SongEndTemp
	dc.l	0
Intena
	dc.w	0
Intreq
	dc.w	0
RightVolume
	dc.w	64
LeftVolume
	dc.w	64
Voice1
	dc.w	-1
Voice2
	dc.w	-1
Voice3
	dc.w	-1
Voice4
	dc.w	-1
StructAdr
	ds.b	UPS_SizeOF

***************************************************************************
**************************** EP_ModuleChange ******************************
***************************************************************************

ModuleChange
	move.w	Change(PC),D0
	bne.s	NoChange
	move.l	PlayPtr(PC),EPG_ARG1(A5)
	lea	PatchTable(PC),A1
	move.l	A1,EPG_ARG3(A5)
	move.l	#2100,D1
	move.l	D1,EPG_ARG2(A5)
	moveq	#-2,D0
	move.l	D0,EPG_ARG5(A5)		
	moveq	#1,D0
	move.l	D0,EPG_ARG4(A5)			;Search-Modus
	moveq	#5,D0
	move.l	D0,EPG_ARGN(A5)
	move.l	EPG_ModuleChange(A5),A0
	jsr	(A0)
NoChange
	move.w	#1,Change
	moveq	#0,D0
	rts

***************************************************************************
******************** DTP_Volume DTP_Balance *******************************
***************************************************************************

SetVolume
SetBalance
	move.w	dtg_SndLBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0

	move.w	D0,LeftVolume

	move.w	dtg_SndRBal(A5),D0
	mulu.w	dtg_SndVol(A5),D0
	lsr.w	#6,D0

	move.w	D0,RightVolume
	moveq	#0,D0
	rts

ChangeVolume
	move.l	D1,-(A7)
	and.w	#$7F,D0
	move.l	A5,D1
	cmp.w	#$F0A0,D1
	beq.s	Left1
	cmp.w	#$F0B0,D1
	beq.s	Right1
	cmp.w	#$F0C0,D1
	beq.s	Right2
	cmp.w	#$F0D0,D1
	bne.s	Exit2
Left2
	mulu.w	LeftVolume(PC),D0
	and.w	Voice4(PC),D0
	bra.s	Ex
Left1
	mulu.w	LeftVolume(PC),D0
	and.w	Voice1(PC),D0
	bra.s	Ex

Right1
	mulu.w	RightVolume(PC),D0
	and.w	Voice2(PC),D0
	bra.s	Ex
Right2
	mulu.w	RightVolume(PC),D0
	and.w	Voice3(PC),D0
Ex
	lsr.w	#6,D0
	move.w	D0,8(A5)
Exit2
	move.l	(A7)+,D1
	rts

*------------------------------- Set Vol -------------------------------*

SetVol
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Vol(PC),A0
	cmp.l	#$DFF0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Vol(PC),A0
	cmp.l	#$DFF0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Vol(PC),A0
	cmp.l	#$DFF0C0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Vol(PC),A0
.SetVoice
	move.w	D0,(A0)
	move.l	(A7)+,A0
	rts

*------------------------------- Set All -------------------------------*

SetAll
	move.l	A0,-(A7)
	lea	StructAdr+UPS_Voice1Adr(PC),A0
	cmp.l	#$DFF0A0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice2Adr(PC),A0
	cmp.l	#$DFF0B0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice3Adr(PC),A0
	cmp.l	#$DFF0C0,A5
	beq.s	.SetVoice
	lea	StructAdr+UPS_Voice4Adr(PC),A0
.SetVoice
	move.l	$1C(A4),(A0)
	move.w	$28(A4),UPS_Voice1Len(A0)
	move.w	$46(A4),UPS_Voice1Per(A0)
	move.l	(A7)+,A0
	rts

***************************************************************************
****************************** EP_Voices  *********************************
***************************************************************************

SetVoices
	lea	Voice1(PC),A0
	lea	StructAdr(PC),A1
	move.w	#$FFFF,D1
	move.w	D1,(A0)+			Voice1=0 setzen
	btst	#0,D0
	bne.s	.NoVoice1
	clr.w	-2(A0)
	clr.w	$DFF0A8
	clr.w	UPS_Voice1Vol(A1)
.NoVoice1
	move.w	D1,(A0)+			Voice2=0 setzen
	btst	#1,D0
	bne.s	.NoVoice2
	clr.w	-2(A0)
	clr.w	$DFF0B8
	clr.w	UPS_Voice2Vol(A1)
.NoVoice2
	move.w	D1,(A0)+			Voice3=0 setzen
	btst	#2,D0
	bne.s	.NoVoice3
	clr.w	-2(A0)
	clr.w	$DFF0C8
	clr.w	UPS_Voice3Vol(A1)
.NoVoice3
	move.w	D1,(A0)+			Voice4=0 setzen
	btst	#3,D0
	bne.s	.NoVoice4
	clr.w	-2(A0)
	clr.w	$DFF0D8
	clr.w	UPS_Voice4Vol(A1)
.NoVoice4
	move.w	D0,UPS_DMACon(A1)
	moveq	#0,D0
	rts

***************************************************************************
******************************* EP_StructInit *****************************
***************************************************************************

StructInit
	lea	StructAdr(PC),A0
	rts

***************************************************************************
******************************* EP_SampleInit *****************************
***************************************************************************

SampleInit
	moveq	#EPR_NotEnoughMem,D7
	lea	EPG_SampleInfoStructure(A5),A3
	move.l	SampleInfoPtr(PC),D0
	beq.b	return
	move.l	D0,A0

	move.l	InfoBuffer+Samples(PC),D5
	beq.b	return
	subq.l	#1,D5
hop
	jsr	ENPP_AllocSampleStruct(A5)
	move.l	D0,(A3)
	beq.b	return
	move.l	D0,A3

	addq.l	#4,A0
	moveq	#0,D0
	move.w	(A0)+,D0
	lsl.l	#1,D0
	move.l	(A0)+,D2
	beq.b	SkipInfo
	move.l	D2,A1
	cmp.b	#'F',-104(A1)
	bne.b	NoIFF
	cmp.b	#'O',-103(A1)
	bne.b	NoIFF
	cmp.b	#'R',-102(A1)
	bne.b	NoIFF
	cmp.b	#'M',-101(A1)
	bne.b	NoIFF
	moveq	#104,D1
	add.l	D1,D0
	sub.l	D1,A1
	lea	48(A1),A2
	move.l	A2,EPS_SampleName(A3)
	move.w	#20,EPS_MaxNameLen(A3)
NoIFF
	move.l	A1,EPS_Adr(A3)			; sample address
	move.l	D0,EPS_Length(A3)		; sample length
	move.l	#64,EPS_Volume(A3)
	move.w	#USITY_RAW,EPS_Type(A3)
	move.w	#USIB_Playable!USIB_Saveable!USIB_8BIT,EPS_Flags(A3)
SkipInfo
	addq.l	#4,A0
	dbf	D5,hop

	moveq	#0,D7
return
	move.l	D7,D0
	rts

***************************************************************************
******************************** DTP_Check1 *******************************
***************************************************************************

Check1
	move.l	DeliBase(PC),D0
	beq.b	fail

***************************************************************************
******************************* EP_Check3 *********************************
***************************************************************************

Check3
	movea.l	dtg_ChkData(A5),A0

	cmp.l	#$000003F3,(A0)
	bne.b	fail
	tst.b	20(A0)				; loading into chip check
	beq.b	fail
	lea	32(A0),A0
	cmp.l	#$70FF4E75,(A0)+
	bne.b	fail
	cmp.l	#'R.JO',(A0)+
	bne.b	fail
	cmp.l	#'SEPH',(A0)+
	bne.b	fail
	tst.l	(A0)+				; Interrupt pointer check
	beq.b	fail
	tst.l	(A0)+				; Audio Interrupt pointer check
	beq.b	fail
	tst.l	(A0)+				; InitPlayer pointer check
	beq.b	fail
	tst.l	(A0)				; InitSong pointer check
	beq.b	fail

	moveq	#0,D0
	rts
fail
	moveq	#-1,D0
	rts

***************************************************************************
***************************** EP_Get_ModuleInfo ***************************
***************************************************************************

GetInfos
	lea	InfoBuffer(PC),A0
	rts

SubSongs	=	4
LoadSize	=	12
SongSize	=	20
SamplesSize	=	28
Samples		=	36
CalcSize	=	44
SpecialInfo	=	52
AuthorName	=	60
SongName	=	68
Voices		=	76

InfoBuffer
	dc.l	MI_SubSongs,0		;4
	dc.l	MI_LoadSize,0		;12
	dc.l	MI_Songsize,0		;20
	dc.l	MI_SamplesSize,0	;28
	dc.l	MI_Samples,0		;36
	dc.l	MI_Calcsize,0		;44
	dc.l	MI_SpecialInfo,0	;52
	dc.l	MI_AuthorName,0		;60
	dc.l	MI_SongName,0		;68
	dc.l	MI_Voices,0		;76
	dc.l	MI_MaxVoices,4
	dc.l	MI_Prefix,Prefix
	dc.l	0

***************************************************************************
***************************** DTP_Intterrupt ******************************
***************************************************************************

Interrupt	
	movem.l	D0-D7/A0-A6,-(SP)

	lea	StructAdr(PC),A0
	st	UPS_Enabled(A0)
	clr.w	UPS_Voice1Per(A0)
	clr.w	UPS_Voice2Per(A0)
	clr.w	UPS_Voice3Per(A0)
	clr.w	UPS_Voice4Per(A0)
	move.w	#UPSB_Adr!UPSB_Len!UPSB_Per!UPSB_Vol,UPS_Flags(A0)

	move.l	PlayPtr(PC),A0
	jsr	(A0)				; play module

	lea	StructAdr(PC),A0
	clr.w	UPS_Enabled(A0)

	movem.l	(SP)+,D0-D7/A0-A6
	rts

DMAWait
	movem.l	D0/D1,-(SP)
	moveq	#8,D0
.dma1	move.b	$DFF006,D1
.dma2	cmp.b	$DFF006,D1
	beq.b	.dma2
	dbeq	D0,.dma1
	movem.l	(SP)+,D0/D1
	rts

Audio
	bsr.b	DMAWait
	movem.l	D0-D1/A0-A3,-(SP)
	move.l	VoicesBase(PC),A3
	lea	$DFF000,A0
	move.w	Intreq(PC),D0
	and.w	Intena(PC),D0
	btst	#7,D0
	beq.b	Second
	move.l	(A3),A1
	bsr.b	Main
Second
	move.w	Intreq(PC),D0
	and.w	Intena(PC),D0
	btst	#8,D0
	beq.b	Third
	move.l	4(A3),A1
	bsr.b	Main
Third
	move.w	Intreq(PC),D0
	and.w	Intena(PC),D0
	btst	#9,D0
	beq.b	Fourth
	move.l	8(A3),A1
	bsr.b	Main
Fourth
	move.w	Intreq(PC),D0
	and.w	Intena(PC),D0
	btst	#10,D0
	beq.b	Quit
	move.l	12(A3),A1
	bsr.b	Main
Quit
	movem.l	(SP)+,D0-D1/A0-A3
	clr.w	Intreq
	rts

Main
	move.l	8(A1),A2
	subq.w	#1,14(A1)
	tst.w	$24(A1)
	bpl.b	NoLoop
	moveq	#0,D0
	move.w	$26(A1),D0
	move.w	D0,D1
	add.l	$1C(A1),D0
	move.l	D0,(A2)
	move.w	$28(A1),D0
	lsr.w	#1,D1
	sub.w	D1,D0
	move.w	D0,4(A2)
	move.w	6(A1),Intena
	bra.b	QuitMain

NoLoop
	tst.w	14(A1)
	bne.b	SetEmpty
	move.w	6(A1),Intena
	move.w	2(A1),$96(A0)
	bra.b	QuitMain

SetEmpty
	move.l	ModulePtr(PC),(A2)
	move.w	#1,4(A2)
QuitMain
	move.w	6(A1),Intreq
	rts

***************************************************************************
***************************** DTP_SubSongRange ****************************
***************************************************************************

SubSongRange	
	moveq	#1,D0
	move.l	InfoBuffer+SubSongs(PC),D1
	rts

***************************************************************************
***************************** DTP_InitPlayer ******************************
***************************************************************************

InitPlayer
	move.l	dtg_DOSBase(A5),A6
	move.l	dtg_PathArrayPtr(A5),D1
	jsr	_LVOLoadSeg(A6)
	lsl.l	#2,D0
	beq.w	InitFail
	addq.l	#4,D0
	move.l	D0,A0				; module address
	lea	ModulePtr(PC),A1
	move.l	D0,(A1)+
	clr.l	(A0)+				; Empty sample
	addq.l	#8,A0
	move.l	(A0)+,(A1)+			; Play pointer
	move.l	(A0)+,(A1)+			; Audio Interrupt pointer
	move.l	(A0)+,(A1)+			; InitPlayer pointer
	move.l	(A0)+,(A1)+			; InitSong pointer
	move.l	(A0)+,(A1)+			; SampleInfo pointer
	move.l	(A0)+,(A1)+			; EndSampleInfo pointer

	clr.w	(A1)+				; Change
	move.l	A5,(A1)+			; EagleBase

	lea	InfoBuffer(PC),A2
	move.l	(A0)+,SongName(A2)
	move.l	(A0)+,AuthorName(A2)
	move.l	(A0)+,SpecialInfo(A2)
	move.l	(A0)+,LoadSize(A2)
	move.l	(A0)+,CalcSize(A2)
	move.l	(A0)+,SamplesSize(A2)
	move.l	(A0)+,SongSize(A2)
	move.l	(A0),D0
	beq.b	InFile
	move.l	D0,SubSongs(A2)

	move.l	EndSampleInfoPtr(PC),D1
	sub.l	SampleInfoPtr(PC),D1
	divu.w	#14,D1
	move.l	D1,Samples(A2)

	move.l	InitSongPtr(PC),A2
Find
	cmp.w	#$287B,(A2)+
	bne.b	Find
	move.w	(A2),D0
	ext.w	D0
	add.w	D0,A2
	move.l	A2,(A1)
	bsr.w	ModuleChange

	movea.l	dtg_AudioAlloc(A5),A0
	jmp	(A0)

InitFail
	moveq	#EPR_NotEnoughMem,D0
	rts

InFile
	bsr.b	Free
	moveq	#EPR_ErrorInFile,D0
	rts

***************************************************************************
***************************** DTP_EndPlayer *******************************
***************************************************************************

EndPlayer
	bsr.b	Free
	move.l	dtg_AudioFree(A5),A0
	jmp	(A0)

Free
	move.l	dtg_DOSBase(A5),A6
	move.l	ModulePtr(PC),D1
	subq.l	#4,D1
	lsr.l	#2,D1
	jmp	_LVOUnLoadSeg(A6)

***************************************************************************
***************************** DTP_InitSound *******************************
***************************************************************************

InitSound
	lea	StructAdr(PC),A0
	lea	UPS_SizeOF(A0),A1
ClearUPS
	clr.w	(A0)+
	cmp.l	A0,A1
	bne.b	ClearUPS
	lea	SongEnd(PC),A1
	move.l	#'WTWT',(A1)
	move.l	InitPlayerPtr(PC),A0
	jsr	(A0)
	moveq	#0,D0
	move.w	dtg_SndNum(A5),D0
	move.l	D0,D1
	lsl.l	#2,D1
	move.l	InitSongPtr(PC),A0
	jsr	(A0)
	lea	InfoBuffer(PC),A2
	moveq	#4,D2
FindIt
	cmp.w	#$4E75,(A0)
	beq.b	LastVoice
	cmp.w	#$41F9,(A0)+
	beq.b	OK
	bne.b	FindIt
OK	move.l	(A0),A0
	add.l	D1,A0
	tst.b	(A0)+
	bne.b	NextVoice1
	clr.b	(A1)
	subq.l	#1,D2
NextVoice1
	tst.b	(A0)+
	bne.b	NextVoice2
	clr.b	1(A1)
	subq.l	#1,D2
NextVoice2
	tst.b	(A0)+
	bne.b	NextVoice3
	clr.b	2(A1)
	subq.l	#1,D2
NextVoice3
	tst.b	(A0)
	bne.b	LastVoice
	clr.b	3(A1)
	subq.l	#1,D2
LastVoice
	move.l	D2,Voices(A2)
	move.l	(A1)+,(A1)
	rts

***************************************************************************
***************************** DTP_EndSound ********************************
***************************************************************************

EndSound
	lea	$DFF000,A0
	move.w	#15,$96(A0)
	moveq	#0,D0
	move.w	D0,$A8(A0)
	move.w	D0,$B8(A0)
	move.w	D0,$C8(A0)
	move.w	D0,$D8(A0)
	rts

	*----------------- PatchTable for Richard Joseph -------------------*

PatchTable
	dc.w	Code0-PatchTable,(Code0End-Code0)/2-1,Patch0-PatchTable
	dc.w	Code1-PatchTable,(Code1End-Code1)/2-1,Patch1-PatchTable
	dc.w	Code2-PatchTable,(Code2End-Code2)/2-1,Patch2-PatchTable
	dc.w	Code3-PatchTable,(Code3End-Code3)/2-1,Patch3-PatchTable
	dc.w	Code4-PatchTable,(Code4End-Code4)/2-1,Patch4-PatchTable
	dc.w	Code5-PatchTable,(Code5End-Code5)/2-1,Patch5-PatchTable
	dc.w	Code6-PatchTable,(Code6End-Code6)/2-1,Patch6-PatchTable
	dc.w	Code7-PatchTable,(Code7End-Code7)/2-1,Patch7-PatchTable
	dc.w	Code8-PatchTable,(Code8End-Code8)/2-1,Patch8-PatchTable
	dc.w	Code9-PatchTable,(Code9End-Code9)/2-1,Patch9-PatchTable
	dc.w	CodeA-PatchTable,(CodeAEnd-CodeA)/2-1,PatchA-PatchTable
	dc.w	CodeB-PatchTable,(CodeBEnd-CodeB)/2-1,PatchB-PatchTable
	dc.w	CodeC-PatchTable,(CodeCEnd-CodeC)/2-1,PatchC-PatchTable
	dc.w	CodeD-PatchTable,(CodeDEnd-CodeD)/2-1,PatchD-PatchTable
	dc.w	CodeE-PatchTable,(CodeEEnd-CodeE)/2-1,Patch6-PatchTable
	dc.w	CodeF-PatchTable,(CodeFEnd-CodeF)/2-1,Patch7-PatchTable
	dc.w	CodeG-PatchTable,(CodeGEnd-CodeG)/2-1,PatchG-PatchTable
	dc.w	0

; Volume patch for Richard Joseph modules

Code0
	MOVE.W	$48(A4),6(A5)
	MOVE.W	$2C(A4),8(A5)
Code0End
Patch0
	move.w	$48(A4),6(A5)
	move.l	D0,-(SP)
	move.w	$2C(A4),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0
	rts

; Address/length patch for Richard Joseph modules

Code1
	MOVE.W	$28(A4),4(A5)
Code1End
Patch1
	move.w	$28(A4),4(A5)
	bra.w	SetAll

; Bugfix patch for Richard Joseph modules

Code2
	MOVE.W	#2,$96(A5)
Code2End
Patch2
	move.w	2(A4),$96(A5)
	rts

; Volume patch for Richard Joseph modules

Code3
	MOVE.W	$48(A4),6(A5)
	MOVE.W	D0,-(SP)
	MOVE.W	$2C(A4),D0
	SUB.W	$8E(A4),D0
	BPL.S	lbC0003B8
	CLR.W	D0
lbC0003B8	MOVE.W	D0,8(A5)
	MOVE.W	(SP)+,D0
Code3End
Patch3
	move.w	$48(A4),6(A5)
	move.w	D0,-(SP)
	move.w	$2C(A4),D0
	sub.w	$8E(A4),D0
	bpl.b	VolOK
	clr.w	D0
VolOK
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.w	(SP)+,D0
	rts

; SongEnd patch for Richard Joseph modules

Code4
	MOVEA.L	$36(A4),A2
	MOVE.L	A2,$3A(A4)
Code4End
Patch4
	move.l	$36(A4),A2
	move.l	A2,$3A(A4)
	bra.b	SongEndTest

; SongEnd patch for Richard Joseph modules (priority before patch D)

Code5
	MOVE.L	A2,$36(A4)
	MOVE.W	6(A4),$9A(A5)
Code5End
Patch5
	move.l	A2,$36(A4)
	move.w	6(A4),Intena
SongEndTest
	movem.l	A1/A5,-(A7)
	lea	SongEnd(PC),A1
	cmp.l	#$DFF0A0,8(A4)
	bne.b	test1
	clr.b	(A1)
	bra.b	test
test1
	cmp.l	#$DFF0B0,8(A4)
	bne.b	test2
	clr.b	1(A1)
	bra.b	test
test2
	cmp.l	#$DFF0C0,8(A4)
	bne.b	test3
	clr.b	2(A1)
	bra.b	test
test3
	cmp.l	#$DFF0D0,8(A4)
	bne.b	test
	clr.b	3(A1)
test
	tst.l	(A1)+
	bne.b	SkipEnd
	move.l	(A1),-(A1)
	move.l	EagleBase(PC),A5
	move.l	dtg_SongEnd(A5),A1
	jsr	(A1)
SkipEnd
	movem.l	(A7)+,A1/A5
	rts

; Audio patch for Richard Joseph modules

Code6
	MOVE.W	#1,6(A0)
	MOVE.W	(A4),$96(A5)
Code6End
Patch6
	move.w	#1,6(A0)
	move.w	(A4),$96(A5)
	bra.w	Audio

; Audio patch for Richard Joseph modules

Code7
	MOVE.W	#1,6(A3)
	MOVE.W	(A4),$96(A5)
Code7End
Patch7
	move.w	#1,6(A3)
	move.w	(A4),$96(A5)
	bra.w	Audio

; Intena/Intreq patch for Richard Joseph modules

Code8
	MOVE.W	#$780,$9A(A5)
	MOVE.W	#$780,$9C(A5)
Code8End
Patch8
	move.w	#$780,Intena
	move.w	#$780,Intreq
	rts

; DMA patch for Richard Joseph modules

Code9
	MOVE.W	#$800F,$96(A5)
Code9End
Patch9
	move.w	#15,$96(A5)
	rts

; Intena patch for Richard Joseph modules

CodeA
	MOVE.W	4(A4),$9A(A5)
CodeAEnd
PatchA
	move.w	4(A4),Intena
	bra.w	Audio

; Intena patch for Richard Joseph modules (priority before patch D)

CodeB
	MOVE.W	6(A4),$9A(A5)
	RTS
CodeBEnd
PatchB
	move.w	6(A4),Intena
	bsr.w	Audio
	addq.l	#4,SP
	rts

; Intreq patch for Richard Joseph modules

CodeC
	MOVE.W	6(A4),$9C(A5)
CodeCEnd
PatchC
	move.w	6(A4),Intreq
	rts

; Intena patch for Richard Joseph modules

CodeD
	MOVE.W	6(A4),$9A(A5)
CodeDEnd
PatchD
	move.w	6(A4),Intena
	rts


; Audio patch for Richard Joseph modules (Cadaver, Moonstone)

CodeE
	MOVE.W	#1,6(A0)
	MOVE.W	0(A4),$96(A5)
CodeEEnd
PatchE					; used Patch6

; Audio patch for Richard Joseph modules (Cadaver, Moonstone)

CodeF
	MOVE.W	#1,6(A3)
	MOVE.W	0(A4),$96(A5)
CodeFEnd
PatchF					; used Patch7

; Multi patch for Richard Joseph modules (Palace modified version)

CodeG
	MOVE.L	A0,-(SP)
	MOVEA.L	8(A4),A5
CodeGEnd
PatchG
	addq.l	#4,SP
	move.l	8(A4),A5
	move.w	$48(A4),6(A5)
	move.l	D0,-(SP)
	move.w	$2C(A4),D0
	bsr.w	ChangeVolume
	bsr.w	SetVol
	move.l	(SP)+,D0
	tst.w	$2E(A4)
	beq.b	QuitM
	clr.w	$2E(A4)
	move.l	$1C(A4),(A5)
	move.w	$28(A4),4(A5)
	bsr.w	SetAll
	lea	$DFF000,A5
	move.w	#2,14(A4)
	move.w	(A4),$96(A5)
	move.w	6(A4),Intreq
	tst.w	$24(A4)
	bpl.b	AudiM
	tst.w	$26(A4)
	bne.b	MoveM
	move.w	6(A4),Intena
	bra.w	Audio

MoveM
	move.w	#1,14(A4)
AudiM
	move.w	4(A4),Intena
	bsr.w	Audio
QuitM
	rts
