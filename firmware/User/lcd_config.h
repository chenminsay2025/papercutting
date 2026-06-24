#ifndef __LCD_CONFIG_H
#define __LCD_CONFIG_H

/* WLK2401SPI-8P  2.4" 240×320 ST7789V  8 针 SPI（GND VCC SCL SDA RES DC CS BLC）
 * 引脚与 屏幕显示_源码示例/STM32例程…Hardware4SPI(SPI2)/HARDWARE/LCD/lcd.h 一致
 *
 * BOARD_LCD_MODE（同一固件适配有屏 / 无屏 C8T6）:
 *   0 = 上电自动检测 ST7789（检测失败则按无屏标准板：PA6=串口灯 PA7=按键）
 *   1 = 强制外接 2.4 寸 LCD（PB9=串口灯 PB8=按键，启用 LCD UI）
 *   2 = 强制无 LCD 标准板（不初始化 LCD 引脚）
 */
#define BOARD_LCD_MODE          1
#define LCD_DRIVER_ST7789       1
#define LCD_USE_HARD_SPI        1
#define LCD_USE_SOFT_SPI        0

/* 0/1=竖屏 240×320   2/3=横屏 320×240 */
#define LCD_USE_HORIZONTAL      0

#if LCD_USE_HORIZONTAL == 0 || LCD_USE_HORIZONTAL == 1
#define LCD_WIDTH               240
#define LCD_HEIGHT              320
#define LCD_X_OFFSET            0
#define LCD_Y_OFFSET            0
#if LCD_USE_HORIZONTAL == 0
#define LCD_MADCTL_VAL          0x00
#else
#define LCD_MADCTL_VAL          0xC0
#endif
#else
#define LCD_WIDTH               320
#define LCD_HEIGHT              240
#define LCD_X_OFFSET            0
#define LCD_Y_OFFSET            0
#if LCD_USE_HORIZONTAL == 2
#define LCD_MADCTL_VAL          0x70
#else
#define LCD_MADCTL_VAL          0xA0
#endif
#endif

/* 例程 lcd.h：SPI2 硬件 SCL/SDA，其余 GPIO */
#define LCD_SCK_GPIO            GPIOB
#define LCD_SCK_PIN             GPIO_Pin_13
#define LCD_MOSI_GPIO           GPIOB
#define LCD_MOSI_PIN            GPIO_Pin_15
#define LCD_CS_GPIO             GPIOB
#define LCD_CS_PIN              GPIO_Pin_12
#define LCD_DC_GPIO             GPIOB
#define LCD_DC_PIN              GPIO_Pin_14
#define LCD_RST_GPIO            GPIOB
#define LCD_RST_PIN             GPIO_Pin_11
#define LCD_BLK_GPIO            GPIOB
#define LCD_BLK_PIN             GPIO_Pin_10
#define LCD_BLK_ACTIVE_LOW      0

#endif
