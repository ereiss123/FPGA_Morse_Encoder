`timescale 1ns/1ps

module morse_table #(parameter DATA_WIDTH = 8,parameter ADDR_WIDTH = 8)
   (
    input 			clk,
    input [ADDR_WIDTH-1:0] 	addr,
    output reg [DATA_WIDTH-1:0] d_out,

    //UART Handshake
    output reg 			ack,
    input 			ready,

    //FIFO Handshake
    output reg 			tx_rdy,
    input 			tx_done
    );

   //The Memory Array
   reg [DATA_WIDTH-1:0] 	ram[2**ADDR_WIDTH-1:0];
   reg[1:0] 				state;
   localparam WAIT = 0;
   localparam ACK  = 1;
   localparam SEND = 2;

   initial begin
      state = WAIT;
      ack = 0;
      tx_rdy = 0;
      
      $readmemb("morse_LUT.txt", ram, 0, 255);
   end

   //State Machine
   always @(posedge clk) begin
      case(state)
	WAIT: begin
	   if(ready) begin
	      d_out <= ram[addr];
	      ack <= 1;
	      state <= ACK;
	   end
	   else begin
	      ack <= 0;
	      tx_rdy <= 0;
	   end
	end // case: WAIT
	ACK: begin
	   if(!ready) begin
	      ack <= 0;
	      tx_rdy <= 1;
	      state <= SEND;
	   end
	   else
	     ack <= 1;
	end
	SEND: begin
	   if(tx_done) begin
	      state <= WAIT;
	      tx_rdy <= 0;
	   end
	   else
	     tx_rdy <= 1;
	end
      endcase // case (state)
   end // always @ (posedge clk)
endmodule // morse LUT
