/*
ALU has an 8-bit accumulator (ACC) for all operations
ACT and TMP are temporary registers. These 2 will be used for when we need multiple operands
ACT will contain ACC value if we don't want to overwrite ACC

4 status flags:
- Z: Zero (indicates whether the value in ACC resulted in a 0)
- C: Carry (indicates whether the previous operation resulted in a carry bit)
- P: Parity (indicates whether the value in ACC has an even parity. 1 is even, 0 is odd)
- S: Sign (indicates whether the value in ACC is negative)
*/
module alu(
	input clk,
	input rst,
	input cs, // control signal	
	input flags_we,
	input a_we,
	input a_store,
	input a_restore,
	input tmp_we,
	input[4:0] op,
	input[7:0] bus,

	output[7:0] flags,
	output[7:0] out
);

	wire flag_z;
	wire flag_c;
	wire flag_p;
	wire flag_s;
	
	reg carry;

	reg[7:0] acc;
	reg[7:0] act;
	reg[7:0] tmp;
	reg[7:0] flag;

	localparam FLAG_Z = 0;
	localparam FLAG_C = 1;
	localparam FLAG_P = 2;
	localparam FLAG_S = 3;

	localparam OP_ADD = 5'b00000; // add
	localparam OP_ADC = 5'b00001; // add carry
	localparam OP_SUB = 5'b00010; // sub
	localparam OP_SBB = 5'b00011; // sub borrow
	localparam OP_ANA = 5'b00100; // and
	localparam OP_XRA = 5'b00101; // xor
	localparam OP_ORA = 5'b00110; // or
	localparam OP_CMP = 5'b00111; // compare
	localparam OP_RLC = 5'b01000; // rotate left carry
	localparam OP_RRC = 5'b01001; // rotate right carry
	localparam OP_RAL = 5'b01010; // rotate left
	localparam OP_RAR = 5'b01011; // rotate right
	localparam OP_DAA = 5'b01100; // adjust result in bcd
	localparam OP_CMA = 5'b01101; // complement
	localparam OP_STC = 5'b01110; // set carry
	localparam OP_CMC = 5'b01111; // complement carry
	localparam OP_INR = 5'b10000; // increment
	localparam OP_DCR = 5'b10001; // decrement

	assign flag_z = (acc[7:0] == 8'b0);
	assign flag_c = (carry == 1'b1);
	assign flag_p = ~^acc[7:0];
	assign flag_s = acc[7];

	// flag assignment
	always @ (negedge clk, posedge rst)
	begin
		if (rst)
		begin
			flag <= 8'b0;
		end else if (flags_we)
		begin
			flag <= bus;
		end else
		begin
			if (cs)
			begin
				case (op)
					OP_ADD, OP_ADC, OP_SUB, OP_SBB, OP_ANA, OP_XRA, OP_ORA:
					begin
						flag[FLAG_Z] <= flag_z;
						flag[FLAG_C] <= flag_c;
						flag[FLAG_P] <= flag_p;
						flag[FLAG_S] <= flag_s;
					end
					
					OP_CMP:
					begin
						flag[FLAG_Z] <= (act == 8'b0);
					end

					OP_INR, OP_DCR:
					begin
						flag[FLAG_Z] <= flag_z;
						flag[FLAG_P] <= flag_p;
						flag[FLAG_S] <= flag_s;
					end

					OP_RLC, OP_RRC, OP_RAL, OP_RAR, OP_STC, OP_CMC:
					begin
						flag[FLAG_C] <= flag_c;
					end
				endcase
			end
		end
	end

    // operations logic
	always @ (posedge clk, posedge rst)
	begin
		if (rst)
		begin
			acc <= 8'b0;
			act <= 8'b0;
			tmp <= 8'b0;
			carry <= 1'b0;
		end else
		begin
			if (a_we)
			begin
				acc <= bus;
			end else if (a_restore)
			begin
				acc <= act;
			end else if (cs)
			begin
				case (op)
					OP_ADD:
					begin
						{carry, acc} <= acc + tmp;
					end

					OP_ADC:
                    begin
						{carry, acc} <= acc + tmp + flag[FLAG_C];
					end

					OP_SUB:
					begin
						{carry, acc} <= acc - tmp;
					end

					OP_SBB:
                    begin
						{carry, acc} <= acc - tmp - flag[FLAG_C];
					end

                    OP_ANA:
                    begin
                        {carry, acc} <= acc & tmp;
                    end

                    OP_XRA:
                    begin
                        {carry, acc} <= acc ^ tmp;
                    end

                    OP_ORA:
                    begin
                        {carry, acc} <= acc | tmp;
                    end

                    OP_CMP:
                    begin
                        act <= acc - tmp;
                    end

                    OP_RLC:
                    begin
                        carry <= acc[7];
                        acc <= acc << 1;
                    end

                    OP_RRC:
                    begin
                        carry <= acc[0];
                        acc <= acc >> 1;
                    end

                    OP_RAL:
                    begin
                        carry <= acc[7];
                        acc <= acc << 1 | {7'b0, flag[FLAG_C]};
                    end

                    OP_RAR:
                    begin
                        carry <= acc[0];
                        acc <= acc >> 1 | {flag[FLAG_C], 7'b0};
                    end

                    OP_CMA:
                    begin
                        acc <= ~acc;
                    end

                    OP_STC:
                    begin
                        carry <= 1'b1;
                    end

                    OP_CMC:
                    begin
                        carry <= ~flag[FLAG_C];
                    end

                    OP_INR:
                    begin
                        acc <= acc + 1;
                    end

                    OP_DCR:
                    begin
                        acc <= acc - 1;
                    end
				endcase
			end

            if (a_store)
            begin
                act <= acc;
            end

            if (tmp_we)
            begin
                tmp <= bus;
            end
		end
	end

    assign flags = flag;
    assign out = acc;

endmodule
