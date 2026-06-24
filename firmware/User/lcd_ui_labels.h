#ifndef __LCD_UI_LABELS_H
#define __LCD_UI_LABELS_H

#include <stdint.h>

#define LCD_LBL_RETRACT         0u
#define LCD_LBL_PULSE_A         1u
#define LCD_LBL_FOCUS           2u
#define LCD_LBL_SEND_CUT        3u
#define LCD_LBL_WAIT_CUT        4u
#define LCD_LBL_EXTEND          5u
#define LCD_LBL_PULSE_B         6u
#define LCD_LBL_RESTORE         7u
#define LCD_LBL_CONFIRM         8u
#define LCD_LBL_CALL_GROUP      9u
#define LCD_LBL_CONDITION       10u
#define LCD_LBL_STOP            11u
#define LCD_LBL_OTHER           12u

extern const uint8_t g_lcd_step_label_count;

const char *LcdUiLabels_Get(uint8_t id);

#endif
