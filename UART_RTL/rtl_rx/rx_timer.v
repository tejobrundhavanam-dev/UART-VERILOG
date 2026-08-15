module rx_timer #(
    parameter integer CLK_FREQ  = 50_000_000,
    parameter integer BAUD_RATE = 115200
)(
    input clk,
    input reset,
    input half_bit_enable,
    input full_bit_enable,
    output reg timer_tick
);

    localparam integer FULL_BIT_DIV = CLK_FREQ / BAUD_RATE;     // e.g. 434
    localparam integer FULL_BIT_MAX = FULL_BIT_DIV -1;
    localparam integer HALF_BIT_DIV = FULL_BIT_DIV / 2;         // e.g. 217
    localparam integer HALF_BIT_MAX = HALF_BIT_DIV -1; 
    reg [8:0] rx_cnt;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            timer_tick <= 0;
            rx_cnt     <= 0;
        end
        else begin
            timer_tick <= 0;
            if (!half_bit_enable && !full_bit_enable) begin
                rx_cnt <= 0;
            end
            else if (half_bit_enable) begin
                if (rx_cnt == HALF_BIT_MAX) begin
                    timer_tick <= 1;
                    rx_cnt <= 0;
                end
                else rx_cnt <= rx_cnt + 1;
            end
            else if (full_bit_enable) begin
                if (rx_cnt == FULL_BIT_MAX) begin
                    timer_tick <= 1;
                    rx_cnt <= 0;
                end
                else rx_cnt <= rx_cnt + 1;
            end
        end
    end
endmodule