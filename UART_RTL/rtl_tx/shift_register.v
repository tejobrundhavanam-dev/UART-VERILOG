//=============================================================
// Module : shift_register
//
// Description:
// Stores UART frame
// {Stop, Data[7:0], Start}
//
// Shifts one bit every baud tick.
//=============================================================
module shift_register (
    input        clk,
    input        reset,
    input        load,
    input        shift,
    input  [7:0] tx_data,
    output       serial_out
);

    reg [9:0] shift_reg;

    assign serial_out = shift_reg[0];

    always @(posedge clk or posedge reset) begin
        if (reset)
            shift_reg <= 10'b11111_11111;
        else if (load)
            shift_reg <= {1'b1, tx_data, 1'b0};
        else if (shift)
            shift_reg <= {1'b1, shift_reg[9:1]};
    end

endmodule