#ifndef __LCD_CONFIG_H
#define __LCD_CONFIG_H

/* nologo 0.96" IPS TFT — 引脚与 屏幕显示_源码示例/HARDWARE/LCD/lcd_init.h 一致
 * 例程: https://www.nologo.tech/product/stm32/STM32F103C8T6-C6T60.96TFT/example/example7.html
 */
#define BOARD_HAS_ONBOARD_LCD   1
#define BOARD_NOLOGO_096TFT     1
#define LCD_USE_SOFT_SPI        1
#define LCD_USE_NOLOGO_INIT     1

/* 0=竖屏80x160  2=横屏160x80（与官方 USE_HORIZONTAL 相同） */
#define LCD_USE_HORIZONTAL      0

#if LCD_USE_HORIZONTAL == 0 || LCD_USE_HORIZONTAL == 1
#define LCD_WIDTH               80
#define LCD_HEIGHT              160
#define LCD_X_OFFSET            26
#define LCD_Y_OFFSET            1
#define LCD_MADCTL_VAL          0x08
#else
#define LCD_WIDTH               160
#define LCD_HEIGHT              80
#define LCD_X_OFFSET            1
#define LCD_Y_OFFSET            26
#define LCD_MADCTL_VAL          0x78
#endif

/* 官方 lcd_init.h 端口定义 */
#define LCD_SCK_GPIO            GPIOB
#define LCD_SCK_PIN             GPIO_Pin_10
#define LCD_MOSI_GPIO           GPIOB
#define LCD_MOSI_PIN            GPIO_Pin_11
#define LCD_CS_GPIO             GPIOB
#define LCD_CS_PIN              GPIO_Pin_1
#define LCD_DC_GPIO             GPIOB
#define LCD_DC_PIN              GPIO_Pin_0
#define LCD_RST_GPIO            GPIOA
#define LCD_RST_PIN             GPIO_Pin_7
#define LCD_BLK_GPIO            GPIOA
#define LCD_BLK_PIN             GPIO_Pin_6
#define LCD_BLK_ACTIVE_LOW      1

#endif
