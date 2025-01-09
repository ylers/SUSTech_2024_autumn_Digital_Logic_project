`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/07 19:59:29
// Design Name: 
// Module Name: gesture_control
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


module gesture_control_on(

    input clk,           // Clock signal
    input reset,
    input button1,       // Button 1 input
    input button2,       // Button 2 input
    input [4:0] modes,
    input [3:0]gesture_time,
    output reg on             // Output signal
);

    // Parameters
    wire [31:0] COUNTER_MAX;
    assign COUNTER_MAX = gesture_time * 100_000_000;  // Counter value for 5 seconds (100 MHz clock)

    // Internal signals
    reg [31:0] counter1;       // 32-bit counter for counting up to 500,000,000
    reg counting1;             // Flag to indicate counting is in progress
     // Internal signals
  
    // Synchronous process
    always @(posedge clk) begin
        if (!reset) begin
           on <= 0;
           counter1 <= 0;
           counting1 <= 0;
        end
        else if (on==0)begin
        
            
        if(modes==5'b00000)begin
        
                       if (button1 && !counting1) begin
                           // Start the counter when button1 is pressed and counting isn't active
                           counting1 <= 1;
                           counter1 <= COUNTER_MAX;
                       end
           
                       if (counting1) begin
                           if (counter1 > 0) begin
                               counter1 <= counter1 - 1; // Decrement the counter
                           end else begin
                               counting1 <= 0; // Stop counting when the counter reaches 0
                           end
                       end
           
                       if (button2 && counting1) begin
                           // If button2 is pressed within the 5-second window, set `on` to 1
                           on <= ~on;
                           counting1 <= 0; // Stop counting
                       end
                       
          end             
                       
          end else begin
          
                on <= 0;
          
          
          end
        
        
                
        
        
   end 
        
        

    

endmodule

module gesture_control_off(

    input clk,           // Clock signal
    input reset,
    input button1,       // Button 1 input
    input button2,       // Button 2 input
    input [4:0] modes,
    input [3:0]gesture_time,
    output reg on             // Output signal
);

    // Parameters
    wire [31:0] COUNTER_MAX;
    assign COUNTER_MAX = gesture_time * 100_000_000;  // Counter value for 5 seconds (100 MHz clock)

    // Internal signals
    reg [31:0] counter1;       // 32-bit counter for counting up to 500,000,000
    reg counting1;             // Flag to indicate counting is in progress
     // Internal signals
  
    // Synchronous process
    always @(posedge clk) begin
        if (!reset) begin
           on <= 0;
           counter1 <= 0;
           counting1 <= 0;
        end
        else if (on==0)begin
        
            
        if(modes!=5'b00000)begin
        
                       if (button1 && !counting1) begin
                           // Start the counter when button1 is pressed and counting isn't active
                           counting1 <= 1;
                           counter1 <= COUNTER_MAX;
                       end
           
                       if (counting1) begin
                           if (counter1 > 0) begin
                               counter1 <= counter1 - 1; // Decrement the counter
                           end else begin
                               counting1 <= 0; // Stop counting when the counter reaches 0
                           end
                       end
           
                       if (button2 && counting1) begin
                           // If button2 is pressed within the 5-second window, set `on` to 1
                           on <= ~on;
                           counting1 <= 0; // Stop counting
                       end
                       
          end             
                       
          end else begin
          
                on <= 0;
          
          
          end
        
        
                
        
        
   end 
        
        

    

endmodule