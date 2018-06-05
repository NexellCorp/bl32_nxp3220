#ifndef __SERIAL_H__
#define __SERIAL_H__

/* Function Define */
 int serial_init(unsigned int channel);

char serial_getc(void);
void serial_putc(char ch);

 int serial_is_uart_tx_done(void);
 int serial_is_tx_empty(void);
 int serial_is_busy(void);

#endif	//#ifndef __SERIAL_H__
