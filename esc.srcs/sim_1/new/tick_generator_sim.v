`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/01/2025 08:29:45 PM
// Design Name: 
// Module Name: tick_generator_sim
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


module tick_generator_sim();
    reg clk = 0;
    always #1 
    begin
        clk = ~clk;
    end
    
    wire tick;
    
    tick_generator #(
        .DIVISOR(10)) t (
        .clk(clk),  
        .tick(tick));
    
    initial 
    begin 
        #100;
    end
        
endmodule
