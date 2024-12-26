`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2024 08:29:18 AM
// Design Name: 
// Module Name: main
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

module esc(
    input clk,              // Master clock
    output [0:1] led,
    output pio1,            // U phase hi
    output pio2,            // V phase hi
    output pio3,            // W phase hi
    output pio4,            // U phase lo
    output pio5,            // V phase lo
    output pio6,            // W phase lo
    input pio7,             // U zero sense
    input pio8,             // V zero sense
    input pio9,             // W zero sense
    output pio16,           // Cleaned U sense (for debug)
    input vauxp5,           // Power control pos
    input vauxn5            // Power control neg
    );
    
    // Assign friendly names to the pins
    wire u_hi = pio1;  
    wire u_lo = pio2;
    wire v_hi = pio3;
    wire v_lo = pio4;
    wire w_hi = pio5;
    wire w_lo = pio6;
    wire u_zero = pio7;
    wire v_zero = pio8;
    wire w_zero = pio9;
    wire u_zero_cleaned = pio16; // For debug
    
    // Master 200MHz clock
    wire master_clk;
    
    // Slow clock (1MHz)
    wire slow_clk;
    
    // 100kHz sense clock
    wire sense_clk;
    
    // Clock locked flag (not used)
    wire locked;
    
    // User speed knob position
    wire [15:0] user_speed;
    wire user_speed_rdy;
    
    // Pulse generator parameters
    reg [9:0] duty_cycle;
    
    // Create 200MHz and 10MHz clocks
    clk_wiz_0 clock (
        .clk_out1(master_clk),
        .clk_out2(slow_clk),
        .reset(0),               // TODO: Implement reset
        .locked(locked),
        .clk_in1(clk));
        
    // Generate a 100kHz clock based on the 10MHz slow_clk
    clock_divider #(
        DIVISOR(100)) clock_divider (
        .clk_in(slow_clk),
        .clk_out(sense_clock));
        
    // ADC for the speed knob
    xadc_0 speed_knob (
        .di_in(0),                            // input wire [15 : 0] di_in
        .daddr_in(7'h15),                     // input wire [6 : 0] daddr_in
        .den_in(1),                           // input wire den_in
        .dwe_in(0),                           // input wire dwe_in
        .drdy_out(),                          // output wire drdy_out
        .do_out(user_speed),                  // output wire [15 : 0] do_out
        .dclk_in(master_clk),                 // input wire dclk_in
        .reset_in(0),                         // input wire reset_in TODO: Add reset logic
        .vp_in(0),                            // input wire vp_in
        .vn_in(0),                            // input wire vn_in
        .vauxp5(vauxp5),                      // input wire vauxp5
        .vauxn5(vauxn5),                      // input wire vauxn5
        .user_temp_alarm_out(),               // output wire user_temp_alarm_out
        .vccint_alarm_out(),                  // output wire vccint_alarm_out
        .vccaux_alarm_out(),                  // output wire vccaux_alarm_out
        .ot_out(),                            // output wire ot_out
        .channel_out(),                       // output wire [4 : 0] channel_out
        .eoc_out(user_speed_rdy),             // output wire eoc_out
        .alarm_out(),                         // output wire alarm_out
        .eos_out(),                           // output wire eos_out
        .busy_out()                           // output wire busy_out
        );
        
    // Speed control logic
    always @(posedge master_clk)
    begin
        if(user_speed_rdy) 
        begin
            duty_cycle <= user_speed >> 6; // Divde by 64
        end
    end
        
    // Main pulse generator logic
    pulse_gen pulse_gen(
        master_clk, 
        100000,
        duty_cycle,
        u_hi,
        u_lo,
        v_hi,
        v_lo,
        w_hi,
        w_lo);
        
    // Test/demo code
    reg [31:0] blink_count;
    reg blink;
    assign led[0] = blink;
    always @(posedge master_clk)
    begin            
        if(blink_count == 0) 
        begin
            blink_count <= 100_000_000;
            blink <= ~blink;
        end else begin
            blink_count <= blink_count - 1;
        end
    end 
    
    // Test of zero crossing detection. Move to esc pulse generator
    zero_detect #(
        .WINDOW_SIZE(20),
        .THRESHOLD(14)) (
        .clk(sample_clk),
        .in(u_zero),
        .out(u_zero_cleaned)); 

endmodule

module clock_divider #(
    DIVISOR = 1) (
        input clk_in,
        output reg clk_out);
    
    reg [$clog2(DIVISOR) - 1:0] counter = 0;
    
    always @(posedge clk_in) 
    begin
        counter <= counter + 1;
        if(counter == DIVISOR) 
        begin
            clk_out <= ~clk_out;
            counter = 0;
        end
    end
    
endmodule

module zero_detect #(
    parameter WINDOW_SIZE = 60, 
    parameter THRESHOLD = 40) (
    input clk,
    input in,
    output reg pos_edge = 0,
    output reg neg_edge = 0);
    
//    localparam UNDEFINED = 0;
    localparam LOW = 0;
    localparam HIGH = 1;
    localparam COUNTER_SIZE = $clog2(WINDOW_SIZE);
     
    reg state = LOW;
    reg [WINDOW_SIZE - 1:0] fifo = 0; 
    reg [COUNTER_SIZE:0] ones = 0;
    wire [COUNTER_SIZE:0] zeroes = WINDOW_SIZE - ones;
    
    // Determine increment/decrement action depending on incoming and outgoing bit
    wire do_increment = in == 1 && fifo[WINDOW_SIZE - 1:WINDOW_SIZE - 1] == 0;
    wire do_decrement = in == 0 && fifo[WINDOW_SIZE - 1:WINDOW_SIZE - 1] == 1; 
       
    always @(posedge clk) 
    begin
        // Apply effect of incoming bit
        fifo <= (fifo << 1) | in;
        if(do_increment)
        begin
            ones <= ones + 1;
        end else if(do_decrement)
        begin
            ones <= ones - 1;
        end
        
        if(state == HIGH)
        begin
            pos_edge <= 0;
            
            // Negative crossing?
            if(zeroes >= THRESHOLD)
            begin
                state <= LOW;
                neg_edge <= 1;
            end
        end else
        begin
            neg_edge <= 0;
            
            // Positive crossing?
            if(ones >= THRESHOLD)
            begin
                state <= HIGH;
                pos_edge <= 1;
            end
        end
    end
endmodule

module div_by_3(
    input unsigned [26:0] x,
    output unsigned [26:0] y);
   
    // Power series approximation of x / 3
    assign y = (x >> 1) - (x >> 2) + (x >> 3) - (x >> 4) + (x >> 5) - (x >> 6) + (x >> 7) - (x >> 8) + (x >> 9) - (x >> 10); 
endmodule

module div_by_6(
    input unsigned [26:0] x,
    output unsigned [26:0] y);
    
    wire [26:0] tmp;
    div_by_3 div_by_3(
        x, 
        tmp);
    assign y = tmp >> 1;
endmodule

module pwm_carrier(
    input clk,
    input [9:0] t_on,
    input [9:0] t_off,
    output reg out = 0);
    
reg [9:0] counter = 0;

always @(posedge clk)
begin    
    counter <= counter - 1;    
    if(counter == 0) 
    begin
        if(out)
        begin 
            counter <= t_off;
            out <= 0;
        end else begin
            out <= 1;
            counter <= t_on;
        end
    end
end    
    
endmodule

module pulse_gen(
    input clk,
    input [26:0] period,
    input [9:0] power,
    output reg u_hi,
    output reg u_lo, 
    output reg v_hi,
    output reg v_lo,
    output reg w_hi,
    output reg w_lo
    );
     
    reg unsigned [26:0] counter = 0;
    reg unsigned [2:0] step = 0;
    reg [26:0] current_period = 0;  
    wire [26:0] sub_period;
    wire [9:0] t_on = power;
    wire [9:0] t_off = 1024 - power;
    wire pwm;

    
    // Calculate length of sub-perdiod
    div_by_6 div_by_6(
        current_period,
        sub_period);
        
    // Set up pwm choppers
    pwm_carrier pwm_carrier(clk, t_on, t_off, pwm);
 
    always @(posedge clk) 
    begin
        // Have we reached the end of a sub period?
        if(counter == 0)
        begin
            if(step == 0) 
            begin 
                // Make any period changes take effect at the start of the first step
                current_period <= period;
            end   
            if(step == 5)
            begin 
                step <= 0;
            end else begin 
                step <= step + 1;
            end
            
            
        end
        case(step) 
            0: begin
                u_hi <= pwm;
                u_lo <= 0;
                v_hi <= 0;
                v_lo <= 0;
                w_hi <= 0;
                w_lo <= pwm;
            end
            1: begin
                u_hi <= 0;
                u_lo <= 0;
                v_hi <= pwm;
                v_lo <= 0;
                w_hi <= 0;
                w_lo <= pwm;
            end
            2: begin
                u_hi <= 0;
                u_lo <= pwm;
                v_hi <= pwm;
                v_lo <= 0;
                w_hi <= 0;
                w_lo <= 0;
            end
            3: begin
                u_hi <= 0;
                u_lo <= pwm;
                v_hi <= 0;
                v_lo <= 0;
                w_hi <= pwm;
                w_lo <= 0;
            end
            4: begin
                u_hi <= 0;
                u_lo <= 0;
                v_hi <= 0;
                v_lo <= pwm;
                w_hi <= pwm;
                w_lo <= 0;
            end
            5: begin
                u_hi <= pwm;
                u_lo <= 0;
                v_hi <= 0;
                v_lo <= pwm;
                w_hi <= 0;
                w_lo <= 0;
            end
         endcase
         
         // Update counter
         if(counter == sub_period - 1)
         begin
            counter <= 0;
         end else begin
            counter <= counter + 1;
         end
    end
endmodule    