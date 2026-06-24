//////////////////////////////////////////////////////////////////////////////////	 
//  文 件 名   : main.c
//  功能描述   : LCD SPI接口演示例程(STM32F103系列)
/////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////              深圳市沃乐康科技有限公司                               //////////////////
///////////////////              0755-32882855                                        //////////////////
///////////////////              https://ourplaza.taobao.com/                         //////////////////
///////////////////              版权所有  仅用于学习参考                              //////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//******************************************************************************/

#include "delay.h"
#include "sys.h"
#include "lcd.h"


int main(void)
 {	
	 u8 i,m;
	 u8 z;
	 float t=0;
	 delay_init();	    	 //延时函数初始化	  
	 NVIC_Configuration(); 	 //设置NVIC中断分组2:2位抢占优先级，2位响应优先级
	 Lcd_Init();			//初始化  
	 LCD_Clear(WHITE);
	 BACK_COLOR=WHITE;
	 LED_ON;
	 while(1)
	 {
		
			LCD_DispBand();
		 delay_ms(13000); 
		 
		  LCD_Clear(BLACK);
		 //delay_ms(12000);  
		 Draw_Circle(120,160,100,RED);
		 LCD_DrawRectangle(0, 0, 239, 319,WHITE);
		 delay_ms(13000);
		 
		 LCD_Clear(WHITE);
		  delay_ms(13000);
		 
			LCD_Clear(RED);
		 delay_ms(500);              //Delay 120ms 
		  LCD_Clear(GREEN);
		 delay_ms(500);              //Delay 120ms 
		  LCD_Clear(BLUE);
		 delay_ms(500);              //Delay 120ms 
		 
		 
		 LCD_DispGrayHor16();
		 delay_ms(12000);
		 LCD_DispBlock();
		 delay_ms(12000);
		 LCD_DispSnow();
		 delay_ms(12000);
		 
		 
		 
			LCD_Clear(WHITE);
			
			z=32;
		
			LCD_ShowChinese(((LCD_W-z*3)/2),0,0,z,RED);   
			LCD_ShowChinese((((LCD_W-z*3)/2)+z),0,1,z,RED);   
			LCD_ShowChinese((((LCD_W-z*3)/2)+z+z),0,2,z,RED);   
			
			z=16;
		 
		 	LCD_ShowChinese(((LCD_W-z*7)/2),40,0,z,RED);   
			LCD_ShowChinese((((LCD_W-z*7)/2)+z),40,1,z,RED);   
			LCD_ShowChinese((((LCD_W-z*7)/2)+z*2),40,2,z,RED);   
			LCD_ShowChinese((((LCD_W-z*7)/2)+z*3),40,3,z,RED);  //电
			LCD_ShowChinese((((LCD_W-z*7)/2)+z*4),40,4,z,RED);  //子
		  LCD_ShowChinese((((LCD_W-z*7)/2)+z*5),40,5,z,RED);  //科
		  LCD_ShowChinese((((LCD_W-z*7)/2)+z*6),40,6,z,RED);  //技

			LCD_ShowString(22,60,"1.8 TFT SPI",RED);
			LCD_ShowString(22,80,"LCD_W:",RED);	LCD_ShowNum(82,80,LCD_W,3,RED);
			LCD_ShowString(22,100,"LCD_H:",RED);LCD_ShowNum(82,100,LCD_H,3,RED);
		 delay_ms(20000);
		   
		 	LCD_Clear(WHITE);
			LCD_DrawRectangle(6, 6, 122, 26,GREEN);
			LCD_ShowChinese(8,8,0,16,RED);   
			LCD_ShowChinese(24,8,1,16,RED);   
			LCD_ShowChinese(40,8,2,16,RED);
      LCD_ShowChinese(56,8,3,16,RED);  //电
			LCD_ShowChinese(72,8,4,16,RED);  //子
		  LCD_ShowChinese(88,8,5,16,RED);  //科
		  LCD_ShowChinese(104,8,6,16,RED);  //技			
			
			for(m=0;m<3;m++)
			{
				LCD_ShowPicture(4+m*40,120,43+m*40,159);
			}
			
			Draw_Circle(64,64,35,BLUE);
			
			while(1)
			{
				LCD_ShowNum1(40,55,t,5,RED);
		    t+=0.01;
      }
   }
		
   
}