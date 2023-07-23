extends Node2D

class_name Player

var dealer: Dealer = null : set = set_dealer
var holder: Holder = null : set = set_holder
var tex_path: String = "res://assets/blocks/default/"
var tex_suffix: String = ""

var board: Board = null : set = set_board
var active_piece: Piece = null
var next_piece: Piece = null
var move_delay: float = 1.0
var tex: Texture2D : set = set_tex
var set_actions = InputMap.get_actions()

var just_moved: int = 0
var pressed = null
var down_ready: bool = true
var horizontal_ready: bool = true
var horizontal_moved: bool = false
var original_horizontal_delay: float = 0.05
var horizontal_delay: float = self.original_horizontal_delay
var move_cd: float = 0.05
var original_lock_time: float = 0.5
var active: bool = false
var is_game_over: bool = false
var held: bool = false

var total_moves_before_lock: int = 15
var moves_before_lock: int = self.total_moves_before_lock
var lowest_reached: int

@export var left_action = "left"
@export var right_action = "right"
@export var down_action = "down"
@export var up_action = "up"
@export var soft_drop_action = "soft_drop"
@export var hard_drop_action = "hard_drop"
@export var hold_action = "hold_piece"
@export var rotate_clockwise_action = "rotate_clockwise"
@export var rotate_counter_clockwise_action = "rotate_counter_clockwise"

@onready var spawn_pos: Marker2D = $"spawn_pos"
@onready var auto_drop_timer: Timer = $"auto_drop_timer"
@onready var down_timer: Timer = $"down_delay"
@onready var lock_timer: Timer = $"lock_delay"
@onready var horizontal_timer: Timer = $"horizontal_timer"

func _ready() -> void:
	ControllerManager.player_instances.append(self)
	set_process(false)

func _process(delta) -> void:
#	if active_piece.rot_pos:
#		print(lowest_reached, ", ", active_piece.rot_pos.y)
	move(delta)

func start() -> void:
	if not active:
		#warning-ignore:return_value_discarded
		auto_drop_timer.connect("timeout",Callable(self,"_on_drop_timer_timeout"))
		#warning-ignore:return_value_discarded
		down_timer.connect("timeout",Callable(self,"_on_down_timer_timeout"))
		#warning-ignore:return_value_discarded
		horizontal_timer.connect("timeout",Callable(self,"_on_horizontal_timer_timeout"))
		horizontal_timer.set_wait_time(0.3)
		#warning-ignore:return_value_discarded
		lock_timer.connect("timeout",Callable(self,"_on_lock_timer_timeout"))
		lock_timer.set_wait_time(original_lock_time)
		lock_timer.start()
		set_process(true)
		cycle()
		active = true

# Initializes player
func init(new_board: Board):
	set_board(new_board)
#	next_piece = dealer.deal()
#	next_piece.set_tex(tex_path)
#	next_piece.position = Vector2(10000, 10000)
#	add_child(next_piece)

# Moves piece
func move(delta) -> void:
	if Input.is_action_just_pressed(hard_drop_action):
		hard_drop()

	if Input.is_action_pressed(soft_drop_action):
		soft_drop()

	if Input.is_action_just_pressed(hold_action):
		hold()

	if not Input.is_action_pressed(left_action) and not Input.is_action_pressed(right_action):
		pressed = null
	elif (Input.is_action_just_pressed(left_action) or
		Input.is_action_just_released(right_action) and Input.is_action_pressed(left_action)):
		pressed = "left"
	elif (Input.is_action_just_pressed(right_action) or
		Input.is_action_just_released(left_action) and Input.is_action_pressed(right_action)):
		pressed = "right"

	if (Input.is_action_just_pressed(left_action) or
		Input.is_action_just_pressed(right_action)):
			reset_horizontal_movement()
			just_moved = 0
	if (Input.is_action_just_released(left_action) or 
		Input.is_action_just_released(right_action)) and just_moved > 1:
			reset_horizontal_movement()

	if Input.is_action_pressed(left_action) or Input.is_action_pressed(right_action):
		horizontal_delay -= delta

	if Input.is_action_pressed(left_action) and not pressed == "right" and horizontal_delay <= 0:
		move_active_piece_left()
		horizontal_delay = original_horizontal_delay
	elif Input.is_action_pressed(right_action) and horizontal_delay <= 0:
		move_active_piece_right()
		horizontal_delay = original_horizontal_delay

	if Input.is_action_pressed(right_action) and not pressed == "left" and horizontal_delay <= 0:
		move_active_piece_right()
		horizontal_delay = original_horizontal_delay
	elif Input.is_action_pressed(left_action) and horizontal_delay <= 0:
		move_active_piece_left()
		horizontal_delay = original_horizontal_delay

	if Input.is_action_just_pressed(rotate_clockwise_action):
		rotate_clockwise()

	if Input.is_action_just_pressed(rotate_counter_clockwise_action):
		rotate_counter_clockwise()

# Moves active piece to tentative position
func confirm_move(piece) -> void:
	lock_timer.start()
	piece.move(board)

# Attempts to move a piece a certain sequence
func move_piece(piece: Piece, directions: Array):
	if piece.try_move(board, [Main.moves.DOWN]) == Main.block_state.FIXED:
		moves_before_lock -= 1
	piece.reset_tentative_pos()
	if piece.move(board, directions) == Main.block_state.EMPTY and moves_before_lock > 0:
		lock_timer.start(original_lock_time)
	if active_piece.rot_pos.y > lowest_reached:
		lowest_reached = active_piece.rot_pos.y
		moves_before_lock = total_moves_before_lock
	ControllerManager.update_all_ghosts()

# Move active piece left once
func move_active_piece_left() -> void:
	if horizontal_ready:
		just_moved += 1
		move_piece(active_piece, [Main.moves.LEFT])
	if not horizontal_moved:
		horizontal_moved = true
		horizontal_ready = false
		horizontal_timer.start()

# Move active piece right once
func move_active_piece_right() -> void:
	if horizontal_ready:
		just_moved += 1
		move_piece(active_piece, [Main.moves.RIGHT])
	if not horizontal_moved:
		horizontal_moved = true
		horizontal_ready = false
		horizontal_timer.start()

# Move active piece down once
func move_active_piece_down() -> void:
	auto_drop_timer.start(move_delay)
	move_piece(active_piece, [Main.moves.DOWN])

# Rotate active piece clockwise
func rotate_clockwise():
	move_piece(active_piece, [])
	active_piece.rotate_clockwise(board)
	ControllerManager.update_all_ghosts()

# Rotate active piece counter-clockwise
func rotate_counter_clockwise():
	move_piece(active_piece, [])
	active_piece.rotate_counter_clockwise(board)
	ControllerManager.update_all_ghosts()

# Resets horizontal movement flags
func reset_horizontal_movement():
	self.horizontal_moved = false
	self.horizontal_ready = true

# Locks active piece in place
func lock_piece() -> void:
	moves_before_lock = total_moves_before_lock
	lock_timer.start(original_lock_time)
	board.lock_blocks(active_piece.get_blocks(), Main.block_state.FIXED)
	cycle()

# Soft drops current piece
func soft_drop() -> void:
	if self.down_ready:
		down_timer.start(move_cd)
		down_ready = false
		auto_drop_timer.start(move_delay)  # reset auto drop timer
		move_active_piece_down()

# Hard drops current piece
func hard_drop() -> void:
	var legal_move = true
	for block in active_piece.get_blocks():
		var cell = board.matrix_pos(block.global_position)
		var _row = cell[0]
		var col = cell[1]
		var lowest = board.last_occupied(col, block)
		if lowest[1] != null and lowest[1][0] == Main.block_state.MOVING:
			legal_move = false
	active_piece.set_ghost_pos(board)
	active_piece.move_to_ghost(board)
	if legal_move:
		board.lock_blocks(active_piece.get_blocks(), Main.block_state.FIXED)
		cycle()

# Holds current piece
func hold() -> void:
	if held:
		return
	board.lock_blocks(active_piece.get_blocks(), Main.block_state.EMPTY)
	var new_piece = holder.hold(active_piece.new_instance())
	active_piece.queue_free()
	cycle(new_piece)
	held = true

# Cycles to next piece
func cycle(next_piece_cycle=null) -> void:
	if is_game_over:
		return
	if next_piece_cycle == null:
		next_piece = grab_piece().instantiate()
	else:
		next_piece = next_piece_cycle.new_instance()
	held = false
	active_piece = next_piece
	active_piece.transform = spawn_pos.transform
	auto_drop_timer.start(move_delay)
	active_piece.tex_path = self.tex_path
	if tex_suffix != "":
		active_piece.tex_suffix = tex_suffix
		dealer.set_tex_suffix(tex_suffix)
	add_child(active_piece)
	if board.available_current_position(active_piece) != Main.block_state.EMPTY:
		get_parent().game_over()
	board.lock_blocks(active_piece.get_blocks(), Main.block_state.MOVING)
	lowest_reached = active_piece.rot_pos.y
	active_piece.set_ghost_pos(board)

# Gets a piece from the dealer
func grab_piece():
	return dealer.cycle()

func game_over():
	set_process(false)
	is_game_over = true
	auto_drop_timer.stop()
	lock_timer.stop()

# Timer for moving active piece down
func _on_drop_timer_timeout() -> void:
	move_active_piece_down()

# Timer for delaying press of down button
func _on_down_timer_timeout() -> void:
	self.down_ready = true

# Timer for locking a piece
func _on_lock_timer_timeout() -> void:
	if active_piece.try_move(board, [Main.moves.DOWN]) == Main.block_state.FIXED:
		lock_piece()
	active_piece.reset_tentative_pos()

func _on_horizontal_timer_timeout() -> void:
	self.horizontal_ready = true

# Sets texture for player's pieces
func set_tex(new_tex) -> void:
	tex = new_tex

func set_board(new_board: Board) -> void:
	board = new_board

func set_dealer(new_dealer: Dealer) -> void:
	dealer = new_dealer

func set_holder(new_holder: Holder) -> void:
	holder = new_holder
	new_holder.tex_path = self.tex_path

func set_ghost_pos():
	active_piece.set_ghost_pos(board)

func gamepad(gamepad_num: int) -> void:
	left_action += str(gamepad_num)
	if InputMap.has_action(left_action):
		InputMap.erase_action(left_action)
	var left_event: InputEventJoypadButton = InputEventJoypadButton.new()
	left_event.set_device(gamepad_num)
	left_event.set_button_index(JOY_BUTTON_DPAD_LEFT)
	InputMap.add_action(left_action)
	InputMap.action_add_event(left_action, left_event)
	
	right_action += str(gamepad_num)
	if InputMap.has_action(right_action):
		InputMap.erase_action(right_action)
	var right_event: InputEventJoypadButton = InputEventJoypadButton.new()
	right_event.set_device(gamepad_num)
	right_event.set_button_index(JOY_BUTTON_DPAD_RIGHT)
	InputMap.add_action(right_action)
	InputMap.action_add_event(right_action, right_event)
	
	hard_drop_action += str(gamepad_num)
	if InputMap.has_action(hard_drop_action):
		InputMap.erase_action(hard_drop_action)
	var hard_drop_event: InputEventJoypadButton = InputEventJoypadButton.new()
	hard_drop_event.set_device(gamepad_num)
	hard_drop_event.set_button_index(JOY_BUTTON_DPAD_UP)
	InputMap.add_action(hard_drop_action)
	InputMap.action_add_event(hard_drop_action, hard_drop_event)
	
	soft_drop_action += str(gamepad_num)
	if InputMap.has_action(soft_drop_action):
		InputMap.erase_action(soft_drop_action)
	var soft_drop_event: InputEventJoypadButton = InputEventJoypadButton.new()
	soft_drop_event.set_device(gamepad_num)
	soft_drop_event.set_button_index(JOY_BUTTON_DPAD_DOWN)
	InputMap.add_action(soft_drop_action)
	InputMap.action_add_event(soft_drop_action, soft_drop_event)
	
	hold_action += str(gamepad_num)
	if InputMap.has_action(hold_action):
		InputMap.erase_action(hold_action)
	var hold_event: InputEventJoypadButton = InputEventJoypadButton.new()
	hold_event.set_device(gamepad_num)
	hold_event.set_button_index(JOY_BUTTON_RIGHT_SHOULDER)
	InputMap.add_action(hold_action)
	InputMap.action_add_event(hold_action, hold_event)
	
	rotate_clockwise_action += str(gamepad_num)
	if InputMap.has_action(rotate_clockwise_action):
		InputMap.erase_action(rotate_clockwise_action)
	var rotate_clockwise_event: InputEventJoypadButton = InputEventJoypadButton.new()
	rotate_clockwise_event.set_device(gamepad_num)
	rotate_clockwise_event.set_button_index(JOY_BUTTON_B)
	InputMap.add_action(rotate_clockwise_action)
	InputMap.action_add_event(rotate_clockwise_action, rotate_clockwise_event)
	
	rotate_counter_clockwise_action += str(gamepad_num)
	if InputMap.has_action(rotate_counter_clockwise_action):
		InputMap.erase_action(rotate_counter_clockwise_action)
	var rotate_counter_clockwise_event: InputEventJoypadButton = InputEventJoypadButton.new()
	rotate_counter_clockwise_event.set_device(gamepad_num)
	rotate_counter_clockwise_event.set_button_index(JOY_BUTTON_A)
	InputMap.add_action(rotate_counter_clockwise_action)
	InputMap.action_add_event(rotate_counter_clockwise_action, rotate_counter_clockwise_event)

func _exit_tree():
	if next_piece:
		next_piece.queue_free()
	ControllerManager.player_instances.erase(self)
#	board.free_matrix()
