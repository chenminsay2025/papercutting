#include "stm32f10x.h"
#include "board.h"
#include "motor.h"
#include "relay.h"
#include "usart_serial.h"
#include "protocol.h"
#include "led.h"

int main(void)
{
	/* 最先拉低 PA0/PA1，避免上电瞬间继电器 IN1/IN2 因浮空误触发 */
	Motor_Init();
	Board_Init();
	Relay_Init();
	Led_Init();
	Serial_Init();
	Protocol_Init();

	Serial_SendLine("OK:BOOT");

	while (1)
	{
		Protocol_Poll();
		Protocol_CheckCommTimeout();
		Relay_Tick();
		Led_Tick();
		Board_FeedWatchdog();
	}
}
