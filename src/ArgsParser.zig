//! argument parser

const USAGE: []const u8 =
    \\Delti Usage:
    \\    build -- build a project     
    \\    build run -- build and run
    \\    help -- Shows this menu
;

const Self = @This();

fpath: []const u8,

/// Parses arguments given to the program
pub fn parse() !Self {
    const args = std.os.argv;
    const argc = args.len;

    if (argc != 2) {
        std.debug.print("No filename given..\n", .{});
        return error.NotEnoughFlags;
    }

    const firstArg: []const u8 = std.mem.span(args[1]);

    if (utils.eqlString("help", firstArg)) {
        std.debug.print(USAGE, .{});
        return error.ThisIsNotAnError;
    }

    const fpath: []const u8 = std.mem.span(args[1]);

    const extension = futils.getFileExtension(fpath);

    if (extension) |e| {
        if (utils.eqlString(e, ".dlt")) {
            std.debug.print("Extension {s}\n\n", .{e});
            return Self{ .fpath = fpath };
        } else {
            std.debug.print("Not a valid extension...\n", .{});
            return error.InvalidExtension;
        }
    } else {
        std.debug.print("No extension found ...\n", .{});
        return error.NoExtensionFound;
    }
}

const std = @import("std");
const futils = @import("fileutils.zig");
const utils = @import("utils.zig");
