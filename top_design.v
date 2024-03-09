module top_design(
	input CLK
);

    reg[7:0] out;
    always @(posedge clk, posedge rst)
    begin
        if (rst)
        begin
            out = 8'b0;
        end else if (display)
        begin
            out = alu_out;
        end
    end

    // bus
    reg[15:0] bus;
    always @ (*)
    begin
        bus = 16'b0;

        if (reg_oe)
        begin
            bus = reg_out;
        end else if (mem_oe)
        begin
            bus = {8'b0, mem_out};
        end else if (alu_oe)
        begin
            bus = {8'b0, alu_out};
        end else if (alu_flags_oe)
        begin
            bus = {8'b0, alu_flags};
        end
    end


    reg[23:0] slow_clk;
    always @ (posedge CLK)
    begin
        slow_clk <= slow_clk + 1;
    end

    // generate clock signal
    wire rst;
    wire hlt;
    wire clk;
    clock clock (
        .hlt(hlt),
        .clk_in(slow_clk[14]),
        .clk_out(clk)
    );


    // memory
    wire mem_mar_we;
    wire mem_ram_we;
    wire mem_oe;
    wire[7:0] mem_out;
    memory memory (
        .clk(clk),
        .rst(rst),
        .mar_we(mem_mar_we),
        .ram_we(mem_ram_we),
        .bus(bus),
        .out(mem_out)
    );


    // Register file
    wire reg_oe;
    wire reg_we;
    wire[4:0] reg_rd_sel;
    wire[4:0] reg_wr_sel;
    wire[1:0] reg_ext;
    wire[15:0] reg_out;
    reg_file reg_file (
        .clk(clk),
        .rst(rst),
        .rd_sel(reg_rd_sel),
        .wr_sel(reg_wr_sel),
        .ext(reg_ext),
        .we(reg_we),
        .data_in(bus),
        .out(reg_out)
    );


    // alu
    wire alu_cs;
    wire alu_flags_we;
    wire alu_a_we;
    wire alu_a_store;
    wire alu_a_restore;
    wire alu_tmp_we;
    wire alu_oe;
    wire alu_flags_oe;
    wire[4:0] alu_op;
    wire[7:0] alu_flags;
    wire[7:0] alu_out;
    alu alu (
        .clk(clk),
        .rst(rst),
        .cs(alu_cs),
        .flags_we(alu_flags_we),
        .a_we(alu_a_we),
        .a_store(alu_a_store),
        .a_restore(alu_a_restore),
        .tmp_we(alu_tmp_we),
        .op(alu_op),
        .bus(bus[7:0]),
        .flags(alu_flags),
        .out(alu_out)
    );


    // instruction register
    wire ir_we;
    wire[7:0] ir_out;
    ir ir (
        .clk(clk),
        .rst(rst),
        .we(ir_we),
        .bus(bus[7:0]),
        .out(ir_out)
    );


    // controller
    wire display;
    controller controller (
        .clk(clk),
        .rst(rst),
        .opcode(ir_out),
        .flags(alu_flags),
        .out({
            display,
            hlt,
            alu_cs,
            alu_flags_we,
            alu_a_we,
            alu_a_store,
            alu_a_restore,
            alu_tmp_we,
            alu_op,
            alu_oe,
            alu_flags_oe,
            reg_rd_sel,
            reg_wr_sel,
            reg_ext,
            reg_oe,
            reg_we,
            mem_ram_we,
            mem_mar_we,
            mem_oe,
            ir_we
        })
    );


endmodule
