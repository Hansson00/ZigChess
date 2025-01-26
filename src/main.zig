const std = @import("std");
const defines = @import("tools/defines.zig");
const draw = @import("tools/draw.zig");
const fenString = @import("tools/fen.zig");

pub fn main() !void {
    var bs = defines.BoardState.init();
    fenString.setFen(&bs, "rnbqkbnr/ppppppp1/7p/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
    try draw.printBoard(&bs);
}
