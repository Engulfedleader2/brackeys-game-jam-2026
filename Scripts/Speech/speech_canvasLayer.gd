extends CanvasLayer


func _on_game_test_scene_leave_signal() -> void:
	$Speech._leave()


func _on_game_test_scene_show_signal() -> void:
	$Speech._on_shared_pile_speech_signal()
