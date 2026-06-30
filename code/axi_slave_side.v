module axi_slave_side #(
    parameter DATA_WIDTH = 8
)(
input[DATA_WIDTH-1:0] s_data,
input s_valid,
output s_ready,
input fifo_full,
output fifo_winc,
output [DATA_WIDTH-1:0] fifo_wdata
);

assign s_ready = !fifo_full;
	 
assign fifo_winc   = s_valid && s_ready;

assign fifo_wdata  = s_data;

endmodule
