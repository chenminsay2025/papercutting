/*************************************************************************************************
 ****@CompanyName  : 深圳市沃乐康科技有限公司
 ****@FileName     : main.c
 ****@Description  : 主程序  循环显示纯色及图片
 ****@Contact      : www.wlklcd.com   https://wlklcd.1688.com/  0755-32882855   woleconn@163.com
 *                              接线图				     
 *                   SPI-TFT -------------- W806 BOARD
 *                       GND -------------- GND
 *                       VCC -------------- 3.3V
 *                       SCL -------------- PB1
 *                       SDA -------------- PA7
 *                       RES -------------- PB27
 *                       DC  -------------- PB3
 *                       BLC -------------- PB2 
 * 需要显示屏请联系咨询，企业淘宝店：https://shop341012592.taobao.com/   
**************************************************************************************************/

#include <stdio.h>
#include "wm_hal.h"
#include "tftlcd.h"    //LCD驱动模式 分辨率 基本颜色定义

#if (Screen_W==240 && Screen_H==320) 
#include "240320_image.h"
#elif (Screen_W==240 && Screen_H==240)
#include "240240_image.h"   //图片取模数组文件
#endif

static void GPIO_Init(void);

#if ST7789_SPI
SPI_HandleTypeDef hspi;
static void SPI_Init(void);     
#endif
void Error_Handler(void);

int main(void)
{
	SystemClock_Config(CPU_CLK_240M); //设置主频为240MHZ 可设置160/80/40/2 见wm_cpu.h
	printf("enter main\r\n");         //串口打印
	
	GPIO_Init();           
#if ST7789_SPI	
	SPI_Init();                //硬件SPI寄存器初始化
#endif
	LCD_Init();
	
	while (1)
	{    
		LCD_Fill(0, 0, Screen_W, Screen_H, WHITE_16B);   //显示纯色
		HAL_Delay(300);
		LCD_DrawRectangle(0, 0, Screen_W-1, Screen_H-1, RED_16B,BLACK_16B);  //显示矩形
		tftlcd_show_font_string(10, 10, 239, 239,"0123456789ABCDEFGHIGKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*()_+/.,:" , 32, GREEN_16B, RED_16B);
        HAL_Delay(500);
		
		//LCD_ShowPicture(0, 0, Screen_W, Screen_H, (uint8_t*)gImage_caisheng);   //显示ROM中图片
		//HAL_Delay(1000);
		LCD_ShowPicture(0, 0, Screen_W, Screen_H, gImage_240320tly);    //显示ROM中图片
		HAL_Delay(1000);
		
		LCD_ShowPicture(0, 0, Screen_W, Screen_H, (uint8_t*)gImage_240320logo);  //显示ROM中图片
		HAL_Delay(3000);
	
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt,BLACK_16B, WHITE_16B);
	    HAL_Delay(500);
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt, RED_16B, WHITE_16B);
		HAL_Delay(500);
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt, GREEN_16B, WHITE_16B);
		HAL_Delay(500);
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt, BLUE_16B, WHITE_16B);
		HAL_Delay(500);
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt,WHITE_16B, BLACK_16B);
		HAL_Delay(500);
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt, RED_16B, BLACK_16B);
		HAL_Delay(500);
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt, GREEN_16B, BLACK_16B);
		HAL_Delay(500);
		tftlcd_bit_image(0,0,Screen_W,Screen_H,(uint8_t*)LogoBmpt, BLUE_16B, BLACK_16B);
		HAL_Delay(500);
		 
	}
}

static void GPIO_Init(void)
{
	GPIO_InitTypeDef GPIO_InitStruct;

	__HAL_RCC_GPIO_CLK_ENABLE();
#if ST7789_SPI	
	GPIO_InitStruct.Pin = S_BLC_PIN;                //背光控制脚
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	HAL_GPIO_Init(S_BLC_PORT, &GPIO_InitStruct);
	HAL_GPIO_WritePin(S_BLC_PORT, S_BLC_PIN, GPIO_PIN_RESET);
	
	
	GPIO_InitStruct.Pin = S_CD_PIN;                //数据指令选择脚
	HAL_GPIO_Init(S_CD_PORT, &GPIO_InitStruct);
	HAL_GPIO_WritePin(S_CD_PORT, S_CD_PIN, GPIO_PIN_SET);
	
	GPIO_InitStruct.Pin = S_RESET_PIN;             //复位脚
	HAL_GPIO_Init(S_RESET_PORT, &GPIO_InitStruct);
	HAL_GPIO_WritePin(S_RESET_PORT, S_RESET_PIN, GPIO_PIN_RESET);
	
	GPIO_InitStruct.Pin = S_FMARK_PIN;             //帧头信号
	GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
	HAL_GPIO_Init(S_FMARK_PORT, &GPIO_InitStruct);
#endif

#if ST7789_8080
	GPIO_InitStruct.Pin = P_LEDA_PIN;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	HAL_GPIO_Init(P_LEDA_PORT, &GPIO_InitStruct);
	HAL_GPIO_WritePin(P_LEDA_PORT, P_LEDA_PIN, GPIO_PIN_SET);
	
	GPIO_InitStruct.Pin = P_RD_PIN;
	HAL_GPIO_Init(P_RD_PORT, &GPIO_InitStruct);
	HAL_GPIO_WritePin(P_RD_PORT, P_RD_PIN, GPIO_PIN_SET);
	
	GPIO_InitStruct.Pin = P_WR_PIN;
	HAL_GPIO_Init(P_WR_PORT, &GPIO_InitStruct);
	HAL_GPIO_WritePin(P_WR_PORT, P_WR_PIN, GPIO_PIN_RESET);
	
	GPIO_InitStruct.Pin = P_CD_PIN;
	HAL_GPIO_Init(P_CD_PORT, &GPIO_InitStruct);
	HAL_GPIO_WritePin(P_CD_PORT, P_CD_PIN, GPIO_PIN_SET);
	
	GPIO_InitStruct.Pin = P_CS_PIN;
	HAL_GPIO_Init(P_CS_PORT, &GPIO_InitStruct);
	HAL_GPIO_WritePin(P_CS_PORT, P_CS_PIN, GPIO_PIN_SET);
	
	GPIO_InitStruct.Pin = P_RESET_PIN;
	HAL_GPIO_Init(P_RESET_PORT, &GPIO_InitStruct);
	HAL_GPIO_WritePin(P_RESET_PORT, P_RESET_PIN, GPIO_PIN_SET);
	
	GPIO_InitStruct.Pin = P_DATA_PIN;
	HAL_GPIO_Init(P_DATA_PORT, &GPIO_InitStruct);
	HAL_GPIO_WritePin(P_DATA_PORT, P_DATA_PIN, GPIO_PIN_RESET);
	
	GPIO_InitStruct.Pin = P_FMARK_PIN;
	GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
	HAL_GPIO_Init(P_FMARK_PORT, &GPIO_InitStruct);
	
#endif

}

#if ST7789_SPI
static void SPI_Init(void)
{
	hspi.Instance = SPI;
	hspi.Init.Mode = SPI_MODE_MASTER;            //设置为SPI主机模式
	hspi.Init.CLKPolarity = SPI_POLARITY_HIGH;   //设置为CLK空闲时高电平  
	hspi.Init.CLKPhase = SPI_PHASE_2EDGE;        //设置为第二个时钟沿捕获 
	hspi.Init.NSS = SPI_NSS_SOFT;                //设置为软件CS
	hspi.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_2;    //设置SPI分频速率，最快2分频 20M，详见wm_spi.h
	hspi.Init.FirstByte = SPI_LITTLEENDIAN;
	
	if (HAL_SPI_Init(&hspi) != HAL_OK)
	{
		Error_Handler();
	}
}
#endif

void Error_Handler(void)
{
	while (1)
	{
	}
}

void assert_failed(uint8_t *file, uint32_t line)
{
	printf("Wrong parameters value: file %s on line %d\r\n", file, line);
}