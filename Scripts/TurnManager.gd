extends Node

var players: Array[Player] = []
var temp_players = ["Player 1", "Player 2", "Player 3", "Player 4"]
var current_player_index: int = 0

# This function is called at the start of a player's turn. Here you can setup whatever needs to be setup at the start of the players turn.
func start_turn() -> void:
	print("Start Turn")

func end_turn() -> void:
	print("End Turn")

# Function to move to the next player
func next_player() -> void:
	print("Next Player")
	current_player_index += 1
	if current_player_index >= temp_players.size():
		current_player_index = 0

# Function to get the current player
func get_current_player() -> String:
		print("Get Current Player")
		return temp_players[current_player_index]
