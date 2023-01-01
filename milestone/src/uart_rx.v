`timescale 1ns/1ps

module uart_rx #(parameter N = 8, baud = 9600)
  (
   //Clock and Reset signals
   input 	    clk,
   input 	    rst_l,
   //Handshake Signals
   input 	    ack,
   output reg 	    ready,
   //Received Input
   input 	    rx,
   output reg [N-1:0] d_in
   );

   //INTERNAL SIGNALS
   reg [1:0] 	    state; //Track state
   reg [2:0] 	    bit_index; //Count rx bits
   reg 		    start_bit;
   
   //STATE PARAMETERS
   localparam WAIT = 0;
   localparam READ = 1;
   localparam DONE = 2;

   //Clock Divider Signals
   reg 	     clk_div;
   reg [31:0] clk_count;
   integer   refresh;
   
   //INITIALIZE SIGNALS
   initial begin
      ready = 0;
      d_in = 0;
      clk_div = 0;
      clk_count = 0;
      refresh = 100_000_000/(2*baud); //set refresh rate to get 9600 baud
   end

   //CLOCK DIVIDER W/ RISING EDGE SYNC
   always @(posedge clk, negedge rst_l) begin
      if(!rst_l) begin
	 clk_count <= 0;
	 clk_div <= 0;
      end
      //Hold until rising edge
      else if((state == WAIT) && rx) begin
	 clk_div <= 0;
	 clk_count <= 0;
      end
      //Initialize on rising edge
      else if((state == WAIT) && !rx && (clk_count == 0)) begin
	 clk_div <= 1;
	 clk_count <= 0;
      end
      //Operate as normal
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
      if(!rst_l)begin
	 d_in <= 0;
	 ready <= 0;
	 state <= WAIT;
	 bit_index <= 0;	 
      end
      else begin
	 case(state)
	   WAIT: begin
	      if(!rx) begin
		 bit_index <= 0;
		 state <= READ;
	      end
	      else begin
		 ready <= 0;
		 d_in <= 0;
	      end 
	   end //case: WAIT
	   READ: begin
	      if(bit_index == (N-1))begin
		 d_in[bit_index] <= rx;
		 ready <= 1;
		 state <= DONE;
	      end
	      else begin
		 d_in[bit_index] <= rx;
		 bit_index <= bit_index + 1;
	      end
	   end // case: READ
	   DONE: begin
	      if(/*rx &&*/ ack) begin
		 ready <= 0;
		 state <= WAIT;
	      end
	      else
		ready <= 1;
	   end // case: DONE
	   default:begin
	      state <= WAIT;
	      bit_index <= 0;
	   end // default
	 endcase // case (state)
      end // else: !if(!rst_l)
   end // always @ (posedge clk_div, negedge rst_l)
endmodule // uart_rx

	 
      
