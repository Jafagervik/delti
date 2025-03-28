/// Reads a file from path into a string buffer
pub fn readFile(file_path: []const u8, allocator: *std.mem.Allocator) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_path, .{ .mode = .read_only });
    defer file.close();
    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    _ = try file.readAll(buffer);
    return buffer;
}

/// Gets the file extension of a string
pub fn getFileExtension(file_path: []const u8) ?[]const u8 {
    if (std.mem.lastIndexOfScalar(u8, file_path, '.')) |index| {
        return file_path[index..];
    }
    return null;
}

const std = @import("std");
const u = @import("utils.zig");
const testing = std.testing;

test "fileext" {
    const e: []const u8 = getFileExtension("dir/filename.dlt").?;
    try testing.expect(u.eqlString(e, ".dlt"));
}
