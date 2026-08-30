class_name SharedPile
extends Node2D

enum ClearReason { BUST, BLUFF_CALL, ROUND_RESET }
signal card_added(entry: PileEntry)
signal total_changed(pile_total: int)
signal card_revealed(entry: PileEntry)
signal bluff_called(result: BluffResult)
signal pile_cleared(reason: ClearReason, card_count: int)

signal speech_signal
signal value_signal
const CARD_SCENE: PackedScene = preload("res://Scripts/Cards/Card.tscn")

@export var rules: PileRules
@export var card_step := Vector2(4, 3)
@export var card_scale := Vector2(0.45, 0.45)
@export var pile_jitter := 15.0
@export var pile_rotation := 0.14
@export var drop_duration := 0.22

@onready var card_pile: Node2D = $CardPile

var _entries: Array[PileEntry] = []
var _next_play_index: int = 0
var _card_nodes: Dictionary = {}

func _ready() -> void:
	if rules == null:
		rules = PileRules.new()
		push_warning("[SharedPile] No PilesRules assigned - using default")
	print("[SharedPile] ready - bust over if greater than %d, legal face-down values %s" % [ rules.bust_threshold, rules.legal_face_down_values ])

	card_added.connect(_on_card_added)
	card_revealed.connect(_on_card_revealed)
	pile_cleared.connect(_on_pile_cleared)

func play_card(instance: CardInstance, owner_id: int, face_down: bool, declared_value: int = -1) -> PileEntry:
	if instance == null or instance.resource == null:
		push_error("[SharedPile] play_card called with a null card")
		return null
	
	var entry := PileEntry.new(instance, owner_id, face_down, _next_play_index, declared_value)
	_next_play_index += 1
	_entries.append(entry)
	var total := get_total()
	card_added.emit(entry)
	total_changed.emit(total)
	print("[SharedPile] Player %d plays %s" % [ owner_id, "face-down" if face_down else str(instance.resource.value)])
	return entry

func resolve_bluff_call(caller_id: int) -> BluffResult:
	var entry := peek_top()
	if  entry == null or not entry.is_hidden():
		push_warning("[SharedPile] No callable face-down card on top of pile.")
		return null
	if caller_id == entry.owner_id:
		push_warning("[SharedPile] Player cannot call the bluff on their own cards")
		return null
	_reveal_entry(entry)
	var result := BluffResult.new()
	result.entry = entry
	result.caller_id = caller_id
	result.was_lie = is_lie(entry)
	result.loser_id = entry.owner_id if result.was_lie else caller_id
	bluff_called.emit(result)
	print(result.describe())
	return result

func collect_all(reason: ClearReason = ClearReason.BUST) -> Array[CardInstance]:
	var collected: Array[CardInstance] = []
	for entry in _entries:
		entry.instance.negated = false
		collected.append(entry.instance)
	print("[SharedPile] %s - %d cards handed back" % [ ClearReason.keys()[reason], collected.size()])
	_clear(reason)
	return collected
	
func reset_for_new_round() -> Array[CardInstance]:
	print("[SharedPile] ====== new round ====== ")
	return collect_all(ClearReason.ROUND_RESET)
	
func _contribution(entry: PileEntry) -> int:
	return entry.effective_value()

func is_lie(entry: PileEntry) -> bool:
	if not entry.face_down:
		return false
	# If declared value exists, check if it matches actual value (declared lie)
	if entry.declared_value != -1:
		return entry.is_declared_lie()
	# Fallback: check if actual value is legal
	return not rules.legal_face_down_values.has(entry.actual_value())
	
func get_total() -> int:
	var total := 0
	for entry in _entries:
		total += _contribution(entry)
	return total

func get_card_count() -> int:
	return _entries.size()

func is_empty() -> bool:
	return _entries.is_empty()

func peek_top() -> PileEntry:
	return _entries[-1] if not _entries.is_empty() else null
	
func can_call_bluff() -> bool:
	var top := peek_top()
	return top != null and top.is_hidden()

#Maybe needed for the AI
func would_bust_play(card_value: int, face_down: bool) -> bool:
	return false if face_down else is_bust(get_total() + card_value)

func total_after_play(card_value: int, face_down: bool) -> int:
	return get_total() if face_down else get_total() + card_value

func safe_face_up_values() -> Array[int]:
	var total := get_total()
	var safe: Array[int]  = []
	for v in range(rules.min_card_value, rules.max_card_value + 1):
		if not is_bust(total + v):
			safe.append(v)
	return safe
#Internal stuff
	
func is_bust(total: int) -> bool:
	return total > rules.bust_threshold

func _reveal_entry(entry: PileEntry) -> void:
	if entry.revealed:
		return
	entry.revealed = true
	print("[SharedPile] revealed player %d: %d %s" % [entry.owner_id, entry.actual_value(), "LIE" if is_lie(entry) else "LEGAL"])
	card_revealed.emit(entry)
	value_signal.emit(entry.actual_value())
	
func reveal_all() -> void:
	for entry in _entries:
		if entry.is_hidden():
			entry.revealed = true
			card_revealed.emit(entry)

func _public_entry(entry: PileEntry) -> Dictionary:
	var hidden := entry.is_hidden()
	return {
		"owner_id": entry.owner_id,
		"play_index": entry.play_index,
		"face_down": entry.face_down,
		"hidden": hidden,
		"revealed": entry.revealed,
		"counted_value": _contribution(entry),
		"value": 0 if hidden else entry.actual_value(),
		"is_lie": false if hidden else is_lie(entry),	
	}

func get_public_entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for entry in _entries:
		out.append(_public_entry(entry))
	return out
	
func _clear(reason: ClearReason) -> void:
	var count := _entries.size()
	_entries.clear()
	_next_play_index = 0
	pile_cleared.emit(reason, count)
	total_changed.emit(0)
	speech_signal.emit()

func _on_card_added(entry: PileEntry) -> void:
	var card: Card = CARD_SCENE.instantiate()
	card_pile.add_child(card)
	card.setup(entry.instance)
	card.refresh_sticker()
	card.scale = card_scale
	#card.position = card_step * float(entry.play_index)
	card.z_index = entry.play_index
	card.card_area.input_pickable = false

	if entry.face_down:
		card.set_face_down()
		# Show declared value as a temporary label
		if entry.declared_value != -1:
			_add_declared_label(card, entry.declared_value)

	#testing some stuff to make it look like an actual pile
	var rng := RandomNumberGenerator.new()
	rng.seed = entry.instance.instance_id
	var target := card_step * float(entry.play_index) + Vector2(rng.randf_range(-pile_jitter, pile_jitter), rng.randf_range(-pile_jitter, pile_jitter))
	card.rotation = rng.randf_range(-pile_rotation, pile_rotation)
	card.position = target + Vector2(0, -280)
	var tween := create_tween()
	tween.tween_property(card, "position", target, drop_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_card_nodes[entry] = card

func _on_card_revealed(entry: PileEntry) -> void:
	var card: Card = _card_nodes.get(entry)
	if card == null:
		return

	card.front_face.visible = true
	card.back_face.visible = false
	card.modulate = Color("RED") if is_lie(entry) else Color("GREEN")

func _on_pile_cleared(_reason: ClearReason, _count: int) -> void:
	for card in _card_nodes.values():
		card.queue_free()
	_card_nodes.clear()

func _add_declared_label(card: Card, declared_value: int) -> void:
	var label = Label.new()
	label.text = str(declared_value)
	label.add_theme_font_size_override("font_size", 24)
	label.position = Vector2(40, -40)
	card.add_child(label)

	# Fade out and remove after 2 seconds
	var tween := create_tween()
	await get_tree().create_timer(1.5).timeout
	tween.tween_property(label, "modulate", Color.TRANSPARENT, 0.5)
	await tween.finished
	label.queue_free()
