class_name Player
extends Node2D


signal card_played(instance: CardInstance, face_down: bool)

@export var player_name: String
@export var owner_id: int

@onready var hand: Hand = $Hand
@onready var player_name_label: Label = $PlayerNameLabel


func start_turn() -> void:
	var new_card := RoundManager.deck.draw_card()
	if new_card != null:
		hand.add_card(new_card)
	
	hand.set_interactive(true)


func _ready() -> void:
	hand.card_played.connect(_on_hand_card_played)

	player_name_label.text = player_name


func _on_hand_card_played(instance: CardInstance, face_down: bool) -> void:
	hand.set_interactive(false)
	card_played.emit(instance, face_down)
