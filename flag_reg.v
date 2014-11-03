//This is the flag register that is updated
//only on valid alu instructions.
//Its output is used to determine branch instructions

module flag_reg(clk,rst_n,flag_wr_en,n,z,v,flag_out);

input clk, rst_n, n, z, v;
input flag_wr_en;			// asserted on arith instruc

output reg [2:0] flag_out;	//output Flag

/////////////////////////////////////
// Flag is updated on falling edge //
///////////////////////////////////
always @(posedge clk)
  if (~rst_n)
    flag_out <= 3'b000;
  else if (flag_wr_en)
    flag_out <= {n,z,v};
  else
    flag_out <= flag_out;
endmodule
