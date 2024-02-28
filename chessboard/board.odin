package chessboard
import rl "vendor:raylib"

START_BOARD_SIZE :: 32
MAX_BOARD_SIZE :: 64
WHITE :: true
BLACK :: false
MAX_COLUMN :: 8
MAX_ROW :: 8
CELL_WIDTH :: 64

BoardColor :: enum {
    Gray,
    White,
    Selected,
    Danger
}

BoardCell :: struct {
    color: BoardColor,
    piece: ^Piece,
    x: int,
    y: int,
}

PieceType :: enum {
    Knight,
    King,
    Queen,
    Bishop,
    Rook,
    Pawn
}

Piece :: struct {
    type: PieceType,
    white: bool,
}


ChessBoard :: struct {
   // pieces: [dynamic]Piece,
    turn: bool,
    cells: [dynamic]BoardCell,
    config:BoardConfiguration
}

BoardConfiguration :: struct {
    width: i32,
    image_width: i32,
    start_pos: [2]i32
}

TexturePack :: struct {
    width: i32,
    rook: rl.Texture2D,
    rookb: rl.Texture2D,
    pawn: rl.Texture2D,
    pawnb: rl.Texture2D,
    knight:rl.Texture2D,
    knightb: rl.Texture2D,
    bishop:rl.Texture2D,
    bishopb: rl.Texture2D,
    king:rl.Texture2D,
    kingb: rl.Texture2D,
    queen:rl.Texture2D,
    queenb: rl.Texture2D,
}