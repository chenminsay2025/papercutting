#ifndef __LCD_UI_H
#define __LCD_UI_H

#include <stdint.h>

void LcdUi_Init(void);
void LcdUi_ScrollPoll(void);
void LcdUi_Tick(void);
void LcdUi_SetProgress(uint8_t percent);
void LcdUi_SetProgressX10(uint16_t percent_x10);
void LcdUi_ClearProgress(void);
void LcdUi_AppendStep(uint8_t label_id);
void LcdUi_ClearSteps(void);
void LcdUi_SetStepList(const uint8_t *label_ids, uint8_t count, uint8_t current_idx);
void LcdUi_SetCurrentStep(uint8_t current_idx);
void LcdUi_SetMeta(uint8_t idx, uint8_t total, uint32_t elapsed_ms, uint32_t total_ms, uint16_t loop);
void LcdUi_SetPhase(uint8_t phase);
void LcdUi_SetLoop(uint16_t loop);
void LcdUi_SetWaitTimer(uint16_t elapsed_ds, uint16_t total_ds);
void LcdUi_ClearWaitTimer(void);

#endif
