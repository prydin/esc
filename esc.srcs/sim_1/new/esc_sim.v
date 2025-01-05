`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2024 08:58:07 AM
// Design Name: 
// Module Name: esc_sim
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


module esc_sim(
    );
    reg clk = 0;
    
    always #1 
    begin
        clk <= ~clk;
    end
    
    
    
    wire u_hi, u_lo, v_hi, v_lo, w_hi, w_lo;
    reg start;
    
    pulse_gen #(
        .PWM_PERIOD(10)
        ) pulse_gen(
        .clk(clk), 
        .period(1000),
        .start_period(2000),
        .idle_period(1000),
        .start(start),
        .power(5),
        .u_hi(u_hi),
        .u_lo(u_lo),
        .v_hi(v_hi),
        .v_lo(v_lo),
        .w_hi(w_hi),
        .w_lo(w_lo));
        
     initial
         begin
         start <= 0;
         
         #10;
         
         start <= 1;
         #4;
         start <= 0;
          
         #1000000;
     end
     
     
endmodule
