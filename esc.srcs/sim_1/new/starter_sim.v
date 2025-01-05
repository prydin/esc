`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/02/2025 07:55:27 AM
// Design Name: 
// Module Name: starter_sim
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


module starter_sim();
    reg clk = 0;
    always #1 
    begin
        clk = ~clk;
    end
    
    reg trigger;
    wire [26:0] period;
    
    starter starter (
        .clk(clk),
        .trigger(trigger),
        .target_period((100_000_000 / 5) - 100),
        .period(period));
          
    initial
    begin
        trigger <= 1;
        #1;
        trigger <= 0;
        
        #100;
    end
    
endmodule
