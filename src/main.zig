const std = @import("std");
const cpu = @import("cpu.zig");
const memory = @import("memory.zig");
const executor = @import("executor.zig");
const assembler = @import("assembler.zig");

pub fn main() !void {
    var c = cpu.cpu.init();
    var m = memory.memory.init();

    const lines = [_][]const u8{
        "addi 1 0 0",
        "addi 2 0 1",
        "addi 3 0 10",
        "add 4 1 2", //
        "addi 1 2 0",
        "addi 2 4 0",
        "addi 3 3 -1",
        "bne 3 0 -16",
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
