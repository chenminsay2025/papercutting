#include "oled_ui.h"
#include "oled_config.h"
#include "oled_ssd1306.h"
#include "board.h"
#include "motor.h"
#include "protocol.h"
#include "rod_sensor.h"

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

static void OledUi_DrawTitle(void)
{
	Oled_ShowChinese(0, 0, CN_TITLE);
}

static void OledUi_DrawRow(uint8_t page, const char *label, const char *value)
{
	Oled_ShowChinese(0, page, label);
	Oled_ShowChinese(40, page, value);
}

static void OledUi_DrawRowUsb(uint8_t page, const char *value)
{
	Oled_ShowString(0, page, "USB");
	Oled_ShowChinese(24, page, value);
}

static void OledUi_DrawFrame(uint8_t rod_home, MotorState_t motor, uint8_t comm)
{
	const char *motor_text = CN_MOTOR_STOP;

	if (motor == MOTOR_STATE_RETRACT)
		motor_text = CN_MOTOR_RETRACT;
	else if (motor == MOTOR_STATE_EXTEND)
		motor_text = CN_MOTOR_EXTEND;

	Oled_Clear();
	OledUi_DrawTitle();
	OledUi_DrawRow(2, CN_LABEL_PAPER, rod_home ? CN_PAPER_ON : CN_PAPER_OFF);
	OledUi_DrawRowUsb(4, comm ? CN_LINK_ON : CN_LINK_OFF);
	OledUi_DrawRow(6, CN_LABEL_MOTOR, motor_text);
}

void OledUi_Init(void)
{
	s_last_draw_ms = 0;
	s_ui_ready = 0;
	s_last_rod_home = 0xFF;
	s_last_motor = 0xFF;
	s_last_comm = 0xFF;

	Oled_Init();
	OledUi_DrawFrame(RodSensor_IsHome(), Motor_GetState(), 0);
	s_ui_ready = 1;
}

void OledUi_Tick(void)
{
	uint32_t now = Board_GetTickMs();
	uint8_t rod_home = RodSensor_IsHome();
	MotorState_t motor = Motor_GetState();
	uint8_t comm = Protocol_IsCommActive();
	uint8_t changed;

	if (!s_ui_ready)
		return;

	if ((now - s_last_draw_ms) < OLED_UI_REFRESH_MS)
		return;

	changed = (rod_home != s_last_rod_home) || ((uint8_t)motor != s_last_motor) || (comm != s_last_comm);
	if (!changed && s_last_draw_ms != 0)
		return;

	s_last_draw_ms = now;
	s_last_rod_home = rod_home;
	s_last_motor = (uint8_t)motor;
	s_last_comm = comm;

	OledUi_DrawFrame(rod_home, motor, comm);
}
