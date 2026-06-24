#ifndef __ROD_SENSOR_H
#define __ROD_SENSOR_H

#include "stm32f10x.h"

typedef enum
{
	ROD_POS_AWAY = 0,
	ROD_POS_HOME = 1
} RodPosition_t;

void RodSensor_Init(void);
void RodSensor_Tick(void);
RodPosition_t RodSensor_GetPosition(void);
uint8_t RodSensor_IsHome(void);

#endif
