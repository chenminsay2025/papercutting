#include "relay.h"
#include "board.h"

#define RELAY_PULSE_MS_MAX 5000

typedef struct
{
	uint8_t active;
	uint8_t which;
	uint32_t end_tick;
} RelayPulse_t;

static RelayPulse_t s_pulse = {0, 0, 0};

static void Relay_SetA(uint8_t on)
{
	if (on)
	{
		GPIO_SetBits(RELAY_GPIO, RELAY_A_PIN);
	}
	else
	{
		GPIO_ResetBits(RELAY_GPIO, RELAY_A_PIN);
	}
}

static void Relay_SetB(uint8_t on)
{
	if (on)
	{
		GPIO_SetBits(RELAY_GPIO, RELAY_B_PIN);
	}
	else
	{
		GPIO_ResetBits(RELAY_GPIO, RELAY_B_PIN);
	}
}

void Relay_Init(void)
{
	GPIO_InitTypeDef gpio;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);

	gpio.GPIO_Mode = GPIO_Mode_Out_PP;
	gpio.GPIO_Pin = RELAY_A_PIN | RELAY_B_PIN;
	gpio.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(RELAY_GPIO, &gpio);

	Relay_AllOff();
}

void Relay_AllOff(void)
{
	s_pulse.active = 0;
	Relay_SetA(0);
	Relay_SetB(0);
}

static void Relay_StartPulse(uint8_t which, uint32_t duration_ms)
{
	if (duration_ms == 0)
	{
		duration_ms = 1;
	}
	if (duration_ms > RELAY_PULSE_MS_MAX)
	{
		duration_ms = RELAY_PULSE_MS_MAX;
	}

	Relay_AllOff();
	s_pulse.which = which;
	s_pulse.end_tick = Board_GetTickMs() + duration_ms;
	s_pulse.active = 1;

	if (which == 'A')
	{
		Relay_SetA(1);
	}
	else
	{
		Relay_SetB(1);
	}
}

void Relay_PulseA(uint32_t duration_ms)
{
	Relay_StartPulse('A', duration_ms);
}

void Relay_PulseB(uint32_t duration_ms)
{
	Relay_StartPulse('B', duration_ms);
}

void Relay_Tick(void)
{
	if (!s_pulse.active)
	{
		return;
	}

	if ((int32_t)(Board_GetTickMs() - s_pulse.end_tick) >= 0)
	{
		Relay_AllOff();
	}
}

uint8_t Relay_IsBusy(void)
{
	return s_pulse.active;
}
