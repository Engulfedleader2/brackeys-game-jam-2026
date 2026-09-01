extends MarginContainer

var index = 0
var key = []
var text1: String = "You’ll feel much better sitting between my teeth"
var text2: String = "Good little Plushies"
var text3: String = "Eeny. Meeny. Miny. Moe."
var text4: String = "Your scent is….delectable"
var text5: String = "[p][center]Why did the chicken cross the road…[/center][p][center]not to get away from me, I hope.[/center]"
var text6: String = "Mine, mine, mine. Such soft fur you got"



var final = 6
var rng = RandomNumberGenerator.new()
var random_range = randi_range(1,final)




@onready var write_text = $MarginContainer/RichTextLabel



# Called when the node enters the scene tree for the first time.
func _ready():
	randomText()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_text()


func _text():
	if index == 1:
		write_text.text = text1
	if index == 2:
		write_text.text = text2
	if index == 3:
		write_text.text = text3
	if index == 4:
		write_text.text = text4
	if index == 5:
		write_text.text = text5
	if index == 6:
		write_text.text = text6


func randomText():
	var random_range = randi_range(1,final)
	index = random_range


func _on_test_speech_new_text_signal():
	randomText()


func _on_shared_pile_speech_signal() -> void:
	show()
	get_tree().create_tween().tween_property(self,"modulate:a", 1, .1)
	randomText()


func _leave():
	get_tree().create_tween().tween_property(self,"modulate:a", 0, 1)
