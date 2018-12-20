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
#include <uart.h>
#include <serial.h>

static volatile unsigned int g_uart_reg;

static int serial_get_baseaddr(unsigned int channel)
{
	return (PHY_BASEADDR_UART_CH0 + (channel * 0x10000));
}

int serial_init(unsigned int channel)
{
	g_uart_reg = serial_get_baseaddr(channel);

	return 0;
}

int serial_is_tx_empty(void)
{
	return (int)(!(mmio_read_32(g_uart_reg + USR) & TX_FIFO_NOTEMPTY));
}

int serial_is_rx_empty(void)
{
	return (int)(!(mmio_read_32(g_uart_reg + USR) & RX_FIFO_NOTEMPTY));
}

char serial_getc(void)
{
	while (!(mmio_read_32(g_uart_reg + USR) & RX_FIFO_NOTEMPTY));
	return (char)mmio_read_32(g_uart_reg + RBR);
}

void serial_putc(char ch)
{
	while (!(mmio_read_32(g_uart_reg + USR) & TX_FIFO_NOTFULL));
	mmio_write_32((g_uart_reg + THR), (unsigned int)ch);
}

int serial_is_busy(void)
{
	return (int)(mmio_read_32(g_uart_reg + USR) & UART_BUSY);
}

int serial_is_uart_tx_done(void)
{
	int tx_empty = (int)(!(mmio_read_32(g_uart_reg + USR) & TX_FIFO_NOTEMPTY));
	int busy = (int)(mmio_read_32(g_uart_reg + USR) & UART_BUSY);

	if (tx_empty && !busy)
		return 1;

	return 0;
}