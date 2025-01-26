////////////////////////////////////
//
// @brief All defines for the engine
//
////////////////////////////////////

const intrinsics = @import("std").zig.c_builtins;
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

    const PieceIndex = enum {
        const PIECE_OFFSET: u8 = 5;
        const QUEEN: u8 = 0;
        const ROOK: u8 = 1;
        const BISHOP: u8 = 2;
        const KNIGHT: u8 = 3;
        const PAWN: u8 = 4;
        const KING: u8 = 5;
        const FULL_BOARD: u8 = 0;
        const TEAM_WHITE: u8 = 1;
        const TEAM_BLACK: u8 = 2;
    };
};

test "Board state" {
    const bs = BoardState.init();
    try std.testing.expect(0 != bs.blockMask);
}

const MoveList = struct {
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

const MoveModifiers = enum {
    const FROM_MASK: u16 = 63;
    const TO_MASK: u16 = 4032;
    const FROM_TO_MASK: u16 = 4095;
    const SPECIAL_MOVE_MASK: u16 = 61440;
    const QUIET_MOVE: u16 = 0;
    const DPUSH: u16 = 4096;
    const KING_CASTLE: u16 = 8192;
    const QUEEN_CASTLE: u16 = 12288;
    const CAPTURE: u16 = 16384;
    const EP_CAPTURE: u16 = 20480;
    const PROMO: u16 = 32768;
    const QUEEN_PROMO: u16 = 32768;
    const ROOK_PROMO: u16 = 36864;
    const BISHOP_PROMO: u16 = 40960;
    const KNIGHT_PROMO: u16 = 45056;
    const QUEEN_PROMO_CAPTURE: u16 = 49152;
    const ROOK_PROMO_CAPTURE: u16 = 53248;
    const BISHOP_PROMO_CAPTURE: u16 = 57344;
    const KNIGHT_PROMO_CAPTURE: u16 = 61440;
};

pub fn bitscan(bytes: u64) u8 {
    return @ctz(bytes);
}

test "Bitscan" {
    for (0..64) |i| {
        try std.testing.expectEqual(i, bitscan(@as(u64, 1) << @intCast(i)));
    }
}
