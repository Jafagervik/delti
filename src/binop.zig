/// Pemdas for the win baby
pub const BinopPrecedence = enum(u16) {
    LessThan = 10, // <
    GreaterThan = 10, // >
    Plus = 20, // +
    Minus = 20, // -
    Divide = 30, // /
    Multiply = 40, // * - highest

    // Optional: you might want a default value for unknown operators
    Unknown = 0,

    const default: BinopPrecedence = .Unknown;

    pub fn fromSymbol(symbol: u8) BinopPrecedence {
        return switch (symbol) {
            '<' => .LessThan,
            '>' => .GreaterThan,
            '+' => .Plus,
            '-' => .Minus,
            '/' => .Divide,
            '*' => .Multiply,
            else => .Unknown,
        };
    }

    // Optional: if you need to get the precedence value
    pub inline fn getValue(self: BinopPrecedence) u16 {
        return @intFromEnum(self);
    }
};
