const std = @import("std");
const cpu = @import("cpu.zig");
const memory = @import("memory.zig");
const executor = @import("executor.zig");

pub fn main() !void {
    var c = cpu.cpu.init();
    var m = memory.memory.init();

    const instructions = [_]u32{
        0b000000000011_00000_000_00001_1100100, // addi x1, x0, 3
        0b000000000100_00000_000_00010_1100100, // addi x3, x0, 4
        0b0000000_00010_00001_000_01010_1100110, // add x10, x1, x2
    };

    for (instructions) |instruction| {
        std.debug.print("instruction: 0x{x}\n", .{instruction});
        executor.execute(&c, &m, instruction);
    }

    c.show();
}
