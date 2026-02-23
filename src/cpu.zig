const register = u32;

const cpu = struct {
    x: [32]register,
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

    pub fn reg(self: *cpu, index: u5) *register {
        return &self.x[@as(usize, index)];
    }
};
