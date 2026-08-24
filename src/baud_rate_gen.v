module baud_rate_gen (
    input wire clk,
    input wire arstn,
    output wire Rclk_en, //clk_en in receiver with sample
    output wire Tclk_en //clk_en in transmitter
);

    //parameter RX_ACC_MAX = 27000000/(9600*16);
    parameter RX_ACC_MAX = 176;
    // parameter RX_ACC_WIDTH = $clog2(RX_ACC_MAX);
    parameter RX_ACC_WIDTH = 8;
    

    reg [RX_ACC_WIDTH-1:0] rx_acc = 0;
    //reg [TX_ACC_WIDTH-1:0] tx_acc = 0;
    reg [3:0] tx_acc = 0;

    assign Rclk_en = (rx_acc == 0);
    assign Tclk_en = (tx_acc == 0) && (Rclk_en);

    always @(posedge clk or negedge arstn) begin
        if(~arstn) begin
            rx_acc <= 0;
        end
        else begin
            if(rx_acc == RX_ACC_MAX -1) begin
            rx_acc <= 0;
            end
            else begin
                rx_acc <= rx_acc + 1;
          end
        end
    end

    always @(posedge clk or negedge arstn) begin
        if(~arstn) begin
            tx_acc <= 0;
        end
        else begin
            if(Rclk_en) begin
                tx_acc <= tx_acc + 1;
            end
        end
    end
endmodule