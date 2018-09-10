/*
 * Copyright (C) 2018  Nexell Co., Ltd.
 * Author: deoks <truevirtue@nexell.co.kr>
 *
 * Nexell informs that this code and information is provided "as Is" base
 * and without warranty of any kind, either expressed or implied, including,
 * but not limited to the implied warranties of merchantabulity and/or
 * fitness for a aparticular purpose.
 *
 * This program is copyrighted by Nexell and does not allow modification or
 * distribution. In addition to the author (person in charge), the modifier
 * is responsible for the modification.
 */
#include <delay.h>
#include <armv7_pmu.h>

void udelay(volatile int us)
{
#if 0
	pmu_delay_us(us);
#else
	register volatile unsigned int i;
	register unsigned int j = us;
	for ( ; j > 0; j--)
		for (i = 6; i > 0; i--);

#endif
}

void mdelay(volatile int ms)
{
	udelay(ms * 1000);
}