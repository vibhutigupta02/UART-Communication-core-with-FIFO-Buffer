`timescale 1ns/1ps
module receiver #(
    parameter BAUD_DIV = 100
)(
    input  wire clk_r,
    input  wire rx,
    output reg  dma_rxend,
    output reg [7:0] data_out
);

    parameter rx_idle     = 3'b000,
              rx_start    = 3'b001,
              rx_data     = 3'b010,
              rx_stop     = 3'b011,
              rx_transfer = 3'b100;

    reg [2:0] mode_r = rx_idle;
    reg [9:0] rsr;
    reg [7:0] rhr;
    integer clk_cnt = 0;
    integer index_r = 0;
    reg rxrdy = 0;

    always @(posedge clk_r) begin
        case(mode_r)
            rx_idle: begin
                dma_rxend <= 0;
                if (rx == 1'b0) begin
                    mode_r <= rx_start;
                    clk_cnt <= 0;
                    index_r <= 0;
                end
            end

            rx_start: begin
                if (clk_cnt == (BAUD_DIV/2)) begin
                    if (rx == 1'b0) begin
                        clk_cnt <= 0;
                        mode_r <= rx_data;
                        index_r <= 0;
                    end else
                        mode_r <= rx_idle;
                end else
                    clk_cnt <= clk_cnt + 1;
            end

            rx_data: begin
                if (clk_cnt == BAUD_DIV-1) begin
                    rsr[index_r] <= rx;
                    clk_cnt <= 0;
                    if (index_r < 7) begin
                        index_r <= index_r + 1;
                    end else begin
                        mode_r <= rx_stop;
                    end
                end else
                    clk_cnt <= clk_cnt + 1;
            end

            rx_stop: begin
                if (clk_cnt == BAUD_DIV-1) begin
                    if (rx == 1'b1) begin
                        rhr <= rsr[7:0];
                        data_out <= rsr[7:0];
                        rxrdy <= 1;
                        dma_rxend <= 1;
                        mode_r <= rx_transfer;
                    end else begin
                        mode_r <= rx_idle;
                    end
                    clk_cnt <= 0;
                end else
                    clk_cnt <= clk_cnt + 1;
            end

            rx_transfer: begin
                rxrdy <= 0;
                mode_r <= rx_idle;
            end
        endcase
    end

endmodule
