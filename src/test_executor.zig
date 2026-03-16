const std = @import("std");
const cpu = @import("cpu.zig");
const memory_mod = @import("memory.zig");
const executor = @import("executor.zig");

// R形式命令のエンコード補助関数
fn encode_r(funct7: u7, rs2: u5, rs1: u5, funct3: u3, rd: u5) u32 {
    return (@as(u32, funct7) << 25) |
        (@as(u32, rs2) << 20) |
        (@as(u32, rs1) << 15) |
        (@as(u32, funct3) << 12) |
        (@as(u32, rd) << 7) |
        0b0110011;
}

// I形式命令のエンコード補助関数
fn encode_i(imm: u12, rs1: u5, funct3: u3, rd: u5, opcode: u7) u32 {
    return (@as(u32, imm) << 20) |
        (@as(u32, rs1) << 15) |
        (@as(u32, funct3) << 12) |
        (@as(u32, rd) << 7) |
        @as(u32, opcode);
}

// S形式命令のエンコード補助関数
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

// B形式命令のエンコード補助関数
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

// U形式命令のエンコード補助関数
fn encode_u(imm: u20, rd: u5, opcode: u7) u32 {
    return (@as(u32, imm) << 12) |
        (@as(u32, rd) << 7) |
        @as(u32, opcode);
}

// J形式命令のエンコード補助関数
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

test "execute_r ADD" {
    var c = cpu.cpu.init();
    c.reg(1).* = 5;
    c.reg(2).* = 3;
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x0, 3));
    try std.testing.expectEqual(@as(u32, 8), c.reg(3).*);
}

test "execute_r ADD wrapping" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0xFFFFFFFF;
    c.reg(2).* = 1;
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x0, 3));
    try std.testing.expectEqual(@as(u32, 0), c.reg(3).*);
}

test "execute_r SUB" {
    var c = cpu.cpu.init();
    c.reg(1).* = 10;
    c.reg(2).* = 4;
    executor.execute_r(&c, encode_r(0x20, 2, 1, 0x0, 3));
    try std.testing.expectEqual(@as(u32, 6), c.reg(3).*);
}

test "execute_r SUB wrapping" {
    var c = cpu.cpu.init();
    c.reg(1).* = 3;
    c.reg(2).* = 5;
    executor.execute_r(&c, encode_r(0x20, 2, 1, 0x0, 3));
    try std.testing.expectEqual(@as(u32, 0xFFFFFFFE), c.reg(3).*);
}

test "execute_r SLL" {
    var c = cpu.cpu.init();
    c.reg(1).* = 1;
    c.reg(2).* = 3;
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x1, 3));
    try std.testing.expectEqual(@as(u32, 8), c.reg(3).*);
}

test "execute_r SLL uses lower 5 bits of rs2" {
    var c = cpu.cpu.init();
    c.reg(1).* = 1;
    c.reg(2).* = 0xFF_0001; // 下位5ビットは1
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x1, 3));
    try std.testing.expectEqual(@as(u32, 2), c.reg(3).*);
}

test "execute_r SLT rs1 < rs2" {
    var c = cpu.cpu.init();
    c.reg(1).* = 1;
    c.reg(2).* = 2;
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x2, 3));
    try std.testing.expectEqual(@as(u32, 1), c.reg(3).*);
}

test "execute_r SLT rs1 >= rs2" {
    var c = cpu.cpu.init();
    c.reg(1).* = 2;
    c.reg(2).* = 2;
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x2, 3));
    try std.testing.expectEqual(@as(u32, 0), c.reg(3).*);
}

test "execute_r SLT signed: -1 < 1" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0xFFFFFFFF; // -1 (符号付き)
    c.reg(2).* = 1;
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x2, 3));
    try std.testing.expectEqual(@as(u32, 1), c.reg(3).*);
}

test "execute_r SLTU unsigned: large > small" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0xFFFFFFFF; // 符号なしでは最大値
    c.reg(2).* = 1;
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x3, 3));
    try std.testing.expectEqual(@as(u32, 0), c.reg(3).*);
}

test "execute_r SLTU unsigned: small < large" {
    var c = cpu.cpu.init();
    c.reg(1).* = 1;
    c.reg(2).* = 0xFFFFFFFF;
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x3, 3));
    try std.testing.expectEqual(@as(u32, 1), c.reg(3).*);
}

test "execute_r XOR" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0b1010;
    c.reg(2).* = 0b1100;
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x4, 3));
    try std.testing.expectEqual(@as(u32, 0b0110), c.reg(3).*);
}

test "execute_r SRL" {
    var c = cpu.cpu.init();
    c.reg(1).* = 8;
    c.reg(2).* = 2;
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x5, 3));
    try std.testing.expectEqual(@as(u32, 2), c.reg(3).*);
}

test "execute_r SRL logical: no sign extension" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0x80000000;
    c.reg(2).* = 1;
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x5, 3));
    try std.testing.expectEqual(@as(u32, 0x40000000), c.reg(3).*);
}

test "execute_r SRA" {
    var c = cpu.cpu.init();
    c.reg(1).* = 8;
    c.reg(2).* = 2;
    executor.execute_r(&c, encode_r(0x20, 2, 1, 0x5, 3));
    try std.testing.expectEqual(@as(u32, 2), c.reg(3).*);
}

test "execute_r SRA arithmetic: sign extension" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0x80000000; // -2147483648
    c.reg(2).* = 1;
    executor.execute_r(&c, encode_r(0x20, 2, 1, 0x5, 3));
    try std.testing.expectEqual(@as(u32, 0xC0000000), c.reg(3).*);
}

test "execute_r OR" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0b1010;
    c.reg(2).* = 0b0101;
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x6, 3));
    try std.testing.expectEqual(@as(u32, 0b1111), c.reg(3).*);
}

test "execute_r AND" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0b1010;
    c.reg(2).* = 0b1100;
    executor.execute_r(&c, encode_r(0x00, 2, 1, 0x7, 3));
    try std.testing.expectEqual(@as(u32, 0b1000), c.reg(3).*);
}

// ---- execute_i_alu ----

test "execute_i_alu ADDI" {
    var c = cpu.cpu.init();
    c.reg(1).* = 5;
    // ADDI x3, x1, 3
    executor.execute_i_alu(&c, encode_i(3, 1, 0x0, 3, 0b0010011));
    try std.testing.expectEqual(@as(u32, 8), c.reg(3).*);
}

test "execute_i_alu ADDI negative immediate" {
    var c = cpu.cpu.init();
    c.reg(1).* = 10;
    // ADDI x3, x1, -3  (imm = 0xFFD = -3 as i12)
    executor.execute_i_alu(&c, encode_i(0xFFD, 1, 0x0, 3, 0b0010011));
    try std.testing.expectEqual(@as(u32, 7), c.reg(3).*);
}

test "execute_i_alu SLLI" {
    var c = cpu.cpu.init();
    c.reg(1).* = 1;
    // SLLI x3, x1, 4  (imm = shamt = 4)
    executor.execute_i_alu(&c, encode_i(4, 1, 0x1, 3, 0b0010011));
    try std.testing.expectEqual(@as(u32, 16), c.reg(3).*);
}

test "execute_i_alu SLTI rs1 < imm" {
    var c = cpu.cpu.init();
    c.reg(1).* = 1;
    // SLTI x3, x1, 2
    executor.execute_i_alu(&c, encode_i(2, 1, 0x2, 3, 0b0010011));
    try std.testing.expectEqual(@as(u32, 1), c.reg(3).*);
}

test "execute_i_alu SLTI signed: -1 < 1" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0xFFFFFFFF; // -1 (符号付き)
    // SLTI x3, x1, 1
    executor.execute_i_alu(&c, encode_i(1, 1, 0x2, 3, 0b0010011));
    try std.testing.expectEqual(@as(u32, 1), c.reg(3).*);
}

test "execute_i_alu SLTIU unsigned" {
    var c = cpu.cpu.init();
    c.reg(1).* = 1;
    // SLTIU x3, x1, 2
    executor.execute_i_alu(&c, encode_i(2, 1, 0x3, 3, 0b0010011));
    try std.testing.expectEqual(@as(u32, 1), c.reg(3).*);
}

test "execute_i_alu XORI" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0b1010;
    // XORI x3, x1, 0b1100
    executor.execute_i_alu(&c, encode_i(0b1100, 1, 0x4, 3, 0b0010011));
    try std.testing.expectEqual(@as(u32, 0b0110), c.reg(3).*);
}

test "execute_i_alu SRLI" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0x80000000;
    // SRLI x3, x1, 1  (imm = shamt = 1, funct7 = 0x00)
    executor.execute_i_alu(&c, encode_i(1, 1, 0x5, 3, 0b0010011));
    try std.testing.expectEqual(@as(u32, 0x40000000), c.reg(3).*);
}

test "execute_i_alu SRAI arithmetic" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0x80000000; // -2147483648
    // SRAI x3, x1, 1  (imm = (0x20 << 5) | 1 = 0x401, funct7 = 0x20)
    executor.execute_i_alu(&c, encode_i(0x401, 1, 0x5, 3, 0b0010011));
    try std.testing.expectEqual(@as(u32, 0xC0000000), c.reg(3).*);
}

test "execute_i_alu ORI" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0b1010;
    // ORI x3, x1, 0b0101
    executor.execute_i_alu(&c, encode_i(0b0101, 1, 0x6, 3, 0b0010011));
    try std.testing.expectEqual(@as(u32, 0b1111), c.reg(3).*);
}

test "execute_i_alu ANDI" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0b1010;
    // ANDI x3, x1, 0b1100
    executor.execute_i_alu(&c, encode_i(0b1100, 1, 0x7, 3, 0b0010011));
    try std.testing.expectEqual(@as(u32, 0b1000), c.reg(3).*);
}

// ---- execute_i_load / execute_s ----

test "execute_s SW / execute_i_load LW" {
    var c = cpu.cpu.init();
    var m: memory_mod.memory = undefined;
    @memset(&m.memory, 0);

    c.reg(1).* = 0; // ベースアドレス
    c.reg(2).* = 0xDEADBEEF;
    // SW x2, 4(x1)
    executor.execute_s(&c, &m, encode_s(4, 2, 1, 0x2));
    // LW x3, 4(x1)
    executor.execute_i_load(&c, &m, encode_i(4, 1, 0x2, 3, 0b0000011));
    try std.testing.expectEqual(@as(u32, 0xDEADBEEF), c.reg(3).*);
}

test "execute_s SB / execute_i_load LBU" {
    var c = cpu.cpu.init();
    var m: memory_mod.memory = undefined;
    @memset(&m.memory, 0);

    c.reg(1).* = 0;
    c.reg(2).* = 0xFF;
    // SB x2, 0(x1)
    executor.execute_s(&c, &m, encode_s(0, 2, 1, 0x0));
    // LBU x3, 0(x1)  → ゼロ拡張
    executor.execute_i_load(&c, &m, encode_i(0, 1, 0x4, 3, 0b0000011));
    try std.testing.expectEqual(@as(u32, 0xFF), c.reg(3).*);
}

test "execute_i_load LB sign extend" {
    var c = cpu.cpu.init();
    var m: memory_mod.memory = undefined;
    @memset(&m.memory, 0);

    c.reg(1).* = 0;
    c.reg(2).* = 0xFF; // -1 as i8
    // SB x2, 0(x1)
    executor.execute_s(&c, &m, encode_s(0, 2, 1, 0x0));
    // LB x3, 0(x1)  → 符号拡張: 0xFFFFFFFF
    executor.execute_i_load(&c, &m, encode_i(0, 1, 0x0, 3, 0b0000011));
    try std.testing.expectEqual(@as(u32, 0xFFFFFFFF), c.reg(3).*);
}

test "execute_s SH / execute_i_load LHU" {
    var c = cpu.cpu.init();
    var m: memory_mod.memory = undefined;
    @memset(&m.memory, 0);

    c.reg(1).* = 0;
    c.reg(2).* = 0x8001;
    // SH x2, 0(x1)
    executor.execute_s(&c, &m, encode_s(0, 2, 1, 0x1));
    // LHU x3, 0(x1)  → ゼロ拡張
    executor.execute_i_load(&c, &m, encode_i(0, 1, 0x5, 3, 0b0000011));
    try std.testing.expectEqual(@as(u32, 0x8001), c.reg(3).*);
}

test "execute_i_load LH sign extend" {
    var c = cpu.cpu.init();
    var m: memory_mod.memory = undefined;
    @memset(&m.memory, 0);

    c.reg(1).* = 0;
    c.reg(2).* = 0x8000; // -32768 as i16
    // SH x2, 0(x1)
    executor.execute_s(&c, &m, encode_s(0, 2, 1, 0x1));
    // LH x3, 0(x1)  → 符号拡張: 0xFFFF8000
    executor.execute_i_load(&c, &m, encode_i(0, 1, 0x1, 3, 0b0000011));
    try std.testing.expectEqual(@as(u32, 0xFFFF8000), c.reg(3).*);
}

// ---- execute_b ----

test "execute_b BEQ taken" {
    var c = cpu.cpu.init();
    c.reg(1).* = 5;
    c.reg(2).* = 5;
    // BEQ x1, x2, +8
    executor.execute_b(&c, encode_b(8, 2, 1, 0x0));
    try std.testing.expectEqual(@as(u32, 8), c.pc);
}

test "execute_b BEQ not taken" {
    var c = cpu.cpu.init();
    c.reg(1).* = 5;
    c.reg(2).* = 6;
    executor.execute_b(&c, encode_b(8, 2, 1, 0x0));
    try std.testing.expectEqual(@as(u32, 0), c.pc);
}

test "execute_b BNE taken" {
    var c = cpu.cpu.init();
    c.reg(1).* = 5;
    c.reg(2).* = 6;
    executor.execute_b(&c, encode_b(8, 2, 1, 0x1));
    try std.testing.expectEqual(@as(u32, 8), c.pc);
}

test "execute_b BLT signed taken" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0xFFFFFFFF; // -1 (符号付き)
    c.reg(2).* = 1;
    // BLT x1, x2, +8
    executor.execute_b(&c, encode_b(8, 2, 1, 0x4));
    try std.testing.expectEqual(@as(u32, 8), c.pc);
}

test "execute_b BGE signed taken" {
    var c = cpu.cpu.init();
    c.reg(1).* = 1;
    c.reg(2).* = 0xFFFFFFFF; // -1 (符号付き)
    // BGE x1, x2, +8
    executor.execute_b(&c, encode_b(8, 2, 1, 0x5));
    try std.testing.expectEqual(@as(u32, 8), c.pc);
}

test "execute_b BLTU unsigned taken" {
    var c = cpu.cpu.init();
    c.reg(1).* = 1;
    c.reg(2).* = 0xFFFFFFFF; // 符号なしでは最大値
    // BLTU x1, x2, +8
    executor.execute_b(&c, encode_b(8, 2, 1, 0x6));
    try std.testing.expectEqual(@as(u32, 8), c.pc);
}

test "execute_b BGEU unsigned taken" {
    var c = cpu.cpu.init();
    c.reg(1).* = 0xFFFFFFFF;
    c.reg(2).* = 1;
    // BGEU x1, x2, +8
    executor.execute_b(&c, encode_b(8, 2, 1, 0x7));
    try std.testing.expectEqual(@as(u32, 8), c.pc);
}

// ---- execute_u_lui / execute_u_auipc ----

test "execute_u_lui" {
    var c = cpu.cpu.init();
    // LUI x3, 0xABCDE
    executor.execute_u_lui(&c, encode_u(0xABCDE, 3, 0b0110111));
    try std.testing.expectEqual(@as(u32, 0xABCDE000), c.reg(3).*);
}

test "execute_u_auipc" {
    var c = cpu.cpu.init();
    c.pc = 0x1000;
    // AUIPC x3, 0x1  → x3 = pc + (0x1 << 12) = 0x1000 + 0x1000 = 0x2000
    executor.execute_u_auipc(&c, encode_u(1, 3, 0b0010111));
    try std.testing.expectEqual(@as(u32, 0x2000), c.reg(3).*);
}

// ---- execute_j (JAL) ----

test "execute_j JAL" {
    var c = cpu.cpu.init();
    c.pc = 100;
    // JAL x1, +8  → x1 = 104, pc = 108
    executor.execute_j(&c, encode_j(8, 1));
    try std.testing.expectEqual(@as(u32, 104), c.reg(1).*);
    try std.testing.expectEqual(@as(u32, 108), c.pc);
}

// ---- execute_i_jalr (JALR) ----

test "execute_i_jalr JALR" {
    var c = cpu.cpu.init();
    c.pc = 100;
    c.reg(1).* = 200;
    // JALR x2, x1, 8  → x2 = 104, pc = (200 + 8) & ~1 = 208
    executor.execute_i_jalr(&c, encode_i(8, 1, 0x0, 2, 0b1100111));
    try std.testing.expectEqual(@as(u32, 104), c.reg(2).*);
    try std.testing.expectEqual(@as(u32, 208), c.pc);
}

test "execute_i_jalr JALR clears bit 0" {
    var c = cpu.cpu.init();
    c.pc = 100;
    c.reg(1).* = 200;
    // JALR x2, x1, 9  → pc = (200 + 9) & ~1 = 209 & ~1 = 208
    executor.execute_i_jalr(&c, encode_i(9, 1, 0x0, 2, 0b1100111));
    try std.testing.expectEqual(@as(u32, 208), c.pc);
}
