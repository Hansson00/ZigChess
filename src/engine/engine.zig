////////////////////////////////////////////////
///  ______           ___ _
/// / _  (_) __ _    / __\ |__   ___  ___ ___
/// \// /| |/ _` |  / /  | '_ \ / _ \/ __/ __|
///  / //\ | (_| | / /___| | | |  __/\__ \__ \
/// /____/_|\__, | \____/|_| |_|\___||___/___/
///         |___/
////////////////////////////////////////////////
/// @brief Engine, runs the application
////////////////////////////////////////////////

const std = @import("std");
const fen = @import("../tools/fen.zig");
const draw = @import("../tools/draw.zig");
const defines = @import("../tools/defines.zig");
const stringTools = @import("../tools/stringTools.zig");
const movePiece = @import("movePiece.zig").movePiece;

const sizeOfInputBuffer = 10;

var boardstate = defines.BoardState.init();

////////////////////////////////////////////////
/// @brief Main loop, handles input and output
////////////////////////////////////////////////
pub fn mainLoop() !void {
    var buffer: [sizeOfInputBuffer]u8 = undefined;
    fen.setFen(&boardstate, fen.baseFenString);
    try draw.printBoard(&boardstate);

    while (true) {
        try getInput(&buffer);
        if (try handleInput(&buffer) == 0) {
            break;
        }
    }
}

////////////////////////////////////////////////
/// @brief Gets an input from stdin on '\n'
///
/// @param [out] output string
////////////////////////////////////////////////
fn getInput(output: []u8) !void {
    const stdin = std.io.getStdIn().reader();
    _ = try stdin.readUntilDelimiter(output, '\n');
}

////////////////////////////////////////////////
/// @brief Handles an input string
///
/// @param [in] string to be handled
///
/// @features:
///         - Make moves
///         - Exit app
////////////////////////////////////////////////
fn handleInput(input: []u8) !u8 {
    switch (input[0]) {
        'a'...'h' => {
            movePiece(&boardstate, stringToMove(input));
            try draw.printBoard(&boardstate);
        },
        'q' => {
            return 0;
        },

        else => {},
    }
    return 1;
}

pub fn stringToMove(input: []u8) u16 {
    var move: u16 = 0;
    var partialMove: u16 = 0;

    for (input) |c| {
        if (c == 0) {
            break;
        }
        if (stringTools.isChar(c)) {
            partialMove = c - 'a';
        } else if (stringTools.isNumber(c)) {
            if (move != 0) {
                move |= ((c - '1') * 8 + partialMove) << 4;
            } else {
                move = (c - '1') * 8 + partialMove;
                partialMove = 0;
            }
        }
    }
    return move;
}
