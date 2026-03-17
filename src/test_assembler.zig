const std = @import("std");
const assembler = @import("assembler.zig");

fn encode_r(funct7: u7, rs2: u5, rs1: u5, funct3: u3, rd: u5) u32 {
    return (@as(u32, funct7) << 25) |
        (@as(u32, rs2) << 20) |
        (@as(u32, rs1) << 15) |
        (@as(u32, funct3) << 12) |
        (@as(u32, rd) << 7) |
        0b0110011;
}

fn encode_i(imm: u12, rs1: u5, funct3: u3, rd: u5, opcode: u7) u32 {
    return (@as(u32, imm) << 20) |
        (@as(u32, rs1) << 15) |
        (@as(u32, funct3) << 12) |
        (@as(u32, rd) << 7) |
        @as(u32, opcode);
}

fn encode_s(imm: u12, rs2: u5, rs1: u5, funct3: u3) u32 {
    const imm_4_0: u5 = @truncate(imm);
    const imm_11_5: u7 = @truncate(imm >> 5);
    return (@as(u32, imm_11_5) << 25) |
        (@as(u32, rs2) << 20) |
        (@as(u32, rs1) << 15) |
        (@as(u32, funct3) << 12) |
        (@as(u32, imm_4_0) << 7) |
        0b0100011;
}

fn encode_b(imm: u13, rs2: u5, rs1: u5, funct3: u3) u32 {
    const imm_12: u1 = @truncate(imm >> 12);
    const imm_10_5: u6 = @truncate(imm >> 5);
    const imm_4_1: u4 = @truncate(imm >> 1);
    const imm_11: u1 = @truncate(imm >> 11);
    return (@as(u32, imm_12) << 31) |
        (@as(u32, imm_10_5) << 25) |
        (@as(u32, rs2) << 20) |
        (@as(u32, rs1) << 15) |
        (@as(u32, funct3) << 12) |
        (@as(u32, imm_4_1) << 8) |
        (@as(u32, imm_11) << 7) |
        0b1100011;
}

fn encode_j(imm: u21, rd: u5) u32 {
    const imm_20: u1 = @truncate(imm >> 20);
    const imm_10_1: u10 = @truncate(imm >> 1);
    const imm_11: u1 = @truncate(imm >> 11);
    const imm_19_12: u8 = @truncate(imm >> 12);
    return (@as(u32, imm_20) << 31) |
        (@as(u32, imm_10_1) << 21) |
        (@as(u32, imm_11) << 20) |
        (@as(u32, imm_19_12) << 12) |
        (@as(u32, rd) << 7) |
        0b1101111;
}

// ---- TYPE_R ----

test "assemble add" {
    try std.testing.expectEqual(encode_r(0b0000000, 2, 1, 0b000, 3), assembler.assemble("add 3 1 2"));
}

test "assemble sub" {
    try std.testing.expectEqual(encode_r(0b0100000, 2, 1, 0b000, 3), assembler.assemble("sub 3 1 2"));
}

test "assemble xor" {
    try std.testing.expectEqual(encode_r(0b0000000, 2, 1, 0b100, 3), assembler.assemble("xor 3 1 2"));
}

test "assemble or" {
    try std.testing.expectEqual(encode_r(0b0000000, 2, 1, 0b110, 3), assembler.assemble("or 3 1 2"));
}

test "assemble and" {
    try std.testing.expectEqual(encode_r(0b0000000, 2, 1, 0b111, 3), assembler.assemble("and 3 1 2"));
}

test "assemble sll" {
    try std.testing.expectEqual(encode_r(0b0000000, 2, 1, 0b001, 3), assembler.assemble("sll 3 1 2"));
}

test "assemble srl" {
    try std.testing.expectEqual(encode_r(0b0000000, 2, 1, 0b101, 3), assembler.assemble("srl 3 1 2"));
}

test "assemble sra" {
    try std.testing.expectEqual(encode_r(0b0100000, 2, 1, 0b101, 3), assembler.assemble("sra 3 1 2"));
}

test "assemble slt" {
    try std.testing.expectEqual(encode_r(0b0000000, 2, 1, 0b010, 3), assembler.assemble("slt 3 1 2"));
}

test "assemble sltu" {
    try std.testing.expectEqual(encode_r(0b0000000, 2, 1, 0b011, 3), assembler.assemble("sltu 3 1 2"));
}

// ---- TYPE_I (ALU) ----

test "assemble addi" {
    try std.testing.expectEqual(encode_i(10, 1, 0b000, 3, 0b0010011), assembler.assemble("addi 3 1 10"));
}

test "assemble xori" {
    try std.testing.expectEqual(encode_i(0b1100, 1, 0b100, 3, 0b0010011), assembler.assemble("xori 3 1 12"));
}

test "assemble ori" {
    try std.testing.expectEqual(encode_i(0b0101, 1, 0b110, 3, 0b0010011), assembler.assemble("ori 3 1 5"));
}

test "assemble andi" {
    try std.testing.expectEqual(encode_i(0b1100, 1, 0b111, 3, 0b0010011), assembler.assemble("andi 3 1 12"));
}

test "assemble slli" {
    try std.testing.expectEqual(encode_i(4, 1, 0b001, 3, 0b0010011), assembler.assemble("slli 3 1 4"));
}

test "assemble srli" {
    try std.testing.expectEqual(encode_i(2, 1, 0b101, 3, 0b0010011), assembler.assemble("srli 3 1 2"));
}

test "assemble srai" {
    // imm = 0b010000000000 | shamt
    try std.testing.expectEqual(encode_i(0b010000000001, 1, 0b101, 3, 0b0010011), assembler.assemble("srai 3 1 1"));
}

test "assemble slti" {
    try std.testing.expectEqual(encode_i(5, 1, 0b010, 3, 0b0010011), assembler.assemble("slti 3 1 5"));
}

test "assemble sltiu" {
    try std.testing.expectEqual(encode_i(5, 1, 0b011, 3, 0b0010011), assembler.assemble("sltiu 3 1 5"));
}

// ---- TYPE_I (LOAD) ----

test "assemble lb" {
    try std.testing.expectEqual(encode_i(4, 1, 0b000, 3, 0b0000011), assembler.assemble("lb 3 1 4"));
}

test "assemble lh" {
    try std.testing.expectEqual(encode_i(4, 1, 0b001, 3, 0b0000011), assembler.assemble("lh 3 1 4"));
}

test "assemble lw" {
    try std.testing.expectEqual(encode_i(4, 1, 0b010, 3, 0b0000011), assembler.assemble("lw 3 1 4"));
}

test "assemble lbu" {
    try std.testing.expectEqual(encode_i(4, 1, 0b100, 3, 0b0000011), assembler.assemble("lbu 3 1 4"));
}

test "assemble lhu" {
    try std.testing.expectEqual(encode_i(4, 1, 0b101, 3, 0b0000011), assembler.assemble("lhu 3 1 4"));
}

test "assemble jalr" {
    try std.testing.expectEqual(encode_i(8, 1, 0b000, 2, 0b1100111), assembler.assemble("jalr 2 1 8"));
}

test "assemble ecall" {
    try std.testing.expectEqual(encode_i(0, 0, 0b000, 0, 0b1110011), assembler.assemble("ecall"));
}

test "assemble ebreak" {
    try std.testing.expectEqual(encode_i(1, 0, 0b000, 0, 0b1110011), assembler.assemble("ebreak"));
}

// ---- TYPE_S ----

test "assemble sb" {
    // sb rs1=1 rs2=2 imm=4
    try std.testing.expectEqual(encode_s(4, 2, 1, 0b000), assembler.assemble("sb 1 2 4"));
}

test "assemble sh" {
    try std.testing.expectEqual(encode_s(4, 2, 1, 0b001), assembler.assemble("sh 1 2 4"));
}

test "assemble sw" {
    try std.testing.expectEqual(encode_s(4, 2, 1, 0b010), assembler.assemble("sw 1 2 4"));
}

test "assemble sw imm crossing bit5" {
    // imm=0x20=32: imm[11:5]=1, imm[4:0]=0 — バグがあれば失敗する
    try std.testing.expectEqual(encode_s(32, 2, 1, 0b010), assembler.assemble("sw 1 2 32"));
}

// ---- TYPE_B ----

test "assemble beq" {
    try std.testing.expectEqual(encode_b(8, 2, 1, 0b000), assembler.assemble("beq 1 2 8"));
}

test "assemble bne" {
    try std.testing.expectEqual(encode_b(8, 2, 1, 0b001), assembler.assemble("bne 1 2 8"));
}

test "assemble blt" {
    try std.testing.expectEqual(encode_b(8, 2, 1, 0b100), assembler.assemble("blt 1 2 8"));
}

test "assemble bge" {
    try std.testing.expectEqual(encode_b(8, 2, 1, 0b101), assembler.assemble("bge 1 2 8"));
}

test "assemble bltu" {
    try std.testing.expectEqual(encode_b(8, 2, 1, 0b110), assembler.assemble("bltu 1 2 8"));
}

test "assemble bgeu" {
    try std.testing.expectEqual(encode_b(8, 2, 1, 0b111), assembler.assemble("bgeu 1 2 8"));
}

// ---- TYPE_J ----

test "assemble jal" {
    try std.testing.expectEqual(encode_j(8, 1), assembler.assemble("jal 1 8"));
}

test "assemble jal large offset" {
    // imm=0x100: imm[19:12]=1, 他=0
    try std.testing.expectEqual(encode_j(0x100, 1), assembler.assemble("jal 1 256"));
}
