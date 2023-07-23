extends Node2D

class_name Piece

@onready var ini_pos = self.global_position
@onready var blocks = $"blocks"
@onready var rot_pos = blocks.position
@onready var tentative_rot_pos = rot_pos

#var tex_suffix: String
var tex: Texture2D = preload("res://assets/icon.png")
var tex_path: String = "res://assets/blocks/default/"
var block_scene = preload("res://scenes/block.tscn")
var rotation_state = 0
var tentative_rotation_state = rotation_state
var ghost_y
#var scene = null

var zero_to_one = [[],												# basic rotation
				[Main.moves.LEFT],									# test 2
				[Main.moves.LEFT, Main.moves.UP],					# test 3
				[Main.moves.DOWN, Main.moves.DOWN],					# test 4
				[Main.moves.LEFT, Main.moves.DOWN, Main.moves.DOWN]	# test 5
				]
var one_to_zero = [[],												# basic rotation
				[Main.moves.RIGHT],									# test 2
				[Main.moves.RIGHT, Main.moves.DOWN],				# test 3
				[Main.moves.UP, Main.moves.UP],						# test 4
				[Main.moves.RIGHT, Main.moves.UP, Main.moves.UP]	# test 5
				]
var one_to_two = one_to_zero
var two_to_one = zero_to_one
var two_to_three = [[],													# basic rotation
					[Main.moves.RIGHT],									# test 2
					[Main.moves.RIGHT, Main.moves.UP],					# test 3
					[Main.moves.DOWN, Main.moves.DOWN],					# test 4
					[Main.moves.RIGHT, Main.moves.DOWN, Main.moves.DOWN]# test 5
				]
var three_to_two = [[],													# basic rotation
					[Main.moves.LEFT],									# test 2
					[Main.moves.LEFT, Main.moves.DOWN],					# test 3
					[Main.moves.UP, Main.moves.UP],						# test 4
					[Main.moves.LEFT, Main.moves.UP, Main.moves.UP]		# test 5
				]
var three_to_zero = three_to_two
var zero_to_three = two_to_three
var wall_kicks: Array = [
						[[],			 zero_to_one, [], 			zero_to_three],
						[one_to_zero,	 [], 		  one_to_two,	[]],
						[[], 			 two_to_one,  [], 			two_to_three],
						[three_to_zero, [], 		  three_to_two, []]
						]

func _ready() -> void:
	set_tex(tex_path)
	tex_init()
	adjust_size()

#func _draw():
#	if ghost_y:
#		draw_circle(Vector2(0, self.ghost_y), 10, Color(1,1,1))
#	for block in self.get_blocks():
#		draw_circle(block.tentative_pos, 10, Color(1, 1, 1))
#
#func _process(_delta):
#	print(self.ghost_y)
#	queue_redraw()

func reset_tentative_pos() -> void:
	tentative_rot_pos = rot_pos
	for block in self.get_blocks():
		block.tentative_pos = block.position

func reset_tentative_state() -> void:
	tentative_rotation_state = rotation_state

# Checks if piece is able to be placed after a series of moves
func try_move(board: Board, move_list: Array) -> int:
	for single_move in move_list:
		match single_move:
			Main.moves.UP:
				try_move_up()
			Main.moves.DOWN:
				try_move_down()
			Main.moves.LEFT:
				try_move_left()
			Main.moves.RIGHT:
				try_move_right()
	var can_move = board.available_position(self)
	return can_move

# Checks if piece is able to move up
func try_move_up() -> void:
	tentative_rot_pos.y -= Main.BLOCK_SIZE
	for block in self.get_blocks():
		block.try_move_up()

# Checks if piece is able to move down
func try_move_down() -> void:
	tentative_rot_pos.y += Main.BLOCK_SIZE
	for block in self.get_blocks():
		block.try_move_down()

# Checks if piece is able to move left
func try_move_left() -> void:
	tentative_rot_pos.x -= Main.BLOCK_SIZE
	for block in self.get_blocks():
		block.try_move_left()

# Checks if piece is able to move right
func try_move_right() -> void:
	tentative_rot_pos.x += Main.BLOCK_SIZE
	for block in self.get_blocks():
		block.try_move_right()

# Moves piece towards tentative position
func move(board: Board, directions: Array) -> int:
	var can_move = try_move(board, directions)
	if can_move == Main.block_state.EMPTY:
		rot_pos = tentative_rot_pos
		board.empty_cells(self.get_blocks())
		for block in self.get_blocks():
			block.move()
		board.lock_blocks(self.get_blocks(), Main.block_state.MOVING)
	reset_tentative_pos()
	return can_move

# Places piece on location of ghost piece
#func move_to_ghost(board: Board) -> void:
#	board.empty_cells(self.get_blocks())
#	for block in self.get_blocks():
#		block.global_position = block.ghost.global_position
#		block.ghost.global_position = block.global_position
#		block.tentative_pos = block.position
#		block.move()
#	reset_tentative_pos()
#	board.lock_blocks(self.get_blocks(), Main.block_state.MOVING)
func move_to_ghost(board: Board) -> void:
	var moves = []
	moves.resize(ghost_y)
	moves.fill(Main.moves.DOWN)
	move(board, moves)
	set_ghost_pos(board)

# Initializes block textures with piece texture
func tex_init() -> void:
	for block in self.get_blocks():
		block.set_tex(tex)

# If possible, rotate a piece by a given angle
func do_rotate(angle: float, board: Board) -> void:
	if try_rotate(angle, board):
		board.empty_cells(self.get_blocks())
		for block in self.get_blocks():
			block.move()
		board.lock_blocks(self.get_blocks(), Main.block_state.MOVING)
		set_ghost_pos(board)
	reset_tentative_state()
	reset_tentative_pos()

# Try rotating piece by a given angle
func try_rotate(angle: float, board: Board) -> bool:
	tentative_rotation_state = fposmod(rotation_state + int(sign(angle)), 4)
	for block in self.get_blocks():
		var block_pos = block.tentative_pos + blocks.position - self.rot_pos
		var new_x = block_pos.x * cos(angle) - block_pos.y * sin(angle)
		var new_y = block_pos.x * sin(angle) + block_pos.y * cos(angle)
		block.temporal_tentative_pos = Vector2(new_x, new_y) - blocks.position + self.rot_pos
	
	var can_move
	for moves in wall_kicks[rotation_state][tentative_rotation_state]:
		reset_tentative_pos()
		for block in self.get_blocks():
			block.tentative_pos = block.temporal_tentative_pos
		#warning-ignore:return_value_discarded
		try_move(board, moves)
		can_move = board.available_position(self)
#		if can_move:
		if can_move == Main.block_state.EMPTY:
			rot_pos = tentative_rot_pos
			rotation_state = tentative_rotation_state
			return true
	return false

# Rotate piece clockwise
func rotate_clockwise(board) -> void:
	self.do_rotate(PI/2, board)
	
# Rotate piece counterclockwise
func rotate_counter_clockwise(board) -> void:
	self.do_rotate(-PI/2, board)

# Reset piece position and values
func reset() -> void:
	rot_pos = blocks.position
	tentative_rot_pos = rot_pos
	rotation_state = 0
	tentative_rotation_state = rotation_state
	for block in get_blocks():
		block.return_to_original_position()

# Return block with the lowest position
func get_lowest_block() -> Block:
	var lowest = null
	for block in self.get_blocks():
		if lowest == null or block.position.y > lowest.position.y:
			lowest = block
	return lowest

# Set ghost position
func set_ghost_pos(board: Board) -> void:
	var offset = INF
	for block in self.get_blocks():
		var cell = board.matrix_pos(block.global_position)
		var row = cell[0]
		var col = cell[1]
		var lowest_available = board.first_empty(col, block)
		offset = min(offset, max(0, lowest_available - row))
		
	for block in self.get_blocks():
		block.ghost.position.y = offset * Main.BLOCK_SIZE
	ghost_y = offset

# To be overriden, instances a new piece
func new_instance():
	var instance = self.scene.instantiate()
	instance.tex_suffix = self.tex_suffix
	return instance

# Sets current texture
func set_tex(path: String) -> void:
	self.tex = load(path + self.tex_suffix + '.png')

# Adjust size of all block sprites and positions depending on texture size
func adjust_size() -> void:
	rot_pos = blocks.position
	tentative_rot_pos = rot_pos

# Gets all blocks in a list
func get_blocks():
	return blocks.get_children()

func _exit_tree():
	for block in self.get_blocks():
		block.queue_free()
