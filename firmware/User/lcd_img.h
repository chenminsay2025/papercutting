#ifndef __LCD_IMG_H
#define __LCD_IMG_H

#include <stdint.h>

typedef struct
{
	uint16_t W;
	uint16_t H;
	const uint16_t *Data;
} LcdImg_t;

extern const LcdImg_t g_lcd_img_paper_press;
extern const LcdImg_t g_lcd_img_paper_lift;
extern const LcdImg_t g_lcd_img_usb_on;
extern const LcdImg_t g_lcd_img_usb_off;
extern const LcdImg_t g_lcd_img_obstacle_blocked;
extern const LcdImg_t g_lcd_img_obstacle_clear;

#endif
