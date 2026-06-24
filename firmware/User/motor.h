#ifndef __MOTOR_H
#define __MOTOR_H

#include "stm32f10x.h"

typedef enum
{
	MOTOR_STATE_STOP = 0,
	MOTOR_STATE_RETRACT,
	MOTOR_STATE_EXTEND
} MotorState_t;

void Motor_Init(void);
void Motor_Retract(void);
void Motor_Extend(void);
void Motor_Stop(void);
void Motor_EStop(void);
MotorState_t Motor_GetState(void);

#endif
