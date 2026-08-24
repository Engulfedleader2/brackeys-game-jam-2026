extends Node

# This function marks the beginning of the round. Here you can setup whatever needs to be setup before players start taking turns.
func start_round() -> void:
	print("Start Round")

# This function is called for the current player to play a card.
func play_card() -> void:
	print("Play Card")

# This function will check if the player has busted or not
func check_bust() -> bool:
	var temp_busted = true
	print("Check if player Busted")
	return temp_busted

# This function marks the end of the round. Here you can do whatever needs to be done after players have taken their turns or someone busted.
func end_round() -> void:
	print("End Round")