`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 19:13:27
// Design Name: 
// Module Name: clock
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


module clock(
    input              clk      ,
    input              rst      ,
    input [4:0]        mode     ,
    input [7:0]        switch   ,
    input [4:0]        bin      ,
    output reg [31:0] data
    
    );
    //没用Counter模块，因为不好实现设置时间
    integer timer_cnt;
    //reg state=1'b0;
    reg [6:0]seconds;
    reg [6:0]minutes;
    reg [5:0]hours;
    reg [1:0]who = 2'b00;

    
    
    
    always@(posedge clk) begin
    if(mode == 5'b00001 && switch == 8'b0000_0001)
    begin
                    if(bin[1])
                    begin
                        who = who + 1;
                        if(who == 3)
                        who = 0;
                        else
                        who = who;
                    end
    end
    else
        who <= 0;
    end
    
    
    
    
    
    
    
    
   
    always @(posedge clk or negedge rst) begin
        if(!rst)
                                            begin
                                            timer_cnt = 0;
                                            seconds = 0;
                                            minutes = 0;
                                            hours = 0;
                                            end
        else if(mode==5'b00000)begin
                                                        timer_cnt = 0;
                                                        seconds = 0;
                                                        minutes = 0;
                                                        hours = 0;
                                                    end
        else if(timer_cnt>=100_000_000) begin
        
                                            
                                            if(mode != 5'b00001 || ~switch[0])begin
                                                timer_cnt=0;
                                                if(seconds>=59)     
                                                    begin
                                                    seconds=0;
                                                    if(minutes>=59)     
                                                        begin
                                                        minutes=0;
                                                        if(hours>=23)     
                                                            begin
                                                            hours=0;
                                                            end
                                                        else    hours=hours+1;
                                                        end
                                                    else    minutes=minutes+1;
                                                    end
                                                else    seconds=seconds+1;
         end else begin
         
                                                 if(bin  == 5'b00001) //进入时间调制状态
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
            
            
            
            
            
            
       end else    timer_cnt <= timer_cnt+1;
     end


    //reg [31:0] data;
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
    

//show_number u1(  .clk(clk),
//                .rst(rst),
//                .data(data),
//                .seg_data(seg_data),
//                .seg_data2(seg_data2),
//                .seg_cs(seg_cs)
//            );

endmodule