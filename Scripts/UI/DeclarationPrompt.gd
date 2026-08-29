class_name DeclarationPrompt
extends CanvasLayer

signal closed(declared_value: int)

@onready var prompt_label: Label = $Control/VBoxContainer/PromptLabel
@onready var button_1: Button = $Control/VBoxContainer/HBoxContainer/Button1
@onready var button_5: Button = $Control/VBoxContainer/HBoxContainer/Button5

func _ready() -> void:
	button_1.pressed.connect(_on_button_1_pressed)
	button_5.pressed.connect(_on_button_5_pressed)
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
