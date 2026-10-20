module sync_r2w(wr_clk,wr_rst_n,rptr,wq2_rptr);
parameter ADDR_WIDTH=4;
input wr_clk;
input wr_rst_n;
input [ADDR_WIDTH:0]rptr;
output reg [ADDR_WIDTH:0] wq2_rptr;
reg [ADDR_WIDTH:0] wq1_rptr;
always @(posedge wr_clk or negedge wr_rst_n)
begin
if (!wr_rst_n)
begin
wq1_rptr<=0;
wq2_rptr<=0;
end
else
begin
wq1_rptr<=rptr;
wq2_rptr<=wq1_rptr;
end
end
endmodule
