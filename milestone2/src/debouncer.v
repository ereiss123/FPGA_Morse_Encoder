`timescale 1ns/1ps


module debouncer (
		  input      clk,
		  input      btn,
		  output reg btn_db
		  );

   reg 			     btn_delay;

   always @(posedge clk) begin
      btn_delay <= btn;
      if (btn && ~btn_delay)
	btn_db <= 1;
      else
	btn_db <= 0;
   end
   

endmodule
