class_name CardInstance
extends RefCounted

var resource: CardResource
var instance_id: int

#variables for items
var negated: bool = false

func _init(p_resource: CardResource, p_instance_id: int) -> void:
	resource = p_resource
	instance_id = p_instance_id

func base_value() -> int:
	return resource.value

func effective_value() -> int:
	return -base_value() if negated else base_value()
