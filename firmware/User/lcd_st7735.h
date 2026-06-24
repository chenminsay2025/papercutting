#ifndef __LCD_ST7735_H
#define __LCD_ST7735_H

#include <stdint.h>
#include "lcd_img.h"

#define LCD_COLOR_BLACK   0x0000
#define LCD_COLOR_WHITE   0xFFFF
#define LCD_COLOR_GREEN   0x07E0
#define LCD_COLOR_YELLOW  0xFFE0
#define LCD_COLOR_RED     0xF800
#define LCD_COLOR_CYAN    0x07FF
#define LCD_COLOR_BLUE    0x001F
#define LCD_COLOR_GRAY    0x8410
#define LCD_COLOR_UI_CYAN 0x67FF
#define LCD_COLOR_UI_LINE 0x528A

void Lcd_Init(void);
void Lcd_Fill(uint16_t color);
void Lcd_FillRect(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint16_t color);
void Lcd_BlitRgb565(uint16_t x, uint16_t y, uint16_t w, uint16_t h, const uint16_t *data);
void Lcd_BlitImg(uint16_t x, uint16_t y, const LcdImg_t *img);
void Lcd_BlitImgBright(uint16_t x, uint16_t y, const LcdImg_t *img, uint8_t bright);
void Lcd_BlitImgHScroll(uint16_t x, uint16_t y, uint16_t view_w, const LcdImg_t *img,
	uint16_t tile_w, uint16_t scroll, uint8_t bright);
void Lcd_DrawChar(uint16_t x, uint16_t y, char c, uint16_t fg, uint16_t bg, uint8_t scale);
void Lcd_DrawString(uint16_t x, uint16_t y, const char *text, uint16_t fg, uint16_t bg, uint8_t scale);
void Lcd_DrawCharScaledFrac(uint16_t x, uint16_t y, char c, uint16_t fg, uint16_t bg, uint8_t num, uint8_t den);
void Lcd_DrawStringScaledFrac(uint16_t x, uint16_t y, const char *text, uint16_t fg, uint16_t bg, uint8_t num, uint8_t den);
void Lcd_DrawStringGb16(uint16_t x, uint16_t y, const char *text, uint16_t fg, uint16_t bg);
uint8_t Lcd_Gb16CharAdvance(char c);
void Lcd_DrawChinese16(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg);
void Lcd_DrawChinese(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg);
void Lcd_DrawChineseScaled(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg, uint8_t scale);
void Lcd_DrawChineseScaledFrac(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg, uint8_t num, uint8_t den);

uint8_t Lcd_Probe(void);
void Lcd_GpioRelease(void);

#endif
