#ifndef __OBSTACLE_SENSOR_H
#define __OBSTACLE_SENSOR_H

#include "stm32f10x.h"

typedef enum
{
	OBSTACLE_CLEAR = 0,
	OBSTACLE_BLOCKED = 1
} ObstacleState_t;

void ObstacleSensor_Init(void);
void ObstacleSensor_Tick(void);
ObstacleState_t ObstacleSensor_GetState(void);
uint8_t ObstacleSensor_IsBlocked(void);

#endif
