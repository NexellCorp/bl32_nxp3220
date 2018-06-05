#include <libnx.h>

void *memcpy(void *dest, const void *src, int n)
{
	const char *s = src;
	char *d = dest;

	while (n--)
		*d++ = *s++;

	return dest;
}

void *memset(void *str, int c, int n)
{
	char *pdata = str;
	while (n--)
		*pdata++ = c;
	return str;
}

int memcmp(const void* s1, const void* s2, int n)
{
	const char *src1 = s1, *src2 = s2;

	while (n--) {
		char res = *src1++ - *src2++;
		if (res)
			return (res);
	}
	return 0;
}

unsigned long abs(int n)
{
	if (n < 0)
		n =- n;

	return n;
}

int round_up(double x)
{
	if (x >= 0)
		return (int) (x + 0.5);
	return (int) (x - 0.5);
}

unsigned int get_quotient(unsigned int dividend, unsigned int divisor)
{
	unsigned int quotient, remainder;
	unsigned int t, num_bits;
	unsigned int q, bit, d = 0;
	unsigned int i;

	remainder = 0;
	quotient = 0;

	if (divisor == 0)
		return -1;

	if (divisor > dividend) {
		return 0;
	}

	if (divisor == dividend) {
		return 1;
	}

	num_bits = 32;

	while (remainder < divisor) {
		bit = (dividend & 0x80000000) >> 31;
		remainder = (remainder << 1) | bit;
		d = dividend;
		dividend = dividend << 1;
		num_bits--;
	}

	dividend = d;
	remainder = remainder >> 1;
	num_bits++;

	for (i = 0; i < num_bits; i++) {
		bit = (dividend & 0x80000000) >> 31;
		remainder = (remainder << 1) | bit;
		t = remainder - divisor;
		q = !((t & 0x80000000) >> 31);
		dividend = dividend << 1;
		quotient = (quotient << 1) | q;
		if (q) {
			remainder = t;
		}
	}
	return quotient;
}

unsigned int get_remainder(unsigned int dividend, unsigned int divisor)
{
	unsigned int quotient, remainder;
	unsigned int t, num_bits;
	unsigned int q, bit, d = 0;
	unsigned int i;

	remainder = 0;
	quotient = 0;

	if (divisor == 0)
		return -1;

	if (divisor > dividend) {
		return dividend;
	}

	if (divisor == dividend) {
		return 0;
	}

	num_bits = 32;

	while (remainder < divisor) {
		bit = (dividend & 0x80000000) >> 31;
		remainder = (remainder << 1) | bit;
		d = dividend;
		dividend = dividend << 1;
		num_bits--;
	}

	dividend = d;
	remainder = remainder >> 1;
	num_bits++;

	for (i = 0; i < num_bits; i++) {
		bit = (dividend & 0x80000000) >> 31;
		remainder = (remainder << 1) | bit;
		t = remainder - divisor;
		q = !((t & 0x80000000) >> 31);
		dividend = dividend << 1;
		quotient = (quotient << 1) | q;
		if (q) {
			remainder = t;
		}
	}
	return remainder;
}
