extends Node2D

@onready var animation = $AnimationPlayer
var index = 0
var can_play = false


signal new_text_signal

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
	#if can_play == true:
		#_speechBubble()


func _input(event):
	if event.is_action_pressed("ui_accept"):
		_speechBubble()
		can_play = true
		new_text_signal.emit()
		can_play = false


func _speechBubble():
	animation.play("Enter")
	await get_tree().create_timer(2).timeout
	animation.play("Exit")
