extends CanvasLayer

@onready var animation: AnimationPlayer = $AnimationPlayer

var can_play = true

func _reveal():
	if can_play == true:
		animation.play("Reveal")
	else:
		$Control.position = Vector2(0,-1000)

func _on_main_menu_start_game_signal() -> void:
	can_play = true
	show()
	$Control.position = Vector2(0,-1271)
	animation.play_backwards("Reveal")
	await animation.animation_finished
	await get_tree().create_timer(1).timeout
	SceneManager.go_to_game()


func _hide():
	hide()

func _show():
	show()
