#include "include/armv7.h"

        .align

.global main
.global set_montior_vector
.global set_nonsecure_mode

/* arm exceptions vectors */
.global vectors
vectors:
        b       reset_handler       						/* 00 - Reset					*/
        b       .          							/* 04 - Undefined instructions			*/
        b       .                   						/* 08 - SWI instructions			*/
        b       .          							/* 0C - Instruction fetch aborts		*/
        b       .          							/* 10 - Data access aborts			*/
        b       .                  						/* 14 - Reserved (was address exception)	*/
        b       .                   						/* 18 - IRQ interrupts				*/
        b       .                   						/* 1C - FIQ interrupts				*/

reset_handler:
	stmfd	sp!, {lr}

	bl	set_montior_vector

	/* Set the BSS-Area to zero. */
        ldr     r1, =__bss_start__
        ldr     r2, =__bss_end__

        mov     r3, #0x00000000							/* Prepare zero to clear BSS			*/

clbss_l:
        cmp     r1, r2								/* while not at end of BSS			*/
        strlo   r3, [r1]							/* clear 32-bit BSS word			*/
        addlo   r1, r1, #4
        blo     clbss_l

	bl	main
	bl	set_nonsecure_mode

	ldmfd	sp!, {lr}
	bx	lr