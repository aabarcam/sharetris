extends Label

func _process(_delta):
	set_text("FPS " + String.num(Engine.get_frames_per_second()))
