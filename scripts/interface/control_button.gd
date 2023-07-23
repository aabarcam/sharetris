extends Button

func _ready():
	#warning-ignore:return_value_discarded
	connect("button_up",Callable(self,"_on_button_pressed"))

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/interface/controls.tscn")
