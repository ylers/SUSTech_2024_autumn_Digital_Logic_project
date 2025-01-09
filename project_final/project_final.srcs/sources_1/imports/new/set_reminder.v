`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/07 16:21:32
// Design Name: 
// Module Name: set_reminder
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


module set_reminder(
input              clk       ,
input              rst       ,
input [4:0]        mode      ,
input [7:0]        switch    ,
input [4:0]        bin       ,
input              init      ,
output reg [31:0] data
    );
    reg [6:0]seconds;
    reg [6:0]minutes;
    reg [5:0]hours;
    reg [1:0]who = 2'b00;
    
    
    always@(posedge clk) begin
    if(mode == 5'b00001 && switch==8'b0000_0100)
    begin
                    if(bin == 5'b00010)
                    begin
                        who = who + 1;
                        if(who == 3)
                        who = 0;
                        else
                        who = who;
                    end
    end
    else
        who = 0;
    end
   
    always @(posedge clk or negedge rst) begin
        if(!rst)
                begin
                seconds = 0;
                minutes = 0;
                hours = 10;
                end
        else if (init) begin
                begin
                        seconds = 0;
                        minutes = 0;
                        hours = 10;
                        end
        
        end else
        
           if(mode == 5'b00001 && switch==8'b0000_0100 && bin  == 5'b00001) 
           case(who)
                    2'd0: begin
                                   hours = hours+ 1;
                                   if(hours == 24)
                                   hours = 0;
                                   else
                                   hours = hours;
                                   end
                    2'd1: begin
                                   minutes = minutes + 1;
                                   if(minutes == 60)
                                   minutes = 0;
                                   else
                                   minutes = minutes;
                                   end
                    2'd2: begin
                                   seconds = seconds + 1;
                                   if(seconds == 60)
                                   seconds = 0;
                                   else
                                   seconds = seconds;
                                   end
                    default: seconds = seconds;
                    endcase
            else
            begin
            hours = hours;
            minutes = minutes;
            seconds = seconds;
            end



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
