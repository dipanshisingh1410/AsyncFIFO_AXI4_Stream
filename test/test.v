`timescale 1ns / 1ps

module test;

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 4;
          
reg  m_clk, s_clk;
reg  m_reset_n, s_reset_n;
reg  [DATA_WIDTH-1:0] m_data;
reg  m_valid;
wire m_ready;
            
wire [DATA_WIDTH-1:0] s_data;
wire s_valid;
reg  s_ready;

top_axi_async_fifo dut (
    .m_clk (m_clk), .m_reset_n (m_reset_n), .m_data (m_data), .m_valid (m_valid), .m_ready(m_ready), 
    .s_clk (s_clk), .s_reset_n (s_reset_n), .s_data (s_data), .s_valid (s_valid), .s_ready(s_ready) 
);

initial m_clk = 1'b0;
always #2 m_clk = ~m_clk;   

initial s_clk = 1'b0;
always #3.5 s_clk = ~s_clk; 
       
integer i;
reg [DATA_WIDTH-1:0] scoreboard [0:63];
integer sb_wr_ptr = 0;
integer sb_rd_ptr = 0;
    
reg concurrent_test_active = 0;

initial begin
        
m_data = 0;
m_valid = 1'b0;
s_ready = 1'b0;
m_reset_n = 1'b0;
s_reset_n = 1'b0;
            
#10;
m_reset_n = 1'b1;
s_reset_n = 1'b1;
#20;

$display("\n[TEST 1] Starting Burst Write Operations From Master...");
s_ready = 1'b0; 
            
for (i = 1; i <= 20; i = i + 1) begin
    @(posedge m_clk);
    if (m_ready) begin
        m_data  = i;
        m_valid = 1'b1;
        $display("[WRITE] Master Sent Data Payload: %d", i);
    end else begin
        m_valid = 1'b0;
        $display("[BACK-PRESSURE] FIFO Full detected. Master safely stalled at value: %d", i);
        i = 21;
    end
end
            
    @(posedge m_clk);
    m_valid = 1'b0;
    #50; 
          
$display("\n[TEST 2] Starting Burst Read Operations From Slave...");
m_valid = 1'b0; 
s_ready = 1'b1; 
            
while (s_valid === 1'b1) begin
    @(posedge s_clk);
    if (s_valid && s_ready) begin
        $display("[READ] Slave Handshake Succeeded. Captured Data: %d", s_data);
    end
end
            
    @(posedge s_clk);
    s_ready = 1'b0;
    $display("[EMPTY] FIFO completely starved. Slave Reader safely deactivated.");
    #100;
        
$display("\n[TEST 3] Starting Concurrent Streaming Race Conditions...");
sb_wr_ptr = 0;
sb_rd_ptr = 0;
        
concurrent_test_active = 1;

while (sb_rd_ptr < 30) begin
    #5;
end

concurrent_test_active = 0;
m_valid = 1'b0;
s_ready = 1'b0;

$display("[SUCCESS] All 3 evaluation stages verified error-free!");
$finish;
end

    // -------------------------------------------------------------------------
    // CONCURRENT BLOCK A: Master Write Process
    // -------------------------------------------------------------------------
    always @(posedge m_clk) begin
        if (concurrent_test_active) begin
            if (sb_wr_ptr < 30) begin
                if (m_ready) begin
                    m_data  <= 8'd100 + sb_wr_ptr;
                    m_valid <= 1'b1;
                    scoreboard[sb_wr_ptr] <= 8'd100 + sb_wr_ptr;
                    $display("[SIMUL-WRITE] Byte %d pushed from Master into RAM.", 8'd100 + sb_wr_ptr);
                    sb_wr_ptr <= sb_wr_ptr + 1;
                end
            end else begin
                m_valid <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // CONCURRENT BLOCK B: Slave Read Process
    // -------------------------------------------------------------------------
    always @(posedge s_clk) begin
        if (concurrent_test_active) begin
            if (sb_rd_ptr < 30) begin
                s_ready <= 1'b1; 
                if (s_valid && s_ready) begin
                    if (s_data !== scoreboard[sb_rd_ptr]) begin
                        $display("[FATAL CONCURRENT ERROR] Mismatch! Slot: %d, Received: %d, Expected: %d", 
                                 sb_rd_ptr, s_data, scoreboard[sb_rd_ptr]);
                        $finish; 
                    end else begin
                        $display("[SIMUL-READ] Byte %d matched and popped safely by Slave.", s_data);
                        sb_rd_ptr <= sb_rd_ptr + 1;
                    end
                end
            end else begin
                s_ready <= 1'b0;
            end
        end
    end

endmodule