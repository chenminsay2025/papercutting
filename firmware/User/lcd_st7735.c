#include "lcd_st7735.h"
#include "lcd_config.h"
#include "lcd_font.h"
#include "lcd_font_gb16.h"
#include "board.h"
#include "stm32f10x.h"
#if LCD_USE_HARD_SPI
#include "stm32f10x_spi.h"
#endif

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

#if LCD_USE_HARD_SPI
static void Lcd_SpiSendRaw(uint8_t dat)
{
	while (SPI_I2S_GetFlagStatus(SPI2, SPI_I2S_FLAG_TXE) == RESET)
		;
	SPI_I2S_SendData(SPI2, dat);
	while (SPI_I2S_GetFlagStatus(SPI2, SPI_I2S_FLAG_BSY) == SET)
		;
}

static void Lcd_SpiInit(void)
{
	SPI_InitTypeDef spi;

	RCC_APB1PeriphClockCmd(RCC_APB1Periph_SPI2, ENABLE);

	spi.SPI_Direction = SPI_Direction_1Line_Tx;
	spi.SPI_Mode = SPI_Mode_Master;
	spi.SPI_DataSize = SPI_DataSize_8b;
	spi.SPI_CPOL = SPI_CPOL_Low;
	spi.SPI_CPHA = SPI_CPHA_1Edge;
	spi.SPI_NSS = SPI_NSS_Soft;
	spi.SPI_BaudRatePrescaler = SPI_BaudRatePrescaler_2;
	spi.SPI_FirstBit = SPI_FirstBit_MSB;
	spi.SPI_CRCPolynomial = 7;
	SPI_Init(SPI2, &spi);
	SPI_Cmd(SPI2, ENABLE);
}
#endif

static void Lcd_WritBus(uint8_t dat)
{
#if LCD_USE_HARD_SPI
	LCD_CS_LOW();
	Lcd_SpiSendRaw(dat);
	LCD_CS_HIGH();
#else
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
#endif
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

static void Lcd_WriteByteHoldCs(uint8_t dat)
{
#if LCD_USE_HARD_SPI
	Lcd_SpiSendRaw(dat);
#else
	uint8_t i;

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
#endif
}

static void Lcd_StreamBegin(void)
{
	LCD_DC_DATA();
	LCD_CS_LOW();
}

static void Lcd_StreamData16(uint16_t dat)
{
	Lcd_WriteByteHoldCs((uint8_t)(dat >> 8));
	Lcd_WriteByteHoldCs((uint8_t)(dat & 0xFF));
}

static void Lcd_StreamEnd(void)
{
	LCD_CS_HIGH();
}

static void Lcd_AddressSet(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2)
{
	Lcd_WriteReg(0x2A);
	Lcd_WriteData16((uint16_t)(x1 + LCD_X_OFFSET));
	Lcd_WriteData16((uint16_t)(x2 + LCD_X_OFFSET));
	Lcd_WriteReg(0x2B);
	Lcd_WriteData16((uint16_t)(y1 + LCD_Y_OFFSET));
	Lcd_WriteData16((uint16_t)(y2 + LCD_Y_OFFSET));
	Lcd_WriteReg(0x2C);
}

static void Lcd_GpioInit(void)
{
	GPIO_InitTypeDef gpio;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB | RCC_APB2Periph_AFIO, ENABLE);

	gpio.GPIO_Mode = GPIO_Mode_Out_PP;
	gpio.GPIO_Speed = GPIO_Speed_50MHz;
	gpio.GPIO_Pin = LCD_DC_PIN | LCD_CS_PIN | LCD_RST_PIN | LCD_BLK_PIN;
	GPIO_Init(GPIOB, &gpio);
	GPIO_SetBits(GPIOB, LCD_DC_PIN | LCD_CS_PIN | LCD_RST_PIN);
	GPIO_SetBits(GPIOB, LCD_BLK_PIN);

#if LCD_USE_HARD_SPI
	gpio.GPIO_Pin = LCD_SCK_PIN | LCD_MOSI_PIN;
	gpio.GPIO_Mode = GPIO_Mode_AF_PP;
	GPIO_Init(GPIOB, &gpio);
	Lcd_SpiInit();
#else
	gpio.GPIO_Mode = GPIO_Mode_Out_PP;
	gpio.GPIO_Pin = LCD_SCK_PIN | LCD_MOSI_PIN;
	GPIO_Init(GPIOB, &gpio);
	GPIO_SetBits(GPIOB, LCD_SCK_PIN | LCD_MOSI_PIN);
#endif

	LCD_CS_HIGH();
	LCD_BLK_OFF();
}

#if LCD_DRIVER_ST7789
static void Lcd_InitSequence(void)
{
	LCD_RST_LOW();
	Board_DelayMs(20);
	LCD_RST_HIGH();
	Board_DelayMs(100);
	LCD_BLK_ON();

	Lcd_WriteReg(0x11);
	Board_DelayMs(120);

	Lcd_WriteReg(0x36);
	Lcd_WriteData8(LCD_MADCTL_VAL);

	Lcd_WriteReg(0x3A);
	Lcd_WriteData8(0x55);

	Lcd_WriteReg(0xB2);
	Lcd_WriteData8(0x0C);
	Lcd_WriteData8(0x0C);
	Lcd_WriteData8(0x00);
	Lcd_WriteData8(0x33);
	Lcd_WriteData8(0x33);

	Lcd_WriteReg(0xB7);
	Lcd_WriteData8(0x35);

	Lcd_WriteReg(0xBB);
	Lcd_WriteData8(0x2B);

	Lcd_WriteReg(0xC0);
	Lcd_WriteData8(0x2C);

	Lcd_WriteReg(0xC2);
	Lcd_WriteData8(0x01);

	Lcd_WriteReg(0xC3);
	Lcd_WriteData8(0x11);

	Lcd_WriteReg(0xC4);
	Lcd_WriteData8(0x20);

	Lcd_WriteReg(0xC6);
	Lcd_WriteData8(0x0F);

	Lcd_WriteReg(0xD0);
	Lcd_WriteData8(0xA4);
	Lcd_WriteData8(0xA1);

	Lcd_WriteReg(0xE0);
	Lcd_WriteData8(0xD0);
	Lcd_WriteData8(0x00);
	Lcd_WriteData8(0x05);
	Lcd_WriteData8(0x0E);
	Lcd_WriteData8(0x15);
	Lcd_WriteData8(0x0D);
	Lcd_WriteData8(0x37);
	Lcd_WriteData8(0x43);
	Lcd_WriteData8(0x47);
	Lcd_WriteData8(0x09);
	Lcd_WriteData8(0x15);
	Lcd_WriteData8(0x12);
	Lcd_WriteData8(0x16);
	Lcd_WriteData8(0x19);

	Lcd_WriteReg(0xE1);
	Lcd_WriteData8(0xD0);
	Lcd_WriteData8(0x00);
	Lcd_WriteData8(0x05);
	Lcd_WriteData8(0x0D);
	Lcd_WriteData8(0x0C);
	Lcd_WriteData8(0x06);
	Lcd_WriteData8(0x2D);
	Lcd_WriteData8(0x44);
	Lcd_WriteData8(0x40);
	Lcd_WriteData8(0x0E);
	Lcd_WriteData8(0x1C);
	Lcd_WriteData8(0x18);
	Lcd_WriteData8(0x16);
	Lcd_WriteData8(0x19);

	Lcd_WriteReg(0x29);
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

void Lcd_BlitRgb565(uint16_t x, uint16_t y, uint16_t w, uint16_t h, const uint16_t *data)
{
	uint16_t i;
	uint16_t j;
	uint16_t xend;
	uint16_t yend;
	uint32_t idx = 0;

	if (data == 0 || w == 0 || h == 0)
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

	Lcd_StreamBegin();
	for (i = y; i < yend; i++)
	{
		for (j = x; j < xend; j++)
		{
			Lcd_StreamData16(data[idx++]);
		}
		if ((i & 0xF) == 0)
			Board_FeedWatchdog();
	}
	Lcd_StreamEnd();
}

void Lcd_BlitImg(uint16_t x, uint16_t y, const LcdImg_t *img)
{
	if (img == 0 || img->Data == 0)
		return;
	Lcd_BlitRgb565(x, y, img->W, img->H, img->Data);
}

static uint16_t Lcd_Scale565(uint16_t c, uint8_t bright)
{
	uint8_t r;
	uint8_t g;
	uint8_t b;

	if (bright >= 255u)
		return c;
	if (bright == 0u)
		return 0x0000;

	r = (uint8_t)(((c >> 11) & 0x1Fu) * bright / 255u);
	g = (uint8_t)(((c >> 5) & 0x3Fu) * bright / 255u);
	b = (uint8_t)((c & 0x1Fu) * bright / 255u);
	return (uint16_t)(((uint16_t)r << 11) | ((uint16_t)g << 5) | b);
}

void Lcd_BlitImgBright(uint16_t x, uint16_t y, const LcdImg_t *img, uint8_t bright)
{
	uint16_t i;
	uint16_t j;
	uint16_t xend;
	uint16_t yend;
	uint32_t idx = 0;

	if (img == 0 || img->Data == 0)
		return;
	if (bright >= 255u)
	{
		Lcd_BlitImg(x, y, img);
		return;
	}
	if (x >= LCD_WIDTH || y >= LCD_HEIGHT)
		return;

	xend = x + img->W;
	yend = y + img->H;
	if (xend > LCD_WIDTH)
		xend = LCD_WIDTH;
	if (yend > LCD_HEIGHT)
		yend = LCD_HEIGHT;

	Lcd_AddressSet(x, y, (uint16_t)(xend - 1u), (uint16_t)(yend - 1u));

	Lcd_StreamBegin();
	for (i = y; i < yend; i++)
	{
		for (j = x; j < xend; j++)
		{
			Lcd_StreamData16(Lcd_Scale565(img->Data[idx++], bright));
		}
		if ((i & 0x0Fu) == 0u)
			Board_FeedWatchdog();
	}
	Lcd_StreamEnd();
}

void Lcd_BlitImgHScroll(uint16_t x, uint16_t y, uint16_t view_w, const LcdImg_t *img,
	uint16_t tile_w, uint16_t scroll, uint8_t bright)
{
	uint16_t col;
	uint16_t py;
	uint16_t xend;
	uint16_t yend;
	uint16_t src_x;

	if (img == 0 || img->Data == 0 || view_w == 0 || tile_w == 0)
		return;
	if (x >= LCD_WIDTH || y >= LCD_HEIGHT)
		return;

	xend = x + view_w;
	yend = y + img->H;
	if (xend > LCD_WIDTH)
		xend = LCD_WIDTH;
	if (yend > LCD_HEIGHT)
		yend = LCD_HEIGHT;
	view_w = (uint16_t)(xend - x);
	if (view_w == 0)
		return;

	Lcd_AddressSet(x, y, (uint16_t)(xend - 1u), (uint16_t)(yend - 1u));

	Lcd_StreamBegin();
	for (py = 0; py < img->H; py++)
	{
		for (col = 0; col < view_w; col++)
		{
			src_x = (uint16_t)((tile_w + col - scroll) % tile_w);
			Lcd_StreamData16(Lcd_Scale565(img->Data[(uint32_t)py * img->W + src_x], bright));
		}
		if ((py & 0x07u) == 0u)
			Board_FeedWatchdog();
	}
	Lcd_StreamEnd();
}

void Lcd_DrawChar(uint16_t x, uint16_t y, char c, uint16_t fg, uint16_t bg, uint8_t scale)
{
	const uint8_t *glyph = LcdFont_GetGlyph(c);
	uint8_t row;
	uint8_t col;
	uint8_t sy;
	uint8_t cw;
	uint8_t ch;

	if (scale == 0)
		scale = 1;

	cw = (uint8_t)(LCD_FONT_W * scale);
	ch = (uint8_t)(LCD_FONT_H * scale);

	Lcd_AddressSet(x, y, (uint16_t)(x + cw - 1), (uint16_t)(y + ch - 1));

	for (row = 0; row < LCD_FONT_H; row++)
	{
		for (sy = 0; sy < scale; sy++)
		{
			for (col = 0; col < LCD_FONT_W; col++)
			{
				uint16_t color = (glyph[col] & (1u << row)) ? fg : bg;
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

static uint16_t Lcd_Blend565(uint16_t fg, uint16_t bg, uint8_t weight);

static uint8_t Lcd_FontGetPixel(const uint8_t *glyph, uint8_t col, uint8_t row)
{
	if (col >= LCD_FONT_W || row >= LCD_FONT_H)
	{
		return 0u;
	}
	return (uint8_t)((glyph[col] & (1u << row)) ? 1u : 0u);
}

static uint16_t Lcd_AsciiFracPixelColor(const uint8_t *glyph, uint16_t oc, uint16_t or,
	uint8_t num, uint8_t den, uint16_t fg, uint16_t bg)
{
	uint32_t acc = 0;
	uint32_t cnt = (uint32_t)num * num;
	uint8_t sy;
	uint8_t sx;

	for (sy = 0; sy < num; sy++)
	{
		for (sx = 0; sx < num; sx++)
		{
			uint16_t sc = (uint16_t)((oc * den * num + sx * den + den / 2u) / (num * num));
			uint16_t sr = (uint16_t)((or * den * num + sy * den + den / 2u) / (num * num));

			if (sc < LCD_FONT_W && sr < LCD_FONT_H && Lcd_FontGetPixel(glyph, (uint8_t)sc, (uint8_t)sr))
			{
				acc++;
			}
		}
	}
	return Lcd_Blend565(fg, bg, (uint8_t)((acc * 255u + cnt / 2u) / cnt));
}

void Lcd_DrawCharScaledFrac(uint16_t x, uint16_t y, char c, uint16_t fg, uint16_t bg, uint8_t num, uint8_t den)
{
	const uint8_t *glyph = LcdFont_GetGlyph(c);
	uint16_t out_w;
	uint16_t out_h;
	uint16_t oc;
	uint16_t or;

	if (num == 0 || den == 0)
	{
		return;
	}

	out_w = (uint16_t)(LCD_FONT_W * num / den);
	out_h = (uint16_t)(LCD_FONT_H * num / den);
	if (out_w == 0u || out_h == 0u)
	{
		return;
	}

	Lcd_AddressSet(x, y, (uint16_t)(x + out_w - 1u), (uint16_t)(y + out_h - 1u));
	for (or = 0; or < out_h; or++)
	{
		for (oc = 0; oc < out_w; oc++)
		{
			Lcd_WriteData16(Lcd_AsciiFracPixelColor(glyph, oc, or, num, den, fg, bg));
		}
		Board_FeedWatchdog();
	}
}

void Lcd_DrawStringScaledFrac(uint16_t x, uint16_t y, const char *text, uint16_t fg, uint16_t bg, uint8_t num, uint8_t den)
{
	uint16_t advance;

	if (text == 0 || num == 0 || den == 0)
	{
		return;
	}

	advance = (uint16_t)(LCD_FONT_W * num / den);
	while (*text)
	{
		if (*text == '\n')
		{
			y = (uint16_t)(y + (LCD_FONT_H * num / den) + 1u);
		}
		else
		{
			Lcd_DrawCharScaledFrac(x, y, *text, fg, bg, num, den);
			x = (uint16_t)(x + advance);
			Board_FeedWatchdog();
		}
		text++;
	}
}

static uint16_t Lcd_Blend565(uint16_t fg, uint16_t bg, uint8_t weight)
{
	uint32_t fr;
	uint32_t fg_g;
	uint32_t fb;
	uint32_t br;
	uint32_t bg_g;
	uint32_t bb;
	uint32_t inv;
	uint32_t r;
	uint32_t g;
	uint32_t b;

	if (weight >= 255u)
	{
		return fg;
	}
	if (weight == 0u)
	{
		return bg;
	}

	fr = (fg >> 11) & 0x1Fu;
	fg_g = (fg >> 5) & 0x3Fu;
	fb = fg & 0x1Fu;
	br = (bg >> 11) & 0x1Fu;
	bg_g = (bg >> 5) & 0x3Fu;
	bb = bg & 0x1Fu;
	inv = 255u - weight;

	r = (fr * weight + br * inv + 127u) / 255u;
	g = (fg_g * weight + bg_g * inv + 127u) / 255u;
	b = (fb * weight + bb * inv + 127u) / 255u;
	return (uint16_t)((r << 11) | (g << 5) | b);
}

static uint16_t Lcd_Gb16PixelColor(const uint8_t *msk, uint8_t col, uint8_t row, uint16_t fg, uint16_t bg)
{
#if (LCD_GB16_AA_LEVELS > 0u)
	uint16_t bi;
	uint8_t v;
	uint8_t a;

	if (col >= LCD_GB16_W || row >= LCD_GB16_H)
	{
		return bg;
	}
	bi = (uint16_t)row * ((LCD_GB16_W + 1u) / 2u) + col / 2u;
	v = msk[bi];
	a = (col & 1u) ? (v & 0x0Fu) : (v >> 4);
	if (a == 0u)
	{
		return bg;
	}
	if (a >= (LCD_GB16_AA_LEVELS - 1u))
	{
		return fg;
	}
	return Lcd_Blend565(fg, bg, (uint8_t)((a * 255u + (LCD_GB16_AA_LEVELS / 2u)) / (LCD_GB16_AA_LEVELS - 1u)));
#else
	uint8_t byte;
	uint8_t bit;

	if (col < 8u)
	{
		byte = msk[row * 2u];
		bit = (uint8_t)(0x80u >> col);
	}
	else
	{
		byte = msk[row * 2u + 1u];
		bit = (uint8_t)(0x80u >> (col - 8u));
	}
	return (byte & bit) ? fg : bg;
#endif
}

#if (LCD_GB16_AA_LEVELS > 0u)
static void Lcd_DrawGb16Glyph(uint16_t x, uint16_t y, const uint8_t *msk, uint16_t fg, uint16_t bg)
{
	uint8_t row;
	uint8_t col;

	Lcd_AddressSet(x, y,
		(uint16_t)(x + LCD_GB16_W - 1u),
		(uint16_t)(y + LCD_GB16_H - 1u));
	Lcd_StreamBegin();
	for (row = 0u; row < LCD_GB16_H; row++)
	{
		for (col = 0u; col < LCD_GB16_W; col++)
		{
			Lcd_StreamData16(Lcd_Gb16PixelColor(msk, col, row, fg, bg));
		}
		Board_FeedWatchdog();
	}
	Lcd_StreamEnd();
}
#else
static void Lcd_DrawGb16Glyph(uint16_t x, uint16_t y, const uint8_t *msk, uint16_t fg, uint16_t bg)
{
	uint8_t row;
	uint8_t col;

	Lcd_AddressSet(x, y,
		(uint16_t)(x + LCD_GB16_W - 1u),
		(uint16_t)(y + LCD_GB16_H - 1u));
	Lcd_StreamBegin();
	for (row = 0u; row < LCD_GB16_H; row++)
	{
		for (col = 0u; col < LCD_GB16_W; col++)
		{
			uint8_t byte = msk[row * LCD_GB16_ROW_BYTES + col / 8u];
			uint8_t bit = (uint8_t)(0x80u >> (col % 8u));

			Lcd_StreamData16((byte & bit) ? fg : bg);
		}
		Board_FeedWatchdog();
	}
	Lcd_StreamEnd();
}
#endif

#if (LCD_GB16_AA_LEVELS > 0u)
static uint8_t Lcd_TryDrawGb16Ascii(uint16_t x, uint16_t y, char c, uint16_t fg, uint16_t bg)
{
	uint16_t k;
	uint8_t ch;

	ch = (uint8_t)c;
	for (k = 0u; k < g_lcd_font_gb16_count; k++)
	{
		if (g_lcd_font_gb16[k].Index[0] == 0u && g_lcd_font_gb16[k].Index[1] == ch)
		{
			Lcd_DrawGb16Glyph(x, y, g_lcd_font_gb16[k].Msk, fg, bg);
			if (g_lcd_font_gb16[k].AdvW > 0u)
			{
				return g_lcd_font_gb16[k].AdvW;
			}
			return LCD_GB16_HALF_W;
		}
	}
	return 0u;
}
#endif

uint8_t Lcd_Gb16CharAdvance(char c)
{
	uint16_t k;
	uint8_t ch;

	ch = (uint8_t)c;
	if (ch >= 0x80u)
	{
		return LCD_GB16_W;
	}
	for (k = 0u; k < g_lcd_font_gb16_count; k++)
	{
		if (g_lcd_font_gb16[k].Index[0] == 0u && g_lcd_font_gb16[k].Index[1] == ch)
		{
			if (g_lcd_font_gb16[k].AdvW > 0u)
			{
				return g_lcd_font_gb16[k].AdvW;
			}
			return LCD_GB16_HALF_W;
		}
	}
	return LCD_GB16_HALF_W;
}

void Lcd_DrawChinese16(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg)
{
	uint16_t k;
	uint16_t hznum;

	if (s == 0 || s[0] == 0 || s[1] == 0)
		return;

	hznum = g_lcd_font_gb16_count;
	for (k = 0; k < hznum; k++)
	{
		if ((g_lcd_font_gb16[k].Index[0] == (uint8_t)s[0]) &&
			(g_lcd_font_gb16[k].Index[1] == (uint8_t)s[1]))
		{
			Lcd_DrawGb16Glyph(x, y, g_lcd_font_gb16[k].Msk, fg, bg);
			return;
		}
	}
}

void Lcd_DrawStringGb16(uint16_t x, uint16_t y, const char *text, uint16_t fg, uint16_t bg)
{
	if (text == 0)
		return;

	while (*text)
	{
		if (*text == '\n')
		{
			y = (uint16_t)(y + LCD_GB16_H + 2u);
			text++;
		}
		else if ((uint8_t)*text >= 0x80u && text[1] != '\0')
		{
			Lcd_DrawChinese16(x, y, text, fg, bg);
			x = (uint16_t)(x + LCD_GB16_W);
			text += 2;
			Board_FeedWatchdog();
		}
		else
		{
			uint8_t adv;

#if (LCD_GB16_AA_LEVELS > 0u)
			adv = Lcd_TryDrawGb16Ascii(x, y, *text, fg, bg);
			if (adv == 0u)
#endif
			{
				adv = LCD_GB16_HALF_W;
			}
			x = (uint16_t)(x + adv);
			text++;
			Board_FeedWatchdog();
		}
	}
}

void Lcd_DrawChinese(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg)
{
	while (s && s[0] && s[1])
	{
		Lcd_DrawChinese16(x, y, s, fg, bg);
		s += 2;
		x = (uint16_t)(x + LCD_GB16_W);
		Board_FeedWatchdog();
	}
}

static void Lcd_DrawChinese16Scaled(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg, uint8_t scale)
{
	if (s == 0 || s[0] == 0 || s[1] == 0)
		return;
	if (scale == 0)
		scale = 1;
	if (scale == 1)
	{
		Lcd_DrawChinese16(x, y, s, fg, bg);
		return;
	}
#if (LCD_GB16_AA_LEVELS > 0u)
	Lcd_DrawChinese16(x, y, s, fg, bg);
#else
	{
		uint16_t k;
		uint8_t row;
		uint8_t col;
		uint8_t sy;
		uint8_t sx;
		uint16_t hznum;
		const uint8_t *msk;

		hznum = g_lcd_font_gb16_count;
		for (k = 0; k < hznum; k++)
		{
			if ((g_lcd_font_gb16[k].Index[0] == (uint8_t)s[0]) &&
				(g_lcd_font_gb16[k].Index[1] == (uint8_t)s[1]))
			{
				msk = g_lcd_font_gb16[k].Msk;
				Lcd_AddressSet(x, y,
					(uint16_t)(x + LCD_GB16_W * scale - 1u),
					(uint16_t)(y + LCD_GB16_H * scale - 1u));
				for (row = 0; row < LCD_GB16_H; row++)
				{
					for (sy = 0; sy < scale; sy++)
					{
						for (col = 0; col < LCD_GB16_W; col++)
						{
							uint16_t color = Lcd_Gb16PixelColor(msk, col, row, fg, bg);

							for (sx = 0; sx < scale; sx++)
								Lcd_WriteData16(color);
						}
						Board_FeedWatchdog();
					}
				}
				return;
			}
		}
	}
#endif
}

void Lcd_DrawChineseScaled(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg, uint8_t scale)
{
	if (scale == 0)
		scale = 1;

	while (s && s[0] && s[1])
	{
		Lcd_DrawChinese16Scaled(x, y, s, fg, bg, scale);
		s += 2;
		x = (uint16_t)(x + LCD_GB16_W * scale);
		Board_FeedWatchdog();
	}
}

static void Lcd_DrawChinese16ScaledFrac(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg, uint8_t num, uint8_t den)
{
	if (num == 0 || den == 0)
		return;
	if (s == 0 || s[0] == 0 || s[1] == 0)
		return;
#if (LCD_GB16_AA_LEVELS > 0u)
	Lcd_DrawChinese16(x, y, s, fg, bg);
#else
	{
		uint16_t k;
		uint8_t row;
		uint8_t col;
		uint8_t sy;
		uint8_t sx;
		uint16_t hznum;
		uint16_t out_w;
		uint16_t out_h;
		uint16_t phys_row_start;
		uint16_t phys_row_end;
		uint16_t phys_col_start;
		uint16_t phys_col_end;
		uint8_t phys_rows;
		uint8_t phys_cols;
		const uint8_t *msk;

		out_w = (uint16_t)(LCD_GB16_W * num / den);
		out_h = out_w;

		hznum = g_lcd_font_gb16_count;
		for (k = 0; k < hznum; k++)
		{
			if ((g_lcd_font_gb16[k].Index[0] == (uint8_t)s[0]) &&
				(g_lcd_font_gb16[k].Index[1] == (uint8_t)s[1]))
			{
				msk = g_lcd_font_gb16[k].Msk;
				Lcd_AddressSet(x, y, (uint16_t)(x + out_w - 1u), (uint16_t)(y + out_h - 1u));
				for (row = 0; row < LCD_GB16_H; row++)
				{
					phys_row_start = (uint16_t)(row * num / den);
					phys_row_end = (uint16_t)((row + 1u) * num / den);
					phys_rows = (uint8_t)(phys_row_end - phys_row_start);
					for (sy = 0; sy < phys_rows; sy++)
					{
						for (col = 0; col < LCD_GB16_W; col++)
						{
							uint16_t color = Lcd_Gb16PixelColor(msk, col, row, fg, bg);

							phys_col_start = (uint16_t)(col * num / den);
							phys_col_end = (uint16_t)((col + 1u) * num / den);
							phys_cols = (uint8_t)(phys_col_end - phys_col_start);
							for (sx = 0; sx < phys_cols; sx++)
								Lcd_WriteData16(color);
						}
						Board_FeedWatchdog();
					}
				}
				return;
			}
		}
	}
#endif
}

void Lcd_DrawChineseScaledFrac(uint16_t x, uint16_t y, const char *s, uint16_t fg, uint16_t bg, uint8_t num, uint8_t den)
{
	uint16_t advance;

	if (num == 0 || den == 0)
		return;

	advance = (uint16_t)(LCD_GB16_W * num / den);
	while (s && s[0] && s[1])
	{
		Lcd_DrawChinese16ScaledFrac(x, y, s, fg, bg, num, den);
		s += 2;
		x = (uint16_t)(x + advance);
		Board_FeedWatchdog();
	}
}

static void Lcd_MosiAsInput(void)
{
	GPIO_InitTypeDef gpio;

#if LCD_USE_HARD_SPI
	SPI_Cmd(SPI2, DISABLE);
#endif
	gpio.GPIO_Pin = LCD_MOSI_PIN;
	gpio.GPIO_Mode = GPIO_Mode_IPU;
	gpio.GPIO_Speed = GPIO_Speed_2MHz;
	GPIO_Init(LCD_MOSI_GPIO, &gpio);
}

static void Lcd_MosiAsOutput(void)
{
	GPIO_InitTypeDef gpio;

#if LCD_USE_HARD_SPI
	gpio.GPIO_Pin = LCD_MOSI_PIN;
	gpio.GPIO_Mode = GPIO_Mode_AF_PP;
	gpio.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(LCD_MOSI_GPIO, &gpio);
	SPI_Cmd(SPI2, ENABLE);
#else
	gpio.GPIO_Pin = LCD_MOSI_PIN;
	gpio.GPIO_Mode = GPIO_Mode_Out_PP;
	gpio.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(LCD_MOSI_GPIO, &gpio);
	GPIO_SetBits(LCD_MOSI_GPIO, LCD_MOSI_PIN);
#endif
}

#if LCD_USE_HARD_SPI
static void Lcd_SckAsGpioOutput(void)
{
	GPIO_InitTypeDef gpio;

	SPI_Cmd(SPI2, DISABLE);
	gpio.GPIO_Pin = LCD_SCK_PIN;
	gpio.GPIO_Mode = GPIO_Mode_Out_PP;
	gpio.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(LCD_SCK_GPIO, &gpio);
	GPIO_SetBits(LCD_SCK_GPIO, LCD_SCK_PIN);
}

static void Lcd_SckAsSpiAf(void)
{
	GPIO_InitTypeDef gpio;

	gpio.GPIO_Pin = LCD_SCK_PIN;
	gpio.GPIO_Mode = GPIO_Mode_AF_PP;
	gpio.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(LCD_SCK_GPIO, &gpio);
	SPI_Cmd(SPI2, ENABLE);
}
#endif

static uint8_t Lcd_ReadBus(void)
{
	uint8_t i;
	uint8_t dat = 0;

	for (i = 0; i < 8; i++)
	{
		dat <<= 1;
		LCD_SCK_LOW();
		if (GPIO_ReadInputDataBit(LCD_MOSI_GPIO, LCD_MOSI_PIN) == Bit_SET)
			dat |= 0x01;
		LCD_SCK_HIGH();
	}
	return dat;
}

static uint8_t Lcd_ProbeIdLooksValid(uint8_t b1, uint8_t b2, uint8_t b3)
{
	if ((b1 == 0x00 && b2 == 0x00 && b3 == 0x00) ||
		(b1 == 0xFF && b2 == 0xFF && b3 == 0xFF))
	{
		return 0;
	}
#if LCD_DRIVER_ST7789
	if (b2 == 0x85u || b3 == 0x85u || b2 == 0x77u || b3 == 0x89u)
		return 1;
#endif
	return 1;
}

uint8_t Lcd_Probe(void)
{
	uint8_t b1;
	uint8_t b2;
	uint8_t b3;

	Lcd_GpioInit();

	LCD_RST_LOW();
	Board_DelayMs(20);
	LCD_RST_HIGH();
	Board_DelayMs(120);

	LCD_CS_LOW();
	LCD_DC_CMD();
#if LCD_USE_HARD_SPI
	Lcd_SpiSendRaw(0x04);
#else
	Lcd_WritBus(0x04);
#endif
	LCD_DC_DATA();

#if LCD_USE_HARD_SPI
	Lcd_SckAsGpioOutput();
#endif

	Lcd_MosiAsInput();
	(void)Lcd_ReadBus();
	b1 = Lcd_ReadBus();
	b2 = Lcd_ReadBus();
	b3 = Lcd_ReadBus();
	Lcd_MosiAsOutput();
#if LCD_USE_HARD_SPI
	Lcd_SckAsSpiAf();
#endif
	LCD_CS_HIGH();

	if (!Lcd_ProbeIdLooksValid(b1, b2, b3))
		return 0;

	return 1;
}

void Lcd_GpioRelease(void)
{
	GPIO_InitTypeDef gpio;

	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);

	gpio.GPIO_Mode = GPIO_Mode_IPU;
	gpio.GPIO_Speed = GPIO_Speed_2MHz;
	gpio.GPIO_Pin = LCD_DC_PIN | LCD_CS_PIN | LCD_RST_PIN | LCD_BLK_PIN |
		LCD_SCK_PIN | LCD_MOSI_PIN;
	GPIO_Init(GPIOB, &gpio);
}

