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

pub fn main() !void {
    // try draw.printBoard(&engine.boardstate);
    try engine.mainLoop();
}
