const std = @import("std");
const defines = @import("tools/defines.zig");
const draw = @import("tools/draw.zig");

pub fn main() !void {
    var bs = defines.BoardState.init();
    bs.pieceBoards[0] = 2;
    try draw.printBoard(&bs);
    try draw.printBitboard(3 << 10);
}

// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }
