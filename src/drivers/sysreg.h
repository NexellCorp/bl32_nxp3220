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
#ifndef __SYSREG_H__
#define __SYSREG_H__

/* nxp3220 - System Control Reigster for System */
struct nx_sysreg_can_reg {
	volatile unsigned int can_ext_ts;					/* 0x0 		*/
	volatile unsigned int can_mod;						/* 0x4		*/
	volatile unsigned int can_ir;						/* 0x8 		*/
	volatile unsigned int can_txbrp;					/* 0xC		*/
	volatile unsigned int can_cok;						/* 0x10 	*/
	volatile unsigned int rsv[4];						/* 0x14 ~ 0x20	*/
};

/*
 * The register name may be different from the datasheet,
 * but it is named for convenience. See address.
 */
struct nx_sysreg_sys_reg {
	volatile unsigned int spare_ctrl[4];					/* 0x00 ~ 0x10	*/
	volatile unsigned int spare_ctrl_input; 				/* 0x10 	*/
	volatile unsigned int rsv0[7];						/* 0x14 ~ 0x30	*/
	volatile unsigned int spi_ctrl2;					/* 0x30 	*/
	volatile unsigned int spi_ctrl1;					/* 0x34 	*/
	volatile unsigned int spi_ctrl0;					/* 0x38 	*/
	volatile unsigned int rsv1;						/* 0x3C 	*/
	struct nx_sysreg_can_reg can[2];					/* 0x40 ~ 0x80	*/
	volatile unsigned int rsv2[32]; 					/* 0x80 ~ 0x100 */
	volatile unsigned int dpc_padplace;					/* 0x100	*/
	volatile unsigned int rsv3[3];						/* 0x104 ~ 0x110*/
	volatile unsigned int ema[4];						/* 0x110 ~ 0x120*/
	volatile unsigned int rsv4;						/* 0x120	*/
	volatile unsigned int uart6;						/* 0x124 */
	volatile unsigned int uart5;						/* 0x128 */
	volatile unsigned int uart4;						/* 0x12C */
	volatile unsigned int uart3;						/* 0x130 */
	volatile unsigned int uart2;						/* 0x134 */
	volatile unsigned int uart1;						/* 0x138 */
	volatile unsigned int uart0;						/* 0x13C */
	volatile unsigned int tmu;						/* 0x140	*/
	volatile unsigned int rsv5;						/* 0x144	*/
	volatile unsigned int blk_mm_adb;					/* 0x148	*/
	volatile unsigned int rsv6;						/* 0x14C	*/
	volatile unsigned int blk_ddr_adb;					/* 0x150	*/
	volatile unsigned int rsv7[3];						/* 0x154 ~ 0x160*/
	volatile unsigned int blk_usb_adb;					/* 0x160	*/
	volatile unsigned int rsv8[3];						/* 0x164 ~ 0x170*/
	volatile unsigned int blk_hsif_adb;					/* 0x170	*/
	volatile unsigned int rsv9[7];						/* 0x174 ~ 0x190*/
	volatile unsigned int pwrdn_reqn;					/* 0x190	*/
	volatile unsigned int pwrdn_ackn;					/* 0x194	*/
	volatile unsigned int rsv10[26];					/* 0x198 ~ 0x200 */
	volatile unsigned int bus_cfg6; 					/* 0x200 */
	volatile unsigned int bus_cfg7; 					/* 0x204 */
	volatile unsigned int bus_cfg8; 					/* 0x208 */
	volatile unsigned int bus_cfg9; 					/* 0x20C */
	volatile unsigned int rsv11[4]; 					/* 0x210 ~ 0x220 */
	volatile unsigned int bus_cfg10;					/* 0x220 */
	volatile unsigned int rsv12[3]; 					/* 0x224 ~ 0x230 */
	volatile unsigned int bus_cfg11;					/* 0x230 */
	volatile unsigned int bus_cfg12;					/* 0x234 */

	volatile unsigned int rsv13[26];					/* 0x238 ~ 0x2A0*/

	volatile unsigned int dma_boot_manager_ns;				/* 0x2A0	*/
	volatile unsigned int dma0_irq_ns;					/* 0x2A4	*/
	volatile unsigned int dma0_periph_ns;					/* 0x2A8	*/
	volatile unsigned int dma1_irq_ns;					/* 0x2AC	*/
	volatile unsigned int dma1_periph_ns;					/* 0x2B0	*/
	volatile unsigned int sdma0_irq_ns;					/* 0x2B4	*/
	volatile unsigned int sdma0_periph_ns;					/* 0x2B8	*/
	volatile unsigned int sdma1_irq_ns;					/* 0x2BC	*/
	volatile unsigned int sdma1_periph_ns;					/* 0x2C0	*/

	volatile unsigned int mdma_ctrl0;					/* 0x2C4	*/
	volatile unsigned int dma0_ctrl2;					/* 0x2C8	*/
	volatile unsigned int dma1_ctrl2;					/* 0x2CC	*/

	volatile unsigned int rsv14[12];					/* 0x2D0 ~ 0x300*/
	volatile unsigned int pdm;						/* 0x300	*/
	volatile unsigned int rsv15[8]; 					/* 0x304 ~ 0x324*/
	volatile unsigned int mdama0_ns;					/* 0x324	*/
	volatile unsigned int rsv16[54];					/* 0x328 ~ 0x400*/
	volatile unsigned int sss;						/* 0x400	*/
	volatile unsigned int hpm[2];						/* 0x404 ~ 0x40C*/
	volatile unsigned int rsv17;						/* 0x40C	*/
	volatile unsigned int axisram;						/* 0x410	*/
	volatile unsigned int rsv18[3]; 					/* 0x414 ~ 0x420*/
	volatile unsigned int pwm0;						/* 0x420	*/
	volatile unsigned int timer0;						/* 0x424	*/
	volatile unsigned int secure_timer0;					/* 0x428	*/
	volatile unsigned int cssys_0;						/* 0x42C	*/
};

/* nxp3220 - System Control Reigster for USB Block */
struct nx_sysreg_usb_reg {
	volatile unsigned int spare_ctrl[4];					/* 0x00 ~ 0x0C	*/
	volatile unsigned int spare_ctrl_input;					/* 0x10		*/
	volatile unsigned int rsv0[3];						/* 0x14 ~ 0x1C	*/
	volatile unsigned int host_ctrl_reg[7];					/* 0x20 ~ 0x38	*/
	volatile unsigned int usb20phy_host0_ctrl[2];				/* 0x40 ~ 0x44	*/
	volatile unsigned int usb20phy_host0_turn[2];				/* 0x48 ~ 0x4C	*/
	volatile unsigned int usb20phy_host1_ctrl[2];				/* 0x50 ~ 0x54	*/
	volatile unsigned int usb20phy_host1_turn[2];				/* 0x58 ~ 0x5C	*/
	volatile unsigned int otg_ctrl[7];					/* 0x60 ~ 0x78	*/
	volatile unsigned int usb20phy_otg0_ctrl[2];				/* 0x80 ~ 0x84	*/
	volatile unsigned int usb20phy_otg0_turn[2];				/* 0x88 ~ 0x8C	*/
	volatile unsigned int rsv1[29];						/* 0x90 ~ 0xFC	*/
	volatile unsigned int cfg_bus_secure0;					/* 0x100	*/
	volatile unsigned int rsv2[3];						/* 0x104 ~ 0x10C*/
	volatile unsigned int cfg_bus_secure1;					/* 0x110	*/
};

#endif /* #ifndef __SYSREG_H__ */
