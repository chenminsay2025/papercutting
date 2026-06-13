#ifndef __BOARD_H
#define __BOARD_H

#include "stm32f10x.h"

/* 伸缩杆: PA0=缩回, PA1=伸出 */
#define MOTOR_RETRACT_PIN   GPIO_Pin_0
#define MOTOR_EXTEND_PIN    GPIO_Pin_1
#define MOTOR_GPIO          GPIOA

/* 继电器: PA2=继续(A), PA3=原点(B) */
#define RELAY_A_PIN         GPIO_Pin_2
#define RELAY_B_PIN         GPIO_Pin_3
#define RELAY_GPIO          GPIOA

/* USART1: PA9=TX, PA10=RX (USB-TTL) */
#define SERIAL_USART        USART1
#define SERIAL_BAUDRATE     115200

void Board_Init(void);
void Board_TickInc(void);
void Board_FeedWatchdog(void);
void Board_DelayMs(uint32_t ms);
uint32_t Board_GetTickMs(void);

#endif
