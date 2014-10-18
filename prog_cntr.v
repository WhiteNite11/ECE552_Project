//This is the program counter, triggers on falling edge
//of clk, an enable signal is used for data hazards, when
//it is zero don't update PC. PC is reset to 0.

module PC(clk,rst_n,pc_wr_en,pc_in,pc_out);

input clk, rst_n;
input pc_wr_en;			// asserted when PC update is requested
input [15:0] pc_in;

output reg [15:0] pc_out;	//output PC

/////////////////////////////////////
// PC is updated on falling edge //
///////////////////////////////////
always @(negedge clk, negedge rst_n)
  if (~rst_n)
    pc_out <= 16'h0000;
  else if (pc_wr_en)
    pc_out <= pc_in;
  else
    pc_out <= pc_out;
endmodule

module t_PC();
reg [15:0] pc_in;
wire [15:0] pc_out;
reg clk, rst_n, pc_wr_en;

PC uut(.clk(clk),.rst_n(rst_n),.pc_wr_en(pc_wr_en),.pc_in(pc_in),.pc_out(pc_out));
initial $monitor("rst:%b, PC_in:%d PC_out: %h, clk: %b", rst_n, pc_in, pc_out, clk);

//Reset initially
initial begin
rst_n = 1;
#2;
rst_n = 0;
#2;
rst_n = 1;
end
//Let the counter run
initial begin
clk = 1'b1;
pc_wr_en = 1'b1;
pc_in = 16'd0;
#50;
pc_wr_en = 0;
#20;
$stop;
end

//Clock
always clk = #5 ~clk;
//PC increment
always pc_in = #10 (pc_in + 16'd4);

endmodule
