extends Control

@onready var back_button: Button = $Content/Credits/BackButton


func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	Wwise.register_game_obj(self,self.name)
	Wwise.add_default_listener(SoundManager)
	Wwise.post_event("Credits",SoundManager)


func _on_back_button_pressed() -> void:
	Curtain._hide()
	SceneManager.go_to_main_menu()
	Wwise.post_event("Title",SoundManager)
