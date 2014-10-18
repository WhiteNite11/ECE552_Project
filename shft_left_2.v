//This module only shifts the 16 bit input left 2 bits
module shft_left_2(in, out);
input [15:0] in;
output [15:0] out;

assign out = {in[13:0], 2'b00};
endmodule

module t_shft_left_2();
reg [15:0] in;
wire [15:0] out;

shft_left_2 uut(.in(in), .out(out));
initial $monitor("in:%b, out:%b", in, out);

initial begin
in = 16'hf0f0;
#2;
in = 16'hffff;
#2;
in = 16'h0000;
end
endmodule

