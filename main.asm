;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------

; constexpr setup

ARY1		.set	0x0200
ARY1S		.set	0x0210
ARY2		.set	0x0220
ARY2S		.set	0x0230

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

		clr		R4 ; storage for ARY1 / ARY2
		clr 	R6 ; storage for ARY1S / ARY2S
		call	#CLR_REGISTERS

ARR1_PROCESS:
		mov.w	#ARY1,	R4
		mov.w	#ARY1S,	R6

		call	#ARR1_INIT
		call	#COPY
		call 	#BUBBLE_SORT

ARR2_PROCESS:
		mov.w	#ARY2,	R4
		mov.w	#ARY2S,	R6
		call	#ARR2_INIT
		call	#COPY
		call	#BUBBLE_SORT


ARR1_INIT:
		mov.b	#10,	0(R4)
		mov.b	#45,		1(R4)
		mov.b	#-23,	2(R4)
		mov.b	#-78,	3(R4)
 		mov.b	#32,	4(R4)
		mov.b	#89,	5(R4)
		mov.b	#-19,	6(R4)
		mov.b	#-99,	7(R4)
		mov.b	#73,	8(R4)
		mov.b	#-18,	9(R4)
		mov.b	#56,	10(R4)

		ret

ARR2_INIT:
		mov.b	#10,	0(R4)
		mov.b	#22,	1(R4)
		mov.b	#45,	2(R4)
		mov.b	#21,	3(R4)
		mov.b	#-39,	4(R4)
		mov.b	#-63,	5(R4)
		mov.b	#69,	6(R4)
		mov.b	#72,	7(R4)
		mov.b	#41,	8(R4)
		mov.b	#28,	9(R4)
		mov.b	#-28,	10(R4)

		ret

COPY:
		call 	#CLR_REGISTERS

		mov.b	0(R4),	R7
		inc.w	R7 ; off by one fix

		mov.w	R4,		R8 ; R8 pointer to extract data
		mov.w	R6,		R9 ; R9 pointer to insert data
COPY_LP:
		mov.b	@R8+,	0(R9) ; shift elem

		inc.w	R9
		dec.w	R7

		jnz		COPY_LP
		ret

BUBBLE_SORT:
		call 	#CLR_REGISTERS
		mov.b	0(R4),	R7 ; i (outer)
		dec.w	R7
OUTER_LOOP:
		mov.b	0(R4),	R8 ; j (inner)
		sub.w	R11,	R8 ; prevent un-necessary amount of iterations

		dec.w	R8

		mov.w	R6,	R9 ; reset R9 pointer to the start R9[0]
		inc.w	R9 	   ; shift R9 to *(R6+1) in the interest of not removing the size component of the arr
INNER_LOOP:
		cmp.b	@R9+,	0(R9) ; gets R9[i] than increments making the next elem R9[++i]

		jge 	IL_SENTINEL

		; handle a swap

		mov.b	-1(R9),	R10
		mov.b	0(R9),	-1(R9)
		mov.b	R10,	0(R9)
IL_SENTINEL:
		dec.w	R8
		jnz		INNER_LOOP ; if it is zero than you decrement the outer look sentinel now

		; if it is zero, increment R11 by 1 to do less iterations since you know one position is sorted correctly now

		inc.w	R11
		dec.w	R7

		jnz		OUTER_LOOP

		ret

CLR_REGISTERS:
		clr.w	R7
		clr.w	R8
		clr.w	R9
		clr.w	R10
		clr.w	R11

		ret

Mainloop 		jmp		Mainloop ; infinite loopin

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
