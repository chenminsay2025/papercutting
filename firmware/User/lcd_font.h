#ifndef __LCD_FONT_H
#define __LCD_FONT_H

#include <stdint.h>

#define LCD_FONT_W  6
#define LCD_FONT_H  8

const uint8_t *LcdFont_GetGlyph(char c);

#endif
