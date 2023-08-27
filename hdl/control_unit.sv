`include "cpu.svh"

module control_unit
    (
        input logic clk, rst,
        input logic [5:0] op, funct,
        output logic IorD, shift, JumpReg, MemWrite, AluSrcA, Branch, BranchNotEqual, IRWrite, PCWrite, RegWrite,
        output logic [2:0] ALUOp, PCSrc, RegDst, MemtoReg,
        output logic [3:0] ALUControl,
        output logic [2:0] ALUSrcB 
    );

    typedef enum { s0, s1, s2, s3, s4, s5, s6, s7, s8, sbne, s10, s11j, s12jr, s13jal } state_t;
    state_t state_reg, state_next;

    // state register 
    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            state_reg <= s0; 
        else
            state_reg <= state_next;
    end

    always @(ALUOp) begin
        unique case (ALUOp)
            3'b000: begin
                ALUControl = `ALU_ADD; // Add 4 for the program counter to increase
            end 
            3'b001: begin
                ALUControl = `ALU_SUB; // Then, the ALU should subtract 
            end
            3'b010: begin
                case (funct)
                    `F_AND: begin
                        ALUControl = `ALU_AND;
                    end
                    `F_XOR: begin 
                        ALUControl = `ALU_XOR;
                    end
                    `F_OR:  begin 
                        ALUControl = `ALU_OR;
                    end
                    `F_NOR: begin 
                        ALUControl = `ALU_NOR;
                    end
                    `F_SLL: begin 
                        ALUControl = `ALU_SLL;
                    end
                    `F_SRA: begin
                        ALUControl = `ALU_SRA;
                    end
                    `F_SRL: begin 
                        ALUControl = `ALU_SRL;
                    end
                    `F_SLT: begin
                        ALUControl = `ALU_SLT;
                    end
                    `F_ADD: begin 
                        ALUControl = `ALU_ADD;
                    end
                    `F_SUB: begin 
                        ALUControl = `ALU_SUB;
                    end
                    default: begin
                        ALUControl = `ALU_ADD;
                    end
                endcase
            end
            3'b011: begin 
            
            end
            3'b100: begin
                unique case(op)
                    `OP_ORI: begin
                        ALUControl = `ALU_OR;
                    end
                    `OP_XORI: begin
                        ALUControl = `ALU_XOR;
                    end
                    `OP_ANDI: begin
                        ALUControl = `ALU_AND;
                    end
                    `OP_SLTI: begin
                        ALUControl = `ALU_SLT;
                    end
                endcase
            end
        endcase
    end


    always_comb begin
        state_next = state_reg; // default state is the same. do i need this line? I don't really understand it
        IorD = 1'b0;            // default output 
        AluSrcA = 1'b0; 
        ALUOp = 3'b000;
        PCSrc = 3'b000;
        IRWrite = 1'b1; 
        PCWrite = 1'b1;
        RegDst = 3'b001;
        MemtoReg = 3'b000;
        RegWrite = 1'b0;
        Branch = 1'b0;
        MemWrite = 1'b0;
        BranchNotEqual = 1'b0;
        shift = 1'b0;
        JumpReg = 1'b0;

        ALUSrcB = 3'b001;

        unique case (state_reg) // Assigning next states and output. For r-type transitions
            s0: begin           // no logic because automatic cycle through states after each step 
                state_next = s1;
            end
            s1: begin
                IRWrite = 1'b0; 
                PCWrite = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                BranchNotEqual = 1'b0;
                RegWrite = 1'b0;

                AluSrcA = 1'b0;
                ALUSrcB = 3'b011;
                ALUOp = 3'b000;

                if (op == `OP_RTYPE) begin
                    if (funct == `F_SRL || funct == `F_SLL || funct == `F_SRA) begin
                        shift = 1'b1;
                    end
                end 

                if (op == `OP_RTYPE) begin
                    if (funct == `F_JR) begin
                        state_next = s12jr;
                    end else begin
                        state_next = s6;
                    end
                end else if (op == `OP_BEQ) begin
                    state_next = s8;
                end else if (op == `OP_BNE) begin
                    state_next = sbne;
                end else if (op == `OP_J) begin
                    state_next = s11j;
                end else if (op == `OP_JAL) begin
                    state_next = s13jal;
                end else begin
                    state_next = s2;
                end
            end
            s13jal: begin
                IorD = 1'b0;
                IRWrite = 1'b0; 
                PCWrite = 1'b1;
                MemWrite = 1'b0;
                Branch = 1'b0;
                BranchNotEqual = 1'b0;
                RegWrite = 1'b1;
                PCSrc = 3'b010;
                RegDst = 3'b010;
                MemtoReg = 3'b010;

                state_next = s0;
            end
            s12jr: begin
                IorD = 1'b0;
                IRWrite = 1'b0;
                PCWrite = 1'b1;
                MemWrite = 1'b0;
                Branch = 1'b0;
                BranchNotEqual = 1'b0;
                RegWrite = 1'b0;
                JumpReg = 1'b1;

                state_next = s0;
            end
            s11j: begin
                IorD = 1'b0;
                IRWrite = 1'b0; 
                PCWrite = 1'b1;
                MemWrite = 1'b0;
                Branch = 1'b0;
                BranchNotEqual = 1'b0;
                RegWrite = 1'b0;
                PCSrc = 3'b010;

                state_next = s0;
            end
            s8: begin
                AluSrcA = 1'b1;
                ALUSrcB = 3'b000;
                ALUOp = 3'b001;
                PCSrc = 3'b001;
                RegWrite = 1'b0;
                IRWrite = 1'b0; 
                PCWrite = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b1;
                BranchNotEqual = 1'b0;
                state_next = s0;
            end
            sbne: begin
                AluSrcA = 1'b1;
                ALUSrcB = 3'b000;
                ALUOp = 3'b001;
                PCSrc = 3'b001;
                RegWrite = 1'b0;
                IRWrite = 1'b0; 
                PCWrite = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                BranchNotEqual = 1'b1;
                state_next = s0;
            end
            s6: begin
                AluSrcA = 1'b1;
                ALUOp = 3'b010;
                IRWrite = 1'b0; 
                PCWrite = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                BranchNotEqual = 1'b0;
                RegWrite = 1'b0;

                if (funct == `F_SRL || funct == `F_SLL || funct == `F_SRA) begin
                    ALUSrcB = 3'b100;
                end else begin
                    ALUSrcB = 3'b000;
                end

                state_next = s7;
                
            end
            s7: begin
                RegWrite = 1'b1; // Assert this signal in ALU Writeback
                IRWrite = 1'b0; 
                PCWrite = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                BranchNotEqual = 1'b0;

                state_next = s0;
            end
            s2: begin
                AluSrcA = 1'b1;
                IRWrite = 1'b0; 
                PCWrite = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                BranchNotEqual = 1'b0;
                RegWrite = 1'b0;
                ALUSrcB = 3'b010; 
                if (op == `OP_LW) begin
                    ALUOp = 3'b000;
                    state_next = s3;
                end else if (op == `OP_SW) begin
                    ALUOp = 3'b000;
                    state_next = s5;
                end else begin
                    ALUOp = 3'b100;
                    state_next = s10;
                end
            end
            s10: begin
                IorD = 1'b0;
                IRWrite = 1'b0; 
                PCWrite = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                BranchNotEqual = 1'b0;
                RegWrite = 1'b1;
                RegDst = 3'b000;
                MemtoReg = 3'b000;

                state_next = s0;

            end
            s3: begin
                IorD = 1'b1;
                IRWrite = 1'b0; 
                PCWrite = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                BranchNotEqual = 1'b0;
                RegWrite = 1'b0;

                state_next = s4;
            end
            s5: begin
                IorD = 1'b1;
                IRWrite = 1'b0; 
                PCWrite = 1'b0;
                MemWrite = 1'b1;
                Branch = 1'b0;
                BranchNotEqual = 1'b0;
                RegWrite = 1'b0;

                state_next = s0;
            end
            s4: begin
                RegDst = 3'b000;
                MemtoReg = 3'b001;
                IorD = 1'b0;
                IRWrite = 1'b0; 
                PCWrite = 1'b0;
                MemWrite = 1'b0;
                Branch = 1'b0;
                BranchNotEqual = 1'b0;
                RegWrite = 1'b1;

                state_next = s0;
            end
        endcase
    end

endmodule