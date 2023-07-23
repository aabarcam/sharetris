extends Node2D

var board: Board

var board_scene = preload("res://scenes/gameplay/board.tscn")
var dealer = preload("res://scripts/gameplay/dealer.gd").new()

@onready var npc = $"npc"
@onready var player = $"player"

func _ready():
	board = board_scene.instantiate()
	board.set_players(2)
	add_child(board)
	
	player.set_dealer(dealer)
	player.init(board)
	player.start()
	
	npc.gamepad(999)
	npc.set_dealer(dealer)
	npc.init(board)
	npc.start()
