#include "stm32f10x.h"
#include "board.h"
#include "motor.h"
#include "relay.h"
#include "usart_serial.h"
#include "protocol.h"

int main(void)
{
	Board_Init();
	Motor_Init();
	Relay_Init();
	Serial_Init();
	Protocol_Init();

	Serial_SendLine("OK:BOOT");

	while (1)
	{
		Protocol_Poll();
		Protocol_CheckCommTimeout();
		Relay_Tick();
		Board_FeedWatchdog();
	}
}
