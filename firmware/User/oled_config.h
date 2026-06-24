#ifndef __OLED_CONFIG_H
#define __OLED_CONFIG_H

/* 本固件面向：标准 STM32F103C8T6 + 外接 0.96" 7-pin SPI OLED (SSD1306)
 * 不含板载 TFT。引脚与示例 SPI接口液晶显示中文字符串数字(标准库)/Source/oled.h 一致：
 *   PB8=SCLK  PB9=SDIN(MOSI)  PB13=DC  PB14=CS
 * 模块 RES 建议接 3.3V（固件不占用 RST 引脚）。
 * 串口灯 PA6、切换键 PA7（标准最小系统板布局）。
 */

#define OLED_SCLK_GPIO          GPIOB
#define OLED_SCLK_PIN           GPIO_Pin_8
#define OLED_SDIN_GPIO          GPIOB
#define OLED_SDIN_PIN           GPIO_Pin_9
#define OLED_DC_GPIO            GPIOB
#define OLED_DC_PIN             GPIO_Pin_13
#define OLED_CS_GPIO            GPIOB
#define OLED_CS_PIN             GPIO_Pin_14

#define OLED_WIDTH              128
#define OLED_HEIGHT             64
#define OLED_UI_REFRESH_MS      500

#endif
