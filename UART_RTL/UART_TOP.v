module UART_TOP #(
    parameter integer CLK_FREQ  = 50_000_000,
    parameter integer BAUD_RATE = 115200
) (
    input clk,
    input reset,

    input [7:0]tx_data,
    input tx_start,
    input clear_framing_error,

    output [7:0] rx_data,
    output rx_done,
    output tx_busy,
    output framing_error,
    output framing_error_sticky



);

    wire serial_wire;

     top_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) rx(.clk(clk), .reset(reset), .serial_in(serial_wire),.clear_framing_error(clear_framing_error),.rx_data(rx_data), .rx_done(rx_done),.framing_error(framing_error),.framing_error_sticky(framing_error_sticky));
     top #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE))tx(.serial_out(serial_wire),.tx_busy(tx_busy),.clk(clk), .reset(reset), .tx_start(tx_start),.tx_data(tx_data));

endmodule
