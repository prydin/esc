`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2024 02:13:09 PM
// Design Name: 
// Module Name: zero_detect_sim
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


module zero_detect_sim();
    reg clk = 0;
    always #1 
    begin
        clk = ~clk;
    end
    
    reg sense;
    
    zero_detect #(
        .WINDOW_SIZE(60),
        .HIGH_THRESHOLD(40),
        .LOW_THRESHOLD(30)
    ) zero_detect (
        .clk(clk),
        .reset(0),
        .enable(1),
        .in(sense),
        .pos_edge(pos_edge),
        .neg_edge(neg_edge));
        
    integer i;
        
    initial 
    begin
        sense <= 0;
        #40; // Let things settle
      
        // Positive zero crossing from UNDEFINED
        for (i = 0; i < 130; i = i + 1) 
        begin
			#1
			sense <= 1;
			
			#4
			sense <= 0;
		end
       
        // Leave sense high for a while, then transition to LOW
        sense <= 1;
        #100;
        
        for (i = 0; i < 130; i = i + 1) 
        begin
			#1
			sense <= 0;
			
			#4
			sense <= 1;
		end
		
		sense <= 0;
		#400;
		
        sense <= 1;
		#400;
		
    end
endmodule
