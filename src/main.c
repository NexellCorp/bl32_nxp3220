#include <sysheader.h>
#include <tz.h>

/* External Function Define */
extern void build_information(void);

void main(void)
{
	struct sbi_header *pbi
		= ((struct sbi_header *)RE_HEADER_BASEADDR);
	unsigned int serial_ch = pbi->serial_ch;

	serial_init(serial_ch);

	build_information();

//	tz_initialize();
}
