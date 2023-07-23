extends Node

enum block_state {EMPTY, MOVING, FIXED}
enum moves {UP, DOWN, LEFT, RIGHT}

const BLOCK_SIZE: float = 64.0

var shared_dealer = false
var shared_holder = false

# Pieces
var I_piece = preload("res://scenes/pieces/I_piece.tscn")
var J_piece = preload("res://scenes/pieces/J_piece.tscn")
var L_piece = preload("res://scenes/pieces/L_piece.tscn")
var O_piece = preload("res://scenes/pieces/O_piece.tscn")
var S_piece = preload("res://scenes/pieces/S_piece.tscn")
var T_piece = preload("res://scenes/pieces/T_piece.tscn")
var Z_piece = preload("res://scenes/pieces/Z_piece.tscn")
# 0:I, 1:J, 2:L, 3:O, 4:S, 5:T, 6:Z
var pieces: Array = [I_piece, J_piece, L_piece, O_piece, S_piece, T_piece, Z_piece]
var colors: Array

func _ready():
	Input.connect("joy_connection_changed",Callable(self,"_on_joy_connection_changed"))
	var dir = DirAccess.open("res://assets/blocks/default")
	colors = Array(dir.get_files()).filter(func(file: String): return file.ends_with("png"))
	for i in range(len(colors)):
		colors[i] = colors[i].trim_suffix(".png")

# Returns target block size
func get_block_size() -> float:
	return BLOCK_SIZE

func _on_joy_connection_changed(device, connected):
	if connected:
		ControllerManager.add_player(device)
	else:
		ControllerManager.remove_player(device)
