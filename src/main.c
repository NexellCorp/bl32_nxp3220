#include <sysheader.h>
#include <tz.h>

/* External Function Define */
extern void build_information(void);

void main(void)
{
	struct sbi_header *pbi
		= ((struct sbi_header *)RE_HEADER_BASEADDR);

	serial_init(2);

	build_information();

//	tz_initialize();
}
