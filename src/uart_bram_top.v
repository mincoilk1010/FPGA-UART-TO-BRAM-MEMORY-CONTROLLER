

module uart_bram_top (
    input wire clk,
    input wire arstn,
    input wire rx_pin, //receive cmd+addr+data from PC
    output wire tx_pin, //transfer data from BRAM to PC
    output wire rx_error_flag,
    output wire tx_busy,
    output wire tx_en
);
    wire bram_wr_en;
    wire [9:0] bram_addr;
    wire [7:0] bram_wr_data;
    wire [7:0] bram_rd_data;

    wire clk_en_rx, clk_en_tx;
    wire ready;
    wire ready_clr;
    wire [7:0] rx_data_out;
    wire [7:0] tx_data_in;
    

    uart_bram_ctrl FSM (
        .clk(clk),
        .arstn(arstn),
        .bram_wr_en(bram_wr_en),
        .bram_address(bram_addr),
        .bram_wr_data(bram_wr_data),
        .bram_rd_data(bram_rd_data),
        .rx_data_out(rx_data_out),
        .rx_ready(ready),
        .rx_ready_clr(ready_clr),
        .tx_data_in(tx_data_in),
        .tx_en(tx_en),
        .tx_busy(tx_busy)
    );

    baud_rate_gen baud_gen (
        .clk(clk),
        .arstn(arstn),
        .Rclk_en(clk_en_rx),
        .Tclk_en(clk_en_tx)
    );

    uart_rx rcv (
        .clk(clk),
        .arstn(arstn),
        .clk_en(clk_en_rx),
        .ready(ready),
        .ready_clr(ready_clr),
        .Rx(rx_pin),
        .Rx_en(1'b1),
        .data(rx_data_out),
        .error_flag(rx_error_flag)
    );

    uart_tx transmit (
        .clk(clk),
        .arstn(arstn),
        .clk_en(clk_en_tx),
        .data_in(tx_data_in),
        .Tx_en(tx_en),
        .Tx(tx_pin),
        .Tx_busy(tx_busy)
    );

    BRAM #(
        .RAM_WIDTH(8),
        .RAM_DEPTH(1024)
    )
    bram (
        .clk(clk),
        .wr_en(bram_wr_en),
        .addr(bram_addr),
        .wr_data(bram_wr_data),
        .rd_data(bram_rd_data)
    );

endmodule