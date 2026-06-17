#include "lcd_ui.h"
#include "lcd_config.h"
#include "board.h"
#include "lcd_st7735.h"
#include "motor.h"
#include "protocol.h"
#include "rod_sensor.h"

#define LCD_UI_REFRESH_MS  500

#define CN_TITLE           "\xC7\xD0\xD6\xBD\xBB\xFA\xD7\xB4\xCC\xAC"
#define CN_LABEL_PAPER     "\xD1\xB9\xD6\xBD"
#define CN_PAPER_ON        "\xD1\xB9\xD6\xBD\xD6\xD0"
#define CN_PAPER_OFF       "\xCE\xB4\xD1\xB9\xD6\xBD"
#define CN_LINK_ON         "\xD2\xD1\xC1\xAC\xBD\xD3"
#define CN_LINK_OFF        "\xCE\xB4\xC1\xAC\xBD\xD3"
#define CN_LABEL_MOTOR     "\xB5\xE7\xBB\xFA"
#define CN_MOTOR_STOP      "\xCD\xA3\xD6\xB9"
#define CN_MOTOR_RETRACT   "\xCB\xF5\xBB\xD8"
#define CN_MOTOR_EXTEND    "\xC9\xEC\xB3\xF6"

static uint32_t s_last_draw_ms = 0;
static uint8_t s_ui_ready = 0;
static uint8_t s_last_rod_home = 0xFF;
static uint8_t s_last_motor = 0xFF;
static uint8_t s_last_comm = 0xFF;

#define LCD_ROW_H           18
#define LCD_LABEL_W         32

static void LcdUi_DrawTitle(void)
{
	Lcd_FillRect(0, 0, LCD_WIDTH, 20, LCD_COLOR_BLACK);
	Lcd_DrawChinese(0, 2, CN_TITLE, LCD_COLOR_CYAN, LCD_COLOR_BLACK);
}

static void LcdUi_DrawRow(uint16_t y, const char *label, const char *value, uint16_t value_color)
{
	Lcd_FillRect(0, y, LCD_WIDTH, LCD_ROW_H, LCD_COLOR_BLACK);
	Lcd_DrawChinese(0, y, label, LCD_COLOR_WHITE, LCD_COLOR_BLACK);
	Lcd_DrawChinese(LCD_LABEL_W, y, value, value_color, LCD_COLOR_BLACK);
}

static void LcdUi_DrawRowUsb(uint16_t y, const char *value, uint16_t value_color)
{
	Lcd_FillRect(0, y, LCD_WIDTH, LCD_ROW_H, LCD_COLOR_BLACK);
	Lcd_DrawString(0, y + 4, "USB", LCD_COLOR_WHITE, LCD_COLOR_BLACK, 1);
	Lcd_DrawChinese(LCD_LABEL_W, y, value, value_color, LCD_COLOR_BLACK);
}

static void LcdUi_DrawPaper(uint8_t home)
{
	const char *text = home ? CN_PAPER_ON : CN_PAPER_OFF;
	uint16_t color = home ? LCD_COLOR_GREEN : LCD_COLOR_RED;

	LcdUi_DrawRow(26, CN_LABEL_PAPER, text, color);
}

static void LcdUi_DrawLink(uint8_t online)
{
	LcdUi_DrawRowUsb(50, online ? CN_LINK_ON : CN_LINK_OFF,
		online ? LCD_COLOR_GREEN : LCD_COLOR_RED);
}

static void LcdUi_DrawMotor(MotorState_t state)
{
	const char *text = CN_MOTOR_STOP;

	if (state == MOTOR_STATE_RETRACT)
		text = CN_MOTOR_RETRACT;
	else if (state == MOTOR_STATE_EXTEND)
		text = CN_MOTOR_EXTEND;

	LcdUi_DrawRow(74, CN_LABEL_MOTOR, text, LCD_COLOR_YELLOW);
}

static void LcdUi_DrawFrame(uint8_t rod_home, MotorState_t motor, uint8_t comm)
{
	LcdUi_DrawTitle();
	LcdUi_DrawPaper(rod_home);
	LcdUi_DrawLink(comm);
	LcdUi_DrawMotor(motor);
}

void LcdUi_Init(void)
{
	if (!Board_HasOnboardLcd())
		return;

	s_last_draw_ms = 0;
	s_ui_ready = 0;
	s_last_rod_home = 0xFF;
	s_last_motor = 0xFF;
	s_last_comm = 0xFF;

	Lcd_Init();
	Lcd_Fill(LCD_COLOR_BLACK);
	LcdUi_DrawFrame(RodSensor_IsHome(), Motor_GetState(), 0);
	s_ui_ready = 1;
}

void LcdUi_Tick(void)
{
	uint32_t now = Board_GetTickMs();
	uint8_t rod_home = RodSensor_IsHome();
	MotorState_t motor = Motor_GetState();
	uint8_t comm = Protocol_IsCommActive();
	uint8_t changed;

	if (!Board_HasOnboardLcd())
		return;

	if (!s_ui_ready)
		return;

	if ((now - s_last_draw_ms) < LCD_UI_REFRESH_MS)
		return;

	changed = (rod_home != s_last_rod_home) || ((uint8_t)motor != s_last_motor) || (comm != s_last_comm);
	if (!changed && s_last_draw_ms != 0)
		return;

	s_last_draw_ms = now;
	s_last_rod_home = rod_home;
	s_last_motor = (uint8_t)motor;
	s_last_comm = comm;

	LcdUi_DrawFrame(rod_home, motor, comm);
}

