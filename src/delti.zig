pub fn main() !void {
    const args = ArgsParser.parse() catch |err| {
        std.debug.print("Error parsing cli flags: {any}\n", .{err});
        return err;
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    // const inp = try futils.readFile(fpath, &allocator);
    //defer allocator.free(inp);
    var timer = try std.time.Timer.start();

    var lexer: Lexer = try .init(args.fpath, allocator);
    defer lexer.deinit();

    const tokens = try lexer.tokenize(allocator);
    defer allocator.free(tokens);

    const elapsed_ns = timer.read();
    const elapsed_ms = utils.nsToMs(elapsed_ns);

    std.debug.print("Number of tokens: {}\n", .{tokens.len});
    std.debug.print("Tokenize took {d:.2} ms\n", .{elapsed_ms});

    for (tokens) |token| std.debug.print("{}\n", .{token});
}

const std = @import("std");
const testing = std.testing;
const lex = @import("lexer.zig");
const Lexer = lex.Lexer;
const TokenType = @import("token.zig").TokenType;
const futils = @import("fileutils.zig");
const utils = @import("utils.zig");
const ArgsParser = @import("ArgsParser.zig");

test {
    testing.refAllDecls(@This());
}
