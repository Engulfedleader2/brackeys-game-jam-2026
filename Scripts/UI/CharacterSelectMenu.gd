extends Control

# Each button below is a real node in the scene - UI dev can freely reposition,
# resize, restyle, or swap icons/text directly in the editor. This script only
# wires each one to the toy it selects, nothing else.

@onready var bear: Sprite2D = $Control/Bear
@onready var broc: Sprite2D = $Control/Broc
@onready var carrot: Sprite2D = $Control/Carrot
@onready var chicken: Sprite2D = $Control/Chicken
@onready var dachs: Sprite2D = $Control/Dachs
@onready var fox: Sprite2D = $Control/Fox
@onready var lamb: Sprite2D = $Control/Lamb


@onready var back_button: Button = $Content/VBoxContainer/BackButton

@onready var soft_chicken_button: Button = $SoftChickenButton
@onready var cloth_carrot_button: Button = $ClothCarrotButton
@onready var broccoli_button: Button = $BroccoliButton
@onready var lamb_chop_button: Button = $LambChopButton
@onready var dachshund_button: Button = $DachshundButton
@onready var fox_plush_button: Button = $FoxPlushButton
@onready var squeaky_bear_button: Button = $SqueakyBearButton

@onready var back_img: Sprite2D = $Back_IMG



func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

	soft_chicken_button.pressed.connect(_on_toy_selected.bind(SoftChicken))
	cloth_carrot_button.pressed.connect(_on_toy_selected.bind(ClothCarrot))
	broccoli_button.pressed.connect(_on_toy_selected.bind(Broccoli))
	lamb_chop_button.pressed.connect(_on_toy_selected.bind(LambChop))
	dachshund_button.pressed.connect(_on_toy_selected.bind(DachshundDogPlush))
	fox_plush_button.pressed.connect(_on_toy_selected.bind(FoxPlush))
	squeaky_bear_button.pressed.connect(_on_toy_selected.bind(SqueakyBear))
	halfDim()


func halfDim():
	bear.modulate.a = 0
	broc.modulate.a = 0
	carrot.modulate.a = 0
	chicken.modulate.a = 0
	dachs.modulate.a = 0
	fox.modulate.a = 0
	lamb.modulate.a = 0

func _disableButton():
	$SoftChickenButton.hide()
	$ClothCarrotButton.hide()
	$BroccoliButton.hide()
	$LambChopButton.hide()
	$DachshundButton.hide()
	$FoxPlushButton.hide()
	$SqueakyBearButton.hide()
	$BackButton.hide()

func _on_toy_selected(toy_class: Script) -> void:
	_disableButton()
	CharacterSelection.select(toy_class)
	Curtain._on_main_menu_start_game_signal()


func _on_back_pressed() -> void:
	SceneManager.go_to_main_menu()


func _on_soft_chicken_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(chicken,"modulate:a",1,.2)


func _on_soft_chicken_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(chicken,"modulate:a",0,.2)


func _on_cloth_carrot_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(carrot,"modulate:a",1,.2)


func _on_cloth_carrot_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(carrot,"modulate:a",0,.2)


func _on_broccoli_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(broc,"modulate:a",1,.2)


func _on_broccoli_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(broc,"modulate:a",0,.2)


func _on_lamb_chop_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(lamb,"modulate:a",1,.2)


func _on_lamb_chop_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(lamb,"modulate:a",0,.2)


func _on_dachshund_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(dachs,"modulate:a",1,.2)


func _on_dachshund_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(dachs,"modulate:a",0,.2)


func _on_fox_plush_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(fox,"modulate:a",1,.2)


func _on_fox_plush_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(fox,"modulate:a",0,.2)


func _on_squeaky_bear_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(bear,"modulate:a",1,.2)


func _on_squeaky_bear_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(bear,"modulate:a",0,.2)




func _on_back_button_mouse_entered() -> void:
	get_tree().create_tween().tween_property(back_img,"scale",Vector2(1.1,1.1),.1)
	get_tree().create_tween().tween_property(back_img,"modulate:a",1,.1)


func _on_back_button_mouse_exited() -> void:
	get_tree().create_tween().tween_property(back_img,"scale",Vector2(1,1),.1)
	get_tree().create_tween().tween_property(back_img,"modulate:a",.5,.1)


func _on_back_button_pressed() -> void:
	SceneManager.go_to_main_menu()
