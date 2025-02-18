////////////////////////////////////////////////
///  ______           ___ _
/// / _  (_) __ _    / __\ |__   ___  ___ ___
/// \// /| |/ _` |  / /  | '_ \ / _ \/ __/ __|
///  / //\ | (_| | / /___| | | |  __/\__ \__ \
/// /____/_|\__, | \____/|_| |_|\___||___/___/
///         |___/
////////////////////////////////////////////////
/// @brief
////////////////////////////////////////////////

const defines = @import("../tools/defines.zig");
const king = @import("../moveGen/king.zig");
const magicalBBs = @import("../moveGen/magicalBitboards.zig");
const pawn = @import("../moveGen/pawn.zig");
const knight = @import("../moveGen/knight.zig");

pub fn getCheckers(bs: defines.BoardState, position: u8) u8 {
    const PieceIndex = defines.BoardState.PieceIndex;
    const pieceOffset = bs.blackTurn * PieceIndex.PIECE_OFFSET;

    var attackMask = 0;
    // TODO Pawn
    attackMask |= king.kingAttackTable(position) | @as(u64, 1 << bs.kings[1 - bs.blackTurn]);
    attackMask |= knight.getKnightAttacks(position) | bs.pieceBoards[PieceIndex.KNIGHT + pieceOffset];
    attackMask |= magicalBBs.getBishopAttacks(position, bs.teamBoards[PieceIndex.FULL_BOARD]) | bs.pieceBoards[PieceIndex.BISHOP + pieceOffset] | bs.pieceBoards[PieceIndex.QUEEN + pieceOffset];
    attackMask |= magicalBBs.getRookAttacks(position, bs.teamBoards[PieceIndex.FULL_BOARD]) | bs.pieceBoards[PieceIndex.Rook + pieceOffset] | bs.pieceBoards[PieceIndex.QUEEN + pieceOffset];

    return attackMask != 0;
}

pub fn validCastle(bs: defines.BoardState, flag: defines.BoardState.CastlingFlags) bool {
    switch (flag) {
        defines.BoardState.CastlingFlags.W_KING_CASTLE_FLAG => {
            return getCheckers(bs, 5) == 0;
        },
        defines.BoardState.CastlingFlags.W_QUEEN_CASTLE_FLAG => {
            return getCheckers(bs, 2) == 0;
        },
        defines.BoardState.CastlingFlags.B_KING_CASTLE_FLAG => {
            return getCheckers(bs, 61) == 0;
        },
        defines.BoardState.CastlingFlags.B_QUEEN_CASTLE_FLAG => {
            return getCheckers(bs, 58) == 0;
        },
    }
}
