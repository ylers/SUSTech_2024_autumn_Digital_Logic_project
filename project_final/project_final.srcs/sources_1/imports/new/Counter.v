`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 19:24:51
// Design Name: 
// Module Name: Counter
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

/*
It can be Countup and Countdown, 
reverse=1 'b1 when Countdown, enter start, 
reverse=1' b0 when Countup, start is whatever you want.

*/
module Counter(
input clk,
input rst,
input enable,
input reverse,//
input [31:0] start,
output reg [6:0]seconds,
output reg [6:0]minutes,
output reg [5:0]hours
    );
     integer timer_cnt;  
      always @(posedge clk or negedge rst) begin
            
      if(!rst)
       
      begin
                                if(reverse)begin
                                timer_cnt <= 0;
                                seconds <= start % 60;
                                minutes <= (start / 60) % 60;
                                hours <= (start / 3600) % 24;
                                end else begin
                                timer_cnt <= 0;
                                seconds <= 0;
                                minutes <= 0;
                                hours <= 0;

                                 end
       end
     else if(timer_cnt>=100_000_000)
     begin
                if(reverse)begin
                                               timer_cnt<=0;
                                             if(seconds<=0)begin
                                                   seconds<=59;
                                                   if(minutes<=0)begin
                                                         minutes<=59;
                                                         if(hours<=0)begin
                                                                seconds <= start % 60;        
                                                                minutes <= (start / 60) % 60; 
                                                                hours <= (start / 3600) % 24; 
                                                         end else    hours<=hours-1;
                                                   end else    minutes<=minutes-1;
                                             end else    seconds<=seconds-1;
                                             
                  
                  end else begin  
                                                    timer_cnt<=0;
                                                     if(seconds>=59)begin
                                                            seconds<=0;
                                                            if(minutes>=59)begin
                                                                 minutes<=0;
                                                                 if(hours>=23)begin
                                                                     hours<=0;
                                                                 end else    hours<=hours+1;
                                                             end else    minutes<=minutes+1;
                                                     end else    seconds<=seconds+1;
                  end
                  
                  
     end
                  
                
       
                
                
                
       else    timer_cnt <= timer_cnt+1;
            
            
            
        end
        
        


    
    
    
    
endmodule