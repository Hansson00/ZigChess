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

// Dont forget Team boards
fn makeMove(move: u16, bs: *defines.BoardState) void {
    const moveMods = move & defines.MoveModifiers.SPECIAL_MOVE_MASK;

    const startSquare = move & defines.MoveModifiers.FROM_MASK;
    const startSquareBB: u64 = 1 << startSquare;

    const toSquare = move & defines.MoveModifiers.TO_MASK;
    var toSquareBB: u64 = 1 << toSquare;

    const blackOffset = bs.blackTurn * defines.BoardState.PieceIndex.PIECE_OFFSET;

    var isPiece: bool = false;
    for (0..6) |i| {
        if (startSquareBB & bs.pieceBoards[i + blackOffset] != 0) {
            isPiece = true;
            bs.pieceBoards[i + blackOffset] ^= startSquareBB & toSquareBB;
            break;
        }
    }

    bs.teamBoards[1 + bs.blackTurn] ^= startSquareBB & toSquareBB;
    bs.teamBoards[defines.BoardState.PieceIndex.FULL_BOARD] &= ~startSquareBB;
    bs.teamBoards[defines.BoardState.PieceIndex.FULL_BOARD] |= toSquareBB;

    if (!isPiece) {
        bs.kings[bs.blackTurn] = toSquare;
    }

    if (bs.flags and (startSquareBB | toSquareBB) & rookCorners != 0) {
        // We have lost castle rights
    }

    if (moveMods == defines.MoveModifiers.DPUSH) {
        bs.enPassant = toSquare + if (bs.blackTurn == 1) -8 else 8;
    } else {
        bs.enPassant = 0;
    }

    if (moveMods == defines.MoveModifiers.EP_CAPTURE) {
        if (bs.blackTurn == 1) {
            toSquareBB <<= 8;
        } else {
            toSquareBB >>= 8;
        }
    }

    if (moveMods & defines.MoveModifiers.CAPTURE != 0) {
        // TODO: This is not correct
        const enemyOffset = 0;
        for (0..6) |i| {
            if (bs.pieceBoards[i + enemyOffset] & toSquareBB != 0) {
                bs.pieceBoards[i + enemyOffset] ^= toSquareBB;
                break;
            }
        }
    }

    if (moveMods == defines.MoveModifiers.KING_CASTLE) {
        // Remove flags
        bs.flags = 0;

        // Move rook
        bs.teamBoards[1 + bs.blackTurn] ^= startSquareBB & toSquareBB;
        bs.teamBoards[defines.BoardState.PieceIndex.FULL_BOARD] &= ~startSquareBB;
        bs.teamBoards[defines.BoardState.PieceIndex.FULL_BOARD] |= toSquareBB;
    }

    if (moveMods == defines.MoveModifiers.QUEEN_CASTLE) {
        // Remove flags
        bs.flags = 0;

        // Move rook
        bs.teamBoards[1 + bs.blackTurn] ^= startSquareBB & toSquareBB;
        bs.teamBoards[defines.BoardState.PieceIndex.FULL_BOARD] &= ~startSquareBB;
        bs.teamBoards[defines.BoardState.PieceIndex.FULL_BOARD] |= toSquareBB;
    }

    if (moveMods & defines.MoveModifiers.PROMO != 0) {
        //
    }
}
