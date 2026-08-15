module bit_counter_rx(
    output rx_done,
    input clk ,
    input reset,
    input count_enable,
    input timer_tick
);

    reg [2:0]bit_cnt;

always@(posedge clk or posedge reset)begin
    if(reset || !count_enable)begin
        bit_cnt <= 0;
    end
    else if(timer_tick)begin
        if (bit_cnt == 3'd7)begin
            bit_cnt <= 3'd0;
    end
        else
            bit_cnt <= bit_cnt + 1'd1;
    end
end

assign rx_done = (count_enable && timer_tick && bit_cnt == 3'd7 );

endmodule
