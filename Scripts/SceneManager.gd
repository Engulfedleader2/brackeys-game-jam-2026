extends Node

const MAIN_MENU := "res://Scenes/MainMenu.tscn"
const SETTINGS_MENU := "res://Scenes/SettingsMenu.tscn"
const CREDITS_MENU := "res://Scenes/CreditsMenu.tscn"
const GAME_SCENE := "res://Scenes/Game/GameTestScene.tscn"


func change_scene(scene_path: String) -> void:
	if scene_path.is_empty():
		push_error("[SceneManager] Scene path is null or empty.")
		return

	print("[SceneManager] Changing scene to ", scene_path)

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


func quit_game() -> void:
	get_tree().quit()
