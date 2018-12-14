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
        b       reset_handler       						@ 00 - Reset
        b       .          							@ 04 - Undefined instructions
        b       .                   						@ 08 - SWI instructions
        b       .          							@ 0C - Instruction fetch aborts
        b       .          							@ 10 - Data access aborts
        b       .                  						@ 14 - Reserved (was address exception)
        b       .                   						@ 18 - IRQ interrupts
        b       .                   						@ 1C - FIQ interrupts

reset_handler:
	stmfd	sp!, {lr}

	mov	r12, r11

	/* Set the monitor mode vertor base address */
	bl	set_montior_vector

	/* Set the vector base address */
        mov     r0, r12
	mcr     p15, 0, r0, c12, c0, 0

	/* Check if Secondary Core? */
	mrc	p15, 0, r0, c0, c0, 5
	ands	r0, r0, #0xF
	bne	subcpu_launch

	/*
	 * Disable caches and MMU in case they were left enabled
	 * from an earlier run.
	 * This does not need to be done from a cold reset
	 */
	mrc     p15, 0, r0, c1, c0, 0						@ Read System Control Register
	bic     r0, r0, #(0x1 << 12)						@ Clear I bit 12 to disable I Cache
	bic     r0, r0, #(0x1 <<  2)						@ Clear C bit  2 to disable D Cache
	bic     r0, r0, #0x1							@ Clear M bit  0 to disable MMU
	mcr     p15, 0, r0, c1, c0, 0						@ Write System Control Register
	isb

	/*
	 * ACTLR.SMP bit must be set before the caches and MMU are enabled,
	 * or any cache and TLB maintenance operations are performed, even
	 * for single-core.
	 */
	mrc	p15, 0, r0, c1, c0, 1						@ Read ACTLR
	orr	r0, r0, #(1 << 6)						@ Set ACTLR.SMP bit
	mcr	p15, 0, r0, c1, c0, 1						@ Write ACTLR
	isb

	/*
	 * Invalidate Data and Instruction TLBs and branch predictor
	 * This does not need to be done from a cold reset.
	 */
	mov	r0, #0								@ set up for MCR
	mcr	p15, 0, r0, c8, c7, 0						@ invalidate TLBs
	mcr	p15, 0, r0, c7, c5, 0						@ invalidate icache
	mcr	p15, 0, r0, c7, c5, 6						@ invalidate BP array
	mcr     p15, 0, r0, c7, c10, 4						@ DSB
	mcr     p15, 0, r0, c7, c5, 4						@ ISB

	/*
	 * Cache Invalidation code for Cortex-A7
	 * The caches, MMU and BTB do not need post-reset invalidation
	 * on Cortex-A7, but forcing a cache invalidation makes the code
	 * more portable to other CPUs (e.g. Cortex-A9)
	 */
	bl	invaildate_l1_icache
	bl	invaildate_dcache

	/*
	 * MMU Configuration - Set translation table base
	 */
	/*
	 * Two translation tables are supported, TTBR0 and TTBR1
	 * Configure translation table base (TTB) control register cp15,c2
	 * to a value of all zeros, indicates we are using TTB register 0.
	 */
	mov	r0, #0x0
	mcr	p15, 0, r0, c2, c0, 2

	/* Write the address of our page table base to TTB register 0 */
	mov	r0, r12								@ physical address (text base)

	ldr	r1, =0x1000000							@ BL32(or secure-os) allocate size
	add	r0, r1								@ + 16MB
	sub	r0, #0x1000							@ - stack size
	sub	r0, #0x4000							@ - page-table size
	ldr	r2, =0xFFFFC000							@ align mask value
	and	r0, r2								@ align address (16KB align)
	mov	r10, r0

	mov	r1, #0x08							@ RGN=b01  (outer cacheable write-back cached, write allocate)
										@ S=0	   (translation table walk to non-shared memory)
	orr	r1, r1, #0x40							@ IRGN=b01 (inner cacheability for the translation table walk is Write-back Write-allocate)

	orr	r0, r0, r1
	mcr	p15, 0, r0, c2, c0, 0

	/*
	 * PAGE TABLE generation
	 * Generate the page tables
	 * Build a flat translation table for the whole address space.
	 * ie: Create 4096 1MB sections from 0x000xxxxx to 0xFFFxxxxx

	 * 31		      20 19  18  17  16 15  14	 12 11 10  9  8     5	4    3 2   1 0
	 * |section base address| 0  0	|nG| S |AP2|  TEX  |  AP | P | Domain | XN | C B | 1 0|
	 *
	 * Bits[31:20]	 - Top 12 bits of VA is pointer into table
	 * nG[17]=0	 - Non global, enables matching against ASID in the TLB when set.
	 * S[16]=0	 - Indicates normal memory is shared when set.
	 * AP2[15]=0
	 * AP[11:10]=11  - Configure for full read/write access in all modes
	 * TEX[14:12]=000
	 * CB[3:2]= 00	 - Set attributes to Strongly-ordered memory.
	 *		   (except for the code segment descriptor, see below)
	 * IMPP[9]=0	 - Ignored
	 * Domain[5:8]=1111   - Set all pages to use domain 15
	 * XN[4]=1	 - Execute never on Strongly-ordered memory
	 * Bits[1:0]=10  - Indicate entry is a 1MB section
	 */
	mov	r0, r10								@ TTBR0 Address

	ldr	r1, =0xFFF							@ 4096 entery
	ldr	r2, =0xC12							@ 0b00000000000000000000110000010010

	/*
	 * r0 contains the address of the translation table base
	 * r1 is loop counter
	 * r2 is level1 descriptor (bits 19:0)
	 *
	 * use loop counter to create 4096 individual table entries.
	 * this writes from address 'Image$$TTB$$ZI$$Base' +
	 * offset 0x3FFC down to offset 0x0 in word steps (4 bytes)
	 */
init_ttb_1:
	orr	r3, r2, r1, lsl#20						@ R3 now contains full level1 descriptor to write
	orr	r3, r3, #0x10							@ Set XN bit (0b0000000010000)

	str	r3, [r0, r1, lsl#2]						@ Str table entry at TTB base + loopcount*4
	subs	r1, r1, #1							@ Decrement loop counter
	bpl	init_ttb_1

	/*
	 * r1: page table size variable
	 * r2: text base address
	 * r3: boot-loader32(or secure-os) allocate size
	 * r4: page table attribute
	 * r5: loop count
	 * r6: virtual address
	 */
	ldr	r1, =0xFEF							@ page table size variable  (0xFE0 + 0xF(16M))

	mov	r2, r12 							@ physical address (text base)
	ldr	r3, =0x1000000
	add	r2, r3								@ + 16M
	sub	r2, #0x1000							@ - stack size
	sub	r2, #0x4000							@ - page-table size
	mov	r6, r2								@ cpoy the TTBR0
	ldr	r3, =0xFFFFC000							@ calcurate the TTBR0
	and	r6, r3								@ align address
	lsr	r2, #20								@ extract upper address

	ldr	r5, =0xF							@ 16M (16M/1M = 16)
	ldr	r4, =0xC12							@ 0b00000000000000000000110000010010

set_ttb_1:
	orr	r3, r4, r2, lsl#20						@ R3 now contains full level1 descriptor to write
	orr	r3, r3, #0x10							@ Set XN bit (0b0000000010000)
	str	r3, [r6, r1, lsl#2]						@ Str table entry at TTB base + page-table size variable * 4
	sub	r2, r2, #1							@ Decrement physical address
	sub	r1, r1, #1							@ Decrement virtual address
	subs	r5, r5, #1							@ Decrement loop counter
	bpl	set_ttb_1

	/*
	 * TEX[14:12]=001 and CB[3:2]= 11, Outer and inner write back, write
	 * allocate normal memory.
	 */
	/* For actual text-base */
	mov	r1, r12 							@ Base physical address of code segment
	lsr	r1, #20 							@ Shift right to align to 1MB boundaries
	orr	r3, r2, r1, lsl#20						@ Setup the initial level1 descriptor again
	orr	r3, r3, #0x0C							@ Set CB bits (0b0000000001100)
	orr	r3, r3, #0x1000 						@ Set TEX bit 12 (0b1000000000000)
	str	r3, [r0, r1, lsl#2]						@ str table entry

	/* For virtual(original) text-base */
	ldr	r4, =__text_base__						@ text-based applied at compile time. (virtual text-base)
	lsr	r4, #20
	orr	r3, r2, r1, lsl#20						@ Setup the initial level1 descriptor again
	orr	r3, r3, #0x0C							@ Set CB bits (0b0000000001100)
	orr	r3, r3, #0x1000 						@ Set TEX bit 12 (0b1000000000000)
	str	r3, [r0, r1, lsl#2]

	/* For sram base address */
	ldr	r1, =0xFFF							@ SRAM Base Address (0xFFFF0000)
	orr	r3, r2, r1, lsl#20						@ Setup the initial level1 descriptor again
	orr	r3, r3, #0x0C							@ Set CB bits (0b0000000001100)
	orr	r3, r3, #0x1000 						@ Set TEX bit 12 (0b1000000000000)
	str	r3, [r0, r1, lsl#2]						@ str table entry

	/* Setup domain control register - Enable all domains to client mode */
	mrc	p15, 0, r0, c3, c0, 0						@ Read Domain Access Control Register
	ldr	r0, =0xFFFFFFFF 						@ Initialize every domain entry to b01 (manager)
	mcr	p15, 0, r0, c3, c0, 0						@ Write Domain Access Control Register

	/* Enables the MMU */
        mrc     p15, 0, r0, c1, c0, 0      					@ Read System Control Register
     	bic     r0, r0, #(0x1 << 12)       					@ Clear I bit 12 to disable I Cache
     	bic     r0, r0, #(0x1 <<  2)       					@ Clear C bit  2 to disable D Cache
	bic     r0, r0, #(0x1 <<  1)           					@ Clear A bit  1 to disable strict alignment fault checking
        orr     r0, r0, #(0x1 <<  0)           					@ Set M bit 0 to enable MMU before scatter loading
        mcr     p15, 0, r0, c1, c0, 0      					@ Write System Control Register
	isb

	/* Enable the I/DCaches */
        mrc     p15, 0, r0, c1, c0, 0      					@ Read System Control Register
        orr     r0, r0, #(0x1 << 12)       					@ Set I bit 12 to enable I Cache
//      orr     r0, r0, #(0x1 << 2)        					@ Set C bit  2 to enable D Cache
        mcr     p15, 0, r0, c1, c0, 0      					@ Write System Control Register
        isb

	/* Set the BSS-Area to zero. */
	ldr	r1, =__bss_start__
	ldr	r2, =__bss_end__

	mov	r3, #0x00000000 						@ Prepare zero to clear BSS

clbss_l:
	cmp	r1, r2								@ while not at end of BSS
	strlo	r3, [r1]							@ clear 32-bit BSS word
	addlo	r1, r1, #4
	blo	clbss_l

#if 0
	/* Stack size set to monitor mode  */
	ldr	sp, =BL32_BASEADDR
	add	sp, sp, #BL32_SIZE
	sub	sp, sp, #MON_STACK_SIZE

	mrc	p15, 0, r12, c0, c0, 5						@ Get our cpu id
	ands	r12, r12, #0xF							@ Save CPU id

	mov	r1, #0x100
	sub	r2, r12, #1
	and	r2, r2, #3
	mul	r1, r1, r2
	sub	sp, sp, r1
#endif

	bl	main

subcpu_launch:
	ldmfd	sp!, {r10}

next_launch:
	mov	r1, r10
	mov	r0, #0

	b	non_secure_launch
	b	.
