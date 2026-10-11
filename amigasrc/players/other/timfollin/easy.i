********************************************
** A short collection of Assembler-Macros **
** for fast programming and debugging...  **
**                                        **
**         by Andy Silva in 1994          **
********************************************

	IFND	SILVA_EASY_I
SILVA_EASY_I SET 1

* Wait for left MouseButton

WM	MACRO
wm\@	btst	#6,$bfe001
	bne.b	wm\@
mw\@	btst	#6,$bfe001
	beq.b	mw\@
	ENDM


* Color-Flash

FLASH	MACRO
	move.l	d0,-(a7)
	move.w	#$5000,d0
fl\@	move.w	#$\1,$dff180
	dbf	d0,fl\@
	move.l	(a7)+,d0
	ENDM


* Silva's SUPER-BIT-BEFEHLE
*
* nun z.B. möglich:	btst.l	#0<=x=>31,ea

bsb	MACRO
	bset	#\1,\2
	ENDM

bsw	MACRO
	IFGT	\1-7
	  bset	#\1-8,\2
        ENDC
	IFLE	\1-7
	  bset	#\1,1+\2
	ENDC
	ENDM

bsl	MACRO
	IFGT	\1-15
	  bsw	\1-16,\2
	ENDC
	IFLE	\1-15
	  bsw	\1,2+\2
	ENDC
	ENDM

bcb	MACRO
	bclr	#\1,\2
	ENDM

bcw	MACRO
	IFGT	\1-7
	  bclr	#\1-8,\2
        ENDC
	IFLE	\1-7
	  bclr	#\1,1+\2
	ENDC
	ENDM

bcl	MACRO
	IFGT	\1-15
	  bcw	\1-16,\2
	ENDC
	IFLE	\1-15
	  bcw	\1,2+\2
	ENDC
	ENDM

btb	MACRO
	btst	#\1,\2
	ENDM

btw	MACRO
	IFGT	\1-7
	  btst	#\1-8,\2
        ENDC
	IFLE	\1-7
	  btst	#\1,1+\2	; wenn Ziel (ax) ohne Offset -> Error!
	ENDC
	ENDM

btl	MACRO
	IFGT	\1-15
	  btw	\1-16,\2
	ENDC
	IFLE	\1-15
	  btw	\1,2+\2
	ENDC
	ENDM


* komfortable Rettungen  (Pseudo-Opcodes)

PUSH	MACRO
	IFEQ	NARG-1
		move.l	\1,-(a7)
	  ELSE
		IFEQ	NARG-2
			move.l	\1,\2,-(a7)
		  ELSE
			move.l	\1,\2,\3,-(a7)
		ENDC
	ENDC
	ENDM

POP	MACRO
	IFEQ	NARG-1
		move.l	(a7)+,\1
	  ELSE
		IFEQ	NARG-2
			move.l	(a7)+,\1,\2
		  ELSE
			move.l	(a7)+,\1,\2,\3
		ENDC
	ENDC
	ENDM

PUSHM	MACRO
	movem.l	\1,-(a7)
	ENDM

POPM	MACRO
	movem.l	(a7)+,\1
	ENDM

PUSHW	MACRO
	movem.w	/1,-(a7)
	ENDM

POPW	MACRO
	movem.w	(a7)+,/1
	ENDM


* Ersatz für Utility-Tags:

BASE	MACRO			; same as ENUM
	IFEQ	NARG-1
tbase	SET	\1
	ELSE
tbase	SET	1
	ENDC
	ENDM

ITEM	MACRO			; same as EITEM
\1	EQU	tbase
tbase	SET	tbase+1
	ENDM


* Jumptabellen und Libraryvektoren

LVORES	MACRO		; vector to zero
mylvo	set	0
	ENDM

LVO4	MACRO		; simulate a 'jmp Label(pc)'
mylvo	set	mylvo-4
\1	equ	mylvo
	ENDM

LVO6	MACRO		; simulate a 'jmp Label'
mylvo	set	mylvo-6
\1	equ	mylvo
	ENDM


** einfacher Zugriff auf gerettete Register bei d1-a6:

sr_d1	= 0
sr_d2	= 4
sr_d3	= 8
sr_d4	= 12
sr_d5	= 16
sr_d6	= 20
sr_d7	= 24
sr_a0	= 28
sr_a1	= 32
sr_a2	= 36
sr_a3	= 40
sr_a4	= 44
sr_a5	= 48
sr_a6	= 52
sr_d1w	= 2
sr_d2w	= 6
sr_d3w	= 10
sr_d4w	= 14
sr_d5w	= 18
sr_d6w	= 22
sr_d7w	= 26
sr_a0w	= 30
sr_a1w	= 34
sr_a2w	= 38
sr_a3w	= 42
sr_a4w	= 46
sr_a5w	= 50
sr_a6w	= 54
sr_d1b	= 3
sr_d2b	= 7
sr_d3b	= 11
sr_d4b	= 15
sr_d5b	= 19
sr_d6b	= 23
sr_d7b	= 27
sr_a0b	= 31
sr_a1b	= 35
sr_a2b	= 39
sr_a3b	= 43
sr_a4b	= 47
sr_a5b	= 51
sr_a6b	= 55

* Jumptabellen

JTBASE	MACRO		; Basis für Wortoffset-Jumptabelle
jtb\@
JTDUMMY EQU jtb\@
	IFEQ	NARG-1
	dc.w	\1	; wahlweise 'etwas' nach Offset 0
	ENDC
	ENDM

JTLAB	MACRO
	dc.w	\1-JTDUMMY
	ENDM

	ENDC
