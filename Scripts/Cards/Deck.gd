class_name Deck
extends Node

const CARD_RESOURCES_PATH := "res://Scripts/Cards/CardResources/"

var cards: Array[CardInstance] = [] # entire deck of cards, loaded in once during game initialization
var draw_pile: Array[CardInstance] = [] # deck of cards per round, reset each round
var _next_instance_id := 0


func _ready() -> void:
	_load_cards()
	setup_round()
	var hands := deal(2, 2)
	for i in hands.size():
			print("Player %d hand size: %d" % [i, hands[i].size()])
			for instance in hands[i]:
					print("  - id %d, value %d" % [instance.instance_id, instance.resource.value])


func _load_cards() -> void:
	print("[Deck] Loading cards from " + CARD_RESOURCES_PATH)

	var dir := DirAccess.open(CARD_RESOURCES_PATH)
	dir.list_dir_begin()

	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var resource: CardResource = load(CARD_RESOURCES_PATH + file_name)
			cards.append(CardInstance.new(resource, _next_instance_id))
			_next_instance_id += 1
		file_name = dir.get_next()

	dir.list_dir_end()
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
