#ifndef __BUZZER_H
#define __BUZZER_H

#include "stm32f10x.h"

void Buzzer_Init(void);
void Buzzer_On(void);
void Buzzer_Off(void);
void Buzzer_BeepBlocking(uint32_t on_ms, uint32_t gap_ms, uint8_t count);
void Buzzer_PatternShort(uint32_t on_ms);
void Buzzer_PatternLong(uint32_t on_ms);
void Buzzer_PatternDouble(uint32_t on_ms, uint32_t gap_ms);
void Buzzer_PatternTriple(uint32_t on_ms, uint32_t gap_ms);
void Buzzer_PatternContinuous(uint32_t on_ms, uint32_t gap_ms);
void Buzzer_Tick(void);
uint8_t Buzzer_IsBusy(void);

#endif
