extends Node2D

class_name Dealer

var rng = RandomNumberGenerator.new()
var next_pieces: Array = []
var current_next: Piece
var tex_suffix: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	for _i in range(5):
		var new_piece = deal()
		next_pieces.append(new_piece)

# Return next piece and cycle
func cycle():
	var next_piece = next_pieces.pop_front()
	var new_piece = deal()
	next_pieces.append(new_piece)
	show_next()
	return next_piece

# Returns one random piece
func deal():
	return Main.pieces[random()]

# Returns one random number between 0 and 6
func random() -> int:
	return rng.randi_range(0, 6)

func show_next() -> void:
	if current_next:
		current_next.queue_free()
	current_next = next_pieces.front().instantiate()
	if tex_suffix != "":
		current_next.tex_suffix = tex_suffix
	current_next.set_scale(Vector2(0.5, 0.5))
	add_child(current_next)
	if current_next.scene == Main.I_piece:
		current_next.global_position.y -= 16
	if not current_next.scene == Main.O_piece and not current_next.scene == Main.I_piece:
		current_next.global_position.x += 16

func set_tex_suffix(new_tex_suffix) -> void:
	tex_suffix = new_tex_suffix
	show_next()
	
