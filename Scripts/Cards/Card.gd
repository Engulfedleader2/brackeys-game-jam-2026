class_name Card
extends Node2D


signal hovered
signal unhovered
signal played(face_down: bool)

var instance: CardInstance

@onready var texture_rect: TextureRect = $FrontFace/TextureRect
@onready var card_area: Area2D = $Area2D
@onready var front_face: Node2D = $FrontFace
@onready var back_face: Node2D = $BackFace
@onready var sticker: Node2D = get_node_or_null("Sticker")

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
		# 1s and 5s awlays face down
		if _must_play_face_down():
			played.emit(true)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			played.emit(false)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			played.emit(true)


func _must_play_face_down() -> bool:
	return instance != null and instance.resource != null and instance.resource.value in [1, 5]


func setup(card_instance: CardInstance) -> void:
	instance = card_instance
	if card_instance.resource.card_texture:
		texture_rect.texture = card_instance.resource.card_texture


func set_face_down() -> void:
	front_face.visible = false
	back_face.visible = true

func refresh_sticker() -> void:
	if sticker == null or instance == null:
		return
	sticker.visible = instance.negated
