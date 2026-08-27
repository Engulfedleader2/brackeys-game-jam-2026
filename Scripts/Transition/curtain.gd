extends CanvasLayer

@onready var animation: AnimationPlayer = $AnimationPlayer



func _reveal():
	animation.play("Reveal")

func _on_main_menu_start_game_signal() -> void:
	show()
	animation.play_backwards("Reveal")
	await animation.animation_finished
	await get_tree().create_timer(1).timeout
	SceneManager.go_to_game()


func _hide():
	hide()

func _show():
	show()
