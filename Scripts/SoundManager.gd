extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Wwise.register_game_obj(self,self.name)
	Wwise.load_bank("Game")
	Wwise.add_default_listener(self)
	Wwise.post_event("Game_Open",self)
