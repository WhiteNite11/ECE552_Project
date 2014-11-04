module controller(rst_n, opcode, pc_wr_en, im_rd_en, rf_re1, rf_re2, rf_we, rf_hlt,
                  op_lxb, op_sw, alu_alt_src, dm_rd_en, dm_wr_en, mem_to_reg, op_jal, op_jr, take_branch);
input [3:0] opcode;
input rst_n;
//PC signals
output  reg pc_wr_en;
//Instruction memory signals
output reg im_rd_en;
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
//PC update control signals
output reg op_jal; 
output reg op_jr; 
output reg take_branch;
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
localparam BRANCH = 4'hc;
localparam JAL    = 4'hd;
localparam JR     = 4'he;
localparam HLT    = 4'hf;

//Case statement on every opcode
always @(opcode, rst_n) begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
  case (opcode)
    ADD: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
    PADDSB: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
    SUB: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
    AND: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
    NOR: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
    SLL: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
    SRL: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
    SRA: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
    LW: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
    SW: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
    LHB: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
    LLB: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
    BRANCH: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b1;
    end
    JAL: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b1; 
    op_jr       = 1'b0; 
    take_branch = 1'b1;
    end
    JR: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b1; 
    take_branch = 1'b1;
    end
    HLT: begin
    im_rd_en = 1'b0;
    pc_wr_en = 1'b0;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
    default: begin
    im_rd_en = 1'b1;
    pc_wr_en = 1'b1;
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
    op_jal      = 1'b0; 
    op_jr       = 1'b0; 
    take_branch = 1'b0;
    end
  endcase
end
endmodule

//Branch controller
module branch_cntrl(flag, cond, op_jal, op_jr, take_branch_IN, take_branch_OUT);
input [2:0] cond, flag;
input op_jal, op_jr, take_branch_IN;

reg take_branch; 
output take_branch_OUT;

assign take_branch_OUT = (take_branch & take_branch_IN) | op_jal | op_jr; 
localparam NE    = 3'b000;
localparam EQ    = 3'b001;
localparam GT    = 3'b010;
localparam LT    = 3'b011;
localparam GTE   = 3'b100;
localparam LTE   = 3'b101;
localparam OVF   = 3'b110;
localparam UNCOND = 3'b111;

always @(cond, flag, take_branch_IN) begin
case(cond) // flag[2]=n, flag[1]=z, flag[0]=v, 
      NE: 
      begin //not equal z=0
        if (flag[1] == 1'b0) begin
          take_branch = 1'b1;
        end
        else begin
          take_branch = 1'b0;
        end
      end
      EQ: 
      begin //equal z=1
        if (flag[1] == 1'b1) begin
          take_branch = 1'b1;
        end
        else begin
          take_branch = 1'b0;
        end
      end
      GT: 
      begin // greater than n=z=0
        if (flag[2] == 1'b0 && flag[1] == 1'b0) begin
          take_branch = 1'b1;
        end
        else begin
          take_branch = 1'b0;
        end
      end
      LT: 
      begin // less than n=1
        if (flag[2] == 1'b1) begin
          take_branch = 1'b1;
        end
        else begin
          take_branch = 1'b0;
        end
      end
      GTE: 
      begin // greater than or equal n=z=0 or z=1  
        if ((flag[2] == 1'b0 && flag[1] == 1'b0) || flag[1] == 1'b1) begin
          take_branch = 1'b1;
        end
        else begin
          take_branch = 1'b0;
        end
      end
      LTE: 
      begin // less than or equal n=1 or z=1
        if (flag[2] == 1'b1 || flag[1] == 1'b1) begin
          take_branch = 1'b1;
        end
        else begin
          take_branch = 1'b0;
        end
      end
      OVF: 
      begin // overflow v=1
        if (flag[0] == 1'b1) begin
          take_branch = 1'b1;
        end
        else begin
          take_branch = 1'b0;
        end
      end
      UNCOND:
      begin //unconditional
        take_branch = 1'b1;
      end
      default: 
      begin
        take_branch = 1'b0;
      end
    endcase 
end

endmodule
