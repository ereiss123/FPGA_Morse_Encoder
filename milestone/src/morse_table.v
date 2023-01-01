`timescale 1ns/1ps

module morse_table #(parameter DATA_WIDTH = 8,parameter ADDR_WIDTH = 8)
   (
    input 			clk,
    input [ADDR_WIDTH-1:0] 	addr,
    output reg [DATA_WIDTH-1:0] d_out
    );

   //The Memory Array
   reg [DATA_WIDTH-1:0] 	ram[2**ADDR_WIDTH-1:0];

   initial begin
      //d_out = 0;
      $readmemb("morse_LUT.txt", ram, 0, 255);
   end
   
   always @(posedge clk) begin
      d_out <= ram[addr];
      //else begin
	// d_out <= d_out;
      //end
   end
endmodule // single_port_RAM
