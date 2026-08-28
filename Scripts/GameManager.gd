extends Node

@export var turn_manager: Node
@export var deck: Deck
@export var shared_pile: SharedPile
@export var player_paths: Array[NodePath] = []
@export var call_bluff_prompt: CallBluffPrompt
@export var turn_label: Label
var total_game_rounds = 3
const STARTING_HAND_SIZE := 5

# Will run at the start of scene.
func _ready() -> void:
	RoundManager.turn_started.connect(_on_turn_started)
	start_game()


func _on_turn_started(player: Player) -> void:
	if turn_label != null:
		turn_label.text = "%s is playing" % player.player_name

func start_game() -> void:
	print("Start Game")
	setup_players()
	RoundManager.start_round()

# This function will be part of start up scene launch to setup players before the start of the round.
func setup_players() -> void:
	print("Setting up players")
	var players: Array[Player] = []
	for path in player_paths:
		players.append(get_node(path) as Player)
	RoundManager.setup(players, shared_pile, deck, call_bluff_prompt)

	var hands := deck.deal(players.size(), STARTING_HAND_SIZE)
	for i in players.size():
		players[i].hand.set_cards(hands[i])

# This function will probably be a bool to check if the entire game is over or not and will call end_game if it is.
func check_game_over() -> void:
	print("Checking if game is over")

# Function to end the game and display the winner.
func end_game() -> void:
	print("Ending game")
