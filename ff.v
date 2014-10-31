module dff(clk, d, rst_n, q);
input clk, d, rst_n;
output q;
reg myQ;

assign q = myQ;

always @(posedge clk) begin
  if (!rst_n) begin
    myQ <= 1'b0;
  end
  else begin
    myQ <= d;
  end
end
endmodule

module dff2(rst_n, clk, d, q);
input [1:0] d;
input rst_n, clk;
output [1:0] q;

dff dff0(.clk(clk), .d(d[0]), .rst_n(rst_n), .q(q[0]));
dff dff1(.clk(clk), .d(d[1]), .rst_n(rst_n), .q(q[1]));

endmodule

module dff4(rst_n, clk, d, q);
input [3:0] d;
input rst_n, clk;
output [3:0] q;

dff dff0(.clk(clk), .d(d[0]), .rst_n(rst_n), .q(q[0]));
dff dff1(.clk(clk), .d(d[1]), .rst_n(rst_n), .q(q[1]));
dff dff2(.clk(clk), .d(d[2]), .rst_n(rst_n), .q(q[2]));
dff dff3(.clk(clk), .d(d[3]), .rst_n(rst_n), .q(q[3]));

endmodule

module dff8(rst_n, clk, d, q);
input [7:0] d;
input rst_n, clk;
output [7:0] q;

dff4 dff0(.clk(clk), .d(d[3:0]), .rst_n(rst_n), .q(q[3:0]));
dff4 dff1(.clk(clk), .d(d[7:4]), .rst_n(rst_n), .q(q[7:4]));

endmodule


module dff16(rst_n, clk, d, q);
input [15:0] d;
input rst_n, clk;
output [15:0] q;

dff4 dff0(.clk(clk), .d(d[3:0]), .rst_n(rst_n), .q(q[3:0]));
dff4 dff1(.clk(clk), .d(d[7:4]), .rst_n(rst_n), .q(q[7:4]));
dff4 dff2(.clk(clk), .d(d[11:8]), .rst_n(rst_n), .q(q[11:8]));
dff4 dff3(.clk(clk), .d(d[15:12]), .rst_n(rst_n), .q(q[15:12]));

endmodule
