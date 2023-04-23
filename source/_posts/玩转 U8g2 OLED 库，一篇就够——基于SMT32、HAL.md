---
author: 深藏Blue
title: 玩转 U8g2 OLED库，一篇就够——基于SMT32、HAL
tags:
  - 笔记
  - U8g2
  - STM32
categories:
  - U8g2
  - STM32
abbrlink: 290313423
date: 2023-04-23 07:51:00
---
<meta name="referrer" content="no-referrer"/>
@[TOC](STM32中U8g2图形库的使用)

# 1 前言
&emsp;&emsp;OLED图形库众多，如Adafruit_GFX 和 Adafruit_SSD1306库。但是，今天要使用的是 U8g2图形库。

> [参考文章：深入学习Arduino u8g2 OLED库，一篇就够](https://blog.csdn.net/dpjcn1990/article/details/92831760?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522168193238616800197030830%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fall.%2522%257D&request_id=168193238616800197030830&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~first_rank_ecpm_v1~hot_rank-1-92831760-null-null.142%5Ev85%5Econtrol,239%5Ev2%5Einsert_chatgpt&utm_term=u8g2&spm=1018.2226.3001.4187)

> [参考文章：GitHub-->u8g2reference](https://github.com/olikraus/u8g2/wiki/u8g2reference)

## 1.1 U8g2库百度脑图
![U8g2库百度脑图](https://img-blog.csdnimg.cn/c2f06932d54243d1a46d9319cceedd9f.png)
可以分为四大类：

 - 基本函数
 - 绘制相关函数
 - 显示配置相关函数
 - 缓存相关函数

# 2 U8g2库函数详解
## 2.1 基本函数（干货从这里开始）
### 2.1.1 u8g2_t u8g2;

```cpp
u8g2_t u8g2;		// 显示器初始化结构体
```
### 2.1.2 u8g2Init(u8g2_t *u8g2)

```cpp
u8g2_t u8g2;		// 显示器初始化结构体
u8g2Init(&u8g2);   //显示器调用初始化函数
```
### 2.1.3 u8g2_InitDisplay(u8g2)

```cpp
void u8g2Init(u8g2_t *u8g2)
{
	u8g2_Setup_ssd1306_128x64_noname_f(u8g2, U8G2_R0, u8x8_byte_4wire_hw_spi, u8x8_stm32_gpio_and_delay); 
	u8g2_InitDisplay(u8g2);     //初始化显示
	u8g2_SetPowerSave(u8g2, 0); //开启显示
}
```
### 2.1.4  u8g2_SetPowerSave(u8g2, is_enable);

```cpp
u8g2_SetPowerSave(&u8g2, 0);   //开启显示
```
 - 不管是启用还是禁用，显示器需要的内存消耗是不变的，说到底就是为了关闭屏幕，做到省电；
 - 所以这里就可以理解为什么初始化需要 **u8g2_SetPowerSave(u8g2, 0);** 来开启显示
 
### 2.1.5 u8g2_ClearDisplay(u8g2_t *u8g2)

```cpp
u8g2_ClearDisplay(&u8g2);    //清除屏幕缓冲区
```

 - 不要在 firstPage 和 nextPage 函数之间调用该方法。
 
### 2.1.6 u8g2_ClearBuffer(u8g2_t *u8g2) —— 清除缓冲区
 - 一般这个函数是与u8g2_SendBuffer函数配对使用，通常用法如下：

```cpp
void Buffer(u8g2_t *u8g2) {
  u8g2_ClearBuffer(u8g2); 
  // ... 向缓冲区写入内容
  u8g2_SendBuffer(u8g2);
}
```

## 2.2 绘制相关函数（进阶）
### 2.2.1 u8g2_DrawBox() —— 画实心矩形
函数说明：

```cpp
/**
 * 画实心矩形，左上角坐标为(x,y),宽度为w，高度为h
 * @param x 左上角的x坐标
 * @param y 左上角的y坐标
 * @param w 方形的宽度
 * @param h 方形的高度
 */
void u8g2_DrawBox(u8g2_t *u8g2, u8g2_uint_t x, u8g2_uint_t y, u8g2_uint_t w, u8g2_uint_t h)
```

 - 如果支持绘制颜色（也就是不是单色显示器），那么由**u8g2_SetDrawColor(u8g2_t *u8g2, uint8_t color)**设置；
 - 示例：

```cpp
u8g2_DrawBox(&u8g2,3,7,25,15);
```
![画实心矩形](https://img-blog.csdnimg.cn/8191fc123ee6418699ad146264e97090.png)
 - 显示一个简单的进度条 



```cpp
u8g2_FirstPage(&u8g2);
do
{
	u8g2_DrawBox(&u8g2,0,32,i++,15);
	HAL_Delay(50);
}while (u8g2_NextPage(&u8g2));
```

![显示进度条](https://img-blog.csdnimg.cn/65f75b333baf4315a770716d97ea2779.gif)

### 2.2.2 u8g2_DrawCircle() —— 画空心圆
函数说明：

```cpp
/**
 * 画空心圆，圆心坐标为(x0,y0),半径为rad
 * @param x0 圆点的x坐标
 * @param y0 圆点的y坐标
 * @param rad 圆形的半径
 * @param opt 圆形选项
 *        U8G2_DRAW_ALL 整个圆
 *        U8G2_DRAW_UPPER_RIGHT 右上部分的圆弧
 *        U8G2_DRAW_UPPER_LEFT  左上部分的圆弧
 *        U8G2_DRAW_LOWER_LEFT  左下部分的圆弧
 *        U8G2_DRAW_LOWER_RIGHT 右下部分的圆弧
 *        选项可以通过 | 操作符来组合
 */
void u8g2_DrawCircle(u8g2_t *u8g2, u8g2_uint_t x0, u8g2_uint_t y0, u8g2_uint_t rad, uint8_t option)
```

 - 示例：

```cpp
u8g2_DrawCircle(&u8g2,20,25,10,U8G2_DRAW_ALL);
```

![画空心圆](https://img-blog.csdnimg.cn/868b1d7cdb13488d869704318979a534.png)

 - 动态测试

```cpp
u8g2_FirstPage(&u8g2);
do
{
	u8g2_DrawCircle(&u8g2,63,31,i++,U8G2_DRAW_ALL ); 
//    u8g2_DrawCircle(&u8g2,63,31,i++,U8G2_DRAW_UPPER_RIGHT|U8G2_DRAW_LOWER_LEFT); 
	HAL_Delay(50);
}while (u8g2_NextPage(&u8g2));
```
![空心圆测试all](https://img-blog.csdnimg.cn/9cd754e22b8149ebaca6e8d2a6bd20cb.gif)
![空心圆测试](https://img-blog.csdnimg.cn/3bcba1fc7fb8419cb0cd054aadfb256d.gif)

### 2.2.3 u8g2_DrawDisc() —— 画实心圆

```cpp
/**
 * 画实心圆，圆心坐标为(x0,y0),半径为rad
 * @param x0 圆点的x坐标
 * @param y0 圆点的y坐标
 * @param rad 圆形的半径
 * @param opt 圆形选项
 *        U8G2_DRAW_ALL 整个圆
 *        U8G2_DRAW_UPPER_RIGHT 右上部分的圆弧
 *        U8G2_DRAW_UPPER_LEFT  左上部分的圆弧
 *        U8G2_DRAW_LOWER_LEFT  左下部分的圆弧
 *        U8G2_DRAW_LOWER_RIGHT 右下部分的圆弧
 *       选项可以通过 | 操作符来组合
 */
void u8g2_DrawDisc(u8g2_t *u8g2, u8g2_uint_t x0, u8g2_uint_t y0, u8g2_uint_t rad, uint8_t option)
```
 * 直径等于2rad + 1；
 - 如果支持绘制颜色（也就是不是单色显示器），那么由**u8g2_SetDrawColor(u8g2_t *u8g2, uint8_t color)**设置；
 - 示例

```cpp
u8g2_FirstPage(&u8g2);
do
{
	u8g2_DrawDisc(&u8g2,63,31,i++,U8G2_DRAW_UPPER_RIGHT|U8G2_DRAW_LOWER_LEFT); 
	HAL_Delay(50);
}while (u8g2_NextPage(&u8g2));
```

![实心圆测试](https://img-blog.csdnimg.cn/d53ebc9940b34a448af82ee91610af7f.gif)

### 2.2.4 u8g2_DrawEllipse() —— 画空心椭圆
函数说明：

```cpp
/**
 * 画空心椭圆，圆心坐标为(x0,y0),半径为rad
 * @param x0 圆点的x坐标
 * @param y0 圆点的y坐标
 * @param rx 椭圆形水平x方向的半径
 * @param ry 椭圆形竖直y方向的半径
 * @param opt 圆形选项
 *        U8G2_DRAW_ALL 整个椭圆
 *        U8G2_DRAW_UPPER_RIGHT 右上部分的圆弧
 *        U8G2_DRAW_UPPER_LEFT  左上部分的圆弧
 *        U8G2_DRAW_LOWER_LEFT  左下部分的圆弧
 *        U8G2_DRAW_LOWER_RIGHT 右下部分的圆弧
 *        选项可以通过 | 操作符来组合
 */
void u8g2_DrawEllipse(u8g2_t *u8g2, u8g2_uint_t x0, u8g2_uint_t y0, u8g2_uint_t rx, u8g2_uint_t ry, uint8_t option)
```
 * rx*ry 在8位模式的u8g2必须小于512（博主也没有理解）；
 * 示例：

```cpp
u8g2_DrawEllipse(&u8g2,20,25,15,10,U8G2_DRAW_ALL);
```
![画空心椭圆](https://img-blog.csdnimg.cn/2e5a5bd77f154b01aa25622e2a01852b.png)

```cpp
u8g2_FirstPage(&u8g2);
do
{
	u8g2_DrawEllipse(&u8g2,63,31,i++,30,U8G2_DRAW_UPPER_RIGHT|U8G2_DRAW_LOWER_LEFT); 
	HAL_Delay(50);
}while (u8g2_NextPage(&u8g2));
```
>>>视频

### 2.2.5 u8g2_DrawFilledEllipse() —— 画实心椭圆
### 2.2.6 u8g2_DrawFrame() —— 画空心矩形
函数说明：

```cpp
/**
 * 画空心方形，左上角坐标为(x,y),宽度为w，高度为h
 * @param x 左上角的x坐标
 * @param y 左上角的y坐标
 * @param w 方形的宽度
 * @param h 方形的高度
 */
void u8g2_DrawFrame(u8g2_t *u8g2, u8g2_uint_t x, u8g2_uint_t y, u8g2_uint_t w, u8g2_uint_t h)
```
 - 如果支持绘制颜色（也就是不是单色显示器），那么由**u8g2_SetDrawColor(u8g2_t *u8g2, uint8_t color)**设置；
 - 示例

```cpp
u8g2_DrawFrame(&u8g2,3,7,25,15);
```
![画空心矩形](https://img-blog.csdnimg.cn/7615177436624106b325e32e6de3448d.png)

 - 进度条示例

```cpp
u8g2_FirstPage(&u8g2);
do
{
	for(uint8_t i=0;i<=99;i=i+1)
	{
		u8g2_ClearBuffer(&u8g2); 
		
		char buff[20];
		u8g2_SetFont(&u8g2,u8g2_font_ncenB08_tf);//字体
		sprintf(buff,"%d%%",(int)(i/100.0*100));
		u8g2_DrawStr(&u8g2,105,49,buff);//当前进度显示
		
		u8g2_DrawBox(&u8g2,2,40,i,10);//填充框实心矩形框
		u8g2_DrawFrame(&u8g2,0,38,103,14);//空心矩形框
		
		HAL_Delay(200);
		u8g2_SendBuffer(&u8g2);
	}
}while (u8g2_NextPage(&u8g2));
```

>>>视频

### 2.2.7 u8g2_DrawGlyph() —— 绘制字体字集的符号
函数说明：

```cpp
/**
 * 绘制字体字集里面定义的符号
 * @param x 左上角的x坐标
 * @param y 左上角的y坐标
 * @param encoding 字符的unicode值
 * @Note 关联方法 u8g2_SetFont
 */
u8g2_uint_t u8g2_DrawGlyph(u8g2_t *u8g2, u8g2_uint_t x, u8g2_uint_t y, uint16_t encoding)
```
 * U8g2支持16位以内的unicode字符集，也就是说encoding的范围为0-65535，DrawGlyph方法只能绘制存在于所使用的字体字集中的unicode值；
 * 这个绘制方法依赖于当前的字体模式和绘制颜色；

### 2.2.8 u8g2_DrawHLine() —— 绘制水平线
函数说明：

```cpp
/**
 * 绘制水平线
 * @param x 左上角的x坐标
 * @param y 左上角的y坐标
 * @param w 水平线的长度
 */
 void u8g2_DrawHLine(u8g2_t *u8g2, u8g2_uint_t x, u8g2_uint_t y, u8g2_uint_t len)
```
 - 如果支持绘制颜色（也就是不是单色显示器），那么由**u8g2_SetDrawColor(u8g2_t *u8g2, uint8_t color)**设置；
 
### 2.2.9 u8g2_DrawLine() —— 两点之间绘制线
函数说明：

```cpp
/**
 * 绘制线，从坐标(x0,y0) 到(x1,y1)
 * @param x0 端点0的x坐标
 * @param y0 端点0的y坐标
 * @param x1 端点1的x坐标
 * @param y1 端点1的y坐标
 */
void u8g2_DrawLine(u8g2_t *u8g2, u8g2_uint_t x1, u8g2_uint_t y1, u8g2_uint_t x2, u8g2_uint_t y2)
```
 - 如果支持绘制颜色（也就是不是单色显示器），那么由**u8g2_SetDrawColor(u8g2_t *u8g2, uint8_t color)**设置；
 - 示例：

```cpp
u8g2_DrawLine(&u8g2,20, 5, 5, 32);
```
![两点之间绘制线](https://img-blog.csdnimg.cn/e376b3b50d0b4303bae30a939f47fc5b.png)


### 2.2.10 u8g2_DrawPixel() —— 绘制像素点
函数说明：

```cpp
/**
 * 绘制像素点，坐标(x,y)
 * @param x 像素点的x坐标
 * @param y 像素点的y坐标
 * @Note 关联方法 setDrawColor
 */
void u8g2_DrawPixel(u8g2_t *u8g2, u8g2_uint_t x, u8g2_uint_t y)
```
 - 如果支持绘制颜色（也就是不是单色显示器），那么由**u8g2_SetDrawColor(u8g2_t *u8g2, uint8_t color)**设置；
 - 你会发现很多绘制方法的底层都是调用**u8g2_DrawPixel()**，毕竟像素属于最小颗粒度；
 - 我们可以利用这个绘制方法自定义自己的图形显示；
 
### 2.2.11 u8g2_DrawRBox() —— 绘制圆角实心方形
函数说明：

```cpp
/**
 * 绘制圆角实心方形，左上角坐标为(x,y),宽度为w，高度为h，圆角半径为r
 * @param x 左上角的x坐标
 * @param y 左上角的y坐标
 * @param w 方形的宽度
 * @param h 方形的高度
 * @param r 圆角半径
 */
void u8g2_DrawRBox(u8g2_t *u8g2, u8g2_uint_t x, u8g2_uint_t y, u8g2_uint_t w, u8g2_uint_t h, u8g2_uint_t r)
```
 - 如果支持绘制颜色（也就是不是单色显示器），那么由**u8g2_SetDrawColor(u8g2_t *u8g2, uint8_t color)**设置；
 - 要求，w >= 2(r+1) 并且 h >= 2(r+1)，这是显而易见的限制；
 - 示例
>>>

### 2.2.12 u8g2_DrawRFrame() —— 绘制圆角空心方形
函数说明：

```cpp
/**
 * 绘制圆角空心方形，左上角坐标为(x,y),宽度为w，高度为h，圆角半径为r
 * @param x 左上角的x坐标
 * @param y 左上角的y坐标
 * @param w 方形的宽度
 * @param h 方形的高度
 * @param r 圆角半径
 */
void u8g2_DrawRFrame(u8g2_t *u8g2, u8g2_uint_t x, u8g2_uint_t y, u8g2_uint_t w, u8g2_uint_t h, u8g2_uint_t r)
```
- 如果支持绘制颜色（也就是不是单色显示器），那么由**u8g2_SetDrawColor(u8g2_t *u8g2, uint8_t color)**设置；
- 要求，w >= 2(r+1) 并且 h >= 2(r+1)，这是显而易见的限制
- 示例：

```cpp
u8g2_DrawRFrame(&u8g2,20,15,30,22,7);
```
![绘制圆角空心方形](https://img-blog.csdnimg.cn/f0a216708f884e12ba4878fbdd311976.png)
>>>

### 2.2.13 u8g2_DrawStr() —— 绘制字符串
函数说明：
```cpp
/**
 * 绘制字符串
 * @param x 左上角的x坐标
 * @param y 左上角的y坐标
 * @param s 绘制字符串内容
 * @return 字符串的长度
 */
u8g2_uint_t u8g2_DrawStr(u8g2_t *u8g2, u8g2_uint_t x, u8g2_uint_t y, const char *str)
```
 - 需要先设置字体，调用**u8g2_SetFont()**方法；
 - 这个方法不能绘制encoding超过256的，超过256需要用**u8g2_DrawUTF8()**或者**u8g2_DrawGlyph()**；说白了就是一般用来显示英文字符；
 - x，y属于字符串左下角的坐标；
 - 我们可以用它来**显示变量**；
 - 示例：

```cpp
u8g2_SetFont(&u8g2,u8g2_font_ncenB14_tr);
u8g2_DrawStr(&u8g2,0,15,"Hello World!");
```
![绘制字符串](https://img-blog.csdnimg.cn/9c2442f1854347d8a608957695640f8b.png)

```cpp
	for(uint8_t i=0;i<100;i++)
	{
		u8g2_ClearBuffer(&u8g2); 
			
		char buff[20];
		sprintf(buff,"%d",(int)(i/100.0*100));
		u8g2_SetFont(&u8g2,u8g2_font_inb24_mf);
        u8g2_DrawStr(&u8g2,127-41,24,buff);
     	u8g2_SendBuffer(&u8g2);	
        HAL_Delay(100);  
	} 
```


### 2.2.14 u8g2_DrawTriangle() —— 绘制实心三角形
函数说明：
```cpp
/**
 * 绘制实心三角形，定点坐标分别为(x0,y0),(x1,y1),(x2,y2)
 */
void u8g2_DrawTriangle(u8g2_t *u8g2, int16_t x0, int16_t y0, int16_t x1, int16_t y1, int16_t x2, int16_t y2)
```
 - 示例：

```cpp
u8g2_DrawTriangle(&u8g2,20,5, 27,50, 5,32);
```
![绘制实心三角形](https://img-blog.csdnimg.cn/c4fd193817e145c090255271849494a3.png)

```cpp
	for(uint8_t i=0;i<100;i++)
	{
        u8g2_ClearBuffer(&u8g2); 

        u8g2_DrawTriangle(&u8g2,20,5, 27,50, i,32);
        HAL_Delay(100);  
        u8g2_SendBuffer(&u8g2);	
	} 
```
>>>

### 2.2.15 u8g2_DrawUTF8() —— 绘制UTF8编码的字符
函数说明：
```cpp
/**
 * 绘制UTF8编码的字符串
 * @param x 字符串在屏幕上的左下角x坐标
 * @param y 字符串在屏幕上的左下角y坐标
 * @param s 需要绘制的UTF-8编码字符串
 * @return 返回字符串的长度
 */
u8g2_uint_t u8g2_DrawUTF8(u8g2_t *u8g2, u8g2_uint_t x, u8g2_uint_t y, const char *str)
```
 - 使用该方法，有两个前提。首先是你的编译器需要支持UTF-8编码，对于绝大部分Arduino板子已经支持；其次，显示的字符串需要存为“UTF-8”编码，Arduino IDE上默认支持；
 - 该方法需要依赖于fontMode（setFont）以及drawing Color，也就是说如果你传进来的字符串编码必须在font定义里面；
 - Keil v5 mdk 编译UTF8字符串报错的解决办法--no-multibyte-chars
 ![UTF8字符串报错的解决办法](https://img-blog.csdnimg.cn/1492d7f3a54745deafb6a590272da21d.png)

 - 示例

```cpp
u8g2_SetFont(&u8g2,u8g2_font_unifont_t_symbols);
u8g2_DrawUTF8(&u8g2,5, 20, "Snowman: ☃");
```

![绘制UTF8编码的字符](https://img-blog.csdnimg.cn/2812e16384f34423b8a8cf23f6fb34fe.png)


### 2.2.16 u8g2_DrawVLine() —— 绘制竖直线
函数说明：
```cpp
/**
 * 绘制竖直线
 * @param x 左上角坐标x
 * @param y 左上角坐标y
 * @param h 高度
 */
void u8g2_DrawVLine(u8g2_t *u8g2, u8g2_uint_t x, u8g2_uint_t y, u8g2_uint_t len)
```

### 2.2.17 u8g2_DrawXBM()/u8g2_DrawXBMP() —— 绘制图像
函数说明：
```cpp
/**
 * 绘制图像
 * @param x 左上角坐标x
 * @param y 左上角坐标y
 * @param w 图形宽度
 * @param h 图形高度
 * @param bitmap 图形内容
 * @Note 关联方法 setBitmapMode
 */
void u8g2_DrawXBM(u8g2_t *u8g2, u8g2_uint_t x, u8g2_uint_t y, u8g2_uint_t w, u8g2_uint_t h, const uint8_t *bitmap)
void u8g2_DrawXBMP(u8g2_t *u8g2, u8g2_uint_t x, u8g2_uint_t y, u8g2_uint_t w, u8g2_uint_t h, const uint8_t *bitmap)
```
 - **u8g2_DrawXBM**和**u8g2_DrawXBMP**区别在于 **XBMP**支持**PROGMEM**；
 
### 2.2.18 u8g2_FirstPage()/u8g2_NextPage() —— 绘制命令
函数说明：
```cpp
/**
 * 绘制图像
 */
void u8g2_FirstPage(u8g2_t *u8g2)
uint8_t u8g2_NextPage(u8g2_t *u8g2)
```
 - **u8g2_FirstPage**方法会把当前页码位置变成0；
 - 修改内容处于**u8g2_FirstPage**和**u8g2_NextPage**之间，每次都是重新渲染所有内容；
 - 该方法消耗的ram空间，比**u8g2_SendBuffer**消耗的RAM空间要少；
 - 示例：
```cpp
u8g2_FirstPage(&u8g2);
do {
	u8g2_SetFont(&u8g2,u8g2_font_ncenB14_tr);
	u8g2_DrawStr(&u8g2,0,15,"Hello World!");
} while (u8g2_NextPage(&u8g2));
```
 - 库源码解析：

```cpp
void u8g2_FirstPage(u8g2_t *u8g2)
{
  if ( u8g2->is_auto_page_clear )
  {
    //清除缓冲区
    u8g2_ClearBuffer(u8g2);
  }
  //设置当前缓冲区的Tile Row 一个Tile等于8个像素点的高度
  u8g2_SetBufferCurrTileRow(u8g2, 0);
}

uint8_t u8g2_NextPage(u8g2_t *u8g2)
{
  uint8_t row;
  u8g2_send_buffer(u8g2);
  row = u8g2->tile_curr_row;
  row += u8g2->tile_buf_height;
  if ( row >= u8g2_GetU8x8(u8g2)->display_info->tile_height )
  { 
  	//如果row已经到达最后一行，触发refreshDisplay调用，表示整个页面已经刷完了
    u8x8_RefreshDisplay( u8g2_GetU8x8(u8g2) );
    return 0;
  }
  if ( u8g2->is_auto_page_clear )
  {
    //清除缓冲区
    u8g2_ClearBuffer(u8g2);
  }
  //不断更新TileRow 这是非常关键的一步
  u8g2_SetBufferCurrTileRow(u8g2, row);
  return 1;
}
```
### 2.2.19 u8g2_SendBuffer() —— 绘制缓冲区的内容
函数说明：
```cpp
/**
 * 绘制缓冲区的内容
 * @Note 关联方法  clearBuffer
 */
void u8g2_SendBuffer(u8g2_t *u8g2)
```
 - **u8g2_SendBuffer**的**RAM**占用空间大，需要结合构造器的buffer选项使用；
 - 不管是**u8g2_FirstPage**、**u8g2_NextPage**还是**u8g2_SendBuffer**，都涉及到一个叫做 **current page position**的概念；
 - 库源码解析：

```cpp
void u8g2_SendBuffer(u8g2_t *u8g2)
{
  u8g2_send_buffer(u8g2);
  u8x8_RefreshDisplay( u8g2_GetU8x8(u8g2) );  
}
 
static void u8g2_send_tile_row(u8g2_t *u8g2, uint8_t src_tile_row, uint8_t dest_tile_row)
{
  uint8_t *ptr;
  uint16_t offset;
  uint8_t w;
  
  w = u8g2_GetU8x8(u8g2)->display_info->tile_width;
  offset = src_tile_row;
  ptr = u8g2->tile_buf_ptr;
  offset *= w;
  offset *= 8;
  ptr += offset;
  u8x8_DrawTile(u8g2_GetU8x8(u8g2), 0, dest_tile_row, w, ptr);
}
 
/* 
  write the buffer to the display RAM. 
  For most displays, this will make the content visible to the user.
  Some displays (like the SSD1606) require a u8x8_RefreshDisplay()
*/
static void u8g2_send_buffer(u8g2_t *u8g2) U8X8_NOINLINE;
static void u8g2_send_buffer(u8g2_t *u8g2)
{
  uint8_t src_row;
  uint8_t src_max;
  uint8_t dest_row;
  uint8_t dest_max;
 
  src_row = 0;
  src_max = u8g2->tile_buf_height;
  dest_row = u8g2->tile_curr_row;
  dest_max = u8g2_GetU8x8(u8g2)->display_info->tile_height;
  
  do
  {
    u8g2_send_tile_row(u8g2, src_row, dest_row);
    src_row++;
    dest_row++;
  } while( src_row < src_max && dest_row < dest_max );
}
```
 - 示例

```cpp
void Buffer(u8g2_t *u8g2) {
	u8g2_ClearBuffer(u8g2);
	// ... write something to the buffer 
	u8g2_SendBuffer(u8g2);	
	HAL_Delay(1000);
}
```

## 2.3 显示配置相关函数（并不是很有用，再进阶）
### 2.3.1 u8g2_GetAscent() —— 获取基准线以上的高度
函数说明：

```cpp
/**
 * 获取基准线以上的高度
 * @return 返回高度值
 * @Note 关联方法  setFont getDescent setFontRefHeightAll
 */
int8_t u8g2_GetAscent(&u8g2)
```
 - 跟字体有关（u8g2_SetFont）；
 - 示例：
下面例子，ascent是18
![获取基准线以上的高度](https://img-blog.csdnimg.cn/719839ae60974a95b8e5426c38b407df.png)

### 2.3.2 u8g2_GetDescent() —— 获取基准线以下的高度
函数说明：

```cpp
/**
 * 获取基准线以下的高度
 * @return 返回高度值
 * @Note 关联方法  setFont setFontRefHeightAll
 */
int8_t u8g2_GetDescent(&u8g2);
```
 - 跟字体有关（setFont）；
 - 示例：
下面例子，descent是-5
![获取基准线以下的高度](https://img-blog.csdnimg.cn/da5eb213190a4538aa7f0983e23f6966.png)

### 2.3.3 u8g2_GetDisplayHeight() —— 获取显示器的高度
函数说明：

```cpp
/**
 * 获取显示器的高度
 * @return 返回高度值
 */
u8g2_uint_t getDisplayHeight(void)
```
### 2.3.4 u8g2_GetDisplayWidth() —— 获取显示器的宽度
函数说明：

```cpp
/**
 * 获取显示器的宽度
 * @return 返回宽度值
 */
u8g2_uint_t getDisplayWidth(void)
```
### 2.3.5 u8g2_GetMaxCharHeight() —— 获取当前字体里的最大字符的高度
函数说明：

```cpp
/**
 * 获取当前字体里的最大字符的高度
 * @return 返回高度值
 * @Note 关联方法 setFont
 */
u8g2_uint_t getMaxCharHeight(void)
```
### 2.3.6 u8g2_GetMaxCharWidth() —— 获取当前字体里的最大字符的宽度
函数说明：

```cpp
/**
 * 获取当前字体里的最大字符的宽度
 * @return 返回宽度值
 * @Note 关联方法 setFont
 */
u8g2_uint_t getMaxCharWidth(void)
```
### 2.3.7 u8g2_GetStrWidth() —— 获取字符串的像素宽度
函数说明：

```cpp
/**
 * 获取字符串的像素宽度
 * @param s 绘制字符串
 * @return 返回字符串的像素宽度值
 * @Note 关联方法 setFont drawStr
 */
u8g2_uint_t U8G2::getStrWidth(const char *s)
```
### 2.3.8 u8g2_GetUTF8Width() —— 获取UTF-8字符串的像素宽度
函数说明：

```cpp
/**
 * 获取UTF-8字符串的像素宽度
 * @param s 绘制字符串
 * @return 返回字符串的像素宽度值
 * @Note 关联方法 setFont drawStr
 */
u8g2_uint_t U8G2::getUTF8Width(const char *s)
```
### 2.3.9 u8g2_SetAutoPageClear() —— 设置自动清除缓冲区
函数说明：

```cpp
/**
 * 是否自动清除缓冲区
 * @param mode 0 表示关闭
 *             1 表示开启，默认是开启
 */
void U8G2::setAutoPageClear(uint8_t mode)
```
### 2.3.10 u8g2_SetBitmapMode() —— 设置位图模式
函数说明：

```cpp
/**
 * 设置位图模式（定义drawXBM方法是否绘制背景颜色）
 * @param is_transparent
 *         0 绘制背景颜色，不透明，默认是该值
 *         1 不绘制背景颜色，透明
 * @Note 关联方法 drawXBM
 */
void U8G2::setBitmapMode(uint8_t is_transparent)
```
 - 示例：

```cpp
u8g2.setDrawColor(1);
u8g2.setBitmapMode(0);
u8g2.drawXBM(4,3, u8g2_logo_97x51_width, u8g2_logo_97x51_height,  u8g2_logo_97x51_bits);
u8g2.drawXBM(12,11, u8g2_logo_97x51_width, u8g2_logo_97x51_height,  u8g2_logo_97x51_bits);
```

![设置位图模式1](https://img-blog.csdnimg.cn/5def81f3580d4e45b70e907cc3f3c69c.png)

```cpp
u8g2.setDrawColor(1);
u8g2.setBitmapMode(1);
u8g2.drawXBM(4,3, u8g2_logo_97x51_width, u8g2_logo_97x51_height,  u8g2_logo_97x51_bits);
u8g2.drawXBM(12,11, u8g2_logo_97x51_width, u8g2_logo_97x51_height,  u8g2_logo_97x51_bits);
```

![设置位图模式2](https://img-blog.csdnimg.cn/f4c5a187659b46cebca8d8c17e982cb8.png)


### 2.3.11 u8g2_SetBusClock() —— 设置总线时钟
函数说明：

```cpp
/**
 * 设置总线时钟(I2C SPI)
 * @param mode clock_speed 总线时钟频率(Hz)
 * @Note 关联方法 begin
 */
void U8G2::setBusClock(uint32_t clock_speed);
```
 - 仅仅Arduino平台支持；
 - 必须在u8g2.begin() 或者 u8g2.initDisplay()之前调用；
 
### 2.3.12 u8g2_SetClipWindow() —— 设置采集窗口大小
函数说明：

```cpp
/**
 * 设置采集窗口，窗口范围从左上角(x0,y0)到右下角(x1,y1)
 * 也就是我们绘制的内容只能在规范范围内显示
 * @param x0 左上角x坐标
 * @param y0 左上角y坐标
 * @param x1 右上角x坐标
 * @param y1 右上角y坐标
 * @Note 关联方法 begin
 */
void U8G2::setClipWindow(u8g2_uint_t x0, u8g2_uint_t y0, u8g2_uint_t x1, u8g2_uint_t y1 );
```
 - 可以通过 setMaxClipWindow 去掉该限制

```cpp
void U8G2::setMaxClipWindow(void)
```

```cpp
u8g2.setClipWindow(10, 10, 85, 30);
u8g2.setDrawColor(1);
u8g2.drawStr(3, 32, "U8g2");
```

![设置采集窗口大小](https://img-blog.csdnimg.cn/731363022d3b4fd1af6e6b1356bac1e0.png)

### 2.3.13 u8g2_SetCursor() —— 设置绘制光标位置
函数说明：

```cpp
/**
 * 设置绘制光标位置(x,y)
 * @Note 关联方法 print
 */
void U8G2::setCursor(u8g2_uint_t x, u8g2_uint_t y)
```
 - 示例：

```cpp
u8g2.setFont(u8g2_font_ncenB14_tr);
u8g2.setCursor(0, 15);
u8g2.print("Hello World!");
```
![设置绘制光标位置](https://img-blog.csdnimg.cn/2c171a07277248baaf0bf7ac984e3348.png)

### 2.3.14 u8g2_SetDisplayRotation() —— 设置显示器的旋转角度
函数说明：

```cpp
/**
 * 设置显示器的旋转角度
 * @param u8g2_cb 旋转选项
 *        U8G2_R0 不做旋转 水平
 *        U8G2_R1 旋转90度
 *        U8G2_R2 旋转180度
 *        U8G2_R3 旋转270度
 *        U8G2_MIRROR 不做旋转 水平，显示内容是镜像的，暂时不理解
 */
void setDisplayRotation(const u8g2_cb_t *u8g2_cb)
```
### 2.3.15 u8g2_SetDrawColor() —— 设置绘制颜色
函数说明：

```cpp
/**
 * 设置绘制颜色（暂时还没有具体去了解用法）
 */
void U8G2::setDrawColor(uint8_t color)
```
### 2.3.16 u8g2_SetFont() —— 设置字体集
&emsp;&emsp;**这是一个非常重要的方法，非常重要！！！**
函数说明：

```cpp
/**
 * 设置字体集（字体集用于字符串绘制方法或者glyph绘制方法）
 * @param font 具体的字体集
 * @Note 关联方法  drawUTF8 drawStr drawGlyph print
 */
void U8G2::setFont(const uint8_t *font)
```
 - Font会根据像素点高度做了很多区分，具体font请参考 [Fntlistall iki](https://github.com/olikraus/u8g2/wiki/fntlistall)。
 - 如果我们需要用到中文字符，可以在wiki里面搜索一下chinese，你就会发现很多中文font，比如：
![字体集](https://img-blog.csdnimg.cn/89ed285ab0284c9abb99513124069533.png)
![设置字体集1](https://img-blog.csdnimg.cn/b5c62b928189461ea513fad74716ca9f.png)

![设置字体集2](https://img-blog.csdnimg.cn/aba9fc370509443db372ef6b7436b857.png)

### 2.3.17 u8g2_SetFontDirection() —— 设置字体方向
函数说明：

```cpp
在这里插入代码片
```
![设置字体方向](https://img-blog.csdnimg.cn/08609654bd0b43449199b7e04f4d29a6.png)

## 2.4 缓存相关函数（了解了解）
### 2.4.1 u8g2_GetBufferPtr() —— 获取缓存空间的地址
函数说明：

```cpp
在这里插入代码片
```
### 2.4.2 u8g2_GetBufferTileHeight() —— 获取缓冲区的Tile高度
函数说明：

```cpp
在这里插入代码片
```
### 2.4.3 u8g2_GetBufferTileWidth() —— 获取缓冲区的Tile宽度
函数说明：

```cpp
在这里插入代码片
```
### 2.4.4 u8g2_GetBufferCurrTileRow() —— 获取缓冲区的当前Tile row
函数说明：

```cpp
在这里插入代码片
```
### 2.4.5 u8g2_SetBufferCurrTileRow() —— 设置缓冲区的当前Tile row
函数说明：

```cpp
在这里插入代码片
```
![设置缓冲区的当前Tile row](https://img-blog.csdnimg.cn/fe840e6183ae4189a53bce879497e94e.png)

## 3.如何运用U8G2库