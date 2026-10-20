`timescale 1ns / 1ps

module tb_axis_async_fifo;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    // Slave Interface Signals (Write Domain)
    reg  s_axis_aclk;
    reg  s_axis_aresetn;
    reg  [DATA_WIDTH-1:0] s_axis_tdata;
    reg   s_axis_tvalid;
    wire  s_axis_tready;

    // Master Interface Signals (Read Domain)
    reg  m_axis_aclk;
    reg  m_axis_aresetn;
    wire [DATA_WIDTH-1:0] m_axis_tdata;
    wire m_axis_tvalid;
    reg m_axis_tready;

    // Instantiate AXI-Stream Wrapper DUT
    axis_async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .s_axis_aclk   (s_axis_aclk),
        .s_axis_aresetn(s_axis_aresetn),
        .s_axis_tdata  (s_axis_tdata),
        .s_axis_tvalid (s_axis_tvalid),
        .s_axis_tready (s_axis_tready),

        .m_axis_aclk   (m_axis_aclk),
        .m_axis_aresetn(m_axis_aresetn),
        .m_axis_tdata  (m_axis_tdata),
        .m_axis_tvalid (m_axis_tvalid),
        .m_axis_tready (m_axis_tready)
    );

    // Clock Generation
    always #5  s_axis_aclk = ~s_axis_aclk; // 100 MHz Write Clock
    always #15 m_axis_aclk = ~m_axis_aclk; // ~33.3 MHz Read Clock

    integer i;

    initial begin
        // Initialize
        s_axis_aclk    = 0;
        m_axis_aclk    = 0;
        s_axis_aresetn = 0;
        m_axis_aresetn = 0;
        s_axis_tvalid  = 0;
        s_axis_tdata   = 0;
        m_axis_tready  = 0;

        // Reset Sequence
        #50;
        s_axis_aresetn = 1;
        m_axis_aresetn = 1;
        #20;

        // --- STAGE 1: Fill FIFO with stream data ---
        $display("[%0t] STARTING AXIS WRITES...", $time);
        for (i = 1; i <= 10; i = i + 1) begin
            @(posedge s_axis_aclk);
            s_axis_tvalid <= 1'b1;
            s_axis_tdata  <= i;
            
            // Wait if FIFO becomes temporarily ready-governed
            while (!s_axis_tready) @(posedge s_axis_aclk);
            $display("[%0t] [AXIS WRITE] Sent Data = %0d", $time, i);
        end

        @(posedge s_axis_aclk);
        s_axis_tvalid <= 1'b0;

        #100;
        repeat (15) begin
            @(posedge m_axis_aclk);
            // Randomly or deterministically apply backpressure
            m_axis_tready <= ($random % 2 == 0) ? 1'b1 : 1'b0;

            if (m_axis_tvalid && m_axis_tready) begin
                $display("[%0t] [AXIS READ SUCCESS] Handshake complete! Data = %0d", $time, m_axis_tdata);
            end else if (m_axis_tvalid && !m_axis_tready) begin
                $display("[%0t] [BACKPRESSURE HELD] Valid Data (%0d) held, consumer NOT ready", $time, m_axis_tdata);
            end
        end

        // Drain remaining items cleanly
        @(posedge m_axis_aclk);
        m_axis_tready <= 1'b1;
        #200;
        $finish;
    end

endmodule
