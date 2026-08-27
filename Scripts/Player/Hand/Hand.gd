class_name Hand
extends Node2D


signal card_played(instance: CardInstance, face_down: bool)


const CARD_SCENE: PackedScene = preload("res://Scripts/Cards/Card.tscn");
@onready var bluff_button: Button = $Bluff
@export var bluff_button_lift := 200.0
@export var card_spacing := 200.0
@export var hover_lift := 100.0
@export var hover_tween_duration := 0.25
@export var reveal_cards := true # false for opponent hands, so their cards stay hidden

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
	card.setup.call_deferred(instance)
	if not reveal_cards:
		card.set_face_down()
	cards.append(card)

	card.hovered.connect(_on_card_hovered.bind(card))
	card.unhovered.connect(_on_card_unhovered.bind(card))
	card.played.connect(_on_card_played.bind(card))


# if cards seem jittery on fast inputs,
# might have to keep track of tween per card and kill previous tween before starting new one
func _on_card_hovered(card: Card) -> void:
	if _bluff_target != null and _bluff_target != card:
		_lower(_bluff_target)
	
	create_tween().tween_property(card, "position:y", -hover_lift, hover_tween_duration)
	_bluff_target = card
	bluff_button.position = Vector2(
		card.position.x - bluff_button.size.x * 0.5, -hover_lift - bluff_button_lift
	)
	bluff_button.visible = true


func _on_card_unhovered(card: Card) -> void:
	if _bluff_target == card and bluff_button.visible:
		return
	_lower(card)
	#create_tween().tween_property(card, "position:y", 0.0, hover_tween_duration)


func _on_card_played(face_down: bool, card: Card) -> void:
	if face_down:
		card.set_face_down()

	cards.erase(card)
	card_played.emit(card.instance, face_down)
	card.queue_free()
	_display_cards()


func _display_cards() -> void:
	var total_width := (cards.size() - 1) * card_spacing

	var start_x := -total_width / 2.0
	for i in cards.size():
		var card := cards[i]
		card.position.x = start_x + i * card_spacing
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
		create_tween().tween_property(card, "position:y", 0.0, hover_tween_duration)
