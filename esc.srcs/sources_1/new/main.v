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

// Master clock rate (Hz)
`define CLK_RATE 100_000_000 

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
    
    localparam PWM_PERIOD = 16384; // Must be power of 2
    
    // Assign friendly names to the pins
    wire u_hi = pio1;  
    wire v_hi = pio2;
    wire w_hi = pio3;
    wire u_lo = pio4;
    wire v_lo = pio5;
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
    reg [15:0] duty_cycle;
    
    // Create 200MHz and 10MHz clocks
    clk_wiz_0 clock (
        .clk_out1(master_clk),
        .clk_out2(slow_clk),
        .reset(0),               // TODO: Implement reset
        .locked(locked),
        .clk_in1(clk));
        
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
            duty_cycle <= user_speed >> (16 - $clog2(PWM_PERIOD));  
        end
    end
        
    // Main pulse generator logic
    pulse_gen #(
        .PWM_PERIOD(PWM_PERIOD)) pulse_gen (
        master_clk, 
        CLK_RATE / 30, // 3600 RPM
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
        .WINDOW_SIZE(200),
        .HIGH_THRESHOLD(150),
        .LOW_THRESHOLD(100)) zero_detect (
        .clk(slow_clk),
        .enable(1),
        .reset(0), // TODO: Add reset logic
        .in(u_zero),
        .pos_edge(u_zero_cleaned)); 

endmodule

// Generate a one-clock period tick at an interval determined by DIVISOR
module tick_generator #(
    DIVISOR = 1) (
        input clk,
        output reg tick);
       
    reg [$clog2(DIVISOR) - 1:0] counter = 0;
    
    always @(posedge clk) 
    begin
        if(counter == DIVISOR) 
        begin
            tick <= 1;
            counter = 0;
        end else
        begin 
            tick <= 0;
            counter <= counter + 1;
        end
    end
endmodule

module starter #(
    RAMPUP_TIME = 10_000_000) (
    input clk,
    input trigger,
    input [26:0] target_period,
    output reg [26:0] period);
    
    localparam START_PERIOD = `CLK_RATE / 5;
    
    reg active = 0;
    reg [26:0] counter = 0;
    
    always @(posedge clk) 
    begin
        if(trigger && !active) 
        begin
            period <= START_PERIOD;
            active <= 1;
        end
        if(active) 
        begin
            if(period > target_period)
            begin
                period <= period + 1;
            end else
            begin
                active <= 0;
            end 
        end 
    end
endmodule
    
module ones_counter #(
    parameter PERIOD = 1) (
    input clk, 
    input reset,
    input enable,
    input start,
    input signal_in,
    output reg ready,
    output reg [$clog2(PERIOD):0] count = 0);
    
    reg [$clog2(PERIOD):0] period = 0;
    reg [$clog2(PERIOD):0] internal_count = 0;
 
    always @(posedge clk) 
    begin
        if(reset || !enable) 
        begin
            internal_count <= 0;
            period <= 0;
            ready <= 0;
        end else 
        begin
            if(start)
            begin
                ready <= 0;
                internal_count <= 0;
                period <= 0;
            end
            if(!ready && signal_in)
            begin
                internal_count <= internal_count + 1;
            end
            if(period == PERIOD)
            begin
                count <= internal_count;
                ready <= 1;
            end else
            begin
                period <= period + 1;
            end
        end
    end
endmodule

module zero_detect #(
    parameter WINDOW_SIZE = 60, 
    parameter HIGH_THRESHOLD = 40,
    parameter LOW_THRESHOLD = 30) (
    input clk,
    input reset,
    input enable, 
    input in,
    output reg pos_edge = 0,
    output reg neg_edge = 0);
    
    localparam LOW = 0;
    localparam HIGH = 1;
    localparam COUNTER_SIZE = $clog2(WINDOW_SIZE);
     
    reg state = LOW;
   
    wire ready;
    wire [COUNTER_SIZE:0] ones;
    reg trigger = 1; 

    ones_counter #(
        .PERIOD(WINDOW_SIZE)) ones_counter (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .start(trigger),
        .signal_in(in),
        .ready(ready),
        .count(ones));
            
    always @(posedge clk) 
    begin
        if(reset) 
        begin
            trigger <= 1;
        end
        if(enable) 
        begin
            if(ready) 
            begin 
                if(ones > HIGH_THRESHOLD && state == LOW) 
                begin
                    state <= HIGH;
                    pos_edge <= 1;
                end else
                begin
                    pos_edge <= 0;
                end
                
                if(ones < LOW_THRESHOLD && state == HIGH) 
                begin
                    state <= LOW;
                    neg_edge <= 1;
                end else 
                begin
                    neg_edge <= 0;
                end
                trigger <= 1;
            end else
            begin
                if(trigger)
                begin
                    trigger <= 0;
                end
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

module pwm_carrier #(
    parameter PERIOD = 8192
    )(
    input clk,
    input [$clog2(PERIOD) - 1:0] t_on,
    input [$clog2(PERIOD) - 1:0] t_off,
    output reg out = 0);
    
reg [$clog2(PERIOD) - 1:0] counter = 0;

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

module pulse_gen #(
    PWM_PERIOD = 8192
    ) (
    input clk,
    input [26:0] period,
    input [$clog2(PWM_PERIOD) - 1:0] power,
    input start,
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
    reg [26:0] rampup_period = 0;
    wire [26:0] sub_period;
    wire [16:0] t_on = power;
    wire [16:0] t_off = PWM_PERIOD - power;
    wire pwm;
    reg [1:0] motor_state = MODE_STARTING;
    
    localparam MODE_STARTING    = 0; // Motor is starting
    localparam MODE_ACCEL       = 1; // Motor is accelerating
    localparam MODE_RUNNING     = 2; // Motor is running

    
    // Calculate length of sub-perdiod
    div_by_6 div_by_6(
        current_period,
        sub_period);
          
    // Set up pwm choppers
    pwm_carrier  #(
        .PERIOD(PWM_PERIOD)) pwm_carrier ( 
        .clk(clk),
        .t_on(t_on), 
        .t_off(t_off),
        .out(pwm));
 
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