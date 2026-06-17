#include "oled_ssd1306.h"
#include "oled_config.h"
#include "oled_font_gb16.h"
#include "board.h"
#include "stm32f10x_gpio.h"
#include "stm32f10x_rcc.h"

#define OLED_SIZE 16

#define OLED_SCLK_Clr() OLED_SCLK_GPIO->BRR = OLED_SCLK_PIN
#define OLED_SCLK_Set() OLED_SCLK_GPIO->BSRR = OLED_SCLK_PIN
#define OLED_SDIN_Clr() OLED_SDIN_GPIO->BRR = OLED_SDIN_PIN
#define OLED_SDIN_Set() OLED_SDIN_GPIO->BSRR = OLED_SDIN_PIN
#define OLED_DC_Clr()   OLED_DC_GPIO->BRR = OLED_DC_PIN
#define OLED_DC_Set()   OLED_DC_GPIO->BSRR = OLED_DC_PIN
#define OLED_CS_Clr()   OLED_CS_GPIO->BRR = OLED_CS_PIN
#define OLED_CS_Set()   OLED_CS_GPIO->BSRR = OLED_CS_PIN

#include "oled_font_ascii.h"

static void Oled_WR_Byte(uint8_t dat, uint8_t cmd)
{
	uint8_t i;

	if (cmd)
		OLED_DC_Set();
	else
		OLED_DC_Clr();
	OLED_CS_Clr();
	for (i = 0; i < 8; i++)
	{
		OLED_SCLK_Clr();
		if (dat & 0x80)
			OLED_SDIN_Set();
		else
			OLED_SDIN_Clr();
		OLED_SCLK_Set();
		dat <<= 1;
	}
	OLED_CS_Set();
	OLED_DC_Set();
}

static void Oled_SetPos(uint8_t x, uint8_t y)
{
	Oled_WR_Byte((uint8_t)(0xB0 + y), OLED_CMD);
	Oled_WR_Byte((uint8_t)(((x & 0xF0) >> 4) | 0x10), OLED_CMD);
	Oled_WR_Byte((uint8_t)((x & 0x0F) | 0x01), OLED_CMD);
}

static const OledFontGb16_t *Oled_FindGlyph(const char *s)
{
	uint16_t i;

	if (s == 0 || s[0] == 0 || s[1] == 0)
		return 0;
	for (i = 0; i < g_oled_font_gb16_count; i++)
	{
		if (g_oled_font_gb16[i].Index[0] == (uint8_t)s[0] &&
			g_oled_font_gb16[i].Index[1] == (uint8_t)s[1])
		{
			return &g_oled_font_gb16[i];
		}
	}
	return 0;
}

void Oled_Clear(void)
{
	uint8_t i;
	uint8_t n;

	for (i = 0; i < 8; i++)
	{
		Oled_WR_Byte((uint8_t)(0xB0 + i), OLED_CMD);
		Oled_WR_Byte(0x00, OLED_CMD);
		Oled_WR_Byte(0x10, OLED_CMD);
		for (n = 0; n < 128; n++)
			Oled_WR_Byte(0, OLED_DATA);
	}
}

void Oled_ShowChar(uint8_t x, uint8_t y, char chr)
{
	uint8_t c;
	uint8_t i;

	c = (uint8_t)(chr - ' ');
	if (x > 127)
	{
		x = 0;
		y = (uint8_t)(y + 2);
	}
	Oled_SetPos(x, y);
	for (i = 0; i < 8; i++)
		Oled_WR_Byte(F8X16[c * 16 + i], OLED_DATA);
	Oled_SetPos(x, (uint8_t)(y + 1));
	for (i = 0; i < 8; i++)
		Oled_WR_Byte(F8X16[c * 16 + i + 8], OLED_DATA);
}

void Oled_ShowString(uint8_t x, uint8_t y, const char *text)
{
	uint8_t col = x;

	while (text && *text)
	{
		Oled_ShowChar(col, y, *text);
		col = (uint8_t)(col + 8);
		if (col > 120)
		{
			col = 0;
			y = (uint8_t)(y + 2);
		}
		text++;
	}
}

void Oled_ShowChinese(uint8_t x, uint8_t y, const char *gb2312_text)
{
	const OledFontGb16_t *glyph;
	uint8_t col = x;
	uint8_t i;

	while (gb2312_text && gb2312_text[0] && gb2312_text[1])
	{
		glyph = Oled_FindGlyph(gb2312_text);
		if (glyph != 0)
		{
			Oled_SetPos(col, y);
			for (i = 0; i < 16; i++)
				Oled_WR_Byte(glyph->PageTop[i], OLED_DATA);
			Oled_SetPos(col, (uint8_t)(y + 1));
			for (i = 0; i < 16; i++)
				Oled_WR_Byte(glyph->PageBottom[i], OLED_DATA);
		}
		gb2312_text += 2;
		col = (uint8_t)(col + 16);
		if (col > 112)
		{
			col = 0;
			y = (uint8_t)(y + 2);
		}
	}
}

void Oled_Init(void)
{
	GPIO_InitTypeDef gpio;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);

	gpio.GPIO_Pin = OLED_SCLK_PIN | OLED_SDIN_PIN | OLED_DC_PIN | OLED_CS_PIN;
	gpio.GPIO_Mode = GPIO_Mode_Out_PP;
	gpio.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOB, &gpio);
	GPIO_SetBits(GPIOB, OLED_SCLK_PIN | OLED_SDIN_PIN | OLED_DC_PIN | OLED_CS_PIN);

	Board_DelayMs(100);

	Oled_WR_Byte(0xAE, OLED_CMD);
	Oled_WR_Byte(0x00, OLED_CMD);
	Oled_WR_Byte(0x10, OLED_CMD);
	Oled_WR_Byte(0x40, OLED_CMD);
	Oled_WR_Byte(0x81, OLED_CMD);
	Oled_WR_Byte(0xCF, OLED_CMD);
	Oled_WR_Byte(0xA1, OLED_CMD);
	Oled_WR_Byte(0xC8, OLED_CMD);
	Oled_WR_Byte(0xA6, OLED_CMD);
	Oled_WR_Byte(0xA8, OLED_CMD);
	Oled_WR_Byte(0x3F, OLED_CMD);
	Oled_WR_Byte(0xD3, OLED_CMD);
	Oled_WR_Byte(0x00, OLED_CMD);
	Oled_WR_Byte(0xD5, OLED_CMD);
	Oled_WR_Byte(0xF0, OLED_CMD);
	Oled_WR_Byte(0xD9, OLED_CMD);
	Oled_WR_Byte(0xF1, OLED_CMD);
	Oled_WR_Byte(0xDA, OLED_CMD);
	Oled_WR_Byte(0x12, OLED_CMD);
	Oled_WR_Byte(0xDB, OLED_CMD);
	Oled_WR_Byte(0x40, OLED_CMD);
	Oled_WR_Byte(0x20, OLED_CMD);
	Oled_WR_Byte(0x02, OLED_CMD);
	Oled_WR_Byte(0x8D, OLED_CMD);
	Oled_WR_Byte(0x14, OLED_CMD);
	Oled_WR_Byte(0xA4, OLED_CMD);
	Oled_WR_Byte(0xA6, OLED_CMD);
	Oled_WR_Byte(0xAF, OLED_CMD);

	Oled_Clear();
	Oled_SetPos(0, 0);
}
