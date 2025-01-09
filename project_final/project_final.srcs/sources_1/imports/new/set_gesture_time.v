`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/07 16:29:32
// Design Name: 
// Module Name: set_gesture_time
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


module set_gesture_time(
input             clk         ,
input             reset       ,
input [4:0]       mode        ,
input [7:0]       switch      ,
input             enable      ,
input             addition    ,
input             init        ,
output reg [31:0] data        ,
output reg [3:0]  count
);


reg addition_prev;  // For detecting rising edge of 'addition'

// Debounce logic
//reg [3:0] debounce_count;   // Counter to track debounce stability
//wire addition_stable;       // Stable version of the addition signal

// Controls display for second digit
//assign tubsel1 = 1;
//assign tubsel2 = 1;

// Debounce logic


always @(posedge clk or negedge reset) begin
    if (!reset || init) begin
        count <= 4'b0101;           // Reset the count to 5
         
    end else if (enable) begin
        // Detect rising edge of debounced 'addition'
        if (mode==5'b00001 && switch==8'b0000_0010 && addition) begin
            if (count == 4'b1111) begin
                count <= 4'b0;    // Reset count when it reaches 15 (4'b1111)
            end else begin
                count <= count + 1; // Increment count
            end
        end
        
    end
end


reg [31:0] hours ,counting,minutes,seconds;
    always @(*) begin
        hours   = count / 3600;
        counting = count % 3600;
        minutes = counting / 60;
        seconds = counting % 60;
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

