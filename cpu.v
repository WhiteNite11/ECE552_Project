//This is the top level design, it will have all the functions
//of the CPU, and output the PC
module cpu(clk, rst_n, hlt, pc);
input clk, rst_n;
output hlt;
output [15:0] pc;

//PC wires
wire [15:0] pc_in, pc_out;
wire pc_wr_en;
//Instruction memory wires
wire [15:0] im_instr;
wire im_rd_en;
//PC + 4 wires
wire [15:0] pc_plus4_out;
//Program Counter
PC cpu_pc(.clk(clk),.rst_n(rst_n),.pc_wr_en(pc_wr_en),
          .pc_in(pc_in),.pc_out(pc_out));
//Instruction Memory
IM cpu_im(.clk(clk),.addr(pc_out),.rd_en(im_rd_en),.instr(im_instr));
//PC + 4 adder
adder_16 pc_plus4(.in1(pc_out), .in2(16'h0001), .out(pc_in)); //.out needs to be pc_plus4_out
//Test purpose
assign im_rd_en = 1'b1;
assign pc_wr_en = 1'b1;
assign pc = pc_out;
endmodule

//Test benches for cpu

//Test bench for PC and IM of cpu
module t_cpu_PC_IM();
reg clk, rst_n;
wire hlt;
wire [15:0] pc;

cpu uut(.clk(clk), .rst_n(rst_n), .hlt(hlt), .pc(pc));
initial $monitor("PC:%h, instruc:%h", pc, uut.im_instr);
//Reset initially
initial begin
rst_n = 1'b1;
#5;
rst_n = 1'b0;
#10;
rst_n = 1'b1;
end
//Clock
initial begin
  forever begin 
  #5;
  clk = ~clk;
  end
end

initial begin
clk = 1'b1;
#250;
$stop;
end
endmodule
