////////////////////////////////////////////////
///  ______           ___ _
/// / _  (_) __ _    / __\ |__   ___  ___ ___
/// \// /| |/ _` |  / /  | '_ \ / _ \/ __/ __|
///  / //\ | (_| | / /___| | | |  __/\__ \__ \
/// /____/_|\__, | \____/|_| |_|\___||___/___/
///         |___/
////////////////////////////////////////////////
/// @brief King movement
////////////////////////////////////////////////

const defines = @import("../tools/defines.zig");

////////////////////////////////////////////////
/// @brief Gets all king attacks given a
///        BoardState
///
/// @param [in] BoardState
/// @return king attacks
////////////////////////////////////////////////
pub fn getKingAttacks(bs: defines.BoardState) u64 {
    var attacks: u64 = kingAttackTable[bs.kings[@intFromBool(bs.whiteTurn == 0)]] & ~bs.attacks;

    const CastlingFlags = defines.BoardState.CastlingFlags;
    if (bs.whiteTurn == 1) {
        if (bs.castlingRights & CastlingFlags.W_KING_CASTLE_FLAG != 0 and !(CastlingSquares.W_KING_SIDE & bs.teamBoards[0] != 0) and !(CastlingSquares.W_KING_SIDE & bs.attacks != 0)) {
            attacks |= 1 << 6;
        }
        if (bs.castlingRights & CastlingFlags.W_QUEEN_CASTLE_FLAG != 0 and !(CastlingSquares.W_QUEEN_SIDE_VACANT & bs.teamBoards[0] != 0) and !(CastlingSquares.W_QUEEN_SIDE & bs.attacks != 0)) {
            attacks |= 1 << 2;
        }
    } else {
        if (bs.castlingRights & CastlingFlags.B_KING_CASTLE_FLAG != 0 and !(CastlingSquares.B_KING_SIDE & bs.teamBoards[0] != 0) and !(CastlingSquares.B_KING_SIDE & bs.attacks != 0)) {
            attacks |= 1 << 62;
        }
        if (bs.castlingRights & CastlingFlags.B_QUEEN_CASTLE_FLAG != 0 and !(CastlingSquares.B_QUEEN_SIDE_VACANT & bs.teamBoards[0] != 0) and !(CastlingSquares.B_QUEEN_SIDE & bs.attacks != 0)) {
            attacks |= 1 << 58;
        }
    }

    return attacks;
}

////////////////////////////////////////////////
// @brief Masks for checking validity of castling
////////////////////////////////////////////////
const CastlingSquares = enum {
    // Mask for attack and vacant squares
    const W_KING_SIDE: u64 = 1 << 5 | 1 << 6;
    const B_KING_SIDE: u64 = 1 << 61 | 1 << 62;

    // Mask for vacant squares
    const W_QUEEN_SIDE_VACANT: u64 = 1 << 1 | 1 << 2 | 1 << 3;
    const B_QUEEN_SIDE_VACANT: u64 = 1 << 57 | 1 << 58 | 1 << 59;

    // Mask for attack squares
    const W_QUEEN_SIDE: u64 = 1 << 2 | 1 << 3;
    const B_QUEEN_SIDE: u64 = 1 << 58 | 1 << 59;
};

const kingAttackTable: [64]u64 = initAttacks();

fn initAttacks() [64]u64 {
    var table: [64]u64 = undefined;
    for (0..64) |i| {
        const king = 1 << i;

        var attack = (king >> 1) & ~(defines.files[7]); // One step left
        attack |= (king >> 9) & ~(defines.files[7] | defines.ranks[7]); // Diagonal left up
        attack |= (king >> 8) & ~(defines.ranks[7]); // One step up
        attack |= (king >> 7) & ~(defines.files[0] | defines.ranks[7]); // Diagonal right up

        if (i != 63) {
            attack |= (king << 1) & ~(defines.files[0]); // One step right
        }
        if (i < 63 - 8) {
            attack |= (king << 7) & ~(defines.files[7] | defines.ranks[0]); // Diagonal left down
            attack |= (king << 8) & ~(defines.ranks[0]); // One step down
            attack |= (king << 9) & ~(defines.files[0] | defines.ranks[0]); // Diagonal right down
        }
        table[i] = attack;
    }
    return table;
}
