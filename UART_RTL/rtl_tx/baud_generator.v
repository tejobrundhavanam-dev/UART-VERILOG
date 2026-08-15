//=============================================================
// Module : baudgenerator
// Author : Tejo RAma Krishna
// Project: UART Transmitter
//
// Description:
// Generates one baud_tick pulse every baud period.
// Baud rate is configurable using parameters.
//
// Parameters:
//   CLK_FREQ  - Input clock frequency
//   BAUD_RATE - UART baud rate
//=============================================================
module baudgenerator #(
    parameter integer CLK_FREQ  = 50_000_000,
    parameter integer BAUD_RATE = 115200
)(
    output baud_tick,
    input clk,
    input reset,
    input baud_enable
);

    localparam integer BAUD_DIV   = CLK_FREQ / BAUD_RATE;      // e.g. 434 at 50MHz
    localparam integer BAUD_CNT_MAX = BAUD_DIV - 1;
    reg [8:0] baud_cnt;

    always @(posedge clk or posedge reset) begin
        if (reset || !baud_enable) begin
            baud_cnt <= 0;
        end
        else if (baud_enable) begin
            if (baud_cnt == BAUD_CNT_MAX)
                baud_cnt <= 0;
            else
                baud_cnt <= baud_cnt + 1'b1;
        end
    end

    assign baud_tick = (baud_cnt == BAUD_CNT_MAX);

endmodule