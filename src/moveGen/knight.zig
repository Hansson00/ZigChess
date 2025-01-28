////////////////////////////////////////////////
///  ______           ___ _
/// / _  (_) __ _    / __\ |__   ___  ___ ___
/// \// /| |/ _` |  / /  | '_ \ / _ \/ __/ __|
///  / //\ | (_| | / /___| | | |  __/\__ \__ \
/// /____/_|\__, | \____/|_| |_|\___||___/___/
///         |___/
////////////////////////////////////////////////
/// @brief Knight movement
////////////////////////////////////////////////

const std = @import("std");
const defines = @import("../tools/defines.zig");

////////////////////////////////////////////////
/// @brief Gets all knight attacks for a given
///        position
///
/// @param [in] position of the knight
/// @return knight attacks
////////////////////////////////////////////////
pub fn getKnightAttacks(position: u8) u64 {
    return knightMovementTable[@intCast(position)];
}

const knightMovementTable: [64]u64 = initAttacks();

fn initAttacks() [64]u64 {
    var table: [64]u64 = undefined;
    for (0..64) |i| {
        const knight: u64 = 1 << i;
        var attack: u64 = (knight >> 10) & ~(defines.files[6] | defines.files[7] | defines.ranks[7]); // Two files to left and up
        attack |= (knight << 6) & ~(defines.files[6] | defines.files[7] | defines.ranks[0]); // Two files to left and down
        attack |= (knight >> 17) & ~(defines.files[7] | defines.ranks[6] | defines.ranks[7]); // One file to left and up
        attack |= (knight << 15) & ~(defines.files[7] | defines.ranks[0] | defines.ranks[1]); // One file to left and down
        attack |= (knight >> 15) & ~(defines.files[0] | defines.ranks[6] | defines.ranks[7]); // One file to right and up
        attack |= (knight << 17) & ~(defines.files[0] | defines.ranks[0] | defines.ranks[1]); // One file to right and down
        attack |= (knight >> 6) & ~(defines.files[0] | defines.files[1] | defines.ranks[7]); // Two files to right and up
        attack |= (knight << 10) & ~(defines.files[0] | defines.files[1] | defines.ranks[0]); // Two files to right and down
        table[i] = attack;
    }
    return table;
}
