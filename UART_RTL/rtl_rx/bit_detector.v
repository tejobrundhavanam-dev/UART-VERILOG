module start_bit(
    output reg start_detect=0,
    input clk,
    input reset,
    input serial_in
);
    reg serial_prev;

   always@(posedge clk)begin
    if (reset) begin
        serial_prev <=1;
        start_detect<=0;
    end
    else begin
    serial_prev <= serial_in;
    if((serial_prev)&&(!serial_in)) begin
        start_detect <= 1'b1;
        
    end
    else start_detect <= 0 ;
    end



   end
endmodule