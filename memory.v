// 64k memory addresses
module memory(
	input clk,
	input rst,
	input mar_we,
	input ram_we,
	input[15:0] bus,

	output[7:0] out
);

	// setting memory
	initial begin
		$readmemh("program.bin", ram);
	end

	reg[15:0] mar;
	reg[7:0] ram[0:65535];

	always @ (posedge clk, posedge rst)
	begin
		if (rst)
		begin
			mar <= 16'b0;
		end else if (mar_we)
		begin
			mar <= bus;
		end
	end

	always @ (posedge clk)
	begin
		if (ram_we)
		begin
			ram[mar] <= bus[7:0];
		end
	end

	assign out = ram[mar];

endmodule
