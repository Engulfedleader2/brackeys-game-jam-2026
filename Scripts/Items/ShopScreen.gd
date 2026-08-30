class_name ShopScreen
extends CanvasLayer

signal closed

@export var stock: Array[ItemResource] = []
@export var allow_duplicate_purchases := true

@onready var root: Control = $Root
@onready var buttons_label: Label = $Root/CurrencyBox/HBoxContainer/ButtonLabel
@onready var grid: GridContainer = $Root/Split/MarginContainer/ItemRect/Margin/Column/Grid
@onready var back_button: Button = $Root/BackButton

var _buy_buttons: Array[Button] = []
var _player: Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	root.visible = false
	back_button.pressed.connect(_on_back_pressed)
	
	for i in grid.get_child_count():
		var card := grid.get_child(i)
		var buy := card.find_child("BuyButton", true, false) as Button
		if buy == null:
			push_warning("[Shopp] Item %s has no BuyButton" % card.name)
			continue
		buy.pressed.connect(_on_buy_pressed.bind(i))
		_buy_buttons.append(buy)
		
		var has_item := i < stock.size() and stock[i] != null
		card.visible = has_item
		if not has_item:
			continue
		var item: ItemResource = stock[i]
		buy.icon = item.icon
		buy.tooltip_text = item.description
		
		_set_label(card, "NameLabel", item.display_name)
		_set_label(card, "Description", item.description)
		_set_label(card, "CostLabel", "Cost: %d" % item.cost)

func _set_label(card: Node, node_name: String, text: String) -> void:
	var label := card.find_child(node_name, true, false) as Label
	if label != null:
		label.text = text
		
func open(player: Player) -> void:
	_player = player
	_refresh()
	visible = true
	root.visible = true

func _refresh() -> void:
	if _player == null:
		return
	buttons_label.text = "Buttons: %d" % _player.buttons
	
	for i in _buy_buttons.size():
		if i >= stock.size() or stock[i] == null:
			continue
		var item: ItemResource = stock[i]
		var sold_out := not allow_duplicate_purchases and _owned_count(item) > 0
		_buy_buttons[i].disabled = _player.buttons < item.cost or sold_out

func _on_buy_pressed(index: int) -> void:
	if _player == null or index >= stock.size():
		return
	var item: ItemResource = stock[index]
	if item == null or _player.buttons < item.cost:
		return
	if not allow_duplicate_purchases and _owned_count(item) > 0:
		return
	
	_player.buttons -= item.cost
	_player.items.append(item)
	print("[Shop] bought %s for %d (%d buttons left)" % [item.display_name, item.cost, _player.buttons])
	_refresh()

func _owned_count(item: ItemResource) -> int:
	var count := 0
	for owned in _player.items:
		if owned == item:
			count += 1
	return count

func _on_back_pressed() -> void:
	visible = false
	root.visible = false
	_player = null
	closed.emit()
	Wwise.post_event("Table",SoundManager)
