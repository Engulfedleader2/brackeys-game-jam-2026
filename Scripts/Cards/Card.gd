class_name Card
extends Node2D


signal hovered
signal unhovered
signal played(face_down: bool)

var resource: CardResource
var instance_id: int

@onready var color_rect: ColorRect = $FrontFace/ColorRect
@onready var label: Label = $FrontFace/ColorRect/Label
@onready var card_area: Area2D = $Area2D


func _ready() -> void:
	card_area.mouse_entered.connect(_on_mouse_entered)
	card_area.mouse_exited.connect(_on_mouse_exited)
	card_area.input_event.connect(_on_area_input_event)


func _on_mouse_entered() -> void:
	hovered.emit()


func _on_mouse_exited() -> void:
	unhovered.emit()


func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			played.emit(false)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			played.emit(true)


func setup(data: CardResource, id: int) -> void:
	resource = data
	instance_id = id
	label.text = str(data.value)
