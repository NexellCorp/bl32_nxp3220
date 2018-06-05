#ifndef __LIBARMV7_H__
#define __LIBARMV7_H__

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

#endif	// __LIBARMV7_H__
