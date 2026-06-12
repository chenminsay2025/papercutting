#ifndef __USART_SERIAL_H
#define __USART_SERIAL_H

#include "stm32f10x.h"

#define SERIAL_RX_BUF_SIZE 128

void Serial_Init(void);
void Serial_SendString(const char *str);
void Serial_SendLine(const char *str);
uint8_t Serial_ReadLine(char *line, uint16_t max_len);

#endif
