////////////////////////////////////////////////
///  ______           ___ _
/// / _  (_) __ _    / __\ |__   ___  ___ ___
/// \// /| |/ _` |  / /  | '_ \ / _ \/ __/ __|
///  / //\ | (_| | / /___| | | |  __/\__ \__ \
/// /____/_|\__, | \____/|_| |_|\___||___/___/
///         |___/
////////////////////////////////////////////////

const std = @import("std");
const draw = @import("tools/draw.zig");
const fenString = @import("tools/fen.zig");
const defines = @import("tools/defines.zig");
const engine = @import("engine/engine.zig");
const magicalBits = @import("moveGen/magicalBitboards.zig");
const king = @import("moveGen/king.zig");
const knight = @import("moveGen/knight.zig");

pub fn main() !void {
    var bs = defines.BoardState.init();
    fenString.setFen(&bs, "rq2kq1r/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1");
    try draw.printBoard(&bs);
    try draw.printBitboard(knight.getKnightAttacks(0));
}
