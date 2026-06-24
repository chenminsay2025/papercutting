#ifndef __OLED_SSD1306_H
#define __OLED_SSD1306_H

#include <stdint.h>

#define OLED_CMD  0
#define OLED_DATA 1

void Oled_Init(void);
void Oled_Clear(void);
void Oled_ShowChar(uint8_t x, uint8_t y, char chr);
void Oled_ShowString(uint8_t x, uint8_t y, const char *text);
void Oled_ShowChinese(uint8_t x, uint8_t y, const char *gb2312_text);

#endif
