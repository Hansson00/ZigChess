////////////////////////////////////////////////
///  ______           ___ _
/// / _  (_) __ _    / __\ |__   ___  ___ ___
/// \// /| |/ _` |  / /  | '_ \ / _ \/ __/ __|
///  / //\ | (_| | / /___| | | |  __/\__ \__ \
/// /____/_|\__, | \____/|_| |_|\___||___/___/
///         |___/
////////////////////////////////////////////////
/// @brief Fen string manipulation
////////////////////////////////////////////////

const BoardState = @import("defines.zig").BoardState;
const std = @import("std");
const pow = std.math.pow;
const stringTools = @import("stringTools.zig");

pub const baseFenString = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

////////////////////////////////////////////////
/// @brief Sets a fen string to a given board
///
/// @param [in/out] BoardState to be altered
/// @param [in] fen string to be applied
///
/// @note Currently missing half moves
////////////////////////////////////////////////
pub fn setFen(bs: *BoardState, fenString: []const u8) void {
    var phase: u8 = 0;
    var row: u8 = 7;
    var col: u8 = 0;
    var ep: u8 = 0;
    var movesSeen: u8 = 0;

    for (fenString) |c| {
        if (c == ' ') {
            phase += 1;
            continue;
        }
        switch (phase) {
            0 => {
                if (stringTools.isChar(c)) {
                    const space: u64 = @as(u64, 1) << @intCast(row * 8 + col);
                    insertPiece(bs, space, c);
                } else {
                    specialChar(c, &row, &col);
                }
            },
            1 => {
                bs.whiteTurn = if (c == 'w') 1 else 0;
            },
            2 => {
                bs.castlingRights |= getCastlingFlags(c);
            },
            3 => {
                if (stringTools.isChar(c)) {
                    ep = c - 'a';
                } else if (stringTools.isNumber(c)) {
                    bs.enPassant = ep + (c - '0') * 8;
                }
            },
            4 => {
                // Half moves
            },
            5 => {
                // Full moves
                bs.turns = (c - '0') * pow(u8, 10, movesSeen);
                movesSeen += 1;
            },
            else => {},
        }

        col = @addWithOverflow(col, 1)[0];
    }
}

////////////////////////////////////////////////
/// @brief Handles special characters for
///        fen string
///
/// @param [in] character
/// @param [in/out] current row
/// @param [in/out] current col
////////////////////////////////////////////////
inline fn insertPiece(bs: *BoardState, position: u64, c: u8) void {
    if (c == 'k' or c == 'K') {
        bs.kings[@intFromBool(!stringTools.isCapital(c))] = @ctz(position);
    } else {
        bs.pieceBoards[tableIndex(c)] |= position;
    }
    bs.teamBoards[BoardState.PieceIndex.FULL_BOARD] |= position;
    bs.teamBoards[BoardState.PieceIndex.TEAM_BLACK - @intFromBool(stringTools.isCapital(c))] |= position;
}

////////////////////////////////////////////////
/// @brief Handles special characters for
///        fen string
///
/// @param [in] character
/// @param [in/out] current row
/// @param [in/out] current col
////////////////////////////////////////////////
inline fn specialChar(c: u8, row: *u8, col: *u8) void {
    if (c == '/') {
        row.* -= 1;
        col.* = 255;
    } else if (stringTools.isNumber(c)) {
        col.* += (c - 49);
    }
}

////////////////////////////////////////////////
/// @brief Gets castling flags from a character
///
/// @param [in] character for flag
/// @return Castling flags as a bitfiled (use |=)
////////////////////////////////////////////////
inline fn getCastlingFlags(c: u8) u8 {
    switch (c) {
        'K' => {
            return 0b1;
        },
        'Q' => {
            return 0b10;
        },
        'k' => {
            return 0b100;
        },
        'q' => {
            return 0b1000;
        },
        else => {},
    }
    return 0;
}

////////////////////////////////////////////////
/// @brief Generates a lookupTable for
///        setting pieces
///
/// @return table
////////////////////////////////////////////////
fn getLookup() [stringTools.alphabetSize]u8 {
    var table: [stringTools.alphabetSize]u8 = [_]u8{0} ** (stringTools.alphabetSize);

    table['b' - 'a'] = BoardState.PieceIndex.BISHOP;
    table['n' - 'a'] = BoardState.PieceIndex.KNIGHT;
    table['p' - 'a'] = BoardState.PieceIndex.PAWN;
    table['q' - 'a'] = BoardState.PieceIndex.QUEEN;
    table['r' - 'a'] = BoardState.PieceIndex.ROOK;

    return table;
}

const lookupTable: ['z' - 'a']u8 = getLookup();

////////////////////////////////////////////////
/// @brief Takes a character and returns
///        pieceBoard index
///
/// @param [in] character of piece
/// @return index
////////////////////////////////////////////////
inline fn tableIndex(c: u8) u8 {
    if (stringTools.isCapital(c)) {
        return (lookupTable[c - 'A']) + 0;
    } else {
        return (lookupTable[c - 'a']) + 5;
    }
}

test "tableIndex" {
    try std.testing.expectEqual(tableIndex('Q'), BoardState.PieceIndex.QUEEN);
    try std.testing.expectEqual(tableIndex('B'), BoardState.PieceIndex.BISHOP);
    try std.testing.expectEqual(tableIndex('P'), BoardState.PieceIndex.PAWN);
    try std.testing.expectEqual(tableIndex('Q'), BoardState.PieceIndex.QUEEN);
    try std.testing.expectEqual(tableIndex('R'), BoardState.PieceIndex.ROOK);

    try std.testing.expectEqual(tableIndex('q'), BoardState.PieceIndex.PIECE_OFFSET + BoardState.PieceIndex.QUEEN);
    try std.testing.expectEqual(tableIndex('b'), BoardState.PieceIndex.PIECE_OFFSET + BoardState.PieceIndex.BISHOP);
    try std.testing.expectEqual(tableIndex('p'), BoardState.PieceIndex.PIECE_OFFSET + BoardState.PieceIndex.PAWN);
    try std.testing.expectEqual(tableIndex('q'), BoardState.PieceIndex.PIECE_OFFSET + BoardState.PieceIndex.QUEEN);
    try std.testing.expectEqual(tableIndex('r'), BoardState.PieceIndex.PIECE_OFFSET + BoardState.PieceIndex.ROOK);
}
