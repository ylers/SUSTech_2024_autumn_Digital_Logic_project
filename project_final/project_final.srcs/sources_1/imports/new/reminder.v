`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/07 17:21:14
// Design Name: 
// Module Name: reminder
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


module reminder(
    input               clk                  ,
    input               rst                  ,
    input [4:0]         mode                 ,
    input [7:0]         switch               ,
    input               auto_clean_reset     ,//Clear zero for 1'b1
    input               hand_clean_reset     ,//Clear zero for 1'b1
    input [4:0]         bin                  ,
    input [31:0]        data_set_r           ,
    input [31:0]        data_bluetooth       ,
    output reg          reminder_led         ,
    output reg [31:0]   data_time
    );
    
    
    
    integer timer_cnt;
    reg [6:0]seconds;
    reg [6:0]minutes;
    reg [5:0]hours;
    
    //select data
    reg [31:0] data_final;
    always @(*) begin
        if(switch[5])begin
            data_final = data_bluetooth;
        end else begin
            data_final = data_set_r;
        end
    
    
    end
    //||mode==5'b00000
    always @(posedge clk or negedge rst) begin
            if(!rst || auto_clean_reset || hand_clean_reset)
                begin
                timer_cnt <= 0;
                seconds <= 0;
                minutes <= 0;
                hours <= 0;
                end
            else if(timer_cnt>=100_000_000) begin
                        
                        
                        if(mode != 5'b00001 || ~switch[0])begin
                            timer_cnt<=0;
                            if(seconds>=59)     
                                begin
                                seconds<=0;
                                if(minutes>=59)     
                                    begin
                                    minutes<=0;
                                    if(hours>=23)     
                                        begin
                                        hours<=0;
                                        end
                                    else    hours<=hours+1;
                                    end
                                else    minutes<=minutes+1;
                                end
                            else    seconds<=seconds+1;
                         end
             end  
             else if(mode==5'b00101 ||mode==5'b00110 || mode==5'b00111|| mode==5'b01001)timer_cnt <= timer_cnt+1;
             else    timer_cnt <= timer_cnt;
                
     end
     
     
     always @(*)begin
        if(mode==5'b00001)begin
            if(data_time>=data_final)begin
                    reminder_led = 1'b1;
            end else reminder_led = 1'b0; 
        end else reminder_led = reminder_led;
     end
     
     
     
     always @(*) begin
             data_time[31:28] = hours/10;
             data_time[27:24] = hours%10;
             data_time[23:20] = 04'hf;
             data_time[19:16] = minutes/10;
             data_time[15:12] = minutes%10;
             data_time[11:8]  = 04'hf;
             data_time[7:4]   = seconds/10;
             data_time[3:0]   = seconds%10;
         end
     
     
    
endmodule
