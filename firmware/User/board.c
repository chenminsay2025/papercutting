#include "board.h"
#include "misc.h"
#include "stm32f10x_iwdg.h"

static volatile uint32_t s_tick_ms = 0;

void Board_Init(void)
{
	SysTick_Config(SystemCoreClock / 1000);
}

void Board_WatchdogInit(void)
{
	/* IWDG: LSI ~40kHz, prescaler 64, reload 1250 => ~2s timeout */
	IWDG_WriteAccessCmd(IWDG_WriteAccess_Enable);
	IWDG_SetPrescaler(IWDG_Prescaler_64);
	IWDG_SetReload(1250);
	IWDG_ReloadCounter();
	IWDG_Enable();
}

void Board_FeedWatchdog(void)
{
	IWDG_ReloadCounter();
}

void Board_DelayMs(uint32_t ms)
{
	uint32_t start = s_tick_ms;
	while ((s_tick_ms - start) < ms)
	{
		Board_FeedWatchdog();
	}
}

uint32_t Board_GetTickMs(void)
{
	return s_tick_ms;
}

void Board_TickInc(void)
{
	s_tick_ms++;
}
