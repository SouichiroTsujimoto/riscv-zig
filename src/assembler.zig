const std = @import("std");

fn type_r(funct7: u7, funct3: u3, rd: u5, rs1: u5, rs2: u5) u32 {
    return @as(u32, funct7) << 25 |
        @as(u32, rs2) << 20 |
        @as(u32, rs1) << 15 |
        @as(u32, funct3) << 12 |
        @as(u32, rd) << 7 |
        0b0110011;
}

fn type_i(opcode: u7, funct3: u3, rd: u5, rs1: u5, imm: u12) u32 {
    return @as(u32, imm) << 20 |
        @as(u32, rs1) << 15 |
        @as(u32, funct3) << 12 |
        @as(u32, rd) << 7 |
        @as(u32, opcode);
}

fn type_s(imm: u12, funct3: u3, rs1: u5, rs2: u5) u32 {
    const imm_0_4: u5 = @truncate(imm);
    const imm_5_11: u7 = @truncate(imm);

    return @as(u32, imm_5_11) << 25 |
        @as(u32, rs2) << 20 |
        @as(u32, rs1) << 15 |
        @as(u32, funct3) << 12 |
        @as(u32, imm_0_4) << 7 |
        0b0100011;
}

fn type_b(imm: u13, funct3: u3, rs1: u5, rs2: u5) u32 {
    const imm_1_4: u4 = @truncate(imm >> 1);
    const imm_5_10: u6 = @truncate(imm >> 5);
    const imm_11: u1 = @truncate(imm >> 11);
    const imm_12: u1 = @truncate(imm >> 12);

    const imm_11_1_4: u5 = imm_11 | @as(u5, imm_1_4) << 1;
    const imm_5_10_12: u7 = imm_5_10 | @as(u7, imm_12) << 6;

    return @as(u32, imm_5_10_12) << 25 |
        @as(u32, rs2) << 20 |
        @as(u32, rs1) << 15 |
        @as(u32, funct3) << 12 |
        @as(u32, imm_11_1_4) << 7 |
        0b1100011;
}

pub fn assemble(line: []const u8) u32 {
    var tokens = std.mem.splitAny(u8, line, " ");

    const inst = tokens.next().?;

    // TYPE_R
    if (std.mem.eql(u8, inst, "add")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;

        return type_r(0b0000000, 0b000, rd, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "sub")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;

        return type_r(0b0100000, 0b000, rd, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "xor")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;

        return type_r(0b0000000, 0b100, rd, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "or")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;

        return type_r(0b0000000, 0b110, rd, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "and")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;

        return type_r(0b0000000, 0b111, rd, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "sll")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;

        return type_r(0b0000000, 0b001, rd, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "srl")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;

        return type_r(0b0000000, 0b101, rd, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "sra")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;

        return type_r(0b0100000, 0b101, rd, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "slt")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;

        return type_r(0b0000000, 0b010, rd, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "sltu")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;

        return type_r(0b0000000, 0b011, rd, rs1, rs2);
    }
    // TYPE_I
    else if (std.mem.eql(u8, inst, "addi")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b0010011, 0b000, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "xori")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b0010011, 0b100, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "ori")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b0010011, 0b110, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "andi")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b0010011, 0b111, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "slli")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b0010011, 0b001, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "srli")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b0010011, 0b101, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "srai")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const shamt: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = 0b010000000000 | @as(u12, shamt);

        return type_i(0b0010011, 0b101, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "slti")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b0010011, 0b010, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "sltiu")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b0010011, 0b011, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "lb")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b0000011, 0b000, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "lh")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b0000011, 0b001, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "lw")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b0000011, 0b010, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "lbu")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b0000011, 0b100, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "lhu")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b0000011, 0b101, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "jalr")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_i(0b1100111, 0b000, rd, rs1, imm);
    } else if (std.mem.eql(u8, inst, "ecall")) {
        return type_i(0b1110011, 0b000, 0b00000, 0b00000, 0b000000000000);
    } else if (std.mem.eql(u8, inst, "ebreak")) {
        return type_i(0b1110011, 0b000, 0b00000, 0b00000, 0b000000000001);
    }
    // TYPE_S
    else if (std.mem.eql(u8, inst, "sb")) {
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_s(imm, 0b000, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "sh")) {
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_s(imm, 0b001, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "sw")) {
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u12 = std.fmt.parseInt(u12, tokens.next().?, 10) catch unreachable;

        return type_s(imm, 0b010, rs1, rs2);
    }
    // TYPE_B
    else if (std.mem.eql(u8, inst, "beq")) {
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u13 = std.fmt.parseInt(u13, tokens.next().?, 10) catch unreachable;

        return type_b(imm, 0b000, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "bne")) {
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u13 = std.fmt.parseInt(u13, tokens.next().?, 10) catch unreachable;

        return type_b(imm, 0b001, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "blt")) {
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u13 = std.fmt.parseInt(u13, tokens.next().?, 10) catch unreachable;

        return type_b(imm, 0b100, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "bge")) {
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u13 = std.fmt.parseInt(u13, tokens.next().?, 10) catch unreachable;

        return type_b(imm, 0b101, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "bltu")) {
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u13 = std.fmt.parseInt(u13, tokens.next().?, 10) catch unreachable;

        return type_b(imm, 0b110, rs1, rs2);
    } else if (std.mem.eql(u8, inst, "bgeu")) {
        const rs1: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const rs2: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u13 = std.fmt.parseInt(u13, tokens.next().?, 10) catch unreachable;

        return type_b(imm, 0b111, rs1, rs2);
    }
    // TYPE_J
    else if (std.mem.eql(u8, inst, "jal")) {
        const rd: u5 = std.fmt.parseInt(u5, tokens.next().?, 10) catch unreachable;
        const imm: u21 = std.fmt.parseInt(u21, tokens.next().?, 10) catch unreachable;

        const imm_20: u1 = @truncate(imm >> 20);
        const imm_1_10: u10 = @truncate(imm >> 1);
        const imm_11: u1 = @truncate(imm >> 11);
        const imm_12_19: u8 = @truncate(imm >> 12);

        return @as(u32, imm_20) << 31 |
            @as(u32, imm_1_10) << 21 |
            @as(u32, imm_11) << 20 |
            @as(u32, imm_12_19) << 12 |
            @as(u32, rd) << 7 |
            0b1101111;
    }

    return 0;
}
