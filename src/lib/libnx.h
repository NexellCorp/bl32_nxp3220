#ifndef __LIBNX_H__
#define __LIBNX_H__

void *memcpy(void *dest, const void *src, int n);
void *memset(void *str, int c, int n);
int memcmp(const void* s1, const void* s2, int n);

/* Define Function */
unsigned long abs(int n);

int round_up(double x);

unsigned int get_quotient(unsigned int dividend, unsigned int divisor);
unsigned int get_remainder(unsigned int dividend, unsigned int divisor);

#endif // ifndef __LIBNX_H__
