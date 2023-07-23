extends Control

@onready var restart_button: Button = $"Restart"
@onready var quit_button: Button = $"Quit"

@export var quit_target: PackedScene = preload("res://scenes/interface/Menu.tscn")

func _ready():
	restart_button.connect("button_up", Callable(self, "_on_restart_button_up"))
	quit_button.connect("button_up", Callable(self, "_on_quit_button_up"))

func _on_restart_button_up() -> void:
	get_tree().reload_current_scene()

func _on_quit_button_up() -> void:
	get_tree().change_scene_to_packed(quit_target)
