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
   clk,			//ʱ���ź�100Mhz
   rst,            //������λ
   key,            //�û�����
   out            
   );

//�˿ڶ���
   input clk;
   input rst;
   input key;
   
   output reg out;

   reg[31:0] count;    
   reg last_key; //��ɨ�谴����ƽ
   wire flag_up; //�����ؼ���־\\\\
   wire flag_down; //�����ؼ���־\\\\
   


/*
** ����״̬����һ��ʱ������    
*/
always @(posedge clk)
   begin
       last_key <= key;
   end

assign flag_up = (~last_key) & key;        //��ⰴ���ɵ�������
assign flag_down = (~key) & last_key;        //��ⰴ���ɵ��½���


/*
**    count����,������������ʱ�䳤��
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
**    ���ݰ�������ʱ��ĳ��̽�����Ӧ�Ķ���
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
