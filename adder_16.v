//This module adds two 16 bit numbers
//Will be used for PC + 4 and PC + sexOff
module adder_16(in1, in2, out);
input [15:0] in1, in2;
output [15:0] out;

assign out = in1 + in2;

endmodule
/*
module t_adder_16();
reg [15:0] in1, in2;
wire [15:0] out;

adder_16 uut(.in1(in1), .in2(in2), .out(out));
initial $monitor("in1:%d, in2:%d, out:%d", in1, in2, out);

initial begin
  for(in1 = 16'd0; in1 < 16'd10; in1 = in1 + 1) begin
    for(in2 = 16'd0; in2 < 16'd10; in2 = in2 + 1) #5;
  end
end
endmodule
*/
