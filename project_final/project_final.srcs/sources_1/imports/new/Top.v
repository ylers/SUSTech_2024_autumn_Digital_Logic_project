`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 18:31:31
// Design Name: 
// Module Name: Top
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


module Top(
input clk,
input rst,
input [4:0] butten,
input [7:0] switch,
input init,
/*
0,               1,                       2,
Set the clock    Set gesture switch      Set a ceiling
3,               4,                         5, 
Running time    Turn on gesture switch   enable bluetooth time
6,                  7,
Manual cleaning    led light
*/
output light,
output reminder_led,
output [7:0] tub_control,
output [7:0] seg1,
output [7:0] seg2,
//output reg [7:0] mode_led 
output [4:0] modes,
//////////////////////////
input rst_pin,
// RS232 signals
input            rxd_pin,        // RS232 RXD pin
output           txd_pin,        // RS232 RXD pin
// Loopback selector
input            lb_sel_pin,     // Loopback selector 
//BT 
output bt_pw_on,
output bt_master_slave,
output bt_sw_hw,
output bt_rst_n,
output bt_sw,
input  sw_pin,

///////////////////////////

output t,
output music
//////////////////////////////
    );

//reg [4:0] modes;
wire [4:0]bin;
wire [4:0]bin_d;
wire [31:0] data_clock,data_set_gt,data_set_r,data_time,data_cmc,data_three,data_three_return,data_bluetooth;
wire [31:0] data_final;
wire on_off_gesture_open,on_off_gesture_close;
wire [3:0] gesture_time;
wire signal,signal2,signal3;
wire reset_after_clean;


debounce d0(clk,1'b1,butten[0],bin_d[0]);
debounce d1(clk,1'b1,butten[1],bin_d[1]);
debounce d2(clk,1'b1,butten[2],bin_d[2]);
debounce d3(clk,1'b1,butten[3],bin_d[3]);
debounce d4(clk,1'b1,butten[4],bin_d[4]);

bonetime bot0(clk,bin_d[0],bin[0]);
bonetime bot1(clk,bin_d[1],bin[1]);
bonetime bot2(clk,bin_d[2],bin[2]);
bonetime bot3(clk,bin_d[3],bin[3]);
bonetime bot4(clk,bin_d[4],bin[4]);


mode mode0(
.clk                 (clk)                 ,
.rst                 (rst)                 , 
.bin                 (bin)                 ,
.bin_o               (butten[3])           , 
.switch              (switch)              ,
.on_off_gesture_open (on_off_gesture_open) , 
.on_off_gesture_close(on_off_gesture_close), 
.signal              (signal)              ,
.signal2             (signal2)             ,
.signal3             (signal3)             ,
.modes               (modes)               ,
.reset_after_clean   (reset_after_clean)         
);

gesture_control_off gesture_control_off0(
.clk           (clk                 )           ,           // Clock signal
.reset         (rst                 )           ,
.button1       (bin[2]              )           ,       // Button 1 input
.button2       (bin[0]              )           ,       // Button 2 input
.modes         (modes               )           ,
.gesture_time  (gesture_time        )           ,
.on            (on_off_gesture_close)           // Output signal
);


gesture_control_on gesture_control_on0(
.clk          (clk                )            ,           // Clock signal
.reset        (rst                )            ,
.button1      (bin[0]             )            ,       // Button 1 input
.button2      (bin[2]             )            ,       // Button 2 input
.modes        (modes              )            ,
.gesture_time (gesture_time       )            ,
.on           (on_off_gesture_open)          // Output signal
);



clock clock0(
.clk     ( clk         ) ,
.rst     ( rst         ) ,
.mode    ( modes       ) ,
.switch  ( switch      ) ,
.bin     ( bin         ) ,
.data    ( data_clock  )
);
   

data_select data_select0(
.clk               (clk                        ) ,
.rst               (rst                        ) ,
.modes             (modes                      ) ,
.switch            (switch                     ) ,
.data_clock        (data_clock                 ) ,
.data_set_gt       (data_set_gt                ) ,
.data_set_r        (data_set_r                 ) ,
.data_time         (data_time                  ) ,
.data_cmc          (data_cmc                   ) ,
.data_three        (data_three                 ) ,
.data_three_return (data_three_return          ) ,
.data_bluetooth    (data_bluetooth             ) ,
.data_final        (data_final                 )
); 


show_number show_number0(
.clk       (clk          )          ,
.rst       (rst          )          ,
.data      (data_final   )          ,
.seg_data  (seg1         )          ,
.seg_data2 (seg2         )          ,
.seg_cs    (tub_control  )
);




  
   
set_gesture_time set_gesture_time0(
.clk     (clk                                     )         ,
.reset   (rst                                     )         ,
.mode    (modes                                   )         ,
.switch  (switch                                  )         ,
.enable  (1'b1                                    )         ,
.addition(bin[0]                                  )         ,
.init    (modes==5'b00001 && init && bin[1]       )         ,
.data    (data_set_gt                             )         ,
.count   (gesture_time                            )
);   


set_reminder set_reminder0(
. clk   (clk                                      )          ,
. rst   (rst                                      )          ,
. mode  (modes                                    )          ,
. switch(switch                                   )          ,
. bin   (bin                                      )          ,
.init   (modes==5'b00001 && init && bin[1]        )          ,
.data   (data_set_r                               )
);


   
   

  
reminder reminder0(
.clk             (clk                )     ,
.rst             (rst                )     ,
.mode            (modes              )     ,
.switch          (switch             )     ,
.auto_clean_reset(reset_after_clean  )     ,
.hand_clean_reset(switch[6]          )     ,
.bin             (bin                )     ,
.data_set_r      (data_set_r         )     ,
.data_bluetooth  (data_bluetooth     )     ,
.reminder_led    (reminder_led       )     ,
.data_time       (data_time          )
    );
      


clean_mode_counter clean_mode_counter0(
.clk   (clk       )          ,
.rst   (rst       )          ,
.mode  (modes     )          ,
.signal(signal    )          ,
.data  (data_cmc  )
    );
    
    
three_Counter three_Counter0(
.clk    (clk          )           ,
.rst    (rst          )           ,
.mode   (modes        )           ,
.signal (signal2      )           ,
.data   (data_three   )
    );
    
three_return_Counter three_return_Counter0(
.clk   (clk                )       ,
.rst   (rst                )       ,
.mode  (modes              )       ,
.signal(signal3            )       ,
.data  (data_three_return  )
    );

 


bluetooth bluetooth0(
clk                      ,      // Clock input (from pin)
rst_pin                  ,        // Active HIGH reset (from pin)
//sw,
rxd_pin                  ,        // RS232 RXD pin
txd_pin                  ,        // RS232 RXD pin
  // Loopback selector
lb_sel_pin               ,     // Loopback selector 
 //BT 
bt_pw_on                 ,
bt_master_slave          ,
bt_sw_hw                 ,
bt_rst_n                 ,
bt_sw                    ,
{2'b01,(modes!=5'b00000 && sw_pin),2'b11}     ,// ON-OFF
modes                    ,    
data_bluetooth
);
    
audio audio(
.clk(clk),
.mode(modes),
.music(music)
);


assign t =0;
assign light = (modes!=5'b00000 ) && switch[7];    


  
endmodule
