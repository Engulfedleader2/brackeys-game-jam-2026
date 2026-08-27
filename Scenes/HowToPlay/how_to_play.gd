extends Node2D
@onready var back_img: Sprite2D = $Back_IMG
@onready var back_button: Button = $Back_Button




func _on_back_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(back_img,"scale",Vector2(1.1,1.1),.1)


func _on_back_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(back_img,"scale",Vector2(1,1),.1)


func _on_back_button_pressed() -> void:
	hide()
