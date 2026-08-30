extends Node2D

signal leave_signal
signal show_signal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Wwise.register_game_obj(self,self.name)
	Wwise.add_default_listener(SoundManager)
	Wwise.post_event("Table",SoundManager)
	await Curtain._reveal()
	$GameManager.start_game()


#func _on_shared_pile_speech_signal() -> void:
	#$AnimationPlayer.play("Reveal")
	#show_signal.emit()


func _leave():
	leave_signal.emit()
