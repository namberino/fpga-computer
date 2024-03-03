/*
12 8-bit registers
6 of them will be available to programmers (B, C, D, E, H, L)
The registers can be paired together to make 16-bit registers (BC, DE, HL)
W and Z registers are inaccessible, they are temporary storage registers for some instructions
P and C registers together make the PC register (program counter)
S and P registers together make the SP register (stack pointer)
5th bit of the wr_sel and rd_sel determines whether the registers should be treated as 16-bit extended or not
*/
module reg_file(
	input clk,
	input rst,
	input we, // write enable
	input[4:0] rd_sel,
	input[4:0] wr_sel,
	input[1:0] ext, // extended operations
	input[15:0] data_in,

	output[15:0] out
);

	reg[7:0] data[0:11]; // 12 registers

	reg[15:0] out;
	wire[3:0] wr_dst = wr_sel[3:0];
	wire[3:0] rd_dst = rd_sel[3:0];
	wire wr_ext = wr_sel[4];
	wire rd_ext = rd_sel[4];

	localparam EXT_INC = 2'b01;
	localparam EXT_DEC = 2'b10;
	localparam EXT_INC2 = 2'b11;

	always @ (posedge clk, posedge rst)
	begin
		if (rst)
		begin
			data[0] <= 8'b0;
			data[1] <= 8'b0;
			data[2] <= 8'b0;
			data[3] <= 8'b0;
			data[4] <= 8'b0;
			data[5] <= 8'b0;
			data[6] <= 8'b0;
			data[7] <= 8'b0;
			data[8] <= 8'b0;
			data[9] <= 8'b0;
			data[10] <= 8'b0;
			data[11] <= 8'b0;
		end else
		begin
			if (ext == EXT_INC)
			begin
				{data[wr_dst], data[wr_dst + 1]} <= {data[wr_dst], data[wr_dst + 1]} + 1;
			end else if (ext == EXT_INC2)
			begin
				{data[wr_dst], data[wr_dst + 1]} <= {data[wr_dst], data[wr_dst + 1]} + 2;
			end else if (ext == EXT_DEC)
			begin
				{data[wr_dst], data[wr_dst + 1]} <= {data[wr_dst], data[wr_dst + 1]} - 1;
			end else if (we)
			begin
				if (wr_ext)
				begin
					{data[wr_dst], data[wr_dst + 1]} <= data_in;
				end else
				begin
					data[wr_dst] <= data_in[7:0];
				end
			end
		end
	end

	always @ (*)
	begin
		if (rd_ext)
		begin
			data_out = {data[rd_dst], data[rd_dst + 1]};
		end else
		begin
			data_out = {8'b0, data[rd_dst]};
		end
	end

endmodule
