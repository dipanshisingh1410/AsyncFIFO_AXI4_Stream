module axi_master_side #(
    parameter DATA_WIDTH = 8
)(
output wire [DATA_WIDTH-1:0] m_data,
output wire m_valid,
input wire m_ready,
input wire fifo_empty,
output wire fifo_rinc,
input wire [DATA_WIDTH-1:0] fifo_rdata
);

assign m_valid = !fifo_empty;

assign fifo_rinc   = m_valid && m_ready;

assign m_data  = fifo_rdata;

endmodule
