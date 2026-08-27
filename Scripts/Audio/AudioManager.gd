extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

func _ready() -> void:
	# Prevent this node from being freed when scenes change
	add_to_group("persist")
	print("[AudioManager] initialized")

func play_music(audio_stream: AudioStream, loop: bool = true) -> void:
	if music_player.stream == audio_stream and music_player.playing:
		return
	music_player.stream = audio_stream
	music_player.bus = &"Music"
	if loop:
		music_player.bus = &"Music"
	music_player.play()

func stop_music(fade_duration: float = 0.5) -> void:
	if fade_duration > 0:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, fade_duration)
		await tween.finished
	music_player.stop()
	music_player.volume_db = 0

func play_sfx(audio_stream: AudioStream) -> void:
	sfx_player.stream = audio_stream
	sfx_player.bus = &"SFX"
	sfx_player.play()

func set_music_volume(volume_db: float) -> void:
	music_player.volume_db = volume_db

func set_sfx_volume(volume_db: float) -> void:
	sfx_player.volume_db = volume_db
