class_name DachshundDogPlush
extends Toy

func _init() -> void:
	id = &"dachshund_dog_plush"
	display_name = "Dachshund Dog Plush"
	description = "Call if someone placed face-down one turn ago."
	icon = preload("res://AssetDump/Spooky/Dachshund.png")

func should_call(pile_state: Dictionary) -> bool:
	var face_down_count = pile_state.get("face_down_count", 0)
	var last_was_face_down = pile_state.get("last_was_face_down", false)
	return last_was_face_down

func should_bluff() -> bool:
	return false
