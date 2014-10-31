//******************************************************************************
// File: alu.v
// Author: Mike Feilbach, David Gardner
// ECE 552 UW-Madison Fall 2014
//
// Description: This is the ALU module for the single cycle processor design.
//
// Instruction Opcode  Flags Set  Further Description
// ----------- ------  ---------  ---------------------------------------------
// ADD         0000    N, Z, V    rd = rs + rt
// PADDSB      0001    none       rd = rs + rt (parallel add split bytes)
// SUB         0010    N, Z, V    rd = rs - rt
// AND         0011    Z          rd = rs AND rt (bitwise)
// NOR         0100    Z          rd = rs NOR rt (bitwise)
// SLL         0101    Z          rd = rs << shamt
// SRL         0110    Z          rd = rs >> shamt
// SRA         0111    Z          rd = rs >>> shamt
// LLB	       1010    none       rd[7:0] = immed, rd[15:8] sign-extention of immed
// LHB	       1011    none	  rd[15:8] = immed, rd[7:0] unchanged
//*****************************************************************************
module alu(opcode, rs, rt, shamt, immed, out, n, z, v);					// must implement and test flags for ALU. **** next step.

	input [3:0] opcode;
	input [15:0] rs, rt;
	input [3:0] shamt;
	input [7:0] immed;
	output [15:0] out;
	output n, z, v;

	wire [15:0] AL_output;	// Adder logic outout (ADD, PADDSB, SUB).
	wire [15:0] SL_output;	// Shifter logic output (SLL, SRL, SRA).
	wire [15:0] AND_output;	// AND output.
	wire [15:0] NOR_output;	// NOR output.
	wire [15:0] SHFITER_output;	// Output for SLL, SRL, SRA.
	wire [15:0] LD_output;	// Output for LLB, LHB.
	wire [15:0] unused;
	wire [15:0] mux0_output;

	// Assign flags.
	wire doNotSetFlags;
	assign doNotSetFlags = ((opcode == 4'b0001) || (opcode == 4'b1010) || (opcode == 4'b1011));

	wire addOrSub;
	assign addOrSub = ((opcode == 4'b0000) || (opcode == 4'b0010));

	wire addSubSaturationFlag;

	// if (PADDSB or LLB or LHB) set n to zero, else set it based on the result.
	// Note that if MSB of result is 1, it is negative.
	assign n = (~addOrSub) ? 1'b0 : out[15];

	// If ADD or SUB, use the saturation flag, else set it to zero. 
	assign v = (addOrSub) ? addSubSaturationFlag : 1'b0; 

	// if (PADDSB or LLB or LHB) set z to zero, else set it based on the result
	assign z = (doNotSetFlags) ? 1'b0 : 
			((out & 16'hFFFF) == 16'h0000) ? 1'b1 : 1'b0;


	// Picks between outputs for: AL, AND, NOR, SHIFTER units.
	mux8to1_16bit mux0(.Select(opcode[2:0]), .Out(mux0_output), .A(AL_output), .B(AL_output), .C(AL_output), .D(AND_output), .E(NOR_output), .F(SHFITER_output), .G(SHFITER_output), .H(SHFITER_output));

	// Picks between outputs for: mux0 and LLB/LHB.
	mux2to1_16bit outputMux(.Select(opcode[3]), .Out(out), .A(mux0_output), .B(LD_output));

	// Adder logic unit (does ADD, SUB, PADDSB).
	AL_unit AL(.rd(AL_output), .rs(rs), .rt(rt), .opcodeTwoLSB(opcode[1:0]), .saturationFlag(addSubSaturationFlag));

	// Does AND.
	and_16bit and_unit(.A(rs), .B(rt), .Out(AND_output));

	// Does NOR.
	nor_16bit nor_unit(.A(rs), .B(rt), .Out(NOR_output));

	// Does SLL, SRL, SRA.
	shifter_16bit shifter_unit(.in(rs), .mode(opcode[1:0]), .shamt(shamt), .out(SHFITER_output));

	// Does LLB, LHB. Assume for now that rs is the one that is used to be
	// written to (not rt).
	LD_unit LD(.Rx(rs), .immed(immed), .difference_bit(opcode[0]), .new_Rx(LD_output));

endmodule
/*
module alu_t();
	// For passing arguments to testing functions.
	// These values do not necessarily correspond to opcode
	// bits or anything, they are just enumerations.
	localparam ADD = 2'b00;
	localparam SUB = 2'b01;
	localparam PADDSB = 2'b10;
	localparam AND = 1'b0;
	localparam NOR = 2'b1;
	localparam SLL = 2'b00;
	localparam SRL = 2'b01;
	localparam SRA = 2'b10;
	localparam LHB = 1'b0;
	localparam LLB = 1'b1;

	reg [7:0] immed;
	reg [3:0] shamt;
	reg [15:0] ActualResult;	// Used for testing AND, NOR, SLL, SRL, SRA, LLB, LHB.
	reg [3:0] opcode;
	reg signed [15:0] rs, rt;	// So it interprets (prints out and does comparison as) as a two's complement.
	wire signed [15:0] out;		// So it interprets (prints out and does comparison as) as a two's complement.
	reg signed [16:0] ActualSum;					// Extra bit so we can do adds that will
									// cause overflow with 16-bit (this way we
									// can test saturation).
	reg signed [8:0] ActualHalfSum_LSB, ActualHalfSum_MSB;			// Extra bit so we can do adds that will
										// cause overflow with 8-bit (this way we
										// can test saturation).

	reg signed [7:0] rt_LSB_half, rt_MSB_half, rs_LSB_half, rs_MSB_half;	
	reg signed [7:0] out_LSB_half, out_MSB_half;	// These store the results of out as signed half values in order
							// for the test to interpret the half results as signed values
							// instead of an unsigned lower half and a signed upper half.

	reg signed [16:0] i, j;	// Extra bit so increment past 32767 does not break testing in loop.

	wire n, z, v;
	reg actualN, actualZ, actualV;

	// DUT.
	alu DUT(.opcode(opcode), .rs(rs), .rt(rt), .shamt(shamt), .immed(immed), .out(out), .n(n), .z(z), .v(v));

	// Tests for LLB, LHB.
	task test_number_load;
		input [15:0] i, j;
		input OPERATION;

		begin
			#5;
			rs = i;
			immed = j;
			#5; // Wait a BIT.

			if (OPERATION == LLB) begin
				// This code is for testing LLB only.

				// Get what the result should be and test against our output.
				ActualResult = {immed[7], immed[7], immed[7], immed[7], immed[7], immed[7], immed[7], immed[7], immed};
				if ((out !== ActualResult) || (n !== 1'b0) || ( z !== 1'b0) || ( v !== 1'b0)) begin
					$display("Tesbench Failed (LLB): Rx :%b    immed:%b    new_Rx:%b Actual:%b n:%b z:%b v:%b", rs, immed, $signed(out), ActualResult, n, z, v);
					$finish;
				end

				// Display each result.
				//$display("LLB: Rx :%b    immed:%b    new_Rx:%b Actual:%b, n:%b z:%b v:%b", rs, immed, $signed(out), ActualResult, n, z, v);

			end else begin
				// This code is for testing LHB only.

				// Get what the result should be and test against our output.
				ActualResult = {immed, rs[7:0]};
				if ((out !== ActualResult) || (n !== 1'b0) || ( z !== 1'b0) || ( v !== 1'b0)) begin
					$display("Tesbench Failed (LLB): Rx :%b    immed:%b    new_Rx:%b Actual:%b n:%b z:%b v:%b", rs, immed, $signed(out), ActualResult, ActualResult, n, z, v);
					$finish;
				end

				// Display each result.
				//$display("LLB: Rx :%b    immed:%b    new_Rx:%b Actual:%b n:%b z:%b v:%b", rs, immed, $signed(out), ActualResult, n, z, v);
			end
		end // End task body.
	endtask // End task.

	// Tests for ADD, SUB, and PADDSB.
	task test_number_adder;
		input [15:0] i, j;
		input [1:0] OPERATION;

		begin
			#5;
			rt = i;
			rs = j;
			#5; // Wait a BIT.

			if (OPERATION == PADDSB) begin
				// This code is for testing PADDSB only.
				rt_LSB_half = rt[7:0];
				rt_MSB_half = rt[15:8];
				rs_LSB_half = rs[7:0];
				rs_MSB_half = rs[15:8];

				// Get the proper results.
				ActualHalfSum_LSB = (rt_LSB_half + rs_LSB_half);
				ActualHalfSum_MSB = (rt_MSB_half + rs_MSB_half);

				// Store the out result as a proper data form. Store the LSB half
				// and the MSB half as signed numbers so it is interpreted correctly
				// in the test bench.
				out_LSB_half = out[7:0];
				out_MSB_half = out[15:8];

				// Check for overflow and underflow of both "half" results.
				if (ActualHalfSum_LSB > 127) begin
					ActualHalfSum_LSB = 127;
				end else if (ActualHalfSum_LSB < -128) begin
					ActualHalfSum_LSB = -128;
				end

				if (ActualHalfSum_MSB > 127) begin
					ActualHalfSum_MSB = 127;
				end else if (ActualHalfSum_MSB < -128) begin
					ActualHalfSum_MSB = -128;
				end

				if ((out_LSB_half !== ActualHalfSum_LSB) || (n !== 1'b0) || ( z !== 1'b0) || ( v !== 1'b0)) begin
					$display("Tesbench Failed PADDSB (LSB half): rs (LSB half):%d    rt (LSB half):%d    out (LSB half):%d Actual (LSB half):%d n:%b z:%b v:%b", rs_LSB_half, rt_LSB_half, out_LSB_half, ActualHalfSum_LSB, n, z, v);
					//$display("inputs to Adder Logic Unit: %d %d", $signed(DUT.AL.rs[7:0]), $signed(DUT.AL.rt[7:0]));		
					//$display("adder8_0 inputs:%d, %d", $signed(DUT.AL.adder0.A), $signed(DUT.AL.adder0.B));
					//$display("adder8_0 sum: %d", $signed(DUT.AL.adder0.Sum));
					//$display("AL output LSB half: %d", $signed(DUT.AL.rd[7:0]));
					//$display("ALU output LSB half: %d", $signed(DUT.out[7:0]));
					//$display("%d", DUT.AL.rd);
					//$display("%d", DUT.AL_output);
					$finish;
				end

				// Display each result for LSB half.
				//$display("rs (LSB half):%d    rt (LSB half):%d    out (LSB half):%d Actual (LSB half):%d n:%b z:%b v:%b", rs_LSB_half, rt_LSB_half, out_LSB_half, ActualHalfSum_LSB, n, z, v);

				if ((out_MSB_half !== ActualHalfSum_MSB) || (n !== 1'b0) || ( z !== 1'b0) || ( v !== 1'b0)) begin
					$display("Tesbench Failed PADDSB (MSB half): rs (MSB half):%d    rt (MSB half):%d    out (MSB half):%d Actual (MSB half):%d n:%b z:%b v:%b", rs_MSB_half, rt_MSB_half, out_MSB_half, ActualHalfSum_MSB, n, z, v);
					$finish;
				end
				
				// Display each result for MSB half.
				//$display("rs (MSB half):%d    rt (MSB half):%d    out (MSB half):%d Actual (MSB half):%d n:%b z:%b v:%b", rs_MSB_half, rt_MSB_half, out_MSB_half, ActualHalfSum_MSB, n, z, v);				

			end else begin
				// This code is for testing ADD and SUB only.
				// Get the "proper result."
				if (OPERATION == ADD) begin
					ActualSum = (rt + rs);
				end else if (OPERATION == SUB) begin
					ActualSum = (rs - rt);
				end
	
				// Modify the actual sum to agree with our underflow and overflow saturation conventions.
				if (ActualSum >= 32768) begin
					ActualSum = 32767;
					actualV = 1'b1;
				end else if (ActualSum < -32768) begin
					ActualSum = -32768;
					actualV = 1'b1;
				end else begin
					actualV = 1'b0;
				end

				// Set the negative or zero flags.
				if (ActualSum === 16'h0000) begin
					actualZ = 1'b1;
				end else begin
					actualZ = 1'b0;
				end
				
				if (ActualSum < 0) begin
					actualN = 1'b1;
				end else begin
					actualN = 1'b0;
				end

				if ((out !== ActualSum) || (v !== actualV) || (n !== actualN) || (z !== actualZ)) begin
					$display("Tesbench Failed ADD or SUB: rs:%d    rt:%d    out:%d Actual:%d n:%b z:%b v:%b", rs, rt, out, ActualSum, n, z, v);
					$display("adder8_0 inputs: %b, %b", DUT.AL.adder0.A, DUT.AL.adder0.B);
					$display("adder8_1 inputs: %b, %b", DUT.AL.adder1.A, DUT.AL.adder1.B);
					$display("%d", DUT.AL.rd);
					$display("%d", DUT.AL_output);
					$display("actualN: %b", actualN);
					$display("actualZ: %b", actualZ);
					$display("actualV: %b", actualV);
					$finish;
				end

				// Display each result for ADD and SUB.
				//$display("rs:%d    rt:%d    out:%d, n:%b z:%b v:%b", rs, rt, out, n, z, v);
			end
		end // End task body.
	endtask // End task.


	// Tests for AND, NOR.
	task test_number_logic;
		input [15:0] i, j;
		input [1:0] OPERATION;

		begin
			#5;
			rt = i;
			rs = j;
			#5; // Wait a BIT.

			// Get the proper result.
			if (OPERATION == AND) begin
				ActualResult = (rt & rs);
			end else if (OPERATION == NOR) begin
				ActualResult = ~(rt | rs);
			end

			if (ActualResult === 16'h0000) begin
				actualZ = 1'b1;
			end else begin
				actualZ = 1'b0;
			end

			if ((out !== ActualResult) || (v !== 1'b0) || (n !== 1'b0) || (z !== actualZ)) begin
				if (OPERATION == ADD) begin
					$display("AND Tesbench Failed: rs&:%b    rt:%b    out:%b Actual:%b n:%b z:%b v:%b", rs, rt, out, ActualResult, n, z, v);
				end else if (OPERATION == NOR) begin
					$display("NOR Tesbench Failed: rs&:%b    rt:%b    out:%b Actual:%b n:%b z:%b v:%b", rs, rt, out, ActualResult, n, z, v);
				end
				$finish;
			end
			
			// Display each result.
			//$display("rs:%b    rt:%b    out:%b Actual:%b n:%b z:%b v:%b", rs, rt, out, ActualResult, n, z, v);

		end // End task body.
	endtask // End task.

	// Tests SLL, SRA, SRL
	task test_shifter_exhuastive;
		input [1:0] OPERATION;
		begin
			// Do not test NOP here, we will not be using it.

			// Test NOP.
			// mode = 2'b00;
			// for (i = 0; i < 65536; i = i + 1) begin
			//	for (j = 0; j < 16; j = j + 1) begin
			//		in = i;
			//		shamt = j;
			//		result = in;
			//		
			//		#5;
			//		
			//		if ((out != result) || (overflow != actualOverflow)) begin
			//			$display("NOP FAILED: in:%b    out:%b    shamt:%b    overflow:%b", in, out, shamt, overflow);
			//			$display("CORRECT:    in:%b    out:%b    shamt:%b    overflow:%b", in, result, shamt, overflow);
			//			$finish;
			//		end
			//			
			//		//$display("in:%b    out%b    shamt:%b", in, out, shamt);
			//	end
			// end
			// $display("NOP TEST BENCH PASSED (:");
	
			if (OPERATION == SLL) begin
				// Test Left Shift Logical (mode 2'b10 on shifter).
				for (i = 0; i < 65; i = i + 1) begin
					for (j = 0; j < 16; j = j + 1) begin
						shamt = j;
						rs = i;
						ActualResult = (i << shamt);
						#5;

						if (ActualResult === 16'h0000) begin
							actualZ = 1'b1;
						end else begin
							actualZ = 1'b0;
						end

					
						if ((out != ActualResult) || (v !== 1'b0) || (n !== 1'b0) || (z !== actualZ)) begin
							$display("LEFT SHIFT FAILED: rs:%b    out:%b    shamt:%b n:%b z:%b v:%b", rs, out, shamt, n, z, v);
							$display("CORRECT:           rs:%b    out:%b    shamt:%b", rs, ActualResult, shamt);
							$display("mode of shifter: %b", DUT.shifter_unit.actualMode);
							$display("output of shifter direct: %b", DUT.shifter_unit.out);
							$display("shamt of shifter direct: %b", DUT.shifter_unit.shamt);
							$finish;
						end
	
						// Display each result.
						//$display("rs:%b    out:%b    shamt:%b n:%b z:%b v:%b", rs, out, shamt, n, z, v);
					end
				end
			end else if (OPERATION == SRL) begin	
				// Test Shift Right Logical (mode 2'b01 on shifter).
				for (i = 0; i < 65; i = i + 1) begin
					for (j = 0; j < 16; j = j + 1) begin
						shamt = j;
						rs = i;
						ActualResult = (i >> shamt);
						#5;

						if (ActualResult === 16'h0000) begin
							actualZ = 1'b1;
						end else begin
							actualZ = 1'b0;
						end
					
						if ((out != ActualResult) || (v !== 1'b0) || (n !== 1'b0) || (z !== actualZ)) begin
							$display("RIGHT SHIFT LOGICAL FAILED: rs:%b    out:%b    shamt:%b n:%b z:%b v:%b", rs, out, shamt, n, z, v);
							$display("CORRECT:                    rs:%b    out:%b    shamt:%b", rs, ActualResult, shamt);
							$finish;
						end
		
						// Display each result.
						//$display("rs:%b    out:%b    shamt:%b n:%b z:%b v:%b", rs, out, shamt, n, z, v);
					end
				end
			end else if (OPERATION == SRA) begin
				// Test Shift Right Arithmetic (mode 2'b11 on shifter).
				for (i = 0; i < 65; i = i + 1) begin
					for (j = 0; j < 16; j = j + 1) begin
						shamt = j;
						rs = i;
						ActualResult = (i >>> shamt);
						#5;

						if (ActualResult === 16'h0000) begin
							actualZ = 1'b1;
						end else begin
							actualZ = 1'b0;
						end
					
						if ((out != ActualResult) || (v !== 1'b0) || (n !== 1'b0) || (z !== actualZ)) begin
							$display("RIGHT SHIFT ARITHMETIC FAILED: rs:%b    out:%b    shamt:%b n:%b z:%b v:%b", rs, out, shamt, n, z, v);
							$display("CORRECT:                       rs:%b    out:%b    shamt:%b", rs, ActualResult, shamt);
							$finish;
						end
		
						// Display each result.
						//$display("rs:%b    out:%b    shamt:%b n:%b z:%b v:%b", rs, out, shamt, n, z, v);
					end
				end
			end
		end // End task body.
	endtask // End task.

	initial begin
		
		//*************************************************************
		// Test ADD (0000).
		//*************************************************************
		opcode = 4'b0000;
		#5;

		// Test numbers that will not hit any sort of saturation (overflow).
		for (i = 1000; i < 1200; i = i + 1) begin
			for (j = 1000; j < 1200; j = j + 1) begin
				test_number_adder(i, j, ADD);
			end
		end

		// Test numbers that will hit negative saturation.
		for (i = -32768; i < -32600; i = i + 1) begin
			for (j = 0 -32768; j < -32600; j = j + 1) begin
				test_number_adder(i, j, ADD);
			end
		end

		// Test numbers that will hit positive saturation.
		for (i = 32600; i < 32768; i = i + 1) begin
			for (j = 32600; j < 32768; j = j + 1) begin
				test_number_adder(i, j, ADD);
			end
		end

		// Test random numbers.
		for (i = 0; i < 50000; i = i + 1) begin
			test_number_adder(($random % 32768), ($random % 32768), ADD);
		end

		$display("\nADD (0000) TESTBENCH PASSED! (:\n\n");
		
		//*************************************************************
		// Test SUB (0010).
		//*************************************************************
		opcode = 4'b0010;
		#5;

		// Test numbers that will not hit any sort of saturation (overflow).
		for (i = 1000; i < 1200; i = i + 1) begin
			for (j = 1000; j < 1200; j = j + 1) begin
				test_number_adder(i, j, SUB);
			end
		end

		// Test numbers that will hit negative saturation.
		for (i = -32768; i < -32600; i = i + 1) begin
			for (j = 0 -32768; j < -32600; j = j + 1) begin
				test_number_adder(i, j, SUB);
			end
		end

		// Test numbers that will hit positive saturation.
		for (i = 32600; i < 32768; i = i + 1) begin
			for (j = 32600; j < 32768; j = j + 1) begin
				test_number_adder(i, j, SUB);
			end
		end

		// Test random numbers.
		for (i = 0; i < 50000; i = i + 1) begin
			test_number_adder(($random % 32768), ($random % 32768), SUB);
		end

		$display("\nSUB (0010) TESTBENCH PASSED! (:\n\n");

		//*************************************************************
		// Test PADDSB (0001).
		//*************************************************************
		opcode = 4'b0001;
		#5;

		// Test random numbers.
		for (i = 0; i < 50000; i = i + 1) begin
			test_number_adder(($random % 32768), ($random % 32768), PADDSB);
		end

		$display("\nPADDSB (0001) TESTBENCH PASSED! (:\n\n");

		//*************************************************************
		// Test AND (0001).
		//*************************************************************
		opcode = 4'b0011;
		#5;

		// Test random numbers.
		for (i = 0; i < 50000; i = i + 1) begin
			test_number_logic(($random % 32768), ($random % 32768), AND);
		end

		$display("\nAND (0011) TESTBENCH PASSED! (:\n\n");
		//*************************************************************
		// Test NOR (0001).
		//*************************************************************
		opcode = 4'b0100;
		#5;

		// Test random numbers.
		for (i = 0; i < 50000; i = i + 1) begin
			test_number_logic(($random % 32768), ($random % 32768), NOR);
		end

		$display("\nNOR (0100) TESTBENCH PASSED! (:\n\n");

		//*************************************************************
		// Test SLL (0101).
		//*************************************************************
		opcode = 4'b0101;
		#5;

		test_shifter_exhuastive(SLL);
		
		$display("\nSLL (0101) TESTBENCH PASSED! (:\n\n");

		//*************************************************************
		// Test SRL (0110).
		//*************************************************************
		opcode = 4'b0110;
		#5;

		test_shifter_exhuastive(SRL);

		$display("\nSRL (0110) TESTBENCH PASSED! (:\n\n");

		//*************************************************************
		// Test SRA (0111).
		//*************************************************************
		opcode = 4'b0111;
		#5;

		test_shifter_exhuastive(SRA);

		$display("\nSRA (0111) TESTBENCH PASSED! (:\n\n");

		//*************************************************************
		// Test LLB (1011).
		//*************************************************************
		opcode = 4'b1011;
		#5;

		// Test random numbers.
		for (i = 0; i < 50000; i = i + 1) begin
			test_number_load(($random % 32768), ($random % 255), LLB);
		end

		$display("\nLLB (1011) TESTBENCH PASSED! (:\n\n");

		//*************************************************************
		// Test LHB (1010).
		//*************************************************************
		opcode = 4'b1010;
		#5;

		// Test random numbers.
		for (i = 0; i < 50000; i = i + 1) begin
			test_number_load(($random % 32768), ($random % 255), LHB);
		end

		$display("\nLHB (1010) TESTBENCH PASSED! (:\n\n");		

		$finish;
	end
endmodule
*/
//*****************************************************************************
// The Adder logic unit.
// This is where the following happens:
// 1) ADD (0000)
// 2) SUB (0010)
// 3) PADDSB (0001)
//
// If the operation is ADD or SUB, it will output an overflow signal. If the
// operation is PADDSB, the overflow signal will be set to 0.
//*****************************************************************************
module AL_unit(rd, rs, rt, opcodeTwoLSB, saturationFlag);
	input [15:0] rs, rt;
	input [1:0] opcodeTwoLSB;	// The two LSB bits of the opcode
					// distinguist between ADD, SUB,
					// and PADDSB.
	output [15:0] rd;
	output saturationFlag;

	// If SUB, we want to bitwise invert rt. If Cin is 1 to
	// the adder, then this will perform subtraction for us.
	wire [15:0] actual_rt;
	assign actual_rt = (opcodeTwoLSB[1] == 1'b1) ? ~rt : rt;

	// The outputs of ADD, SUB, PADDSB.
	wire [15:0] ADD_result, SUB_result, PADDSB_result;

	// Assign the output based on which operation we did.
	assign rd = (opcodeTwoLSB == 2'b00) ? ADD_result :
			(opcodeTwoLSB == 2'b10) ? SUB_result:
				PADDSB_result;

	// Wires for the two 8-bit adders.
	wire Cin0, Cin1, Cout0, Cout1;

	// Store the rd value from the adder to see if we need to do 
	// saturation, before giving it to the output of the module.
	wire [15:0] temp_rd;

	// Saturation logic for ADD and SUB (PADDSB takes care of saturation before this point,
	// so just pass the PADDSB result through if we are doing PADDSB).
	// if (PADDSB)
	//   pass through temp_rd (saturation done already for this instruction).
	// else if (result MSB == 1 & rs MSB == 0 & rt MSB == 0)
	//   rd is the positive saturation value.
	// else if (result MSB == 0 & rs MSB == 1 & rt MSB == 1)
	//   rd is the negative saturation value.
	// else
	//   no saturation occured, pass through the rd value from the adder.

	assign rd = (opcodeTwoLSB[0]) ? temp_rd :						// PADDSB.
			(temp_rd[15] & ~rs[15] & ~actual_rt[15]) ? 16'b0111111111111111 :	// non-PADDSB, positive saturation
			(~temp_rd[15] & rs[15] & actual_rt[15]) ? 16'b1000000000000000 :	// non-PADDSB, negative saturation
			temp_rd;								// non-PADDSB, no saturation

	assign saturationFlag = (opcodeTwoLSB[0]) ? 1'b0 :					// PADDSB (no saturation).
			(temp_rd[15] & ~rs[15] & ~actual_rt[15]) ? 1'b1 :			// non-PADDSB, positive saturation
			(~temp_rd[15] & rs[15] & actual_rt[15]) ? 1'b1 :			// non-PADDSB, negative saturation
			1'b0;									// non-PADDSB, no saturation

	// Adds the least significant 8 bits.
	adder_8bit adder0(.A(rs[7:0]), .B(actual_rt[7:0]), .Cin(Cin0), .Sum(temp_rd[7:0]), .Cout(Cout0), .PADDSB_bit(opcodeTwoLSB[0]));
	
	// Adds the most significant 8 bits.
	adder_8bit adder1(.A(rs[15:8]), .B(actual_rt[15:8]), .Cin(Cin1), .Sum(temp_rd[15:8]), .Cout(Cout1), .PADDSB_bit(opcodeTwoLSB[0]));
	
	// If SUB, then Cin to the first 8-bit adder is 1. For ADD, PADDSB, it should be 0.
	assign Cin0 = (opcodeTwoLSB[1] == 1'b1) ? 1'b1 :1'b0;
	
	// If ADD or SUB, Cin to second 8-bit adder is Cout of first 8-bit adder. For PADDSB,
	// it should be 0.
	assign Cin1 = (opcodeTwoLSB[0] == 1'b1) ? 1'b0 : Cout0;
endmodule

//*****************************************************************************
// A two's complement 8-bit adder with a carry in and a carry out bit.
// If the operation is PADDSB, positive overflow is  saturated to (2^7 - 1),
// negative overflow is saturated to (-(2^7)).
//*****************************************************************************
module adder_8bit(A, B, Cin, Sum, Cout, PADDSB_bit);

	input [7:0] A, B;
	output [7:0] Sum;
	input Cin, PADDSB_bit;
	output Cout;

	wire [8:0] actualSum;

	assign actualSum = (A + B + Cin);

	// Saturation logic for PADDSB done here.
	// If (we are not doing PADDSB):
	//  	do not do any saturation modifications to the sum
	// Else (if we are doing PADDSB and there was overflow):
	//	saturate the result
	// Else:
	//	do not do any saturation modifications to the sum
	//
	assign {Cout, Sum} = (PADDSB_bit == 1'b0) ? actualSum :	
				(actualSum[7] & ~A[7]  & ~B[7]) ? {1'b0, 8'b01111111} :		// Give Cout = 0, arbitrary.
				(~actualSum[7] & A[7] & B[7]) ? {1'b0, 8'b10000000} :		// Give Cout = 0, arbitrary.
					actualSum;
endmodule

//*****************************************************************************
// The load unit. Takes care of LLB and LHB instructions.
// The difference_bit is the LSB of the opcode, this distinguishes between
// LLB and LHB (see comments within the module).
//
// LLB (1010): rd[7:0] = immed, rd[15:8] sign-extention of immed
// LHB (1011): rd[15:8] = immed, rd[7:0] unchanged
//*****************************************************************************
module LD_unit(Rx, immed, difference_bit, new_Rx);
	input [7:0] immed;

	// LLB's opcode: 1011
	// LHB's opcode: 1010
	// The difference bit is the LSB of these opcodes.
	input difference_bit;
	input [15:0] Rx;
	output [15:0] new_Rx;

	// if (LLB)
	//   sign extend the MSB and fill the low bits.
	// else
	//   this is LHB, fill high bits, leave low bits unchanged. 
	assign new_Rx = (difference_bit == 1'b1) ? {immed[7], immed[7], immed[7], immed[7], immed[7], immed[7], immed[7], immed[7], immed} :
		{immed, Rx[7:0]};
endmodule

//*****************************************************************************
// 16-bit shifter.
//	mode 00: NOP
//	mode 01: Right Shift Logical
//	mode 10: Left Shift Logical
//	mode 11: Right Shift Arithmetic
//
// Overflow has been coded, but has been removed, it is not necessary per the
// project spec.
//*****************************************************************************
// Our version does not give overflow signal (it is not specified in the project document).
// module shifter_16bit(input [15:0] in, input [1:0] mode, input [3:0] shamt, output [15:0] out, output overflow);
module shifter_16bit(in, mode, shamt, out);
	input [15:0] in;
	input [1:0] mode;
	input [3:0] shamt;
	output [15:0] out;
	// output overflow;

	wire [1:0] s0, s1, s2, s3;
	wire [15:0] Ma, Mb, Mc, Md;

	// The field opcode[1:0] will match with our proper modes if we
	// simply swap the bits.
	wire [1:0] actualMode;
	assign actualMode = {mode[0], mode[1]};
	
	// Overflow flag.
	// assign overflow = (mode[1] & ~mode[0]) ? (in[15] ^ out[15]) : 0;

	assign s0 = {actualMode[1] & shamt[0], actualMode[0] & shamt[0]};
	assign s1 = {actualMode[1] & shamt[1], actualMode[0] & shamt[1]};
	assign s2 = {actualMode[1] & shamt[2], actualMode[0] & shamt[2]};
	assign s3 = {actualMode[1] & shamt[3], actualMode[0] & shamt[3]};

	assign Ma = (s0==2'b00) ? in :
				(s0==2'b01) ? {1'b0, in[15:1]} :
				(s0==2'b10) ? {in[14:0], 1'b0} :
				(s0==2'b11) ? {in[15], in[15:1]} :
							 16'h0000;
	assign Mb = (s1==2'b00) ? Ma :
				(s1==2'b01) ? {2'b00, Ma[15:2]} :
				(s1==2'b10) ? {Ma[13:0], 2'b00} :
				(s1==2'b11) ? {{2{Ma[15]}}, Ma[15:2]} :
							 16'h0000;
	assign Mc = (s2==2'b00) ? Mb :
				(s2==2'b01) ? {4'b0000, Mb[15:4]} :
				(s2==2'b10) ? {Mb[11:0], 4'b0000} :
				(s2==2'b11) ? {{4{Mb[15]}}, Mb[15:4]} :
							 16'h0000;
	assign Md = (s3==2'b00) ? Mc :
				(s3==2'b01) ? {8'h00, Mc[15:8]} :
				(s3==2'b10) ? {Mc[7:0], 8'h00} :
				(s3==2'b11) ? {{8{Mc[15]}}, Mc[15:8]} :
							 16'h0000;
	assign out = Md;
endmodule

//*****************************************************************************
// This mux has 8 16-bit inputs. The input is selected by a select vector
// of 3 bits.
//*****************************************************************************
module mux8to1_16bit(A, B, C, D, E, F, G, H, Out, Select);

	input [15:0] A, B, C, D, E, F, G, H;
	input [2:0] Select;
	output [15:0] Out;

	assign Out = (Select == 3'b000) ? A :
			(Select == 3'b001) ? B:
			(Select == 3'b010)? C:
			(Select == 3'b011) ? D:
			(Select == 3'b100) ? E:
			(Select == 3'b101) ? F:
			(Select == 3'b110) ? G:
				H;
endmodule

//*****************************************************************************
// This mux has 2 16-bit inputs. The input is selected by a select vector
// of 1 bit.
//*****************************************************************************
module mux2to1_16bit(A, B, Out, Select);

	input [15:0] A, B;
	input Select;
	output [15:0] Out;

	assign Out = (Select == 1'b0) ? A : B;
endmodule

//*****************************************************************************
// 16-bit bitwise AND.
//*****************************************************************************
module and_16bit(A, B, Out);

	input [15:0] A, B;
	output [15:0] Out;

	assign Out = (A & B);
endmodule

//*****************************************************************************
// 16-bit bitwise NOR.
//*****************************************************************************
module nor_16bit(A, B, Out);

	input [15:0] A, B;
	output [15:0] Out;

	assign Out = ~(A | B);
endmodule


