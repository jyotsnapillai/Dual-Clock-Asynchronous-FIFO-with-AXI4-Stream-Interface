module axis_async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    // AXI4-Stream Slave Interface (Write Clock Domain)
    input  wire s_axis_aclk,
    input  wire s_axis_aresetn,
    input  wire [DATA_WIDTH-1:0] s_axis_tdata,
    input  wire s_axis_tvalid,
    output wire s_axis_tready,

    // AXI4-Stream Master Interface (Read Clock Domain)
    input  wire   m_axis_aclk,
    input  wire   m_axis_aresetn,
    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire  m_axis_tvalid,
    input  wire  m_axis_tready
);
    // Core FIFO Flag Signals
    wire full;
    wire empty;

   // 1. Handshake Logic Mapping
    // Write happens when master sends valid data and slave is ready (not full)
    wire wr_en = s_axis_tvalid && s_axis_tready;
    assign s_axis_tready = !full;

    // Read happens when slave has valid data (not empty) and downstream master is ready
    wire rd_en = m_axis_tvalid && m_axis_tready;
    assign m_axis_tvalid = !empty;

    // 2. Instantiate core Top-Level Dual-Clock Async FIFO
    async_fifo_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_async_fifo_top (
        .wr_clk   (s_axis_aclk),
        .wr_rst_n (s_axis_aresetn),
        .wr_en    (wr_en),
        .data_in  (s_axis_tdata),
        .full     (full),

        .rd_clk   (m_axis_aclk),
        .rd_rst_n (m_axis_aresetn),
        .rd_en    (rd_en),
        .data_out (m_axis_tdata),
        .empty    (empty)
    );

endmodule
