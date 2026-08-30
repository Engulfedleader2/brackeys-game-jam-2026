class_name SqueakyBear
extends Toy

func _init() -> void:
	id = &"squeaky_bear"
	display_name = "Squeaky Bear"
	description = "Call after 2+ face-down cards in pile."
	icon = preload("res://AssetDump/Spooky/Bear.png")

func should_call(pile_state: Dictionary) -> bool:
	var face_down_count = pile_state.get("face_down_count", 0)
	return face_down_count >= 2

# No extra bluff value - only bluffs the 1s/5s that are mandatory for everyone.

# Unlike every other toy, Bear never lies about which one it is.
func declare(actual_value: int) -> int:
	return actual_value
