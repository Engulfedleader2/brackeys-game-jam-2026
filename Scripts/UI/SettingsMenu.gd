extends Control

@onready var music_toggle: CheckButton = $Content/Settings/MusicToggle
@onready var sfx_toggle: CheckButton = $Content/Settings/SfxToggle
@onready var back_button: Button = $Content/Settings/BackButton


func _ready() -> void:
	music_toggle.toggled.connect(_on_music_toggled)
	sfx_toggle.toggled.connect(_on_sfx_toggled)
	back_button.pressed.connect(_on_back_button_pressed)


func _on_music_toggled(enabled: bool) -> void:
	print("[SettingsMenu] Music enabled: ", enabled)


func _on_sfx_toggled(enabled: bool) -> void:
	print("[SettingsMenu] SFX enabled: ", enabled)


func _on_back_button_pressed() -> void:
	Curtain._hide()
	SceneManager.go_to_main_menu()
