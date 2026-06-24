/*****************************************************************************************************
 **** @CompanyName  : 
 **** @FlieName     : tont.h
 **** @Description  : 字体库(头文件)
 **** @Contact      : www.wlklcd.com   https://wlklcd.1688.com/  0755-32882855   woleconn@163.com
******************************************************************************************************/
#ifndef __FONT_H
#define __FONT_H
#include "wm_hal.h"

/*****************************************************************************************************
 **** @brief   : 字库的取模方式
 **** @brief   : 点阵格式：阴码（亮为1.不亮为0）
 **** @brief   : 取模方式：逐行式
 **** @brief   : 取模走向：逆向（低字节在前）
******************************************************************************************************/

/*****************************************************************************************************
 **** @brief   : ASCII字符集
******************************************************************************************************/
/*
 !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
*/

/*****************************************************************************************************
 **** @brief   : 全部汉字库太大，自定义汉字库
******************************************************************************************************/
typedef struct
{
    uint8_t font[2];   //汉字ASCII码
    uint8_t array[32]; //字符集
} _font_16_type;

typedef struct
{
    uint8_t font[2];   //汉字ASCII码
    uint8_t array[72]; //字符集
} _font_24_type;

typedef struct
{
    uint8_t font[2];    //汉字ASCII码
    uint8_t array[128]; //字符集
} _font_32_type;

typedef struct
{
    uint8_t font[2];    //汉字ASCII码
    uint8_t array[288]; //字符集
} _font_48_type;

typedef struct
{
    uint8_t font[2];    //汉字ASCII码
    uint8_t array[512]; //字符集
} _font_64_type;

/*****************************************************************************************************
 **** @brief   : 字体大小定义
******************************************************************************************************/
#define Font_16 16
#define Font_24 24
#define Font_32 32
#define Font_48 48
#define Font_64 64
#define Font_96 96

/*****************************************************************************************************
 **** @brief   : 支付库使用有效声明
******************************************************************************************************/
//#define Font_16_USING
//#define Font_24_USING
#define Font_32_USING
// #define Font_48_USING
//#define Font_64_USING
//#define Font_96_USING

/*****************************************************************************************************
 **** @brief   : 全局字库申明
******************************************************************************************************/
#ifdef Font_16_USING
extern const _font_16_type font_16_array[15];
extern const unsigned char ascii_1608[95][16];
#endif
#ifdef Font_24_USING
extern const _font_24_type font_24_array[7];
extern const unsigned char ascii_2412[95][48];
#endif
#ifdef Font_32_USING
extern const _font_32_type font_32_array[10];
extern const unsigned char ascii_3216[95][64];
#endif
#ifdef Font_48_USING
extern const _font_48_type font_48_array[10];
extern const unsigned char ascii_4824[95][144];
#endif
#ifdef Font_64_USING
extern const _font_64_type font_64_array[2];
extern const unsigned char ascii_6432[95][256];
#endif
#ifdef Font_96_USING
extern const unsigned char ascii_9648[12][576];
#endif

/*****************************************************************************************************
 **** @brief   : 函数申明
******************************************************************************************************/
void font_get_chinese_characters_array(uint8_t *font, uint8_t *buff, uint8_t size);

#endif
