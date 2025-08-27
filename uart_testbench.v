`timescale 1ns/1ps
module uart_test;

    reg clk;
    reg [7:0] pc_in_t;
    reg wr_en;
    reg start_tx;
    wire [7:0] pc_out_r;
    wire tx;
    wire rx_done;

    uart uut (
        .clk(clk),
        .pc_in_t(pc_in_t),
        .wr_en(wr_en),
        .start_tx(start_tx),
        .pc_out_r(pc_out_r),
        .tx(tx),
        .rx(tx),     // loopback
        .rx_done(rx_done)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        wr_en = 0;
        start_tx = 0;
        pc_in_t = 8'h00;
        #20;

        // send A5
        pc_in_t = 8'hA5;
        wr_en = 1; start_tx = 1;
        #10;
        wr_en = 0; start_tx = 0;

        // wait 100 us then send 3C
        #100000;
        pc_in_t = 8'h3C;
        wr_en = 1; start_tx = 1;
        #10;
        wr_en = 0; start_tx = 0;

        #500000; // run long enough
        $finish;
    end

    always @(posedge rx_done) begin
        $display("[%0t ns] Received byte: %h", $time, pc_out_r);
    end

endmodule
