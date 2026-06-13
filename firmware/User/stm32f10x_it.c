#include "stm32f10x_it.h"
#include "board.h"
#include "motor.h"
#include "relay.h"

void NMI_Handler(void)
{
}

void HardFault_Handler(void)
{
	Motor_EStop();
	Relay_AllOff();
	while (1) {}
}

void MemManage_Handler(void)
{
	Motor_EStop();
	Relay_AllOff();
	while (1) {}
}

void BusFault_Handler(void)
{
	Motor_EStop();
	Relay_AllOff();
	while (1) {}
}

void UsageFault_Handler(void)
{
	Motor_EStop();
	Relay_AllOff();
	while (1) {}
}

void SVC_Handler(void)
{
}

void DebugMon_Handler(void)
{
}

void PendSV_Handler(void)
{
}

void SysTick_Handler(void)
{
	Board_TickInc();
}
