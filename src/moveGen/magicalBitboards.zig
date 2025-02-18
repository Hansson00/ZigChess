////////////////////////////////////////////////
///  ______           ___ _
/// / _  (_) __ _    / __\ |__   ___  ___ ___
/// \// /| |/ _` |  / /  | '_ \ / _ \/ __/ __|
///  / //\ | (_| | / /___| | | |  __/\__ \__ \
/// /____/_|\__, | \____/|_| |_|\___||___/___/
///         |___/
////////////////////////////////////////////////
/// @brief Plain Magical Bitboards
/// @site https://www.chessprogramming.org/Magic_Bitboards
///
/// @TODO:  - Clean private functions
///         - Document private functions
///         - Test other implementations
///           (Black Magic Bitboards)
///         - Put everythin in the same table.
///           We are currently doing 4 lookups
///           when 2 would be enough
////////////////////////////////////////////////

const std = @import("std");
const defines = @import("../tools/defines.zig");

////////////////////////////////////////////////
/// PUBLIC
////////////////////////////////////////////////

////////////////////////////////////////////////
/// @brief Gets all bishop attacks for a given
///        position
///
/// @param [in] position of the piece
/// @param [in] board occupations
/// @return bishop attacks
////////////////////////////////////////////////
pub inline fn getBishopAttacks(square: u8, occupancy: u64) u64 {
    var occupancy_ = occupancy & bishopMasks[square];
    occupancy_ *= bishopMagicBitboard[square];
    occupancy_ >>= @intCast(64 - occupacyCountBishop[square]);
    return bishopAttacks[square][occupancy_];
}

////////////////////////////////////////////////
/// @brief Gets all rook attacks for a given
///        position
///
/// @param [in] position of the piece
/// @param [in] board occupations
/// @return rook attacks
////////////////////////////////////////////////
pub inline fn getRookAttacks(square: u8, occupancy: u64) u64 {
    var occupancy_ = occupancy & rookMasks[square];
    occupancy_ *= rookMagicBitboard[square];
    occupancy_ >>= @intCast(64 - occupacyCountRook[square]);
    return rookAttacks[square][occupancy_];
}

////////////////////////////////////////////////
// Pseudo legal
////////////////////////////////////////////////

pub fn rookMoveGenerator(
    bs: defines.BoardState,
    ml: *defines.MoveList,
    moveMod: defines.MoveModifiers,
    pieceOrigin: u8,
) void {
    const PieceIndex = defines.BoardState.PieceIndex;
    var moves = getRookAttacks(pieceOrigin, bs.teamBoards[0]);

    if (moveMod == defines.MoveModifiers.QUIET_MOVE) {
        moves &= ~bs.teamBoards[PieceIndex.FULL_BOARD];
    } else {
        moves &= bs.teamBoards[PieceIndex.TEAM_BLACK - bs.whiteTurn];
    }

    const baseMove = pieceOrigin | moveMod;
    while (moves) {
        const destination = @ctz(moves);
        ml.addMove(baseMove | (destination << 6));
        moves &= moves - 1;
    }
}

pub fn bishopMoveGenerator(
    bs: defines.BoardState,
    ml: *defines.MoveList,
    moveMod: defines.MoveModifiers,
    pieceOrigin: u8,
) void {
    const PieceIndex = defines.BoardState.PieceIndex;
    var moves = getBishopAttacks(pieceOrigin, bs.teamBoards[0]);

    if (moveMod == defines.MoveModifiers.QUIET_MOVE) {
        moves &= ~bs.teamBoards[PieceIndex.FULL_BOARD];
    } else {
        moves &= bs.teamBoards[PieceIndex.TEAM_BLACK - bs.whiteTurn];
    }

    const baseMove = pieceOrigin | moveMod;
    while (moves) {
        const destination = @ctz(moves);
        ml.addMove(baseMove | (destination << 6));
        moves &= moves - 1;
    }
}

////////////////////////////////////////////////
// Legal
////////////////////////////////////////////////

pub fn legalRookMoveGenerator(
    bs: defines.BoardState,
    ml: *defines.MoveList,
    moveMod: defines.MoveModifiers,
    pieceOrigin: u8,
) void {
    const PieceIndex = defines.BoardState.PieceIndex;
    var moves = getRookAttacks(pieceOrigin, bs.teamBoards[0]) & bs.blockMask;

    const pinned = (bs.pinnedSquares & (1 << pieceOrigin)) != 0;
    if (pinned) {
        if (defines.sameColumn(pieceOrigin, bs.kings[1 - bs.whiteTurn])) {
            moves &= defines.files[pieceOrigin & 7];
        } else {
            moves &= defines.ranks[pieceOrigin / 8];
        }
    }

    if (moveMod == defines.MoveModifiers.QUIET_MOVE) {
        moves &= ~bs.teamBoards[PieceIndex.FULL_BOARD];
    } else {
        moves &= bs.teamBoards[PieceIndex.TEAM_BLACK - bs.whiteTurn];
    }

    const baseMove = pieceOrigin | moveMod;
    while (moves) {
        const destination = @ctz(moves);
        ml.addMove(baseMove | (destination << 6));
        moves &= moves - 1;
    }
}

pub fn legalBishopMoveGenerator(
    bs: defines.BoardState,
    ml: *defines.MoveList,
    moveMod: defines.MoveModifiers,
    pieceOrigin: u8,
) void {
    const PieceIndex = defines.BoardState.PieceIndex;
    var moves = getBishopAttacks(pieceOrigin, bs.teamBoards[0]) & bs.blockMask;

    const pinned = (bs.pinnedSquares & (1 << pieceOrigin)) != 0;
    if (pinned) {
        const kingX = bs.kings[1 - bs.whiteTurn] & 7;
        const kingY = bs.kings[1 - bs.whiteTurn] / 8;
        moves &= ~defines.files[kingX];
        moves &= ~defines.ranks[kingY];
    }

    if (moveMod == defines.MoveModifiers.QUIET_MOVE) {
        moves &= ~bs.teamBoards[PieceIndex.FULL_BOARD];
    } else {
        moves &= bs.teamBoards[PieceIndex.TEAM_BLACK - bs.whiteTurn];
    }

    const baseMove = pieceOrigin | moveMod;
    while (moves) {
        const destination = @ctz(moves);
        ml.addMove(baseMove | (destination << 6));
        moves &= moves - 1;
    }
}

////////////////////////////////////////////////
/// PRIVATE (Everything below is comptime)
////////////////////////////////////////////////

////////////////////////////////////////////////
/// Merged tables (should be faster due to cache)
////////////////////////////////////////////////
// const TableBishop = struct {
//     magicBitboard: u64,
//     masks: u64,
//     occupacyCount: u8,
//     attacks: [512]u64,
// };
//
// const TableRook = struct {
//     magicBitboard: u64,
//     masks: u64,
//     occupacyCount: u8,
//     attacks: [4096]u64,
// };
////////////////////////////////////////////////

const bishopMagicBitboard: [64]u64 = .{ 0x1104043802430608, 0x48600381421c3088, 0x1004011206050048, 0x2008048118581261, 0xac5040030810a4, 0x22010521200200, 0x401e061220450926, 0x10e020710821030, 0x486301010093060, 0x1442280807540da0, 0x421a500c20802201, 0x281080841000140, 0x2241c0504140227, 0x38a1250452405085, 0x1058008801282081, 0x2c14338841301000, 0x1204556044703220, 0x420e381a180a08, 0x106d1628060400b1, 0x8006220a04082, 0xa0c041201210302, 0x94a022342304400, 0x200101c94f082048, 0x21a24840221e1014, 0x5040004a381108, 0x4764108360814100, 0x44180a1029020204, 0x1004044040002, 0x60020041405000, 0x1118084018806007, 0x219c2bc060980420, 0x40810826424c0401, 0x1118044004314202, 0x121284200783048, 0xe005000610300, 0x3c13200800090810, 0x29020484008a0020, 0x19010700aa0341, 0x2821080204e90f38, 0x3098010020c04a21, 0x206e101024800801, 0x2000482450003488, 0x80f1c1850081804, 0x240220420281180c, 0x5826084104002441, 0x3208050802030220, 0x7812621454044100, 0x4830588e00821042, 0x2204110119201102, 0x19032a090c200404, 0x520018404c82240, 0x408e314842020000, 0x2080200425040240, 0x4a0200a4a8a0003, 0x4060606965031023, 0x8820c45060204a9, 0x4005450405a00400, 0x2077114228140a25, 0x22102941014b1073, 0x1cc0421402420205, 0x6c8b2a4042104109, 0x41a2401950304188, 0x3b06700c5848304a, 0x2160381011132121 };
const rookMagicBitboard: [64]u64 = .{ 0x280018940015060, 0x4c0006008405005, 0xe000a8022001040, 0xd00100048646100, 0x680180044004680, 0x5a00012804160050, 0x880208021000200, 0x4600020b02224184, 0x10860022058300c0, 0x202400220100048, 0x2822001200402088, 0x401a000a10220042, 0x92a0020040a0010, 0x4cb00480c001700, 0x83c004204082150, 0x41100055e960100, 0xd08218001c00884, 0x817020028820040, 0x3010370020004100, 0x2e630039001000, 0x40b80280082c0080, 0xc2010100080400, 0x10a00c0010021807, 0x10200010348a4, 0x2480025140002005, 0x4008470200220281, 0x5620030100241040, 0x120601c200200812, 0x1001001100080084, 0x4909001300081400, 0x46511400103278, 0x2000269200130054, 0x60244006800081, 0x810002000400051, 0x491704103002000, 0x102420112000820, 0x3022010812002004, 0x113c001002020008, 0x410308304001842, 0x31035830e00224c, 0x1280094660084005, 0xc3000201040400b, 0x4930004020010100, 0x490030108110020, 0x2920010040a0020, 0x4bc409060080104, 0x1401802391400b0, 0x109240044860027, 0x1403148008e04100, 0x4920208108400d00, 0x820021020470100, 0x70052008110100, 0x2166041100080100, 0x5000204000900, 0x52c6110210e80400, 0x4a011409488b0200, 0x2043321048000c1, 0x407a400102201481, 0x12010400a0282, 0x4002000840102106, 0x27200082015501e, 0x420200106c130846, 0x86a12821028250c, 0x104202104840646 };

const occupacyCountBishop: [64]u8 = .{ 6, 5, 5, 5, 5, 5, 5, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 7, 7, 7, 7, 5, 5, 5, 5, 7, 9, 9, 7, 5, 5, 5, 5, 7, 9, 9, 7, 5, 5, 5, 5, 7, 7, 7, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 5, 5, 5, 5, 5, 5, 6 };
const occupacyCountRook: [64]u8 = .{ 12, 11, 11, 11, 11, 11, 11, 12, 11, 10, 10, 10, 10, 10, 10, 11, 11, 10, 10, 10, 10, 10, 10, 11, 11, 10, 10, 10, 10, 10, 10, 11, 11, 10, 10, 10, 10, 10, 10, 11, 11, 10, 10, 10, 10, 10, 10, 11, 11, 10, 10, 10, 10, 10, 10, 11, 12, 11, 11, 11, 11, 11, 11, 12 };

const bishopMasks: [64]u64 = initBishopMask();
const rookMasks: [64]u64 = initRookMask();

const bishopAttacks: [64][512]u64 = initBishopAttacks();
const rookAttacks: [64][4096]u64 = initRookAttacks();

fn initBishopMask() [64]u64 {
    var masks: [64]u64 = undefined;
    for (0..64) |i| {
        masks[i] = maskBishopAttacks(i);
    }
    return masks;
}

fn initRookMask() [64]u64 {
    var masks: [64]u64 = undefined;
    for (0..64) |i| {
        masks[i] = maskRookAttacks(i);
    }
    return masks;
}

fn initBishopAttacks() [64][512]u64 {
    var attacks: [64][512]u64 = undefined;
    for (0..64) |square| {
        const attackMask = bishopMasks[square];
        const relevantBitsCount = countBits(attackMask);
        const occupancyIndicies = 1 << relevantBitsCount;

        for (0..occupancyIndicies) |i| {
            const occupancy = setOccupancy(i, relevantBitsCount, attackMask);
            const magicIndex = @mulWithOverflow(occupancy, bishopMagicBitboard[square])[0] >> (64 - occupacyCountBishop[square]);
            attacks[square][magicIndex] = maskBishopAttacksWithBlock(square, occupancy);
        }
    }
    return attacks;
}

fn initRookAttacks() [64][4096]u64 {
    var attacks: [64][4096]u64 = undefined;
    for (0..64) |square| {
        const attackMask = rookMasks[square];
        const relevantBitsCount = countBits(attackMask);
        const occupancyIndicies = 1 << relevantBitsCount;

        for (0..occupancyIndicies) |i| {
            const occupancy = setOccupancy(i, relevantBitsCount, attackMask);
            const magicIndex = @mulWithOverflow(occupancy, rookMagicBitboard[square])[0] >> (64 - occupacyCountRook[square]);
            attacks[square][magicIndex] = maskRookAttacksWithBlock(square, occupancy);
        }
    }
    return attacks;
}

fn maskBishopAttacks(position: u8) u64 {
    var attacks: u64 = 0;

    const tr: i8 = position >> 3;
    const tf: i8 = position & 7;

    var r: i32 = 0;
    var f: i32 = 0;

    r = tr + 1;
    f = tf + 1;
    while (r <= 6 and f <= 6) {
        attacks |= 1 << (r * 8 + f);
        r += 1;
        f += 1;
    }
    r = tr - 1;
    f = tf + 1;
    while (r >= 1 and f <= 6) {
        attacks |= 1 << (r * 8 + f);
        r -= 1;
        f += 1;
    }
    r = tr + 1;
    f = tf - 1;
    while (r <= 6 and f >= 1) {
        attacks |= 1 << (r * 8 + f);
        r += 1;
        f -= 1;
    }
    r = tr - 1;
    f = tf - 1;
    while (r >= 1 and f >= 1) {
        attacks |= 1 << (r * 8 + f);
        r -= 1;
        f -= 1;
    }
    return attacks;
}

fn maskRookAttacks(position: u8) u64 {
    var attacks: u64 = 0;

    const tr: i8 = position >> 3;
    const tf: i8 = position & 7;

    var r = tr + 1;
    while (r <= 6) : (r += 1)
        attacks |= (1 << (r * 8 + tf));
    r = tr - 1;
    while (r >= 1) : (r -= 1)
        attacks |= (1 << (r * 8 + tf));
    var f = tf + 1;
    while (f <= 6) : (f += 1)
        attacks |= (1 << (tr * 8 + f));
    f = tf - 1;
    while (f >= 1) : (f -= 1)
        attacks |= (1 << (tr * 8 + f));

    return attacks;
}

fn maskBishopAttacksWithBlock(position: u8, boardMask: u64) u64 {
    var attacks: u64 = 0;
    var attack: u64 = 0;

    var r: i32 = 0;
    var f: i32 = 0;

    const tr: i8 = position >> 3;
    const tf: i8 = position & 7;

    r = tr + 1;
    f = tf + 1;
    while (r <= 7 and f <= 7) {
        attack = (1 << (r * 8 + f));
        attacks |= attack;
        if (attack & boardMask != 0)
            break;
        r += 1;
        f += 1;
    }

    r = tr - 1;
    f = tf + 1;
    while (r >= 0 and f <= 7) {
        attack = (1 << (r * 8 + f));
        attacks |= attack;
        if (attack & boardMask != 0)
            break;
        r -= 1;
        f += 1;
    }

    r = tr + 1;
    f = tf - 1;
    while (r <= 7 and f >= 0) {
        attack = (1 << (r * 8 + f));
        attacks |= attack;
        if (attack & boardMask != 0)
            break;
        r += 1;
        f -= 1;
    }

    r = tr - 1;
    f = tf - 1;
    while (r >= 0 and f >= 0) {
        attack = (1 << (r * 8 + f));
        attacks |= attack;
        if (attack & boardMask != 0)
            break;
        r -= 1;
        f -= 1;
    }

    return attacks;
}

fn maskRookAttacksWithBlock(position: u8, boardMask: u64) u64 {
    var attacks: u64 = 0;
    var attack: u64 = 0;

    var r: i8 = 0;
    var f: i8 = 0;

    const tr: i8 = position >> 3;
    const tf: i8 = position & 7;

    r = tr + 1;
    while (r <= 7) : (r += 1) {
        attack = (1 << (r * 8 + tf));
        attacks |= attack;
        if (attack & boardMask != 0)
            break;
    }
    r = tr - 1;
    while (r >= 0) : (r -= 1) {
        attack = (1 << (r * 8 + tf));
        attacks |= attack;
        if (attack & boardMask != 0)
            break;
    }
    f = tf + 1;
    while (f <= 7) : (f += 1) {
        attack = (1 << (tr * 8 + f));
        attacks |= attack;
        if (attack & boardMask != 0)
            break;
    }
    f = tf - 1;
    while (f >= 0) : (f -= 1) {
        attack = (1 << (tr * 8 + f));
        attacks |= attack;
        if (attack & boardMask != 0)
            break;
    }

    return attacks;
}

fn countBits(board: u64) u8 {
    var count: u8 = 0;
    var board_ = board;
    while (board_ != 0) : (count += 1) {
        board_ &= board_ - 1;
    }
    return count;
}

fn setOccupancy(position: u32, bitCount: u8, attackMask: u64) u64 {
    var occupancy: u64 = 0;
    var attackMask_ = attackMask;

    @setEvalBranchQuota(10000000);
    for (0..bitCount) |count| {
        const square = @ctz(attackMask);
        attackMask_ &= attackMask_ - 1;

        if (position & (1 << count) != 0) {
            occupancy |= 1 << square;
        }
    }
    return occupancy;
}
