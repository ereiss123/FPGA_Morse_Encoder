`timescale 1ns/1ps

module morse_testbench();
   reg 			clk;
   reg [7:0] 		addr;
   wire [15:0] 		d_out;
   
   reg [15:0] 		morse_verify;

   integer 		clk_count;
   integer 		fid;
   
   initial fid = $fopen("morse_table_results.txt","w");
 
   //Initialize signals
   initial begin
      clk = 0;
      addr = 0;
      clk_count = 0;
   end
      
   //100MHz Clock
   initial forever #5 clk = ~clk;
   
   morse_table #(.DATA_WIDTH(16), .ADDR_WIDTH(8)) DUT(
		   .clk(clk),
		   .addr(addr),
		   .d_out(d_out)
		   );

   integer morse;
   initial morse = 45056;
   
   always @(posedge clk) begin
      clk_count <= clk_count+1;

      addr <= addr + 1;
/*
      if(addr == 97)begin
	 if(d_out == morse)
	   $write("Correct d_out: %x  morse: %x",d_out,morse);
	 else
	   $write("Wrong d_out: %x  morse: %x",d_out,morse);
      end
*/    
      if(d_out != 0) begin  
	 $write("ascii:%c %b %d\tmorse: %b  %x  %d \n",addr, addr,addr,d_out,d_out,d_out);
	 $fwrite(fid,"ascii:%c %b %d\tmorse: %b  %x  %d \n",addr, addr,addr,d_out,d_out,d_out);
      end
      
      if(clk_count == 255) begin
	 $fclose(fid);
	 $finish;
      end
   end
   
   
endmodule // morse_testbench

   
