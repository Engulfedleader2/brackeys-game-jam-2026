extends Node2D
@onready var bear: Sprite2D = $Control/Bear
@onready var broc: Sprite2D = $Control/Broc
@onready var carrot: Sprite2D = $Control/Carrot
@onready var chicken: Sprite2D = $Control/Chicken
@onready var dachs: Sprite2D = $Control/Dachs
@onready var fox: Sprite2D = $Control/Fox
@onready var lamb: Sprite2D = $Control/Lamb


@onready var all_buttons: Control = $Buttons
@onready var bear_button: Button = $Buttons/Bear_Button
@onready var fox_button: Button = $Buttons/Fox_Button
@onready var dachs_button: Button = $Buttons/Dachs_Button
@onready var broc_button: Button = $Buttons/Broc_Button
@onready var lamb_button: Button = $Buttons/Lamb_Button
@onready var chicken_button: Button = $Buttons/Chicken_Button
@onready var carrot_button: Button = $Buttons/Carrot_Button


var bear_select = false
var fox_select = false
var dachs_select = false
var broc_select = false
var lamb_select = false
var chicken_select = false
var carrot_select = false

var can_select = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Curtain._reveal()
	halfDim()

func _process(_delta: float) -> void:
	if can_select == false:
		all_buttons.hide()


func halfDim():
	bear.modulate.a = 0
	broc.modulate.a = 0
	carrot.modulate.a = 0
	chicken.modulate.a = 0
	dachs.modulate.a = 0
	fox.modulate.a = 0
	lamb.modulate.a = 0

#region Tween property for characters
func _on_bear_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(bear,"modulate:a",1,.2)


func _on_bear_button_mouse_exited() -> void:
	if bear_select == false:
		var tween = get_tree().create_tween()
		tween.tween_property(bear,"modulate:a",0,.2)


func _on_fox_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(fox,"modulate:a",1,.2)


func _on_fox_button_mouse_exited() -> void:
	if fox_select == false:
		var tween = get_tree().create_tween()
		tween.tween_property(fox,"modulate:a",0,.2)


func _on_dachs_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(dachs,"modulate:a",1,.2)


func _on_dachs_button_mouse_exited() -> void:
	if dachs_select == false:
		var tween = get_tree().create_tween()
		tween.tween_property(dachs,"modulate:a",0,.2)


func _on_broc_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(broc,"modulate:a",1,.2)


func _on_broc_button_mouse_exited() -> void:
	if broc_select == false:
		var tween = get_tree().create_tween()
		tween.tween_property(broc,"modulate:a",0,.2)


func _on_lamb_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(lamb,"modulate:a",1,.2)


func _on_lamb_button_mouse_exited() -> void:
	if lamb_select == false:
		var tween = get_tree().create_tween()
		tween.tween_property(lamb,"modulate:a",0,.2)


func _on_chicken_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(chicken,"modulate:a",1,.2)


func _on_chicken_button_mouse_exited() -> void:
	if chicken_select == false:
		var tween = get_tree().create_tween()
		tween.tween_property(chicken,"modulate:a",0,.2)


func _on_carrot_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(carrot,"modulate:a",1,.2)


func _on_carrot_button_mouse_exited() -> void:
	if carrot_select == false:
		var tween = get_tree().create_tween()
		tween.tween_property(carrot,"modulate:a",0,.2)
#endregion


#region Button pressed
func _on_bear_button_pressed() -> void:
	bear_select = true
	


func _on_fox_button_pressed() -> void:
	fox_select = true


func _on_dachs_button_pressed() -> void:
	dachs_select = true


func _on_broc_button_pressed() -> void:
	broc_select = true


func _on_lamb_button_pressed() -> void:
	lamb_select = true


func _on_chicken_button_pressed() -> void:
	chicken_select = true


func _on_carrot_button_pressed() -> void:
	carrot_select = true
#endregion
