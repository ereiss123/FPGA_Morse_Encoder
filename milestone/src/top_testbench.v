`timescale 1ns/1ps

module top_testbench();
   //DUT Signals
   reg 	       clk;
   reg 	       rst;
   reg 	       rx;
   reg 	       ack;
   wire [15:0] led;
   //Driver Signals
   reg [7:0]   ascii_in;
   wire        done;
   reg 	       start;
   wire        ready_done;
   

   //------SIMULATION FILES AND CLK SIGNALS------//
   integer     fid;
   integer     clk_count;
   integer     tx_count;
   
   initial begin
      clk = 0;
      clk_count = 0;
      fid = $fopen("top_test_results.txt", "w");
      $dumpfile("top_milestone.vcd");
      $dumpvars(2,top_testbench);
   end

   initial forever #5 clk = ~clk;
   //-------------------------------------------//

   //-----------------DUT----------------------//
   milestone_top DUT(
		     .clk(clk),
		     .rst(rst),
		     .rx(rx),
		     .ack(ack),
		     .led(led),
		     .done(ready_done)
		     );
   //------------------------------------------//

   integer i;
   initial begin
      rst = 1;
      ack = 0;
      start = 0;
      ascii_in = 9;
      tx_count = 0;
      
      
      // After 100ns, stop resetting
      #100 rst = 0;

      //ADDED 
      rx = 1;
      ack = 0;
      
      while (1) begin
	 
	 //ADDED
	 ascii_in = ascii_in +1;
	 if(ascii_in == 10 || (ascii_in > 31 && ascii_in<65)
	    || (ascii_in >93 && ascii_in < 128)) begin
	    $write("Sending %d(%c)\n", ascii_in, ascii_in);
	    $fwrite(fid,"Sending %d(%c)\n", ascii_in, ascii_in);
	    
	    $write("Start bit. RX=");
	    $fwrite(fid,"Start bit. RX="); 

	    rx = 0; //send start bit
	 
	    // SEND eight bits:
	    for (i=0; i<8; i=i+1) begin
	       #104170;
	       rx = ascii_in[i];
	       $write("%b",rx);
	       $fwrite(fid,"%b",rx);	    
	    end

	    // Wait for stop bit:
	    #104170;
	    
	    $write(". Stop bit. ");
	    $fwrite(fid,". Stop bit. ");

	    while(!DUT.ready) begin
	       #104170; //wait for ready signal
	    end
	 
	    $write("%d ascii_in: %b led: %b  \n", clk_count,ascii_in, led); 
	    $fwrite(fid,"%d ascii_in: %b led: %b  \n", clk_count,ascii_in,led);
	    
	    ack = 1;
	    rx = 1;

	    while(DUT.ready) begin
	       #104170;
	    end
	    
	    ack = 0;
	    #104170;
	    tx_count = tx_count+1;
	    
	 end // if (ascii_in == 10 || (ascii_in > 31 && ascii_in<65)...
	 else begin
  	    $write("No Morse output for %b(%c)\n", ascii_in, ascii_in);
	    $fwrite(fid,"No Morse output for %b(%c)\n", ascii_in, ascii_in);
	 end // else: !if(ascii_in == 10 || (ascii_in > 31 && ascii_in<65)...
      end // while (1)
   end // initial begin

   
      //Finish conditions
   always @(posedge clk) begin
     
      clk_count <= clk_count+1;
      if(ascii_in >= 128 || clk_count > 200_000_000 || tx_count >= 68) begin
	 $fclose(fid);
	 $finish;
      end
   end
endmodule // top_testbench

   

