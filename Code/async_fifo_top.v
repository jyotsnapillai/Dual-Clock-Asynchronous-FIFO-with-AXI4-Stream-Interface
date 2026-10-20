module async_fifo_top #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  wire                  wr_clk,
    input  wire                  wr_rst_n,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] data_in,
    output wire                  full,
    
    input  wire                  rd_clk,
    input  wire                  rd_rst_n,
    input  wire                  rd_en,
    output wire [DATA_WIDTH-1:0] data_out,
    output wire                  empty
);
    wire [ADDR_WIDTH-1:0] waddr, raddr;
    wire [ADDR_WIDTH:0]   wptr, rptr;
    wire [ADDR_WIDTH:0]   wq2_rptr, rq2_wptr;
    fifomem #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_fifomem (
        .wr_clk   (wr_clk),
        .wr_en    (wr_en),
        .full     (full),
        .wr_addr  (waddr),
        .data_in  (data_in),
        .rd_addr  (raddr),
        .data_out (data_out)
    );
    sync_r2w #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_sync_r2w (
        .wr_clk   (wr_clk),
        .wr_rst_n (wr_rst_n),
        .rptr     (rptr),
        .wq2_rptr (wq2_rptr)
    );
    sync_w2r #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_sync_w2r (
        .rd_clk   (rd_clk),
        .rd_rst_n (rd_rst_n),
        .wptr     (wptr),
        .rq2_wptr (rq2_wptr)
    );
    rptr_empty #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_rptr_empty (
        .rd_clk   (rd_clk),
        .rd_rst_n (rd_rst_n),
        .rinc     (rd_en),
        .rq2_wptr (rq2_wptr),
        .empty    (empty),
        .raddr    (raddr),
        .rptr     (rptr)
    );
    wptr_full #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_wptr_full (
        .wr_clk   (wr_clk),
        .wr_rst_n (wr_rst_n),
        .winc     (wr_en),
        .wq2_rptr (wq2_rptr),
        .full     (full),
        .waddr    (waddr),
        .wptr     (wptr)
    );

endmodule
