module rptr_empty
#(parameter WIDTH   = 8,
  parameter DEPTH   = 16,
  parameter ADDRESS = 4
)(
  input rclk, rinc, rrst_n,
  input [ADDRESS:0] r_wptr,     
  output fifo_empty, 
  output reg [ADDRESS:0] rptr,       
  output reg [ADDRESS-1:0] raddr       
);  

reg  [ADDRESS:0] rbin = 0;
wire [ADDRESS:0] rbin_next;
wire [ADDRESS:0] rptr_gray_next;

assign rbin_next = (rinc && !fifo_empty) ? (rbin + 1'b1) : rbin;

assign rptr_gray_next = rbin_next ^ (rbin_next >> 1);

always @(posedge rclk or negedge rrst_n) begin 
if (!rrst_n) begin 
rbin <= {ADDRESS+1{1'b0}}; 
raddr <= {ADDRESS{1'b0}};   
rptr <= {ADDRESS+1{1'b0}}; 
end else begin 
rbin  <= rbin_next;
raddr <= rbin_next[ADDRESS-1:0]; 
rptr  <= rptr_gray_next;
end 
end 

assign fifo_empty = (!rrst_n) ? 1'b1 : (rptr == r_wptr);

endmodule