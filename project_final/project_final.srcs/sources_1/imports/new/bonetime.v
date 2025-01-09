`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 12:21:46
// Design Name: 
// Module Name: bonetime
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


module bonetime(

    input clk,
    input x_in,
    output x_pos
    );
    
    //wire x_pos;
    reg x_d1,x_d2,x_d3;
    always@(posedge clk) begin
    x_d1<=x_in; //x_d1是x_in 延迟一个cycle周期
    x_d2<=x_d1; //x_d2是x_d1 延迟一个cycle周期
    x_d3<=x_d2; //x_d3是x_d1 延迟一个cycle周期
    end
    assign x_pos = x_d2 & ~x_d3; //信号的上一个状态是低电平，当前态是高电平，则表示x_in 出现了一个上升沿的变化

endmodule
