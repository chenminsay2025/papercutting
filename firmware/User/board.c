#include "board.h"
#include "lcd_config.h"
#include "lcd_st7735.h"
#include "misc.h"
#include "stm32f10x_iwdg.h"

static volatile uint32_t s_tick_ms = 0;
static uint8_t s_has_onboard_lcd = 0;
static GPIO_TypeDef *s_led_com_gpio = GPIOA;
static uint16_t s_led_com_pin = GPIO_Pin_6;
static GPIO_TypeDef *s_button_gpio = GPIOA;
static uint16_t s_button_pin = GPIO_Pin_7;

void Board_Init(void)
{
	SysTick_Config(SystemCoreClock / 1000);
}

void Board_DetectHardware(void)
{
#if BOARD_LCD_MODE == 1
	s_has_onboard_lcd = 1;
	s_led_com_gpio = GPIOB;
	s_led_com_pin = GPIO_Pin_9;
	s_button_gpio = GPIOB;
	s_button_pin = GPIO_Pin_8;
#elif BOARD_LCD_MODE == 2
	s_has_onboard_lcd = 0;
	s_led_com_gpio = GPIOA;
	s_led_com_pin = GPIO_Pin_6;
	s_button_gpio = GPIOA;
	s_button_pin = GPIO_Pin_7;
#else
	if (Lcd_Probe())
	{
		s_has_onboard_lcd = 1;
		s_led_com_gpio = GPIOB;
		s_led_com_pin = GPIO_Pin_9;
		s_button_gpio = GPIOB;
		s_button_pin = GPIO_Pin_8;
		Lcd_GpioRelease();
	}
	else
	{
		s_has_onboard_lcd = 0;
		s_led_com_gpio = GPIOA;
		s_led_com_pin = GPIO_Pin_6;
		s_button_gpio = GPIOA;
		s_button_pin = GPIO_Pin_7;
	}
#endif
}

uint8_t Board_HasOnboardLcd(void)
{
	return s_has_onboard_lcd;
}

GPIO_TypeDef *Board_LedComGpio(void)
{
	return s_led_com_gpio;
}

uint16_t Board_LedComPin(void)
{
	return s_led_com_pin;
}

GPIO_TypeDef *Board_ButtonGpio(void)
{
	return s_button_gpio;
}

uint16_t Board_ButtonPin(void)
{
	return s_button_pin;
}

void Board_WatchdogInit(void)
{
	IWDG_WriteAccessCmd(IWDG_WriteAccess_Enable);
	IWDG_SetPrescaler(IWDG_Prescaler_64);
	IWDG_SetReload(1250);
	IWDG_ReloadCounter();
	IWDG_Enable();
}

void Board_FeedWatchdog(void)
{
	IWDG_ReloadCounter();
}

void Board_DelayMs(uint32_t ms)
{
	uint32_t start = s_tick_ms;
	while ((s_tick_ms - start) < ms)
		Board_FeedWatchdog();
}

uint32_t Board_GetTickMs(void)
{
	return s_tick_ms;
}

void Board_TickInc(void)
{
	s_tick_ms++;
}
