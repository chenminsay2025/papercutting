#include "usart_serial.h"
#include <string.h>

static char s_rx_line[SERIAL_RX_BUF_SIZE];
static volatile uint8_t s_line_ready = 0;
static volatile uint16_t s_rx_len = 0;

static void Serial_ResetBuffer(void)
{
	s_rx_len = 0;
	s_line_ready = 0;
}

static void Serial_PushChar(char ch)
{
	/* Ignore CR; host sends CRLF and LF terminates the line. */
	if (ch == '\r')
	{
		return;
	}

	if (ch == '\n')
	{
		if (s_rx_len > 0)
		{
			s_rx_line[s_rx_len] = '\0';
			s_line_ready = 1;
		}
		return;
	}

	if (s_line_ready)
	{
		return;
	}

	if (s_rx_len >= SERIAL_RX_BUF_SIZE - 1)
	{
		Serial_ResetBuffer();
		return;
	}

	s_rx_line[s_rx_len++] = ch;
}

void Serial_Init(void)
{
	GPIO_InitTypeDef gpio;
	USART_InitTypeDef usart;
	NVIC_InitTypeDef nvic;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA | RCC_APB2Periph_USART1, ENABLE);

	gpio.GPIO_Mode = GPIO_Mode_AF_PP;
	gpio.GPIO_Pin = GPIO_Pin_9;
	gpio.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOA, &gpio);

	gpio.GPIO_Mode = GPIO_Mode_IN_FLOATING;
	gpio.GPIO_Pin = GPIO_Pin_10;
	GPIO_Init(GPIOA, &gpio);

	usart.USART_BaudRate = SERIAL_BAUDRATE;
	usart.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
	usart.USART_Mode = USART_Mode_Tx | USART_Mode_Rx;
	usart.USART_Parity = USART_Parity_No;
	usart.USART_StopBits = USART_StopBits_1;
	usart.USART_WordLength = USART_WordLength_8b;
	USART_Init(SERIAL_USART, &usart);

	USART_ITConfig(SERIAL_USART, USART_IT_RXNE, ENABLE);

	nvic.NVIC_IRQChannel = USART1_IRQn;
	nvic.NVIC_IRQChannelCmd = ENABLE;
	nvic.NVIC_IRQChannelPreemptionPriority = 1;
	nvic.NVIC_IRQChannelSubPriority = 1;
	NVIC_Init(&nvic);

	USART_Cmd(SERIAL_USART, ENABLE);
}

void Serial_SendString(const char *str)
{
	while (*str)
	{
		while (USART_GetFlagStatus(SERIAL_USART, USART_FLAG_TXE) == RESET);
		USART_SendData(SERIAL_USART, (uint16_t)(*str));
		str++;
	}
}

void Serial_SendLine(const char *str)
{
	Serial_SendString(str);
	Serial_SendString("\r\n");
}

uint8_t Serial_ReadLine(char *line, uint16_t max_len)
{
	uint16_t copy_len;
	uint32_t primask;

	primask = __get_PRIMASK();
	__disable_irq();

	if (!s_line_ready)
	{
		__set_PRIMASK(primask);
		return 0;
	}

	copy_len = s_rx_len;
	if (copy_len >= max_len)
	{
		copy_len = max_len - 1;
	}
	memcpy(line, s_rx_line, copy_len);
	line[copy_len] = '\0';
	s_rx_len = 0;
	s_line_ready = 0;

	__set_PRIMASK(primask);
	return 1;
}

void USART1_IRQHandler(void)
{
	if (USART_GetITStatus(SERIAL_USART, USART_IT_RXNE) != RESET)
	{
		char ch = (char)USART_ReceiveData(SERIAL_USART);
		Serial_PushChar(ch);
	}
}
