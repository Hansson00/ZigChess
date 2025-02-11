////////////////////////////////////////////////
///  ______           ___ _
/// / _  (_) __ _    / __\ |__   ___  ___ ___
/// \// /| |/ _` |  / /  | '_ \ / _ \/ __/ __|
///  / //\ | (_| | / /___| | | |  __/\__ \__ \
/// /____/_|\__, | \____/|_| |_|\___||___/___/
///         |___/
////////////////////////////////////////////////
/// @brief Pawn movement
/// @TODO:
///         - Legal En passant capture
///         - Pawn attack mask
////////////////////////////////////////////////

const defines = @import("../tools/defines.zig");

pub fn getAttackMask(
    bs: defines.BoardState,
) u64 {
    const PieceIndex = defines.BoardState.PieceIndex;

    const pieceOffset = if (bs.whiteTurn == 1) 0 else PieceIndex.PIECE_OFFSET;
    const pawnsBB = bs.pieceBoards[PieceIndex.PAWN + pieceOffset];
    const pawnAttacksBBs = pawnCapture(pawnsBB, bs.whiteTurn);
    return pawnAttacksBBs[0] | pawnAttacksBBs[1];
}

////////////////////////////////////////////////
// pseudo legal
////////////////////////////////////////////////

pub fn getQuiet(
    bs: defines.BoardState,
    ml: *defines.MoveList,
) u64 {
    const PieceIndex = defines.BoardState.PieceIndex;

    const pieceOffset = if (bs.whiteTurn == 1) 0 else PieceIndex.PIECE_OFFSET;
    const pawnsBB = bs.pieceBoards[PieceIndex.PAWN + pieceOffset];
    const nonOccupiedBB = ~bs.teamBoards[PieceIndex.FULL_BOARD];

    const promotingRankMask = comptime if (bs.whiteTurn == 1) defines.ranks[7] else defines.ranks[0];
    const startRankMask = comptime if (bs.whiteTurn == 1) defines.ranks[5] else defines.ranks[2];

    const pushBB = pawnPush(pawnsBB, bs.whiteTurn) & nonOccupiedBB;
    const doublePushBB = pawnPush(pawnsBB & startRankMask, bs.whiteTurn) & nonOccupiedBB;

    const moveDirection: i8 = comptime if (bs.whiteTurn == 1) 8 else -8;

    pawnMoveCreator(ml, pushBB & ~promotingRankMask, 0, moveDirection, defines.sameColumn);
    pawnMoveCreator(ml, doublePushBB, defines.MoveModifiers.DPUSH, moveDirection * 2, defines.sameColumn);
    pawnMoveCreator(ml, pushBB & promotingRankMask, defines.MoveModifiers.PROMO, moveDirection, defines.sameColumn);
}

pub fn getAttacks(
    bs: defines.BoardState,
    ml: *defines.MoveList,
) u64 {
    const PieceIndex = defines.BoardState.PieceIndex;

    const pieceOffset = if (bs.whiteTurn == 1) 0 else PieceIndex.PIECE_OFFSET;
    const pawnsBB = bs.pieceBoards[PieceIndex.PAWN + pieceOffset];

    const opponentOccupiedBB = bs.teamBoards[PieceIndex.TEAM_BLACK - bs.bs.whiteTurn];
    const promotingRankMask = comptime if (bs.whiteTurn == 1) defines.ranks[7] else defines.ranks[0];

    var pawnAttacksBBs = pawnCapture(pawnsBB, bs.whiteTurn);
    pawnAttacksBBs[0] &= opponentOccupiedBB;
    pawnAttacksBBs[1] &= opponentOccupiedBB;

    const moveDirectionR: i8 = comptime if (bs.whiteTurn == 1) 9 else -7;
    const moveDirectionL: i8 = comptime if (bs.whiteTurn == 1) 7 else -9;

    pawnMoveCreator(ml, pawnAttacksBBs[0] & ~promotingRankMask, defines.MoveModifiers.CAPTURE, moveDirectionR, defines.sameDiagonal);
    pawnMoveCreator(ml, pawnAttacksBBs[1] & ~promotingRankMask, defines.MoveModifiers.CAPTURE, moveDirectionL, defines.sameDiagonal);
    pawnMoveCreator(ml, pawnAttacksBBs[0] & promotingRankMask, defines.MoveModifiers.PROMO, moveDirectionR, defines.sameDiagonal);
    pawnMoveCreator(ml, pawnAttacksBBs[1] & promotingRankMask, defines.MoveModifiers.PROMO, moveDirectionL, defines.sameDiagonal);

    // EP capture
    if (bs.enPassant != 0) {
        epCapture(bs, ml, bs.whiteTurn);
    }
}

fn epCapture(bs: defines.BoardState, ml: *defines.MoveList) void {
    const PieceIndex = defines.BoardState.PieceIndex;

    const epPos = bs.enPassant;
    const epBB: u64 = 1 << epPos;

    const pieceOffset = if (bs.whiteTurn) 0 else PieceIndex.PIECE_OFFSET;
    const pawnsBB = bs.pieceBoards[PieceIndex.PAWN + pieceOffset];

    if (bs.whiteTurn) {
        if (epBB >> 9 & pawnsBB) {
            ml.addMove(defines.MoveList.createMoveWMod(epPos - 9, epPos, defines.MoveModifiers.EP_CAPTURE));
        }
        if (epBB >> 7 & pawnsBB) {
            ml.addMove(defines.MoveList.createMoveWMod(epPos - 7, epPos, defines.MoveModifiers.EP_CAPTURE));
        }
    } else {
        if (epBB << 9 & pawnsBB) {
            ml.addMove(defines.MoveList.createMoveWMod(epPos + 9, epPos, defines.MoveModifiers.EP_CAPTURE));
        }
        if (epBB << 7 & pawnsBB) {
            ml.addMove(defines.MoveList.createMoveWMod(epPos + 7, epPos, defines.MoveModifiers.EP_CAPTURE));
        }
    }
}

////////////////////////////////////////////////
// legal
////////////////////////////////////////////////

pub fn getLegalQuiet(
    bs: defines.BoardState,
    ml: *defines.MoveList,
) u64 {
    const PieceIndex = defines.BoardState.PieceIndex;

    const pieceOffset = if (bs.whiteTurn == 1) 0 else PieceIndex.PIECE_OFFSET;
    const pawnsBB = bs.pieceBoards[PieceIndex.PAWN + pieceOffset];
    const nonOccupiedBB = ~bs.teamBoards[PieceIndex.FULL_BOARD];

    const promotingRankMask = comptime if (bs.whiteTurn == 1) defines.ranks[7] else defines.ranks[0];
    const startRankMask = comptime if (bs.whiteTurn == 1) defines.ranks[5] else defines.ranks[2];

    var pushBB = pawnPush(pawnsBB, bs.whiteTurn) & nonOccupiedBB;
    const doublePushBB = pawnPush(pawnsBB & startRankMask, bs.whiteTurn) & nonOccupiedBB & bs.blockMask;
    pushBB &= bs.blockMask;

    const moveDirection: i8 = comptime if (bs.whiteTurn == 1) 8 else -8;

    legalPawnMoveCreator(bs, ml, pushBB & ~promotingRankMask, 0, moveDirection, defines.sameColumn);
    legalPawnMoveCreator(bs, ml, doublePushBB, defines.MoveModifiers.DPUSH, moveDirection * 2, defines.sameColumn);
    legalPawnMoveCreator(bs, ml, pushBB & promotingRankMask, defines.MoveModifiers.PROMO, moveDirection, defines.sameColumn);
}

pub fn getLegalAttacks(
    bs: defines.BoardState,
    ml: *defines.MoveList,
) u64 {
    const PieceIndex = defines.BoardState.PieceIndex;

    const pieceOffset = if (bs.whiteTurn == 1) 0 else PieceIndex.PIECE_OFFSET;
    const pawnsBB = bs.pieceBoards[PieceIndex.PAWN + pieceOffset];

    const opponentOccupiedBB = bs.teamBoards[PieceIndex.TEAM_BLACK - bs.whiteTurn];
    const promotingRankMask = comptime if (bs.whiteTurn == 1) defines.ranks[7] else defines.ranks[0];

    var pawnAttacksBBs = pawnCapture(pawnsBB, bs.whiteTurn);
    pawnAttacksBBs[0] &= opponentOccupiedBB & bs.blockMask;
    pawnAttacksBBs[1] &= opponentOccupiedBB & bs.blockMask;

    const moveDirectionR: i8 = comptime if (bs.whiteTurn == 1) 9 else -7;
    const moveDirectionL: i8 = comptime if (bs.whiteTurn == 1) 7 else -7;

    legalPawnMoveCreator(bs, ml, pawnAttacksBBs[0] & ~promotingRankMask, defines.MoveModifiers.CAPTURE, moveDirectionR, defines.sameDiagonal);
    legalPawnMoveCreator(bs, ml, pawnAttacksBBs[1] & ~promotingRankMask, defines.MoveModifiers.CAPTURE, moveDirectionL, defines.sameDiagonal);
    legalPawnMoveCreator(bs, ml, pawnAttacksBBs[0] & promotingRankMask, defines.MoveModifiers.PROMO, moveDirectionR, defines.sameDiagonal);
    legalPawnMoveCreator(bs, ml, pawnAttacksBBs[1] & promotingRankMask, defines.MoveModifiers.PROMO, moveDirectionL, defines.sameDiagonal);

    // TODO legal EP capture
}

////////////////////////////////////////////////
// Helper Functions
////////////////////////////////////////////////

inline fn pawnPush(
    pawns: u64,
    whiteTurn: u8,
) u64 {
    return comptime if (whiteTurn == 1) pawns << 8 else pawns >> 8;
}

inline fn pawnCapture(
    pawns: u64,
    whiteTurn: u8,
) struct { u64, u64 } {
    if (whiteTurn == 1) {
        return .{ (pawns & ~defines.files[7]) << 9, (pawns & ~defines.files[0]) << 7 };
    } else {
        return .{ (pawns & ~defines.files[0]) >> 9, (pawns & ~defines.files[7]) >> 7 };
    }
}

fn pawnMoveCreator(
    ml: *defines.MoveList,
    pawnBB: u64,
    comptime moveMod: defines.MoveModifiers,
    moveDirection: i8,
) void {
    var pawns = pawnBB;

    while (pawns) {
        const destination = @ctz(pawns);
        const origin = @as(u16, @intCast(destination - moveDirection));
        const baseMove = defines.MoveList.createMoveWMod(origin, destination, moveMod);
        comptime if (moveMod & defines.MoveModifiers.PROMO != 0) {
            ml.add(baseMove | defines.MoveModifiers.QUEEN_PROMO);
            ml.add(baseMove | defines.MoveModifiers.ROOK_PROMO);
            ml.add(baseMove | defines.MoveModifiers.BISHOP_PROMO);
            ml.add(baseMove | defines.MoveModifiers.KNIGHT_PROMO);
        } else {
            ml.addMove(baseMove);
        };

        pawns &= pawns - 1;
    }
}

fn legalPawnMoveCreator(
    bs: defines.BoardState,
    ml: *defines.MoveList,
    pawnBB: u64,
    comptime moveMod: defines.MoveModifiers,
    moveDirection: i8,
    pinCheck: fn (u8, u8) bool,
) void {
    var pawns = pawnBB;

    while (pawns) {
        const destination = @ctz(pawns);
        const origin = @as(u16, @intCast(destination - moveDirection));

        const pinned = (bs.pinnedSquares & (1 << origin)) != 0;
        if (pinned) {
            // Can only pawn push if on the same column as the king
            const kingDiagonal = pinCheck(origin, bs.kings[@intFromBool(bs.whiteTurn == 0)]);
            if (!kingDiagonal) {
                continue;
            }
        }
        const baseMove = defines.MoveList.createMoveWMod(origin, destination, moveMod);
        comptime if (moveMod & defines.MoveModifiers.PROMO != 0) {
            ml.add(baseMove | defines.MoveModifiers.QUEEN_PROMO);
            ml.add(baseMove | defines.MoveModifiers.ROOK_PROMO);
            ml.add(baseMove | defines.MoveModifiers.BISHOP_PROMO);
            ml.add(baseMove | defines.MoveModifiers.KNIGHT_PROMO);
        } else {
            ml.addMove(baseMove);
        };

        pawns &= pawns - 1;
    }
}
