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