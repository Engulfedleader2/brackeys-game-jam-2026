class_name DeclarationPrompt
extends CanvasLayer

signal closed(declared_value: int)

@onready var prompt_label: Label = $Control/VBoxContainer/PromptLabel
@onready var button_1: Button = $Control/Button1
@onready var button_5: Button = $Control/Button5
@onready var button_5_img: Sprite2D = $"Control/5"
@onready var button_1_img: Sprite2D = $"Control/1"



func _ready() -> void:
	hide()

func open(player_name: String) -> void:
	prompt_label.text = "%s declares their face-down card:\nIs it a 1 or a 5?" % player_name
	show()

func _on_button_1_pressed() -> void:
	hide()
	closed.emit(1)

func _on_button_5_pressed() -> void:
	hide()
	closed.emit(5)


func _on_button_1_mouse_entered() -> void:
	get_tree().create_tween().tween_property(button_1_img,"scale",Vector2(.8,.8),.1)


func _on_button_1_mouse_exited() -> void:
	get_tree().create_tween().tween_property(button_1_img,"scale",Vector2(0.569,0.569),.1)


func _on_button_5_mouse_entered() -> void:
	get_tree().create_tween().tween_property(button_5_img,"scale",Vector2(.8,.8),.1)


func _on_button_5_mouse_exited() -> void:
	get_tree().create_tween().tween_property(button_5_img,"scale",Vector2(0.569,0.569),.1)
