`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 19:21:06
// Design Name: 
// Module Name: on_off
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module on_off(
   clk,			//时钟信号100Mhz
   rst,            //按键复位
   key,            //用户按键
   out            
   );

//端口定义
   input clk;
   input rst;
   input key;
   
   output reg out;

   reg[31:0] count;    
   reg last_key; //旧扫描按键电平
   wire flag_up; //上升沿检测标志\\\\
   wire flag_down; //上升沿检测标志\\\\
   


/*
** 按键状态保存一个时钟周期    
*/
always @(posedge clk)
   begin
       last_key <= key;
   end

assign flag_up = (~last_key) & key;        //检测按键松的上升沿
assign flag_down = (~key) & last_key;        //检测按键松的下降沿


/*
**    count计数,测量按键按下时间长度
*/
always @(posedge clk or negedge rst)
   begin 
       if (!rst)
           count <= 32'd0;
       else if (key == 1)
           count <= count +1'b1;
       else if (flag_down == 1) begin
           count <= 32'd0;
       end    
   end
/*
**    根据按键按下时间的长短进行相应的动作
*/
always @(posedge clk or negedge rst) 
begin
       if (!rst)
           out <= 0;
   else if (count >= 32'd299_999_999)//3s
            out <= 1'b1;
   else if (count <= 32'd299_999_999)
            out <= 1'b0;             
   end
   
endmodule
