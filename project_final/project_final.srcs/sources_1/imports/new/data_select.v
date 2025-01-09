`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 15:40:05
// Design Name: 
// Module Name: data_select
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


module data_select(
input            clk                 ,
input            rst                 ,
input [4:0]      modes               ,
input [7:0]      switch              ,
input [31:0]     data_clock          ,
input [31:0]     data_set_gt         ,
input [31:0]     data_set_r          ,
input [31:0]     data_time           ,
input [31:0]     data_cmc            ,
input [31:0]     data_three          ,
input [31:0]     data_three_return   ,
input [31:0]     data_bluetooth      ,
output reg[31:0] data_final
    );
   // reg [31:0] data_final_next;
    
    parameter
    S0 = 5'b00000, //�ػ�
    S1 = 5'b00001, //����
    S2 = 5'b00010, //����
    S3 = 5'b00011, //��ѯ
    S4 = 5'b00100, //�˵�
    S5 = 5'b00101, //һ��
    S6 = 5'b00110, //����
    S7 = 5'b00111, //����
    S8 = 5'b01000, //�����
    S9 = 5'b01001; //��������
/*    
always @(posedge clk, negedge rst)begin
    if(~rst)begin
        data_final = 0;
    end else begin
        data_final = data_final_next;
    end
end    
 */   
    
always @(*)begin
    case(modes)
        S0:data_final = 32'b0;
        S1:     if(switch[1])data_final = data_set_gt; 
                else if(switch[2])data_final = data_set_r; 
                else if(switch[3])data_final = data_time; 
                else if(switch[5])data_final = data_bluetooth; 
                else data_final = data_clock;
        //S2:data_final = 32'b0;//
        //S3:data_final = 32'b0;//
        S4:data_final = data_clock;
        S5:data_final = data_clock;
        S6:data_final = data_clock;
        S7:data_final = data_three;//��������ʱ
        S8:data_final = data_cmc;//����൹��ʱ
        S9:data_final = data_three_return;
        default: data_final = 32'b0;
    endcase
        
        
  
end





endmodule
