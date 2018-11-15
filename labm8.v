module labm8;
reg [31:0] PCin;
reg clk, RegDst, RegWrite, ALUSrc;
reg [2:0] op;
wire [31:0] ins, PCp4, wd, rd1, rd2, imm, z;
wire [25:0] jTarget;
wire zero;

yIF myIF(ins, PCp4, PCin, clk);
yID myID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
assign wd = z;

initial
begin
	//------------------------------Entry point
	PCin = 128;
	//------------------------------Run program
	repeat (11)
	begin
		//--------------------------Fetch an ins
		clk = 1; #1;
		//---------------------------------Set   control   signals   
		RegDst = 0; RegWrite = 0; ALUSrc = 1; op = 3'b010;
		//--------------------------Execute the ins
		// Add statements to adjust the above defaults
		if (ins[31:26] == 0)			// R format
		begin
			RegDst = 1; 
			RegWrite = 1; 
			ALUSrc = 0;
		end
		else if (ins[31:26] == 2)		// J format
		begin
			RegDst = 0; 
			RegWrite = 0;
			ALUSrc = 1;
		end
		else					        //I format
		begin
			RegDst = 0; 
			RegWrite = 1; 
			ALUSrc = 1;
		end
		clk = 0; #1;
		//--------------------------View the result
		$display("instruction = %h: rd1=%2d rd2=%2d imm=%h jTarget=%h z=%2d zero=%b", ins, rd1, rd2, imm, jTarget, z, zero);
		PCin = PCp4;
	end
	$finish;
end

endmodule