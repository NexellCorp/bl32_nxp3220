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
#ifndef __NXP3220_H__
#define __NXP3220_H__

#define SRAM_BASEADDR			0xFFFF0000
#define BL32_BASEADDR			0x5F000000
#define BL32_SIZE			(16 * 1024 * 1024)
#define	SVC_STACK_SIZE			(0x400)
#define MON_STACK_SIZE			(0x400)

#define RE_HEADER_BASEADDR		(SRAM_BASEADDR + (64 * 1024) - (1 * 1024) + (256 * 3))

#endif // __NXP3220_H__
