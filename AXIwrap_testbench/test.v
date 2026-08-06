module test#(
parameter WIDTH = 8, 
parameter ADDRESS = 4, 
parameter DEPTH = 16
); 

// from/to write 
reg wclk,wrst_n; 
reg [WIDTH-1:0] wdata; 
reg winc; 
wire [ADDRESS-1:0]waddr; 
wire fifo_full; 

// from/to read 
reg   rclk,rrst_n,rinc ; 
wire [WIDTH-1:0] rdata ; 
wire [ADDRESS-1:0]raddr; 
wire fifo_empty ; 

// internal (tracking) 
reg s_ready, m_valid ;

// internal (not tracking) 
reg [WIDTH-1:0] data;  
integer i; 

async_fifo_core DUT( .wclk(wclk) , .rclk(rclk), .wrst_n(wrst_n),.rrst_n(rrst_n),
                     .wdata(wdata), .winc(winc), .rinc(rinc), .rdata(rdata),
                     .fifo_full(fifo_full), .fifo_empty(fifo_empty),.waddr(waddr),
							.raddr(raddr) , .s_ready(s_ready), .m_valid(m_valid) ); 

initial begin 
       wclk = 1'b0; 
    #2;rclk = 1'b1;   
end 

initial begin 
      rrst_n = 1'b1; 
	   wrst_n = 1'b1; 
		
		#2; 
		
	   rrst_n = 1'b0;  
      wrst_n = 1'b0;  
		
		#50; 
		
		rrst_n = 1'b1; 
	   wrst_n = 1'b1; 
		
end 

always begin 
#2; wclk = ~ wclk ;   end 

always begin 
#20; rclk = ~rclk ;    end 


// master -------------------------------------------------------
task master (input [WIDTH -1:0] data); 
begin 
     @(posedge wclk) ; 
	  
      if(m_valid && s_ready) begin 
        winc <= 1'b1; 
		  wdata <= data ; 
		  $display("DATA SENT %d", data); 
      end  
		
		else begin 
		  winc <= 1'b0; 
		  if(s_ready == 1'b0) $display("FIFO FULL") ; 
		end 
   
end 
endtask  


// slave 
task slave; 
begin 
  if(!fifo_empty) 
  rinc <= 1'b1; 
  else
  rinc <= 1'b0 ; $display("FIFO EMPTY"); 
end 
endtask 
//----------------------------------------------------------------

always @(*) begin s_ready = ~fifo_full ; end  
always @(posedge rclk) begin if(rrst_n) slave(); end 

initial begin 

// case 1 tvalid=0 , sready =1

#5; 
m_valid= 1'b0; 
  $display("CASE1: M_VALID 0 BUT S_READY= 1, NO DATA ON THE DATA LINE");
#10; 


// case 2 tvalid=1 , sready =1
// case 3 tvalid=1 , sready =0 

  $display("REAL EXECUTION ABOUT TO BEGIN!!!");
#5;  
m_valid= 1'b1; 
  
@(posedge wclk); 
	 
	for(i=0; i<= (DEPTH+3'b111);i= i+1'b1) begin 
   data = i ;
   master(data); 	
   end   
#10 ; 

// case 4 tvalid=0 , sready =0

m_valid = 1'b0 ; 
  $display("ONLY READ UNTIL FIFO_EMPTY"); 
  wait(fifo_empty); 
  
  
$finish; 
end 

endmodule 