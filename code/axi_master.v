module axi_master #(
    parameter DATA_WIDTH = 8
)(
input [DATA_WIDTH-1:0] m_data,
input m_valid,
output m_ready,
input fifo_full,
output fifo_winc,
output [DATA_WIDTH-1:0] fifo_wdata
);

assign m_ready    = !fifo_full;
assign fifo_winc  = m_valid && m_ready;
assign fifo_wdata = m_data;

endmodule