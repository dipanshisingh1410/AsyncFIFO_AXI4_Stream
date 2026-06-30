module top_axi_async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
// Master Write Interface Domain
input m_clk,
input m_reset_n,
input [DATA_WIDTH-1:0] m_data,
input m_valid,
output m_ready,

// Slave Read Interface Domain
input s_clk,
input s_reset_n,
output [DATA_WIDTH-1:0] s_data,
output s_valid,
input s_ready
);
    
wire fifo_full, fifo_empty, fifo_winc, fifo_rinc;
wire [DATA_WIDTH-1:0] fifo_wdata, fifo_rdata;
wire [ADDR_WIDTH-1:0] waddr_wire, raddr_wire; 

// Master writes to the FIFO
axi_master master( .m_data (m_data), .m_valid (m_valid), .m_ready (m_ready), .fifo_full(fifo_full),
                   .fifo_winc (fifo_winc), .fifo_wdata (fifo_wdata) );

// Slave reads from the FIFO
axi_slave slave( .s_data (s_data), .s_valid (s_valid), .s_ready (s_ready), .fifo_empty (fifo_empty),
                 .fifo_rinc (fifo_rinc), .fifo_rdata (fifo_rdata));

// Internal Core Sync Core Bridge
async_fifo_core fifo( .wclk (m_clk), .rclk (s_clk), .wrst_n (m_reset_n), .rrst_n (s_reset_n), .wdata (fifo_wdata),
                      .winc (fifo_winc), .rinc (fifo_rinc), .rdata (fifo_rdata), .fifo_full (fifo_full),
                      .fifo_empty (fifo_empty), .waddr (waddr_wire), .raddr (raddr_wire) );

endmodule