extends Button

@onready var howtoplay_img: Sprite2D = $"../Sprite2D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	get_tree().create_tween().tween_property(howtoplay_img,"modulate:a",1,.1)
	get_tree().create_tween().tween_property(howtoplay_img,"scale",Vector2(.12,.12),.1)


func _on_mouse_exited() -> void:
	get_tree().create_tween().tween_property(howtoplay_img,"modulate:a",.5,.1)
	get_tree().create_tween().tween_property(howtoplay_img,"scale",Vector2(.1,.1),.1)


func _on_pressed() -> void:
	$"../HowToPlay".show()
