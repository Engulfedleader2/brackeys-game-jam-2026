class_name SoftChicken
extends Toy

func _init() -> void:
	id = &"soft_chicken"
	display_name = "Soft Chicken"
	description = "Always call face-down cards."
	icon = preload("res://AssetDump/Spooky/Soft_Chicken.png")

func should_call(_pile_state: Dictionary) -> bool:
	return true

# Bluffs every 3rd turn, no matter what card they're playing.
func should_bluff(_card_value: int, context: Dictionary) -> bool:
	var turns_taken: int = context.get("turns_taken", 0)
	return turns_taken > 0 and turns_taken % 3 == 0
