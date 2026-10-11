;fs "Includes"
         incdir    "IncludeIII:"
         include   "exec/exec_lib.i"
         incdir    "mus:delitracker_II/developer/include"
         include   "misc/deliplayer.i"

CALL     macro
         jsr       _LVO\1(a6)
         endm

AbsExecBase        = 4
;fe
;fs "Header"
         PLAYERHEADER        Tags
         dc.b      0,"$VER: Art&Magic player 0.51 (25.6.97) adapted by MORB/CdBS Software",0
         even
Tags:
         dc.l      DTP_RequestKickVersion,37
         dc.l      DTP_PlayerVersion,00<<16+51
         dc.l      DTP_PlayerName,Name
         dc.l      DTP_Creator,Creator
         dc.l      DTP_Check2,Check
         dc.l      DTP_Interrupt,Inter
         dc.l      DTP_InitPlayer,Init
         dc.l      DTP_EndPlayer,Cleanup
         dc.l      DTP_InitSound,InitSnd
         dc.l      DTP_EndSound,EndSnd
         dc.l      DTP_Volume,SetVol
         dc.l      DTP_Balance,SetVol
         dc.l      DTP_CheckLen,ChkLength-Check
         dc.l      DTP_Flags,PLYF_SONGEND
         dc.l      TAG_DONE
Name:
         dc.b      "Art&Magic",0
Creator:
         dc.b      "Adapted by",$a
         dc.b      "MORB/CdBS Software",0
         even
Data:
         ds.l      1
DeliGlobals:
         ds.l      1
;fe
;fs "Code"
;fs "Check"
Check:
         move.l    dtg_ChkData(a5),a0
         moveq     #-1,d0
         cmp.l     #"EXIT",26(a0)
         bne.s     .Done
         move.l    dtg_ChkSize(a5),d1
         add.l     d1,a0
         cmp.l     #"EXIT",-4(a0)
         bne.s     .Done
         moveq     #0,d0
.Done:
         rts
ChkLength:
;fe
;fs "Init"
Init:
         move.l    a5,DeliGlobals
         moveq     #0,d0
         move.l    dtg_GetListData(a5),a0
         jsr       (a0)
         move.l    a0,Data

         move.l    dtg_AudioAlloc(a5),a0
         jsr       (a0)
         tst.l     d0
         bne.s     .Fail

         move.l    Data(pc),a0
         move.l    a0,d1
         move.w    $e2(a0),d2
         add.w     #$e2,d2
         lea       (a0,d2.w),a1
         move.w    $15e(a0),d2
         add.w     #$15e-9,d2
         sub.l     (a0,d2.w),d1
         ext.l     d2
         add.l     d2,d1
         add.l     #9,d1
         add.l     a0,d2
         sub.l     a1,d2
         sub.l     #40,d2
         lsr.l     #2,d2

         moveq     #5-1,d3
.RLoop:
         add.l     d1,(a1)
         addq.l    #8,a1
         dbf       d3,.RLoop
.RLoop2:
         add.l     d1,(a1)+
         dbf       d2,.RLoop2

         move.l    Data(pc),a2

         move.w    #$4eb9,$17c(a2)
         move.l    #VolHandler,$17e(a2)

         cmp.l     #$01020408,$20e(a2)
         beq.s     .Gnargh
         move.w    #$4eb9,$420(a2)
         move.l    #EndSig,$422(a2)

         bra.s     .Miaou
.Gnargh:
         move.w    #$4eb9,$424(a2)
         move.l    #EndSig,$426(a2)
.Miaou:
         move.l    (AbsExecBase).w,a6
         CALL      CacheClearU

         jsr       (a2)

         moveq     #0,d0
.Fail:
         rts
;fe
;fs "EndSig"
EndSig:
         move.l    a0,-(a7)
         move.l    DeliGlobals(pc),a0
         move.l    dtg_SongEnd(a0),a0
         jsr       (a0)
         move.l    (a7)+,a0
         move.b    (a1),d0
         move.w    $16(a0),d1
         rts
;fe
;fs "VolHandler"
VolHandler:
         movem.l   d1/a0,-(a7)
         lsr.w     #6,d0
         move.w    a4,d1
         lsr.w     #4,d1
         ext.w     d1
         lea       ModVols-1,a0
         move.b    d0,(a0,d1.w)
         lea       MastVols-1,a0
         move.b    (a0,d1.w),d1
         mulu      d1,d0
         lsr.w     #6,d0
         move.w    d0,$a8(a4)
         movem.l   (a7)+,d1/a0
         rts
;fe
;fs "Cleanup"
Cleanup:
         move.l    dtg_AudioFree(a5),a0
         jmp       (a0)
;fe
;fs "InitSnd"
InitSnd:
         move.l    a5,-(a7)
         move.l    Data(pc),a4
         lea       162(a4),a4
         moveq     #1,d6
         moveq     #1,d7
         jsr       (a4)
         moveq     #2,d6
         moveq     #2,d7
         jsr       (a4)
         moveq     #3,d6
         moveq     #3,d7
         jsr       (a4)
         move.l    (a7)+,a5
         rts
;fe
;fs "EndSnd"
EndSnd:
         lea       $dff000,a0
         clr.w     $a8(a0)
         clr.w     $b8(a0)
         clr.w     $c8(a0)
         clr.w     $d8(a0)
         move.w    #$f,$96(a0)
         rts
;fe
;fs "Inter"
Inter:
         movem.l   d2-7/a2-6,-(a7)
         move.l    Data(pc),a0
         jsr       132(a0)
         movem.l   (a7)+,d2-7/a2-6
         rts
;fe
;fs "SetVol"
ModVols:
         ds.l      1
MastVols:
         ds.l      1
SetVol:
         move.w    dtg_SndVol(a5),d0
         move.w    dtg_SndRBal(a5),d1
         mulu      d0,d1
         lsr.w     #6,d1
         move.b    d1,MastVols
         move.b    d1,MastVols+1

         mulu      dtg_SndLBal(a5),d0
         lsr.w     #6,d0
         move.b    d0,MastVols+2

         rts
;fe
;fe
