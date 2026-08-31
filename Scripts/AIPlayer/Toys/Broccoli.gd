class_name Broccoli
extends Toy

func _init() -> void:
	id = &"broccoli"
	display_name = "Broccoli"
	description = "Call when top card holds a 1 or 5."
	# No dedicated art exists for Broccoli yet - reusing Soft Chicken's as a placeholder.
	icon = preload("res://AssetDump/Characters/Broccoli.png")

func should_call(pile_state: Dictionary) -> bool:
	var top_value = pile_state.get("top_value", -1)
	return top_value == 1 or top_value == 5

# Bluffs whenever they're playing a 2.
func should_bluff(card_value: int, _context: Dictionary) -> bool:
	return card_value == 2
