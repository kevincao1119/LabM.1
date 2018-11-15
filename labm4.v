module labm4;
reg [31:0] address, memIn;
reg clk, memRead, memWrite;
wire [31:0] memOut;

mem data(memOut, address, memIn, clk, memRead, memWrite);

initial
begin
	memRead = 0; memWrite = 1;
	clk = 0;
	address = 16;
	memIn = 32'h12345678;
	clk = 1;
	#1;  //wait for the mem to store the value

	clk = 0;
	address = 24;
	memIn = 32'h89abcdef;
	clk = 1;
	#1;
	
	memWrite = 0; memRead = 1; address = 16;
	repeat (3)
	begin
		if (address % 4 === 0)
			#1 $display("Address %0d contains %0h", address, memOut);
		else
			$display("Address is not aligned!");
		address = address + 4;
	end
	$finish;
end

endmodule