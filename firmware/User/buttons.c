#include "buttons.h"
#include "board.h"
#include "motor.h"
#include "stm32f10x_gpio.h"
#include "stm32f10x_rcc.h"

/* 实体按键：单键切换缩回/伸出，每次运行固定 3 秒
 * 一端接 GPIO，另一端接 GND，按下为低电平；与串口命令互不干扰
 */
#define BUTTON_DEBOUNCE_MS  30

typedef struct
{
	uint8_t stable;
	uint8_t raw_last;
	uint32_t change_tick;
} ButtonDeb_t;

static ButtonDeb_t s_toggle_btn;
static uint8_t s_last_stable_pressed = 0;
static uint8_t s_next_is_retract = 1;
static uint32_t s_run_until_ms = 0;
static uint8_t s_button_active = 0;

static uint8_t Button_ReadPressed(void)
{
	return GPIO_ReadInputDataBit(Board_ButtonGpio(), Board_ButtonPin()) == Bit_RESET;
}

static void Button_Debounce(ButtonDeb_t *btn, uint32_t now)
{
	uint8_t raw = Button_ReadPressed();

	if (raw != btn->raw_last)
	{
		btn->raw_last = raw;
		btn->change_tick = now;
	}
	else if ((now - btn->change_tick) >= BUTTON_DEBOUNCE_MS)
	{
		btn->stable = raw;
	}
}

static void Button_StartTimedRun(uint8_t retract, uint32_t now)
{
	if (retract)
		Motor_Retract();
	else
		Motor_Extend();

	s_button_active = 1;
	s_run_until_ms = now + BUTTON_ACTION_MS;
}

static void Button_StopTimedRun(void)
{
	if (!s_button_active)
		return;

	Motor_Stop();
	s_button_active = 0;
	s_run_until_ms = 0;
}

void Button_Init(void)
{
	GPIO_InitTypeDef gpio;
	GPIO_TypeDef *btn_gpio = Board_ButtonGpio();
	uint16_t btn_pin = Board_ButtonPin();

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
	if (btn_gpio == GPIOB)
		RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);

	gpio.GPIO_Mode = GPIO_Mode_IPU;
	gpio.GPIO_Pin = btn_pin;
	gpio.GPIO_Speed = GPIO_Speed_2MHz;
	GPIO_Init(btn_gpio, &gpio);

	s_toggle_btn.raw_last = Button_ReadPressed();
	s_toggle_btn.stable = s_toggle_btn.raw_last;
	s_toggle_btn.change_tick = Board_GetTickMs();
	s_last_stable_pressed = s_toggle_btn.stable;
	s_next_is_retract = 1;
	s_run_until_ms = 0;
	s_button_active = 0;
}

void Button_Tick(void)
{
	uint32_t now = Board_GetTickMs();

	Button_Debounce(&s_toggle_btn, now);

	if (s_toggle_btn.stable && !s_last_stable_pressed && s_run_until_ms == 0)
	{
		Button_StartTimedRun(s_next_is_retract, now);
		s_next_is_retract = !s_next_is_retract;
	}

	s_last_stable_pressed = s_toggle_btn.stable;

	if (s_run_until_ms != 0 && now >= s_run_until_ms)
		Button_StopTimedRun();
}
