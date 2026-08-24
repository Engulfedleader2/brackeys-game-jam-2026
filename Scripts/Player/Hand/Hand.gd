class_name Hand
extends Node2D


const CARD_SCENE: PackedScene = preload("res://Scripts/Cards/Card.tscn");
@export var card_spacing := 200.0
@export var hover_lift := 100.0
@export var hover_tween_duration := 0.25

var cards: Array[Card] = []


func set_cards(instances: Array[CardInstance]) -> void:
	for i in instances:
		_add_card(i)
	
	_display_cards()


func get_card_count() -> int:
	return cards.size()


func _add_card(instance: CardInstance) -> void:
	var card: Card = CARD_SCENE.instantiate()
	add_child(card)
	card.setup.call_deferred(instance.resource, instance.instance_id)
	cards.append(card)

	card.hovered.connect(_on_card_hovered.bind(card))
	card.unhovered.connect(_on_card_unhovered.bind(card))
	card.played.connect(_on_card_played.bind(card))


# if cards seem jittery on fast inputs,
# might have to keep track of tween per card and kill previous tween before starting new one
func _on_card_hovered(card: Card) -> void:
	create_tween().tween_property(card, "position:y", -hover_lift, hover_tween_duration)


func _on_card_unhovered(card: Card) -> void:
	create_tween().tween_property(card, "position:y", 0.0, hover_tween_duration)


func _on_card_played(_face_down: bool, card: Card) -> void:
	print("[Hand] Card %d played" % [card.resource.value])


func _display_cards() -> void:
	var total_width := (cards.size() - 1) * card_spacing

	var start_x := -total_width / 2.0
	for i in cards.size():
		var card := cards[i]
		card.position.x = start_x + i * card_spacing
		card.z_index = i
