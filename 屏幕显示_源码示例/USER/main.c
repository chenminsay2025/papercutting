#include "delay.h"
#include "sys.h"
#include "led.h"
#include "lcd_init.h"
#include "lcd.h"
#include "pic.h"
#include <stdint.h>
int main(void)
{
	delay_init();
	LCD_Init();//LCD≥ı ºªØ
	LCD_Fill(0,0,LCD_W,LCD_H,WHITE);	
	LCD_ShowString(10,0,"Hello!",BLACK,WHITE,16,0);
	LCD_ShowChinese(50,20,"WMNologo",BLACK,WHITE,16,0);	
	while(1)
	{
		//∑¿÷π≥Ã–Ú≈‹∑…
	}
}


