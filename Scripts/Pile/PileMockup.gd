extends Node2D

const CARD_SCENE: PackedScene = preload("res://Scripts/Cards/Card.tscn")
const CARD_RESOURCE_PATH := "res://Scripts/Cards/CardResources/%d.tres"

@export var card_step := Vector2(70, 12)
@export var card_scale := Vector2(0.45, 0.45)
@export var resolve_delay := 0.5
@export_range(2, 4) var player_count := 2
@export var copies_per_value := 4
@export var starting_hand_size := 6
@export var lose_at_hand_size := 15

@onready var pile: SharedPile = $SharedPile
@onready var pile_cards: Node2D = $CardPile
@onready var readout: Label = $UI/Readout
@onready var log_box: RichTextLabel = $UI/Log
@onready var face_up_row: HBoxContainer = $UI/Controls/FaceUp
@onready var face_down_row: HBoxContainer = $UI/Controls/FaceDown
@onready var call_bluff_button: Button = $UI/Controls/CallBluff
@onready var new_round_button: Button = $UI/Controls/NewRound

var _card_nodes: Dictionary = {}
var _current_player := 0
var _next_instance_id := 0
var _busy := false
#Log colors
# e3e8e3 default
# 7f8a83 system logs
# d08c30 revealed details
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pile.card_added.connect(_on_card_added)
	pile.card_revealed.connect(_on_card_revealed)
	pile.total_changed.connect(func(_t): _refresh())
	pile.bluff_called.connect(func(r): _log(r.describe(), "#d08c30"))
	pile.pile_cleared.connect(_on_pile_cleared)
	
	for i in face_up_row.get_child_count():
		(face_up_row.get_child(i) as Button).pressed.connect(_play.bind(i + 1, false))
	for i in face_down_row.get_child_count():
		(face_down_row.get_child(i) as Button).pressed.connect(_play.bind(i + 1, true))
		
	call_bluff_button.pressed.connect(_call_bluff)
	new_round_button.pressed.connect(_new_round)
	_log("Pile ready. Bust Over %d. Legal face down cards: %s" % [pile.rules.bust_threshold, pile.rules.legal_face_down_values], "#7f8a83")
	_refresh()

func _play(value: int, face_down: bool) -> void:
	if _busy:
		return
	var actor := _current_player
	if pile.play_card(_make_instance(value), actor, face_down) == null:
		_log("play_card failed", "#c0554e")
		return
	
	var total := pile.get_total()
	if pile.is_bust(total):
		_log("player %d BUSTED at %d" % [actor, total], "#c0554e")
		pile.reveal_all()
		await _pause()
		var taken := pile.collect_all(SharedPile.ClearReason.BUST)
		_log("player %d picks up %d cards" % [actor, taken.size()], "#c0554e")
	else:
		_current_player = 1 - _current_player
		
	_refresh()

func _call_bluff() -> void:
	if _busy:
		return
	var result := pile.resolve_bluff_call(_current_player)
	if result == null:
		_log("Nothing callable right now", "#7f8a83")
		return
	
	await _pause()
	var taken := pile.collect_all(SharedPile.ClearReason.BLUFF_CALL)
	_log("player %d picks up %d cards" % [result.loser_id, taken.size()], "#c0554e")
	_current_player = 1 - _current_player
	_refresh()

func _new_round() -> void:
	_log("New round. %d cards returned." % pile.reset_for_new_round().size(), "#4f9e86")
	_current_player = 0
	_refresh()

func _pause() -> void:
	_busy = true
	await get_tree().create_timer(resolve_delay).timeout
	_busy = false
	
func _make_instance(value: int) -> CardInstance:
	var res: CardResource = load(CARD_RESOURCE_PATH % value)
	_next_instance_id += 1
	return CardInstance.new(res, _next_instance_id)

func _refresh() -> void:
	
	readout.text = "\n".join([
		"TURN player %d" % _current_player,
		"Total %d (bust over %d)" % [pile.get_total(), pile.rules.bust_threshold],
	])
	
func _log(text: String, color := "#e3e8e3") -> void:
	log_box.append_text("[color=%s]%s[/color]\n" % [color, text])
	
func _on_card_added(entry: PileEntry) -> void:
	var card: Card = CARD_SCENE.instantiate()
	pile_cards.add_child(card)
	card.setup(entry.instance)
	card.scale = card_scale
	card.position = card_step * float(entry.play_index)
	card.z_index = entry.play_index
	card.card_area.input_pickable = false
	
	if entry.face_down:
		card.set_face_down()
	_card_nodes[entry] = card
	_log("player %d plays %s" % [ entry.owner_id, "face-down" if entry.face_down else str(entry.actual_value())])

func _on_card_revealed(entry: PileEntry) -> void:
	var card: Card = _card_nodes.get(entry)
	if card == null:
		return
		
	card.front_face.visible = true
	card.back_face.visible = false
	card.modulate = Color("RED") if pile.is_lie(entry) else Color("GREEN")
	
	_log(" revealed player %d: %d (%s)" % [entry.owner_id, entry.actual_value(), "LIE" if pile.is_lie(entry) else "legal"], "#d08c30")
	
func _on_pile_cleared(reason: SharedPile.ClearReason, count: int) -> void:
	_log("Pile cleared: %s (%d cards)" % [SharedPile.ClearReason.keys()[reason], count], "#7f8a83")
	for card in _card_nodes.values():
		card.queue_free()
	_card_nodes.clear()
