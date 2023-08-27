`include "cpu.svh"

module cpu
    (
        input logic clk_100M, clk_en, rst,
        input logic [31:0] r_data,
        output logic wr_en,
        output logic [31:0] mem_addr, w_data,
        // debug addr/data and instr are for showing CPU information
        // on the FPGA (only useful in synthesis)
        input logic [4:0] rdbg_addr,
        output logic [31:0] rdbg_data,
        output logic [31:0] instr
    );

    logic IorD, AluSrcA, IRWrite, JumpReg, PCWrite, Branch, BranchNotEqual, RegWrite, shift;
    logic [2:0] ALUOp, PCSrc, RegDst, MemtoReg;
    logic [2:0] ALUSrcB;
    logic [3:0] AluControl;
    

    // Internal for the program counter non-architectural register
    logic [31:0] PC, PCprime; 
    logic PCEn;
    reg_en #(.INIT(32'h00400000)) program_counter (.clk(clk_100M), .rst(rst), .en(PCEn), .d(PCprime), .q(PC)); // For design, this hard code of the init value should be a variable 
    

    // Mux input to instruction/data memory. 
    // We will use PC, but must also consider a memory address, which is output from the CPU to
    // the rw_ram file as mem_addr if the select signal is 1. The input here will be from the ALU. 
    logic [31:0] ALUOut;
    mux rw_ram_input_select (.f(mem_addr) , .a(PC) , .b(ALUOut) , .sel(IorD) );    

    // The read data from the rw_ram file should be stored in a nonarchitectural register 
    logic [31:0] reg_instr;
    reg_en read_data_reg (.clk(clk_100M), .rst(rst), .en(IRWrite), .d(r_data), .q(reg_instr));

    // Instantiate the register file. Create the register inputs and select the right write register
    // while also creating the register file outputs 
    logic [4:0] a1, a2, a3, a3_choice0, a3_choice1; 
    assign a2 = reg_instr[20:16];
    assign a3_choice0 = reg_instr[20:16];
    assign a3_choice1 = reg_instr[15:11];
    eight_one_32b_mux #(.N(5)) a3_select (.f(a3), .i0(a3_choice0), .i1(a3_choice1), .i2(5'd31), .i3(5'd0), .i4(5'd0), .i5(5'd0), .i6(5'd0), .i7(5'd0), .s(RegDst));
    mux #(.N(5)) a1_select (.f(a1), .a(reg_instr[25:21]), .b(a2), .sel(shift));

    logic [31:0] rd1, rd2, wd3;

    reg_file register_file (.clk(clk_100M), .wr_en(RegWrite), .w_addr(a3), .r0_addr(a1), .r1_addr(a2), .w_data(wd3), .r0_data(rd1),
                                .r1_data(rd2), .rdbg_addr(rdbg_addr), .rdbg_data(rdbg_data));



    // Instantiate non-architectural registers to store the data values from RD1 and RD2 
    logic [31:0] rd1_A;  // The A and the B match up with symbols in H & H 
    logic [31:0] rd2_B;
    assign w_data = rd2_B;
    reg_en reg_data_reg_A (.clk(clk_100M), .rst(rst), .en(1'b1), .d(rd1), .q(rd1_A));
    reg_en reg_data_reg_B (.clk(clk_100M), .rst(rst), .en(1'b1), .d(rd2), .q(rd2_B));

    // Select either the program counter or the register data A to go into the ALU 
    logic [31:0] SrcA;
    mux select_A_to_ALU (.f(SrcA), .a(PC), .b(rd1_A), .sel(AluSrcA));

    // Sign extend unit in our data path 
    logic [31:0] SignImm;
    logic [31:0] signimm_shift2;
    assign SignImm = {{16{reg_instr[15]}} , reg_instr[15:0]};
    assign signimm_shift2 = 4 * SignImm;
    
    // Select the correct value to place as the second parameter to the ALU 
    logic [31:0] SrcB;
    logic [31:0] potentialShiftAmount;
    assign potentialShiftAmount = {{27{1'b0}} , reg_instr[10:6]};
    eight_one_32b_mux select_B_to_ALU (.i0(rd2_B), .i1(32'd4), .i2(SignImm), .i3(signimm_shift2), .i4(potentialShiftAmount), .i5(32'd0), .i6(32'd0), .i7(32'd0), .s(ALUSrcB), .f(SrcB));


    // Instantiate the ALU 
    logic [31:0] ALUResult;
    logic zero_flag;
    alu alu_unit (.x(SrcA), .y(SrcB), .op(AluControl), .zero(zero_flag), .z(ALUResult));

    // Store the ALU Result in a non-architectural register 
    reg_en alu_result_store (.clk(clk_100M), .rst(rst), .en(1'b1), .d(ALUResult), .q(ALUOut));

    // Now, select the correct ALU Result to pass to the program counter 
    // mux select_aluresult (.f(PCprime), .a(ALUResult), .b(ALUOut), .sel(PCSrc));
    logic [31:0] PCJump;
    logic [31:0] ALUprime;
    assign PCJump = {PC[31:28], reg_instr[25:0], 2'b00};
    eight_one_32b_mux select_aluresult(.f(ALUprime), .s(PCSrc), .i0(ALUResult), .i1(ALUOut), .i2(PCJump), .i3(32'd0), .i4(32'd0), .i5(32'd0), .i6(32'd0), .i7(32'd0));
    mux selectPCPrime (.f(PCprime), .sel(JumpReg), .a(ALUprime), .b(rd1_A));

    // Take care of the PCEn 
    assign PCEn = (zero_flag & Branch) | PCWrite | (~(zero_flag) & BranchNotEqual);

    // Take care of the entrance to the register file write data including the nonarchitectural register before the mux 
    logic [31:0] data;
    reg_en store_write_data_fromram (.clk(clk_100M), .rst(rst), .en(1'b1), .d(r_data), .q(data));
    eight_one_32b_mux select_input_towd3(.f(wd3), .s(MemtoReg), .i0(ALUOut), .i1(data), .i2(PC), .i3(32'd0), .i4(32'd0), .i5(32'd0), .i6(32'd0), .i7(32'd0));


    // Instantiate the control unit, which is internal to this module 
    control_unit control_unit (.shift(shift), .JumpReg(JumpReg), .op(reg_instr[31:26]), .funct(reg_instr[5:0]), .ALUControl(AluControl), .rst(rst), .clk(clk_100M), .IorD(IorD), .AluSrcA(AluSrcA), .PCSrc(PCSrc), .IRWrite(IRWrite), 
                                .PCWrite(PCWrite), .Branch(Branch), .BranchNotEqual(BranchNotEqual), .MemWrite(wr_en), .RegDst(RegDst), .MemtoReg(MemtoReg), .RegWrite(RegWrite), .ALUOp(ALUOp), .ALUSrcB(ALUSrcB));



    // The CPU interfaces with main memory which is enabled by the
    // inputs and outputs of this module (r_data, wr_en, mem_addr, w_data)
    // You should create the register file, flip flops, and logic implementing
    // a simple datapath so that instructions can be loaded from main memory,
    // executed, and the results can be inspected in the register file, or in
    // main memory (once lw and sw are supported). You should also create a
    // control FSM that controls the behavior of the datapath depending on the
    // instruction that is currently executing. You may want to split the CPU
    // into one or more submodules.
    //
    // We have provided modules for you to use inside the CPU. Please see
    // the following files:
    // reg_file.sv (register file), reg_en.sv (register with enable and reset),
    // reg_reset.sv (register with only reset), alu.sv (ALU)
    // Useful constants and opcodes are provided in cpu.svh, which is included
    // at the top of this file.
    //
    // Place the instruction machine code (generated by your assembler, or the
    // provided assembler) in asm/instr.mem and it will be automatically
    // loaded into main memory starting at address 0x0000. Make sure the memory
    // file is imported into Vivado first (`./tcl.sh refresh`).
endmodule
