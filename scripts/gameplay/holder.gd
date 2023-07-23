extends Node2D

class_name Holder

var held_piece: Piece = null : set = set_piece, get = get_piece
var tex_path

func hold(new_piece: Piece) -> Piece:
	if held_piece:
		held_piece.queue_free()
	var return_piece = get_piece()
	set_piece(new_piece)
	return return_piece

func set_piece(new_piece: Piece) -> void:
	held_piece = new_piece
	held_piece.tex_path = tex_path
	held_piece.set_scale(Vector2(0.5, 0.5))
	add_child(held_piece)
	held_piece.global_position = self.global_position
	if held_piece.scene == Main.I_piece:
		held_piece.global_position.y -= 16
	if not held_piece.scene == Main.O_piece and not held_piece.scene == Main.I_piece:
		held_piece.global_position.x += 16

func get_piece() -> Piece:
	return held_piece
