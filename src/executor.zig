const std = @import("std");
const cpu = @import("cpu.zig");
const decoder = @import("decoder.zig");
const memory = @import("memory.zig");

fn sign_extend_12(imm: u12) u32 {
    const signed: i12 = @bitCast(imm);
    return @bitCast(@as(i32, signed));
}

fn sign_extend_13(imm: u13) u32 {
    const signed: i13 = @bitCast(imm);
    return @bitCast(@as(i32, signed));
}

fn sign_extend_21(imm: u21) u32 {
    const signed: i21 = @bitCast(imm);
    return @bitCast(@as(i32, signed));
}

pub fn execute_r(c: *cpu.cpu, raw: u32) void {
    const instruction = decoder.decode_r(raw);

    switch (instruction.funct3) {
        0x0 => {
            switch (instruction.funct7) {
                // ADD
                0x00 => {
                    c.reg(instruction.rd).* = c.reg(instruction.rs1).* +% c.reg(instruction.rs2).*;
                },
                // SUB
                0x20 => {
                    c.reg(instruction.rd).* = c.reg(instruction.rs1).* -% c.reg(instruction.rs2).*;
                },
                else => unreachable,
            }
        },
        // SLL
        0x1 => {
            const shamt: u5 = @intCast(c.reg(instruction.rs2).* & 0x1f);
            c.reg(instruction.rd).* = c.reg(instruction.rs1).* << shamt;
        },
        // SLT
        0x2 => {
            const signed_rs1: i32 = @bitCast(c.reg(instruction.rs1).*);
            const signed_rs2: i32 = @bitCast(c.reg(instruction.rs2).*);
            c.reg(instruction.rd).* = if (signed_rs1 < signed_rs2) 1 else 0;
        },
        // SLTU
        0x3 => {
            c.reg(instruction.rd).* = if (c.reg(instruction.rs1).* < c.reg(instruction.rs2).*) 1 else 0;
        },
        // XOR
        0x4 => {
            c.reg(instruction.rd).* = c.reg(instruction.rs1).* ^ c.reg(instruction.rs2).*;
        },
        0x5 => {
            switch (instruction.funct7) {
                // SRL
                0x00 => {
                    const shamt: u5 = @intCast(c.reg(instruction.rs2).* & 0x1f);
                    c.reg(instruction.rd).* = c.reg(instruction.rs1).* >> shamt;
                },
                // SRA
                0x20 => {
                    const shamt: u5 = @intCast(c.reg(instruction.rs2).* & 0x1f);
                    const signed: i32 = @bitCast(c.reg(instruction.rs1).*);
                    c.reg(instruction.rd).* = @bitCast(signed >> shamt);
                },
                else => unreachable,
            }
        },
        // OR
        0x6 => {
            c.reg(instruction.rd).* = c.reg(instruction.rs1).* | c.reg(instruction.rs2).*;
        },
        // AND
        0x7 => {
            c.reg(instruction.rd).* = c.reg(instruction.rs1).* & c.reg(instruction.rs2).*;
        },
    }
}

pub fn execute_i_alu(c: *cpu.cpu, raw: u32) void {
    const instruction = decoder.decode_i(raw);

    switch (instruction.funct3) {
        // ADDI
        0x0 => {
            c.reg(instruction.rd).* = c.reg(instruction.rs1).* +% sign_extend_12(instruction.imm);
        },
        // SLLI
        0x1 => {
            const shamt: u5 = @intCast(instruction.imm & 0x1f);
            c.reg(instruction.rd).* = c.reg(instruction.rs1).* << shamt;
        },
        // SLTI
        0x2 => {
            const signed_rs1: i32 = @bitCast(c.reg(instruction.rs1).*);
            const signed_imm: i32 = @as(i32, @as(i12, @bitCast(instruction.imm)));
            c.reg(instruction.rd).* = if (signed_rs1 < signed_imm) 1 else 0;
        },
        // SLTIU
        0x3 => {
            c.reg(instruction.rd).* = if (c.reg(instruction.rs1).* < sign_extend_12(instruction.imm)) 1 else 0;
        },
        // XORI
        0x4 => {
            c.reg(instruction.rd).* = c.reg(instruction.rs1).* ^ sign_extend_12(instruction.imm);
        },
        0x5 => {
            const funct7: u7 = @truncate(instruction.imm >> 5);
            switch (funct7) {
                // SRLI
                0x00 => {
                    const shamt: u5 = @intCast(instruction.imm & 0x1f);
                    c.reg(instruction.rd).* = c.reg(instruction.rs1).* >> shamt;
                },
                // SRAI
                0x20 => {
                    const shamt: u5 = @intCast(instruction.imm & 0x1f);
                    const signed: i32 = @bitCast(c.reg(instruction.rs1).*);
                    c.reg(instruction.rd).* = @bitCast(signed >> shamt);
                },
                else => unreachable,
            }
        },
        // ORI
        0x6 => {
            c.reg(instruction.rd).* = c.reg(instruction.rs1).* | sign_extend_12(instruction.imm);
        },
        // ANDI
        0x7 => {
            c.reg(instruction.rd).* = c.reg(instruction.rs1).* & sign_extend_12(instruction.imm);
        },
    }
}

pub fn execute_i_load(c: *cpu.cpu, m: *memory.memory, raw: u32) void {
    const instruction = decoder.decode_i(raw);
    const addr = c.reg(instruction.rs1).* +% sign_extend_12(instruction.imm);

    switch (instruction.funct3) {
        // LB
        0x0 => {
            const val: i8 = @bitCast(m.read8(addr));
            c.reg(instruction.rd).* = @bitCast(@as(i32, val));
        },
        // LH
        0x1 => {
            const val: i16 = @bitCast(m.read16(addr));
            c.reg(instruction.rd).* = @bitCast(@as(i32, val));
        },
        // LW
        0x2 => {
            c.reg(instruction.rd).* = m.read32(addr);
        },
        // LBU
        0x4 => {
            c.reg(instruction.rd).* = @as(u32, m.read8(addr));
        },
        // LHU
        0x5 => {
            c.reg(instruction.rd).* = @as(u32, m.read16(addr));
        },
        else => {},
    }
}

pub fn execute_i_jalr(c: *cpu.cpu, raw: u32) void {
    const instruction = decoder.decode_i(raw);

    switch (instruction.funct3) {
        // JALR
        0x0 => {
            const ret = c.pc + 4;
            c.pc = (c.reg(instruction.rs1).* +% sign_extend_12(instruction.imm)) & ~@as(u32, 1);
            c.reg(instruction.rd).* = ret;
        },
        else => {},
    }
}

// 今はダミー
fn execute_i_system(_: *cpu.cpu, _: u32) void {}

pub fn execute_s(c: *cpu.cpu, m: *memory.memory, raw: u32) void {
    const instruction = decoder.decode_s(raw);
    const addr = c.reg(instruction.rs1).* +% sign_extend_12(instruction.imm);

    switch (instruction.funct3) {
        // SB
        0x0 => {
            m.write8(addr, @truncate(c.reg(instruction.rs2).*));
        },
        // SH
        0x1 => {
            m.write16(addr, @truncate(c.reg(instruction.rs2).*));
        },
        // SW
        0x2 => {
            m.write32(addr, c.reg(instruction.rs2).*);
        },
        else => {},
    }
}

pub fn execute_b(c: *cpu.cpu, raw: u32) void {
    const instruction = decoder.decode_b(raw);
    const target = c.pc +% sign_extend_13(instruction.imm);

    switch (instruction.funct3) {
        // BEQ
        0x0 => {
            if (c.reg(instruction.rs1).* == c.reg(instruction.rs2).*) {
                c.pc = target;
            }
        },
        // BNE
        0x1 => {
            if (c.reg(instruction.rs1).* != c.reg(instruction.rs2).*) {
                c.pc = target;
            }
        },
        // BLT
        0x4 => {
            const signed_rs1: i32 = @bitCast(c.reg(instruction.rs1).*);
            const signed_rs2: i32 = @bitCast(c.reg(instruction.rs2).*);
            if (signed_rs1 < signed_rs2) {
                c.pc = target;
            }
        },
        // BGE
        0x5 => {
            const signed_rs1: i32 = @bitCast(c.reg(instruction.rs1).*);
            const signed_rs2: i32 = @bitCast(c.reg(instruction.rs2).*);
            if (signed_rs1 >= signed_rs2) {
                c.pc = target;
            }
        },
        // BLTU
        0x6 => {
            if (c.reg(instruction.rs1).* < c.reg(instruction.rs2).*) {
                c.pc = target;
            }
        },
        // BGEU
        0x7 => {
            if (c.reg(instruction.rs1).* >= c.reg(instruction.rs2).*) {
                c.pc = target;
            }
        },
        else => {},
    }
}

pub fn execute_u_lui(c: *cpu.cpu, raw: u32) void {
    const instruction = decoder.decode_u(raw);
    c.reg(instruction.rd).* = @as(u32, instruction.imm) << 12;
}

pub fn execute_u_auipc(c: *cpu.cpu, raw: u32) void {
    const instruction = decoder.decode_u(raw);
    c.reg(instruction.rd).* = c.pc +% (@as(u32, instruction.imm) << 12);
}

pub fn execute_j(c: *cpu.cpu, raw: u32) void {
    const instruction = decoder.decode_j(raw);
    c.reg(instruction.rd).* = c.pc + 4;
    c.pc = c.pc +% sign_extend_21(instruction.imm);
}

pub fn execute(c: *cpu.cpu, m: *memory.memory, raw: u32) void {
    const opcode: u7 = @truncate(raw);
    switch (opcode) {
        0b0110011 => execute_r(c, raw),
        0b0010011 => execute_i_alu(c, raw),
        0b0000011 => execute_i_load(c, m, raw),
        0b1100111 => execute_i_jalr(c, raw),
        0b1110011 => execute_i_system(c, raw),
        0b0100011 => execute_s(c, m, raw),
        0b1100011 => execute_b(c, raw),
        0b0110111 => execute_u_lui(c, raw),
        0b0010111 => execute_u_auipc(c, raw),
        0b1101111 => execute_j(c, raw),
        else => @panic("unknown opcode"),
    }
}
