`timescale 1ns / 1ps
module tb_async_fifo;
parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 4;
reg  wr_clk;
reg wr_rst_n;
reg wr_en;
reg [DATA_WIDTH-1:0] data_in;
reg  rd_clk;
reg  rd_rst_n;
reg   rd_en;
wire   full;
wire   empty;
wire [DATA_WIDTH-1:0] data_out;
async_fifo_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .data_in(data_in),
        .full(full),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .data_out(data_out),
        .empty(empty)
    );
always #5 wr_clk = ~wr_clk;
always #15 rd_clk = ~rd_clk;
integer i;
initial begin
        wr_clk   = 0;
        rd_clk   = 0;
        wr_rst_n = 0;
        rd_rst_n = 0;
        wr_en    = 0;
        rd_en    = 0;
        data_in  = 0;
        #50;
        wr_rst_n <= 1’b1;
        rd_rst_n< = 1’b1;
        #20;
for (i=1;i<=16;i=i+1)
begin
@(posedge wr_clk);
if(!full)
begin
wr_en<=1’b1;
data_in<=i;
end 
end
@(posedge wr_clk);
wr_en<=0;
#100;
for (i = 1; i <= 16; i = i + 1) begin
@(posedge rd_clk);
if (!empty) begin
rd_en <= 1’b1;
end
end
@(posedge rd_clk);
rd_en = 0;
  #100;
$finish;
end
endmodule



