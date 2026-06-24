#ifndef __LCD_FONT_ASCII16_H
#define __LCD_FONT_ASCII16_H

#include <stdint.h>

#define LCD_FONT_ASCII16_W  8
#define LCD_FONT_ASCII16_H  16

const uint8_t *LcdFontAscii16_GetGlyph(char c);

#endif
