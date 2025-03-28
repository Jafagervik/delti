pub const TokenType = enum {
    Number,
    String,
    Plus,
    Minus,
    Multiply,
    Divide,
    Invalid,
    LPAR,
    RPAR,
    LBRACK,
    RBRACK,
    LBRACE,
    RBRACE,
    LTAG, // <
    RTAG, // >
    COLON, // :
    COLON_COLON, // ::
    COLON_EQUAL, // :=
    EQUAL, // =
    DOUBLE_EQUAL, // ==
    SEMI_COLON, // ;
    EOF, // EOF

    COMMA, // ,
    DOT, // .

    // Keywords
    STRUCT,
    ENUM,
    RETURN,
    IF,
    ELSE,
    CONTINUE,
    BREAK,
    FOR,
    WHILE,
    AND,
    OR,
    INLINE,

    QUOTE, // '
    DOUBLE_QUOTE, // "
};

pub const Token = struct {
    tt: TokenType,
    value: []const u8,
    start: usize,
    stop: usize,

    const Self = @This();

    /// Creates a new token
    pub fn new(
        tt: TokenType,
        value: []const u8,
        start: usize,
        stop: usize,
    ) Token {
        return Token{ .tt = tt, .value = value, .start = start, .stop = stop };
    }

    pub fn format(
        self: Self,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.print(
            "{} - Value {s} at {d}:{d}",
            .{ self.tt, self.value, self.start, self.stop },
        );
    }
};

const std = @import("std");
