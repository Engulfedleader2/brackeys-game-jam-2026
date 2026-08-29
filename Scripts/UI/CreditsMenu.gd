extends Control

@onready var back_button: Button = $Content/Credits/BackButton
@onready var back_img: Sprite2D = $Back_IMG


func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	Wwise.register_game_obj(self,self.name)
	Wwise.add_default_listener(SoundManager)
	Wwise.post_event("Credits",SoundManager)


func _on_back_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(back_img,"scale",Vector2(1.1,1.1),.1)
	get_tree().create_tween().tween_property(back_img,"modulate:a",1,.1)


func _on_back_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(back_img,"scale",Vector2(1,1),.1)
	get_tree().create_tween().tween_property(back_img,"modulate:a",.5,.1)




func _on_back_button_pressed() -> void:
	Curtain._hide()
	SceneManager.go_to_main_menu()
	Wwise.post_event("Title",SoundManager)
