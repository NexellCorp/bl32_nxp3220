/*
 * Copyright (c) 2005-2017 Arm Limited (or its affiliates). All rights reserved.
 * Use, modification and redistribution of this file is subject to your
 * possession of a valid DS-5 end user licence agreement and your compliance
 * with all applicable terms and conditions of such licence agreement.
 * Cortex-A7 Embedded example - Startup Code
 */
/* Copyright (C) 2018  Nexell Co., Ltd.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *  * Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *  * Neither the name of the Nexell nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL,SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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