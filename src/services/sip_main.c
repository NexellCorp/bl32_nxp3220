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

/* Macro for Secure Write/Read  */
#define SECURE_HWREG_WRITE		0x82000000
#define SECURE_HWREG_READ		0x82000001
#define SIP_PLATFORM_LOAD		0x82000002
#define PMU_BLK_PWRUP			0x82000003

#define SECURE_EFUSE_READ		0x82000010
#define SECURE_EFUSE_WRITE		0x82000011

/* External Function Define */
extern int smc_get_fnptr(void);

int bl1_smc_handler(unsigned int smc_fid,
	unsigned int r1, unsigned int r2, unsigned int r3)
{
	unsigned int (*handler)(unsigned int, unsigned int,
		unsigned int, unsigned int) =
		(unsigned int (*)(unsigned int, unsigned int,
			unsigned int, unsigned int))smc_get_fnptr();
	DBGOUT(" SMC Handler: %X \n", handler);
	return handler(smc_fid, r1, r2, r3);
}

struct res_s {
	int a0;
	int a1;
	int a2;
	int a3;
};

/*******************************************************************************
 * For implementing the functions defiend by the user, the SIP interface the
 * main function
 ******************************************************************************/
int sip_smc_handler(unsigned int smc_fid,
	unsigned int r1, unsigned int r2, unsigned int r3)
{
	int ret = 0;

	switch (smc_fid) {
#if 0
		case SECURE_HWREG_WRITE:
			return secure_write_32((void*)r1, r2);
		case SECURE_HWREG_READ:
			return secure_read_32((void*)r1);
#endif
		case SECURE_EFUSE_WRITE:
			printf("Secure Efuse Write!! \n");
			break;
		case SECURE_EFUSE_READ:
			printf("Secure Efuse Read!! \n");
			break;
		default:
			ret = false;
			break;
	}

	if (ret != 0)
		return bl1_smc_handler(smc_fid, r1, r2, r3);

	return ret;
}
