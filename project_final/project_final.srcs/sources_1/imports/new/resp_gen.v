//-----------------------------------------------------------------------------
//  
//  Copyright (c) 2009 Xilinx Inc.
//
//  Project  : Programmable Wave Generator
//  Module   : resp_parse.v
//  Parent   : wave_gen.v
//  Children : to_dec.v
//
//  Description: 
//     This module is responsible for pushing data into the character FIFO to
//     send to the user over the serial link.
//     There are two interfaces from the command parser to this module. The
//     first is the one that echoes received characters back to the user
//     (giving full duplex communication) - every character received while the
//     character FIFO is not full is simply pushed into the FIFO.
//     The second is the generation of the response string when a command (or
//     error) is entered. There are 3 types of responses
//       - The error response (normally "-ERR\n")
//       - The OK response (normally "-OK\n")
//       - The data response the '-' followed by 4 hex digits, a space, and 5
//         decimal digits, then the \n
//
//  Parameters:
//
//  Local Parameters:
//     RESP_TYPE_*: Values for the different response types
//                  Must correspond to those defined in cmd_parse
//
//  Notes       : 
//     The end of line will be terminated with both a CR/LF. This is a 
//     change, and will allow the terminal program to not do translation
//
//  Multicycle and False Paths
//     The submodule "to_dec.v" contains a 5 cycle MCP
//

`timescale 1ns/1ps


module resp_gen (
  input             clk_rx,         // Clock input
  input             rst_clk_rx,     // Active HIGH reset - synchronous to clk_rx

  // From Character FIFO
  input             char_fifo_full, // The char_fifo is full
  // To/From the Command Parser
  input             send_char_val,  // A character is ready to be sent
  input      [7:0]  send_char,      // Character to be sent
  input displayMode,


  input             send_resp_val,  // A response is requested
  input      [3:0]  send_resp_type, // Type of response - see localparams
  input      [15:0] send_resp_data, // Data to be output

  output reg        send_resp_done, // The response generation is complete

  input [4:0] mode,


  // To character FIFO
  output reg [7:0]  char_fifo_din,  // Character to push into the FIFO
                                    // char_fifo_din is NOT from a flop
  output            char_fifo_wr_en // Write enable (push) for the FIFO
);


//***************************************************************************
// Parameter definitions
//***************************************************************************

  `include "clogb2.txt"

  function [31:0] max;
    input [31:0] a;
    input [31:0] b;
  begin
    max = (a > b) ? a : b;
  end
  endfunction

  function [7:0] to_digit;
    input [3:0] val;
  begin
    if (val < 4'd10)
      to_digit = 8'h30 + val; // 8'h30 is the character '0'
    else
      to_digit = 8'h57 + val; // 8'h57 + 10 is 8'h61 - the character 'a' 
  end
  endfunction

//***************************************************************************
// Parameter definitions
//***************************************************************************

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
      RESP_other = 4'b1001;

  localparam
    STR_OK_LEN   = 5,  // -OK\n
    STR_ERR_LEN  = 6,  // -ERR\n
    STR_DATA_LEN = 13, // -HHHH DDDDD\n
    STR_CURRENTSTATE_LEN = 21, // CURRENT STATE-Wind1\n


    STR_STATE_LEN = 7; //  wind1\n


  localparam STR_LEN = 21;

  localparam CNT_WID = clogb2(STR_LEN);   // Must hold 0 to STR_LEN-1

  localparam LEN_WID = clogb2(STR_LEN+1); // Must hold the value STR_LEN

  localparam
    IDLE    = 1'b0,
    SENDING = 1'b1;
   
//***************************************************************************
// Reg declarations
//***************************************************************************

  reg               state;    // State variable
  reg [CNT_WID-1:0] char_cnt; // Current character being sent

//***************************************************************************
// Wire declarations
//***************************************************************************

  // From to_dec
  wire [5*4-1-1:0]     bcd_out;         // Most significant digit can
                                        // only go from 0 to 6, hence
                                        // only needs 3 bits

  wire [LEN_WID-1:0]   str_to_send_len; // The length of the string to be sent

//***************************************************************************
// Tasks and Functions
//***************************************************************************


//***************************************************************************
// Code
//***************************************************************************

  // Instantiate the Binary Coded Decimal converter

  to_bcd to_bcd_i0 (
    .clk_rx     (clk_rx),
    .rst_clk_rx (rst_clk_rx),
    .value_val  (send_resp_val && (send_resp_type == RESP_DATA)),
        // .value_val  (send_resp_val && ((send_resp_type == RESP_STATE) || (send_resp_type == RESP_CURRENT))),
    .value      (send_resp_data),
    .bcd_out    (bcd_out)
  );


  assign str_to_send_len = (send_resp_type == RESP_OK)  ? STR_OK_LEN  :
                           (send_resp_type == RESP_ERR) ? STR_ERR_LEN :  STR_CURRENTSTATE_LEN ;

  // Echo the incoming character to the output, if there is room in the FIFO
  always @(posedge clk_rx)
  begin
    if (rst_clk_rx)
    begin
      state           <= IDLE;
      char_cnt        <= 0;
      send_resp_done  <= 1'b0;
    end
    else if (state == IDLE)
    begin
      send_resp_done <= 1'b0;
      // Make sure not to re-trigger while we are waiting for the 
      // send_resp_done to affect the send_resp_val. In other words,
      // never respond to a send_resp_val if send_resp_done is being sent
      if (send_resp_val && !send_resp_done)  // A new response is requested
      begin
        state    <= SENDING;
        char_cnt <= 0;
      end
    end 
    else // Not in IDLE state
    begin // So are in sending state
      if (!char_fifo_full)
      begin
        // We will send a character this clock
        if (char_cnt == (str_to_send_len - 1'b1)) 
        begin
          // This will be the last one
          state          <= IDLE; // Return to IDLE
          send_resp_done <= 1'b1; // Signal cmd_parse that we are done
        end
        else
        begin
          char_cnt <= char_cnt + 1'b1;
        end
      end // if !char_fifo_full
    end // if STATE
  end // always

  assign char_fifo_wr_en = 
            ((state == IDLE) && send_char_val) ||
            ((state == SENDING) && !char_fifo_full) ;

  // Generate the DATA to the FIFO
  // If idle, the only thing we can be sending is the send_char
  // If in the SENDING state, it depends on the send_resp_type, and where
  // we are in the sequence
  always @(*)
  begin
    if (state == IDLE)
    begin
      char_fifo_din = send_char;
    end
    else
    begin
      if (send_resp_type == RESP_OK) 
      begin
        case (char_cnt) // synthesis full_case
          0 : char_fifo_din = "-"; // Dash
          1 : char_fifo_din = "O";
          2 : char_fifo_din = "K";
          3 : char_fifo_din = 8'h0d; // Newline
          4 : char_fifo_din = 8'h0a; // LineFeed
        endcase
      end
      else if (send_resp_type == RESP_ERR)
      begin
        case (char_cnt) // synthesis full_case
          0 : char_fifo_din = "-"; // Dash
          1 : char_fifo_din = "E";
          2 : char_fifo_din = "R";
          3 : char_fifo_din = "R";
          4 : char_fifo_din = 8'h0d; // Newline
          5 : char_fifo_din = 8'h0a; // LineFeed
        endcase
      end
    //   else if (send_resp_type == RESP_DATA)// It is RESP_DATA
    //   begin
    //     case(char_cnt) // synthesis full_case
    //       0 : char_fifo_din = "-"; // Dash
    //       1 : char_fifo_din = to_digit(send_resp_data[15:12]);
    //       2 : char_fifo_din = to_digit(send_resp_data[11:8 ]);
    //       3 : char_fifo_din = to_digit(send_resp_data[ 7:4 ]);
    //       4 : char_fifo_din = to_digit(send_resp_data[ 3:0 ]);
    //       5 : char_fifo_din = " "; // Space
    //       6 : char_fifo_din = to_digit({1'b0,bcd_out[18:16]});
    //       7 : char_fifo_din = to_digit(bcd_out[15:12]);
    //       8 : char_fifo_din = to_digit(bcd_out[11:8 ]);
    //       9 : char_fifo_din = to_digit(bcd_out[ 7:4 ]);
    //       10: char_fifo_din = to_digit(bcd_out[ 3:0 ]);
    //       11: char_fifo_din = 8'h0d; // Newline
    //       12: char_fifo_din = 8'h0a; // LineFeed
    //     endcase
    //   end // if RESP_DATA
    // end // if send_char
    else if (send_resp_type == RESP_wind1)

      begin
        case(char_cnt) // synthesis full_case
          0 : char_fifo_din = "C"; // Dash
          1 : char_fifo_din = "u";
          2 : char_fifo_din = "r";
          3 : char_fifo_din = "r";
          4 : char_fifo_din = "e";
          5 : char_fifo_din = "n"; // Space
          6 : char_fifo_din = "t";
          7 : char_fifo_din = " ";
          8 : char_fifo_din = "S";
          9 : char_fifo_din = "t";
          10: char_fifo_din = "a";
          11: char_fifo_din = "t";
          12: char_fifo_din = "e"; 
          13: char_fifo_din = "-"; 
          14: char_fifo_din = "W"; 
          15: char_fifo_din = "i"; 
          16: char_fifo_din = "n"; 
          17: char_fifo_din = "d"; 
          18: char_fifo_din = "1"; 
          19: char_fifo_din = 8'h0d; 
          20: char_fifo_din = 8'h0a; 
        endcase
      end 

    else if (send_resp_type == RESP_wind2)
      begin
        case(char_cnt) // synthesis full_case
          0 : char_fifo_din = "C"; // Dash
          1 : char_fifo_din = "u";
          2 : char_fifo_din = "r";
          3 : char_fifo_din = "r";
          4 : char_fifo_din = "e";
          5 : char_fifo_din = "n"; // Space
          6 : char_fifo_din = "t";
          7 : char_fifo_din = " ";
          8 : char_fifo_din = "S";
          9 : char_fifo_din = "t";
          10: char_fifo_din = "a";
          11: char_fifo_din = "t";
          12: char_fifo_din = "e"; 
          13: char_fifo_din = "-"; 
          14: char_fifo_din = "W"; 
          15: char_fifo_din = "i"; 
          16: char_fifo_din = "n"; 
          17: char_fifo_din = "d"; 
          18: char_fifo_din = "2"; 
          19: char_fifo_din = 8'h0d; 
          20: char_fifo_din = 8'h0a; 
        endcase
      end 

    else if (send_resp_type == RESP_wind3)

      begin
        case(char_cnt) // synthesis full_case
          0 : char_fifo_din = "C"; // Dash
          1 : char_fifo_din = "u";
          2 : char_fifo_din = "r";
          3 : char_fifo_din = "r";
          4 : char_fifo_din = "e";
          5 : char_fifo_din = "n"; // Space
          6 : char_fifo_din = "t";
          7 : char_fifo_din = " ";
          8 : char_fifo_din = "S";
          9 : char_fifo_din = "t";
          10: char_fifo_din = "a";
          11: char_fifo_din = "t";
          12: char_fifo_din = "e"; 
          13: char_fifo_din = "-"; 
          14: char_fifo_din = "W"; 
          15: char_fifo_din = "i"; 
          16: char_fifo_din = "n"; 
          17: char_fifo_din = "d"; 
          18: char_fifo_din = "3"; 
          19: char_fifo_din = 8'h0d; 
          20: char_fifo_din = 8'h0a; 
        endcase
      end 

    else if (send_resp_type == RESP_await)

      begin
        case(char_cnt) // synthesis full_case
          0 : char_fifo_din = "C"; // Dash
          1 : char_fifo_din = "u";
          2 : char_fifo_din = "r";
          3 : char_fifo_din = "r";
          4 : char_fifo_din = "e";
          5 : char_fifo_din = "n"; // Space
          6 : char_fifo_din = "t";
          7 : char_fifo_din = " ";
          8 : char_fifo_din = "S";
          9 : char_fifo_din = "t";
          10: char_fifo_din = "a";
          11: char_fifo_din = "t";
          12: char_fifo_din = "e"; 
          13: char_fifo_din = "-"; 
          14: char_fifo_din = "A"; 
          15: char_fifo_din = "w"; 
          16: char_fifo_din = "a"; 
          17: char_fifo_din = "i"; 
          18: char_fifo_din = "t"; 
          19: char_fifo_din = 8'h0d; 
          20: char_fifo_din = 8'h0a; 
        endcase
      end 





          else if (send_resp_type == RESP_clean)

      begin
        case(char_cnt) // synthesis full_case
          0 : char_fifo_din = "C"; // Dash
          1 : char_fifo_din = "u";
          2 : char_fifo_din = "r";
          3 : char_fifo_din = "r";
          4 : char_fifo_din = "e";
          5 : char_fifo_din = "n"; // Space
          6 : char_fifo_din = "t";
          7 : char_fifo_din = " ";
          8 : char_fifo_din = "S";
          9 : char_fifo_din = "t";
          10: char_fifo_din = "a";
          11: char_fifo_din = "t";
          12: char_fifo_din = "e"; 
          13: char_fifo_din = "-"; 
          14: char_fifo_din = "C"; 
          15: char_fifo_din = "l"; 
          16: char_fifo_din = "e"; 
          17: char_fifo_din = "a"; 
          18: char_fifo_din = "n"; 
          19: char_fifo_din = 8'h0d; 
          20: char_fifo_din = 8'h0a; 
        endcase
      end 


    else if (send_resp_type == RESP_close)

      begin
        case(char_cnt) // synthesis full_case
          0 : char_fifo_din = "C"; // Dash
          1 : char_fifo_din = "u";
          2 : char_fifo_din = "r";
          3 : char_fifo_din = "r";
          4 : char_fifo_din = "e";
          5 : char_fifo_din = "n"; // Space
          6 : char_fifo_din = "t";
          7 : char_fifo_din = " ";
          8 : char_fifo_din = "S";
          9 : char_fifo_din = "t";
          10: char_fifo_din = "a";
          11: char_fifo_din = "t";
          12: char_fifo_din = "e"; 
          13: char_fifo_din = "-"; 
          14: char_fifo_din = "C"; 
          15: char_fifo_din = "l"; 
          16: char_fifo_din = "o"; 
          17: char_fifo_din = "s"; 
          18: char_fifo_din = "e"; 
          19: char_fifo_din = 8'h0d; 
          20: char_fifo_din = 8'h0a; 
        endcase
      end 


    else if (send_resp_type == RESP_menuu)

      begin
        case(char_cnt) // synthesis full_case
          0 : char_fifo_din = "C"; // Dash
          1 : char_fifo_din = "u";
          2 : char_fifo_din = "r";
          3 : char_fifo_din = "r";
          4 : char_fifo_din = "e";
          5 : char_fifo_din = "n"; // Space
          6 : char_fifo_din = "t";
          7 : char_fifo_din = " ";
          8 : char_fifo_din = "S";
          9 : char_fifo_din = "t";
          10: char_fifo_din = "a";
          11: char_fifo_din = "t";
          12: char_fifo_din = "e"; 
          13: char_fifo_din = "-"; 
          14: char_fifo_din = "M"; 
          15: char_fifo_din = "e"; 
          16: char_fifo_din = "n"; 
          17: char_fifo_din = "u"; 
          18: char_fifo_din = " "; 
          19: char_fifo_din = 8'h0d; 
          20: char_fifo_din = 8'h0a; 
        endcase
      end 


    else if (send_resp_type == RESP_clean)

      begin
        case(char_cnt) // synthesis full_case
          0 : char_fifo_din = "C"; // Dash
          1 : char_fifo_din = "u";
          2 : char_fifo_din = "r";
          3 : char_fifo_din = "r";
          4 : char_fifo_din = "e";
          5 : char_fifo_din = "n"; // Space
          6 : char_fifo_din = "t";
          7 : char_fifo_din = " ";
          8 : char_fifo_din = "S";
          9 : char_fifo_din = "t";
          10: char_fifo_din = "a";
          11: char_fifo_din = "t";
          12: char_fifo_din = "e"; 
          13: char_fifo_din = "-"; 
          14: char_fifo_din = "C"; 
          15: char_fifo_din = "l"; 
          16: char_fifo_din = "e"; 
          17: char_fifo_din = "a"; 
          18: char_fifo_din = "n"; 
          19: char_fifo_din = 8'h0d; 
          20: char_fifo_din = 8'h0a; 
        endcase
      end 


    else if (send_resp_type == RESP_other)

      begin
        case(char_cnt) // synthesis full_case
          0 : char_fifo_din = "C"; // Dash
          1 : char_fifo_din = "u";
          2 : char_fifo_din = "r";
          3 : char_fifo_din = "r";
          4 : char_fifo_din = "e";
          5 : char_fifo_din = "n"; // Space
          6 : char_fifo_din = "t";
          7 : char_fifo_din = " ";
          8 : char_fifo_din = "S";
          9 : char_fifo_din = "t";
          10: char_fifo_din = "a";
          11: char_fifo_din = "t";
          12: char_fifo_din = "e"; 
          13: char_fifo_din = "-"; 
          14: char_fifo_din = "O"; 
          15: char_fifo_din = "t"; 
          16: char_fifo_din = "h"; 
          17: char_fifo_din = "e"; 
          18: char_fifo_din = "r"; 
          19: char_fifo_din = 8'h0d; 
          20: char_fifo_din = 8'h0a; 
        endcase
      end 



    end 
    
    
  end // always


endmodule
