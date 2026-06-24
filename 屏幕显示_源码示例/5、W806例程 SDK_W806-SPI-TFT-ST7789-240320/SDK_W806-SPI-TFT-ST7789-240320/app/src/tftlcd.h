/*************************************************************************************************
 ****@CompanyName  : 深圳市沃乐康科技有限公司
 ****@FileName     : tftlcd.h
 ****@Description  : LCD头文件  配置参数
 ****@Contact      : www.wlklcd.com   https://wlklcd.1688.com/  0755-32882855   woleconn@163.com
 ****@Remark       : 
**************************************************************************************************/
#ifndef __TFTLCD_H__
#define __TFTLCD_H__

#include "wm_hal.h"
#include "font.h"

#define ST7789_SPI	1       //使用SPI接口时，SPI定义为1,8080定义为0
#define ST7789_8080	0       //使用8080并口时，8080定义为1,SPI定义为0

#define Screen_W 240        //显示宽度像素数
#define Screen_H 320        //显示高度像素数


#define ST7789_HSD154IPS 0
#define ST7789_CTC24TN   0
#define ST7789_CTC20IPS  1

#define TFTLCD_X_OFFSET 0
#define TFTLCD_Y_OFFSET 0
#define TFTLCD_DIR  0

#define Screen_Color_Alpha   0x10000

#define RED_16B   0xf800
#define GREEN_16B 0x07e0
#define BLUE_16B  0x001f
#define BLACK_16B 0x0000
#define WHITE_16B 0xffff

#if ST7789_SPI
#include "st7789_serial.h"     //SPI接口配置文件
#endif
#if ST7789_8080
#include "st7789_parallel.h"   //8080并口配置文件
#endif

void LCD_Back_On(void);
void LCD_Back_Off(void);
void LCD_Init(void);

void Set_Screen_Windows(uint16_t sx, uint16_t sy, uint16_t width, uint16_t height);
void LCD_Fill(uint16_t xs, uint16_t ys, uint16_t xe, uint16_t ye, uint16_t color);
void LCD_DrawPoint(uint16_t x, uint16_t y, uint16_t color);
void LCD_DrawLine(uint16_t xs, uint16_t ys, uint16_t xe, uint16_t ye, uint16_t color);
void LCD_DrawRectangle(uint16_t xs, uint16_t ys, uint16_t xe, uint16_t ye, uint16_t border,uint16_t fill);
void LCD_DrawCircle(uint16_t x, uint16_t y, uint8_t r, uint16_t color);
void LCD_ShowPicture(uint16_t x, uint16_t y, uint16_t length, uint16_t width, uint8_t *data);

void tftlcd_show_string(uint16_t x, uint16_t y, uint16_t width, char *str, uint8_t size, uint16_t pcolor, uint16_t bcolor);
void tftlcd_show_font_string(uint16_t x, uint16_t y, uint16_t width, uint16_t height, char *str, uint8_t size, uint16_t pcolor, uint16_t bcolor);

#endif