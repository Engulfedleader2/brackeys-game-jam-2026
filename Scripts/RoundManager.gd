extends Node

var players: Array[Player] = []
var shared_pile: SharedPile
var deck: Deck
var _current_player_index: int = 0
var call_bluff_prompt: CallBluffPrompt

signal round_finished(winner_owner_id: int, loser_owner_id: int)
signal turn_started(player: Player)

func setup(p_players: Array[Player], p_shared_pile: SharedPile, p_deck: Deck, p_prompt: CallBluffPrompt) -> void:
	players = p_players
	shared_pile = p_shared_pile
	deck = p_deck
	call_bluff_prompt = p_prompt

	for i in players.size():
		players[i].card_played.connect(_on_player_card_played.bind(players[i].owner_id))

func eliminate_player(player: Player) -> void:
	if player in players:
		players.erase(player)
		print("[RoundManager] Player %s removed from active players" % player.player_name)


# This function marks the beginning of the round. Here you can setup whatever needs to be setup before players start taking turns.
func start_round() -> void:
	_current_player_index = 0
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
func end_round(winner_owner_id: int = -1) -> void:
	print("End Round")
	var player_at_risk := _get_round_loser()
	var loser_id := -1
	if player_at_risk != null:
		loser_id = player_at_risk.owner_id
		print("[RoundManager] Player %s (%d) has the most cards (%d) - watch out!" % [player_at_risk.player_name, loser_id, player_at_risk.hand.get_card_count()])
	shared_pile.reset_for_new_round()
	round_finished.emit(winner_owner_id, loser_id)


func _advance_turn() -> void:
	_current_player_index = (_current_player_index + 1) % players.size()
	var player := players[_current_player_index]
	turn_started.emit(player)
	player.start_turn()


func _on_player_card_played(instance: CardInstance, face_down: bool, owner_id: int) -> void:
	var playing_player = _player_for(owner_id)

	shared_pile.play_card(instance, owner_id, face_down)

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

	if _check_round_over():
		return

	_advance_turn()

func _resolve_bust(owner_id: int) -> void:
	print("[RoundManager] Player %d BUSTED at %d - ELIMINATED!" % [owner_id, shared_pile.get_total()])
	shared_pile.reveal_all()
	_give_pile_to(owner_id, SharedPile.ClearReason.BUST)
	# Busted player is immediately eliminated (no winner for this round)
	end_round(-1)
	
func _give_pile_to(owner_id: int, reason: SharedPile.ClearReason) -> void:
	var loser := _player_for(owner_id)
	if loser == null:
		push_error("[Round] No player with owner_id %d" % owner_id)
		return

	var picked_up := shared_pile.collect_all(reason)
	loser.hand.set_cards(picked_up)
	print("[RoundManager] Player %d picks up %d cards (hand: %d)" % [owner_id, picked_up.size(), loser.hand.get_card_count()])

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
	
