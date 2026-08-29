class_name LambChop
extends Toy

func _init() -> void:
	id = &"lamb_chop"
	display_name = "Lamb Chop"
	description = "Call when pile total is even."

func should_call(pile_state: Dictionary) -> bool:
	var pile_total = pile_state.get("pile_total", 0)
	return pile_total > 0 and pile_total % 2 == 0

func should_bluff() -> bool:
	return false
