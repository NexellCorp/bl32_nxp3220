#include <delay.h>
#include <armv7_pmu.h>

void udelay(volatile int us)
{
#if 0
	pmu_delay_us(us);
#else
	register volatile unsigned int i;
	register unsigned int j = us;
	for ( ; j > 0; j--)
		for (i = 6; i > 0; i--);

#endif
}

void mdelay(volatile int ms)
{
	udelay(ms * 1000);
}