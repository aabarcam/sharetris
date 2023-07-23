extends Control

@onready var back_button: Button = $"Back"

# Called when the node enters the scene tree for the first time.
func _ready():
	back_button.connect("button_up", Callable(self, "_on_back_button_up"))

func _on_back_button_up() -> void:
	get_tree().change_scene_to_file("res://scenes/interface/Menu.tscn")
