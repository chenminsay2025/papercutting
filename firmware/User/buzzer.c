#include "buzzer.h"
#include "board.h"

#define BUZZER_MS_MAX 10000u

typedef struct
{
	uint8_t active;
	uint8_t phase_on;
	uint32_t phase_end;
	uint16_t on_ms;
	uint16_t gap_ms;
	uint8_t pulses_left;
	uint8_t continuous;
} BuzzerSeq_t;

static BuzzerSeq_t s_seq = {0, 0, 0, 0, 0, 0, 0};

static void Buzzer_SetOutput(uint8_t on)
{
#if BUZZER_ACTIVE_LOW
	if (on)
	{
		GPIO_ResetBits(BUZZER_GPIO, BUZZER_PIN);
	}
	else
	{
		GPIO_SetBits(BUZZER_GPIO, BUZZER_PIN);
	}
#else
	if (on)
	{
		GPIO_SetBits(BUZZER_GPIO, BUZZER_PIN);
	}
	else
	{
		GPIO_ResetBits(BUZZER_GPIO, BUZZER_PIN);
	}
#endif
}

static uint32_t Buzzer_ClampMs(uint32_t ms)
{
	if (ms == 0u)
	{
		return 200u;
	}
	if (ms > BUZZER_MS_MAX)
	{
		return BUZZER_MS_MAX;
	}
	return ms;
}

static void Buzzer_BeginPhase(uint8_t on, uint32_t duration_ms)
{
	s_seq.phase_on = on;
	s_seq.phase_end = Board_GetTickMs() + duration_ms;
	Buzzer_SetOutput(on);
}

static void Buzzer_StartAsync(uint16_t on_ms, uint16_t gap_ms, uint8_t pulses, uint8_t continuous)
{
	s_seq.on_ms = (uint16_t)Buzzer_ClampMs(on_ms);
	s_seq.gap_ms = (uint16_t)(gap_ms ? Buzzer_ClampMs(gap_ms) : 1u);
	s_seq.pulses_left = pulses;
	s_seq.continuous = continuous;
	s_seq.active = 1;
	Buzzer_BeginPhase(1u, s_seq.on_ms);
}

void Buzzer_Init(void)
{
	GPIO_InitTypeDef gpio;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);

	gpio.GPIO_Mode = GPIO_Mode_Out_PP;
	gpio.GPIO_Pin = BUZZER_PIN;
	gpio.GPIO_Speed = GPIO_Speed_2MHz;
	GPIO_Init(BUZZER_GPIO, &gpio);

	Buzzer_Off();
}

void Buzzer_On(void)
{
	s_seq.active = 0;
	Buzzer_SetOutput(1);
}

void Buzzer_Off(void)
{
	s_seq.active = 0;
	s_seq.continuous = 0;
	s_seq.pulses_left = 0;
	Buzzer_SetOutput(0);
}

void Buzzer_BeepBlocking(uint32_t on_ms, uint32_t gap_ms, uint8_t count)
{
	uint8_t i;
	uint32_t on = Buzzer_ClampMs(on_ms);
	uint32_t gap = gap_ms ? Buzzer_ClampMs(gap_ms) : 100u;

	if (count == 0u)
	{
		count = 1u;
	}

	Buzzer_Off();

	for (i = 0u; i < count; i++)
	{
		Buzzer_On();
		Board_DelayMs(on);
		Buzzer_Off();
		if ((i + 1u) < count)
		{
			Board_DelayMs(gap);
		}
	}
}

void Buzzer_PatternShort(uint32_t on_ms)
{
	Buzzer_BeepBlocking(on_ms, 0u, 1u);
}

void Buzzer_PatternLong(uint32_t on_ms)
{
	Buzzer_BeepBlocking(on_ms, 0u, 1u);
}

void Buzzer_PatternDouble(uint32_t on_ms, uint32_t gap_ms)
{
	Buzzer_BeepBlocking(on_ms, gap_ms, 2u);
}

void Buzzer_PatternTriple(uint32_t on_ms, uint32_t gap_ms)
{
	Buzzer_BeepBlocking(on_ms, gap_ms, 3u);
}

void Buzzer_PatternContinuous(uint32_t on_ms, uint32_t gap_ms)
{
	Buzzer_StartAsync((uint16_t)on_ms, (uint16_t)gap_ms, 1u, 1u);
}

void Buzzer_Tick(void)
{
	uint32_t now;

	if (!s_seq.active)
	{
		return;
	}

	now = Board_GetTickMs();
	if ((int32_t)(now - s_seq.phase_end) < 0)
	{
		return;
	}

	if (s_seq.phase_on)
	{
		if (s_seq.continuous)
		{
			Buzzer_BeginPhase(0u, s_seq.gap_ms);
			return;
		}

		if (s_seq.pulses_left > 1u)
		{
			s_seq.pulses_left--;
			Buzzer_BeginPhase(0u, s_seq.gap_ms);
			return;
		}

		Buzzer_Off();
		return;
	}

	if (s_seq.continuous)
	{
		Buzzer_BeginPhase(1u, s_seq.on_ms);
		return;
	}

	if (s_seq.pulses_left > 0u)
	{
		Buzzer_BeginPhase(1u, s_seq.on_ms);
		return;
	}

	Buzzer_Off();
}

uint8_t Buzzer_IsBusy(void)
{
	return s_seq.active;
}
