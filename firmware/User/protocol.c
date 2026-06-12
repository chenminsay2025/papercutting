#include "protocol.h"
#include "usart_serial.h"
#include "motor.h"
#include "relay.h"
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static char s_cmd_line[SERIAL_RX_BUF_SIZE];

static void Protocol_ToUpper(char *str)
{
	while (*str)
	{
		*str = (char)toupper((unsigned char)*str);
		str++;
	}
}

static uint32_t Protocol_ParsePulseMs(const char *line, uint32_t default_ms)
{
	const char *colon;
	char *end_ptr;
	unsigned long value;

	colon = strchr(line, ':');
	if (colon == NULL)
	{
		return default_ms;
	}

	value = strtoul(colon + 1, &end_ptr, 10);
	if (end_ptr == colon + 1)
	{
		return default_ms;
	}
	if (value == 0)
	{
		value = 1;
	}
	return (uint32_t)value;
}

static void Protocol_SendStatus(void)
{
	switch (Motor_GetState())
	{
	case MOTOR_STATE_RETRACT:
		Serial_SendLine("STATUS:RETRACTING");
		break;
	case MOTOR_STATE_EXTEND:
		Serial_SendLine("STATUS:EXTENDING");
		break;
	default:
		if (Relay_IsBusy())
		{
			Serial_SendLine("STATUS:RELAY");
		}
		else
		{
			Serial_SendLine("STATUS:IDLE");
		}
		break;
	}
}

static void Protocol_HandleLine(char *line)
{
	uint32_t pulse_ms;

	Protocol_ToUpper(line);

	if (strcmp(line, "PING") == 0)
	{
		Serial_SendLine("OK:PONG");
		return;
	}

	if (strcmp(line, "STATUS") == 0)
	{
		Protocol_SendStatus();
		return;
	}

	if (strcmp(line, "RETRACT") == 0)
	{
		Motor_Retract();
		Serial_SendLine("OK");
		return;
	}

	if (strcmp(line, "EXTEND") == 0)
	{
		Motor_Extend();
		Serial_SendLine("OK");
		return;
	}

	if (strcmp(line, "STOP") == 0)
	{
		Motor_Stop();
		Serial_SendLine("OK");
		return;
	}

	if (strcmp(line, "ESTOP") == 0)
	{
		Motor_EStop();
		Relay_AllOff();
		Serial_SendLine("OK:ESTOP");
		return;
	}

	if (strncmp(line, "PULSE_A", 7) == 0)
	{
		pulse_ms = Protocol_ParsePulseMs(line, 200);
		Relay_PulseA(pulse_ms);
		Serial_SendLine("OK");
		return;
	}

	if (strncmp(line, "PULSE_B", 7) == 0)
	{
		pulse_ms = Protocol_ParsePulseMs(line, 200);
		Relay_PulseB(pulse_ms);
		Serial_SendLine("OK");
		return;
	}

	Serial_SendLine("ERR:INVALID");
}

void Protocol_Init(void)
{
}

void Protocol_Poll(void)
{
	if (Serial_ReadLine(s_cmd_line, sizeof(s_cmd_line)))
	{
		Protocol_HandleLine(s_cmd_line);
	}
}
