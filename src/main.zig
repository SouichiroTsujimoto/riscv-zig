const std = @import("std");
const cpu = @import("cpu.zig");
const memory = @import("memory.zig");
const executor = @import("executor.zig");
const assembler = @import("assembler.zig");

pub fn main() !void {
    var c = cpu.cpu.init();
    var m = memory.memory.init();

    // JAL を使ったサブルーチン呼び出しの例
    // サブルーチン: x10 = x1 + x2
    //
    // pc= 0: addi 1 0 5       x1 = 5
    // pc= 4: addi 2 0 3       x2 = 3
    // pc= 8: jal 3 12         x3 = 12 (戻りアドレス), pc = 20 へジャンプ
    // pc=12: addi 11 10 0     [戻り後] x11 = x10
    // pc=16: jal 0 12         pc = 28 (プログラム終了)
    // pc=20: add 10 1 2       [sub] x10 = x1 + x2 = 8
    // pc=24: jalr 0 3 0       pc = x3 = 12 (return)
    const lines = [_][]const u8{
        "addi 1 0 5",
        "addi 2 0 3",
        "jal 3 12",
        "addi 11 10 0",
        "jal 0 12",
        "add 10 1 2",
        "jalr 0 3 0",
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
