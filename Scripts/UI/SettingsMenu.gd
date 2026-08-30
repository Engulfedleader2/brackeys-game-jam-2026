extends Control

@onready var master_toggle: CheckButton = $Content/Settings/MasterToggle
@onready var music_volume_slider: HSlider = $Content/Settings/MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = $Content/Settings/SfxVolumeSlider
@onready var vox_volume_slider: HSlider = $Content/Settings/VoxVolumeSlider
@onready var back_button: Button = $BackButton
@onready var back_img: Sprite2D = $Back_IMG



func _ready() -> void:
	master_toggle.toggled.connect(_on_master_toggled)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	vox_volume_slider.value_changed.connect(_on_vox_volume_changed)
	back_button.pressed.connect(_on_back_button_pressed)

	Wwise.register_game_obj(self, self.name)
	Wwise.add_default_listener(SoundManager)
	Wwise.post_event("Settings", SoundManager)

	# Push the current UI state into Wwise so audio matches the menu on open.
	_on_master_toggled(master_toggle.button_pressed)
	_on_music_volume_changed(music_volume_slider.value)
	_on_sfx_volume_changed(sfx_volume_slider.value)
	_on_vox_volume_changed(vox_volume_slider.value)


# Bus RTPCs are global scope (a bus is not a game object), so pass null.
func _on_master_toggled(enabled: bool) -> void:
	Wwise.set_rtpc_value("MTR_Volume", 100.0 if enabled else 0.0, null)
	print("[SettingsMenu] Master enabled: ", enabled)


func _on_music_volume_changed(value: float) -> void:
	Wwise.set_rtpc_value("MX_Volume", value, null)


func _on_sfx_volume_changed(value: float) -> void:
	Wwise.set_rtpc_value("SFX_Volume", value, null)


func _on_vox_volume_changed(value: float) -> void:
	Wwise.set_rtpc_value("VOX_Volume", value, null)


func _on_back_button_pressed() -> void:
	Wwise.post_event("Back",SoundManager)
	Curtain._hide()
	SceneManager.go_to_main_menu()
	Wwise.post_event("Title", SoundManager)


func _on_back_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(back_img,"scale",Vector2(1.1,1.1),.1)
	get_tree().create_tween().tween_property(back_img,"modulate:a",1,.1)


func _on_back_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(back_img,"scale",Vector2(1,1),.1)
	get_tree().create_tween().tween_property(back_img,"modulate:a",.5,.1)
