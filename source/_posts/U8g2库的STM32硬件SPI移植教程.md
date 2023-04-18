title: U8g2库的STM32硬件SPI移植教程
author: 深藏Blue
tags:
  - U8g2
  - 笔记
  - CubeMX
  - STM32
categories:
  - 笔记
abbrlink: 1345941684
date: 2023-04-17 23:08:00
---
<meta name="referrer" content="no-referrer"/>

# U8g2库的STM32硬件SPI移植教程（HAL、OLED显示、四线SPI）
## 前言

 - 本文教你把U8g2图形库移植到STM32上，基于STM32的硬件SPI、CubeMX
 - [U8g2库Github网址：https://github.com/olikraus/u8g2](https://github.com/olikraus/u8g2)
 - [U8g2库CSDN镜像网址：https://gitcode.net/mirrors/olikraus/u8g2?utm_source=csdn_github_accelerator](https://gitcode.net/mirrors/olikraus/u8g2?utm_source=csdn_github_accelerator)
 - 硬件准备：STM32C8T6（STM32系列芯片）、0.96寸OLED（128×64）、J-Link（或其他）
 - 引脚连接：

```c
//----------------------------------------------------------------
本次用的是SPI1、DMA、全双工(当然半双工也没什么问题、CS、DC、RS是普通GPIO，自行切换)
GND -----------> 电源地
VCC -----------> 接5V或3.3v电源
D0 -----------> 接PA5（SCL）
D1 -----------> 接PA7（SDA）
RES -----------> 接PB0
DC -----------> 接PB1
CS -----------> 接PA4              
//----------------------------------------------------------------
```
## U8g2简介（出自此篇[基于STM32移植U8g2图形库——OLED显示](https://blog.csdn.net/black_sneak/article/details/126312657?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522168163849116800211564885%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=168163849116800211564885&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~top_positive~default-1-126312657-null-null.142%5Ev83%5Epc_search_v2,239%5Ev2%5Einsert_chatgpt&utm_term=U8g2&spm=1018.2226.3001.4187)）

### U8g2是什么
&emsp;&emsp; U8g2是GitHub上一款十分优秀的开源图形库（GUI库），其本质是嵌入式设备的单色图形库。在 Github 上超过3.2K Star，2.6K Commit。其开发语言90%为C语言，且代码简洁干练便于移植与后期修改。

### U8g2支持的显示控制器
 &emsp;&emsp; U8g2支持单色OLED和LCD，包括以下控制器：
 
|  |  |  |  |  |  |
|--|--|--|--|--|--|
| SSD1305 | **SSD1306** | SSD1309 | SSD1312 | SSD1316 | SSD1320 | 
| SSD1322 | SSD1325 | SSD1327 | SSD1329 | SSD1606 | SSD1607 | 
| SH1106 | SH1107 | SH1108 | SH1122 | T6963 | RA8835 |
| LC7981 | PCD8544 | PCF8812 | HX1230 | UC1601 | UC1604 |
| UC1608 | UC1610 | UC1611 | UC1617 | UC1638 | UC1701 |
| ST7511 | ST7528 | ST7565 | ST7567 | ST7571 | ST7586 |
| ST7588 | ST75256 | ST75320 | NT7534 | ST7920 | IST3020 | 
| IST7920 | LD7032 | KS0108 | KS0713 | HD44102 | T7932 |
| SED1520 | SBN1661 | IL3820 | MAX7219 |  |  |

&emsp;&emsp; 可以说，基本上主流的显示控制器都支持，比如我们常见的SSD1306等，读者在使用该库之前请查阅自己的OLED显示控制器是否处于支持列表中。

### U8g2的优势
 - U8g2库平台支持性好，基本上支持绝大部分Arduino与STM32开发板，也包含物联网比较常用的esp8266；
 - U8g2库显示控制器支持性好，基本上市面上的OLED都完美支持；
 - U8g2库 API函数众多，特别支持了中文，支持了不同字体，这是一个对于开发者俩说不小的福利；
 - U8g2 库移植简单，容易使用（这一点也是笔者比较钟意的）；

 &emsp;&emsp;其实，我们可以把U8g2当作一个工具箱，需要使用的时候就去打开工具箱，使用里面的已经写好的API函数去实现我们需要达到的显示效果。（当然，前提是需要熟悉U8g2的使用，这一点网上有很多用法博客写得都很详细，感兴趣的读者朋友可以去看看这篇：[深入学习Arduino u8g2 OLED库，一篇就够](https://blog.csdn.net/dpjcn1990/article/details/92831760?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522168165487716800180669581%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fall.%2522%257D&request_id=168165487716800180669581&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~first_rank_ecpm_v1~hot_rank-1-92831760-null-null.142%5Ev83%5Epc_search_v2,239%5Ev2%5Einsert_chatgpt&utm_term=u8g2&spm=1018.2226.3001.4187)）
 
## CubexMX的配置

### RCC配置外部高速晶振（精度更高）——HSE：

![RCC配置外部高速晶振（精度更高）——HSE](https://img-blog.csdnimg.cn/898c214b2d4f41be86ed19f72879c570.png)

### SYS配置：Debug设置成Serial Wire（否则可能导致芯片自锁）：

![Debug设置成Serial Wire](https://img-blog.csdnimg.cn/a163ea11d7d64a3aa2d7bff932b64c7e.png)

### 时钟树配置：

![时钟树配置](https://img-blog.csdnimg.cn/db970f2364b64b8cbc3b76fe2bccf04f.png)

### SPI1配置半双工（全双工）：作为OLED的通讯方式：
**&emsp;&emsp;半双工：**
![SPI1配置半双工](https://img-blog.csdnimg.cn/95f16dd2bcb346a8b24a115c55ce0dd7.png)
**&emsp;&emsp;全双工：**
![SPI1配置全双工](https://img-blog.csdnimg.cn/7da21c305c2949de8399c17ae0540e1b.png)

### DMA配置：
![DMA配置](https://img-blog.csdnimg.cn/65c0c9fd905d4d86989d3e4f3eac5d65.png)

### 工程配置：
![工程命名](https://img-blog.csdnimg.cn/abde58d25e62430092db882a905a3ee8.png)
&emsp;&emsp;**这里我们不用的库不加，减小代码体积**
![工程配置](https://img-blog.csdnimg.cn/1867710e32f34461a8250322ca52dc9f.png)
**然后生成**

## U8g2移植

### 准备U8g2库文件
 - `准备U8g2库文件---------->U8g2下载地址: https://github.com/olikraus/u8g2    下载压缩包`
 - `Git用---------->git clone https://ghproxy.com/https://github.com/olikraus/u8g2.git`
 
### 精简U8g2库文件
 -  U8g2支持多种显示驱动的屏幕，因为源码中也包含了各个驱动对应的文件（因此不需要自己去写屏幕底层驱动了），为了减小整个工程的代码体积和芯片资源占用，在移植U8g2时，可以删除一些无用的文件。
 - 这里我们主要关注的是U8g2库文件中的**csrc文件夹** ![csrc文件夹](https://img-blog.csdnimg.cn/f2f679bd6ab448228be9c75adecaacad.png)
 
#### 去掉csrc文件夹中无用的驱动文件
&emsp;&emsp;这些驱动文件通常是**u8x8_d_xxx.c**，**xxx**包括**驱动的型号**和**屏幕分辨率**。**ssd1306**驱动芯片的OLED，使用**u8x8_ssd1306_128x64_noname.c**这个文件，其它的屏幕驱动和分辨率的文件可以删掉。
![去掉csrc文件夹中无用的驱动文件](https://img-blog.csdnimg.cn/c71c9005d94a4a78b8ad7aa884173549.png)
**u8x8_d_xxx.c**文件中留下**u8x8_ssd1306_128x64_noname.c**即可

#### 精简u8g2_d_setup.c（注意不是u8x8_setup.c）
&emsp;&emsp;由于本文使用的OLED是**SPI**接口，只留一个本次要用到**u8g2_Setup_ssd1306_128x64_noname_f**就好（如果是**IIC**接口，需要使用**u8g2_Setup_ssd1306_i2c_128x64_noname_f**这个函数，**多了i2c**注意区分），其它的可以删掉或注释掉。
![精简u8g2_d_setup.c](https://img-blog.csdnimg.cn/4f1653309e1f41108c3733a396ad282b.png)

> 注意，与这个函数看起来十分相似的函数的有：
>  - u8g2_Setup_ssd1306_128x64_noname_1 
>  - u8g2_Setup_ssd1306_128x64_noname_2
>  - **u8g2_Setup_ssd1306_128x64_noname_f**
>  - u8g2_Setup_ssd1306_i2c_128x64_noname_1
>  - u8g2_Setup_ssd1306_i2c_128x64_noname_2
>  - u8g2_Setup_ssd1306_i2c_128x64_noname_f
> 
> 其中，前面3个，是给**SPI**接口的OLED用的，后面3个，是给**I2C**用的函数最后的数字或字母，代表显示时的buf大小：
>  - 1：128字节
>  - 2：256字节
>  - **f：1024字节**

#### 精简u8g2_d_memory.c
&emsp;&emsp;**u8g2_d_memory.c**文件中，由于用到的**u8g2_Setup_ssd1306_128x64_noname_f**函数中，只调用了**u8g2_m_16_8_f**这个函数，所以只用留下这个函数，如果你用的其他函数，在**u8g2_d_memory.c**留下它相对应调用到的函数即可，**其它的函数要删掉或注释**，否则编译时很可能会导致**内存不足**。
![其它的函数要删掉或注释](https://img-blog.csdnimg.cn/62fefd3f5d65419bb777a50ca9d52213.png)
![精简u8g2_d_memory.c](https://img-blog.csdnimg.cn/2cc6547d7ea349a7b6ccd5082895b3a6.png)

### 将精简后的U8g2库添加至Keil
 &emsp;&emsp;Keil工程目录添加**精简后U8g2库文件中的csrc**文件夹，然后再添加U8g2的头文件搜寻目录（U8g2_lib里都是csrc文件里面的文件，可以根据自己的需要删减），如下：
![将精简后的U8g2库添加至Keil](https://img-blog.csdnimg.cn/ed4690cfa2674fb0aba706b7e96e9158.png)
![精简后U8g2库](https://img-blog.csdnimg.cn/9a6127b26e8941e5811c2c553b0be35e.png)

## 代码

### Oled回调函数
**oled_driver.c：**
```c
#include "oled_driver.h"
#include "stdlib.h"
#include "spi.h"
#include "dma.h"
#include "u8g2.h"

uint8_t u8x8_byte_4wire_hw_spi(u8x8_t *u8x8, uint8_t msg, uint8_t arg_int,void *arg_ptr)
{
    switch (msg)
    {
        case U8X8_MSG_BYTE_SEND: /*通过SPI发送arg_int个字节数据*/
//           HAL_SPI_Transmit_DMA(&hspi1, (uint8_t *)arg_ptr, arg_int);while(hspi1.TxXferCount);
			/*配置了DMA取消上一行注释即可*/
			HAL_SPI_Transmit(&hspi1,(uint8_t *)arg_ptr,arg_int,200);
			/*这是CubeMX生成的初始化*/
            break;
        case U8X8_MSG_BYTE_INIT: /*初始化函数*/
            break;
        case U8X8_MSG_BYTE_SET_DC: /*设置DC引脚,表明发送的是数据还是命令*/
			HAL_GPIO_WritePin(OLED_DC_GPIO_Port,OLED_DC_Pin,arg_int);
            break;
        case U8X8_MSG_BYTE_START_TRANSFER: 
            u8x8_gpio_SetCS(u8x8, u8x8->display_info->chip_enable_level);
            u8x8->gpio_and_delay_cb(u8x8, U8X8_MSG_DELAY_NANO, u8x8->display_info->post_chip_enable_wait_ns, NULL);
            break;
        case U8X8_MSG_BYTE_END_TRANSFER: 
            u8x8->gpio_and_delay_cb(u8x8, U8X8_MSG_DELAY_NANO, u8x8->display_info->pre_chip_disable_wait_ns, NULL);
            u8x8_gpio_SetCS(u8x8, u8x8->display_info->chip_disable_level);
            break;
        default:
            return 0;
    }
    return 1;
}

uint8_t u8x8_stm32_gpio_and_delay(U8X8_UNUSED u8x8_t *u8x8,
    U8X8_UNUSED uint8_t msg, U8X8_UNUSED uint8_t arg_int,
    U8X8_UNUSED void *arg_ptr) 
{
    switch (msg)
    {
        case U8X8_MSG_GPIO_AND_DELAY_INIT: /*delay和GPIO的初始化，在main中已经初始化完成了*/
            break;
        case U8X8_MSG_DELAY_MILLI: /*延时函数*/
            HAL_Delay(arg_int);     //调用谁stm32系统延时函数
            break;
        case U8X8_MSG_GPIO_CS: /*片选信号*/ //由于只有一个SPI设备，所以片选信号在初始化时已经设置为常有效
            HAL_GPIO_WritePin(OLED_CS_GPIO_Port, OLED_CS_Pin, arg_int);
            break;
        case U8X8_MSG_GPIO_DC: /*设置DC引脚,表明发送的是数据还是命令*/
            HAL_GPIO_WritePin(OLED_DC_GPIO_Port,OLED_DC_Pin,arg_int);
            break;
        case U8X8_MSG_GPIO_RESET:
            break;
    }
    return 1;
}

void u8g2Init(u8g2_t *u8g2)
{
/********************************************     
U8G2_R0     //不旋转，不镜像     
U8G2_R1     //旋转90度
U8G2_R2     //旋转180度   
U8G2_R3     //旋转270度
U8G2_MIRROR   //没有旋转，横向显示左右镜像
U8G2_MIRROR_VERTICAL    //没有旋转，竖向显示镜像
********************************************/
//    u8g2_Setup_sh1106_128x64_noname_2(u8g2, U8G2_R0, u8x8_byte_4wire_hw_spi, u8x8_stm32_gpio_and_delay);  // 初始化1.3寸OLED u8g2 结构体
	u8g2_Setup_ssd1306_128x64_noname_f(u8g2, U8G2_R0, u8x8_byte_4wire_hw_spi, u8x8_stm32_gpio_and_delay);  // 初始化0.96寸OLED u8g2 结构体
	u8g2_InitDisplay(u8g2);     //初始化显示
	u8g2_SetPowerSave(u8g2, 0); //开启显示
}
/*官方logo的Demo*/
void draw(u8g2_t *u8g2)
{
    u8g2_SetFontMode(u8g2, 1); /*字体模式选择*/
    u8g2_SetFontDirection(u8g2, 0); /*字体方向选择*/
    u8g2_SetFont(u8g2, u8g2_font_inb24_mf); /*字库选择*/
    u8g2_DrawStr(u8g2, 0, 20, "U");
    
    u8g2_SetFontDirection(u8g2, 1);
    u8g2_SetFont(u8g2, u8g2_font_inb30_mn);
    u8g2_DrawStr(u8g2, 21,8,"8");
        
    u8g2_SetFontDirection(u8g2, 0);
    u8g2_SetFont(u8g2, u8g2_font_inb24_mf);
    u8g2_DrawStr(u8g2, 51,30,"g");
    u8g2_DrawStr(u8g2, 67,30,"\xb2");
    
    u8g2_DrawHLine(u8g2, 2, 35, 47);
    u8g2_DrawHLine(u8g2, 3, 36, 47);
    u8g2_DrawVLine(u8g2, 45, 32, 12);
    u8g2_DrawVLine(u8g2, 46, 33, 12);
  
    u8g2_SetFont(u8g2, u8g2_font_4x6_tr);
    u8g2_DrawStr(u8g2, 1,54,"github.com/olikraus/u8g2");
}
/********************************* end_of_file **********************************/
```
GPIO定义的时候在CubeMX**设置别名**能更容易的切换IO口，如下
![GPIO设置别名](https://img-blog.csdnimg.cn/c0cdcfeb0f984979ab7f43925b65f3e8.png)
**oled_driver.h：**
```c
#ifndef __MD_OLED_DRIVER_H
#define __MD_OLED_DRIVER_H

#include "stdlib.h"	  
#include "main.h"
#include "gpio.h"
#include "u8g2.h"

//-----------------OLED端口定义----------------  					   
#define MD_OLED_RST_Clr() HAL_GPIO_WritePin(OLED_RES_GPIO_Port,OLED_RES_Pin,GPIO_PIN_RESET) //oled 复位端口操作
#define MD_OLED_RST_Set() HAL_GPIO_WritePin(OLED_RES_GPIO_Port,OLED_RES_Pin,GPIO_PIN_SET)

//OLED控制用函数
uint8_t u8x8_byte_4wire_hw_spi(u8x8_t *u8x8, uint8_t msg, uint8_t arg_int,void *arg_ptr);
uint8_t u8x8_stm32_gpio_and_delay(U8X8_UNUSED u8x8_t *u8x8,U8X8_UNUSED uint8_t msg, U8X8_UNUSED uint8_t arg_int,U8X8_UNUSED void *arg_ptr) ;
void u8g2Init(u8g2_t *u8g2);
void draw(u8g2_t *u8g2);

#endif  
```
&emsp;&emsp;上述编写的移植函数代码属于HAL库下的代码，标准库的代码其实差不多，有个别地方需要注意修改。有一定MCU编程基础的朋友应该很简单就可以做到仿写。移植代码的本质：这些函数代码就是对应的U8g2图形库的接口函数，通过这些函数去启用U8g2图形库。

### main函数

```c
int main(void)
{
  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_DMA_Init();
  MX_SPI1_Init();

  /* Initialize interrupts */
  MX_NVIC_Init();
  /* USER CODE BEGIN 2 */
  u8g2_t u8g2; // 显示器初始化结构体
  MD_OLED_RST_Set(); //显示器复位拉高
  u8g2Init(&u8g2);   //显示器调用初始化函数
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
       u8g2_FirstPage(&u8g2);
       do
       {
   			draw(&u8g2);
           
       } while (u8g2_NextPage(&u8g2));
  }
  /* USER CODE END 3 */
}
```
## 最终效果
![U8g2最终效果](https://img-blog.csdnimg.cn/d2087b1b1d3f4c98ae7477361ed54430.jpeg)

## 总结 
 &emsp;&emsp;U8g2图形库可以说目前小尺寸OLED首选的GUI，其可以呈现出的图形远不止上述中的图形，更多的功能还需要读者朋友们自己去好好发掘。优秀GUI的移植是一名合格嵌入式工程师必须掌握的技能之一，其可以达到大大缩短开发周期，优化UI界面等目的。LCD屏幕也存在类似的优秀开源GUI库，后续笔者会进行更新，感兴趣的读者朋友可以点波关注，感谢！！！
————————————————
原文链接：[https://blog.csdn.net/black_sneak/article/details/126312657](https://blog.csdn.net/black_sneak/article/details/126312657)

 - 开源代码：[https://gitee.com/ljs_ice/STM32_u8g2](https://gitee.com/ljs_ice/STM32_u8g2)