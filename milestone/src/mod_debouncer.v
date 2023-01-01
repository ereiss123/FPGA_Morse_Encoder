`timescale 1ns/1ps

module mod_debouncer 
  #(
    parameter N=50
    )
   (
    input      clk,
    input      rst_n,
    input      btn,
    input      done,
    output reg btn_db
    );

   reg [1:0]  state;
   reg 	      clear;
   wire       t;
   
   mod_tcounter #(.N(N)) tc1
     (
      .clk(clk),
      .rst_n(rst_n),
      .clear(clear),
      .done(t)
      );
   
   initial begin
      state = 0;
      btn_db = 0;
      clear = 1;
      
   end

   always @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
	 state <= 0;
	 btn_db <= 0;
	 clear <= 1;
	 
      end
      else begin
	 case (state)
	   0:
	     begin
		if (btn) begin
		   clear <= 0;
		   state <= 1;
		end
		else begin
		   clear <= 1;
		   
		end
	     end // case: 0
	   1:
	     begin
		if (t && btn) begin
		   state <= 2;
		   btn_db <= 1;
		end
		else if (!btn && !t) begin
		   state <= 0;
		   clear <= 1;		   
		end
	     end // case: 1
	   2:
	     begin
		if (done) begin
		   btn_db <= 0;
		   state <= 0;
		   clear <= 1;
		   
		end
	     end
	   
	   
	 endcase // case (state)
	 
      end
   end
   

endmodule //
