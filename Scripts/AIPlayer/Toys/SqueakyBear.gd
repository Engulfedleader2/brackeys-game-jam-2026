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

func should_bluff() -> bool:
	return false
