extends Node

@export var turn_manager: Node
@export var deck: Deck
@export var shared_pile: SharedPile
@export var player_paths: Array[NodePath] = []
@export var call_bluff_prompt: CallBluffPrompt
@export var declaration_prompt: DeclarationPrompt
@export var turn_label: Label
@export var round_survived_screen: RoundSurvivedScreen
@export var you_died_screen: CanvasLayer
@export var pile_total: Label
@export var action_message: Label
@export var shop_screen: ShopScreen

@export_group("Economy")
@export var placement_payouts: Array[int] = [15, 10, 5, 0]
@export var starting_buttons: int = 0

var total_game_rounds = 3
const STARTING_HAND_SIZE := 6
const LOSE_HAND_SIZE := 15
const ROUNDS_TO_WIN := 2
const HUMAN_OWNER_ID := 0

var current_round_number := 0
var round_wins: Dictionary = {}  # owner_id -> wins
var _human_eliminated := false # persists across rounds, unlike a per-call local
var _game_over := false # guards against any stray round_finished firing post-game

# Will run at the start of scene. Will do an await on curtains before dealing now
func _ready() -> void:
	RoundManager.turn_started.connect(_on_turn_started)
	RoundManager.round_finished.connect(_on_round_finished)
	RoundManager.pile_picked_up.connect(_on_pile_picked_up)


func _on_turn_started(player: Player) -> void:
	if turn_label != null:
		turn_label.text = "%s is playing" % player.player_name

	if pile_total != null:
		pile_total.text = "Pile Total: %d" % shared_pile.get_total()

func _on_pile_picked_up(player_name: String, card_count: int) -> void:
	var message = "%s picked up %d card%s!" % [player_name, card_count, "s" if card_count != 1 else ""]
	show_message(message, 2.5)

func _on_round_finished(winner_owner_id: int, loser_owner_id: int, human_place: int) -> void:
	if _game_over:
		return
	print("[GameManager] Round %d finished - Winner: %d, Loser: %d" % [current_round_number, winner_owner_id, loser_owner_id])

	_award_buttons(human_place)
	# Award round win to the winner
	if winner_owner_id != -1 and round_wins.has(winner_owner_id):
		round_wins[winner_owner_id] += 1
		var winner = _get_player_by_id(winner_owner_id)
		print("[GameManager] Player %s wins round %d! (Record: %d wins)" % [winner.player_name, current_round_number, round_wins[winner_owner_id]])

	# Check for players who have reached the lose condition (15 cards) or busted (winner_owner_id == -1)
	var eliminated_players: Array[Player] = []

	# If no winner, someone busted - find who has the most cards (the buster)
	if winner_owner_id == -1:
		var buster := _get_round_loser()
		if buster != null:
			print("[GameManager] Player %s BUSTED and is EATEN! (%d cards)" % [buster.player_name, buster.hand.get_card_count()])
			# Show "You Died" screen if the player (owner_id 0) busted
			if buster.owner_id == 0 and you_died_screen:
				you_died_screen.visible = true
				await get_tree().create_timer(3.0).timeout
				you_died_screen.visible = false
			eliminated_players.append(buster)

	# Also check for players who reached 15+ cards
	for path in player_paths:
		var player = get_node(path) as Player
		if player.hand.get_card_count() >= LOSE_HAND_SIZE:
			print("[GameManager] Player %s EATEN! Eliminated with %d cards" % [player.player_name, player.hand.get_card_count()])
			if player not in eliminated_players:
				eliminated_players.append(player)

	# Check if player 0 survived - once eliminated, they stay eliminated for
	# the rest of the game, not just for whatever round they died on.
	for eliminated in eliminated_players:
		if eliminated.owner_id == 0:
			_human_eliminated = true
			break
	var player_survived = not _human_eliminated

	# Show appropriate screen for player 0
	#if player_survived:
		# Show round survived screen only if player survived
		#if round_survived_screen:
		#	round_survived_screen.visible = true
		#	await get_tree().create_timer(2.0).timeout
		#	round_survived_screen.visible = false

	# Remove eliminated players from active play
	for player in eliminated_players:
		player_paths.erase(get_path_to(player))
		RoundManager.eliminate_player(player)
		player.visible = false

	# Check if only 1 or 0 players left - round is over
	if RoundManager.players.size() <= 1:
		print("[GameManager] Round %d over - only %d player(s) left" % [current_round_number, RoundManager.players.size()])
		# Award win to last remaining player
		if RoundManager.players.size() == 1:
			var winner = RoundManager.players[0]
			if winner.owner_id in round_wins:
				round_wins[winner.owner_id] += 1
				print("[GameManager] Player %s wins round %d! (Record: %d wins)" % [winner.player_name, current_round_number, round_wins[winner.owner_id]])

		# Check if someone has won the game (2 rounds)
		for owner_id in round_wins:
			if round_wins[owner_id] >= ROUNDS_TO_WIN:
				var game_winner = _get_player_by_id(owner_id)
				if game_winner:
					print("[GameManager] Player %s WINS THE GAME! (2 rounds won)" % [game_winner.player_name])
					_end_game_with_winner(owner_id)
					return

		# Move to next round
		_start_next_round()
		return

	# If any players were eliminated during the round, restart with remaining players
	if not eliminated_players.is_empty():
		print("[GameManager] Players eliminated! Restarting round with remaining players...")
		await get_tree().create_timer(1.0).timeout
		await _show_round_survived(player_survived)
		_redeal_and_start_new_round()
		return

	if winner_owner_id != -1 and round_wins.get(winner_owner_id, 0) >= ROUNDS_TO_WIN:
		var game_winner = _get_player_by_id(winner_owner_id)
		print("[GameManager] Player %s WINS THE GAME! (2 rounds won)" % [game_winner.player_name])
		_end_game_with_winner(winner_owner_id)
		return

	# Continue to next round if rounds remain
	if current_round_number >= total_game_rounds:
		end_game()
		return

	await get_tree().create_timer(1.0).timeout
	await _show_round_survived(player_survived)
	_start_next_round()
func _show_round_survived(player_survived: bool) -> void:
	if round_survived_screen == null or not player_survived:
		return
	while await round_survived_screen.prompt():
		await _maybe_open_shop(true)
		
func _award_buttons(human_place: int) -> void:
	var human := _get_player_by_id(HUMAN_OWNER_ID)
	if human == null or human_place < 1:
		return
	var payout: int = placement_payouts[human_place - 1] if human_place <= placement_payouts.size() else 0
	human.buttons += payout
	print("[GameManager] Placed %d - earned %d buttons (total %d)" % [human_place, payout, human.buttons])

func _maybe_open_shop(player_survived: bool) -> void:
	if shop_screen == null or not player_survived:
		return
	var human := _get_player_by_id(HUMAN_OWNER_ID)
	if human == null:
		return
	shop_screen.open(human)
	await shop_screen.closed
	
func start_game() -> void:
	print("Start Game")
	setup_players()
	_initialize_round_tracking()
	_start_next_round()

func _initialize_round_tracking() -> void:
	current_round_number = 0
	round_wins.clear()
	_human_eliminated = false
	_game_over = false
	for path in player_paths:
		var player = get_node(path) as Player
		round_wins[player.owner_id] = 0

func _start_next_round() -> void:
	current_round_number += 1
	print("[GameManager] Starting round %d of %d" % [current_round_number, total_game_rounds])

	# Clear the pile from previous round
	shared_pile.reset_for_new_round()

	# Reshuffle the deck for the new round
	print("[GameManager] Deck before setup: %d cards in draw_pile" % deck.get_card_count())
	deck.setup_round()
	print("[GameManager] Deck after setup: %d cards in draw_pile" % deck.get_card_count())

	# Get all remaining players and deal new hands
	var players: Array[Player] = []
	for player in RoundManager.players:
		players.append(player)

	print("[GameManager] About to deal %d cards to %d players" % [STARTING_HAND_SIZE, players.size()])
	var hands := deck.deal(players.size(), STARTING_HAND_SIZE)

	for i in players.size():
		print("[GameManager] Player %s getting %d cards" % [players[i].player_name, hands[i].size()])
		await players[i].hand.set_cards(hands[i])
		players[i].skip_next_turn = false

	print("[GameManager] Cards dealt to %d players. Round %d starting..." % [players.size(), current_round_number])
	RoundManager.start_round()

func _redeal_and_start_new_round() -> void:
	# Reshuffle the deck
	deck.setup_round()

	var players: Array[Player] = []
	for path in player_paths:
		players.append(get_node(path) as Player)

	var hands := deck.deal(players.size(), STARTING_HAND_SIZE)
	for i in players.size():
		await players[i].hand.set_cards(hands[i])

	print("[GameManager] Cards redealt to %d remaining players. Starting new round..." % players.size())
	RoundManager.start_round()

# This function will be part of start up scene launch to setup players before the start of the round.
func setup_players() -> void:
	print("Setting up players")
	var players: Array[Player] = []
	for path in player_paths:
		players.append(get_node(path) as Player)
	RoundManager.setup(players, shared_pile, deck, call_bluff_prompt, declaration_prompt)

	# Assign random toys to AI players
	_assign_toys(players)

	var hands := deck.deal(players.size(), STARTING_HAND_SIZE)
	for i in players.size():
		await players[i].hand.set_cards(hands[i])

	var human := _get_player_by_id(HUMAN_OWNER_ID)
	if human != null:
		human.buttons = starting_buttons

func _assign_toys(players: Array[Player]) -> void:
	var toy_classes: Array[Variant] = [
		SoftChicken,
		ClothCarrot,
		BallChicken,
		LambChop,
		DachshundDogPlush,
		FoxPlush,
		SqueakyBear,
	]

	var toy_pool := toy_classes.duplicate()
	toy_pool.shuffle()

	for player in players:
		if player is AIPlayer:
			if toy_pool.is_empty():
				toy_pool = toy_classes.duplicate()
				toy_pool.shuffle()

			var toy_class = toy_pool.pop_front()
			var ai_player := player as AIPlayer
			ai_player.toy = toy_class.new()
			ai_player.player_name = ai_player.toy.display_name
			ai_player.player_name_label.text = ai_player.player_name
			print("[GameManager] %s assigned toy: %s" % [ai_player.player_name, ai_player.toy.display_name])


func _get_player_by_id(owner_id: int) -> Player:
	for path in player_paths:
		var player = get_node(path) as Player
		if player.owner_id == owner_id:
			return player
	return null

func _get_round_loser() -> Player:
	var loser: Player = null
	var most_cards := -1
	for path in player_paths:
		var player = get_node(path) as Player
		var count: int = player.hand.get_card_count()
		if count > most_cards:
			loser = player
			most_cards = count
	return loser

# This function will probably be a bool to check if the entire game is over or not and will call end_game if it is.
func check_game_over() -> void:
	print("Checking if game is over")

func _end_game_with_winner(winner_owner_id: int) -> void:
	_game_over = true
	print("[GameManager] Game Over! Eliminating all other players...")
	# Show "You Died" if player 0 lost
	if winner_owner_id != HUMAN_OWNER_ID and you_died_screen:
		you_died_screen.visible = true
		await get_tree().create_timer(3.0).timeout
		you_died_screen.visible = false

	# Eliminate all players except the winner
	for path in player_paths:
		var player = get_node(path) as Player
		if player.owner_id != winner_owner_id:
			print("[GameManager] Player %s EATEN by Wuffles!" % player.player_name)
			player.visible = false
	end_game()

func show_message(text: String, duration: float = 2.0) -> void:
	if action_message == null:
		return
	action_message.text = text
	action_message.modulate = Color.WHITE

	var tween := create_tween()
	await get_tree().create_timer(duration - 0.3).timeout
	tween.tween_property(action_message, "modulate", Color.TRANSPARENT, 0.3)

# Function to end the game and display the winner.
func end_game() -> void:
	_game_over = true
	print("Ending game")

	var human := _get_player_by_id(HUMAN_OWNER_ID)
	var human_won := human != null and human in RoundManager.players and not _human_eliminated
	show_message("You win!" if human_won else "Game Over", 3.0)

	await get_tree().create_timer(3.5).timeout
	SceneManager.go_to_main_menu()
