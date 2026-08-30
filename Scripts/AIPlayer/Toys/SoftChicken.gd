class_name SoftChicken
extends Toy

func _init() -> void:
	id = &"soft_chicken"
	display_name = "Soft Chicken"
	description = "Always call face-down cards."
	icon = preload("res://AssetDump/Spooky/Soft_Chicken.png")

func should_call(_pile_state: Dictionary) -> bool:
	return true

func should_bluff() -> bool:
	return false
