#ifndef __NXP3220_H__
#define __NXP3220_H__

#define SRAM_BASEADDR			0xFFFF0000
#define BL32_BASEADDR			0x5E000000
#define BL32_SIZE			(32 * 1024 * 1024)
#define	SVC_STACK_SIZE			(0x400)
#define MON_STACK_SIZE			(0x400)

#define RE_HEADER_BASEADDR		(SRAM_BASEADDR + (64 * 1024) - 256)

#endif // __NXP3220_H__
