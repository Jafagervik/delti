pub fn main() !void {
    // Get some args for us
    const args = ArgsParser.parse() catch |err| {
        std.debug.print("Error parsing cli flags: {any}\n", .{err});
        return err;
    };

    // Init new gpa
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var timer = try std.time.Timer.start();

    // Lexer
    var lexer: Lexer = try .init(args.fpath, &allocator);
    defer lexer.deinit();

    // Get them tokens
    const tokens = try lexer.tokenize(&allocator);
    defer allocator.free(tokens);

    const elapsed_ns = timer.read();
    const elapsed_ms = utils.nsToMs(elapsed_ns);

    std.debug.print("Number of tokens: {}\n", .{tokens.len});
    std.debug.print("Tokenize took {d:.2} ms\n", .{elapsed_ms});

    for (tokens, 0..) |token, i| {
        if (i > 10) break;
        std.debug.print("{}\n", .{token});
    }
}

const std = @import("std");
const testing = std.testing;

const utils = @import("utils.zig");

const Lexer = @import("lexer.zig").Lexer;
const TokenType = @import("token.zig").TokenType;
const ArgsParser = @import("ArgsParser.zig");

test {
    testing.refAllDecls(@This());
}

// const inp = try futils.readFile(fpath, &allocator);
// defer allocator.free(inp);
