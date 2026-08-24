
module uart_top (
    input wire clk,
    input wire arstn,
    input wire [7:0] data_in,
    input wire Tx_en,
    output wire Tx,
    output wire Tx_busy,
    output wire ready, 
    input wire ready_clr, 
    input wire Rx, 
    input wire Rx_en,
    output wire [7:0] data,
    output wire error_flag
);
    wire Rx_clk_en, Tx_clk_en;
    baud_rate_gen uart_baud (
        .clk(clk),
        .arstn(arstn),
        .Rclk_en(Rx_clk_en),
        .Tclk_en(Tx_clk_en)
    );

    uart_tx transmitter(
        .clk(clk),
        .arstn(arstn),
        .clk_en(Tx_clk_en),
        .data_in(data_in),
        .Tx_en(Tx_en),
        .Tx(Tx),
        .Tx_busy(Tx_busy)
    );

    uart_rx receiver (
        .clk(clk),
        .arstn(arstn),
        .clk_en(Rx_clk_en),
        .ready(ready),
        .ready_clr(ready_clr),
        .Rx(Rx),
        .Rx_en(Rx_en),
        .data(data),
        .error_flag(error_flag)
    );
endmodule