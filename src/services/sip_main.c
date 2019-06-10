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
#include <sysheader.h>

/* Macro for Secure Write/Read  */
#define SECURE_HWREG_WRITE		0x82000000
#define SECURE_HWREG_READ		0x82000001

#define SECURE_EFUSE_READ		0x82000010
#define SECURE_EFUSE_WRITE		0x82000011

/* Macro for PSCI Interface (Extra) */
#define PSCI_SYSTEM_SUSPEND_AARCH32	0x8400000E

/* External Function Define */
extern int smc_get_fnptr(void);

int bl1_smc_handler(unsigned int smc_fid,
	unsigned int r1, unsigned int r2, unsigned int r3)
{
	unsigned int (*handler)(unsigned int, unsigned int,
		unsigned int, unsigned int) =
		(unsigned int (*)(unsigned int, unsigned int,
			unsigned int, unsigned int))smc_get_fnptr();
	INFO(" SMC Handler: %X \n", handler);
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
		/*
		 * @brief: Performs the required action upon chip suspend entry.
		 * It will be deleted after a few weeks.
		 */
		case PSCI_SYSTEM_SUSPEND_AARCH32:
			v7_flush_kern_cache_all();
			ret = false;
			break;
		default:
			ret = false;
			break;
	}

	if (ret != 0)
		return bl1_smc_handler(smc_fid, r1, r2, r3);

	return ret;
}
