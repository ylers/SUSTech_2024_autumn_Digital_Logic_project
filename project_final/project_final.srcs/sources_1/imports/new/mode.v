`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 18:31:49
// Design Name: 
// Module Name: mode
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


module mode(
input clk,
input rst,
input [4:0] bin,
input bin_o,
input [7:0] switch,
input on_off_gesture_open,
input on_off_gesture_close,
input signal,
input signal2,
input signal3,
output reg [4:0] modes,
output reg reset_after_clean
);

reg [4:0] next_mode;
reg onlyone,changeonlyone;//Third gear can only be used once

wire onoff_y;
on_off oo1(clk,rst,bin_o,onoff_y);
//bonetime botoo(clk,onoff_x,onoff_y);


parameter
S0 = 5'b00000,    //Power Off
S1 = 5'b00001,    //standby
//S2 = 5'b00010,  //Settings
//S3 = 5'b00011,  //inquire
S4 = 5'b00100,    //menu
S5 = 5'b00101,    //First gear
S6 = 5'b00110,    //Second gear
S7 = 5'b00111,    //Third gear
S8 = 5'b01000,    //self-cleaning
S9 = 5'b01001;    //Third gear return


always @ (posedge clk,negedge rst)begin
        if(~rst)begin
            modes <= S0;
            onlyone <= 1'b0;
        end else begin
            modes <= next_mode;
            onlyone <= changeonlyone;
        end
end


always @(*) begin
    case(modes)
        S0: begin
                if(bin[3]) next_mode = S1;
                else if(switch[4] && on_off_gesture_open) next_mode = S1;
                else next_mode = S0;
                changeonlyone =  1'b0;
                reset_after_clean = 1'b0;
                
            end
        S1:begin
                if(onoff_y) next_mode = S0;
                else if(switch[4] && on_off_gesture_close) next_mode = S0;
                //else if(switch == 8'b0 && bin[0]) next_mode <= S2;
                //else if(switch == 8'b0 && bin[1]) next_mode <= S3;
                else if(switch== 8'b0 && bin[4]) next_mode = S4;
                else next_mode = S1;
                //changeonlyone =  changeonlyone;
                if(~onlyone)
                    changeonlyone = 1'b0;
                else changeonlyone = 1'b1;
                reset_after_clean = 1'b0;
            end
//        S2:begin
//                if(onoff_y) next_mode <= S0;
//                else if(bin[4]) next_mode <= S1;
//                else next_mode <= S2;
//            end
//        S3:begin
//                if(onoff_y) next_mode <= S0;
//                else if(bin[4]) next_mode <= S1;
//                else next_mode <= S3;
//            end
        S4:begin
            
                if(onoff_y) next_mode = S0;
                else if(switch[4] && on_off_gesture_close) next_mode = S0;
                //else if(bin[4]) next_mode <= S1;
                else if(bin[0]) next_mode = S5;
                else if(bin[1]) next_mode = S6;
                else if(bin[2])begin
                    if(~onlyone)
                        next_mode = S7;
                    else next_mode = S4;
                end
                else if(bin[4]) next_mode = S8;
                else next_mode = S4;
                
                
                if(~onlyone)
                    changeonlyone = 1'b0;
                else changeonlyone = 1'b1;
                reset_after_clean = 1'b0;
            end
        S5:begin
                if(onoff_y) next_mode = S0;
                else if(switch[4] && on_off_gesture_close) next_mode = S0;
                else if(bin[4]) next_mode = S1;
                else if(bin[1]) next_mode = S6;
                else next_mode = S5;
                //changeonlyone =  changeonlyone;
                
                if(~onlyone)                
                    changeonlyone = 1'b0;   
                else changeonlyone = 1'b1;  
                reset_after_clean = 1'b0;
                
            end
        S6:begin
                if(onoff_y) next_mode = S0;
                else if(switch[4] && on_off_gesture_close) next_mode = S0;
                else if(bin[4]) next_mode = S1;
                else if(bin[0]) next_mode = S5;
                else next_mode = S6;
                //changeonlyone =  changeonlyone;
                
                if(~onlyone)                
                    changeonlyone = 1'b0;   
                else changeonlyone = 1'b1;
                reset_after_clean = 1'b0;  
                
            end
        S7:begin
                 
                 if(onoff_y) next_mode = S0;
                 else if(switch[4] && on_off_gesture_close) next_mode = S0;
                 else if(signal2) next_mode = S6;
                 else if(bin[4]) next_mode = S9;
                 else next_mode = S7;
                 changeonlyone = 1'b1;
                 reset_after_clean = 1'b0;
             end
         S8:begin
                if(onoff_y) next_mode = S0;
                else if(switch[4] && on_off_gesture_close) next_mode = S0;
                else if(signal)begin next_mode = S1; reset_after_clean = 1'b1; end
                else next_mode = S8;
                //changeonlyone =  changeonlyone;
                
                if(~onlyone)                
                    changeonlyone = 1'b0;   
                else changeonlyone = 1'b1;  
                
            end
         S9:begin
                if(onoff_y) next_mode = S0;
                else if(switch[4] && on_off_gesture_close) next_mode = S0;
                else if(signal3) next_mode = S1;
                else next_mode = S9;
                //changeonlyone =  changeonlyone;
                changeonlyone = 1'b1;
                reset_after_clean = 1'b0;
                
            end
         default:begin 
         next_mode = S1;//changeonlyone =  changeonlyone;
         if(~onlyone)                
              changeonlyone = 1'b0;   
          else changeonlyone = 1'b1;
          reset_after_clean = 1'b0;
          end
    endcase
end







endmodule
