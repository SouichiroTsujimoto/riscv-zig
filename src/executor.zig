const cpu = @import("cpu.zig");
const decorder = @import("decorder.zig");

fn execute_r(c: *cpu, raw: u32) void {
    const instruction = decorder.decode_r(raw);

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
            }
        },
        // SLL
        0x1 => {
            c.reg(instruction.rd).* = c.reg(instruction.rs1).* << c.reg(instruction.rs2).*;
        },
        // SLT
        0x2 => {},
        // SLTU
        0x3 => {},
        // XOR
        0x4 => {},
        0x5 => {
            switch (instruction.funct7) {
                // SRL
                0x00 => {},
                // SRA
                0x20 => {},
            }
        },
        // OR
        0x6 => {},
        // AND
        0x7 => {},
    }
}

fn execute_i_alu(c: *cpu, raw: u32) void {
    const instruction = decorder.decode_i(raw);

    switch (instruction.funct3) {
        0x0 => {},
        0x1 => {},
        0x2 => {},
        0x3 => {},
        0x4 => {},
        0x5 => {},
        0x6 => {},
        0x7 => {},
    }
}

fn execute_i_load(c: *cpu, raw: u32) void {
    const instruction = decorder.decode_i(raw);

    switch (instruction.funct3) {
        0x0 => {},
        0x1 => {},
        0x2 => {},
        0x4 => {},
        0x5 => {},
    }
}

fn execute_i_jalr(c: *cpu, raw: u32) void {
    const instruction = decorder.decode_i(raw);

    switch (instruction.funct3) {
        0x0 => {},
    }
}

fn execute_i_system(c: *cpu, raw: u32) void {
    const instruction = decorder.decode_i(raw);

    switch (instruction.imm) {
        0x0 => {},
        0x1 => {},
    }
}

// 今はダミー
fn execute_i_fence(_: *cpu, _: u32) void {
    // const instruction = decorder.decode_i(raw);

    return void;
}

fn execute_s(c: *cpu, raw: u32) void {
    const instruction = decorder.decode_s(raw);
}

fn execute_b(c: *cpu, raw: u32) void {
    const instruction = decorder.decode_b(raw);
}

fn execute_u(c: *cpu, raw: u32) void {
    const instruction = decorder.decode_u(raw);
}

fn execute(c: *cpu, raw: u32) void {
    const opcode = @as(u7, raw & 0b1111111);
    switch (opcode) {
        0b0110011 => return execute_r(raw),
        0b0010011 => return execute_i_alu(raw),
        0b0000011 => return execute_i_load(raw),
        0b1100111 => return execute_i_jalr(raw),
        0b1110011 => return execute_i_system(raw),
        0b0001111 => return execute_i_fence(raw),
        0b0100011 => return execute_s(raw),
        0b1100011 => return execute_b(raw),
        0b0110111 => return execute_u_lui(raw),
        0b0010111 => return execute_u_auipc(raw),
        0b1101111 => return execute_j(raw),
        else => @panic("unknown opcode"),
    }
}
