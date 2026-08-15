module tb;

    localparam CLK_FREQ  = 50_000_000;
    localparam BAUD_RATE = 115200;

    reg clk = 0;
    reg reset = 1;
    reg [7:0] tx_data = 0;
    reg tx_start = 0;
    reg clear_framing_error = 0;

    wire [7:0] rx_data;
    wire rx_done;
    wire tx_busy;
    wire framing_error;
    wire framing_error_sticky;

    integer pass_count = 0;
    integer fail_count = 0;

    UART_TOP #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) top1 (
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .clear_framing_error(clear_framing_error),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .tx_busy(tx_busy),
        .framing_error(framing_error),
        .framing_error_sticky(framing_error_sticky)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("topwave.vcd");
        $dumpvars;
    end

   task send_byte(input [7:0] data);
    begin
        $display("t=%0t  >>> send_byte START, data=%h", $time, data);   // NEW

        @(posedge clk);
        tx_data  = data;
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;

        @(posedge rx_done);
        #1;

        if (!framing_error && rx_data == data) begin
            $display("[PASS] Sent %h, Received %h", data, rx_data);
            pass_count = pass_count + 1;
        end
        else begin
            $display("[FAIL] Sent %h, Received %h, framing_error=%b", data, rx_data, framing_error);
            fail_count = fail_count + 1;
        end

        wait (tx_busy == 0);
        @(posedge clk);

        $display("t=%0t  <<< send_byte END, data=%h", $time, data);    // NEW
    end
endtask


initial begin
    #500000;
    $display("### WATCHDOG TIMEOUT at t=%0t ###", $time);
    $finish;
end


    initial begin : main
        reg [7:0] test_bytes [0:4];
        integer i;

        test_bytes[0] = 8'hA5;
        test_bytes[1] = 8'h00;
        test_bytes[2] = 8'hFF;
        test_bytes[3] = 8'h3C;
        test_bytes[4] = 8'h81;

        repeat(2) @(posedge clk);
        reset = 0;
        
        repeat(3) @(posedge clk);

        $display("---- TEST 1: Back-to-back multi-byte transfer ----");
        for (i = 0; i < 5; i = i + 1) begin
            send_byte(test_bytes[i]);
        end

        

        $display("---- TEST 2: Overlapping tx_start ignored while busy ----");
        @(posedge clk);
        tx_data  = 8'h55;
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;

        @(posedge top1.tx.uut2.baud_tick); 
        tx_data  = 8'h99;
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;

        @(posedge rx_done);
        #1;
        if (!framing_error && rx_data == 8'h55) begin
            $display("[PASS] Overlap ignored correctly. Received %h", rx_data);
            pass_count = pass_count + 1;
        end
        else begin
            $display("[FAIL] Overlap not ignored. Received %h, framing_error=%b", rx_data, framing_error);
            fail_count = fail_count + 1;
        end
        wait (tx_busy == 0);
        @(posedge clk);
        

        

        $display("---- TEST 3: Corrupted stop bit (forced framing error) ----");
        tx_data  = 8'h3F;
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;

        @(posedge top1.tx.uut3.tx_done);
        force top1.serial_wire = 1'b0;

        @(posedge rx_done or posedge framing_error);
        #1;

        if (framing_error) begin
            $display("[PASS] framing_error correctly asserted on corrupted stop bit");
            pass_count = pass_count + 1;
        end
        else begin
            $display("[FAIL] framing_error did NOT assert on corrupted stop bit");
            fail_count = fail_count + 1;
        end

        release top1.serial_wire;
        wait (tx_busy == 0);
        @(posedge clk);
        

        

        $display("---- TEST 4: Sticky framing_error flag ----");
        if (framing_error_sticky) begin
            $display("[PASS] framing_error_sticky is still set after TEST 3");
            pass_count = pass_count + 1;
        end
        else begin
            $display("[FAIL] framing_error_sticky was not latched");
            fail_count = fail_count + 1;
        end

        clear_framing_error = 1;
        @(posedge clk);
        clear_framing_error = 0;
        @(posedge clk);

        if (!framing_error_sticky) begin
            $display("[PASS] framing_error_sticky cleared correctly");
            pass_count = pass_count + 1;
        end
        else begin
            $display("[FAIL] framing_error_sticky did not clear");
            fail_count = fail_count + 1;
        end

        $display("=======================================");
        $display("TOTAL PASS = %0d, TOTAL FAIL = %0d", pass_count, fail_count);
        $display("=======================================");
        

        $finish;
    end

endmodule