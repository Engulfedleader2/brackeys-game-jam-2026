extends Node2D

var index = 1
@onready var dog_img: Sprite2D = $CanvasLayer/dog_img
@onready var animated: AnimatedSprite2D = $CanvasLayer/AnimatedSprite2D


@onready var text_img: Sprite2D = $CanvasLayer/text_img

func reveal_final_screen():
	$CanvasLayer.show()

func _ready() -> void:
	index = randi_range(1,6)

func _process(_delta: float) -> void:
	if index == 1:
		animated.play("Bear")
	if index == 2:
		animated.play("Carrot")
	if index == 3:
		animated.play("Chicken")
	if index == 4:
		animated.play("Dachs")
	if index == 5:
		animated.play("Fox")
	if index == 6:
		animated.play("Lamb")
