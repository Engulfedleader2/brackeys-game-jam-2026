extends Control

@onready var start_button: Button = $StartButton
@onready var settings_button: Button = $SettingsButton
@onready var credits_button: Button = $CreditsButton
@onready var quit_button: Button = $Content/VBoxContainer/QuitButton
@onready var start_img: Sprite2D = $Start_img
@onready var credits_img: Sprite2D = $Credits_img
@onready var settings_img: Sprite2D = $Settings_img


func _ready() -> void:
	Wwise.register_game_obj(self,self.name)
	Wwise.add_default_listener(SoundManager)
	Wwise.post_event("Title",SoundManager)

	# Don't let the buttons be clickable until the curtain is done.
	hidebutton()
	if Curtain.can_play == true:
		await get_tree().create_timer(2).timeout
		await Curtain._reveal()
		Curtain.can_play = false
	showbutton()


func hidebutton():
	start_button.hide()
	settings_button.hide()
	credits_button.hide()
	quit_button.hide()


func showbutton():
	start_button.show()
	settings_button.show()
	credits_button.show()
	quit_button.show()


func _on_start_button_pressed() -> void:
	Wwise.post_event("Click",SoundManager)
	hidebutton()
	SceneManager.go_to_character_select()


func _on_settings_button_pressed() -> void:
	Wwise.post_event("Click",SoundManager)
	SceneManager.go_to_settings_menu()


func _on_credits_button_pressed() -> void:
	Wwise.post_event("Click",SoundManager)
	SceneManager.go_to_credits_menu()


func _on_quit_button_pressed() -> void:
	Wwise.post_event("Back",SoundManager)
	SceneManager.quit_game()


func _on_start_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(start_img,"scale",Vector2(1.1,1.1),.1)
	get_tree().create_tween().tween_property(start_img,"modulate:a",1,.1)


func _on_start_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(start_img,"scale",Vector2(1,1),.1)
	get_tree().create_tween().tween_property(start_img,"modulate:a",.5,.1)


func _on_credits_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(credits_img,"scale",Vector2(1.1,1.1),.1)
	get_tree().create_tween().tween_property(credits_img,"modulate:a",1,.1)


func _on_credits_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(credits_img,"scale",Vector2(1,1),.1)
	get_tree().create_tween().tween_property(credits_img,"modulate:a",.5,.1)


func _on_settings_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(settings_img,"scale",Vector2(1.1,1.1),.1)
	get_tree().create_tween().tween_property(settings_img,"modulate:a",1,.1)


func _on_settings_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(settings_img,"scale",Vector2(1,1),.1)
	get_tree().create_tween().tween_property(settings_img,"modulate:a",.5,.1)
