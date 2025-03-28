/// String equals
pub fn eqlString(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

pub inline fn nsToMs(ns: u64) f64 {
    return @as(f64, @floatFromInt(ns)) / 1_000_000.0;
}

const std = @import("std");
const testing = std.testing;

test "eqlString" {
    const a = "mama";
    const b = "mama";
    const c = "mia";

    try testing.expect(eqlString(a, b));
    try testing.expect(!eqlString(a, c));
    try testing.expect(!eqlString(b, c));
}
