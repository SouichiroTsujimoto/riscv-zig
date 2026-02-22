const std = @import("std");
const decoder = @import("decoder.zig");

test "decode_r" {
    const raw: u32 = (@as(u32, 0b0101010) << 25) |
        (@as(u32, 0b00101) << 20) |
        (@as(u32, 0b00011) << 15) |
        (@as(u32, 0b111) << 12) |
        (@as(u32, 0b00010) << 7) |
        0b0110011;
    const inst = decoder.decode_r(raw);
    try std.testing.expectEqual(@as(u7, 0b0110011), inst.opcode);
    try std.testing.expectEqual(@as(u5, 0b00010), inst.rd);
    try std.testing.expectEqual(@as(u3, 0b111), inst.funct3);
    try std.testing.expectEqual(@as(u5, 0b00011), inst.rs1);
    try std.testing.expectEqual(@as(u5, 0b00101), inst.rs2);
    try std.testing.expectEqual(@as(u7, 0b0101010), inst.funct7);
}

test "decode_i" {
    const raw: u32 = (@as(u32, 0xABC) << 20) |
        (@as(u32, 0b10010) << 15) |
        (@as(u32, 0b010) << 12) |
        (@as(u32, 0b01000) << 7) |
        0b0010011;

    const inst = decoder.decode_i(raw);
    try std.testing.expectEqual(@as(u7, 0b0010011), inst.opcode);
    try std.testing.expectEqual(@as(u5, 0b01000), inst.rd);
    try std.testing.expectEqual(@as(u3, 0b010), inst.funct3);
    try std.testing.expectEqual(@as(u5, 0b10010), inst.rs1);
    try std.testing.expectEqual(@as(u12, 0xABC), inst.imm);
}

test "decode_s" {
    const imm_low: u5 = 0b10101;
    const imm_high: u7 = 0b0110011;
    const raw: u32 = (@as(u32, imm_high) << 25) |
        (@as(u32, 0b00111) << 20) |
        (@as(u32, 0b10001) << 15) |
        (@as(u32, 0b001) << 12) |
        (@as(u32, imm_low) << 7) |
        0b0100011;

    const inst = decoder.decode_s(raw);
    try std.testing.expectEqual(@as(u7, 0b0100011), inst.opcode);
    try std.testing.expectEqual(@as(u3, 0b001), inst.funct3);
    try std.testing.expectEqual(@as(u5, 0b10001), inst.rs1);
    try std.testing.expectEqual(@as(u5, 0b00111), inst.rs2);
    try std.testing.expectEqual((@as(u12, imm_high) << 5) | @as(u12, imm_low), inst.imm);
}

test "decode_b" {
    const imm_12: u1 = 1;
    const imm_11: u1 = 0;
    const imm_10_5: u6 = 0b101011;
    const imm_4_1: u4 = 0b0110;

    const raw: u32 = (@as(u32, imm_12) << 31) |
        (@as(u32, imm_10_5) << 25) |
        (@as(u32, 0b11100) << 20) |
        (@as(u32, 0b00010) << 15) |
        (@as(u32, 0b101) << 12) |
        (@as(u32, imm_4_1) << 8) |
        (@as(u32, imm_11) << 7) |
        0b1100011;

    const inst = decoder.decode_b(raw);
    const expected_imm: u13 = (@as(u13, imm_12) << 12) |
        (@as(u13, imm_11) << 11) |
        (@as(u13, imm_10_5) << 5) |
        (@as(u13, imm_4_1) << 1);

    try std.testing.expectEqual(@as(u7, 0b1100011), inst.opcode);
    try std.testing.expectEqual(@as(u3, 0b101), inst.funct3);
    try std.testing.expectEqual(@as(u5, 0b00010), inst.rs1);
    try std.testing.expectEqual(@as(u5, 0b11100), inst.rs2);
    try std.testing.expectEqual(expected_imm, inst.imm);
}

test "decode_u" {
    const raw: u32 = (@as(u32, 0xABCDE) << 12) |
        (@as(u32, 0b10101) << 7) |
        0b0110111;

    const inst = decoder.decode_u(raw);
    try std.testing.expectEqual(@as(u7, 0b0110111), inst.opcode);
    try std.testing.expectEqual(@as(u5, 0b10101), inst.rd);
    try std.testing.expectEqual(@as(u20, 0xABCDE), inst.imm);
}

test "decode_j" {
    const imm_20: u1 = 1;
    const imm_19_12: u8 = 0x5A;
    const imm_11: u1 = 1;
    const imm_10_1: u10 = 0x155;

    const raw: u32 = (@as(u32, imm_20) << 31) |
        (@as(u32, imm_19_12) << 12) |
        (@as(u32, imm_11) << 20) |
        (@as(u32, imm_10_1) << 21) |
        (@as(u32, 0b00110) << 7) |
        0b1101111;

    const inst = decoder.decode_j(raw);
    const expected_imm: u21 = (@as(u21, imm_20) << 20) |
        (@as(u21, imm_19_12) << 12) |
        (@as(u21, imm_11) << 11) |
        (@as(u21, imm_10_1) << 1);

    try std.testing.expectEqual(@as(u7, 0b1101111), inst.opcode);
    try std.testing.expectEqual(@as(u5, 0b00110), inst.rd);
    try std.testing.expectEqual(expected_imm, inst.imm);
}


