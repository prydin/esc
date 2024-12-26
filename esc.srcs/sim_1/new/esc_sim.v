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
    always #10 // 100MHz 
    begin
        clk = ~clk;
    end
    
    
    
    wire u_hi, u_lo, v_hi, v_lo, w_hi, w_lo;
    
    pulse_gen pulse_gen(
        clk, 
        100000,
        200,
        u_hi,
        u_lo,
        v_hi,
        v_lo,
        w_hi,
        w_lo);
        
     initial
     begin
        #1000000;
     end
endmodule
