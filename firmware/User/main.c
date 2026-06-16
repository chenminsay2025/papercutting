#include "stm32f10x.h"
#include "board.h"
#include "motor.h"
#include "relay.h"
#include "buttons.h"
#include "rod_sensor.h"
#include "lcd_ui.h"
#include "usart_serial.h"
#include "protocol.h"
#include "led.h"

int main(void)
{
	/* 最先拉低 PA0/PA1，避免上电瞬间继电器 IN1/IN2 因浮空误触发 */
	Motor_Init();
	Board_Init();

#if BOARD_HAS_ONBOARD_LCD
	/* 尽早初始化 LCD（官方例程：上电白底 + Hello!） */
	LcdUi_Init();
#endif

	Board_WatchdogInit();

	Relay_Init();
	Led_Init();
	Button_Init();
	RodSensor_Init();
	Serial_Init();
	Protocol_Init();

	Serial_SendLine("OK:BOOT");

	while (1)
	{
		Protocol_Poll();
		Protocol_CheckCommTimeout();
		Button_Tick();
		RodSensor_Tick();
		Relay_Tick();
		Led_Tick();
#if BOARD_HAS_ONBOARD_LCD
		LcdUi_Tick();
#endif
		Board_FeedWatchdog();
	}
}
