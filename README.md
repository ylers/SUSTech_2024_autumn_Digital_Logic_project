# SUSTech_2024_autumn_Digital_Logic_project

### 0 Preface

2024秋期 CS207 Digital logic 的 project

工作量较大，难度基础部分一般，bonus较大。

Project score: 116.70/100

Document score 10/10

总评最后加了2.5分，弥补了期中的一坨，big win



### 1 Introduction 

1. 使用的软件是vivado2017.4，应该可以直接打开上板。

2. 做的是抽油烟机项目，主要分以下几块实现（感觉项目间基本大差不差，主要都是考察这些知识）：

    - 基础状态机实现

    - 按键消抖，检测上升沿

    - 加入时序的状态转换

    - 计时器部分

    - bonus 部分：
        - 音频输出
        - 蓝牙输入输出

3. 在答辩时出现一点小bug，此项目中__<u>应该</u>__已经改正

    - 一个是蓝牙输入时分位显示错误，原因是蓝牙模块某数值设置错误
    - 另一个是时钟没法设置时间，把clock module里的<=全改为=就好了



### 2 Implementation summary

1. 具体可见Project Document，从实现到使用都非常详细

2. 以Top module作为中枢实现各个模块数据的传递

3. 重要module比如:

    - mode module 实现状态间的转换

    - show_number module 实现数据的显示

    - data_select module 将多个数据传入，根据状态选择传出的数据，这个数据就是show_number module 显示的数据（data是由三十二位特殊格式组成的）
    
     ```verilog
        always @(*) begin            
            data[31:28] = hours/10;    //时十位
            data[27:24] = hours%10;    //时个位
            data[23:20] = 04'hf;       //显示的横杠
            data[19:16] = minutes/10;  //分十位
            data[15:12] = minutes%10;  //分个位
            data[11:8]  = 04'hf;       //显示的横杠
            data[7:4]   = seconds/10;  //秒十位
            data[3:0]   = seconds%10;  //秒个位
        end                                              
     ```
    
    - 消抖模块(debounce module)，检测上升沿模块(bonetime module)可以参考，因为当时项目发布的时候还没讲到这两个模块，花了好长时间来解决按钮问题，后来发现lab课上有现成的，难受 T_T，相关lab ppt也附上了。
    
    - Counter module是一个独立的计时模块, 感觉比较实用 ,⽀持计时（Countup）和倒计时（Countdown）两种模式.
    
     ```verilog
        module Counter(
        input clk,
        input rst,
        input enable,       //1'b1时启动，1‘b0时暂停
        input reverse,      //1'b1为正计时，1‘b0为倒计时
        input [31:0] start, //倒计时开始时间，正计时时可随便填写
        //时分秒分别传出
        output reg [6:0]seconds,
        output reg [6:0]minutes,
        output reg [5:0]hours
            );
     ```



### 3 Special thanks

感谢G神对此项目的大力帮助。
