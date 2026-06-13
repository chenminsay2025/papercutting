#include "protocol.h"
#include "usart_serial.h"
#include "motor.h"
#include "relay.h"
#include "board.h"
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define PULSE_MS_MAX 5000
#define COMM_TIMEOUT_MS 70000
#define COMM_ACTIVE_MS 3000

static char s_cmd_line[SERIAL_RX_BUF_SIZE];
static uint32_t s_last_comm_tick = 0;
static uint8_t s_comm_timed_out = 0;

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
	if (value > PULSE_MS_MAX)
	{
		value = PULSE_MS_MAX;
	}
	return (uint32_t)value;
}

static void Protocol_SendStatus(void)
{
	if (s_comm_timed_out)
	{
		Serial_SendLine("STATUS:TIMEOUT");
		return;
	}

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

static void Protocol_TouchComm(void)
{
	s_last_comm_tick = Board_GetTickMs();
	s_comm_timed_out = 0;
}

static void Protocol_HandleLine(char *line)
{
	uint32_t pulse_ms;

	Protocol_TouchComm();
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
	s_last_comm_tick = Board_GetTickMs();
}

void Protocol_Poll(void)
{
	if (Serial_ReadLine(s_cmd_line, sizeof(s_cmd_line)))
	{
		Protocol_HandleLine(s_cmd_line);
	}
}

void Protocol_CheckCommTimeout(void)
{
	uint32_t now = Board_GetTickMs();

	if (s_comm_timed_out)
	{
		return;
	}

	if ((now - s_last_comm_tick) >= COMM_TIMEOUT_MS)
	{
		Motor_EStop();
		Relay_AllOff();
		s_comm_timed_out = 1;
	}
}

uint8_t Protocol_IsCommActive(void)
{
	uint32_t now = Board_GetTickMs();

	if (s_comm_timed_out)
	{
		return 0;
	}
	return (now - s_last_comm_tick) < COMM_ACTIVE_MS;
}
