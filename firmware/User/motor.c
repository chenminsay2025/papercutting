#include "motor.h"
#include "board.h"

/* 2 线电机 H 桥（docs/wiring.md §5.3，跳线 H）
 * NO1-NO2 拱桥→24V+，NC1-NC2 拱桥→GND，COM1/COM2→电机
 * 缩回：仅 IN1（PA0=1 PA1=0）
 * 伸出：仅 IN2（PA0=0 PA1=1）
 * 停止：全释放（PA0=0 PA1=0）；换向前先停 80ms
 */
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
		/* H 桥下双吸合为安全刹车(两端同+24V)；此处按停止处理 */
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
