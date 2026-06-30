module fifomem
#(parameter WIDTH   = 8,
  parameter ADDRESS = 4
)(
  input [WIDTH-1:0] wdata,
  input wclken, wclk,
  input [ADDRESS-1:0] waddr, raddr,
  output [WIDTH-1:0] rdata
);

localparam MEM_DEPTH = 1 << ADDRESS; 
reg [WIDTH-1:0] mem [0:MEM_DEPTH-1];

always @(posedge wclk) begin
if (wclken) begin
mem[waddr] <= wdata;
end
end

assign rdata = mem[raddr];

endmodule