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
module ID_EX_pipe(rst_n, clk, im_instr_7_0_IN, im_instr_7_0_OUT,
                  pc_plus1_IN,  pc_plus1_OUT, 
                  rf_r1_IN, rf_r2_IN, rf_we_IN, rf_r1_OUT, rf_r2_OUT, rf_we_OUT,
                  sext4_IN, sext9_IN, sext12_IN, sext4_OUT, sext9_OUT, sext12_OUT,
                  alu_op_IN, alu_alt_src_IN, alu_op_OUT, alu_alt_src_OUT,
                  dm_rd_en_IN, dm_wr_en_IN, mem_to_reg_IN, dm_rd_en_OUT, dm_wr_en_OUT, mem_to_reg_OUT,
                  op_jal_IN, op_jr_IN, take_branch_IN, op_jal_OUT, op_jr_OUT, take_branch_OUT, 
                  flag_wr_en_IN, flag_wr_en_OUT);

input rst_n, clk, flag_wr_en_IN;
input [3:0] alu_op_IN;
input [7:0] im_instr_7_0_IN;
input [15:0] pc_plus1_IN, rf_r1_IN, rf_r2_IN, sext4_IN, sext9_IN, sext12_IN;
input rf_we_IN, alu_alt_src_IN, dm_rd_en_IN, dm_wr_en_IN, mem_to_reg_IN, op_jal_IN, op_jr_IN, take_branch_IN;

output flag_wr_en_OUT;
output [3:0] alu_op_OUT;
output [7:0] im_instr_7_0_OUT;
output [15:0] pc_plus1_OUT, rf_r1_OUT, rf_r2_OUT, sext4_OUT, sext9_OUT, sext12_OUT;
output rf_we_OUT, alu_alt_src_OUT, dm_rd_en_OUT, dm_wr_en_OUT, mem_to_reg_OUT, op_jal_OUT, op_jr_OUT, take_branch_OUT;

//Pipe block for shamt & immed
dff8 im_instr_7_0_ff(.rst_n(rst_n), .clk(clk), .d(im_instr_7_0_IN), .q(im_instr_7_0_OUT));
//Pipe block for PC+1
dff16 im_pc_plus1_ff(.rst_n(rst_n), .clk(clk), .d(pc_plus1_IN), .q(pc_plus1_OUT));
//Pipe blocks for Reg ports
dff16 rf1_ff(.rst_n(rst_n), .clk(clk), .d(rf_r1_IN), .q(rf_r1_OUT));
dff16 rf2_ff(.rst_n(rst_n), .clk(clk), .d(rf_r2_IN), .q(rf_r2_OUT));
//Pipe block for sign extened blocks
dff16 sext4_ff(.rst_n(rst_n), .clk(clk), .d(sext4_IN), .q(sext4_OUT));
dff16 sext9_ff(.rst_n(rst_n), .clk(clk), .d(sext9_IN), .q(sext9_OUT));
dff16 sext12_ff(.rst_n(rst_n), .clk(clk), .d(sext12_IN), .q(sext12_OUT));
//Pipe block for alu_op
dff4 alu_op_ff(.rst_n(rst_n), .clk(clk), .d(alu_op_IN), .q(alu_op_OUT));
//Pipe block for control signals
dff8 control_signals_ff(.rst_n(rst_n), .clk(clk), 
  .d({rf_we_IN,alu_alt_src_IN, dm_rd_en_IN, dm_wr_en_IN, mem_to_reg_IN, op_jal_IN, op_jr_IN, take_branch_IN}), 
  .q({rf_we_OUT, alu_alt_src_OUT, dm_rd_en_OUT, dm_wr_en_OUT, mem_to_reg_OUT, op_jal_OUT, op_jr_OUT, take_branch_OUT}));
//Pipe block for flag
dff flag_ff(.clk(clk), .d(flag_wr_en_IN), .rst_n(rst_n), .q(flag_wr_en_OUT));

endmodule
