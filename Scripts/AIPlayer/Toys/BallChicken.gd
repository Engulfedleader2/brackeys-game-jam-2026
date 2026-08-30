class_name BallChicken
extends Toy

func _init() -> void:
	id = &"ball_chicken"
	display_name = "Ball Chicken"
	description = "Call when top card holds a 1 or 5."
	# No dedicated art exists for Ball Chicken yet - reusing Soft Chicken's as a placeholder.
	icon = preload("res://AssetDump/Spooky/Soft_Chicken.png")

func should_call(pile_state: Dictionary) -> bool:
	var top_value = pile_state.get("top_value", -1)
	return top_value == 1 or top_value == 5

func should_bluff() -> bool:
	return false
