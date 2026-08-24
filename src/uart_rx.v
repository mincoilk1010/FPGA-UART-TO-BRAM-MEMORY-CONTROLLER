module uart_rx (
    input wire clk,
    input wire arstn,
    input wire clk_en,
    output reg ready, //signal to remind outside block that the data is ready to read
    input wire ready_clr, //outside has finished reading
    input wire Rx, //data receive from transmitter
    input wire Rx_en,
    output reg [7:0] data,
    output reg error_flag
);

    initial begin
        ready = 1'b0;
        data = 8'd0;
    end

    localparam RX_IDLE = 3'd0;
    localparam RX_START = 3'd1; //Handle start bit
    localparam RX_DATA = 3'd2; //Handle 8 bit data
    localparam RX_PARITY = 3'd3; //Handle parity bit
    localparam RX_STOP = 3'd4; //Handle stop bits

    reg [2:0] state = RX_IDLE;
    reg [3:0] sample = 4'd0;
    reg [7:0] data_buffer = 8'd0;
    reg [3:0] bit_pos = 4'd0;
    reg parity_check = 1'b0;

    always @(posedge clk or negedge arstn) begin
        if(~arstn) begin
            ready <= 0;
            data <= 0; 
            error_flag <= 0;  
            sample <= 0;
            state <= RX_IDLE;
            data_buffer <= 0;
            bit_pos <= 0;
            parity_check <= 0;
        end
        else begin
            if(ready_clr) begin
                ready <= 0;
            end
            case(state)
                RX_IDLE: begin
                    if(Rx_en == 1'b1) begin
                        state <= RX_START;
                        error_flag <= 0;
                        sample <= 0;
                   end 
                end
                RX_START: begin
                    if(clk_en) begin
                        if(!Rx || sample != 0) begin
                            sample <= sample + 1;
                        end
                        if(sample == 4'd15) begin
                            state <= RX_DATA;
                            bit_pos <= 0;
                            data_buffer <= 0;
                            sample <= 0;
                        end
                    end
                end
                RX_DATA: begin
                    if(clk_en) begin
                        sample <= sample + 1;
                        if(sample == 4'd7) begin
                            data_buffer[bit_pos] <= Rx;
                        end
                        if(sample == 4'd15) begin
                            if(bit_pos == 4'd7) begin
                                state <= RX_PARITY;
                                parity_check <= ^data_buffer;
                            end
                            else begin
                            bit_pos <= bit_pos + 1;
                            end
                        end
                    end
                end
                RX_PARITY: begin 
                    if(clk_en) begin
                        sample <= sample + 1;
                        if(sample == 4'd7) begin
                            if(Rx != parity_check) begin //Parity check
                                error_flag <= 1;
                            end
                        end
                        if(sample == 4'd15) begin
                            if(error_flag) begin
                                state <= RX_IDLE;
                            end
                            else begin
                                state <= RX_STOP;
                            end
                        end
                    end
                end
                RX_STOP: begin
                    if(clk_en) begin
                        sample <= sample + 1;
                        if(sample == 4'd7) begin
                            if(Rx) begin
                                data <= data_buffer;
                                ready <= 1;
                            end
                            else begin
                                data <= 8'd0;
                                error_flag <= 1;
                            end
                        end
                        if(sample == 4'd15) begin
                            state <= RX_IDLE;
                        end
                    end
                end
            endcase
        end
    end

endmodule