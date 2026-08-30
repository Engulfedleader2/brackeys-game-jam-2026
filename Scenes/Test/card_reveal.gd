extends CanvasLayer

var index = 1

const UNO_1 = preload("uid://d0vm0wuh17gbd")
const UNO_2 = preload("uid://noo2kwaa0l2w")
const UNO_3 = preload("uid://iy8ojnt3ionl")
const UNO_4 = preload("uid://coxv8co3cviey")
const UNO_5 = preload("uid://k7y4wrytuemm")


const BEAR_BLUFF = preload("uid://dh0x006cv43vr")
const BROCCOLI_BLUFF = preload("uid://c3ndo80teqmel")
const CARROT_BLUFF = preload("uid://bdc030l0rluj3")
const DACHSHUND_BLUFF = preload("uid://86kobshebo2")
const FOX_BLUFF = preload("uid://cgae8wr1esp66")
const LAMB_CHOP_BLUFF = preload("uid://bsyhwvq5xti2b")
const SOFT_CHICKEN_BLUFF = preload("uid://4m5bwwydby3w")


var current_character


@onready var face_card = $Sprite2D2
@onready var accused = $Accused


# Called when the node enters the scene tree for the first time.
#func _ready():
	#Curtain._hide()
	#$AnimationPlayer.play("Shake")
	#$Accused_AnimationPlayer.play("zoom")



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
	if CharacterSelection.chosen_toy_class == SqueakyBear:
		accused.texture = BEAR_BLUFF
	elif CharacterSelection.chosen_toy_class == FoxPlush:
		accused.texture = FOX_BLUFF
	elif CharacterSelection.chosen_toy_class == Broccoli:
		accused.texture = BROCCOLI_BLUFF
	elif CharacterSelection.chosen_toy_class == ClothCarrot:
		accused.texture = CARROT_BLUFF
	elif CharacterSelection.chosen_toy_class == DachshundDogPlush:
		accused.texture = DACHSHUND_BLUFF
	elif CharacterSelection.chosen_toy_class == LambChop:
		accused.texture = LAMB_CHOP_BLUFF
	elif CharacterSelection.chosen_toy_class == SoftChicken:
		accused.texture = SOFT_CHICKEN_BLUFF



func _on_call_bluff_prompt_closed(did_call):
	if did_call == true:
		_whoIsit()
		get_tree().paused = true
		$".".show()
		$AnimationPlayer.play("Shake")
		$Accused_AnimationPlayer.play("zoom")
		await get_tree().create_timer(5).timeout
		$".".hide()
		get_tree().paused = false





func _on_shared_pile_value_signal(entry) -> void:
	if entry == 1:
		index = 1
	if entry == 2:
		index = 2
	if entry == 3:
		index = 3
	if entry == 4:
		index = 4
	if entry == 5:
		index = 5
