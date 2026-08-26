extends Node

var players: Array[Player] = []
var shared_pile: SharedPile
var deck: Deck
var _current_player_index: int = 0


func setup(p_players: Array[Player], p_shared_pile: SharedPile, p_deck: Deck) -> void:
	players = p_players
	shared_pile = p_shared_pile
	deck = p_deck

	for i in players.size():
		players[i].card_played.connect(_on_player_card_played.bind(players[i].owner_id))


# This function marks the beginning of the round. Here you can setup whatever needs to be setup before players start taking turns.
func start_round() -> void:
	_current_player_index = 0
	players[_current_player_index].start_turn()


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


func _advance_turn() -> void:
	_current_player_index = (_current_player_index + 1) % players.size()
	players[_current_player_index].start_turn()


func _on_player_card_played(instance: CardInstance, face_down: bool, owner_id: int) -> void:
	shared_pile.play_card(instance, owner_id, face_down)
