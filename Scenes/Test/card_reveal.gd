extends Node2D

var index = 3

const UNO_1 = preload("uid://d0vm0wuh17gbd")
const UNO_2 = preload("uid://noo2kwaa0l2w")
const UNO_3 = preload("uid://iy8ojnt3ionl")
const UNO_4 = preload("uid://coxv8co3cviey")
const UNO_5 = preload("uid://k7y4wrytuemm")


const CARROT_BLUFF = preload("uid://davd8ckv0fahp")
const CARROT_CALL = preload("uid://objwwwag7mg0")
const LAMB_CHOP_BLUFF = preload("uid://cjjdvkur7ysud")
const LAMB_CHOP_CALL = preload("uid://bc53lxyq5d2tc")



@onready var face_card = $Sprite2D2
@onready var accused = $Accused


# Called when the node enters the scene tree for the first time.
func _ready():
	Curtain._hide()
	$AnimationPlayer.play("Shake")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_whoIsit()
	if index == 1:
		face_card.texture = UNO_1
	if index == 2:
		face_card.texture = UNO_2
	if index == 3:
		face_card.texture = UNO_3
	if index == 4:
		face_card.texture = UNO_4
	if index == 5:
		face_card.texture = UNO_5


func _whoIsit():
	if index == 1:
		accused.texture = CARROT_BLUFF
	if index == 3:
		accused.texture  = LAMB_CHOP_BLUFF
