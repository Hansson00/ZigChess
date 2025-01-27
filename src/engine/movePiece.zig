////////////////////////////////////////////////
///  ______           ___ _
/// / _  (_) __ _    / __\ |__   ___  ___ ___
/// \// /| |/ _` |  / /  | '_ \ / _ \/ __/ __|
///  / //\ | (_| | / /___| | | |  __/\__ \__ \
/// /____/_|\__, | \____/|_| |_|\___||___/___/
///         |___/
////////////////////////////////////////////////
/// @brief Handels piece movement
////////////////////////////////////////////////

const defines = @import("../tools/defines.zig");

////////////////////////////////////////////////
/// @brief Move a piece given a move.
///
/// @param [in/out] BoardState to be altered
/// @param [in] move to be executed
///
/// @note Can do illegal moves (Not the job of this function)
/// @note Currently missing:
///         - King moves
///         - EP moves
////////////////////////////////////////////////
pub fn movePiece(bs: *defines.BoardState, move: u16) void {
    const fromSquare = move & defines.MoveModifiers.FROM_MASK;
    const toSquare = (move & defines.MoveModifiers.TO_MASK) >> 4;

    const fromBitboard: u64 = @as(u64, 1) << @intCast(fromSquare);
    const toBitboard: u64 = @as(u64, 1) << @intCast(toSquare);

    // Remove from and to Square
    for (bs.pieceBoards, 0..) |board, i| {
        if (board & toBitboard & fromBitboard != 0) {
            bs.pieceBoards[i] &= ~toBitboard;
            bs.teamBoards[0] &= ~toBitboard;
            bs.teamBoards[1] &= ~toBitboard;
            bs.teamBoards[2] &= ~toBitboard;
        }
    }

    // Set toSquare
    for (bs.pieceBoards, 0..) |board, i| {
        const result = board & fromBitboard;

        if (result != 0) {
            bs.pieceBoards[i] |= toBitboard;
            bs.teamBoards[2 - bs.whiteTurn] |= toBitboard;
            break;
        }
    }
}
