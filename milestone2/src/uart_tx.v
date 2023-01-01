`timescale 1ns/1ps

module uart_tx #(parameter N = 8, baud = 9600)
   (
    input clk,
    input start,
    input rst_l,
    input [N-1:0] d_out,
    output reg done,
    output reg tx
    );
   //State Machine Signals
   reg [1:0] state;
   reg [2:0] bit_index;

   //Clock Divider Signals
   reg 	     clk_div;
   reg [31:0] clk_count;
   integer   refresh;

   //State Parameters
   localparam WAIT = 0;
   localparam SEND = 1;
   localparam STOP = 2;

   //INITIALIZE SIGNALS
   initial begin
      done = 0;
      tx = 1;
      state = WAIT;
      bit_index = 0;
      clk_div = 0;
      clk_count = 0;
      refresh = 100_000_000/(2*baud);
   end

   //CLOCK DIVIDER
   always @(posedge clk, negedge rst_l) begin
      if(!rst_l) begin
	 clk_count <= 0;
      end
      else begin 
	if(clk_count >= refresh) begin
	 clk_div <= ~clk_div;
	 clk_count <= 0;
	end
	else
	  clk_count <= clk_count + 1;
      end // else: !if(!rst_l)
   end // always @ (posedge clk, negedge rst_l)

   //STATE MACHINE
   always @(posedge clk_div, negedge rst_l) begin
      if(!rst_l) begin
	 tx <= 1;
	 done <= 0;
	 bit_index <= 0;
	 state <= WAIT;
      end
      else begin
	 case(state)
	   WAIT: begin
	      if(start) begin
		 tx <= 0;
		 bit_index <= 0;
		 state <= SEND;
	      end
	      else begin
		 state <= WAIT;
		 tx <= 1;
		 done <= 0;
	      end
	   end // case: WAIT
	   SEND: begin
	      if(bit_index == (N-1)) begin
		 tx <= d_out[bit_index];
		 state <= STOP;
	      end
	      else begin
		 tx <= d_out[bit_index];
		 bit_index <= bit_index + 1;
		 state <= SEND;
	      end
	   end // case: SEND
	   STOP: begin
	      if(start) begin
		 done <= 1;
		 tx <= 1;
		 state <= STOP;
	      end
	      else begin
		 done <= 0;
		 state <= WAIT;
	      end
	   end // case: STOP
	   default: begin
	      state <= WAIT;
	   end
	 endcase // case (state)
      end // else: !if(!rst_l)
   end // always @ (posedge clk_div, negedge rst_l)
endmodule // uart_tx
