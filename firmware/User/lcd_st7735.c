#include "lcd_st7735.h"
#include "lcd_config.h"
#include "lcd_font.h"
#include "lcd_font_gb16.h"
#include "board.h"
#include "stm32f10x.h"

#if BOARD_HAS_ONBOARD_LCD

#define LCD_CS_LOW()    LCD_CS_GPIO->BRR = LCD_CS_PIN
#define LCD_CS_HIGH()   LCD_CS_GPIO->BSRR = LCD_CS_PIN
#define LCD_DC_CMD()    LCD_DC_GPIO->BRR = LCD_DC_PIN
#define LCD_DC_DATA()   LCD_DC_GPIO->BSRR = LCD_DC_PIN
#define LCD_RST_LOW()   LCD_RST_GPIO->BRR = LCD_RST_PIN
#define LCD_RST_HIGH()  LCD_RST_GPIO->BSRR = LCD_RST_PIN

#if LCD_BLK_ACTIVE_LOW
#define LCD_BLK_ON()    LCD_BLK_GPIO->BRR = LCD_BLK_PIN
#define LCD_BLK_OFF()   LCD_BLK_GPIO->BSRR = LCD_BLK_PIN
#else
#define LCD_BLK_ON()    LCD_BLK_GPIO->BSRR = LCD_BLK_PIN
#define LCD_BLK_OFF()   LCD_BLK_GPIO->BRR = LCD_BLK_PIN
#endif

#define LCD_SCK_HIGH()  LCD_SCK_GPIO->BSRR = LCD_SCK_PIN
#define LCD_SCK_LOW()   LCD_SCK_GPIO->BRR = LCD_SCK_PIN
#define LCD_MOSI_HIGH() LCD_MOSI_GPIO->BSRR = LCD_MOSI_PIN
#define LCD_MOSI_LOW()  LCD_MOSI_GPIO->BRR = LCD_MOSI_PIN

/* 官方 LCD_Writ_Bus */
static void Lcd_WritBus(uint8_t dat)
{
	uint8_t i;

	LCD_CS_LOW();
	for (i = 0; i < 8; i++)
	{
		LCD_SCK_LOW();
		if (dat & 0x80)
			LCD_MOSI_HIGH();
		else
			LCD_MOSI_LOW();
		LCD_SCK_HIGH();
		dat <<= 1;
	}
	LCD_CS_HIGH();
}

/* 官方 LCD_WR_REG：写命令后 DC 回到数据态 */
static void Lcd_WriteReg(uint8_t reg)
{
	LCD_DC_CMD();
	Lcd_WritBus(reg);
	LCD_DC_DATA();
}

static void Lcd_WriteData8(uint8_t dat)
{
	Lcd_WritBus(dat);
}

static void Lcd_WriteData16(uint16_t dat)
{
	Lcd_WritBus((uint8_t)(dat >> 8));
	Lcd_WritBus((uint8_t)(dat & 0xFF));
}

static void Lcd_AddressSet(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2)
{
#if LCD_USE_HORIZONTAL == 0 || LCD_USE_HORIZONTAL == 1
	Lcd_WriteReg(0x2A);
	Lcd_WriteData16((uint16_t)(x1 + LCD_X_OFFSET));
	Lcd_WriteData16((uint16_t)(x2 + LCD_X_OFFSET));
	Lcd_WriteReg(0x2B);
	Lcd_WriteData16((uint16_t)(y1 + LCD_Y_OFFSET));
	Lcd_WriteData16((uint16_t)(y2 + LCD_Y_OFFSET));
#else
	Lcd_WriteReg(0x2A);
	Lcd_WriteData16((uint16_t)(x1 + LCD_X_OFFSET));
	Lcd_WriteData16((uint16_t)(x2 + LCD_X_OFFSET));
	Lcd_WriteReg(0x2B);
	Lcd_WriteData16((uint16_t)(y1 + LCD_Y_OFFSET));
	Lcd_WriteData16((uint16_t)(y2 + LCD_Y_OFFSET));
#endif
	Lcd_WriteReg(0x2C);
}

static void Lcd_GpioInit(void)
{
	GPIO_InitTypeDef gpio;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA | RCC_APB2Periph_GPIOB | RCC_APB2Periph_AFIO, ENABLE);

	gpio.GPIO_Mode = GPIO_Mode_Out_PP;
	gpio.GPIO_Speed = GPIO_Speed_50MHz;

	gpio.GPIO_Pin = LCD_BLK_PIN | LCD_RST_PIN;
	GPIO_Init(GPIOA, &gpio);
	GPIO_SetBits(GPIOA, LCD_BLK_PIN | LCD_RST_PIN);

	gpio.GPIO_Pin = LCD_DC_PIN | LCD_CS_PIN | LCD_SCK_PIN | LCD_MOSI_PIN;
	GPIO_Init(GPIOB, &gpio);
	GPIO_SetBits(GPIOB, LCD_DC_PIN | LCD_CS_PIN | LCD_SCK_PIN | LCD_MOSI_PIN);

	LCD_BLK_OFF();
}

#if LCD_USE_NOLOGO_INIT
static void Lcd_InitSequence(void)
{
	LCD_RST_LOW();
	Board_DelayMs(100);
	LCD_RST_HIGH();
	Board_DelayMs(100);

	LCD_BLK_ON();
	Board_DelayMs(100);

	Lcd_WriteReg(0x11);
	Board_DelayMs(120);

	Lcd_WriteReg(0xB1);
	Lcd_WriteData8(0x05);
	Lcd_WriteData8(0x3C);
	Lcd_WriteData8(0x3C);

	Lcd_WriteReg(0xB2);
	Lcd_WriteData8(0x05);
	Lcd_WriteData8(0x3C);
	Lcd_WriteData8(0x3C);

	Lcd_WriteReg(0xB3);
	Lcd_WriteData8(0x05);
	Lcd_WriteData8(0x3C);
	Lcd_WriteData8(0x3C);
	Lcd_WriteData8(0x05);
	Lcd_WriteData8(0x3C);
	Lcd_WriteData8(0x3C);

	Lcd_WriteReg(0xB4);
	Lcd_WriteData8(0x03);

	Lcd_WriteReg(0xC0);
	Lcd_WriteData8(0xAB);
	Lcd_WriteData8(0x0B);
	Lcd_WriteData8(0x04);

	Lcd_WriteReg(0xC1);
	Lcd_WriteData8(0xC5);

	Lcd_WriteReg(0xC2);
	Lcd_WriteData8(0x0D);
	Lcd_WriteData8(0x00);

	Lcd_WriteReg(0xC3);
	Lcd_WriteData8(0x8D);
	Lcd_WriteData8(0x6A);

	Lcd_WriteReg(0xC4);
	Lcd_WriteData8(0x8D);
	Lcd_WriteData8(0xEE);

	Lcd_WriteReg(0xC5);
	Lcd_WriteData8(0x0F);

	Lcd_WriteReg(0xE0);
	Lcd_WriteData8(0x07);
	Lcd_WriteData8(0x0E);
	Lcd_WriteData8(0x08);
	Lcd_WriteData8(0x07);
	Lcd_WriteData8(0x10);
	Lcd_WriteData8(0x07);
	Lcd_WriteData8(0x02);
	Lcd_WriteData8(0x07);
	Lcd_WriteData8(0x09);
	Lcd_WriteData8(0x0F);
	Lcd_WriteData8(0x25);
	Lcd_WriteData8(0x36);
	Lcd_WriteData8(0x00);
	Lcd_WriteData8(0x08);
	Lcd_WriteData8(0x04);
	Lcd_WriteData8(0x10);

	Lcd_WriteReg(0xE1);
	Lcd_WriteData8(0x0A);
	Lcd_WriteData8(0x0D);
	Lcd_WriteData8(0x08);
	Lcd_WriteData8(0x07);
	Lcd_WriteData8(0x0F);
	Lcd_WriteData8(0x07);
	Lcd_WriteData8(0x02);
	Lcd_WriteData8(0x07);
	Lcd_WriteData8(0x09);
	Lcd_WriteData8(0x0F);
	Lcd_WriteData8(0x25);
	Lcd_WriteData8(0x35);
	Lcd_WriteData8(0x00);
	Lcd_WriteData8(0x09);
	Lcd_WriteData8(0x04);
	Lcd_WriteData8(0x10);

	Lcd_WriteReg(0xFC);
	Lcd_WriteData8(0x80);

	Lcd_WriteReg(0x3A);
	Lcd_WriteData8(0x05);

	Lcd_WriteReg(0x36);
	Lcd_WriteData8(LCD_MADCTL_VAL);

	Lcd_WriteReg(0x21);
	Lcd_WriteReg(0x29);

	Lcd_WriteReg(0x2A);
	Lcd_WriteData8(0x00);
	Lcd_WriteData8(0x1A);
	Lcd_WriteData8(0x00);
	Lcd_WriteData8(0x69);

	Lcd_WriteReg(0x2B);
	Lcd_WriteData8(0x00);
	Lcd_WriteData8(0x01);
	Lcd_WriteData8(0x00);
	Lcd_WriteData8(0xA0);

	Lcd_WriteReg(0x2C);
}
#else
static void Lcd_InitSequence(void)
{
	LCD_RST_LOW();
	Board_DelayMs(100);
	LCD_RST_HIGH();
	Board_DelayMs(100);
	LCD_BLK_ON();
	Board_DelayMs(100);
	Lcd_WriteReg(0x11);
	Board_DelayMs(120);
	Lcd_WriteReg(0x3A);
	Lcd_WriteData8(0x05);
	Lcd_WriteReg(0x36);
	Lcd_WriteData8(LCD_MADCTL_VAL);
	Lcd_WriteReg(0x29);
	Board_DelayMs(20);
}
#endif

void Lcd_Init(void)
{
	Lcd_GpioInit();
	Lcd_InitSequence();
}

void Lcd_Fill(uint16_t color)
{
	Lcd_FillRect(0, 0, LCD_WIDTH, LCD_HEIGHT, color);
}

/* 与官方 LCD_Fill(xsta,ysta,xend,yend,color) 相同，xend/yend 为不含端点 */
void Lcd_FillRect(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint16_t color)
{
	uint16_t i;
	uint16_t j;
	uint16_t xend;
	uint16_t yend;

	if (w == 0 || h == 0)
		return;
	if (x >= LCD_WIDTH || y >= LCD_HEIGHT)
		return;

	xend = x + w;
	yend = y + h;
	if (xend > LCD_WIDTH)
		xend = LCD_WIDTH;
	if (yend > LCD_HEIGHT)
		yend = LCD_HEIGHT;

	Lcd_AddressSet(x, y, (uint16_t)(xend - 1), (uint16_t)(yend - 1));

	for (i = y; i < yend; i++)
	{
		for (j = x; j < xend; j++)
		{
			Lcd_WriteData16(color);
		}
		if ((i & 0xF) == 0)
			Board_FeedWatchdog();
	}
}

void Lcd_DrawChar(uint16_t x, uint16_t y, char c, uint16_t fg, uint16_t bg, uint8_t scale)
{
	const uint8_t *glyph = LcdFont_GetGlyph(c);
	uint8_t row;
	uint8_t col;
	uint8_t cw;
	uint8_t ch;

	if (scale == 0)
		scale = 1;

	cw = (uint8_t)(LCD_FONT_W * scale);
	ch = (uint8_t)(LCD_FONT_H * scale);

	Lcd_AddressSet(x, y, (uint16_t)(x + cw - 1), (uint16_t)(y + ch - 1));

	for (row = 0; row < LCD_FONT_H; row++)
	{
		for (col = 0; col < LCD_FONT_W; col++)
		{
			uint16_t color = (glyph[col] & (1u << row)) ? fg : bg;
			uint8_t sy;

			for (sy = 0; sy < scale; sy++)
			{
				uint8_t sx;
				for (sx = 0; sx < scale; sx++)
					Lcd_WriteData16(color);
			}
		}
	}
}

void Lcd_DrawString(uint16_t x, uint16_t y, const char *text, uint16_t fg, uint16_t bg, uint8_t scale)
{
	uint16_t cursor = x;
	uint8_t advance;

	if (text == 0)
		return;
	if (scale == 0)
		scale = 1;

	advance = (uint8_t)(LCD_FONT_W * scale);

	while (*text)
	{
		if (*text == '\n')
		{
			y = (uint16_t)(y + (LCD_FONT_H + 1) * scale);
			cursor = x;
		}
		else
		{
			Lcd_DrawChar(cursor, y, *text, fg, bg, scale);
			cursor = (uint16_t)(cursor + advance);
			Board_FeedWatchdog();
		}
		text++;
	}
}

void Lcd_DrawChinese16(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg)
{
	uint16_t k;
	uint8_t i;
	uint8_t j;
	uint8_t m = 0;
	uint16_t hznum;

	if (s == 0 || s[0] == 0 || s[1] == 0)
		return;

	hznum = g_lcd_font_gb16_count;
	for (k = 0; k < hznum; k++)
	{
		if ((g_lcd_font_gb16[k].Index[0] == (uint8_t)s[0]) &&
			(g_lcd_font_gb16[k].Index[1] == (uint8_t)s[1]))
		{
			Lcd_AddressSet(x, y, (uint16_t)(x + 15), (uint16_t)(y + 15));
			for (i = 0; i < 32; i++)
			{
				for (j = 0; j < 8; j++)
				{
					Lcd_WriteData16((g_lcd_font_gb16[k].Msk[i] & (0x01u << j)) ? fg : bg);
					m++;
					if ((m % 16) == 0)
						break;
				}
			}
			return;
		}
	}
}

void Lcd_DrawChinese(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg)
{
	while (s && s[0] && s[1])
	{
		Lcd_DrawChinese16(x, y, s, fg, bg);
		s += 2;
		x = (uint16_t)(x + 16);
		Board_FeedWatchdog();
	}
}

#endif /* BOARD_HAS_ONBOARD_LCD */
