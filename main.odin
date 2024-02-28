package game
import rl "vendor:raylib"
import "core:fmt"
import "core:time"
import "core:math"
import "chessboard"

WINDOW_WIDTH :: 1280
WINDOw_HEIGHT :: chessboard.CELL_WIDTH * 8

draw_cell :: proc(cb:^chessboard.ChessBoard, cell: chessboard.BoardCell, tp:^chessboard.TexturePack) {
    rl.DrawRectangleRec(chessboard.cell_to_rectangle(cb, cell), chessboard.cell_color(cell))
    if cell.piece != nil {
        piece := cell.piece
        m := int(cb.config.width / 2)
        rec := chessboard.cell_to_rectangle(cb, cell)
        row := (int(rec.y) + m) - int(tp.width / 2)
        col := (int(rec.x) + m) - int(tp.width / 2)
        rl.DrawTexture(chessboard.select_texture(tp,piece), i32(col), i32(row), rl.WHITE)
    }
}

reset_chessboard :: proc(cb:^chessboard.ChessBoard){
    for i in 0..<len(cb.cells) {
        chessboard.set_default_color(&cb.cells[i])
    }
}
is_mouse_on_cell :: proc(cb: ^chessboard.ChessBoard,cell: ^chessboard.BoardCell, mp: rl.Vector2) -> bool {
    x :=  f32(cb.config.start_pos[0] +  (i32(cell.x) * cb.config.width))
    y := f32(cb.config.start_pos[1] +  (i32(cell.y) * cb.config.width))
    a := mp[0] >= x && mp[0] <= x + f32(cb.config.width)
    b := mp[1] >= y && mp[1] <= y + f32(cb.config.width)
    return a && b 

}
is_mouse_on_cells :: proc(cb: ^chessboard.ChessBoard, mp: rl.Vector2) -> ^chessboard.BoardCell {
    for i in 0..<len(cb.cells) {
        cell := &cb.cells[i]
        if is_mouse_on_cell(cb, cell, mp) {
            return cell
        }
    }
    return nil
}


find_valid_move_from_cell :: proc(cb: ^chessboard.ChessBoard, cell: ^chessboard.BoardCell) {
    for i in 0..<len(cb.cells) {
        c := &cb.cells[i]        
        if c == cell {
            continue
        }
        if chessboard.valid_piece_move(cb, cell,{c.x, c.y}) {
            c.color = c.piece == nil ? .Selected : .Danger            
        }
    }
}

move_piece :: proc(src, dst: ^chessboard.BoardCell) -> ^chessboard.Piece {
    if src == nil || dst == nil || src.piece == nil {
        return nil
    }
    tmp := dst.piece
    dst.piece = src.piece
    src.piece = nil
    return tmp
}

can_move :: proc(scell, tcell: ^chessboard.BoardCell) -> bool {
    a := tcell != nil && scell != nil && scell != tcell && scell.piece != nil && (tcell.color == .Selected || tcell.color == .Danger)
    b := !(a && tcell.piece != nil && tcell.piece.white == scell.piece.white)
    return a && b
}

set_mouse_style :: proc(cell: ^chessboard.BoardCell, turn: bool) -> rl.MouseCursor{
    v := cell != nil && (cell.color == .Selected || cell.color == .Danger || (cell.piece != nil && cell.piece.white == turn))
    return v ? .POINTING_HAND : .DEFAULT
}

draw_eated_pieces :: proc(ep: ^[dynamic]chessboard.Piece, tp: ^chessboard.TexturePack) {
    if len(ep) == 0 {
        return
    }
    width := tp.width * i32( math.ceil(f32(len(ep)) / 8))
    height := f32(tp.width * i32(len(ep) % 9))
    if len(ep) > 8 {
        height = f32(tp.width * 8)
    }
    x :i32= 600
    y :i32= 10
    canva := rl.Rectangle{
        width= f32(width) + 20,
        height=height + 20,
        x=f32(x),
        y=f32(y),
    }

    rl.DrawRectangleRec(canva, rl.RED)
    for piece, i in ep {
        a := x + i32((tp.width) * i32(i/8)) + 10
        b := y + i32((tp.width) * i32(i % 8)) + 10
        rl.DrawTexture(chessboard.select_texture(tp,&piece) ,a, b, rl.WHITE)
    }
}

GameStage :: enum {
    //Intro,
    Game,
    End
} 

GameState :: struct {
    stage: GameStage,
    cb: chessboard.ChessBoard,
    tp: chessboard.TexturePack,
    turn: bool,
    eated_pieces: [dynamic]chessboard.Piece,
    selected_cell: ^chessboard.BoardCell,
    sounds: chessboard.SoundEffects
}

new_game :: proc() -> GameState {
    return GameState {
        cb=chessboard.new_chessboard(),
        tp= chessboard.new_texture_pack(),
        selected_cell=nil,
        eated_pieces=make([dynamic]chessboard.Piece, 0, 10),
        turn=chessboard.WHITE,
        stage=GameStage.Game,
        sounds=chessboard.load_sound(),
    }
}

free_game :: proc(game: ^GameState) {
    chessboard.free_texture_pack(&game.tp)
    chessboard.free_chessboard(&game.cb)
    rl.UnloadAudioStream(game.sounds.capture)
    rl.UnloadAudioStream(game.sounds.move)
    delete(game.eated_pieces)
    game^ = GameState{}
}


draw_game :: proc(game: ^GameState) {
    rl.BeginDrawing()
    rl.ClearBackground(rl.BLUE)
    defer rl.EndDrawing()
    switch game.stage {
        case .Game:
            draw_stage_game(game)
        case .End:
            draw_stage_end(game)
    }
}


draw_stage_end :: proc(game: ^GameState) {
    reset_chessboard(&game.cb)
    for cell in game.cb.cells {
        draw_cell(&game.cb, cell, &game.tp)
    }
    rl.DrawRectangle(0, 0, WINDOW_WIDTH, WINDOw_HEIGHT, {200,200,200, 129})
    mid_pos :[2]i32= {WINDOW_WIDTH / 4, (WINDOw_HEIGHT / 4)}
    txt :cstring= "END, Restart ?"
    rl.DrawText(txt, mid_pos[0] ,mid_pos[1] , 64, rl.RED)
    yes_button := rl.Rectangle{f32(mid_pos[0] + 100),f32(mid_pos[1] + 64) ,96, 64}
    no_button := rl.Rectangle{f32(mid_pos[0]) + 96 + 100 + 32,f32(mid_pos[1] + 64) ,96, 64}
    mp := rl.GetMousePosition()
    rl.GuiButton(yes_button, "YES")
    rl.GuiButton(no_button, "NO")
    if mp[0] > yes_button.x &&  mp[0] < (yes_button.x + yes_button.width) && mp[1] > yes_button.y && mp[1] < (yes_button.y + yes_button.height) {
        if rl.IsMouseButtonPressed(.LEFT) {
            free_game(game)
            game^ = new_game()
            game.stage = .Game
        }
    }
    if mp[0] > no_button.x &&  mp[0] < (no_button.x + no_button.width) && mp[1] > no_button.y && mp[1] < (no_button.y + no_button.height) {
        if rl.IsMouseButtonPressed(.LEFT) {
            rl.CloseWindow()
        }
    }
    
}
draw_stage_game :: proc(game: ^GameState) {
    mouse_pos := rl.GetMousePosition()
    reset_chessboard(&game.cb)
    mouse_clicked := rl.IsMouseButtonPressed(.LEFT)
    hovered_cell := is_mouse_on_cells(&game.cb, mouse_pos)
    find_valid_move_from_cell(&game.cb, game.selected_cell)
    if mouse_clicked {
        if can_move(game.selected_cell, hovered_cell) {
            if piece := move_piece(game.selected_cell, hovered_cell); piece != nil {
                append(&game.eated_pieces, piece^)
                free(piece)
                rl.PlaySound(game.sounds.capture)
            }
            game.selected_cell = nil
            game.turn = !game.turn
            rl.PlaySound(game.sounds.move)
        } else if hovered_cell != nil && hovered_cell.piece != nil && hovered_cell.piece.white == game.turn {
            game.selected_cell = hovered_cell
        }   
    }
    king_present := 0
    for cell in game.cb.cells {
        if cell.piece != nil && cell.piece.type == .King {
            king_present += 1
        }
        draw_cell(&game.cb, cell, &game.tp)
    }
    draw_eated_pieces(&game.eated_pieces,&game.tp)
    if king_present != 2 {
        game.stage = .End
        rl.SetMouseCursor(.DEFAULT)
        reset_chessboard(&game.cb)
        return
    }
    rl.SetMouseCursor(set_mouse_style(hovered_cell, game.turn))
}

main :: proc() {

    rl.InitWindow(WINDOW_WIDTH, WINDOw_HEIGHT, "Main")
    defer rl.CloseWindow()
    rl.InitAudioDevice()
    game := new_game()
    defer rl.CloseAudioDevice()
    defer free_game(&game)
    rl.SetTargetFPS(60)
    for !rl.WindowShouldClose() {
        draw_game(&game)
    }

}