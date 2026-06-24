#include "obstacle_sensor.h"
#include "board.h"

/* KY-032 红外避障：S→PB6，EN→GND，LOW=有遮挡 */
#define OBSTACLE_DEBOUNCE_MS  20u

static uint8_t s_raw_last = 0;
static uint8_t s_stable_blocked = 0;
static uint32_t s_change_tick = 0;

static uint8_t ObstacleSensor_ReadBlocked(void)
{
	return GPIO_ReadInputDataBit(OBSTACLE_GPIO, OBSTACLE_PIN) == Bit_RESET;
}

void ObstacleSensor_Init(void)
{
	GPIO_InitTypeDef gpio;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);

	gpio.GPIO_Mode = GPIO_Mode_IPU;
	gpio.GPIO_Pin = OBSTACLE_PIN;
	gpio.GPIO_Speed = GPIO_Speed_2MHz;
	GPIO_Init(OBSTACLE_GPIO, &gpio);

	s_raw_last = ObstacleSensor_ReadBlocked();
	s_stable_blocked = s_raw_last;
	s_change_tick = Board_GetTickMs();
}

void ObstacleSensor_Tick(void)
{
	uint32_t now = Board_GetTickMs();
	uint8_t raw = ObstacleSensor_ReadBlocked();

	if (raw != s_raw_last)
	{
		s_raw_last = raw;
		s_change_tick = now;
	}
	else if ((now - s_change_tick) >= OBSTACLE_DEBOUNCE_MS)
	{
		s_stable_blocked = raw;
	}
}

ObstacleState_t ObstacleSensor_GetState(void)
{
	return s_stable_blocked ? OBSTACLE_BLOCKED : OBSTACLE_CLEAR;
}

uint8_t ObstacleSensor_IsBlocked(void)
{
	return s_stable_blocked ? 1u : 0u;
}
