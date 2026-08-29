class_name ItemController
extends Node

@export var human_path: NodePath
@export var shared_pile: SharedPile
@export var item_bar: ItemBar
@export var shop_screen: ShopScreen
@export var call_bluff_prompt: CallBluffPrompt

const ITEM_NEGATIVE_STICKER := &"negative_sticker"
const ITEM_MAGNIFYING_GLASS := &"magnifying_glass"
const ITEM_BOOKWORM := &"bookworm"
const ITEM_HALL_PASS := &"hall_pass"

var _human: Player
var _pending_item: ItemResource = null

func _ready() -> void:
	_human = get_node_or_null(human_path) as Player
	if _human == null: 
		push_error("[ItemController] human_path does not point at a Player")
		return
	if item_bar == null:
		push_error("[ItemController] No ItemBar assigned")
		return
	
	item_bar.item_activated.connect(_on_item_activated)
	item_bar.cancel_requested.connect(_cancel_targeting)
	_human.hand.card_targeted.connect(_on_card_targeted)
	_human.card_played.connect(_on_human_card_played)
	
	if shop_screen != null:
		shop_screen.closed.connect(_refresh)
	if call_bluff_prompt != null:
		call_bluff_prompt.peek_requested.connect(_on_peek_requested)
	
	RoundManager.turn_started.connect(_on_turn_started)
	RoundManager.round_finished.connect(_on_round_finished)
	
	item_bar.set_enabled(false)
	_refresh()
	
func _unhandled_input(event: InputEvent) -> void:
	if _pending_item != null and event.is_action_pressed("ui_cancel"):
		_cancel_targeting()
		get_viewport().set_input_as_handled()
	
func _refresh() -> void:
	item_bar.refresh(_human)
	if call_bluff_prompt != null:
		call_bluff_prompt.peek_available = _find_item(ITEM_MAGNIFYING_GLASS) != null

func _on_turn_started(player: Player) -> void:
	if player != _human:
		_cancel_targeting()
	item_bar.set_enabled(player == _human)

func _on_human_card_played(_instance: CardInstance, _face_down: bool) -> void:
	_cancel_targeting()
	item_bar.set_enabled(false)

func _on_round_finished(_winner_owner_id: int, _loser_owner_id: int, _human_place: int) -> void:
	_cancel_targeting()
	item_bar.set_enabled(false)

func _on_item_activated(item: ItemResource) -> void:
	if item == null or not _human.items.has(item):
		return
	if not RoundManager.is_current_player(_human):
		item_bar.show_prompt("You can only use items on your own turn")
		return
	
	_cancel_targeting()
	
	match item.target:
		ItemResource.TargetKind.CARD:
			if _human.hand.get_card_count() == 0:
				item_bar.show_prompt("No cards to use that on")
				return
			_pending_item = item
			_human.hand.targeting = true
			item_bar.show_prompt("Pick a card for the %s." % item.display_name, true)
		ItemResource.TargetKind.PLAYER:
			_pending_item = item
			var target: Player = await item_bar.open_player_picker(RoundManager.players)
			_pending_item = null
			if target != null:
				_apply_to_player(item, target)
		ItemResource.TargetKind.PILE:
			item_bar.show_prompt("The %s is used from the call prompt." % item.display_name)
		_:
			_consume(item)

func _on_card_targeted(card: Card) -> void:
	if _pending_item == null or card == null or card.instance == null:
		return
	
	var item := _pending_item
	_cancel_targeting()
	
	match item.id:
		ITEM_NEGATIVE_STICKER:
			if card.instance.negated:
				item_bar.show_prompt("That card already has a sticker.")
				return
			card.instance.negated = true
			card.refresh_sticker()
			item_bar.show_prompt("Stickered - that card is now worth %d." % card.instance.effective_value())
		ITEM_BOOKWORM:
			_human.hand.discard_card(card)
			item_bar.show_prompt("The bookworm ate a card")
		_:
			return
	_consume(item)
	if item.id == ITEM_BOOKWORM:
		RoundManager.check_round_over()
	
func _apply_to_player(item: ItemResource, target: Player) -> void:
	if  item.id != ITEM_HALL_PASS:
		return
	
	if target == _human and RoundManager.is_current_player(_human):
		_consume(item)
		item_bar.show_prompt("You passed your turn.")
		RoundManager.pass_current_turn()
		return
	
	target.skip_next_turn = true
	_consume(item)
	item_bar.show_prompt("%s will miss their next turn." % target.player_name)
	
func _on_peek_requested() -> void:
	var item := _find_item(ITEM_MAGNIFYING_GLASS)
	if item == null or shared_pile == null:
		return
	var top := shared_pile.peek_top()
	if top == null:
		return
	_consume(item)
	call_bluff_prompt.show_peek_result(shared_pile.is_lie(top))

func _consume(item: ItemResource) -> void:
	_human.items.erase(item)
	_refresh()

func _cancel_targeting() -> void:
	_pending_item = null
	if _human != null:
		_human.hand.targeting = false
	item_bar.hide_prompt()

func _find_item(item_id: StringName) -> ItemResource:
	if _human == null:
		return null
	for item in _human.items:
		if item.id == item_id:
			return item
	return null
