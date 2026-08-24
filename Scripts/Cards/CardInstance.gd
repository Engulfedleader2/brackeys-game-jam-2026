class_name CardInstance
extends RefCounted

var resource: CardResource
var instance_id: int

func _init(p_resource: CardResource, p_instance_id: int) -> void:
	resource = p_resource
	instance_id = p_instance_id
