`timescale 1ns/1ps

module milestone_top( 
		     input 	       clk,
		     input 	       rst,
		     input 	       rx,
		     input 	       send,
		     output reg [15:0] led
		     );
   wire 			       rst_l;
   wire 			       ack;
   wire [7:0] 			       d_in;
   wire [15:0] 			       d_out;
   wire [15:0] 			       morse_out;
   wire 			       empty;
   wire 			       full;
   wire 			       send_db;
   wire 			       rx_rdy;
   wire 			       tx_rdy;
   wire 			       tx_done; 
   wire 			       ready;
   wire 			       empty_n;
 			       
   
   assign rst_l = ~rst;
   assign empty_n = send & ~empty;
   
   
   uart_rx 
     receive(
 	     .clk(clk),
	     .rst_l(rst_l),
	     .ack(ack),
	     .ready(ready),
	     .rx(rx),
	     .d_in(d_in)
	     );
   
   morse_table #(.DATA_WIDTH(16),.ADDR_WIDTH(8))  
   ROM(
       .clk(clk),
       .addr(d_in),
       .d_out(d_out),
       .ack(ack),
       .ready(ready),
       .tx_rdy(tx_rdy),
       .tx_done(tx_done)
       );
   
  /* mod_debouncer 
     db_ack(
	    .clk(clk),
	    .rst_n(rst_l),
	    .btn(send),
	    .done(done),
	    .btn_db(send_db)
	    );
*/
     debouncer 
     db_send(
	    .clk(clk),
	    .btn(send),
	    .btn_db(send_db)
	    );


   fifo #(.WIDTH(16),.DEPTH(64),.ADR_WIDTH(6))
   fifo(
	.clk(clk),
	.tx_rdy(tx_rdy),
	.tx_done(tx_done),
	.in_data(d_out),
	.rx_rdy(rx_rdy),
	.rx_done(send_db),
	.out_data(morse_out),
	.empty(empty),
	.full(full)
	);


   always @(posedge clk) begin
      if(send_db)begin
	 led <= morse_out;
	// done <= 1;
      end
      
      else begin
	 led <= led;
	// done <= 0;
      end
   end // always @ (posedge clk)
   
   
   
endmodule // milestone_top
