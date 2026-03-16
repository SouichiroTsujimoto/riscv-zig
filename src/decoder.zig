const r_type = struct {
    opcode: u7,
    rd: u5,
    funct3: u3,
    rs1: u5,
    rs2: u5,
    funct7: u7,
};

pub fn decode_r(raw: u32) r_type {
    return r_type{
        .opcode = @truncate(raw),
        .rd = @truncate(raw >> 7),
        .funct3 = @truncate(raw >> 12),
        .rs1 = @truncate(raw >> 15),
        .rs2 = @truncate(raw >> 20),
        .funct7 = @truncate(raw >> 25),
    };
}

pub const i_type = struct {
    opcode: u7,
    rd: u5,
    funct3: u3,
    rs1: u5,
    imm: u12,
};

pub fn decode_i(raw: u32) i_type {
    return i_type{
        .opcode = @truncate(raw),
        .rd = @truncate(raw >> 7),
        .funct3 = @truncate(raw >> 12),
        .rs1 = @truncate(raw >> 15),
        .imm = @truncate(raw >> 20),
    };
}

pub const s_type = struct {
    opcode: u7,
    funct3: u3,
    rs1: u5,
    rs2: u5,
    imm: u12,
};

pub fn decode_s(raw: u32) s_type {
    const imm_a: u5 = @truncate(raw >> 7);
    const imm_b: u7 = @truncate(raw >> 25);

    return s_type{
        .opcode = @truncate(raw),
        .funct3 = @truncate(raw >> 12),
        .rs1 = @truncate(raw >> 15),
        .rs2 = @truncate(raw >> 20),
        .imm = @as(u12, imm_a) | @as(u12, imm_b) << 5,
    };
}

pub const b_type = struct {
    opcode: u7,
    funct3: u3,
    rs1: u5,
    rs2: u5,
    imm: u13,
};

pub fn decode_b(raw: u32) b_type {
    const imm_a: u1 = 0;
    const imm_b: u4 = @truncate(raw >> 8);
    const imm_c: u6 = @truncate(raw >> 25);
    const imm_d: u1 = @truncate(raw >> 7);
    const imm_e: u1 = @truncate(raw >> 31);

    return b_type{
        .opcode = @truncate(raw),
        .funct3 = @truncate(raw >> 12),
        .rs1 = @truncate(raw >> 15),
        .rs2 = @truncate(raw >> 20),
        .imm = @as(u13, imm_a) | @as(u13, imm_b) << 1 | @as(u13, imm_c) << 5 | @as(u13, imm_d) << 11 | @as(u13, imm_e) << 12,
    };
}

pub const u_type = struct {
    opcode: u7,
    rd: u5,
    imm: u20,
};

pub fn decode_u(raw: u32) u_type {
    return u_type{
        .opcode = @truncate(raw),
        .rd = @truncate(raw >> 7),
        .imm = @truncate(raw >> 12),
    };
}

pub const j_type = struct {
    opcode: u7,
    rd: u5,
    imm: u21,
};

pub fn decode_j(raw: u32) j_type {
    const imm_a: u1 = 0;
    const imm_b: u10 = @truncate(raw >> 21);
    const imm_c: u1 = @truncate(raw >> 20);
    const imm_d: u8 = @truncate(raw >> 12);
    const imm_e: u1 = @truncate(raw >> 31);

    return j_type{
        .opcode = @truncate(raw),
        .rd = @truncate(raw >> 7),
        .imm = @as(u21, imm_a) | @as(u21, imm_b) << 1 | @as(u21, imm_c) << 11 | @as(u21, imm_d) << 12 | @as(u21, imm_e) << 20,
    };
}

pub const InstructionType = enum {
    r,
    i,
    s,
    b,
    u,
    j,
};

// const Instruction = union(InstructionType) {
//     r: r_type,
//     i: i_type,
//     s: s_type,
//     b: b_type,
//     u: u_type,
//     j: j_type,
// };
