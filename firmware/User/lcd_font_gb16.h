#ifndef __LCD_FONT_GB16_H
#define __LCD_FONT_GB16_H

#include <stdint.h>

typedef struct
{
	uint8_t Index[2];
	uint8_t Msk[32];
} LcdFontGb16_t;

extern const LcdFontGb16_t g_lcd_font_gb16[];
extern const uint16_t g_lcd_font_gb16_count;

#endif
