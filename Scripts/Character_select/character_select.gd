extends Node2D
@onready var bear: Sprite2D = $Control/Bear
@onready var broc: Sprite2D = $Control/Broc
@onready var carrot: Sprite2D = $Control/Carrot
@onready var chicken: Sprite2D = $Control/Chicken
@onready var dachs: Sprite2D = $Control/Dachs
@onready var fox: Sprite2D = $Control/Fox
@onready var lamb: Sprite2D = $Control/Lamb

@onready var bear_button: Button = $Bear_Button
@onready var fox_button: Button = $Fox_Button
@onready var dachs_button: Button = $Dachs_Button
@onready var broc_button: Button = $Broc_Button
@onready var lamb_button: Button = $Lamb_Button
@onready var chicken_button: Button = $Chicken_Button
@onready var carrot_button: Button = $Carrot_Button





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Curtain._reveal()
	halfDim()



func halfDim():
	bear.modulate.a = 0
	broc.modulate.a = 0
	carrot.modulate.a = 0
	chicken.modulate.a = 0
	dachs.modulate.a = 0
	fox.modulate.a = 0
	lamb.modulate.a = 0

func _on_bear_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(bear,"modulate:a",1,.2)


func _on_bear_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(bear,"modulate:a",0,.2)


func _on_fox_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	pass # Replace with function body.


func _on_fox_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	pass # Replace with function body.


func _on_dachs_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	pass # Replace with function body.


func _on_dachs_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	pass # Replace with function body.


func _on_broc_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	pass # Replace with function body.


func _on_broc_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	pass # Replace with function body.


func _on_lamb_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	pass # Replace with function body.


func _on_lamb_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	pass # Replace with function body.


func _on_chicken_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	pass # Replace with function body.


func _on_chicken_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	pass # Replace with function body.


func _on_carrot_button_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	pass # Replace with function body.


func _on_carrot_button_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	pass # Replace with function body.
