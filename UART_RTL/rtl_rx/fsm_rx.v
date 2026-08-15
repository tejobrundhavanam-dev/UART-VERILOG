//=============================================================
// Module : fsm_rx
//
// Description:
// UART Receiver Controller
//
// Detects start bit,
// waits half-bit,
// samples 8 data bits,
// checks stop bit,
// reports framing errors.
//=============================================================
module fsm_rx(
    input clk,
    input reset,
    input rx_done,
    input start_detect,
    input timer_tick,
    input serial_in,
    output reg half_bit_enable,
    output reg full_bit_enable,
    output reg shift_enable,
    output reg count_enable,
    output reg rx_done_out,
    output reg framing_error
);

localparam IDLE = 3'd0;       // Waiting for start bit
localparam CHECK = 3'd1;      // Validate start bit
localparam RUN = 3'd2;        // Receive 8 bits
localparam CHECK_STOP = 3'd3; // Verify stop bit
localparam F_ERROR = 3'd4;    // Framing error
localparam DONE = 3'd5;       // Reception complete

reg [2:0] ps,ns;

always@(posedge clk or posedge reset)begin
    if (reset)  ps <= IDLE;
    else ps <= ns;
end
always@(*)begin
    ns = ps;
    case(ps)
    IDLE        : ns = (start_detect)?CHECK:IDLE;
    CHECK       : begin
                  if (timer_tick)begin
                    if (!serial_in) 
                    ns = RUN;
                    else 
                        ns = IDLE;
                  end

                else
                    ns = CHECK;
                  end

    RUN         : ns =  rx_done?CHECK_STOP:RUN;
    CHECK_STOP  : begin
                  if (timer_tick)begin
                    if (serial_in) 
                    ns = DONE;
                    else begin
                        ns = F_ERROR;
                        end

                  end

                else
                    ns = CHECK_STOP;
                  end
    F_ERROR     : ns = IDLE;             
    DONE        : ns = IDLE;
    default     : ns = IDLE;
    endcase
end
always@(*)begin
    half_bit_enable = 0;
    full_bit_enable = 0;
    shift_enable = 0;
    count_enable = 0;
    rx_done_out = 0;
    framing_error=0;
    case(ps)
    IDLE : begin
            end
    CHECK : half_bit_enable = 1;
    
    RUN   : begin
        full_bit_enable = 1;
        count_enable = 1'b1;
        shift_enable = timer_tick;
    end
    CHECK_STOP :begin full_bit_enable = 1;
    end
    F_ERROR    : begin framing_error = 1 ;
    end
    DONE : begin
        rx_done_out =1'b1;
    end
    
    endcase
end
endmodule



