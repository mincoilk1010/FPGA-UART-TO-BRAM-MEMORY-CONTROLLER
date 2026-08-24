
module uart_bram_ctrl (
    input wire clk,
    input wire arstn,

    //Bram communication
    output reg bram_wr_en,
    output reg [9:0] bram_address,
    output reg [7:0] bram_wr_data,
    input wire [7:0] bram_rd_data,

    //uart_rx communication (receive data from PC)
    input wire [7:0] rx_data_out, //data_out from uart_rx (this is 1 byte of data that PC send to FPGA)
    input wire rx_ready, //data_out ready to read
    output reg rx_ready_clr, //FSM finished reading data_out

    //uart_tx communication (send data from BRAM(FPGA) to PC)
    output reg [7:0] tx_data_in,
    output reg tx_en,
    input wire tx_busy
);
    /*
    //PC sent 4 bytes: [DATA][2 high bit addr][8 low bit addr][WR_EN] 
    */

    parameter RCV_WR = 3'd0;
    parameter RCV_ADDR_LOW = 3'd1; //8 bit
    parameter RCV_ADDR_HIGH = 3'd2; //2 bit -> total addr bit = 10bit
    parameter RCV_DATA = 3'd3;
    //parameter WR_DECIDE = 3'd4;
    parameter WRITE_BRAM = 3'd4;
    parameter READ_BRAM = 3'd5;
    parameter STOP = 3'd6;

    reg [2:0] state = 3'd0;
    reg [7:0] rcv_wr, rcv_addr_low, rcv_addr_high, rcv_data;
    reg [9:0] addr;
    reg wait_flag = 0;

    always @(posedge clk or negedge arstn) begin
        if(~arstn) begin
            bram_wr_en <= 0;
            bram_address <= 0;
            bram_wr_data <= 0;
            rx_ready_clr <= 0;
            tx_data_in <= 0;
            tx_en <= 0;
            state <= RCV_WR;

        end
        else begin
            case(state) 
                RCV_WR: begin
                    if(rx_ready && !rx_ready_clr) begin
                        rcv_wr <= rx_data_out;
                        rx_ready_clr <= 1;
                    end
                    else if(rx_ready_clr) begin
                        rx_ready_clr <= 0;
                        state <= RCV_ADDR_LOW;
                    end
                end
                RCV_ADDR_LOW: begin
                    if(rx_ready && !rx_ready_clr) begin
                        rcv_addr_low <= rx_data_out;
                        rx_ready_clr <= 1;
                    end
                    else if(rx_ready_clr) begin
                        rx_ready_clr <= 0;
                        state <= RCV_ADDR_HIGH;
                    end
                end
                RCV_ADDR_HIGH: begin
                    if(rx_ready && !rx_ready_clr) begin
                        rcv_addr_high <= rx_data_out;
                        rx_ready_clr <= 1;
                    end
                    else if(rx_ready_clr) begin
                        rx_ready_clr <= 0;
                        state <= RCV_DATA;
                        addr <= {rcv_addr_high[1:0],rcv_addr_low};
                    end
                end
                RCV_DATA: begin
                    bram_address <= addr;
                    if(rx_ready && !rx_ready_clr) begin
                        rcv_data <= rx_data_out;
                        rx_ready_clr <= 1;
                    end
                    else if(rx_ready_clr) begin
                        rx_ready_clr <= 0;
                        if(rcv_wr == 8'h57) begin
                            state <= WRITE_BRAM;
                        end
                        else if(rcv_wr == 8'h52) begin
                            state <= READ_BRAM;
                            //bram_address <= addr;
                        end
                    end
                end
                WRITE_BRAM: begin
                    //bram_address <= addr;
                    bram_wr_en <= 1;
                    bram_wr_data <= rcv_data;
                    state <= STOP;
                end
                READ_BRAM: begin
                    bram_wr_en <= 0;
                    tx_data_in <= bram_rd_data;
                    tx_en <= 1;
                    state <= STOP;
                end
                STOP: begin
                    bram_wr_en <= 0;
                    tx_en <= 0;
                    state <= RCV_WR;
                end
                default: begin
                    state <= RCV_WR;
                end
            endcase
        end
    end

endmodule