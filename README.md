# FPGA_Morse_Encoder
This project fulfilled the final project requirements for the Digital System Design Course (ECE3700) at Utah State University. 
This project is a Morse Encoder implemented on a Digilient Artix-7 Basys3 FPGA board. It was developped concurrently
with a Morse Decoder that another student, Jaron Bono, was working on. The project was proposed in three milestones. 
<br>
<br>
The first milestone was to implement a LUT to convert ASCII characters to a binary implementation of Morse that myself and Jaron Bono developped. This LUT 
was then used to convert a single character sent from a terminal via UART to a static morse output on the board's LEDs.
<br>
<br>
The next milestone implemented a memory component in the form of FIFO queue. This allowed multiple characters to be sent via UART and read on the LEDs in the order they 
were received. 
<br>
<br>
The final milestone was to combine the Encoder and Decoder using a microphone and speaker; however, time constraints did not allow us to finish this. If Jaron and I get 
time in the future, this may be something we implement. 

