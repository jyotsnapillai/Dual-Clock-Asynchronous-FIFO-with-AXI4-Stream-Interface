module rptr_empty #(
parameter ADDR_WIDTH=4)(
rd_clk,rd_rst_n,rinc,rq2_wptr,empty,raddr,rptr);
input rd_clk;
input rd_rst_n;
input rinc;
input [ADDR_WIDTH:0] rq2_wptr;
output reg empty;
output [ADDR_WIDTH-1:0] raddr;
output reg [ADDR_WIDTH:0] rptr;
reg [ADDR_WIDTH:0] rbin;
wire [ADDR_WIDTH:0] rbin_next;
wire [ADDR_WIDTH:0] rgray_next;
wire rempty_val;
assign rbin_next = rbin + (rinc & ~empty);
assign rgray_next = rbin_next ^ (rbin_next >> 1);
assign raddr = rbin[ADDR_WIDTH-1:0];
assign rempty_val = (rgray_next == rq2_wptr);
always @(posedge rd_clk or negedge rd_rst_n)
begin
if(!rd_rst_n)
begin
rbin<=0;
rptr <=0;
empty <= 1'b1;
end
else
begin 
rbin<=rbin_next;
rptr<=rgray_next;
empty <= rempty_val;
end
end
endmodule
