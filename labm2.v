module labm1;
reg [31:0] d, e;
reg enable, clk, flag;
wire [31:0] z;

register #(32) mine(z, d, clk, enable);

initial
begin
	//initialize clk to 0
	clk = 0;
	flag = $value$plusargs("enable=%b", enable);
	
	//generate random values for d every two unites of time
	repeat (20)
	begin
		#2 d = $random;
	end

	$finish;
end

//generate clk signal every 5 units of time
always
begin
	#5 clk = ~clk;
end

//set the value of expected
always @(posedge clk)
begin
	if (enable ===1)
		e = d;
end

initial
	$monitor("%5d: clk=%b   d=%d   z=%d  expect=%d", $time, clk, d, z, e);

endmodule
