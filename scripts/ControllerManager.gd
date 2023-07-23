extends Node

var players: Dictionary = {}
var active_players: Array = []
var player_instances : Array = []

func add_player(p_index):
	players[p_index] = true

func remove_player(p_index):
	players[p_index] = false

func update_all_ghosts():
	for player in player_instances:
		player.set_ghost_pos()
