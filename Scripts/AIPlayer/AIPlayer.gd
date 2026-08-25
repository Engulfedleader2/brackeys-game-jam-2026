class_name AIPlayer
extends Player

## skeleton for AI Player
## basically same as normal Player for now, except it never makes the hand interactable


func start_turn() -> void:
	var new_card := RoundManager.deck.draw_card()
	if new_card != null:
		hand.add_card(new_card)

	if not hand.cards.is_empty():
		hand.cards[0].played.emit(false)
