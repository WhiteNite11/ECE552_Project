//This file contains various muxes

//2 to 1 mux, 16 bit
//Uses: PC in selector, data memory output selector, alu input 2 selector
module mux_2to1_16(in0, in1, sel, out);
input [15:0] in0, in1;
input sel;
output [15:0] out;

assign out = sel ? in1 : in0;
endmodule

//4 to 1 mux, 16 bit
module mux_4to1_16(in0, in1, in2, in3, sel, out);
input [15:0] in0, in1, in2, in3;
input [1:0] sel;
output [15:0] out;

assign out = (sel == 2'b00) ? in0 : 
             (sel == 2'b01) ? in1 :
             (sel == 2'b10) ? in2 :
             (sel == 2'b11) ? in3 :
                          16'h0000;
endmodule

//2 to 1 mux, 4 bit
//Uses: PC in selector, data memory output selector, alu input 2 selector
module mux_2to1_4(in0, in1, sel, out);
input [3:0] in0, in1;
input sel;
output [3:0] out;

assign out = sel ? in1 : in0;
endmodule

//2 to 1 mux, 1 bit
module mux_2to1_1(in0, in1, sel, out);
input in0, in1;
input sel;
output out;

assign out = sel ? in1 : in0;
endmodule
/*
module t_mux_2to1_16();
reg [15:0] in0, in1;
reg sel;
wire [15:0] out;

mux_2to1_16 uut(.in0(in0), .in1(in1), .sel(sel), .out(out));
initial $monitor("in0:%d, in1:%d, sel:%b, out:%d", in0, in1, sel, out);
initial begin
in0 = 16'd0;
in1 = 16'd15;
sel = 1'b0;
#5;
sel = 1'b1;
#5;
end
endmodule
*/