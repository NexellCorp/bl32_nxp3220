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
#include <secure_rw.h>

/* Gloval Variables (To Do..After.. ) */
static struct s_rw_filter g_s_rw_list[2] =
{
	/* Index 0 - Alive GPIO */
	{
		PHY_BASEADDR_ALIVE,
		(PHY_BASEADDR_ALIVE + 0x25C),
		0xFFFFFFFF
	},
	/* Index 1 - eFuse HPM */
	{
		(PHY_BASEADDR_ECID_SECURE_MODULE + 0x530),
		(PHY_BASEADDR_ECID_SECURE_MODULE + 0x530 + 0x3F),
		0xFFFFFFFF
	},
};

static unsigned int check_rw_list(unsigned int addr, unsigned int value)
{
	volatile unsigned int index = 0, cnt;

	cnt = (sizeof(g_s_rw_list)/sizeof(struct s_rw_filter));

	do {
		if ((g_s_rw_list[index].start <= addr)
			&& (g_s_rw_list[index].end >= addr)) {
			value &= g_s_rw_list[index].mask;
			return value;
		}
	} while(index++ < cnt);

	return value;
}

int secure_write_32(void *addr, unsigned int value)
{
	volatile unsigned int cal_value;

	/* Check the Secure R/W Memory */
	cal_value = check_rw_list((unsigned int)addr, value);

	return mmio_write_32(addr, cal_value);
}

int secure_read_32(void *addr)
{
	volatile unsigned int cal_value, value;

	value = mmio_read_32(addr);

	/* Check the Secure R/W Memory */
	cal_value = check_rw_list((unsigned int)addr, value);

	return cal_value;
}
