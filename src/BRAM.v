module BRAM 
#(
    parameter RAM_WIDTH = 8,
    parameter RAM_DEPTH = 1024 //-> length_of_address = 10 bit
)
(
    input wire clk,
    input wire wr_en,
    input wire [$clog2(RAM_DEPTH)-1:0] addr,
    input wire [RAM_WIDTH-1:0] wr_data,
    output reg [RAM_WIDTH-1:0] rd_data
);

    reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];

    always @(posedge clk) begin
        if(wr_en) begin
            BRAM[addr] <= wr_data;
        end
        else begin
            rd_data <= BRAM[addr];
        end
    end
endmodule