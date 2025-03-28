pub fn main() !void {
    const args = std.os.argv;
    const argc = args.len;

    // TODO: Parse args properly
    if (argc != 2) {
        std.debug.print("No filename given..\n", .{});
        return;
    }

    const fpath: []const u8 = std.mem.span(args[1]);
    std.debug.print("Filepath{s}\n", .{fpath});

    const extension = futils.getFileExtension(fpath);

    if (extension) |e| {
        if (utils.eqlString(e, ".dlt")) {
            std.debug.print("Extension {s}\n\n", .{e});
        } else {
            std.debug.print("Not a valid extension...\n", .{});
            return;
        }
    } else {
        std.debug.print("No extension found ...\n", .{});
        return;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    // const inp = try futils.readFile(fpath, &allocator);
    //defer allocator.free(inp);
    var timer = try std.time.Timer.start();

    var lexer: Lexer = try .init(fpath, allocator);
    defer lexer.deinit();

    const tokens = try lexer.tokenize(allocator);
    defer allocator.free(tokens);

    const elapsed_ns = timer.read();
    const elapsed_ms = utils.nsToMs(elapsed_ns);

    std.debug.print("Number of tokens: {}\n", .{tokens.len});
    std.debug.print("Tokenize took {d:.2} ms\n", .{elapsed_ms});

    // for (tokens) |token| std.debug.print("{}\n", .{token});
}

const std = @import("std");
const testing = std.testing;
const lex = @import("lexer.zig");
const Lexer = lex.Lexer;
const TokenType = @import("token.zig").TokenType;
const futils = @import("fileutils.zig");
const utils = @import("utils.zig");

test {
    testing.refAllDecls(@This());
}
