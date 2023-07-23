extends Node2D

var board: Board
var tile_map: TileMap

var dealer = preload("res://scenes/gameplay/dealer.tscn")
var holder = preload("res://scenes/gameplay/holder.tscn")
var player = preload("res://scenes/gameplay/player.tscn")
var lobbyplayer = preload("res://scenes/interface/LobbyPlayer.tscn")
var board_scene = preload("res://scenes/gameplay/board.tscn")

var started = false
var time_to_start: int = 3
var lines: int = 0
var goal: int = 5

@export var level: int = 1

@onready var game_over_menu = $"game_over_menu"
@onready var line_counter = $"line_counter"
@onready var start_timer = $"start_timer"
@onready var label = $"Label"

func _ready():
#	for i in range(0,6):
#		var p = lobbyplayer.instantiate()
#		p.set_type("Gamepad")
#		p.set_controller(i)
#		ControllerManager.active_players.append(p)
	board = board_scene.instantiate()
	board.connect("line_clear", Callable(self, "_on_line_clear"))
	board.set_players(len(ControllerManager.active_players))
	add_child(board)
	tile_map = board.tile_map
	line_counter.position = Vector2(Main.BLOCK_SIZE * (board.width/2.0 - 1.25), Main.BLOCK_SIZE * -11)
	
	# Center board on camera
	var board_pos = Vector2(board.position.x - Main.BLOCK_SIZE * board.get_width() / 2,
							board.position.y - Main.BLOCK_SIZE * board.get_height() / 2)
	board.set_board_position(board_pos)
	
	start_timer.start(1)
	start_timer.connect("timeout", Callable(self, "_on_start_timer_timeout"))

func _process(_delta):
	pass

func start_game():
	var starting_pos = board.position + Vector2(Main.BLOCK_SIZE * 5, Main.BLOCK_SIZE * 2)
	
	for gamepad in ControllerManager.active_players:
		var gamepad_num = gamepad.controller_num
		var color_index = gamepad.color
		var player_instance = player.instantiate()
		if gamepad_num >= 0:
			player_instance.gamepad(gamepad_num)
		add_child(player_instance)
		player_instance.position = starting_pos
		player_instance.tex_suffix = Main.colors[color_index]
		starting_pos.x += Main.BLOCK_SIZE * 4
	
	if Main.shared_dealer:
		var dealer_instance = dealer.instantiate()
		add_child(dealer_instance)
		dealer_instance.position = Vector2(Main.BLOCK_SIZE * min(board.width * 0.5 + 2, 20), Main.BLOCK_SIZE * -8)
		for player_instance in ControllerManager.player_instances:
			player_instance.set_dealer(dealer_instance)
	else:
		for player_instance in ControllerManager.player_instances:
			var dealer_instance = dealer.instantiate()
			dealer_instance.position = Vector2(-Main.BLOCK_SIZE * (0.225 * len(ControllerManager.player_instances) - 0.5 * ControllerManager.player_instances.find(player_instance) - 1), -Main.BLOCK_SIZE * 2.6)
			player_instance.add_child(dealer_instance)
			player_instance.set_dealer(dealer_instance)
	
	if Main.shared_holder:
		var holder_instance = holder.instantiate()
		add_child(holder_instance)
		holder_instance.position = Vector2(Main.BLOCK_SIZE * min(board.width * 0.5 + 2, 20), Main.BLOCK_SIZE * -5)
		for player_instance in ControllerManager.player_instances:
			player_instance.set_holder(holder_instance)
	else:
		for player_instance in ControllerManager.player_instances:
			var holder_instance = holder.instantiate()
			holder_instance.position = Vector2(-Main.BLOCK_SIZE * (0.225 * len(ControllerManager.player_instances) - 0.5 * ControllerManager.player_instances.find(player_instance) + 1), -Main.BLOCK_SIZE * 2.6)
			player_instance.add_child(holder_instance)
			player_instance.set_holder(holder_instance)
		
	for player_instance in ControllerManager.player_instances:
		player_instance.init(board)
		player_instance.start()

func _on_line_clear() -> void:
	lines += 1
	line_counter.text = "Lines: {n}".format({"n":lines})
	if lines > goal:
		level += 1
		goal += 5
		for player_instance in ControllerManager.player_instances:
			player_instance.move_delay = (0.95 - (level * 0.025))**level
	ControllerManager.update_all_ghosts()

func _on_start_timer_timeout() -> void:
	if time_to_start > 0:
		label.text = str(time_to_start)
		time_to_start -= 1
		return
	start_game()
	start_timer.queue_free()
	label.hide()

func game_over() -> void:
	for player_instance in ControllerManager.player_instances:
		player_instance.game_over()
	game_over_menu.show()

func _exit_tree():
	for active_player in ControllerManager.active_players:
		active_player.queue_free()
