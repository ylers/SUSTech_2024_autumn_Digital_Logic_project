`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 09:52:01
// Design Name: 
// Module Name: three_Counter
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


module three_Counter(
input              clk              ,
input              rst              ,
input [4:0]        mode             ,
output reg         signal           ,
output reg [31:0]  data 
    );
    parameter [31:0] START_TIME=12;
    parameter NOW_MODE = 5'b00111;
    wire [6:0]seconds;
    wire [6:0]minutes;
    wire [5:0]hours;
    reg rst_signal,enable;
Counter c2(
clk,
rst_signal,
enable,
1'b1,
START_TIME,
seconds,
minutes,
hours
        );
    always @(posedge clk,negedge rst)begin
        if(~rst || mode!=NOW_MODE)begin
            rst_signal = 1'b0;
            enable = 1'b0;
        end else begin
            rst_signal = 1'b1;
            enable = 1'b1;
        end
    end
        
     always @(*) begin
        if(hours==0&&minutes==0&&seconds==0)begin
            signal = 1'b1;
        end else 
            signal = 1'b0;
     end
    
    
    
    always @(*) begin
             data[31:28] = hours/10;
             data[27:24] = hours%10;
             data[23:20] = 04'hf;
             data[19:16] = minutes/10;
             data[15:12] = minutes%10;
             data[11:8]  = 04'hf;
             data[7:4]   = seconds/10;
             data[3:0]   = seconds%10;
         end
    
    
    
    
    
endmodule
