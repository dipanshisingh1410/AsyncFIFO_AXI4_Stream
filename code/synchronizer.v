module synchronizer
#(
  parameter ADDRESS = 4
)(
  input clk,
  input reset,
  input [ADDRESS:0] input_address,
  output reg [ADDRESS:0] address
);

reg [ADDRESS:0] sync_pipe;

always @(posedge clk or negedge reset) begin
if (!reset) begin
sync_pipe <= {ADDRESS+1{1'b0}};
address <= {ADDRESS+1{1'b0}};
end else begin
sync_pipe <= input_address; 
address <= sync_pipe;    
end
end

endmodule