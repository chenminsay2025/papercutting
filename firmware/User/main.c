#include "stm32f10x.h"
#include "board.h"
#include "motor.h"
#include "relay.h"
#include "buttons.h"
#include "rod_sensor.h"
#include "obstacle_sensor.h"
#include "buzzer.h"
#include "lcd_ui.h"
#include "usart_serial.h"
#include "protocol.h"
#include "led.h"

int main(void)
{
	Motor_Init();
	Board_Init();
	Board_DetectHardware();

	LcdUi_Init();
	Board_WatchdogInit();

	Relay_Init();
	Led_Init();
	Button_Init();
	RodSensor_Init();
	ObstacleSensor_Init();
	Buzzer_Init();
	Serial_Init();
	Protocol_Init();

	Serial_SendLine("OK:BOOT");

	while (1)
	{
		LcdUi_ScrollPoll();
		Protocol_Poll();
		Protocol_CheckCommTimeout();
		Button_Tick();
		RodSensor_Tick();
		ObstacleSensor_Tick();
		Buzzer_Tick();
		Relay_Tick();
		Led_Tick();
		LcdUi_Tick();
		Board_FeedWatchdog();
	}
}
