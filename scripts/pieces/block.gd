extends Node2D

class_name Block

var original_position: Vector2 = self.global_position
var tex: Texture2D = preload("res://assets/icon.png") : set = set_tex
var ghost_tex: Texture2D = tex
var size: float = Main.get_block_size() : set = set_size
var temporal_tentative_pos: Vector2
var tentative_pos: Vector2
var ghost = Sprite2D.new()

@onready var sprite: Sprite2D = get_node("block_sprite")

func _ready():
	tentative_pos = self.position
	
	# Create ghost
	add_child(ghost)
	ghost.modulate.a = 0.5

# Moves tentative new pos up
func try_move_up() -> void:
	tentative_pos.y -= size

# Moves tentative new pos down
func try_move_down() -> void:
	tentative_pos.y += size

# Moves tentative new pos left
func try_move_left() -> void:
	tentative_pos.x -= size

# Moves tentative new pos right
func try_move_right() -> void:
	tentative_pos.x += size

# Moves block to tentative position
func move() -> void:
	self.position = tentative_pos

# Returns block to original position
func return_to_original_position() -> void:
	pass
#	tentative_pos = original_position
#	self.position = original_position

# Returns block texture
func get_texture() -> Texture2D:
	return sprite.texture

# Sets block texture
func set_tex(new_tex) -> void:
	tex = new_tex
	ghost_tex = new_tex
	set_size(Main.get_block_size())
	sprite.texture = tex
	ghost.texture = ghost_tex

# Sets texure size
func set_size(new_size) -> void:
	size = new_size

func _exit_tree():
	if ghost != null:
		ghost.queue_free()
