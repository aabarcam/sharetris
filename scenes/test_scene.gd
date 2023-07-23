extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("debug_spawn"):
		var rd = randi_range(0, 6)
		var piece = Main.pieces[rd]
		var piece_instance = piece.instantiate()
		piece_instance.global_position = Vector2(300, 300)
		add_child(piece_instance)
