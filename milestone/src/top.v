`timescale 1ns/1ps

module milestone_top( 
		     input 	       clk,
		     input 	       rst,
		     input 	       rx,
		     input 	       ack,
		     output reg [15:0] led,
		     output reg        done
		     );
   wire 			       rst_l;
   wire 			       ack_db;
   wire [7:0] 			       d_in;
   wire [15:0] 			       d_out;
   
   assign rst_l = ~rst;
   
   
   uart_rx receive(
 		   .clk(clk),
		   .rst_l(rst_l),
		   .ack(ack_db),
		   .ready(ready),
		   .rx(rx),
		   .d_in(d_in)
		   );
   

   
   morse_table #(.DATA_WIDTH(16),.ADDR_WIDTH(8))  
   ROM(
       .clk(clk),
       .addr(d_in),
       .d_out(d_out)
       );
   
   mod_debouncer db_ack(
		    .clk(clk),
		    .rst_n(rst_l),
		    .btn(ack),
		    .done(~ready),
		    .btn_db(ack_db)
		    );

   always @(posedge clk) begin
      if(ready)begin
	 led <= d_out;
	 done <= 1;
      end
      
      else begin
	 led <= led;
	 done <= 0;
      end
   end // always @ (posedge clk)
   
   
   
endmodule // milestone_top
