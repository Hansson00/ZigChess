////////////////////////////////////////////////
///  ______           ___ _
/// / _  (_) __ _    / __\ |__   ___  ___ ___
/// \// /| |/ _` |  / /  | '_ \ / _ \/ __/ __|
///  / //\ | (_| | / /___| | | |  __/\__ \__ \
/// /____/_|\__, | \____/|_| |_|\___||___/___/
///         |___/
////////////////////////////////////////////////
/// @brief General string tools
////////////////////////////////////////////////

pub const alphabetSize = 'z' - 'a';

////////////////////////////////////////////////
/// @brief Checks if char is a character in the
///        alphabet
///
/// @param [in] char
/// @return char in alphabet
////////////////////////////////////////////////
pub inline fn isChar(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z');
}

////////////////////////////////////////////////
/// @brief Checks if char is a number
///
/// @param [in] char
/// @return char is a number
////////////////////////////////////////////////
pub inline fn isNumber(c: u8) bool {
    return (c >= '0' and c <= '9');
}

////////////////////////////////////////////////
/// @brief Checks if a character is capital
///
/// @param [in] character from alphabet
/// @return char is capital
////////////////////////////////////////////////
pub inline fn isCapital(c: u8) bool {
    return c < 'a';
}
