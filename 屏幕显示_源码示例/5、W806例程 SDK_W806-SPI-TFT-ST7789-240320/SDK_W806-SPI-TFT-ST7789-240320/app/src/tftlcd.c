/*************************************************************************************************
 ****@CompanyName  : 深圳市沃乐康科技有限公司
 ****@FileName     : tftlcd.c
 ****@Description  : LCD显示基础函数及初始化
 ****@Contact      : www.wlklcd.com   https://wlklcd.1688.com/  0755-32882855   woleconn@163.com
 ****@Remark       : 
**************************************************************************************************/
#include "tftlcd.h"

void LCD_Reset_On(void)    //复位高
{
#if ST7789_SPI
	S_RESET_LOW;
#endif
#if ST7789_8080
	P_RESET_LOW;
#endif
}

void LCD_Reset_Off(void)    //复位低
{
#if ST7789_SPI
	S_RESET_HIGH;
#endif
#if ST7789_8080
	P_RESET_HIGH;
#endif
}

void LCD_Back_On(void)     //背光开
{
#if ST7789_SPI
	S_Back_On();
#endif
#if ST7789_8080
	P_Back_On();
#endif
}

void LCD_Back_Off(void)    //背光关
{
#if ST7789_SPI
	S_Back_Off();
#endif
#if ST7789_8080
	P_Back_Off();
#endif
}

static void LCD_WriteReg(uint8_t reg)   //写寄存器指令
{
#if ST7789_SPI
	S_WriteReg(reg);
#endif
#if ST7789_8080
	P_WriteReg(reg);
#endif
}

static void LCD_WriteData8(uint8_t data)  //写数据  8位
{
#if ST7789_SPI
	S_WriteData8(data);
#endif
#if ST7789_8080
	P_WriteData8(data);
#endif
}

static void LCD_WriteData16(uint16_t data)  //写数据 16位
{
#if ST7789_SPI
	S_WriteData16(data);
#endif
#if ST7789_8080
	P_WriteData16(data);
#endif
}
 void LCD_WriteData(uint8_t *data, uint32_t len)   //写数组 
{
	uint32_t t1 = 0, t2 = 0;
	
#if ST7789_SPI
	t1 = HAL_GetTick();
	S_WriteData(data, len);
	t2 = HAL_GetTick();
	printf("s_t = %d\r\n", t2 - t1);
#endif
#if ST7789_8080
	t1 = HAL_GetTick();
	P_WriteData(data, len);
	t2 = HAL_GetTick();
	printf("p_t = %d\r\n", t2 - t1);
#endif
}

void LCD_Init(void)       // LCD初始化
{
	LCD_Reset_On();
	HAL_Delay(120);
	LCD_Reset_Off();
	HAL_Delay(120);
	LCD_Back_On();
	HAL_Delay(100);
	LCD_WriteReg(0x11);
	HAL_Delay(120);
	
#if ST7789_HSD154IPS	

LCD_WriteReg(0x11);              
HAL_Delay(120); 

LCD_WriteReg(0x36); //MX, MY, RGB mode 
LCD_WriteData8(0x00);

LCD_WriteReg(0x3A);     
LCD_WriteData8(0x55);   

LCD_WriteReg(0xB2);     
LCD_WriteData8(0x1F);   
LCD_WriteData8(0x1F);   
LCD_WriteData8(0x00);   
LCD_WriteData8(0x33);   
LCD_WriteData8(0x33);  

LCD_WriteReg(0xB7);    
LCD_WriteData8(0x12);  //VGH=12.54V,VGL=-8.23V 

LCD_WriteReg(0xBB);     
LCD_WriteData8(0x35);  

LCD_WriteReg(0xC0);     
LCD_WriteData8(0x2C); 

LCD_WriteReg(0xC2);     
LCD_WriteData8(0x01);   

LCD_WriteReg(0xC3);     
LCD_WriteData8(0x15); //4.6V 

LCD_WriteReg(0xC4);     
LCD_WriteData8(0x20);   //VDV, 0x20:0v

LCD_WriteReg(0xC6);     
LCD_WriteData8(0x13);     

LCD_WriteReg(0xD0);     
LCD_WriteData8(0xA4);   
LCD_WriteData8(0xA1);   

LCD_WriteReg(0xD6);     
LCD_WriteData8(0xA1);   //sleep in后，gate输出为GND

LCD_WriteReg(0xE0);
LCD_WriteData8(0xF0);
LCD_WriteData8(0x06);
LCD_WriteData8(0x0D);
LCD_WriteData8(0x0B);
LCD_WriteData8(0x0A);
LCD_WriteData8(0x07);
LCD_WriteData8(0x2E);
LCD_WriteData8(0x43);
LCD_WriteData8(0x45);
LCD_WriteData8(0x38);
LCD_WriteData8(0x14);
LCD_WriteData8(0x13);
LCD_WriteData8(0x25);
LCD_WriteData8(0x29);

LCD_WriteReg(0xE1);
LCD_WriteData8(0xF0);
LCD_WriteData8(0x07);
LCD_WriteData8(0x0A);
LCD_WriteData8(0x08);
LCD_WriteData8(0x07);
LCD_WriteData8(0x23);
LCD_WriteData8(0x2E);
LCD_WriteData8(0x33);
LCD_WriteData8(0x44);
LCD_WriteData8(0x3A);
LCD_WriteData8(0x16);
LCD_WriteData8(0x17);
LCD_WriteData8(0x26);
LCD_WriteData8(0x2C);  

LCD_WriteReg(0xE4);    
LCD_WriteData8(0x1D); //使用240根gate  (N+1)*8
LCD_WriteData8(0x00); //设定gate起点位置
LCD_WriteData8(0x00); //当gate没有用完时，bit4(TMG)设为0

LCD_WriteReg(0x21);        

LCD_WriteReg(0x2A);     //Column Address Set
LCD_WriteData8(0x00);   
LCD_WriteData8(0x00);   //0
LCD_WriteData8(0x00);   
LCD_WriteData8(0xEF);   //239

LCD_WriteReg(0x2B);     //Row Address Set
LCD_WriteData8(0x00);   
LCD_WriteData8(0x00);   //0
LCD_WriteData8(0x00);   
LCD_WriteData8(0xEF);   //239

LCD_WriteReg(0x2C);     

LCD_WriteReg(0x29); //Display on

#endif

#if ST7789_CTC24TN
//---------------------------------------------------------------------------------------------------// 
LCD_WriteReg(0x11); 
HAL_Delay(120);        //HAL_Delay 120ms 
//--------------------------------------Display Setting------------------------------------------// 
LCD_WriteReg(0x36); 
LCD_WriteData8(0x00); 
LCD_WriteReg(0x3a); 
LCD_WriteData8(0x05); 
//--------------------------------ST7789V Frame rate setting----------------------------------// 
LCD_WriteReg(0xb2); 
LCD_WriteData8(0x0c); 
LCD_WriteData8(0x0c); 
LCD_WriteData8(0x00); 
LCD_WriteData8(0x33); 
LCD_WriteData8(0x33); 
LCD_WriteReg(0xb7); 
LCD_WriteData8(0x35); 
//---------------------------------ST7789V Power setting--------------------------------------// 
LCD_WriteReg(0xbb); 
LCD_WriteData8(0x2b); 
LCD_WriteReg(0xc0); 
LCD_WriteData8(0x2c); 
LCD_WriteReg(0xc2); 
LCD_WriteData8(0x01); 
LCD_WriteReg(0xc3); 
LCD_WriteData8(0x11); 
LCD_WriteReg(0xc4); 
LCD_WriteData8(0x20); 
LCD_WriteReg(0xc6); 
LCD_WriteData8(0x0f); 
LCD_WriteReg(0xd0); 
LCD_WriteData8(0xa4); 
LCD_WriteData8(0xa1); 
//--------------------------------ST7789V gamma setting---------------------------------------// 
LCD_WriteReg(0xe0); 
LCD_WriteData8(0xd0); 
LCD_WriteData8(0x00); 
LCD_WriteData8(0x05); 
LCD_WriteData8(0x0e); 
LCD_WriteData8(0x15); 
LCD_WriteData8(0x0d); 
LCD_WriteData8(0x37); 
LCD_WriteData8(0x43); 
LCD_WriteData8(0x47); 
LCD_WriteData8(0x09); 
LCD_WriteData8(0x15); 
LCD_WriteData8(0x12); 
LCD_WriteData8(0x16); 
LCD_WriteData8(0x19); 
LCD_WriteReg(0xe1); 
LCD_WriteData8(0xd0); 
LCD_WriteData8(0x00); 
LCD_WriteData8(0x05); 
LCD_WriteData8(0x0d); 
LCD_WriteData8(0x0c); 
LCD_WriteData8(0x06); 
LCD_WriteData8(0x2d); 
LCD_WriteData8(0x44); 
LCD_WriteData8(0x40); 
LCD_WriteData8(0x0e); 
LCD_WriteData8(0x1c); 
LCD_WriteData8(0x18); 
LCD_WriteData8(0x16); 
LCD_WriteData8(0x19); 
LCD_WriteReg(0x29); 

#endif

#if ST7789_CTC20IPS

LCD_WriteReg(0x11);     
HAL_Delay(120);                //ms
LCD_WriteReg(0x36);     
LCD_WriteData8(0x00);   

LCD_WriteReg(0x3A);     
LCD_WriteData8(0x05);  //    262Kɫ 06

LCD_WriteReg(0xB2);     
LCD_WriteData8(0x0C);   
LCD_WriteData8(0x0C);   
LCD_WriteData8(0x00);   
LCD_WriteData8(0x33);   
LCD_WriteData8(0x33);   

LCD_WriteReg(0xB7);     
LCD_WriteData8(0x75);   //VGH=14.97V, VGL=-10.43V  

LCD_WriteReg(0xBB);     //VCOM  
LCD_WriteData8(0x21);   

LCD_WriteReg(0xC0);     
LCD_WriteData8(0x2C);   

LCD_WriteReg(0xC2);     
LCD_WriteData8(0x01);   

LCD_WriteReg(0xC3);     //GVDD  
LCD_WriteData8(0x13);   

LCD_WriteReg(0xC4);     
LCD_WriteData8(0x20);   

LCD_WriteReg(0xC6);     
LCD_WriteData8(0x0F);   

LCD_WriteReg(0xD0);     
LCD_WriteData8(0xA4);   
LCD_WriteData8(0xA1);

LCD_WriteReg(0xd6);
LCD_WriteData8(0xa1);
   
LCD_WriteReg(0xE0);
LCD_WriteData8(0x70);
LCD_WriteData8(0x04);
LCD_WriteData8(0x0A);
LCD_WriteData8(0x08);
LCD_WriteData8(0x07);
LCD_WriteData8(0x05);
LCD_WriteData8(0x32);
LCD_WriteData8(0x32);
LCD_WriteData8(0x48);
LCD_WriteData8(0x38);
LCD_WriteData8(0x15);
LCD_WriteData8(0x15);
LCD_WriteData8(0x2A);
LCD_WriteData8(0x2E);

LCD_WriteReg(0xE1);
LCD_WriteData8(0x70);
LCD_WriteData8(0x07);
LCD_WriteData8(0x0D);
LCD_WriteData8(0x09);
LCD_WriteData8(0x09);
LCD_WriteData8(0x16);
LCD_WriteData8(0x30);
LCD_WriteData8(0x44);
LCD_WriteData8(0x49);
LCD_WriteData8(0x39);
LCD_WriteData8(0x16);
LCD_WriteData8(0x16);
LCD_WriteData8(0x2B);
LCD_WriteData8(0x2F);
  
LCD_WriteReg(0x21);

LCD_WriteReg(0x29);     

#endif



}


/*****************************************************************************************************
 **** @defgroup: void Set_ST7789_GRAM_Address(uint16_t xs, uint16_t ys, uint16_t xe, uint16_t ye)  
 **** @brief   : 设置7789GRAM 地址
 **** @param    {uint16_t} xs            起始X坐标
 **** @param    {uint16_t} ys            起始X坐标
 **** @param    {uint16_t} xe            结束X坐标
 **** @param    {uint16_t} ye            结束Y坐标
 **** @return   {*}
******************************************************************************************************/
void Set_ST7789_GRAM_Address(uint16_t xs, uint16_t ys, uint16_t xe, uint16_t ye)   
{
	LCD_WriteReg(0x2A);
	LCD_WriteData16(xs);
	LCD_WriteData16(xe);
	LCD_WriteReg(0x2B);
	LCD_WriteData16(ys);
	LCD_WriteData16(ye);
	LCD_WriteReg(0x2C);
}

/*****************************************************************************************************
 **** @defgroup: void Set_Screen_Windows(uint16_t sx, uint16_t sy, uint16_t width, uint16_t height)
 **** @brief   : 对TFT进行窗口设置
 **** @param    {uint16_t} sx            起始X坐标
 **** @param    {uint16_t} sy            起始X坐标
 **** @param    {uint16_t} width        X方向长度
 **** @param    {uint16_t} height        Y方向高度
 **** @return   {*}
******************************************************************************************************/
void Set_Screen_Windows(uint16_t sx, uint16_t sy, uint16_t width, uint16_t height)
{
    //芯片显示偏移
    if (TFTLCD_X_OFFSET > 0 || TFTLCD_Y_OFFSET > 0)
    {
        if (TFTLCD_DIR == 0)
           { sx += TFTLCD_X_OFFSET;
		   sy += TFTLCD_Y_OFFSET; }
        else
           { sx += TFTLCD_Y_OFFSET;
		   sy += TFTLCD_X_OFFSET; }
			
    }

    width  = sx + width - 1;
    height = sy + height - 1;

    //调用各个芯片的窗口设置函数
    Set_ST7789_GRAM_Address(sx, sy, width, height);
}

/*****************************************************************************************************
 **** @defgroup: void LCD_Fill(uint16_t xs, uint16_t ys, uint16_t xe, uint16_t ye, uint16_t color)
 **** @brief   : 指定区域填充纯色
 **** @param    {uint16_t} sx            起始X坐标
 **** @param    {uint16_t} sy            起始X坐标
 **** @param    {uint16_t} xe            结束X坐标
 **** @param    {uint16_t} ye            结束Y坐标
 **** @param    {uint16_t} color         颜色值
 **** @return   {*}
******************************************************************************************************/
void LCD_Fill(uint16_t xs, uint16_t ys, uint16_t xe, uint16_t ye, uint16_t color)
{
	uint16_t i, j;
	
	Set_Screen_Windows(xs, ys, xe, ye);
	for (i = 0; i < ye; i++)
	{
		for (j = 0; j < xe; j++)
		{
			LCD_WriteData16(color);
		}
	}
}


/*****************************************************************************************************
 **** @defgroup: void LCD_DrawPoint(uint16_t xpos, uint16_t ypos, uint16_t color)
 **** @brief   : 在TFT上画一个点
 **** @param    {uint16_t} xpos    X坐标
 **** @param    {uint16_t} ypos    y坐标
 **** @param    {uint16_t} color    颜色值
 **** @return   {*}
******************************************************************************************************/
void LCD_DrawPoint(uint16_t xpos, uint16_t ypos, uint16_t color)
{
	LCD_Fill(xpos, ypos, 1, 1, color);
}

// 画线
void LCD_DrawLine(uint16_t xs, uint16_t ys, uint16_t xe, uint16_t ye, uint16_t color)
{
	uint16_t i;
	int x = 0, y = 0, dx, dy, offset;
	int stepx, stepy, nowx, nowy;
	
	dx = xe - xs;
	dy = ye - ys;
	
	nowx = xs;
	nowy = ys;
	
	stepx = (dx > 0) ? 1 : ((dx == 0) ? 0 : -1);
	stepy = (dy > 0) ? 1 : ((dy == 0) ? 0 : -1);
	dx = (stepx >= 0) ? dx : -dx;
	dy = (stepy >= 0) ? dy : -dy;
	offset = (dx > dy) ? dx : dy;
	
	for (i = 0; i < (offset + 1); i++)
	{
		//LCD_DrawPoint(nowx, nowy, color);
		Set_ST7789_GRAM_Address(nowx, nowy, nowx, nowy);
	    LCD_WriteData16(color);
		x += dx;
		y += dy;
		if (x > offset)
		{
			x -= offset;
			nowx += stepx;
		}
		if (y > offset)
		{
			y -= offset;
			nowy += stepy;
		}
	}
}

// 画矩形
void LCD_DrawRectangle(uint16_t xs, uint16_t ys, uint16_t xe, uint16_t ye, uint16_t border,uint16_t fill)
{ 
  if(border !=Screen_Color_Alpha)
  {
	LCD_DrawLine(xs, ys, xe, ys, border);
	LCD_DrawLine(xe, ys, xe, ye, border);
	LCD_DrawLine(xe, ye, xs, ye, border);
	LCD_DrawLine(xs, ye, xs, ys, border);
	
  }
  if(fill !=Screen_Color_Alpha)
  {LCD_Fill(xs+1, ys+1, xe-1, ye-1, fill);}
}

// 画圆
void LCD_DrawCircle(uint16_t x, uint16_t y, uint8_t r, uint16_t color)
{
	int a, b;
	
	a = 0;
	b = r;
	while (a <= b)
	{
		LCD_DrawPoint(x - b, y - a, color);
		LCD_DrawPoint(x - b, y + a, color);
		LCD_DrawPoint(x + b, y - a, color);
		LCD_DrawPoint(x + b, y + a, color);
		LCD_DrawPoint(x + a, y - b, color);
		LCD_DrawPoint(x - a, y - b, color);
		LCD_DrawPoint(x + a, y + b, color);
		LCD_DrawPoint(x - a, y + b, color);
		a++;
		if ((a * a + b * b) > (r * r))
		{
			b--;
		}
	}
}


/*****************************************************************************************************
 **** @defgroup: void tftlcd_show_char(uint16_t x, uint16_t y, uint8_t num, uint8_t size, uint16_t pcolor, uint16_t bcolor)
 **** @brief   : 在TFT上指定位置显示一个字符
 **** @param    {uint16_t} x
 **** @param    {uint16_t} y        坐标
 **** @param    {uint8_t}  num        字符
 **** @param    {uint8_t}  size    字体大小 16/24/32/64
 **** @param    {uint16_t} pcolor    笔颜色
 **** @param    {uint16_t} bcolor    背景颜色
 **** @return   {*}
******************************************************************************************************/
void tftlcd_show_char(uint16_t x, uint16_t y, uint8_t num, uint8_t size, uint16_t pcolor, uint16_t bcolor)
{
    uint8_t temp;
    uint8_t t, n;
    uint16_t pos   = 0;
    uint16_t csize = 0;

    //得到字体一个字符对应点阵集所占的字节数
    csize = ((uint16_t)(size / 8 + ((size / 2 % 8) ? 1 : 0))) * (size / 2);
    //得到偏移后的值
    if (size != Font_96)
        num = num - ' ';

    //超界限直接退出
    if (x > Screen_W || y > Screen_H)
        return;

    //设置窗口
    Set_Screen_Windows(x, y, size / 2, size);

    for (pos = 0; pos < csize; pos++)
    {
        switch (size)
        {
        case Font_16:
#ifdef Font_16_USING
            temp = ascii_1608[num][pos];
#else
            temp = 0XFF;
#endif

            n = 8;
            break;

        case Font_24:
#ifdef Font_24_USING
            temp = ascii_2412[num][pos];
#else
            temp = 0XFF;
#endif
            if (pos % 2)
                n = 4;
            else
                n = 8;
            break;

        case Font_32:
#ifdef Font_32_USING
            temp = ascii_3216[num][pos];
#else
            temp = 0XFF;
#endif
            n    = 8;
            break;

        case Font_48:
#ifdef Font_48_USING
            temp = ascii_4824[num][pos];
#else
            temp = 0XFF;
#endif
            n    = 8;
            break;

        case Font_64:
#ifdef Font_64_USING
            temp = ascii_6432[num][pos];
#else
            temp = 0XFF;
#endif
            n    = 8;
            break;

        case Font_96:
#ifdef Font_96_USING
            //96号字体太大简化为用到的数据
            if (num >= '0' && num <= '9')
                temp = ascii_9648[num - '0'][pos];
            else
            {
                if (num == '~')
                    temp = ascii_9648[10][pos];
                else

                {
                    if (num == 'V')
                        temp = ascii_9648[11][pos];
                    else
                        temp = 0XFF;
                }
            }
#else
            temp = 0XFF;
#endif

            n = 8;
            break;

        default:
            temp = 0XFF;
            n    = 8;
            break;
        }

        for (t = 0; t < n; t++)
        {
            //从低位开始
            if (temp & 0x01)
                LCD_WriteData16(pcolor);  //画字体颜色 一个点
            else
                LCD_WriteData16(bcolor);  //画背景颜色 一个点
            temp >>= 1;
        }
    }
}

/*****************************************************************************************************
 **** @defgroup: void tftlcd_show_font(uint16_t x, uint16_t y, uint8_t *font, uint8_t size, uint16_t pcolor, uint16_t bcolor)
 **** @brief   : 在TFT上指定位置显示一个汉字
 **** @param    {uint16_t} x
 **** @param    {uint16_t} y        坐标
 **** @param    {uint8_t*} font    汉字
 **** @param    {uint8_t}  size    字体大小 16/24/32/64
 **** @param    {uint16_t} pcolor    笔颜色
 **** @param    {uint16_t} bcolor    背景颜色
 **** @return   {*}
******************************************************************************************************/
void tftlcd_show_font(uint16_t x, uint16_t y, uint8_t *font, uint8_t size, uint16_t pcolor, uint16_t bcolor)
{
    uint8_t temp;
    uint8_t t      = 0;
    uint16_t pos   = 0;
    uint16_t csize = 0;
    uint8_t ascii_font[512];

    //得到字体一个字符对应点阵集所占的字节数
    csize = ((uint16_t)(size / 8 + ((size % 8) ? 1 : 0))) * size;

    //超界限直接退出
    if (x > Screen_W || y > Screen_H)
        return;

    //获取汉字的字库到ascii_font
    font_get_chinese_characters_array(font, ascii_font, size);

    //设置窗口
    Set_Screen_Windows(x, y, size, size);

    for (pos = 0; pos < csize; pos++)
    {
        temp = ascii_font[pos];

        for (t = 0; t < 8; t++)
        {
            //从低位开始
            if (temp & 0x01)
                LCD_WriteData16(pcolor);  //画字体颜色 一个点
            else
                LCD_WriteData16(bcolor);  //画背景颜色 一个点
            temp >>= 1;
        }
    }
}

/*****************************************************************************************************
 **** @defgroup: void tftlcd_show_string(uint16_t x, uint16_t y, uint16_t width, char *str, uint8_t size, uint16_t pcolor, uint16_t bcolor)
 **** @brief   : LCD在指定位置显示字符串，不换行，不显示汉字
 **** @param    {uint16_t} x        x起点的坐标
 **** @param    {uint16_t} y        y起点的坐标
 **** @param    {uint16_t} width    长度
 **** @param    {uint8_t}  *str    字符串起始地址
 **** @param    {uint8_t}  size    选择字体，只支持16/24/32/64
 **** @param    {uint16_t} pcolor    笔颜色
 **** @param    {uint16_t} bcolor    背景颜色
 **** @return   {*}
******************************************************************************************************/
void tftlcd_show_string(uint16_t x, uint16_t y, uint16_t width, char *str, uint8_t size, uint16_t pcolor, uint16_t bcolor)
{
    width += x;
    while ((*str <= '~') && (*str >= ' '))  //判断是不是非法字符!
    {
        if (x >= width)
            break;  //退出

        tftlcd_show_char(x, y, *str, size, pcolor, bcolor);

        x += size / 2;

        str++;
    }
}

/*****************************************************************************************************
 **** @defgroup: void tftlcd_show_font_string(uint16_t x, uint16_t y, uint16_t width, uint16_t height, char *str, uint8_t size, uint16_t pcolor, uint16_t bcolor)
 **** @brief   : LCD在指定位置显示字符串，换行，显示汉字
 **** @param    {uint16_t} x        x起点的坐标
 **** @param    {uint16_t} y        y起点的坐标
 **** @param    {uint16_t} width    长度
 **** @param    {uint16_t} height  宽度
 **** @param    {uint8_t}  *str    字符串起始地址
 **** @param    {uint8_t}  size    选择字体，只支持16/24/32/64
 **** @param    {uint16_t} pcolor    笔颜色
 **** @param    {uint16_t} bcolor    背景颜色
 **** @return   {*}
******************************************************************************************************/
void tftlcd_show_font_string(uint16_t x, uint16_t y, uint16_t width, uint16_t height, char *str, uint8_t size, uint16_t pcolor, uint16_t bcolor)
{
    uint16_t x0 = x;
    uint16_t y0 = y;
    while (*str != 0)  //数据未结束
    {
        if (*str > (char)0x80)
        {
            //汉字
            if (x > (x0 + width - size))  //换行
            {
                y += size;
                x = x0;
            }
            if (y > (y0 + height - size))
                break;                                                     //越界返回
            tftlcd_show_font(x, y, (uint8_t *)str, size, pcolor, bcolor);  //显示这个汉字,空心显示
            str += 2;
            x += size;  //下一个汉字偏移
        }
        else  //字符
        {
            //字符
            if (x > (x0 + width - size / 2))  //换行
            {
                y += size;
                x = x0;
            }
            if (y > (y0 + height - size))
                break;       //越界返回
            if (*str == 13)  //换行符号
            {
                y += size;
                x = x0;
                str++;
            }
            else
                tftlcd_show_char(x, y, *str, size, pcolor, bcolor);  //有效部分写入
            str++;
            x += size / 2;  //字符,为全字的一半
        }
    }
}

/*****************************************************************************************************
 **** @defgroup: void tftlcd_midshow_font_string(uint16_t x, uint16_t y, char *str, uint16_t len, uint8_t size, uint16_t pcolor, uint16_t bcolor)
 **** @brief   : LCD在指定的长度对称显示字符串，显示汉字
 **** @param    {uint16_t} x        x起点的坐标
 **** @param    {uint16_t} y        y起点的坐标
 **** @param    {uint8_t}  *str    字符串起始地址
 **** @param    {uint8_t}  size    选择字体，只支持16/24/32/64
 **** @param    {uint16_t} len        长度
 **** @param    {uint16_t} pcolor    笔颜色
 **** @param    {uint16_t} bcolor    背景颜色
 **** @return   {*}
******************************************************************************************************/
void tftlcd_midshow_font_string(uint16_t x, uint16_t y, char *str, uint16_t len, uint8_t size, uint16_t pcolor, uint16_t bcolor)
{
    uint16_t strlenth = 0;
    strlenth          = strlen((const char *)str);
    strlenth *= size / 2;
    if (strlenth > len)
        tftlcd_show_font_string(x, y, Screen_W, Screen_H, str, size, pcolor, bcolor);
    else
    {
        strlenth = (len - strlenth) / 2;
        tftlcd_show_font_string(strlenth + x, y, Screen_W, Screen_H, str, size, pcolor, bcolor);
    }
}


/*****************************************************************************************************
 **** @defgroup: void tftlcd_bit_image(uint16_t x,uint16_t y,uint16_t width,uint16_t height,uint8_t *pic, uint16_t pcolor, uint16_t bcolor)
 **** @brief   : 在LCD上指定位置显示1张单色图片
 **** @param    {uint16_t} x
 **** @param    {uint16_t} y        坐标
 **** @param    {uint16_t} width    宽度
 **** @param    {uint16_t} height    长度
 **** @param    {uint8_t}  *pic    图片起始地址
 **** @param    {uint16_t} pcolor    笔颜色
 **** @param    {uint16_t} bcolor    背景颜色
 **** @return   {*}
******************************************************************************************************/
void tftlcd_bit_image(uint16_t x, uint16_t y, uint16_t width, uint16_t height, uint8_t *pic, uint16_t pcolor, uint16_t bcolor)
{
    uint32_t pos, num, i;
    uint8_t temp;

    num = (uint32_t)width * height / 8;

    //设置窗口
    Set_Screen_Windows(x, y, width, height);

    for (pos = 0; pos < num; pos++)
    {
        temp = *pic;

        for (i = 0; i < 8; i++)
        {
            //从低位开始
            if (temp & 0x01)
                LCD_WriteData16(pcolor);  //画字体颜色 一个点
            else
                LCD_WriteData16(bcolor);  //画背景颜色 一个点
            temp >>= 1;
        }

        pic++;
    }
}



// 显示图片
void LCD_ShowPicture(uint16_t x, uint16_t y, uint16_t length, uint16_t width,  uint8_t *data)
{
	
	Set_Screen_Windows(x, y, length, width);
	LCD_WriteData(data, length * width * 2);
}
