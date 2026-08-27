class_name CallBluffPrompt
extends CanvasLayer

signal closed(did_call: bool)
@export var window_seconds := 7.0

@onready var root: Control = $Root
@onready var prompt_label: Label = $Root/Group/Label
@onready var timer_bar: TextureProgressBar = $Root/Group/ProgressBar
@onready var call_button : Button = $Root/Group/CallButton

var _time_left := 0.0
var _active := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root.visible = false
	set_process(false)
	call_button.pressed.connect(_on_call_pressed)


func open(accused_name: String, duration := -1.0) -> void:
	_time_left = duration if duration > 0.0 else window_seconds
	prompt_label.text = "%s played a card face down" % accused_name
	timer_bar.max_value = _time_left
	timer_bar.value = _time_left
	root.visible = true
	_active = true
	set_process(true)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_time_left -= delta
	timer_bar.value = maxf(_time_left, 0.0)
	if _time_left <= 0.0:
		_finish(false)
	
func _on_call_pressed() -> void:
	_finish(true)

func _finish(did_call: bool) -> void:
	if not _active:
		return
	_active = false
	set_process(false)
	root.visible = false
	closed.emit(did_call)
