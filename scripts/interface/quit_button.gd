extends Button

func _ready():
	#warning-ignore:return_value_discarded
	connect("button_up",Callable(self,"_on_button_pressed"))

func _on_button_pressed():
	get_tree().quit()
