extends Node

var players: Array[Player] = []
var shared_pile: SharedPile
var deck: Deck
var _current_player_index: int = 0
var call_bluff_prompt: CallBluffPrompt
var declaration_prompt: DeclarationPrompt

var _pending_face_down_declaration: int = -1  # Stores declared value (1 or 5) for face-down card

signal round_finished(winner_owner_id: int, loser_owner_id: int, human_place: int)
signal turn_started(player: Player)
signal pile_picked_up(player_name: String, card_count: int)

func setup(p_players: Array[Player], p_shared_pile: SharedPile, p_deck: Deck, p_prompt: CallBluffPrompt, p_declaration_prompt: DeclarationPrompt = null) -> void:
	players = p_players
	shared_pile = p_shared_pile
	deck = p_deck
	call_bluff_prompt = p_prompt
	declaration_prompt = p_declaration_prompt

	for i in players.size():
		players[i].card_played.connect(_on_player_card_played.bind(players[i].owner_id))

func eliminate_player(player: Player) -> void:
	if player in players:
		players.erase(player)
		print("[RoundManager] Player %s removed from active players" % player.player_name)


# This function marks the beginning of the round. Here you can setup whatever needs to be setup before players start taking turns.
func start_round() -> void:
	# Randomize starting player
	_current_player_index = randi() % players.size()
	print("[RoundManager] Random starting player: %s (index %d)" % [players[_current_player_index].player_name, _current_player_index])

	for p in players:
		p.skip_next_turn = false
	var player := players[_current_player_index]
	turn_started.emit(player)
	player.start_turn()


# This function will check if the player has busted or not
func check_bust() -> bool:
	var current_total = shared_pile.get_total()
	var busted = shared_pile.is_bust(current_total)
	print("Checking bust. Pile total: ", current_total, " Busted: ", busted)
	return busted

# This function marks the end of the round. Here you can do whatever needs to be done after players have taken their turns or someone busted.
# winner_owner_id: the player who emptied their hand first (or -1 if round ended by bust)
func end_round(winner_owner_id: int = -1, buster_owner_id: int = -1) -> void:
	print("End Round")
	var human_place := get_human_place(buster_owner_id)
	var player_at_risk := _get_round_loser()
	var loser_id := -1
	if player_at_risk != null:
		loser_id = player_at_risk.owner_id
		print("[RoundManager] Player %s (%d) has the most cards (%d) - watch out!" % [player_at_risk.player_name, loser_id, player_at_risk.hand.get_card_count()])
	shared_pile.reset_for_new_round()
	round_finished.emit(winner_owner_id, loser_id, human_place)

func get_human_place(buster_owner_id: int) -> int:
	var human := _human_player()
	if human == null:
		return -1
	if human.owner_id == buster_owner_id:
		return players.size()
	
	var human_cards := human.hand.get_card_count()
	var ahead := 0
	for player in players:
		if player == human or player.owner_id == buster_owner_id:
			continue
		if player.hand.get_card_count() < human_cards:
			ahead += 1
	return ahead + 1

func is_current_player(player: Player) -> bool:
	return not players.is_empty() and players[_current_player_index] == player

func pass_current_turn() -> void:
	if players.is_empty():
		return
	var player := players[_current_player_index]
	print("[RoundManager] %s passes their turn" % player.player_name)
	player.hand.set_interactive(false)
	_advance_turn()
#updating this to handle the skip turn item
func _advance_turn() -> void:
	if players.is_empty():
		return
	var attempts := players.size()
	while attempts > 0:
		_current_player_index = (_current_player_index + 1) % players.size()
		var candidate := players[_current_player_index]
		if not candidate.consume_skip_turn():
			break
		print("[RoundManager] Skipping player %s's turn (hall pass)" % candidate.player_name)
		attempts -= 1
		
	var player := players[_current_player_index]
	turn_started.emit(player)
	player.start_turn()


func _on_player_card_played(instance: CardInstance, face_down: bool, owner_id: int) -> void:
	var playing_player = _player_for(owner_id)

	# If face-down, get declaration (from human player or AI auto-declare)
	var declared_value: int = -1
	if face_down and playing_player:
		if playing_player is AIPlayer:
			var ai_player := playing_player as AIPlayer
			if ai_player.toy:
				declared_value = ai_player.toy.declare(instance.resource.value, {"pile_total": shared_pile.get_total(), "bust_threshold": shared_pile.rules.bust_threshold})
			else:
				declared_value = [1, 5][randi() % 2]
			print("[RoundManager] AI %s auto-declares: %d" % [playing_player.player_name, declared_value])
		else:
			# Human player shows declaration prompt
			if declaration_prompt:
				declaration_prompt.open(playing_player.player_name)
				declared_value = await declaration_prompt.closed
				print("[RoundManager] Player %s declares: %d" % [playing_player.player_name, declared_value])

	var entry := shared_pile.play_card(instance, owner_id, face_down, declared_value)
	#if entry and declared_value != -1:
	#	entry.declared_value = declared_value

	# Wait for card animation to complete
	await get_tree().create_timer(0.4).timeout

	# Check immediately if this player emptied their hand
	if playing_player and playing_player.hand.get_card_count() == 0:
		print("[RoundManager] Player %s emptied their hand on play!" % playing_player.player_name)
		end_round(owner_id)
		return

	if check_bust():
		#print("Player ", owner_id, " busted!")
		#end_round()
		_resolve_bust.call_deferred(owner_id)
		return

	if face_down and _human_can_call(owner_id):
		if await _run_call_window(owner_id):
			return

	# Check if any AI wants to call
	if face_down:
		if await _check_ai_calls(owner_id):
			return

	if _check_round_over():
		return

	# Brief pause before next player's turn
	await get_tree().create_timer(0.3).timeout
	_advance_turn()

func _resolve_bust(owner_id: int) -> void:
	print("[RoundManager] Player %d BUSTED at %d - ELIMINATED!" % [owner_id, shared_pile.get_total()])
	shared_pile.reveal_all()
	_give_pile_to(owner_id, SharedPile.ClearReason.BUST)
	# Busted player is immediately eliminated (no winner for this round)
	end_round(-1, owner_id)
	
func _give_pile_to(owner_id: int, reason: SharedPile.ClearReason) -> void:
	var loser := _player_for(owner_id)
	if loser == null:
		push_error("[Round] No player with owner_id %d" % owner_id)
		return

	var picked_up := shared_pile.collect_all(reason)
	# Add picked-up cards to existing hand instead of replacing
	for card in picked_up:
		loser.hand.add_card(card)

	print("[RoundManager] Player %d picks up %d cards (hand: %d)" % [owner_id, picked_up.size(), loser.hand.get_card_count()])
	pile_picked_up.emit(loser.player_name, picked_up.size())

	if _check_round_over():
		return

	# Don't advance turn if this was a bust - round will end after
	if reason != SharedPile.ClearReason.BUST:
		_advance_turn.call_deferred()

func _get_round_loser() -> Player:
	var loser: Player = null
	var most_cards := -1
	for player in players:
		var count := player.hand.get_card_count()
		if count > most_cards:
			loser = player
			most_cards = count
	
	return loser
	
func _human_can_call(accused_owner_id: int) -> bool:
	if call_bluff_prompt == null:
		return false
	var human := _human_player()
	return human != null and human.owner_id != accused_owner_id and shared_pile.can_call_bluff()
	
func _run_call_window(accused_owner_id: int) -> bool:
	var accused := _player_for(accused_owner_id)
	if accused == null:
		return false

	call_bluff_prompt.open(accused.player_name)
	var did_call: bool = await call_bluff_prompt.closed
	if not did_call:
		return false

	var result := shared_pile.resolve_bluff_call(_human_player().owner_id)
	if result == null:
		return false

	print("[RoundManager] ", result.describe())
	_give_pile_to(result.loser_id, SharedPile.ClearReason.BLUFF_CALL)
	return true

func _check_ai_calls(accused_owner_id: int) -> bool:
	if not shared_pile.can_call_bluff():
		return false

	var pile_state := _build_pile_state()

	# Check each AI player in order (after the accused player)
	var accused_idx := -1
	for i in players.size():
		if players[i].owner_id == accused_owner_id:
			accused_idx = i
			break

	if accused_idx == -1:
		return false

	# Start checking from next player after accused
	for i in range(players.size()):
		var check_idx := (accused_idx + 1 + i) % players.size()
		var checking_player := players[check_idx]

		# Skip if it's the accused player or not an AI
		if checking_player.owner_id == accused_owner_id or not (checking_player is AIPlayer):
			continue

		var ai_player := checking_player as AIPlayer
		if ai_player.toy == null:
			continue

		if ai_player.toy.should_call(pile_state):
			print("[RoundManager] %s (with %s) CALLS the bluff!" % [ai_player.player_name, ai_player.toy.display_name])
			var result := shared_pile.resolve_bluff_call(ai_player.owner_id)
			if result != null:
				print("[RoundManager] ", result.describe())
				_give_pile_to(result.loser_id, SharedPile.ClearReason.BLUFF_CALL)
				return true

	return false

func _build_pile_state() -> Dictionary:
	var top_entry := shared_pile.peek_top()
	var face_down_count := 0
	var last_was_face_down := false

	var entries := shared_pile.get_public_entries()
	for entry in entries:
		if entry.get("face_down", false):
			face_down_count += 1

	if entries.size() >= 2:
		last_was_face_down = entries[-2].get("face_down", false)

	return {
		"pile_total": shared_pile.get_total(),
		"face_down_count": face_down_count,
		"last_was_face_down": last_was_face_down,
		"top_value": top_entry.actual_value() if top_entry and top_entry.revealed else -1,
	}

func _player_for(owner_id: int) -> Player:
	for player in players:
		if player.owner_id ==  owner_id:
			return player
	return null

func _human_player() -> Player:
	for player in players:
		if not (player is AIPlayer):
			return player
	return null

func _check_round_over() -> bool:
	for player in players:
		if player.hand.get_card_count() == 0:
			print("[RoundManager] Player %s (%d) wins the round - emptied their hand!" % [player.player_name, player.owner_id])
			end_round(player.owner_id)
			return true
	return false

#public check round over for items
func check_round_over() -> bool:
	return _check_round_over()
