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
wire [15:0] pc_plus1_IF_OUT, pc_plus1_IF_IN, pc_plus1_ID_OUT, pp1_EX_OUT, pp1_MEM_OUT;
//PC + 1 + Offset wires
wire op_jal, op_jal_ID, op_jal_EX_OUT, op_jal_MEM_OUT;
wire [15:0] pc_offset_in;
wire [15:0] pc_plus_offset_out;
//PC branch selector wires
wire op_jr, op_jr_ID;
wire take_branch, take_branch_ID, take_branch_OUT;
wire [3:0] br_info_ID, br_info_EX_OUT;
wire [15:0] alt_pc, alt_pc_EX_OUT;
//Register file wires
wire op_sw, op_lxb, rf_we, rf_re1, rf_re2, rf_hlt, rf_hlt_ID, rf_hlt_EX_OUT, rf_hlt_MEM_OUT;
wire rf_we_ID, rf_we_EX_OUT, rf_we_MEM_OUT;
wire [3:0] rf_r1_in, rf_r2_in;
wire [3:0] wr_reg_in;
wire [15:0] wr_data_in;
wire [15:0] write_data;
wire [15:0] rf_r1_out, rf_r2_out, rf_r1_out_OUT, rf_r2_out_OUT, wrt_data_EX_OUT;
wire [15:0] im_instr_ID_OUT;
wire [3:0] wr_reg_EX_OUT, wr_reg_MEM_OUT;
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
wire [3:0]  alu_op;
wire [15:0] alu_out, alu_out_EX_OUT, alu_out_MEM_OUT;
//Data Memory wires
wire dm_rd_en, dm_wr_en, dm_rd_en_ID, dm_wr_en_ID, dm_rd_en_EX_OUT, dm_wr_en_EX_OUT;
wire [15:0] dm_out, dm_MEM_OUT;
wire mem_to_reg, mem_to_reg_ID, mem_to_reg_EX_OUT, mem_to_reg_MEM_OUT;
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
adder_16 cpu_pc_plus1(.in1(pc_out), .in2(16'h0001), .out(pc_plus1_IF_IN)); 
//PIPE IF/ID
IF_ID_pipe cpu_IF_ID_pipe(.rst_n(rst_n), .clk(clk), 
                          .im_instr_IN(im_instr_IN), .pc_plus1_IN(pc_plus1_IF_IN), 
                          .im_instr_OUT(im_instr), .pc_plus1_OUT(pc_plus1_IF_OUT));
//MUX for selecting which offset to add to PC
mux_2to1_16 mux_pc_offset_in(.in0(sext9_out_OUT), .in1(sext12_out_OUT), .sel(op_jal_ID), .out(pc_offset_in));
//PC+1 + offset adder
adder_16 cpu_pc_plus_offset(.in1(pc_plus1_ID_OUT), .in2(pc_offset_in), .out(pc_plus_offset_out));
//Mux for selecting between offset add(B & JAL) or register value(JR)
mux_2to1_16 mux_pc_sel_jr(.in0(pc_plus_offset_out), .in1(rf_r1_out_OUT), .sel(op_jr_ID), .out(alt_pc));
//Mux for selecting between PC + 1 or branch PC
mux_2to1_16 mux_pc_sel_branch(.in0(pc_plus1_IF_IN), .in1(alt_pc_EX_OUT), .sel(take_branch_OUT), .out(pc_in));
//MUX for selecting which bits are for Reg2 read, if it's SW instuc then needs to be I[11:8] else I[3:0]
mux_2to1_4 mux_sw(.in0(im_instr[3:0]), .in1(im_instr[11:8]), .sel(op_sw), .out(rf_r2_in));
//MUX for selecting which bits are for Reg1 read, if it's LLB or LHB instuc then needs to be I[11:8] else I[7:4]
mux_2to1_4 mux_lxb(.in0(im_instr[7:4]), .in1(im_instr[11:8]), .sel(op_lxb), .out(rf_r1_in));
//MUX for selecting what reg will be written to, on JAL its R15 else I[11:8] 
mux_2to1_4 mux_rf_wr_reg(.in0(wr_reg_MEM_OUT), .in1(4'hf), .sel(op_jal_MEM_OUT), .out(wr_reg_in));
//MUX for selecting write data source, on JAL select pc_plus1, else write_data
mux_2to1_16 mux_rf_write_src(.in0(write_data), .in1(pp1_MEM_OUT), .sel(op_jal_MEM_OUT), .out(wr_data_in));
//Register File
rf cpu_rf(.clk(clk),.p0_addr(rf_r1_in),.p1_addr(rf_r2_in),.p0(rf_r1_out),.p1(rf_r2_out),
          .re0(rf_re1),.re1(rf_re2),.dst_addr(wr_reg_in),.dst(wr_data_in),
          .we(rf_we_MEM_OUT),.hlt(rf_hlt_MEM_OUT));
//Sign extenders
sext_4to16 cpu_sext4(.imm(im_instr[3:0]), .out(sext4_out));
sext_9to16 cpu_sext9(.imm(im_instr[8:0]), .out(sext9_out));
sext_12to16 cpu_sext12(.imm(im_instr[11:0]), .out(sext12_out));
//PIPE ID/EX
ID_EX_pipe cpu_ID_EX_pipe(.rst_n(rst_n), .clk(clk), 
                  .im_instr_ID_IN(im_instr), .im_instr_ID_OUT(im_instr_ID_OUT),
                  .pc_plus1_IN(pc_plus1_IF_OUT),  .pc_plus1_OUT(pc_plus1_ID_OUT), 
                  .rf_r1_IN(rf_r1_out),      .rf_r2_IN(rf_r2_out),      .rf_we_IN(rf_we), 
                  .rf_r1_OUT(rf_r1_out_OUT), .rf_r2_OUT(rf_r2_out_OUT), .rf_we_OUT(rf_we_ID),
                  .sext4_IN(sext4_out),      .sext9_IN(sext9_out),      .sext12_IN(sext12_out), 
                  .sext4_OUT(sext4_out_OUT), .sext9_OUT(sext9_out_OUT), .sext12_OUT(sext12_out_OUT),
                  .alu_alt_src_IN(alu_alt_src),.alu_alt_src_OUT(alu_alt_src_ID),
                  .dm_rd_en_IN(dm_rd_en),     .dm_wr_en_IN(dm_wr_en),     .mem_to_reg_IN(mem_to_reg), 
                  .dm_rd_en_OUT(dm_rd_en_ID), .dm_wr_en_OUT(dm_wr_en_ID), .mem_to_reg_OUT(mem_to_reg_ID),
                  .op_jal_IN(op_jal),     .op_jr_IN(op_jr),     .take_branch_IN(take_branch), 
                  .op_jal_OUT(op_jal_ID), .op_jr_OUT(op_jr_ID), .take_branch_OUT(take_branch_ID),
                  .flag_wr_en_IN(~im_instr[15]), .flag_wr_en_OUT(flag_wr_en),
                  .rf_hlt_IN(rf_hlt), .rf_hlt_OUT(rf_hlt_ID),
                  .br_info_ID_IN({take_branch, cond}), .br_info_ID_OUT(br_info_ID));
//MUX for selecting ALU Source, if 1 then select immediate, else Rt
mux_2to1_16 mux_alu_alt_src(.in0(rf_r2_out_OUT), .in1(sext4_out_OUT), .sel(alu_alt_src_ID), .out(alu_in2));
//ALU
assign shamt = im_instr_ID_OUT[3:0];
assign immed = im_instr_ID_OUT[7:0];
assign alu_op = im_instr_ID_OUT[15:12];
alu cpu_alu(.opcode(alu_op), .rs(rf_r1_out_OUT), .rt(alu_in2), .shamt(shamt), .immed(immed), 
            .out(alu_out), .n(n), .z(z), .v(v));

// EX/MEM pipe.
EX_MEM_pipe cp_EX_MEM_pipe(.clk(clk), .rst_n(rst_n),
                   .alu_out_EX_IN(alu_out), .alu_out_EX_OUT(alu_out_EX_OUT),
                   .wrt_data_EX_IN(rf_r2_out_OUT), .wrt_data_EX_OUT(wrt_data_EX_OUT),
                   .pp1_EX_IN(pc_plus1_ID_OUT), .pp1_EX_OUT(pp1_EX_OUT),
                   .alt_pc_EX_IN(alt_pc), .alt_pc_EX_OUT(alt_pc_EX_OUT),
                   .dm_en_EX_IN({dm_rd_en_ID, dm_wr_en_ID}), .dm_en_EX_OUT({dm_rd_en_EX_OUT, dm_wr_en_EX_OUT}),
                   .mr_EX_IN(mem_to_reg_ID), .mr_EX_OUT(mem_to_reg_EX_OUT),
                   .br_info_EX_IN(br_info_ID), .br_info_EX_OUT(br_info_EX_OUT),
                   .rf_we_EX_IN(rf_we_ID), .rf_we_EX_OUT(rf_we_EX_OUT),
                   .op_jal_EX_IN(op_jal_ID), .op_jal_EX_OUT(op_jal_EX_OUT),
                   .rf_hlt_EX_IN(rf_hlt_ID), .rf_hlt_EX_OUT(rf_hlt_EX_OUT),
                   .wr_reg_EX_IN(im_instr_ID_OUT[11:8]), .wr_reg_EX_OUT(wr_reg_EX_OUT));
//Flag reg
flag_reg cpu_flag(.clk(clk),.rst_n(rst_n),.flag_wr_en(flag_wr_en),.n(n),.z(z),.v(v),.flag_out(flag));
// Branch controller.
branch_cntrl cpu_branch_cntrl(.flag(flag), .cond(br_info_EX_OUT[2:0]), .take_branch_IN(br_info_EX_OUT[3]), .take_branch_OUT(take_branch_OUT));                 
//Data Memory
DM cpu_dm(.clk(clk), .addr(alu_out_EX_OUT), .re(dm_rd_en_EX_OUT), .we(dm_wr_en_EX_OUT), .wrt_data(wrt_data_EX_OUT), .rd_data(dm_out));
// MEM/WB pipe
MEM_WB_pipe cpu_MEM_WB_pipe(.clk(clk), .rst_n(rst_n),
                   .alu_out_MEM_IN(alu_out_EX_OUT), .alu_out_MEM_OUT(alu_out_MEM_OUT),
                   .dm_MEM_IN(dm_out), .dm_MEM_OUT(dm_MEM_OUT),
                   .pp1_MEM_IN(pp1_EX_OUT), .pp1_MEM_OUT(pp1_MEM_OUT),
                   .mr_MEM_IN(mem_to_reg_EX_OUT), .mr_MEM_OUT(mem_to_reg_MEM_OUT),
                   .rf_we_MEM_IN(rf_we_EX_OUT), .rf_we_MEM_OUT(rf_we_MEM_OUT),
                   .op_jal_MEM_IN(op_jal_EX_OUT), .op_jal_MEM_OUT(op_jal_MEM_OUT),
                   .rf_hlt_MEM_IN(rf_hlt_EX_OUT), .rf_hlt_MEM_OUT(rf_hlt_MEM_OUT),
                   .wr_reg_MEM_IN(wr_reg_EX_OUT), .wr_reg_MEM_OUT(wr_reg_MEM_OUT));
//MUX for selecting write_data Source, if 1 then select DataMem out, else alu_out
mux_2to1_16 mux_write_data_src(.in0(alu_out_MEM_OUT), .in1(dm_MEM_OUT), .sel(mem_to_reg_MEM_OUT), .out(write_data));


//Controller
assign cond = im_instr[11:9];
controller cpu_control(.rst_n(rst_n), .opcode(im_instr[15:12]),
                       .pc_wr_en(pc_wr_en), .im_rd_en(im_rd_en), 
                       .rf_re1(rf_re1), .rf_re2(rf_re2), .rf_we(rf_we), .rf_hlt(rf_hlt),
                       .op_lxb(op_lxb), .op_sw(op_sw), .alu_alt_src(alu_alt_src), 
                       .dm_rd_en(dm_rd_en), .dm_wr_en(dm_wr_en), .mem_to_reg(mem_to_reg),
                       .op_jal(op_jal), .op_jr(op_jr), .take_branch(take_branch));
//Test purpose
assign pc = pc_in;
assign hlt = rf_hlt;
endmodule

//Test benches for cpu

//Test bench for PC and IM of cpu
module t_cpu_PC_IM();
reg clk, rst_n;
wire hlt;
wire [15:0] pc;

cpu uut(.clk(clk), .rst_n(rst_n), .hlt(hlt), .pc(pc));
always @(posedge clk) begin
  $display("clk:%b PC:%h,  pc+offset:%h alt_pc%h pc_in:%h pc+1_in:%h instr_in:%h || pc+1_out:%h instruc_out:%h || flag_en:%b alu_op:%h nzv:%b%b%b r1out:%h r2out:%h ||branch+cond%b flag:%b write_data:%h take_branch_OUT:%b rf_we:%b", 
  clk, uut.pc_out, uut.pc_plus_offset_out, uut.alt_pc_EX_OUT, uut.pc_in, uut.pc_plus1_IF_IN, uut.im_instr_IN, uut.pc_plus1_IF_OUT, uut.im_instr, uut.cpu_flag.flag_wr_en, uut.alu_op, uut.n, uut.z, uut.v, uut.rf_r1_out_OUT, uut.rf_r2_out_OUT, uut.br_info_EX_OUT, uut.flag,uut.write_data,uut.take_branch_OUT,uut.rf_we_EX_OUT);
end

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
