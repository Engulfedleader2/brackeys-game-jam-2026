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
	Wwise.register_game_obj(self,self.name)
	Wwise.add_default_listener(SoundManager)
	Wwise.post_event("Title",SoundManager)

	# Don't let the buttons be clickable until the curtain is done.
	_set_buttons_disabled(true)
	if Curtain.can_play == true:
		await get_tree().create_timer(2).timeout
		await Curtain._reveal()
		Curtain.can_play = false
	_set_buttons_disabled(false)


func _set_buttons_disabled(disabled: bool) -> void:
	start_button.disabled = disabled
	settings_button.disabled = disabled
	credits_button.disabled = disabled
	quit_button.disabled = disabled


func _on_start_button_pressed() -> void:
	Curtain._on_main_menu_start_game_signal()
	#SceneManager.go_to_game()
	Wwise.post_event("Table",SoundManager)


func _on_settings_button_pressed() -> void:
	SceneManager.go_to_settings_menu()


func _on_credits_button_pressed() -> void:
	SceneManager.go_to_credits_menu()


func _on_quit_button_pressed() -> void:
	SceneManager.quit_game()
