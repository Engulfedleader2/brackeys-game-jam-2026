class_name LambChop
extends Toy

func _init() -> void:
	id = &"lamb_chop"
	display_name = "Lamb Chop"
	description = "Call when pile total is even."
	icon = preload("res://AssetDump/Spooky/Lamb_Chop.png")

func should_call(pile_state: Dictionary) -> bool:
	var pile_total = pile_state.get("pile_total", 0)
	return pile_total > 0 and pile_total % 2 == 0

# Bluffs 1, 3, or 5 - 1 and 5 are already mandatory for everyone, so the
# only thing this actually adds is bluffing with a 3.
func should_bluff(card_value: int, _context: Dictionary) -> bool:
	return card_value == 3
