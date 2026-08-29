class_name PileEntry
extends RefCounted

var instance: CardInstance
var face_down: bool
var owner_id: int
var play_index: int #order of placement in current pile
var revealed: bool = false
var declared_value: int = -1 # For face-down cards: what player declared (1 or 5)


func _init(c_instance: CardInstance, c_owner_id: int, c_face_down: bool, c_play_index: int) -> void:
	instance = c_instance
	face_down = c_face_down
	owner_id = c_owner_id
	play_index = c_play_index

func actual_value() -> int:
	return instance.resource.value

func is_hidden() -> bool:
	return face_down and not revealed

func base_value() -> int:
	return instance.base_value()

func effective_value() -> int:
	return instance.effective_value()

func is_declared_lie() -> bool:
	if not face_down or declared_value == -1:
		return false
	return declared_value != actual_value()
