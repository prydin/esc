`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2024 09:44:19 PM
// Design Name: 
// Module Name: div_sim
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


module div_sim(
    );
    reg clk = 0;
    always #1 
    begin
        clk = ~clk;
    end 
    
    reg [26:0] x = 3;
    wire [26:0] y;

    div_by_3 div_by_3(
        x, 
        y); 
     
     initial begin
         #10 
         x <= 30;
         
         #10
         x <= 3000000;
         
         #10
         x <= 9999;
         
         #10 
         x <= 10000000;
     end     
endmodule
