class_name Toy
extends Resource

@export var id: StringName = &""
@export var display_name: String = "Toy"
@export_multiline var description: String = ""
@export var icon: Texture2D

func should_call(pile_state: Dictionary) -> bool:
	return false

func should_bluff() -> bool:
	return false
