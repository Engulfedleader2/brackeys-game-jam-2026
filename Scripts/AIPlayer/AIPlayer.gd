class_name AIPlayer
extends Player

## skeleton for AI Player
## basically same as normal Player for now, except it never makes the hand interactable
## added random amount of bluffing because i needed to test bluffcall, probably need to update in the future
@export_range(0.0, 1.0) var bluff_chance := 0.4

func start_turn() -> void:
	#if not hand.cards.is_empty():
	#	hand.cards[0].played.emit(false)
	if hand.cards.is_empty():
		return
	
	var card: Card = hand.cards[0]
	var face_down := false
	
	face_down = randf() < bluff_chance
	card.played.emit(face_down)
	
