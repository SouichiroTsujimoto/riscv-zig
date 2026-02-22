const decorder = @import("decorder.zig");

fn execute_r(instruction: decorder.r_type) void {
    switch (instruction.funct3) {
        0x0 => {},
        0x1 => {},
        0x2 => {},
        0x3 => {},
    }
}

fn execute(raw: u32) void {
    const instruction = decorder.decode(raw);
    switch (instruction) {
        .r => execute_r(instruction.r),
    }
}
