class_name Player
extends Node2D


signal card_played(instance: CardInstance, face_down: bool)

@export var player_name: String
@export var owner_id: int

@onready var hand: Hand = $Hand
@onready var player_name_label: Label = $PlayerNameLabel
@onready var card_count_label: Label = $CardCountLabel

#variables for items
var buttons: int = 0
var items: Array[ItemResource] = []
var skip_next_turn: bool = false

func start_turn() -> void:
	hand.set_interactive(true)


func _ready() -> void:
	hand.card_played.connect(_on_hand_card_played)

	player_name_label.text = player_name
	update_card_count()

func update_card_count() -> void:
	var count = hand.get_card_count()
	card_count_label.text = "Cards: %d" % count


func _on_hand_card_played(instance: CardInstance, face_down: bool) -> void:
	hand.set_interactive(false)
	card_played.emit(instance, face_down)

func consume_skip_turn() -> bool: 
	if not skip_next_turn:
		return false
	skip_next_turn = false
	return true
	
