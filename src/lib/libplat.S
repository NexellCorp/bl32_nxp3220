#include "../include/asm.h"
#include "../include/armv7.h"

	.align	4
ENTRY(extcfg_get_bopt)
	mrc	p15, 0, r0, c13, c0, 1						@ CONTEXTIDR
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
	msr	CPSR_c,  #(MODE_SVC|I_BIT)

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
	mov	r0, #(MODE_SVC | I_BIT)
	msr	SPSR_cxsf, r0
	mov	r0, #0
	movs	pc, lr
ENDPROC(non_secure_launch)
