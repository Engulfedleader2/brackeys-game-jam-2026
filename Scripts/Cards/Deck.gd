class_name Deck
extends Node

@export var card_resources: Array[CardResource] = []

var cards: Array[CardInstance] = [] # entire deck of cards, loaded in once during game initialization
var draw_pile: Array[CardInstance] = [] # deck of cards per round, reset each round
var _next_instance_id := 0


func _ready() -> void:
	_load_cards()
	setup_round()


func _load_cards() -> void:
	print("[Deck] Loading %d card resources" % card_resources.size())

	for resource in card_resources:
		cards.append(CardInstance.new(resource, _next_instance_id))
		_next_instance_id += 1

	print("[Deck] Loaded " + str(cards.size()))


func setup_round() -> void:
	draw_pile = cards.duplicate()
	draw_pile.shuffle()


func draw_card() -> CardInstance:
	return draw_pile.pop_back() # returns null if draw_pile is empty


func deal(number_of_players: int, hand_size: int) -> Array[Array]:
	print("[Deck] Dealing ", str(hand_size) + " cards out to " + str(number_of_players) + " players")

	# refactor into hands when we have hands class
	var hands: Array[Array] = []
	for player_index in number_of_players:
		var hand: Array[CardInstance] = []

		for i in hand_size:
			var instance := draw_card()
			if instance == null:
				break
			
			hand.append(instance)
		hands.append(hand)

	print("[Deck] Finished dealing cards")
	return hands


func get_card_count() -> int:
	return draw_pile.size()
