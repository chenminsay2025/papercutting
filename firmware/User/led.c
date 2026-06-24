#include "led.h"
#include "board.h"
#include "motor.h"
#include "protocol.h"
#include "stm32f10x.h"
#include "stm32f10x_gpio.h"
#include "stm32f10x_rcc.h"
#include "stm32f10x_tim.h"

#define LED_FAST_BLINK_MS      120
#define LED_BREATH_PERIOD_MS   2800
#define LED_BREATH_MIN_LEVEL   6
#define LED_BREATH_MAX_LEVEL   255
#define LED_PWM_PRESCALER      35
#define LED_PWM_PERIOD         255

typedef enum
{
	COM_PWM_NONE = 0,
	COM_PWM_TIM3_CH1,
	COM_PWM_TIM4_CH4
} ComPwmKind_t;

static ComPwmKind_t s_com_pwm = COM_PWM_NONE;
static GPIO_TypeDef *s_com_gpio = GPIOA;
static uint16_t s_com_pin = GPIO_Pin_6;

static void Led_SetPin(GPIO_TypeDef *gpio, uint16_t pin, uint8_t on)
{
	if (on)
		gpio->BSRR = pin;
	else
		gpio->BSRR = (uint32_t)pin << 16;
}

static void Led_ComPwmTimerInit(TIM_TypeDef *tim, uint8_t is_tim3_ch1)
{
	TIM_TimeBaseInitTypeDef tb;
	TIM_OCInitTypeDef oc;

	tb.TIM_Prescaler = LED_PWM_PRESCALER;
	tb.TIM_Period = LED_PWM_PERIOD;
	tb.TIM_ClockDivision = TIM_CKD_DIV1;
	tb.TIM_CounterMode = TIM_CounterMode_Up;
	tb.TIM_RepetitionCounter = 0;
	TIM_TimeBaseInit(tim, &tb);

	TIM_OCStructInit(&oc);
	oc.TIM_OCMode = TIM_OCMode_PWM1;
	oc.TIM_OutputState = TIM_OutputState_Enable;
	oc.TIM_Pulse = 0;
	oc.TIM_OCPolarity = TIM_OCPolarity_High;

	if (is_tim3_ch1)
	{
		TIM_OC1Init(tim, &oc);
		TIM_OC1PreloadConfig(tim, TIM_OCPreload_Enable);
	}
	else
	{
		TIM_OC4Init(tim, &oc);
		TIM_OC4PreloadConfig(tim, TIM_OCPreload_Enable);
	}

	TIM_ARRPreloadConfig(tim, ENABLE);
	TIM_Cmd(tim, ENABLE);
}

static void Led_ComPwmInit(void)
{
	GPIO_InitTypeDef gpio;

	s_com_gpio = Board_LedComGpio();
	s_com_pin = Board_LedComPin();
	s_com_pwm = COM_PWM_NONE;

	if (s_com_gpio == GPIOB && s_com_pin == GPIO_Pin_9)
	{
		RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM4, ENABLE);
		RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB | RCC_APB2Periph_AFIO, ENABLE);
		gpio.GPIO_Pin = s_com_pin;
		gpio.GPIO_Mode = GPIO_Mode_AF_PP;
		gpio.GPIO_Speed = GPIO_Speed_50MHz;
		GPIO_Init(GPIOB, &gpio);
		Led_ComPwmTimerInit(TIM4, 0);
		s_com_pwm = COM_PWM_TIM4_CH4;
		return;
	}

	if (s_com_gpio == GPIOA && s_com_pin == GPIO_Pin_6)
	{
		RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM3, ENABLE);
		RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA | RCC_APB2Periph_AFIO, ENABLE);
		gpio.GPIO_Pin = s_com_pin;
		gpio.GPIO_Mode = GPIO_Mode_AF_PP;
		gpio.GPIO_Speed = GPIO_Speed_50MHz;
		GPIO_Init(GPIOA, &gpio);
		Led_ComPwmTimerInit(TIM3, 1);
		s_com_pwm = COM_PWM_TIM3_CH1;
		return;
	}

	RCC_APB2PeriphClockCmd(
		(s_com_gpio == GPIOB) ? RCC_APB2Periph_GPIOB : RCC_APB2Periph_GPIOA,
		ENABLE);
	gpio.GPIO_Pin = s_com_pin;
	gpio.GPIO_Mode = GPIO_Mode_Out_PP;
	gpio.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(s_com_gpio, &gpio);
	Led_SetPin(s_com_gpio, s_com_pin, 0);
}

static void Led_ComSetBrightness(uint8_t level)
{
	switch (s_com_pwm)
	{
	case COM_PWM_TIM3_CH1:
		TIM_SetCompare1(TIM3, level);
		break;
	case COM_PWM_TIM4_CH4:
		TIM_SetCompare4(TIM4, level);
		break;
	default:
		Led_SetPin(s_com_gpio, s_com_pin, level > 127);
		break;
	}
}

static void Led_UpdateMotor(void)
{
	MotorState_t state = Motor_GetState();

	Led_SetPin(LED_MOTOR_GPIO, LED_RETRACT_PIN, state == MOTOR_STATE_RETRACT);
	Led_SetPin(LED_MOTOR_GPIO, LED_EXTEND_PIN, state == MOTOR_STATE_EXTEND);
}

/* 三角波 + 伽马（tri²）近似正弦；亮度在 MIN..MAX 之间，不全灭 */
static uint8_t Led_ComBreathLevel(uint32_t ms)
{
	uint32_t phase = ms % LED_BREATH_PERIOD_MS;
	uint32_t half = LED_BREATH_PERIOD_MS / 2;
	uint32_t tri;
	uint32_t shaped;
	uint32_t span = LED_BREATH_MAX_LEVEL - LED_BREATH_MIN_LEVEL;

	if (phase < half)
		tri = (phase * 255u) / half;
	else
		tri = ((LED_BREATH_PERIOD_MS - phase) * 255u) / half;

	shaped = (tri * tri + 127u) / 255u;
	return (uint8_t)(LED_BREATH_MIN_LEVEL + (shaped * span + 127u) / 255u);
}

static void Led_UpdateCom(uint32_t ms)
{
	if (Protocol_IsCommActive())
		Led_ComSetBrightness(Led_ComBreathLevel(ms));
	else
		Led_ComSetBrightness((((ms / LED_FAST_BLINK_MS) % 2) != 0) ? 255u : 0u);
}

void Led_Init(void)
{
	GPIO_InitTypeDef gpio;
	uint32_t motor_pins = LED_RETRACT_PIN | LED_EXTEND_PIN;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);

	gpio.GPIO_Mode = GPIO_Mode_Out_PP;
	gpio.GPIO_Speed = GPIO_Speed_50MHz;
	gpio.GPIO_Pin = motor_pins;
	GPIO_Init(LED_MOTOR_GPIO, &gpio);

	Led_SetPin(LED_MOTOR_GPIO, LED_RETRACT_PIN, 0);
	Led_SetPin(LED_MOTOR_GPIO, LED_EXTEND_PIN, 0);

	Led_ComPwmInit();
}

void Led_ComTickISR(void)
{
	Led_UpdateCom(Board_GetTickMs());
}

void Led_Tick(void)
{
	Led_UpdateMotor();
}
