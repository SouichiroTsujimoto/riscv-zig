var ram: [2 * 1024 * 1024]u8 = undefined; // 2MB

pub const memory = struct {
    memory: [1024]u8,

    pub fn init() memory {
        return memory{ .memory = undefined };
    }

    pub fn read8(self: *const memory, addr: u32) u8 {
        return self.memory[@as(usize, addr)];
    }

    pub fn read16(self: *const memory, addr: u32) u16 {
        return @as(u16, self.read8(addr)) | (@as(u16, self.read8(addr + 1)) << 8);
    }

    pub fn read32(self: *const memory, addr: u32) u32 {
        return @as(u32, self.read8(addr)) | (@as(u32, self.read8(addr + 1)) << 8) | (@as(u32, self.read8(addr + 2)) << 16) | (@as(u32, self.read8(addr + 3)) << 24);
    }

    pub fn write8(self: *memory, addr: u32, value: u8) void {
        self.memory[@as(usize, addr)] = value;
    }

    pub fn write16(self: *memory, addr: u32, value: u16) void {
        self.write8(addr, @truncate(value));
        self.write8(addr + 1, @truncate(value >> 8));
    }

    pub fn write32(self: *memory, addr: u32, value: u32) void {
        self.write8(addr, @truncate(value));
        self.write8(addr + 1, @truncate(value >> 8));
        self.write8(addr + 2, @truncate(value >> 16));
        self.write8(addr + 3, @truncate(value >> 24));
    }
};
