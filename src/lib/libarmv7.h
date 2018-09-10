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
#ifndef __LIBARMV7_H__
#define __LIBARMV7_H__

void secure_launch(unsigned int is_resume, unsigned int secure_os_addr,
		unsigned int non_secure_addr, unsigned int bootarg);
void non_secure_launch(unsigned int is_resume, unsigned int n_secure);

/* "libarmv7.S" armv7 function */
void set_nonsecure_mode(void);
void set_secure_mode(void);

 int get_secure_status(void);

 int armv7_get_scr(void);
void armv7_set_scr(int reg);

 int armv7_get_auxctrl(void);
void armv7_set_auxctrl(int value);

 int armv7_get_cpuid(void);

/* functions added by the chip-dependent user. */
 int bl0_get_fnptr(void);
void bl0_set_fnptr(int);

 int get_bootoption(void);
void set_bootoption(int);

void v7_flush_kern_cache_all(void);

#endif	// __LIBARMV7_H__
