extends Node

const MAIN_MENU := "res://Scenes/MainMenu.tscn"
const SETTINGS_MENU := "res://Scenes/SettingsMenu.tscn"
const CREDITS_MENU := "res://Scenes/CreditsMenu.tscn"
const GAME_SCENE := "res://Scenes/Game/GameTestScene.tscn"
const CHARACTER_SELECT_MENU := "res://Scenes/CharacterSelectMenu.tscn"


func change_scene(scene_path: String) -> void:
	if scene_path.is_empty():
		push_error("[SceneManager] Scene path is null or empty.")
		return

	print("[SceneManager] Changing scene to ", scene_path)

	# Fade out music if AudioManager exists
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager and audio_manager.music_player.playing:
		await audio_manager.stop_music(0.3)

	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("[SceneManager] Failed to change scene to %s (error %d)" % [scene_path, error])


func go_to_main_menu() -> void:
	change_scene(MAIN_MENU)


func go_to_game() -> void:
	change_scene(GAME_SCENE)


func go_to_settings_menu() -> void:
	change_scene(SETTINGS_MENU)


func go_to_credits_menu() -> void:
	change_scene(CREDITS_MENU)


func go_to_character_select() -> void:
	change_scene(CHARACTER_SELECT_MENU)


func quit_game() -> void:
	get_tree().quit()
