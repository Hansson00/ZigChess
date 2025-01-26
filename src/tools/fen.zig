const BoardState = @import("defines.zig").BoardState;
const std = @import("std");
const pow = std.math.pow;

/// @brief sets a fenstring to a given board
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
                if (isChar(c)) {
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
                bs.castlingRights |= setCastlingFlags(c);
            },
            3 => {
                if (isChar(c)) {
                    ep = c - 'a';
                } else if (isNumber(c)) {
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

inline fn setCastlingFlags(c: u8) u8 {
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

inline fn specialChar(c: u8, row: *u8, col: *u8) void {
    if (c == '/') {
        row.* -= 1;
        col.* = 255;
    } else if (isNumber(c)) {
        col.* += (c - 49);
    }
}

inline fn insertPiece(bs: *BoardState, position: u64, c: u8) void {
    if (c == 'k' or c == 'K') {
        bs.kings[@intFromBool(!isCapital(c))] = @ctz(position);
    } else {
        bs.pieceBoards[tableIndex(c)] |= position;
    }
    bs.teamBoards[BoardState.PieceIndex.FULL_BOARD] |= position;
    bs.teamBoards[BoardState.PieceIndex.TEAM_BLACK - @intFromBool(isCapital(c))] |= position;
}

inline fn isChar(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z');
}

inline fn isNumber(c: u8) bool {
    return (c >= '0' and c <= '9');
}

inline fn isCapital(c: u8) bool {
    return c < 'a';
}

const alphabetSize = 'z' - 'a';

fn getLookup() [alphabetSize]u8 {
    var table: [alphabetSize]u8 = [_]u8{0} ** (alphabetSize);

    table['b' - 'a'] = BoardState.PieceIndex.BISHOP;
    table['n' - 'a'] = BoardState.PieceIndex.KNIGHT;
    table['p' - 'a'] = BoardState.PieceIndex.PAWN;
    table['q' - 'a'] = BoardState.PieceIndex.QUEEN;
    table['r' - 'a'] = BoardState.PieceIndex.ROOK;

    return table;
}

const lookupTable: ['z' - 'a']u8 = getLookup();

inline fn tableIndex(c: u8) u8 {
    if (isCapital(c)) {
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
