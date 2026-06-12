#include "board.h"
#include "misc.h"

static volatile uint32_t s_tick_ms = 0;

void Board_Init(void)
{
	SysTick_Config(SystemCoreClock / 1000);
}

uint32_t Board_GetTickMs(void)
{
	return s_tick_ms;
}

void Board_TickInc(void)
{
	s_tick_ms++;
}
