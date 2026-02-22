const cpu = struct {
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
};
