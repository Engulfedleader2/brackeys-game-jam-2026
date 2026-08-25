extends Node

var hands: Array[Hand] = []
var shared_pile: SharedPile
var deck: Deck


func setup(p_hands: Array[Hand], p_shared_pile: SharedPile, p_deck: Deck) -> void:
	hands = p_hands
	shared_pile = p_shared_pile
	deck = p_deck

	for i in hands.size():
		hands[i].card_played.connect(_on_hand_card_played.bind(i))


func _on_hand_card_played(instance: CardInstance, face_down: bool, owner_id: int) -> void:
	shared_pile.play_card(instance, owner_id, face_down)

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
