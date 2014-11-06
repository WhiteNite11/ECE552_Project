module IM(clk,addr,rd_en,instr);

input clk;
input [15:0] addr;
input rd_en;			// asserted when instruction read desired

output reg [15:0] instr;	//output of insturction memory

reg [15:0]instr_mem[0:65535];

/////////////////////////////////////
// Memory is latched on clock low //
///////////////////////////////////
always @(addr,rd_en,clk)
  if (~clk & rd_en)
    instr <= instr_mem[addr];

initial begin
  //$readmemh("instr.hex",instr_mem);
  //$readmemh("instr2.hex",instr_mem);
  //$readmemh("instr3.hex",instr_mem);
  //$readmemh("instr4.hex",instr_mem);
  //$readmemh("alu_sweep.hex",instr_mem);
  //$readmemh("jumping_test.hex",instr_mem);
  //$readmemh("data_hzrd_test.hex",instr_mem);
  //$readmemh("ls_hzrd.hex",instr_mem);
  //$readmemh("lw_hzrd.hex",instr_mem);
  //$readmemh("jump_hzrd.hex",instr_mem);
  //$readmemh("data_hazard_lw.hex",instr_mem);
  $readmemh("t2.hex",instr_mem);
end

endmodule
