module async_fifo_core
#(
  parameter WIDTH   = 8,
  parameter DEPTH   = 16,
  parameter ADDRESS = 4
)(
  input  wclk,rclk,
  input  wrst_n,rrst_n,
  input  [WIDTH-1:0] wdata,
  input  winc,rinc, 
  output [WIDTH-1:0] rdata,
  output fifo_full,  
  output fifo_empty,
  output [ADDRESS-1:0]waddr,raddr,
  input  s_ready, m_valid // only for waveform 
); 

wire [ADDRESS:0] w_rptr, r_wptr;  
wire [ADDRESS:0] wptr, rptr;      

 
fifomem FIFO (.wclk(wclk), .wclken (winc & ~fifo_full), .waddr  (waddr),
              .wdata(wdata), .raddr(raddr), .rdata(rdata));  

wptr_full wptr_blk ( .wclk(wclk), .wrst_n(wrst_n), .winc(winc), .w_rptr(w_rptr),
                     .waddr(waddr), .wptr(wptr), .fifo_full (fifo_full));  
                                        
synchronizer sync_w2r (.clk(rclk), .reset(rrst_n), .input_address (wptr), 
                       .address (r_wptr) ); 

synchronizer sync_r2w (.clk (wclk), .reset (wrst_n), .input_address (rptr), 
                       .address (w_rptr) );  
												
rptr_empty rptr_blk ( .rclk (rclk), .rrst_n (rrst_n), .rinc  (rinc), .r_wptr (r_wptr), 
                      .raddr (raddr), .rptr (rptr), .fifo_empty (fifo_empty)); 

endmodule