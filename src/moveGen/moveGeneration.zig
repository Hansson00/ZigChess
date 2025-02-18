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
const king = @import("king.zig");
const magicalBitboards = @import("magicalBitboards.zig");
const pawn = @import("pawn.zig");
const knight = @import("knight.zig");

fn getMoves(
    bs: defines.BoardState,
    ml: *defines.MoveList,
) void {
    const PieceIndex = defines.BoardState.PieceIndex;
    const pieceOffset = if (bs.whiteTurn == 1) 0 else PieceIndex.PIECE_OFFSET;

    ////////////////////////////////////////////////
    // Quiet moves
    ////////////////////////////////////////////////

    pawn.getQuiet(bs, ml);
    {
        var bb = bs.pieceBoards[PieceIndex.PAWN + pieceOffset];
        while (bb) {
            const index = @ctz(bb);
            knight.moveGenerator(bs, ml, defines.MoveModifiers.QUIET_MOVE, index);
            bb &= bb - 1;
        }
    }
    {
        var bb = bs.pieceBoards[PieceIndex.QUEEN + pieceOffset] | bs.pieceBoards[PieceIndex.ROOK + pieceOffset];
        while (bb) {
            const index = @ctz(bb);
            magicalBitboards.legalRookMoveGenerator(bs, ml, defines.MoveModifiers.QUIET_MOVE, index);
            bb &= bb - 1;
        }
    }
    {
        var bb = bs.pieceBoards[PieceIndex.QUEEN + pieceOffset] | bs.pieceBoards[PieceIndex.BISHOP + pieceOffset];
        while (bb) {
            const index = @ctz(bb);
            magicalBitboards.legalBishopMoveGenerator(bs, ml, defines.MoveModifiers.QUIET_MOVE, index);
            bb &= bb - 1;
        }
    }

    ////////////////////////////////////////////////
    // Attacking moves
    ////////////////////////////////////////////////

    {
        var bb = bs.pieceBoards[PieceIndex.PAWN + pieceOffset];
        while (bb) {
            const index = @ctz(bb);
            knight.moveGenerator(bs, ml, defines.MoveModifiers.CAPTURE, index);
            bb &= bb - 1;
        }
    }
    {
        var bb = bs.pieceBoards[PieceIndex.QUEEN + pieceOffset] | bs.pieceBoards[PieceIndex.ROOK + pieceOffset];
        while (bb) {
            const index = @ctz(bb);
            magicalBitboards.legalRookMoveGenerator(bs, ml, defines.MoveModifiers.CAPTURE, index);
            bb &= bb - 1;
        }
    }
    {
        var bb = bs.pieceBoards[PieceIndex.QUEEN + pieceOffset] | bs.pieceBoards[PieceIndex.BISHOP + pieceOffset];
        while (bb) {
            const index = @ctz(bb);
            magicalBitboards.legalBishopMoveGenerator(bs, ml, defines.MoveModifiers.CAPTURE, index);
            bb &= bb - 1;
        }
    }

    pawn.getAttacks(bs, ml);
}
