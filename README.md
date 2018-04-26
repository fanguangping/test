# funnyos


----------


标签（空格分隔）： OS OperatingSystem MIPS scheme funny


---


**简介**


----------


funnyos（泛语言操作系统）是一种以MIPS指令集为基础，使用scheme语言编写的操作系统。目前处于实验的初步阶段。


----------


**开发所需的背景知识**


----------

目前多数操作系统内核都是以C语言写成的，因其轻巧高效易于嵌入。但是这并不代表只有C语言可以写操作系统。本项目计划用scheme语言来编写操作系统，它并非完全遵循rnrs标准，而是经过深思熟虑而改写的一个变种。为了使该项目的开发者能够达成共识，我们就funnyos开发所需的知识做一下梳理。

 1. 依赖的硬件
    本项目以MIPS指令集为基础，为了使funnyos能够不依赖于具体的硬件执行，使用java语言编写一个MIPS的虚拟机，具体知识请移步本空间的另一个项目：funnymachine，该项目同时包含汇编器
 2. MIPS指令集
    MIPS指令集与汇编语言知识可参考《计算机组成与设计-硬件软件接口》一书
 3. scheme语言变种funny-scheme
    funnyos所需的scheme语言演变至热r5rs标准，变动的地方主要有这么几点：
    a) 不解析所有的类型，而是改为部分类型对字符串做解析，例如，(define var 1.23)需改写为(define var (lex 3 "1.23"))
    b) 不使用宏
 4. 使用MIPS汇编器编写funny-scheme语言编译器
    可以参考项目[EMECHS-Scheme][1]
 5. 使用funny-scheme编写funnyos操作系统
    编写操作系统的知识可参考《Orange'S:一个操作系统的实现》和《30天自制操作系统》这两本书，以及minix系统的源码
 6. 应用层语言funny
    funny是一种基于funny-scheme的宏语言，版本规范可参考。。。

  [1]: https://github.com/Schol-R-LEA/EMECHS-Scheme