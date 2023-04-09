---
title: FOC
date: 2023-04-08 10:13:20
top: 2
tags: FOC
mathjax: true
coauthor: 深藏blue
---


<meta name="referrer" content="no-referrer"/>

## 绪论:sparkles:

**▌什么是FOC控制？**

FOC（Field-Oriented Control），即磁场定向控制，也称矢量变频，是目前高效控制无刷直流电机（BLDC）和永磁同步电机（PMSM）的最佳选择。FOC 能精确地控制磁场大小与方向，使得电机转矩平稳、噪声小、效率高，并且具有高速的动态响应，优越的高低速控制性能。目前已在很多应用上逐步替代传统的控制方式，在运动控制行业中备受瞩目。利用FOC控制的产品在我们生活中处处可见，家电消费的变频空调、高性能吹风机、洗地机，工业领域的新能源汽车电机、生产线上的伺服电机[1]，又或是热门的机器人行业[2]，都离不开FOC的身影。 

![图1.FOC机械臂应用	图2.FOC机械人应用](https://i0.hdslb.com/bfs/article/db010619e98e39b5893894306e04e9c642c0353e.png@942w_393h_progressive.webp)


 <!-- more -->

**▌FOC控制的核心思想**

笔者认为，想要通俗地理解FOC（磁场定向控制），需要先从名称入手，即磁场、定向、控制这三部分。

- **磁场**：通过SVPWM等手段合成矢量磁场。
- **定向**：通过一定手段准确测量到转子的位置。
- **控制**：根据期望的定子磁场矢量，对磁场的大小与方向进行准确控制。

**▌坐标变换**

通过逆变电路，我们可以输出调制三相电压，对电机进行控制。然而对于非线性信号进行准确控制，需要非常复杂的高阶控制器，驱动动辄上万转速的电机，控制的实时性无法达到。所以，为简化自然坐标系下的三相PMSM的数学模型，实现控制上的解耦，需建立相应的坐标变换包括**静止坐标α-β** 变换和**同步旋转坐标d-q**变换，即**Clark**变换与**Park**变换。其具体过程就是将三相坐标系交流转为两相坐标系交流，然后将两相坐标系交流转为电机自身旋转坐标系下的直流量。从而简化控制过程。

**▌自然坐标系**

如下图所示，将一个旋转的向量映射到三相自然坐标系[3]上，波形如右图所示。

![图片](https://i0.hdslb.com/bfs/article/3e02d54e2068263974f88ce726d65ffa182f63bd.gif@942w_486h_progressive.webp)

图3.三相电流表示

▌αβ 坐标系
我们可以用两相正交坐标系[4]下的交流量来表示三相坐标系下的交流量，保证幅值不变。这种由三相自然坐标系到两相静止坐标系的变换为Clark变换。

![img](https://i0.hdslb.com/bfs/article/f52d3004f9818610096eb3eec4e2ddcad005f4f9.gif@942w_486h_progressive.webp)

图4.两相电流表示

▌dq 坐标系
我们将两相静止坐标系下的电流转化到两相旋转坐标系上[5]，以直流量的方式进行PI运算。这种由两相静止坐标系到同步旋转坐标系下的变化为Park变换。根据物理结构，d轴与转子磁链方向重合，q轴与转子磁链方向垂直。id（direct）为励磁电流也称为直轴电流，iq（quadrature）为转矩电流也称为交轴电流。 

![图片](https://i0.hdslb.com/bfs/article/63658e2d6f2a72cdbeb45a9b7d17c7dc923077b0.gif@942w_486h_progressive.webp)
▌力的控制
通过以上的坐标转换推导，我们提取出了id与iq的概念，根据永磁同步电机的运动方程，得出以下公式。

![img](https://i0.hdslb.com/bfs/article/d98e9de053f24a3800ff14abb22f3dfb52801a11.png@942w_173h_progressive.webp)

其中，Te为电磁转矩，Pn为极对数，Ld、Lq为直交轴电感，id、iq为直交轴电流，φ为永磁体磁链。可以看出当进行id = 0的控制时，iq与扭矩线性相关。

![图片](https://i0.hdslb.com/bfs/article/d6a5c1466eb6dd833358f730f14fb12b9f6ffbf5.jpg@675w_408h_progressive.webp)

图6.FOC的生动表示[3]

上图[3]生动形象地描述了永磁同步电机的控制。胡萝卜就是转矩电流iq，毛驴就是转子，与毛驴之间的距离就是控制角度。保持萝卜与毛驴的合适位置不变，毛驴就能一直向前。这也解释了磁场方向与转子的关系，即磁场方向需要始终和转子方向垂直，这样的转矩最大，过大或过小都会造成效率低下甚至控制发散。综上，我们只需要设计控制器，对同步电角度进行准确观测，对iq精准控制，就能实现对永磁同步电机转矩的控制。

▌FOC驱动器
FOC除了算法本身，驱动器也是其中的重要一环，驱动器设计的优异，往往决定着电机控制的最终效果。驱动模块由以下器件组成：

主控：负责进行运行电机驱动算法，与其他设备进行通信。为了提高控制性能，更高芯片性能的代表能进行一个采样的FOC运算所消耗的时间越少，进行采样的频率能更高，所能输出的载波频率越高，电流高次谐波成分越小，电机运行更顺滑。且理论上一个电角度至少包含12次电流采样，所以更高的载波频率代表电机能达到的速度越快。部分主控带有电机专用外设例如差分运放、栅极驱动器、DCDC等模拟外设，能极大的节省PCB空间，降低BOM成本。

栅极驱动器：负责驱动NMOS，由于芯片输出PWM无法直接驱动MOS，需要自举电路，所以绝大多数需要单独的电机驱动。有些驱动集成DCDC、可编程运放，所以既是通用单片机也可以作为电机控制使用。

运算放大器：对于无运放的主控和驱动器，需要用分立元件搭建电流采样的运算放大器，对相电流采样电阻上的电压信号进行成比例放大。

MOS:主控通过控制场效应管和逆变桥式电路来通断来生成SVPWM波，从而产生正弦波电流驱动电机，选择MOS的Vds应当大于等于两倍额定电压，以防止反电动势击穿MOS。MOS是整个PCB的主要热源，选型时需要考虑好导通电流、耗散功率等参数，并对MOS进行适当散热手段。

编码器：对于伺服有感应用，编码器必不可少，通常使用磁编作为无刷伺服编码器，且编码器分辨率理论上越高越好。

![图片](https://i0.hdslb.com/bfs/article/fdcd2318c3b6be047b819b383d5dfd206e8425d7.png@942w_854h_progressive.webp)

除了上述硬件外，各种硬件设计也决定着性能的优越与成本的高低。例如单电阻与多电阻采样等。

▌总结
借助FOC优越的控制性能，使得机械臂等作业机构能够通过力控来更好地完成作业任务。当然，本文只是对FOC的核心思想和驱动器进行了简单的介绍，实际应用过程中的细节远不止此，如有机会我们以后探讨，敬请期待！ 作者：西湖大学空中机器人 https://www.bilibili.com/read/cv17289017 出处：bilibili

### 六步换向

``` bash
$ hexo new "My New Post"
```

### 坐标变换

``` bash
$ hexo server
```

### SVPWM

``` bash
$ hexo generate
```

### 电流环


$$\begin{equation} \label{eq1}
e=mc^2
\end{equation}$$

$$
i\hbar\frac{\partial}{\partial t}\psi=-\frac{\hbar^2}{2m}\nabla^2\psi+V\psi
$$

$\ce{CO2 + C -> 2 CO}$

-$ \epsilon_0 $
+$\epsilon_0$
-$ \frac{\partial}{\partial t} $
+$\frac{\partial}{\partial t}$

\begin{eqnarray\*}
\nabla\cdot\vec{E}&=&\frac{\rho}{\epsilon_0}\\\\
\nabla\cdot\vec{B}&=&0\\\\
\nabla\times\vec{E}&=&-\frac{\partial B}{\partial t}\\\\
\nabla\times\vec{B}&=&\mu_0\left(\vec{J}+\epsilon_0\frac{\partial E}{\partial t}\right)\\\\
\end{eqnarray\*}

-$ \epsilon_0 $
+$\epsilon_0$
-$ \frac{\partial}{\partial t} $
+$\frac{\partial}{\partial t}$