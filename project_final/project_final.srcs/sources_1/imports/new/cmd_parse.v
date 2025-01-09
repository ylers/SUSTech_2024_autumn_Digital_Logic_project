

`timescale 1ns/1ps


module cmd_parse(
  input             clk_rx,         // Clock input
  input             rst_clk_rx,     // Active HIGH reset - synchronous to clk_rx

  input      [7:0]  rx_data,        // Character to be parsed
  input             rx_data_rdy,    // Ready signal for rx_data
  // From Character FIFO
  input             char_fifo_full, // The char_fifo is full
  // To/From Response generator
  output reg        send_char_val,  // A character is ready to be sent
  output reg [7:0]  send_char,      // Character to be sent
  output reg        send_resp_val,  // A response is requested
  output reg [3:0]  send_resp_type, // Type of response - see localparams
  output reg [15:0] send_resp_data, // Data to be output
  input             send_resp_done, // The response generation is complete
  // to system
  input [4:0] currentMode, //当前的mode 用于'/D'指令显示

  output reg [6:0] TimeH, //设置显示时间 上限60
  output reg [6:0] TimeM, //设置显示时间
  output reg [6:0] TimeS, //设置显示时间

  // output [2:0] debug_state,    // 添加输出端口用于监控 state
  // output [4*11-1:0] debug_arg_val, // 添加输出端口用于监控 arg_val
  // output [3:0] debug_char,
  // output [6:0] debug_combine,
  // output [7:0] debug_arg_cnt,
  // output reg [6:0] cur_cmd,  // move to output for debug



  output reg [4:0] mode //change当前模式
);

/*
Command:
C int n     e.g. C 2 切换至模�?2
S 1/2 time 设置时间 1：智能提醒时�? 2：手势开关时�? 其中智能提醒的time为hh-mm-ss 手势�?关时间为ss

*/

//***************************************************************************
// Parameter definitions
//***************************************************************************
  parameter MAX_ARG_CH   = 11;    // Number of characters in largest set of args


  localparam [3:0]
     RESP_OK    = 4'b0000,
     RESP_ERR   = 4'b0001,
     RESP_wind1 = 4'b0010,
     RESP_wind2 = 4'b0011,
     RESP_wind3 = 4'b0100,
     RESP_clean = 4'b0101,
     RESP_await = 4'b0110,
     RESP_close = 4'b0111,
      RESP_menuu = 4'b1000,
      RESP_other = 4'b1001,
      S0 = 5'b00000, //关机  
      S1 = 5'b00001, //待机  
      S4 = 5'b00100, //菜单  
      S5 = 5'b00101, //�?�?  
      S6 = 5'b00110, //二档  
      S7 = 5'b00111, //三档  
      S8 = 5'b01000, //自清�? 
      S9 = 5'b01001; //三档返回

    

  // States for the main state machine
  localparam
     IDLE      = 3'b000,
     CMD_WAIT  = 3'b001,
     GET_ARG   = 3'b010,
     SEND_RESP = 3'b011;

   localparam
      CMD_C     = 7'h43, //change mode
      CMD_S     = 7'h53, //set argument
     CMD_D     = 7'h44; //display current mode




  // `include "clogb2.txt"
//***************************************************************************
// Reg declarations
//***************************************************************************
  reg [2:0]         state;    // State variable
  reg               old_rx_data_rdy; // rx_data_rdy on previous clock
  reg [6:0]         cur_cmd;  // Current cmd - least 7 significant bits of char
  reg [4*MAX_ARG_CH-5:0]        arg_sav;  // All but last char of args 
  reg [clogb2(MAX_ARG_CH)-1:0]  arg_cnt;  // Count the #chars in an argument
  integer insertIndex = 0;

//***************************************************************************
// Wire declarations
//***************************************************************************

  // Accept a new character when one is available, and we can push it into
  // the response FIFO. A new character is available on the FIRST clock that
  // rx_data_rdy is asserted - it remains asserted for 1/16th of a bit period.
  wire new_char = rx_data_rdy && !old_rx_data_rdy && !char_fifo_full; 

  
//***************************************************************************
// Tasks and Functions
//***************************************************************************

  // This function takes the lower 7 bits of a character and converts them
  // to a hex digit. It returns 5 bits - the upper bit is set if the character
  // is not a valid hex digit (i.e. is not 0-9,a-f, A-F), and the remaining
  // 4 bits are the digit
function [4:0] to_val;
    input [6:0] char;
begin
    if ((char >= 7'h30) && (char <= 7'h39)) // 0-9
    begin
        to_val[4]   = 1'b0;
        to_val[3:0] = char[3:0];
    end
    else if (((char >= 7'h41) && (char <= 7'h46)) || // A-F
             ((char >= 7'h61) && (char <= 7'h66)) )  // a-f
    begin
        to_val[4]   = 1'b0;
        to_val[3:0] = char[3:0] + 4'h9; // gives 10 - 15
    end
    else if (char == 7'h20 || char == 7'h2D) // space and '-'
    begin
        to_val[4]   = 1'b0;
        to_val[3:0] = 4'h0;  // You can decide to map space to a value like 0
    end
    else 
    begin
        to_val      = 5'b1_0000; // Invalid character
    end
end
endfunction

function integer clogb2;
    input [31:0] value;
    reg   [31:0] my_val;
    begin
      my_val = value - 1;
      for (clogb2 = 0; my_val > 0; clogb2 = clogb2 + 1)
        my_val = my_val >> 1;
    end
endfunction




//  将两�?4位宽的二进制数拼接成原来十进制数的二进制表示
function [6:0] combine_digits;
    input [3:0] tens;  // 十位�?4位二进制�?
    input [3:0] ones;  // 个位�?4位二进制�?
    reg [6:0] tens_part; // 存储十位部分
begin
    // 十位�?10
    tens_part = (tens << 3) + (tens << 1); // tens * 10 = (tens * 8) + (tens * 2)
    
    // 拼接十位和个位，返回结果
    combine_digits = tens_part + ones;
end
endfunction



//***************************************************************************
// Code
//***************************************************************************
  // capture the rx_data_rdy for edge detection
  always @(posedge clk_rx)
  begin
    if (rst_clk_rx)
    begin
      old_rx_data_rdy <= 1'b0;
    end
    else
    begin
      old_rx_data_rdy <= rx_data_rdy;
    end
  end
  // Echo the incoming character to the output, if there is room in the FIFO
  always @(posedge clk_rx)
  begin
    if (rst_clk_rx)
    begin
      send_char_val <= 1'b0;
      send_char     <= 8'h00;
    end
    else if (new_char)
    begin
      send_char_val <= 1'b1;
      send_char     <= rx_data;
    end // if !rst and new_char
    else
    begin
      send_char_val <= 1'b0;
    end
  end // always

  // For each character that is potentially part of an argument, we need to 
  // check that it is in the HEX range, and then figure out what the value is.
  // This is done using the function to_val
  wire [4:0]  char_to_digit = to_val(rx_data);
  wire        char_is_digit = !char_to_digit[4];

  // Assuming it is a value, the new digit is the least significant digit of
  // those that have already come in - thus we need to concatenate the new 4
  // bits to the right of the existing data
  reg [4*MAX_ARG_CH-1:0] arg_val;

  always @(posedge clk_rx)
  begin
    if (rst_clk_rx)
    begin
      state             <= IDLE;
      cur_cmd           <= 7'h00;
      arg_sav           <= 28'b0;
      arg_cnt           <= 3'b0;
      send_resp_val     <= 1'b0;
      send_resp_type    <= RESP_ERR;
      send_resp_data    <= 16'h0000;
      arg_val <= 4*MAX_ARG_CH-1'b0;


    TimeH <= 7'b0;
    TimeM <= 7'b0;
    TimeS <= 7'b0;
    mode <= 5'b0;
    end
    else
    begin
                            TimeH <= combine_digits(arg_val[15:12],arg_val[19:16]);
                            TimeM <= combine_digits(arg_val[27:24],arg_val[31:28]);
                            TimeS <= combine_digits(arg_val[39:36],arg_val[43:40]);
                            mode <= {1'b0,arg_val[7:4]}; 

      // Defaults - overridden in the appropriate state
      case (state)

        IDLE: begin // Wait for the '/'
          if (new_char && (rx_data[6:0] == 7'h2F))
          begin
            state <= CMD_WAIT;
          end // if found '/'
        end // state IDLE

        CMD_WAIT: begin // Validate the incoming command
          if (new_char)
          begin
            cur_cmd <= rx_data[7:0];
            case (rx_data[6:0])
  
              CMD_C: begin 
                state   <= GET_ARG;
                arg_cnt <= 3'd1;
              end 
  
              CMD_S: begin 
                state   <= GET_ARG;
                arg_cnt <= 5'd11;
              end  

              CMD_D: begin 
                state   <= GET_ARG;
                arg_cnt <= 3'd0;
              end             
  
              default: begin
                send_resp_val  <= 1'b1;
                send_resp_type <= RESP_ERR;
                state          <= SEND_RESP;
              end // default
            endcase // current character case

            insertIndex <= 0;
          end // if new character has arrived
        end // state CMD_WAIT
        
        GET_ARG: begin
          // Get the correct number of characters of argument. Check that
          // all characters are legel HEX values.
          // Once the last character is successfully received, take action
          // based on what the current command is
          if (new_char)
          begin
            if (!char_is_digit)
            begin
              // Send an error response
              send_resp_val  <= 1'b1;
              send_resp_type <= RESP_ERR;
              state          <= SEND_RESP;
            end
            else // character IS a digit
            begin
              if (arg_cnt != 0) // This is NOT the last char of arg
              begin


                    arg_val[insertIndex +: 4] <= char_to_digit[3:0];
                    insertIndex <= insertIndex + 4;

                // Wait for the next character
                arg_cnt <= arg_cnt - 1'b1;
              end // Not last char of arg
              else // This IS the last character of the argument - process
              begin
                case (cur_cmd) 
                  CMD_C: begin
                      mode <= {1'b0,arg_val[7:4]}; 
					          // Send OK
                      send_resp_val     <= 1'b1;
                      send_resp_type    <= RESP_OK;
                      state             <= SEND_RESP;
                  end 

                  CMD_S: begin
                    /*
                    example : input : S 1 11-45-14

                                  1                   1                     1               4           5            1        4
                    */
                    //arg[7:4] 第一个参�? 1/2  [15:12] 第一个数�? [19:16] 第二个数 [27:24] no.3 [31:28] no.4 [39:36] no.5 [43:40] no.6



                        /*
                        
                        Have bug, can't work
                        
                        */

                        // case (arg_val[7:4]) 
                        //   4'b0001 :   begin 
                        //     TimeH <= combine_digits(arg_val[15:12],arg_val[19:16]);
                        //     TimeM <= combine_digits(arg_val[27:24],arg_val[31:28]);
                        //     TimeS <= combine_digits(arg_val[39:36],arg_val[43:40]);
                        //    end
                        //   4'b0010 : begin
                        //     TimeS <= combine_digits(arg_val[39:36],arg_val[43:40]);
                        //     end

                        //   default: begin 
                        //     TimeH <= 7'b0;
                        //     TimeM <= 7'b0;
                        //     TimeS <= 7'b0;

                        //   end
                        // endcase
                        


                      // Send OK
                      send_resp_val  <= 1'b1;
                      send_resp_type <= RESP_OK;
                      state          <= SEND_RESP;
                  end 

                  CMD_D: begin
                      send_resp_val  <= 1'b1;
                      case (currentMode)
                          S0: send_resp_type <= RESP_close;  // 关机
                          S1: send_resp_type <= RESP_await;  // 待机
                          S4: send_resp_type <= RESP_menuu;  // 菜单
                          S5: send_resp_type <= RESP_wind1;  // �?�?
                          S6: send_resp_type <= RESP_wind2;  // 二档
                          S7: send_resp_type <= RESP_wind3;  // 三档
                          S8: send_resp_type <= RESP_clean;  // 自清�?
                          S9: send_resp_type <= RESP_wind3;  // 三档返回
                          default: send_resp_type <= RESP_other;  // 默认错误
                      endcase
                      state          <= SEND_RESP;
                  end 



                endcase
              end // received last char of arg
            end // if the char is a valid HEX digit
          end // if new_char
        end // state GET_ARG

        SEND_RESP: begin
          // The response request has already been sent - all we need to
          // do is keep the request asserted until the response is complete.
          // Once it is complete, we return to IDLE
          if (send_resp_done)
          begin
            send_resp_val <= 1'b0;
            state         <= IDLE;
          end
        end // state SEND_RESP

        default: begin
          state <= IDLE;
        end // state default

      endcase
    end // if !rst
  end // always



// assign debug_state = state;
// assign debug_arg_val = arg_val;
// assign debug_char = {1'b0,char_to_digit[3:0]};
// assign debug_combine = combine_digits(arg_val[15:12],arg_val[19:16]);
// assign debug_arg_cnt = arg_cnt;




endmodule
