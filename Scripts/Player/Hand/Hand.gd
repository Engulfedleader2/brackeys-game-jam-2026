class_name Hand
extends Node2D


signal card_played(instance: CardInstance, face_down: bool)


const CARD_SCENE: PackedScene = preload("res://Scripts/Cards/Card.tscn");
@onready var bluff_button: Button = $Bluff
@export var bluff_button_lift := 150.0
@export var card_spacing := 120.0
@export var card_scale := 0.6
@export var hover_lift := 100.0
@export var hover_tween_duration := 0.25
@export var reveal_cards := true # false for opponent hands, so their cards stay hidden
@export var vertical_layout := false # true for side-seated players, so the hand spreads up/down

var cards: Array[Card] = []
var _bluff_target: Card = null

func _ready() -> void:
	bluff_button.visible = false
	bluff_button.pressed.connect(_on_bluff_pressed)
	bluff_button.mouse_exited.connect(_release_bluff_target)

func set_cards(instances: Array[CardInstance]) -> void:
	for i in instances:
		_add_card(i)
	
	_display_cards()


func get_card_count() -> int:
	return cards.size()


func set_interactive(enabled: bool) -> void:
	for card in cards:
		card.card_area.input_pickable = enabled
	if not enabled:
		_release_bluff_target()


func add_card(instance: CardInstance) -> void:
	_add_card(instance)
	_display_cards()


# should only be used internally
func _add_card(instance: CardInstance) -> void:
	var card: Card = CARD_SCENE.instantiate()
	add_child(card)
	card.scale = Vector2(card_scale, card_scale)
	card.setup.call_deferred(instance)
	if not reveal_cards:
		card.set_face_down()
	# Cards start non-interactive no matter who turn it is
	card.card_area.input_pickable = false
	cards.append(card)

	card.hovered.connect(_on_card_hovered.bind(card))
	card.unhovered.connect(_on_card_unhovered.bind(card))
	card.played.connect(_on_card_played.bind(card))


# if cards seem jittery on fast inputs,
# might have to keep track of tween per card and kill previous tween before starting new one
func _hover_prop() -> String:
	return "position:x" if vertical_layout else "position:y"


func _on_card_hovered(card: Card) -> void:
	if _bluff_target != null and _bluff_target != card:
		_lower(_bluff_target)

	create_tween().tween_property(card, _hover_prop(), -hover_lift, hover_tween_duration)
	_bluff_target = card

	if vertical_layout:
		bluff_button.position = Vector2(
			-hover_lift - bluff_button_lift, card.position.y - bluff_button.size.y * 0.5
		)
	else:
		bluff_button.position = Vector2(
			card.position.x - bluff_button.size.x * 0.5, -hover_lift - bluff_button_lift
		)
	bluff_button.visible = true


func _on_card_unhovered(card: Card) -> void:
	if _bluff_target == card and bluff_button.visible:
		return
	_lower(card)


func _on_card_played(face_down: bool, card: Card) -> void:
	if face_down:
		card.set_face_down()

	cards.erase(card)
	card_played.emit(card.instance, face_down)
	card.queue_free()
	_display_cards()


func _display_cards() -> void:
	var total_span := (cards.size() - 1) * card_spacing
	var start := -total_span / 2.0

	for i in cards.size():
		var card := cards[i]
		if vertical_layout:
			card.position.y = start + i * card_spacing
			card.rotation_degrees = 90
		else:
			card.position.x = start + i * card_spacing
			card.rotation_degrees = 0
		card.z_index = i
		
func _on_bluff_pressed() -> void:
	if _bluff_target == null:
		return
	var card := _bluff_target
	_bluff_target = null
	bluff_button.visible = false
	_on_card_played(true, card)

func _release_bluff_target() -> void:
	bluff_button.visible = false
	_lower(_bluff_target)
	_bluff_target = null

func _lower(card: Card) -> void:
	if card != null and is_instance_valid(card):
		create_tween().tween_property(card, _hover_prop(), 0.0, hover_tween_duration)
