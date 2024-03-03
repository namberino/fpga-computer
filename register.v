// for implementing the 3 registers
module register(
	input clk,
	input rst,
	input inc, // for INR instruction
	input dec, // for DCR instruction
	input load,
	input[15:0] bus,

	output[7:0] out
);

	reg[7:0] data;

	always @ (posedge clk, posedge rst)
	begin
		if (rst)
		begin
			data <= 8'b0;
		end else if (load)
		begin
			data <= bus[7:0];
		end else if (dec)
		begin
			data <= data - 1;
		end else if (inc)
		begin
			data <= data + 1;
		end
	end

	assign out = data;

endmodule
