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

pub fn main() !void {
    for (0..64) |i| {
        try draw.printBitboard(magicalBits.getBishopAttacks(@intCast(i), @as(u64, 1) << @intCast(i)));
    }
    // try engine.mainLoop();
}
