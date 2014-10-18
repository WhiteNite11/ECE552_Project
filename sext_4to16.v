//This module sign extends a 4 bit immediate
module sext_4to16(imm, out);
input [3:0] imm;
output [15:0] out;

assign out = {{12{imm[3]}}, imm};
endmodule

module t_sext_4to16();
reg [3:0] imm;
wire [15:0] out;

sext_4to16 uut(.imm(imm), .out(out));
initial $monitor("imm:%b out:%b", imm, out);

initial begin
imm = 4'b0111;
#5;
imm = 4'b1000;
#5;
imm = 4'b0000;
#5;
imm = 4'b1111;
end
endmodule
