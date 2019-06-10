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

	.align	4
ENTRY(extcfg_get_bopt)
	mrc	p15, 0, r0, c13, c0, 1		@ CONTEXTIDR
	bx	lr
ENDPROC(extcfg_get_bopt)

ENTRY(extcfg_set_bopt)
	mcr	p15, 0, r0, c13, c0, 1
	bx	lr
ENDPROC(extcfg_set_bopt)

ENTRY(smc_get_fnptr)
	mrc	p15, 0, r0, c13, c0, 2
	bx	lr
ENDPROC(smc_get_fnptr)

ENTRY(smc_set_fnptr)
	mcr	p15, 0, r0, c13, c0, 2
	bx	lr
ENDPROC(smc_set_fnptr)

ENTRY(secure_launch)
	mov	r11, r1
	msr	CPSR_c,  #(MODE_SVC | I_BIT)

	mov	lr, r2
	mov	r1, r3

	mov	r3, #0

	bx	r11
ENDPROC(secure_launch)

ENTRY(non_secure_launch)
	mov	r4, r1

	mrs	r0, cpsr
	and	r0, #0x1F
	cmp	r0, #MODE_MON
	bne	.

	/* Change to Secure -> Non-Secure */
	bl	set_nonsecure_mode

	mov	lr, r4

	mov	r1,  #0
	mov	r2,  #0
	mov	r3,  #0
	mov	r4,  #0
	mov	r5,  #0
	mov	r6,  #0
	mov	r7,  #0
	mov	r8,  #0
	mov	r9,  #0
	mov	r10, #0
	mov	r11, #0
	mov	r12, #0

	/* switch to supervisor mode */
	mov	r0, #(MODE_SVC | A_BIT | I_BIT)
	msr	SPSR_cxsf, r0
	mov	r0, #0
	movs	pc, lr
ENDPROC(non_secure_launch)
