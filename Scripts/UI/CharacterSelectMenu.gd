extends Control

# Each button below is a real node in the scene - UI dev can freely reposition,
# resize, restyle, or swap icons/text directly in the editor. This script only
# wires each one to the toy it selects, nothing else.

@onready var back_button: Button = $Content/VBoxContainer/BackButton

@onready var soft_chicken_button: Button = $Content/VBoxContainer/GridContainer/SoftChickenButton
@onready var cloth_carrot_button: Button = $Content/VBoxContainer/GridContainer/ClothCarrotButton
@onready var ball_chicken_button: Button = $Content/VBoxContainer/GridContainer/BallChickenButton
@onready var lamb_chop_button: Button = $Content/VBoxContainer/GridContainer/LambChopButton
@onready var dachshund_button: Button = $Content/VBoxContainer/GridContainer/DachshundButton
@onready var fox_plush_button: Button = $Content/VBoxContainer/GridContainer/FoxPlushButton
@onready var squeaky_bear_button: Button = $Content/VBoxContainer/GridContainer/SqueakyBearButton


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

	soft_chicken_button.pressed.connect(_on_toy_selected.bind(SoftChicken))
	cloth_carrot_button.pressed.connect(_on_toy_selected.bind(ClothCarrot))
	ball_chicken_button.pressed.connect(_on_toy_selected.bind(BallChicken))
	lamb_chop_button.pressed.connect(_on_toy_selected.bind(LambChop))
	dachshund_button.pressed.connect(_on_toy_selected.bind(DachshundDogPlush))
	fox_plush_button.pressed.connect(_on_toy_selected.bind(FoxPlush))
	squeaky_bear_button.pressed.connect(_on_toy_selected.bind(SqueakyBear))


func _on_toy_selected(toy_class: Script) -> void:
	CharacterSelection.select(toy_class)
	Curtain._on_main_menu_start_game_signal()


func _on_back_pressed() -> void:
	SceneManager.go_to_main_menu()
