class_name AIPlayer
extends Player

## skeleton for AI Player
## basically same as normal Player for now, except it never makes the hand interactable
## added random amount of bluffing because i needed to test bluffcall, probably need to update in the future
@export_range(0.0, 1.0) var bluff_chance := 0.4
@export var vertical_layout := false # true for side-seated players
@export var portrait_offset := Vector2(-50, -180)
@export var portrait_size := Vector2(2,2)

# Random portrait only for now - not tied to personality/decision logic yet.
const PORTRAITS: Array[Texture2D] = [
	preload("res://Scripts/AIPlayer/Portraits/Bear.png"),
	preload("res://Scripts/AIPlayer/Portraits/Dachshund.png"),
	preload("res://Scripts/AIPlayer/Portraits/Fox.png"),
	preload("res://Scripts/AIPlayer/Portraits/LambChop.png"),
]

@onready var portrait: TextureRect = $Portrait


func _ready() -> void:
	super._ready()
	portrait.texture = PORTRAITS.pick_random()
	portrait.position = portrait_offset
	hand.vertical_layout = vertical_layout
	portrait.scale = portrait_size


func start_turn() -> void:
	#if not hand.cards.is_empty():
	#	hand.cards[0].played.emit(false)
	if hand.cards.is_empty():
		return
	
	var card: Card = hand.cards[0]
	var face_down := false
	
	face_down = randf() < bluff_chance
	card.played.emit(face_down)
	
