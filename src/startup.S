/*
 * Copyright (c) 2005-2017 Arm Limited (or its affiliates). All rights reserved.
 * Use, modification and redistribution of this file is subject to your
 * possession of a valid DS-5 end user licence agreement and your compliance
 * with all applicable terms and conditions of such licence agreement.
 * Cortex-A7 Embedded example - Startup Code
 */
/*
 * Copyright (C) 2018  Nexell Co., Ltd.
 * Author: deoks <truevirtue@nexell.co.kr>
 *
 * Nexell informs that this code and information is provided "as Is" base
 * and without warranty of any kind, either expressed or implied, including,
 * but not limited to the implied warranties of merchantabulity and/or
 * fitness for a aparticular purpose.
 *
 * This program is copyrighted by Nexcel and does not allow modification or
 * distribution. In addition to the author (person in charge), the modifier
 * is responsible for the modification.
 */
#include "include/armv7.h"
#include "include/nxp3220.h"

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

	/* Check if Secondary Core? */
        mrc     p15, 0, r0, c0, c0, 5
        ands    r0, r0, #0xF
        bne     subcpu_launch

	/* Invaild Data Cache */
	bl	invaildate_dcache

	/* Set the BSS-Area to zero. */
        ldr     r1, =__bss_start__
        ldr     r2, =__bss_end__

        mov     r3, #0x00000000							/* Prepare zero to clear BSS			*/

clbss_l:
        cmp     r1, r2								/* while not at end of BSS			*/
        strlo   r3, [r1]							/* clear 32-bit BSS word			*/
        addlo   r1, r1, #4
        blo     clbss_l

	ldmfd	sp!, {r10}
#if 0
	/* Stack size set to monitor mode  */
	ldr     sp, =BL32_BASEADDR
	add     sp, sp, #BL32_SIZE
	sub	sp, sp, #MON_STACK_SIZE

	mrc     p15, 0, r12, c0, c0, 5						@ Get our cpu id
	ands    r12, r12, #0xF							@ Save CPU id

	mov     r1, #0x100
	sub     r2, r12, #1
	and     r2, r2, #3
	mul     r1, r1, r2
	sub     sp, sp, r1
#endif
	stmfd	sp!, {r10}
	bl	main

subcpu_launch:
	ldmfd	sp!, {r10}

next_launch:
	mov	r1, r10
	mov	r0, #0

	b	non_secure_launch
	b	.