class_name AIPlayer
extends Player

@export_range(0.0, 1.0) var bluff_chance := 0.4
@export var vertical_layout := false # true for side-seated players
@export var right_side_player := false #player is sitting right side
@export var portrait_offset := Vector2(-50, -180)
@export var portrait_size := Vector2(2,2)
@export var hand_skew: float = 0
@export var hand_card_scale = Vector2 (1,1)
@export var think_min := 0.6
@export var think_max := 1.5

enum Facing { FRONT, LEFT, RIGHT }
@export var facing: Facing = Facing.FRONT
@export var art_faces_right := true
@export var table_center_x := 960.0

var toy: Toy

@onready var portrait: TextureRect = $Portrait


func _ready() -> void:
	super._ready()
	_apply_facing()
	portrait.position = portrait_offset
	hand.vertical_layout = vertical_layout
	portrait.scale = portrait_size
	hand.skew = hand_skew
	hand.scale = hand_card_scale

func _process(_delta):
	if right_side_player == true:
		portrait.flip_h = true

var _turns_taken := 0


func start_turn() -> void:
	if hand.cards.is_empty():
		return

	_turns_taken += 1

	var card: Card = hand.cards[0]
	var card_value := 0
	if card.instance != null and card.instance.resource != null:
		card_value = card.instance.resource.value

	var face_down := false

	# 1s and 5s always face down for everyone, no exceptions.
	if card_value == 1 or card_value == 5:
		face_down = true
	elif toy:
		var context := {
			"pile_total": RoundManager.shared_pile.get_total(),
			"turns_taken": _turns_taken,
		}
		face_down = toy.should_bluff(card_value, context)
	else:
		face_down = randf() < bluff_chance

	card.played.emit(face_down)

func _apply_facing() -> void:
	var wants_left := false
	
	match facing:
		Facing.LEFT:
			wants_left = true
		Facing.RIGHT:
			wants_left = false
		Facing.FRONT:
			var dx := global_position.x - table_center_x
			if absf(dx) < 1.0:
				return
			wants_left = dx > 0.0
	
	portrait.flip_h = wants_left == art_faces_right
