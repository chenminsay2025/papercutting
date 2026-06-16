#ifndef __LCD_ST7735_H
#define __LCD_ST7735_H

#include <stdint.h>

#define LCD_COLOR_BLACK   0x0000
#define LCD_COLOR_WHITE   0xFFFF
#define LCD_COLOR_GREEN   0x07E0
#define LCD_COLOR_YELLOW  0xFFE0
#define LCD_COLOR_RED     0xF800
#define LCD_COLOR_CYAN    0x07FF
#define LCD_COLOR_BLUE    0x001F
#define LCD_COLOR_GRAY    0x8410

void Lcd_Init(void);
void Lcd_Fill(uint16_t color);
void Lcd_FillRect(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint16_t color);
void Lcd_DrawChar(uint16_t x, uint16_t y, char c, uint16_t fg, uint16_t bg, uint8_t scale);
void Lcd_DrawString(uint16_t x, uint16_t y, const char *text, uint16_t fg, uint16_t bg, uint8_t scale);
void Lcd_DrawChinese16(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg);
void Lcd_DrawChinese(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg);

#endif
