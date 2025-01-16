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
    output pio16,           // Cleaned U pos sense (for debug)
    output pio17,           // Cleaned U neg sense (for debug)
    input vauxp5,           // Power control pos
    input vauxn5,           // Power control neg
    input [1:0]btn          // Started button (to be removed in final design)            
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
    wire start = btn[0];
    
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
        .clk(master_clk), 
        .start(start),
        .period(`CLK_RATE / 30), 
        .start_period(`CLK_RATE / 5),
        .idle_period(`CLK_RATE / 30),
        .power(duty_cycle),
        .u_hi(u_hi),
        .u_lo(u_lo),
        .v_hi(v_hi),
        .v_lo(v_lo),
        .w_hi(w_hi),
        .w_lo(w_lo));
        
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
    localparam ZD_WINDOW = 200; // Number of 10MHz ticks to look across
    localparam ZD_PERCENT = 80; // Percentage of ones to trigger a zero crossing
        
    wire u_zero_pos;
    wire u_zero_neg;
    wire v_zero_pos;
    wire v_zero_neg;
    wire w_zero_pos;
    wire w_zero_neg;
    
    zero_detect #(
        .WINDOW_SIZE(ZD_WINDOW),
        .HIGH_THRESHOLD(ZD_PERCENT),
        .LOW_THRESHOLD(100 - ZD_PERCENT)) zero_detect_u (
        .clk(slow_clk),
        .enable(1),
        .reset(0), // TODO: Add reset logic
        .in(u_zero),
        .pos_edge(u_zero_pos),
        .neg_edge(u_zero_neg));
        
    mono_ff #(.PULSE_LENGTH(300)) u_pos_ff (
        .clk(slow_clk),
        .trigger(u_zero_pos),
        .out(pio16));
        
    mono_ff #(.PULSE_LENGTH(300)) u_neg_ff (
        .clk(slow_clk),
        .trigger(u_zero_neg),
        .out(pio17));
        
    zero_detect #(
        .WINDOW_SIZE(ZD_WINDOW),
        .HIGH_THRESHOLD(ZD_PERCENT),
        .LOW_THRESHOLD(100 - ZD_PERCENT)) zero_detect_v (
        .clk(slow_clk),
        .enable(1),
        .reset(0), // TODO: Add reset logic
        .in(v_zero),
        .pos_edge(v_zero_pos),
        .neg_edge(v_zero_neg));
        
    mono_ff #(.PULSE_LENGTH(300)) v_pos_ff (
        .clk(slow_clk),
        .trigger(v_zero_pos),
        .out(pio18));
        
    mono_ff #(.PULSE_LENGTH(300)) v_neg_ff (
        .clk(slow_clk),
        .trigger(v_zero_neg),
        .out(pio19));
        
    zero_detect #(
        .WINDOW_SIZE(ZD_WINDOW),
        .HIGH_THRESHOLD(ZD_PERCENT),
        .LOW_THRESHOLD(100 - ZD_PERCENT)) zero_detect_W (
        .clk(slow_clk),
        .enable(1),
        .reset(0), // TODO: Add reset logic
        .in(w_zero),
        .pos_edge(w_zero_pos),
        .neg_edge(w_zero_neg));
        
    mono_ff #(.PULSE_LENGTH(300)) w_pos_ff (
        .clk(slow_clk),
        .trigger(w_zero_pos),
        .out(pio20));
        
    mono_ff #(.PULSE_LENGTH(300)) w_neg_ff (
        .clk(slow_clk),
        .trigger(w_zero_neg),
        .out(pio21));        
        
endmodule

//////////////////////////////////////////////////////////
// mono_ff 
// Monostable flip-flop. Currently used only for debugging
//////////////////////////////////////////////////////////
module mono_ff #(
    PULSE_LENGTH = 1000) (
    input clk, 
    input trigger,
    output reg out = 0);
    
    reg [$clog2(PULSE_LENGTH):0] counter = 0;
    
    always @(posedge clk) 
    begin
        if(out)
        begin
            begin
                if(counter == 0) 
                begin
                   out <= 0; 
                end else 
                begin
                    counter <= counter - 1;
                end
            end
        end 
        if(trigger && !out)
        begin
            out <= 1; 
            counter <= PULSE_LENGTH;            
        end     
    end
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

////////////////////////////////////////////////////////////////////////
// starter
// Ramps up RPM in open loop mode until we can detect back EMF
////////////////////////////////////////////////////////////////////////
module starter #(
    DIVISOR = 5
    ) (
    input clk,
    input trigger,
    input [26:0] start_period,
    input [26:0] target_period,
    output reg [26:0] period,
    output reg active = 0);
        
    reg [$clog2(DIVISOR):0] sub_counter= 0;
    
    always @(posedge clk) 
    begin
        if(trigger && !active) 
        begin
            period <= start_period;
            active <= 1;
        end
        if(active) 
        begin
            if(sub_counter == 0) 
            begin
                sub_counter <= DIVISOR;
                if(period > target_period)
                begin
                    period <= period - 1;
                end else
                begin
                    active <= 0;
                end 
            end else
            begin
                sub_counter <= sub_counter - 1;
            end
        end
    end
endmodule

///////////////////////////////////////////////////////////////
// filter 
// A simple first-order IIR filter for cleaning up the polarity
// pulses coming out of the the analog comparators
///////////////////////////////////////////////////////////////
module filter #(
    parameter                   NUM_BITS    = 16,
    parameter                   WINDOW_SIZE = 100) (
    input                       clk,
    input                       reset,
    input                       enable,
    input                       in,
    output reg [NUM_BITS - 1:0] out = 0);
        
    localparam MAX_VALUE        = 2 ** NUM_BITS;
    localparam SCALED_ALPHA     = MAX_VALUE / WINDOW_SIZE;
    localparam SCALED_ALPHA_1   = MAX_VALUE - SCALED_ALPHA;
     
    wire [NUM_BITS * 2 - 1:0]   lag_term = out * SCALED_ALPHA_1;
    wire [NUM_BITS - 1:0]       acc = (lag_term >> NUM_BITS) + (in ? SCALED_ALPHA : 0);  
     
    always @(posedge clk)
    begin
        if(reset)
        begin
            out <= 0;
        end else
        begin
            out <= acc;
        end  
    end         
endmodule 


/////////////////////////////////////////////////////////////////////
// zero_detect
// Detects a back EMF zero crossing
/////////////////////////////////////////////////////////////////////
module zero_detect #(
    parameter   WINDOW_SIZE       = 100, 
    parameter   HIGH_THRESHOLD    = 80,
    parameter   LOW_THRESHOLD     = 20) (
    input       clk,
    input       reset,
    input       enable, 
    input       in,
    output reg  pos_edge = 0,
    output reg  neg_edge = 0);
    
    localparam FILTER_BITS  = 16;
    localparam MAX_VALUE    = (2 ** FILTER_BITS) - 1;
    localparam RAW_HI       = (MAX_VALUE * HIGH_THRESHOLD) / 100;
    localparam RAW_LO       = (MAX_VALUE * LOW_THRESHOLD) / 100;  
    
    wire [FILTER_BITS - 1:0] filter_out;
    
    filter #(
      .NUM_BITS(FILTER_BITS),
      .WINDOW_SIZE(WINDOW_SIZE)) filter (
      .clk(clk),
      .enable(enable),
      .reset(reset),
      .in(in),
      .out(filter_out));
      
    reg state = 0;
      
    always @(posedge clk) 
    begin
        if(enable)
        begin
            if(filter_out > RAW_HI && !state)
            begin
                state <= 1;
                pos_edge <= 1;
            end else 
            begin
                pos_edge <= 0;
            end
            if(filter_out < RAW_LO && state)
            begin
                state <= 0;
                neg_edge <= 1;
            end else
            begin
                neg_edge <= 0;
            end
        end
    end
endmodule

module div_by_3(
    input [26:0] x,
    output [26:0] y);
   
    // Power series approximation of x / 3
    assign y = (x >> 1) - (x >> 2) + (x >> 3) - (x >> 4) + (x >> 5) - (x >> 6) + (x >> 7) - (x >> 8) + (x >> 9) - (x >> 10); 
endmodule

module div_by_6(
    input [26:0] x,
    output [26:0] y);
    
    wire [26:0] tmp;
    div_by_3 div_by_3(
        x, 
        tmp);
    assign y = tmp >> 1;
endmodule


////////////////////////////////////////////////////////////////////////////
// pwm_carrier
// Generates the PWM chopping frequency based on an on-time and and off-time
////////////////////////////////////////////////////////////////////////////
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

//////////////////////////////////////
// pulse_gen
// Main commutation generator logic
//////////////////////////////////////
module pulse_gen #(
    PWM_PERIOD = 8192
    ) (
    input clk,
    input [26:0] period,
    input [26:0] start_period, 
    input [26:0] idle_period,
    input [$clog2(PWM_PERIOD) - 1:0] power,
    input start,
    output reg u_hi,
    output reg u_lo, 
    output reg v_hi,
    output reg v_lo,
    output reg w_hi,
    output reg w_lo
    );
         
    reg [26:0] counter = 0;
    reg [2:0] step = 0;
    reg [26:0] current_period = 0;  
    wire [26:0] starter_period;
    wire starter_enabled;
    wire [26:0] sub_period;
    wire [16:0] t_on = power;
    wire [16:0] t_off = PWM_PERIOD - power;
    wire pwm;
    
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
        
    // Set up the starter
    starter starter (
        .clk(clk),
        .trigger(start),
        .start_period(start_period), 
        .target_period(idle_period),
        .period(starter_period),
        .active(starter_enabled));
 
    always @(posedge clk) 
    begin
        // Have we reached the end of a sub period?
        if(counter == 0)
        begin
            if(step == 0) 
            begin 
                // Make any period changes take effect at the start of the first step.
                // Use the period for the starter if it's enabled.
                if(starter_enabled)
                begin
                    current_period <= starter_period;
                end else
                begin
                    current_period <= period;
                end
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