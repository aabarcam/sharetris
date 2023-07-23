extends Node2D

var board: Board

var dealer = preload("res://scripts/gameplay/dealer.gd").new()
var board_scene = preload("res://scenes/gameplay/board.tscn")
@export var players: int
@onready var player_list: Array = $"Players".get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board = board_scene.instantiate()
	board.set_players(2)
	add_child(board)
	start_game()

# Starts game
func start_game() -> void:
	for player in player_list:
		player.set_dealer(dealer)
		player.init(board)
