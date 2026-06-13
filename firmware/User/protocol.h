#ifndef __PROTOCOL_H
#define __PROTOCOL_H

#include <stdint.h>

void Protocol_Init(void);void Protocol_Poll(void);
void Protocol_CheckCommTimeout(void);
uint8_t Protocol_IsCommActive(void);

#endif
