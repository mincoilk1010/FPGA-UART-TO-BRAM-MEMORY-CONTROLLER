module uart_tx (
    input wire clk,
    input wire arstn,
    input wire clk_en,
    input wire [7:0] data_in,
    input wire Tx_en,
    output reg Tx,
    output wire Tx_busy
);
    //In IDLE State, Tx always on high
    initial begin
        Tx = 1'b1;
    end

    localparam TX_IDLE = 3'd0;
    localparam TX_START = 3'd1;
    localparam TX_DATA = 3'd2;
    localparam TX_PARITY = 3'd3; 
    localparam TX_STOP = 3'd4;

    reg [2:0] bit_pos = 3'd0; 
    reg [2:0] state = TX_IDLE;
    reg [7:0] data_buffer = 8'd0;
    reg parity_check = 0;
    reg [1:0] count = 2'd0;

    always @(posedge clk or negedge arstn) begin
        if(~arstn) begin
            Tx <= 1'b1;
            bit_pos <= 3'd0;
            state <= TX_IDLE;
            data_buffer <= 8'd0;
            count <= 0;
        end
        else begin
            case(state) 
                TX_IDLE: begin
                    Tx <= 1'b1;
                    if(Tx_en) begin
                        state <= TX_START;
                        data_buffer <= data_in;
                    end
                end
                TX_START: begin
                    if(clk_en) begin
                        Tx <= 1'b0;
                        state <= TX_DATA;
                        bit_pos <= 3'd0;
                    end
                end
                TX_DATA: begin
                    if(clk_en) begin
                        Tx <= data_buffer[bit_pos];
                        bit_pos <= bit_pos + 1;
                        if(bit_pos == 3'd7) begin
                            state <= TX_PARITY;
                            parity_check <= ^data_buffer;
                        end
                    end
                end
                TX_PARITY: begin
                    if(clk_en) begin
                        Tx <= parity_check;
                        state <= TX_STOP;
                    end
                end
                TX_STOP: begin
                    if(clk_en) begin
                        Tx <= 1'b1;
                        state <= TX_IDLE;
                    end
                end
                default: state <= TX_IDLE;
            endcase
        end
    end

    assign Tx_busy = (state != TX_IDLE);

endmodule