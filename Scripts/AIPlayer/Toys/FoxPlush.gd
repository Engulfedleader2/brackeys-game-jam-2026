class_name FoxPlush
extends Toy

func _init() -> void:
	id = &"fox_plush"
	display_name = "Fox Plush"
	description = "Never call face-down cards."

func should_call(_pile_state: Dictionary) -> bool:
	return false

func should_bluff() -> bool:
	return true
