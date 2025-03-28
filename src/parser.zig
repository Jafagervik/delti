//! parser lezzz go

const Expr = union(enum) {
    number: i32,
    ident: []const u8,
    binary_op: struct {
        left: *Expr,
        op: []const u8,
        right: *Expr,
    },
    call: struct {
        name: []const u8,
        args: []Expr,
    },

    // Optional method to print debug representation
    pub fn format(
        self: @This(),
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        switch (self.*) {
            .number => |n| try writer.print("Number({})", .{n}),
            .ident => |id| try writer.print("Ident({})", .{id}),
            .binary_op => |op| try writer.print("BinaryOp({s} {} {})", .{ op.op, op.left.*, op.right.* }),
            .call => |call| {
                try writer.print("Call({s}(", .{call.name});
                for (call.args, 0..) |arg, i| {
                    if (i > 0) try writer.print(", ", .{});
                    _ = arg;
                    //arg.debugPrint();
                }
                try writer.print("))", .{});
            },
        }
    }
};

pub const Param = struct {
    name: []const u8,
    typ: []const u8,
};

pub const Function = struct {
    functions: ?i32,
};

pub const Stmt = struct {
    functions: ?i32,
};

pub const Program = struct {
    functions: ?i32,
};

pub const Parser = struct {
    tokens: []Token,
    pos: usize,
    n: usize,

    const Self = @This();

    pub fn init(tokens: []Token) Self {
        return .{ .tokens = tokens, .pos = 0, .n = tokens.len };
    }

    /// Peeks at the next token
    fn peek(self: Self) ?Token {
        return if (self.pos > self.n - 1) null else self.tokens[self.pos];
    }

    /// Advances pos and yields a token
    fn advance(_: []Token) void {
        return;
    }

    /// Parses the entire program and returns an AST
    pub fn parse(self: Self) AST(Token) {
        _ = self;
        return;
    }
};

const std = @import("std");
const t = @import("token.zig");
const Token = t.Token;
const AST = @import("ast.zig").AST;
const testing = std.testing;
