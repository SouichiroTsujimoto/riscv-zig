const std = @import("std");

pub const cpu = struct {
    x: [32]u32,
    pc: u32,

    pub fn init() cpu {
        return cpu{
            .x = .{0} ** 32,
            .pc = 0,
        };
    }

    pub fn reset(self: *cpu) void {
        self.x = .{0} ** 32;
        self.pc = 0;
    }

    pub fn reg(self: *cpu, index: u5) *u32 {
        return &self.x[@as(usize, index)];
    }

    pub fn show(self: *cpu) void {
        for (self.x, 0..) |r, i| {
            std.debug.print("{d}: 0x{x}\n", .{ i, r });
        }
        std.debug.print("pc: 0x{x}\n", .{self.pc});
    }
};
