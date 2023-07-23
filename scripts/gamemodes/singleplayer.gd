extends Node2D

var time_to_start: int = 3
var lines: int = 0
var goal: int = 10

var dealer = preload("res://scenes/gameplay/dealer.tscn")
var holder = preload("res://scenes/gameplay/holder.tscn")
var board_scene = preload("res://scenes/gameplay/board.tscn")
var board: Board

@export var level: int = 1

@onready var player: Player = $"player"
@onready var start_timer: Timer = $"start_timer"
@onready var label: Label = $"Label"
@onready var game_over_menu = $"game_over_menu"
@onready var line_counter = $"line_counter"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board = board_scene.instantiate()
	board.connect("line_clear", Callable(self, "_on_line_clear"))
	board.set_players(1)
	add_child(board)
	start_game()
	
	start_timer.start(1)
	start_timer.connect("timeout", Callable(self, "_on_start_timer_timeout"))

#func _process(_delta):
#	if Input.is_action_just_pressed("ui_accept"):
#		player.start()

# Starts game
func start_game() -> void:
	var dealer_instance = dealer.instantiate()
	dealer_instance.position = Vector2(Main.BLOCK_SIZE * 8, Main.BLOCK_SIZE)
	player.add_child(dealer_instance)
	player.set_dealer(dealer_instance)
	
	var holder_instance = holder.instantiate()
	holder_instance.position = Vector2(-Main.BLOCK_SIZE * 8, Main.BLOCK_SIZE)
	player.add_child(holder_instance)
	player.set_holder(holder_instance)
	player.init(board)

func _on_start_timer_timeout() -> void:
	if time_to_start > 0:
		label.text = str(time_to_start)
		time_to_start -= 1
		return
	player.start()
	label.hide()

func _on_line_clear() -> void:
	lines += 1
	line_counter.text = "Lines: {n}".format({"n":lines})
	if lines > goal:
		level += 1
		goal += 10
		player.move_delay = (0.95 - (level * 0.025))**level

func game_over() -> void:
	player.game_over()
	game_over_menu.show()
