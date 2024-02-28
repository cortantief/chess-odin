package chessboard
import rl "vendor:raylib"
import "core:fmt"





@(private)
new_cells :: proc() -> [dynamic]BoardCell {
    cells := make([dynamic]BoardCell, 0, MAX_BOARD_SIZE)
    for col in 0..<8 {
        append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Pawn, white=BLACK}), x=col,y=1})
        append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Pawn, white=WHITE}), x=col,y=6})
    }
    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Rook, white=BLACK}), x=0,y=0})
    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Rook, white=BLACK}), x=7,y=0})
    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Rook, white=WHITE}), x=0,y=7})
    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Rook, white=WHITE}), x=7,y=7})

    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Knight, white=BLACK}), x=1,y=0})
    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Knight, white=BLACK}), x=6,y=0})
    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Knight, white=WHITE}), x=1,y=7})
    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Knight, white=WHITE}), x=6,y=7})

    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Bishop, white=BLACK}), x=2,y=0})
    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Bishop, white=BLACK}), x=5,y=0})
    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Bishop, white=WHITE}), x=2,y=7})
    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Bishop, white=WHITE}), x=5,y=7})

    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.King, white=BLACK}), x=3,y=0})
    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Queen, white=BLACK}), x=4,y=0})
    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.King, white=WHITE}), x=4,y=7})
    append(&cells, BoardCell{piece=new_clone(Piece{type=PieceType.Queen, white=WHITE}), x=3,y=7})
    for row in  2..<6 {
        for col in 0..<8 {
            append(&cells, BoardCell{x=int(col), y=int(row), piece=nil})
        }        
    }

    return cells
}

new_chessboard :: proc() -> ChessBoard{
    //append(&pieces, Piece{type=PieceType.Rook, white=WHITE, x=0,y=0})
    config := BoardConfiguration {
        width=CELL_WIDTH,
        start_pos={0,0},
    }
    return ChessBoard {
      //  pieces= new_pieces(),
        turn=WHITE,
        cells=new_cells(),
        config=config,
    }
}

load_rook_texture :: proc (tp: ^TexturePack) {
    img := rl.LoadImage("ressources/rook_b.png")
    rl.ImageResize(&img, tp.width, tp.width)
    tp.rookb = rl.LoadTextureFromImage(img)
    rl.UnloadImage(img)
    img = rl.LoadImage("ressources/rook.png")
    defer rl.UnloadImage(img)
    rl.ImageResize(&img, tp.width, tp.width)
    tp.rook = rl.LoadTextureFromImage(img)
}

load_pawn_texture :: proc (tp: ^TexturePack) {
    img := rl.LoadImage("ressources/pawn_b.png")
    rl.ImageResize(&img, tp.width, tp.width)
    tp.pawnb = rl.LoadTextureFromImage(img)
    rl.UnloadImage(img)
    img = rl.LoadImage("ressources/pawn.png")
    defer rl.UnloadImage(img)
    rl.ImageResize(&img, tp.width, tp.width)
    tp.pawn = rl.LoadTextureFromImage(img)
}

load_knight_texture :: proc (tp: ^TexturePack) {
    img := rl.LoadImage("ressources/knight_b.png")
    rl.ImageResize(&img, tp.width, tp.width)
    tp.knightb = rl.LoadTextureFromImage(img)
    rl.UnloadImage(img)
    img = rl.LoadImage("ressources/knight.png")
    defer rl.UnloadImage(img)
    rl.ImageResize(&img, tp.width, tp.width)
    tp.knight = rl.LoadTextureFromImage(img)
}

load_bishop_texture :: proc (tp: ^TexturePack) {
    img := rl.LoadImage("ressources/bishop_b.png")
    rl.ImageResize(&img, tp.width, tp.width)
    tp.bishopb = rl.LoadTextureFromImage(img)
    rl.UnloadImage(img)
    img = rl.LoadImage("ressources/bishop.png")
    defer rl.UnloadImage(img)
    rl.ImageResize(&img, tp.width, tp.width)
    tp.bishop = rl.LoadTextureFromImage(img)
}

load_king_texture :: proc (tp: ^TexturePack) {
    img := rl.LoadImage("ressources/king_b.png")
    rl.ImageResize(&img, tp.width, tp.width)
    tp.kingb = rl.LoadTextureFromImage(img)
    rl.UnloadImage(img)
    img = rl.LoadImage("ressources/king.png")
    defer rl.UnloadImage(img)
    rl.ImageResize(&img, tp.width, tp.width)
    tp.king = rl.LoadTextureFromImage(img)
}

load_queen_texture :: proc (tp: ^TexturePack) {
    img := rl.LoadImage("ressources/queen_b.png")
    rl.ImageResize(&img, tp.width, tp.width)
    tp.queenb = rl.LoadTextureFromImage(img)
    rl.UnloadImage(img)
    img = rl.LoadImage("ressources/queen.png")
    defer rl.UnloadImage(img)
    rl.ImageResize(&img, tp.width, tp.width)
    tp.queen = rl.LoadTextureFromImage(img)
}

new_texture_pack :: proc() -> TexturePack {
    tp := TexturePack {width=46}
    load_rook_texture(&tp)
    load_pawn_texture(&tp)
    load_knight_texture(&tp)
    load_bishop_texture(&tp)
    load_king_texture(&tp)
    load_queen_texture(&tp)
    return tp
}

free_texture_pack :: proc(tp: ^TexturePack) {
    rl.UnloadTexture(tp.rook)
    rl.UnloadTexture(tp.rookb)

    rl.UnloadTexture(tp.pawn)
    rl.UnloadTexture(tp.pawnb)

    rl.UnloadTexture(tp.knight)
    rl.UnloadTexture(tp.knightb)

    rl.UnloadTexture(tp.bishop)
    rl.UnloadTexture(tp.bishopb)

    rl.UnloadTexture(tp.king)
    rl.UnloadTexture(tp.kingb)

    rl.UnloadTexture(tp.queen)
    rl.UnloadTexture(tp.queenb)
}

select_texture :: proc(tp: ^TexturePack, p: ^Piece) -> rl.Texture2D {
    switch p.type {
        case .King:
            return p.white ? tp.king : tp.kingb
        case .Knight:
            return p.white ? tp.knight : tp.knightb
        case .Pawn:
            return p.white ? tp.pawn : tp.pawnb
        case .Queen:
            return p.white ? tp.queen : tp.queenb
        case .Bishop:
            return p.white ? tp.bishop : tp.bishopb
        case .Rook:
            return  p.white ? tp.rook : tp.rookb
    }
    return p.white ? tp.pawn : tp.pawnb
}

free_chessboard :: proc(cb: ^ChessBoard) {
    for cell in cb.cells {
        free(cell.piece)
    }
    delete(cb.cells)
}

SoundEffects :: struct {
    move:rl.Sound,
    capture: rl.Sound
}

load_sound :: proc() -> SoundEffects {
    return SoundEffects {
        move=rl.LoadSound("ressources/move-self.mp3"),
        capture=rl.LoadSound("ressources/capture.mp3"),
    }
}