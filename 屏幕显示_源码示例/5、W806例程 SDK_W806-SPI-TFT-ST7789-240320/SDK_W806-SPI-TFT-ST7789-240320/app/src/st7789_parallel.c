/*************************************************************************************************
 ****@CompanyName  : 深圳市沃乐康科技有限公司
 ****@FileName     : st7789_parallel.c
 ****@Description  : I8080并口基础读写函数
 ****@Contact      : www.wlklcd.com   https://wlklcd.1688.com/  0755-32882855   woleconn@163.com
 ****@Remark       : 
**************************************************************************************************/
#include "st7789_parallel.h"

void P_Back_On(void)     //背光打开
{
	HAL_GPIO_WritePin(P_LEDA_PORT, P_LEDA_PIN, GPIO_PIN_SET);
}

void P_Back_Off(void)    //背光关闭
{
	HAL_GPIO_WritePin(P_LEDA_PORT, P_LEDA_PIN, GPIO_PIN_RESET);
}

static void P_WaitTe(void)
{
	while ((P_FMARK_PORT->DATA & P_FMARK_PIN) == 0);
}

void P_WriteReg(uint8_t reg)  //写寄存器指令 8位
{
	P_CS_LOW;
	P_CD_LOW;
	P_WR_LOW;
	MODIFY_REG(P_DATA_PORT->DATA, P_DATA_PIN, reg);
	P_WR_HIGH;
	P_CD_HIGH;
	P_CS_HIGH;
}

void P_WriteData8(uint8_t data)   //写寄数据 8位
{
	P_CS_LOW;
	P_WR_LOW;
	MODIFY_REG(P_DATA_PORT->DATA, P_DATA_PIN, data);
	P_WR_HIGH;
	P_CS_HIGH;
}

void P_WriteData16(uint16_t data)   //写寄数据 16位
{
	P_CS_LOW;
	P_WR_LOW;
	MODIFY_REG(P_DATA_PORT->DATA, P_DATA_PIN, (data >> 8));
	P_WR_HIGH;
	P_WR_LOW;
	MODIFY_REG(P_DATA_PORT->DATA, P_DATA_PIN, (data & 0x00FF));
	P_WR_HIGH;
	P_CS_HIGH;
}

void P_WriteData(uint8_t *data, uint32_t len)
{
	int i = 0;
	
	P_CS_LOW;
	P_DATA_PORT->DATA_B_EN &= P_DATA_PIN;
	P_WR_PORT->DATA_B_EN &= P_WR_PIN;
	for (i = 0; i < len; i ++)
	{
		P_WR_PORT->DATA = 0;
		P_DATA_PORT->DATA = data[i];
		P_WR_PORT->DATA = P_WR_PIN;
	}
	P_WR_PORT->DATA_B_EN |= ~P_WR_PIN;
	P_DATA_PORT->DATA_B_EN |= ~P_DATA_PIN;
	P_CS_HIGH;
}
