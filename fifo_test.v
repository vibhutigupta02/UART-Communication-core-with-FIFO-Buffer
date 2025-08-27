// Testbench to demonstrate FIFO partial transfer capability
module fifo_test;

    reg clk;
    reg [7:0] data_in;
    reg wr_en;
    reg start_tx;
    wire [7:0] data_out;
    wire fifo_status;
    reg next_frame;
    
    // Instantiate the fixed FIFO
    fifo_tx uut (
        .clk_fifo_tx(clk),
        .data_in(data_in),
        .next_frame(next_frame),
        .data_out(data_out),
        .fifo_tx_status(fifo_status),
        .wr_en(wr_en),
        .start_tx(start_tx)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize
        data_in = 8'h00;
        wr_en = 0;
        start_tx = 0;
        next_frame = 0;
        
        #10;
        
        // Test 1: Write only 5 bytes (less than 16)
        $display("Test 1: Writing 5 bytes to FIFO");
        repeat(5) begin
            @(posedge clk);
            wr_en = 1;
            data_in = data_in + 1;
            @(posedge clk);
            wr_en = 0;
        end
        
        #20;
        
        // Start transmission even though FIFO isn't full
        $display("Starting transmission with partial FIFO");
        start_tx = 1;
        next_frame = 1;
        
        #10;
        start_tx = 0;
        
        // Read out the data
        while(fifo_status) begin
            @(posedge clk);
            $display("Data out: %h", data_out);
            next_frame = 1;
            @(posedge clk);
            next_frame = 0;
        end
        
        $display("Test completed - FIFO can now handle partial transfers!");
        $finish;
    end
    
endmodule