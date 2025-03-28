/// Tokenize input from a string
pub fn tokenize(
    allocator: std.mem.Allocator,
    input: []const u8,
) error{OutOfMemory}![]Token {
    var tokens = std.ArrayList(Token).init(allocator);
    var i: usize = 0;
    const n = input.len;

    // Tokenizer using labeled switch
    sw: switch (input[i]) {
        'a'...'z', 'A'...'Z' => {
            const start: usize = i;
            while (input[i] >= 'a' and input[i] <= 'z' and input[i] >= 'A' and input[i] <= 'Z' and isWithin(i, n)) {
                i += 1;
                if (atEnd(i, n)) break :sw;
            }
            try tokens.append(Token.new(.String, input[start..i], start, i));
            continue :sw input[i];
        },
        '0'...'9' => {
            const start: usize = i;
            while (input[i] >= '0' and input[i] <= '9' and isWithin(i, n)) {
                i += 1;
                if (atEnd(i, n)) break :sw;
            }
            try tokens.append(Token.new(.Number, input[start..i], start, i));
            continue :sw input[i];
        },
        '<' => {
            try tokens.append(Token.new(.LTAG, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        '>' => {
            try tokens.append(Token.new(.RTAG, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        '(' => {
            try tokens.append(Token.new(.LPAR, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        ')' => {
            try tokens.append(Token.new(.RPAR, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        '[' => {
            try tokens.append(Token.new(.LBRACK, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        ']' => {
            try tokens.append(Token.new(.RBRACK, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        '{' => {
            try tokens.append(Token.new(.LBRACE, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        '}' => {
            try tokens.append(Token.new(.RBRACE, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        ',' => {
            try tokens.append(Token.new(.COMMA, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        '.' => {
            try tokens.append(Token.new(.DOT, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        ':' => {
            if (peek(input, i) == ':') {
                try tokens.append(Token.new(.COLON_COLON, input[i .. i + 2], i, i + 2));
                i += 2;
                if (atEnd(i, n)) break :sw;
                continue :sw input[i];
            } else {
                try tokens.append(Token.new(.COLON, input[i .. i + 1], i, i + 1));
                i += 1;
                if (atEnd(i, n)) break :sw;
                continue :sw input[i];
            }
        },
        '+' => {
            try tokens.append(Token.new(.Plus, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        '-' => {
            try tokens.append(Token.new(.Minus, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        '*' => {
            try tokens.append(Token.new(.Multiply, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        '/' => {
            // Comment is started by //
            if (peek(input, i) == '/') {
                while (isWithin(i, n) and input[i] != '\n') {
                    i += 1;
                    if (atEnd(i, n)) break :sw;
                }
                continue :sw input[i];
            } else {
                // Simple divide
                try tokens.append(Token.new(.Divide, input[i .. i + 1], i, i + 1));
                i += 1;
                if (atEnd(i, n)) break :sw;
                continue :sw input[i];
            }
        },
        ' ', '\n', '\t' => {
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        ';' => {
            try tokens.append(Token.new(.SEMI_COLON, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        '\"' => {
            try tokens.append(Token.new(.DOUBLE_QUOTE, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        '\'' => {
            try tokens.append(Token.new(.QUOTE, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
        else => {
            try tokens.append(Token.new(.Invalid, input[i .. i + 1], i, i + 1));
            i += 1;
            if (atEnd(i, n)) break :sw;
            continue :sw input[i];
        },
    }
    // try tokens.append(Token.new(.EOF, "EOF", i, i + 1));
    return tokens.toOwnedSlice();
}

/// Checks if we're not at the end of the file
inline fn isWithin(curr: usize, stop: usize) bool {
    return curr < stop;
}

/// Checks if we're at the end of the file
inline fn atEnd(curr: usize, stop: usize) bool {
    return curr == stop;
}

/// Peeks one char in advance
inline fn peek(inp: []const u8, idx: usize) u8 {
    return inp[idx + 1];
}

/// Not used yet Peeks n chars in advance
/// Can fail if idx + n > inp.len!!
inline fn peekn(inp: []const u8, idx: usize, n: usize) ![]const u8 {
    if (idx + n > inp.len) return error.OutOfBounds;
    return inp[idx .. idx + n];
}

// TODO:
fn lexString() void {}
fn lexNumber() void {}

// ================================
// IMPORTS
// ================================
const std = @import("std");
const testing = std.testing;
const t = @import("token.zig");
const TokenType = t.TokenType;
const Token = t.Token;
// ================================

test "Tokenize" {
    const allocator = std.testing.allocator;
    const input = "88 + 921234 - 5 * 2 / 2 ";
    const tokens = try tokenize(allocator, input);
    defer allocator.free(tokens);

    for (tokens) |token| {
        std.debug.print("{}\n", .{token});
    }

    try testing.expectEqual(tokens[0].tt, TokenType.Number);
    try testing.expectEqual(tokens[1].tt, TokenType.Plus);
    try testing.expectEqual(tokens[2].tt, TokenType.Number);
    try testing.expectEqual(tokens[3].tt, TokenType.Minus);
    try testing.expectEqual(tokens[4].tt, TokenType.Number);
    try testing.expectEqual(tokens[5].tt, TokenType.Multiply);
    try testing.expectEqual(tokens[6].tt, TokenType.Number);
    try testing.expectEqual(tokens[7].tt, TokenType.Divide);
    try testing.expectEqual(tokens[8].tt, TokenType.Number);
}

test "bracks" {
    const allocator = std.testing.allocator;
    const input = "( { [ : ; :: ] } )";
    const tokens = try tokenize(allocator, input);
    defer allocator.free(tokens);

    for (tokens) |token| std.debug.print("{}\n", .{token});
}

test "strings" {
    std.debug.print("STRINGS\n", .{});
    const allocator = std.testing.allocator;
    const input = " :: { } ";
    const tokens = try tokenize(allocator, input);
    defer allocator.free(tokens);

    for (tokens) |token| std.debug.print("{}\n", .{token});
}
