class_name FoxPlush
extends Toy

func _init() -> void:
	id = &"fox_plush"
	display_name = "Fox Plush"
	description = "Never call face-down cards."
	icon = preload("res://AssetDump/Spooky/Fox.png")

func should_call(_pile_state: Dictionary) -> bool:
	return false

# No extra bluff value - only bluffs the 1s/5s that are mandatory for everyone.
