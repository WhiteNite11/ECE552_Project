//This module will hold all the pipe line registers

//IF/ID Pipe
module IF_ID_pipe(rst_n, clk, im_instr_IN, pc_plus1_IN, im_instr_OUT, pc_plus1_OUT);
input rst_n, clk;
input [15:0] im_instr_IN, pc_plus1_IN;
output [15:0] im_instr_OUT, pc_plus1_OUT;

//Pipe block for instruction
dff16 im_instr_ff(.rst_n(rst_n), .clk(clk), .d(im_instr_IN), .q(im_instr_OUT));
//Pipe block for PC+1
dff16 im_pc_plus1_ff(.rst_n(rst_n), .clk(clk), .d(pc_plus1_IN), .q(pc_plus1_OUT));
endmodule

//ID/EX Pipe
module ID_EX_pipe(rst_n, clk, im_instr_ID_IN, im_instr_ID_OUT,
                  pc_plus1_IN,  pc_plus1_OUT, 
                  rf_r1_IN, rf_r2_IN, rf_we_IN, rf_r1_OUT, rf_r2_OUT, rf_we_OUT,
                  sext4_IN, sext9_IN, sext12_IN, sext4_OUT, sext9_OUT, sext12_OUT,
                  alu_alt_src_IN, alu_alt_src_OUT,
                  dm_rd_en_IN, dm_wr_en_IN, mem_to_reg_IN, dm_rd_en_OUT, dm_wr_en_OUT, mem_to_reg_OUT,
                  op_jal_IN, op_jr_IN, take_branch_IN, op_jal_OUT, op_jr_OUT, take_branch_OUT, 
                  flag_wr_en_IN, flag_wr_en_OUT,
                  rf_hlt_IN, rf_hlt_OUT,
                  br_info_ID_IN, br_info_ID_OUT,
                  rs_ID_IN, rs_ID_OUT,
                  rt_ID_IN, rt_ID_OUT);

input rst_n, clk, flag_wr_en_IN, rf_hlt_IN;
input [3:0] br_info_ID_IN, rs_ID_IN, rt_ID_IN;
input [15:0] im_instr_ID_IN;
input [15:0] pc_plus1_IN, rf_r1_IN, rf_r2_IN, sext4_IN, sext9_IN, sext12_IN;
input rf_we_IN, alu_alt_src_IN, dm_rd_en_IN, dm_wr_en_IN, mem_to_reg_IN, op_jal_IN, op_jr_IN, take_branch_IN;

output flag_wr_en_OUT, rf_hlt_OUT;
output [3:0] br_info_ID_OUT, rs_ID_OUT, rt_ID_OUT;
output [15:0] im_instr_ID_OUT;
output [15:0] pc_plus1_OUT, rf_r1_OUT, rf_r2_OUT, sext4_OUT, sext9_OUT, sext12_OUT;
output rf_we_OUT, alu_alt_src_OUT, dm_rd_en_OUT, dm_wr_en_OUT, mem_to_reg_OUT, op_jal_OUT, op_jr_OUT, take_branch_OUT;

//Pipe block for alu op, write reg dst, shamt & immed
dff16 im_instr_ff(.rst_n(rst_n), .clk(clk), .d(im_instr_ID_IN), .q(im_instr_ID_OUT));
//Pipe block for PC+1
dff16 im_pc_plus1_ff(.rst_n(rst_n), .clk(clk), .d(pc_plus1_IN), .q(pc_plus1_OUT));
//Pipe blocks for Reg ports
dff16 rf1_ff(.rst_n(rst_n), .clk(clk), .d(rf_r1_IN), .q(rf_r1_OUT));
dff16 rf2_ff(.rst_n(rst_n), .clk(clk), .d(rf_r2_IN), .q(rf_r2_OUT));
//Pipe block for sign extened blocks
dff16 sext4_ff(.rst_n(rst_n), .clk(clk), .d(sext4_IN), .q(sext4_OUT));
dff16 sext9_ff(.rst_n(rst_n), .clk(clk), .d(sext9_IN), .q(sext9_OUT));
dff16 sext12_ff(.rst_n(rst_n), .clk(clk), .d(sext12_IN), .q(sext12_OUT));
//Pipe block for control signals
dff8 control_signals_ff(.rst_n(rst_n), .clk(clk), 
  .d({rf_we_IN,alu_alt_src_IN, dm_rd_en_IN, dm_wr_en_IN, mem_to_reg_IN, op_jal_IN, op_jr_IN, take_branch_IN}), 
  .q({rf_we_OUT, alu_alt_src_OUT, dm_rd_en_OUT, dm_wr_en_OUT, mem_to_reg_OUT, op_jal_OUT, op_jr_OUT, take_branch_OUT}));
//Pipe block for flag
dff flag_ff(.clk(clk), .d(flag_wr_en_IN), .rst_n(rst_n), .q(flag_wr_en_OUT));
//Pipe block for hlt flag
dff hlt_ff(.clk(clk), .d(rf_hlt_IN), .rst_n(rst_n), .q(rf_hlt_OUT));
//Pipe block for cond and take_branch
dff4 cond_ff(.clk(clk), .d(br_info_ID_IN), .rst_n(rst_n), .q(br_info_ID_OUT));
//Pipe block for Rs number
dff4 rs_ff(.clk(clk), .d(rs_ID_IN), .rst_n(rst_n), .q(rs_ID_OUT));
//Pipe block for Rt number
dff4 rt_ff(.clk(clk), .d(rt_ID_IN), .rst_n(rst_n), .q(rt_ID_OUT));

endmodule

//EX/MEM PIPE
module EX_MEM_pipe(clk, rst_n,
                   alu_out_EX_IN, alu_out_EX_OUT,
                   wrt_data_EX_IN, wrt_data_EX_OUT,
                   pp1_EX_IN, pp1_EX_OUT,
                   alt_pc_EX_IN, alt_pc_EX_OUT,
                   dm_en_EX_IN, dm_en_EX_OUT,
                   mr_EX_IN, mr_EX_OUT,
                   br_info_EX_IN, br_info_EX_OUT,
                   rf_we_EX_IN, rf_we_EX_OUT,
                   op_jal_EX_IN, op_jal_EX_OUT,
                   op_jr_EX_IN, op_jr_EX_OUT,
                   rf_hlt_EX_IN, rf_hlt_EX_OUT,
                   wr_reg_EX_IN, wr_reg_EX_OUT);
                   
input [15:0] alu_out_EX_IN, wrt_data_EX_IN, pp1_EX_IN, alt_pc_EX_IN;
input [3:0] br_info_EX_IN, wr_reg_EX_IN;
input [1:0] dm_en_EX_IN;
input mr_EX_IN, op_jal_EX_IN, op_jr_EX_IN, rf_we_EX_IN, rf_hlt_EX_IN, clk, rst_n;

output[15:0] alu_out_EX_OUT, wrt_data_EX_OUT, pp1_EX_OUT, alt_pc_EX_OUT;
output [3:0] br_info_EX_OUT, wr_reg_EX_OUT;
output [1:0] dm_en_EX_OUT;
output mr_EX_OUT, op_jal_EX_OUT, op_jr_EX_OUT, rf_we_EX_OUT, rf_hlt_EX_OUT;


// Pipe for alu_out.
dff16 alu_out_ff(.rst_n(rst_n), .clk(clk), .d(alu_out_EX_IN), .q(alu_out_EX_OUT));

// Pipe for wrt_data.
dff16 wrt_data_ff(.rst_n(rst_n), .clk(clk), .d(wrt_data_EX_IN), .q(wrt_data_EX_OUT));

// Pipe for pc plus 1.
dff16 pp1_ff(.rst_n(rst_n), .clk(clk), .d(pp1_EX_IN), .q(pp1_EX_OUT));

// Pipe for alt_pc.
dff16 alt_pc_ff(.rst_n(rst_n), .clk(clk), .d(alt_pc_EX_IN), .q(alt_pc_EX_OUT));

// Pipe for dm_rd_en and dm_wr_en.
dff2 dm_en_ff(.rst_n(rst_n), .clk(clk), .d(dm_en_EX_IN), .q(dm_en_EX_OUT));

// Pipe for mem to reg.
dff mr_ff(.rst_n(rst_n), .clk(clk), .d(mr_EX_IN), .q(mr_EX_OUT));

// Pipe for wr_reg.
dff4 wr_reg_ff(.rst_n(rst_n), .clk(clk), .d(wr_reg_EX_IN), .q(wr_reg_EX_OUT));

// Pipe for br_info.
dff4 br_info_ff(.rst_n(rst_n), .clk(clk), .d(br_info_EX_IN), .q(br_info_EX_OUT));

// Pipe for rf_we.
dff rf_we_ff(.rst_n(rst_n), .clk(clk), .d(rf_we_EX_IN), .q(rf_we_EX_OUT));

// Pipe for op_jal.
dff op_jal_ff(.rst_n(rst_n), .clk(clk), .d(op_jal_EX_IN), .q(op_jal_EX_OUT));

// Pipe for op_jr.
dff op_jr_ff(.rst_n(rst_n), .clk(clk), .d(op_jr_EX_IN), .q(op_jr_EX_OUT));

// Pipe for rf_hlt.
dff rf_hlt_ff(.rst_n(rst_n), .clk(clk), .d(rf_hlt_EX_IN), .q(rf_hlt_EX_OUT));
endmodule

//EX/MEM PIPE
module MEM_WB_pipe(clk, rst_n,
                   alu_out_MEM_IN, alu_out_MEM_OUT,
                   dm_MEM_IN, dm_MEM_OUT,
                   pp1_MEM_IN, pp1_MEM_OUT,
                   mr_MEM_IN, mr_MEM_OUT,
                   rf_we_MEM_IN, rf_we_MEM_OUT,
                   op_jal_MEM_IN, op_jal_MEM_OUT,
                   rf_hlt_MEM_IN, rf_hlt_MEM_OUT,
                   wr_reg_MEM_IN, wr_reg_MEM_OUT);
                   
input [15:0] alu_out_MEM_IN, pp1_MEM_IN, dm_MEM_IN;
input [3:0]  wr_reg_MEM_IN;
input mr_MEM_IN, op_jal_MEM_IN, rf_we_MEM_IN, rf_hlt_MEM_IN, clk, rst_n;

output [15:0] alu_out_MEM_OUT, pp1_MEM_OUT, dm_MEM_OUT;
output [3:0]  wr_reg_MEM_OUT;
output mr_MEM_OUT, op_jal_MEM_OUT, rf_we_MEM_OUT, rf_hlt_MEM_OUT;

// Pipe for alu_out pass through.
dff16 alu_out_ff(.rst_n(rst_n), .clk(clk), .d(alu_out_MEM_IN), .q(alu_out_MEM_OUT));

// Pipe for alu_out pass through.
dff16 dm_out_ff(.rst_n(rst_n), .clk(clk), .d(dm_MEM_IN), .q(dm_MEM_OUT));

// Pipe for pc plus 1.
dff16 pp1_ff(.rst_n(rst_n), .clk(clk), .d(pp1_MEM_IN), .q(pp1_MEM_OUT));

// Pipe for mem to reg.
dff mr_ff(.rst_n(rst_n), .clk(clk), .d(mr_MEM_IN), .q(mr_MEM_OUT));

// Pipe for rf_we.
dff rf_we_ff(.rst_n(rst_n), .clk(clk), .d(rf_we_MEM_IN), .q(rf_we_MEM_OUT));

// Pipe for op_jal.
dff op_jal_ff(.rst_n(rst_n), .clk(clk), .d(op_jal_MEM_IN), .q(op_jal_MEM_OUT));

// Pipe for wr_reg.
dff4 wr_reg_ff(.rst_n(rst_n), .clk(clk), .d(wr_reg_MEM_IN), .q(wr_reg_MEM_OUT));

// Pipe for rf_hlt.
dff rf_hlt_ff(.rst_n(rst_n), .clk(clk), .d(rf_hlt_MEM_IN), .q(rf_hlt_MEM_OUT));
 
endmodule
