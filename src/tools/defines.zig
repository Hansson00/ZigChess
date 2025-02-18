////////////////////////////////////////////////
///  ______           ___ _
/// / _  (_) __ _    / __\ |__   ___  ___ ___
/// \// /| |/ _` |  / /  | '_ \ / _ \/ __/ __|
///  / //\ | (_| | / /___| | | |  __/\__ \__ \
/// /____/_|\__, | \____/|_| |_|\___||___/___/
///         |___/
////////////////////////////////////////////////
// @brief All defines for the engine
////////////////////////////////////////////////

const std = @import("std");

pub const BoardState = struct {
    pieceBoards: [10]u64,
    teamBoards: [5]u64,

    // Remove
    pinnedSquares: u64,

    // Remove
    blockMask: u64,

    attacks: u64,
    kings: [2]u8,

    // Might remove
    numCheckers: u8,

    castlingRights: u8,
    enPassant: u8,
    turns: u8,

    // Remove
    whiteTurn: u8,

    blackTurn: u8,
    // hash: u64,

    pub fn init() BoardState {
        return BoardState{
            .pieceBoards = [_]u64{0} ** 10,
            .teamBoards = [_]u64{0} ** 5,

            .pinnedSquares = 0,
            .blockMask = ~@as(u64, 0),

            .attacks = 0,
            .kings = .{ 0, 0 },
            .numCheckers = 0,
            .castlingRights = 0,
            .enPassant = 0,
            .turns = 0,
            .whiteTurn = 0,
            .hash = 0,
        };
    }

    pub const PieceIndex = enum {
        // Offset to black pieces
        pub const PIECE_OFFSET: u8 = 5;

        // For pieceBoards
        pub const QUEEN: u8 = 0;
        pub const ROOK: u8 = 1;
        pub const BISHOP: u8 = 2;
        pub const KNIGHT: u8 = 3;
        pub const PAWN: u8 = 4;
        // pub const KING: u8 = 5;

        // For teamBoards
        pub const FULL_BOARD: u8 = 0;
        pub const TEAM_WHITE: u8 = 1;
        pub const TEAM_BLACK: u8 = 2;
    };

    pub const CastlingFlags = enum {
        // Castling flags
        pub const W_KING_CASTLE_FLAG: u8 = 0b1;
        pub const W_QUEEN_CASTLE_FLAG: u8 = 0b10;
        pub const B_KING_CASTLE_FLAG: u8 = 0b100;
        pub const B_QUEEN_CASTLE_FLAG: u8 = 0b1000;
    };
};

test "Board state" {
    const bs = BoardState.init();
    try std.testing.expect(0 != bs.blockMask);
}

pub const MoveList = struct {
    end: u16 = 0,
    moves: [100]u16,

    pub fn init() MoveList {
        return MoveList{
            .end = 0,
            .moves = [_]u16{0} ** 100,
        };
    }

    pub inline fn addMove(self: *MoveList, newMove: u16) void {
        self.moves[self.end] = newMove;
        self.end += 1;
    }

    pub inline fn getMove(self: *MoveList) u16 {
        self.end -= 1;
        return self.moves[self.end];
    }

    pub inline fn resetMoves(self: *MoveList) void {
        self.end = 0;
    }

    pub inline fn createMoveWMod(startPosition: u8, endPosition: u8, moveMod: MoveModifiers) u16 {
        return startPosition | (endPosition << 6) | moveMod;
    }

    pub inline fn createMove(startPosition: u8, endPosition: u8) u16 {
        return startPosition | (endPosition << 6);
    }
};

pub inline fn sameColumn(piece1: u8, piece2: u8) bool {
    return piece1 & 7 == piece2 & 7;
}

pub inline fn sameDiagonal(piece1: u8, piece2: u8) bool {
    return @abs(piece1 / 8 - piece2 / 8) == @abs(piece1 & 7 - piece2 & 7);
}

pub inline fn sameRow(piece1: u8, piece2: u8) bool {
    return piece1 / 8 == piece2 / 8;
}

test "Move list" {
    var ml = MoveList.init();
    const move1: u16 = 16;
    const move2: u16 = 32;
    const move3: u16 = 64;

    ml.addMove(move1);
    ml.addMove(move2);
    ml.addMove(move3);

    try std.testing.expectEqual(move3, ml.getMove());
    try std.testing.expectEqual(move2, ml.getMove());
    try std.testing.expectEqual(move1, ml.getMove());
}

const SIZE_OF_BOARD: u8 = 64;

///////////////////////////////////////
///   +---+---+---+---+---+---+---+---+
/// 8 | x |   |   |   |   |   |   | x |
///   +---+---+---+---+---+---+---+---+
/// 7 |   |   |   |   |   |   |   |   |
///   +---+---+---+---+---+---+---+---+
/// 6 |   |   |   |   |   |   |   |   |
///   +---+---+---+---+---+---+---+---+
/// 5 |   |   |   |   |   |   |   |   |
///   +---+---+---+---+---+---+---+---+
/// 4 |   |   |   |   |   |   |   |   |
///   +---+---+---+---+---+---+---+---+
/// 3 |   |   |   |   |   |   |   |   |
///   +---+---+---+---+---+---+---+---+
/// 2 |   |   |   |   |   |   |   |   |
///   +---+---+---+---+---+---+---+---+
/// 1 | x |   |   |   |   |   |   | x |
///   +---+---+---+---+---+---+---+---+
///     a   b   c   d   e   f   g   h
///////////////////////////////////////
const rookCorners: u64 = 1 | 1 << 7 | 1 << 56 | 1 << 63;

/// ----------|------|-----------|---------|-----------|-----------|----------------------
///  dec code | code | promotion | capture | special 1 | special 0 | kind of move
/// ----------|------|-----------|---------|-----------|-----------|----------------------
///  0        | 0    | 0         | 0       | 0         | 0         | quiet moves
///  4096     | 1    | 0         | 0       | 0         | 1         | double pawn push
///  8192     | 2    | 0         | 0       | 1         | 0         | king castle
///  12288    | 3    | 0         | 0       | 1         | 1         | queen castle
///  16384    | 4    | 0         | 1       | 0         | 0         | captures
///  20480    | 5    | 0         | 1       | 0         | 1         | ep-capture
///           | 6    | 0         | 1       | 1         | 0         | --
///           | 7    | 0         | 1       | 1         | 1         | --
///  32768    | 8    | 1         | 0       | 0         | 0         | knight-promotion
///  36864    | 9    | 1         | 0       | 0         | 1         | bishop-promotion
///  40960    | 10   | 1         | 0       | 1         | 0         | rook-promotion
///  45056    | 11   | 1         | 0       | 1         | 1         | queen-promotion
///  49152    | 12   | 1         | 1       | 0         | 0         | knight-promo capture
///  53248    | 13   | 1         | 1       | 0         | 1         | bishop-promo capture
///  57344    | 14   | 1         | 1       | 1         | 0         | rook-promo capture
///  61440    | 15   | 1         | 1       | 1         | 1         | queen-promo capture
/// ----------|------|-----------|---------|-----------|-----------|----------------------
pub const MoveModifiers = enum {
    pub const FROM_MASK: u16 = 63;
    pub const TO_MASK: u16 = 4032;
    pub const FROM_TO_MASK: u16 = 4095;
    pub const SPECIAL_MOVE_MASK: u16 = 61440;
    pub const QUIET_MOVE: u16 = 0;
    pub const DPUSH: u16 = 4096;
    pub const KING_CASTLE: u16 = 8192;
    pub const QUEEN_CASTLE: u16 = 12288;
    pub const CAPTURE: u16 = 16384;
    pub const EP_CAPTURE: u16 = 20480;
    pub const PROMO: u16 = 32768;
    pub const QUEEN_PROMO: u16 = 32768;
    pub const ROOK_PROMO: u16 = 36864;
    pub const BISHOP_PROMO: u16 = 40960;
    pub const KNIGHT_PROMO: u16 = 45056;
    pub const QUEEN_PROMO_CAPTURE: u16 = 49152;
    pub const ROOK_PROMO_CAPTURE: u16 = 53248;
    pub const BISHOP_PROMO_CAPTURE: u16 = 57344;
    pub const KNIGHT_PROMO_CAPTURE: u16 = 61440;
};

pub const files: [8]u64 = .{ 0x0101010101010101, 0x0202020202020202, 0x0404040404040404, 0x0808080808080808, 0x1010101010101010, 0x2020202020202020, 0x4040404040404040, 0x8080808080808080 };
pub const ranks: [8]u64 = .{ 0xFF, 0xFF00, 0xFF0000, 0xFF000000, 0xFF00000000, 0xFF0000000000, 0xFF000000000000, 0xFF00000000000000 };

pub const main_diagonals: [15]u64 = .{ 0x0100000000000000, 0x0201000000000000, 0x0402010000000000, 0x0804020100000000, 0x1008040201000000, 0x2010080402010000, 0x4020100804020100, 0x8040201008040201, 0x80402010080402, 0x804020100804, 0x8040201008, 0x80402010, 0x804020, 0x8040, 0x80 };
pub const anti_diagonals: [15]u64 = .{ 0x1, 0x0102, 0x010204, 0x01020408, 0x0102040810, 0x010204081020, 0x01020408102040, 0x0102040810204080, 0x0204081020408000, 0x0408102040800000, 0x0810204080000000, 0x1020408000000000, 0x2040800000000000, 0x4080000000000000, 0x8000000000000000 };
