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
#include <sysheader.h>
#include <tz.h>

/* External Function Define */
extern void build_information(void);

void main(void)
{
	struct sbi_header *pbi
		= ((struct sbi_header *)RE_HEADER_BASEADDR);
	unsigned int serial_ch = pbi->serial_ch;

	serial_init(serial_ch);

	build_information();

	tz_initialize();
}
