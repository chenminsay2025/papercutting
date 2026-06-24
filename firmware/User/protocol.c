#include "protocol.h"
#include "usart_serial.h"
#include "motor.h"
#include "relay.h"
#include "rod_sensor.h"
#include "obstacle_sensor.h"
#include "buzzer.h"
#include "board.h"
#include "lcd_ui.h"
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

static void Protocol_AppendRodSuffix(char *buf, size_t cap)
{
	const char *rod;

	if (cap == 0 || buf == NULL)
	{
		return;
	}

	rod = RodSensor_IsHome() ? ";ROD:HOME" : ";ROD:AWAY";
	if (strlen(buf) + strlen(rod) + 1 > cap)
	{
		return;
	}
	strcat(buf, rod);
}

static void Protocol_AppendObstacleSuffix(char *buf, size_t cap)
{
	const char *obs;

	if (cap == 0 || buf == NULL)
	{
		return;
	}

	obs = ObstacleSensor_IsBlocked() ? ";OBSTACLE:BLOCKED" : ";OBSTACLE:CLEAR";
	if (strlen(buf) + strlen(obs) + 1 > cap)
	{
		return;
	}
	strcat(buf, obs);
}

static void Protocol_SendRodSensor(void)
{
	if (RodSensor_IsHome())
	{
		Serial_SendLine("ROD:HOME");
	}
	else
	{
		Serial_SendLine("ROD:AWAY");
	}
}

static void Protocol_SendObstacleSensor(void)
{
	if (ObstacleSensor_IsBlocked())
	{
		Serial_SendLine("OBSTACLE:BLOCKED");
	}
	else
	{
		Serial_SendLine("OBSTACLE:CLEAR");
	}
}

static void Protocol_SendStatus(void)
{
	char line[80];

	if (s_comm_timed_out)
	{
		Serial_SendLine("STATUS:TIMEOUT");
		return;
	}

	switch (Motor_GetState())
	{
	case MOTOR_STATE_RETRACT:
		strcpy(line, "STATUS:RETRACTING");
		break;
	case MOTOR_STATE_EXTEND:
		strcpy(line, "STATUS:EXTENDING");
		break;
	default:
		if (Relay_IsBusy())
		{
			strcpy(line, "STATUS:RELAY");
		}
		else
		{
			strcpy(line, "STATUS:IDLE");
		}
		break;
	}

	Protocol_AppendRodSuffix(line, sizeof(line));
	Protocol_AppendObstacleSuffix(line, sizeof(line));
	Serial_SendLine(line);
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

	if (strcmp(line, "ROD_SENSOR") == 0)
	{
		Protocol_SendRodSensor();
		return;
	}

	if (strcmp(line, "OBSTACLE") == 0 || strcmp(line, "OBSTACLE?") == 0)
	{
		Protocol_SendObstacleSensor();
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
		Buzzer_Off();
		LcdUi_ClearProgress();
		LcdUi_SetPhase(3);
		Serial_SendLine("OK:ESTOP");
		return;
	}

	if (strncmp(line, "UI_PROGRESS", 11) == 0)
	{
		const char *arg = strchr(line, ':');

		if (arg == NULL)
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		arg++;
		if (strcmp(arg, "OFF") == 0 || strcmp(arg, "IDLE") == 0)
		{
			LcdUi_ClearProgress();
		}
		else
		{
			char *end_ptr;
			unsigned long value;

			value = strtoul(arg, &end_ptr, 10);
			if (end_ptr == arg || value > 1000u)
			{
				Serial_SendLine("ERR:INVALID");
				return;
			}
			LcdUi_SetProgressX10((uint16_t)value);
		}
		return;
	}

	if (strncmp(line, "UI_WAIT", 7) == 0)
	{
		const char *arg = strchr(line, ':');

		if (arg == NULL)
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		arg++;
		if (strcmp(arg, "OFF") == 0 || strcmp(arg, "IDLE") == 0)
		{
			LcdUi_ClearWaitTimer();
		}
		else
		{
			char *end_ptr;
			unsigned long elapsed;
			unsigned long total;

			elapsed = strtoul(arg, &end_ptr, 10);
			if (end_ptr == arg || *end_ptr != ',')
			{
				Serial_SendLine("ERR:INVALID");
				return;
			}
			arg = end_ptr + 1;
			total = strtoul(arg, &end_ptr, 10);
			if (end_ptr == arg || elapsed > 9999u || total > 9999u)
			{
				Serial_SendLine("ERR:INVALID");
				return;
			}
			LcdUi_SetWaitTimer((uint16_t)elapsed, (uint16_t)total);
		}
		return;
	}

	if (strncmp(line, "UI_STEPIDX", 10) == 0)
	{
		const char *arg = strchr(line, ':');
		char *end_ptr;
		unsigned long value;

		if (arg == NULL)
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		value = strtoul(arg + 1, &end_ptr, 10);
		if (end_ptr == arg + 1 || value > 255u)
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		LcdUi_SetCurrentStep((uint8_t)value);
		Serial_SendLine("OK");
		return;
	}

	if (strncmp(line, "UI_STEPS", 8) == 0)
	{
		const char *arg = strchr(line, ':');
		uint8_t ids[16];
		uint8_t count = 0;
		uint8_t current = 0xFFu;

		if (arg == NULL)
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		arg++;
		if (strcmp(arg, "CLEAR") == 0)
		{
			LcdUi_ClearSteps();
			Serial_SendLine("OK");
			return;
		}

		while (*arg != '\0' && count < sizeof(ids))
		{
			char *end_ptr;
			unsigned long value;

			while (*arg == ',')
			{
				arg++;
			}
			if (*arg == '\0')
			{
				break;
			}

			value = strtoul(arg, &end_ptr, 10);
			if (end_ptr == arg || value > 255u)
			{
				Serial_SendLine("ERR:INVALID");
				return;
			}

			if (count == 0u)
			{
				current = (uint8_t)value;
			}
			else
			{
				ids[count - 1u] = (uint8_t)value;
			}
			count++;
			arg = end_ptr;
		}

		if (count == 0u)
		{
			LcdUi_ClearSteps();
		}
		else
		{
			LcdUi_SetStepList(ids, (uint8_t)(count - 1u), current);
		}
		Serial_SendLine("OK");
		return;
	}

	if (strncmp(line, "UI_STEP", 7) == 0)
	{
		const char *arg = strchr(line, ':');

		if (arg == NULL)
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		arg++;
		if (strcmp(arg, "CLEAR") == 0)
		{
			LcdUi_ClearSteps();
		}
		else
		{
			char *end_ptr;
			unsigned long value;

			value = strtoul(arg, &end_ptr, 10);
			if (end_ptr == arg || value > 255u)
			{
				Serial_SendLine("ERR:INVALID");
				return;
			}
			LcdUi_AppendStep((uint8_t)value);
		}
		Serial_SendLine("OK");
		return;
	}

	if (strncmp(line, "UI_META", 7) == 0)
	{
		const char *arg = strchr(line, ':');
		unsigned long idx;
		unsigned long total;
		unsigned long elapsed;
		unsigned long total_ms;
		unsigned long loop;
		char *end_ptr;

		if (arg == NULL)
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		arg++;
		idx = strtoul(arg, &end_ptr, 10);
		if (end_ptr == arg || *end_ptr != ',')
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		arg = end_ptr + 1;
		total = strtoul(arg, &end_ptr, 10);
		if (end_ptr == arg || *end_ptr != ',')
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		arg = end_ptr + 1;
		elapsed = strtoul(arg, &end_ptr, 10);
		if (end_ptr == arg || *end_ptr != ',')
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		arg = end_ptr + 1;
		total_ms = strtoul(arg, &end_ptr, 10);
		if (end_ptr == arg)
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		loop = 0;
		if (*end_ptr == ',')
		{
			arg = end_ptr + 1;
			loop = strtoul(arg, &end_ptr, 10);
			if (end_ptr == arg)
			{
				Serial_SendLine("ERR:INVALID");
				return;
			}
		}
		LcdUi_SetMeta(
			(uint8_t)(idx > 255u ? 255u : idx),
			(uint8_t)(total > 255u ? 255u : total),
			(uint32_t)(elapsed > 9999999u ? 9999999u : elapsed),
			(uint32_t)(total_ms > 9999999u ? 9999999u : total_ms),
			(uint16_t)(loop > 9999u ? 9999u : loop));
		return;
	}

	if (strncmp(line, "UI_PHASE", 8) == 0)
	{
		const char *arg = strchr(line, ':');
		char *end_ptr;
		unsigned long value;

		if (arg == NULL)
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		value = strtoul(arg + 1, &end_ptr, 10);
		if (end_ptr == arg + 1 || value > 3u)
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		LcdUi_SetPhase((uint8_t)value);
		Serial_SendLine("OK");
		return;
	}

	if (strncmp(line, "UI_LOOP", 7) == 0)
	{
		const char *arg = strchr(line, ':');
		char *end_ptr;
		unsigned long value;

		if (arg == NULL)
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		value = strtoul(arg + 1, &end_ptr, 10);
		if (end_ptr == arg + 1 || value > 9999u)
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}
		LcdUi_SetLoop((uint16_t)value);
		Serial_SendLine("OK");
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

	if (strncmp(line, "BUZZER", 6) == 0)
	{
		const char *arg = strchr(line, ':');
		char tag[16];
		char *cursor;
		char *end_ptr;
		unsigned long on_ms = 200u;
		unsigned long gap_ms = 100u;
		unsigned long repeat = 1u;

		if (arg == NULL || arg[1] == '\0')
		{
			Serial_SendLine("ERR:INVALID");
			return;
		}

		arg++;
		if (strcmp(arg, "OFF") == 0)
		{
			Buzzer_Off();
			Serial_SendLine("OK");
			return;
		}

		cursor = strchr(arg, ',');
		if (cursor != NULL)
		{
			size_t len = (size_t)(cursor - arg);
			if (len >= sizeof(tag))
			{
				len = sizeof(tag) - 1u;
			}
			memcpy(tag, arg, len);
			tag[len] = '\0';
			cursor++;
		}
		else
		{
			strncpy(tag, arg, sizeof(tag) - 1u);
			tag[sizeof(tag) - 1u] = '\0';
			cursor = (char *)"";
		}

		if (strcmp(tag, "SHORT") == 0)
		{
			on_ms = cursor[0] ? strtoul(cursor, &end_ptr, 10) : 200u;
			if (on_ms == 0u) on_ms = 200u;
			Buzzer_PatternShort((uint32_t)on_ms);
			Serial_SendLine("OK");
			return;
		}
		if (strcmp(tag, "LONG") == 0)
		{
			on_ms = cursor[0] ? strtoul(cursor, &end_ptr, 10) : 500u;
			if (on_ms == 0u) on_ms = 500u;
			Buzzer_PatternLong((uint32_t)on_ms);
			Serial_SendLine("OK");
			return;
		}
		if (strcmp(tag, "DOUBLE") == 0)
		{
			on_ms = cursor[0] ? strtoul(cursor, &end_ptr, 10) : 200u;
			if (on_ms == 0u) on_ms = 200u;
			if (end_ptr != cursor && *end_ptr == ',')
			{
				gap_ms = strtoul(end_ptr + 1, &end_ptr, 10);
			}
			if (gap_ms == 0u) gap_ms = 100u;
			Buzzer_PatternDouble((uint32_t)on_ms, (uint32_t)gap_ms);
			Serial_SendLine("OK");
			return;
		}
		if (strcmp(tag, "TRIPLE") == 0)
		{
			on_ms = cursor[0] ? strtoul(cursor, &end_ptr, 10) : 200u;
			if (on_ms == 0u) on_ms = 200u;
			if (end_ptr != cursor && *end_ptr == ',')
			{
				gap_ms = strtoul(end_ptr + 1, &end_ptr, 10);
			}
			if (gap_ms == 0u) gap_ms = 100u;
			Buzzer_PatternTriple((uint32_t)on_ms, (uint32_t)gap_ms);
			Serial_SendLine("OK");
			return;
		}
		if (strcmp(tag, "CONTINUOUS") == 0)
		{
			on_ms = strtoul(cursor, &end_ptr, 10);
			if (end_ptr != cursor && *end_ptr == ',')
			{
				gap_ms = strtoul(end_ptr + 1, &end_ptr, 10);
			}
			Buzzer_PatternContinuous((uint32_t)on_ms, (uint32_t)gap_ms);
			Serial_SendLine("OK");
			return;
		}

		on_ms = strtoul(tag, &end_ptr, 10);
		if (end_ptr != tag)
		{
			if (*end_ptr == ',')
			{
				gap_ms = strtoul(end_ptr + 1, &end_ptr, 10);
				if (*end_ptr == ',')
				{
					repeat = strtoul(end_ptr + 1, &end_ptr, 10);
				}
			}
			if (repeat <= 1u)
			{
				Buzzer_PatternShort((uint32_t)on_ms);
			}
			else if (repeat == 2u)
			{
				Buzzer_PatternDouble((uint32_t)on_ms, (uint32_t)gap_ms);
			}
			else
			{
				Buzzer_PatternTriple((uint32_t)on_ms, (uint32_t)gap_ms);
			}
			Serial_SendLine("OK");
			return;
		}

		Serial_SendLine("ERR:INVALID");
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
	while (Serial_ReadLine(s_cmd_line, sizeof(s_cmd_line)))
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
