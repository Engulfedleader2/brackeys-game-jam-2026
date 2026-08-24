extends Control

@onready var back_button: Button = $Content/Credits/BackButton


func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)


func _on_back_button_pressed() -> void:
	SceneManager.go_to_main_menu()
