#include "usart_serial.h"
#include "board.h"
#include <string.h>

#define SERIAL_LINE_QUEUE  32

static char s_rx_queue[SERIAL_LINE_QUEUE][SERIAL_RX_BUF_SIZE];
static char s_building[SERIAL_RX_BUF_SIZE];
static volatile uint8_t s_q_w = 0;
static volatile uint8_t s_q_r = 0;
static volatile uint8_t s_q_count = 0;
static volatile uint16_t s_build_len = 0;

static void Serial_ResetBuilding(void)
{
	s_build_len = 0;
}

static void Serial_EnqueueLine(void)
{
	if (s_build_len == 0)
	{
		return;
	}
	if (s_q_count >= SERIAL_LINE_QUEUE)
	{
		Serial_ResetBuilding();
		return;
	}

	memcpy(s_rx_queue[s_q_w], s_building, s_build_len);
	s_rx_queue[s_q_w][s_build_len] = '\0';
	s_q_w = (uint8_t)((s_q_w + 1u) % SERIAL_LINE_QUEUE);
	s_q_count++;
	Serial_ResetBuilding();
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
		Serial_EnqueueLine();
		return;
	}

	if (s_build_len >= SERIAL_RX_BUF_SIZE - 1u)
	{
		Serial_ResetBuilding();
		return;
	}

	s_building[s_build_len++] = ch;
}

void Serial_Init(void)
{
	GPIO_InitTypeDef gpio;
	USART_InitTypeDef usart;
	NVIC_InitTypeDef nvic;

	s_q_w = 0;
	s_q_r = 0;
	s_q_count = 0;
	Serial_ResetBuilding();

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
		while (USART_GetFlagStatus(SERIAL_USART, USART_FLAG_TXE) == RESET)
			;
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

	if (s_q_count == 0u)
	{
		__set_PRIMASK(primask);
		return 0;
	}

	copy_len = (uint16_t)strlen(s_rx_queue[s_q_r]);
	if (copy_len >= max_len)
	{
		copy_len = (uint16_t)(max_len - 1u);
	}
	memcpy(line, s_rx_queue[s_q_r], copy_len);
	line[copy_len] = '\0';
	s_q_r = (uint8_t)((s_q_r + 1u) % SERIAL_LINE_QUEUE);
	s_q_count--;

	__set_PRIMASK(primask);
	return 1;
}

void USART1_IRQHandler(void)
{
	if (USART_GetFlagStatus(SERIAL_USART, USART_FLAG_ORE) != RESET ||
	    USART_GetFlagStatus(SERIAL_USART, USART_FLAG_FE) != RESET ||
	    USART_GetFlagStatus(SERIAL_USART, USART_FLAG_NE) != RESET)
	{
		(void)USART_ReceiveData(SERIAL_USART);
		return;
	}

	if (USART_GetITStatus(SERIAL_USART, USART_IT_RXNE) != RESET)
	{
		char ch = (char)USART_ReceiveData(SERIAL_USART);
		Serial_PushChar(ch);
	}
}
