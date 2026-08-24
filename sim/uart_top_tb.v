`timescale 1ns / 1ps
module uart_top_tb ();

    reg [7:0] data_in = 8'b01100001;
    reg clk = 0;
    reg arstn = 0;
    reg ready_clr = 0;
    reg Rx_en = 0;
    reg enable = 0;

    wire Tx, Tx_busy, ready, error_flag, loopback;
    wire [7:0] data;

    uart_top test_uart (
        .clk(clk),
        .arstn(arstn),
        .data_in(data_in),
        .Tx_en(enable),
        .Tx(loopback),
        .Tx_busy(Tx_busy),
        .ready(ready),
        .ready_clr(ready_clr),
        .Rx(loopback),
        .Rx_en(Rx_en),
        .data(data),
        .error_flag(error_flag)
    );

    // CLK gen 27 MHz
    always begin
        #18.5185 clk = ~clk;
    end

    initial begin
        $dumpfile ("uart.vcd");
        $dumpvars (0, uart_top_tb);
        
        // Reset operation
        arstn <= 1'b0;           
        enable <= 1'b0;
        Rx_en <= 1'b0;
        repeat (5) @(posedge clk);  
        arstn <= 1'b1;           
        
        repeat (5) @(posedge clk);
    
        //start to transmit data
        enable <= 1'b1;
        Rx_en <= 1'b1;
        repeat (2) @(posedge clk);
        enable <= 1'b0;
    end

    //Data checking
    always @(posedge ready) begin
        @(posedge clk);
        ready_clr <= 1'b1;
        @(posedge clk);
        ready_clr <= 1'b0;

        if(data != data_in) begin
            $display("FAIL: rx data %x does not match tx %x", data, data_in);
            $finish; // Stop simulation
        end
        else begin
            if(data == 8'd122) begin
                $display("SUCCESS: all bytes verified");
                $finish; //Done test
            end
            
            data_in <= data_in + 1'b1; 
            
            enable <= 1'b1;
            Rx_en <= 1'b1;

            repeat(2) @ (posedge clk);
            enable <= 1'b0;
        end
    end    
endmodule