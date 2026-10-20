module wptr_full #(
parameter ADDR_WIDTH=4)(
wr_clk,wr_rst_n,winc,wq2_rptr,full,waddr,wptr);
input wr_clk;
input wr_rst_n;
input winc;
input [ADDR_WIDTH:0] wq2_rptr;
output reg full;
output [ADDR_WIDTH-1:0] waddr;
output reg [ADDR_WIDTH:0] wptr;
reg [ADDR_WIDTH:0] wbin;
wire [ADDR_WIDTH:0] wbin_next;
wire [ADDR_WIDTH:0] wgray_next;
wire wfull_val;
assign wbin_next = wbin + (winc & ~full);
assign wgray_next = wbin_next ^ (wbin_next >> 1);
assign waddr = wbin[ADDR_WIDTH-1:0];
assign wfull_val = (wgray_next == {~wq2_rptr[ADDR_WIDTH:ADDR_WIDTH-1], wq2_rptr[ADDR_WIDTH-2:0]});
always @(posedge wr_clk or negedge wr_rst_n)
begin
if(!wr_rst_n)
begin
wbin<=0;
wptr <=0;
full<=1'b0;
end
else
begin 
wbin<=wbin_next;
wptr<=wgray_next;
full <= wfull_val;
end
end
endmodule
