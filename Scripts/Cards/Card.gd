extends Node2D

var resource: CardResource
var instance_id: int

@onready var color_rect: ColorRect = $FrontFace/ColorRect
@onready var label: Label = $FrontFace/ColorRect/Label

func setup(data: CardResource, id: int) -> void:
	resource = data
	instance_id = id
	
	label.text = str(data.value)
	
