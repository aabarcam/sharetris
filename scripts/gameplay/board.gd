extends Node2D

class_name Board

var blank_texture = preload("res://assets/blank.png")
var starting_pos: Vector2 = self.position
var left_limit = -10000
var right_limit = 10000
var down_limit = 10000
var size_multiplier = Main.BLOCK_SIZE / 64.0

var matrix: Array = [] : get = get_matrix
var players: int = 1 : set = set_players
var height: int = 20

@export var width: int = 10
@onready var tile_map: TileMap = $"TileMap"

signal line_clear

func _ready() -> void:
	draw_board()
	setup_board()

# Creates an empty board
func setup_board() -> void:
	left_limit = self.starting_pos.x
	right_limit = self.starting_pos.x + width * Main.BLOCK_SIZE
	down_limit = self.starting_pos.y + height * Main.BLOCK_SIZE
	for _i in range(height):
		var column = []
		for _j in range(width):
			column.append([Main.block_state.EMPTY, null])
		matrix.append(column)

# Draws board of empty sprites
func draw_board() -> void:
	for i in range(width):
		for j in range(height):
			tile_map.set_cell(0, Vector2i(i, j), 0, Vector2i.ZERO)

# Prints state of board as a matrix
func print_state(option: int=0) -> void:
	printraw('\n')
	var to_print
	for row in matrix:
		for col in row:
			if option:
				to_print = col
			else:
				to_print = col[0]
			printraw(to_print)
		printraw('\n')

# Checks if current tentative position of piece is available
func available_position(piece):
	for block in piece.blocks.get_children():
		var tentative_global_pos = block.tentative_pos - block.position + block.global_position
#		if (tentative_global_pos.x < self.left_limit or 
#			tentative_global_pos.x > self.right_limit or 
#			tentative_global_pos.y > self.down_limit or
#			cell_occupied(tentative_global_pos, piece)):
#			return false
#	return true
		if (tentative_global_pos.x < self.left_limit or 
			tentative_global_pos.x > self.right_limit or 
			tentative_global_pos.y > self.down_limit):
				return Main.block_state.FIXED

		var cell = cell_content(tentative_global_pos, piece)
		if cell != Main.block_state.EMPTY:
			return cell
	return Main.block_state.EMPTY
	
	# Checks if current position of piece is available
func available_current_position(piece):
	for block in piece.blocks.get_children():
		var global_pos = block.global_position
#		if (tentative_global_pos.x < self.left_limit or 
#			tentative_global_pos.x > self.right_limit or 
#			tentative_global_pos.y > self.down_limit or
#			cell_occupied(tentative_global_pos, piece)):
#			return false
#	return true
		if (global_pos.x < self.left_limit or 
			global_pos.x > self.right_limit or 
			global_pos.y > self.down_limit):
				return Main.block_state.FIXED

		var cell = cell_content(global_pos, piece)
		if cell != Main.block_state.EMPTY:
			return cell
	return Main.block_state.EMPTY

# Checks if matrix cell in a certain position is occupied by a different piece
func cell_occupied(global_pos, piece) -> bool:
	var pos_in_matrix = matrix_pos(global_pos)
	var row = pos_in_matrix[0]
	var col = pos_in_matrix[1]
	var matrix_cel = matrix[row][col]
	return matrix_cel[0] != Main.block_state.EMPTY and matrix_cel[1].get_parent().get_parent() != piece

# Returns state of cell
func cell_content(global_pos, piece) -> int:
	var pos_in_matrix = matrix_pos(global_pos)
	var row = pos_in_matrix[0]
	var col = pos_in_matrix[1]
	var matrix_cel = matrix[row][col]
	if matrix_cel[0] == Main.block_state.EMPTY or matrix_cel[1].get_parent().get_parent() == piece:
		return Main.block_state.EMPTY
	return matrix_cel[0]

# Locks array of blocks in their position, adds them to board matrix
func lock_blocks(blocks: Array, state) -> void:
	for block in blocks:
		var pos = matrix_pos(block.global_position)
		var row = pos[0]
		var col = pos[1]
		if row < 0 and state == Main.block_state.FIXED:
			print("a")
			for player in ControllerManager.player_instances:
				player.game_over()
		self.set_cell(row, col, [state, block])
#	print_state()
	
	if state == Main.block_state.FIXED:
		for block in blocks:
			var pos = matrix_pos(block.global_position)
			var row = pos[0]
			var _col = pos[1]
			if full(row):
				clear(row)

# Checks if line is full
func full(row: int):
	for i in self.width:
		var cell = matrix[row][i]
		if cell[0] != Main.block_state.FIXED:
			return false
	return true

# Clears a line
func clear(row: int):
	for i in self.width:
		delete_block(row, i)
		empty_cell(row, i)
	for r in range(row, -1, -1):
		for c in range(self.width):
			var cell = matrix[r][c]
			if cell[0] == Main.block_state.FIXED:
				cell[1].global_position.y += Main.BLOCK_SIZE
				matrix[r + 1][c] = cell
				empty_cell(r, c)
	line_clear.emit()

func delete_block(row: int, col: int):
	var cell = matrix[row][col]
	cell[1].queue_free()

# Transforms global position inside board to corresponding cell
func matrix_pos(global_pos: Vector2) -> Array:
	var block_pos = global_pos - self.global_position
	var row = ceil(block_pos.y / Main.BLOCK_SIZE) - 1
	var col = ceil(block_pos.x / Main.BLOCK_SIZE) - 1
	return [row, col]

# Returns row of first empty cell in given column
func first_empty(column: int, block: Block) -> int:
	var last_occupied_row = last_occupied(column, block)
	return last_occupied_row[0] - 1

# Returns last occupied row and cell from bottom up
func last_occupied(column: int, block: Block) -> Array:
	var block_row = matrix_pos(block.global_position)[0]
	var last_block = null
	var last_occupied_row = height
	var row = height - 1
	while row >= block_row:
		#if (matrix[row][column][0] == Main.block_state.FIXED and 
		if (matrix[row][column][0] != Main.block_state.EMPTY and 
			block.get_parent().get_parent() != matrix[row][column][1].get_parent().get_parent()):
			last_occupied_row = row
			last_block = matrix[row][column]
		row -= 1
	return [last_occupied_row, last_block]
	

# Sets group of cells to its default empty value
func empty_cells(blocks) -> void:
	for block in blocks:
		var block_pos = matrix_pos(block.global_position)
		var row = block_pos[0]
		var col = block_pos[1]
		empty_cell(row, col)

# Sets a single cell to its default empty value
func empty_cell(row, col):
	set_cell(row, col, [Main.block_state.EMPTY, null])

# Calls queue free on all blocks locked in board
func free_matrix() -> void:
	for row in matrix:
		for col in row:
			if col[0] != Main.block_state.EMPTY:
				col[1].queue_free()

# Modifies values in a single cell of the matrix
func set_cell(row: int, col: int, pair: Array) -> void:
	matrix[row][col] = pair

func get_matrix() -> Array:
	return matrix

func get_height() -> int:
	return height

func get_width() -> int:
	return width

func set_players(new_players: int) -> void:
	players = new_players
	width = 6 + 4 * players

func set_board_position(new_pos: Vector2) -> void:
	position = new_pos
	left_limit = new_pos.x
	right_limit = new_pos.x + width * Main.BLOCK_SIZE
	down_limit = new_pos.y + height * Main.BLOCK_SIZE
