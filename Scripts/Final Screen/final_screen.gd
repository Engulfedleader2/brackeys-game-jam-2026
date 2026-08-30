extends Node2D


@onready var dog_img: Sprite2D = $CanvasLayer/dog_img


@onready var text_img: Sprite2D = $CanvasLayer/text_img

func reveal_final_screen():
	$CanvasLayer.show()
	Wwise.post_event("Win_End",self)
	Wwise.post_event("End",self)
