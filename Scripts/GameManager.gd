extends Node

@export var turn_manager: Node
var total_game_rounds = 3

# Will run at the start of scene.
func _ready() -> void:
	start_game()

func start_game() -> void:
	print("Start Game")
	setup_players()
	for i in range(total_game_rounds):
		print("Round %d" % (i + 1))
		RoundManager.start_round()
		var round_over = false
		while not round_over:
			turn_manager.start_turn()
			var current_player = turn_manager.get_current_player()
			print("Current Player: ", current_player)
			RoundManager.play_card()
			if RoundManager.check_bust():
				print(current_player, " has busted!")
				round_over = true
			else:
				turn_manager.end_turn()
				turn_manager.next_player()
		RoundManager.end_round()
	end_game()

# This function will be part of start up scene launch to setup players before the start of the round.
func setup_players() -> void:
	print("Setting up players")

# This function will probably be a bool to check if the entire game is over or not and will call end_game if it is.
func check_game_over() -> void:
	print("Checking if game is over")

# Function to end the game and display the winner.
func end_game() -> void:
	print("Ending game")
