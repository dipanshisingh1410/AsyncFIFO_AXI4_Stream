module wptr_full
#(parameter WIDTH   = 8,
  parameter DEPTH   = 16,
  parameter ADDRESS = 4
)
( 
  input winc, wclk, wrst_n,
  input [ADDRESS:0] w_rptr, 
  output fifo_full, 
  output reg  [ADDRESS-1:0] waddr,
  output reg  [ADDRESS:0] wptr    
);  

reg  [ADDRESS:0] wbin = 0;
wire [ADDRESS:0] wbin_next;
wire [ADDRESS:0] wptr_gray_next;

assign wbin_next = (winc && !fifo_full) ? (wbin + 1'b1) : wbin;
  
assign wptr_gray_next = wbin_next ^ (wbin_next >> 1);

always @(posedge wclk or negedge wrst_n) begin 
if (!wrst_n) begin 
wbin <= {ADDRESS+1{1'b0}};
waddr <= {ADDRESS{1'b0}};   
wptr <= {ADDRESS+1{1'b0}}; 
end else begin 
wbin <= wbin_next;
waddr <= wbin_next[ADDRESS-1:0];
wptr <= wptr_gray_next;
end 
end 

assign fifo_full = (!wrst_n) ? 1'b0 : 
                   ((wptr[ADDRESS]   != w_rptr[ADDRESS])   &&
                    (wptr[ADDRESS-1] != w_rptr[ADDRESS-1]) &&
                    (wptr[ADDRESS-2:0] == w_rptr[ADDRESS-2:0]));

endmodule