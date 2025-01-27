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

    pinnedSquares: u64,
    blockMask: u64,

    attacks: u64,
    kings: [2]u8,
    numCheckers: u8,
    castlingRights: u8,
    enPassant: u8,
    turns: u8,
    whiteTurn: u8,
    hash: u64,

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
};

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
