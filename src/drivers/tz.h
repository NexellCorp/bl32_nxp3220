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
#ifndef __TZ_H__
#define __TZ_H__

/*
 * Trust Zone Peripheral Controller (or System Controller)
 */
#define SYS_REGSECURE0				(0x0)
#define SYS_REGSECURE1				(0x0)
#define SYS_REGSECURE2				(0x0)

#define CPU_REGSECURE0				(0x0)

#define USB_REGSECURE0				(0x0)
#define USB_REGSECURE1				(0x0)

#define MM_REGSECURE0				(0x0)
#define MM_REGSECURE1				(0x0)

#define HSIF_REGSECURE0				(0x0)

enum {
	SECURE_ONLY	= 0,
	EVERY_ONE	= 1,
	RESERVED	= 0,
};


struct sys_reg {
	unsigned char bit_00 : 1;
	unsigned char bit_01 : 1;
	unsigned char bit_02 : 1;
	unsigned char bit_03 : 1;
	unsigned char bit_04 : 1;
	unsigned char bit_05 : 1;
	unsigned char bit_06 : 1;
	unsigned char bit_07 : 1;
	unsigned char bit_08 : 1;
	unsigned char bit_09 : 1;
	unsigned char bit_10 : 1;
	unsigned char bit_11 : 1;
	unsigned char bit_12 : 1;
	unsigned char bit_13 : 1;
	unsigned char bit_14 : 1;
	unsigned char bit_15 : 1;
	unsigned char bit_16 : 1;
	unsigned char bit_17 : 1;
	unsigned char bit_18 : 1;
	unsigned char bit_19 : 1;
	unsigned char bit_20 : 1;
	unsigned char bit_21 : 1;
	unsigned char bit_22 : 1;
	unsigned char bit_23 : 1;
	unsigned char bit_24 : 1;
	unsigned char bit_25 : 1;
	unsigned char bit_26 : 1;
	unsigned char bit_27 : 1;
	unsigned char bit_28 : 1;
	unsigned char bit_29 : 1;
	unsigned char bit_30 : 1;
	unsigned char bit_31 : 1;
};

union tzinfo_reg {
	struct sys_reg bit;
	volatile unsigned int value;
};

/*
 * Trust Zone Address Space Controller - 400 (or System Controller)
 */

enum {
	REACTION_TZCINT_LOW_OKAY	= 0,
	REACTION_TZCINT_LOW_DECERR	= 1,
	REACTION_TZCINT_HIGH_OKAY	= 2,
	REACTION_TZCINT_HIGH_DECERR	= 3
};

enum {
	TZC_REGION_0,
	TZC_REGION_1,
	TZC_REGION_2,
	TZC_REGION_3,
	TZC_REGION_4,
	TZC_REGION_5,
	TZC_REGION_6,
	TZC_REGION_7,
	TZC_REGION_8,
	TZC_REGION_9
};

struct tzc400_region_reg {
	volatile unsigned int base_low;						/* 0x000 */
	volatile unsigned int base_high;					/* 0x004 */
	volatile unsigned int top_low;						/* 0x008 */
	volatile unsigned int top_high;						/* 0x00C */
	volatile unsigned int attribute;					/* 0x010 */
	volatile unsigned int id_access;					/* 0x014 */
	volatile unsigned int reserved[2];					/* 0x018 ~ 0x020 */
};

struct tzc400_reg {
	volatile unsigned int build_config;					/* 0x000 */
	volatile unsigned int action;						/* 0x004 */
	volatile unsigned int gate_keepper;					/* 0x008 */
	volatile unsigned int speculation_ctrl;					/* 0x00C */
	volatile unsigned int int_status;					/* 0x010 */
	volatile unsigned int int_clear;					/* 0x014 */
	volatile unsigned int reserved0[2];					/* 0x018 ~ 0x01C */
	volatile unsigned int fail_address_low_0;				/* 0x020 */
	volatile unsigned int fail_address_high_0;				/* 0x024 */
	volatile unsigned int fail_control_0;					/* 0x028 */
	volatile unsigned int fail_id_0;					/* 0x02C */
	volatile unsigned int reserved1[52];					/* 0x030 ~ 0x100 */

	struct tzc400_region_reg region[9];					/* 0x100 ~ 0x220 */
	/* @brief: Unused registers are not implemented. */
};

/* Function Define */
void tzasc_set_regionx(unsigned int index, unsigned int base, unsigned int size,
	unsigned int secure);
void tz_initialize(void);

#endif /* #ifdef __TZ_H__ */
