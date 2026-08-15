module bit_counter(
    output tx_done,
    input clk ,
    input reset,
    input count_enable,
    input baud_tick
);

    reg [3:0]bit_cnt;

always@(posedge clk or posedge reset)begin
    if(reset || !count_enable)begin
        bit_cnt <= 0;
    end
    else if(baud_tick)begin
        if (bit_cnt == 4'd9)begin
            bit_cnt <= 4'd0;
    end
        else
            bit_cnt <= bit_cnt + 1'd1;
    end
end

assign tx_done = (count_enable && baud_tick && bit_cnt == 4'd9 );

endmodule
