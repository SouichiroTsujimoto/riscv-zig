const cpu = @import("cpu.zig");
const decorder = @import("decorder.zig");

fn execute_r(c: *cpu, instruction: decorder.r_type) void {
    switch (instruction.funct3) {
        0x0 => {
            switch (instruction.funct7) {
                0x00 => {},
                0x20 => {},
            }
        },
        0x1 => {},
        0x2 => {},
        0x3 => {},
        0x4 => {},
        0x5 => {
            switch (instruction.funct7) {
                0x00 => {},
                0x20 => {},
            }
        },
        0x6 => {},
        0x7 => {},
    }
}

fn execute_i_alu(c: *cpu, instruction: decorder.i_type) void {
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

fn execute(c: *cpu, raw: u32) void {
    const instruction = decorder.decode(raw);
    switch (instruction) {
        .r => execute_r(c, instruction.r),
        .i_alu => execute_i_alu(c, instruction.i_alu),
        .i_load => execute_i_load(c, instruction.i_load),
        .i_jalr => execute_i_jalr(c, instruction.i_jalr),
        .i_system => execute_i_system(c, instruction.i_system),
        .i_fence => execute_i_fence(c, instruction.i_fence),
    }
}
