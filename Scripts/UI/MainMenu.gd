extends Control

@onready var start_button: Button = $Content/VBoxContainer/StartButton
@onready var settings_button: Button = $Content/VBoxContainer/SettingsButton
@onready var credits_button: Button = $Content/VBoxContainer/CreditsButton
@onready var quit_button: Button = $Content/VBoxContainer/QuitButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	credits_button.pressed.connect(_on_credits_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)


func _on_start_button_pressed() -> void:
	SceneManager.go_to_game()


func _on_settings_button_pressed() -> void:
	SceneManager.go_to_settings_menu()


func _on_credits_button_pressed() -> void:
	SceneManager.go_to_credits_menu()


func _on_quit_button_pressed() -> void:
	SceneManager.quit_game()
