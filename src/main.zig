const std = @import("std");
const cpu = @import("cpu.zig");
const memory = @import("memory.zig");
const executor = @import("executor.zig");
const assembler = @import("assembler.zig");

pub fn main() !void {
    var c = cpu.cpu.init();
    var m = memory.memory.init();

    // 0b000000000011_00000_000_00001_0010011, // addi x1, x0, 3
    // 0b000000000100_00000_000_00010_0010011, // addi x3, x0, 4
    // 0b0000000_00010_00001_000_01010_0110011, // add x10, x1, x2

    const lines = [_][]const u8{
        "addi 1 0 3",
        "addi 2 0 4",
        "add 10 1 2",
    };

    for (lines) |line| {
        const instruction = assembler.assemble(line);
        std.debug.print("instruction: 0x{x}\n", .{instruction});
        executor.execute(&c, &m, instruction);
    }

    c.show();
}
