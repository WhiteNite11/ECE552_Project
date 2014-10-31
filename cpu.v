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
//PC + 1 wires
wire [15:0] pc_plus1;
//PC + 1 + Offset wires
wire op_jal;
wire [15:0] pc_offset_in;
wire [15:0] pc_plus_offset_out;
//PC branch selector wires
wire op_jr;
wire take_branch;
wire [15:0] alt_pc;
//Register file wires
wire op_sw, op_lxb, rf_we, rf_re1, rf_re2, rf_hlt;
wire [3:0] rf_r1_in, rf_r2_in;
wire [3:0] wr_reg_in;
wire [15:0] wr_data_in;
wire [15:0] write_data;
wire [15:0] rf_r1_out, rf_r2_out;
//Sign extender wires
wire [15:0] sext4_out;
wire [15:0] sext9_out;
wire [15:0] sext12_out;
//ALU wires
wire alu_alt_src;
wire n, z, v;
wire [15:0] alu_in2;
wire [3:0] shamt;
wire [7:0] immed;
wire [3:0] alu_op;
wire [15:0] alu_out;
//Data Memory wires
wire dm_rd_en, dm_wr_en;
wire [15:0] dm_out;
wire mem_to_reg;
//Flag Register
wire [2:0] flag;
//Controller wires
wire [2:0] cond;
//Program Counter
PC cpu_pc(.clk(clk),.rst_n(rst_n),.pc_wr_en(pc_wr_en),
          .pc_in(pc_in),.pc_out(pc_out));
//Instruction Memory
IM cpu_im(.clk(clk),.addr(pc_out),.rd_en(im_rd_en),.instr(im_instr));
//PC + 1 adder
adder_16 cpu_pc_plus1(.in1(pc_out), .in2(16'h0001), .out(pc_plus1)); //.out needs to be pc_plus4_out
//MUX for selecting which offset to add to PC
mux_2to1_16 mux_pc_offset_in(.in0(sext9_out), .in1(sext12_out), .sel(op_jal), .out(pc_offset_in));
//PC+1 + offset adder
adder_16 cpu_pc_plus_offset(.in1(pc_plus1), .in2(pc_offset_in), .out(pc_plus_offset_out));
//Mux for selecting between offset add(B & JAL) or register value(JR)
mux_2to1_16 mux_pc_sel_jr(.in0(pc_plus_offset_out), .in1(rf_r1_out), .sel(op_jr), .out(alt_pc));
//Mux for selecting between PC + 1 or branch PC
mux_2to1_16 mux_pc_sel_branch(.in0(pc_plus1), .in1(alt_pc), .sel(take_branch), .out(pc_in));
//MUX for selecting which bits are for Reg2 read, if it's SW instuc then needs to be I[11:8] else I[3:0]
mux_2to1_4 mux_sw(.in0(im_instr[3:0]), .in1(im_instr[11:8]), .sel(op_sw), .out(rf_r2_in));
//MUX for selecting which bits are for Reg1 read, if it's LLB or LHB instuc then needs to be I[11:8] else I[7:4]
mux_2to1_4 mux_lxb(.in0(im_instr[7:4]), .in1(im_instr[11:8]), .sel(op_lxb), .out(rf_r1_in));
//MUX for selecting what reg will be written to, on JAL its R15 else I[11:8] 
mux_2to1_4 mux_rf_wr_reg(.in0(im_instr[11:8]), .in1(4'hf), .sel(op_jal), .out(wr_reg_in));
//MUX for selecting write data source, on JAL select pc_plus1, else write_data
mux_2to1_16 mux_rf_write_src(.in0(write_data), .in1(pc_plus1), .sel(op_jal), .out(wr_data_in));
//Register File
rf cpu_rf(.clk(clk),.p0_addr(rf_r1_in),.p1_addr(rf_r2_in),.p0(rf_r1_out),.p1(rf_r2_out),
          .re0(rf_re1),.re1(rf_re2),.dst_addr(wr_reg_in),.dst(wr_data_in),
          .we(rf_we),.hlt(rf_hlt));
//Sign extenders
sext_4to16 cpu_sext4(.imm(im_instr[3:0]), .out(sext4_out));
sext_9to16 cpu_sext9(.imm(im_instr[8:0]), .out(sext9_out));
sext_12to16 cpu_sext12(.imm(im_instr[11:0]), .out(sext12_out));
//MUX for selecting ALU Source, if 1 then select immediate, else Rt
mux_2to1_16 mux_alu_alt_src(.in0(rf_r2_out), .in1(sext4_out), .sel(alu_alt_src), .out(alu_in2));
//ALU
assign shamt = im_instr[3:0];
assign immed = im_instr[7:0];
assign alu_op = im_instr[15:12];
alu cpu_alu(.opcode(alu_op), .rs(rf_r1_out), .rt(alu_in2), .shamt(shamt), .immed(immed), 
            .out(alu_out), .n(n), .z(z), .v(v));
//Data Memory
DM cpu_dm(.clk(clk),.addr(alu_out),.re(dm_rd_en),.we(dm_wr_en),.wrt_data(rf_r2_out),.rd_data(dm_out));
//MUX for selecting write_data Source, if 1 then select DataMem out, else alu_out
mux_2to1_16 mux_write_data_src(.in0(alu_out), .in1(dm_out), .sel(mem_to_reg), .out(write_data));
//Flag reg
flag_reg cpu_flag(.clk(clk),.rst_n(rst_n),.flag_wr_en(~im_instr[15]),.n(n),.z(z),.v(v),.flag_out(flag));

//Controller
assign cond = im_instr[11:9];
controller cpu_control(.rst_n(rst_n), .opcode(alu_op), .cond(cond), .flag(flag), 
                       .pc_wr_en(pc_wr_en), .im_rd_en(im_rd_en), 
                       .rf_re1(rf_re1), .rf_re2(rf_re2), .rf_we(rf_we), .rf_hlt(rf_hlt),
                       .op_lxb(op_lxb), .op_sw(op_sw), .alu_alt_src(alu_alt_src), 
                       .dm_rd_en(dm_rd_en), .dm_wr_en(dm_wr_en), .mem_to_reg(mem_to_reg),
                       .op_jal(op_jal), .op_jr(op_jr), .take_branch(take_branch));
//Test purpose
assign pc = pc_out;
assign hlt = rf_hlt;
endmodule

//Test benches for cpu

//Test bench for PC and IM of cpu
module t_cpu_PC_IM();
reg clk, rst_n;
wire hlt;
wire [15:0] pc;

cpu uut(.clk(clk), .rst_n(rst_n), .hlt(hlt), .pc(pc));
initial $monitor("PC:%h, instruc:%h r1out:%h r2out:%h cond:%b pc_plus1:%h pc_offset:%h pc+offset:%h write_data:%h flag:%b cnrtl cond:%b branch%b", pc, uut.im_instr, uut.rf_r1_out, uut.rf_r2_out, uut.cond, uut.pc_plus1, uut.pc_offset_in,uut.pc_plus_offset_out, uut.write_data, uut.flag, uut.cpu_control.cond,uut.take_branch);

initial begin
  clk = 0;
  $display("rst assert\n");
  rst_n = 0;
  @(posedge clk);
  @(negedge clk);
  rst_n = 1;
  $display("rst deassert\n");
end 
  
always
  #1 clk = ~clk;
initial begin
//clk = 1'b1;
#100;
$stop;
end
endmodule
