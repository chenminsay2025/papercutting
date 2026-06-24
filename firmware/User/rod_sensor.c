#include "rod_sensor.h"
#include "board.h"
#include "motor.h"

/* U 型槽型光电（LM393）：DO 接 PA8
 * 安装于缩回终点：挡片进入槽内 = 遮挡 = 缩回位（HOME）
 * 常见模块：有遮挡时 DO 为低电平
 */
#define ROD_SENSOR_DEBOUNCE_MS  20

static uint8_t s_raw_last = 0;
static uint8_t s_stable_blocked = 0;
static uint8_t s_prev_stable_blocked = 0;
static uint32_t s_change_tick = 0;

static uint8_t RodSensor_ReadBlocked(void)
{
	return GPIO_ReadInputDataBit(ROD_SENSOR_GPIO, ROD_SENSOR_PIN) == Bit_RESET;
}

void RodSensor_Init(void)
{
	GPIO_InitTypeDef gpio;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);

	gpio.GPIO_Mode = GPIO_Mode_IPU;
	gpio.GPIO_Pin = ROD_SENSOR_PIN;
	gpio.GPIO_Speed = GPIO_Speed_2MHz;
	GPIO_Init(ROD_SENSOR_GPIO, &gpio);

	s_raw_last = RodSensor_ReadBlocked();
	s_stable_blocked = s_raw_last;
	s_prev_stable_blocked = s_stable_blocked;
	s_change_tick = Board_GetTickMs();
}

void RodSensor_Tick(void)
{
	uint32_t now = Board_GetTickMs();
	uint8_t raw = RodSensor_ReadBlocked();

	if (raw != s_raw_last)
	{
		s_raw_last = raw;
		s_change_tick = now;
	}
	else if ((now - s_change_tick) >= ROD_SENSOR_DEBOUNCE_MS)
	{
		s_stable_blocked = raw;
	}

	/* 仅在缩回过程中「刚进入」缩回位时停电机；已在位时不拦截 RETRACT */
	if (Motor_GetState() == MOTOR_STATE_RETRACT &&
		s_stable_blocked && !s_prev_stable_blocked)
	{
		Motor_Stop();
	}

	s_prev_stable_blocked = s_stable_blocked;
}

RodPosition_t RodSensor_GetPosition(void)
{
	return s_stable_blocked ? ROD_POS_HOME : ROD_POS_AWAY;
}

uint8_t RodSensor_IsHome(void)
{
	return s_stable_blocked ? 1 : 0;
}
