`timescale 1ns/1ps
module transmitter #(
    parameter BAUD_DIV = 100   // for 1 Mbps @ 100 MHz clk
)(
    input  wire [7:0] pc_t,
    input  wire       clk,
    input  wire       fifo_status,
    output reg        tx,
    output reg        dma_txend
);

    parameter tx_idle  = 2'b00,
              tx_start = 2'b01,
              tx_data  = 2'b10,
              tx_stop  = 2'b11;

    reg [1:0] mode = tx_idle;
    reg [9:0] tsr;
    integer   clk_count = 0;
    integer   index = 0;
    reg       txrdy = 1'b1;

    always @(posedge clk) begin
        case(mode)
            tx_idle: begin
                tx <= 1'b1;
                dma_txend <= 1'b1;
                if (fifo_status && txrdy) begin
                    tsr <= {1'b1, pc_t, 1'b0}; // stop + data + start
                    mode <= tx_start;
                    txrdy <= 1'b0;
                    clk_count <= 0;
                    index <= 0;
                end
            end

            tx_start, tx_data, tx_stop: begin
                tx <= tsr[index];
                if (clk_count < BAUD_DIV-1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    index <= index + 1;
                    if (index == 9) begin
                        mode <= tx_idle;
                        txrdy <= 1'b1;
                        dma_txend <= 1'b1;
                    end else begin
                        mode <= tx_data;
                    end
                end
            end
        endcase
    end

endmodule
