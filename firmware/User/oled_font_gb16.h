#ifndef __OLED_FONT_GB16_H
#define __OLED_FONT_GB16_H

#include <stdint.h>

typedef struct
{
	uint8_t Index[2];
	uint8_t PageTop[16];
	uint8_t PageBottom[16];
} OledFontGb16_t;

extern const OledFontGb16_t g_oled_font_gb16[];
extern const uint16_t g_oled_font_gb16_count;

#endif
