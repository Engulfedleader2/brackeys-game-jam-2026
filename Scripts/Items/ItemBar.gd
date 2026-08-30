class_name ItemBar
extends CanvasLayer


signal item_activated(item: ItemResource)
signal cancel_requested
signal player_chosen(player: Player)

@export var  box_label := "ITEMS"

@onready var root: Control = $Root
@onready var item_button: Button = $Root/Box/ItemsButton
@onready var panel: PanelContainer = $Root/Box/Panel
@onready var slots: VBoxContainer = $Root/Box/Panel/Margin/Column/Slots
@onready var empty_label: Label = $Root/Box/Panel/Margin/Column/EmptyLabel
@onready var prompt_label: Label = $Root/PromptBar/Prompt
@onready var cancel_button: Button = $Root/PromptBar/CancelButton
@onready var picker: PanelContainer = $Root/PlayerPicker
@onready var picker_list: VBoxContainer = $Root/PlayerPicker/Margin/List

var _can_use := false
var _item_count := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel.visible = false
	picker.visible = false
	prompt_label.text = ""
	cancel_button.visible = false
	item_button.pressed.connect(_on_items_button_pressed)
	cancel_button.pressed.connect(func(): cancel_requested.emit())

func is_open() -> bool:
	return panel.visible

func set_open(open: bool) -> void:
	panel.visible = open

func _on_items_button_pressed() -> void:
	Wwise.post_event("Click",self)
	set_open(not panel.visible)

func refresh(player: Player) -> void:
	for child in slots.get_children():
		child.queue_free()
	_item_count = player.items.size() if player != null else 0
	item_button.text = ""
	item_button.tooltip_text = "%s (%d)" % [box_label, _item_count]
	empty_label.visible = _item_count == 0
	
	if player == null:
		return
	
	var counts: Dictionary = {}
	var order: Array[ItemResource] =[]
	for item in player.items:
		if not counts.has(item):
			counts[item] = 0
			order.append(item)
		counts[item] += 1
	
	for item in order:
		var button := Button.new()
		var count: int = counts[item]
		button.text = item.display_name if count == 1 else "%s x%d" % [item.display_name, count]
		button.tooltip_text = item.description
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if item.icon != null:
			button.icon = item.icon
		button.disabled = not _can_use
		button.pressed.connect(func(): _on_slot_pressed(item))
		slots.add_child(button)
	if _item_count == 0:
		set_open(false)

func _on_slot_pressed(item: ItemResource) -> void:
	set_open(false)
	item_activated.emit(item)

func set_enabled(enabled: bool) -> void:
	_can_use = enabled
	for  child in slots.get_children():
		if child is Button:
			child.disabled = not enabled
	if not enabled:
		hide_prompt()
		close_player_picker()

func show_prompt(text: String, cancellable := false) -> void:
	prompt_label.text = text
	cancel_button.visible = false

func hide_prompt() -> void:
	prompt_label.text = ""
	cancel_button.visible = false 

func open_player_picker(players: Array[Player]) -> Player:
	for child in picker_list.get_children():
		child.queue_free()
	
	for p in players:
		var button := Button.new()
		button.text = p.player_name
		button.pressed.connect(func(): player_chosen.emit(p))
		picker_list.add_child(button)
	
	var cancel := Button.new()
	cancel.text = "Cancel"
	cancel.pressed.connect(func(): player_chosen.emit(null))
	picker_list.add_child(cancel)
	
	picker.visible = true
	var chosen: Player = await player_chosen
	picker.visible = false
	return chosen
	
func close_player_picker() -> void:
	if picker.visible:
		picker.visible = false 
		player_chosen.emit(null)
