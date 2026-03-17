const std = @import("std");
const cpu = @import("cpu.zig");
const memory = @import("memory.zig");
const executor = @import("executor.zig");
const assembler = @import("assembler.zig");

pub fn main() !void {
    var c = cpu.cpu.init();
    var m = memory.memory.init();

    // 0b000000000011_00000_000_00001_0010011, // addi x1, x0, 3
    // 0b000000000100_00000_000_00010_0010011, // addi x2, x0, 4
    // 0b0000000_00010_00001_000_01010_0110011, // add x10, x1, x2

    const lines = [_][]const u8{
        "addi 5 0 3",
        "addi 6 0 100",
        "add 10 5 6",
        "sub 5 5 5",
        "addi 5 0 20",
        "add 10 10 5",
    };

    var instructions = std.mem.zeroes([lines.len * 4:0]u8);
    for (lines, 0..) |line, i| {
        const assembled = assembler.assemble(line);
        instructions[i * 4 + 0] = @truncate(assembled);
        instructions[i * 4 + 1] = @truncate(assembled >> 8);
        instructions[i * 4 + 2] = @truncate(assembled >> 16);
        instructions[i * 4 + 3] = @truncate(assembled >> 24);
    }

    while (c.pc < instructions.len) {
        const instruction =
            @as(u32, instructions[c.pc + 0]) |
            @as(u32, instructions[c.pc + 1]) << 8 |
            @as(u32, instructions[c.pc + 2]) << 16 |
            @as(u32, instructions[c.pc + 3]) << 24;
        std.debug.print("instruction: 0x{x}\n", .{instruction});
        executor.execute(&c, &m, instruction);
    }

    c.show();
}
