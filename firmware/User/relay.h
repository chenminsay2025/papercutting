#ifndef __RELAY_H
#define __RELAY_H

#include "stm32f10x.h"

void Relay_Init(void);
void Relay_AllOff(void);
void Relay_PulseA(uint32_t duration_ms);
void Relay_PulseB(uint32_t duration_ms);
void Relay_Tick(void);
uint8_t Relay_IsBusy(void);

#endif
