`timescale 1ns / 1ps

module uart_bram_top_tb ();

    reg clk;
    reg arstn;
    reg rx_pin;

    wire tx_pin;
    wire rx_error_flag;
    wire tx_busy;
    wire tx_en;

    parameter BAUD_RATE = 9600;
    parameter BAUD_PERIOD = 1000000000.0/BAUD_RATE;

    uart_bram_top testbench (
        .clk(clk),
        .arstn(arstn),
        .rx_pin(rx_pin),
        .tx_pin(tx_pin),
        .rx_error_flag(rx_error_flag),
        .tx_busy(tx_busy),
        .tx_en(tx_en)                                                                                                                                                                  
    );

    //clk gen 27 MHz
    initial begin
        clk = 0;
        forever #18.5185 clk = ~clk;
    end

    //Simulation PC send 1 byte
    task send_uart_byte (input [7:0] data_byte);
        integer i;
        reg parity_bit;
        begin
            rx_pin = 0;
            #(BAUD_PERIOD);

            for(i=0; i<8; i++) begin
                rx_pin = data_byte[i];
                #(BAUD_PERIOD);
            end
            parity_bit = ^data_byte;

            rx_pin = parity_bit;
            #(BAUD_PERIOD);

            rx_pin = 1;
            #(BAUD_PERIOD);

            #(BAUD_PERIOD * 2);
            
        end
    endtask

    initial begin
        $dumpfile("uart_bram_sim.vcd");
        $dumpvars(0, uart_bram_top_tb);
        // --- KHỞI TẠO ---
        arstn = 0;
        rx_pin = 1; // Trạng thái nghỉ (Idle) của UART là mức cao
        
        repeat (100) @(posedge clk);
        arstn = 1; // Nhả Reset
        repeat (100) @(posedge clk);

        $display("[%0t] --- SIMULATION START ---", $time);

        // --------------------------------------------------
        // PHASE 1: MASS WRITE
        // --------------------------------------------------
        $display("[%0t] --- PHASE 1: MASS WRITE ---", $time);
        
        $display("[%0t] PC: WRITE cmd, addr = 10 (0x0A), data = 0x99", $time);
        send_uart_byte(8'h57); // 'W'
        send_uart_byte(8'h0A); // Addr L
        send_uart_byte(8'h00); // Addr H
        send_uart_byte(8'h99); // Data
        #(BAUD_PERIOD * 5);

        $display("[%0t] PC: WRITE cmd, addr = 20 (0x14), data = 0xAA", $time);
        send_uart_byte(8'h57); // 'W'
        send_uart_byte(8'h14); // Addr L
        send_uart_byte(8'h00); // Addr H
        send_uart_byte(8'hAA); // Data
        #(BAUD_PERIOD * 5);

        $display("[%0t] PC: WRITE cmd, addr = 128 (0x80), data = 0x55", $time);
        send_uart_byte(8'h57); // 'W'
        send_uart_byte(8'h80); // Addr L
        send_uart_byte(8'h00); // Addr H
        send_uart_byte(8'h55); // Data
        #(BAUD_PERIOD * 5);

        $display("[%0t] PC: WRITE cmd, addr = 512 (0x200), data = 0x66", $time);
        send_uart_byte(8'h57); // 'W'
        send_uart_byte(8'h00); // Addr L
        send_uart_byte(8'h02); // Addr H
        send_uart_byte(8'h66); // Data
        #(BAUD_PERIOD * 5);

        $display("[%0t] PC: WRITE cmd, addr = 1023 (0x3FF), data = 0x77", $time);
        send_uart_byte(8'h57); // 'W'
        send_uart_byte(8'hFF); // Addr L
        send_uart_byte(8'h03); // Addr H
        send_uart_byte(8'h77); // Data
        #(BAUD_PERIOD * 5);

        // --------------------------------------------------
        // PHASE 2: MASS READ & VERIFY
        // --------------------------------------------------
        $display("[%0t] --- PHASE 2: MASS READ & VERIFY ---", $time);

        $display("[%0t] PC: READ cmd, addr = 10 (0x0A)", $time);
        send_uart_byte(8'h52); // 'R'
        send_uart_byte(8'h0A); // Addr L
        send_uart_byte(8'h00); // Addr H
        send_uart_byte(8'h00); // Dummy Data
        #(BAUD_PERIOD * 20);  

        $display("[%0t] PC: READ cmd, addr = 20 (0x14)", $time);
        send_uart_byte(8'h52); 
        send_uart_byte(8'h14); 
        send_uart_byte(8'h00); 
        send_uart_byte(8'h00); 
        #(BAUD_PERIOD * 20);

        $display("[%0t] PC: READ cmd, addr = 128 (0x80)", $time);
        send_uart_byte(8'h52); 
        send_uart_byte(8'h80); 
        send_uart_byte(8'h00); 
        send_uart_byte(8'h00); 
        #(BAUD_PERIOD * 20);

        $display("[%0t] PC: READ cmd, addr = 512 (0x200)", $time);
        send_uart_byte(8'h52); 
        send_uart_byte(8'h00); 
        send_uart_byte(8'h02); 
        send_uart_byte(8'h00); 
        #(BAUD_PERIOD * 20);

        $display("[%0t] PC: READ cmd, addr = 1023 (0x3FF)", $time);
        send_uart_byte(8'h52); 
        send_uart_byte(8'hFF); 
        send_uart_byte(8'h03); 
        send_uart_byte(8'h00); 
        #(BAUD_PERIOD * 20);

        // --------------------------------------------------
        // PHASE 3: READ UNWRITTEN ADDRESS
        // --------------------------------------------------
        $display("[%0t] --- PHASE 3: READ UNWRITTEN ADDRESS ---", $time);

        $display("[%0t] PC: READ cmd, addr = 50 (0x32)", $time);
        send_uart_byte(8'h52); 
        send_uart_byte(8'h32); 
        send_uart_byte(8'h00); 
        send_uart_byte(8'h00); 
        #(BAUD_PERIOD * 20);
        
        $display("[%0t] --- END OF SIMULATION ---", $time);
        $finish;
    end
endmodule