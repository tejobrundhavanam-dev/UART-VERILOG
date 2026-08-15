//=============================================================
// Module : fsm
// Project: UART Transmitter
//
// Description:
// Controls UART transmission.
//
// States
//   IDLE  : Wait for tx_start
//   LOAD  : Load shift register
//   RUN   : Shift 10 UART bits
//   STOP  : Finish transmission
//=============================================================
module fsm(
input clk,
input reset,

input tx_start,      // Request to start transmission
input baud_tick,     // One-clock pulse from baud generator
input tx_done,       // One-clock pulse from bit counter

output reg load,
output reg shift,

output reg baud_enable,
output reg count_enable,
output reg tx_busy
);

parameter IDLE = 2'b00 ;
parameter LOAD = 2'b01 ;
parameter RUN = 2'b10 ;
parameter STOP = 2'b11;

reg [1:0] ps,ns;

always@(posedge clk or posedge reset)begin
    if(reset) begin
        ps <= IDLE;
    end
    else 
        ps <= ns;
end

always@(*)begin
    case(ps)
    IDLE : ns = (tx_start)?LOAD:IDLE;
    LOAD : ns = RUN;
    RUN  : ns = tx_done?STOP:RUN;
    STOP : ns = IDLE;
    default : ns = IDLE;
    endcase
end
always @(*) begin

    // Default values
    load = 0;
    shift = 0;
    baud_enable = 0;
    count_enable = 0;
    tx_busy =0;

    case(ps)

        IDLE: begin
        end

        LOAD: begin
            load = 1;
            tx_busy =1;
        end

        RUN: begin
            shift = baud_tick;
            baud_enable = 1;
            count_enable = 1;
            tx_busy =1;
        end

        STOP: begin tx_busy =1;
        end

    endcase
end

endmodule
