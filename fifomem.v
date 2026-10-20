module fifomem (wr_clk,wr_en,full,wr_addr,data_in,rd_addr,data_out)
parameter DATA_WIDTH=8;
parameter ADDR_WIDTH=4;
input wr_clk;
input wr_en;
input full;
input [ADDR_WIDTH-1:0] wr_addr;
input [ADDR_WIDTH-1:0] rd_addr;
input [DATA_WIDTH-1:0] data_in;
output wire [DATA_WIDTH-1:0] data_out;
reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
always @(posedge wr_clk)
begin
if(wr_en && !full)
begin
mem[wr_addr]<=data_in;
end
end 
assign data_out = mem[rd_addr];
endmodule
