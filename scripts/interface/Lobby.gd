extends Control

var lobby_player = preload("res://scenes/interface/LobbyPlayer.tscn")
var spectators = []
var players = []

@onready var spectator_container: VBoxContainer = $"Spectators/PanelContainer/VBoxContainer"
@onready var player_container: VBoxContainer = $"Players/PanelContainer/VBoxContainer"
@onready var start_button: Button = $"Start"
@onready var back_button: Button = $"Back"
@onready var check_holder: CheckBox = $"check_holder"
@onready var check_dealer: CheckBox = $"check_dealer"

func _ready() -> void:
	Input.connect("joy_connection_changed", Callable(self, "_on_joy_connection_changed"))
	start_button.connect("button_up", Callable(self,"_on_start_button_up"))
	back_button.connect("button_up", Callable(self, "_on_back_button_up"))
	# Add keyboard as a player
	var new_player = lobby_player.instantiate()
	new_player.set_type("Keyboard")
	new_player.set_lobby(self)
	spectators.append(new_player)
	
	# Add gamepads as players
	for gamepad in Input.get_connected_joypads():
		add_gamepad(gamepad)
	
	update_lists()

func add_gamepad(device_id):
	var new_player = lobby_player.instantiate()
	new_player.set_type("Gamepad")
	new_player.set_controller(device_id)
	new_player.set_lobby(self)
	spectators.append(new_player)

# Move player from spectators list to players list
func move_to_player(player: LobbyPlayer):
	if len(players) >= 8:
		return
	if player in spectators:
		spectators.erase(player)
	if not player in players:
		players.append(player)
	player.show_color()
	update_lists()

# Move player from players list to spectator list
func move_to_spectator(player: LobbyPlayer):
	if not player in spectators:
		spectators.append(player)
	if  player in players:
		players.erase(player)
	player.hide_color()
	update_lists()

# Updates both lists contents
func update_lists() -> void:
	delete_players()
	for spectator in spectators:
		spectator_container.add_child(spectator)
	for player in players:
		player_container.add_child(player)

# Deletes spectator and player lists
func delete_players() -> void:
	for spectator in spectator_container.get_children():
		spectator_container.remove_child(spectator)
	for player in player_container.get_children():
		player_container.remove_child(player)

# Start game
func _on_start_button_up() -> void:
	if len(players) < 2:
		$"error".show()
		return
	Main.shared_holder = check_holder.is_pressed()
	Main.shared_dealer = check_dealer.is_pressed()
	for player in players:
		player_container.remove_child(player)
	ControllerManager.active_players = players.duplicate()
	get_tree().change_scene_to_file("res://scenes/gamemodes/multiplayer.tscn")

func _on_back_button_up() -> void:
	get_tree().change_scene_to_file("res://scenes/interface/Menu.tscn")

func _on_joy_connection_changed(device, connected) -> void:
	if connected:
		add_gamepad(device)
	else:
		var to_erase = spectators.filter(func(player): return player.get_controller() == device)
		if not to_erase.is_empty():
			spectators.erase(to_erase.front())
			to_erase.front().unset_controller()
			to_erase.front().queue_free()
		
		to_erase = players.filter(func(player): return player.get_controller() == device)
		if not to_erase.is_empty():
			players.erase(to_erase.front())
			to_erase.front().unset_controller()
			to_erase.front().queue_free()
	update_lists()
