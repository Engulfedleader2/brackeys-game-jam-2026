class_name AIPlayer
extends Player

## skeleton for AI Player
## basically same as normal Player for now, except it never makes the hand interactable


func start_turn() -> void:
	if not hand.cards.is_empty():
		hand.cards[0].played.emit(false)
