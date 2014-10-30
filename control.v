module controller(rst_n, opcode, pc_wr_en, im_rd_en, rf_re1, rf_re2, rf_we, rf_hlt,
                  op_lxb, op_sw, alu_alt_src, dm_rd_en, dm_wr_en, mem_to_reg);
input [3:0] opcode;
input rst_n;
//PC signals
output  pc_wr_en;
//Instruction memory signals
output im_rd_en;
//Register file signals
output reg op_lxb;
output reg op_sw; 
output reg rf_re1; 
output reg rf_re2; 
output reg rf_we; 
output reg rf_hlt;
//ALU control signals
output reg alu_alt_src;
//Data memory control signals
output reg dm_rd_en; 
output reg dm_wr_en; 
output reg mem_to_reg;
//Parameters for opcode
localparam ADD    = 4'h0;
localparam PADDSB = 4'h1;
localparam SUB    = 4'h2;
localparam AND    = 4'h3;
localparam NOR    = 4'h4;
localparam SLL    = 4'h5;
localparam SRL    = 4'h6;
localparam SRA    = 4'h7;
localparam LW     = 4'h8;
localparam SW     = 4'h9;
localparam LHB    = 4'ha;
localparam LLB    = 4'hb;
localparam B      = 4'hc;
localparam JAL    = 4'hd;
localparam JR     = 4'he;
localparam HLT    = 4'hf;
//assign control instructions before controller
assign im_rd_en = rst_n ? 1'b1: 1'b0;
assign pc_wr_en = rst_n ? 1'b1: 1'b0;
//Case statement on every opcode
always @(opcode) begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b0;
    rf_re2 = 1'b0;
    rf_we  = 1'b0;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
  case (opcode)
    ADD: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b1;
    rf_re2 = 1'b1;
    rf_we  = 1'b1;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    PADDSB: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b1;
    rf_re2 = 1'b1;
    rf_we  = 1'b1;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    SUB: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b1;
    rf_re2 = 1'b1;
    rf_we  = 1'b1;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    AND: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b1;
    rf_re2 = 1'b1;
    rf_we  = 1'b1;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    NOR: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b1;
    rf_re2 = 1'b1;
    rf_we  = 1'b1;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    SLL: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b1;
    rf_re2 = 1'b0;
    rf_we  = 1'b1;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    SRL: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b1;
    rf_re2 = 1'b0;
    rf_we  = 1'b1;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    SRA: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b1;
    rf_re2 = 1'b0;
    rf_we  = 1'b1;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    LW: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b1;
    rf_re2 = 1'b0;
    rf_we  = 1'b1;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b1;
    dm_rd_en    = 1'b1;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b1;
    end
    SW: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b1;
    rf_re1 = 1'b1;
    rf_re2 = 1'b1;
    rf_we  = 1'b0;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b1;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b1;
    mem_to_reg  = 1'b0;
    end
    LHB: begin
    op_lxb = 1'b1; 
    op_sw  = 1'b0;
    rf_re1 = 1'b1;
    rf_re2 = 1'b0;
    rf_we  = 1'b1;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    LLB: begin
    op_lxb = 1'b1; 
    op_sw  = 1'b0;
    rf_re1 = 1'b1;
    rf_re2 = 1'b0;
    rf_we  = 1'b1;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    B: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b0;
    rf_re2 = 1'b0;
    rf_we  = 1'b0;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    JAL: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b0;
    rf_re2 = 1'b0;
    rf_we  = 1'b1;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    JR: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b1;
    rf_re2 = 1'b0;
    rf_we  = 1'b0;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    HLT: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b0;
    rf_re2 = 1'b0;
    rf_we  = 1'b0;
    rf_hlt = 1'b1; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
    default: begin
    op_lxb = 1'b0; 
    op_sw  = 1'b0;
    rf_re1 = 1'b0;
    rf_re2 = 1'b0;
    rf_we  = 1'b0;
    rf_hlt = 1'b0; 
    alu_alt_src = 1'b0;
    dm_rd_en    = 1'b0;
    dm_wr_en    = 1'b0;
    mem_to_reg  = 1'b0;
    end
  endcase
end
endmodule
