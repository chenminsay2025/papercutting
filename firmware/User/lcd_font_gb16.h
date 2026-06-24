#ifndef __LCD_FONT_GB16_H
#define __LCD_FONT_GB16_H

#include <stdint.h>

#define LCD_GB16_W           16u
#define LCD_GB16_H           16u
#define LCD_GB16_ROW_BYTES   2u
#define LCD_GB16_AA_LEVELS   16u
#if (LCD_GB16_AA_LEVELS > 0u)
#define LCD_GB16_MSK_BYTES   (((LCD_GB16_W * LCD_GB16_H) + 1u) / 2u)
#else
#define LCD_GB16_MSK_BYTES   (LCD_GB16_H * LCD_GB16_ROW_BYTES)
#endif
#define LCD_GB16_HALF_W      8u

typedef struct
{
	uint8_t Index[2];
	uint8_t AdvW;
	uint8_t Msk[LCD_GB16_MSK_BYTES];
} LcdFontGb16_t;

extern const LcdFontGb16_t g_lcd_font_gb16[];
extern const uint16_t g_lcd_font_gb16_count;

#endif
