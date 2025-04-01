//! Lexer data type

/// Lexer data structure
pub const Lexer = struct {
    /// Path to program
    filepath: []const u8 = "",
    /// Buffered data
    data: []const u8,
    /// Current line
    line: usize = 1,
    /// Current col
    col: usize = 0,
    /// Current position
    i: usize = 0,
    /// Length of source file
    n: usize,
    /// Allocator for this lexer
    gpa: std.mem.Allocator,

    const Self = @This();

    /// Initialize this shait
    pub fn init(filepath: []const u8, allocator: *std.mem.Allocator) !Self {
        const data: []const u8 = try fu.readFile(filepath, allocator);
        return Self{ .filepath = filepath, .data = data, .n = data.len, .gpa = allocator.* };
    }

    /// Deinits the Lexer type
    pub fn deinit(self: Self) void {
        self.gpa.free(self.data);
        // TODO: How do we free tokens?
    }

    /// Tokenize data from a string
    pub fn tokenize(
        self: *Self,
        allocator: *std.mem.Allocator,
    ) error{OutOfMemory}![]Token {
        var tokens = std.ArrayList(Token).init(allocator.*);

        // Tokenizer using labeled switch
        sw: switch (self.currChar()) {
            'a'...'z', 'A'...'Z' => {
                const start: usize = self.i;
                while (self.data[self.i] >= 'a' and self.data[self.i] <= 'z' and self.data[self.i] >= 'A' and self.data[self.i] <= 'Z' and self.isWithin()) {
                    self.advance();
                    if (self.atEnd()) break :sw;
                }
                try tokens.append(Token.new(.String, self.data[start..self.i], start, self.i));
                continue :sw self.currChar();
            },
            '0'...'9' => {
                const start: usize = self.i;
                while (self.data[self.i] >= '0' and self.data[self.i] <= '9' and self.isWithin()) {
                    self.advance();
                    if (self.atEnd()) break :sw;
                }
                try tokens.append(Token.new(.Number, self.data[start..self.i], start, self.i));
                continue :sw self.currChar();
            },
            '<' => {
                try tokens.append(Token.new(.LTAG, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            '>' => {
                try tokens.append(Token.new(.RTAG, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            '(' => {
                try tokens.append(Token.new(.LPAR, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            ')' => {
                try tokens.append(Token.new(.RPAR, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            '[' => {
                try tokens.append(Token.new(.LBRACK, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            ']' => {
                try tokens.append(Token.new(.RBRACK, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            '{' => {
                try tokens.append(Token.new(.LBRACE, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            '}' => {
                try tokens.append(Token.new(.RBRACE, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            ',' => {
                try tokens.append(Token.new(.COMMA, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            '.' => {
                try tokens.append(Token.new(.DOT, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            ':' => {
                if (self.peek() == ':') {
                    try tokens.append(Token.new(.COLON_COLON, self.data[self.i .. self.i + 2], self.i, self.i + 2));
                    self.advanceN(2);
                    if (self.atEnd()) break :sw;
                    continue :sw self.currChar();
                } else if (self.peek() == '=') {
                    try tokens.append(Token.new(.COLON_EQUAL, self.data[self.i .. self.i + 2], self.i, self.i + 2));
                    self.advanceN(2);
                    if (self.atEnd()) break :sw;
                    continue :sw self.currChar();
                } else {
                    try tokens.append(Token.new(.COLON, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                    self.advance();
                    if (self.atEnd()) break :sw;
                    continue :sw self.currChar();
                }
            },
            '+' => {
                try tokens.append(Token.new(.Plus, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            '-' => {
                try tokens.append(Token.new(.Minus, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            '*' => {
                try tokens.append(Token.new(.Multiply, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            '/' => {
                // Comment is started by //
                if (self.peek() == '/') {
                    while (self.isWithin() and self.currChar() != '\n') {
                        self.advance();
                    }
                    if (self.atEnd()) break :sw;
                    continue :sw self.currChar();
                } else {
                    // Simple divide
                    try tokens.append(Token.new(.Divide, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                    self.advance();
                    if (self.atEnd()) break :sw;
                    continue :sw self.currChar();
                }
            },
            '=' => {
                if (self.peek() == '=') {
                    try tokens.append(Token.new(.DOUBLE_EQUAL, self.data[self.i .. self.i + 2], self.i, self.i + 2));
                    self.advanceN(2);
                    if (self.atEnd()) break :sw;
                    continue :sw self.currChar();
                } else {
                    try tokens.append(Token.new(.EQUAL, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                    self.advance();
                    if (self.atEnd()) break :sw;
                    continue :sw self.currChar();
                }
            },
            ' ', '\n', '\t' => {
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            ';' => {
                try tokens.append(Token.new(.SEMI_COLON, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            '\"' => {
                try tokens.append(Token.new(.DOUBLE_QUOTE, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            '\'' => {
                try tokens.append(Token.new(.QUOTE, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
            else => {
                try tokens.append(Token.new(.Invalid, self.data[self.i .. self.i + 1], self.i, self.i + 1));
                self.advance();
                if (self.atEnd()) break :sw;
                continue :sw self.currChar();
            },
        }
        // try tokens.append(Token.new(.EOF, "EOF", i, i + 1));
        return tokens.toOwnedSlice();
    }

    /// Checks if we're not at the end of the file
    inline fn isWithin(self: *Self) bool {
        return self.i < self.n;
    }

    /// Gets the current character
    inline fn currChar(self: *Self) u8 {
        return self.data[self.i];
    }

    /// Checks if we're at the end of the file
    inline fn atEnd(self: *Self) bool {
        return self.i == self.n;
    }

    /// Peeks one char in advance
    inline fn peek(self: *Self) u8 {
        return self.data[self.i + 1];
    }

    /// Peeks n chars in advance
    inline fn peekN(self: *Self, n: usize) []const u8 {
        return self.data[self.i + n];
    }

    /// Advance cursor one position
    inline fn advance(self: *Self) void {
        self.i += 1;
    }

    /// Advance cursor n positions
    inline fn advanceN(self: *Self, n: usize) void {
        self.i += n;
    }

    // TODO: implement
    fn lexString() void {}
    fn lexNumber() void {}
};

// ================================
// IMPORTS
// ================================
const std = @import("std");
const testing = std.testing;
const fu = @import("fileutils.zig");
const t = @import("token.zig");
const TokenType = t.TokenType;
const Token = t.Token;
// ================================

test "Tokenize" {
    const allocator = std.testing.allocator;
    const data = "88 + 921234 - 5 * 2 / 2 ";
    const lexer: Lexer = .init("");
    const tokens = try lexer.tokenize(allocator, data);
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
    const data = "( { [ : ; :: ] } )";
    const lexer: Lexer = .init("");
    const tokens = try lexer.tokenize(allocator, data);
    defer allocator.free(tokens);

    for (tokens) |token| std.debug.print("{}\n", .{token});
}

test "strings" {
    std.debug.print("STRINGS\n", .{});
    const allocator = std.testing.allocator;
    const data = " :: { } ";
    const lexer: Lexer = .init("");
    const tokens = try lexer.tokenize(allocator, data);
    defer allocator.free(tokens);

    for (tokens) |token| std.debug.print("{}\n", .{token});
}
