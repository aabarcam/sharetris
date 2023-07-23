extends Label

class_name LobbyPlayer

var type: String = ""
var controller_num: int = -1
var color: int = 0
var piece: Piece
var input_map: Dictionary = {}
var lobby

func _ready() -> void:
	text = type
	if controller_num >= 0:
		text += " " + str(controller_num)

func _process(_delta) -> void:
	if type == "Keyboard":
		if Input.is_action_just_pressed("right"):
			lobby.move_to_player(self)
		elif Input.is_action_just_pressed("left"):
			lobby.move_to_spectator(self)
		elif Input.is_action_just_pressed("up"):
			color = (color + 1)%len(Main.colors)
			piece.tex_suffix = Main.colors[color]
			piece._ready()
		elif Input.is_action_just_pressed("down"):
			color = (color - 1)%len(Main.colors)
			piece.tex_suffix = Main.colors[color]
			piece._ready()
	elif type == "Gamepad":
		if Input.is_action_just_pressed("lobby_right_{n}".format({"n":controller_num})):
			lobby.move_to_player(self)
		if Input.is_action_just_pressed("lobby_left_{n}".format({"n":controller_num})):
			lobby.move_to_spectator(self)
		if Input.is_action_just_pressed("lobby_up_{n}".format({"n":controller_num})):
			color = (color + 1)%len(Main.colors)
			piece.tex_suffix = Main.colors[color]
			piece._ready()
		if Input.is_action_just_pressed("lobby_down_{n}".format({"n":controller_num})):
			color = (color - 1)%len(Main.colors)
			piece.tex_suffix = Main.colors[color]
			piece._ready()

func _enter_tree():
	piece = Main.T_piece.instantiate()
	piece.tex_suffix = Main.colors[color]
	piece.set_scale(Vector2(0.25, 0.25))
	piece.set_position(Vector2(224, 36))
	add_child(piece)

func set_type(new_type: String):
	assert(new_type == "Gamepad" or new_type == "Keyboard") #,"ERROR: Invalid player type")
	type = new_type

func set_controller(new_controller_num: int):
	controller_num = new_controller_num
	
	# Add right button
	var right_action: String = "lobby_right_{n}".format({"n":new_controller_num})
	if InputMap.has_action(right_action):
		InputMap.erase_action(right_action)
	var right_action_event: InputEventJoypadButton = InputEventJoypadButton.new()
	right_action_event.set_device(int(new_controller_num))
	right_action_event.set_button_index(JOY_BUTTON_DPAD_RIGHT)
	InputMap.add_action(right_action)
	InputMap.action_add_event(right_action, right_action_event)
	
	# Add left button
	var left_action: String = "lobby_left_{n}".format({"n":new_controller_num})
	if InputMap.has_action(left_action):
		InputMap.erase_action(left_action)
	var left_action_event: InputEventJoypadButton = InputEventJoypadButton.new()
	left_action_event.set_device(int(new_controller_num))
	left_action_event.set_button_index(JOY_BUTTON_DPAD_LEFT)
	InputMap.add_action(left_action)
	InputMap.action_add_event(left_action, left_action_event)
	
	# Add up button
	var up_action: String = "lobby_up_{n}".format({"n":new_controller_num})
	if InputMap.has_action(up_action):
		InputMap.erase_action(up_action)
	var up_action_event: InputEventJoypadButton = InputEventJoypadButton.new()
	up_action_event.set_device(int(new_controller_num))
	up_action_event.set_button_index(JOY_BUTTON_DPAD_UP)
	InputMap.add_action(up_action)
	InputMap.action_add_event(up_action, up_action_event)
	
	# Add down button
	var down_action: String = "lobby_down_{n}".format({"n":new_controller_num})
	if InputMap.has_action(down_action):
		InputMap.erase_action(down_action)
	var down_action_event: InputEventJoypadButton = InputEventJoypadButton.new()
	down_action_event.set_device(int(new_controller_num))
	down_action_event.set_button_index(JOY_BUTTON_DPAD_DOWN)
	InputMap.add_action(down_action)
	InputMap.action_add_event(down_action, down_action_event)

func unset_controller() -> void:
	InputMap.erase_action("lobby_right_{n}".format({"n":controller_num}))
	InputMap.erase_action("lobby_left_{n}".format({"n":controller_num}))
	InputMap.erase_action("lobby_up_{n}".format({"n":controller_num}))
	InputMap.erase_action("lobby_down_{n}".format({"n":controller_num}))

func show_color() -> void:
	piece.visible = true

func hide_color() -> void:
	piece.visible = false

func get_controller() -> int:
	return controller_num

func set_lobby(new_lobby) -> void:
	lobby = new_lobby

func new_name(new_text) -> void:
	self.text = new_text
