module labm;
reg clk, read, write;
reg [31:0] address, memIn;
reg [5:0] type;
wire [31:0] memOut;

mem data(memOut, address, memIn, clk, read, write);

initial 
begin        
	address = 128; write = 0; read = 1; 
	repeat (11)   
	begin
		#1;
		type = memOut[31:26];
		if (type == 0)
			$display("R: %6b %5b %5b %5b %6b", memOut[31:26], memOut[25:21], memOut[20:16], memOut[15:11], memOut[5:0]);
		else if (type == 2)
			$display("J: %6b %26b", memOut[31:26], memOut[25:0]);	
		else 
			$display("I: %6b %5b %5b %16b", memOut[31:26], memOut[25:21], memOut[20:16], memOut[15:0]);
		address += 4;
	end
end   

endmodule
