module axi_slave#(
    parameter DATA_WIDTH = 8
)(
output [DATA_WIDTH-1:0] s_data,
output s_valid,
input s_ready,
input fifo_empty,
output fifo_rinc,
input [DATA_WIDTH-1:0] fifo_rdata
);

assign s_valid   = !fifo_empty;
assign fifo_rinc = s_valid && s_ready;
assign s_data    = fifo_rdata;

endmodule