module yMux1(z, a, b, c);
output z;
input a, b, c;
wire notC, upper, lower;

not my_not(notC, c);
and upperAnd(upper, a, notC);
and lowerAnd(lower, c, b);
or my_or(z, upper, lower);
endmodule

module yMux2(z, a, b, c);
parameter SIZE = 2; //by default SIZE is 2, but it can be change upon instantiation
output [SIZE-1:0] z;
input [SIZE-1:0] a, b;
input c;

//yMux1 upper(z[0], a[0], b[0], c);
//yMux1 lower(z[1], a[1], b[1], c);
yMux1 mine[SIZE-1:0](z, a, b, c);
endmodule

module yMux4to1(z, a0, a1, a2, a3, c);
parameter SIZE = 2;
output [SIZE-1:0] z;
input [SIZE-1:0] a0, a1, a2, a3;
input[1:0] c;
wire [SIZE-1:0] zLo, zHi;

yMux2 #(SIZE) lo(zLo, a0, a1, c[0]);
yMux2 #(SIZE) hi(zHi, a2, a3, c[0]);
yMux2 #(SIZE) final(z, zLo, zHi, c[1]);
endmodule

module yAdder1(z, cout, a, b, cin);
output z, cout;
input a, b, cin;

xor left_xor(tmp, a, b);
xor right_xor(z, cin, tmp);
and left_and(outL, a, b);
and right_and(outR, tmp, cin);
or my_or(cout, outR, outL);
endmodule

module yAdder(z, cout, a, b, cin);
output [31:0] z;
output cout;
input [31:0] a, b;
input cin;
wire [31:0] in, out;  //used to connect the 32 adders one by on
integer i;

yAdder1 mine[31:0] (z, out, a, b, in); //instantiate 32 adders
assign in[0] = cin; 
assign in[1] = out[0]; 
assign in[2] = out[1];
assign in[3] = out[2];
assign in[4] = out[3];
assign in[5] = out[4];
assign in[6] = out[5];
assign in[7] = out[6];
assign in[8] = out[7];
assign in[9] = out[8];
assign in[10] = out[9];
assign in[11] = out[10];
assign in[12] = out[11];
assign in[13] = out[12];
assign in[14] = out[13];
assign in[15] = out[14];
assign in[16] = out[15];
assign in[17] = out[16];
assign in[18] = out[17];
assign in[19] = out[18];
assign in[20] = out[19];
assign in[21] = out[20];
assign in[22] = out[21];
assign in[23] = out[22];
assign in[24] = out[23];
assign in[25] = out[24];
assign in[26] = out[25];
assign in[27] = out[26];
assign in[28] = out[27];
assign in[29] = out[28];
assign in[30] = out[29];
assign in[31] = out[30];
assign cout = out[31];
endmodule

module yArith(z, cout, a, b, ctrl);
//add if ctrl = 0, substract if ctrl = 1
output [31:0] z;
output cout;
input [31:0] a, b;
input ctrl;
wire [31:0] notB, tmp;

not my_not[31:0](notB, b);
yMux2 #(32) my_mux(tmp, b, notB, ctrl);
yAdder my_adder(z, cout, a, tmp, ctrl);
endmodule

module yAlu (z, ex, a, b, op) ;
input [31:0] a, b;
input [2:0]  op;
output [31:0] z;
output        ex;
wire          cout;
wire [31:0]   alu_and, alu_or, alu_arith, slt, tmp;

wire [15:0]   z16;
wire [7:0]    z8;
wire [3:0]    z4;
wire [1:0]    z2;
wire          z1, z0;

// upper bits are always zero
assign slt[31:1] = 0;

// ex ('or' all bits of z, then 'not' the result)
or or16[15:0] (z16, z[15: 0], z[31:16]);
or or8[7:0] (z8, z16[7: 0], z16[15:8]);
or or4[3:0] (z4, z8[3: 0], z8[7:4]);
or or2[1:0] (z2, z4[1:0], z4[3:2]);
or or1[15:0] (z1, z2[1], z2[0]);
not m_not (z0, z1);
assign ex = z0;

// set slt[0]
xor (condition, a[31], b[31]);
yArith slt_arith (tmp, cout, a, b, 1'b1);
yMux2 #(.SIZE(1)) slt_mux(slt[0], tmp[31], a[31], condition);

// instantiate the components and connect them
and m_and [31:0] (alu_and, a, b);
or m_or [31:0] (alu_or, a, b);
yArith m_arith (alu_arith, cout, a, b, op[2]);
yMux4to1 #(.SIZE(32)) mux(z, alu_and, alu_or, alu_arith, slt, op[1:0]);
endmodule



module yIF(ins, PCp4, PCin, clk);
output [31:0] ins, PCp4;
input [31:0] PCin;
input clk;
wire [31:0] PC, memIn;

register #(32) pc(PC, PCin, clk, 1'b1);
mem data(ins, PC, memIn, clk, 1'b1, 1'b0);
yAlu my_alu(PCp4, ex, 4, PC, 3'b010);
endmodule


module yID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
output [31:0] rd1, rd2, imm;
output [25:0] jTarget;
input [31:0] ins, wd;
input RegDst, RegWrite, clk;
wire [4:0] rn1, rn2_1, rn2_2, wn;
reg [15:0] zeros = 16'b0;
reg [15:0] ones = -16'b1;

assign rn1 = ins[25:21];
assign rn2_1 = ins[20:16];
assign rn2_2 = ins[15:11];
yMux2 #(5) my_mux(wn, rn2_1, rn2_2, RegDst);
//get the imm and sign extended to 32bits
assign imm[15:0] = ins[15:0];
yMux2 #(16) se(imm[31:16], zeros, ones, ins[15]);
rf rf0(rd1, rd2, rn1, rn2_1, wn, wd, clk, RegWrite);

assign jTarget = ins[25:0];
endmodule


module yEX(z, zero, rd1, rd2, imm, op, ALUSrc);
output [31:0] z;
output zero;
input [31:0] rd1, rd2, imm;
input [2:0] op;
input ALUSrc;
wire [31:0] b;

yMux2 #(32) my_mux(b, rd2, imm, ALUSrc);
yAlu my_alu(z, zero, rd1, b, op);
endmodule


module yDM(memOut, exeOut, rd2, clk, MemRead, MemWrite);
output [31:0] memOut;
input [31:0] exeOut, rd2;
input clk, MemRead, MemWrite;

mem data(memOut, exeOut, rd2, clk, MemRead, MemWrite);
endmodule

module yWB(wb, exeOut, memOut, Mem2Reg);
output [31:0] wb;
input [31:0] exeOut, memOut;
input Mem2Reg;

yMux2 #(32) my_mux(wb, exeOut, memOut, Mem2Reg);
endmodule








