#include "led.h"
#include "board.h"
#include "motor.h"
#include "protocol.h"
#include "stm32f10x.h"

#define LED_FAST_BLINK_MS   120
#define LED_BREATH_PERIOD_MS 2000
#define LED_BREATH_PWM_MS   16

static void Led_SetPin(uint16_t pin, uint8_t on)
{
	if (on)
	{
		LED_GPIO->BSRR = pin;
	}
	else
	{
		LED_GPIO->BSRR = (uint32_t)pin << 16;
	}
}

static void Led_UpdateMotor(void)
{
	MotorState_t state = Motor_GetState();

	Led_SetPin(LED_RETRACT_PIN, state == MOTOR_STATE_RETRACT);
	Led_SetPin(LED_EXTEND_PIN, state == MOTOR_STATE_EXTEND);
}

static void Led_UpdateCom(uint32_t ms)
{
	if (Protocol_IsCommActive())
	{
		uint32_t phase = ms % LED_BREATH_PERIOD_MS;
		uint32_t level = (phase < (LED_BREATH_PERIOD_MS / 2))
			? phase
			: (LED_BREATH_PERIOD_MS - phase);
		uint8_t on = ((ms % LED_BREATH_PWM_MS) * (LED_BREATH_PERIOD_MS / 2) / LED_BREATH_PWM_MS) < level;
		Led_SetPin(LED_COM_PIN, on);
	}
	else
	{
		Led_SetPin(LED_COM_PIN, ((ms / LED_FAST_BLINK_MS) % 2) != 0);
	}
}

void Led_Init(void)
{
	GPIO_InitTypeDef gpio;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);

	gpio.GPIO_Mode = GPIO_Mode_Out_PP;
	gpio.GPIO_Pin = LED_RETRACT_PIN | LED_EXTEND_PIN | LED_COM_PIN;
	gpio.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(LED_GPIO, &gpio);

	Led_SetPin(LED_RETRACT_PIN, 0);
	Led_SetPin(LED_EXTEND_PIN, 0);
	Led_SetPin(LED_COM_PIN, 0);
}

void Led_Tick(void)
{
	uint32_t ms = Board_GetTickMs();

	Led_UpdateMotor();
	Led_UpdateCom(ms);
}
