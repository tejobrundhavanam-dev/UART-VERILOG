module top_rx #(
    parameter integer CLK_FREQ  = 50_000_000,
    parameter integer BAUD_RATE = 115200
)(
    input clk,
    input reset,
    input serial_in,
    input clear_framing_error,

    output [7:0]rx_data,
    output rx_done,
    output framing_error,
    output reg framing_error_sticky
    
);

wire start_detect,timer_tick;
wire half_bit_enable,full_bit_enable;
wire count_enable,shift_enable;
wire rx_done_out,rx_done_int;

start_bit uut1(start_detect, clk, reset,serial_in);
rx_timer #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) uut2(clk,reset,half_bit_enable,full_bit_enable,timer_tick);
bit_counter_rx uut3( rx_done_int,clk ,reset, count_enable, timer_tick);
shift_register_rx uut4( clk, reset, shift_enable, serial_in, rx_done_int, rx_data);
fsm_rx uut5( clk,reset, rx_done_int, start_detect,timer_tick, serial_in,half_bit_enable, full_bit_enable, shift_enable, count_enable,rx_done_out,framing_error);

assign rx_done = rx_done_out;

always@(posedge clk or posedge reset)begin
    if(reset) 
        framing_error_sticky <= 1'b0;
    else if (framing_error)
        framing_error_sticky <= 1'b1;
    else if (clear_framing_error)
        framing_error_sticky <= 1'b0;
end

endmodule






