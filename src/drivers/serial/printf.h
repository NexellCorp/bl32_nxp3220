#ifndef __K_PRINTF__
#define __K_PRINTF__

#include <stdarg.h>
#include <serial.h>

#define getc		serial_getc
#define putc		serial_putc

#define serial_done	serial_is_uart_tx_done
#define serial_busy	serial_is_busy
#define serial_tx_empty	serial_is_tx_empty

int printf(const char *format, ...);
int empty_printf(const char *format, ...);

#endif
