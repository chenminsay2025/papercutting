#ifndef __BOARD_H
#define __BOARD_H

#include "stm32f10x.h"

/* 四路继电器 H 桥：PA0=IN1 缩回，PA1=IN2 伸出；COM1/COM2 接电机 */
#define MOTOR_RETRACT_PIN   GPIO_Pin_0
#define MOTOR_EXTEND_PIN    GPIO_Pin_1
#define MOTOR_GPIO          GPIOA

/* 继电器: PA2=继续(A), PA3=原点(B) */
#define RELAY_A_PIN         GPIO_Pin_2
#define RELAY_B_PIN         GPIO_Pin_3
#define RELAY_GPIO          GPIOA

/* LED: PA4=缩回, PA5=伸出；串口灯见 Board_LedComGpio/Pin */
#define LED_RETRACT_PIN     GPIO_Pin_4
#define LED_EXTEND_PIN      GPIO_Pin_5
#define LED_MOTOR_GPIO      GPIOA

#define BUTTON_ACTION_MS    3000

/* 槽型光电: PA8=DO（缩回终点检测；有遮挡=缩回位 HOME） */
#define ROD_SENSOR_PIN      GPIO_Pin_8
#define ROD_SENSOR_GPIO     GPIOA

/* 有源蜂鸣器: PB0（C8T6 排针 B0）
 * BUZZER_ACTIVE_LOW=1：低电平响（多数三脚/开集电极模块，默认）
 * BUZZER_ACTIVE_LOW=0：高电平响（I/O 高触发模块） */
#ifndef BUZZER_ACTIVE_LOW
#define BUZZER_ACTIVE_LOW     1
#endif

#define BUZZER_PIN          GPIO_Pin_0
#define BUZZER_GPIO         GPIOB

/* KY-032 红外避障: PB6=S，EN 跳线 GND，LOW=有遮挡 */
#define OBSTACLE_PIN        GPIO_Pin_6
#define OBSTACLE_GPIO       GPIOB

/* USART1: PA9=TX, PA10=RX (USB-TTL) */
#define SERIAL_USART        USART1
#define SERIAL_BAUDRATE     115200

void Board_Init(void);
void Board_DetectHardware(void);
uint8_t Board_HasOnboardLcd(void);
GPIO_TypeDef *Board_LedComGpio(void);
uint16_t Board_LedComPin(void);
GPIO_TypeDef *Board_ButtonGpio(void);
uint16_t Board_ButtonPin(void);
void Board_WatchdogInit(void);
void Board_TickInc(void);
void Board_FeedWatchdog(void);
void Board_DelayMs(uint32_t ms);
uint32_t Board_GetTickMs(void);

#endif
