extends Control

@onready var resume_button: Button = $"Resume"
@onready var quit_button: Button = $"Quit"

@export var quit_target: PackedScene = preload("res://scenes/interface/Menu.tscn")

func _ready():
	resume_button.connect("button_up", Callable(self, "_on_resume_button_up"))
	quit_button.connect("button_up", Callable(self, "_on_quit_button_up"))

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if not get_tree().paused:
			pause()
		else:
			unpause()

func pause():
	self.show()
	get_tree().paused = true

func unpause():
	self.hide()
	get_tree().paused = false

func _on_resume_button_up() -> void:
	unpause()

func _on_quit_button_up() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(quit_target)
