////////////////////////////////////////////////
///  ______           ___ _
/// / _  (_) __ _    / __\ |__   ___  ___ ___
/// \// /| |/ _` |  / /  | '_ \ / _ \/ __/ __|
///  / //\ | (_| | / /___| | | |  __/\__ \__ \
/// /____/_|\__, | \____/|_| |_|\___||___/___/
///         |___/
////////////////////////////////////////////////
// @brief Draw tools for CLI
////////////////////////////////////////////////

const std = @import("std");
const defines = @import("defines.zig");
const BoardState = defines.BoardState;

const rowSize = 37;
const rowOffset = 42;
var board: [664]u8 = .{ ' ', ' ', ' ', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '\n', ' ', '8', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', '\n', ' ', ' ', ' ', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '\n', ' ', '7', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', '\n', ' ', ' ', ' ', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '\n', ' ', '6', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', '\n', ' ', ' ', ' ', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '\n', ' ', '5', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', '\n', ' ', ' ', ' ', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '\n', ' ', '4', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', '\n', ' ', ' ', ' ', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '\n', ' ', '3', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', '\n', ' ', ' ', ' ', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '\n', ' ', '2', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', '\n', ' ', ' ', ' ', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '\n', ' ', '1', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', ' ', ' ', ' ', '|', '\n', ' ', ' ', ' ', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '-', '-', '-', '+', '\n', ' ', ' ', ' ', ' ', ' ', 'a', ' ', ' ', ' ', 'b', ' ', ' ', ' ', 'c', ' ', ' ', ' ', 'd', ' ', ' ', ' ', 'e', ' ', ' ', ' ', 'f', ' ', ' ', ' ', 'g', ' ', ' ', ' ', 'h', '\n' };

////////////////////////////////////////////////
/// @brief Draws a board from a BoardState
///
/// @note Shows turn, turns, ep pawn and flags
////////////////////////////////////////////////
pub fn printBoard(bs: *BoardState) !void {
    const piece = [_]u8{ 'Q', 'R', 'B', 'N', 'P', 'q', 'r', 'b', 'n', 'p' };

    clearBoard();

    for (0..10) |i| {
        var bitboard = bs.pieceBoards[i];
        while (bitboard != 0) {
            const pos = @ctz(bitboard);
            board[setIndex(pos)] = piece[i];
            bitboard &= bitboard - 1;
        }
    }

    board[setIndex(bs.kings[0])] = 'K';
    board[setIndex(bs.kings[1])] = 'k';

    const turn: u8 = if (bs.whiteTurn == 1) 'W' else 'B';
    const flags = getFlagString(bs.castlingRights);

    var bw = getBufferedWriter();
    if (bs.enPassant != 0x0) {
        try bw.writer().print("{s}\nTurn: {c}\t Nr: {d}\t Ep: {s}\nFlags: {s}\n", .{ board, turn, bs.turns, epRep(bs.enPassant), flags });
    } else {
        try bw.writer().print("{s}\nTurn: {c}\t Nr: {d}\nFlags: {s}\n", .{ board, turn, bs.turns, flags });
    }

    try bw.flush();
}

////////////////////////////////////////////////
/// @brief Draws a given bitboard on the board.
///        Uses x in the place of a bit
///
/// @param bitboard
////////////////////////////////////////////////
pub fn printBitboard(positions: u64) !void {
    clearBoard();

    var bitboard = positions;
    while (bitboard != 0) {
        board[setIndex(@ctz(bitboard))] = 'x';
        bitboard &= bitboard - 1;
    }

    var bw = getBufferedWriter();
    try bw.writer().print("{s}\n", .{board});
    try bw.flush();
}

////////////////////////////////////////////////
/// @brief Draws a move to the board with the
///        from square represented by F and
///        to square by T
///
/// @param move
////////////////////////////////////////////////
pub fn printMove(move: u16) !void {
    clearBoard();

    board[setIndex(move & defines.MoveModifiers.FROM_MASK)] = 'F';
    board[setIndex(move & defines.MoveModifiers.TO_MASK >> 6)] = 'T';

    var bw = getBufferedWriter();
    try bw.writer().print("{s}\n", .{board});
    try bw.flush();
}

////////////////////////////////////////////////
/// @brief Sets all board positions to empty
////////////////////////////////////////////////
fn clearBoard() void {
    for (0..64) |i| {
        board[setIndex(@intCast(i))] = ' ';
    }
}

////////////////////////////////////////////////
/// @brief Translates board position to the
///        string position
///
/// @param [in] position
/// @return string position
////////////////////////////////////////////////
fn setIndex(pos: u16) u16 {
    const row = 7 - (pos >> 3);
    return rowOffset + row * rowSize * 2 + (pos & 7) * 4;
}

////////////////////////////////////////////////
/// @brief Takes castling flags and generates
///        a string representation
///
/// @param [in] flags
/// @return string representation
////////////////////////////////////////////////
fn getFlagString(flags: u8) [4]u8 {
    var flagString = [_]u8{ ' ', ' ', ' ', ' ' };
    if (flags & 0b1 != 0) {
        flagString[0] = 'K';
    }
    if (flags & 0b10 != 0) {
        flagString[1] = 'Q';
    }
    if (flags & 0b100 != 0) {
        flagString[2] = 'k';
    }
    if (flags & 0b1000 != 0) {
        flagString[3] = 'q';
    }
    return flagString;
}

////////////////////////////////////////////////
/// @brief Generates a string representation
///        from a board position (ex a3).
///
/// @param [in] position
/// @return string representation
////////////////////////////////////////////////
fn epRep(ep: u8) [2]u8 {
    const char = ep % 8 + 'a';
    const number = (ep / 8) + '0';
    return .{ char, number };
}

inline fn getBufferedWriter() @TypeOf(std.io.bufferedWriter(std.io.getStdOut().writer())) {
    const stdout_file = std.io.getStdOut().writer();
    return std.io.bufferedWriter(stdout_file);
}
