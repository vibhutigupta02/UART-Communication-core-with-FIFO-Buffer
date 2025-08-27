`timescale 1ns/1ps
module uart (
    input  wire       clk,
    input  wire [7:0] pc_in_t,
    input  wire       wr_en,
    input  wire       start_tx,
    output wire [7:0] pc_out_r,
    output wire       tx,
    input  wire       rx,
    output wire       rx_done
);

    wire [7:0] data;
    wire fifo_status;
    wire dma_txend;

    fifo_tx ft (
        .clk_fifo_tx(clk),
        .data_in(pc_in_t),
        .wr_en(wr_en),
        .start_tx(start_tx),
        .next_frame(dma_txend),
        .data_out(data),
        .fifo_tx_status(fifo_status)
    );

    transmitter #(.BAUD_DIV(100)) t (
        .pc_t(data),
        .clk(clk),
        .fifo_status(fifo_status),
        .tx(tx),
        .dma_txend(dma_txend)
    );

    receiver #(.BAUD_DIV(100)) r (
        .clk_r(clk),
        .rx(tx), // loopback
        .dma_rxend(rx_done),
        .data_out(pc_out_r)
    );

endmodule
