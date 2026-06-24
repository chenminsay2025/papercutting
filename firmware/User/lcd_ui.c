#include "lcd_ui.h"
#include "lcd_config.h"
#include "board.h"
#include "lcd_st7735.h"
#include "lcd_font_gb16.h"
#include "lcd_ui_labels.h"
#include "rod_sensor.h"
#include "obstacle_sensor.h"
#include "protocol.h"
#include <string.h>

#define UI_PROGRESS_IDLE       0xFF

#define UI_LOG_CAPACITY        16u
#define UI_LOG_VISIBLE         8u
#define UI_LOG_LINE_H          18u
#define UI_STEP_CURRENT_NONE   0xFFu

#define UI_GLYPH_W             LCD_GB16_W
#define UI_GLYPH_H             LCD_GB16_H
#define UI_CN_H                UI_GLYPH_H
#define UI_CN_W                UI_GLYPH_W

static void LcdUi_DrawCn(uint16_t x, uint16_t y, const char *text_gb, uint16_t fg, uint16_t bg)
{
	Lcd_DrawChinese(x, y, text_gb, fg, bg);
}

static void LcdUi_DrawText16(uint16_t x, uint16_t y, const char *text, uint16_t fg, uint16_t bg)
{
	Lcd_DrawStringGb16(x, y, text, fg, bg);
}

static uint16_t LcdUi_Text16Width(const char *text)
{
	uint16_t w = 0;

	if (text == NULL)
		return 0u;

	while (*text)
	{
		if ((uint8_t)*text >= 0x80u && text[1] != '\0')
		{
			w = (uint16_t)(w + UI_GLYPH_W);
			text += 2;
		}
		else if (*text == '\n')
		{
			text++;
		}
		else
		{
			w = (uint16_t)(w + Lcd_Gb16CharAdvance(*text));
			text++;
		}
	}
	return w;
}

#define UI_COL_MUTED           0x528A  /* 未执行步骤：较 UI_COL_TEXT 更暗 */
#define UI_COL_OK              0x57E8
#define UI_COL_DONE            0x9CD3
#define UI_COL_TEXT            0xEF7D
#define UI_COL_BORDER          0x2945u /* 淡色描边 */
#define UI_COL_WARN            0xFD20u /* 离线等告警文字 */
#define UI_COL_BAD             0xF040u /* 未压纸等告警文字 */
#define UI_RADIUS              3u
#define UI_BG                  LCD_COLOR_BLACK

#if LCD_WIDTH < LCD_HEIGHT && LCD_HEIGHT >= 300

#define UI_PAD_X               10u
#define UI_INNER_W             (uint16_t)(LCD_WIDTH - UI_PAD_X * 2u)
#define UI_STATUS_Y              6u
#define UI_STATUS_ICON_W         70u
#define UI_STATUS_ICON_H         35u
#define UI_STATUS_GAP            4u
#define UI_STATUS_ROW_W          (uint16_t)(UI_STATUS_ICON_W * 3u + UI_STATUS_GAP * 2u)
#define UI_STATUS_DISP_H         UI_STATUS_ICON_H
#define UI_STEP_Y                47u
#define UI_STEP_H              178u
#define UI_STEP_VIEW_Y         51u
#define UI_STEP_VIEW_H         (uint16_t)(UI_LOG_VISIBLE * UI_LOG_LINE_H)
#define UI_PROG_Y              228u
#define UI_PROG_H              5u
#define UI_FOOT_Y              240u

typedef struct
{
	uint8_t label_id;
} UiLogEntry_t;

static UiLogEntry_t s_log[UI_LOG_CAPACITY];
static uint8_t s_log_count = 0;
static uint8_t s_current_idx = UI_STEP_CURRENT_NONE;
static uint8_t s_scroll_start = 0u;
static uint8_t s_ui_ready = 0;
static uint8_t s_last_rod_home = 0xFF;
static uint8_t s_last_comm = 0xFF;
static uint8_t s_last_obstacle = 0xFF;
static uint8_t s_ui_progress = UI_PROGRESS_IDLE;
static uint16_t s_prog_target_x10 = 0u;
static uint16_t s_prog_display_x10 = 0u;
static uint16_t s_prog_last_fill_w = 0xFFFFu;
static uint8_t s_prog_visible = 0u;
static uint8_t s_prog_dirty = 1u;
static uint8_t s_prog_lock_decrease = 0u;
static uint8_t s_wait_active = 0u;
static uint16_t s_wait_elapsed_ds = 0u;
static uint16_t s_wait_total_ds = 0u;
static uint16_t s_last_wait_drawn_ds = 0xFFFFu;

static void LcdUi_DrawProgress(void);

static void LcdUi_DrawChrome(void)
{
	Lcd_Fill(LCD_COLOR_BLACK);
}

static void LcdUi_DrawRoundRectBorder(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint16_t color)
{
	uint16_t r = UI_RADIUS;
	uint16_t i;

	if (w < 2u || h < 2u)
	{
		return;
	}

	if (w <= (uint16_t)(r * 2u) || h <= (uint16_t)(r * 2u))
	{
		Lcd_FillRect(x, y, w, 1u, color);
		Lcd_FillRect(x, (uint16_t)(y + h - 1u), w, 1u, color);
		Lcd_FillRect(x, y, 1u, h, color);
		Lcd_FillRect((uint16_t)(x + w - 1u), y, 1u, h, color);
		return;
	}

	Lcd_FillRect((uint16_t)(x + r), y, (uint16_t)(w - r * 2u), 1u, color);
	Lcd_FillRect((uint16_t)(x + r), (uint16_t)(y + h - 1u), (uint16_t)(w - r * 2u), 1u, color);
	Lcd_FillRect(x, (uint16_t)(y + r), 1u, (uint16_t)(h - r * 2u), color);
	Lcd_FillRect((uint16_t)(x + w - 1u), (uint16_t)(y + r), 1u, (uint16_t)(h - r * 2u), color);

	for (i = 0u; i < r; i++)
	{
		uint16_t dx = (uint16_t)(r - i);

		Lcd_FillRect((uint16_t)(x + dx), (uint16_t)(y + i), 1u, 1u, color);
		Lcd_FillRect((uint16_t)(x + w - 1u - dx), (uint16_t)(y + i), 1u, 1u, color);
		Lcd_FillRect((uint16_t)(x + dx), (uint16_t)(y + h - 1u - i), 1u, 1u, color);
		Lcd_FillRect((uint16_t)(x + w - 1u - dx), (uint16_t)(y + h - 1u - i), 1u, 1u, color);
	}
}

static void LcdUi_DrawPanel(uint16_t x, uint16_t y, uint16_t w, uint16_t h)
{
	Lcd_FillRect(x, y, w, h, UI_BG);
	LcdUi_DrawRoundRectBorder(x, y, w, h, UI_COL_BORDER);
}

static void LcdUi_DrawStatusBar(uint8_t rod_home, uint8_t comm, uint8_t obstacle_blocked)
{
	uint16_t x_usb;
	uint16_t x_paper;
	uint16_t x_obs;
	const LcdImg_t *usb = comm ? &g_lcd_img_usb_on : &g_lcd_img_usb_off;
	const LcdImg_t *paper = rod_home ? &g_lcd_img_paper_press : &g_lcd_img_paper_lift;
	const LcdImg_t *obs = obstacle_blocked ? &g_lcd_img_obstacle_blocked : &g_lcd_img_obstacle_clear;

	x_usb = (uint16_t)(UI_PAD_X + (UI_INNER_W - UI_STATUS_ROW_W) / 2u);
	x_paper = (uint16_t)(x_usb + UI_STATUS_ICON_W + UI_STATUS_GAP);
	x_obs = (uint16_t)(x_paper + UI_STATUS_ICON_W + UI_STATUS_GAP);

	Lcd_FillRect(UI_PAD_X, UI_STATUS_Y, UI_INNER_W, UI_STATUS_DISP_H, UI_BG);
	Lcd_BlitImg(x_usb, UI_STATUS_Y, usb);
	Lcd_BlitImg(x_paper, UI_STATUS_Y, paper);
	Lcd_BlitImg(x_obs, UI_STATUS_Y, obs);
}

static void LcdUi_DrawLogLabelText(uint16_t x, uint16_t y, const char *label, uint16_t fg, uint16_t bg)
{
	LcdUi_DrawText16(x, y, label, fg, bg);
}

static void LcdUi_UpdateScroll(void)
{
	if (s_log_count <= UI_LOG_VISIBLE)
	{
		s_scroll_start = 0u;
		return;
	}

	if (s_current_idx == UI_STEP_CURRENT_NONE)
	{
		s_scroll_start = 0u;
		return;
	}

	if (s_current_idx < s_scroll_start)
	{
		s_scroll_start = s_current_idx;
	}
	else if (s_current_idx >= (uint8_t)(s_scroll_start + UI_LOG_VISIBLE))
	{
		s_scroll_start = (uint8_t)(s_current_idx + 1u - UI_LOG_VISIBLE);
	}
}

static void LcdUi_DrawStepPrefix(uint16_t x, uint16_t y, uint8_t seq, uint16_t fg)
{
	char prefix[4];
	uint8_t n = 0u;

	if (seq >= 10u)
	{
		prefix[n++] = (char)('0' + (seq / 10u));
		prefix[n++] = (char)('0' + (seq % 10u));
	}
	else
	{
		prefix[n++] = (char)('0' + seq);
	}
	prefix[n++] = '.';
	prefix[n] = '\0';
	LcdUi_DrawText16(x, y, prefix, fg, UI_BG);
}

static void LcdUi_DrawLogLine(uint16_t y, uint8_t list_idx, uint8_t seq, uint8_t label_id)
{
	uint16_t fg;
	const char *label = LcdUiLabels_Get(label_id);
	uint16_t label_x;

	if (s_current_idx == UI_STEP_CURRENT_NONE)
	{
		fg = UI_COL_MUTED;
	}
	else if (list_idx == s_current_idx)
	{
		fg = LCD_COLOR_UI_CYAN;
	}
	else if (list_idx < s_current_idx)
	{
		fg = UI_COL_DONE;
	}
	else
	{
		fg = UI_COL_MUTED;
	}

	LcdUi_DrawStepPrefix((uint16_t)(UI_PAD_X + 4u), y, seq, fg);
	label_x = (uint16_t)(UI_PAD_X + 4u + LcdUi_Text16Width("16."));
	LcdUi_DrawLogLabelText(label_x, y, label, fg, UI_BG);
}

static void LcdUi_DrawLogViewport(void)
{
	uint8_t i;

	Lcd_FillRect((uint16_t)(UI_PAD_X + 1u), UI_STEP_VIEW_Y,
		(uint16_t)(UI_INNER_W - 2u), UI_STEP_VIEW_H, UI_BG);

	if (s_log_count == 0u)
	{
		LcdUi_DrawCn((uint16_t)(UI_PAD_X + 6u), (uint16_t)(UI_STEP_VIEW_Y + 2u),
			"\xb5\xc8\xb4\xfd\xbf\xaa\xca\xbc", UI_COL_MUTED, UI_BG); /* 等待开始 */
		return;
	}

	LcdUi_UpdateScroll();

	for (i = 0u; i < UI_LOG_VISIBLE; i++)
	{
		uint8_t log_idx = (uint8_t)(s_scroll_start + i);
		uint16_t line_y;

		if (log_idx >= s_log_count)
		{
			break;
		}
		line_y = (uint16_t)(UI_STEP_VIEW_Y + (uint16_t)i * UI_LOG_LINE_H);
		LcdUi_DrawLogLine(line_y, log_idx, (uint8_t)(log_idx + 1u), s_log[log_idx].label_id);
	}
}

static void LcdUi_RedrawLog(void)
{
	LcdUi_DrawPanel(UI_PAD_X, UI_STEP_Y, UI_INNER_W, UI_STEP_H);
	LcdUi_DrawLogViewport();
}

static void LcdUi_AppendDec(char *buf, uint8_t *pos, uint16_t value)
{
	uint8_t digits[5];
	uint8_t count = 0;
	uint8_t i;

	if (value == 0u)
	{
		buf[(*pos)++] = '0';
		return;
	}
	while (value > 0u && count < 5u)
	{
		digits[count++] = (uint8_t)(value % 10u);
		value = (uint16_t)(value / 10u);
	}
	for (i = count; i > 0u; i--)
	{
		buf[(*pos)++] = (char)('0' + digits[i - 1u]);
	}
}

static void LcdUi_DrawWaitTimerText(uint16_t x, uint16_t y, uint16_t elapsed_ds, uint16_t total_ds)
{
	char buf[20];
	uint8_t pos = 0u;
	uint16_t es;
	uint16_t ed;
	uint16_t ts;
	uint16_t td;

	es = (uint16_t)(elapsed_ds / 10u);
	ed = (uint16_t)(elapsed_ds % 10u);
	LcdUi_AppendDec(buf, &pos, es);
	buf[pos++] = '.';
	buf[pos++] = (char)('0' + ed);
	if (total_ds > 0u)
	{
		buf[pos++] = '/';
		ts = (uint16_t)(total_ds / 10u);
		td = (uint16_t)(total_ds % 10u);
		LcdUi_AppendDec(buf, &pos, ts);
		if (td > 0u || total_ds < 100u)
		{
			buf[pos++] = '.';
			buf[pos++] = (char)('0' + td);
		}
	}
	buf[pos++] = 's';
	buf[pos] = '\0';
	LcdUi_DrawText16(x, y, buf, LCD_COLOR_UI_CYAN, UI_BG);
}

static void LcdUi_DrawFooter(void)
{
	uint16_t x;
	uint16_t timer_w;
	uint16_t timer_x;

	if (s_wait_active)
	{
		Lcd_FillRect(UI_PAD_X, UI_FOOT_Y, UI_INNER_W, UI_CN_H, UI_BG);
		LcdUi_DrawCn((uint16_t)(UI_PAD_X + 2u), UI_FOOT_Y,
			"\xb5\xc8\xb4\xfd", UI_COL_MUTED, UI_BG); /* 等待 */
		timer_w = (uint16_t)(LcdUi_Text16Width("999.9/999.9s") + 4u);
		timer_x = (uint16_t)(UI_PAD_X + UI_INNER_W - timer_w);
		LcdUi_DrawWaitTimerText(timer_x, UI_FOOT_Y, s_wait_elapsed_ds, s_wait_total_ds);
		return;
	}

	LcdUi_DrawText16(UI_PAD_X, UI_FOOT_Y, "PB8", UI_COL_MUTED, UI_BG);
	x = (uint16_t)(UI_PAD_X + LcdUi_Text16Width("PB8") + 4u);
	LcdUi_DrawCn(x, UI_FOOT_Y,
		"\xb0\xb4\xcf\xc2\xcb\xf5/\xc9\xec",
		UI_COL_MUTED, UI_BG); /* 按下缩/伸 */
	LcdUi_DrawText16((uint16_t)(LCD_WIDTH - UI_PAD_X - LcdUi_Text16Width("3s")), UI_FOOT_Y,
		"3s", UI_COL_MUTED, UI_BG);
}

static void LcdUi_ProgMarkDirty(void)
{
	s_prog_dirty = 1u;
}

void LcdUi_SetProgressX10(uint16_t percent_x10)
{
	if (!Board_HasOnboardLcd())
	{
		return;
	}

	if (percent_x10 > 1000u)
	{
		percent_x10 = 1000u;
	}
	if (s_ui_progress != UI_PROGRESS_IDLE && s_prog_target_x10 == percent_x10 && s_prog_visible)
	{
		return;
	}

	if (s_prog_lock_decrease && percent_x10 < s_prog_target_x10)
	{
		return;
	}
	if (percent_x10 == 0u)
	{
		s_prog_lock_decrease = 0u;
	}
	else if (percent_x10 > s_prog_target_x10)
	{
		s_prog_lock_decrease = 1u;
	}

	s_ui_progress = (uint8_t)(percent_x10 / 10u);
	s_prog_target_x10 = percent_x10;
	s_prog_display_x10 = percent_x10;
	s_prog_visible = 1u;
	if (percent_x10 == 0u)
	{
		s_prog_last_fill_w = 0xFFFFu;
	}
	LcdUi_ProgMarkDirty();
	if (s_ui_ready && percent_x10 == 0u)
	{
		s_prog_dirty = 0u;
		LcdUi_DrawProgress();
	}
}

static void LcdUi_DrawProgress(void)
{
	uint16_t x = UI_PAD_X;
	uint16_t y = UI_PROG_Y;
	uint16_t w = UI_INNER_W;
	uint16_t fill_w;

	if (!s_prog_visible && s_prog_display_x10 == 0u)
	{
		Lcd_FillRect(x, y, w, UI_PROG_H, LCD_COLOR_BLACK);
		s_prog_last_fill_w = 0xFFFFu;
		return;
	}

	fill_w = (uint16_t)((uint32_t)w * s_prog_display_x10 / 1000u);

	if (s_prog_last_fill_w == 0xFFFFu || fill_w < s_prog_last_fill_w)
	{
		Lcd_FillRect(x, y, w, UI_PROG_H, UI_BG);
		if (fill_w > 0u)
		{
			Lcd_FillRect(x, y, fill_w, UI_PROG_H, LCD_COLOR_UI_CYAN);
		}
	}
	else if (fill_w > s_prog_last_fill_w)
	{
		Lcd_FillRect((uint16_t)(x + s_prog_last_fill_w), y,
			(uint16_t)(fill_w - s_prog_last_fill_w), UI_PROG_H, LCD_COLOR_UI_CYAN);
	}

	s_prog_last_fill_w = fill_w;
}

static void LcdUi_ProgressService(void)
{
	if (s_prog_dirty)
	{
		s_prog_dirty = 0u;
		LcdUi_DrawProgress();
	}
}

static void LcdUi_RedrawAll(uint8_t rod_home, uint8_t comm, uint8_t obstacle_blocked)
{
	LcdUi_DrawChrome();
	LcdUi_DrawStatusBar(rod_home, comm, obstacle_blocked);
	LcdUi_RedrawLog();
	LcdUi_DrawProgress();
	LcdUi_DrawFooter();
}

void LcdUi_Init(void)
{
	if (!Board_HasOnboardLcd())
	{
		return;
	}

	memset(s_log, 0, sizeof(s_log));
	s_log_count = 0;
	s_current_idx = UI_STEP_CURRENT_NONE;
	s_scroll_start = 0u;
	s_last_rod_home = 0xFF;
	s_last_comm = 0xFF;
	s_last_obstacle = 0xFF;
	s_ui_progress = UI_PROGRESS_IDLE;
	s_prog_target_x10 = 0u;
	s_prog_display_x10 = 0u;
	s_prog_last_fill_w = 0xFFFFu;
	s_prog_visible = 0u;
	s_prog_dirty = 1u;

	Lcd_Init();
	LcdUi_RedrawAll(RodSensor_IsHome(), 0, ObstacleSensor_IsBlocked());
	s_last_rod_home = RodSensor_IsHome();
	s_last_comm = 0;
	s_last_obstacle = ObstacleSensor_IsBlocked();
	s_ui_ready = 1;
}

void LcdUi_ScrollPoll(void)
{
	if (!Board_HasOnboardLcd() || !s_ui_ready)
	{
		return;
	}
	LcdUi_ProgressService();
}

void LcdUi_SetProgress(uint8_t percent)
{
	if (percent > 100u)
	{
		percent = 100u;
	}
	LcdUi_SetProgressX10((uint16_t)percent * 10u);
}

void LcdUi_ClearProgress(void)
{
	if (!Board_HasOnboardLcd())
	{
		return;
	}

	if (s_ui_progress == UI_PROGRESS_IDLE && !s_prog_visible && s_prog_display_x10 == 0u)
	{
		return;
	}

	s_ui_progress = UI_PROGRESS_IDLE;
	s_prog_target_x10 = 0u;
	s_prog_display_x10 = 0u;
	s_prog_visible = 0u;
	s_prog_last_fill_w = 0xFFFFu;
	s_prog_lock_decrease = 0u;
	LcdUi_ProgMarkDirty();
	if (s_ui_ready)
	{
		s_prog_dirty = 0u;
		LcdUi_DrawProgress();
	}
}

void LcdUi_SetStepList(const uint8_t *label_ids, uint8_t count, uint8_t current_idx)
{
	uint8_t n = count;

	if (!Board_HasOnboardLcd())
	{
		return;
	}

	if (n > UI_LOG_CAPACITY)
	{
		n = UI_LOG_CAPACITY;
	}

	s_log_count = n;
	if (label_ids != NULL && n > 0u)
	{
		uint8_t i;

		for (i = 0u; i < n; i++)
		{
			s_log[i].label_id = label_ids[i];
		}
	}

	if (current_idx == UI_STEP_CURRENT_NONE || current_idx >= s_log_count)
	{
		s_current_idx = UI_STEP_CURRENT_NONE;
	}
	else
	{
		s_current_idx = current_idx;
	}

	LcdUi_UpdateScroll();
	if (s_ui_ready)
	{
		LcdUi_DrawLogViewport();
	}
}

void LcdUi_SetCurrentStep(uint8_t current_idx)
{
	if (!Board_HasOnboardLcd())
	{
		return;
	}
	if (current_idx != UI_STEP_CURRENT_NONE && current_idx >= s_log_count)
	{
		return;
	}

	if (s_current_idx == current_idx)
	{
		return;
	}

	s_current_idx = current_idx;
	LcdUi_UpdateScroll();
	if (s_ui_ready)
	{
		LcdUi_DrawLogViewport();
	}
}

void LcdUi_AppendStep(uint8_t label_id)
{
	if (!Board_HasOnboardLcd())
	{
		return;
	}

	if (s_log_count < UI_LOG_CAPACITY)
	{
		s_log[s_log_count].label_id = label_id;
		s_log_count++;
		s_current_idx = (uint8_t)(s_log_count - 1u);
	}
	else
	{
		memmove(&s_log[0], &s_log[1], (UI_LOG_CAPACITY - 1u) * sizeof(s_log[0]));
		s_log[UI_LOG_CAPACITY - 1u].label_id = label_id;
		s_current_idx = (uint8_t)(UI_LOG_CAPACITY - 1u);
	}
	LcdUi_UpdateScroll();
	if (s_ui_ready)
	{
		LcdUi_DrawLogViewport();
	}
}

void LcdUi_ClearSteps(void)
{
	if (!Board_HasOnboardLcd())
	{
		return;
	}

	s_log_count = 0;
	s_current_idx = UI_STEP_CURRENT_NONE;
	s_scroll_start = 0u;
	if (s_ui_ready)
	{
		LcdUi_DrawLogViewport();
	}
}

void LcdUi_SetMeta(uint8_t idx, uint8_t total, uint32_t elapsed_ms, uint32_t total_ms, uint16_t loop)
{
	/* UI_META 仍由后端发送，屏幕不再显示步骤计数/百分比 */
	(void)idx;
	(void)total;
	(void)elapsed_ms;
	(void)total_ms;
	(void)loop;
}

void LcdUi_SetPhase(uint8_t phase)
{
	(void)phase;
}

void LcdUi_SetLoop(uint16_t loop)
{
	(void)loop;
}

void LcdUi_SetWaitTimer(uint16_t elapsed_ds, uint16_t total_ds)
{
	if (!Board_HasOnboardLcd())
	{
		return;
	}

	if (elapsed_ds > 9999u)
	{
		elapsed_ds = 9999u;
	}
	if (total_ds > 9999u)
	{
		total_ds = 9999u;
	}
	s_wait_active = 1u;
	s_wait_elapsed_ds = elapsed_ds;
	s_wait_total_ds = total_ds;
	if (s_ui_ready && elapsed_ds != s_last_wait_drawn_ds)
	{
		s_last_wait_drawn_ds = elapsed_ds;
		LcdUi_DrawFooter();
	}
}

void LcdUi_ClearWaitTimer(void)
{
	if (!Board_HasOnboardLcd())
	{
		return;
	}

	if (!s_wait_active)
	{
		return;
	}
	s_wait_active = 0u;
	s_wait_elapsed_ds = 0u;
	s_wait_total_ds = 0u;
	s_last_wait_drawn_ds = 0xFFFFu;
	if (s_ui_ready)
	{
		LcdUi_DrawFooter();
	}
}

void LcdUi_Tick(void)
{
	uint8_t rod_home;
	uint8_t comm;
	uint8_t obstacle;

	if (!Board_HasOnboardLcd() || !s_ui_ready)
	{
		return;
	}

	rod_home = RodSensor_IsHome();
	comm = Protocol_IsCommActive();
	obstacle = ObstacleSensor_IsBlocked();

	if (rod_home != s_last_rod_home || comm != s_last_comm || obstacle != s_last_obstacle)
	{
		s_last_rod_home = rod_home;
		s_last_comm = comm;
		s_last_obstacle = obstacle;
		LcdUi_DrawStatusBar(rod_home, comm, obstacle);
	}
}

#else /* compact fallback */

static uint8_t s_ui_ready = 0;
static uint8_t s_ui_progress = UI_PROGRESS_IDLE;

void LcdUi_Init(void)
{
	if (!Board_HasOnboardLcd())
		return;
	Lcd_Init();
	Lcd_Fill(LCD_COLOR_BLACK);
	s_ui_ready = 1;
}

void LcdUi_ScrollPoll(void) {}
void LcdUi_Tick(void) {}

void LcdUi_SetProgress(uint8_t percent)
{
	if (!Board_HasOnboardLcd() || !s_ui_ready)
		return;
	if (percent > 100u)
		percent = 100u;
	s_ui_progress = percent;
}

void LcdUi_ClearProgress(void)
{
	if (!Board_HasOnboardLcd())
		return;
	s_ui_progress = UI_PROGRESS_IDLE;
}

void LcdUi_AppendStep(uint8_t label_id) { (void)label_id; }
void LcdUi_ClearSteps(void) {}
void LcdUi_SetStepList(const uint8_t *label_ids, uint8_t count, uint8_t current_idx)
{
	(void)label_ids; (void)count; (void)current_idx;
}
void LcdUi_SetCurrentStep(uint8_t current_idx) { (void)current_idx; }
void LcdUi_SetMeta(uint8_t idx, uint8_t total, uint32_t elapsed_ms, uint32_t total_ms, uint16_t loop)
{
	(void)idx; (void)total; (void)elapsed_ms; (void)total_ms; (void)loop;
}
void LcdUi_SetPhase(uint8_t phase) { (void)phase; }
void LcdUi_SetLoop(uint16_t loop) { (void)loop; }
void LcdUi_SetWaitTimer(uint16_t elapsed_ds, uint16_t total_ds)
{
	(void)elapsed_ds; (void)total_ds;
}
void LcdUi_ClearWaitTimer(void) {}

#endif
