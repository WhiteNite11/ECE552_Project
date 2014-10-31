//This is the top level design for Pipeline, it will have all the functions
//of the CPU, and output the PC
module cpu(clk, rst_n, hlt, pc);
input clk, rst_n;
output hlt;
output [15:0] pc;
//PC wires
wire [15:0] pc_in, pc_out;
wire pc_wr_en;
//Instruction memory wires
wire [15:0] im_instr, im_instr_IN;
wire im_rd_en;
//PC + 1 wires
wire [15:0] pc_plus1, pc_plus1_IN, pc_plus1_OUT;
//PC + 1 + Offset wires
wire op_jal, op_jal_ID;
wire [15:0] pc_offset_in;
wire [15:0] pc_plus_offset_out;
//PC branch selector wires
wire op_jr, op_jr_ID;
wire take_branch, take_branch_ID;
wire [15:0] alt_pc;
//Register file wires
wire op_sw, op_lxb, rf_we, rf_re1, rf_re2, rf_hlt;
wire rf_we_ID;
wire [3:0] rf_r1_in, rf_r2_in;
wire [3:0] wr_reg_in;
wire [15:0] wr_data_in;
wire [15:0] write_data;
wire [15:0] rf_r1_out, rf_r2_out, rf_r1_out_OUT, rf_r2_out_OUT;
wire [7:0]  im_instr_7_0;
//Sign extender wires
wire [15:0] sext4_out, sext4_out_OUT;
wire [15:0] sext9_out, sext9_out_OUT;
wire [15:0] sext12_out, sext12_out_OUT;
//ALU wires
wire alu_alt_src, alu_alt_src_ID;
wire n, z, v;
wire [15:0] alu_in2;
wire [3:0] shamt;
wire [7:0] immed;
wire [3:0]  alu_op_OUT, alu_op;
wire [15:0] alu_out;
//Data Memory wires
wire dm_rd_en, dm_wr_en, dm_rd_en_ID, dm_wr_en_ID;
wire [15:0] dm_out;
wire mem_to_reg, mem_to_reg_ID;
//Flag Register
wire [2:0] flag;
wire flag_wr_en;
//Controller wires
wire [2:0] cond;
//Program Counter
PC cpu_pc(.clk(clk),.rst_n(rst_n),.pc_wr_en(pc_wr_en),
          .pc_in(pc_in),.pc_out(pc_out));
//Instruction Memory
IM cpu_im(.clk(clk),.addr(pc_out),.rd_en(im_rd_en),.instr(im_instr_IN));
//PC + 1 adder
adder_16 cpu_pc_plus1(.in1(pc_out), .in2(16'h0001), .out(pc_plus1_IN)); 
//PIPE IF/ID
IF_ID_pipe cpu_IF_ID_pipe(.rst_n(rst_n), .clk(clk), 
                          .im_instr_IN(im_instr_IN), .pc_plus1_IN(pc_plus1_IN), 
                          .im_instr_OUT(im_instr), .pc_plus1_OUT(pc_plus1));
//MUX for selecting which offset to add to PC
mux_2to1_16 mux_pc_offset_in(.in0(sext9_out_OUT), .in1(sext12_out_OUT), .sel(op_jal_ID), .out(pc_offset_in));
//PC+1 + offset adder
adder_16 cpu_pc_plus_offset(.in1(pc_plus1_OUT), .in2(pc_offset_in), .out(pc_plus_offset_out));
//Mux for selecting between offset add(B & JAL) or register value(JR)
mux_2to1_16 mux_pc_sel_jr(.in0(pc_plus_offset_out), .in1(rf_r1_out_OUT), .sel(op_jr_ID), .out(alt_pc));
//Mux for selecting between PC + 1 or branch PC
mux_2to1_16 mux_pc_sel_branch(.in0(pc_plus1_OUT), .in1(alt_pc), .sel(take_branch_ID), .out(pc_in));
//MUX for selecting which bits are for Reg2 read, if it's SW instuc then needs to be I[11:8] else I[3:0]
mux_2to1_4 mux_sw(.in0(im_instr[3:0]), .in1(im_instr[11:8]), .sel(op_sw), .out(rf_r2_in));
//MUX for selecting which bits are for Reg1 read, if it's LLB or LHB instuc then needs to be I[11:8] else I[7:4]
mux_2to1_4 mux_lxb(.in0(im_instr[7:4]), .in1(im_instr[11:8]), .sel(op_lxb), .out(rf_r1_in));
//MUX for selecting what reg will be written to, on JAL its R15 else I[11:8] 
mux_2to1_4 mux_rf_wr_reg(.in0(im_instr[11:8]), .in1(4'hf), .sel(op_jal_ID), .out(wr_reg_in));
//MUX for selecting write data source, on JAL select pc_plus1, else write_data
mux_2to1_16 mux_rf_write_src(.in0(write_data), .in1(pc_plus1_OUT), .sel(op_jal_ID), .out(wr_data_in));
//Register File
rf cpu_rf(.clk(clk),.p0_addr(rf_r1_in),.p1_addr(rf_r2_in),.p0(rf_r1_out),.p1(rf_r2_out),
          .re0(rf_re1),.re1(rf_re2),.dst_addr(wr_reg_in),.dst(wr_data_in),
          .we(rf_we_ID),.hlt(rf_hlt));
//Sign extenders
sext_4to16 cpu_sext4(.imm(im_instr[3:0]), .out(sext4_out));
sext_9to16 cpu_sext9(.imm(im_instr[8:0]), .out(sext9_out));
sext_12to16 cpu_sext12(.imm(im_instr[11:0]), .out(sext12_out));
//PIPE ID/EX
ID_EX_pipe cpu_ID_EX_pipe(.rst_n(rst_n), .clk(clk), 
                  .im_instr_7_0_IN(im_instr[7:0]), .im_instr_7_0_OUT(im_instr_7_0),
                  .pc_plus1_IN(pc_plus1),  .pc_plus1_OUT(pc_plus1_OUT), 
                  .rf_r1_IN(rf_r1_out),      .rf_r2_IN(rf_r2_out),      .rf_we_IN(rf_we), 
                  .rf_r1_OUT(rf_r1_out_OUT), .rf_r2_OUT(rf_r2_out_OUT), .rf_we_OUT(rf_we_ID),
                  .sext4_IN(sext4_out),      .sext9_IN(sext9_out),      .sext12_IN(sext12_out), 
                  .sext4_OUT(sext4_out_OUT), .sext9_OUT(sext9_out_OUT), .sext12_OUT(sext12_out_OUT),
                  .alu_op_IN(im_instr[15:12]), .alu_alt_src_IN(alu_alt_src), 
                  .alu_op_OUT(alu_op_OUT),     .alu_alt_src_OUT(alu_alt_src_ID),
                  .dm_rd_en_IN(dm_rd_en),     .dm_wr_en_IN(dm_wr_en),     .mem_to_reg_IN(mem_to_reg), 
                  .dm_rd_en_OUT(dm_rd_en_ID), .dm_wr_en_OUT(dm_wr_en_ID), .mem_to_reg_OUT(mem_to_reg_ID),
                  .op_jal_IN(op_jal),     .op_jr_IN(op_jr),     .take_branch_IN(take_branch), 
                  .op_jal_OUT(op_jal_ID), .op_jr_OUT(op_jr_ID), .take_branch_OUT(take_branch_ID),
                  .flag_wr_en_IN(~im_instr[15]), .flag_wr_en_OUT(flag_wr_en));
//MUX for selecting ALU Source, if 1 then select immediate, else Rt
mux_2to1_16 mux_alu_alt_src(.in0(rf_r2_out_OUT), .in1(sext4_out_OUT), .sel(alu_alt_src_ID), .out(alu_in2));
//ALU
assign shamt = im_instr_7_0[3:0];
assign immed = im_instr_7_0[7:0];
assign alu_op = alu_op_OUT;
alu cpu_alu(.opcode(alu_op), .rs(rf_r1_out_OUT), .rt(alu_in2), .shamt(shamt), .immed(immed), 
            .out(alu_out), .n(n), .z(z), .v(v));
//Data Memory
DM cpu_dm(.clk(clk),.addr(alu_out),.re(dm_rd_en_ID),.we(dm_wr_en_ID),.wrt_data(rf_r2_out_OUT),.rd_data(dm_out));
//MUX for selecting write_data Source, if 1 then select DataMem out, else alu_out
mux_2to1_16 mux_write_data_src(.in0(alu_out), .in1(dm_out), .sel(mem_to_reg_ID), .out(write_data));
//Flag reg
flag_reg cpu_flag(.clk(clk),.rst_n(rst_n),.flag_wr_en(flag_wr_en),.n(n),.z(z),.v(v),.flag_out(flag));

//Controller
assign cond = im_instr[11:9];
controller cpu_control(.rst_n(rst_n), .opcode(im_instr[15:12]), .cond(cond), .flag(flag), 
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
initial $monitor("clk:%b PC:%h, pc+1_in:%h pc+1_out:%h instr_in:%h instruc_out:%h alu_olp:%h r1out:%h r2out:%h write_data:%h rf_we:%b rf_we_ID:%b", clk, pc, uut.pc_plus1_IN, uut.pc_plus1, uut.im_instr_IN, uut.im_instr, uut.alu_op, uut.rf_r1_out_OUT, uut.rf_r2_out_OUT, uut.write_data,uut.rf_we, uut.rf_we_ID);

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
#50;
$stop;
end
endmodule
