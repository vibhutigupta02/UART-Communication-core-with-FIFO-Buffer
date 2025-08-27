`timescale 1ns/1ps
module fifo_tx (
    input  wire       clk_fifo_tx,
    input  wire [7:0] data_in,
    input  wire       wr_en,
    input  wire       start_tx,
    input  wire       next_frame,
    output reg  [7:0] data_out,
    output reg        fifo_tx_status
);

    reg [7:0] mem [0:15];
    reg [3:0] wr_ptr = 0;
    reg [3:0] rd_ptr = 0;
    reg [4:0] count  = 0;

    always @(posedge clk_fifo_tx) begin
        if (wr_en) begin
            mem[wr_ptr] <= data_in;
            wr_ptr <= wr_ptr + 1;
            if (count < 16) count <= count + 1;
        end
        if (next_frame || start_tx) begin
            if (count > 0) begin
                data_out <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count <= count - 1;
                fifo_tx_status <= 1'b1;
            end else begin
                fifo_tx_status <= 1'b0;
            end
        end
    end

endmodule
