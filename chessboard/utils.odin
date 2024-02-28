package chessboard
import rl "vendor:raylib"
import "core:fmt"
import "core:math"

Pos :: struct {
    x, y: int
}

@(private)
valid_pawn_move :: proc(cb: ^ChessBoard, cell: ^BoardCell, pos: Pos) -> bool {
    start := cell.piece.white ? cell.y == 6 : cell.y == 1

    x : int = math.abs(cell.x - pos.x)
    if pos.x != cell.x && !(x > 0.0 && x <= 1.0) {
        return false
    }
    y := cell.piece.white ?  cell.y - pos.y : pos.y - cell.y
    if y <= 0 || (start && y > 2) || (!start && y > 1) {
        return false
    }
    for i in 0..<len(cb.cells) {
        c := &cb.cells[i]
        if c == cell || !(c.x == pos.x && c.y == pos.y){
            continue
        }
        if c.piece != nil && c.piece.white == cell.piece.white {
            return false
        }
        if c.x != cell.x {
            return y == 1 && c.piece != nil && c.piece.white != cell.piece.white
        }
        if y == 1 {
            return c.piece == nil
        }
        for val in cb.cells {
            if val.piece == nil || val.x != cell.x || val == cell^ || val == c^{
                continue
            }
            dy := cell.piece.white ?  cell.y - val.y : val.y - cell.y
            if dy > 0 && dy < y {
                return false
            }
        }
        return true
    }
    return false
}

@(private)
valid_rook_move :: proc(cb: ^ChessBoard, cell: ^BoardCell, pos: Pos) -> bool {
    if !((cell.x == pos.x && cell.y != pos.y) || (cell.x != pos.x && cell.y == pos.y)) {
        return false
    }
    found_pos :^BoardCell
    for c,i in cb.cells {
        if c.x == pos.x && c.y == pos.y {
            found_pos = &cb.cells[i]
            continue
        }
        if c.y == pos.y && c.piece != nil {
            if c.x > cell.x && pos.x > cell.x && c.x < pos.x {
                return false
            }
            if c.x < cell.x && pos.x < cell.x && c.x > pos.x {
                return false
            }
        }else if c.x == pos.x && c.piece != nil {
            if c.y > cell.y && pos.y > cell.y && c.y < pos.y {
                return false
            }
            if c.y < cell.y && pos.y < cell.y && c.y > pos.y {
                return false
            }
        }
    }
    return found_pos.piece == nil || found_pos.piece.white != cell.piece.white
}

@(private)
is_same_direction :: proc(cell,c, pos:Pos ) -> bool {
    if (c.x < cell.x && pos.x < cell.x) && (c.y < cell.y && pos.y < cell.y)  {
        return true
    }
    // up right
    if (c.x < cell.x && pos.x < cell.x) && (c.y > cell.y && pos.y > cell.y) {
        return true
    }
    // down left
    if (c.x > cell.x && pos.x > cell.x) && (c.y < cell.y && pos.y < cell.y) {
        return true
    }
    // down right
    if (c.x > cell.x && pos.x > cell.x) && (c.y > cell.y && pos.y > cell.y) {
        return true
    }
    return false
}



@(private)
valid_bishop_move :: proc(cb: ^ChessBoard, cell: ^BoardCell, pos: Pos) -> bool {
    b := cell.y - pos.y
    a := cell.x - pos.x
    
    if math.abs(a) != math.abs(b) {
        return false
    }
    dstp := (a*a) + b*b
    for c, i in cb.cells {
        b = cell.y - c.y
        a = cell.x - c.x
        if (math.abs(a) != math.abs(b)) {
            continue
        }
        if c.x == pos.x && c.y == pos.y && c.piece != nil &&  c.piece.white == cell.piece.white {
            return false
        }
        d :=  a*a + b*b
        // upleft
        if is_same_direction({x=cell.x,y=cell.y},{x=c.x,y=c.y}, pos) {
            if c.piece != nil && d < dstp {
                return false
            }
        }
    }
    return true

}

@(private)
valid_knight_move :: proc(cb: ^ChessBoard, cell: ^BoardCell, pos: Pos) -> bool {
    dx := math.abs(cell.x - pos.x)
    dy := math.abs(cell.y - pos.y)
    if !((dx == 2 && dy == 1) || (dx == 1 && dy == 2)) {
        return false
    } 
    for c in cb.cells {
        if c.x == pos.x && c.y == pos.y {
            return c.piece == nil || (c.piece.white != cell.piece.white)
        }
    }
    return true
}

@(private)
valid_king_move :: proc(cb: ^ChessBoard, cell: ^BoardCell, pos: Pos) -> bool {
    dx := math.abs(cell.x - pos.x)
    dy := math.abs(cell.y - pos.y)
    if !(dx <= 1 && dy <= 1) {
        return false
    }
    for c in cb.cells {
        if c.x == pos.x && c.y == pos.y && c.piece != nil {
            return c.piece.white != cell.piece.white
        }
    }
    return true
}

valid_piece_move :: proc(cb: ^ChessBoard, cell: ^BoardCell, pos: Pos) -> bool {
    if cell == nil {
        return false
    }
    #partial switch cell.piece.type {
        case .Pawn:
            return valid_pawn_move(cb, cell, pos)
        case .Bishop:
            return valid_bishop_move(cb,cell, pos)
        case .Rook:
            return valid_rook_move(cb, cell, pos)
        case .Queen:
            return valid_bishop_move(cb,cell,pos) || valid_rook_move(cb,cell,pos)
        case .Knight:
            return valid_knight_move(cb, cell, pos)
        case .King:
            return valid_king_move(cb, cell, pos)
    }
    return false
}


cell_to_rectangle :: proc(cb: ^ChessBoard,cell: BoardCell) -> rl.Rectangle {
    width := f32(cb.config.width)
    col := cb.config.start_pos[0] + (i32(cell.x) * cb.config.width)
    row := cb.config.start_pos[1] + (i32(cell.y) * cb.config.width)
    return rl.Rectangle {
        x=f32(col),
        y=f32(row),
        height = width,
        width = width,
    }
}

cell_color :: proc(cell: BoardCell) -> rl.Color {
    switch cell.color {
        case .Gray:
            return rl.GRAY
        case .Selected:
            return rl.ORANGE
        case .Danger:
            return rl.RED

        case .White:
            return rl.WHITE
        case:
            return rl.WHITE
    }
}

set_default_color:: proc(cell: ^BoardCell) {
    cell.color = BoardColor.Gray
    if (cell.y % 2) == (cell.x % 2) {
        cell.color = BoardColor.White
    }
}