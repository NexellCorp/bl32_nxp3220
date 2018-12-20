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
#include "../include/asm.h"
#include "../include/armv7.h"

	.align 5								@ below instruction number is 8, 32bytes

ENTRY(enable_fpu)
	/* Set NSACR to access CP10, CP11 in secure and non-secure mode */
	mrc	p15, 0, r0, c1, c1, 2
	orr	r0, r0, #(2 << 10)						@ enable fpu
	mcr	p15, 0, r0, c1, c1, 2

	/* Set CPACR for access to CP10, CP11 */
	mov	r0, #(0xF<<20)
	mcr	p15, 0, r0, c1, c0, 2

	/* Set FPEXC EN bit to enable the FPU */
	mov	r0, #0x40000000
	vmsr	fpexc, r0
	mov	pc, lr
ENDPROC(enable_fpu)

ENTRY(set_nonsecure_mode)
	mrc	p15, 0, r0, c1, c1, 0
	orr	r0, r0, #(1 << 0)
	mcr	p15, 0, r0, c1, c1, 0
	bx	lr
ENDPROC(set_nonsecure_mode)

ENTRY(set_secure_mode)
	mrc	p15, 0, r0, c1, c1, 0
	bic	r0, r0, #(1 << 0)
	mcr	p15, 0, r0, c1, c1, 0
	bx	lr
ENDPROC(set_secure_mode)

ENTRY(get_secure_status)
	mrc	p15, 0, r0, c1, c1, 0
	and	r0, r0, #(1 << 0)
	bx	lr
ENDPROC(get_secure_status)

ENTRY(armv7_get_cpuid)
	mrc	p15, 0, r0, c0, c0, 5
	ands	r0, r0, #0xF
	bx	lr
ENDPROC(armv7_get_cpuid)

ENTRY(armv7_get_mpidr)
	mrc	p15, 0, r0, c0, c0, 5						@ Get MPIDR
	bx	lr
ENDPROC(armv7_get_mpidr)

ENTRY(armv7_set_auxctrl)
	mcr	p15, 0, r0, c1, c0, 1
	bx	lr
ENDPROC(armv7_set_auxctrl)

ENTRY(armv7_get_auxctrl)
	mrc	p15, 0, r0, c1, c0, 1
	bx	lr
ENDPROC(armv7_get_auxctrl)

ENTRY(armv7_get_scr)
	mrc	p15, 0, r0, c1, c1, 0
	bx	lr
ENDPROC(armv7_get_scr)

ENTRY(armv7_set_scr)
	mcr	p15, 0, r0, c1, c1, 0
	bx	lr
ENDPROC(armv7_set_scr)

ENTRY(set_mon_mode)
	msr	CPSR_c,  #(MODE_MON|I_BIT)
	bx	lr
ENDPROC(set_mon_mode)

ENTRY(set_svc_mode)
	msr	CPSR_c,  #(MODE_SVC|I_BIT)
	bx	lr
ENDPROC(set_svc_mode)

ENTRY(v7_flush_dcache_all)
	dmb									@ ensure ordering with previous memory accesses
	mrc	p15, 1, r0, c0, c0, 1						@ read clidr
	mov	r3, r0, lsr #23							@ move LoC into position
	ands	r3, r3, #7 << 1							@ extract LoC*2 from clidr
	beq	finished							@ if loc is 0, then no need to clean
start_flush_levels:
	mov	r10, #0								@ start clean at cache level 0
flush_levels:
	add	r2, r10, r10, lsr #1						@ work out 3x current cache level
	mov	r1, r0, lsr r2							@ extract cache type bits from clidr
	and	r1, r1, #7							@ mask of the bits for current cache only
	cmp	r1, #2								@ see what cache we have at this level
	blt	skip								@ skip if no cache, or just i-cache
#if 0
	mrs	r9, cpsr
	cpsid	i
#endif
	mcr	p15, 2, r10, c0, c0, 0						@ select current cache level in cssr
	isb									@ isb to sych the new cssr&csidr
	mrc	p15, 1, r1, c0, c0, 0						@ read the new csidr
#if 0
	msr	cpsr_c,	r9
#endif
	and	r2, r1, #7							@ extract the length of the cache lines
	add	r2, r2, #4							@ add 4 (line length offset)
	movw	r4, #0x3ff
	ands	r4, r4, r1, lsr #3						@ find maximum number on the way size
	clz	r5, r4								@ find bit position of way size increment
	movw	r7, #0x7fff
	ands	r7, r7, r1, lsr #13						@ extract max number of the index size
loop1:
	mov	r9, r7								@ create working copy of max index
loop2:
	orr	r11, r10, r4, lsl r5						@ factor way and cache number into r11
	orr	r11, r11, r9, lsl r2						@ factor index number into r11
	mcr	p15, 0, r11, c7, c14, 2						@ clean & invalidate by set/way
	subs	r9, r9, #1							@ decrement the index
	bge	loop2
	subs	r4, r4, #1							@ decrement the way
	bge	loop1
skip:
	add	r10, r10, #2							@ increment cache number
	cmp	r3, r10
	bgt	flush_levels
finished:
	mov	r10, #0								@ switch back to cache level 0
	mcr	p15, 2, r10, c0, c0, 0						@ select current cache level in cssr
	dsb	st
	isb
	bx	lr
ENDPROC(v7_flush_dcache_all)

ENTRY(v7_flush_kern_cache_all)
	stmfd	sp!, {r4-r5, r7, r9-r11, lr}
	bl	v7_flush_dcache_all
	mov	r0, #0
	mcr	p15, 0, r0, c7, c1, 0						@ invalidate I-cache inner shareable
	mcr	p15, 0, r0, c7, c5, 0						@ I+BTB cache invalidate
	ldmfd	sp!, {r4-r5, r7, r9-r11, lr}
	bx	lr
ENDPROC(v7_flush_kern_cache_all)

ENTRY(invaildate_dcache)
	/* Invalidate Data/Unified Caches */
	mrc	p15, 1, r0, c0, c0, 1	   					@ Read CLIDR
	ands	r3, r0, #0x07000000	  					@ Extract coherency level
	mov	r3, r3, lsr #23 	   					@ Total cache levels << 1
	beq	finished2		  					@ If 0, no need to clean

	mov	r10, #0 		  					@ R10 holds current cache level << 1
loop21:
	add	r2, r10, r10, lsr #1	  					@ R2 holds cache "Set" position
	mov	r1, r0, lsr r2		   					@ Bottom 3 bits are the Cache-type for this level
	and	r1, r1, #7		   					@ Isolate those lower 3 bits
	cmp	r1, #2
	blt	skip2			   					@ No cache or only instruction cache at this level

	mcr	p15, 2, r10, c0, c0, 0	   					@ Write the Cache Size selection register
	isb				   					@ ISB to sync the change to the CacheSizeID reg
	mrc	p15, 1, r1, c0, c0, 0	   					@ Reads current Cache Size ID register
	and	r2, r1, #7		  					@ Extract the line length field
	add	r2, r2, #4		   					@ Add 4 for the line length offset (log2 16 bytes)
	ldr	r4, =0x3FF
	ands	r4, r4, r1, lsr #3	   					@ R4 is the max number on the way size (right aligned)
	clz	r5, r4			   					@ R5 is the bit position of the way size increment
	ldr	r7, =0x7FFF
	ands	r7, r7, r1, lsr #13	   					@ R7 is the max number of the index size (right aligned)

loop22:
	mov	r9, r4			   					@ R9 working copy of the max way size (right aligned)

loop23:
	orr	r11, r10, r9, LSL r5	   					@ Factor in the Way number and cache number into R11
	orr	r11, r11, r7, LSL r2	   					@ Factor in the Set number
	mcr	p15, 0, r11, c7, c6, 2	   					@ Invalidate by Set/Way
	subs	r9, r9, #1		   					@ Decrement the Way number
	bge	loop23
	subs	r7, r7, #1		   					@ Decrement the Set number
	bge	loop22
skip2:
	add	r10, r10, #2		   					@ Increment the cache number
	cmp	r3, r10
	bgt	loop21
finished2:
	mov	r0, #0
	mcr	p15, 0, r0, c7, c10, 4						@ Drain write buffer

	mcr	p15, 0, r0, c8, c7, 0						@ invalidate I + D TLBs
	mcr	p15, 0, r0, C2, c0, 2						@ TTB Control Register

	bx	lr
ENDPROC(invaildate_dcache)
