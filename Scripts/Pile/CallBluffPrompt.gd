class_name CallBluffPrompt
extends CanvasLayer

signal closed(did_call: bool)
signal peek_requested
@export var window_seconds := 7.0
@export var peek_display_seconds := 1.5

var peek_available := false
signal call_signal

@onready var root: Control = $Root
@onready var timer_bar: TextureProgressBar = $Root/Group/ProgressBar
@onready var call_button: Button = $Control/CallButton
@onready var skip_button: Button = $Control/Skip
@onready var peek_button: Button = $Root/Group/Peek
@onready var peek_label: Label = $Root/Group/PeekLabel



var _time_left := 0.0
var _active := false
var _paused := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Wwise.post_event("Bluff",SoundManager)
	Wwise.post_event("Stress",SoundManager)
	root.visible = false
	set_process(false)
	call_button.pressed.connect(_on_call_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	peek_button.pressed.connect(_on_peek_pressed)
	peek_button.visible = false
	peek_label.visible = false


func open(accused_name: String, duration := -1.0) -> void:
	_time_left = duration if duration > 0.0 else window_seconds
	#prompt_label.text = "%s played a card face down" % accused_name
	timer_bar.max_value = _time_left
	timer_bar.value = _time_left
	peek_button.visible = peek_available
	peek_button.disabled = false
	peek_label.visible = false
	root.visible = true
	_active = true
	_paused = false
	set_process(true)
	$Control/Skip.show()
	$Control/CallButton.show()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _paused:
		return
	_time_left -= delta
	timer_bar.value = maxf(_time_left, 0.0)
	if _time_left <= 0.0:
		Wwise.post_event("Bluff_Fail",SoundManager)
		_finish(false)

func _on_call_pressed() -> void:
	$Control/Skip.hide()
	$Control/CallButton.hide()
	Wwise.post_event("Bluff_Call",SoundManager)
	call_signal.emit()
	await get_tree().create_timer(6.1).timeout
	_finish(true)

func _finish(did_call: bool) -> void:
	if not _active:
		return
	_active = false
	set_process(false)
	root.visible = false
	peek_label.visible = false
	closed.emit(did_call)

func _on_skip_pressed() -> void:
	$Control/Skip.hide()
	$Control/CallButton.hide()
	Wwise.post_event("Bluff_Fail",SoundManager)
	_finish(false)

func _on_peek_pressed() -> void:
	Wwise.post_event("Glass",SoundManager)
	if not _active or not peek_available:
		return
	peek_button.disabled = true
	peek_requested.emit()

func show_peek_result(is_lie: bool) -> void:
	peek_label.text = "Thats a LIE." if is_lie else "Legitmate face down"
	peek_label.visible = true
	peek_button.visible = false
	_paused = true
	await get_tree().create_timer(peek_display_seconds).timeout
	_paused = false
	if not _active:
		peek_label.visible = false
