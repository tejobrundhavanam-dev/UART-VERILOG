module shift_register_rx(
    input clk,
    input reset,
    input shift_enable,
    input serial_in,
    input rx_done_int,
    output reg [7:0] rx_data
);

    reg [7:0] shift_reg;

    always@(posedge clk or posedge reset)begin
        if(reset) begin 
            shift_reg <= 0;
            rx_data <= 0;
        end
        else begin
            if(shift_enable) begin
                shift_reg <= {serial_in, shift_reg[7:1]};
                if (rx_done_int)
                    rx_data <= {serial_in, shift_reg[7:1]};  // capture the fully-updated byte
            end
            else if (rx_done_int) begin
                rx_data <= shift_reg;
            end
        end
    end

endmodule