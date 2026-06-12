#include "motor.h"
#include "board.h"

static MotorState_t s_state = MOTOR_STATE_STOP;

static void Motor_SetOutputs(uint8_t retract_on, uint8_t extend_on)
{
	if (retract_on)
	{
		GPIO_SetBits(MOTOR_GPIO, MOTOR_RETRACT_PIN);
	}
	else
	{
		GPIO_ResetBits(MOTOR_GPIO, MOTOR_RETRACT_PIN);
	}

	if (extend_on)
	{
		GPIO_SetBits(MOTOR_GPIO, MOTOR_EXTEND_PIN);
	}
	else
	{
		GPIO_ResetBits(MOTOR_GPIO, MOTOR_EXTEND_PIN);
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
	Motor_SetOutputs(1, 0);
	s_state = MOTOR_STATE_RETRACT;
}

void Motor_Extend(void)
{
	Motor_SetOutputs(0, 1);
	s_state = MOTOR_STATE_EXTEND;
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
