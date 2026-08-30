class_name ClothCarrot
extends Toy

func _init() -> void:
	id = &"cloth_carrot"
	display_name = "Cloth Carrot"
	description = "Call if face-down card before pile = 5."
	icon = preload("res://AssetDump/Spooky/Carrot.png")

func should_call(pile_state: Dictionary) -> bool:
	if pile_state.is_empty():
		return false
	var pile_total = pile_state.get("pile_total", 0)
	return pile_total == 5

func should_bluff() -> bool:
	return false
