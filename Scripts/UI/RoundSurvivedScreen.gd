class_name RoundSurvivedScreen
extends CanvasLayer

signal choice_made(wants_store: bool)
@onready var store_button: Button = $Buttons/StoreButton
@onready var next_button: Button = $Buttons/NextRoundButton
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	store_button.pressed.connect(_on_store_pressed)
	next_button.pressed.connect(_on_next_pressed)

func prompt() -> bool:
	visible = true
	var wants_store: bool = await choice_made
	visible = false
	return wants_store
	
func _on_store_pressed() -> void:
	choice_made.emit(true)
	Wwise.post_event("Shop",SoundManager)
	Wwise.post_event("Click",self)
	Wwise.post_event("Shopkeep",self)
	
func _on_next_pressed() -> void:
	Wwise.post_event("Click",self)
	choice_made.emit(false)
