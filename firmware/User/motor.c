#include "motor.h"
#include "board.h"

/* BTS7960: LPWM/RPWM 方向控制，停止时双低；换向前先 STOP 80ms */
static MotorState_t s_state = MOTOR_STATE_STOP;

#define MOTOR_DIR_SWITCH_MS 80

static void Motor_SetOutputs(uint8_t retract_on, uint8_t extend_on)
{
	uint32_t bsrr = 0;

	if (retract_on)
	{
		bsrr |= MOTOR_RETRACT_PIN;
	}
	else
	{
		bsrr |= (MOTOR_RETRACT_PIN << 16);
	}

	if (extend_on)
	{
		bsrr |= MOTOR_EXTEND_PIN;
	}
	else
	{
		bsrr |= (MOTOR_EXTEND_PIN << 16);
	}

	MOTOR_GPIO->BSRR = bsrr;
}

static void Motor_ApplyDirection(uint8_t retract_on, uint8_t extend_on)
{
	if (retract_on && extend_on)
	{
		Motor_SetOutputs(0, 0);
		s_state = MOTOR_STATE_STOP;
		return;
	}

	if (s_state != MOTOR_STATE_STOP)
	{
		if ((s_state == MOTOR_STATE_RETRACT && extend_on) ||
			(s_state == MOTOR_STATE_EXTEND && retract_on))
		{
			Motor_SetOutputs(0, 0);
			s_state = MOTOR_STATE_STOP;
			Board_DelayMs(MOTOR_DIR_SWITCH_MS);
		}
	}

	Motor_SetOutputs(retract_on, extend_on);
	if (retract_on)
	{
		s_state = MOTOR_STATE_RETRACT;
	}
	else if (extend_on)
	{
		s_state = MOTOR_STATE_EXTEND;
	}
	else
	{
		s_state = MOTOR_STATE_STOP;
	}
}

void Motor_Init(void)
{
	GPIO_InitTypeDef gpio;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);

	gpio.GPIO_Mode = GPIO_Mode_Out_PP;
	gpio.GPIO_Pin = MOTOR_RETRACT_PIN | MOTOR_EXTEND_PIN;
	gpio.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(MOTOR_GPIO, &gpio);

	Motor_Stop();
}

void Motor_Retract(void)
{
	Motor_ApplyDirection(1, 0);
}

void Motor_Extend(void)
{
	Motor_ApplyDirection(0, 1);
}

void Motor_Stop(void)
{
	Motor_SetOutputs(0, 0);
	s_state = MOTOR_STATE_STOP;
}

void Motor_EStop(void)
{
	Motor_Stop();
}

MotorState_t Motor_GetState(void)
{
	return s_state;
}
